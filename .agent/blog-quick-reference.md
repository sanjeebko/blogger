# Quick Reference: Blog Post Generation

## Checklist for Every Article

### Before Starting

- [ ] Topic clearly defined
- [ ] Copy `template.html` to new numbered folder
- [ ] Create `assets/` folder for images
- [ ] Review `blog-writing-guide.md` for specifications

### Content Structure (2,000-2,500 words total)

- [ ] **Introduction** (250-375 words) - Hook, info box, context, problem
- [ ] **Background** (200-300 words) - Prerequisites, foundational knowledge
- [ ] **Main Sections** (1,250-1,500 words) - 2-4 sections, each with subsections
- [ ] **Real-World Example** (375-500 words) - Complete working code with steps
- [ ] **Troubleshooting** (250-350 words) - 3-5 common issues with solutions
- [ ] **Best Practices** (125-175 words) - 5-7 actionable practices
- [ ] **Resources** (75-100 words) - 3-5 external links
- [ ] **Conclusion** (125-175 words) - Summary and call to action

### Code Examples (Minimum 4-6)

- [ ] All examples are complete and runnable
- [ ] Every code block is explained before AND after
- [ ] Syntax highlighting applied (keyword, string, function, class, control, comment)
- [ ] Real-world scenarios (not toy examples)
- [ ] Progressive complexity (simple → intermediate → advanced)
- [ ] Comments explain non-obvious parts

### Visual Elements

- [ ] **1 Banner image** - referenced as `assets/banner.png`
- [ ] **1+ Comparison table** - old vs new, or feature comparison
- [ ] **1 Info box** - "What You'll Learn" in introduction
- [ ] **1+ Tip/Warning box** - scattered throughout
- [ ] **1 Example box** - before real-world example
- [ ] **Feature grid** - if listing 3+ features/benefits

### Syntax Highlighting Classes

```
highlight-keyword     → const, let, class, import, async, await, return
highlight-string      → 'string literals', "string literals"
highlight-function    → functionName, methodName
highlight-class       → ClassName, InterfaceName
highlight-control     → @if, @for, if, else, for, while, switch
highlight-comment     → // comments and /* comments */
highlight-number      → 123, 0, 3.14
```

### Info Box Classes & Icons

```
info-box     → 📘 (blue)   - "What You'll Learn", definitions, key concepts
tip-box      → 💡 (green)  - Pro tips, best practices, performance
warning-box  → ⚠️ (red)    - Gotchas, breaking changes, security
example-box  → 📋 (orange) - Scenario descriptions, use cases
```

### Writing Style Checklist

- [ ] Simple, professional language (no unnecessary jargon)
- [ ] Second person ("you") for engagement
- [ ] Active voice ("Angular compiles" not "is compiled by")
- [ ] One idea per paragraph
- [ ] Clear transitions between sections
- [ ] Technical accuracy verified
- [ ] Version numbers mentioned where relevant

### File Checklist

- [ ] HTML file created with all content
- [ ] `title.txt` created with article title
- [ ] `assets/` folder created
- [ ] `image-prompts-table.md` created with banner prompt
- [ ] All `[PLACEHOLDERS]` replaced
- [ ] Navigation links updated (if part of series)

### Quality Gates

- [ ] Total word count: 2,000-2,500 words
- [ ] Code examples: 4-6 complete examples
- [ ] All code has syntax highlighting
- [ ] No placeholder text remains
- [ ] All sections are substantial (not brief)
- [ ] Reading would take 9-11 minutes
- [ ] Helps readers solve a problem or learn something valuable

---

## Quick Template Reminder

**Standard Section Structure:**

```html
<section>
  <h2>[Section Title]</h2>
  <p>[Introduction to section topic]</p>

  <h3>[Subtopic]</h3>
  <p>[Explanation]</p>

  <pre><code>[CODE WITH HIGHLIGHTING]</code></pre>

  <p>[Code explanation]</p>

  <div class="tip-box">
    <strong>💡 Pro Tip</strong>
    <p>[Helpful insight]</p>
  </div>
</section>
```

**Comparison Table Structure:**

```html
<table class="comparison-table">
  <thead>
    <tr>
      <th>Feature</th>
      <th>Old Way</th>
      <th>New Way</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <!-- 3-5 rows -->
  </tbody>
</table>
```

---

## Word Count Targets by Section

| Section              | Words           | Percentage |
| -------------------- | --------------- | ---------- |
| Introduction         | 250-375         | 12-15%     |
| Background           | 200-300         | 10-12%     |
| Main Content (total) | 1,250-1,500     | 50-60%     |
| Real-World Example   | 375-500         | 15-20%     |
| Troubleshooting      | 250-350         | 10-14%     |
| Best Practices       | 125-175         | 5-7%       |
| Resources            | 75-100          | 3-4%       |
| Conclusion           | 125-175         | 5-7%       |
| **TOTAL**            | **2,000-2,500** | **100%**   |

---

_Keep this reference handy when generating blog posts._
