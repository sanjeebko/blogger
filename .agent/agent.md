# AI Agent Instructions for Blogger Workspace

This document serves as the long-term memory and instruction manual for AI agents working on the Blogger workspace. It outlines the architecture, coding standards, and key constraints for both the MCP server and blog pages.

## 1. Project Overview

This workspace contains two main projects:

### 1.1 Blogger MCP Server (`bloggerMCP/`)

**Blogger MCP Server** is a Model Context Protocol (MCP) server that provides tools for interacting with the Google Blogger platform. It allows AI models to read, write, and manage blog posts and comments via the Blogger API.

#### Key Features (Planned)

- **Posts & Drafts**: List, fetch, create, and update blog posts (including drafts).
- **Tags**: specific management of post labels (tags).
- **Images**: Upload functionality (via Google Photos/Drive integration) and metadata retrieval.
- **Dockerized Deployment**: Containerized for distribution.

### 1.2 Blog Pages (`blogs/`)

**Static HTML blog pages** organized by category (computer, health, other) containing educational and informational content.

#### Structure

- `blogs/index.html`: Main landing page with category navigation
- `blogs/computer/`: Technology-related articles (Angular, .NET, Hardware, etc.)
- `blogs/health/`: Health and wellness articles
- `blogs/other/`: Miscellaneous content

#### Key Characteristics

- **Static HTML**: No build process, pure HTML/CSS/JavaScript
- **Organized by Number**: Each article in numbered folders (1/, 2/, 3/, etc.)
- **Consistent Structure**: Each article has:
  - `index.html` or `{topic}.html`: Main content file
  - `title.txt`: Article title (optional)
  - `assets/`: Images and supporting files (optional)
  - `image-prompts-table.md`: AI image generation prompts (optional)
- **Series Support**: Complex topics split into sub-articles (e.g., `17/1/`, `17/2/`)

---

## 2. Architecture

### 2.1 Blogger MCP Server Architecture

**Primary Stack**: Python 3.11 + Flask (production deployment)  
**Legacy Stack**: TypeScript + Node.js (local development only)

#### Python Implementation (Current Production)

- **Server**: Flask HTTP server with custom `/mcp-n8n` endpoint
- **File**: `src/http_server.py`
- **Blogger API**: Uses `google-api-python-client` for authentication and data access
- **Auth**: OAuth2 Desktop App credentials (personal Gmail)
- **Distribution**: Docker Image (`sanjeebojha/mcpserver-blogger:latest`)
- **Deployment**: Kubernetes LoadBalancer at `192.168.1.60:80`

#### 🚨 CRITICAL DEPLOYMENT CONSTRAINT

**Kubernetes server is on a SEPARATE machine with NO kubectl access from this workspace.**

- **NEVER run kubectl commands** from this project
- User manually deploys and restarts pods on the K8s server
- This project only handles:
  - Building Docker images locally
  - Pushing to Docker Hub
- Deployment steps (manual restart, logs, etc.) are done by user on K8s server

#### TypeScript Implementation (Legacy)

- **Server**: Express with `@modelcontextprotocol/sdk`
- **File**: `src/index.ts`
- **Status**: Not deployed, local testing only
- **Issue**: SDK's StreamableHTTPServerTransport has strict Accept header validation incompatible with n8n

### 2.2 Blog Pages Architecture

**Static HTML** with no build process or framework dependencies.

#### Design Patterns

- **Responsive Design**: Mobile-first approach with CSS media queries
- **Modern CSS**: Uses CSS Grid, Flexbox, and custom properties
- **Minimal JavaScript**: Progressive enhancement, no framework dependencies
- **Accessibility**: Semantic HTML, ARIA labels where needed
- **Visual Effects**: Optional libraries like vanta.js for backgrounds

#### Styling Approach

- **Inline Styles**: Some pages use style tags in head
- **External CSS**: Shared styles when applicable
- **Consistency**: Similar layout patterns across articles
- **Dark/Light Themes**: Some pages implement theme switching

---

## 3. Folder Structure

### 3.1 Root: `blogger/`

- **`bloggerMCP/`**: MCP server project (see below)
- **`blogs/`**: Static blog pages (see below)
- `README.md`: Workspace documentation
- `SETUP-TOKEN-LOCAL.ps1`: OAuth token setup script
- `plan.md`, `plan_improvement.md`, `angular17_series_plan.md`: Planning documents

### 3.2 MCP Server: `bloggerMCP/`

- `src/`: Source code.
  - **`http_server.py`**: Python Flask server with custom `/mcp-n8n` endpoint (PRODUCTION - deployed to K8s)
  - **`http_server_mcp.py`**: Python MCP SDK server with streamable HTTP transport at `/mcp` (alternative implementation)
  - **`index.ts`**: TypeScript server (LEGACY - local only)
  - `server.py`: Python MCP SDK stdio server (experimental, not used)
  - `test_mcp_client.ts`: Test client
- `build/`: Compiled JavaScript (TypeScript output).
- **`Dockerfile.python`**: Python container definition (CURRENT DEPLOYMENT)
- **`Dockerfile`**: TypeScript container definition (legacy)
- `requirements.txt`: Python dependencies
- `package.json`: TypeScript dependencies and scripts.
- `tsconfig.json`: TypeScript configuration.
- `k8s/`: Kubernetes manifests (deployment.yaml, service.yaml, secret.yaml)
- `README.md`: MCP server documentation
- `PROJECT_STATUS.md`: Project status and progress

### 3.3 Blog Pages: `blogs/`

- `index.html`: Main landing page
- **`computer/`**: Technology articles
  - `1/csharp14.html`: C# 14 features
  - `2/dotnet9.html`: .NET 9 overview
  - `3/diagnosing-net-container-crashes.html`: Container debugging
  - `10/dotnet10.html`: .NET 10 preview
  - `11/angular17.html`: Angular 17 overview
  - `15/angular-dotnet-fullstack.html`: Full-stack development
  - `17/`: Angular 17 series (multiple sub-articles)
    - `1/mastering-signals.html`
    - `2/control-flow.html`
    - `3/deferrable-views.html`
    - `4/hydration-ssr.html`
  - Hardware series: GPU, CPU, RAM, Internet, OS, etc.
- **`health/`**: Health and wellness articles
  - `10/weight-loss-diet-plans.html`
  - `11/exercise-routines-workouts.html`
  - `12/healthy-eating-nutrition.html`
  - `13/mental-health-stress-reduction.html`
  - `14/sleep-improvement.html`
  - `15/specific-health-conditions.html`
  - `16/supplements-vitamins.html`
  - `17/body-pain-management.html`
  - `18/heart-health.html`
  - `19/hydration.html`
  - `20/intermittent-fasting-guide.html`
- **`other/`**: Miscellaneous content

## 4. Coding Standards

### 4.1 MCP Server (Python - Production)

- **PEP 8**: Follow Python style guide
- **Type Hints**: Use where applicable (Python 3.11+)
- **Async/Await**: Not required for Flask (synchronous)
- **Error Handling**: Try-except blocks for all API calls, return JSON-RPC error format
- **Logging**: Use Python logging module (INFO level)

### 4.2 MCP Server (TypeScript - Legacy)

- **Strict Mode**: Enabled in `tsconfig.json`.
- **Async/Await**: Use for all asynchronous operations.
- **Types**: Explicit typing for function parameters and return values. Avoid `any`.
- **Error Handling**: Wrap API calls in try-catch blocks and return meaningful errors to the client.

### 4.3 MCP Tools

- **Naming**: blogger_snake_case for tool names (e.g., `blogger_list_posts`, `blogger_create_post`).
- **Descriptions**: Detailed descriptions for each tool so the LLM knows when to use it.
- **Input Schemas**: JSON Schema format with proper types, descriptions, and required fields.

### 4.4 Blog Pages (HTML/CSS/JavaScript)

#### HTML Standards

- **Semantic HTML5**: Use appropriate tags (`<article>`, `<section>`, `<nav>`, `<header>`, `<footer>`)
- **Accessibility**: Include alt text, ARIA labels, proper heading hierarchy
- **Meta Tags**: Include viewport, description, charset in all pages
- **Consistency**: Maintain similar structure across articles

#### CSS Standards

- **Mobile-First**: Design for mobile, enhance for desktop
- **Modern CSS**: Use Grid, Flexbox, CSS custom properties (variables)
- **Responsiveness**: Media queries at common breakpoints (768px, 1024px)
- **Naming**: Use descriptive class names, avoid inline styles when possible
- **Colors**: Use consistent color schemes, support dark mode where applicable

#### JavaScript Standards

- **Progressive Enhancement**: Pages should work without JavaScript
- **No Dependencies**: Avoid heavy frameworks, use vanilla JS when possible
- **External Libraries**: Only when needed (e.g., vanta.js for visual effects)
- **Performance**: Defer or async script loading when appropriate

#### Content Guidelines

- **Template**: Use `blogs/computer/template.html` for all new computer articles
- **Writing Guide**: Follow `.agent/blog-writing-guide.md` for detailed specifications
- **Generation Prompt**: Reference `.agent/blog-generation-prompt.md` for workflow
- **Length**: 2,000-2,500 words (10-minute read)
- **Detail Level**: Comprehensive with 4-6 code examples minimum
- **Style**: Simple, professional language targeting developers and students
- **Purpose**: Help readers solve problems, understand topics, learn new features
- **Structure**: Must include: Introduction with info box, main sections, real-world example, troubleshooting, best practices, conclusion
- **Code Examples**: Complete, runnable, with syntax highlighting (use CSS classes)
- **Visual Elements**: Include comparison tables, info boxes (tip/warning/example), feature grids
- **Images**: Banner image in assets folder, document prompts in image-prompts-table.md

---

## 5. Development Environment & Verification

### 5.1 MCP Server - Python Build Commands (CURRENT)

- **Install**: `pip install -r requirements.txt`
- **Run Locally**: `python src/http_server.py` (requires PORT env var)
- **Docker Build**: `docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .`
- **Docker Push**: `docker push sanjeebojha/mcpserver-blogger:latest`
- **Test Locally**:
  ```powershell
  docker run -d -p 8082:8081 -e PORT=8081 \
    -v "C:\Users\sanjeeb\blogger-credentials.json:/app/credentials.json:ro" \
    -v "C:\Users\sanjeeb\blogger-token.json:/app/token.json" \
    sanjeebojha/mcpserver-blogger:latest
  ```

### 5.2 MCP Server - TypeScript Build Commands (LEGACY)

- **Install**: `npm install`
- **Build**: `npm run build`
- **Watch**: `npm run watch` (for development)
- **Run**: `node build/index.js` (stdio mode)
- **Docker Build**: `docker build -t blogger-mcp .`

### 5.3 MCP Server - Verification

- **Test Initialize** (local Docker):
  ```powershell
  $body = @{jsonrpc='2.0'; id=1; method='initialize'; params=@{protocolVersion='2024-11-05'; clientInfo=@{name='test'; version='1.0'}; capabilities=@{}}} | ConvertTo-Json -Depth 10 -Compress
  Invoke-WebRequest -Uri 'http://localhost:8082/mcp-n8n' -Method POST -Body $body -ContentType 'application/json'
  ```
- **Test Tools List** (local Docker):
  ```powershell
  $body = @{jsonrpc='2.0'; id=2; method='tools/list'; params=@{}} | ConvertTo-Json -Compress
  Invoke-WebRequest -Uri 'http://localhost:8082/mcp-n8n' -Method POST -Body $body -ContentType 'application/json'
  ```
- **Test Production** (after user deploys):
  ```powershell
  Invoke-WebRequest -Uri 'http://192.168.1.60/mcp-n8n' -Method GET  # Should return server info
  ```

**Note**: Kubernetes deployment and pod management is done manually by user on K8s server (no kubectl access from this workspace)

### 5.4 Blog Pages - Development Workflow

#### Creating New Articles

1. **Determine Category**: Choose `computer/`, `health/`, or `other/`
2. **Create Numbered Folder**: Find next available number in category
3. **Create HTML File**: Name appropriately (e.g., `topic-name.html`)
4. **Create `title.txt`**: Add article title (optional but recommended)
5. **Add Assets**: Create `assets/` folder for images if needed
6. **Update Index**: Add link in `blogs/index.html` if appropriate

#### Testing Changes

- **Local Preview**: Open HTML files directly in browser
- **Live Server**: Use VS Code Live Server extension for auto-reload
- **Responsive Testing**: Test at multiple screen sizes
- **Cross-Browser**: Verify in Chrome, Firefox, Safari, Edge
- **Accessibility**: Use browser dev tools to check ARIA and semantic HTML

#### Content Updates

- **Edit Existing**: Modify HTML files directly
- **Add Images**: Place in `assets/` folder, reference with relative paths
- **Update Styling**: Modify inline styles or add external CSS
- **Add Scripts**: Include at bottom of body or in head with defer/async

---

## 6. Common Tasks

### 6.1 MCP Server Tasks

#### Adding New Blogger API Tool

1. Define tool schema in appropriate section of `http_server.py`
2. Implement handler function with try-except error handling
3. Add route to JSON-RPC dispatcher
4. Test locally with PowerShell verification commands
5. Build Docker image: `docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .`
6. Push to Docker Hub: `docker push sanjeebojha/mcpserver-blogger:latest`
7. Notify user to restart K8s pod (no kubectl from this workspace)

#### Debugging MCP Server

1. Check logs in Docker container: `docker logs <container-id>`
2. Test individual endpoints with curl or Invoke-WebRequest
3. Verify Blogger API credentials and token
4. Check Flask app is listening on correct port
5. Test JSON-RPC message format

### 6.2 Blog Pages Tasks

#### Creating Article Series

1. Create parent folder with number (e.g., `17/`)
2. Create `index.html` in parent folder with series overview
3. Create sub-folders for each part (`1/`, `2/`, `3/`)
4. Each sub-folder gets its own HTML file and `title.txt`
5. Link between articles with navigation (Previous/Next)

#### Adding Images

1. Create or use existing `assets/` folder in article directory
2. Optimize images (compress, resize for web)
3. Use descriptive filenames (e.g., `angular-signals-diagram.png`)
4. Reference with relative paths: `<img src="assets/image.png" alt="description">`
5. Consider creating `image-prompts-table.md` for AI-generated images

#### Updating Main Index

1. Open `blogs/index.html`
2. Find appropriate category section
3. Add new article link with title and brief description
4. Maintain chronological or logical ordering
5. Test navigation works correctly

---

## 7. Blog Post Generation System

### Files and Resources

When generating blog posts, use these resources in order:

1. **Template**: `blogs/computer/template.html` - Base HTML structure for all articles
2. **Master Prompt**: `.agent/MASTER-BLOG-PROMPT.md` - Complete generation instructions
3. **Writing Guide**: `.agent/blog-writing-guide.md` - Detailed specifications and standards
4. **Quick Reference**: `.agent/blog-quick-reference.md` - Checklist and quick tips
5. **Quality Examples**: `.agent/example-comparison.md` - Bad vs Good examples
6. **Image Template**: `blogs/computer/template-image-prompts.md` - Image generation guide

### Quick Start for Blog Generation

1. Copy `template.html` to `blogs/computer/[NUMBER]/[topic].html`
2. Create `assets/` folder in same directory
3. Create `title.txt` with article title
4. Follow MASTER-BLOG-PROMPT.md workflow
5. Ensure 2,000-2,500 words with 4-6 code examples
6. Add syntax highlighting to all code
7. Include comparison table, info boxes, feature grid
8. Verify quality checklist before finishing

## 8. n8n Workflow Management

### Overview

n8n workflows for automation are version-controlled in `n8n/` folder. These workflows connect AI content generation, MCP server integration, and blog publishing.

### Workflow System

- **Local Editing**: Edit workflow JSON files in `n8n/workflows/`
- **Testing**: Sync to n8n server for execution testing
- **Version Control**: Git tracks all workflow changes
- **Metadata**: YAML files in `n8n/metadata/` document each workflow

### Key Files

- **Workflows**: `n8n/workflows/*.json` - Workflow definitions
- **Metadata**: `n8n/metadata/*.yaml` - Documentation per workflow
- **Scripts**: `n8n/scripts/*.ps1` - PowerShell sync utilities
- **Documentation**: `n8n/README.md` - Complete workflow guide
- **Agent Guide**: `.agent/n8n-workflow-guide.md` - Editing instructions for AI agents

### Sync Workflow

```powershell
# Import local workflow to n8n server
.\n8n\scripts\import-workflow.ps1 -File n8n\workflows\my-workflow.json

# Export workflow from n8n server to local
.\n8n\scripts\export-workflow.ps1 -WorkflowId 123

# Sync all workflows
.\n8n\scripts\sync-all.ps1 -Direction ToServer  # Local → Server
.\n8n\scripts\sync-all.ps1 -Direction FromServer  # Server → Local
```

### MCP Integration in Workflows

Workflows connect to Blogger MCP Server:

- **Production**: `http://192.168.1.60/mcp-n8n`
- **Local**: `http://localhost:8082/mcp-n8n`
- **Node Type**: `@n8n/n8n-nodes-langchain.mcpClient`

### Development Cycle

1. **Edit** workflow JSON locally in VS Code
2. **Validate** JSON syntax and structure
3. **Import** to n8n using sync script
4. **Test** execution in n8n UI
5. **Iterate** if needed
6. **Commit** to git when working

### Agent Responsibilities

When modifying n8n workflows:

- ✅ **Follow** `.agent/n8n-workflow-guide.md` for detailed instructions
- ✅ **Validate** JSON structure before sync
- ✅ **Update** metadata YAML if workflow changes significantly
- ✅ **Test** after importing to n8n
- ✅ **Document** changes in git commit messages
- ❌ **Never** hardcode credentials in workflow JSON

---

## 9. Memory Management

- **Read**: `.agent/memory.md` at session start.
- **Write**: Update `memory.md` with new architectural decisions, API quirks, or important context.
- **Location**: Root `.agent/` folder (previously in `bloggerMCP/.agent/`)

---

## 10. Key Constraints & Reminders

### MCP Server

- ❌ **NEVER run kubectl commands** - K8s server is on different machine
- ✅ **Only build and push Docker images** - User deploys manually
- ✅ **Use Flask `/mcp-n8n` endpoint** for production (not MCP SDK StreamableHTTPServerTransport)
- ✅ **Test locally with Docker** before pushing to production

### Blog Pages

- ✅ **Keep it simple** - No build process, no frameworks
- ✅ **Maintain consistency** - Similar structure across articles
- ✅ **Mobile-first** - Design for mobile, enhance for desktop
- ✅ **Accessibility matters** - Semantic HTML, ARIA labels, alt text
- ✅ **Numbered folders** - Continue sequential numbering in each category

### n8n Workflows

- ❌ **Never** hardcode credentials in workflow JSON files
- ❌ **Never** modify workflows directly on n8n server without exporting
- ✅ **Always** validate JSON before importing to n8n
- ✅ **Always** export workflows after editing in n8n UI
- ✅ **Always** commit both JSON and YAML files together
- ✅ **Use sync scripts** for all import/export operations

---

## 11. File Locations Quick Reference

| Item                     | Location                              |
| ------------------------ | ------------------------------------- |
| MCP Server Python        | `bloggerMCP/src/http_server.py`       |
| MCP Server Dockerfile    | `bloggerMCP/Dockerfile.python`        |
| MCP Server Python Deps   | `bloggerMCP/requirements.txt`         |
| Blog Landing Page        | `blogs/index.html`                    |
| Computer Articles        | `blogs/computer/{number}/`            |
| Health Articles          | `blogs/health/{number}/`              |
| **Blog Template**        | `blogs/computer/template.html`        |
| **Blog Master Prompt**   | `.agent/MASTER-BLOG-PROMPT.md`        |
| **Blog Writing Guide**   | `.agent/blog-writing-guide.md`        |
| **Blog Quick Reference** | `.agent/blog-quick-reference.md`      |
| **Blog Examples**        | `.agent/example-comparison.md`        |
| **n8n Workflows**        | `n8n/workflows/*.json`                |
| **n8n Metadata**         | `n8n/metadata/*.yaml`                 |
| **n8n Sync Scripts**     | `n8n/scripts/*.ps1`                   |
| **n8n Documentation**    | `n8n/README.md`                       |
| **n8n Agent Guide**      | `.agent/n8n-workflow-guide.md`        |
| Agent Instructions       | `.agent/agent.md` (this file)         |
| Agent Memory             | `.agent/memory.md`                    |
| Planning Docs            | `plan.md`, `angular17_series_plan.md` |

---

_Last Updated: January 26, 2026_
