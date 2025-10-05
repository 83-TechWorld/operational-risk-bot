import axios from 'axios';
import { ChatRequest, ChatResponse, UserContext } from '../types';

// Extend ImportMeta to include env property
interface ImportMeta {
  readonly env: {
    readonly VITE_API_BASE_URL?: string;
  };
}

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const chatAPI = {
  // Regular chat (non-streaming)
  sendMessage: async (request: ChatRequest): Promise<ChatResponse> => {
    const response = await apiClient.post<ChatResponse>('/chat', request);
    return response.data;
  },

  // Streaming chat
  sendMessageStream: async (
    request: ChatRequest,
    onChunk: (event: any) => void,
    onError: (error: Error) => void
  ) => {
    try {
      const response = await fetch(`${API_BASE_URL}/chat/stream`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(request),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();

      if (!reader) {
        throw new Error('Response body is null');
      }

      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n');

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6);
            
            if (data === '[DONE]') {
              return;
            }

            try {
              const parsed = JSON.parse(data);
              onChunk(parsed);
            } catch (e) {
              console.error('Failed to parse SSE data:', e);
            }
          }
        }
      }
    } catch (error) {
      onError(error as Error);
    }
  },

  // Confirm and execute query
  confirmQuery: async (
    sql_query: string,
    application: string,
    user_context: UserContext
  ): Promise<ChatResponse> => {
    const response = await apiClient.post<ChatResponse>('/chat', {
      query: `EXECUTE: ${sql_query}`,
      user_context,
      confirmed: true,
    });
    return response.data;
  },
};

export const documentAPI = {
  // Upload document
  uploadDocument: async (
    file: File,
    application: string,
    metadata?: Record<string, any>
  ): Promise<any> => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('application', application);
    if (metadata) {
      formData.append('metadata', JSON.stringify(metadata));
    }

    const response = await apiClient.post('/documents/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });

    return response.data;
  },

  // List documents
  listDocuments: async (): Promise<any> => {
    const response = await apiClient.get('/documents');
    return response.data;
  },
};

export const userAPI = {
  // Get user context
  getUserContext: async (userId: number, application: string): Promise<UserContext> => {
    const response = await apiClient.get<UserContext>(`/user/context/${userId}`, {
      params: { application },
    });
    return response.data;
  },
};

export const healthAPI = {
  // Health check
  checkHealth: async (): Promise<any> => {
    const response = await apiClient.get('/health');
    return response.data;
  },
};