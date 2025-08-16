# PowerShell script to convert images to WebP format
# This script requires ImageMagick to be installed
# Download from: https://imagemagick.org/script/download.php#windows

param(
    [string]$InputDir = "assets",
    [string]$Quality = "80",
    [switch]$KeepOriginal = $true,
    [switch]$DryRun = $false
)

Write-Host "WebP Image Conversion Script" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green
Write-Host ""

# Check if ImageMagick is installed
try {
    $magickVersion = magick -version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ImageMagick found" -ForegroundColor Green
    }
} catch {
    Write-Host "ImageMagick not found!" -ForegroundColor Red
    Write-Host "Please install ImageMagick from: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host "Make sure to check 'Add application directory to your system path' during installation" -ForegroundColor Yellow
    exit 1
}

# Function to convert image to WebP
function Convert-ToWebP {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [string]$Quality
    )
    
    try {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would convert: $InputPath -> $OutputPath" -ForegroundColor Yellow
            return $true
        } else {
            # Create output directory if it doesn't exist
            $outputDir = Split-Path $OutputPath -Parent
            if (!(Test-Path $outputDir)) {
                New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
            }
            
            # Convert using ImageMagick
            magick "$InputPath" -quality $Quality "$OutputPath" 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                # Get file sizes for comparison
                $originalSize = (Get-Item $InputPath).Length
                $webpSize = (Get-Item $OutputPath).Length
                $savings = [math]::Round((($originalSize - $webpSize) / $originalSize) * 100, 1)
                
                $originalKB = [math]::Round($originalSize/1KB, 1)
                $webpKB = [math]::Round($webpSize/1KB, 1)
                
                Write-Host "  Converted: $(Split-Path $InputPath -Leaf) -> $(Split-Path $OutputPath -Leaf)" -ForegroundColor Green
                Write-Host "    Size: ${originalKB}KB -> ${webpKB}KB (${savings} percent savings)" -ForegroundColor Cyan
                return $true
            } else {
                Write-Host "  Failed to convert: $InputPath" -ForegroundColor Red
                return $false
            }
        }
    } catch {
        Write-Host "  Error converting ${InputPath}: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Find all image files
$imageExtensions = @("*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff", "*.tif")
$imageFiles = @()

foreach ($ext in $imageExtensions) {
    $files = Get-ChildItem -Path $InputDir -Filter $ext -Recurse -File
    $imageFiles += $files
}

if ($imageFiles.Count -eq 0) {
    Write-Host "No image files found in $InputDir" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($imageFiles.Count) image files to convert" -ForegroundColor Cyan
Write-Host "Quality setting: $Quality percent" -ForegroundColor Cyan
Write-Host "Keep originals: $KeepOriginal" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be modified" -ForegroundColor Yellow
    Write-Host ""
}

# Convert each image
$convertedCount = 0
$failedCount = 0

foreach ($file in $imageFiles) {
    $relativePath = $file.FullName.Substring((Get-Location).Path.Length + 1)
    $webpPath = [System.IO.Path]::ChangeExtension($file.FullName, ".webp")
    
    Write-Host "Processing: $relativePath"
    
    # Skip if WebP version already exists (unless it's older than the source)
    if ((Test-Path $webpPath) -and !$DryRun) {
        $sourceTime = $file.LastWriteTime
        $webpTime = (Get-Item $webpPath).LastWriteTime
        if ($webpTime -gt $sourceTime) {
            Write-Host "  Skipping: WebP version already exists and is newer" -ForegroundColor Gray
            continue
        }
    }
    
    if (Convert-ToWebP -InputPath $file.FullName -OutputPath $webpPath -Quality $Quality) {
        $convertedCount++
        
        # Delete original if requested
        if (!$KeepOriginal -and !$DryRun) {
            try {
                Remove-Item $file.FullName -Force
                Write-Host "  Deleted original file" -ForegroundColor Gray
            } catch {
                Write-Host "  Could not delete original: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        $failedCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "Conversion Summary:" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host "Successfully converted: $convertedCount files" -ForegroundColor Green
if ($failedCount -gt 0) {
    Write-Host "Failed conversions: $failedCount files" -ForegroundColor Red
} else {
    Write-Host "Failed conversions: $failedCount files" -ForegroundColor Green
}
Write-Host ""

if (!$DryRun -and $convertedCount -gt 0) {
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Update your Flutter code to use .webp extensions instead of .png/.jpg" -ForegroundColor White
    Write-Host "2. Test your app to ensure all images load correctly" -ForegroundColor White
    Write-Host "3. Consider running 'flutter clean' and 'flutter pub get' after changes" -ForegroundColor White
}

Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Cyan
Write-Host "  .\convert_to_webp_fixed.ps1                          # Convert all images in assets/ folder (keep originals)"
Write-Host "  .\convert_to_webp_fixed.ps1 -Quality 90              # Convert with 90 percent quality"
Write-Host "  .\convert_to_webp_fixed.ps1 -KeepOriginal:`$false     # Convert and delete originals"
Write-Host "  .\convert_to_webp_fixed.ps1 -DryRun                  # Preview what would be converted"
Write-Host "  .\convert_to_webp_fixed.ps1 -InputDir 'assets\Slider' # Convert only Slider folder"
