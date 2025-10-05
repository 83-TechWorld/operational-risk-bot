# 📚 Document Ingestion Guide

## Understanding Document Structure

Your documents array contains metadata-rich documents that will be embedded and stored in ChromaDB for RAG retrieval.

```python
documents = [
    {
        "filename": "intent_classification_guide.md",
        "content": "...",  # Your actual content
        "metadata": {
            "document_type": "classification",
            "application": "General"
        }
    },
    {
        "filename": "sql_generation_guide.md",
        "content": "...",
        "metadata": {
            "document_type": "sql_guide",
            "application": "General"
        }
    },
    {
        "filename": "response_formatting_guide.md",
        "content": "...",
        "metadata": {
            "document_type": "response_guide",
            "application": "General"
        }
    }
]
```

## How RAG Works with Your Documents

### 1. **Document Chunking Process**
```
Original Document (intent_classification_guide.md)
                    ↓
        Text Splitter (1000 chars/chunk)
                    ↓
    [Chunk 1] [Chunk 2] [Chunk 3] ... [Chunk N]
                    ↓
        OpenAI Embeddings (vectors)
                    ↓
    [Vec 1] [Vec 2] [Vec 3] ... [Vec N]
                    ↓
        ChromaDB Storage (with metadata)
```

### 2. **Retrieval Process**
```
User Query: "How do I classify intent?"
            ↓
    Convert to Embedding
            ↓
    Search Similar Vectors in ChromaDB
            ↓
    Return Top 5 Relevant Chunks
            ↓
    Provide to LLM as Context
```

## Method 1: Upload via API (Recommended for Production)

### Step 1: Save Your Documents as Files

```bash
# Create a documents directory
mkdir -p backend/data/initial_docs

# Create the files
cat > backend/data/initial_docs/intent_classification_guide.md << 'EOF'
# Intent Classification Guide

## Overview
This guide explains how to classify user intents...

[Your full content here]
EOF

cat > backend/data/initial_docs/sql_generation_guide.md << 'EOF'
# SQL Generation Guide

## Overview
This guide covers SQL query generation...

[Your full content here]
EOF

cat > backend/data/initial_docs/response_formatting_guide.md << 'EOF'
# Response Formatting Guide

## Overview
This guide explains response formatting...

[Your full content here]
EOF
```

### Step 2: Upload Using curl

```bash
# Upload each document
curl -X POST http://localhost:8000/api/v1/documents/upload \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here" \
  -F "file=@backend/data/initial_docs/intent_classification_guide.md"

curl -X POST http://localhost:8000/api/v1/documents/upload \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here" \
  -F "file=@backend/data/initial_docs/sql_generation_guide.md"

curl -X POST http://localhost:8000/api/v1/documents/upload \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here" \
  -F "file=@backend/data/initial_docs/response_formatting_guide.md"
```

### Step 3: Upload Using Python

```python
import requests

documents = [
    {
        "filename": "intent_classification_guide.md",
        "content": """# Intent Classification Guide
        
Your full content here...
""",
        "metadata": {"document_type": "classification", "application": "General"}
    },
    # ... other documents
]

# Save and upload each document
for doc in documents:
    # Save to file
    filepath = f"backend/data/initial_docs/{doc['filename']}"
    with open(filepath, 'w') as f:
        f.write(doc['content'])
    
    # Upload to API
    with open(filepath, 'rb') as f:
        files = {'file': f}
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
        
        print(f"Uploaded {doc['filename']}: {response.json()}")
```

## Method 2: Direct Programmatic Ingestion

Create a script to directly add documents to ChromaDB:

```python
# backend/scripts/ingest_documents.py

import asyncio
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.rag_service import RAGService
from app.config.settings import settings

# Your documents
documents = [
    {
        "filename": "intent_classification_guide.md",
        "content": """# Intent Classification Guide

## Overview
Intent classification is the process of determining what the user wants to accomplish.

## Categories

### 1. Information Retrieval
- Questions starting with: what, when, where, who
- Keywords: "tell me", "show me", "find", "search"
- Example: "What is our refund policy?"

### 2. Data Query
- Database-related questions
- Keywords: "query", "from app", "database", "show data"
- Example: "Show me users from app1"

### 3. Action Request
- Requests to perform actions
- Keywords: "send", "create", "update", "delete"
- Example: "Send an email to john@example.com"

## Classification Logic

```python
def classify_intent(query):
    query_lower = query.lower()
    
    if any(word in query_lower for word in ['query', 'from app', 'database']):
        return 'data_query'
    elif any(word in query_lower for word in ['send email', 'create ticket']):
        return 'action_request'
    else:
        return 'information_retrieval'
```
""",
        "metadata": {
            "document_type": "classification",
            "application": "General",
            "version": "1.0"
        }
    },
    {
        "filename": "sql_generation_guide.md",
        "content": """# SQL Generation Guide

## Overview
This guide explains how to generate SQL queries from natural language.

## Schema Understanding

Before generating SQL, understand the database schema:

```
Table: users
- id (INTEGER)
- name (VARCHAR)
- email (VARCHAR)
- created_at (TIMESTAMP)

Table: orders
- id (INTEGER)
- user_id (INTEGER)
- amount (DECIMAL)
- status (VARCHAR)
```

## Query Patterns

### 1. Simple SELECT
Question: "Show me all users"
SQL: `SELECT * FROM users LIMIT 100;`

### 2. Filtered SELECT
Question: "Show users created after 2023"
SQL: `SELECT * FROM users WHERE created_at > '2023-01-01' LIMIT 100;`

### 3. JOIN Queries
Question: "Show users with their orders"
SQL: `SELECT u.name, o.amount FROM users u LEFT JOIN orders o ON u.id = o.user_id LIMIT 100;`

### 4. Aggregations
Question: "Count total users"
SQL: `SELECT COUNT(*) as total_users FROM users;`

## Best Practices

1. Always use LIMIT for safety
2. Validate table and column names against schema
3. Use parameterized queries to prevent SQL injection
4. Test queries before execution
""",
        "metadata": {
            "document_type": "sql_guide",
            "application": "General",
            "version": "1.0"
        }
    },
    {
        "filename": "response_formatting_guide.md",
        "content": """# Response Formatting Guide

## Overview
Properly formatted responses improve user experience and clarity.

## Response Types

### 1. Informational Response
```
Format:
- Clear, concise answer
- Relevant sources if from documents
- Helpful context

Example:
"Based on our company policy document, the refund period is 30 days from purchase date. 

Source: Refund Policy v2.3, Page 5"
```

### 2. Data Query Response
```
Format:
- Brief summary of results
- Structured data presentation
- Row count and execution time

Example:
"I found 145 users in the system.

Top 10 users:
1. John Doe (john@example.com)
2. Jane Smith (jane@example.com)
...

Total: 145 users
Query executed in 0.23 seconds"
```

### 3. Action Response
```
Format:
- Confirmation of action
- Action details
- Result/ticket ID

Example:
"✅ Email sent successfully

To: support@example.com
Subject: Support Request #12345
Status: Delivered
Message ID: msg_abc123"
```

### 4. Error Response
```
Format:
- Clear error message
- Helpful suggestions
- No technical jargon

Example:
"I couldn't process that request because the database connection timed out. 
Please try again in a moment, or contact support if this persists."
```

## Formatting Guidelines

1. **Use Clear Language**: Avoid jargon
2. **Structure Data**: Use tables or lists for multiple items
3. **Include Sources**: Always cite document sources
4. **Be Concise**: Get to the point quickly
5. **Use Emojis**: ✅ ❌ 📊 for visual clarity (optional)
""",
        "metadata": {
            "document_type": "response_guide",
            "application": "General",
            "version": "1.0"
        }
    }
]


async def ingest_documents():
    """Ingest documents into RAG system"""
    
    print("🚀 Starting document ingestion...")
    print("="*80)
    
    # Initialize RAG service
    rag_service = RAGService()
    await rag_service.initialize()
    
    print(f"✓ RAG Service initialized")
    print(f"  Collection: {settings.CHROMA_COLLECTION_NAME}")
    print(f"  Persist Directory: {settings.CHROMA_PERSIST_DIRECTORY}")
    print()
    
    # Create temporary directory for documents
    temp_dir = "backend/data/temp_docs"
    os.makedirs(temp_dir, exist_ok=True)
    
    total_chunks = 0
    
    # Process each document
    for i, doc in enumerate(documents, 1):
        print(f"[{i}/{len(documents)}] Processing: {doc['filename']}")
        
        # Save document to file
        filepath = os.path.join(temp_dir, doc['filename'])
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(doc['content'])
        
        # Add metadata
        metadata = {
            "document_id": f"doc_{i}",
            "filename": doc['filename'],
            **doc['metadata']
        }
        
        # Process document
        try:
            chunks = await rag_service.process_document(filepath, metadata)
            total_chunks += chunks
            print(f"  ✓ Processed: {chunks} chunks created")
        except Exception as e:
            print(f"  ✗ Error: {e}")
        
        print()
    
    print("="*80)
    print(f"✅ Ingestion complete!")
    print(f"  Total documents: {len(documents)}")
    print(f"  Total chunks: {total_chunks}")
    print(f"  Average chunks per document: {total_chunks / len(documents):.1f}")
    print()
    
    # Test retrieval
    print("🔍 Testing retrieval...")
    test_query = "How do I classify user intent?"
    results = await rag_service.search(test_query, top_k=3)
    
    print(f"Query: '{test_query}'")
    print(f"Found {len(results)} relevant chunks:")
    for i, result in enumerate(results, 1):
        print(f"\n[{i}] From: {result['metadata']['filename']}")
        print(f"    Relevance: {(1 - result['distance']):.2%}")
        print(f"    Content preview: {result['content'][:150]}...")
    
    await rag_service.cleanup()
    print("\n✓ RAG Service cleaned up")


if __name__ == "__main__":
    asyncio.run(ingest_documents())
```

## Method 3: Batch Upload via Frontend

Use the React frontend to upload multiple documents:

```typescript
// frontend/src/components/BatchUpload.tsx

const batchUpload = async () => {
    const documents = [
        { name: 'intent_classification_guide.md', content: '...' },
        { name: 'sql_generation_guide.md', content: '...' },
        { name: 'response_formatting_guide.md', content: '...' }
    ];
    
    for (const doc of documents) {
        // Create a File object
        const blob = new Blob([doc.content], { type: 'text/markdown' });
        const file = new File([blob], doc.name, { type: 'text/markdown' });
        
        // Upload
        const formData = new FormData();
        formData.append('file', file);
        
        await axios.post(
            `${API_URL}/documents/upload`,
            formData,
            {
                headers: {
                    'X-App-Name': 'my-app-name',
                    'X-Key-Name': 'my-key',
                    'Authorization': 'Bearer your-token-here'
                }
            }
        );
        
        console.log(`Uploaded: ${doc.name}`);
    }
};
```

## Verification

After uploading, verify the documents are embedded:

```bash
# 1. Check via API
curl -X GET http://localhost:8000/api/v1/documents \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here"

# 2. Test search
curl -X POST "http://localhost:8000/api/v1/documents/search?query=intent%20classification&top_k=5" \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here"

# 3. Test in chat
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-App-Name: my-app-name" \
  -H "X-Key-Name: my-key" \
  -H "Authorization: Bearer your-token-here" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "How do I classify user intent?",
    "user_id": "test_user"
  }'
```

## Understanding the Embedding Process

When you upload a document, here's what happens:

1. **Document Loading**: File is read and parsed
2. **Text Splitting**: Content is split into chunks (1000 chars with 200 overlap)
3. **Embedding Generation**: Each chunk is converted to a vector using OpenAI
4. **Storage**: Vectors + metadata stored in ChromaDB
5. **Indexing**: ChromaDB indexes for fast similarity search

### Example of Chunks Created:

```
Original Document: intent_classification_guide.md (3000 chars)
                          ↓
Chunk 1 (0-1000):    "# Intent Classification Guide\n## Overview..."
Chunk 2 (800-1800):  "...## Categories\n### 1. Information Retrieval..."
Chunk 3 (1600-2600): "...### 2. Data Query\n- Database-related..."
Chunk 4 (2400-3000): "...## Classification Logic\ndef classify..."
```

Each chunk gets its own embedding and can be retrieved independently!

## Best Practices

1. **Document Size**: Keep documents focused (< 50KB each)
2. **Metadata**: Add rich metadata for better filtering
3. **Versioning**: Include version numbers in metadata
4. **Organization**: Group related documents
5. **Updates**: Re-upload documents when content changes

## Troubleshooting

**Issue**: Documents not being retrieved
**Solution**: Check similarity threshold in settings (default: 0.7)

**Issue**: Too many/few chunks
**Solution**: Adjust CHUNK_SIZE and CHUNK_OVERLAP in settings

**Issue**: Slow upload
**Solution**: Upload documents one at a time, check OpenAI API quota