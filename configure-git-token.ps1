# Automated GitHub Authentication Setup
# This script configures Git to use your Personal Access Token automatically

param(
    [Parameter(Mandatory=$true)]
    [string]$PersonalAccessToken
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Configuring Automated GitHub Authentication" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Configure Git user
Write-Host "Setting Git user configuration..." -ForegroundColor Yellow
git config --global user.name "sanjeebko"
git config --global user.email "sanjeebko@users.noreply.github.com"

# Configure credential helper to use store (plaintext - use with caution)
Write-Host "Configuring credential storage..." -ForegroundColor Yellow
git config --global credential.helper store

# Create credentials file with token
$credentialsPath = "$env:USERPROFILE\.git-credentials"
$credentials = "https://sanjeebko:$PersonalAccessToken@github.com"

# Write credentials to file
Write-Host "Storing credentials..." -ForegroundColor Yellow
Set-Content -Path $credentialsPath -Value $credentials -Force

Write-Host ""
Write-Host "? Configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your credentials are stored at: $credentialsPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "??  SECURITY WARNING:" -ForegroundColor Yellow
Write-Host "The token is stored in plaintext. Keep this file secure!" -ForegroundColor Red
Write-Host ""
Write-Host "To test, run:" -ForegroundColor Cyan
Write-Host "  git push -u origin develop" -ForegroundColor Yellow
Write-Host ""
Write-Host "MCP server will now push automatically without prompts!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
