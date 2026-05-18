# Copilot Instructions for Blogger Workspace

## Project Overview

This workspace manages a blog system with two main components:
- **Blogger MCP Server** (`bloggerMCP/`): Python 3.11, Dockerized, exposes tools for Google Blogger management via the Model Context Protocol (MCP). Entry: `server.py`. See `bloggerMCP/README.md` for Docker build/run and client config.
- **Blog Content** (`blogs/`): Markdown and HTML blog posts, organized by topic and ID. Uses `template.html` as the base for new posts. See `.agent/README.md` for blog generation workflow.
- **n8n Workflows** (`n8n/workflows/`): Automation and integration flows, including blog generation and MCP orchestration. See `n8n/README.md` for workflow and troubleshooting.

## Essential Workflows

- **Build MCP Server**: `docker build -f bloggerMCP/Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .`
- **Run MCP Server**: `docker run -p 8081:8081 ... sanjeebojha/mcpserver-blogger:latest` (see `bloggerMCP/README.md` for full command)
- **Configure MCP Clients**: Update VS Code `.vscode/settings.json` or Claude Desktop config as shown in `bloggerMCP/README.md`.
- **n8n Workflow Import**: Place JSON in `n8n/workflows/`, validate node types and connections. See `n8n/README.md` for troubleshooting.

## AI Agent Guidance

- **Start Here**: `.agent/agent.md` (project architecture, MCP, blog system)
- **Blog Generation**: Use `.agent/MASTER-BLOG-PROMPT.md` and `.agent/blog-quick-reference.md` for requirements and checklists. Always base new posts on `blogs/computer/template.html`.
- **Update Learnings**: Add new patterns or solutions to `.agent/memory.md`.
- **File Priority**: When in doubt, prefer `.agent/agent.md` > `.agent/MASTER-BLOG-PROMPT.md` > `.agent/blog-quick-reference.md` > `.agent/memory.md`.

## Project Conventions

- **No Kubernetes commands**: K8s is managed separately; only build/push Docker images.
- **Blog posts**: 2,000-2,500 words, 4-6 code examples, 1+ tables, 3+ info boxes, intro/summary, troubleshooting, best practices. See `.agent/blog-writing-guide.md`.
- **All code in blogs**: Use syntax highlighting and real-world examples.
- **Troubleshooting**: For n8n, check workflow JSON, node types, and connections. For MCP, verify endpoint and credentials.

## Key Files & Directories

- `bloggerMCP/README.md`: MCP server setup, Docker, client config
- `.agent/agent.md`: Project architecture, agent instructions
- `.agent/MASTER-BLOG-PROMPT.md`: Blog generation requirements
- `blogs/computer/template.html`: Blog post template
- `n8n/README.md`: Workflow automation, troubleshooting

---

_This file is for AI coding agents. Update with new patterns, workflows, or conventions as they emerge._
