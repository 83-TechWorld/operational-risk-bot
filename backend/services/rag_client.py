import httpx
import aiofiles
from typing import AsyncGenerator, Optional, Dict, Any
from config import settings
import logging
import json
import re

logger = logging.getLogger(__name__)

class RAGClient:
    def __init__(self):
        self.base_url = settings.RAG_API_BASE_URL
        self.bearer_token = settings.RAG_API_BEARER_TOKEN
        self.upload_endpoint = f"{self.base_url}{settings.RAG_UPLOAD_ENDPOINT}"
        self.query_endpoint = f"{self.base_url}{settings.RAG_QUERY_ENDPOINT}"
        
        self.headers = {
            "Authorization": f"Bearer {self.bearer_token}",
            "Content-Type": "application/json"
        }
    
    async def upload_document(
        self,
        file_path: str,
        document_name: str,
        metadata: Optional[dict] = None
    ) -> dict:
        """Upload document to RAG system"""
        try:
            async with aiofiles.open(file_path, 'rb') as f:
                file_content = await f.read()
            
            files = {
                'file': (document_name, file_content)
            }
            
            data = {
                'metadata': json.dumps(metadata) if metadata else '{}'
            }
            
            async with httpx.AsyncClient(timeout=300.0) as client:
                response = await client.post(
                    self.upload_endpoint,
                    files=files,
                    data=data,
                    headers={"Authorization": f"Bearer {self.bearer_token}"}
                )
                
                response.raise_for_status()
                result = response.json()
                
                logger.info(f"Document uploaded successfully: {document_name}")
                return {
                    "success": True,
                    "document_name": document_name,
                    "message": "Document uploaded and indexed",
                    "details": result
                }
                
        except httpx.HTTPStatusError as e:
            logger.error(f"HTTP error uploading document: {e}")
            return {
                "success": False,
                "error": f"Upload failed: {str(e)}"
            }
        except Exception as e:
            logger.error(f"Error uploading document: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    async def query_rag(
        self,
        query: str,
        top_k: int = 5,
        filters: Optional[dict] = None,
        return_raw: bool = False
    ) -> dict:
        """
        Query RAG system for relevant information
        
        Args:
            query: The query string
            top_k: Number of results to return
            filters: Metadata filters (e.g., {"document_type": "classification"})
            return_raw: If True, return raw response without processing
        """
        try:
            payload = {
                "query": query,
                "top_k": top_k,
                "filters": filters or {}
            }
            
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    self.query_endpoint,
                    json=payload,
                    headers=self.headers
                )
                
                response.raise_for_status()
                result = response.json()
                
                logger.info(f"RAG query successful: {query[:50]}...")
                
                if return_raw:
                    return result
                
                return {
                    "success": True,
                    "results": result.get("results", []),
                    "context": result.get("context", ""),
                    "sources": result.get("sources", [])
                }
                
        except httpx.HTTPStatusError as e:
            logger.error(f"HTTP error querying RAG: {e}")
            return {
                "success": False,
                "error": f"Query failed: {str(e)}",
                "results": [],
                "context": ""
            }
        except Exception as e:
            logger.error(f"Error querying RAG: {e}")
            return {
                "success": False,
                "error": str(e),
                "results": [],
                "context": ""
            }
    
    async def query_rag_with_structure(
        self,
        query: str,
        expected_format: str = "json",
        top_k: int = 5,
        filters: Optional[dict] = None
    ) -> Dict[str, Any]:
        """
        Query RAG and extract structured data (JSON, SQL, etc.)
        
        Args:
            query: The query string
            expected_format: 'json', 'sql', or 'text'
            top_k: Number of results
            filters: Metadata filters
        
        Returns:
            Extracted structured data
        """
        result = await self.query_rag(query, top_k, filters)
        
        if not result.get("success"):
            return result
        
        context = result.get("context", "")
        
        if expected_format == "json":
            # Extract JSON from response
            extracted = self._extract_json(context)
            return {
                "success": True,
                "data": extracted,
                "context": context,
                "sources": result.get("sources", [])
            }
        
        elif expected_format == "sql":
            # Extract SQL from response
            extracted = self._extract_sql(context)
            return {
                "success": True,
                "sql": extracted,
                "context": context,
                "sources": result.get("sources", [])
            }
        
        else:  # text
            # Clean up text response
            extracted = self._clean_text(context)
            return {
                "success": True,
                "text": extracted,
                "context": context,
                "sources": result.get("sources", [])
            }
    
    def _extract_json(self, text: str) -> Optional[dict]:
        """Extract JSON object from text"""
        try:
            # Method 1: Look for JSON pattern
            json_pattern = r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}'
            matches = re.finditer(json_pattern, text, re.DOTALL)
            
            for match in matches:
                try:
                    json_str = match.group(0)
                    parsed = json.loads(json_str)
                    # Validate it's a dict (not just a number or string in braces)
                    if isinstance(parsed, dict):
                        return parsed
                except json.JSONDecodeError:
                    continue
            
            # Method 2: Try to parse entire text
            try:
                return json.loads(text)
            except json.JSONDecodeError:
                pass
            
            # Method 3: Look for JSON in code blocks
            code_block_pattern = r'```(?:json)?\s*(\{.*?\})\s*```'
            code_match = re.search(code_block_pattern, text, re.DOTALL)
            if code_match:
                try:
                    return json.loads(code_match.group(1))
                except json.JSONDecodeError:
                    pass
            
            logger.warning("Could not extract valid JSON from response")
            return None
            
        except Exception as e:
            logger.error(f"Error extracting JSON: {e}")
            return None
    
    def _extract_sql(self, text: str) -> Optional[str]:
        """Extract SQL query from text"""
        try:
            # Method 1: Look for SQL with semicolon
            sql_pattern = r'(SELECT|INSERT|UPDATE|DELETE|WITH)\s+.*?;'
            match = re.search(sql_pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                sql = match.group(0).strip()
                return self._clean_sql(sql)
            
            # Method 2: Look for SQL in code blocks
            code_block_pattern = r'```(?:sql)?\s*((?:SELECT|INSERT|UPDATE|DELETE|WITH).*?)\s*```'
            match = re.search(code_block_pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                sql = match.group(1).strip()
                return self._clean_sql(sql)
            
            # Method 3: Find SQL without semicolon
            sql_pattern = r'(SELECT|INSERT|UPDATE|DELETE|WITH)\s+.*?(?=\n\n|$)'
            match = re.search(sql_pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                sql = match.group(0).strip()
                return self._clean_sql(sql)
            
            logger.warning("Could not extract SQL from response")
            return None
            
        except Exception as e:
            logger.error(f"Error extracting SQL: {e}")
            return None
    
    def _clean_sql(self, sql: str) -> str:
        """Clean and format SQL query"""
        # Remove extra whitespace
        sql = ' '.join(sql.split())
        
        # Ensure it ends with semicolon
        if not sql.endswith(';'):
            sql += ';'
        
        return sql
    
    def _clean_text(self, text: str) -> str:
        """Clean text response by removing guide/instruction text"""
        # Remove common instruction patterns
        patterns_to_remove = [
            r'based on the.*?guide[,:]?\s*',
            r'(?:example|response|format):\s*',
            r'here(?:\'s| is) (?:the|a|an).*?:\s*',
            r'```.*?```',  # Remove code blocks
        ]
        
        cleaned = text
        for pattern in patterns_to_remove:
            cleaned = re.sub(pattern, '', cleaned, flags=re.IGNORECASE | re.DOTALL)
        
        # Remove multiple blank lines
        cleaned = re.sub(r'\n{3,}', '\n\n', cleaned)
        
        # Trim whitespace
        cleaned = cleaned.strip()
        
        return cleaned
    
    async def query_rag_stream(
        self,
        query: str,
        top_k: int = 5,
        filters: Optional[dict] = None
    ) -> AsyncGenerator[str, None]:
        """Query RAG system with streaming response"""
        try:
            payload = {
                "query": query,
                "top_k": top_k,
                "filters": filters or {},
                "stream": True
            }
            
            async with httpx.AsyncClient(timeout=120.0) as client:
                async with client.stream(
                    "POST",
                    self.query_endpoint,
                    json=payload,
                    headers=self.headers
                ) as response:
                    response.raise_for_status()
                    
                    async for chunk in response.aiter_bytes():
                        if chunk:
                            yield chunk.decode('utf-8')
                            
        except httpx.HTTPStatusError as e:
            logger.error(f"HTTP error streaming RAG: {e}")
            yield json.dumps({"error": f"Streaming failed: {str(e)}"})
        except Exception as e:
            logger.error(f"Error streaming RAG: {e}")
            yield json.dumps({"error": str(e)})
    
    async def list_documents(self) -> dict:
        """List all uploaded documents"""
        try:
            list_endpoint = f"{self.base_url}/documents"
            
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.get(
                    list_endpoint,
                    headers=self.headers
                )
                
                response.raise_for_status()
                result = response.json()
                
                return {
                    "success": True,
                    "documents": result.get("documents", [])
                }
                
        except Exception as e:
            logger.error(f"Error listing documents: {e}")
            return {
                "success": False,
                "error": str(e),
                "documents": []
            }
    
    async def health_check(self) -> bool:
        """Check if RAG API is accessible"""
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(
                    f"{self.base_url}/health",
                    headers=self.headers
                )
                return response.status_code == 200
        except Exception as e:
            logger.error(f"RAG health check failed: {e}")
            return False