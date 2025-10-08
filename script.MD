chmod +x setup_project.sh
./setup_project.sh
cd enterprise-rag-chatbot

Configure your RAG credentials:

bashcd backend
cp .env.example .env
nano .env  # Edit with your actual credentials

# Backend
pip install -r requirements.txt
uvicorn main:app --reload

# Frontend (new terminal)
cd ../frontend
npm install
npm run dev

bash# Backend
pip install -r requirements.txt
uvicorn main:app --reload

# Frontend (new terminal)
cd ../frontend
npm install
npm run dev