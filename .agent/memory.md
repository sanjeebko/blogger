# Blogger MCP Server - Project Memory

This document stores application-specific and domain-specific knowledge for the Blogger MCP Server project.

## 1. Project Context

**Blogger MCP Server** allows AI agents to manage Blogger content on behalf of a user.

- **Protocol**: Model Context Protocol (MCP).
- **Transport**: Streamable HTTP (SSE was removed on 2026-01-24).

## 2. Tech Stack

- **Language**: Python (primary), TypeScript (legacy).
- **Runtime**: Python 3.11 (Flask), Node.js 18 (legacy).
- **Infrastructure**: Docker (Python 3.11-alpine), Kubernetes.
- **Libraries**:
  - **Python**: `flask`, `google-api-python-client`, `google-auth-oauthlib`, `mcp>=1.0.0`
  - **TypeScript (legacy)**: `@modelcontextprotocol/sdk`, `googleapis`, `express`, `zod`

## 3. Current State (as of 2026-01-25 23:17 UTC)

- **Status**: ✅ Deployed on K8s (Python version) - **VERIFIED LATEST**
- **Docker Hub**: `sanjeebojha/mcpserver-blogger:latest` (digest: sha256:54ecfba84674ec15056baba6aef272118d1d3455029a367dd4c5cc3a76a1befa)
- **K8s Service**: LoadBalancer at `192.168.1.60:80` → container `8081`
- **Endpoint**: `http://192.168.1.60/mcp-n8n` (custom endpoint for n8n compatibility)
- **Verification (2026-01-25 23:17 UTC)**:
  - ✅ GET /mcp-n8n returns server info (Python 3.11.14, Werkzeug/3.1.5)
  - ✅ POST initialize returns session ID successfully
  - ✅ POST tools/list returns all 11 tools
  - ✅ Server version: 1.0.0
  - ✅ Protocol version: 2024-11-05
- **n8n Integration**:
  - Workflow `nBRYddJcbWqn4fEb`: "Blogger MCP - Create if missing" (v10)
  - Workflow `RPl6kytrnqkl7wlM`: "BlogGenerator" (v6) with AI Agent
- **Pending Tasks**:
  - Test BlogGenerator workflow with AI Agent
  - Replace placeholders (BLOG_ID, NEW_TITLE, NEW_CONTENT) in workflow nBRYddJcbWqn4fEb
  - Troubleshoot Antigravity MCP connection issue

## 4. Key Decisions

- **Python Rewrite (2026-01-25)**: Migrated from TypeScript to Python Flask server due to:
  - n8n MCP Client compatibility issues with JavaScript MCP SDK
  - TypeScript SDK's `StreamableHTTPServerTransport` has strict Accept header validation
  - n8n HTTP Request node cannot send `Accept: application/json, text/event-stream`
  - Python version simpler, lighter, more compatible
- **Custom `/mcp-n8n` Endpoint**: Created to bypass SDK Accept header validation
  - Manually implements JSON-RPC protocol (initialize, tools/list, tools/call)
  - Supports both GET (discovery) and POST (JSON-RPC)
  - No session validation (single-user private deployment)
- **Image Handling**: Blogger API v3 doesn't natively support direct image uploads to a blog. Implementation will likely require Google Drive or Google Photos API integration to host images and embed links, OR finding a workaround via the Google Media Upload protocol if supported.
- **Drafts**: Handled via the `status` field ('LIVE', 'DRAFT', 'SCHEDULED') in Post resources.
- **Tags**: Handled via the `labels` array in Post resources.
- **OAuth2 vs Service Account**: Using OAuth2 Desktop App credentials for personal Gmail access (not Service Account)

## 5. Environment & Auth

- **Credentials**: Google Cloud Service Account or OAuth2.
- **Scopes**:
  - `https://www.googleapis.com/auth/blogger`
  - (Potential) `https://www.googleapis.com/auth/drive.file` (if Drive is used for images).

## 6. Known Issues / Quirks

- **406 Not Acceptable Error (SOLVED - 2026-01-25)**:
  - MCP SDK validates Accept header in `@hono/node-server` before middleware
  - n8n cannot set multi-value Accept header properly
  - Solution: Created `/mcp-n8n` endpoint bypassing SDK entirely
- **n8n MCP Client Connection Error (RESOLVED - 2026-01-25 23:17 UTC)**:
  - Error: "Could not connect to your MCP server"
  - Cause 1: Wrong endpoint port (8081 vs 80 for LoadBalancer) ✅ FIXED
  - Cause 2: Python server only had POST, n8n sends GET first ✅ FIXED (added GET handler)
  - Cause 3: K8s deployment running old image ✅ **RESOLVED** (latest image deployed and verified)
  - **Status**: Latest Python version with GET+POST support is deployed and functional
- **TypeScript vs Python**:
  - TypeScript has full MCP SDK but Accept header validation too strict
  - Python simpler but MCP SDK stdio-only (uses Flask for HTTP instead)
  - Both implement same 11 tools via `/mcp-n8n`
- **Root Endpoint Fixed (2026-01-25)**: Added `GET /` route that returns server information JSON instead of "Cannot GET /" error.
- **Antigravity MCP Issue (2026-01-25)**: Antigravity cannot connect to the Blogger MCP server despite:
  - Config file at `c:\Users\sanjeeb\.gemini\antigravity\mcp_config.json` is correct.
  - Server is reachable and responding correctly on all endpoints (`/`, `/health`, `/mcp`).
  - Multiple Antigravity restarts attempted.
  - Tried with and without explicit `"transport": "streamable-http"`.
  - **Possible cause**: Antigravity may not fully support `streamable-http` transport yet, or requires specific configuration.

## 7. Infrastructure & Deployment

- **Hosting**: Kubernetes (K8s) Cluster on-premise at 192.168.1.x
- **Network Layout**: Flat network; all K8s pods, laptops, and mobiles share the same network.
- **Access**:
  - **LoadBalancer IP**: `192.168.1.60:80` (External)
  - **Service**: `mcpserver-blogger-svc` (K8s LoadBalancer)
  - **Deployment**: `mcpserver-blogger-deployment` in namespace `prod`
  - **Container Port**: `8081`
  - **Domain**: `blogger-mcp.local` (mapped in Windows hosts file - may not be active)
- **Endpoints**:
  - `/mcp-n8n` - Custom JSON-RPC endpoint for n8n (GET + POST)
  - `/mcp` - Standard MCP StreamableHTTP (TypeScript version only)
  - `/health` - Health check
- **Docker Hub**: `sanjeebojha/mcpserver-blogger:latest` (Python version)
  - Also tagged: `sanjeebojha/mcpserver-blogger:python`
  - Previous TypeScript version available as `:typescript` tag (if needed)

## 8. n8n Integration

- **n8n Instance**: `https://n8n.saasa.co.uk` (cloud hosted, v2.0.3)
- **n8n-mcp Plugin**: v2.22.17 (outdated, latest is v2.33.5)
- **Workflows Created**:
  1. **"Blogger MCP - Create if missing"** (ID: nBRYddJcbWqn4fEb, v10)
     - Flow: Initialize → List Posts → Check Exists → Create if Missing
     - Uses HTTP Request nodes with manual JSON-RPC
     - Placeholders: BLOG_ID, NEW_TITLE, NEW_CONTENT
  2. **"BlogGenerator"** (ID: RPl6kytrnqkl7wlM, v6)
     - AI Agent (Google Gemini) with MCP Client tool
     - Generates 2 unique programming blog topics
     - Uses blogger_list_blogs → blogger_list_posts → generate topics
- **Connection**: n8n on 192.168.1.xx network, can reach K8s LoadBalancer at 192.168.1.60

## 8. n8n Integration

- **n8n Instance**: `https://n8n.saasa.co.uk` (cloud hosted, v2.0.3)
- **n8n-mcp Plugin**: v2.22.17 (outdated, latest is v2.33.5)
- **Workflows Created**:
  1. **"Blogger MCP - Create if missing"** (ID: nBRYddJcbWqn4fEb, v10)
     - Flow: Initialize → List Posts → Check Exists → Create if Missing
     - Uses HTTP Request nodes with manual JSON-RPC
     - Placeholders: BLOG_ID, NEW_TITLE, NEW_CONTENT
  2. **"BlogGenerator"** (ID: RPl6kytrnqkl7wlM, v6)
     - AI Agent (Google Gemini) with MCP Client tool
     - Generates 2 unique programming blog topics
     - Uses blogger_list_blogs → blogger_list_posts → generate topics
- **Connection**: n8n on 192.168.1.xx network, can reach K8s LoadBalancer at 192.168.1.60

## 9. Antigravity MCP Config

**Location**: `c:\Users\sanjeeb\.gemini\antigravity\mcp_config.json`

```json
{
  "mcpServers": {
    "blogger": {
      "url": "http://blogger-mcp.local/mcp"
    }
  }
}
```
