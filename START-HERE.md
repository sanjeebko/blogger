# Blog Generation System - Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER REQUEST                            │
│  "Create a blog post about [TOPIC]"                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AI AGENT LOADS                             │
│  1. .agent/MASTER-BLOG-PROMPT.md    (What to do)               │
│  2. .agent/blog-quick-reference.md  (Checklist)                │
│  3. .agent/agent.md                 (Project context)          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AGENT PLANS CONTENT                           │
│  • Research topic (if needed)                                  │
│  • Identify 4-6 key concepts to cover                          │
│  • Plan code examples and scenarios                            │
│  • Determine comparison table content                          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                 COPY TEMPLATE & CREATE FILES                    │
│  • Copy blogs/computer/template.html                           │
│  • Create blogs/computer/[NUMBER]/[topic].html                 │
│  • Create title.txt                                            │
│  • Create assets/ folder                                       │
│  • Create image-prompts-table.md                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              GENERATE CONTENT (Follow Guide)                    │
│                                                                 │
│  Introduction (250-375 words)                                  │
│  ├─ Hook + Info box                                            │
│  └─ Context + Problem                                          │
│                                                                 │
│  Background (200-300 words)                                    │
│  └─ Prerequisites + foundational knowledge                     │
│                                                                 │
│  Main Sections (1,250-1,500 words)                             │
│  ├─ Section 1: Concept + 2 code examples + table              │
│  ├─ Section 2: Details + 2 code examples + boxes              │
│  └─ Section 3: Advanced + 1 code example + grid               │
│                                                                 │
│  Real-World Example (375-500 words)                            │
│  ├─ Example box with scenario                                 │
│  ├─ Step 1: Setup code                                        │
│  ├─ Step 2: Implementation code                               │
│  └─ Step 3: Enhancement code                                  │
│                                                                 │
│  Troubleshooting (250-350 words)                               │
│  └─ 3-5 issues with Symptom → Cause → Solution                │
│                                                                 │
│  Best Practices (125-175 words)                                │
│  └─ 5-7 actionable practices + tip box                        │
│                                                                 │
│  Conclusion (125-175 words)                                    │
│  └─ Summary + encouragement + next steps                      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              ADD SYNTAX HIGHLIGHTING                            │
│  • Wrap keywords in <span class="highlight-keyword">          │
│  • Wrap strings in <span class="highlight-string">            │
│  • Wrap functions in <span class="highlight-function">        │
│  • Wrap comments in <span class="highlight-comment">          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   QUALITY VERIFICATION                          │
│  ✓ Word count: 2,000-2,500                                    │
│  ✓ Code examples: 4-6                                         │
│  ✓ Comparison table: 1+                                       │
│  ✓ Info boxes: 3+                                             │
│  ✓ All placeholders replaced                                  │
│  ✓ All code has syntax highlighting                           │
│  ✓ Navigation links updated                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FINAL OUTPUT FILES                           │
│                                                                 │
│  blogs/computer/[NUMBER]/                                      │
│  ├── [topic].html          ← Complete article                 │
│  ├── title.txt             ← Article title                    │
│  ├── image-prompts-table.md ← Banner image prompts            │
│  └── assets/                                                   │
│      └── (empty, ready for banner.png)                        │
└─────────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### Resource Files (What Agent Uses)

```
.agent/
├── 🎯 MASTER-BLOG-PROMPT.md
│   └─→ Complete instructions for generation
│
├── 📋 blog-quick-reference.md
│   └─→ Checklist during generation
│
├── 📖 blog-writing-guide.md
│   └─→ Detailed specifications
│       ├─ Word count targets
│       ├─ Section structure
│       ├─ Code example format
│       ├─ Visual element requirements
│       └─ Quality standards
│
├── 🎓 example-comparison.md
│   └─→ Good vs Bad examples
│       ├─ Code explanations
│       ├─ Real-world examples
│       ├─ Comparison tables
│       └─ Info boxes
│
├── 📐 visual-structure-guide.md
│   └─→ Visual layout reference
│       ├─ Section spacing
│       ├─ Color palette
│       ├─ Typography scale
│       └─ Responsive breakpoints
│
└── 🏗️ agent.md
    └─→ Overall workspace context
        ├─ MCP server architecture
        ├─ Blog pages structure
        ├─ Coding standards
        └─ File locations
```

### Template Files (What Gets Copied)

```
blogs/computer/
├── 📄 template.html
│   └─→ Complete HTML structure
│       ├─ All CSS styling
│       ├─ Section scaffolding
│       ├─ Info box styles
│       ├─ Table styles
│       ├─ Code block styles
│       └─ Navigation structure
│
└── 📝 template-image-prompts.md
    └─→ Image generation guide
        ├─ Banner prompt format
        ├─ Additional image prompts
        └─ Image specifications
```

## Quality Enforcement

The system ensures quality through:

```
MASTER-BLOG-PROMPT.md
    ├─→ Mandatory Structure
    │   └─ All sections required
    │
    ├─→ Content Requirements
    │   ├─ 2,000-2,500 words
    │   ├─ 4-6 code examples
    │   └─ Specific word counts per section
    │
    ├─→ Visual Elements
    │   ├─ 1+ comparison table
    │   ├─ 3+ info boxes
    │   └─ Feature grids
    │
    └─→ Code Standards
        ├─ Syntax highlighting mandatory
        ├─ Complete examples (no snippets)
        └─ Explanation before & after

blog-quick-reference.md
    └─→ Checklist Verification
        ├─ Content structure ✓
        ├─ Word count ✓
        ├─ Code examples ✓
        ├─ Visual elements ✓
        └─ Quality gates ✓

example-comparison.md
    └─→ Quality Standards
        ├─ Good examples to follow
        └─ Bad examples to avoid
```

## Generation Workflow

```
1. USER SAYS
   "Create a blog post about [TOPIC]"

2. AGENT READS
   ├─ MASTER-BLOG-PROMPT.md (instructions)
   ├─ blog-quick-reference.md (checklist)
   └─ agent.md (context)

3. AGENT PLANS
   ├─ Identify key concepts
   ├─ Plan code examples
   └─ Determine visual elements

4. AGENT GENERATES
   ├─ Copy template.html
   ├─ Fill in all sections
   ├─ Add code with highlighting
   ├─ Create tables and boxes
   └─ Write 2,000-2,500 words

5. AGENT VERIFIES
   ├─ Check word count ✓
   ├─ Count code examples ✓
   ├─ Verify visual elements ✓
   └─ Ensure quality standards ✓

6. AGENT DELIVERS
   ├─ [topic].html
   ├─ title.txt
   ├─ image-prompts-table.md
   └─ assets/ folder
```

## File Structure After Generation

```
blogs/computer/18/              ← New numbered folder
├── dependency-injection.html   ← Generated article
├── title.txt                   ← "Mastering Dependency Injection in ASP.NET Core 8"
├── image-prompts-table.md      ← Banner image prompts
└── assets/
    └── (empty - you add banner.png after generation)
```

## Your Next Steps

1. **Generate your first blog post** - Try it with any topic!
2. **Review the output** - Check it matches your quality standards
3. **Generate banner image** - Use prompts in image-prompts-table.md
4. **Save banner** - Place in assets/banner.png
5. **Preview** - Open HTML file in browser
6. **Publish** - Copy to your blog platform

## Example Topics Ready to Generate

### Angular

- "Angular 18's new control flow syntax deep dive"
- "Mastering signals and computed values"
- "Building forms with the new model-driven approach"

### .NET

- "ASP.NET Core 9 minimal APIs best practices"
- "Entity Framework Core 9 performance improvements"
- "Building microservices with .NET 9"

### General

- "Understanding Docker multi-stage builds"
- "Git workflow strategies for teams"
- "API design best practices in 2026"

---

## 🎊 That's It!

Your blog generation system is ready. Just ask your AI agent for a blog post on any topic, and it will create a comprehensive, professional article following all your requirements.

**Quick command:**

```
"Create a blog post about [YOUR TOPIC HERE]"
```

---

_For detailed usage instructions, see `.agent/HOW-TO-USE.md`_
_For technical details, see `BLOG-SYSTEM-SETUP.md`_
