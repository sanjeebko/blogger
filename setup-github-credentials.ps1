# GitHub Credential Helper for MCP
# This script helps configure Git to use your Personal Access Token

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  GitHub Credential Configuration for MCP Server" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Configure Git to use Windows Credential Manager
Write-Host "Configuring Git credential helper..." -ForegroundColor Yellow
git config --global credential.helper wincred

# Set GitHub username
Write-Host "Setting GitHub username: sanjeebko" -ForegroundColor Yellow
git config --global user.name "sanjeebko"

# Prompt for email
$email = Read-Host "Enter your GitHub email for sanjeebko account"
git config --global user.email $email

Write-Host ""
Write-Host "? Git configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Create a Personal Access Token at:" -ForegroundColor White
Write-Host "   https://github.com/settings/tokens/new" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Select scope: 'repo' (Full control of private repositories)" -ForegroundColor White
Write-Host ""
Write-Host "3. Run the following command to store your credentials:" -ForegroundColor White
Write-Host "   git push -u origin develop" -ForegroundColor Yellow
Write-Host ""
Write-Host "   When prompted:" -ForegroundColor White
Write-Host "   Username: sanjeebko" -ForegroundColor Yellow
Write-Host "   Password: <paste-your-PAT-token>" -ForegroundColor Yellow
Write-Host ""
Write-Host "After this one-time setup, MCP server will push automatically!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
