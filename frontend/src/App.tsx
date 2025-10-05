import React, { useState, useEffect } from 'react';
import {
  Container,
  Row,
  Col,
  Card,
  CardBody,
  Form,
  FormGroup,
  Label,
  Input,
  Button,
  Nav,
  NavItem,
  NavLink,
  Alert,
} from 'reactstrap';
import { useStoreState, useStoreActions } from 'easy-peasy';
import { StoreModel } from './store/chatStore';
import { ChatInterface } from './components/ChatInterface';
import { DocumentUpload } from './components/DocumentUpload';
import { userAPI, healthAPI } from './services/api';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { UserRole } from './types';

type Tab = 'chat' | 'documents' | 'analytics';

function App() {
  const [activeTab, setActiveTab] = useState<Tab>('chat');
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [userId, setUserId] = useState<string>('');
  const [selectedApp, setSelectedApp] = useState<string>('eControls');
  const [selectedRole, setSelectedRole] = useState<UserRole>('user');

  const userContext = useStoreState((state: StoreModel) => state.userContext);
  const setUserContext = useStoreActions((actions: StoreModel) => actions.setUserContext);

  useEffect(() => {
    checkBackendHealth();
  }, []);

  const checkBackendHealth = async () => {
    try {
      await healthAPI.checkHealth();
      toast.success('Connected to backend successfully');
    } catch (error) {
      toast.error('Failed to connect to backend. Please check if the server is running.');
    }
  };

  const handleLogin = async () => {
    if (!userId) {
      toast.error('Please enter a user ID');
      return;
    }

    setIsLoggingIn(true);

    try {
      const context = await userAPI.getUserContext(parseInt(userId), selectedApp);
      // Add role to context (in production, this should come from backend)
      const contextWithRole = { ...context, role: selectedRole };
      setUserContext(contextWithRole);
      toast.success(`Logged in as ${context.username} (${selectedRole.toUpperCase()})`);
    } catch (error: any) {
      toast.error(error.response?.data?.detail || 'Failed to fetch user context');
    } finally {
      setIsLoggingIn(false);
    }
  };

  const handleLogout = () => {
    setUserContext(null);
    setUserId('');
    setActiveTab('chat');
    toast.info('Logged out successfully');
  };

  // Login Screen
  if (!userContext) {
    return (
      <div
        className="d-flex align-items-center justify-content-center"
        style={{
          minHeight: '100vh',
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        }}
      >
        <ToastContainer position="top-right" autoClose={3000} />

        <Container>
          <Row className="justify-content-center">
            <Col md={6} lg={5}>
              <Card className="shadow-lg">
                <CardBody className="p-5">
                  <div className="text-center mb-4">
                    <div
                      className="bg-primary rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                      style={{ width: '80px', height: '80px' }}
                    >
                      <i className="bi bi-database text-white" style={{ fontSize: '2.5rem' }}></i>
                    </div>
                    <h2 className="mb-2">Enterprise RAG Assistant</h2>
                    <p className="text-muted">
                      Connect to eControls and MyKRI applications
                    </p>
                  </div>

                  <Form>
                    <FormGroup>
                      <Label for="user-id">User ID</Label>
                      <Input
                        type="number"
                        id="user-id"
                        value={userId}
                        onChange={(e) => setUserId(e.target.value)}
                        placeholder="Enter your user ID"
                      />
                    </FormGroup>

                    <FormGroup>
                      <Label for="application">Application</Label>
                      <Input
                        type="select"
                        id="application"
                        value={selectedApp}
                        onChange={(e) => setSelectedApp(e.target.value)}
                      >
                        <option value="eControls">eControls</option>
                        <option value="MyKRI">MyKRI</option>
                      </Input>
                    </FormGroup>

                    <FormGroup>
                      <Label for="role">User Role</Label>
                      <Input
                        type="select"
                        id="role"
                        value={selectedRole}
                        onChange={(e) => setSelectedRole(e.target.value as UserRole)}
                      >
                        <option value="user">Normal User</option>
                        <option value="admin">Administrator</option>
                      </Input>
                      <small className="text-muted">
                        Admin can upload documents, User can only query
                      </small>
                    </FormGroup>

                    <Button
                      color="primary"
                      block
                      size="lg"
                      onClick={handleLogin}
                      disabled={isLoggingIn}
                    >
                      {isLoggingIn ? (
                        <>
                          <span
                            className="spinner-border spinner-border-sm me-2"
                            role="status"
                          />
                          Connecting...
                        </>
                      ) : (
                        <>
                          <i className="bi bi-box-arrow-in-right me-2"></i>
                          Connect
                        </>
                      )}
                    </Button>
                  </Form>

                  <Alert color="info" className="mt-4 mb-0">
                    <small>
                      <i className="bi bi-shield-lock me-2"></i>
                      <strong>Secure Access:</strong> Your queries are filtered by
                      Organization Unit (OU), Legal Entity (LRE), and Country based on
                      your access rights.
                    </small>
                  </Alert>
                </CardBody>
              </Card>
            </Col>
          </Row>
        </Container>
      </div>
    );
  }

  // Main Application (After Login)
  return (
    <div className="d-flex flex-column" style={{ height: '100vh' }}>
      <ToastContainer position="top-right" autoClose={3000} />

      {/* Top Navigation Bar */}
      <nav className="navbar navbar-dark bg-primary">
        <Container fluid>
          <span className="navbar-brand mb-0 h1">
            <i className="bi bi-database me-2"></i>
            Enterprise RAG Assistant
          </span>
          
          <div className="d-flex align-items-center">
            <span className="text-white me-3">
              <i className="bi bi-person-circle me-2"></i>
              {userContext.username} ({userContext.role.toUpperCase()})
            </span>
            <Button color="light" outline size="sm" onClick={handleLogout}>
              <i className="bi bi-box-arrow-right me-2"></i>
              Logout
            </Button>
          </div>
        </Container>
      </nav>

      {/* Tab Navigation */}
      <div className="bg-light border-bottom">
        <Container fluid>
          <Nav tabs>
            <NavItem>
              <NavLink
                className={activeTab === 'chat' ? 'active' : ''}
                onClick={() => setActiveTab('chat')}
                style={{ cursor: 'pointer' }}
              >
                <i className="bi bi-chat-dots me-2"></i>
                Chat
              </NavLink>
            </NavItem>

            {userContext.role === 'admin' && (
              <NavItem>
                <NavLink
                  className={activeTab === 'documents' ? 'active' : ''}
                  onClick={() => setActiveTab('documents')}
                  style={{ cursor: 'pointer' }}
                >
                  <i className="bi bi-file-earmark-arrow-up me-2"></i>
                  Upload Documents
                </NavLink>
              </NavItem>
            )}

            <NavItem>
              <NavLink
                className={activeTab === 'analytics' ? 'active' : ''}
                onClick={() => setActiveTab('analytics')}
                style={{ cursor: 'pointer' }}
              >
                <i className="bi bi-graph-up me-2"></i>
                Analytics
              </NavLink>
            </NavItem>
          </Nav>
        </Container>
      </div>

      {/* Main Content Area */}
      <div className="flex-grow-1 overflow-hidden">
        {activeTab === 'chat' && <ChatInterface />}
        
        {activeTab === 'documents' && userContext.role === 'admin' && (
          <DocumentUpload />
        )}

        {activeTab === 'documents' && userContext.role !== 'admin' && (
          <Container className="mt-5">
            <Alert color="warning">
              <i className="bi bi-exclamation-triangle me-2"></i>
              <strong>Access Denied:</strong> Only administrators can upload documents.
            </Alert>
          </Container>
        )}

        {activeTab === 'analytics' && (
          <Container className="mt-4">
            <Card>
              <CardBody>
                <h4>
                  <i className="bi bi-graph-up me-2"></i>
                  Analytics Dashboard
                </h4>
                <p className="text-muted">
                  Analytics module coming soon...
                </p>
                <ul>
                  <li>Query statistics</li>
                  <li>Document usage metrics</li>
                  <li>User activity reports</li>
                  <li>Performance insights</li>
                </ul>
              </CardBody>
            </Card>
          </Container>
        )}
      </div>
    </div>
  );
}

export default App;