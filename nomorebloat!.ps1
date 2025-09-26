$paths = @("$env:TEMP", "C:\Windows\Temp")
$totalDeleted = 0
$totalSkipped = 0
$totalSize = 0

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "🧹 Starting cleanup for: $path" -ForegroundColor Cyan
        $items = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | 
                 Where-Object { $_.FullName -notmatch "NLTmpMnt" }   # 🚫 ignore scary temp mounts

        foreach ($item in $items) {
            try {
                $size = if ($item.PSIsContainer) { 0 } else { $item.Length }
                Write-Host "   ➡️ Deleting: $($item.FullName)" -ForegroundColor Yellow
                Remove-Item $item.FullName -Force -Recurse -ErrorAction Stop
                Write-Host "   ✅ Deleted!" -ForegroundColor Green
                $totalDeleted++
                $totalSize += $size
            }
            catch {
                Write-Host "   ⚠️ Skipped (locked): $($item.FullName)" -ForegroundColor DarkYellow
                $totalSkipped++
            }
        }

        Write-Host "✔ Finished cleaning: $path" -ForegroundColor Cyan
        Write-Host "-----------------------------------"
    }
}

# Summary
$sizeMB = [math]::Round($totalSize / 1MB, 2)
$sizeGB = [math]::Round($totalSize / 1GB, 2)
Write-Host "`n📊 SUMMARY:" -ForegroundColor Magenta
Write-Host "   Total items deleted: $totalDeleted"
Write-Host "   Total skipped (locked): $totalSkipped"
Write-Host "   Space freed: $sizeMB MB ($sizeGB GB)"
