# Setup Guides and Configuration Files

## 📁 .gitignore

```gitignore
# ============================================
# BACKEND (Java/Maven)
# ============================================

# Compiled class files
*.class

# Log files
*.log
logs/

# Package files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# IDE files
.idea/
*.iml
*.iws
*.ipr
.vscode/
.settings/
.classpath
.project
*.swp
*.swo
*~

# Application specific
application-local.yml
application-dev.yml
src/main/resources/application-secrets.yml

# ============================================
# FRONTEND (React/Node)
# ============================================

# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
.nyc_output

# Production build
dist/
build/

# Misc
.DS_Store
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
pnpm-debug.log*

# Editor directories
.vscode/
.idea/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Vite
.vite/

# ============================================
# DATABASE
# ============================================

# Database files
*.db
*.sqlite
*.sqlite3

# ============================================
# OPERATING SYSTEM
# ============================================

# MacOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Linux
*~
.directory
.Trash-*

# ============================================
# SECURITY & CREDENTIALS
# ============================================

# Environment variables
.env
.env.local
.env.*.local
secrets/
*.pem
*.key
*.crt

# Backup files
*.bak
*.backup
*.old

# ============================================
# UPLOADS & TEMPORARY FILES
# ============================================

uploads/
temp/
tmp/
*.tmp

# ============================================
# DOCUMENTATION BUILD
# ============================================

# Jekyll
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata
```

---

## 📖 INSTALLATION.md

```markdown
# Installation Guide

This guide will walk you through setting up the RAG Interview System from scratch.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Prerequisites Installation](#prerequisites-installation)
3. [Database Setup](#database-setup)
4. [Backend Setup](#backend-setup)
5. [Frontend Setup](#frontend-setup)
6. [RAG API Configuration](#rag-api-configuration)
7. [SSO Configuration](#sso-configuration)
8. [Verification](#verification)
9. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Minimum Requirements

- **CPU**: 2 cores
- **RAM**: 4 GB
- **Storage**: 10 GB free space
- **OS**: Windows 10/11, macOS 10.15+, Ubuntu 20.04+

### Recommended Requirements

- **CPU**: 4 cores
- **RAM**: 8 GB
- **Storage**: 20 GB SSD
- **OS**: Latest stable version

---

## Prerequisites Installation

### 1. Install Java 17

**Windows:**
```powershell
# Download from Oracle or use Chocolatey
choco install openjdk17
```

**macOS:**
```bash
# Using Homebrew
brew install openjdk@17

# Add to PATH
echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

**Verify:**
```bash
java -version
# Output: openjdk version "17.0.x"
```

### 2. Install Maven

**Windows:**
```powershell
choco install maven
```

**macOS:**
```bash
brew install maven
```

**Linux:**
```bash
sudo apt install maven
```

**Verify:**
```bash
mvn -version
# Output: Apache Maven 3.8.x
```

### 3. Install Node.js and npm

**Windows:**
```powershell
choco install nodejs
```

**macOS:**
```bash
brew install node
```

**Linux:**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Verify:**
```bash
node -v
# Output: v18.x.x

npm -v
# Output: 9.x.x
```

### 4. Install PostgreSQL

**Windows:**
```powershell
choco install postgresql
```

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Linux:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**Verify:**
```bash
psql --version
# Output: psql (PostgreSQL) 15.x
```

### 5. Install Git

**All Platforms:**
```bash
# Windows
choco install git

# macOS
brew install git

# Linux
sudo apt install git
```

**Verify:**
```bash
git --version
# Output: git version 2.x.x
```

---

## Database Setup

### Step 1: Access PostgreSQL

```bash
# Switch to postgres user (Linux)
sudo -u postgres psql

# Direct access (Windows/macOS)
psql -U postgres
```

### Step 2: Create Database and User

```sql
-- Create database
CREATE DATABASE interview_db;

-- Create user
CREATE USER interview_user WITH PASSWORD 'your_secure_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE interview_db TO interview_user;

-- Grant schema privileges
\c interview_db
GRANT ALL ON SCHEMA public TO interview_user;

-- Exit
\q
```

### Step 3: Test Connection

```bash
psql -U interview_user -d interview_db -h localhost

# Should connect successfully
# Type \q to exit
```

### Step 4: Configure PostgreSQL (Optional)

Edit `postgresql.conf` to allow remote connections:

```bash
# Find config file location
psql -U postgres -c "SHOW config_file"

# Edit the file
# Set: listen_addresses = '*'
```

Edit `pg_hba.conf` to allow password authentication:

```
# Add this line
host    interview_db    interview_user    0.0.0.0/0    md5
```

Restart PostgreSQL:

```bash
# Linux
sudo systemctl restart postgresql

# macOS
brew services restart postgresql@15

# Windows
# Use Services app to restart PostgreSQL service
```

---

## Backend Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/your-org/rag-interview-system.git
cd rag-interview-system
```

### Step 2: Navigate to Backend

```bash
cd backend
```

### Step 3: Configure Application

Create `src/main/resources/application-local.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/interview_db
    username: interview_user
    password: your_secure_password_here
    
rag:
  api:
    base-url: https://your-rag-api.com
    client-id: your_client_id
    client-secret: your_client_secret
    application-name: interview-system
    application-key: your_app_key
    
sso:
  oauth2:
    client-id: your_sso_client_id
    client-secret: your_sso_secret
    authorization-uri: https://sso.yourorg.com/oauth/authorize
    token-uri: https://sso.yourorg.com/oauth/token
    user-info-uri: https://sso.yourorg.com/oauth/userinfo
```

Or use environment variables in `.env`:

```bash
# Database
DB_USERNAME=interview_user
DB_PASSWORD=your_secure_password_here

# RAG API
RAG_BASE_URL=https://your-rag-api.com
RAG_CLIENT_ID=your_client_id
RAG_CLIENT_SECRET=your_client_secret
RAG_APP_NAME=interview-system
RAG_APP_KEY=your_app_key

# SSO
SSO_CLIENT_ID=your_sso_client_id
SSO_CLIENT_SECRET=your_sso_secret
SSO_AUTH_URI=https://sso.yourorg.com/oauth/authorize
SSO_TOKEN_URI=https://sso.yourorg.com/oauth/token
SSO_USER_INFO_URI=https://sso.yourorg.com/oauth/userinfo
```

### Step 4: Build Project

```bash
# Clean and build
mvn clean install

# Skip tests if needed
mvn clean install -DskipTests
```

### Step 5: Run Application

```bash
# Option 1: Using Maven
mvn spring-boot:run

# Option 2: Using JAR
java -jar target/rag-interview-system-1.0.0.jar

# Option 3: With profile
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

**Expected Output:**
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)

INFO  Application - Started Application in 8.5 seconds
```

### Step 6: Verify Backend

```bash
# Test health endpoint
curl http://localhost:8080/actuator/health

# Test API endpoint
curl http://localhost:8080/api/job-descriptions
```

---

## Frontend Setup

### Step 1: Navigate to Frontend

```bash
cd frontend
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Configure Environment

Create `.env` file:

```bash
VITE_API_BASE_URL=http://localhost:8080/api
```

For production:

```bash
VITE_API_BASE_URL=https://api.yourcompany.com/api
```

### Step 4: Run Development Server

```bash
npm run dev
```

**Expected Output:**
```
  VITE v5.0.8  ready in 823 ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
  ➜  press h to show help
```

### Step 5: Build for Production

```bash
npm run build
```

Output will be in `dist/` folder.

### Step 6: Verify Frontend

Open browser and navigate to:
```
http://localhost:3000
```

You should see the RAG Interview System interface.

---

## RAG API Configuration

### Step 1: Obtain RAG Credentials

Contact your RAG API provider to get:
- Base URL
- Client ID
- Client Secret
- Application Name
- Application Key

### Step 2: Test RAG Connection

```bash
# Test token endpoint
curl -X POST https://your-rag-api.com/oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your_client_id",
    "client_secret": "your_secret",
    "application_name": "interview-system",
    "application_key": "your_key",
    "grant_type": "client_credentials"
  }'
```

**Expected Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### Step 3: Test RAG Endpoints

```bash
# Get token
TOKEN="your_access_token"

# Test chat endpoint
curl -X POST https://your-rag-api.com/api/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test message",
    "context": "test"
  }'

# Test upload endpoint
curl -X POST https://your-rag-api.com/api/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test.pdf" \
  -F "document_type=test"
```

---

## SSO Configuration

### Step 1: Register Application

Register your application with your SSO provider:

1. Go to your SSO admin console
2. Create new OAuth2 application
3. Set redirect URIs:
   - Development: `http://localhost:8080/login/oauth2/code/sso`
   - Production: `https://yourapp.com/login/oauth2/code/sso`
4. Note down Client ID and Client Secret

### Step 2: Configure Spring Security

The security configuration is already in place in `SecurityConfig.java`.

### Step 3: Test SSO Login

```bash
# Navigate to login endpoint
curl http://localhost:8080/login

# Should redirect to SSO provider
```

---

## Verification

### Complete System Test

#### 1. Backend Health Check

```bash
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}
```

#### 2. Database Connection

```bash
curl http://localhost:8080/api/job-descriptions
# Expected: [] or list of job descriptions
```

#### 3. RAG API Connection

Check application logs for:
```
INFO  RagService - RAG API token obtained successfully
```

#### 4. Frontend Access

Navigate to `http://localhost:3000` and verify:
- [ ] Home page loads
- [ ] Navigation works
- [ ] No console errors (F12)

#### 5. End-to-End Test

1. Create a job description
2. Schedule an interview
3. Start interview as candidate
4. Complete interview
5. View evaluation

---

## Troubleshooting

### Backend Won't Start

**Issue:** Port 8080 already in use

**Solution:**
```bash
# Find process using port
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Kill process or change port in application.yml
server:
  port: 8081
```

---

**Issue:** Database connection failed

**Solution:**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql  # Linux
brew services list  # macOS

# Test connection manually
psql -U interview_user -d interview_db -h localhost
```

---

**Issue:** Could not find or load main class

**Solution:**
```bash
# Clean and rebuild
mvn clean install -U

# Check JAVA_HOME
echo $JAVA_HOME  # Should point to JDK 17
```

### Frontend Won't Start

**Issue:** Module not found

**Solution:**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

**Issue:** Cannot connect to backend

**Solution:**
```bash
# Check .env file
cat .env
# Should have: VITE_API_BASE_URL=http://localhost:8080/api

# Verify backend is running
curl http://localhost:8080/api/job-descriptions
```

### Database Issues

**Issue:** Tables not created

**Solution:**
```sql
-- Check if tables exist
\c interview_db
\dt

-- If not, check application logs for Hibernate errors
-- Verify: spring.jpa.hibernate.ddl-auto=update
```

---

**Issue:** Permission denied

**Solution:**
```sql
-- Grant all privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO interview_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO interview_user;
```

### RAG API Issues

**Issue:** Failed to obtain token

**Solution:**
```bash
# Verify credentials
# Test manually with curl
curl -X POST https://your-rag-api.com/oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your_client_id",
    "client_secret": "your_secret",
    "application_name": "interview-system",
    "application_key": "your_key",
    "grant_type": "client_credentials"
  }'

# Check firewall/network access
ping your-rag-api.com
```

---

## Next Steps

After successful installation:

1. Read the [Usage Guide](README.md#usage-guide)
2. Review [API Documentation](README.md#api-documentation)
3. Set up [Development Environment](DEVELOPMENT.md)
4. Configure [CI/CD Pipeline](docs/ci-cd.md)

---

## Getting Help

If you encounter issues:

1. Check [Troubleshooting](#troubleshooting)
2. Search [GitHub Issues](https://github.com/your-org/rag-interview-system/issues)
3. Ask in [GitHub Discussions](https://github.com/your-org/rag-interview-system/discussions)
4. Contact: support@yourcompany.com

---

**Installation complete! 🎉**
```

---

## 🧪 API_TESTING.md

```markdown
# API Testing Guide

Complete guide for testing the RAG Interview System APIs.

## Table of Contents

1. [Testing Tools](#testing-tools)
2. [Environment Setup](#environment-setup)
3. [Authentication](#authentication)
4. [API Endpoints Testing](#api-endpoints-testing)
5. [Automated Testing](#automated-testing)
6. [Performance Testing](#performance-testing)

---

## Testing Tools

### Recommended Tools

1. **cURL** - Command line testing
2. **Postman** - Interactive API testing
3. **HTTPie** - User-friendly HTTP client
4. **JMeter** - Performance testing
5. **Newman** - Postman CLI runner

### Install Tools

```bash
# cURL (usually pre-installed)
curl --version

# HTTPie
pip install httpie

# Postman
# Download from: https://www.postman.com/downloads/

# Newman
npm install -g newman
```

---

## Environment Setup

### Base URLs

```bash
# Development
export API_BASE=http://localhost:8080/api

# Staging
export API_BASE=https://staging-api.yourcompany.com/api

# Production
export API_BASE=https://api.yourcompany.com/api
```

### Authentication Headers

```bash
export USER_EMAIL="hr@company.com"
```

---

## API Endpoints Testing

### 1. Job Descriptions

#### Create Job Description

**cURL:**
```bash
curl -X POST "$API_BASE/job-descriptions" \
  -H "User-Email: $USER_EMAIL" \
  -F 'data={
    "title": "Senior Java Developer",
    "description": "We are looking for an experienced Java developer...",
    "requirements": "5+ years of Java experience",
    "interviewMode": "MEDIUM"
  };type=application/json' \
  -F "file=@job_description.pdf"
```

**HTTPie:**
```bash
http POST "$API_BASE/job-descriptions" \
  User-Email:$USER_EMAIL \
  data='{"title":"Senior Java Developer","description":"...","interviewMode":"MEDIUM"}' \
  file@job_description.pdf
```

**Expected Response (200 OK):**
```json
{
  "id": 1,
  "title": "Senior Java Developer",
  "description": "We are looking for...",
  "requirements": "5+ years...",
  "interviewMode": "MEDIUM",
  "ragDocumentId": "doc_abc123",
  "createdBy": "hr@company.com",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00",
  "isActive": true
}
```

#### Get All Job Descriptions

```bash
curl -X GET "$API_BASE/job-descriptions" \
  -H "User-Email: $USER_EMAIL"
```

**Expected Response (200 OK):**
```json
[
  {
    "id": 1,
    "title": "Senior Java Developer",
    "interviewMode": "MEDIUM",
    ...
  },
  {
    "id": 2,
    "title": "Frontend Developer",
    "interviewMode": "EASY",
    ...
  }
]
```

#### Get Job Description by ID

```bash
curl -X GET "$API_BASE/job-descriptions/1" \
  -H "User-Email: $USER_EMAIL"
```

#### Delete Job Description

```bash
curl -X DELETE "$API_BASE/job-descriptions/1" \
  -H "User-Email: $USER_EMAIL"
```

**Expected Response (204 No Content)**

---

### 2. Interview Sessions

#### Create Interview Session

```bash
curl -X POST "$API_BASE/interviews/create" \
  -H "User-Email: $USER_EMAIL" \
  -F 'data={
    "candidateName": "John Doe",
    "email": "john.doe@email.com",
    "phone": "+1234567890",
    "jobDescriptionId": 1
  };type=application/json' \
  -F "resume=@resume.pdf"
```

**Expected Response (200 OK):**
```json
{
  "session_id": 1,
  "session_token": "550e8400-e29b-41d4-a716-446655440000",
  "candidate_name": "John Doe",
  "job_title": "Senior Java Developer",
  "interview_mode": "MEDIUM",
  "total_steps": 10,
  "eligible": true
}
```

**Error Response - Candidate in Cooldown:**
```json
{
  "error": "Candidate is in cooldown period",
  "cooldown_until": "2024-04-15T10:30:00"
}
```

**Error Response - Not Eligible:**
```json
{
  "error": "Candidate not eligible for this position",
  "eligible": false
}
```

#### Start Interview

```bash
curl -X POST "$API_BASE/interviews/start?email=john.doe@email.com"
```

**Expected Response (200 OK):**
```json
{
  "questionId": 1,
  "questionText": "Please introduce yourself and tell us about your background.",
  "category": "GENERAL",
  "stepNumber": 1,
  "totalSteps": 10,
  "currentStep": 1
}
```

#### Get Session Status

```bash
SESSION_TOKEN="550e8400-e29b-41d4-a716-446655440000"
curl -X GET "$API_BASE/interviews/session/$SESSION_TOKEN/status"
```

**Expected Response (200 OK):**
```json
{
  "session_id": 1,
  "status": "IN_PROGRESS",
  "current_step": 3,
  "total_steps": 10,
  "candidate_name": "John Doe",
  "job_title": "Senior Java Developer"
}
```

#### Submit Answer

```bash
SESSION_ID=1
QUESTION_ID=1

curl -X POST "$API_BASE/interviews/session/$SESSION_ID/answer/$QUESTION_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "answerText": "I have 5 years of experience in Java development, working primarily with Spring Boot and microservices architecture. I have led teams of 3-5 developers and have experience in both backend and full-stack development."
  }'
```

**Expected Response (200 OK):**
```json
{
  "answer_submitted": true,
  "step_number": 1,
  "score": 85.5
}
```

#### Get Next Question

```bash
curl -X GET "$API_BASE/interviews/session/$SESSION_ID/next-question"
```

**Expected Response (200 OK):**
```json
{
  "questionId": 2,
  "questionText": "Explain the difference between @Component, @Service, and @Repository annotations in Spring.",
  "category": "TECHNICAL",
  "stepNumber": 2,
  "totalSteps": 10,
  "currentStep": 2
}
```

#### Complete Interview

```bash
curl -X POST "$API_BASE/interviews/session/$SESSION_ID/complete"
```

**Expected Response (200 OK):**
```json
{
  "session_completed": true,
  "cooldown_until": "2024-04-15T10:30:00",
  "evaluation_id": 1,
  "message": "Thank you for your time. Your interview has been submitted for evaluation."
}
```

---

### 3. Dashboard & Evaluations

#### Get All Evaluations

```bash
curl -X GET "$API_BASE/dashboard/evaluations" \
  -H "User-Email: $USER_EMAIL"
```

**Expected Response (200 OK):**
```json
[
  {
    "codingScore": 85.5,
    "behavioralScore": 78.0,
    "technicalScore": 82.3,
    "overallScore": 81.9,
    "codingFeedback": "Strong understanding of algorithms and data structures...",
    "behavioralFeedback": "Good communication skills...",
    "technicalFeedback": "Solid grasp of Spring framework...",
    "recommendation": "Excellent candidate. Strongly recommend for next round.",
    "proceedToNextRound": true
  }
]
```

#### Get Evaluation by Session

```bash
curl -X GET "$API_BASE/dashboard/evaluations/session/1" \
  -H "User-Email: $USER_EMAIL"
```

---

## Automated Testing

### Postman Collection

Create a Postman collection with the following structure:

```json
{
  "info": {
    "name": "RAG Interview System API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:8080/api"
    },
    {
      "key": "userEmail",
      "value": "hr@company.com"
    }
  ],
  "item": [
    {
      "name": "Job Descriptions",
      "item": [
        {
          "name": "Create Job Description",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "User-Email",
                "value": "{{userEmail}}"
              }
            ],
            "body": {
              "mode": "formdata",
              "formdata": [
                {
                  "key": "data",
                  "value": "{\"title\":\"Test Job\",\"description\":\"Test\",\"interviewMode\":\"MEDIUM\"}",
                  "type": "text"
                }
              ]
            },
            "url": {
              "raw": "{{baseUrl}}/job-descriptions",
              "host": ["{{baseUrl}}"],
              "path": ["job-descriptions"]
            }
          }
        }
      ]
    }
  ]
}
```

### Newman CLI Testing

```bash
# Run collection
newman run postman_collection.json \
  --environment postman_environment.json \
  --reporters cli,json \
  --reporter-json-export results.json

# Run with specific folder
newman run postman_collection.json \
  --folder "Job Descriptions"

# Run with iterations
newman run postman_collection.json \
  --iteration-count 10
```

---

## Performance Testing

### JMeter Test Plan

Create `interview-system-test.jmx`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.5">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Interview System Load Test">
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments">
        <collectionProp name="Arguments.arguments">
          <elementProp name="BASE_URL" elementType="Argument">
            <stringProp name="Argument.name">BASE_URL</stringProp>
            <stringProp name="Argument.value">http://localhost:8080/api</stringProp>
          </elementProp>
        </collectionProp>
      </elementProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Users">
        <intProp name="ThreadGroup.num_threads">50</intProp>
        <intProp name="ThreadGroup.ramp_time">10</intProp>
        <longProp name="ThreadGroup.duration">60</longProp>
      </ThreadGroup>
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="Get Job Descriptions">
          <stringProp name="HTTPSampler.domain">${BASE_URL}</stringProp>
          <stringProp name="HTTPSampler.path">/job-descriptions</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
        </HTTPSamplerProxy>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

### Run JMeter Test

```bash
# GUI mode
jmeter -t interview-system-test.jmx

# CLI mode
jmeter -n -t interview-system-test.jmx \
  -l results.jtl \
  -e -o report/

# View report
open report/index.html
```

### Load Testing with k6

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  const res = http.get('http://localhost:8080/api/job-descriptions', {
    headers: { 'User-Email': 'hr@company.com' },
  });
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

Run k6:
```bash
k6 run load-test.js
```

---

## Test Data

### Sample Job Description

```json
{
  "title": "Senior Full Stack Developer",
  "description": "We are seeking an experienced Full Stack Developer with expertise in Java, Spring Boot, React, and modern web technologies. The ideal candidate will have strong problem-solving skills and experience building scalable applications.",
  "requirements": "- 5+ years of software development experience\n- Proficiency in Java and Spring Boot\n- Experience with React and modern JavaScript\n- Strong understanding of RESTful APIs\n- Experience with PostgreSQL or similar databases\n- Excellent communication skills",
  "interviewMode": "HARD"
}
```

### Sample Candidate Data

```json
{
  "candidateName": "Jane Smith",
  "email": "jane.smith@email.com",
  "phone": "+1-555-0123",
  "jobDescriptionId": 1
}
```

---

## Validation Checklist

- [ ] All endpoints return correct status codes
- [ ] Response times are acceptable (<500ms)
- [ ] Error messages are descriptive
- [ ] Authentication works correctly
- [ ] File uploads work properly
- [ ] Data validation is enforced
- [ ] Database transactions are handled
- [ ] No memory leaks observed
- [ ] Concurrent requests handled properly
- [ ] API documentation is accurate

---

**Happy Testing! 🧪**
```

This completes the comprehensive documentation suite for your RAG Interview System GitHub repository!