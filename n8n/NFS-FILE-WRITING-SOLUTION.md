# N8N File Writing to NFS - Complete Solution

## Problem Summary

N8N 2.0.3 blocks the `fs` module in Code nodes for security reasons. The error `"Module 'fs' is disallowed"` occurs when trying to use `require('fs')`.

## ✅ SOLUTION: Use Write Binary File Node

Instead of using `fs.writeFileSync()` in Code nodes, use n8n's built-in **Write Binary File** node.

---

## Implementation Pattern

### ❌ WRONG (Won't Work - fs is blocked):

```javascript
// Code node
const fs = require("fs"); // ← ERROR: Module 'fs' is disallowed
fs.writeFileSync("/files/test.txt", "content");
```

### ✅ CORRECT (Works with n8n 2.0.3+):

**Step 1: Prepare Binary Data (Code Node)**

```javascript
const content = "Your file content here";
const filename = "test.txt";

const buffer = Buffer.from(content, "utf8");

return [
  {
    json: {
      filename: filename,
      folderPath: "/files/projectName",
    },
    binary: {
      data: {
        data: buffer.toString("base64"),
        mimeType: "text/plain",
        fileName: filename,
      },
    },
  },
];
```

**Step 2: Write Binary File Node**

- **Node Type:** Write Binary File
- **File Name:** `={{ $json.folderPath + '/' + $json.filename }}`
- This writes to NFS mount at `/files/`

---

## Complete Working Examples

### Example 1: Save Image from Base64

**Node 1: Prepare Image Data (Code)**

```javascript
const imageData = $json.imageDataBase64; // from API response
const filename = $json.filename || "image.png";
const folderPath = "/files/bloggergenerator/images";

const buffer = Buffer.from(imageData, "base64");

return [
  {
    json: {
      filename: filename,
      folderPath: folderPath,
    },
    binary: {
      data: {
        data: buffer.toString("base64"),
        mimeType: "image/png",
        fileName: filename,
      },
    },
  },
];
```

**Node 2: Write Binary File**

- File Name: `={{ $json.folderPath + '/' + $json.filename }}`
- Result: File saved to `/files/bloggergenerator/images/image.png`

### Example 2: Save HTML Content

**Node 1: Prepare HTML Data (Code)**

```javascript
const htmlContent = $json.generatedHTML;
const title = $json.title;
const filename = title.toLowerCase().replace(/[^a-z0-9]+/g, "-") + ".html";
const folderPath = "/files/blogs";

const buffer = Buffer.from(htmlContent, "utf8");

return [
  {
    json: {
      filename: filename,
      htmlFile: folderPath + "/" + filename,
      generatedContent: htmlContent,
    },
    binary: {
      data: {
        data: buffer.toString("base64"),
        mimeType: "text/html",
        fileName: filename,
      },
    },
  },
];
```

**Node 2: Write Binary File**

- File Name: `={{ $json.htmlFile }}`
- Result: HTML saved to `/files/blogs/my-article.html`

---

## Creating Folders and Multiple Files

### Option 1: Use Execute Command Node (Shell)

**Node Type:** Execute Command  
**Command:**

```bash
mkdir -p '/files/bloggergenerator/{{ $json.uniqueId }}/assets' && \
echo '# {{ $json.title }}

Created: {{ $json.createdDate }}

Files in this folder:
- blog-data.json
- assets/ (images)
- {{ $json.filename }}' > '/files/bloggergenerator/{{ $json.uniqueId }}/README.md'
```

This creates:

- `/files/bloggergenerator/[uniqueId]/`
- `/files/bloggergenerator/[uniqueId]/assets/`
- `/files/bloggergenerator/[uniqueId]/README.md`

### Option 2: Multiple Write Binary File Nodes

Chain multiple "Write Binary File" nodes to create different files. N8N automatically creates parent directories.

---

## Cleanup Old Files

### Option 1: Execute Command (Shell Script)

**Node Type:** Execute Command  
**Command:**

```bash
cd /files/bloggergenerator 2>/dev/null && \
find . -maxdepth 1 -type d -name '[0-9]*' | while read dir; do \
  if [ -f "$dir/README.md" ]; then \
    created=$(grep 'Created:' "$dir/README.md" | cut -d' ' -f2-); \
    age=$(( ($(date +%s) - $(date -d "$created" +%s 2>/dev/null || echo 0)) / 86400 )); \
    if [ $age -gt 180 ]; then \
      echo "Deleting $dir (${age} days old)"; \
      rm -rf "$dir"; \
    fi; \
  fi; \
done
```

This deletes folders older than 180 days (6 months).

### Option 2: HTTP Request to Custom API

Create a separate cleanup service and call it via HTTP Request node.

---

## Binary Data MIME Types

| File Type  | MIME Type          |
| ---------- | ------------------ |
| PNG Image  | `image/png`        |
| JPEG Image | `image/jpeg`       |
| WebP Image | `image/webp`       |
| HTML       | `text/html`        |
| Plain Text | `text/plain`       |
| JSON       | `application/json` |
| PDF        | `application/pdf`  |
| CSV        | `text/csv`         |

---

## Complete Workflow Example

```json
{
  "nodes": [
    {
      "name": "Prepare Data",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const content = 'Hello NFS!';\nconst buffer = Buffer.from(content, 'utf8');\n\nreturn [{\n  json: { filename: 'test.txt', folder: '/files/test' },\n  binary: {\n    data: {\n      data: buffer.toString('base64'),\n      mimeType: 'text/plain',\n      fileName: 'test.txt'\n    }\n  }\n}];"
      }
    },
    {
      "name": "Write File",
      "type": "n8n-nodes-base.writeBinaryFile",
      "parameters": {
        "fileName": "={{ $json.folder + '/' + $json.filename }}"
      }
    }
  ],
  "connections": {
    "Prepare Data": {
      "main": [[{ "node": "Write File", "type": "main", "index": 0 }]]
    }
  }
}
```

---

## Verification Steps

### 1. Check File on NFS Server

```bash
# On NFS server (192.168.0.220)
ls -lh /home/sanjeeb/data/n8n_169/test/

# Should see: test.txt
```

### 2. Check from N8N Container

```bash
# From Docker host (192.168.0.169)
docker compose exec n8n ls -lh /files/test/

# Should see: test.txt
```

### 3. Read File Content

```bash
docker compose exec n8n cat /files/test/test.txt
# Output: Hello NFS!
```

---

## Troubleshooting

### Issue: "Module 'fs' is disallowed"

**Solution:** Remove all `require('fs')` from Code nodes. Use Write Binary File instead.

### Issue: "Permission denied"

**Check NFS mount permissions:**

```bash
docker compose exec n8n ls -ld /files
# Should show: drwxr-xr-x (755)
```

**Fix if needed (on NFS server):**

```bash
chmod 755 /home/sanjeeb/data/n8n_169
chown -R nobody:nogroup /home/sanjeeb/data/n8n_169
```

### Issue: "No such file or directory"

**Folders are auto-created** by Write Binary File node. But if using shell commands, always use `mkdir -p`.

### Issue: Binary data not found

**Ensure Code node returns both `json` and `binary` objects:**

```javascript
return [
  {
    json: { metadata: "here" }, // ← Required
    binary: {
      // ← Required for file writing
      data: { data: "...", mimeType: "...", fileName: "..." },
    },
  },
];
```

---

## Key Differences: Old vs New Approach

| Old Approach (Blocked)       | New Approach (Works)              |
| ---------------------------- | --------------------------------- |
| `require('fs')` in Code node | No `fs` module needed             |
| `fs.writeFileSync()`         | Write Binary File node            |
| `fs.mkdirSync()`             | Auto-created by Write Binary File |
| `fs.existsSync()`            | Not needed - node handles it      |
| `fs.rmSync()`                | Use Execute Command with shell    |

---

## Environment Variables (Not Needed)

No special environment variables are required. The `/files` NFS mount works out-of-the-box with Write Binary File node.

---

## Security Benefits

✅ **Why fs is blocked:** Prevents malicious workflows from:

- Reading sensitive files (`/etc/passwd`)
- Modifying system files
- Executing arbitrary file operations

✅ **Write Binary File is safe:** Only writes to user-specified paths, can't execute code.

---

## Summary

**To write files to NFS in n8n 2.0.3+:**

1. **Prepare binary data** in Code node (convert content to base64)
2. **Add binary object** with `data`, `mimeType`, `fileName`
3. **Use Write Binary File node** with dynamic file path
4. **Folders auto-created** - no mkdir needed
5. **For cleanup** - use Execute Command with shell scripts

**Never use `require('fs')` - it's blocked and will always fail.**
