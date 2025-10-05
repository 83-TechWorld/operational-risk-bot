-- MyKRI Database Initialization Script

-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    user_ou VARCHAR(100) NOT NULL,
    user_lre VARCHAR(100) NOT NULL,
    user_country VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create KRI Indicators Table
CREATE TABLE IF NOT EXISTS kri_indicators (
    kri_id SERIAL PRIMARY KEY,
    kri_ref VARCHAR(50) UNIQUE NOT NULL,
    kri_name VARCHAR(255) NOT NULL,
    kri_description TEXT,
    kri_category VARCHAR(100),
    threshold_value VARCHAR(100),
    ou VARCHAR(100) NOT NULL,
    lre VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create KRI Values Table
CREATE TABLE IF NOT EXISTS kri_values (
    value_id SERIAL PRIMARY KEY,
    kri_id INTEGER REFERENCES kri_indicators(kri_id),
    entered_by INTEGER REFERENCES users(user_id),
    kri_value VARCHAR(255) NOT NULL,
    entry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comments TEXT
);

-- Create Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    audit_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    username VARCHAR(100) NOT NULL,
    application VARCHAR(50) NOT NULL,
    operation VARCHAR(20) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id VARCHAR(100),
    query_executed TEXT,
    changes JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50),
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT
);

-- Create Indexes
CREATE INDEX IF NOT EXISTS idx_kri_ou_lre_country ON kri_indicators(ou, lre, country);
CREATE INDEX IF NOT EXISTS idx_kri_status ON kri_indicators(status);
CREATE INDEX IF NOT EXISTS idx_kri_ref ON kri_indicators(kri_ref);
CREATE INDEX IF NOT EXISTS idx_kri_values_kri_id ON kri_values(kri_id);
CREATE INDEX IF NOT EXISTS idx_kri_values_entry_date ON kri_values(entry_date DESC);
CREATE INDEX IF NOT EXISTS idx_users_ou_lre_country ON users(user_ou, user_lre, user_country);
CREATE INDEX IF NOT EXISTS idx_audit_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp DESC);

-- Insert Sample Users
INSERT INTO users (user_id, username, email, user_ou, user_lre, user_country) 
VALUES 
    (1, 'john.doe', 'john.doe@company.com', 'Finance', 'US Entity', 'USA'),
    (2, 'jane.smith', 'jane.smith@company.com', 'Finance', 'US Entity', 'USA'),
    (3, 'admin.user', 'admin@company.com', 'Finance', 'US Entity', 'USA')
ON CONFLICT (user_id) DO NOTHING;

-- Insert Sample KRI Indicators
INSERT INTO kri_indicators (kri_ref, kri_name, kri_description, kri_category, threshold_value, ou, lre, country, status)
VALUES 
    ('KRI-2024-001', 'Revenue Variance', 'Tracks variance in monthly revenue', 'Financial', '±10%', 'Finance', 'US Entity', 'USA', 'Active'),
    ('KRI-2024-002', 'Expense Ratio', 'Monitors expense to revenue ratio', 'Financial', '<30%', 'Finance', 'US Entity', 'USA', 'Active'),
    ('KRI-2024-003', 'Compliance Score', 'Overall compliance health indicator', 'Compliance', '>90%', 'Finance', 'US Entity', 'USA', 'Active'),
    ('KRI-2024-004', 'Customer Satisfaction Index', 'Customer satisfaction metric', 'Operational', '>85%', 'Finance', 'US Entity', 'USA', 'Active'),
    ('KRI-2024-005', 'System Downtime', 'Tracks system availability', 'IT', '<1%', 'Finance', 'US Entity', 'USA', 'Active'),
    ('KRI-2024-006', 'Audit Findings', 'Number of open audit findings', 'Compliance', '<5', 'Finance', 'US Entity', 'USA', 'Active'),
    ('KRI-2024-007', 'Payment Delay Rate', 'Percentage of delayed payments', 'Financial', '<5%', 'Finance', 'US Entity', 'USA', 'Active')
ON CONFLICT (kri_ref) DO NOTHING;

-- Insert Sample KRI Values
INSERT INTO kri_values (kri_id, entered_by, kri_value, entry_date, comments)
VALUES 
    (1, 1, '8.5%', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Within acceptable range'),
    (1, 1, '12.3%', CURRENT_TIMESTAMP - INTERVAL '15 days', 'Exceeded threshold - investigation initiated'),
    (1, 1, '7.2%', CURRENT_TIMESTAMP, 'Back to normal range'),
    (2, 2, '28%', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Good performance'),
    (2, 2, '29%', CURRENT_TIMESTAMP, 'Slight increase but within threshold'),
    (3, 1, '95%', CURRENT_TIMESTAMP - INTERVAL '7 days', 'Excellent compliance'),
    (3, 1, '96%', CURRENT_TIMESTAMP, 'Maintaining high standards'),
    (4, 2, '88%', CURRENT_TIMESTAMP, 'Above target'),
    (5, 1, '0.5%', CURRENT_TIMESTAMP, 'Minimal downtime')
ON CONFLICT DO NOTHING;

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Print success message
DO $$
BEGIN
    RAISE NOTICE 'MyKRI database initialized successfully!';
END $$;