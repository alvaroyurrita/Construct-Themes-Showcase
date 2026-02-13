# FaderCreator.ps1
# Script to create Sliders-Fad files from Sliders-Adv files
# Transformations applied:
#   1. Replace filename: Sliders-Adv -> Sliders-Fad
#   2. Replace text: "Sliders Advanced" -> "Sliders Fader"
#   3. Replace attribute: slidertype="advanced" -> slidertype="fader"
#   4. Remove HTML tags: <ch5-slider-title-label> and content
#   5. Remove HTML tags: <ch5-slider-button> and content
#   6. Remove TOML sections: Ch5 slider-title-Label and Ch5 Slider Button components

$lightDarkPath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase\LightDark"
$files = Get-ChildItem "$lightDarkPath\Sliders-Adv*.cuiw" | Sort-Object Name

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fader Creator Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Found $($files.Count) files to process"
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    try {
        # Create new filename
        $newFileName = $file.Name -replace 'Sliders-Adv', 'Sliders-Fad'
        $newFilePath = Join-Path $lightDarkPath $newFileName
        if (Test-Path $newFilePath) {
            Write-Host "⚠️  Skipping existing file: $newFileName" -ForegroundColor Yellow
            continue
        }


        $oldContent = Get-Content $file.FullName -Raw -Encoding UTF8
        $newGuid = $oldGuids | Where-Object { $_.Filename -eq $newFileName } | Select-Object -ExpandProperty GUID  
        if ($null -eq $newGuid) {
            Write-Host "⚠️  No GUID found for file: $newFileName, skipping." -ForegroundColor Yellow
            continue
        }
        
        $newContent = $oldContent
        $seedGuid = ($oldContent -match 'Id = "([^"]+)"') ? $Matches[1] : $null

        
        # 1. Replace "Sliders Advanced" with "Sliders Fader"
        $newContent = $newContent -replace 'Sliders Advanced', 'Sliders Fader'
        $newContent = $newContent -replace 'Sliders-Adv', 'Sliders-Fad'
        
        # 2. Replace slidertype="advanced" with slidertype="fader"
        $newContent = $newContent -replace 'slidertype\s*=\s*"advanced"', 'slidertype = "fader"'
        
        # 3. Remove ch5-slider-title-label tags and content (handles multiline with various whitespace)
        $sliderTitlePattern = '<ch5-slider-title-label\s+[^>]*>.*?<\/ch5-slider-title-label\s*>'
        $sliderTitleMatches = [regex]::Matches($newContent, $sliderTitlePattern, 'IgnoreCase, Singleline')
        foreach ($match in $sliderTitleMatches) {
            $newContent = $newContent -replace [regex]::Escape($match.Value), ''
        }
        
        # 4. Remove ch5-slider-button tags and content (handles multiline with various whitespace)
        $sliderButtonPattern = '<ch5-slider-button\s+[^>]*>.*?<\/ch5-slider-button\s*>'
        $sliderButtonMatches = [regex]::Matches($newContent, $sliderButtonPattern, 'IgnoreCase, Singleline')
        foreach ($match in $sliderButtonMatches) {
            $newContent = $newContent -replace [regex]::Escape($match.Value), ''
        }
        
        # 5. Remove TOML section: [[Elements.Components.Components]] with Type = "Ch5 slider-title-Label" through next [Elements.Components
        # 6. Remove TOML section: [[Elements.Components.Components]] with Type = "Ch5 Slider Button" through next section
        # This is more complex as there can be multiple button entries
        $elementsPattern = '\[\[Elements\.Components\.Components[\s\S]*?(?=\[\[Elements|\[Elements\.Components\.Attributes)'
        $elementsMatches = [regex]::Matches($newContent, $elementsPattern, 'IgnoreCase, Singleline')
        foreach ($match in $elementsMatches) {
            if ($match.Value -match 'Type\s*=\s*"Ch5 slider-title-Label"') {
                $newContent = $newContent -replace [regex]::Escape($match.Value), ''
            }
            if ($match.Value -match 'Type\s*=\s*"Ch5 Slider Button"') {
                $newContent = $newContent -replace [regex]::Escape($match.Value), ''
            }
        }

        # # 7. Replace GUID with new one
        # $newGuid = [guid]::NewGuid().ToString()
        # $widgetId = [regex]::Match($newContent, 'Id\s*=\s*"([0-9a-fA-F-]{36})"').Groups[1].Value
        # $newContent = $newContent -replace $widgetId, $newGuid

        # 7. Replace GUID with Previous one from CSV
        $newContent = [regex]::Replace($newContent, [regex]::Escape($seedGuid), $newGuid)
        # Write the new file
        Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8 -NoNewline
        Write-Host "✓ Created Widget: $newFileName" -ForegroundColor Green


<# pages have already been created, skipping this now

        # 8. Create or Update Guids in respective Page.
        $page = [regex]::Match($newFileName, 'Sliders-Fad (\S{1,2})').Groups[1].Value.Trim()
        $oldPageFilename = "Sliders-Adv $page.cuig"
        $newPageFilename = "Sliders-Fad $page.cuig"
        $oldPageFilePath = Join-Path $lightDarkPath $oldPageFilename
        $newPageFilePath = Join-Path $lightDarkPath $newPageFilename
        if (!(Test-Path $newPageFilePath)) {
            $pageContent = Get-Content $oldPageFilePath -Raw -Encoding UTF8
            $attributesPattern = '\[Attributes\][\s\S]*?(?=\[\[Elements)'
            $oldAttributesText = [regex]::Match($pageContent, $attributesPattern, 'IgnoreCase, Singleline').Value
            $newAttributesText = $oldAttributesText -replace 'Sliders-Adv', 'Sliders-Fad'
            $newAttributesText = $newAttributesText -replace '[0-9a-fA-F-]{36}', [guid]::NewGuid().ToString()
            $newAttributesText = $newAttributesText -replace 'Advanced Slider', 'Fader Slider'

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
#>
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
