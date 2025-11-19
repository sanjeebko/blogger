# GitHub Account Configuration

## Account Separation

### Copilot Chat (VS Code/Visual Studio)
- **Account:** bhumikakhadka
- **Purpose:** GitHub Copilot suggestions and chat
- **Authentication:** GitHub account linked to Copilot subscription

### Git Operations & MCP Server
- **Account:** sanjeebko
- **Purpose:** Repository management, commits, pushes
- **Authentication:** Personal Access Token (PAT)

## Setup Instructions

### 1. Create Personal Access Token
1. Go to: https://github.com/settings/tokens/new
2. Token name: `MCP Server - Blogger Repository`
3. Expiration: 90 days (or as needed)
4. Select scopes:
   - ? **repo** (all sub-options)
   - ? **workflow** (for GitHub Actions)
5. Generate and **copy the token**

### 2. Configure Git Credentials
```powershell
# Run the setup script
.\setup-github-credentials.ps1

# Or manually:
git config --global credential.helper wincred
git config --global user.name "sanjeebko"
git config --global user.email "your-email@example.com"
```

### 3. Store Credentials (One-time)
```powershell
git push -u origin develop
```
When prompted:
- Username: `sanjeebko`
- Password: `<your-PAT-token>`

### 4. Verify Configuration
```powershell
# Check current config
git config --global --list | Select-String "user|credential"

# Test push (should work without prompting)
git push
```

## How It Works

1. **Windows Credential Manager** stores your PAT securely
2. **Git** automatically retrieves credentials when needed
3. **MCP Server** uses Git, which uses the cached credentials
4. **No more popups** - Everything automated!

## Security Notes

- Token is stored in Windows Credential Manager (encrypted)
- Token has specific repository access only
- Token can be revoked anytime at: https://github.com/settings/tokens
- Use fine-grained tokens for better security

## Troubleshooting

### If push still asks for credentials:
```powershell
# Clear cached credentials
git credential reject
# protocol=https
# host=github.com
# <press Enter twice>

# Then re-authenticate
git push -u origin develop
```

### If using wrong account:
```powershell
# Check current credentials
cmdkey /list | findstr github

# Remove GitHub credentials
cmdkey /delete:git:https://github.com

# Re-authenticate with correct account
git push -u origin develop
```

### If MCP server still fails:
- Ensure Windows Credential Manager has the entry
- Check token hasn't expired
- Verify token has correct permissions
- Try creating a new token

## Alternative: SSH Keys (More Secure)

If you prefer SSH:
```powershell
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to GitHub: https://github.com/settings/keys

# Change remote URL
git remote set-url origin git@github.com:sanjeebko/blogger.git

# Test
ssh -T git@github.com
```
