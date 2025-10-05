# 🚀 Backend Setup Guide - RAG Only Version

## 📁 Complete Backend File Structure

```
backend/
├── requirements.txt          ✅ Updated (removed LangChain/OpenAI)
├── config.py                ✅ Updated (removed Azure OpenAI settings)
├── main.py                  ✅ Updated (with confirmation logic)
├── .env.example             ✅ Updated (RAG only)
├── .env                     ← Create this (copy from .env.example)
│
├── agents/
│   └── sql_agent.py         ✅ Updated (RAG-based, no direct LLM)
│
├── database/
│   └── connection.py        ✅ Same as before
│
├── models/
│   └── database.py          ✅ Same as before
│
└── services/
    ├── rag_client.py        ✅ Updated (with structure extraction)
    └── audit_service.py     ✅ Same as before
```

## 🔄 What Changed from Original

### ✅ Files Updated:

1. **requirements.txt** - Removed `langchain`, `langchain-openai`, `openai`, `tiktoken`
2. **config.py** - Removed Azure OpenAI configuration
3. **agents/sql_agent.py** - Now `RAGBasedAgent` using only RAG API
4. **services/rag_client.py** - Added `query_rag_with_structure()` method
5. **main.py** - Added proper confirmation logic for WRITE/DELETE
6. **.env.example** - Removed Azure OpenAI variables

### ✅ Files Unchanged:

- `models/database.py` - SQLAlchemy models
- `database/connection.py` - Database connections
- `services/audit_service.py` - Audit logging

## 📋 Step-by-Step Setup

### 1. Create Directory Structure

```bash
mkdir -p backend/{agents,database,models,services}
cd backend
```

### 2. Copy All Backend Files

Copy each artifact from above into these files:

| Artifact Name | Save As |
|--------------|---------|
| Backend: requirements.txt | `requirements.txt` |
| Backend: config.py | `config.py` |
| Backend: main.py | `main.py` |
| Backend: models/database.py | `models/database.py` |
| Backend: database/connection.py | `database/connection.py` |
| Backend: agents/sql_agent.py | `agents/sql_agent.py` |
| Backend: services/rag_client.py | `services/rag_client.py` |
| Backend: services/audit_service.py | `services/audit_service.py` |
| Backend: .env.example | `.env.example` |

### 3. Create __init__.py Files

```bash
touch agents/__init__.py
touch database/__init__.py
touch models/__init__.py
touch services/__init__.py
```

### 4. Install Dependencies

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 5. Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env with your actual values
nano .env  # or use your preferred editor
```

**Update these in .env:**
```bash
# Database credentials
ECONTROLS_DB_PASSWORD=your_actual_password
MYKRI_DB_PASSWORD=your_actual_password

# RAG API credentials
RAG_API_BASE_URL=https://your-actual-rag-api.azure.com
RAG_API_BEARER_TOKEN=your_actual_bearer_token
```

### 6. Setup Databases

```bash
# Start PostgreSQL if not running
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql
# Windows: Start PostgreSQL service

# Create databases
psql -U postgres
```

```sql
CREATE DATABASE econtrols_db;
CREATE DATABASE mykri_db;
\q
```

```bash
# Initialize with sample data
psql -U postgres -d econtrols_db < database/init-econtrols.sql
psql -U postgres -d mykri_db < database/init-mykri.sql
```

### 7. Upload Guide Documents to RAG

**IMPORTANT:** Before the chatbot can work, you need to upload these 3 guide documents to your RAG API:

**Document 1:** `intent_classification_guide.md`
**Document 2:** `sql_generation_guide.md`
**Document 3:** `response_formatting_guide.md`

See the previous conversation for the complete content of these documents.

**Upload them using:**

```bash
# Option 1: Via your admin UI (if available)

# Option 2: Via API
curl -X POST https://your-rag-api.azure.com/upload \
  -H "Authorization: Bearer your-token" \
  -F "file=@intent_classification_guide.md" \
  -F "metadata={\"document_type\":\"classification\",\"application\":\"General\"}"
```

### 8. Start the Backend

```bash
# Development mode
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### 9. Test the Backend

```bash
# Test health check
curl http://localhost:8000/api/health

# Expected response:
{
  "status": "healthy",
  "version": "1.0.0",
  "rag_api_connected": true,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 🧪 Testing Query Flow

### Test 1: READ Query (Auto-Execute)

```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "query": "How many controls are pending?",
    "user_context": {
      "user_id": 1,
      "username": "john.doe",
      "email": "john.doe@company.com",
      "ou": "Finance",
      "lre": "US Entity",
      "country": "USA",
      "role": "user"
    },
    "use_streaming": false
  }'
```

**Expected:** Query executes immediately, returns count

### Test 2: WRITE Query (Requires Confirmation)

```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Update status to Completed for CTRL-2024-001",
    "user_context": {
      "user_id": 1,
      "username": "john.doe",
      "email": "john.doe@company.com",
      "ou": "Finance",
      "lre": "US Entity",
      "country": "USA",
      "role": "user"
    },
    "use_streaming": false
  }'
```

**Expected:** Returns `{"requires_confirmation": true, ...}` - does NOT execute

## 🔍 How It Works

### Query Execution Flow:

```
1. User sends query
   ↓
2. RAG classifies intent
   ├─ READ → Execute immediately
   └─ WRITE/DELETE → Stop and ask confirmation
   ↓
3. RAG generates SQL with user context filter
   ↓
4. [If WRITE/DELETE] Frontend shows confirmation dialog
   ├─ User clicks "Confirm" → Continue to step 5
   └─ User clicks "Cancel" → Stop
   ↓
5. Execute SQL on database
   ↓
6. Log to audit_logs table
   ↓
7. RAG generates natural language response
   ↓
8. Return to user
```

### Safety Mechanisms:

✅ **Intent Classification** - RAG determines if query is safe  
✅ **Confirmation Required** - WRITE/DELETE operations require user approval  
✅ **User Context Filtering** - All queries filtered by OU/LRE/Country  
✅ **Audit Logging** - All operations logged to database  
✅ **Error Handling** - Failed operations logged with error message  

## 📊 Database Audit Trail

Check audit logs anytime:

```sql
-- View recent operations
SELECT 
    username, 
    application, 
    operation, 
    table_name, 
    success, 
    timestamp 
FROM audit_logs 
ORDER BY timestamp DESC 
LIMIT 20;

-- View specific user's history
SELECT * FROM audit_logs 
WHERE user_id = 1 
ORDER BY timestamp DESC;
```

## 🔧 Troubleshooting

### Backend won't start

```bash
# Check Python version
python --version  # Should be 3.10+

# Check dependencies
pip list

# Reinstall if needed
pip install -r requirements.txt --force-reinstall
```

### Database connection fails

```bash
# Test PostgreSQL
psql -U postgres -c "SELECT 1"

# Check database exists
psql -U postgres -l | grep econtrols

# Check credentials in .env
cat .env | grep DB_
```

### RAG API connection fails

```bash
# Test RAG API manually
curl https://your-rag-api.azure.com/health \
  -H "Authorization: Bearer your-token"

# Check .env
cat .env | grep RAG_
```

### Queries not working

**Problem:** Intent classification fails  
**Solution:** Ensure you uploaded the 3 guide documents to RAG

**Problem:** SQL generation fails  
**Solution:** Check RAG API logs, verify SQL guide is uploaded

**Problem:** No results returned  
**Solution:** Check user context matches data in database

## 📞 Need Help?

1. Check logs: Look at terminal output
2. Check database: Verify tables exist and have data
3. Check RAG: Test RAG API directly
4. Check audit logs: See what queries were attempted
5. Enable debug: Set `DEBUG=True` in .env

## ✅ Backend Complete!

Your backend is now ready with:
- ✅ RAG-only architecture (no direct LLM)
- ✅ Dual database support
- ✅ Confirmation for dangerous operations
- ✅ Audit logging
- ✅ User context filtering
- ✅ Streaming support

**Next:** Setup the frontend or test with curl!


# 5. Configure
cp .env.example .env
# Edit .env with your RAG API credentials

# 6. Start
uvicorn main:app --reload