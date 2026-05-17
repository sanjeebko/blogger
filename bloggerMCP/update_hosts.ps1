$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$entry = "192.168.1.60 blogger-mcp.local"

try {
    if (-not (Select-String -Path $hostsPath -Pattern "192.168.1.60" -SimpleMatch -Quiet)) {
        Add-Content -Path $hostsPath -Value "`r`n$entry"
        Write-Host "Successfully added '$entry' to $hostsPath" -ForegroundColor Green
    } else {
        Write-Host "Entry for 192.168.1.60 already exists in hosts file." -ForegroundColor Yellow
    }
} catch {
    Write-Error "Failed to modify hosts file. Please make sure you are running as Administrator."
    exit 1
}

# Verify network connection
Write-Host "Verifying connection..."
Test-NetConnection -ComputerName blogger-mcp.local -Port 80
