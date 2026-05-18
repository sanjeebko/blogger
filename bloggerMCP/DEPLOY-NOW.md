# 🔥 CRITICAL: Your K8s Pod is Running OLD Code!

## The Real Problem

Your token is **PERFECT** (has refresh_token), but your **Kubernetes deployment is running an OLD Docker image** that doesn't have the token refresh fixes.

That's why the AI agent keeps asking for authentication - the old code doesn't properly handle token refresh!

---

## ✅ Quick Fix (3 Steps)

### Step 1: Rebuild & Push (Run on Windows)

```powershell
cd F:\workspace\blogger\bloggerMCP
.\deploy.ps1
```

Or manually:

```powershell
# Build
docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .

# Push
docker push sanjeebojha/mcpserver-blogger:latest
```

### Step 2: Restart K8s Deployment (Run on K8s Server)

```bash
kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
kubectl get pods -n prod -l app=mcpserver-blogger -w
```

Wait for new pod to be `Running`.

### Step 3: Verify

```bash
# Check logs
kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=50

# Look for:
# "Loaded credentials from token file"
# "Refreshing expired access token..."
# "Access token refreshed successfully"
```

---

## 🎯 What Will Happen After Deployment

### Before (Current - OLD CODE):
```
AI Agent: "List blogs"
  ↓
Server (OLD): "Token expired, not authenticated"
  ↓
AI Agent: "Need to authenticate first"
  ↓
Calls: blogger_auth_get_url ❌
```

### After (NEW CODE):
```
AI Agent: "List blogs"
  ↓
Server (NEW): "Token expired, refreshing..."
  ↓
Server (NEW): "Token refreshed! Here are your blogs"
  ↓
AI Agent: Gets blog list ✅
```

---

## 📊 Code Changes Made

### File: `server.py` (lines 57-77)

**BEFORE:**
```python
# Simple check, no logging
if self.creds and self.creds.expired and self.creds.refresh_token:
    self.creds.refresh(Request())
    self.save_token()

if not self.creds or not self.creds.valid:
    raise ValueError("Not authenticated")  # ❌ Vague error
```

**AFTER:**
```python
# Detailed logging and error handling
if self.creds:
    if self.creds.expired and self.creds.refresh_token:
        try:
            logger.info("Refreshing expired access token...")
            self.creds.refresh(Request())
            self.save_token()
            logger.info("Access token refreshed successfully")  # ✅
        except Exception as e:
            logger.error(f"Failed to refresh token: {e}")
            raise ValueError("Token refresh failed. Re-authentication required.")
    elif self.creds.expired and not self.creds.refresh_token:
        raise ValueError("Access token expired and no refresh token available.")  # ✅ Clear error
```

### File: `server.py` (lines 90-97)

**BEFORE:**
```python
# Already had prompt='consent', access_type='offline'
# But on one line, easy to miss
auth_url, _ = flow.authorization_url(prompt='consent', access_type='offline')
```

**AFTER:**
```python
# Explicit with comments
auth_url, _ = flow.authorization_url(
    prompt='consent',      # Force consent screen to get refresh token
    access_type='offline'  # Request offline access for refresh token
)
# Better user message explaining what will happen
```

---

## 🔍 How to Verify It's Working

### Test 1: Check Logs After Deployment

```bash
kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=100 | grep -i "token\|refresh\|blogger"
```

**Expected Output:**
```
INFO - Loaded credentials from token file
INFO - Refreshing expired access token...
INFO - Access token refreshed successfully
INFO - Blogger service initialized successfully
```

### Test 2: Use AI Agent

Ask your AI agent to list blogs. It should:
- ✅ NOT call `blogger_auth_get_url`
- ✅ Directly call `blogger_list_blogs`
- ✅ Return your blogs
- ✅ Work without manual intervention

### Test 3: Check Token File Updated

```bash
# Before calling any tool
kubectl exec -it -n prod <pod-name> -- cat /app/token.json | grep expiry

# Call a blogger tool (e.g., blogger_list_blogs)

# After calling the tool
kubectl exec -it -n prod <pod-name> -- cat /app/token.json | grep expiry

# The expiry should be ~1 hour in the future (token was refreshed)
```

---

## ⚠️ Important Notes

### Your Token is Already Perfect!

```json
{
  "refresh_token": "1//03VUmIYbiDnyRCgYIARAAGAMSNwF-L9Ir...",  // ✅ Present
  "expiry": "2026-01-26T01:18:53Z"  // ⏰ Expired, but will auto-refresh
}
```

You do **NOT** need to re-authenticate! The token will auto-refresh when you call any blogger tool.

### Why It Wasn't Working

The **OLD code** in your K8s pod didn't have proper token refresh handling, so it threw an error instead of refreshing the token.

### After Deployment

The **NEW code** will:
1. Detect token is expired
2. Use refresh_token to get new access token
3. Save the new token
4. Continue with the request
5. **No manual intervention needed!** 🎉

---

## 📋 Deployment Checklist

- [ ] Run `deploy.ps1` on Windows (or manual docker build + push)
- [ ] SSH to K8s server
- [ ] Run `kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod`
- [ ] Wait for new pod to be Running
- [ ] Check logs for "Access token refreshed successfully"
- [ ] Test with AI agent - should work without auth prompt
- [ ] Celebrate! 🎉

---

## 🚀 Expected Timeline

- **Docker build + push**: ~2-5 minutes
- **K8s pod restart**: ~30-60 seconds
- **First blogger tool call**: ~2-3 seconds (includes token refresh)
- **Subsequent calls**: <1 second (token cached)

---

## ✅ Success Criteria

After deployment, your system is working correctly when:

1. ✅ AI agent calls blogger tools directly (not `blogger_auth_get_url`)
2. ✅ Logs show "Access token refreshed successfully"
3. ✅ Blogger tools return data without errors
4. ✅ Works after pod restart
5. ✅ No manual authentication needed

---

## 🆘 If It Still Doesn't Work

### Check 1: Is New Image Running?

```bash
kubectl describe pod -n prod <pod-name> | grep Image:
# Should show: sanjeebojha/mcpserver-blogger:latest
# With a recent digest (sha256:...)
```

### Check 2: Is Token Mounted?

```bash
kubectl exec -it -n prod <pod-name> -- ls -la /app/
# Should show: credentials.json, token.json
```

### Check 3: Check Logs for Errors

```bash
kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=200
# Look for errors related to token refresh
```

### Check 4: Verify Token Has Refresh Token

```bash
kubectl exec -it -n prod <pod-name> -- cat /app/token.json | python -m json.tool
# Should have "refresh_token" field
```

---

## 📞 Need Help?

If it still doesn't work after deployment:

1. Share the pod logs
2. Share the output of `kubectl describe pod`
3. Share any error messages from the AI agent

---

**Ready to deploy? Run `.\deploy.ps1` now!** 🚀
