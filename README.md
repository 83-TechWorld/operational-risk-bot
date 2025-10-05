# 🤖 Enterprise RAG Chatbot

An intelligent AI assistant powered by RAG (Retrieval-Augmented Generation) with multi-database integration, tool calling, and comprehensive CI/CD pipeline.

## ✨ Features

- **🔍 RAG System**: Search and retrieve information from enterprise documents (PDF, DOCX, TXT, MD)
- **💾 Multi-Database Integration**: Connect to 4+ application databases with natural language queries
- **🛠️ Tool Calling**: Automated email sending and support ticket creation
- **📊 Dashboard Generation**: Create visualizations comparing metrics across applications
- **💬 Conversational AI**: Context-aware chat with conversation history
- **🎨 Modern React UI**: Clean, responsive interface with real-time updates
- **🧪 Comprehensive Testing**: Unit, integration, and E2E tests with 80%+ coverage
- **📈 Quality Gates**: SonarQube integration with automated code quality checks
- **🚀 CI/CD Pipeline**: GitHub Actions with automated testing and deployment
- **🔒 Security**: Rate limiting, input validation, and secure API design

## 🏗️ Architecture

```
┌─────────────────┐
│  React Frontend │
│   (TypeScript)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   FastAPI       │
│   Backend       │
├─────────────────┤
│ • RAG Service   │
│ • LLM Service   │
│ • DB Service    │
│ • Tool Service  │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌──────────┐
│Vector  │ │PostgreSQL│
│ DB     │ │Databases │
│(Chroma)│ │(4 Apps)  │
└────────┘ └──────────┘
```

## 🚀 Quick Start

### Prerequisites

#### Required Software (Mac Installation)

```bash
# 1. Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Python 3.11
brew install python@3.11
python3 --version  # Verify: should show 3.11.x

# 3. Install PostgreSQL 15
brew install postgresql@15
brew services start postgresql@15
psql --version  # Verify: should show 15.x

# 4. Install Node.js 18+
brew install node
node --version  # Verify: should show 18.x or higher
npm --version   # Verify npm is installed
```

#### Required Services & Credentials

- **OpenAI API Key**: Get from https://platform.openai.com/api-keys
- **PostgreSQL Databases**: 4 application databases (app1, app2, app3, app4)
- **ChromaDB**: No separate installation needed (embedded with Python package)
- **Authentication Headers**: For organization integration
  - `X-App-Name`: Your application name
  - `X-Key-Name`: Your key identifier  
  - `Authorization`: Bearer token

#### Initial Documents for RAG

Prepare these guide documents to upload to the RAG system:

```python
documents = [
    {
        "filename": "intent_classification_guide.md",
        "content": "# Intent Classification Guide\n\n[Your classification rules and examples]",
        "metadata": {"document_type": "classification", "application": "General"}
    },
    {
        "filename": "sql_generation_guide.md",
        "content": "# SQL Generation Guide\n\n[Your SQL patterns and examples]",
        "metadata": {"document_type": "sql_guide", "application": "General"}
    },
    {
        "filename": "response_formatting_guide.md",
        "content": "# Response Formatting Guide\n\n[Your formatting standards]",
        "metadata": {"document_type": "response_guide", "application": "General"}
    }
]
```

**📚 See [DOCUMENT_INGESTION_GUIDE.md](DOCUMENT_INGESTION_GUIDE.md) for detailed instructions on adding these documents.**

### One-Command Setup

```bash
# Make the setup script executable and run it
chmod +x setup.sh
./setup.sh
```

**Note**: ChromaDB is automatically installed with the Python requirements - no separate database installation needed!

### Manual Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd enterprise-rag-chatbot
   ```

2. **Setup Backend**
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   cp .env.example .env
   # Edit .env with your configuration (see below)
   ```

   **Required `.env` Configuration:**
   ```bash
   # OpenAI API Key (REQUIRED)
   OPENAI_API_KEY=sk-your-key-here
   
   # Database URLs (REQUIRED - configure your 4 app databases)
   APP1_DB_URL=postgresql://user:password@localhost:5432/app1_db
   APP2_DB_URL=postgresql://user:password@localhost:5432/app2_db
   APP3_DB_URL=postgresql://user:password@localhost:5432/app3_db
   APP4_DB_URL=postgresql://user:password@localhost:5432/app4_db
   
   # Authentication (REQUIRED - configure for your organization)
   VALID_CLIENTS={"my-app-name": {"key_name": "my-key", "token": "Bearer your-token-here"}}
   
   # Internal Tools (REQUIRED if using email/ticketing)
   EMAIL_SERVICE_URL=http://your-email-service.com
   EMAIL_SERVICE_API_KEY=your_api_key
   TICKETING_SERVICE_URL=http://your-ticketing-service.com
   TICKETING_SERVICE_API_KEY=your_api_key
   ```

3. **Setup Frontend**
   ```bash
   cd frontend
   npm install
   echo "REACT_APP_API_URL=http://localhost:8000/api/v1" > .env
   ```

4. **Start Services**
   ```bash
   # Terminal 1 - Start Backend
   cd backend
   source venv/bin/activate  # Activate virtual environment
   python app/main.py
   
   # Terminal 2 - Start Frontend
   cd frontend
   npm start
   ```

   **Note**: Redis is NOT required - caching is handled in-memory!

5. **Access the Application**
   - Frontend: http://localhost:3000
   - API Docs: http://localhost:8000/docs
   - Health Check: http://localhost:8000/api/v1/health
   - Prometheus Metrics: http://localhost:8000/metrics

6. **Upload Initial Documents to RAG**
   
   See [DOCUMENT_INGESTION_GUIDE.md](DOCUMENT_INGESTION_GUIDE.md) for complete instructions.
   
   Quick method:
   ```bash
   # Create your guide documents
   mkdir -p backend/data/initial_docs
   
   # Add your intent_classification_guide.md
   # Add your sql_generation_guide.md  
   # Add your response_formatting_guide.md
   
   # Run ingestion script
   cd backend
   python scripts/ingest_documents.py
   ```

## 📚 Documentation

- [Complete Setup Instructions](SETUP_INSTRUCTIONS.md)
- [API Documentation](http://localhost:8000/docs) (when running)
- [Architecture Details](#architecture)

## 🧪 Testing

### Backend Tests

```bash
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test types
pytest -m unit
pytest -m integration

# View coverage report
open htmlcov/index.html
```

### Frontend Tests

```bash
cd frontend

# Run tests
npm test

# Run with coverage
npm test -- --coverage
```

## 📊 Code Quality

### SonarQube Analysis

```bash
# Run SonarQube scanner
sonar-scanner \
  -Dsonar.projectKey=enterprise-rag-chatbot \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_TOKEN
```

### Code Quality Metrics

- **Test Coverage**: > 80%
- **Code Complexity**: Max 10
- **Security**: Zero critical vulnerabilities
- **Maintainability**: A rating

## 🔧 Configuration

### Environment Variables

**Backend (.env)**
```bash
# === REQUIRED CONFIGURATION ===

# OpenAI API Key
OPENAI_API_KEY=sk-your-openai-api-key

# Database Connections (4 application databases)
APP1_DB_URL=postgresql://user:pass@host:5432/app1_db
APP2_DB_URL=postgresql://user:pass@host:5432/app2_db
APP3_DB_URL=postgresql://user:pass@host:5432/app3_db
APP4_DB_URL=postgresql://user:pass@host:5432/app4_db

# Authentication Headers (Implicit Client Auth)
VALID_CLIENTS={"my-app-name": {"key_name": "my-key", "token": "Bearer your-token-here"}}

# === OPTIONAL CONFIGURATION ===

# Internal Tools (if using email/ticketing features)
EMAIL_SERVICE_URL=http://email-service.com
EMAIL_SERVICE_API_KEY=your_key
TICKETING_SERVICE_URL=http://ticket-service.com
TICKETING_SERVICE_API_KEY=your_key

# ChromaDB (defaults are fine, no installation needed)
CHROMA_PERSIST_DIRECTORY=./data/chroma
CHROMA_COLLECTION_NAME=enterprise_documents

# RAG Settings
CHUNK_SIZE=1000
CHUNK_OVERLAP=200
RETRIEVAL_TOP_K=5

# Logging
LOG_LEVEL=INFO
LOG_FILE=./logs/app.log

# Monitoring
ENABLE_METRICS=True
```

**Frontend (.env)**
```bash
REACT_APP_API_URL=http://localhost:8000/api/v1
```

### Authentication Setup

Your organization requires these headers for API calls:

```bash
# Required Headers
X-App-Name: your-app-name
X-Key-Name: your-key-identifier
Authorization: Bearer your-bearer-token
```

Configure valid clients in `.env`:
```bash
VALID_CLIENTS={"your-app-name": {"key_name": "your-key", "token": "Bearer your-token"}}
```

## 🚢 Deployment

### Docker Deployment

```bash
# Build images
docker build -t rag-backend ./backend
docker build -t rag-frontend ./frontend

# Run with docker-compose
docker-compose up -d
```

### GitHub Actions CI/CD

The project includes a complete CI/CD pipeline:

- ✅ Code quality checks (flake8, black, mypy)
- ✅ Security scanning (bandit, safety)
- ✅ Unit and integration tests
- ✅ SonarQube analysis
- ✅ Docker image building
- ✅ Automated deployment to staging/production

## 📖 Usage Examples

### Authentication Headers

All API requests require authentication headers:

```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here" \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "user_id": "user123"}'
```

### Upload Documents

```python
import requests

files = {'file': open('document.pdf', 'rb')}
headers = {
    'X-App-Name': 'my-app-name',
    'X-Key-Name': 'my-key',
    'Authorization': 'Bearer your-token-here'
}

response = requests.post(
    'http://localhost:8000/api/v1/documents/upload',
    files=files,
    headers=headers
)
```

### Chat with the Assistant

```python
import requests

headers = {
    'X-App-Name': 'my-app-name',
    'X-Key-Name': 'my-key',
    'Authorization': 'Bearer your-token-here',
    'Content-Type': 'application/json'
}

response = requests.post(
    'http://localhost:8000/api/v1/chat',
    json={
        'message': 'What is our company policy on remote work?',
        'user_id': 'user123'
    },
    headers=headers
)

print(response.json()['message'])
```

### Query Databases

```python
response = requests.post(
    'http://localhost:8000/api/v1/chat',
    json={
        'message': 'Show me the top 10 users from app1',
        'user_id': 'user123'
    },
    headers=headers
)
```

### Ingest Your Guide Documents

See [DOCUMENT_INGESTION_GUIDE.md](DOCUMENT_INGESTION_GUIDE.md) for complete instructions on uploading:
- intent_classification_guide.md
- sql_generation_guide.md
- response_formatting_guide.md

## 🛠️ Technology Stack

### Backend
- **Framework**: FastAPI
- **LLM**: OpenAI GPT-4
- **Vector DB**: ChromaDB (embedded - no separate installation)
- **Database**: PostgreSQL, SQLAlchemy
- **Cache**: In-memory (no Redis required)
- **Document Processing**: LangChain, PyPDF, python-docx
- **Monitoring**: Prometheus, Loguru
- **Load Testing**: Locust

### Frontend
- **Framework**: React 18 with TypeScript
- **Styling**: CSS3 with modern animations
- **HTTP Client**: Axios
- **State Management**: React Hooks

### DevOps
- **Testing**: Pytest with async support
- **Containerization**: Docker
- **Authentication**: Implicit headers (X-App-Name, X-Key-Name, Bearer token)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for all new features (maintain 80%+ coverage)
- Follow PEP 8 style guide for Python
- Use TypeScript for React components
- Run linters before committing
- Update documentation for API changes

## 📝 Project Structure

```
enterprise-rag-chatbot/
├── backend/
│   ├── app/
│   │   ├── api/endpoints/      # API routes
│   │   ├── services/           # Business logic
│   │   ├── models/             # Data models
│   │   ├── config/             # Configuration
│   │   └── utils/              # Utilities
│   ├── tests/                  # Test files
│   ├── requirements.txt        # Python dependencies
│   └── Dockerfile             # Backend container
├── frontend/
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── services/          # API services
│   │   └── types/             # TypeScript types
│   ├── package.json           # Node dependencies
│   └── Dockerfile            # Frontend container
├── .github/workflows/         # CI/CD pipelines
├── docker-compose.yml         # Multi-container setup
└── README.md                  # This file
```

## 🐛 Troubleshooting

### Common Issues

**ChromaDB Installation**
- ChromaDB is automatically installed with `pip install -r requirements.txt`
- No separate database setup needed
- Data is stored in `backend/data/chroma/` directory

**OpenAI API Errors**
- Verify API key is correct in `.env`
- Check API quota and billing at https://platform.openai.com/account/usage
- Ensure network connectivity

**Database Connection Issues**
- Verify database URLs in `.env`
- Check PostgreSQL is running: `brew services list`
- Ensure databases exist: `psql -l`
- Test connection: `psql postgresql://user:pass@localhost:5432/app1_db`

**Authentication Errors (401/403)**
- Verify headers: X-App-Name, X-Key-Name, Authorization
- Check VALID_CLIENTS configuration in `.env`
- Ensure Bearer token is correct format: "Bearer your-token"

**Frontend Can't Connect to Backend**
- Check CORS settings in `backend/app/config/settings.py`
- Verify backend is running on port 8000
- Check REACT_APP_API_URL in frontend `.env`

**Document Upload Issues**
- Check file size (max 10MB by default)
- Verify file extension (.pdf, .docx, .txt, .md)
- Check OpenAI API quota for embeddings

**RAG Not Finding Documents**
- Verify documents were uploaded successfully
- Check similarity threshold (default: 0.7)
- Try with lower threshold or different query terms
- Check ChromaDB data directory has files

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- OpenAI for GPT-4 API
- LangChain for RAG framework
- FastAPI for excellent Python web framework
- React team for the amazing UI library

## 📧 Contact

For questions or support:
- Create an issue on GitHub
- Check the documentation
- Review the API docs at `/docs`

---

**Happy Coding! 🚀**