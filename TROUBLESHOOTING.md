# 🔧 Troubleshooting Guide

Common issues and solutions for the Enterprise RAG Chatbot application.

## 🚨 Backend Issues

### Issue 1: Backend Won't Start

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Solution:**
```bash
# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Reinstall dependencies
pip install -r requirements.txt
```

---

**Error:** `Database connection failed`

**Cause:** PostgreSQL not running or incorrect credentials

**Solution:**
```bash
# Check if PostgreSQL is running
psql -U postgres -c "SELECT 1"

# If not running, start it:
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql
# Windows: Start PostgreSQL service

# Test connection with credentials from .env
psql -h localhost -U postgres -d econtrols_db

# If password is wrong, update .env file
```

---

**Error:** `Port 8000 already in use`

**Solution:**
```bash
# Find process using port 8000
# macOS/Linux:
lsof -ti:8000
kill -9 <PID>

# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

---

### Issue 2: Azure OpenAI Connection Fails

**Error:** `Authentication failed: invalid API key`

**Solution:**
1. Verify your Azure OpenAI API key in `.env`:
```bash
AZURE_OPENAI_API_KEY=your-actual-key-here
```

2. Check your Azure OpenAI endpoint:
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
```

3. Test connection:
```python
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key="your-key",
    api_version="2024-02-15-preview",
    azure_endpoint="your-endpoint"
)

# Test
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "test"}]
)
print(response)
```

---

**Error:** `Deployment 'gpt-4' not found`

**Solution:**
Check your deployment name in Azure Portal and update `.env`:
```bash
AZURE_OPENAI_DEPLOYMENT=your-actual-deployment-name
```

---

### Issue 3: RAG API Connection Fails

**Error:** `Failed to connect to RAG API`

**Solution:**
1. Verify RAG API endpoint and token in `.env`
2. Test RAG API manually:
```bash
curl -X POST https://your-rag-api.azure.com/query \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{"query":"test"}'
```

3. If RAG API is not available yet, comment out RAG calls in code:
```python
# Temporarily disable RAG
# rag_result = await rag_client.query_rag(query)
rag_result = {"context": "", "sources": []}
```

---

### Issue 4: SQL Query Generation Errors

**Error:** `Failed to generate SQL query`

**Cause:** LangChain agent not properly configured

**Solution:**
1. Check Azure OpenAI is responding
2. Verify schema information in `sql_agent.py`
3. Add debug logging:
```python
logger.setLevel(logging.DEBUG)
```

4. Test query generation manually:
```python
from agents.sql_agent import EnterpriseRAGAgent

agent = EnterpriseRAGAgent()
result = await agent.classify_intent("How many controls?", user_context)
print(result)
```

---

### Issue 5: Database Query Execution Fails

**Error:** `column "user_ou" does not exist`

**Cause:** Database schema not created

**Solution:**
```bash
# Reinitialize databases
psql -U postgres -d econtrols_db < database/init-econtrols.sql
psql -U postgres -d mykri_db < database/init-mykri.sql
```

---

## 💻 Frontend Issues

### Issue 6: Frontend Won't Start

**Error:** `Cannot find module 'reactstrap'`

**Solution:**
```bash
cd frontend

# Clear and reinstall
rm -rf node_modules package-lock.json
npm install

# If still failing, install specifically
npm install reactstrap bootstrap bootstrap-icons easy-peasy
```

---

**Error:** `Port 3000 already in use`

**Solution:**
```bash
# Kill process on port 3000
# macOS/Linux:
lsof -ti:3000 | xargs kill -9

# Or use different port
# Update vite.config.ts:
server: {
  port: 3001
}
```

---

### Issue 7: Cannot Connect to Backend

**Error:** `Network Error: Failed to fetch`

**Cause:** Backend not running or CORS issue

**Solution:**
1. Verify backend is running:
```bash
curl http://localhost:8000/api/health
```

2. Check CORS settings in `backend/config.py`:
```python
CORS_ORIGINS: list = ["http://localhost:3000", "http://localhost:5173"]
```

3. Check browser console for CORS errors
4. Try accessing backend directly:
```
http://localhost:8000/api/docs
```

---

### Issue 8: TypeScript Compilation Errors

**Error:** `Type 'X' is not assignable to type 'Y'`

**Solution:**
1. Check types in `src/types/index.ts`
2. Ensure all required fields are present
3. Use type assertions if needed:
```typescript
const context = response.data as UserContext;
```

4. Rebuild:
```bash
npm run build
```

---

### Issue 9: State Management Not Working

**Error:** State not updating in components

**Cause:** Easy-Peasy store not properly connected

**Solution:**
1. Verify StoreProvider wraps App:
```typescript
// main.tsx
<StoreProvider store={store}>
  <App />
</StoreProvider>
```

2. Check store actions:
```typescript
const addMessage = useStoreActions((actions: StoreModel) => actions.addMessage);
```

3. Debug state:
```typescript
const state = useStoreState((state: StoreModel) => state);
console.log('Current state:', state);
```

---

### Issue 10: Streaming Not Working

**Error:** Streaming responses not appearing

**Cause:** SSE connection issues

**Solution:**
1. Check backend streaming endpoint:
```bash
curl -N http://localhost:8000/api/chat/stream \
  -H "Content-Type: application/json" \
  -d '{"query":"test",...}'
```

2. Verify fetch API usage in frontend:
```typescript
const response = await fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(request),
});

const reader = response.body?.getReader();
// Process stream...
```

3. Check for proxy configuration in `vite.config.ts`

---

## 🗄️ Database Issues

### Issue 11: User Not Found

**Error:** `User not found with ID 1`

**Solution:**
```sql
-- Check if user exists
SELECT * FROM users WHERE user_id = 1;

-- If not, insert sample user
INSERT INTO users (user_id, username, email, user_ou, user_lre, user_country) 
VALUES (1, 'john.doe', 'john.doe@company.com', 'Finance', 'US Entity', 'USA');
```

---

### Issue 12: No Data Returned from Queries

**Cause:** User context filtering too restrictive

**Solution:**
1. Check user's OU, LRE, Country:
```sql
SELECT user_ou, user_lre, user_country FROM users WHERE user_id = 1;
```

2. Verify data exists for that context:
```sql
SELECT * FROM controls 
WHERE ou = 'Finance' 
  AND lre = 'US Entity' 
  AND country = 'USA';
```

3. If no data, insert test data with matching context

---

### Issue 13: Audit Logs Not Created

**Cause:** Audit table doesn't exist or insert fails

**Solution:**
```sql
-- Check if audit table exists
SELECT * FROM audit_logs LIMIT 1;

-- If not, create it
CREATE TABLE audit_logs (
    audit_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    username VARCHAR(100) NOT NULL,
    application VARCHAR(50) NOT NULL,
    operation VARCHAR(20) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    query_executed TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE
);
```

---

## 🐳 Docker Issues

### Issue 14: Docker Containers Won't Start

**Error:** `Cannot connect to Docker daemon`

**Solution:**
```bash
# Start Docker daemon
# macOS: Open Docker Desktop
# Linux: sudo systemctl start docker

# Verify Docker is running
docker ps
```

---

**Error:** `Port already allocated`

**Solution:**
```bash
# Stop conflicting containers
docker ps
docker stop <container_id>

# Or change port in docker-compose.yml
```

---

### Issue 15: Docker Build Fails

**Error:** `Failed to build image`

**Solution:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild with no cache
docker-compose build --no-cache

# Check Dockerfile syntax
docker build -t test-backend ./backend
```

---

## 🔐 Authentication Issues

### Issue 16: Login Fails

**Cause:** User doesn't exist in selected application database

**Solution:**
1. Ensure user exists in **both** databases:
```sql
-- Check eControls
SELECT * FROM econtrols_db.users WHERE user_id = 1;

-- Check MyKRI  
SELECT * FROM mykri_db.users WHERE user_id = 1;
```

2. User data must match in both databases

---

### Issue 17: Role-Based Access Not Working

**Cause:** Role not properly set or checked

**Solution:**
1. Verify role is passed in user context:
```typescript
const contextWithRole = { ...context, role: selectedRole };
```

2. Check role-based rendering:
```typescript
{userContext.role === 'admin' && <DocumentUpload />}
```

---

## 📱 General Application Issues

### Issue 18: Chat Responses Are Incorrect

**Cause:** LLM generating wrong SQL or misclassifying intent

**Solution:**
1. Check classification result in logs
2. Adjust prompts in `sql_agent.py`
3. Add more examples to prompts:
```python
template = """
Examples:
- "How many controls?" -> SELECT COUNT(*) FROM controls
- "Show me KRIs" -> SELECT * FROM kri_indicators
...
"""
```

4. Verify SQL generation includes user context filter

---

### Issue 19: Slow Response Times

**Cause:** Multiple factors

**Solution:**
1. **Database:** Add indexes
```sql
CREATE INDEX idx_controls_status ON controls(review_status);
CREATE INDEX idx_controls_ou ON controls(ou, lre, country);
```

2. **LangChain:** Reduce temperature:
```python
self.llm = AzureChatOpenAI(
    temperature=0,  # More deterministic, faster
    ...
)
```

3. **Frontend:** Enable caching
4. **Backend:** Use connection pooling (already configured)

---

### Issue 20: Memory Leaks

**Cause:** Database connections not closing

**Solution:**
1. Ensure `finally` blocks close connections:
```python
async with session.begin():
    try:
        # operations
    finally:
        await session.close()
```

2. Use `async with` context managers
3. Monitor with:
```bash
# Check backend memory
top -p $(pgrep -f uvicorn)
```

---

## 🧪 Testing Issues

### Issue 21: Tests Fail

**Cause:** Test environment not configured

**Solution:**
```bash
# Set test environment variables
export TESTING=True
export ECONTROLS_DB_NAME=test_econtrols_db

# Create test databases
createdb test_econtrols_db
createdb test_mykri_db

# Run tests with verbose output
pytest -v tests/
```

---

## 📊 Monitoring & Debugging

### Enable Detailed Logging

**Backend:**
```python
# config.py
DEBUG = True

# main.py
logging.basicConfig(level=logging.DEBUG)
```

**Frontend:**
```typescript
// Add to components
console.log('State:', state);
console.log('Props:', props);
```

### Check Application Health

```bash
# Backend health
curl http://localhost:8000/api/health

# Database connections
psql -U postgres -l

# Frontend build
cd frontend && npm run build

# Check logs
tail -f backend/logs/app.log
```

### Performance Profiling

**Backend:**
```python
import cProfile
cProfile.run('main()')
```

**Frontend:**
```bash
# React DevTools Profiler
# Chrome DevTools -> Performance tab
```

---

## 🆘 When All Else Fails

1. **Check Logs:**
```bash
# Backend logs
tail -f logs/app.log

# Docker logs
docker-compose logs -f backend

# Frontend logs
# Check browser console (F12)
```

2. **Restart Everything:**
```bash
# Stop all
docker-compose down
pkill -f uvicorn
pkill -f node

# Start fresh
docker-compose up -d
```

3. **Reset Databases:**
```bash
# Drop and recreate
dropdb econtrols_db
dropdb mykri_db
createdb econtrols_db
createdb mykri_db

# Reinitialize
psql -U postgres -d econtrols_db < database/init-econtrols.sql
psql -U postgres -d mykri_db < database/init-mykri.sql
```

4. **Clean Install:**
```bash
# Backend
cd backend
rm -rf venv __pycache__
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Frontend
cd frontend
rm -rf node_modules package-lock.json dist
npm install
```

---

## 📞 Getting Help

If you're still stuck:

1. Check error messages carefully
2. Search GitHub issues
3. Check documentation
4. Enable debug logging
5. Contact your team lead
6. Check API documentation at `/api/docs`

---

## ✅ Prevention Checklist

To avoid issues:

- [ ] Keep dependencies updated
- [ ] Run tests before deploying
- [ ] Monitor logs regularly
- [ ] Use version control
- [ ] Document changes
- [ ] Backup databases
- [ ] Test in staging first
- [ ] Review error handling
- [ ] Check security settings
- [ ] Monitor performance