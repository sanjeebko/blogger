# AI Agent Instructions for n8n Workflows

This document provides comprehensive guidelines for AI agents working with n8n workflows in the Blogger project.

## 1. Overview

### Purpose

The `n8n/` folder contains version-controlled workflow automation definitions that:

- Automate blog posting via Blogger MCP server
- Generate and process content with AI
- Integrate various services and APIs
- Schedule automated tasks

### Workflow Lifecycle

```
1. CREATE/MODIFY in n8n UI OR edit JSON locally
2. EXPORT to n8n/workflows/*.json
3. COMMIT to git for version control
4. SYNC to n8n server for testing
5. TEST in n8n execution view
6. DEPLOY (activate) when ready
```

---

## 2. Folder Structure

```
n8n/
├── README.md                      (Overview and quick start)
├── workflows/                     (Workflow JSON files)
│   ├── blogger-auto-post.json
│   ├── content-generator.json
│   └── mcp-integration.json
├── metadata/                      (Workflow metadata YAML)
│   ├── blogger-auto-post.yaml
│   ├── content-generator.yaml
│   └── mcp-integration.yaml
└── scripts/                       (Sync utilities)
    ├── export-workflow.ps1       (Export from n8n to local)
    ├── import-workflow.ps1       (Import from local to n8n)
    └── sync-all.ps1              (Batch sync operations)
```

---

## 3. Workflow JSON Structure

### Complete Workflow Schema

```json
{
  "name": "Workflow Display Name",
  "nodes": [
    {
      "id": "unique-node-id",
      "name": "Node Display Name",
      "type": "n8n-nodes-base.nodeType",
      "typeVersion": 1,
      "position": [x, y],
      "parameters": {
        "/* node-specific config */"
      },
      "credentials": {
        "credentialType": {
          "id": "credential-id",
          "name": "Credential Name"
        }
      }
    }
  ],
  "connections": {
    "NodeName1": {
      "main": [
        [
          {
            "node": "NodeName2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1"
  },
  "pinData": {},
  "tags": []
}
```

### Critical Fields

- **name**: Workflow display name (Title Case)
- **nodes**: Array of all workflow nodes
- **connections**: Defines flow between nodes (uses node **names**, not IDs)
- **settings**: Workflow-level configuration
- **pinData**: Test data pinned to nodes (optional, usually omit)
- **tags**: Categorization tags (optional)

---

## 4. Node Structure

### Required Node Fields

Every node must have:

```json
{
  "id": "uniqueId123", // Unique within workflow
  "name": "Descriptive Name", // Used in connections
  "type": "n8n-nodes-base.type", // Node type identifier
  "typeVersion": 1, // Node version
  "position": [250, 300], // [x, y] canvas position
  "parameters": {} // Node configuration
}
```

### Common Node Types

#### HTTP Request

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.example.com/endpoint",
    "authentication": "genericCredentialType",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [{ "name": "Content-Type", "value": "application/json" }]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [{ "name": "key", "value": "={{ $json.value }}" }]
    }
  }
}
```

#### MCP Client (for Blogger MCP Server)

```json
{
  "type": "@n8n/n8n-nodes-langchain.mcpClient",
  "parameters": {
    "serverUrl": "http://192.168.1.60/mcp-n8n",
    "serverType": "http"
  }
}
```

#### Set (Data Transformation)

```json
{
  "type": "n8n-nodes-base.set",
  "parameters": {
    "mode": "manual",
    "duplicateItem": false,
    "assignments": {
      "assignments": [
        {
          "id": "field1",
          "name": "outputField",
          "value": "={{ $json.inputField }}",
          "type": "string"
        }
      ]
    }
  }
}
```

#### Code (JavaScript)

```json
{
  "type": "n8n-nodes-base.code",
  "parameters": {
    "mode": "runOnceForAllItems",
    "jsCode": "// Your JavaScript code\nreturn items.map(item => {\n  return {json: {processed: true}};\n});"
  }
}
```

---

## 5. Connections Structure

### Basic Connection

```json
"connections": {
  "Start": {
    "main": [
      [
        {"node": "HTTP Request", "type": "main", "index": 0}
      ]
    ]
  },
  "HTTP Request": {
    "main": [
      [
        {"node": "Process Data", "type": "main", "index": 0}
      ]
    ]
  }
}
```

### Multiple Outputs

```json
"connections": {
  "IF Node": {
    "main": [
      [
        {"node": "True Branch", "type": "main", "index": 0}
      ],
      [
        {"node": "False Branch", "type": "main", "index": 0}
      ]
    ]
  }
}
```

### Important Rules

- Connection keys use **node names** (not IDs)
- `"main"` is the output type (always use "main" for standard flow)
- Array structure: `[[{connections}]]` - double array is required
- `"index": 0` is the output index (0-based)

---

## 6. Editing Workflows

### Safe Editing Practices

1. **Always validate JSON** before saving
2. **Keep node names consistent** with connections
3. **Increment positions** when adding nodes (avoid overlap)
4. **Test in n8n** after importing changes
5. **Backup before major changes** (git commit first)

### Common Modifications

#### Adding a New Node

```json
// 1. Add to nodes array
{
  "id": "newNode1",
  "name": "New Processing Step",
  "type": "n8n-nodes-base.set",
  "typeVersion": 1,
  "position": [450, 300],  // Position after existing nodes
  "parameters": {
    // ... configuration
  }
}

// 2. Update connections
"Previous Node": {
  "main": [[
    {"node": "New Processing Step", "type": "main", "index": 0}
  ]]
},
"New Processing Step": {
  "main": [[
    {"node": "Next Node", "type": "main", "index": 0}
  ]]
}
```

#### Modifying Node Parameters

```json
// Find the node by id or name
{
  "id": "httpRequest1",
  "name": "Call API",
  "parameters": {
    "url": "NEW_URL", // ← Modify this
    "method": "POST" // ← Or this
  }
}
```

#### Changing Node Connections

```json
// Before: A → B → C
"A": {"main": [[{"node": "B"}]]},
"B": {"main": [[{"node": "C"}]]}

// After: A → C (skip B)
"A": {"main": [[{"node": "C"}]]}
// Remove B's connection
```

---

## 7. MCP Server Integration in Workflows

### Connecting to Blogger MCP Server

#### Production Endpoint

- URL: `http://192.168.1.60/mcp-n8n`
- Type: HTTP
- No authentication needed (internal network)

#### Local Testing Endpoint

- URL: `http://localhost:8082/mcp-n8n`
- Type: HTTP
- Requires Docker container running

### Example: List Blog Posts via MCP

```json
{
  "nodes": [
    {
      "id": "mcpClient1",
      "name": "Blogger MCP",
      "type": "@n8n/n8n-nodes-langchain.mcpClient",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": {
        "serverUrl": "http://192.168.1.60/mcp-n8n",
        "serverType": "http"
      }
    },
    {
      "id": "listPosts1",
      "name": "List Blog Posts",
      "type": "@n8n/n8n-nodes-langchain.toolCall",
      "typeVersion": 1,
      "position": [450, 300],
      "parameters": {
        "tool": "blogger_list_posts",
        "arguments": {
          "blogId": "your-blog-id",
          "maxResults": 10,
          "status": "live"
        }
      }
    }
  ],
  "connections": {
    "Blogger MCP": {
      "main": [[{ "node": "List Blog Posts", "type": "main", "index": 0 }]]
    }
  }
}
```

### Available MCP Tools

Check MCP server tools by calling `tools/list`:

- `blogger_list_posts` - List blog posts
- `blogger_get_post` - Get specific post
- `blogger_create_post` - Create new post
- `blogger_update_post` - Update existing post
- (More tools as implemented in MCP server)

---

## 8. Testing & Validation

### Before Importing to n8n

1. **Validate JSON syntax** in VS Code (should show no errors)
2. **Check node references** in connections match node names exactly
3. **Verify node types** are available in your n8n instance
4. **Review parameters** for required fields

### After Importing to n8n

1. **Open workflow** in n8n UI
2. **Check visual layout** - nodes should be properly positioned
3. **Verify connections** - lines should connect correctly
4. **Test execution** with sample data
5. **Check error handling** - test failure scenarios
6. **Review output** - ensure data flows correctly

### Validation Checklist

```
✓ JSON is valid (no syntax errors)
✓ All node IDs are unique
✓ All connection references match existing node names
✓ Node positions don't overlap
✓ Required parameters are filled
✓ Expressions use correct syntax: ={{ $json.field }}
✓ No hardcoded secrets (use credentials or env vars)
✓ Error handling nodes included
✓ Test data removed (no pinData in production)
```

---

## 9. Common Workflows for Blogger Project

### Workflow 1: Blogger Auto Post

**Purpose**: Publish blog HTML to Blogger platform
**Trigger**: Webhook with blog data
**Flow**:

1. Webhook Trigger → Receive blog HTML and metadata
2. MCP Client → Connect to Blogger MCP server
3. Tool Call → blogger_create_post or blogger_update_post
4. Response → Return post URL and ID

### Workflow 2: Content Generator

**Purpose**: Generate blog content using AI
**Trigger**: Manual or webhook with topic
**Flow**:

1. Trigger → Receive topic and requirements
2. AI Agent → Generate blog post following template
3. Set Node → Format as HTML
4. Code Node → Add syntax highlighting
5. Save to file or webhook response

### Workflow 3: MCP Health Check

**Purpose**: Monitor MCP server availability
**Trigger**: Schedule (every 5 minutes)
**Flow**:

1. Schedule Trigger → Run periodically
2. HTTP Request → GET /mcp-n8n (health check)
3. IF Node → Check if response is OK
4. Email/Slack → Send alert if down

---

## 10. Best Practices

### Workflow Design

✅ **DO:**

- Use descriptive node names ("Fetch User Data" not "HTTP Request 1")
- Add notes to complex nodes explaining logic
- Include error handling (Error Trigger nodes)
- Group related nodes visually
- Use sticky notes for documentation in UI
- Keep workflows focused (one purpose per workflow)

❌ **DON'T:**

- Hardcode credentials or API keys
- Create overly complex workflows (split into multiple)
- Skip error handling
- Use generic node names
- Forget to document in metadata YAML

### Expression Syntax

n8n uses expressions with `={{ }}`:

```javascript
// Access input data
={{ $json.fieldName }}

// Access previous node data
={{ $node["Node Name"].json.field }}

// JavaScript functions
={{ $json.price * 1.1 }}
={{ $json.name.toUpperCase() }}

// Conditionals
={{ $json.status === 'active' ? 'Yes' : 'No' }}

// Array operations
={{ $json.items.map(i => i.name).join(', ') }}
```

### Error Handling

Always include error handling:

```json
{
  "nodes": [
    {
      "type": "n8n-nodes-base.errorTrigger",
      "name": "On Error",
      "parameters": {}
    },
    {
      "type": "n8n-nodes-base.code",
      "name": "Log Error",
      "parameters": {
        "jsCode": "console.error('Workflow error:', $input.all());\nreturn $input.all();"
      }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "name": "Send Alert",
      "parameters": {
        "url": "https://your-alert-webhook"
      }
    }
  ]
}
```

### Credentials Management

**NEVER** store credentials in workflow JSON:

❌ **BAD:**

```json
"parameters": {
  "apiKey": "sk-actual-key-here"  // ← NEVER DO THIS
}
```

✅ **GOOD:**

```json
"credentials": {
  "openAiApi": {
    "id": "credential-id",
    "name": "OpenAI API"
  }
}
```

Or use environment variables:

```json
"parameters": {
  "apiKey": "={{ $env.OPENAI_API_KEY }}"
}
```

---

## 11. Sync Workflow

### Environment Setup

Set these before using sync scripts:

```powershell
$env:N8N_HOST = "http://your-n8n-server:5678"
$env:N8N_API_KEY = "your-api-key"
```

### Import Local Workflow to n8n Server

```powershell
# Single workflow
.\n8n\scripts\import-workflow.ps1 -File n8n\workflows\blogger-auto-post.json

# All workflows
.\n8n\scripts\sync-all.ps1 -Direction ToServer
```

### Export from n8n Server to Local

```powershell
# Single workflow (by ID)
.\n8n\scripts\export-workflow.ps1 -WorkflowId 123

# All workflows
.\n8n\scripts\sync-all.ps1 -Direction FromServer
```

### Development Workflow

```
1. EDIT locally: n8n/workflows/my-workflow.json
2. VALIDATE: Check JSON syntax in VS Code
3. IMPORT: Run import-workflow.ps1
4. TEST: Execute in n8n UI
5. ITERATE: Make adjustments if needed
6. COMMIT: Git commit when working
```

---

## 12. Creating Workflows from Scratch

### Option 1: Create in n8n UI (Recommended for Complex Workflows)

1. Open n8n at `http://your-n8n-server:5678`
2. Create new workflow
3. Add and configure nodes
4. Connect nodes
5. Test execution
6. Download JSON (... menu → Download)
7. Save to `n8n/workflows/`
8. Create metadata YAML
9. Commit to git

### Option 2: Create JSON Manually (For Simple Workflows)

1. Copy `n8n/templates/workflow-template.json` (if exists)
2. Edit in VS Code
3. Add nodes array
4. Define connections
5. Validate JSON
6. Import to n8n
7. Test and adjust

### Minimal Workflow Example

```json
{
  "name": "Simple HTTP Request",
  "nodes": [
    {
      "id": "start",
      "name": "When clicking 'Test workflow'",
      "type": "n8n-nodes-base.manualTrigger",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": {}
    },
    {
      "id": "http1",
      "name": "Fetch Data",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [450, 300],
      "parameters": {
        "method": "GET",
        "url": "https://api.example.com/data"
      }
    }
  ],
  "connections": {
    "When clicking 'Test workflow'": {
      "main": [[{ "node": "Fetch Data", "type": "main", "index": 0 }]]
    }
  },
  "settings": {
    "executionOrder": "v1"
  }
}
```

---

## 13. Metadata Files

### Purpose

Metadata YAML files provide human-readable documentation for each workflow.

### Template

```yaml
# metadata/my-workflow.yaml
name: Workflow Display Name
description: >
  Detailed description of what this workflow does,
  why it exists, and how it fits into the system.
version: 1.0.0
author: Your Name
created: 2026-01-26
updated: 2026-01-26

tags:
  - automation
  - blogger
  - mcp

dependencies:
  nodes:
    - "@n8n/n8n-nodes-langchain.mcpClient"
    - "n8n-nodes-base.httpRequest"
  services:
    - Blogger MCP Server (http://192.168.1.60/mcp-n8n)
  credentials:
    - Blogger OAuth (configured in MCP server)

trigger:
  type: webhook
  path: /webhook/blog-post
  method: POST

inputs:
  - name: blogContent
    type: string
    required: true
    description: HTML content of the blog post
  - name: title
    type: string
    required: true
    description: Blog post title

outputs:
  - name: postUrl
    type: string
    description: URL of the published blog post
  - name: postId
    type: string
    description: Blogger post ID

notes: |
  Additional notes about the workflow:
  - Requires MCP server to be running
  - Expects HTML content formatted with template
  - Automatically adds tags based on content analysis
  - Sends notification on success/failure
```

---

## 14. Troubleshooting

### Common Issues

#### Issue 1: Workflow Import Fails

**Symptom**: Error when running import-workflow.ps1
**Causes**:

- Invalid JSON syntax
- Missing required node types in n8n
- API key incorrect
  **Solution**:
- Validate JSON in VS Code
- Check n8n has required node packages installed
- Verify N8N_API_KEY environment variable

#### Issue 2: MCP Client Can't Connect

**Symptom**: "Could not connect to your MCP server"
**Causes**:

- MCP server not running
- Wrong endpoint URL
- Network connectivity issue
  **Solution**:
- Test endpoint: `curl http://192.168.1.60/mcp-n8n`
- Verify MCP server pod is running (ask user to check K8s)
- Use local endpoint for testing: `http://localhost:8082/mcp-n8n`

#### Issue 3: Node Connections Don't Work

**Symptom**: Workflow doesn't execute as expected
**Cause**: Node names in connections don't match actual node names
**Solution**:

- Check connections use exact node names (case-sensitive)
- Verify connection structure: `{"main": [[{...}]]}`

#### Issue 4: Expressions Not Evaluating

**Symptom**: `={{ }}` shown literally in output
**Causes**:

- Expression syntax error
- Field doesn't exist in data
  **Solution**:
- Use n8n expression editor to test
- Check input data structure
- Use `$json.field` for current item, `$node["Name"].json.field` for other nodes

---

## 15. Git Workflow

### Committing Changes

```bash
# Add workflow and metadata
git add n8n/workflows/my-workflow.json
git add n8n/metadata/my-workflow.yaml

# Commit with descriptive message
git commit -m "feat(n8n): add blogger auto-post workflow

- Integrates with Blogger MCP server
- Handles HTML content formatting
- Includes error notification
- Tested with sample blog post"

git push
```

### Commit Message Format

```
<type>(n8n): <subject>

<body>

<footer>
```

**Types:**

- `feat(n8n):` - New workflow or major feature
- `fix(n8n):` - Bug fix in workflow
- `refactor(n8n):` - Workflow restructuring
- `docs(n8n):` - Documentation only
- `chore(n8n):` - Maintenance, scripts

---

## 16. Agent Tasks for n8n Workflows

### Task: Create New Workflow

1. Understand the automation requirement
2. Design workflow nodes and connections
3. Create JSON structure following templates
4. Add proper error handling
5. Create metadata YAML file
6. Save both files
7. Provide import instructions to user

### Task: Modify Existing Workflow

1. Read current workflow JSON
2. Understand current structure and flow
3. Make targeted modifications (add/remove/update nodes)
4. Update connections if needed
5. Validate JSON structure
6. Update metadata if description/dependencies changed
7. Provide sync instructions to user

### Task: Debug Workflow Issues

1. Read workflow JSON
2. Check for common issues:
   - Invalid JSON syntax
   - Mismatched node names in connections
   - Missing required parameters
   - Incorrect expression syntax
3. Suggest fixes
4. Update workflow if requested

---

## 17. Quick Reference

### File Locations

- Workflows: `n8n/workflows/*.json`
- Metadata: `n8n/metadata/*.yaml`
- Scripts: `n8n/scripts/*.ps1`
- Documentation: `n8n/README.md`

### Common Commands

```powershell
# Import workflow to n8n
.\n8n\scripts\import-workflow.ps1 -File n8n\workflows\my-workflow.json

# Export workflow from n8n
.\n8n\scripts\export-workflow.ps1 -WorkflowId 123

# Sync all to server
.\n8n\scripts\sync-all.ps1 -Direction ToServer

# Sync all from server
.\n8n\scripts\sync-all.ps1 -Direction FromServer
```

### MCP Integration

- Production URL: `http://192.168.1.60/mcp-n8n`
- Local URL: `http://localhost:8082/mcp-n8n`
- Node Type: `@n8n/n8n-nodes-langchain.mcpClient`

---

## 18. Constraints & Reminders

### Critical Rules

- ❌ **NEVER** commit API keys or credentials to git
- ❌ **NEVER** modify workflows directly on n8n server without exporting
- ✅ **ALWAYS** export workflows after testing in n8n UI
- ✅ **ALWAYS** validate JSON before importing
- ✅ **ALWAYS** test workflows after importing changes
- ✅ **ALWAYS** create metadata YAML for new workflows
- ✅ **ALWAYS** commit both JSON and YAML files together

### Sync Direction

- **ToServer**: Push local changes to n8n (for testing modifications)
- **FromServer**: Pull n8n changes to local (after UI editing)

### Testing Environment

- Use **local n8n** or **development n8n instance** for testing
- Verify on **production n8n** only after thorough testing
- MCP server endpoint may differ between environments

---

_Follow these guidelines when working with n8n workflows to ensure consistency, reliability, and proper version control._
