import React, { useState } from 'react';
import {
  Container,
  Row,
  Col,
  Card,
  CardBody,
  CardHeader,
  Form,
  FormGroup,
  Label,
  Input,
  Button,
  Alert,
  Progress,
  Badge,
} from 'reactstrap';
import { documentAPI } from '../services/api';
import { toast } from 'react-toastify';

export const DocumentUpload: React.FC = () => {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [application, setApplication] = useState<string>('eControls');
  const [uploading, setUploading] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [dragActive, setDragActive] = useState(false);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      setUploadStatus('idle');
    }
  };

  const handleDrag = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true);
    } else if (e.type === 'dragleave') {
      setDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    
    const file = e.dataTransfer.files?.[0];
    if (file) {
      setSelectedFile(file);
      setUploadStatus('idle');
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) return;

    setUploading(true);
    setUploadStatus('idle');

    try {
      const result = await documentAPI.uploadDocument(selectedFile, application, {
        uploaded_by: 'current_user',
        upload_date: new Date().toISOString(),
      });

      if (result.success) {
        setUploadStatus('success');
        toast.success('Document uploaded successfully!');
        setTimeout(() => {
          setSelectedFile(null);
          setUploadStatus('idle');
        }, 2000);
      } else {
        setUploadStatus('error');
        toast.error(result.error || 'Upload failed');
      }
    } catch (error: any) {
      setUploadStatus('error');
      toast.error(error.message || 'Upload failed');
    } finally {
      setUploading(false);
    }
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  const handleRemoveFile = () => {
    setSelectedFile(null);
    setUploadStatus('idle');
  };

  return (
    <Container className="mt-4">
      <Row>
        <Col lg={8} className="mx-auto">
          <Card>
            <CardHeader className="bg-primary text-white">
              <h4 className="mb-0">
                <i className="bi bi-cloud-upload me-2"></i>
                Document Upload (Admin Only)
              </h4>
            </CardHeader>
            <CardBody>
              <Form>
                {/* Application Selector */}
                <FormGroup>
                  <Label for="application-select">Select Application</Label>
                  <Input
                    type="select"
                    id="application-select"
                    value={application}
                    onChange={(e) => setApplication(e.target.value)}
                  >
                    <option value="eControls">eControls</option>
                    <option value="MyKRI">MyKRI</option>
                    <option value="General">General Documentation</option>
                  </Input>
                </FormGroup>

                {/* Drop Zone */}
                <div
                  onDragEnter={handleDrag}
                  onDragOver={handleDrag}
                  onDragLeave={handleDrag}
                  onDrop={handleDrop}
                  className={`border border-2 rounded p-5 text-center ${
                    dragActive
                      ? 'border-primary bg-light'
                      : selectedFile
                      ? 'border-success bg-light'
                      : 'border-dashed'
                  }`}
                  style={{
                    borderStyle: selectedFile ? 'solid' : 'dashed',
                    cursor: 'pointer',
                    transition: 'all 0.3s',
                  }}
                >
                  <Input
                    type="file"
                    id="file-input"
                    onChange={handleFileSelect}
                    className="d-none"
                    accept=".pdf,.doc,.docx,.txt,.md,.xlsx,.xls,.csv"
                  />

                  {!selectedFile ? (
                    <Label for="file-input" className="mb-0 w-100" style={{ cursor: 'pointer' }}>
                      <i className="bi bi-cloud-upload display-4 text-muted d-block mb-3"></i>
                      <h5 className="text-muted">Drag and drop a file here</h5>
                      <p className="text-muted">or click to select a file</p>
                      <Badge color="secondary">
                        Supported: PDF, Word, Text, Markdown, Excel, CSV
                      </Badge>
                    </Label>
                  ) : (
                    <div>
                      <i className="bi bi-file-earmark-check display-4 text-success d-block mb-3"></i>
                      <h5>{selectedFile.name}</h5>
                      <p className="text-muted">{formatFileSize(selectedFile.size)}</p>

                      {uploadStatus === 'success' && (
                        <Alert color="success" className="mt-3">
                          <i className="bi bi-check-circle me-2"></i>
                          Upload successful!
                        </Alert>
                      )}

                      {uploadStatus === 'error' && (
                        <Alert color="danger" className="mt-3">
                          <i className="bi bi-exclamation-triangle me-2"></i>
                          Upload failed. Please try again.
                        </Alert>
                      )}

                      {uploading && (
                        <div className="mt-3">
                          <Progress animated color="primary" value={100} />
                          <small className="text-muted">Uploading...</small>
                        </div>
                      )}

                      <div className="mt-3">
                        <Button
                          color="success"
                          onClick={handleUpload}
                          disabled={uploading || uploadStatus === 'success'}
                          className="me-2"
                        >
                          <i className="bi bi-upload me-2"></i>
                          {uploading ? 'Uploading...' : 'Upload Document'}
                        </Button>
                        <Button
                          color="secondary"
                          outline
                          onClick={handleRemoveFile}
                        >
                          <i className="bi bi-x-circle me-2"></i>
                          Remove
                        </Button>
                      </div>
                    </div>
                  )}
                </div>
              </Form>

              {/* Tips Section */}
              <Alert color="info" className="mt-4">
                <h6 className="alert-heading">
                  <i className="bi bi-info-circle me-2"></i>
                  Document Upload Tips
                </h6>
                <ul className="mb-0">
                  <li>Upload SOPs, user manuals, and process documents</li>
                  <li>Include control definitions and KRI reference guides</li>
                  <li>Add FAQs and troubleshooting guides</li>
                  <li>Documents are automatically indexed for quick retrieval</li>
                  <li>Maximum file size: 50MB</li>
                </ul>
              </Alert>
            </CardBody>
          </Card>

          {/* Recent Uploads */}
          <Card className="mt-4">
            <CardHeader>
              <h5 className="mb-0">
                <i className="bi bi-clock-history me-2"></i>
                Recent Uploads
              </h5>
            </CardHeader>
            <CardBody>
              <p className="text-muted">No recent uploads to display.</p>
            </CardBody>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};