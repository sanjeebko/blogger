# ========================================
# DEPLOY FIXED BLOGGER MCP SERVER
# ========================================
#
# This script rebuilds and deploys the fixed Blogger MCP server
# with improved token refresh handling.
#
# Run from: F:\workspace\blogger\bloggerMCP
#

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🚀 Deploying Fixed Blogger MCP Server" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Rebuild Docker image
Write-Host "📦 Step 1: Building Docker image..." -ForegroundColor Yellow
docker build -f Dockerfile.python -t sanjeebojha/mcpserver-blogger:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Push to Docker Hub
Write-Host "📤 Step 2: Pushing to Docker Hub..." -ForegroundColor Yellow
docker push sanjeebojha/mcpserver-blogger:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker push failed!" -ForegroundColor Red
    Write-Host "   Make sure you're logged in: docker login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Image pushed to Docker Hub" -ForegroundColor Green
Write-Host ""

# Step 3: Instructions for Kubernetes
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  📋 Kubernetes Deployment Instructions" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The Docker image has been updated. Now you need to restart" -ForegroundColor White
Write-Host "the Kubernetes deployment on your K8s server (192.168.1.60)." -ForegroundColor White
Write-Host ""
Write-Host "Run these commands on your K8s server:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  kubectl rollout restart deployment/mcpserver-blogger-deployment -n prod" -ForegroundColor Cyan
Write-Host "  kubectl get pods -n prod -l app=mcpserver-blogger -w" -ForegroundColor Cyan
Write-Host ""
Write-Host "Wait for the new pod to be Running, then test:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  curl http://192.168.1.60/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ What Was Fixed" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. ✅ Improved token refresh logic" -ForegroundColor Green
Write-Host "   - Better error handling" -ForegroundColor White
Write-Host "   - Detailed logging" -ForegroundColor White
Write-Host "   - Distinguishes between refresh failure and missing token" -ForegroundColor White
Write-Host ""
Write-Host "2. ✅ Force refresh token request" -ForegroundColor Green
Write-Host "   - Always requests offline access" -ForegroundColor White
Write-Host "   - Ensures refresh_token is granted" -ForegroundColor White
Write-Host "   - Better user instructions" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🔍 After Deployment" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check logs for token refresh:" -ForegroundColor Yellow
Write-Host "   kubectl logs -n prod deployment/mcpserver-blogger-deployment --tail=50" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Look for these log messages:" -ForegroundColor Yellow
Write-Host "   ✅ 'Loaded credentials from token file'" -ForegroundColor Green
Write-Host "   ✅ 'Refreshing expired access token...'" -ForegroundColor Green
Write-Host "   ✅ 'Access token refreshed successfully'" -ForegroundColor Green
Write-Host "   ✅ 'Blogger service initialized successfully'" -ForegroundColor Green
Write-Host ""
Write-Host "3. Test with your AI agent:" -ForegroundColor Yellow
Write-Host "   - Should NOT ask for authentication" -ForegroundColor White
Write-Host "   - Should automatically refresh expired token" -ForegroundColor White
Write-Host "   - Should work indefinitely" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
