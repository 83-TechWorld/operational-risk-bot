export type UserRole = 'admin' | 'user';

export interface UserContext {
  user_id: number;
  username: string;
  email: string;
  ou: string;
  lre: string;
  country: string;
  role: UserRole;
}

export interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Date;
  data?: any;
  sources?: Source[];
  classification?: Classification;
  requires_confirmation?: boolean;
  sql_query?: string;
  application?: string;
}

export interface Classification {
  application: 'eControls' | 'MyKRI' | 'BOTH' | 'RAG_ONLY';
  intent: 'READ' | 'WRITE' | 'DELETE' | 'INFORMATION';
  requires_confirmation: boolean;
  entities: string[];
  reasoning: string;
}

export interface Source {
  document_name: string;
  relevance_score: number;
  content: string;
}

export interface ChatRequest {
  query: string;
  user_context: UserContext;
  use_streaming: boolean;
}

export interface ChatResponse {
  response: string;
  data?: any;
  sql_executed?: string;
  sources?: Source[];
  classification?: Classification;
  requires_confirmation?: boolean;
  sql_query?: string;
  application?: string;
  message?: string;
}

export interface StreamEvent {
  type: 'status' | 'classification' | 'content' | 'data' | 'error';
  message?: string;
  chunk?: string;
  data?: any;
}

export interface Document {
  id: string;
  name: string;
  application: string;
  upload_date: Date;
  size: number;
  uploaded_by: string;
}