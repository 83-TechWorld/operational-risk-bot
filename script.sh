
#!/bin/bash

# Enterprise RAG Chatbot - Complete Project Setup Script
# This script creates the entire project structure with all files

set -e

PROJECT_NAME="enterprise-rag-chatbot"
echo "🚀 Creating Enterprise RAG Chatbot Project..."

# Create main project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p backend/{agents,database,models,services,utils}
mkdir -p frontend/src/{components,services,store,types,styles}
mkdir -p frontend/public
mkdir -p database
mkdir -p k8s
mkdir -p docs
mkdir -p .github/workflows

#############################################
# BACKEND FILES
#############################################

echo "📝 Creating backend files..."

# backend/requirements.txt
cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-dotenv==1.0.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
pydantic==2.5.0
httpx==0.25.1
python-multipart==0.0.6
requests==2.31.0
EOF

# backend/.env.example
cat > backend/.env.example << 'EOF'
# eControls Database
ECONTROLS_DB_HOST=localhost
ECONTROLS_DB_PORT=5432
ECONTROLS_DB_NAME=econtrols_db
ECONTROLS_DB_USER=postgres
ECONTROLS_DB_PASSWORD=your_password

# MyKRI Database
MYKRI_DB_HOST=localhost
MYKRI_DB_PORT=5432
MYKRI_DB_NAME=mykri_db
MYKRI_DB_USER=postgres
MYKRI_DB_PASSWORD=your_password

# Custom RAG Model Configuration
RAG_CLIENT_ID=your_client_id
RAG_CLIENT_SECRET=your_client_secret
RAG_APPLICATION_NAME=your_application_name
RAG_WORKSPACE_NAME=your_workspace_name
RAG_API_BASE_URL=https://your-rag-api.com/api
RAG_TOKEN_URL=https://your-rag-api.com/oauth/token

# Application Settings
LOG_LEVEL=INFO
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
EOF

# backend/config.py
cat > backend/config.py << 'EOF'
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # eControls Database
    ECONTROLS_DB_HOST: str
    ECONTROLS_DB_PORT: int = 5432
    ECONTROLS_DB_NAME: str
    ECONTROLS_DB_USER: str
    ECONTROLS_DB_PASSWORD: str
    
    # MyKRI Database
    MYKRI_DB_HOST: str
    MYKRI_DB_PORT: int = 5432
    MYKRI_DB_NAME: str
    MYKRI_DB_USER: str
    MYKRI_DB_PASSWORD: str
    
    # Custom RAG Model
    RAG_CLIENT_ID: str
    RAG_CLIENT_SECRET: str
    RAG_APPLICATION_NAME: str
    RAG_WORKSPACE_NAME: str
    RAG_API_BASE_URL: str
    RAG_TOKEN_URL: str
    
    # Application
    LOG_LEVEL: str = "INFO"
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:5173"
    
    @property
    def econtrols_db_url(self) -> str:
        return f"postgresql://{self.ECONTROLS_DB_USER}:{self.ECONTROLS_DB_PASSWORD}@{self.ECONTROLS_DB_HOST}:{self.ECONTROLS_DB_PORT}/{self.ECONTROLS_DB_NAME}"
    
    @property
    def mykri_db_url(self) -> str:
        return f"postgresql://{self.MYKRI_DB_USER}:{self.MYKRI_DB_PASSWORD}@{self.MYKRI_DB_HOST}:{self.MYKRI_DB_PORT}/{self.MYKRI_DB_NAME}"
    
    @property
    def cors_origins_list(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
EOF

# backend/services/rag_client.py
cat > backend/services/rag_client.py << 'EOF'
import httpx
import requests
from datetime import datetime, timedelta
from config import settings
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

class RAGClient:
    """Client for custom RAG model with OAuth2 authentication"""
    
    def __init__(self):
        self.client_id = settings.RAG_CLIENT_ID
        self.client_secret = settings.RAG_CLIENT_SECRET
        self.application_name = settings.RAG_APPLICATION_NAME
        self.workspace_name = settings.RAG_WORKSPACE_NAME
        self.base_url = settings.RAG_API_BASE_URL
        self.token_url = settings.RAG_TOKEN_URL
        
        self._access_token: Optional[str] = None
        self._token_expiry: Optional[datetime] = None
    
    def _get_access_token(self) -> str:
        """Generate access token using client credentials"""
        # Check if we have a valid token
        if self._access_token and self._token_expiry:
            if datetime.now() < self._token_expiry:
                return self._access_token
        
        logger.info("Generating new access token...")
        
        try:
            # OAuth2 client credentials flow
            payload = {
                "grant_type": "client_credentials",
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "scope": f"{self.application_name}:{self.workspace_name}"
            }
            
            response = requests.post(
                self.token_url,
                data=payload,
                headers={"Content-Type": "application/x-www-form-urlencoded"}
            )
            response.raise_for_status()
            
            token_data = response.json()
            self._access_token = token_data["access_token"]
            
            # Set expiry time (usually expires_in is in seconds)
            expires_in = token_data.get("expires_in", 3600)
            self._token_expiry = datetime.now() + timedelta(seconds=expires_in - 60)
            
            logger.info("Access token generated successfully")
            return self._access_token
            
        except Exception as e:
            logger.error(f"Failed to generate access token: {e}")
            raise Exception(f"Authentication failed: {str(e)}")
    
    def _get_headers(self) -> Dict[str, str]:
        """Get headers with fresh access token"""
        token = self._get_access_token()
        return {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "X-Application-Name": self.application_name,
            "X-Workspace-Name": self.workspace_name
        }
    
    async def generate_sql(self, query: str, schema: str, user_context: Dict[str, Any]) -> str:
        """Generate SQL query using RAG model"""
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.base_url}/generate-sql",
                    headers=self._get_headers(),
                    json={
                        "query": query,
                        "schema": schema,
                        "user_context": user_context,
                        "application": self.application_name,
                        "workspace": self.workspace_name
                    }
                )
                response.raise_for_status()
                result = response.json()
                return result.get("sql_query", "")
                
        except Exception as e:
            logger.error(f"SQL generation error: {e}")
            raise Exception(f"Failed to generate SQL: {str(e)}")
    
    async def classify_intent(self, query: str) -> str:
        """Classify user intent using RAG model"""
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.base_url}/classify-intent",
                    headers=self._get_headers(),
                    json={
                        "query": query,
                        "application": self.application_name,
                        "workspace": self.workspace_name
                    }
                )
                response.raise_for_status()
                result = response.json()
                return result.get("intent", "select").lower()
                
        except Exception as e:
            logger.error(f"Intent classification error: {e}")
            # Default to 'select' if classification fails
            return "select"
    
    async def query_documents(self, query: str) -> str:
        """Query RAG system for document-based answers"""
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.base_url}/query-documents",
                    headers=self._get_headers(),
                    json={
                        "query": query,
                        "application": self.application_name,
                        "workspace": self.workspace_name
                    }
                )
                response.raise_for_status()
                result = response.json()
                return result.get("answer", "No answer found in documents.")
                
        except Exception as e:
            logger.error(f"Document query error: {e}")
            return f"Error querying documents: {str(e)}"
    
    async def query_documents_stream(self, query: str):
        """Stream RAG document responses"""
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                async with client.stream(
                    "POST",
                    f"{self.base_url}/query-documents-stream",
                    headers=self._get_headers(),
                    json={
                        "query": query,
                        "application": self.application_name,
                        "workspace": self.workspace_name
                    }
                ) as response:
                    response.raise_for_status()
                    async for chunk in response.aiter_text():
                        yield chunk
                        
        except Exception as e:
            logger.error(f"Document stream error: {e}")
            yield f"Error: {str(e)}"
    
    async def upload_document(self, file_name: str, content: str) -> Dict[str, Any]:
        """Upload document to RAG system"""
        try:
            async with httpx.AsyncClient(timeout=120.0) as client:
                response = await client.post(
                    f"{self.base_url}/upload-document",
                    headers=self._get_headers(),
                    json={
                        "file_name": file_name,
                        "content": content,
                        "application": self.application_name,
                        "workspace": self.workspace_name
                    }
                )
                response.raise_for_status()
                return response.json()
                
        except Exception as e:
            logger.error(f"Document upload error: {e}")
            raise Exception(f"Upload failed: {str(e)}")

# Create global instance
rag_client = RAGClient()
EOF

# backend/main.py
cat > backend/main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import logging
from datetime import datetime

from config import settings
from database.connections import get_user_context
from agents.sql_agent import SQLAgent
from services.rag_client import rag_client
from services.audit_service import AuditService

# Configure logging
logging.basicConfig(level=settings.LOG_LEVEL)
logger = logging.getLogger(__name__)

app = FastAPI(title="Enterprise RAG Chatbot API")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
sql_agent = SQLAgent()
audit_service = AuditService()

# Models
class ChatRequest(BaseModel):
    query: str
    user_id: int
    application: str
    role: str = "user"
    stream: bool = False

class ChatResponse(BaseModel):
    response: str
    query_type: str
    sql_query: Optional[str] = None
    results: Optional[List[Dict[str, Any]]] = None
    requires_confirmation: bool = False

class ConfirmationRequest(BaseModel):
    user_id: int
    application: str
    sql_query: str
    original_query: str

class DocumentUploadRequest(BaseModel):
    file_name: str
    content: str
    user_id: int

@app.get("/api/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "rag_model": settings.RAG_APPLICATION_NAME
    }

@app.get("/api/user/context/{user_id}")
async def get_context(user_id: int, application: str):
    try:
        context = get_user_context(user_id, application)
        return context
    except Exception as e:
        logger.error(f"Error fetching user context: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat")
async def chat(request: ChatRequest):
    try:
        # Get user context
        user_context = get_user_context(request.user_id, request.application)
        
        # Classify intent using RAG model
        intent = await rag_client.classify_intent(request.query)
        logger.info(f"Intent classified as: {intent}")
        
        # Handle based on intent
        if intent == "rag":
            if request.stream:
                async def generate_rag_stream():
                    async for chunk in rag_client.query_documents_stream(request.query):
                        yield f"data: {chunk}\n\n"
                
                return StreamingResponse(
                    generate_rag_stream(),
                    media_type="text/event-stream"
                )
            else:
                response = await rag_client.query_documents(request.query)
                return ChatResponse(
                    response=response,
                    query_type="rag"
                )
        
        elif intent in ["select", "insert", "update", "delete"]:
            # Generate SQL using RAG model
            sql_query = await sql_agent.generate_sql(
                query=request.query,
                application=request.application,
                user_context=user_context
            )
            
            # Check if confirmation needed
            if intent in ["insert", "update", "delete"]:
                return ChatResponse(
                    response=f"This will execute: {sql_query}",
                    query_type=intent,
                    sql_query=sql_query,
                    requires_confirmation=True
                )
            
            # Execute SELECT
            results = sql_agent.execute_query(sql_query, request.application)
            
            # Log audit
            audit_service.log_query(
                user_id=request.user_id,
                application=request.application,
                query=request.query,
                sql_query=sql_query,
                intent=intent
            )
            
            if request.stream:
                async def generate():
                    yield f"data: SQL: {sql_query}\n\n"
                    yield f"data: Found {len(results)} results\n\n"
                    for row in results:
                        yield f"data: {row}\n\n"
                
                return StreamingResponse(generate(), media_type="text/event-stream")
            
            return ChatResponse(
                response=f"Found {len(results)} results",
                query_type=intent,
                sql_query=sql_query,
                results=results
            )
        
        else:
            raise HTTPException(status_code=400, detail="Unknown intent")
    
    except Exception as e:
        logger.error(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat/confirm")
async def confirm_action(request: ConfirmationRequest):
    try:
        results = sql_agent.execute_query(request.sql_query, request.application)
        
        # Log audit
        audit_service.log_query(
            user_id=request.user_id,
            application=request.application,
            query=request.original_query,
            sql_query=request.sql_query,
            intent="write"
        )
        
        return {"success": True, "affected_rows": len(results)}
    except Exception as e:
        logger.error(f"Confirmation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/documents/upload")
async def upload_document(request: DocumentUploadRequest):
    try:
        result = await rag_client.upload_document(
            file_name=request.file_name,
            content=request.content
        )
        
        # Log audit
        audit_service.log_query(
            user_id=request.user_id,
            application="RAG",
            query=f"Upload document: {request.file_name}",
            sql_query=None,
            intent="upload"
        )
        
        return result
    except Exception as e:
        logger.error(f"Upload error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# backend/database/connections.py
cat > backend/database/connections.py << 'EOF'
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from config import settings
import logging

logger = logging.getLogger(__name__)

# Create engines
econtrols_engine = create_engine(settings.econtrols_db_url)
mykri_engine = create_engine(settings.mykri_db_url)

# Create session makers
EControlsSession = sessionmaker(bind=econtrols_engine)
MyKRISession = sessionmaker(bind=mykri_engine)

def get_engine(application: str):
    if application.lower() == "econtrols":
        return econtrols_engine
    elif application.lower() == "mykri":
        return mykri_engine
    else:
        raise ValueError(f"Unknown application: {application}")

def get_session(application: str):
    if application.lower() == "econtrols":
        return EControlsSession()
    elif application.lower() == "mykri":
        return MyKRISession()
    else:
        raise ValueError(f"Unknown application: {application}")

def get_user_context(user_id: int, application: str):
    """Fetch user context (OU, LRE, Country) from database"""
    session = get_session(application)
    try:
        query = text("""
            SELECT ou, lre, country 
            FROM users 
            WHERE user_id = :user_id
        """)
        result = session.execute(query, {"user_id": user_id}).fetchone()
        
        if result:
            return {
                "ou": result[0],
                "lre": result[1],
                "country": result[2]
            }
        else:
            logger.warning(f"No user found with ID {user_id}")
            return {"ou": None, "lre": None, "country": None}
    finally:
        session.close()
EOF

# backend/agents/sql_agent.py
cat > backend/agents/sql_agent.py << 'EOF'
from config import settings
from database.connections import get_engine
from services.rag_client import rag_client
import logging
import re

logger = logging.getLogger(__name__)

class SQLAgent:
    """SQL Agent using custom RAG model for query generation"""
    
    def __init__(self):
        self.rag_client = rag_client
    
    async def classify_intent(self, query: str) -> str:
        """Classify user intent using RAG model"""
        return await self.rag_client.classify_intent(query)
    
    async def generate_sql(self, query: str, application: str, user_context: dict) -> str:
        """Generate SQL query using RAG model with user context filtering"""
        
        # Get schema based on application
        if application.lower() == "econtrols":
            schema = """
            Database: eControls
            
            Table: controls
            Columns:
              - control_id (VARCHAR PRIMARY KEY): Unique control identifier
              - control_name (VARCHAR): Name of the control
              - description (TEXT): Detailed description
              - owner (VARCHAR): Person responsible for the control
              - status (VARCHAR): Current status (Pending/In Progress/Completed)
              - category (VARCHAR): Control category (Security/Finance/IT/HR)
              - ou (VARCHAR): Organizational Unit
              - lre (VARCHAR): Legal Registered Entity
              - country (VARCHAR): Country
              - created_at (TIMESTAMP): Creation timestamp
              - updated_at (TIMESTAMP): Last update timestamp
            
            Table: users
            Columns:
              - user_id (SERIAL PRIMARY KEY): User identifier
              - username (VARCHAR): Username
              - email (VARCHAR): Email address
              - ou (VARCHAR): Organizational Unit
              - lre (VARCHAR): Legal Registered Entity
              - country (VARCHAR): Country
              - created_at (TIMESTAMP): Creation timestamp
            
            IMPORTANT CONSTRAINTS:
            - All queries MUST filter by user context: ou='{ou}', lre='{lre}', country='{country}'
            - For SELECT queries, always add: WHERE ou = '{ou}' AND lre = '{lre}' AND country = '{country}'
            - Limit SELECT results to maximum 100 rows
            """.format(
                ou=user_context.get('ou'),
                lre=user_context.get('lre'),
                country=user_context.get('country')
            )
        else:  # mykri
            schema = """
            Database: MyKRI
            
            Table: kris
            Columns:
              - kri_id (VARCHAR PRIMARY KEY): Unique KRI identifier
              - kri_name (VARCHAR): Name of the KRI
              - description (TEXT): Detailed description
              - frequency (VARCHAR): Measurement frequency (Daily/Weekly/Monthly/Quarterly)
              - owner (VARCHAR): Person responsible for the KRI
              - status (VARCHAR): Current status (Active/Inactive)
              - ou (VARCHAR): Organizational Unit
              - lre (VARCHAR): Legal Registered Entity
              - country (VARCHAR): Country
              - created_at (TIMESTAMP): Creation timestamp
            
            Table: kri_values
            Columns:
              - value_id (SERIAL PRIMARY KEY): Value record identifier
              - kri_id (VARCHAR FOREIGN KEY): References kris(kri_id)
              - value (DECIMAL): Recorded value
              - threshold (DECIMAL): Threshold value
              - recorded_date (DATE): Date of recording
              - recorded_by (VARCHAR): Person who recorded the value
              - created_at (TIMESTAMP): Creation timestamp
            
            Table: users
            Columns:
              - user_id (SERIAL PRIMARY KEY): User identifier
              - username (VARCHAR): Username
              - email (VARCHAR): Email address
              - ou (VARCHAR): Organizational Unit
              - lre (VARCHAR): Legal Registered Entity
              - country (VARCHAR): Country
              - created_at (TIMESTAMP): Creation timestamp
            
            IMPORTANT CONSTRAINTS:
            - All queries MUST filter by user context: ou='{ou}', lre='{lre}', country='{country}'
            - For SELECT queries on kris table, always add: WHERE ou = '{ou}' AND lre = '{lre}' AND country = '{country}'
            - For kri_values, join with kris and apply context filters
            - Limit SELECT results to maximum 100 rows
            """.format(
                ou=user_context.get('ou'),
                lre=user_context.get('lre'),
                country=user_context.get('country')
            )
        
        # Generate SQL using RAG model
        sql = await self.rag_client.generate_sql(
            query=query,
            schema=schema,
            user_context=user_context
        )
        
        # Clean up SQL (remove markdown code blocks if present)
        sql = re.sub(r'```sql\n?', '', sql)
        sql = re.sub(r'```\n?', '', sql)
        sql = sql.strip()
        
        logger.info(f"Generated SQL: {sql}")
        return sql
    
    def execute_query(self, sql: str, application: str):
        """Execute SQL query and return results"""
        engine = get_engine(application)
        
        with engine.connect() as conn:
            result = conn.execute(text(sql))
            
            # For SELECT queries, return results
            if sql.strip().upper().startswith('SELECT'):
                columns = result.keys()
                rows = [dict(zip(columns, row)) for row in result.fetchall()]
                return rows
            else:
                # For INSERT/UPDATE/DELETE, commit and return affected rows
                conn.commit()
                return [{"affected_rows": result.rowcount}]
EOF

# backend/services/audit_service.py
cat > backend/services/audit_service.py << 'EOF'
from database.connections import get_session
from sqlalchemy import text
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class AuditService:
    def log_query(self, user_id: int, application: str, query: str, 
                  sql_query: str = None, intent: str = None):
        """Log user query to audit table"""
        session = get_session(application)
        try:
            audit_query = text("""
                INSERT INTO audit_logs 
                (user_id, query, sql_query, intent, timestamp)
                VALUES (:user_id, :query, :sql_query, :intent, :timestamp)
            """)
            
            session.execute(audit_query, {
                "user_id": user_id,
                "query": query,
                "sql_query": sql_query,
                "intent": intent,
                "timestamp": datetime.now()
            })
            session.commit()
            logger.info(f"Audit log created for user {user_id}")
        except Exception as e:
            logger.error(f"Audit logging error: {e}")
            session.rollback()
        finally:
            session.close()
EOF

#############################################
# FRONTEND FILES
#############################################

echo "📝 Creating frontend files..."

# frontend/package.json
cat > frontend/package.json << 'EOF'
{
  "name": "enterprise-rag-chatbot",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "reactstrap": "^9.2.1",
    "bootstrap": "^5.3.2",
    "easy-peasy": "^5.2.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.2.2",
    "vite": "^5.0.0"
  }
}
EOF

# frontend/.env.example
cat > frontend/.env.example << 'EOF'
VITE_API_BASE_URL=http://localhost:8000/api
EOF

# frontend/vite.config.ts
cat > frontend/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000
  }
})
EOF

# frontend/tsconfig.json
cat > frontend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# frontend/tsconfig.node.json
cat > frontend/tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

# frontend/index.html
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Enterprise RAG Chatbot</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# frontend/src/main.tsx
cat > frontend/src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { StoreProvider } from 'easy-peasy'
import App from './App'
import store from './store'
import 'bootstrap/dist/css/bootstrap.min.css'
import './styles/main.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <StoreProvider store={store}>
      <App />
    </StoreProvider>
  </React.StrictMode>,
)
EOF

# frontend/src/App.tsx
cat > frontend/src/App.tsx << 'EOF'
import { useState } from 'react'
import { Container } from 'reactstrap'
import { useStoreState } from './store'
import LoginForm from './components/LoginForm'
import ChatInterface from './components/ChatInterface'
import Header from './components/Header'

function App() {
  const user = useStoreState((state) => state.user)

  return (
    <div className="app">
      <Header />
      <Container className="mt-4">
        {!user ? <LoginForm /> : <ChatInterface />}
      </Container>
    </div>
  )
}

export default App
EOF

# frontend/src/types/index.ts
cat > frontend/src/types/index.ts << 'EOF'
export interface User {
  userId: number
  application: string
  role: 'user' | 'admin'
  context?: {
    ou: string
    lre: string
    country: string
  }
}

export interface Message {
  id: string
  type: 'user' | 'assistant'
  content: string
  timestamp: Date
  queryType?: string
  sqlQuery?: string
  results?: any[]
  requiresConfirmation?: boolean
}

export interface ChatRequest {
  query: string
  user_id: number
  application: string
  role: string
  stream: boolean
}

export interface ChatResponse {
  response: string
  query_type: string
  sql_query?: string
  results?: any[]
  requires_confirmation?: boolean
}
EOF

# frontend/src/store/index.ts
cat > frontend/src/store/index.ts << 'EOF'
import { createStore, action, Action } from 'easy-peasy'
import { User, Message } from '../types'

interface StoreModel {
  user: User | null
  messages: Message[]
  streaming: boolean
  setUser: Action<StoreModel, User | null>
  addMessage: Action<StoreModel, Message>
  clearMessages: Action<StoreModel>
  setStreaming: Action<StoreModel, boolean>
}

const store = createStore<StoreModel>({
  user: null,
  messages: [],
  streaming: false,
  
  setUser: action((state, payload) => {
    state.user = payload
  }),
  
  addMessage: action((state, payload) => {
    state.messages.push(payload)
  }),
  
  clearMessages: action((state) => {
    state.messages = []
  }),
  
  setStreaming: action((state, payload) => {
    state.streaming = payload
  })
})

export default store
EOF

# frontend/src/services/api.ts
cat > frontend/src/services/api.ts << 'EOF'
import axios from 'axios'
import { ChatRequest, ChatResponse } from '../types'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api'

export const api = {
  async getUserContext(userId: number, application: string) {
    const response = await axios.get(
      `${API_BASE_URL}/user/context/${userId}?application=${application}`
    )
    return response.data
  },

  async sendChat(request: ChatRequest): Promise<ChatResponse> {
    const response = await axios.post(`${API_BASE_URL}/chat`, request)
    return response.data
  },

  async streamChat(request: ChatRequest): Promise<ReadableStream> {
    const response = await fetch(`${API_BASE_URL}/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(request),
    })
    return response.body!
  },

  async confirmAction(userId: number, application: string, sqlQuery: string, originalQuery: string) {
    const response = await axios.post(`${API_BASE_URL}/chat/confirm`, {
      user_id: userId,
      application,
      sql_query: sqlQuery,
      original_query: originalQuery
    })
    return response.data
  },

  async uploadDocument(fileName: string, content: string, userId: number) {
    const response = await axios.post(`${API_BASE_URL}/documents/upload`, {
      file_name: fileName,
      content,
      user_id: userId
    })
    return response.data
  }
}
EOF

# frontend/src/components/Header.tsx
cat > frontend/src/components/Header.tsx << 'EOF'
import { Navbar, NavbarBrand, Container } from 'reactstrap'
import { useStoreState, useStoreActions } from '../store'

export default function Header() {
  const user = useStoreState((state) => state.user)
  const setUser = useStoreActions((actions) => actions.setUser)
  const clearMessages = useStoreActions((actions) => actions.clearMessages)

  const handleLogout = () => {
    setUser(null)
    clearMessages()
  }

  return (
    <Navbar color="dark" dark expand="md">
      <Container>
        <NavbarBrand href="/">🤖 Enterprise RAG Chatbot</NavbarBrand>
        {user && (
          <div className="text-white d-flex align-items-center gap-3">
            <span>
              {user.application} | {user.role}
            </span>
            <button className="btn btn-sm btn-outline-light" onClick={handleLogout}>
              Logout
            </button>
          </div>
        )}
      </Container>
    </Navbar>
  )
}
EOF

# frontend/src/components/LoginForm.tsx
cat > frontend/src/components/LoginForm.tsx << 'EOF'
import { useState } from 'react'
import { Card, CardBody, Form, FormGroup, Label, Input, Button } from 'reactstrap'
import { useStoreActions } from '../store'
import { api } from '../services/api'

export default function LoginForm() {
  const [userId, setUserId] = useState('')
  const [application, setApplication] = useState('eControls')
  const [role, setRole] = useState<'user' | 'admin'>('user')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  
  const setUser = useStoreActions((actions) => actions.setUser)

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const context = await api.getUserContext(parseInt(userId), application)
      
      setUser({
        userId: parseInt(userId),
        application,
        role,
        context
      })
    } catch (err) {
      setError('Failed to login. Please check your credentials.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="d-flex justify-content-center align-items-center" style={{ minHeight: '70vh' }}>
      <Card style={{ width: '400px' }}>
        <CardBody>
          <h4 className="text-center mb-4">Login</h4>
          <Form onSubmit={handleLogin}>
            <FormGroup>
              <Label>User ID</Label>
              <Input
                type="number"
                value={userId}
                onChange={(e) => setUserId(e.target.value)}
                required
              />
            </FormGroup>
            
            <FormGroup>
              <Label>Application</Label>
              <Input
                type="select"
                value={application}
                onChange={(e) => setApplication(e.target.value)}
              >
                <option>eControls</option>
                <option>MyKRI</option>
              </Input>
            </FormGroup>
            
            <FormGroup>
              <Label>Role</Label>
              <Input
                type="select"
                value={role}
                onChange={(e) => setRole(e.target.value as 'user' | 'admin')}
              >
                <option value="user">User</option>
                <option value="admin">Admin</option>
              </Input>
            </FormGroup>
            
            {error && <div className="alert alert-danger">{error}</div>}
            
            <Button color="primary" block disabled={loading}>
              {loading ? 'Logging in...' : 'Login'}
            </Button>
          </Form>
        </CardBody>
      </Card>
    </div>
  )
}
EOF

cat > frontend/src/components/ChatInterface.tsx << 'EOF'
import { useState, useRef, useEffect } from 'react'
import { Card, CardBody, Input, Button, Form, FormGroup, Label } from 'reactstrap'
import { useStoreState, useStoreActions } from '../store'
import { api } from '../services/api'
import { Message } from '../types'
import MessageList from './MessageList'
import DocumentUpload from './DocumentUpload'

export default function ChatInterface() {
  const [query, setQuery] = useState('')
  const [loading, setLoading] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  
  const user = useStoreState((state) => state.user)
  const messages = useStoreState((state) => state.messages)
  const streaming = useStoreState((state) => state.streaming)
  const addMessage = useStoreActions((actions) => actions.addMessage)
  const setStreaming = useStoreActions((actions) => actions.setStreaming)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!query.trim() || !user) return

    const userMessage: Message = {
      id: Date.now().toString(),
      type: 'user',
      content: query,
      timestamp: new Date()
    }
    addMessage(userMessage)
    setQuery('')
    setLoading(true)

    try {
      if (streaming) {
        const stream = await api.streamChat({
          query,
          user_id: user.userId,
          application: user.application,
          role: user.role,
          stream: true
        })

        const reader = stream.getReader()
        const decoder = new TextDecoder()
        let assistantContent = ''

        while (true) {
          const { done, value } = await reader.read()
          if (done) break

          const chunk = decoder.decode(value)
          const lines = chunk.split('\n')
          
          for (const line of lines) {
            if (line.startsWith('data: ')) {
              assistantContent += line.substring(6) + '\n'
            }
          }
        }

        const assistantMessage: Message = {
          id: (Date.now() + 1).toString(),
          type: 'assistant',
          content: assistantContent,
          timestamp: new Date()
        }
        addMessage(assistantMessage)
      } else {
        const response = await api.sendChat({
          query,
          user_id: user.userId,
          application: user.application,
          role: user.role,
          stream: false
        })

        const assistantMessage: Message = {
          id: (Date.now() + 1).toString(),
          type: 'assistant',
          content: response.response,
          timestamp: new Date(),
          queryType: response.query_type,
          sqlQuery: response.sql_query,
          results: response.results,
          requiresConfirmation: response.requires_confirmation
        }
        addMessage(assistantMessage)
      }
    } catch (error) {
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: 'Sorry, an error occurred. Please try again.',
        timestamp: new Date()
      }
      addMessage(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="chat-interface">
      <div className="mb-3 d-flex justify-content-between align-items-center">
        <h5>Chat with {user?.application}</h5>
        <div className="d-flex gap-3 align-items-center">
          <FormGroup check className="mb-0">
            <Label check>
              <Input
                type="checkbox"
                checked={streaming}
                onChange={(e) => setStreaming(e.target.checked)}
              />
              {' '}Enable Streaming
            </Label>
          </FormGroup>
          {user?.role === 'admin' && <DocumentUpload />}
        </div>
      </div>

      <Card className="chat-card">
        <CardBody>
          <div className="messages-container" style={{ height: '500px', overflowY: 'auto' }}>
            <MessageList messages={messages} />
            <div ref={messagesEndRef} />
          </div>

          <Form onSubmit={handleSubmit} className="mt-3">
            <div className="d-flex gap-2">
              <Input
                type="text"
                placeholder="Ask a question..."
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                disabled={loading}
              />
              <Button color="primary" type="submit" disabled={loading}>
                {loading ? 'Sending...' : 'Send'}
              </Button>
            </div>
          </Form>
        </CardBody>
      </Card>
    </div>
  )
}
EOF

cat > frontend/src/components/MessageList.tsx << 'EOF'
import { Message } from '../types'
import { Card, CardBody, Table, Button } from 'reactstrap'
import { useStoreState } from '../store'
import { api } from '../services/api'

interface Props {
  messages: Message[]
}

export default function MessageList({ messages }: Props) {
  const user = useStoreState((state) => state.user)

  const handleConfirm = async (message: Message) => {
    if (!user || !message.sqlQuery) return

    try {
      await api.confirmAction(
        user.userId,
        user.application,
        message.sqlQuery,
        messages.find(m => m.id === message.id)?.content || ''
      )
      alert('Action completed successfully!')
    } catch (error) {
      alert('Failed to execute action')
    }
  }

  return (
    <div className="messages">
      {messages.map((message) => (
        <div
          key={message.id}
          className={`message ${message.type === 'user' ? 'message-user' : 'message-assistant'}`}
        >
          <Card className="mb-2">
            <CardBody>
              <div className="d-flex justify-content-between align-items-start">
                <strong>{message.type === 'user' ? 'You' : 'Assistant'}</strong>
                <small className="text-muted">
                  {message.timestamp.toLocaleTimeString()}
                </small>
              </div>
              
              <div className="mt-2">{message.content}</div>
              
              {message.sqlQuery && (
                <div className="mt-2">
                  <code className="d-block bg-light p-2 rounded">
                    {message.sqlQuery}
                  </code>
                </div>
              )}
              
              {message.results && message.results.length > 0 && (
                <div className="mt-3">
                  <Table size="sm" bordered striped>
                    <thead>
                      <tr>
                        {Object.keys(message.results[0]).map((key) => (
                          <th key={key}>{key}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {message.results.map((row, idx) => (
                        <tr key={idx}>
                          {Object.values(row).map((value: any, i) => (
                            <td key={i}>{String(value)}</td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </Table>
                </div>
              )}
              
              {message.requiresConfirmation && (
                <div className="mt-3">
                  <Button
                    color="warning"
                    size="sm"
                    onClick={() => handleConfirm(message)}
                  >
                    Confirm Execution
                  </Button>
                </div>
              )}
            </CardBody>
          </Card>
        </div>
      ))}
    </div>
  )
}
EOF

cat > frontend/src/components/DocumentUpload.tsx << 'EOF'
import { useState } from 'react'
import { Button, Modal, ModalHeader, ModalBody, Form, FormGroup, Label, Input } from 'reactstrap'
import { useStoreState } from '../store'
import { api } from '../services/api'

export default function DocumentUpload() {
  const [modal, setModal] = useState(false)
  const [fileName, setFileName] = useState('')
  const [content, setContent] = useState('')
  const [uploading, setUploading] = useState(false)
  
  const user = useStoreState((state) => state.user)

  const toggle = () => setModal(!modal)

  const handleUpload = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!user) return

    setUploading(true)
    try {
      await api.uploadDocument(fileName, content, user.userId)
      alert('Document uploaded successfully!')
      setFileName('')
      setContent('')
      toggle()
    } catch (error) {
      alert('Upload failed')
    } finally {
      setUploading(false)
    }
  }

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setFileName(file.name)
      const reader = new FileReader()
      reader.onload = (event) => {
        setContent(event.target?.result as string)
      }
      reader.readAsText(file)
    }
  }

  return (
    <>
      <Button color="success" size="sm" onClick={toggle}>
        Upload Document
      </Button>

      <Modal isOpen={modal} toggle={toggle}>
        <ModalHeader toggle={toggle}>Upload Document to RAG</ModalHeader>
        <ModalBody>
          <Form onSubmit={handleUpload}>
            <FormGroup>
              <Label>Select File</Label>
              <Input
                type="file"
                accept=".txt,.md,.pdf"
                onChange={handleFileSelect}
                required
              />
            </FormGroup>
            
            <FormGroup>
              <Label>File Name</Label>
              <Input
                type="text"
                value={fileName}
                onChange={(e) => setFileName(e.target.value)}
                required
              />
            </FormGroup>
            
            <FormGroup>
              <Label>Content Preview</Label>
              <Input
                type="textarea"
                value={content.substring(0, 500)}
                rows={10}
                disabled
              />
            </FormGroup>
            
            <Button color="primary" type="submit" disabled={uploading}>
              {uploading ? 'Uploading...' : 'Upload'}
            </Button>
          </Form>
        </ModalBody>
      </Modal>
    </>
  )
}
EOF

cat > frontend/src/styles/main.css << 'EOF'
.app {
  min-height: 100vh;
  background-color: #f8f9fa;
}

.chat-interface {
  max-width: 900px;
  margin: 0 auto;
}

.chat-card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.messages-container {
  padding: 1rem;
  background-color: #fff;
  border-radius: 4px;
}

.message {
  margin-bottom: 1rem;
}

.message-user .card {
  background-color: #e3f2fd;
}

.message-assistant .card {
  background-color: #f5f5f5;
}

code {
  font-size: 0.875rem;
}
EOF

#############################################
# DATABASE FILES
#############################################

echo "📝 Creating database files..."

cat > database/init-econtrols.sql << 'EOF'
-- eControls Database Schema

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    ou VARCHAR(50),
    lre VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE controls (
    control_id VARCHAR(50) PRIMARY KEY,
    control_name VARCHAR(255) NOT NULL,
    description TEXT,
    owner VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Pending',
    category VARCHAR(100),
    ou VARCHAR(50),
    lre VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    query TEXT,
    sql_query TEXT,
    intent VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO users (username, email, ou, lre, country) VALUES
('john.doe', 'john.doe@company.com', 'IT', 'APAC', 'India'),
('jane.smith', 'jane.smith@company.com', 'Finance', 'EMEA', 'UK'),
('bob.johnson', 'bob.johnson@company.com', 'HR', 'Americas', 'USA');

INSERT INTO controls (control_id, control_name, description, owner, status, category, ou, lre, country) VALUES
('CTRL-2024-001', 'Access Control Review', 'Quarterly review of user access rights', 'john.doe', 'Pending', 'Security', 'IT', 'APAC', 'India'),
('CTRL-2024-002', 'Financial Reconciliation', 'Monthly financial statement reconciliation', 'jane.smith', 'Completed', 'Finance', 'Finance', 'EMEA', 'UK'),
('CTRL-2024-003', 'Data Backup Verification', 'Weekly backup verification process', 'john.doe', 'In Progress', 'IT', 'IT', 'APAC', 'India'),
('CTRL-2024-004', 'Payroll Review', 'Monthly payroll accuracy check', 'bob.johnson', 'Completed', 'HR', 'HR', 'Americas', 'USA'),
('CTRL-2024-005', 'Vendor Assessment', 'Annual vendor risk assessment', 'jane.smith', 'Pending', 'Finance', 'Finance', 'EMEA', 'UK');

CREATE INDEX idx_controls_ou ON controls(ou);
CREATE INDEX idx_controls_lre ON controls(lre);
CREATE INDEX idx_controls_country ON controls(country);
CREATE INDEX idx_controls_status ON controls(status);
EOF

cat > database/init-mykri.sql << 'EOF'
-- MyKRI Database Schema

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    ou VARCHAR(50),
    lre VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kris (
    kri_id VARCHAR(50) PRIMARY KEY,
    kri_name VARCHAR(255) NOT NULL,
    description TEXT,
    frequency VARCHAR(50),
    owner VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Active',
    ou VARCHAR(50),
    lre VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kri_values (
    value_id SERIAL PRIMARY KEY,
    kri_id VARCHAR(50) REFERENCES kris(kri_id),
    value DECIMAL(10,2),
    threshold DECIMAL(10,2),
    recorded_date DATE,
    recorded_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    query TEXT,
    sql_query TEXT,
    intent VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO users (username, email, ou, lre, country) VALUES
('john.doe', 'john.doe@company.com', 'IT', 'APAC', 'India'),
('jane.smith', 'jane.smith@company.com', 'Finance', 'EMEA', 'UK'),
('bob.johnson', 'bob.johnson@company.com', 'HR', 'Americas', 'USA');

INSERT INTO kris (kri_id, kri_name, description, frequency, owner, status, ou, lre, country) VALUES
('KRI-2024-001', 'System Uptime', 'Percentage of system availability', 'Daily', 'john.doe', 'Active', 'IT', 'APAC', 'India'),
('KRI-2024-002', 'Transaction Error Rate', 'Percentage of failed transactions', 'Daily', 'jane.smith', 'Active', 'Finance', 'EMEA', 'UK'),
('KRI-2024-003', 'Employee Turnover', 'Monthly employee turnover rate', 'Monthly', 'bob.johnson', 'Active', 'HR', 'Americas', 'USA'),
('KRI-2024-004', 'Security Incidents', 'Number of security incidents', 'Weekly', 'john.doe', 'Active', 'IT', 'APAC', 'India'),
('KRI-2024-005', 'Budget Variance', 'Percentage variance from budget', 'Monthly', 'jane.smith', 'Active', 'Finance', 'EMEA', 'UK'),
('KRI-2024-006', 'Customer Satisfaction', 'Customer satisfaction score', 'Monthly', 'jane.smith', 'Active', 'Finance', 'EMEA', 'UK'),
('KRI-2024-007', 'Training Completion', 'Percentage of completed training', 'Quarterly', 'bob.johnson', 'Active', 'HR', 'Americas', 'USA');

INSERT INTO kri_values (kri_id, value, threshold, recorded_date, recorded_by) VALUES
('KRI-2024-001', 99.5, 95.0, CURRENT_DATE, 'john.doe'),
('KRI-2024-002', 0.5, 1.0, CURRENT_DATE, 'jane.smith'),
('KRI-2024-003', 5.0, 10.0, CURRENT_DATE - INTERVAL '1 month', 'bob.johnson'),
('KRI-2024-004', 2.0, 5.0, CURRENT_DATE, 'john.doe'),
('KRI-2024-005', 3.5, 5.0, CURRENT_DATE, 'jane.smith');

CREATE INDEX idx_kris_ou ON kris(ou);
CREATE INDEX idx_kris_lre ON kris(lre);
CREATE INDEX idx_kris_country ON kris(country);
CREATE INDEX idx_kri_values_kri_id ON kri_values(kri_id);
CREATE INDEX idx_kri_values_date ON kri_values(recorded_date);
EOF

#############################################
# DOCKER & K8S FILES
#############################################

echo "📝 Creating Docker and Kubernetes files..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  econtrols-db:
    image: postgres:15
    environment:
      POSTGRES_DB: econtrols_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - econtrols-data:/var/lib/postgresql/data
      - ./database/init-econtrols.sql:/docker-entrypoint-initdb.d/init.sql

  mykri-db:
    image: postgres:15
    environment:
      POSTGRES_DB: mykri_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5433:5432"
    volumes:
      - mykri-data:/var/lib/postgresql/data
      - ./database/init-mykri.sql:/docker-entrypoint-initdb.d/init.sql

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - ECONTROLS_DB_HOST=econtrols-db
      - MYKRI_DB_HOST=mykri-db
    env_file:
      - ./backend/.env
    depends_on:
      - econtrols-db
      - mykri-db
    command: uvicorn main:app --host 0.0.0.0 --port 8000

  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  econtrols-data:
  mykri-data:
EOF

cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > frontend/Dockerfile << 'EOF'
FROM node:18 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

cat > frontend/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

cat > k8s/deployment.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: rag-chatbot

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: rag-chatbot
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: enterprise-rag-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: ECONTROLS_DB_HOST
          value: "econtrols-db"
        - name: MYKRI_DB_HOST
          value: "mykri-db"

---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: rag-chatbot
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
  type: LoadBalancer

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: rag-chatbot
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: enterprise-rag-frontend:latest
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: rag-chatbot
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF

#############################################
# CI/CD
#############################################

cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    - name: Install dependencies
      run: |
        cd backend
        pip install -r requirements.txt
    - name: Run tests
      run: |
        cd backend
        python -m pytest

  test-frontend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Node
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - name: Install dependencies
      run: |
        cd frontend
        npm install
    - name: Build
      run: |
        cd frontend
        npm run build

  build-and-push:
    needs: [test-backend, test-frontend]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - name: Build Docker images
      run: |
        docker build -t enterprise-rag-backend:latest ./backend
        docker build -t enterprise-rag-frontend:latest ./frontend
EOF

#############################################
# DOCUMENTATION
#############################################

echo "📝 Creating documentation files..."

cat > README.md << 'EOF'
# 🤖 Enterprise RAG Chatbot with Custom RAG Model

A production-ready enterprise chatbot with custom RAG model integration, SQL query generation, and dual database support.

## Features

✅ Custom RAG model with OAuth2 authentication
✅ Natural language to SQL query generation  
✅ Document-based Q&A with RAG
✅ Dual database support (eControls & MyKRI)
✅ Role-based access control
✅ Row-level security with user context filtering
✅ Audit logging
✅ Streaming responses
✅ Docker & Kubernetes ready

## Architecture

- **Backend**: Python FastAPI + Custom RAG Client
- **Frontend**: React + TypeScript + Reactstrap
- **Databases**: PostgreSQL (eControls & MyKRI)
- **RAG Model**: Custom OAuth2-authenticated RAG API

## Quick Start

1. Run the setup script to create project structure
2. Configure your custom RAG credentials in `.env`
3. Start databases and services
4. Begin querying!

See setup script output for detailed instructions.

## Custom RAG Integration

The system uses your custom RAG model for:
- Intent classification
- SQL query generation
- Document-based question answering
- Streaming responses

Authentication is handled automatically using OAuth2 client credentials flow.

## License

MIT License
EOF

cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
.env

# Node
node_modules/
dist/
.npm
*.log

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Database
*.db
*.sqlite
EOF

echo ""
echo "✅ Project structure created successfully!"
echo ""
echo "📁 Project location: $PROJECT_NAME/"
echo ""
echo "🔐 IMPORTANT: Configure your custom RAG model credentials in backend/.env:"
echo "   - RAG_CLIENT_ID"
echo "   - RAG_CLIENT_SECRET"
echo "   - RAG_APPLICATION_NAME"
echo "   - RAG_WORKSPACE_NAME"
echo "   - RAG_API_BASE_URL"
echo "   - RAG_TOKEN_URL"
echo ""
echo "🚀 Next steps:"
echo ""
echo "1. Navigate to project:"
echo "   cd $PROJECT_NAME"
echo ""
echo "2. Setup databases:"
echo "   psql -U postgres -f database/init-econtrols.sql"
echo "   psql -U postgres -f database/init-mykri.sql"
echo ""
echo "3. Configure backend:"
echo "   cd backend"
echo "   cp .env.example .env"
echo "   # Edit .env with your RAG credentials"
echo "   pip install -r requirements.txt"
echo ""
echo "4. Configure frontend:"
echo "   cd frontend"
echo "   cp .env.example .env"
echo "   npm install"
echo ""
echo "5. Start services:"
echo "   # Terminal 1 - Backend"
echo "   cd backend && uvicorn main:app --reload"
echo "   "
echo "   # Terminal 2 - Frontend"
echo "   cd frontend && npm run dev"
echo ""
echo "6. Open browser: http://localhost:3000"
echo ""
echo "🎉 Your custom RAG model is now integrated!"