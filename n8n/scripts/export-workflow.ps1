# n8n Workflow Export Script

param(
    [Parameter(Mandatory = $true)]
    [string]$WorkflowId,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile,
    
    [Parameter(Mandatory = $false)]
    [string]$N8nHost = $env:N8N_HOST,
    
    [Parameter(Mandatory = $false)]
    [string]$ApiKey = $env:N8N_API_KEY
)

# Validate inputs
if (-not $N8nHost) {
    Write-Error "N8N_HOST environment variable not set. Use -N8nHost parameter or set N8N_HOST env var."
    exit 1
}

if (-not $ApiKey) {
    Write-Error "N8N_API_KEY environment variable not set. Use -ApiKey parameter or set N8N_API_KEY env var."
    exit 1
}

# Prepare API request
$apiUrl = "$N8nHost/api/v1/workflows/$WorkflowId"
$headers = @{
    "X-N8N-API-KEY" = $ApiKey
}

# Export workflow
Write-Host "Exporting workflow ID $WorkflowId from n8n server: $N8nHost" -ForegroundColor Cyan
try {
    $workflow = Invoke-RestMethod -Uri $apiUrl -Method GET -Headers $headers
    
    # Determine output file
    if (-not $OutputFile) {
        $workflowName = $workflow.name -replace '[^a-zA-Z0-9-]', '-' -replace '--+', '-'
        $OutputFile = "workflows\$workflowName.json"
    }
    
    # Ensure directory exists
    $outputDir = Split-Path $OutputFile -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    # Save to file
    $workflow | ConvertTo-Json -Depth 100 | Set-Content $OutputFile -Encoding UTF8
    
    Write-Host "✅ Workflow exported successfully!" -ForegroundColor Green
    Write-Host "Saved to: $OutputFile" -ForegroundColor Green
    Write-Host "Workflow Name: $($workflow.name)" -ForegroundColor Green
    
    return $workflow
}
catch {
    Write-Error "Failed to export workflow: $_"
    exit 1
}
