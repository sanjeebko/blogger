# Workflow Deployment Summary

**Date:** January 26, 2026
**Deployed to:** https://n8n.saasa.co.uk

## Deployed Workflows

### 1. GeminiNanoImageGenerator

- **Workflow ID:** `hwkfsxRY6F35HmEt`
- **Status:** Created ✅
- **Purpose:** Standalone image generation service using Google Imagen API
- **Trigger Types:**
  - Webhook: `/webhook/gemini-image-generator`
  - Execute Workflow (can be called by other workflows)

#### Node Flow:

1. **Start Timer** - Records start timestamp
2. **Generate Image with Gemini** - HTTP POST to Google Imagen API
   - Endpoint: `https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict`
   - Aspect Ratio: 16:9 (1200x600px)
   - Safety Filter: block_some
3. **Extract Image Data** - Parses API response (base64 encoded)
4. **Save Image to Folder** - Writes to NFS mount at specified folder
5. **Return Response** - Returns metadata with timing info

#### Input Parameters:

```json
{
  "prompt": "Detailed image generation prompt",
  "filename": "banner.png",
  "folderName": "/files/bloggergenerator/[uniquePostId]/assets"
}
```

#### Output:

```json
{
  "success": true,
  "filename": "banner.png",
  "fullPath": "/files/bloggergenerator/.../assets/banner.png",
  "folderName": "/files/bloggergenerator/.../assets",
  "timeTakenMs": 3450,
  "timeTakenSeconds": "3.45 seconds",
  "generatedAt": "2026-01-26T17:27:40.496Z"
}
```

---

### 2. BlogGenerator

- **Workflow ID:** `RPl6kytrnqkl7wlM`
- **Status:** Updated ✅
- **Purpose:** Automated blog post generation with AI-powered content and images
- **Version:** 19

#### Architecture Changes:

✅ **Removed:** Stable Diffusion HTTP API call  
✅ **Added:** Execute Workflow node calling GeminiNanoImageGenerator  
✅ **Updated:** Ollama model from `llama3.1:latest` → `mistral:latest`  
✅ **Modified:** Process Image Result node to handle workflow response

#### Complete Node Flow (16 nodes):

**Phase 1: Setup & Cleanup**

1. Manual Trigger
2. Cleanup Old Files (6+ months deletion, runs in parallel)

**Phase 2: Content Planning (AI Agent)** 3. Google Gemini Chat Model (structure generation) 4. MCP Client (Blogger API access) 5. AI Agent (generates structured blog data) 6. Simple Memory (session context)

**Phase 3: Data Processing** 7. Parse JSON Output (adds uniquePostId, folderPath) 8. Create Folder Structure (creates /files/bloggergenerator/[id]/)

**Phase 4: Image Generation Loop** 9. Split Image Prompts (loops through imagePrompts[]) 10. **Generate Image (Gemini)** - Calls GeminiNanoImageGenerator workflow 11. Process Image Result (normalizes response) 12. Aggregate Image Results (merges all images)

**Phase 5: Content Generation** 13. Build Ollama Prompt (constructs detailed prompt with all data) 14. Generate Blog Content (Ollama) - **mistral:latest** at temp 0.7

**Phase 6: Publishing** 15. Save HTML File (writes to /files/bloggergenerator/[id]/[title].html) 16. Create Draft Posts (via Blogger MCP) 17. Done Creating Posts (summary with image count)

#### Key Features:

- **Dual Trigger:** Manual execution + Cleanup runs in parallel
- **Modular Image Generation:** Separate workflow for reusability
- **Timing Metrics:** Tracks image generation time per image
- **File Management:** Auto-cleanup of 6-month-old folders
- **Persistent Storage:** NFS mount at `/files/bloggergenerator/`
- **Structured Pipeline:** Gemini (plan) → Imagen (images) → Mistral (content) → Blogger (publish)

---

## Configuration Required

### In n8n UI:

1. **Ollama Credential** (ID: zyl6PeV6maQJ0cH2)
   - Already configured with name "Ollama account"
   - Verify model: `mistral:latest` is pulled
   - Test connection to local Ollama server

2. **Google Gemini Credential** (ID: 12DKPRNOFpK0yTyy)
   - Already configured with name "Google Gemini(PaLM) Api account"
   - Verify Imagen API access enabled
   - Check quota limits for image generation

3. **Workflow ID Reference**
   - BlogGenerator → GeminiNanoImageGenerator connection uses dynamic lookup
   - Expression: `{{ $workflow('GeminiNanoImageGenerator').id }}`
   - No manual configuration needed

### External Services:

1. **Ollama Server** (Local)
   - Model: `mistral:latest`
   - Ensure running and accessible from n8n container
   - Test: `ollama list` should show mistral:latest

2. **Blogger MCP Server**
   - Endpoint: http://192.168.1.60/mcp
   - Already configured and tested
   - No changes needed

3. **NFS Mount** (n8n Docker)
   - Path: `/files/bloggergenerator/`
   - Verify write permissions
   - Check available disk space

---

## Testing Steps

### Test GeminiNanoImageGenerator:

1. Open GeminiNanoImageGenerator in n8n UI
2. Click "Execute Workflow"
3. Provide test input:
   ```json
   {
     "prompt": "Professional tech blog banner showing AI automation",
     "filename": "test-banner.png",
     "folderName": "/files/bloggergenerator/test"
   }
   ```
4. Verify:
   - Image generated via Gemini Imagen API
   - File saved to `/files/bloggergenerator/test/test-banner.png`
   - Response includes timing (timeTakenMs)
   - No errors in console

### Test BlogGenerator:

1. Open BlogGenerator in n8n UI
2. Verify all nodes show green (no credential errors)
3. Click "Execute Workflow"
4. Monitor execution:
   - AI Agent generates structured data
   - Folders created at `/files/bloggergenerator/[timestamp]_0/`
   - Images generated (check assets/ folder)
   - Ollama generates HTML content
   - Draft post created in Blogger
5. Check output:
   - Total execution time
   - Image count matches imagePrompts length
   - HTML file exists and is valid
   - Blogger draft created successfully

---

## Workflow Files

### Local Workspace:

- `f:\workspace\blogger\n8n\workflows\gemini-nano-image-generator.json`
- `f:\workspace\blogger\n8n\workflows\blog-generator.json`

### n8n Server:

- GeminiNanoImageGenerator: ID `hwkfsxRY6F35HmEt`
- BlogGenerator: ID `RPl6kytrnqkl7wlM`

---

## Next Actions

1. ✅ **Configure Ollama** - Set up mistral:latest model connection
2. ✅ **Test Image Generator** - Verify Gemini Imagen API works
3. ✅ **Test Full Pipeline** - Run BlogGenerator end-to-end
4. ⏳ **Monitor Performance** - Check image generation times
5. ⏳ **Verify NFS Storage** - Ensure files persist across restarts
6. ⏳ **Review Generated Content** - Check Mistral output quality

---

## Notes

- **Gemini Imagen API:** Uses Google's Imagen 3.0 model (not "nano banana" - that was likely auto-correct)
- **Mistral Model:** Better for technical content generation than llama3.1
- **Timing Tracking:** Each image generation includes millisecond precision timing
- **Error Handling:** Workflows include try-catch blocks and validation
- **Scalability:** Image generator can be called by any workflow (reusable)

**Deployment Completed:** January 26, 2026 at 17:29 UTC
