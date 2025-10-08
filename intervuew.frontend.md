/* 
================================================================================
COMPLETE RAG INTERVIEW SYSTEM - REACT TYPESCRIPT FRONTEND
================================================================================

FOLDER STRUCTURE:
frontend/
├── package.json
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
├── index.html
├── .env
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── index.css
    ├── types/
    │   └── index.ts
    ├── services/
    │   └── api.ts
    └── components/
        ├── Navbar.tsx
        ├── HRDashboard.tsx
        ├── CreateJobDescription.tsx
        ├── CreateInterview.tsx
        ├── CandidateInterview.tsx
        ├── InterviewSession.tsx
        └── EvaluationDashboard.tsx

COPY EACH SECTION BELOW TO THE CORRESPONDING FILE
================================================================================
*/

// ============================================================================
// FILE: package.json
// ============================================================================
{
  "name": "rag-interview-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.2",
    "recharts": "^2.10.3"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "@vitejs/plugin-react": "^4.2.1",
    "eslint": "^8.55.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "typescript": "^5.2.2",
    "vite": "^5.0.8"
  }
}

// ============================================================================
// FILE: tsconfig.json
// ============================================================================
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}

// ============================================================================
// FILE: tsconfig.node.json
// ============================================================================
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}

// ============================================================================
// FILE: vite.config.ts
// ============================================================================
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})

// ============================================================================
// FILE: index.html
// ============================================================================
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>RAG Interview System</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>

// ============================================================================
// FILE: .env
// ============================================================================
VITE_API_BASE_URL=http://localhost:8080/api

// ============================================================================
// FILE: src/types/index.ts
// ============================================================================
export enum InterviewMode {
  EASY = 'EASY',
  MEDIUM = 'MEDIUM',
  HARD = 'HARD'
}

export enum InterviewStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED'
}

export enum QuestionCategory {
  CODING = 'CODING',
  BEHAVIORAL = 'BEHAVIORAL',
  TECHNICAL = 'TECHNICAL',
  GENERAL = 'GENERAL'
}

export interface JobDescription {
  id: number;
  title: string;
  description: string;
  requirements?: string;
  interviewMode: InterviewMode;
  ragDocumentId?: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  isActive: boolean;
}

export interface Candidate {
  id: number;
  fullName: string;
  email: string;
  phone?: string;
  resumePath?: string;
  ragResumeId?: string;
  createdAt: string;
  updatedAt: string;
}

export interface InterviewSession {
  id: number;
  sessionToken: string;
  candidate: Candidate;
  jobDescription: JobDescription;
  interviewMode: InterviewMode;
  status: InterviewStatus;
  currentStep: number;
  totalSteps: number;
  startedAt?: string;
  completedAt?: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface Question {
  questionId: number;
  questionText: string;
  category: string;
  stepNumber: number;
  totalSteps: number;
  currentStep: number;
  difficulty?: string;
}

export interface EvaluationResult {
  codingScore: number;
  behavioralScore: number;
  technicalScore: number;
  overallScore: number;
  codingFeedback: string;
  behavioralFeedback: string;
  technicalFeedback: string;
  recommendation: string;
  proceedToNextRound: boolean;
}

export interface JobDescriptionRequest {
  title: string;
  description: string;
  requirements?: string;
  interviewMode: InterviewMode;
}

export interface CreateInterviewSessionRequest {
  candidateName: string;
  email: string;
  phone?: string;
  jobDescriptionId: number;
}

export interface CreateInterviewSessionResponse {
  session_id: number;
  session_token: string;
  candidate_name: string;
  job_title: string;
  interview_mode: InterviewMode;
  total_steps: number;
  eligible: boolean;
  error?: string;
  cooldown_until?: string;
}

export interface SubmitAnswerRequest {
  answerText: string;
}

export interface SubmitAnswerResponse {
  answer_submitted: boolean;
  step_number: number;
  score?: number;
}

export interface SessionStatusResponse {
  session_id: number;
  status: InterviewStatus;
  current_step: number;
  total_steps: number;
  candidate_name: string;
  job_title: string;
}

export interface CompleteInterviewResponse {
  session_completed: boolean;
  cooldown_until: string;
  evaluation_id: number;
  message: string;
}

export interface ApiError {
  timestamp: string;
  error: string;
  status: number;
}

// ============================================================================
// FILE: src/services/api.ts
// ============================================================================
import axios, { AxiosInstance, AxiosResponse } from 'axios';
import {
  JobDescription,
  JobDescriptionRequest,
  CreateInterviewSessionRequest,
  CreateInterviewSessionResponse,
  Question,
  SubmitAnswerRequest,
  SubmitAnswerResponse,
  SessionStatusResponse,
  CompleteInterviewResponse,
  EvaluationResult
} from '../types';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';

const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const jobDescriptionAPI = {
  create: async (
    data: JobDescriptionRequest,
    file: File | null,
    userEmail: string
  ): Promise<JobDescription> => {
    const formData = new FormData();
    formData.append('data', new Blob([JSON.stringify(data)], { type: 'application/json' }));
    if (file) {
      formData.append('file', file);
    }

    const response: AxiosResponse<JobDescription> = await axios.post(
      `${API_BASE_URL}/job-descriptions`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
          'User-Email': userEmail,
        },
      }
    );
    return response.data;
  },

  getAll: async (): Promise<JobDescription[]> => {
    const response: AxiosResponse<JobDescription[]> = await apiClient.get('/job-descriptions');
    return response.data;
  },

  getById: async (id: number): Promise<JobDescription> => {
    const response: AxiosResponse<JobDescription> = await apiClient.get(`/job-descriptions/${id}`);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`/job-descriptions/${id}`);
  },
};

export const interviewAPI = {
  create: async (
    data: CreateInterviewSessionRequest,
    resume: File,
    userEmail: string
  ): Promise<CreateInterviewSessionResponse> => {
    const formData = new FormData();
    formData.append('data', new Blob([JSON.stringify(data)], { type: 'application/json' }));
    formData.append('resume', resume);

    const response: AxiosResponse<CreateInterviewSessionResponse> = await axios.post(
      `${API_BASE_URL}/interviews/create`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
          'User-Email': userEmail,
        },
      }
    );
    return response.data;
  },

  start: async (email: string): Promise<Question> => {
    const response: AxiosResponse<Question> = await apiClient.post('/interviews/start', null, {
      params: { email },
    });
    return response.data;
  },

  getStatus: async (sessionToken: string): Promise<SessionStatusResponse> => {
    const response: AxiosResponse<SessionStatusResponse> = await apiClient.get(
      `/interviews/session/${sessionToken}/status`
    );
    return response.data;
  },

  submitAnswer: async (
    sessionId: number,
    questionId: number,
    answerText: string
  ): Promise<SubmitAnswerResponse> => {
    const response: AxiosResponse<SubmitAnswerResponse> = await apiClient.post(
      `/interviews/session/${sessionId}/answer/${questionId}`,
      { answerText }
    );
    return response.data;
  },

  getNextQuestion: async (sessionId: number): Promise<Question> => {
    const response: AxiosResponse<Question> = await apiClient.get(
      `/interviews/session/${sessionId}/next-question`
    );
    return response.data;
  },

  complete: async (sessionId: number): Promise<CompleteInterviewResponse> => {
    const response: AxiosResponse<CompleteInterviewResponse> = await apiClient.post(
      `/interviews/session/${sessionId}/complete`
    );
    return response.data;
  },
};

export const dashboardAPI = {
  getAllEvaluations: async (): Promise<EvaluationResult[]> => {
    const response: AxiosResponse<EvaluationResult[]> = await apiClient.get('/dashboard/evaluations');
    return response.data;
  },

  getEvaluationBySession: async (sessionId: number): Promise<EvaluationResult> => {
    const response: AxiosResponse<EvaluationResult> = await apiClient.get(
      `/dashboard/evaluations/session/${sessionId}`
    );
    return response.data;
  },
};

export default apiClient;

// ============================================================================
// FILE: src/index.css
// ============================================================================
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover {
  background: #5568d3;
  transform: translateY(-2px);
}

.btn-primary:disabled {
  background: #a0aec0;
  cursor: not-allowed;
  transform: none;
}

.btn-secondary {
  background: #48bb78;
  color: white;
}

.btn-secondary:hover {
  background: #38a169;
}

.btn-danger {
  background: #f56565;
  color: white;
}

.btn-danger:hover {
  background: #e53e3e;
}

.input-group {
  margin-bottom: 20px;
}

.input-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2d3748;
}

.input-group input,
.input-group select,
.input-group textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 0.3s ease;
}

.input-group input:focus,
.input-group select:focus,
.input-group textarea:focus {
  outline: none;
  border-color: #667eea;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
  margin: 20px 0;
}

.progress-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transition: width 0.3s ease;
}

.alert {
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.alert-success {
  background: #c6f6d5;
  border: 1px solid #48bb78;
  color: #22543d;
}

.alert-error {
  background: #fed7d7;
  border: 1px solid #f56565;
  color: #742a2a;
}

.alert-info {
  background: #bee3f8;
  border: 1px solid #4299e1;
  color: #2c5282;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
}

.spinner {
  border: 4px solid #e2e8f0;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.grid {
  display: grid;
  gap: 20px;
}

.grid-2 {
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
}

.stat-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 24px;
  border-radius: 12px;
  text-align: center;
}

.stat-card h3 {
  font-size: 2.5rem;
  margin-bottom: 8px;
}

.stat-card p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.navbar {
  background: white;
  padding: 16px 24px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  margin-bottom: 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 12px;
}

.navbar h1 {
  color: #667eea;
  font-size: 1.8rem;
}

.nav-links {
  display: flex;
  gap: 20px;
}

.nav-links button {
  background: none;
  border: none;
  color: #4a5568;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.nav-links button:hover {
  background: #edf2f7;
  color: #667eea;
}

.nav-links button.active {
  background: #667eea;
  color: white;
}

// ============================================================================
// FILE: src/main.tsx
// ============================================================================
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

// ============================================================================
// FILE: src/App.tsx
// ============================================================================
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import HRDashboard from './components/HRDashboard';
import CandidateInterview from './components/CandidateInterview';
import EvaluationDashboard from './components/EvaluationDashboard';
import Navbar from './components/Navbar';

const App: React.FC = () => {
  return (
    <Router>
      <div className="app">
        <Navbar />
        <div className="container">
          <Routes>
            <Route path="/" element={<Navigate to="/hr" />} />
            <Route path="/hr" element={<HRDashboard />} />
            <Route path="/interview" element={<CandidateInterview />} />
            <Route path="/evaluations" element={<EvaluationDashboard />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
};

export default App;

// ============================================================================
// FILE: src/components/Navbar.tsx
// ============================================================================
import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const Navbar: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const isActive = (path: string): boolean => location.pathname === path;

  return (
    <div className="container">
      <div className="navbar">
        <h1>🎯 RAG Interview System</h1>
        <div className="nav-links">
          <button
            className={isActive('/hr') ? 'active' : ''}
            onClick={() => navigate('/hr')}
          >
            HR Dashboard
          </button>
          <button
            className={isActive('/interview') ? 'active' : ''}
            onClick={() => navigate('/interview')}
          >
            Candidate Portal
          </button>
          <button
            className={isActive('/evaluations') ? 'active' : ''}
            onClick={() => navigate('/evaluations')}
          >
            Evaluations
          </button>
        </div>
      </div>
    </div>
  );
};

export default Navbar;

// ============================================================================
// FILE: src/components/HRDashboard.tsx
// ============================================================================
import React, { useState, useEffect } from 'react';
import { jobDescriptionAPI } from '../services/api';
import { JobDescription, CreateInterviewSessionResponse } from '../types';
import CreateJobDescription from './CreateJobDescription';
import CreateInterview from './CreateInterview';

type TabType = 'jobs' | 'create-job' | 'create-interview';

interface Message {
  type: 'success' | 'error' | 'info';
  text: string;
}

const HRDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState<TabType>('jobs');
  const [jobs, setJobs] = useState<JobDescription[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [message, setMessage] = useState<Message | null>(null);

  useEffect(() => {
    if (activeTab === 'jobs') {
      loadJobs();
    }
  }, [activeTab]);

  const loadJobs = async (): Promise<void> => {
    try {
      setLoading(true);
      const data = await jobDescriptionAPI.getAll();
      setJobs(data);
    } catch (error) {
      setMessage({ type: 'error', text: 'Failed to load job descriptions' });
    } finally {
      setLoading(false);
    }
  };

  const handleJobCreated = (): void => {
    setMessage({ type: 'success', text: 'Job description created successfully!' });
    loadJobs();
    setTimeout(() => setMessage(null), 3000);
  };

  const handleInterviewCreated = (result: CreateInterviewSessionResponse): void => {
    if (result.error) {
      setMessage({ type: 'error', text: result.error });
    } else if (result.eligible === false) {
      setMessage({ type: 'error', text: 'Candidate not eligible for this position' });
    } else {
      setMessage({
        type: 'success',
        text: `Interview created! Session Token: ${result.session_token}`,
      });
    }
    setTimeout(() => setMessage(null), 5000);
  };

  const handleDeleteJob = async (id: number): Promise<void> => {
    if (window.confirm('Are you sure you want to deactivate this job description?')) {
      try {
        await jobDescriptionAPI.delete(id);
        setMessage({ type: 'success', text: 'Job description deactivated' });
        loadJobs();
      } catch (error) {
        setMessage({ type: 'error', text: 'Failed to deactivate job description' });
      }
      setTimeout(() => setMessage(null), 3000);
    }
  };

  return (
    <div>
      <h2 style={{ color: 'white', marginBottom: '24px', fontSize: '2rem' }}>
        HR Dashboard
      </h2>

      {message && <div className={`alert alert-${message.type}`}>{message.text}</div>}

      <div className="card">
        <div style={{ display: 'flex', gap: '12px', marginBottom: '24px' }}>
          <button
            className={`btn ${activeTab === 'jobs' ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setActiveTab('jobs')}
          >
            Job Descriptions
          </button>
          <button
            className={`btn ${activeTab === 'create-job' ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setActiveTab('create-job')}
          >
            Create Job
          </button>
          <button
            className={`btn ${activeTab === 'create-interview' ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setActiveTab('create-interview')}
          >
            Schedule Interview
          </button>
        </div>

        {activeTab === 'jobs' && (
          <div>
            <h3 style={{ marginBottom: '20px' }}>Active Job Descriptions</h3>
            {loading ? (
              <div className="loading">
                <div className="spinner"></div>
              </div>
            ) : jobs.length === 0 ? (
              <p style={{ textAlign: 'center', color: '#718096' }}>
                No job descriptions found. Create one to get started!
              </p>
            ) : (
              <div className="grid grid-2">
                {jobs.map((job) => (
                  <div key={job.id} className="card" style={{ background: '#f7fafc' }}>
                    <h4 style={{ color: '#667eea', marginBottom: '12px' }}>{job.title}</h4>
                    <p style={{ marginBottom: '8px', color: '#4a5568' }}>
                      <strong>Mode:</strong> {job.interviewMode}
                    </p>
                    <p style={{ marginBottom: '12px', color: '#718096', fontSize: '14px' }}>
                      {job.description.substring(0, 150)}...
                    </p>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button
                        className="btn btn-danger"
                        style={{ fontSize: '14px', padding: '8px 16px' }}
                        onClick={() => handleDeleteJob(job.id)}
                      >
                        Deactivate
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {activeTab === 'create-job' && <CreateJobDescription onSuccess={handleJobCreated} />}
        {activeTab === 'create-interview' && <CreateInterview jobs={jobs} onSuccess={handleInterviewCreated} />}
      </div>
    </div>
  );
};

export default HRDashboard;

// ============================================================================
// FILE: src/components/CreateJobDescription.tsx
// ============================================================================
import React, { useState, ChangeEvent, FormEvent } from 'react';
import { jobDescriptionAPI } from '../services/api';
import { InterviewMode, JobDescriptionRequest } from '../types';

interface CreateJobDescriptionProps {
  onSuccess: () => void;
}

const CreateJobDescription: React.FC<CreateJobDescriptionProps> = ({ onSuccess }) => {
  const [formData, setFormData] = useState<JobDescriptionRequest>({
    title: '',
    description: '',
    requirements: '',
    interviewMode: InterviewMode.MEDIUM,
  });
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>): void => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>): void => {
    if (e.target.files && e.target.files.length > 0) {
      setFile(e.target.files[0]);
    }
  };

  const handleSubmit = async (e: FormEvent<HTMLFormElement>): Promise<void> => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await jobDescriptionAPI.create(formData, file, 'hr@company.com');
      setFormData({
        title: '',
        description: '',
        requirements: '',
        interviewMode: InterviewMode.MEDIUM,
      });
      setFile(null);
      onSuccess();
    } catch (err) {
      setError('Failed to create job description');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h3 style={{ marginBottom: '20px' }}>Create New Job Description</h3>
      {error && <div className="alert alert-error">{error}</div>}

      <form onSubmit={handleSubmit}>
        <div className="input-group">
          <label>Job Title *</label>
          <input
            type="text"
            name="title"
            value={formData.title}
            onChange={handleChange}
            required
            placeholder="e.g., Senior Software Engineer"
          />
        </div>

        <div className="input-group">
          <label>Description *</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            required
            rows={6}
            placeholder="Detailed job description..."
          />
        </div>

        <div className="input-group">
          <label>Requirements</label>
          <textarea
            name="requirements"
            value={formData.requirements}
            onChange={handleChange}
            rows={4}
            placeholder="Key requirements and qualifications..."
          />
        </div>

        <div className="input-group">
          <label>Interview Mode *</label>
          <select name="interviewMode" value={formData.interviewMode} onChange={handleChange} required>
            <option value={InterviewMode.EASY}>Easy (8 questions)</option>
            <option value={InterviewMode.MEDIUM}>Medium (10 questions)</option>
            <option value={InterviewMode.HARD}>Hard (15 questions)</option>
          </select>
        </div>

        <div className="input-group">
          <label>Upload Job Description Document (Optional)</label>
          <input type="file" onChange={handleFileChange} accept=".pdf,.doc,.docx" />
        </div>

        <button type="submit" className="btn btn-primary" disabled={loading} style={{ width: '100%' }}>
          {loading ? 'Creating...' : 'Create Job Description'}
        </button>
      </form>
    </div>
  );
};

export default CreateJobDescription;

// ============================================================================
// FILE: src/components/CreateInterview.tsx
// ============================================================================
import React, { useState, useEffect, ChangeEvent, FormEvent } from 'react';
import { interviewAPI } from '../services/api';
import { JobDescription, CreateInterviewSessionRequest, CreateInterviewSessionResponse } from '../types';

interface CreateInterviewProps {
  jobs: JobDescription[];
  onSuccess: (result: CreateInterviewSessionResponse) => void;
}

const CreateInterview: React.FC<CreateInterviewProps> = ({ jobs, onSuccess }) => {
  const [formData, setFormData] = useState<CreateInterviewSessionRequest>({
    candidateName: '',
    email: '',
    phone: '',
    jobDescriptionId: 0,
  });
  const [resume, setResume] = useState<File | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (jobs.length > 0 && formData.jobDescriptionId === 0) {
      setFormData((prev) => ({ ...prev, jobDescriptionId: jobs[0].id }));
    }
  }, [jobs, formData.jobDescriptionId]);

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLSelectElement>): void => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: name === 'jobDescriptionId' ? parseInt(value, 10) : value,
    });
  };

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>): void => {
    if (e.target.files && e.target.files.length > 0) {
      setResume(e.target.files[0]);
    }
  };

  const handleSubmit = async (e: FormEvent<HTMLFormElement>): Promise<void> => {
    e.preventDefault();
    if (!resume) {
      setError('Please upload candidate resume');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const result = await interviewAPI.create(formData, resume, 'hr@company.com');
      setFormData({
        candidateName: '',
        email: '',
        phone: '',
        jobDescriptionId: jobs[0]?.id || 0,
      });
      setResume(null);
      onSuccess(result);
    } catch (err) {
      setError('Failed to create interview session');
    } finally {
      setLoading(false);
    }
  };

  if (jobs.length === 0) {
    return (
      <div className="alert alert-info">
        Please create a job description first before scheduling interviews.
      </div>
    );
  }

  return (
    <div>
      <h3 style={{ marginBottom: '20px' }}>Schedule New Interview</h3>
      {error && <div className="alert alert-error">{error}</div>}

      <form onSubmit={handleSubmit}>
        <div className="input-group">
          <label>Candidate Name *</label>
          <input
            type="text"
            name="candidateName"
            value={formData.candidateName}
            onChange={handleChange}
            required
            placeholder="Full name"
          />
        </div>

        <div className="input-group">
          <label>Email *</label>
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
            placeholder="candidate@email.com"
          />
        </div>

        <div className="input-group">
          <label>Phone</label>
          <input
            type="tel"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
            placeholder="+1 234 567 8900"
          />
        </div>

        <div className="input-group">
          <label>Job Position *</label>
          <select name="jobDescriptionId" value={formData.jobDescriptionId} onChange={handleChange} required>
            {jobs.map((job) => (
              <option key={job.id} value={job.id}>
                {job.title} ({job.interviewMode})
              </option>
            ))}
          </select>
        </div>

        <div className="input-group">
          <label>Upload Resume *</label>
          <input type="file" onChange={handleFileChange} accept=".pdf,.doc,.docx" required />
          {resume && (
            <p style={{ marginTop: '8px', color: '#48bb78', fontSize: '14px' }}>✓ {resume.name}</p>
          )}
        </div>

        <button type="submit" className="btn btn-primary" disabled={loading} style={{ width: '100%' }}>
          {loading ? 'Creating Interview...' : 'Create Interview Session'}
        </button>
      </form>
    </div>
  );
};

export default CreateInterview;

// ============================================================================
// FILE: src/components/CandidateInterview.tsx
// ============================================================================
import React, { useState, FormEvent } from 'react';
import { interviewAPI } from '../services/api';
import { Question } from '../types';
import InterviewSession from './InterviewSession';

const CandidateInterview: React.FC = () => {
  const [email, setEmail] = useState<string>('');
  const [sessionStarted, setSessionStarted] = useState<boolean>(false);
  const [sessionData, setSessionData] = useState<Question | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleStartInterview = async (e: FormEvent<HTMLFormElement>): Promise<void> => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const data = await interviewAPI.start(email);
      setSessionData(data);
      setSessionStarted(true);
    } catch (err) {
      setError('No pending interview found for this email. Please contact HR.');
    } finally {
      setLoading(false);
    }
  };

  const handleInterviewComplete = (): void => {
    setSessionStarted(false);
    setSessionData(null);
    setEmail('');
  };

  if (sessionStarted && sessionData) {
    return (
      <InterviewSession sessionData={sessionData} candidateEmail={email} onComplete={handleInterviewComplete} />
    );
  }

  return (
    <div>
      <h2 style={{ color: 'white', marginBottom: '24px', fontSize: '2rem' }}>Candidate Interview Portal</h2>

      <div className="card" style={{ maxWidth: '600px', margin: '0 auto' }}>
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <h3 style={{ color: '#667eea', marginBottom: '16px' }}>Welcome to Your Interview</h3>
          <p style={{ color: '#718096', lineHeight: '1.6' }}>
            Please enter your registered email address to begin your interview session. Make sure you're in a quiet
            environment and have adequate time to complete all questions.
          </p>
        </div>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={handleStartInterview}>
          <div className="input-group">
            <label>Email Address</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="your.email@example.com"
              style={{ fontSize: '18px' }}
            />
          </div>

          <button type="submit" className="btn btn-primary" disabled={loading} style={{ width: '100%', fontSize: '18px' }}>
            {loading ? 'Verifying...' : 'Start Interview'}
          </button>
        </form>

        <div style={{ marginTop: '32px', padding: '20px', background: '#f7fafc', borderRadius: '8px' }}>
          <h4 style={{ marginBottom: '12px', color: '#2d3748' }}>Before You Begin:</h4>
          <ul style={{ color: '#4a5568', lineHeight: '1.8', paddingLeft: '20px' }}>
            <li>Ensure stable internet connection</li>
            <li>Find a quiet, distraction-free environment</li>
            <li>Have your webcam and microphone ready (if required)</li>
            <li>Read each question carefully before answering</li>
            <li>You cannot go back to previous questions</li>
            <li>Be honest and authentic in your responses</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default CandidateInterview;

// ============================================================================
// FILE: src/components/InterviewSession.tsx
// ============================================================================
import React, { useState, FormEvent } from 'react';
import { interviewAPI } from '../services/api';
import { Question } from '../types';

interface InterviewSessionProps {
  sessionData: Question;
  candidateEmail: string;
  onComplete: () => void;
}

const InterviewSession: React.FC<InterviewSessionProps> = ({ sessionData, candidateEmail, onComplete }) => {
  const [currentQuestion, setCurrentQuestion] = useState<Question>(sessionData);
  const [answer, setAnswer] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [showThankYou, setShowThankYou] = useState<boolean>(false);

  const progress = (currentQuestion.currentStep / currentQuestion.totalSteps) * 100;

  const handleSubmitAnswer = async (e: FormEvent<HTMLFormElement>): Promise<void> => {
    e.preventDefault();

    if (answer.trim().length < 10) {
      setError('Please provide a more detailed answer (at least 10 characters)');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const sessionId = currentQuestion.questionId;
      await interviewAPI.submitAnswer(sessionId, currentQuestion.questionId, answer);

      if (currentQuestion.currentStep >= currentQuestion.totalSteps) {
        setShowThankYou(true);
      } else {
        const nextQuestion = await interviewAPI.getNextQuestion(sessionId);
        setCurrentQuestion(nextQuestion);
        setAnswer('');
      }
    } catch (err) {
      setError('Failed to submit answer. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleCompleteInterview = async (): Promise<void> => {
    setLoading(true);
    try {
      const sessionId = currentQuestion.questionId;
      const result = await interviewAPI.complete(sessionId);
      alert(result.message);
      onComplete();
    } catch (err) {
      setError('Failed to complete interview. Please contact support.');
    } finally {
      setLoading(false);
    }
  };

  if (showThankYou) {
    return (
      <div>
        <h2 style={{ color: 'white', marginBottom: '24px', fontSize: '2rem' }}>Interview Complete</h2>

        <div className="card" style={{ maxWidth: '700px', margin: '0 auto', textAlign: 'center' }}>
          <div style={{ fontSize: '64px', marginBottom: '24px' }}>🎉</div>

          <h3 style={{ color: '#667eea', marginBottom: '16px', fontSize: '2rem' }}>Thank You for Your Time!</h3>

          <p style={{ color: '#4a5568', fontSize: '18px', lineHeight: '1.8', marginBottom: '32px' }}>
            You have successfully completed all {currentQuestion.totalSteps} questions. Your responses have been
            recorded and will be evaluated by our HR team. We will contact you soon with the results.
          </p>

          <div style={{ background: '#f7fafc', padding: '24px', borderRadius: '8px', marginBottom: '24px' }}>
            <h4 style={{ marginBottom: '12px', color: '#2d3748' }}>What's Next?</h4>
            <ul style={{ color: '#718096', lineHeight: '1.8', textAlign: 'left', paddingLeft: '20px' }}>
              <li>Your answers are being evaluated using AI-powered analysis</li>
              <li>HR team will review your performance across all categories</li>
              <li>You'll receive feedback within 3-5 business days</li>
              <li>If selected, you'll be contacted for the next round</li>
            </ul>
          </div>

          <button
            className="btn btn-primary"
            onClick={handleCompleteInterview}
            disabled={loading}
            style={{ fontSize: '18px', padding: '16px 32px' }}
          >
            {loading ? 'Submitting...' : 'Close Interview'}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div>
      <h2 style={{ color: 'white', marginBottom: '24px', fontSize: '2rem' }}>Interview in Progress</h2>

      <div className="card">
        <div style={{ marginBottom: '24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
            <span style={{ fontWeight: '600', color: '#4a5568' }}>
              Question {currentQuestion.currentStep} of {currentQuestion.totalSteps}
            </span>
            <span style={{ fontWeight: '600', color: '#667eea' }}>{Math.round(progress)}% Complete</span>
          </div>
          <div className="progress-bar">
            <div className="progress-bar-fill" style={{ width: `${progress}%` }}></div>
          </div>
        </div>

        <div style={{ background: '#f7fafc', padding: '24px', borderRadius: '8px', marginBottom: '24px' }}>
          <div style={{ marginBottom: '12px' }}>
            <span
              style={{
                display: 'inline-block',
                background: '#667eea',
                color: 'white',
                padding: '4px 12px',
                borderRadius: '4px',
                fontSize: '14px',
                fontWeight: '600',
              }}
            >
              {currentQuestion.category}
            </span>
          </div>

          <h3 style={{ color: '#2d3748', fontSize: '1.5rem', lineHeight: '1.6' }}>{currentQuestion.questionText}</h3>
        </div>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={handleSubmitAnswer}>
          <div className="input-group">
            <label>Your Answer</label>
            <textarea
              value={answer}
              onChange={(e) => setAnswer(e.target.value)}
              required
              rows={8}
              placeholder="Type your detailed answer here..."
              style={{ fontSize: '16px' }}
            />
            <small style={{ color: '#718096', marginTop: '8px', display: 'block' }}>
              Minimum 10 characters. Take your time to provide a thoughtful response.
            </small>
          </div>

          <div style={{ display: 'flex', gap: '12px' }}>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading || answer.trim().length < 10}
              style={{ flex: 1, fontSize: '18px' }}
            >
              {loading
                ? 'Submitting...'
                : currentQuestion.currentStep >= currentQuestion.totalSteps
                ? 'Submit Final Answer'
                : 'Next Question'}
            </button>
          </div>
        </form>

        <div style={{ marginTop: '24px', padding: '16px', background: '#bee3f8', borderRadius: '8px' }}>
          <p style={{ color: '#2c5282', fontSize: '14px', margin: 0 }}>
            💡 <strong>Tip:</strong> Be specific and provide examples when possible. Quality over quantity matters in
            your responses.
          </p>
        </div>
      </div>
    </div>
  );
};

export default InterviewSession;

// ============================================================================
// FILE: src/components/EvaluationDashboard.tsx
// ============================================================================
import React, { useState, useEffect } from 'react';
import { dashboardAPI } from '../services/api';
import { EvaluationResult } from '../types';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
} from 'recharts';

interface ChartData {
  category: string;
  score: number;
}

interface RadarData {
  subject: string;
  A: number;
  fullMark: number;
}

const EvaluationDashboard: React.FC = () => {
  const [evaluations, setEvaluations] = useState<EvaluationResult[]>([]);
  const [selectedEvaluation, setSelectedEvaluation] = useState<EvaluationResult | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadEvaluations();
  }, []);

  const loadEvaluations = async (): Promise<void> => {
    try {
      setLoading(true);
      const data = await dashboardAPI.getAllEvaluations();
      setEvaluations(data);
    } catch (err) {
      setError('Failed to load evaluations');
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetails = (evaluation: EvaluationResult): void => {
    setSelectedEvaluation(evaluation);
  };

  const getScoreColor = (score: number): string => {
    if (score >= 80) return '#48bb78';
    if (score >= 60) return '#ed8936';
    return '#f56565';
  };

  const getRecommendationBadge = (proceedToNextRound: boolean): JSX.Element => {
    return proceedToNextRound ? (
      <span
        style={{
          background: '#c6f6d5',
          color: '#22543d',
          padding: '6px 16px',
          borderRadius: '20px',
          fontSize: '14px',
          fontWeight: '600',
        }}
      >
        ✓ Recommended
      </span>
    ) : (
      <span
        style={{
          background: '#fed7d7',
          color: '#742a2a',
          padding: '6px 16px',
          borderRadius: '20px',
          fontSize: '14px',
          fontWeight: '600',
        }}
      >
        ✗ Not Recommended
      </span>
    );
  };

  if (loading) {
    return (
      <div className="loading">
        <div className="spinner"></div>
      </div>
    );
  }

  if (selectedEvaluation) {
    const chartData: ChartData[] = [
      { category: 'Coding', score: selectedEvaluation.codingScore },
      { category: 'Technical', score: selectedEvaluation.technicalScore },
      { category: 'Behavioral', score: selectedEvaluation.behavioralScore },
    ];

    const radarData: RadarData[] = [
      { subject: 'Coding', A: selectedEvaluation.codingScore, fullMark: 100 },
      { subject: 'Technical', A: selectedEvaluation.technicalScore, fullMark: 100 },
      { subject: 'Behavioral', A: selectedEvaluation.behavioralScore, fullMark: 100 },
    ];

    return (
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
          <h2 style={{ color: 'white', fontSize: '2rem' }}>Candidate Evaluation Details</h2>
          <button className="btn btn-secondary" onClick={() => setSelectedEvaluation(null)}>
            ← Back to List
          </button>
        </div>

        <div className="grid grid-2">
          <div className="stat-card">
            <h3>{selectedEvaluation.overallScore}</h3>
            <p>Overall Score</p>
          </div>
          <div className="stat-card" style={{ background: 'linear-gradient(135deg, #48bb78 0%, #38a169 100%)' }}>
            <h3>{selectedEvaluation.codingScore}</h3>
            <p>Coding Score</p>
          </div>
          <div className="stat-card" style={{ background: 'linear-gradient(135deg, #ed8936 0%, #dd6b20 100%)' }}>
            <h3>{selectedEvaluation.technicalScore}</h3>
            <p>Technical Score</p>
          </div>
          <div className="stat-card" style={{ background: 'linear-gradient(135deg, #4299e1 0%, #3182ce 100%)' }}>
            <h3>{selectedEvaluation.behavioralScore}</h3>
            <p>Behavioral Score</p>
          </div>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '20px' }}>Performance Breakdown</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="category" />
              <YAxis domain={[0, 100]} />
              <Tooltip />
              <Legend />
              <Bar dataKey="score" fill="#667eea" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '20px' }}>Skills Radar</h3>
          <ResponsiveContainer width="100%" height={400}>
            <RadarChart data={radarData}>
              <PolarGrid />
              <PolarAngleAxis dataKey="subject" />
              <PolarRadiusAxis domain={[0, 100]} />
              <Radar name="Score" dataKey="A" stroke="#667eea" fill="#667eea" fillOpacity={0.6} />
              <Tooltip />
            </RadarChart>
          </ResponsiveContainer>
        </div>

        <div className="card">
          <h3 style={{ marginBottom: '20px' }}>Detailed Feedback</h3>

          <div style={{ marginBottom: '24px' }}>
            <h4 style={{ color: '#48bb78', marginBottom: '12px' }}>💻 Coding Evaluation</h4>
            <p style={{ color: '#4a5568', lineHeight: '1.6' }}>
              {selectedEvaluation.codingFeedback || 'No feedback available'}
            </p>
          </div>

          <div style={{ marginBottom: '24px' }}>
            <h4 style={{ color: '#ed8936', marginBottom: '12px' }}>⚙️ Technical Evaluation</h4>
            <p style={{ color: '#4a5568', lineHeight: '1.6' }}>
              {selectedEvaluation.technicalFeedback || 'No feedback available'}
            </p>
          </div>

          <div style={{ marginBottom: '24px' }}>
            <h4 style={{ color: '#4299e1', marginBottom: '12px' }}>🤝 Behavioral Evaluation</h4>
            <p style={{ color: '#4a5568', lineHeight: '1.6' }}>
              {selectedEvaluation.behavioralFeedback || 'No feedback available'}
            </p>
          </div>

          <div
            style={{
              background: selectedEvaluation.proceedToNextRound ? '#c6f6d5' : '#fed7d7',
              padding: '20px',
              borderRadius: '8px',
            }}
          >
            <h4 style={{ marginBottom: '12px' }}>Final Recommendation</h4>
            <p style={{ marginBottom: '12px', lineHeight: '1.6' }}>{selectedEvaluation.recommendation}</p>
            {getRecommendationBadge(selectedEvaluation.proceedToNextRound)}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div>
      <h2 style={{ color: 'white', marginBottom: '24px', fontSize: '2rem' }}>Evaluation Dashboard</h2>

      {error && <div className="alert alert-error">{error}</div>}

      {evaluations.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '60px' }}>
          <div style={{ fontSize: '64px', marginBottom: '16px' }}>📊</div>
          <h3 style={{ color: '#4a5568', marginBottom: '12px' }}>No Evaluations Yet</h3>
          <p style={{ color: '#718096' }}>Completed interviews will appear here with detailed evaluations.</p>
        </div>
      ) : (
        <div className="grid grid-2">
          {evaluations.map((evaluation, index) => (
            <div key={index} className="card" style={{ cursor: 'pointer' }} onClick={() => handleViewDetails(evaluation)}>
              <div style={{ marginBottom: '16px' }}>
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: '12px',
                  }}
                >
                  <h3 style={{ color: '#667eea' }}>Candidate #{index + 1}</h3>
                  {getRecommendationBadge(evaluation.proceedToNextRound)}
                </div>
              </div>

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(2, 1fr)',
                  gap: '12px',
                  marginBottom: '16px',
                }}
              >
                <div style={{ background: '#f7fafc', padding: '12px', borderRadius: '8px' }}>
                  <p style={{ fontSize: '12px', color: '#718096', marginBottom: '4px' }}>Overall</p>
                  <p style={{ fontSize: '24px', fontWeight: '700', color: getScoreColor(evaluation.overallScore) }}>
                    {evaluation.overallScore}
                  </p>
                </div>
                <div style={{ background: '#f7fafc', padding: '12px', borderRadius: '8px' }}>
                  <p style={{ fontSize: '12px', color: '#718096', marginBottom: '4px' }}>Coding</p>
                  <p style={{ fontSize: '24px', fontWeight: '700', color: getScoreColor(evaluation.codingScore) }}>
                    {evaluation.codingScore}
                  </p>
                </div>
                <div style={{ background: '#f7fafc', padding: '12px', borderRadius: '8px' }}>
                  <p style={{ fontSize: '12px', color: '#718096', marginBottom: '4px' }}>Technical</p>
                  <p style={{ fontSize: '24px', fontWeight: '700', color: getScoreColor(evaluation.technicalScore) }}>
                    {evaluation.technicalScore}
                  </p>
                </div>
                <div style={{ background: '#f7fafc', padding: '12px', borderRadius: '8px' }}>
                  <p style={{ fontSize: '12px', color: '#718096', marginBottom: '4px' }}>Behavioral</p>
                  <p style={{ fontSize: '24px', fontWeight: '700', color: getScoreColor(evaluation.behavioralScore) }}>
                    {evaluation.behavioralScore}
                  </p>
                </div>
              </div>

              <button
                className="btn btn-primary"
                style={{ width: '100%', fontSize: '14px' }}
                onClick={(e) => {
                  e.stopPropagation();
                  handleViewDetails(evaluation);
                }}
              >
                View Full Report →
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default EvaluationDashboard;

/*
================================================================================
INSTALLATION INSTRUCTIONS:
================================================================================

1. CREATE PROJECT FOLDER:
   mkdir frontend
   cd frontend

2. COPY FILES:
   - Copy package.json and save it
   - Copy tsconfig.json and save it
   - Copy tsconfig.node.json and save it
   - Copy vite.config.ts and save it
   - Copy index.html and save it
   - Copy .env and save it

3. CREATE SRC FOLDER STRUCTURE:
   mkdir -p src/types src/services src/components

4. COPY ALL SOURCE FILES TO THEIR LOCATIONS:
   - src/types/index.ts
   - src/services/api.ts
   - src/index.css
   - src/main.tsx
   - src/App.tsx
   - src/components/Navbar.tsx
   - src/components/HRDashboard.tsx
   - src/components/CreateJobDescription.tsx
   - src/components/CreateInterview.tsx
   - src/components/CandidateInterview.tsx
   - src/components/InterviewSession.tsx
   - src/components/EvaluationDashboard.tsx

5. INSTALL DEPENDENCIES:
   npm install

6. RUN DEVELOPMENT SERVER:
   npm run dev

7. BUILD FOR PRODUCTION:
   npm run build

================================================================================
THAT'S IT! YOUR TYPESCRIPT REACT FRONTEND IS READY! 🎉
================================================================================
*/