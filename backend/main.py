from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from typing import Optional, Dict
from pydantic import BaseModel
import logging
import json
import asyncio
import tempfile
import os

from config import settings
from database.connection import get_econtrols_db, get_mykri_db, init_databases, close_databases
from agents.sql_agent import RAGBasedAgent
from services.rag_client import RAGClient
from services.audit_service import AuditService

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
rag_agent = RAGBasedAgent()
rag_client = RAGClient()

# ==================== Pydantic Models ====================

class UserContext(BaseModel):
    user_id: int
    username: str
    email: str
    ou: str
    lre: str
    country: str
    role: str = "user"

class ChatRequest(BaseModel):
    query: str
    user_context: UserContext
    use_streaming: bool = False

class DocumentUploadRequest(BaseModel):
    document_name: str
    application: str  # "eControls" or "MyKRI" or "General"
    metadata: Optional[Dict] = None

class QueryExecutionRequest(BaseModel):
    sql_query: str
    application: str
    user_context: UserContext
    confirmed: bool = False

# ==================== Startup/Shutdown Events ====================

@app.on_event("startup")
async def startup_event():
    """Initialize databases on startup"""
    logger.info("Starting application...")
    await init_databases()
    
    # Test RAG connectivity
    is_healthy = await rag_client.health_check()
    if is_healthy:
        logger.info("RAG API connection successful")
    else:
        logger.warning("RAG API connection failed - some features may not work")
    
    logger.info("Application started successfully")

@app.on_event("shutdown")
async def shutdown_event():
    """Close database connections on shutdown"""
    logger.info("Shutting down application...")
    await close_databases()
    logger.info("Application shut down successfully")

# ==================== Health Check ====================

@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    rag_healthy = await rag_client.health_check()
    
    return {
        "status": "healthy",
        "version": settings.APP_VERSION,
        "rag_api_connected": rag_healthy,
        "timestamp": "2024-01-01T00:00:00Z"
    }

# ==================== Chat Endpoint ====================

@app.post("/api/chat")
async def chat(
    request: ChatRequest,
    econtrols_db: AsyncSession = Depends(get_econtrols_db),
    mykri_db: AsyncSession = Depends(get_mykri_db)
):
    """
    Main chat endpoint - handles all queries
    
    Flow:
    1. Classify intent using RAG
    2. Generate SQL using RAG
    3. Check if confirmation needed
    4. Execute query (if safe or confirmed)
    5. Log to audit
    6. Generate response using RAG
    """
    try:
        # Step 1: Classify intent
        classification = await rag_agent.classify_intent(
            request.query,
            request.user_context.dict()
        )
        
        logger.info(f"Query classified: {classification}")
        
        # Step 2: Handle RAG-only queries (no database)
        if classification["application"] == "RAG_ONLY":
            # Query only RAG documents
            rag_result = await rag_client.query_rag(
                query=request.query,
                top_k=5
            )
            
            response_text = await rag_agent.generate_response(
                query_result=None,
                original_query=request.query,
                rag_context=rag_result.get("context", "")
            )
            
            return {
                "response": response_text,
                "sources": rag_result.get("sources", []),
                "classification": classification
            }
        
        # Step 3: Generate SQL query with user context
        sql_info = await rag_agent.generate_sql_query(
            user_query=request.query,
            application=classification["application"],
            user_context=request.user_context.dict(),
            intent=classification["intent"]
        )
        
        # Step 4: Check if confirmation needed (CRITICAL SAFETY CHECK)
        if classification.get("requires_confirmation") and classification["intent"] in ["WRITE", "DELETE"]:
            logger.info(f"Query requires confirmation: {sql_info['sql_query']}")
            return {
                "requires_confirmation": True,
                "sql_query": sql_info["sql_query"],
                "application": classification["application"],
                "message": f"This operation will modify data in {classification['application']}. Please confirm to proceed.",
                "classification": classification
            }
        
        # Step 5: Execute query (auto-execute for READ, or if already confirmed)
        db_session = econtrols_db if classification["application"] == "eControls" else mykri_db
        
        try:
            result = await db_session.execute(text(sql_info["sql_query"]))
            
            if classification["intent"] == "READ":
                rows = result.fetchall()
                query_result = [dict(row._mapping) for row in rows]
            else:
                await db_session.commit()
                query_result = {"affected_rows": result.rowcount}
            
            # Step 6: Log audit (successful operation)
            await AuditService.log_operation(
                session=db_session,
                user_id=request.user_context.user_id,
                username=request.user_context.username,
                application=classification["application"],
                operation=classification["intent"],
                table_name="multi_table_query",
                query_executed=sql_info["sql_query"],
                success=True
            )
            
        except Exception as db_error:
            logger.error(f"Database error: {db_error}")
            
            # Log failed operation
            await AuditService.log_operation(
                session=db_session,
                user_id=request.user_context.user_id,
                username=request.user_context.username,
                application=classification["application"],
                operation=classification["intent"],
                table_name="multi_table_query",
                query_executed=sql_info["sql_query"],
                success=False,
                error_message=str(db_error)
            )
            
            raise HTTPException(status_code=500, detail=f"Database error: {str(db_error)}")
        
        # Step 7: Get additional RAG context (optional)
        rag_result = await rag_client.query_rag(
            query=request.query,
            top_k=3
        )
        
        # Step 8: Generate natural language response
        response_text = await rag_agent.generate_response(
            query_result=query_result,
            original_query=request.query,
            rag_context=rag_result.get("context", "")
        )
        
        return {
            "response": response_text,
            "data": query_result if classification["intent"] == "READ" else None,
            "sql_executed": sql_info["sql_query"],
            "sources": rag_result.get("sources", []),
            "classification": classification
        }
        
    except Exception as e:
        logger.error(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ==================== Streaming Chat Endpoint ====================

@app.post("/api/chat/stream")
async def chat_stream(
    request: ChatRequest,
    econtrols_db: AsyncSession = Depends(get_econtrols_db),
    mykri_db: AsyncSession = Depends(get_mykri_db)
):
    """Streaming chat endpoint"""
    
    async def generate_stream():
        try:
            # Classify intent
            yield f"data: {json.dumps({'type': 'status', 'message': 'Analyzing query...'})}\n\n"
            
            classification = await rag_agent.classify_intent(
                request.query,
                request.user_context.dict()
            )
            
            yield f"data: {json.dumps({'type': 'classification', 'data': classification})}\n\n"
            
            # Handle RAG only
            if classification["application"] == "RAG_ONLY":
                yield f"data: {json.dumps({'type': 'status', 'message': 'Searching documents...'})}\n\n"
                
                async for chunk in rag_client.query_rag_stream(request.query):
                    yield f"data: {json.dumps({'type': 'content', 'chunk': chunk})}\n\n"
                
                yield "data: [DONE]\n\n"
                return
            
            # Generate SQL
            yield f"data: {json.dumps({'type': 'status', 'message': 'Generating query...'})}\n\n"
            
            sql_info = await rag_agent.generate_sql_query(
                user_query=request.query,
                application=classification["application"],
                user_context=request.user_context.dict(),
                intent=classification["intent"]
            )
            
            # Execute query
            yield f"data: {json.dumps({'type': 'status', 'message': 'Executing query...'})}\n\n"
            
            db_session = econtrols_db if classification["application"] == "eControls" else mykri_db
            result = await db_session.execute(text(sql_info["sql_query"]))
            
            if classification["intent"] == "READ":
                rows = result.fetchall()
                query_result = [dict(row._mapping) for row in rows]
            else:
                await db_session.commit()
                query_result = {"affected_rows": result.rowcount}
            
            # Generate response
            yield f"data: {json.dumps({'type': 'status', 'message': 'Generating response...'})}\n\n"
            
            response_text = await rag_agent.generate_response(
                query_result=query_result,
                original_query=request.query
            )
            
            # Stream response in chunks
            words = response_text.split()
            for i in range(0, len(words), 5):
                chunk = ' '.join(words[i:i+5])
                yield f"data: {json.dumps({'type': 'content', 'chunk': chunk + ' '})}\n\n"
                await asyncio.sleep(0.05)
            
            yield f"data: {json.dumps({'type': 'data', 'result': query_result})}\n\n"
            yield "data: [DONE]\n\n"
            
        except Exception as e:
            logger.error(f"Streaming error: {e}")
            yield f"data: {json.dumps({'type': 'error', 'message': str(e)})}\n\n"
    
    return StreamingResponse(
        generate_stream(),
        media_type="text/event-stream"
    )

# ==================== Document Upload ====================

@app.post("/api/documents/upload")
async def upload_document(
    file: UploadFile = File(...),
    application: str = "General",
    metadata: Optional[str] = None
):
    """Upload document to RAG system"""
    try:
        # Save file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename)[1]) as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        # Parse metadata
        meta_dict = json.loads(metadata) if metadata else {}
        meta_dict["application"] = application
        
        # Upload to RAG
        result = await rag_client.upload_document(
            file_path=tmp_path,
            document_name=file.filename,
            metadata=meta_dict
        )
        
        # Clean up
        os.unlink(tmp_path)
        
        return result
        
    except Exception as e:
        logger.error(f"Document upload error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ==================== Get User Context ====================

@app.get("/api/user/context/{user_id}")
async def get_user_context(
    user_id: int,
    application: str,
    econtrols_db: AsyncSession = Depends(get_econtrols_db),
    mykri_db: AsyncSession = Depends(get_mykri_db)
):
    """Get user context (OU, LRE, Country) from database"""
    try:
        db_session = econtrols_db if application == "eControls" else mykri_db
        
        query = text("""
            SELECT user_id, username, email, user_ou, user_lre, user_country
            FROM users
            WHERE user_id = :user_id AND is_active = true
        """)
        
        result = await db_session.execute(query, {"user_id": user_id})
        user = result.fetchone()
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {
            "user_id": user.user_id,
            "username": user.username,
            "email": user.email,
            "ou": user.user_ou,
            "lre": user.user_lre,
            "country": user.user_country
        }
        
    except Exception as e:
        logger.error(f"Error fetching user context: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)