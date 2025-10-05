from sqlalchemy.ext.asyncio import AsyncSession
from models.database import AuditLog
from typing import Dict, Optional
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

class AuditService:
    @staticmethod
    async def log_operation(
        session: AsyncSession,
        user_id: int,
        username: str,
        application: str,
        operation: str,
        table_name: str,
        query_executed: str,
        record_id: Optional[str] = None,
        changes: Optional[Dict] = None,
        ip_address: Optional[str] = None,
        success: bool = True,
        error_message: Optional[str] = None
    ):
        """Log database operation to audit table"""
        try:
            audit_entry = AuditLog(
                user_id=user_id,
                username=username,
                application=application,
                operation=operation,
                table_name=table_name,
                record_id=record_id,
                query_executed=query_executed,
                changes=changes,
                timestamp=datetime.utcnow(),
                ip_address=ip_address,
                success=success,
                error_message=error_message
            )
            
            session.add(audit_entry)
            await session.commit()
            
            logger.info(
                f"Audit logged - User: {username}, App: {application}, "
                f"Operation: {operation}, Table: {table_name}"
            )
            
        except Exception as e:
            logger.error(f"Failed to log audit entry: {e}")
            await session.rollback()
    
    @staticmethod
    async def get_user_audit_history(
        session: AsyncSession,
        user_id: int,
        limit: int = 100
    ) -> list:
        """Get audit history for a specific user"""
        try:
            from sqlalchemy import select
            
            stmt = select(AuditLog).where(
                AuditLog.user_id == user_id
            ).order_by(
                AuditLog.timestamp.desc()
            ).limit(limit)
            
            result = await session.execute(stmt)
            audit_logs = result.scalars().all()
            
            return [
                {
                    "audit_id": log.audit_id,
                    "operation": log.operation,
                    "application": log.application,
                    "table_name": log.table_name,
                    "timestamp": log.timestamp.isoformat(),
                    "success": log.success
                }
                for log in audit_logs
            ]
            
        except Exception as e:
            logger.error(f"Failed to retrieve audit history: {e}")
            return []
    
    @staticmethod
    async def get_operation_audit(
        session: AsyncSession,
        application: str,
        table_name: str,
        record_id: str
    ) -> list:
        """Get audit trail for a specific record"""
        try:
            from sqlalchemy import select
            
            stmt = select(AuditLog).where(
                AuditLog.application == application,
                AuditLog.table_name == table_name,
                AuditLog.record_id == record_id
            ).order_by(
                AuditLog.timestamp.desc()
            )
            
            result = await session.execute(stmt)
            audit_logs = result.scalars().all()
            
            return [
                {
                    "audit_id": log.audit_id,
                    "username": log.username,
                    "operation": log.operation,
                    "changes": log.changes,
                    "timestamp": log.timestamp.isoformat(),
                    "success": log.success
                }
                for log in audit_logs
            ]
            
        except Exception as e:
            logger.error(f"Failed to retrieve operation audit: {e}")
            return []