# full bloat remover, only use when you know what it does

<#
   NoMoreBloat
   Version: 1.0
   anti-bloater, removes most bloat
#>

Write-Host "Booting..." -ForegroundColor Cyan
Write-Host "-----------------------------------`n"

# ==========================================================
# 1. REMOVE KNOWN BLOAT APPS
# ==========================================================
$bloatApps = @(
    "Microsoft.3DBuilder",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.BingWeather",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.SkypeApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Messaging",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Print3D",
    "Microsoft.WindowsFeedbackHub"
)

foreach ($app in $bloatApps) {
    try {
        Write-Host "➡️ Removing $app..." -ForegroundColor Yellow
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction Stop
        Write-Host "   ✅ Removed: $app" -ForegroundColor Green
    }
    catch {
        Write-Host "   ⚠️ Not installed or could not remove: $app" -ForegroundColor DarkYellow
    }
}
Write-Host "`n✔ Finished removing bloat apps" -ForegroundColor Cyan
Write-Host "-----------------------------------`n"

# ==========================================================
# 2. DISABLE TELEMETRY SERVICES (SAFE ONLY)
# ==========================================================
Write-Host "➡️ Disabling telemetry services..." -ForegroundColor Yellow
try {
    Stop-Service DiagTrack -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
    Write-Host "   ✅ Disabled: Connected User Experiences and Telemetry (DiagTrack)" -ForegroundColor Green
}
catch {
    Write-Host "   ⚠️ Could not disable DiagTrack (already disabled or missing)" -ForegroundColor DarkYellow
}
Write-Host "`n✔ Telemetry step complete" -ForegroundColor Cyan
Write-Host "-----------------------------------`n"

# ==========================================================
# 3. TEMP CLEANER
# ==========================================================
$totalDeleted = 0
$totalSkipped = 0
$totalSize = 0
$paths = @("$env:TEMP", "C:\Windows\Temp")

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "🧹 Cleaning temp: $path" -ForegroundColor Cyan
        $items = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | 
                 Where-Object { $_.FullName -notmatch "NLTmpMnt" }

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

# ==========================================================
# 4. SUMMARY
# ==========================================================
$sizeMB = [math]::Round($totalSize / 1MB, 2)
$sizeGB = [math]::Round($totalSize / 1GB, 2)

Write-Host "`n📊 FINAL SUMMARY:" -ForegroundColor Magenta
Write-Host "   Total items deleted: $totalDeleted"
Write-Host "   Total skipped (locked): $totalSkipped"
Write-Host "   Space freed: $sizeMB MB ($sizeGB GB)"
Write-Host "`n🎉 Anti-Bloat + Temp Cleanup Complete!" -ForegroundColor Cyan
