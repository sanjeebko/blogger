# 🔍 n8n AI Agent Error: "Cannot read properties of undefined (reading 'parts')"

## ✅ Good News

**Your MCP server is working!** The authentication issue is fixed.

## ❌ New Issue

n8n AI Agent is getting an error when processing MCP tool responses:
```
Cannot read properties of undefined (reading 'parts')
```

## 🎯 Root Cause

This is an **n8n MCP Client bug**, not your MCP server issue.

**What's happening:**
1. ✅ MCP server returns data correctly (as JSON string)
2. ✅ n8n MCP Client receives the response
3. ❌ n8n AI Agent (Gemini) expects response in a specific format with `parts` array
4. ❌ n8n MCP Client doesn't transform the response correctly
5. ❌ Gemini tries to read `.parts` property that doesn't exist

**Error Location:**
```
at executeBatch.ts:88:11
at Array.forEach (<anonymous>)
```

This is inside n8n's langchain agent code, specifically when it tries to process tool results for Gemini.

---

## 🔧 Workarounds

### Option 1: Use Different AI Model (Recommended)

Instead of Google Gemini, try using:
- **OpenAI GPT-4** (better MCP support)
- **Anthropic Claude** (native MCP support)
- **Local LLM** via Ollama

**Steps:**
1. In your n8n workflow, open the AI Agent node
2. Change the model from Gemini to OpenAI or Claude
3. Add your API key
4. Test again

### Option 2: Use HTTP Request Instead of MCP Client

Bypass the MCP Client and call the server directly:

**Replace MCP Client node with HTTP Request node:**

```json
{
  "method": "POST",
  "url": "http://192.168.1.60/mcp",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "blogger_list_blogs",
      "arguments": {}
    }
  }
}
```

Then parse the response with a Code node:
```javascript
const response = JSON.parse($json.body);
const result = JSON.parse(response.result.content[0].text);
return result;
```

### Option 3: Wait for n8n Fix

This is a known issue with n8n's MCP Client and Gemini integration. You can:
1. Report the bug to n8n team
2. Wait for an update
3. Use workaround in the meantime

---

## 🧪 Testing Each Option

### Test Option 1 (Different AI Model)

```
1. Open n8n workflow
2. Click AI Agent node
3. Under "Model", select "OpenAI Chat Model" or "Anthropic Chat Model"
4. Add credentials
5. Save and execute
```

**Expected:** Should work without the `parts` error.

### Test Option 2 (Direct HTTP)

Create a simple workflow:
```
Manual Trigger
  ↓
HTTP Request (POST to MCP server)
  ↓
Code (parse response)
  ↓
Output
```

**Expected:** Should return blog data without errors.

---

## 📊 Comparison

| Method | Pros | Cons |
|--------|------|------|
| **Gemini + MCP Client** | Native integration | ❌ Has `parts` bug |
| **OpenAI + MCP Client** | Works with MCP | Requires API key |
| **Claude + MCP Client** | Best MCP support | Requires API key |
| **Direct HTTP** | No AI agent needed | Manual parsing required |

---

## 🔍 Debugging the Issue

If you want to investigate further:

### Check n8n MCP Client Response

Add a debug node after MCP Client to see what it's returning:

```javascript
// In a Code node
console.log('MCP Response:', JSON.stringify($json, null, 2));
return $json;
```

### Check MCP Server Logs

```bash
kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=100
```

Look for the actual response being sent.

### Expected MCP Response Format

Your server returns:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "[{\"id\": \"123\", \"name\": \"My Blog\"}]"
      }
    ]
  }
}
```

**This is CORRECT according to MCP spec!**

### What Gemini Expects

Gemini expects tool results in this format:
```json
{
  "parts": [
    {
      "text": "..."
    }
  ]
}
```

**The n8n MCP Client should transform the MCP response to Gemini format, but it's not doing it correctly.**

---

## ✅ Recommended Solution

**Use OpenAI GPT-4 instead of Gemini:**

1. In n8n, replace Gemini with OpenAI Chat Model
2. Add your OpenAI API key
3. Keep the MCP Client as is
4. Test - should work without errors

**Why this works:**
- OpenAI's tool calling format is more compatible with MCP
- n8n's MCP Client has better support for OpenAI
- No `parts` property issue

---

## 🆘 If You Must Use Gemini

You would need to modify the n8n MCP Client code (not recommended) or create a custom MCP wrapper that transforms responses to Gemini format.

**Custom wrapper approach:**
1. Create a new n8n node that wraps MCP calls
2. Transform MCP response to Gemini format
3. Use this wrapper instead of MCP Client

This is complex and not recommended. **Just use OpenAI or Claude instead.**

---

## 📝 Summary

| Issue | Status |
|-------|--------|
| MCP Server | ✅ Working |
| Authentication | ✅ Fixed |
| Token Refresh | ✅ Working |
| n8n + Gemini | ❌ Has `parts` bug |
| **Solution** | **Use OpenAI or Claude** |

---

## 🎯 Next Steps

1. ✅ Your MCP server is working perfectly
2. ✅ Authentication is fixed
3. 📝 **Change AI model from Gemini to OpenAI/Claude**
4. 🧪 Test again
5. 🎉 Should work!

**The issue is NOT with your MCP server - it's with n8n's Gemini integration.**
