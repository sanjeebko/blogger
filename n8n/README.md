# n8n Workflows for Blogger Project

This folder contains n8n workflow definitions that are version-controlled and synced to the n8n server for development and testing.

## Overview

**Purpose**: Store and manage n8n workflows that automate blog posting, content generation, and MCP server interactions.

**Sync Method**: Changes made here are synced to the n8n server (manually or via API) for development and testing.

## Folder Structure

```
n8n/
├── README.md                    (This file)
├── workflows/                   (n8n workflow JSON files)
│   ├── blogger-auto-post.json
│   ├── content-generator.json
│   ├── mcp-integration.json
│   └── ...
├── metadata/                    (Workflow metadata in YAML)
│   ├── blogger-auto-post.yaml
│   ├── content-generator.yaml
│   └── ...
└── scripts/                     (Import/export utilities)
    ├── export-workflow.ps1
    ├── import-workflow.ps1
    └── sync-all.ps1
```

## Workflow Naming Convention

- **File Format**: Kebab-case JSON (e.g., `blogger-auto-post.json`)
- **Workflow Name**: Title Case in n8n (e.g., "Blogger Auto Post")
- **IDs**: Use descriptive node IDs (e.g., `mcpClient1`, `httpRequest1`)

## Common Workflows

### 1. Blogger Auto Post

**File**: `blogger-auto-post.json`
**Purpose**: Automatically publish blog posts to Blogger using MCP server
**Trigger**: Webhook or schedule
**Nodes**: MCP Client → Blogger Tools → Response

### 2. Content Generator

**File**: `content-generator.json`
**Purpose**: Generate blog content using AI and save as HTML
**Trigger**: Manual or webhook
**Nodes**: AI Node → Format HTML → Save to File

### 3. MCP Integration Test

**File**: `mcp-integration.json`
**Purpose**: Test MCP server connectivity and tool availability
**Trigger**: Manual
**Nodes**: HTTP Request → MCP Client → Debug

## Development Workflow

### Creating a New Workflow

1. **Design in n8n UI** (http://your-n8n-server:5678)
2. **Test thoroughly** in n8n interface
3. **Export from n8n**:
   - Click "..." menu → Download
   - Or use export script: `.\scripts\export-workflow.ps1 -WorkflowId [ID]`
4. **Save to** `n8n/workflows/[workflow-name].json`
5. **Create metadata** in `n8n/metadata/[workflow-name].yaml`
6. **Commit to git** for version control

### Modifying an Existing Workflow

1. **Edit JSON file** in `n8n/workflows/[workflow-name].json`
   - Use VS Code for better JSON editing
   - Validate JSON syntax before saving
2. **Update metadata** if needed (description, tags, dependencies)
3. **Sync to n8n server**:
   - Option A: Use import script: `.\scripts\import-workflow.ps1 -File workflows\[name].json`
   - Option B: Manually import via n8n UI (Settings → Import from File)
4. **Test in n8n** to verify changes work
5. **Commit changes** to git

### Syncing Changes

**From Local to n8n Server:**

```powershell
# Single workflow
.\scripts\import-workflow.ps1 -File workflows\blogger-auto-post.json

# All workflows
.\scripts\sync-all.ps1 -Direction ToServer
```

**From n8n Server to Local:**

```powershell
# Single workflow
.\scripts\export-workflow.ps1 -WorkflowId 123

# All workflows
.\scripts\sync-all.ps1 -Direction FromServer
```

## Workflow JSON Structure

### Key Fields

```json
{
  "name": "Workflow Name",
  "nodes": [
    {
      "id": "unique-node-id",
      "name": "Node Display Name",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [x, y],
      "parameters": { /* node configuration */ }
    }
  ],
  "connections": {
    "NodeName1": {
      "main": [[{"node": "NodeName2", "type": "main", "index": 0}]]
    }
  },
  "settings": {
    "executionOrder": "v1"
  }
}
```

### Important Notes

- **Node IDs**: Must be unique within workflow
- **Node Names**: Must match connection references exactly
- **Type Versions**: Check n8n docs for current typeVersion
- **Position**: [x, y] coordinates for visual layout in n8n UI

## MCP Server Integration

### Connecting to Blogger MCP Server

**MCP Server URL**: `http://192.168.1.60/mcp-n8n` (production K8s)
**Local Testing**: `http://localhost:8082/mcp-n8n` (Docker)

#### Example: MCP Client Node Configuration

```json
{
  "id": "mcpClient1",
  "name": "Blogger MCP",
  "type": "@n8n/n8n-nodes-langchain.mcpClient",
  "parameters": {
    "serverUrl": "http://192.168.1.60/mcp-n8n",
    "serverType": "http"
  }
}
```

#### Example: Using MCP Tools

```json
{
  "id": "toolCall1",
  "name": "List Posts",
  "type": "@n8n/n8n-nodes-langchain.toolCall",
  "parameters": {
    "tool": "blogger_list_posts",
    "arguments": {
      "blogId": "={{ $json.blogId }}",
      "maxResults": 10
    }
  }
}
```

## Best Practices

### Version Control

- ✅ **Always commit** workflow changes to git
- ✅ **Use descriptive commit messages** (e.g., "Add error handling to blogger-auto-post")
- ✅ **Export from n8n** after testing changes
- ✅ **Keep metadata updated** with descriptions and dependencies

### Workflow Design

- ✅ **Use descriptive node names** (not "HTTP Request 1", "HTTP Request 2")
- ✅ **Add notes** to complex nodes explaining their purpose
- ✅ **Include error handling** (Error Trigger nodes, try-catch patterns)
- ✅ **Test with real data** before deploying to production
- ✅ **Document credentials** needed (in metadata, not in workflow JSON)

### Node Configuration

- ✅ **Use expressions** for dynamic values: `={{ $json.fieldName }}`
- ✅ **Validate inputs** before making API calls
- ✅ **Handle empty responses** gracefully
- ✅ **Log important data** for debugging
- ✅ **Use Set node** to transform data before passing to next node

### MCP Integration

- ✅ **Check server health** before calling tools
- ✅ **Handle MCP errors** (server unavailable, tool not found)
- ✅ **Use correct endpoint** (`/mcp-n8n` for production)
- ✅ **Test locally first** before deploying to production
- ✅ **Validate tool inputs** match MCP tool schema

## Common Node Types

### Trigger Nodes

- **Webhook**: For external integrations
- **Schedule**: For cron-based automation
- **Manual**: For testing and on-demand execution

### Data Processing

- **Set**: Transform and map data
- **Code**: JavaScript for complex logic
- **IF**: Conditional branching
- **Switch**: Multiple condition branching
- **Merge**: Combine data from multiple sources

### External Services

- **HTTP Request**: Generic API calls
- **MCP Client**: Connect to MCP servers (like Blogger MCP)
- **Google Sheets**: Data storage and retrieval
- **Email**: Send notifications

### AI & LLM

- **OpenAI**: GPT models for text generation
- **AI Agent**: Autonomous task execution
- **Tool Call**: Execute MCP tools

## Troubleshooting

### Workflow Import Fails

- **Check JSON syntax**: Use VS Code's JSON validator
- **Verify node types**: Ensure all node types are installed in n8n
- **Check typeVersion**: Update to compatible versions
- **Review connections**: Ensure node names match connection references

### MCP Server Connection Issues

- **Check endpoint**: Verify `/mcp-n8n` is accessible
- **Test with curl**: `curl http://192.168.1.60/mcp-n8n`
- **Verify MCP Client version**: Use latest n8n with MCP support
- **Check credentials**: Ensure MCP server has valid Blogger credentials

### Execution Errors

- **Check error logs** in n8n execution view
- **Validate data format** between nodes
- **Test expressions** in n8n expression editor
- **Review node parameters** for required fields

## Environment Variables

When workflows need configuration:

```yaml
# In workflow metadata YAML
environment:
  - N8N_MCP_SERVER_URL: "http://192.168.1.60/mcp-n8n"
  - BLOGGER_BLOG_ID: "your-blog-id"
  - BLOGGER_API_URL: "https://www.googleapis.com/blogger/v3"
```

## Scripts Usage

### Export Workflow from n8n

```powershell
.\scripts\export-workflow.ps1 -WorkflowId 123 -OutputFile workflows\my-workflow.json
```

### Import Workflow to n8n

```powershell
.\scripts\import-workflow.ps1 -File workflows\blogger-auto-post.json
```

### Sync All Workflows

```powershell
# Push all local workflows to n8n server
.\scripts\sync-all.ps1 -Direction ToServer

# Pull all workflows from n8n server to local
.\scripts\sync-all.ps1 -Direction FromServer
```

## Metadata Format

Each workflow should have a corresponding YAML metadata file:

```yaml
# metadata/blogger-auto-post.yaml
name: Blogger Auto Post
description: Automatically publish blog posts to Blogger platform using MCP server
version: 1.0.0
author: Sanjeeb Ojha
tags:
  - blogger
  - automation
  - mcp
dependencies:
  - MCP Client node (@n8n/n8n-nodes-langchain)
  - Blogger MCP Server (192.168.1.60)
credentials:
  - Blogger OAuth (configured in MCP server)
trigger: webhook
schedule: null
notes: |
  This workflow requires:
  1. MCP server running at http://192.168.1.60/mcp-n8n
  2. Valid Blogger credentials configured
  3. Webhook URL registered in calling application
```

## Git Workflow

### Committing Changes

```bash
git add n8n/workflows/my-workflow.json
git add n8n/metadata/my-workflow.yaml
git commit -m "feat(n8n): add blogger auto-post workflow"
git push
```

### Commit Message Conventions

- `feat(n8n):` - New workflow or major feature
- `fix(n8n):` - Bug fix in workflow
- `refactor(n8n):` - Workflow restructuring
- `docs(n8n):` - Documentation updates
- `chore(n8n):` - Maintenance tasks

---

## Next Steps

1. Create your first workflow in n8n UI
2. Export and save to `n8n/workflows/`
3. Create metadata file in `n8n/metadata/`
4. Test sync scripts
5. Commit to version control

For detailed workflow creation guidelines, see `.agent/n8n-workflow-guide.md`

---

_Version-controlled automation for your Blogger workflow._
