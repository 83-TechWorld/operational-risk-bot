from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, Boolean, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

# ==================== eControls Models ====================

class EControlsUser(Base):
    __tablename__ = "users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    user_ou = Column(String(100), nullable=False)
    user_lre = Column(String(100), nullable=False)
    user_country = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Control(Base):
    __tablename__ = "controls"
    
    control_id = Column(Integer, primary_key=True, index=True)
    control_ref = Column(String(50), unique=True, nullable=False)
    control_name = Column(String(255), nullable=False)
    control_description = Column(Text)
    control_category = Column(String(100))
    ou = Column(String(100), nullable=False)
    lre = Column(String(100), nullable=False)
    country = Column(String(100), nullable=False)
    review_status = Column(String(50), default="Pending")
    assigned_to = Column(Integer, ForeignKey("users.user_id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    assigned_user = relationship("EControlsUser", backref="controls")

class ControlReview(Base):
    __tablename__ = "control_reviews"
    
    review_id = Column(Integer, primary_key=True, index=True)
    control_id = Column(Integer, ForeignKey("controls.control_id"))
    reviewer_id = Column(Integer, ForeignKey("users.user_id"))
    review_comments = Column(Text)
    review_status = Column(String(50))
    review_date = Column(DateTime, default=datetime.utcnow)
    
    control = relationship("Control", backref="reviews")
    reviewer = relationship("EControlsUser", backref="reviews")

# ==================== MyKRI Models ====================

class MyKRIUser(Base):
    __tablename__ = "users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    user_ou = Column(String(100), nullable=False)
    user_lre = Column(String(100), nullable=False)
    user_country = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class KRIIndicator(Base):
    __tablename__ = "kri_indicators"
    
    kri_id = Column(Integer, primary_key=True, index=True)
    kri_ref = Column(String(50), unique=True, nullable=False)
    kri_name = Column(String(255), nullable=False)
    kri_description = Column(Text)
    kri_category = Column(String(100))
    threshold_value = Column(String(100))
    ou = Column(String(100), nullable=False)
    lre = Column(String(100), nullable=False)
    country = Column(String(100), nullable=False)
    status = Column(String(50), default="Active")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class KRIValue(Base):
    __tablename__ = "kri_values"
    
    value_id = Column(Integer, primary_key=True, index=True)
    kri_id = Column(Integer, ForeignKey("kri_indicators.kri_id"))
    entered_by = Column(Integer, ForeignKey("users.user_id"))
    kri_value = Column(String(255), nullable=False)
    entry_date = Column(DateTime, default=datetime.utcnow)
    comments = Column(Text)
    
    indicator = relationship("KRIIndicator", backref="values")
    user = relationship("MyKRIUser", backref="kri_entries")

# ==================== Audit Log Model (Common) ====================

class AuditLog(Base):
    __tablename__ = "audit_logs"
    
    audit_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    username = Column(String(100), nullable=False)
    application = Column(String(50), nullable=False)  # 'eControls' or 'MyKRI'
    operation = Column(String(20), nullable=False)  # INSERT, UPDATE, DELETE, SELECT
    table_name = Column(String(100), nullable=False)
    record_id = Column(String(100))
    query_executed = Column(Text)
    changes = Column(JSON)  # Store before/after values for updates
    timestamp = Column(DateTime, default=datetime.utcnow)
    ip_address = Column(String(50))
    success = Column(Boolean, default=True)
    error_message = Column(Text)