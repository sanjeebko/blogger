# n8n Workflow Fixes for Blog Generator

## Issue 1: Aggregate Image Results Only Returns 1 Item

**Problem**: When AI generates N blog posts, "Aggregate Image Results" only returns the first post.

**Current Code** (Line 182):
```javascript
const items = $input.all();
const baseData = items[0].json;  // ❌ Only gets first item
const savedImages = items.filter(i => i.json.imageSaved).map(...);

return [{ json: { ...baseData, savedImages } }];  // ❌ Returns only 1 item
```

**Fixed Code**:
```javascript
const items = $input.all();

if (items.length === 0) {
  return [];
}

// Group items by uniquePostId
const postGroups = {};
items.forEach(item => {
  const postId = item.json.uniquePostId;
  if (!postGroups[postId]) {
    postGroups[postId] = {
      baseData: item.json,
      images: []
    };
  }
  if (item.json.imageSaved) {
    postGroups[postId].images.push({
      filename: item.json.imageFilename,
      type: item.json.imageType,
      path: item.json.imagePath
    });
  }
});

// Return one item per blog post
return Object.values(postGroups).map(group => ({
  json: {
    uniquePostId: group.baseData.uniquePostId,
    blogId: group.baseData.blogId,
    title: group.baseData.title,
    description: group.baseData.description,
    labels: group.baseData.labels,
    wordCount: group.baseData.wordCount,
    readingTime: group.baseData.readingTime,
    outline: group.baseData.outline,
    codeExamples: group.baseData.codeExamples,
    visualElements: group.baseData.visualElements,
    createdDate: group.baseData.createdDate,
    folderPath: group.baseData.folderPath,
    imagesGenerated: group.images.length,
    savedImages: group.images
  }
}));
```

---

## Issue 2: Build Ollama Prompt References Template File Path

**Problem**: Ollama can't access `blogs/computer/template.html` - needs actual template content.

**Current Code** (Line 217):
```javascript
const prompt = `...
TEMPLATE: Use structure from blogs/computer/template.html
...`;
```

**Fixed Code**:
```javascript
// Read template content (do this ONCE, store as constant)
const fs = require('fs');
const templatePath = 'F:/workspace/blogger/blogs/computer/template.html';
const templateContent = fs.readFileSync(templatePath, 'utf8');

const imageList = ($json.savedImages || []).map(img => img.filename).join(', assets/');

const prompt = `You are an expert technical writer. Generate a complete 2,000-2,500 word blog post in HTML format using the data and template below.

BLOG DATA:
${JSON.stringify($json, null, 2)}

HTML TEMPLATE STRUCTURE:
${templateContent}

REQUIREMENTS:
- Follow the template structure exactly
- Replace placeholders like [ARTICLE_TITLE], [ARTICLE_DESCRIPTION], etc.
- Use all sections from outline with specified word counts
- Include all ${$json.codeExamples?.length || 0} code examples with syntax highlighting classes (highlight-keyword, highlight-string, etc)
- Add comparison tables, info boxes, feature grids from visualElements
- Reference images: assets/${imageList}
- Images generated: ${$json.imagesGenerated || 0}
- Professional writing, second-person (you), active voice
- Complete runnable code examples
- Replace [CODE_BLOCK], [ADVANCED_CODE_BLOCK], etc. with actual code

Output ONLY the complete HTML content with all placeholders replaced.`;

return { json: { ...$json, ollamaPrompt: prompt } };
```

---

## How to Apply Fixes

### Option 1: Manual Update in n8n UI

1. Open workflow in n8n
2. **Aggregate Image Results** node:
   - Replace code with Fix 1
3. **Build Ollama Prompt** node:
   - Replace code with Fix 2
4. Save and test

### Option 2: Update JSON File

I can update the `blog-generator-fixed.json` file with these fixes if you want.

---

## Expected Behavior After Fixes

**Before:**
- AI generates 3 blog posts
- Only 1 Ollama prompt created ❌
- Template path referenced but not included ❌

**After:**
- AI generates 3 blog posts
- 3 Ollama prompts created (one per post) ✅
- Full template content included in each prompt ✅
- Ollama generates 3 complete HTML files ✅

---

## Note on Template Size

The template is 17KB (644 lines). This will make the prompt larger, but Ollama (Mistral) can handle it.

If the prompt becomes too large, you can:
1. **Simplify template**: Remove comments and extra whitespace
2. **Extract structure only**: Just send the HTML structure without CSS
3. **Use template summary**: Describe the structure instead of including full HTML

Let me know if you want me to apply these fixes to the JSON file!
