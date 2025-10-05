from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Enterprise RAG Chatbot"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    
    # Database - eControls
    ECONTROLS_DB_HOST: str = "localhost"
    ECONTROLS_DB_PORT: int = 5432
    ECONTROLS_DB_NAME: str = "econtrols_db"
    ECONTROLS_DB_USER: str = "postgres"
    ECONTROLS_DB_PASSWORD: str = "password"
    
    # Database - MyKRI
    MYKRI_DB_HOST: str = "localhost"
    MYKRI_DB_PORT: int = 5432
    MYKRI_DB_NAME: str = "mykri_db"
    MYKRI_DB_USER: str = "postgres"
    MYKRI_DB_PASSWORD: str = "password"
    
    # RAG API Configuration
    RAG_API_BASE_URL: str = "https://your-rag-api.azure.com"
    RAG_API_BEARER_TOKEN: str = "your-bearer-token"
    RAG_UPLOAD_ENDPOINT: str = "/upload"
    RAG_QUERY_ENDPOINT: str = "/query"
    
    # Azure OpenAI (for LangChain)
    AZURE_OPENAI_API_KEY: str = "your-azure-openai-key"
    AZURE_OPENAI_ENDPOINT: str = "https://your-resource.openai.azure.com/"
    AZURE_OPENAI_DEPLOYMENT: str = "gpt-4"
    AZURE_OPENAI_API_VERSION: str = "2024-02-15-preview"
    
    # JWT Configuration
    JWT_SECRET_KEY: str = "your-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    CORS_ORIGINS: list = ["http://localhost:3000", "http://localhost:5173"]
    
    # Streaming
    STREAM_CHUNK_SIZE: int = 512
    
    @property
    def econtrols_database_url(self) -> str:
        return f"postgresql+asyncpg://{self.ECONTROLS_DB_USER}:{self.ECONTROLS_DB_PASSWORD}@{self.ECONTROLS_DB_HOST}:{self.ECONTROLS_DB_PORT}/{self.ECONTROLS_DB_NAME}"
    
    @property
    def mykri_database_url(self) -> str:
        return f"postgresql+asyncpg://{self.MYKRI_DB_USER}:{self.MYKRI_DB_PASSWORD}@{self.MYKRI_DB_HOST}:{self.MYKRI_DB_PORT}/{self.MYKRI_DB_NAME}"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()