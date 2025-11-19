# GitHub Authentication - Quick Setup Guide

## ?? EASIEST METHOD: Embed Token in Repository URL

This is the **most automated** approach - no prompts, no manual steps after initial setup.

### Step 1: Get Your Personal Access Token

1. Go to: **https://github.com/settings/tokens/new**
2. **Note:** `MCP Server - Blogger Repo`
3. **Expiration:** 90 days (or your preference)
4. **Select scopes:** 
   - ? **repo** (check this box - includes all sub-options)
5. Click **"Generate token"**
6. **COPY THE TOKEN** immediately (you won't see it again!)

### Step 2: Edit and Run the Script

1. Open: **`embed-token-in-url.ps1`**
2. Replace `YOUR_TOKEN_HERE` with your actual token:
   ```powershell
   $token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   ```
3. Save the file
4. Run in PowerShell:
   ```powershell
   .\embed-token-in-url.ps1
   ```

### Step 3: Test It

```powershell
git push -u origin develop
```

? **No prompt! No popup! Automatic push!**

---

## ?? How It Works

The token is embedded directly in the Git remote URL:
```
https://sanjeebko:YOUR_TOKEN@github.com/sanjeebko/blogger.git
```

When MCP server (or Git) needs to push:
1. Git reads the remote URL from `.git/config`
2. Extracts the username and token automatically
3. Authenticates without any user interaction
4. Push succeeds immediately!

---

## ?? Security Considerations

**IMPORTANT:** The token will be stored in:
- `.git/config` file (plaintext)
- Visible when you run: `git remote -v`

**Recommendations:**
1. ? Keep this repository **private**
2. ? Set token expiration (90 days recommended)
3. ? Use token with **minimal required permissions** (just `repo`)
4. ? Consider using **fine-grained tokens** (per-repository access)
5. ? Add `.git/config` to `.gitignore` if sharing repo (already excluded by Git)
6. ? **Never commit** the token to a public repository

---

## ?? Alternative Methods (If You Change Your Mind)

### Method 2: Git Credential Store
```powershell
.\configure-git-token.ps1 -PersonalAccessToken "your_token_here"
```
- Stores token in `~/.git-credentials`
- Works across all repositories
- Slightly less convenient but more flexible

### Method 3: Windows Credential Manager
```powershell
.\setup-github-credentials.ps1
git push -u origin develop  # Enter token once
```
- Most secure (encrypted storage)
- One-time manual entry required
- Best for production use

---

## ? Recommended: Method 1 (Embedded URL)

**For your use case (automating MCP server):**
- ? Zero prompts after setup
- ? Works immediately
- ? Simple to understand
- ? Easy to update (just run script again)
- ? Repository-specific (doesn't affect other repos)

**Just run:**
1. Edit `embed-token-in-url.ps1`
2. Add your token
3. Run the script
4. Done! ?

---

## ?? Next Steps After Setup

Once configured, the MCP server will be able to:
```powershell
# Push code automatically (no prompts!)
git push origin develop

# MCP server can also use:
github_sanjeebko_commit_and_push -branch develop -message "your message" -repoPath .
```

Everything will work automatically! ??
