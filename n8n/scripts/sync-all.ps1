# n8n Workflow Sync Script - Sync All Workflows

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('ToServer', 'FromServer')]
    [string]$Direction,
    
    [Parameter(Mandatory = $false)]
    [string]$N8nHost = $env:N8N_HOST,
    
    [Parameter(Mandatory = $false)]
    [string]$ApiKey = $env:N8N_API_KEY,
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
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

$workflowsDir = "workflows"
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$rootDir = Split-Path $scriptDir -Parent

Set-Location $rootDir

if ($Direction -eq 'ToServer') {
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Syncing LOCAL workflows TO n8n server" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $workflowFiles = Get-ChildItem -Path $workflowsDir -Filter "*.json" -File
    
    if ($workflowFiles.Count -eq 0) {
        Write-Warning "No workflow files found in $workflowsDir"
        exit 0
    }
    
    Write-Host "Found $($workflowFiles.Count) workflow(s) to import" -ForegroundColor Yellow
    Write-Host ""
    
    $imported = 0
    $failed = 0
    
    foreach ($file in $workflowFiles) {
        Write-Host "Importing: $($file.Name)..." -NoNewline
        
        if ($DryRun) {
            Write-Host " [DRY RUN - Skipped]" -ForegroundColor Yellow
            continue
        }
        
        try {
            & "$scriptDir\import-workflow.ps1" -File $file.FullName -N8nHost $N8nHost -ApiKey $ApiKey
            Write-Host " ✅" -ForegroundColor Green
            $imported++
        }
        catch {
            Write-Host " ❌" -ForegroundColor Red
            Write-Error "Failed to import $($file.Name): $_"
            $failed++
        }
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Summary" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Total: $($workflowFiles.Count) | Imported: $imported | Failed: $failed"
}
else {
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Syncing n8n server workflows TO LOCAL" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Get all workflows from n8n
    $apiUrl = "$N8nHost/api/v1/workflows"
    $headers = @{
        "X-N8N-API-KEY" = $ApiKey
    }
    
    try {
        $workflows = Invoke-RestMethod -Uri $apiUrl -Method GET -Headers $headers
        Write-Host "Found $($workflows.data.Count) workflow(s) on server" -ForegroundColor Yellow
        Write-Host ""
        
        $exported = 0
        $failed = 0
        
        foreach ($workflow in $workflows.data) {
            $workflowName = $workflow.name -replace '[^a-zA-Z0-9-]', '-' -replace '--+', '-'
            $outputFile = "$workflowsDir\$workflowName.json"
            
            Write-Host "Exporting: $($workflow.name) → $outputFile..." -NoNewline
            
            if ($DryRun) {
                Write-Host " [DRY RUN - Skipped]" -ForegroundColor Yellow
                continue
            }
            
            try {
                & "$scriptDir\export-workflow.ps1" -WorkflowId $workflow.id -OutputFile $outputFile -N8nHost $N8nHost -ApiKey $ApiKey
                Write-Host " ✅" -ForegroundColor Green
                $exported++
            }
            catch {
                Write-Host " ❌" -ForegroundColor Red
                Write-Error "Failed to export $($workflow.name): $_"
                $failed++
            }
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  Summary" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "Total: $($workflows.data.Count) | Exported: $exported | Failed: $failed"
    }
    catch {
        Write-Error "Failed to fetch workflows from server: $_"
        exit 1
    }
}
