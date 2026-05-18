# .agent Folder - AI Agent Instructions

This folder contains comprehensive instructions and guidelines for AI agents working on the Blogger workspace.

## Files Overview

### Core Agent Instructions

- **`agent.md`** - Main instruction document covering both MCP server and blog pages
- **`memory.md`** - Long-term memory for architectural decisions and learnings
- **`context.md`** - Additional context and notes
- **`claude.md`** - Claude-specific instructions (if any)
- **`chatgpt.md`** - ChatGPT-specific instructions (if any)
- **`gemini.md`** - Gemini-specific instructions (if any)

### Blog Generation System (New)

- **`MASTER-BLOG-PROMPT.md`** - ⭐ START HERE - Complete prompt for blog generation
- **`blog-writing-guide.md`** - Detailed specifications for blog content
- **`blog-quick-reference.md`** - Quick checklist and reference card
- **`example-comparison.md`** - Examples of good vs bad blog writing
- **`blog-generation-prompt.md`** - Alternative prompt format (same content as MASTER)

## Quick Start for AI Agents

### Working on MCP Server

1. Read `agent.md` sections 1-2 (Project Overview, MCP Architecture)
2. Follow Python coding standards (section 4.1)
3. Remember: NO kubectl commands (K8s is on separate machine)
4. Build and push Docker images only

### Generating Blog Posts

1. **Read**: `MASTER-BLOG-PROMPT.md` (complete instructions)
2. **Reference**: `blog-quick-reference.md` (checklist)
3. **Use Template**: `blogs/computer/template.html`
4. **Follow Guide**: `blog-writing-guide.md` (specifications)
5. **Check Quality**: `example-comparison.md` (examples)
6. **Target**: 2,000-2,500 words, 4-6 code examples, 10-min read

### General Workspace Work

1. Read `agent.md` for complete overview
2. Check `memory.md` for recent learnings
3. Update `memory.md` when discovering new patterns or solutions

## Blog Generation Checklist

Quick checklist for generating a blog post:

- [ ] Use `template.html` as base
- [ ] 2,000-2,500 words total
- [ ] 4-6 complete code examples
- [ ] All code has syntax highlighting (highlight-keyword, etc.)
- [ ] 1+ comparison tables
- [ ] 3+ info boxes (info, tip, warning, example)
- [ ] Introduction with "What You'll Learn" box
- [ ] Real-world example with step-by-step breakdown
- [ ] Troubleshooting section with 3-5 issues
- [ ] Best practices section with 5-7 items
- [ ] Conclusion with summary
- [ ] Banner image referenced (assets/banner.png)
- [ ] Create title.txt file
- [ ] Create image-prompts-table.md

## File Priority

When uncertain, use this priority order:

1. **agent.md** - Overall project understanding
2. **MASTER-BLOG-PROMPT.md** - Blog generation (most important)
3. **blog-quick-reference.md** - Quick checklist
4. **memory.md** - Recent learnings
5. **blog-writing-guide.md** - Detailed specs
6. **example-comparison.md** - Quality examples

---

_This folder is your knowledge base. Read these files to understand the workspace and generate high-quality content._
