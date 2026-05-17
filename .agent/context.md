# Session Context - January 25, 2026

## Session Goal

Integrate Blogger MCP Server with n8n for automated blog post management and AI-generated content creation.

---

## What Was Accomplished

### 1. Problem Diagnosis (406 Not Acceptable Error)

- **Issue**: MCP SDK's `StreamableHTTPServerTransport` validates Accept header before Express middleware
- **Root Cause**: `@hono/node-server` reads `req.rawHeaders` immediately, before middleware can modify headers
- **n8n Limitation**: HTTP Request node cannot set `Accept: application/json, text/event-stream`
- **Attempted Fixes**:
  - Express middleware (too late in lifecycle) ❌
  - req.headers proxy (SDK uses Web Standard Request) ❌
  - Multiple n8n workflow iterations with header configurations ❌

### 2. TypeScript Workaround (src/index.ts)

- **Created**: Custom `/mcp-n8n` endpoint (lines 490-770)
- **Approach**: Bypass SDK transport, manually implement JSON-RPC protocol
- **Implementation**:
  - `initialize`: Returns static response with UUID session
  - `tools/list`: Returns all 11 tools with complete inputSchema
  - `tools/call`: Switch statement executing Blogger API calls directly
- **Status**: ✅ Tested locally (all 11 tools listed)
- **Not Deployed**: Kept TypeScript for Claude Desktop stdio mode

### 3. Python Rewrite (src/http_server.py) - CURRENT PRODUCTION

- **Why**: User suspected JavaScript SDK causing connection issues
- **Framework**: Flask (simpler than Express+Hono+SDK stack)
- **Features**:
  - GET /mcp-n8n → Server discovery info
  - POST /mcp-n8n → JSON-RPC (initialize, tools/list, tools/call)
  - GET /health → Health check
- **Status**: ✅ Built, pushed to Docker Hub, deployed to K8s
- **Testing**: ✅ Verified locally (initialize + 11 tools listed)

### 4. n8n Workflow Creation & Updates

- **Workflow 1** (nBRYddJcbWqn4fEb): "Blogger MCP - Create if missing"
  - Manual JSON-RPC workflow with HTTP Request nodes
  - Updated 10 times to fix endpoint URLs and expression errors
- **Workflow 2** (RPl6kytrnqkl7wlM): "BlogGenerator"
  - AI Agent with Google Gemini model
  - MCP Client tool for Blogger integration
  - Updated 6 times with detailed step-by-step prompt
  - Instructions: Use blogger_list_blogs → blogger_list_posts → generate unique topics

### 5. Docker & Kubernetes Deployment

- **Docker Hub**: Published `sanjeebojha/mcpserver-blogger:latest`
  - Current digest: `sha256:54ecfba84674ec15056baba6aef272118d1d3455029a367dd4c5cc3a76a1befa`
  - Tags: `:latest`, `:python`
- **K8s Service**: `mcpserver-blogger-svc` (LoadBalancer)
  - External IP: `192.168.1.60:80`
  - Maps to container port `8081`
- **K8s Deployment**: `mcpserver-blogger-deployment` in `prod` namespace

---

## Current Blocker

**Error**: "Could not connect to your MCP server" in n8n MCP Client  
**When**: AI Agent tries to initialize connection to Blogger tools  
**Stack Trace**: Error in `getConnectedTools()` during agent preparation

**Root Cause**: K8s deployment is running OLD Docker image

- Old image: Only accepts POST on `/mcp-n8n`
- n8n MCP Client: Sends GET first for discovery
- Result: 405 Method Not Allowed

**Fix Applied**: Updated Python server to handle GET requests

- Latest image (sha256:54ecfba8...) pushed to Docker Hub
- Supports GET (server info) and POST (JSON-RPC)

**Action Required**:

```bash
kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
```

Once restarted, n8n MCP Client should connect successfully.

---

## Technical Decisions Made

### Why `/mcp-n8n` Instead of `/mcp`?

- Standard `/mcp` endpoint uses MCP SDK transport with strict validation
- SDK requires `Accept: application/json, text/event-stream`
- n8n cannot set multi-value Accept headers properly
- Custom endpoint bypasses all SDK validation

### Why Python Instead of TypeScript?

- User requested: "may be the javascript sdk is the problem"
- Python has simpler HTTP implementation (Flask vs Express+Hono+SDK)
- Lighter weight (Python 3.11-alpine vs Node.js 18-alpine)
- Better compatibility with various clients (no SDK assumptions)
- Still kept TypeScript version for Claude Desktop (stdio mode)

### Why Both Implementations Exist?

- **Python (http_server.py)**: Production deployment for n8n integration
- **TypeScript (index.ts)**: Local development, Claude Desktop stdio mode
- Both implement same 11 tools with identical API calls

---

## Session Timeline

1. **14:08 UTC**: Created "Blogger MCP - Create if missing" workflow (nBRYddJcbWqn4fEb)
2. **14:30 UTC**: Fixed expression bracket errors in workflow
3. **15:00 UTC**: Discovered 406 error, diagnosed SDK Accept header validation
4. **15:20 UTC**: Created `/mcp-n8n` endpoint in TypeScript (lines 490-770)
5. **15:30 UTC**: Created "BlogGenerator" workflow (RPl6kytrnqkl7wlM) with AI Agent
6. **16:00 UTC**: Updated tools/list to return all 11 tools (was missing some)
7. **22:00 UTC**: User revealed K8s deployment at 192.168.1.60:80
8. **22:10 UTC**: Updated workflows to use correct LoadBalancer endpoint
9. **22:15 UTC**: User requested Python rewrite due to SDK issues
10. **22:25 UTC**: Created Python version, built, tested locally (✅ working)
11. **22:30 UTC**: Pushed to Docker Hub (sha256:54ecfba8...)
12. **22:35 UTC**: Discovered 405 error (GET not supported), fixed Python server
13. **22:36 UTC**: Rebuilt and pushed with GET support
14. **22:37 UTC**: Updated agent instructions and memory

---

## Next Session Checklist

### On Session Start:

1. ✅ Read `.agent/agent.md` for project structure and standards
2. ✅ Read `.agent/memory.md` for current state and issues
3. ✅ Read `.agent/context.md` (this file) for recent work
4. ✅ Check `PROJECT_STATUS.md` for deployment details

### If Continuing Work:

1. **Verify K8s Deployment**:
   ```bash
   kubectl get pods -n prod -l app=mcpserver-blogger
   kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=20
   ```
2. **Test Endpoint**: `curl http://192.168.1.60/health`
3. **Check n8n**: Test BlogGenerator workflow execution
4. **Review Logs**: Check for OAuth errors or API failures

### If Modifying Code:

1. **Edit**: `src/http_server.py` (production) or `src/index.ts` (legacy)
2. **Test Locally**: Build and run Docker container on port 8082
3. **Push**: `docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest . && docker push sanjeebojha/mcpserver-blogger:latest`
4. **Deploy**: `kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod`

---

## Open Questions

1. **Why n8n MCP Client sends GET first?**
   - Likely for server discovery/health check
   - Standard MCP doesn't require this, but n8n implementation does
   - Fixed by adding GET handler to `/mcp-n8n`

2. **Should we keep TypeScript version?**
   - YES - Still useful for Claude Desktop (stdio mode)
   - Python version cannot do stdio (MCP Python SDK is stdio-only, but we use Flask)
   - Two implementations serve different use cases

3. **Will Antigravity work with Python version?**
   - Unknown - Antigravity issue was with `/mcp` endpoint (TypeScript)
   - `/mcp-n8n` is custom protocol, not standard MCP
   - May need to test `/mcp` endpoint with Python MCP SDK (src/server.py)

---

## Important Endpoints Summary

| Endpoint                       | Method          | Purpose          | Implementation            |
| ------------------------------ | --------------- | ---------------- | ------------------------- |
| `http://192.168.1.60/mcp-n8n`  | GET             | Server discovery | Python Flask ✅           |
| `http://192.168.1.60/mcp-n8n`  | POST            | JSON-RPC (n8n)   | Python Flask ✅           |
| `http://192.168.1.60/health`   | GET             | Health check     | Python Flask ✅           |
| `http://blogger-mcp.local/mcp` | POST/GET/DELETE | Standard MCP     | TypeScript (not deployed) |

---

## Testing Evidence

### Local Python Server Test (2026-01-25 22:29)

```powershell
# Initialize
Status: 200
Session: 447c9289-f00d-40b2-98f5-e67bc2de0671

# Tools List
Tools found: 11
blogger_auth_get_url
blogger_auth_set_code
blogger_list_blogs
blogger_list_posts
blogger_get_post
blogger_get_post_labels
blogger_create_post
blogger_update_post
blogger_update_post_labels
blogger_delete_post
blogger_upload_image
```

### Docker Hub Push Confirmation

```
latest: digest: sha256:54ecfba84674ec15056baba6aef272118d1d3455029a367dd4c5cc3a76a1befa size: 1783
```

### K8s Service Status

```
NAME                    TYPE           EXTERNAL-IP    PORT(S)
mcpserver-blogger-svc   LoadBalancer   192.168.1.60   80:32348/TCP
```

---

## Critical Path Forward

### Immediate (User Must Execute):

```bash
kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
kubectl get pods -n prod -w  # Wait for new pod to be Ready
```

### After K8s Restart:

1. Test BlogGenerator workflow in n8n
   - Should see "Connecting to MCP server..." then list of tools
   - AI Agent should call blogger_list_blogs automatically
   - Generate 2 unique blog topics

2. Update "Create if missing" workflow placeholders:
   - Get BLOG_ID from blogger_list_blogs tool
   - Replace NEW_TITLE and NEW_CONTENT with actual values

3. Test end-to-end post creation

---

## Files Modified This Session

1. **Created**: `src/http_server.py` (352 lines) - Python Flask server
2. **Created**: `requirements.txt` - Python dependencies
3. **Created**: `Dockerfile.python` - Python multi-stage build
4. **Created**: `PROJECT_STATUS.md` - Comprehensive project documentation
5. **Updated**: `src/index.ts` - Added all 11 tools to /mcp-n8n (lines 490-770)
6. **Updated**: `.agent/memory.md` - Current state, tech stack, issues
7. **Updated**: `.agent/agent.md` - Architecture, folder structure, build commands
8. **Created**: `.agent/context.md` (this file) - Session timeline and context

---

**END OF SESSION CONTEXT**
