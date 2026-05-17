# How to Generate Blog Posts with AI Agent

This guide shows you how to use the blog generation system with your AI agent.

## Quick Start

### Option 1: Simple Request

Just give the agent a topic:

```
"Create a blog post about [TOPIC]"
```

Example:

```
"Create a blog post about Angular 17's new inject() function"
```

The agent will automatically:

- Use the template
- Follow the writing guide
- Generate 2,000-2,500 words
- Include 4-6 code examples
- Add all required visual elements
- Create necessary files (HTML, title.txt, image prompts)

### Option 2: Detailed Request

Provide more specific requirements:

```
"Create a blog post about [TOPIC]. Focus on [SPECIFIC ASPECTS].
Include examples of [SCENARIOS]. Target audience: [AUDIENCE LEVEL]"
```

Example:

```
"Create a blog post about Dependency Injection in .NET 8.
Focus on lifetime management and best practices.
Include examples of scoped vs singleton vs transient services.
Target audience: intermediate developers"
```

### Option 3: Reference the Prompt

Point the agent to the master prompt:

```
"Generate a blog post following MASTER-BLOG-PROMPT.md about [TOPIC]"
```

## What the Agent Will Create

For each blog post, you'll get:

1. **HTML File**: Complete article in `blogs/computer/[NUMBER]/[topic].html`
2. **Title File**: `title.txt` with article title
3. **Assets Folder**: `assets/` for images
4. **Image Prompts**: `image-prompts-table.md` with AI image generation prompts

## Expected Output Quality

Every generated article will have:

✅ **2,000-2,500 words** (10-minute read)
✅ **4-6 complete code examples** with syntax highlighting
✅ **1+ comparison tables**
✅ **3+ info boxes** (tips, warnings, examples)
✅ **Detailed explanations** - every code block explained
✅ **Real-world scenario** with step-by-step implementation
✅ **Troubleshooting section** with 3-5 common issues
✅ **Best practices** with 5-7 actionable tips
✅ **Professional design** matching the template style

## Customization Options

### Adjust Complexity

- **"Make it beginner-friendly"** - More explanations, simpler examples
- **"Advanced level"** - Deeper technical details, complex patterns
- **"Quick reference style"** - More code, less explanation (still detailed)

### Focus Areas

- **"Focus on performance"** - Emphasize optimization, benchmarks
- **"Focus on migration"** - Show old vs new, migration paths
- **"Focus on troubleshooting"** - More debugging examples
- **"Focus on best practices"** - Emphasize patterns and anti-patterns

### Visual Elements

- **"Include more tables"** - Add multiple comparison tables
- **"Add feature grid"** - Use grid layout for feature lists
- **"More diagrams"** - Request additional visual explanations

## Example Requests

### Simple Topic

```
"Create a blog post about what is a GPU and how it differs from CPU"
```

### Framework Feature

```
"Create a blog post about Angular 17's @for control flow with track expressions"
```

### Problem-Solving Guide

```
"Create a blog post about debugging .NET container crashes in production"
```

### Deep Dive

```
"Create a blog post about advanced RxJS patterns for state management.
Include examples with combineLatest, switchMap, and shareReplay"
```

### Series Article

```
"Create part 5 of the Angular 17 series about the inject() function.
This should link to parts 1-4 in navigation"
```

## After Generation

### Review Checklist

1. Open the generated HTML file
2. Verify all placeholders replaced
3. Check word count is in range (2,000-2,500)
4. Count code examples (should be 4-6)
5. Verify syntax highlighting is applied
6. Check all sections are present
7. Test responsiveness (resize browser)

### Generate Banner Image

1. Open `image-prompts-table.md`
2. Copy the banner image prompt
3. Use AI image generator (DALL-E, Midjourney, etc.)
4. Save as `assets/banner.png` (1024x400px)

### Finalize

1. Update `blogs/index.html` with link to new article (if needed)
2. Update navigation links (if part of series)
3. Test all links work correctly
4. Preview in browser

## Tips for Best Results

### Be Specific

❌ "Write about Angular"
✅ "Write about Angular 17's new deferrable views feature with @defer blocks"

### Mention Version Numbers

❌ "Write about .NET features"
✅ "Write about new features in .NET 9"

### Specify Use Cases

❌ "Write about dependency injection"
✅ "Write about dependency injection in ASP.NET Core 8, focusing on service lifetimes and factory patterns"

### Request Comparisons

❌ "Write about Signals"
✅ "Write about Angular Signals with a comparison to RxJS Observables"

## Troubleshooting

### If Article is Too Short

- Ask agent to expand sections with more details
- Request additional code examples
- Ask for more troubleshooting scenarios

### If Article is Too Technical

- Request simpler language
- Ask for more analogies and explanations
- Specify "beginner-friendly" or "intermediate level"

### If Missing Visual Elements

- Ask to add comparison table
- Request feature grid for listed items
- Ask for more info boxes (tips, warnings)

### If Code Examples are Brief

- Request "complete, production-ready examples"
- Ask for "step-by-step implementation"
- Specify "show full component, not just snippets"

## Quality Standards

Every blog post should:

- ✅ Help readers solve a real problem
- ✅ Teach something valuable and practical
- ✅ Include working code they can use
- ✅ Explain WHY, not just HOW
- ✅ Be comprehensive yet clear
- ✅ Look professional and polished

---

_With this system, you can generate consistent, high-quality technical blog posts that truly help developers and students._
