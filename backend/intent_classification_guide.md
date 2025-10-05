# Intent Classification Guide

When asked to classify a user query, respond ONLY with valid JSON in this exact format:

{
  "application": "eControls|MyKRI|BOTH|RAG_ONLY",
  "intent": "READ|WRITE|DELETE|INFORMATION",
  "requires_confirmation": true|false,
  "entities": ["entity1", "entity2"],
  "reasoning": "brief explanation"
}

## Classification Rules:

### Application Detection:
- If query mentions "control", "review", "eControls" → application: "eControls"
- If query mentions "KRI", "indicator", "MyKRI", "risk" → application: "MyKRI"
- If query asks about processes, procedures, documentation → application: "RAG_ONLY"
- If query mentions both controls and KRIs → application: "BOTH"

### Intent Detection:
- Keywords "how many", "show", "list", "display", "what", "count" → intent: "READ"
- Keywords "enter", "insert", "add", "create", "update", "change", "set" → intent: "WRITE"
- Keywords "delete", "remove" → intent: "DELETE"
- Questions about processes, definitions, how-to → intent: "INFORMATION"

### Confirmation Required:
- If intent is WRITE or DELETE → requires_confirmation: true
- Otherwise → requires_confirmation: false

## Examples:

Query: "How many controls are pending?"
Response:
{
  "application": "eControls",
  "intent": "READ",
  "requires_confirmation": false,
  "entities": ["controls", "pending"],
  "reasoning": "User wants to count controls with pending status"
}

Query: "Enter KRI value 85 for KRI-2024-001"
Response:
{
  "application": "MyKRI",
  "intent": "WRITE",
  "requires_confirmation": true,
  "entities": ["KRI-2024-001", "85"],
  "reasoning": "User wants to insert a KRI value - requires confirmation"
}

Query: "What is the control review process?"
Response:
{
  "application": "RAG_ONLY",
  "intent": "INFORMATION",
  "requires_confirmation": false,
  "entities": ["control review process"],
  "reasoning": "User asking about documentation/procedures"
}