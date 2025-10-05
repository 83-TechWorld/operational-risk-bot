from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from config import settings
import logging

logger = logging.getLogger(__name__)

# Create async engines for both databases
econtrols_engine = create_async_engine(
    settings.econtrols_database_url,
    echo=settings.DEBUG,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)

mykri_engine = create_async_engine(
    settings.mykri_database_url,
    echo=settings.DEBUG,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)

# Create session makers
EControlsSessionLocal = async_sessionmaker(
    econtrols_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

MyKRISessionLocal = async_sessionmaker(
    mykri_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Dependency functions
async def get_econtrols_db():
    async with EControlsSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception as e:
            await session.rollback()
            logger.error(f"Database session error: {str(e)}")
            raise
        finally:
            await session.close()

async def get_mykri_db():
    async with MyKRISessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception as e:
            await session.rollback()
            logger.error(f"Database session error: {str(e)}")
            raise
        finally:
            await session.close()

# Database initialization
async def init_databases():
    """Initialize database tables"""
    from models.database import Base
    
    try:
        async with econtrols_engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("eControls database initialized successfully")
        
        async with mykri_engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("MyKRI database initialized successfully")
        
    except Exception as e:
        logger.error(f"Database initialization error: {str(e)}")
        raise

async def close_databases():
    """Close database connections"""
    await econtrols_engine.dispose()
    await mykri_engine.dispose()
    logger.info("Database connections closed")