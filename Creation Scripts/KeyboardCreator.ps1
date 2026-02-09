# RangeCreator.ps1
# Script to create Sliders-Rng files from Sliders-Fad files
# Transformations applied:
#   1. Replace filename: Sliders-Fad -> Sliders-Rng
#   2. Replace text: "Sliders Fader" -> "Sliders Range"
#   3. Replace attribute: slidertype="fader" -> slidertype="range"

$lightPath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase\Light"
$files = Get-ChildItem "$lightPath\Keypad-Size*.cuiw" | Sort-Object Name

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Keyboard Creator Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Found $($files.Count) files to process"
Write-Host ""

$KeyboardNewTypes = @(
    "Default",
    "Primary",
    "Info",
    "Text",
    "Danger",
    "Warning",
    "Success",
    "Secondary"
)

$KeyboardNewShapes = @{
    RR="Rounded-Rectangle"
    SQ="Square"
    CI="Circle"
}

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    $fileNumber = [regex]::Match($file.Name, 'Keypad-Size([0-9])').Groups[1].Value
    # Create New Shape Loop
    foreach ($shape in $KeyboardNewShapes.GetEnumerator()) {
        $shapeShort = $shape.Key
        $shapeFilenamePart = "Keypad-Size$fileNumber-$shapeShort-"
        # Create New Type Loop
        foreach ($type in $KeyboardNewTypes) {
            $newFileName = "$shapeFilenamePart$type.cuiw"
            if ($file.Name -eq $newFileName) {
                Write-Host "⚠️  Skipping existing file: $newFileName" -ForegroundColor Yellow
                continue
            }

            $oldContent = Get-Content $file.FullName -Raw -Encoding UTF8
            $newContent = $oldContent
        
            # 1. Replace "Default" with New Type
            $newContent = $newContent -creplace 'Default', $type
            $newContent = $newContent -creplace 'type="default"', "type=`"$($type.ToLower())`""
            $newContent = $newContent -creplace 'type = "default"', "type = `"$($type.ToLower())`""

            #2. Replace "RoundRectangle" with New Shape
            $newContent = $newContent -creplace 'Rounded-Rectangle', $shape.Value
            $newContent = $newContent -creplace 'Rounded-Rectangle'.ToLower(), $shape.Value.ToLower()
            $newContent = $newContent -creplace 'RR', $shapeShort

            # 3. Replace GUID with new one
            $newGuid = [guid]::NewGuid().ToString()
            $widgetId = [regex]::Match($newContent, 'Id\s*=\s*"([0-9a-fA-F-]{36})"').Groups[1].Value
            $newContent = $newContent -replace $widgetId, $newGuid
        
            # Create new filename
            $newFileName = "$shapeFilenamePart$type.cuiw"
            $newFilePath = Join-Path $lightPath $newFileName

            # Write the new file
            Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8 -NoNewline
        
            Write-Host "✓ Created Widget: $newFileName" -ForegroundColor Green
            
            $successCount++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Successfully created: $successCount files" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Errors encountered: $errorCount files" -ForegroundColor Red
}
