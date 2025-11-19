# ⚡ FASTEST SETUP - Just add your token and run!

# 1. Get your token: https://github.com/settings/tokens/new
#    Required scope: 'repo'
#
# 2. Replace the line below with your actual token:
$token = "ghp_YOUR_TOKEN_GOES_HERE"

# 3. Run this script: .\SETUP-TOKEN.ps1
# 4. Done! MCP server will push automatically!

# ============================================
# Don't edit below this line
# ============================================

if ($token -eq "ghp_YOUR_TOKEN_GOES_HERE") {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  ⚠️  SETUP REQUIRED" -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please edit this script and add your GitHub token:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Open: SETUP-TOKEN.ps1" -ForegroundColor Cyan
    Write-Host "2. Go to: https://github.com/settings/tokens/new" -ForegroundColor Cyan
    Write-Host "3. Create token with 'repo' scope" -ForegroundColor Cyan
    Write-Host "4. Replace 'ghp_YOUR_TOKEN_GOES_HERE' with your actual token" -ForegroundColor Cyan
    Write-Host "5. Save and run this script again" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 Configuring Automated GitHub Authentication" -ForegroundColor White
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Update remote URL with embedded token
Write-Host "📝 Embedding token in Git remote URL..." -ForegroundColor Yellow
$remoteUrl = "https://sanjeebko:$token@github.com/sanjeebko/blogger.git"
git remote set-url origin $remoteUrl

Write-Host "✅ Configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✨ MCP Server is Ready!" -ForegroundColor White
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test it now:" -ForegroundColor Cyan
Write-Host "  git push -u origin develop" -ForegroundColor White
Write-Host ""
Write-Host "No prompts. No popups. Automatic authentication! 🎉" -ForegroundColor Green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
