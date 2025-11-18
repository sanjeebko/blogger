# Extract blog titles and create index
$blogData = @()

# Computer blogs
Get-ChildItem -Path "blogs\computer" -Recurse -Filter "*.html" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match '<title>([^<]+)</title>') {
        $title = $matches[1].Trim()
        $relPath = $_.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
        $blogData += "COMPUTER|$title|$relPath"
    }
}

# Health blogs
Get-ChildItem -Path "blogs\health" -Recurse -Filter "*.html" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match '<title>([^<]+)</title>') {
        $title = $matches[1].Trim()
        $relPath = $_.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
        $blogData += "HEALTH|$title|$relPath"
    }
}

# Output to file
$blogData | Out-File -FilePath "blog-data.txt" -Encoding UTF8
Write-Host "Extracted $($blogData.Count) blogs to blog-data.txt"
