# Blogger MCP Server - Project Status & Context

**Last Updated:** January 25, 2026, 23:45 UTC

---

## 🚨 CRITICAL FIX REQUIRED

**Root Cause Found**: Dockerfile.python was deploying WRONG Python file!

- **Was deploying**: `http_server_mcp.py` (MCP SDK with `/mcp` endpoint only)
- **Should deploy**: `http_server.py` (Flask with `/mcp-n8n` endpoint)
- **Impact**: Current K8s deployment doesn't have `/mcp-n8n` endpoint → n8n can't connect

**Fix Applied**: [Dockerfile.python](Dockerfile.python#L23-L37) updated to copy correct file

**Action Required** (perform these steps to fix the deployment):

1. **Rebuild Docker image** (from this workspace):

   ```powershell
   docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .
   ```

2. **Push to Docker Hub**:

   ```powershell
   docker push sanjeebojha/mcpserver-blogger:latest
   ```

3. **Deploy on K8s server** (manual - K8s is on separate machine):

   ```bash
   kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
   kubectl get pods -n prod -l app=mcpserver-blogger -w
   ```

4. **Verify fix**:
   ```powershell
   # Should return server info JSON (not 404)
   Invoke-WebRequest -Uri 'http://192.168.1.60/mcp-n8n' -Method GET
   ```

---

## Current Deployment Status

### ✅ COMPLETED

- **Docker Hub Image**: `sanjeebojha/mcpserver-blogger:latest` (Python version)
  - Digest: `sha256:54ecfba84674ec15056baba6aef272118d1d3455029a367dd4c5cc3a76a1befa`
  - Built with: Python 3.11-alpine, Flask, Google API Client
  - Successfully pushed to Docker Hub
- **Kubernetes Service**: Running in prod namespace
  - Service Name: `mcpserver-blogger-svc`
  - Type: LoadBalancer
  - External IP: `192.168.1.60`
  - Port: 80 → 8081 (container)
  - Deployment: `mcpserver-blogger-deployment`

- **n8n Workflows**: Updated with correct endpoint
  - Workflow ID `nBRYddJcbWqn4fEb`: "Blogger MCP - Create if missing" (v10)
  - Workflow ID `RPl6kytrnqkl7wlM`: "BlogGenerator" (v6)
  - Endpoint URL: `http://192.168.1.60/mcp-n8n`

### ⚠️ CRITICAL ISSUE IDENTIFIED

**Problem**: Dockerfile.python was copying the WRONG Python file!

- **Dockerfile Line 23**: `COPY src/http_server_mcp.py .` ❌
- **Should be**: `COPY src/http_server.py .` ✅

**Impact**:

- `http_server_mcp.py` uses MCP SDK streamable transport at `/mcp` (not `/mcp-n8n`)
- `http_server.py` has the custom Flask endpoint at `/mcp-n8n` for n8n compatibility
- Current Docker image has wrong file → wrong endpoint → n8n can't connect

**Fix Applied**: Updated [Dockerfile.python](Dockerfile.python) to copy correct file

**Next Steps** (user performs on K8s server):

1. Rebuild Docker image: `docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .`
2. Push to Docker Hub: `docker push sanjeebojha/mcpserver-blogger:latest`
3. Restart K8s deployment: `kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod`
4. Verify new pods: `kubectl get pods -n prod -l app=mcpserver-blogger -w`

**Note**: K8s server is on a separate machine with no kubectl access from this workspace. All K8s operations are performed manually by user.

---

## Problem History & Resolution

### Original Issue: 406 Not Acceptable Error

**Root Cause**: MCP SDK's `StreamableHTTPServerTransport` validates Accept header before Express middleware runs.

- n8n HTTP Request node cannot set `Accept: application/json, text/event-stream`
- SDK validation happens in `@hono/node-server` during `getRequestListener()`
- Middleware modifications occur too late in request lifecycle

**First Solution (TypeScript)**: Created `/mcp-n8n` endpoint in [src/index.ts](src/index.ts) (lines 490-770)

- Bypasses SDK transport layer completely
- Implements manual JSON-RPC protocol (initialize, tools/list, tools/call)
- All 11 tools duplicated from main handler
- Tested successfully locally

**Second Solution (Python)**: Rewrote as Python Flask server in [src/http_server.py](src/http_server.py)

- Lighter weight (Flask vs Express+Hono+MCP SDK)
- Better compatibility with n8n MCP Client
- Same `/mcp-n8n` endpoint logic
- Supports both GET (discovery) and POST (JSON-RPC)

---

## Available Implementations

### 1. TypeScript Version (Original)

**File**: [src/index.ts](src/index.ts)  
**Dockerfile**: [Dockerfile](Dockerfile)  
**Status**: Working locally, not deployed to K8s

**Key Components**:

- Lines 490-770: `/mcp-n8n` endpoint (n8n-compatible)
- Lines 580-700: `/mcp` endpoint (standard MCP with StreamableHTTPServerTransport)
- Uses: Express, @modelcontextprotocol/sdk@1.25.3, googleapis

**Docker Build**:

```bash
docker build -t sanjeebojha/mcpserver-blogger:typescript .
```

### 2. Python Version (Current Deployment)

**File**: [src/http_server.py](src/http_server.py) ⚠️ **Was incorrectly deploying http_server_mcp.py**  
**Dockerfile**: [Dockerfile.python](Dockerfile.python) ✅ **Fixed to copy http_server.py**  
**Status**: Dockerfile fixed, needs rebuild + push + K8s restart

**Key Components**:

- Flask app with `/mcp-n8n` endpoint
- Handles GET (discovery) and POST (JSON-RPC)
- Direct Google API client (no MCP SDK wrapper)
- Uses: Flask, google-api-python-client, mcp>=1.0.0

**Docker Build**:

```bash
docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .
```

---

## 🔍 Deployment Diagnostics

### How to Verify Which Version is Running

After rebuilding and redeploying, verify the correct file is running:

```powershell
# Test GET request (only http_server.py supports this)
Invoke-WebRequest -Uri 'http://192.168.1.60/mcp-n8n' -Method GET

# Expected response from http_server.py:
# {
#   "name": "blogger-mcp-server",
#   "version": "1.0.0",
#   "description": "Google Blogger MCP Server",
#   "endpoint": "/mcp-n8n",
#   "methods": ["GET", "POST"]
# }

# If you get 404 or error, http_server_mcp.py is running (wrong file)
```

### Two Python Implementations

| File                 | Transport          | Endpoint   | Purpose                               |
| -------------------- | ------------------ | ---------- | ------------------------------------- |
| `http_server.py`     | Flask custom       | `/mcp-n8n` | **PRODUCTION** - n8n compatible       |
| `http_server_mcp.py` | MCP SDK streamable | `/mcp`     | Alternative with proper MCP transport |

**Currently deployed**: Was `http_server_mcp.py` ❌ → Should be `http_server.py` ✅

---

## API Endpoints

### Production Endpoint (K8s LoadBalancer)

- **URL**: `http://192.168.1.60/mcp-n8n`
- **Port**: 80 (LoadBalancer) → 8081 (container)
- **Methods**: GET (discovery), POST (JSON-RPC)

### Local Testing (Docker Desktop)

- **URL**: `http://localhost:8082/mcp-n8n` (Python)
- **URL**: `http://localhost:8081/mcp-n8n` (TypeScript - if running)

### Health Check

- **URL**: `http://192.168.1.60/health`
- **Response**: `{"status": "ok", "service": "blogger-mcp-server"}`

---

## MCP Protocol Implementation

### Supported Methods

#### 1. `initialize`

**Request**:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "clientInfo": { "name": "n8n", "version": "2.0.3" },
    "capabilities": {}
  }
}
```

**Response**:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": { "tools": {}, "logging": {} },
    "serverInfo": { "name": "blogger-mcp-server", "version": "1.0.0" }
  }
}
```

**Headers**: Sets `mcp-session-id: <uuid>`

#### 2. `tools/list`

**Request**:

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list",
  "params": {}
}
```

**Response**: Returns array of 11 tools with full `inputSchema` definitions.

#### 3. `tools/call`

**Request**:

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "blogger_list_posts",
    "arguments": {
      "blogId": "1234567890",
      "status": ["LIVE"],
      "maxResults": 100,
      "fetchBodies": false
    }
  }
}
```

**Response**:

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "[{\"id\": \"...\", \"title\": \"...\"}]"
      }
    ]
  }
}
```

---

## Available Tools (11 Total)

| Tool Name                    | Description                      | Required Parameters          |
| ---------------------------- | -------------------------------- | ---------------------------- |
| `blogger_auth_get_url`       | Get OAuth2 authorization URL     | None                         |
| `blogger_auth_set_code`      | Complete authorization with code | `code`                       |
| `blogger_list_blogs`         | List all user's blogs            | None                         |
| `blogger_list_posts`         | List posts from a blog           | `blogId`                     |
| `blogger_get_post`           | Get specific post details        | `blogId`, `postId`           |
| `blogger_get_post_labels`    | Get post labels/tags             | `blogId`, `postId`           |
| `blogger_create_post`        | Create new post or draft         | `blogId`, `title`, `content` |
| `blogger_update_post`        | Update existing post             | `blogId`, `postId`           |
| `blogger_update_post_labels` | Update post labels               | `blogId`, `postId`, `labels` |
| `blogger_delete_post`        | Delete a post                    | `blogId`, `postId`           |
| `blogger_upload_image`       | Get image upload instructions    | None                         |

---

## n8n Workflows

### Workflow 1: "Blogger MCP - Create if missing"

**ID**: `nBRYddJcbWqn4fEb`  
**Version**: 10  
**Purpose**: Check if blog post exists by title, create if missing

**Flow**:

1. Manual Trigger
2. MCP Init → POST initialize → Get session ID
3. List Posts → POST tools/call (blogger_list_posts)
4. Check Exists → JavaScript function checks title
5. If Missing → Conditional check
6. Create Post → POST tools/call (blogger_create_post)

**Placeholders to Replace**:

- `BLOG_ID`: Your actual blog ID (get from blogger_list_blogs)
- `NEW_TITLE`: Title to check/create
- `NEW_CONTENT`: Content for new post

### Workflow 2: "BlogGenerator"

**ID**: `RPl6kytrnqkl7wlM`  
**Version**: 6  
**Purpose**: AI Agent generates unique programming blog topics

**Components**:

- **Manual Trigger**: Starts workflow
- **AI Agent**: Google Gemini with step-by-step instructions
- **MCP Client**: Connected to Blogger tools at `http://192.168.1.60/mcp-n8n`
- **Memory**: Simple buffer window (50 messages)

**AI Agent Prompt**:

```
STEP 1: Use blogger_list_blogs to get blog ID
STEP 2: Use blogger_list_posts (status=LIVE, maxResults=100)
STEP 3: Generate 2 NEW unique topics not in existing posts
```

---

## Authentication & Credentials

### OAuth2 Flow

1. **Credentials File**: `/app/credentials.json` (mounted from K8s secret)
   - Type: OAuth2 Desktop App credentials
   - From: Google Cloud Console → APIs & Services → Credentials
   - Format: `{"installed": {"client_id": "...", "client_secret": "...", ...}}`

2. **Token File**: `/app/token.json` (mounted from K8s secret)
   - Stores refresh token after first authorization
   - Auto-refreshes when expired
   - Initially empty `{}`

3. **First-Time Setup**:

   ```bash
   # Get authorization URL
   POST /mcp-n8n with {"method": "tools/call", "params": {"name": "blogger_auth_get_url"}}

   # Open URL in browser, get code, then:
   POST /mcp-n8n with {"method": "tools/call", "params": {"name": "blogger_auth_set_code", "arguments": {"code": "..."}}}
   ```

---

## Kubernetes Configuration

### Deployment Details

**Namespace**: `prod`  
**Deployment**: `mcpserver-blogger-deployment`  
**Service**: `mcpserver-blogger-svc` (LoadBalancer)  
**External IP**: `192.168.1.60:80`

### Environment Variables (in K8s deployment)

```yaml
env:
  - name: PORT
    value: "8081"
  - name: GOOGLE_APPLICATION_CREDENTIALS
    value: /app/credentials.json
  - name: BLOGGER_TOKEN_PATH
    value: /app/token.json

volumeMounts:
  - name: credentials
    mountPath: /app/credentials.json
    subPath: credentials.json
    readOnly: true
  - name: token
    mountPath: /app/token.json
    subPath: token.json
```

### Secrets (Reference)

Created via:

```bash
kubectl create secret generic blogger-credentials \
  --from-file=credentials.json=C:\Users\sanjeeb\blogger-credentials.json \
  -n prod

kubectl create secret generic blogger-token \
  --from-file=token.json=C:\Users\sanjeeb\blogger-token.json \
  -n prod
```

---

## Testing & Verification

### Test Initialize

```powershell
$body = @{jsonrpc='2.0'; id=1; method='initialize'; params=@{protocolVersion='2024-11-05'; clientInfo=@{name='test'; version='1.0'}; capabilities=@{}}} | ConvertTo-Json -Depth 10 -Compress
Invoke-WebRequest -Uri 'http://192.168.1.60/mcp-n8n' -Method POST -Body $body -ContentType 'application/json'
```

**Expected**: Status 200, `mcp-session-id` header

### Test Tools List

```powershell
$body = @{jsonrpc='2.0'; id=2; method='tools/list'; params=@{}} | ConvertTo-Json -Compress
$response = Invoke-WebRequest -Uri 'http://192.168.1.60/mcp-n8n' -Method POST -Body $body -ContentType 'application/json'
($response.Content | ConvertFrom-Json).result.tools | ForEach-Object { $_.name }
```

**Expected**: List of 11 tool names

### Test Tool Call (List Blogs)

```powershell
$body = @{jsonrpc='2.0'; id=3; method='tools/call'; params=@{name='blogger_list_blogs'; arguments=@{}}} | ConvertTo-Json -Depth 10 -Compress
Invoke-WebRequest -Uri 'http://192.168.1.60/mcp-n8n' -Method POST -Body $body -ContentType 'application/json'
```

**Expected**: JSON array of blogs

---

## Known Issues & Solutions

### Issue 1: "406 Not Acceptable" (TypeScript SDK)

**Symptom**: n8n HTTP Request node gets 406 error from `/mcp` endpoint  
**Cause**: SDK validates `Accept: application/json, text/event-stream` before middleware  
**Solution**: Use `/mcp-n8n` endpoint instead (bypasses SDK)

### Issue 2: "Could not connect to your MCP server" (n8n MCP Client)

**Symptom**: n8n AI Agent shows connection error  
**Causes**:

1. Wrong endpoint (used `:8081` instead of `:80` for LoadBalancer) ✅ FIXED
2. K8s deployment running old image without GET support ⚠️ **REQUIRES RESTART**
3. Network isolation (local Docker not reachable from cloud n8n) ✅ SOLVED (K8s deployment)

**Solution**:

```bash
kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
```

### Issue 3: 405 Method Not Allowed

**Symptom**: GET request to `/mcp-n8n` returns 405  
**Cause**: Endpoint only accepted POST  
**Solution**: Updated Python server to handle both GET and POST ✅ FIXED (needs K8s restart)

---

## Architecture Evolution

### Phase 1: TypeScript MCP Server (Initial)

- **Transport**: `StreamableHTTPServerTransport` from `@modelcontextprotocol/sdk`
- **Issue**: Strict Accept header validation incompatible with n8n
- **Endpoint**: `/mcp` (standard MCP protocol)
- **Status**: Working for Claude Desktop, not for n8n

### Phase 2: Custom TypeScript Endpoint

- **Added**: `/mcp-n8n` endpoint in [src/index.ts](src/index.ts) (lines 490-770)
- **Approach**: Manual JSON-RPC implementation bypassing SDK
- **Status**: Working locally, not tested in K8s

### Phase 3: Python Rewrite (Current)

- **File**: [src/http_server.py](src/http_server.py)
- **Framework**: Flask (simpler than Express+Hono)
- **Advantage**: No SDK transport layer, direct Google API calls
- **Status**: ✅ Built, pushed to Docker Hub, pending K8s restart

---

## Network Topology

```
n8n Server (n8n.saasa.co.uk - cloud)
    │
    │ HTTP
    ↓
192.168.1.60:80 (K8s LoadBalancer - mcpserver-blogger-svc)
    │
    │ Port mapping: 80 → 8081
    ↓
K8s Pod (mcpserver-blogger-deployment)
    │
    │ Container port: 8081
    ↓
Python Flask Server
    │
    ├─ GET /mcp-n8n → Server info (discovery)
    ├─ POST /mcp-n8n → JSON-RPC (initialize, tools/list, tools/call)
    └─ GET /health → Health check
```

**Local Network**: 192.168.1.xx  
**n8n Server**: n8n.saasa.co.uk (can access 192.168.1.60)  
**K8s Cluster**: On-premise at 192.168.1.x

---

## File Inventory

### Source Code

- **[src/index.ts](src/index.ts)** (1062 lines) - TypeScript MCP server with dual endpoints
- **[src/http_server.py](src/http_server.py)** (352 lines) - Python Flask server (current deployment)
- **[src/server.py](src/server.py)** (347 lines) - Python MCP SDK version (stdio mode only, not used)

### Docker

- **[Dockerfile](Dockerfile)** - TypeScript multi-stage build (Node.js 18-alpine)
- **[Dockerfile.python](Dockerfile.python)** - Python multi-stage build (Python 3.11-alpine)

### Configuration

- **[package.json](package.json)** - TypeScript dependencies
- **[requirements.txt](requirements.txt)** - Python dependencies
- **[tsconfig.json](tsconfig.json)** - TypeScript compiler config

### Kubernetes (Reference)

- **[k8s/deployment.yaml](k8s/deployment.yaml)** - K8s deployment manifest
- **[k8s/service.yaml](k8s/service.yaml)** - LoadBalancer service
- **[k8s/secret.yaml](k8s/secret.yaml)** - Secret creation template

### Documentation

- **[README.md](README.md)** - Setup instructions, OAuth2 flow, Docker Hub publishing
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - This file (project context)

---

## Next Session Quick Start

### If Starting Fresh:

1. **Read this file** for full context
2. **Check deployment**: User verifies K8s status on K8s server
3. **Verify endpoint**: `curl http://192.168.1.60/health`
4. **Check workflows**: Visit n8n.saasa.co.uk and test BlogGenerator workflow

**Note**: K8s operations (kubectl commands) must be performed manually by user on K8s server.

### If Debugging Issues:

1. **User checks pod logs** on K8s server: `kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=50`
2. **Test locally**: `docker run -p 8082:8081 -e PORT=8081 sanjeebojha/mcpserver-blogger:latest`
3. **Verify credentials**: User ensures blogger-credentials and blogger-token secrets exist in K8s

### If Making Changes:

1. **Edit source**: [src/http_server.py](src/http_server.py) (Python) or [src/index.ts](src/index.ts) (TypeScript)
2. **Build**: `docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .`
3. **Push**: `docker push sanjeebojha/mcpserver-blogger:latest`
4. **Deploy**: User manually restarts deployment on K8s server:
   ```bash
   kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
   ```

---

## Important Notes

### Why Two Implementations?

- **TypeScript**: Full MCP SDK support, better for Claude Desktop (stdio mode)
- **Python**: Simpler HTTP implementation, better n8n compatibility

### Why Custom `/mcp-n8n` Endpoint?

- Standard MCP transport validates Accept header strictly
- n8n HTTP Request node cannot set multiple Accept values
- Custom endpoint bypasses SDK validation entirely

### Why Python Version Created?

- User suspected JavaScript SDK was causing connection issues
- Python version confirmed the endpoint logic works (tested locally)
- Lighter weight with Flask vs Express+Hono+SDK

### Critical Path to Success:

1. ✅ Python server created with GET+POST support
2. ✅ Docker image pushed to Hub
3. ⚠️ **K8s deployment must restart** to pull new image
4. ⏳ Test n8n BlogGenerator workflow
5. ⏳ Replace placeholders in "Create if missing" workflow

---

## Environment Variables

| Variable                         | Default                 | Purpose                        |
| -------------------------------- | ----------------------- | ------------------------------ |
| `PORT`                           | -                       | HTTP server port (8081 in K8s) |
| `GOOGLE_APPLICATION_CREDENTIALS` | `/app/credentials.json` | OAuth2 credentials path        |
| `BLOGGER_TOKEN_PATH`             | `/app/token.json`       | Stored token path              |

---

## Contact & Ownership

- **Docker Hub**: `sanjeebojha/mcpserver-blogger`
- **n8n Instance**: `https://n8n.saasa.co.uk`
- **K8s Namespace**: `prod`
- **Owner**: sanjeeb ojha (sanjeebojha@gmail.com)

---

## Version History

| Date       | Version            | Changes                                                          |
| ---------- | ------------------ | ---------------------------------------------------------------- |
| 2026-01-25 | 1.0.0 (TypeScript) | Initial implementation with `/mcp` and `/mcp-n8n` endpoints      |
| 2026-01-25 | 1.0.0 (Python)     | Rewrote as Flask server, added GET support, pushed to Docker Hub |

---

**END OF STATUS DOCUMENT**
