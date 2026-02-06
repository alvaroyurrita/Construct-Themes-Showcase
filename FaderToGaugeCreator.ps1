# GaugeCreator.ps1
# Script to create Sliders-Gau files from Sliders-Fad files
# Transformations applied:
#   1. Replace filename: Sliders-Fad -> Sliders-Gau
#   2. Replace text: "Sliders Fader" -> "Sliders Gauge"
#   3. Replace attribute: slidertype="fader" -> slidertype="gauge"

$lightPath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase\Light"
$files = Get-ChildItem "$lightPath\Sliders-Fad L*.cuiw" | Sort-Object Name

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Gauge Creator Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Found $($files.Count) files to process"
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    try {
        if ($file.Name -like "*tool*" -and  $file.Name -notlike "*ticks*") {
            Write-Host "→ Skipping Advanced Slider file: $($file.Name)" -ForegroundColor Yellow
            continue
        }
        $oldContent = Get-Content $file.FullName -Raw -Encoding UTF8
        
        $newContent = $oldContent
        
        # 1. Replace "Sliders Fader" with "Sliders Gauge"
        $newContent = $newContent -replace 'Sliders Fader L', 'Sliders Gauge'
        $newContent = $newContent -replace 'Sliders-Fad L', 'Sliders-Gau'
        $newContent = $newContent -replace 'Ticks Tools', 'Ticks'
        $newContent = $newContent -replace 'and ToolTip', ''
        
        # 2. Replace slidertype="fader" with slidertype="gauge"
        $newContent = $newContent -replace 'slidertype="fader"', 'slidertype="gauge"'
        $newContent = $newContent -replace 'slidertype = "fader"', 'slidertype = "gauge"'
        $newContent = $newContent -replace 'gauge="false"', 'gauge="true"'
        $newContent = $newContent -replace 'gauge = "false"', 'gauge = "true"'
        $newContent = $newContent -replace 'customvstheme="custom"', 'customvstheme="theme"'
        $newContent = $newContent -replace 'customvstheme = "custom"', 'customvstheme = "theme"'
        $newContent = $newContent -replace 'handleshape\s*=\s*".*?"', ''
        $newContent = $newContent -replace 'handlesize\s*=\s*".*?"', ''
        $newContent = $newContent -replace 'tooltipshowtype = ".*?"', 'tooltipshowtype = "off"'
        $newContent = $newContent -replace 'tooltipshowtype=".*?"', 'tooltipshowtype="off"'
        $newContent = $newContent -replace 'tooltipdisplaytype\s*=\s*"%"', ''
        $newContent = $newContent -replace 'nohandle=".*?"', 'nohandle="true"'
        $newContent = $newContent -replace 'nohandle = ".*?"', 'nohandle = "true"'
        

        # 7. Replace GUID with new one
        $newGuid = [guid]::NewGuid().ToString()
        $widgetId = [regex]::Match($newContent, 'Id\s*=\s*"([0-9a-fA-F-]{36})"').Groups[1].Value
        $newContent = $newContent -replace $widgetId, $newGuid

        
        # Create new filename
        $newFileName = $file.Name -replace 'Sliders-Fad L', 'Sliders-Gau'
        $newFilePath = Join-Path $lightPath $newFileName

        

        
        # Write the new file
        Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8 -NoNewline
        
        Write-Host "✓ Created Widget: $newFileName" -ForegroundColor Green

        # 8. Create or Update Guids in respective Page.
        $oldPageFilename = "Sliders-Fad L.cuig"
        $newPageFilename = "Sliders-Gau.cuig"
        $oldPageFilePath = Join-Path $lightPath $oldPageFilename
        $newPageFilePath = Join-Path $lightPath $newPageFilename
        if (!(Test-Path $newPageFilePath)) {
            $pageContent = Get-Content $oldPageFilePath -Raw -Encoding UTF8
            $attributesPattern = '\[Attributes\][\s\S]*?(?=\[\[Elements)'
            $oldAttributesText = [regex]::Match($pageContent, $attributesPattern, 'IgnoreCase, Singleline').Value
            $newAttributesText = $oldAttributesText -replace 'Sliders-Fad L', 'Sliders-Gau'
            $newAttributesText = $newAttributesText -replace '[0-9a-fA-F-]{36}', [guid]::NewGuid().ToString()
            $newAttributesText = $newAttributesText -replace 'Fader Slider', 'Gauge Slider'


            $updatedPageContent = $pageContent -replace [regex]::Escape($oldAttributesText), $newAttributesText
            $updatedPageContent = $updatedPageContent -replace $widgetId, $newGuid
            Set-Content -Path $newPageFilePath -Value $updatedPageContent -Encoding UTF8 -NoNewline
            Write-Host "✓ Created Page: $newPageFilePath" -ForegroundColor Green
        }
        else {
            $updatedPageContent = Get-Content $newPageFilePath -Raw -Encoding UTF8
            $updatedPageContent = $updatedPageContent -replace $widgetId, $newGuid
            Set-Content -Path $newPageFilePath -Value $updatedPageContent -Encoding UTF8 -NoNewline
            Write-Host "✓ Updated Page: $newPageFilePath" -ForegroundColor Green
        }
        $successCount++
    }
    catch {
        Write-Host "✗ Error processing $($file.Name): $_" -ForegroundColor Red
        $errorCount++
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
