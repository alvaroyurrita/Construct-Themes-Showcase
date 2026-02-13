# RangeCreator.ps1
# Script to create Sliders-Rng files from Sliders-Fad files
# Transformations applied:
#   1. Replace filename: Sliders-Fad -> Sliders-Rng
#   2. Replace text: "Sliders Fader" -> "Sliders Range"
#   3. Replace attribute: slidertype="fader" -> slidertype="range"
#   4. Replace "showtickvalues="true" pd-receivestatevalue="5" sendeventonchange="5"  -> showtickvalues="true" pd-receivestatevalue="5" sendeventonchange="5" pd-receivestatevaluehigh="6" sendeventonchangehigh="6"
#   5. Replace showtickvalues = "true"
#              pd-receivestatevalue = "5"
#              sendeventonchange = "5"
#              with
#              showtickvalues = "true"
#              pd-receivestatevalue = "5"
#              sendeventonchange = "5"
#              pd-receivestatevaluehigh = "6"
#              sendeventonchangehigh = "6"

$lightDarkPath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase\LightDark"
$files = Get-ChildItem "$lightDarkPath\Sliders-Fad*.cuiw" | Sort-Object Name

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
        # Create new filename
        $newFileName = $file.Name -replace 'Sliders-Fad', 'Sliders-Rng'
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
        
        # 1. Replace "Sliders Fader" with "Sliders Range"
        $newContent = $newContent -replace 'Sliders Fader', 'Sliders Range'
        $newContent = $newContent -replace 'Sliders-Fad', 'Sliders-Rng'
        
        # 2. Replace slidertype="fader" with slidertype="range"
        $newContent = $newContent -replace 'slidertype\s*=\s*"fader"', 'slidertype = "range"'
        $newContent = $newContent -replace 'range\s*=\s*"false"', 'range = "true"'

        # 3. Add high value attributes if not present
        if ($newContent -notmatch 'pd-receivestatevaluehigh') {
            $newContent = $newContent -replace '"showtickvalues="true"\s*pd-receivestatevalue="5"\s*sendeventonchange="5"', ' showtickvalues="true" pd-receivestatevalue="5" sendeventonchange="5" pd-receivestatevaluehigh="6" sendeventonchangehigh="6"'
        }

        

        # 7. Replace GUID with new one
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
        $page = [regex]::Match($newFileName, 'Sliders-Rng (\S{1,2})').Groups[1].Value.Trim()
        $oldPageFilename = "Sliders-Fad $page.cuig"
        $newPageFilename = "Sliders-Rng $page.cuig"
        $oldPageFilePath = Join-Path $lightDarkPath $oldPageFilename
        $newPageFilePath = Join-Path $lightDarkPath $newPageFilename
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
