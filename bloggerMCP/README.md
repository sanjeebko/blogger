# Blogger MCP Server

A Model Context Protocol (MCP) server that provides tools for managing Google Blogger content. Compatible with VS Code, Claude Desktop, n8n, and any MCP-compatible client.

## Features

- **11 Blogger Tools**: Complete blog management via Google Blogger API
- **OAuth2 Authentication**: Secure access using Google OAuth2
- **MCP Streamable HTTP Transport**: Standard protocol compatible with all MCP clients
- **Dockerized**: Ready for container deployment
- **Universal Client Support**: Works with any MCP client (VS Code, Claude Desktop, n8n, etc.)

## Architecture

- **Language**: Python 3.11
- **Framework**: MCP SDK with Streamable HTTP transport
- **API**: Google Blogger API v3
- **Endpoint**: `/mcp` (standard MCP protocol)
- **Health**: `/health` (monitoring)

---

## Quick Start

### 1. Build Docker Image

```bash
docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .
```

### 2. Run Server

```bash
docker run -p 8081:8081 \
  -v /path/to/credentials.json:/app/credentials.json:ro \
  -v /path/to/token.json:/app/token.json \
  -e PORT=8081 \
  sanjeebojha/mcpserver-blogger:latest
```

### 3. Configure MCP Client

**VS Code** (`.vscode/settings.json`):

```json
{
  "github.copilot.chat.mcpServers": {
    "blogger": {
      "type": "streamable-http",
      "url": "http://localhost:8081/mcp"
    }
  }
}
```

**Claude Desktop** (`%APPDATA%\Claude\claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "blogger": {
      "type": "streamable-http",
      "url": "http://localhost:8081/mcp"
    }
  }
}
```

**n8n** (MCP Client node):

- **URL**: `http://localhost:8081/mcp`
- **Transport**: Streamable HTTP

---

## Google Cloud Setup

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project → Enable **Blogger API v3**

### 2. Configure OAuth2 Consent Screen

1. **APIs & Services** → **OAuth consent screen**
2. Select **External** → Fill in app details
3. Add scope: `https://www.googleapis.com/auth/blogger`
4. Add your Gmail as test user

### 3. Create OAuth2 Credentials

1. **APIs & Services** → **Credentials** → **+ CREATE CREDENTIALS**
2. Select **OAuth client ID** → **Desktop app**
3. Download JSON → Save as `credentials.json`

### 4. Prepare Token File

```bash
echo '{}' > token.json
```

---

## Available Tools

| Tool                         | Description                             |
| ---------------------------- | --------------------------------------- |
| `blogger_auth_get_url`       | Get OAuth2 authorization URL            |
| `blogger_auth_set_code`      | Complete OAuth2 with authorization code |
| `blogger_list_blogs`         | List all blogs for authenticated user   |
| `blogger_list_posts`         | List posts from a blog with filters     |
| `blogger_get_post`           | Get specific post with full content     |
| `blogger_get_post_labels`    | Get tags/labels for a post              |
| `blogger_create_post`        | Create new post or draft                |
| `blogger_update_post`        | Update existing post                    |
| `blogger_update_post_labels` | Update post tags/labels                 |
| `blogger_delete_post`        | Permanently delete a post               |
| `blogger_upload_image`       | Get image upload instructions           |

---

## First-Time Authentication

1. Start server and connect with MCP client
2. Call `blogger_auth_get_url` tool → Open URL in browser
3. Sign in with Google → Copy authorization code
4. Call `blogger_auth_set_code` with the code
5. Token saved to `token.json` (auto-refreshes)

---

## Environment Variables

| Variable                         | Default                 | Purpose                 |
| -------------------------------- | ----------------------- | ----------------------- |
| `PORT`                           | `8081`                  | HTTP server port        |
| `GOOGLE_APPLICATION_CREDENTIALS` | `/app/credentials.json` | OAuth2 credentials path |
| `BLOGGER_TOKEN_PATH`             | `/app/token.json`       | Token storage path      |

---

## Deployment

### Docker Hub

```bash
docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .
docker push sanjeebojha/mcpserver-blogger:latest
```

### Kubernetes

Server is deployed at `http://192.168.1.60/mcp` (LoadBalancer service).

**Note**: K8s cluster is on a separate server. This workspace handles build/push only. K8s operations are performed manually on K8s server.

**After pushing new image**:

```bash
# Run on K8s server
kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
```

---

## Testing

```bash
# Health check
curl http://localhost:8081/health

# Test MCP protocol (initialize)
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","clientInfo":{"name":"test","version":"1.0"},"capabilities":{}}}'
```

---

## License

ISC
