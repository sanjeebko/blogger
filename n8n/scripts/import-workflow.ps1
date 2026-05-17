# AI Agent Instructions for n8n Workflows

This document provides comprehensive guidelines for AI agents working with n8n workflows in the Blogger project.

## 1. Overview

### What are n8n Workflows?

n8n workflows are automation sequences defined in JSON format. They connect various services, APIs, and tools to automate tasks like:
- Publishing blog posts via the Blogger MCP server
- Generating content with AI models
- Scheduling automated tasks
- Processing webhooks and events

### How This Works

```
LOCAL WORKSPACE                n8n SERVER
┌──────────────┐              ┌──────────────┐
│ n8n/         │              │ n8n Instance │
│ workflows/   │─────sync────→│ (Running)    │
│ *.json files │←────sync─────│ Workflows    │
└──────────────┘              └──────────────┘
↓ git commit
┌──────────────┐
│ Version      │
│ Control      │
└──────────────┘
```

**Key Points:**
- Workflows are **edited** in local `n8n/workflows/` folder (JSON files)
- Changes are **synced** to n8n server for testing
- Git provides **version control** and change history
- n8n server is used for **development and testing** only

-- -

## 2. Folder Structure

### n8n/workflows/
JSON files containing complete workflow definitions exported from n8n.

**Naming**: Use kebab-case matching the workflow purpose:
- `blogger-auto-post.json` - Publishes blog posts automatically
- `content-generator.json` - Generates blog content with AI
- `mcp-test-workflow.json` - Tests MCP server connectivity

### n8n/metadata/
YAML files containing human-readable metadata for each workflow.

**Structure**:
```yaml
name: Workflow Display Name
description: What this workflow does
version: 1.0.0
author: Your Name
tags: [tag1, tag2]
dependencies: [required nodes]
credentials: [required credentials]
trigger: webhook | schedule | manual
notes: Additional context
```

### n8n/scripts/
PowerShell scripts for importing/exporting workflows to/from n8n server.

**Scripts**:
- `export-workflow.ps1` - Export from n8n server to local file
- `import-workflow.ps1` - Import from local file to n8n server
- `sync-all.ps1` - Batch sync all workflows

-- -

## 3. Working with n8n Workflows

### 3.1 Understanding Workflow JSON Structure

<function_calls>
<invoke name="create_file">
<parameter name="content"># n8n Workflow Import Script

param(
    [Parameter(Mandatory = $true)]
    [string]$File,
    
    [Parameter(Mandatory = $false)]
    [string]$N8nHost = $env:N8N_HOST,
    
    [Parameter(Mandatory = $false)]
    [string]$ApiKey = $env:N8N_API_KEY
)

# Validate inputs
if (-not $N8nHost) {
    Write-Error "N8N_HOST environment variable not set. Use -N8nHost parameter or set N8N_HOST env var."
    exit 1
}

if (-not $ApiKey) {
    Write-Error "N8N_API_KEY environment variable not set. Use -ApiKey parameter or set N8N_API_KEY env var."
    exit 1
}

if (-not (Test-Path $File)) {
    Write-Error "Workflow file not found: $File"
    exit 1
}

# Read workflow JSON
Write-Host "Reading workflow from: $File" -ForegroundColor Cyan
$workflowJson = Get-Content $File -Raw | ConvertFrom-Json

# Prepare API request
$apiUrl = "$N8nHost/api/v1/workflows"
$headers = @{
    "X-N8N-API-KEY" = $ApiKey
    "Content-Type"  = "application/json"
}

# Import workflow
Write-Host "Importing workflow to n8n server: $N8nHost" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Headers $headers -Body ($workflowJson | ConvertTo-Json -Depth 100)
    Write-Host "✅ Workflow imported successfully!" -ForegroundColor Green
    Write-Host "Workflow ID: $($response.id)" -ForegroundColor Green
    Write-Host "Workflow Name: $($response.name)" -ForegroundColor Green
    
    return $response
}
catch {
    Write-Error "Failed to import workflow: $_"
    Write-Error $_.Exception.Response
    exit 1
}
