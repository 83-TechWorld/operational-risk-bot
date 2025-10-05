import React, { useState, useRef, useEffect } from 'react';
import {
  Container,
  Row,
  Col,
  Input,
  Button,
  Card,
  CardBody,
  Badge,
  Table,
  Alert,
  FormGroup,
  Label,
} from 'reactstrap';
import { useStoreState, useStoreActions } from 'easy-peasy';
import { StoreModel } from '../store/chatStore';
import { chatAPI } from '../services/api';
import { Message } from '../types';
import ReactMarkdown from 'react-markdown';
import { toast } from 'react-toastify';

export const ChatInterface: React.FC = () => {
  const [input, setInput] = useState('');
  const [useStreaming, setUseStreaming] = useState(true);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const messages = useStoreState((state: StoreModel) => state.messages);
  const userContext = useStoreState((state: StoreModel) => state.userContext);
  const isLoading = useStoreState((state: StoreModel) => state.isLoading);
  const isStreaming = useStoreState((state: StoreModel) => state.isStreaming);

  const addMessage = useStoreActions((actions: StoreModel) => actions.addMessage);
  const appendToLastMessage = useStoreActions((actions: StoreModel) => actions.appendToLastMessage);
  const setLoading = useStoreActions((actions: StoreModel) => actions.setLoading);
  const setStreaming = useStoreActions((actions: StoreModel) => actions.setStreaming);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async () => {
    if (!input.trim() || !userContext) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    addMessage(userMessage);
    setInput('');

    if (useStreaming) {
      await handleStreamingChat(input);
    } else {
      await handleRegularChat(input);
    }
  };

  const handleRegularChat = async (query: string) => {
    setLoading(true);

    try {
      const response = await chatAPI.sendMessage({
        query,
        user_context: userContext!,
        use_streaming: false,
      });

      if (response.requires_confirmation) {
        const confirmMessage: Message = {
          id: Date.now().toString(),
          role: 'assistant',
          content: response.message || 'This operation requires confirmation.',
          timestamp: new Date(),
          requires_confirmation: true,
          sql_query: response.sql_query,
          classification: response.classification,
        };
        addMessage(confirmMessage);
      } else {
        const assistantMessage: Message = {
          id: Date.now().toString(),
          role: 'assistant',
          content: response.response,
          timestamp: new Date(),
          data: response.data,
          sources: response.sources,
          classification: response.classification,
        };
        addMessage(assistantMessage);
      }
    } catch (error: any) {
      toast.error(error.message || 'Failed to send message');
      const errorMessage: Message = {
        id: Date.now().toString(),
        role: 'system',
        content: `Error: ${error.message}`,
        timestamp: new Date(),
      };
      addMessage(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleStreamingChat = async (query: string) => {
    setStreaming(true);

    const assistantMessage: Message = {
      id: Date.now().toString(),
      role: 'assistant',
      content: '',
      timestamp: new Date(),
    };

    addMessage(assistantMessage);

    try {
      await chatAPI.sendMessageStream(
        {
          query,
          user_context: userContext!,
          use_streaming: true,
        },
        (event) => {
          switch (event.type) {
            case 'content':
              appendToLastMessage(event.chunk);
              break;
            case 'error':
              toast.error(event.message);
              break;
          }
        },
        (error) => {
          toast.error(error.message);
        }
      );
    } catch (error: any) {
      toast.error(error.message);
    } finally {
      setStreaming(false);
    }
  };

  const handleConfirm = async (message: Message) => {
    if (!message.sql_query || !userContext) return;

    setLoading(true);

    try {
      const response = await chatAPI.confirmQuery(
        message.sql_query,
        message.classification?.application || 'eControls',
        userContext
      );

      const resultMessage: Message = {
        id: Date.now().toString(),
        role: 'assistant',
        content: response.response,
        timestamp: new Date(),
        data: response.data,
      };

      addMessage(resultMessage);
      toast.success('Operation completed successfully');
    } catch (error: any) {
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <Container fluid className="h-100 d-flex flex-column" style={{ padding: 0 }}>
      {/* Header */}
      <div className="bg-white border-bottom p-3">
        <Row className="align-items-center">
          <Col>
            <h4 className="mb-0">
              <i className="bi bi-robot me-2"></i>
              Enterprise RAG Assistant
            </h4>
            <small className="text-muted">
              {userContext
                ? `${userContext.username} • ${userContext.ou} • Role: ${userContext.role.toUpperCase()}`
                : 'Not logged in'}
            </small>
          </Col>
          <Col xs="auto">
            <FormGroup check inline className="mb-0">
              <Input
                type="checkbox"
                checked={useStreaming}
                onChange={(e) => setUseStreaming(e.target.checked)}
                id="streaming-toggle"
              />
              <Label check for="streaming-toggle">
                Enable Streaming
              </Label>
            </FormGroup>
          </Col>
        </Row>
      </div>

      {/* Messages */}
      <div
        className="flex-grow-1 overflow-auto p-4"
        style={{ backgroundColor: '#f8f9fa' }}
      >
        <Container>
          {messages.map((message) => (
            <MessageBubble
              key={message.id}
              message={message}
              onConfirm={handleConfirm}
            />
          ))}
          <div ref={messagesEndRef} />
        </Container>
      </div>

      {/* Input Area */}
      <div className="bg-white border-top p-3">
        <Container>
          <Row>
            <Col>
              <Input
                type="textarea"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyPress={handleKeyPress}
                placeholder="Ask about controls, KRIs, or query documents..."
                rows={3}
                disabled={isLoading || isStreaming}
              />
            </Col>
            <Col xs="auto" className="d-flex align-items-end">
              <Button
                color="primary"
                onClick={handleSendMessage}
                disabled={!input.trim() || isLoading || isStreaming || !userContext}
                size="lg"
              >
                <i className="bi bi-send me-2"></i>
                {isLoading || isStreaming ? 'Processing...' : 'Send'}
              </Button>
            </Col>
          </Row>
        </Container>
      </div>
    </Container>
  );
};

interface MessageBubbleProps {
  message: Message;
  onConfirm: (message: Message) => void;
}

const MessageBubble: React.FC<MessageBubbleProps> = ({ message, onConfirm }) => {
  const isUser = message.role === 'user';
  const isSystem = message.role === 'system';

  return (
    <Row className={`mb-3 ${isUser ? 'justify-content-end' : 'justify-content-start'}`}>
      <Col md={8}>
        <Card
          className={
            isUser
              ? 'bg-primary text-white'
              : isSystem
              ? 'border-danger'
              : 'border'
          }
        >
          <CardBody>
            <div className="d-flex align-items-start mb-2">
              <div
                className={`rounded-circle d-flex align-items-center justify-content-center me-2`}
                style={{
                  width: '32px',
                  height: '32px',
                  backgroundColor: isUser ? 'white' : isSystem ? '#dc3545' : '#28a745',
                }}
              >
                <i
                  className={`bi ${
                    isUser ? 'bi-person-fill text-primary' : isSystem ? 'bi-exclamation-triangle-fill text-white' : 'bi-robot text-white'
                  }`}
                ></i>
              </div>
              <div className="flex-grow-1">
                <ReactMarkdown>{message.content}</ReactMarkdown>

                {/* Classification Badges */}
                {message.classification && (
                  <div className="mt-2">
                    <Badge color="secondary" className="me-1">
                      {message.classification.application}
                    </Badge>
                    <Badge color="info">{message.classification.intent}</Badge>
                  </div>
                )}

                {/* Data Table */}
                {message.data && Array.isArray(message.data) && message.data.length > 0 && (
                  <div className="mt-3">
                    <Table striped bordered hover size="sm" responsive>
                      <thead>
                        <tr>
                          {Object.keys(message.data[0]).map((key) => (
                            <th key={key}>{key}</th>
                          ))}
                        </tr>
                      </thead>
                      <tbody>
                        {message.data.slice(0, 10).map((row: any, idx: number) => (
                          <tr key={idx}>
                            {Object.values(row).map((val: any, i: number) => (
                              <td key={i}>{String(val)}</td>
                            ))}
                          </tr>
                        ))}
                      </tbody>
                    </Table>
                    {message.data.length > 10 && (
                      <small className="text-muted">
                        Showing 10 of {message.data.length} rows
                      </small>
                    )}
                  </div>
                )}

                {/* Confirmation Buttons */}
                {message.requires_confirmation && (
                  <div className="mt-3">
                    <Button
                      color="success"
                      size="sm"
                      className="me-2"
                      onClick={() => onConfirm(message)}
                    >
                      <i className="bi bi-check-lg me-1"></i>
                      Confirm
                    </Button>
                    <Button color="danger" size="sm">
                      <i className="bi bi-x-lg me-1"></i>
                      Cancel
                    </Button>
                  </div>
                )}

                {/* Sources */}
                {message.sources && message.sources.length > 0 && (
                  <Alert color="info" className="mt-3 mb-0">
                    <small>
                      <strong>
                        <i className="bi bi-file-text me-1"></i>
                        Sources:
                      </strong>
                    </small>
                    <ul className="mb-0 mt-1">
                      {message.sources.map((source, idx) => (
                        <li key={idx}>
                          <small>{source.document_name}</small>
                        </li>
                      ))}
                    </ul>
                  </Alert>
                )}

                <small className={isUser ? 'text-white-50' : 'text-muted'}>
                  {message.timestamp.toLocaleTimeString()}
                </small>
              </div>
            </div>
          </CardBody>
        </Card>
      </Col>
    </Row>
  );
};