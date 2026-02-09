# RangeCreator.ps1
# Script to create Sliders-Rng files from Sliders-Fad files
# Transformations applied:
#   1. Replace filename: Sliders-Fad -> Sliders-Rng
#   2. Replace text: "Sliders Fader" -> "Sliders Range"
#   3. Replace attribute: slidertype="fader" -> slidertype="range"

$lightPath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase\Light"
$files = Get-ChildItem "$lightPath\Sliders-Fad*.cuiw" | Sort-Object Name

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Range Creator Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Found $($files.Count) files to process"
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    try {
        $oldContent = Get-Content $file.FullName -Raw -Encoding UTF8
        
        $newContent = $oldContent
        
        # 1. Replace "Sliders Fader" with "Sliders Range"
        $newContent = $newContent -replace 'Sliders Fader', 'Sliders Range'
        $newContent = $newContent -replace 'Sliders-Fad', 'Sliders-Rng'
        
        # 2. Replace slidertype="fader" with slidertype="range"
        $newContent = $newContent -replace 'slidertype="fader"', 'slidertype="range"'
        $newContent = $newContent -replace 'slidertype = "fader"', 'slidertype = "range"'
        $newContent = $newContent -replace 'range="false"', 'range="true"'
        $newContent = $newContent -replace 'range = "false"', 'range = "true"'
        $newContent = $newContent -replace 'customvstheme="theme"', 'customvstheme="theme"'
        $newContent = $newContent -replace 'customvstheme = "theme"', 'customvstheme = "theme"'
        

        # 7. Replace GUID with new one
        $newGuid = [guid]::NewGuid().ToString()
        $widgetId = [regex]::Match($newContent, 'Id\s*=\s*"([0-9a-fA-F-]{36})"').Groups[1].Value
        $newContent = $newContent -replace $widgetId, $newGuid

        
        # Create new filename
        $newFileName = $file.Name -replace 'Sliders-Fad', 'Sliders-Rng'
        $newFilePath = Join-Path $lightPath $newFileName

        

        
        # Write the new file
        Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8 -NoNewline
        
        Write-Host "✓ Created Widget: $newFileName" -ForegroundColor Green

        # 8. Create or Update Guids in respective Page.
        $page = [regex]::Match($newFileName, 'Sliders-Rng (\S{1,2})').Groups[1].Value.Trim()
        $oldPageFilename = "Sliders-Fad $page.cuig"
        $newPageFilename = "Sliders-Rng $page.cuig"
        $oldPageFilePath = Join-Path $lightPath $oldPageFilename
        $newPageFilePath = Join-Path $lightPath $newPageFilename
        if (!(Test-Path $newPageFilePath)) {
            $pageContent = Get-Content $oldPageFilePath -Raw -Encoding UTF8
            $attributesPattern = '\[Attributes\][\s\S]*?(?=\[\[Elements)'
            $oldAttributesText = [regex]::Match($pageContent, $attributesPattern, 'IgnoreCase, Singleline').Value
            $newAttributesText = $oldAttributesText -replace 'Sliders-Fad', 'Sliders-Rng'
            $newAttributesText = $newAttributesText -replace '[0-9a-fA-F-]{36}', [guid]::NewGuid().ToString()
            $newAttributesText = $newAttributesText -replace 'Fader Slider', 'Range Slider'


            $updatedPageContent = $pageContent -replace [regex]::Escape($oldAttributesText), $newAttributesText
            $updatedPageContent = $updatedPageContent -replace 'Sliders-Adv', 'Sliders-Rng'
            $updatedPageContent = $updatedPageContent -replace 'Advanced Slider', 'Range Slider'
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
