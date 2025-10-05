import { createStore, action, Action } from 'easy-peasy';
import { Message, UserContext } from '../types';

export interface StoreModel {
  // State
  messages: Message[];
  userContext: UserContext | null;
  isLoading: boolean;
  isStreaming: boolean;
  currentStreamContent: string;
  
  // Actions
  addMessage: Action<StoreModel, Message>;
  updateLastMessage: Action<StoreModel, string>;
  appendToLastMessage: Action<StoreModel, string>;
  setUserContext: Action<StoreModel, UserContext | null>;
  setLoading: Action<StoreModel, boolean>;
  setStreaming: Action<StoreModel, boolean>;
  setStreamContent: Action<StoreModel, string>;
  clearMessages: Action<StoreModel>;
  removeMessage: Action<StoreModel, string>;
}

export const store = createStore<StoreModel>({
  // Initial State
  messages: [],
  userContext: null,
  isLoading: false,
  isStreaming: false,
  currentStreamContent: '',

  // Actions
  addMessage: action((state, payload) => {
    state.messages.push(payload);
  }),

  updateLastMessage: action((state, payload) => {
    if (state.messages.length > 0) {
      state.messages[state.messages.length - 1].content = payload;
    }
  }),

  appendToLastMessage: action((state, payload) => {
    if (state.messages.length > 0) {
      state.messages[state.messages.length - 1].content += payload;
    }
  }),

  setUserContext: action((state, payload) => {
    state.userContext = payload;
  }),

  setLoading: action((state, payload) => {
    state.isLoading = payload;
  }),

  setStreaming: action((state, payload) => {
    state.isStreaming = payload;
  }),

  setStreamContent: action((state, payload) => {
    state.currentStreamContent = payload;
  }),

  clearMessages: action((state) => {
    state.messages = [];
  }),

  removeMessage: action((state, payload) => {
    state.messages = state.messages.filter(msg => msg.id !== payload);
  }),
});