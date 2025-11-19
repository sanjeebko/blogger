# Embed Token in Git Remote URL
# This is the MOST automated approach - token is embedded in the repository URL

# INSTRUCTIONS:
# 1. Get your token from: https://github.com/settings/tokens/new (scope: 'repo')
# 2. Replace YOUR_TOKEN_HERE below
# 3. Run this script

$token = "YOUR_TOKEN_HERE"

if ($token -eq "YOUR_TOKEN_HERE") {
    Write-Host "? Please edit this script and add your GitHub Personal Access Token!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Get token from: https://github.com/settings/tokens/new" -ForegroundColor Yellow
    Write-Host "Required scope: repo" -ForegroundColor Yellow
    exit 1
}

Write-Host "Updating Git remote URL with embedded token..." -ForegroundColor Cyan

# Update remote URL to include token
$remoteUrl = "https://sanjeebko:$token@github.com/sanjeebko/blogger.git"
git remote set-url origin $remoteUrl

Write-Host "? Remote URL updated!" -ForegroundColor Green
Write-Host ""
Write-Host "Token is now embedded in the repository URL." -ForegroundColor Cyan
Write-Host "MCP server can now push without any authentication prompts!" -ForegroundColor Green
Write-Host ""
Write-Host "Test it:" -ForegroundColor Yellow
Write-Host "  git push -u origin develop" -ForegroundColor White
Write-Host ""
Write-Host "??  Security Note:" -ForegroundColor Yellow
Write-Host "Token is visible in .git/config - keep this repository private!" -ForegroundColor Red
