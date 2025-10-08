# 🎯 RAG-Powered Interview System

> An AI-powered automated interview platform leveraging RAG (Retrieval-Augmented Generation) for intelligent candidate evaluation.

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![React](https://img.shields.io/badge/React-19.0.0-blue.svg)](https://reactjs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Usage Guide](#usage-guide)
- [Database Schema](#database-schema)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

The RAG-Powered Interview System is an enterprise-grade solution for automating technical interviews using AI. It integrates with your organization's RAG model and SSO to provide intelligent, context-aware interview questions and real-time candidate evaluation.

### Why This System?

- **🤖 AI-Powered**: Leverages RAG models for intelligent question generation and answer evaluation
- **📊 Data-Driven**: Comprehensive analytics and scoring across multiple dimensions
- **🔒 Secure**: SSO integration and role-based access control
- **🚀 Scalable**: Built with Spring Boot and React for enterprise scalability
- **📱 Responsive**: Mobile-friendly interface for candidates and HR teams

---

## ✨ Features

### For HR Teams

- ✅ **Job Description Management**
  - Upload and manage job descriptions with different difficulty levels (Easy, Medium, Hard)
  - Automatic RAG indexing for context-aware question generation
  - Active/inactive status management

- ✅ **Interview Scheduling**
  - Create interview sessions with candidate details
  - Resume upload and automatic eligibility checking via RAG
  - Bulk session management

- ✅ **Evaluation Dashboard**
  - Real-time candidate performance metrics
  - Category-wise scoring (Coding, Technical, Behavioral)
  - Visual analytics with charts and graphs
  - Detailed feedback reports
  - Hiring recommendations based on AI analysis

### For Candidates

- ✅ **Simple Email-Based Access**
  - No registration required - just email verification
  - Secure session token system

- ✅ **Interactive Interview Experience**
  - Step-by-step question flow
  - Real-time progress tracking
  - Clear instructions and guidance
  - Mobile-responsive interface

- ✅ **Intelligent Questioning**
  - AI-generated questions based on job requirements and resume
  - No repeated questions (tracked per candidate)
  - Adaptive difficulty based on interview mode

### System Intelligence

- ✅ **Smart Question Generation**
  - RAG-powered context-aware questions
  - Prevents question repetition across sessions
  - Category distribution (Coding, Technical, Behavioral, General)

- ✅ **Real-Time Evaluation**
  - AI-powered answer assessment
  - Immediate scoring and feedback
  - Strength and improvement identification

- ✅ **Candidate Management**
  - 90-day cooldown period between interviews
  - Historical interview tracking
  - Resume and question archive

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend Layer                       │
│                      React 19 + Vite                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ HR Dashboard │  │   Candidate  │  │  Evaluation  │     │
│  │              │  │    Portal    │  │   Dashboard  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API
┌────────────────────────▼────────────────────────────────────┐
│                      Backend Layer                           │
│                   Spring Boot 3.2.0                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Controller Layer                         │  │
│  │  - JobDescriptionController                          │  │
│  │  - InterviewController                               │  │
│  │  - DashboardController                               │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                        │
│  ┌──────────────────▼───────────────────────────────────┐  │
│  │              Service Layer                            │  │
│  │  - JobDescriptionService                             │  │
│  │  - CandidateService                                  │  │
│  │  - InterviewService                                  │  │
│  │  - RagService (WebClient)                            │  │
│  │  - DashboardService                                  │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                        │
│  ┌──────────────────▼───────────────────────────────────┐  │
│  │           Repository Layer (JPA)                      │  │
│  └──────────────────┬───────────────────────────────────┘  │
└────────────────────┬┴────────────────────────────────────┬──┘
                     │                                      │
           ┌─────────▼─────────┐              ┌───────────▼──────────┐
           │   PostgreSQL DB   │              │   RAG API Service    │
           │  - Job Descriptions│              │  - Chat Endpoint     │
           │  - Candidates      │              │  - Query Endpoint    │
           │  - Sessions        │              │  - Upload Endpoint   │
           │  - Questions       │              │  - OAuth Token       │
           │  - Answers         │              └──────────────────────┘
           │  - Evaluations     │
           └────────────────────┘
                     │
           ┌─────────▼─────────┐
           │    SSO Provider    │
           │  - OAuth2 Login    │
           └────────────────────┘
```

### Technology Stack

**Backend:**
- Java 17
- Spring Boot 3.2.0
- Spring Data JPA (Hibernate)
- Spring WebFlux (WebClient for RAG)
- Spring Security + OAuth2
- PostgreSQL 15+
- Maven 3.8+

**Frontend:**
- React 19
- Vite 5
- React Router DOM 6
- Axios
- Recharts (Data Visualization)

**External Services:**
- RAG API (Custom)
- SSO OAuth2 Provider

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

```bash
# Java Development Kit 17 or higher
java -version
# Output: openjdk version "17.0.x"

# Maven 3.8 or higher
mvn -version
# Output: Apache Maven 3.8.x

# Node.js 18 or higher
node -version
# Output: v18.x.x

# npm 9 or higher
npm -version
# Output: 9.x.x

# PostgreSQL 15 or higher
psql --version
# Output: psql (PostgreSQL) 15.x
```

### External Services

1. **RAG API Service**
   - Base URL
   - Client ID and Secret
   - Application Name and Key
   - API Endpoints configured

2. **SSO OAuth2 Provider**
   - Client ID and Secret
   - Authorization, Token, and UserInfo URIs

3. **PostgreSQL Database**
   - Running instance
   - Database created
   - User credentials

---

## 🚀 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/rag-interview-system.git
cd rag-interview-system
```

### Step 2: Database Setup

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE interview_db;

# Create user (optional)
CREATE USER interview_user WITH PASSWORD 'your_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE interview_db TO interview_user;

# Exit
\q
```

### Step 3: Backend Setup

```bash
# Navigate to backend directory
cd backend

# Copy environment template
cp src/main/resources/application-example.yml src/main/resources/application.yml

# Edit configuration (see Configuration section below)
nano src/main/resources/application.yml

# Build the project
mvn clean install

# Skip tests if needed
mvn clean install -DskipTests
```

### Step 4: Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit environment variables
nano .env
```

---

## ⚙️ Configuration

### Backend Configuration

Edit `backend/src/main/resources/application.yml`:

```yaml
server:
  port: 8080

spring:
  application:
    name: rag-interview-system
    
  # Database Configuration
  datasource:
    url: jdbc:postgresql://localhost:5432/interview_db
    username: interview_user
    password: your_secure_password
    driver-class-name: org.postgresql.Driver
    
  # JPA/Hibernate Configuration
  jpa:
    hibernate:
      ddl-auto: update  # Use 'validate' in production
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true
        
  # File Upload Configuration
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

# RAG API Configuration
rag:
  api:
    base-url: https://your-rag-api.com
    client-id: ${RAG_CLIENT_ID:your_client_id}
    client-secret: ${RAG_CLIENT_SECRET:your_client_secret}
    application-name: ${RAG_APP_NAME:interview-system}
    application-key: ${RAG_APP_KEY:your_app_key}
    token-endpoint: /oauth/token
    chat-endpoint: /api/chat
    query-endpoint: /api/query
    upload-endpoint: /api/upload
    
# SSO Configuration
sso:
  oauth2:
    client-id: ${SSO_CLIENT_ID:your_sso_client_id}
    client-secret: ${SSO_CLIENT_SECRET:your_sso_secret}
    authorization-uri: ${SSO_AUTH_URI:https://sso.yourorg.com/oauth/authorize}
    token-uri: ${SSO_TOKEN_URI:https://sso.yourorg.com/oauth/token}
    user-info-uri: ${SSO_USER_INFO_URI:https://sso.yourorg.com/oauth/userinfo}
    
# Interview Configuration
interview:
  candidate:
    cooldown-days: 90
  question:
    max-per-session: 15
    min-per-session: 8
  evaluation:
    pass-threshold: 60

# Logging Configuration
logging:
  level:
    com.interview: INFO
    org.springframework: WARN
    org.hibernate: WARN
```

### Environment Variables

Create `.env` file in the backend root:

```bash
# Database
DB_USERNAME=interview_user
DB_PASSWORD=your_secure_password

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

### Frontend Configuration

Create `frontend/.env`:

```bash
VITE_API_BASE_URL=http://localhost:8080/api
```

For production:

```bash
VITE_API_BASE_URL=https://api.yourcompany.com/api
```

---

## 🎮 Running the Application

### Development Mode

**Terminal 1 - Backend:**

```bash
cd backend
mvn spring-boot:run
```

The backend will start on `http://localhost:8080`

**Terminal 2 - Frontend:**

```bash
cd frontend
npm run dev
```

The frontend will start on `http://localhost:3000`

### Production Mode

**Backend:**

```bash
cd backend
mvn clean package
java -jar target/rag-interview-system-1.0.0.jar
```

**Frontend:**

```bash
cd frontend
npm run build
# Serve the 'dist' folder with your web server
```

---

## 📚 API Documentation

### Base URL

```
http://localhost:8080/api
```

### Authentication

All API endpoints require authentication headers:

```
User-Email: hr@company.com
```

### Endpoints

#### Job Descriptions

**Create Job Description**

```http
POST /api/job-descriptions
Content-Type: multipart/form-data

Form Data:
- data: {
    "title": "Senior Software Engineer",
    "description": "Job description text...",
    "requirements": "Requirements text...",
    "interviewMode": "MEDIUM"
  }
- file: [job_description.pdf] (optional)

Response: 200 OK
{
  "id": 1,
  "title": "Senior Software Engineer",
  "description": "...",
  "interviewMode": "MEDIUM",
  "ragDocumentId": "doc_123",
  "createdAt": "2024-01-15T10:30:00",
  "isActive": true
}
```

**Get All Active Job Descriptions**

```http
GET /api/job-descriptions

Response: 200 OK
[
  {
    "id": 1,
    "title": "Senior Software Engineer",
    "interviewMode": "MEDIUM",
    ...
  }
]
```

**Get Job Description by ID**

```http
GET /api/job-descriptions/{id}

Response: 200 OK
{
  "id": 1,
  "title": "Senior Software Engineer",
  ...
}
```

**Deactivate Job Description**

```http
DELETE /api/job-descriptions/{id}

Response: 204 No Content
```

#### Interviews

**Create Interview Session**

```http
POST /api/interviews/create
Content-Type: multipart/form-data

Form Data:
- data: {
    "candidateName": "John Doe",
    "email": "john.doe@email.com",
    "phone": "+1234567890",
    "jobDescriptionId": 1
  }
- resume: [resume.pdf]

Response: 200 OK
{
  "session_id": 1,
  "session_token": "abc123-def456-ghi789",
  "candidate_name": "John Doe",
  "job_title": "Senior Software Engineer",
  "interview_mode": "MEDIUM",
  "total_steps": 10,
  "eligible": true
}
```

**Start Interview**

```http
POST /api/interviews/start?email=john.doe@email.com

Response: 200 OK
{
  "questionId": 1,
  "questionText": "Please introduce yourself...",
  "category": "GENERAL",
  "stepNumber": 1,
  "totalSteps": 10,
  "currentStep": 1
}
```

**Get Session Status**

```http
GET /api/interviews/session/{sessionToken}/status

Response: 200 OK
{
  "session_id": 1,
  "status": "IN_PROGRESS",
  "current_step": 3,
  "total_steps": 10,
  "candidate_name": "John Doe",
  "job_title": "Senior Software Engineer"
}
```

**Submit Answer**

```http
POST /api/interviews/session/{sessionId}/answer/{questionId}
Content-Type: application/json

{
  "answerText": "I have 5 years of experience in Java..."
}

Response: 200 OK
{
  "answer_submitted": true,
  "step_number": 2,
  "score": 85.5
}
```

**Get Next Question**

```http
GET /api/interviews/session/{sessionId}/next-question

Response: 200 OK
{
  "questionId": 2,
  "questionText": "Explain the concept of...",
  "category": "TECHNICAL",
  "stepNumber": 3,
  "totalSteps": 10,
  "currentStep": 3
}
```

**Complete Interview**

```http
POST /api/interviews/session/{sessionId}/complete

Response: 200 OK
{
  "session_completed": true,
  "cooldown_until": "2024-04-15T10:30:00",
  "evaluation_id": 1,
  "message": "Thank you for your time..."
}
```

#### Dashboard

**Get All Evaluations**

```http
GET /api/dashboard/evaluations

Response: 200 OK
[
  {
    "codingScore": 85.5,
    "behavioralScore": 78.0,
    "technicalScore": 82.3,
    "overallScore": 81.9,
    "codingFeedback": "...",
    "behavioralFeedback": "...",
    "technicalFeedback": "...",
    "recommendation": "Excellent candidate...",
    "proceedToNextRound": true
  }
]
```

**Get Evaluation by Session**

```http
GET /api/dashboard/evaluations/session/{sessionId}

Response: 200 OK
{
  "codingScore": 85.5,
  "behavioralScore": 78.0,
  "technicalScore": 82.3,
  "overallScore": 81.9,
  ...
}
```

---

## 📖 Usage Guide

### For HR Teams

#### 1. Create a Job Description

1. Navigate to **HR Dashboard**
2. Click **Create Job** tab
3. Fill in:
   - Job Title
   - Description
   - Requirements
   - Interview Mode (Easy/Medium/Hard)
4. Optionally upload a detailed job description document
5. Click **Create Job Description**

#### 2. Schedule an Interview

1. Go to **Schedule Interview** tab
2. Enter candidate details:
   - Full Name
   - Email (this will be used for interview access)
   - Phone (optional)
3. Select the job position
4. Upload candidate's resume (PDF/DOC)
5. Click **Create Interview Session**
6. Share the session token with the candidate

#### 3. Monitor Evaluations

1. Navigate to **Evaluations** page
2. View all completed interviews
3. Click on any evaluation to see:
   - Overall score
   - Category-wise breakdown
   - Detailed feedback
   - Hiring recommendation
   - Visual analytics

### For Candidates

#### 1. Access Interview

1. Go to **Candidate Portal**
2. Enter your registered email
3. Click **Start Interview**

#### 2. Complete Interview

1. Read each question carefully
2. Type your answer (minimum 10 characters)
3. Click **Next Question**
4. Progress bar shows your completion status
5. After all questions, click **Close Interview**

#### 3. Tips for Success

- Find a quiet environment
- Read questions thoroughly
- Provide detailed, specific answers
- Use examples when possible
- Take your time - quality over speed

---

## 🗄️ Database Schema

### Entity Relationship Diagram

```
┌─────────────────────┐
│  job_descriptions   │
├─────────────────────┤
│ id (PK)             │
│ title               │
│ description         │
│ requirements        │
│ interview_mode      │
│ rag_document_id     │
│ created_by          │
│ is_active           │
└──────────┬──────────┘
           │
           │ 1:N
           ▼
┌─────────────────────┐       ┌─────────────────────┐
│ interview_sessions  │◄──────┤    candidates       │
├─────────────────────┤  N:1  ├─────────────────────┤
│ id (PK)             │       │ id (PK)             │
│ session_token       │       │ full_name           │
│ candidate_id (FK)   │       │ email (UK)          │
│ job_description_id  │       │ phone               │
│ interview_mode      │       │ resume_path         │
│ status              │       │ rag_resume_id       │
│ current_step        │       └─────────────────────┘
│ total_steps         │
│ started_at          │
│ completed_at        │
└──────────┬──────────┘
           │
           │ 1:N
           ▼
┌─────────────────────┐
│     questions       │
├─────────────────────┤
│ id (PK)             │
│ session_id (FK)     │
│ question_text       │
│ category            │
│ difficulty          │
│ step_number         │
│ rag_question_id     │
└──────────┬──────────┘
           │
           │ 1:1
           ▼
┌─────────────────────┐
│      answers        │
├─────────────────────┤
│ id (PK)             │
│ question_id (FK)    │
│ answer_text         │
│ evaluation_score    │
│ evaluation_feedback │
│ strengths           │
│ improvements        │
│ evaluated_at        │
└─────────────────────┘

┌─────────────────────┐
│ evaluation_results  │
├─────────────────────┤
│ id (PK)             │
│ session_id (FK)     │
│ coding_score        │
│ behavioral_score    │
│ technical_score     │
│ overall_score       │
│ coding_feedback     │
│ behavioral_feedback │
│ technical_feedback  │
│ recommendation      │
│ proceed_to_next     │
└─────────────────────┘

┌─────────────────────┐
│ interview_history   │
├─────────────────────┤
│ id (PK)             │
│ candidate_id (FK)   │
│ session_id (FK)     │
│ interview_date      │
│ cooldown_until      │
└─────────────────────┘

┌─────────────────────┐
│ asked_questions_    │
│     archive         │
├─────────────────────┤
│ id (PK)             │
│ candidate_id (FK)   │
│ question_text       │
│ category            │
│ asked_at            │
└─────────────────────┘
```

### Tables Description

**job_descriptions**: Stores job postings and requirements  
**candidates**: Candidate information and resume references  
**interview_sessions**: Active and completed interview sessions  
**questions**: Questions asked during interviews  
**answers**: Candidate responses with AI evaluations  
**evaluation_results**: Final evaluation metrics and recommendations  
**interview_history**: Historical record for cooldown tracking  
**asked_questions_archive**: Prevents question repetition  

---

## 🚢 Deployment

### Docker Deployment

**Backend Dockerfile:**

```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/rag-interview-system-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Frontend Dockerfile:**

```dockerfile
FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: interview_db
      POSTGRES_USER: interview_user
      POSTGRES_PASSWORD: your_secure_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/interview_db
      SPRING_DATASOURCE_USERNAME: interview_user
      SPRING_DATASOURCE_PASSWORD: your_secure_password
      RAG_BASE_URL: ${RAG_BASE_URL}
      RAG_CLIENT_ID: ${RAG_CLIENT_ID}
      RAG_CLIENT_SECRET: ${RAG_CLIENT_SECRET}
    depends_on:
      - postgres

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

**Run with Docker Compose:**

```bash
docker-compose up -d
```

### Cloud Deployment

#### AWS Deployment

**Backend (Elastic Beanstalk):**

```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p corretto-17 rag-interview-backend

# Create environment
eb create rag-interview-prod

# Deploy
eb deploy
```

**Frontend (S3 + CloudFront):**

```bash
# Build
npm run build

# Deploy to S3
aws s3 sync dist/ s3://your-bucket-name

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

#### Heroku Deployment

**Backend:**

```bash
heroku create rag-interview-backend
heroku addons:create heroku-postgresql:standard-0
git push heroku main
```

**Frontend:**

```bash
heroku create rag-interview-frontend
heroku buildpacks:set heroku/nodejs
git push heroku main
```

---

## 🔧 Troubleshooting

### Common Issues

#### Database Connection Failed

**Problem:** `Connection to localhost:5432 refused`

**Solution:**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql

# Verify connection
psql -U postgres -h localhost
```

#### RAG API Authentication Failed

**Problem:** `Failed to obtain RAG API token`

**Solution:**
- Verify RAG credentials in `application.yml`
- Check RAG API is accessible
- Test token endpoint manually:

```bash
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

#### Port Already in Use

**Problem:** `Port 8080 is already in use`

**Solution:**
```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>

# Or change port in application.yml
server:
  port: 8081
```

#### Frontend Cannot Connect to Backend

**Problem:** `Network Error` or `CORS Error`

**Solution:**
- Verify backend is running: `curl http://localhost:8080/api/job-descriptions`
- Check `VITE_API_BASE_URL` in frontend `.env`
- Ensure CORS is configured in `CorsConfig.java`

#### File Upload Too Large

**Problem:** `Maximum upload size exceeded`

**Solution:**
Update `application.yml`:
```yaml
spring:
  servlet:
    multipart:
      max-file-size: 20MB
      max-request-size: 20MB
```

### Logs

**Backend Logs:**
```bash
# View logs
tail -f logs/spring-boot-application.log

# Or if running with Maven
mvn spring-boot:run | tee application.log
```

**Frontend Logs:**
```bash
# Browser console (F12)
# Or Vite dev server output
npm run dev
```

### Database Issues

**Reset Database:**
```sql
-- Connect to PostgreSQL
psql -U postgres

-- Drop and recreate
DROP DATABASE interview_db;
CREATE DATABASE interview_db;
```

**View Tables:**
```sql
\c interview_db
\dt
```

**Check Data:**
```sql
SELECT * FROM job_descriptions;
SELECT * FROM candidates;
SELECT * FROM interview_sessions;
```

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Commit with conventional commits**
   ```bash
   git commit -m "feat: add amazing feature"
   ```
5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Open a Pull Request**

### Commit Message Convention

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

### Code Style

**Java:**
- Follow Google Java Style Guide
- Use meaningful variable names
- Add JavaDoc for public methods
- Maximum line length: 120 characters

**JavaScript/React:**
- Use functional components
- Follow Airbnb React Style Guide
- Use hooks for state management
- Meaningful component names

### Testing

```bash
# Backend tests
cd backend
mvn test

# Frontend tests (if implemented)
cd frontend
npm test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Your Organization

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Support

For support, please:

1. Check the [Troubleshooting](#troubleshooting) section
2. Search [existing issues](https://github.com/your-org/rag-interview-system/issues)
3. Create a [new issue](https://github.com/your-org/rag-interview-system/issues/new)

**Contact:**
- Email: support@yourcompany.com
- Slack: #rag-interview-support

---

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- React team for the powerful UI library
- PostgreSQL community
- All contributors

---

## 📊 Project Status

**Current Version:** 1.0.0  
**Status:** Production Ready ✅  
**Last Updated:** January 2024

### Roadmap

- [ ] Video interview integration
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Mobile app (React Native)
- [ ] AI-powered resume parsing
- [ ] Integration with ATS systems
- [ ] Automated scheduling system
- [ ] Custom branding options

---

**Made with ❤️ by Your Organization**