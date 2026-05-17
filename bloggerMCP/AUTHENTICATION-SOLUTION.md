# 🔐 Blogger MCP Server - Robust Authentication Solution

## Problem

Your Blogger MCP server keeps asking for OAuth2 authentication because:

1. **Token expiration**: OAuth2 tokens expire and need refresh
2. **Token not persisted**: The `token.json` file may not be properly mounted in Docker
3. **Refresh token missing**: Initial auth might not have requested offline access properly
4. **Not suitable for automation**: Interactive OAuth2 flow requires manual browser interaction

---

## ✅ Solution: Make Authentication Robust for Automation

### Option 1: Service Account (RECOMMENDED for Automation)

**Problem**: Google Blogger API doesn't support service accounts directly.

**Workaround**: Use a long-lived refresh token that auto-renews.

### Option 2: Persistent Refresh Token (CURRENT BEST APPROACH)

This is what your server already supports, but needs proper setup:

#### Step 1: One-Time Manual Authentication

Do this ONCE to get a persistent refresh token:

```bash
# 1. Start your MCP server locally (not in Docker yet)
cd F:\workspace\blogger\bloggerMCP
python src/server.py

# 2. In another terminal or through your MCP client:
# Call blogger_auth_get_url
# Open the URL in browser
# Copy the redirect URL
# Call blogger_auth_complete_flow with the URL

# 3. Verify token.json was created
cat token.json  # Should contain refresh_token
```

#### Step 2: Verify Token Has Refresh Token

Check your `token.json` file:

```json
{
  "token": "ya29.xxx",
  "refresh_token": "1//xxx",  // ← THIS IS CRITICAL!
  "token_uri": "https://oauth2.googleapis.com/token",
  "client_id": "xxx.apps.googleusercontent.com",
  "client_secret": "xxx",
  "scopes": ["https://www.googleapis.com/auth/blogger"],
  "expiry": "2026-01-27T14:00:00Z"
}
```

**If `refresh_token` is missing**, you need to re-authenticate with `prompt=consent` and `access_type=offline`.

#### Step 3: Fix Server Code for Better Token Handling

Your server code at lines 70-72 already handles token refresh:

```python
# Refresh token if expired
if self.creds and self.creds.expired and self.creds.refresh_token:
    self.creds.refresh(Request())
    self.save_token()
```

But there's a problem at line 74-75:

```python
if not self.creds or not self.creds.valid:
    raise ValueError("Not authenticated. Use blogger_auth_get_url first.")
```

This throws an error even when a refresh token exists but the access token is expired.

**FIX**: Update the logic to handle refresh better.

---

## 🔧 Code Fixes

### Fix 1: Improve Token Refresh Logic

Update `server.py` lines 57-77:

```python
def init_service(self):
    """Initialize Google Blogger API service"""
    if not Path(CREDENTIALS_PATH).exists():
        raise FileNotFoundError(f"Credentials file not found: {CREDENTIALS_PATH}")
    
    # Load existing token if available
    if Path(TOKEN_PATH).exists():
        try:
            self.creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)
            logger.info("Loaded credentials from token file")
        except Exception as e:
            logger.warning(f"Failed to load token: {e}")
            self.creds = None
    
    # Refresh token if expired
    if self.creds:
        if self.creds.expired and self.creds.refresh_token:
            try:
                logger.info("Refreshing expired access token...")
                self.creds.refresh(Request())
                self.save_token()
                logger.info("Access token refreshed successfully")
            except Exception as e:
                logger.error(f"Failed to refresh token: {e}")
                raise ValueError("Token refresh failed. Re-authentication required.")
        elif self.creds.expired and not self.creds.refresh_token:
            raise ValueError("Access token expired and no refresh token available. Re-authenticate with blogger_auth_get_url.")
    
    if not self.creds or not self.creds.valid:
        raise ValueError("Not authenticated. Use blogger_auth_get_url first.")
    
    self.service = build('blogger', 'v3', credentials=self.creds)
    logger.info("Blogger service initialized successfully")
```

### Fix 2: Ensure Refresh Token is Requested

Update `blogger_auth_get_url()` at line 91-97:

```python
@mcp.tool()
def blogger_auth_get_url() -> str:
    """Get OAuth2 authorization URL for first-time setup"""
    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
    flow.redirect_uri = 'http://localhost'
    
    # IMPORTANT: prompt='consent' ensures refresh_token is always returned
    auth_url, _ = flow.authorization_url(
        prompt='consent',      # Force consent screen to get refresh token
        access_type='offline'  # Request offline access for refresh token
    )
    
    return f"""Open this URL in your browser:
{auth_url}

The browser will redirect to localhost. Copy the FULL URL from the browser address bar and use blogger_auth_complete_flow with that URL.

IMPORTANT: This will generate a refresh token that allows automatic token renewal without re-authentication."""
```

---

## 🐳 Docker Deployment with Persistent Token

### Fix 3: Proper Volume Mounting

Your current Docker run command needs to ensure `token.json` persists:

```bash
# Create a directory for persistent data
mkdir -p /path/to/blogger-data

# Copy your credentials.json there
cp credentials.json /path/to/blogger-data/

# Create empty token.json
echo '{}' > /path/to/blogger-data/token.json

# Run Docker with proper volume mounting
docker run -d \
  --name blogger-mcp \
  -p 8081:8081 \
  -v /path/to/blogger-data:/app:rw \
  -e PORT=8081 \
  sanjeebojha/mcpserver-blogger:latest
```

**Key Points**:
- Mount the entire `/app` directory as read-write (`:rw`)
- This ensures `token.json` changes persist across container restarts
- Both `credentials.json` and `token.json` are in the same mounted directory

---

## 🚀 Complete Setup Workflow

### 1. Initial Setup (One Time)

```bash
# 1. Prepare data directory
mkdir -p ~/blogger-mcp-data
cp credentials.json ~/blogger-mcp-data/
echo '{}' > ~/blogger-mcp-data/token.json

# 2. Start Docker container
docker run -d \
  --name blogger-mcp \
  -p 8081:8081 \
  -v ~/blogger-mcp-data:/app:rw \
  -e PORT=8081 \
  sanjeebojha/mcpserver-blogger:latest

# 3. Authenticate (via MCP client or curl)
# Call blogger_auth_get_url
# Open URL in browser
# Copy redirect URL
# Call blogger_auth_complete_flow with redirect URL

# 4. Verify token was saved
cat ~/blogger-mcp-data/token.json
# Should contain "refresh_token" field
```

### 2. Verify Auto-Refresh Works

```bash
# Wait for token to expire (or manually edit token.json to set expiry to past)
# Then call any blogger tool:
# - If it works without asking for auth → SUCCESS!
# - If it asks for auth again → Check logs for errors
```

### 3. Check Logs

```bash
docker logs blogger-mcp

# Look for:
# - "Loaded credentials from token file"
# - "Refreshing expired access token..."
# - "Access token refreshed successfully"
```

---

## 🔍 Troubleshooting

### Issue: "Not authenticated" error even with token.json

**Cause**: Token doesn't have `refresh_token` field

**Solution**:
1. Delete `token.json`
2. Re-authenticate using `blogger_auth_get_url` (ensure the fix in Fix 2 is applied)
3. Verify new `token.json` has `refresh_token`

### Issue: "Token refresh failed"

**Cause**: Refresh token was revoked or credentials.json changed

**Solution**:
1. Go to https://myaccount.google.com/permissions
2. Revoke access to your app
3. Delete `token.json`
4. Re-authenticate

### Issue: Token.json changes not persisting

**Cause**: Docker volume not mounted correctly

**Solution**:
```bash
# Check if volume is mounted
docker inspect blogger-mcp | grep -A 10 Mounts

# Should show:
# "Source": "/path/to/blogger-data",
# "Destination": "/app",
# "RW": true
```

---

## 📊 Kubernetes Deployment

For your Kubernetes deployment at `192.168.1.60`:

### Create PersistentVolume for Token Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: blogger-mcp-data
  namespace: prod
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### Update Deployment to Use PVC

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mcpserver-blogger-deployment
  namespace: prod
spec:
  template:
    spec:
      containers:
      - name: blogger-mcp
        image: sanjeebojha/mcpserver-blogger:latest
        volumeMounts:
        - name: blogger-data
          mountPath: /app
      volumes:
      - name: blogger-data
        persistentVolumeClaim:
          claimName: blogger-mcp-data
```

### Initial Setup on K8s

```bash
# 1. Copy credentials to pod
kubectl cp credentials.json prod/mcpserver-blogger-deployment-xxx:/app/credentials.json

# 2. Create empty token file
kubectl exec -it -n prod mcpserver-blogger-deployment-xxx -- sh -c "echo '{}' > /app/token.json"

# 3. Authenticate via MCP client
# 4. Verify token persists across pod restarts
kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod
# Wait for new pod
# Test blogger tools - should work without re-auth
```

---

## ✅ Success Criteria

Your authentication is robust when:

1. ✅ `token.json` contains `refresh_token` field
2. ✅ Token auto-refreshes when expired (check logs)
3. ✅ No re-authentication needed after container/pod restart
4. ✅ Automated systems can use blogger tools without manual intervention
5. ✅ Token persists across deployments

---

## 🎯 Next Steps

1. Apply Fix 1 and Fix 2 to `server.py`
2. Rebuild Docker image
3. Deploy with proper volume mounting
4. Do one-time authentication
5. Verify token has refresh_token
6. Test auto-refresh by waiting for token expiry
7. Deploy to Kubernetes with PVC

After this setup, your automated systems will never need manual authentication again! 🎉
