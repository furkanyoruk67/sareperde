# PowerShell script to backup original images before WebP conversion
# This creates a complete backup of the assets folder

param(
    [string]$SourceDir = "assets",
    [string]$BackupDir = "assets_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
)

Write-Host "Image Backup Script" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host ""

# Check if source directory exists
if (!(Test-Path $SourceDir)) {
    Write-Host "Source directory '$SourceDir' not found!" -ForegroundColor Red
    exit 1
}

# Create backup directory
try {
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        Write-Host "Created backup directory: $BackupDir" -ForegroundColor Green
    }
} catch {
    Write-Host "Failed to create backup directory: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Backing up images from '$SourceDir' to '$BackupDir'..." -ForegroundColor Cyan
Write-Host ""

# Copy all image files
$imageExtensions = @("*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff", "*.tif", "*.webp")
$totalCopied = 0
$totalSize = 0

foreach ($ext in $imageExtensions) {
    $files = Get-ChildItem -Path $SourceDir -Filter $ext -Recurse -File
    
    foreach ($file in $files) {
        try {
            # Calculate relative path
            $relativePath = $file.FullName.Substring((Resolve-Path $SourceDir).Path.Length + 1)
            $destinationPath = Join-Path $BackupDir $relativePath
            
            # Create destination directory if it doesn't exist
            $destinationDir = Split-Path $destinationPath -Parent
            if (!(Test-Path $destinationDir)) {
                New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
            }
            
            # Copy file
            Copy-Item $file.FullName $destinationPath -Force
            
            $fileSize = $file.Length
            $totalSize += $fileSize
            $totalCopied++
            
            $fileSizeKB = [math]::Round($fileSize/1KB, 1)
            Write-Host "  Copied: $relativePath (${fileSizeKB}KB)" -ForegroundColor Gray
        } catch {
            Write-Host "  Failed to copy: $($file.FullName) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Backup Summary:" -ForegroundColor Green
Write-Host "===============" -ForegroundColor Green
Write-Host "Files backed up: $totalCopied" -ForegroundColor Green
$totalSizeMB = [math]::Round($totalSize/1MB, 1)
Write-Host "Total size: ${totalSizeMB}MB" -ForegroundColor Green
Write-Host "Backup location: $BackupDir" -ForegroundColor Green
Write-Host ""
Write-Host "Your original images are now safely backed up!" -ForegroundColor Yellow
Write-Host "You can now run the WebP conversion script." -ForegroundColor White
