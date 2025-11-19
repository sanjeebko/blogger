# Quick Git Token Configuration
# Replace YOUR_TOKEN_HERE with your actual GitHub Personal Access Token

# STEP 1: Create your token at: https://github.com/settings/tokens/new
# Required scope: 'repo'

# STEP 2: Replace YOUR_TOKEN_HERE below with your actual token
$token = "YOUR_TOKEN_HERE"

# STEP 3: Run this script
if ($token -eq "YOUR_TOKEN_HERE") {
    Write-Host "? ERROR: Please edit this script and replace YOUR_TOKEN_HERE with your actual token!" -ForegroundColor Red
    exit 1
}

# Configure Git
Write-Host "Configuring Git with your token..." -ForegroundColor Cyan

# Set user info
git config --global user.name "sanjeebko"
git config --global user.email "sanjeebko@users.noreply.github.com"

# Use store credential helper (stores token in plaintext)
git config --global credential.helper store

# Create credential file
$credPath = "$env:USERPROFILE\.git-credentials"
$cred = "https://sanjeebko:$token@github.com"
Set-Content -Path $credPath -Value $cred -Force

Write-Host "? Done! Git is configured to use your token automatically." -ForegroundColor Green
Write-Host ""
Write-Host "Now try: git push -u origin develop" -ForegroundColor Yellow
