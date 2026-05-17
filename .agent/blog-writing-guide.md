# Blog Writing Guide for AI Agents

## Purpose

Generate comprehensive, detailed blog posts that help developers and students:

- **Solve specific problems** they encounter in development
- **Understand complex topics** with clear explanations and examples
- **Learn about new features** and technologies in their field

## Target Audience

- **Primary**: Developers (junior to senior level)
- **Secondary**: Computer science students and technical learners
- **Skill Level**: Assume basic programming knowledge, but explain advanced concepts thoroughly

## Content Requirements

### Length & Depth

- **Reading Time**: 10 minutes for average reader (~2,000-2,500 words)
- **Detail Level**: Comprehensive with thorough explanations
- **Examples**: Multiple code examples (minimum 4-6 per article)
- **Complexity**: Can be technically complex, but must be well-explained

### Writing Style

- **Tone**: Professional but approachable
- **Language**: Simple and clear (avoid unnecessary jargon)
- **Voice**: Second person ("you") to engage readers directly
- **Clarity**: One concept per paragraph; use transitions between ideas

### Content Structure

Every article MUST follow this structure:

#### 1. Introduction (10-15% of content)

- **Hook**: Start with a relatable problem or interesting fact
- **What You'll Learn**: Clear info box listing key takeaways
- **Context**: Why this topic matters now
- **Problem Statement**: What challenge does this solve?

#### 2. Background/Prerequisites (10% of content)

- Necessary background knowledge
- Prerequisites (tools, versions, concepts)
- Links to related foundational topics

#### 3. Main Content (50-60% of content)

Divide into 2-4 major sections, each with:

- **Concept Explanation**: Clear definition and purpose
- **How It Works**: Technical details and mechanics
- **Code Examples**: 2-3 examples per major section
- **Visual Aids**: Tables for comparisons, feature grids for lists
- **Subsections**: Break complex topics into digestible parts

#### 4. Real-World Example (15-20% of content)

- **Complete Working Example**: Full implementation, not snippets
- **Step-by-Step Walkthrough**: Numbered steps with explanations
- **Multiple Code Blocks**: Show progression and build complexity
- **Explanation**: Why each part matters and how it works together

#### 5. Advanced Topics/Deep Dive (Optional, 10% if included)

- For readers who want to go deeper
- Technical details, edge cases, or optimizations
- Should include warnings about complexity

#### 6. Common Issues & Troubleshooting (10% of content)

- List 3-5 common problems
- For each: Symptom → Cause → Solution
- Include code fixes where applicable

#### 7. Best Practices (5% of content)

- 5-7 actionable best practices
- Brief explanations of why each matters
- Performance tips if relevant

#### 8. Conclusion (5% of content)

- Summarize key points (3-4 bullet summary)
- Encourage readers to try it themselves
- Mention related topics or next steps

### Code Example Requirements

#### Quality Standards

- **Complete**: Show full context, not just snippets
- **Runnable**: Code should actually work (test if possible)
- **Commented**: Use comments to explain non-obvious parts
- **Realistic**: Real-world scenarios, not toy examples
- **Progressive**: Build complexity gradually

#### Syntax Highlighting

Always use appropriate HTML classes for code highlighting:

- `highlight-keyword`: for language keywords (const, let, class, import, etc.)
- `highlight-string`: for string literals
- `highlight-function`: for function names
- `highlight-class`: for class names
- `highlight-control`: for control flow (@if, @for, if, else, for, etc.)
- `highlight-comment`: for comments
- `highlight-number`: for numeric literals

Example:

```html
<pre><code><span class="highlight-keyword">const</span> <span class="highlight-function">fetchData</span> = <span class="highlight-keyword">async</span> () => {
  <span class="highlight-comment">// Fetch user data from API</span>
  <span class="highlight-keyword">const</span> response = <span class="highlight-keyword">await</span> <span class="highlight-function">fetch</span>(<span class="highlight-string">'/api/users'</span>);
  <span class="highlight-keyword">return</span> response.<span class="highlight-function">json</span>();
};</code></pre>
```

### Visual Elements

#### Required Elements

1. **Banner Image**: Professional banner at top (768x300px recommended)
   - Place in `assets/banner.png`
   - Use `image-prompts-table.md` to document AI generation prompts
2. **Info Boxes**: Use for key takeaways, tips, warnings
   - `info-box`: General information and "What You'll Learn"
   - `tip-box`: Best practices and helpful hints
   - `warning-box`: Important warnings and gotchas
   - `example-box`: Highlight example scenarios

3. **Tables**: For feature comparisons, version differences, etc.
   - Use `comparison-table` class
   - Minimum 2 columns, 3+ rows
   - Clear headers

4. **Feature Grids**: For listing multiple related items
   - Use `feature-grid` for 2-3 column layouts
   - Good for listing features, benefits, use cases

#### Optional Elements

- Diagrams or architecture images in assets folder
- Screenshots showing UI or results
- Additional visual aids for complex concepts

### Technical Writing Guidelines

#### Explain Code Thoroughly

```
❌ BAD: "Here's the code:"
✅ GOOD: "Let's implement a signal-based counter. The signal() function creates
          a reactive value that automatically updates the UI when changed:"
```

#### Use Real-World Context

```
❌ BAD: "You can use this function to process data."
✅ GOOD: "In a real e-commerce app, you'd use this function to filter products
          based on user-selected categories and price ranges."
```

#### Show Before/After

When discussing improvements or migrations:

- Show the old way first
- Explain its limitations
- Show the new way
- Highlight specific improvements with comparison tables

#### Progressive Complexity

Start simple, build up:

1. Basic example (minimal code)
2. Add one feature
3. Add another feature
4. Full implementation with all features

### Template Variables to Replace

When using the template, replace these placeholders:

- `[ARTICLE_TITLE]`: Main title (e.g., "Angular's New Control Flow")
- `[ARTICLE_SUBTITLE]`: Descriptive subtitle (e.g., "Performance Meets Simplicity")
- `[ARTICLE_DESCRIPTION]`: Meta description for SEO (150-160 chars)
- `[DATE]`: Publication/update date
- `[Section headers]`: Replace with actual topic names
- `[Content blocks]`: Replace with actual content
- `[CODE_BLOCK]`: Replace with actual code
- `[PREV_ARTICLE_URL]`: Link to previous article (or remove if first)
- `[NEXT_ARTICLE_URL]`: Link to next article (or remove if last)

## Writing Process Workflow

### Step 1: Research & Planning (Do First)

1. Identify the topic and scope
2. Research official documentation, GitHub repos, release notes
3. Identify 4-6 key concepts to cover
4. Plan code examples (what to demonstrate)
5. Determine if comparison table or migration guide is needed

### Step 2: Outline Creation

1. Map content to template structure
2. Identify which sections are needed
3. Plan progression from simple to complex
4. Decide on visual aids (tables, grids, boxes)

### Step 3: Content Generation

1. Write introduction with hook and problem statement
2. Write main sections with detailed explanations
3. Create code examples (test syntax if possible)
4. Add syntax highlighting spans
5. Write troubleshooting section based on common issues
6. Add info boxes, tips, warnings where appropriate
7. Write conclusion with summary and call to action

### Step 4: Quality Checks

- [ ] Article is 2,000-2,500 words (10 min read)
- [ ] Has 4-6 substantial code examples
- [ ] Includes at least one comparison table OR feature grid
- [ ] Has 2-3 info boxes (tip/warning/example)
- [ ] Code has syntax highlighting spans
- [ ] All placeholders replaced
- [ ] Transitions between sections are smooth
- [ ] Conclusion summarizes key points
- [ ] Meta description is compelling and accurate

## Example Topics by Complexity

### Simple Topics (Still 10 min read with details)

- "What is [Technology/Concept]"
- "Getting Started with [Tool]"
- "Understanding [Fundamental Concept]"
- Must still include: examples, troubleshooting, best practices

### Medium Topics

- "Mastering [Feature]"
- "[Technology] vs [Technology]"
- "Building [Project] with [Tool]"
- Include: multiple examples, comparison tables, real-world scenario

### Complex Topics

- "Advanced [Technique] in [Framework]"
- "Deep Dive: [Complex System]"
- "Complete Guide to [Large Topic]"
- Include: progressive examples, advanced section, detailed troubleshooting

## Quality Standards Checklist

### Content Quality

- ✅ Every claim is accurate (verify against official docs)
- ✅ Code examples actually work
- ✅ Explanations assume appropriate knowledge level
- ✅ No unnecessary jargon without explanation
- ✅ Active voice preferred over passive
- ✅ Concrete examples over abstract descriptions

### Technical Accuracy

- ✅ Version numbers mentioned (e.g., "Angular 17", ".NET 9")
- ✅ Deprecated features flagged
- ✅ Breaking changes highlighted
- ✅ Command syntax is correct
- ✅ Import statements included in code examples
- ✅ File paths and naming conventions accurate

### Completeness

- ✅ Prerequisites clearly stated
- ✅ Every code block is explained
- ✅ Tables have meaningful comparisons
- ✅ Resources linked for further learning
- ✅ Related topics mentioned
- ✅ Navigation links added (if part of series)

### Formatting

- ✅ Proper HTML5 semantic structure
- ✅ All CSS classes from template used correctly
- ✅ Code has syntax highlighting
- ✅ Responsive design preserved
- ✅ Alt text on all images
- ✅ No broken placeholder tags

## Example: Good vs. Bad Article Sections

### ❌ BAD (Too Brief, No Context)

```html
<section>
  <h2>Using Signals</h2>
  <p>Signals are reactive values in Angular 17.</p>
  <pre><code>const count = signal(0);</code></pre>
</section>
```

### ✅ GOOD (Detailed with Context)

```html
<section>
  <h2>Understanding Signals: Angular's Reactive Primitives</h2>
  <p>
    Signals represent a fundamental shift in how Angular handles reactivity.
    Unlike traditional change detection that relies on Zone.js to track when
    values change, Signals provide an explicit, fine-grained reactivity model
    that Angular can optimize aggressively.
  </p>

  <div class="info-box">
    <strong>📘 What is a Signal?</strong>
    <p>
      A Signal is a wrapper around a value that notifies consumers when that
      value changes. Think of it as an observable, but simpler and with better
      TypeScript integration.
    </p>
  </div>

  <h3>Creating Your First Signal</h3>
  <p>
    Let's create a simple counter using Signals. The
    <code>signal()</code> function takes an initial value and returns a Signal
    object:
  </p>

  <pre><code><span class="highlight-keyword">import</span> { signal } <span class="highlight-keyword">from</span> <span class="highlight-string">'@angular/core'</span>;

<span class="highlight-comment">// Create a Signal with initial value of 0</span>
<span class="highlight-keyword">const</span> count = <span class="highlight-function">signal</span>(<span class="highlight-number">0</span>);

<span class="highlight-comment">// Read the value by calling it as a function</span>
<span class="highlight-function">console.log</span>(count()); <span class="highlight-comment">// Output: 0</span>

<span class="highlight-comment">// Update the value using set()</span>
count.<span class="highlight-function">set</span>(<span class="highlight-number">5</span>);

<span class="highlight-comment">// Or update based on previous value using update()</span>
count.<span class="highlight-function">update</span>(current => current + <span class="highlight-number">1</span>); <span class="highlight-comment">// Now 6</span></code></pre>

  <p>
    Notice the three key operations: <strong>create</strong> with
    <code>signal()</code>, <strong>read</strong> by calling the signal, and
    <strong>write</strong> with <code>set()</code> or <code>update()</code>.
  </p>

  <div class="tip-box">
    <strong>💡 Pro Tip</strong>
    <p>
      Use <code>set()</code> when you have a new value, and
      <code>update()</code> when you need to compute the new value based on the
      current one. This prevents race conditions in async scenarios.
    </p>
  </div>

  <h3>Signals in Components</h3>
  <p>
    Here's how you'd use Signals in a real Angular component to build an
    interactive counter:
  </p>

  <pre><code><span class="highlight-keyword">import</span> { Component, signal } <span class="highlight-keyword">from</span> <span class="highlight-string">'@angular/core'</span>;

<span class="highlight-keyword">@Component</span>({
  selector: <span class="highlight-string">'app-counter'</span>,
  standalone: <span class="highlight-keyword">true</span>,
  template: `
    &lt;div class="counter"&gt;
      &lt;button (click)="decrement()"&gt;-&lt;/button&gt;
      &lt;span&gt;{{ count() }}&lt;/span&gt;
      &lt;button (click)="increment()"&gt;+&lt;/button&gt;
    &lt;/div&gt;
  `
})
<span class="highlight-keyword">export class</span> <span class="highlight-class">CounterComponent</span> {
  count = <span class="highlight-function">signal</span>(<span class="highlight-number">0</span>);

  <span class="highlight-function">increment</span>() {
    <span class="highlight-keyword">this</span>.count.<span class="highlight-function">update</span>(n => n + <span class="highlight-number">1</span>);
  }

  <span class="highlight-function">decrement</span>() {
    <span class="highlight-keyword">this</span>.count.<span class="highlight-function">update</span>(n => n - <span class="highlight-number">1</span>);
  }
}</code></pre>

  <p>
    When you click the buttons, Angular automatically updates only the
    <code>&lt;span&gt;</code> element—no full component re-render needed. This
    is the power of fine-grained reactivity.
  </p>
</section>
```

---

## Technical Topics: Special Considerations

### For Framework Features (Angular, React, .NET)

- Show migration path from old to new
- Include version compatibility information
- Compare with previous approach using tables
- Show both old and new code side-by-side

### For Hardware/Fundamentals (CPU, GPU, RAM)

- Use analogies to explain complex concepts
- Include diagrams or visual descriptions
- Explain both theory and practical implications
- Connect to real-world developer scenarios

### For Debugging/Problem Solving

- Start with the error message or symptom
- Explain root cause in detail
- Show multiple solutions if applicable
- Include prevention strategies

### For New Tool/Technology Introductions

- Explain what problem it solves
- Show installation/setup steps
- Include "Hello World" example
- Build to more complex examples
- Provide migration guide if replacing existing tool

## Info Box Usage Guidelines

### 📘 Info Box (Blue - .info-box)

Use for:

- "What You'll Learn" sections
- Key definitions and concepts
- Important background information
- Feature summaries

### 💡 Tip Box (Green - .tip-box)

Use for:

- Pro tips and best practices
- Performance optimizations
- Shortcuts or time-savers
- "Did you know?" facts

### ⚠️ Warning Box (Red - .warning-box)

Use for:

- Breaking changes
- Common pitfalls to avoid
- Security concerns
- Deprecated features
- "This will cause problems if..."

### 📋 Example Box (Orange - .example-box)

Use for:

- Real-world scenario descriptions
- Use case introductions
- "Imagine you're building..." scenarios
- Before showing example code

## Word Count Distribution Example

For a 2,500-word article:

- Introduction: 250-375 words
- Background: 250 words
- Main Content Sections (3 sections): 1,250-1,500 words
- Real-World Example: 375-500 words
- Common Issues: 250 words
- Best Practices: 125 words
- Conclusion: 125 words

## Final Checklist Before Publishing

- [ ] All `[PLACEHOLDERS]` replaced with actual content
- [ ] Banner image exists in assets folder
- [ ] `title.txt` file created with article title
- [ ] All code examples have syntax highlighting
- [ ] At least 4 code examples included
- [ ] At least 1 comparison table OR feature grid
- [ ] At least 2 info/tip/warning boxes
- [ ] Reading time is 8-12 minutes (2,000-2,500 words)
- [ ] Troubleshooting section with 3+ issues
- [ ] Best practices list with 5+ items
- [ ] Conclusion summarizes key points
- [ ] Navigation links updated (if part of series)
- [ ] All links tested (no broken links)
- [ ] Responsive design works on mobile
- [ ] HTML is valid and semantic

---

_This guide ensures consistent, high-quality blog posts that truly help developers and students learn and solve problems._
