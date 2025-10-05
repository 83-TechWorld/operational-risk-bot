from services.rag_client import RAGClient
from typing import Dict
import logging

logger = logging.getLogger(__name__)

class RAGBasedAgent:
    """Uses enterprise RAG API for all AI tasks"""
    
    def __init__(self):
        self.rag_client = RAGClient()
    
    async def classify_intent(self, user_query: str, user_context: Dict) -> Dict:
        """Classify user intent using RAG API"""
        
        classification_query = f"""
Based on the Intent Classification Guide, classify this query:

User Query: "{user_query}"
User Context: OU={user_context.get('ou')}, LRE={user_context.get('lre')}, Country={user_context.get('country')}

Respond with ONLY valid JSON following the classification format.
"""
        
        try:
            # Use the new structured query method
            result = await self.rag_client.query_rag_with_structure(
                query=classification_query,
                expected_format="json",
                top_k=3,
                filters={"document_type": "classification"}
            )
            
            if result.get("success") and result.get("data"):
                classification = result["data"]
                logger.info(f"Intent classified: {classification}")
                return classification
            else:
                # Fallback
                logger.warning("Classification failed, using fallback")
                return {
                    "application": "RAG_ONLY",
                    "intent": "INFORMATION",
                    "requires_confirmation": False,
                    "entities": [],
                    "reasoning": "Could not classify, defaulting to RAG"
                }
                
        except Exception as e:
            logger.error(f"Classification error: {e}")
            return {
                "application": "RAG_ONLY",
                "intent": "INFORMATION",
                "requires_confirmation": False,
                "entities": [],
                "reasoning": f"Error: {str(e)}"
            }
    
    async def generate_sql_query(
        self,
        user_query: str,
        application: str,
        user_context: Dict,
        intent: str
    ) -> Dict:
        """Generate SQL query using RAG API"""
        
        sql_generation_query = f"""
Based on the SQL Generation Guide, generate SQL for this query:

Application: {application}
User Query: "{user_query}"
User Context: ou={user_context.get('ou')}, lre={user_context.get('lre')}, country={user_context.get('country')}, user_id={user_context.get('user_id')}
Intent: {intent}

Generate ONLY the SQL query with proper user context filtering. Include the semicolon at the end.
"""
        
        try:
            # Use the new structured query method for SQL
            result = await self.rag_client.query_rag_with_structure(
                query=sql_generation_query,
                expected_format="sql",
                top_k=5,
                filters={"document_type": "sql_guide"}
            )
            
            if result.get("success") and result.get("sql"):
                sql_query = result["sql"]
                logger.info(f"Generated SQL: {sql_query}")
                
                return {
                    "sql_query": sql_query,
                    "application": application,
                    "user_context": user_context
                }
            else:
                raise ValueError("Could not generate SQL query")
            
        except Exception as e:
            logger.error(f"SQL generation error: {e}")
            raise
    
    async def generate_response(
        self,
        query_result: any,
        original_query: str,
        rag_context: str = None
    ) -> str:
        """Generate natural language response using RAG API"""
        
        response_query = f"""
Based on the Response Formatting Guide, create a natural response:

User Question: "{original_query}"
Query Result: {str(query_result)}
Additional Context: {rag_context or 'None'}

Generate a clear, conversational response.
"""
        
        try:
            # Use the new structured query method for text
            result = await self.rag_client.query_rag_with_structure(
                query=response_query,
                expected_format="text",
                top_k=3,
                filters={"document_type": "response_guide"}
            )
            
            if result.get("success") and result.get("text"):
                final_response = result["text"]
                
                # Fallback if response is too short
                if len(final_response) < 10:
                    if isinstance(query_result, list) and len(query_result) > 0:
                        final_response = f"I found {len(query_result)} result(s) matching your query."
                    elif isinstance(query_result, dict) and 'count' in query_result:
                        final_response = f"The count is {query_result['count']}."
                    else:
                        final_response = "Query executed successfully."
                
                return final_response
            else:
                return "I've processed your request. Please check the results below."
            
        except Exception as e:
            logger.error(f"Response generation error: {e}")
            return "I've processed your request. Please check the results below."