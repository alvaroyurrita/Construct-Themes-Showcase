# Advancde Slider creator
# Creates all sliders from an initial Slider widget : Sliders-Adv L Crcl Ticks Tool.cuiw
# Since at this point the pages hosting the widgets have already been created, it will not recreate a GUID but instead grab
# it from the OldSliders_GUIDs.csv file created in the previous step, matching by filename. This is to avoid breaking the pages that are already referencing the existing widgets.    
# Transformations applied:
#   1. Replace filename: Sliders-Adv L Crcl Ticks Tool.cuiw -> Sliders-Adv L Crcl Tool.cuiw
#       1.2 Replace 'showtickvalues = "on"' with 'showtickvalues = "off"' 
#       1.3 Remove 'ticks = "{\"0\":\"0\", \"25\":\"25\", \"50\":\"50\", \"75\":\"75\", \"100\": \"100\" }"'
#       1.4 Replace ` with Ticks and ToolTip` with ` with ToolTip`
#       1.5 Replace `Sliders-Adv L Crcl Ticks Tool` with `Sliders-Adv L Crcl Tool`
#       1.6 Replace Old GUID with the one from the CSV file matching the filename
#   2. Replace filename: Sliders-Adv L Crcl Ticks Tool.cuiw -> Sliders-Adv L Crcl.cuiw
#       2.1 Replace 'tooltipshowtype = "on"' with 'tooltipshowtype = "off"' 
#       2.2 Replace 'showtickvalues = "on"' with 'showtickvalues = "off"' 
#       2.3 Remove 'ticks = "{\"0\":\"0\", \"25\":\"25\", \"50\":\"50\", \"75\":\"75\", \"100\": \"100\" }"
#       2.4 Replace ` with Ticks and ToolTip` with ``
#       2.5 Replace `Sliders-Adv L Crcl Ticks Tool` with `Sliders-Adv L Crcl`
#       2.6 Replace Old GUID with the one from the CSV file matching the filename
#   3. Replace all Filenames: Sliders-Adv L Crcl xxxx.cuiw -> Sliders-Adv L Ovl xxxx.cuiw (Rec, R-Rec)
#       3.1 Replace 'handleshape = "circle"' with 'handleshape = "oval"'  (rectangle, rounded-rectangle)
#       3.2 Replace `Crcl` with `Ovl` (Rec, R-Rec)
#       3.3 Replace `Sliders Advanced Circle` with `Sliders Advanced Oval` (`Sliders Advanced Rectangle`, `Sliders Advanced Rounded Rectangle`)
#       3.3 Replace Old GUID with the one from the CSV file matching the filename
#   4. Replace text: "Sliders-Adv L xxxx yyy.cuiw" -> "Sliders-Adv R xxxx yyy.cuiw (S, XL, XS)"
#        4.1 Repalce 'handlesize = "large"' with 'handlesize = "small"' (regular, small, x-large, x-small)
#       4.1 Replace `Sliders-Adv L` with `Sliders-Adv R` (S, XL, XS)
#       4.2 Replace `Large Handle` with `Regular Handle` (`Regular Handle`, `Small Handle`, `X-Large Handle`, `X-Small Handle`)
#       4.3 Replace Old GUID with the one from the CSV file matching the filename


# Set the path to the Old Sliders folder
$showcasePath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase"
$LightDarkPath = Join-Path $showcasePath "\LightDark"
$SlidersSeedPath = Join-Path $LightDarkPath "Sliders-Adv L Crcl Ticks Tool.cuiw"
$oldSlidersGuidCsvPath = Join-Path $PSScriptRoot "OldSliders_GUIDs.csv"

#1 Creating the new files based on the seed file
$changesToMake = @(
    @{
        NewFileName  = "Sliders-Adv L Crcl Tool.cuiw"
        Replacements = @{
            'showtickvalues\s*=\s*"on"'     = 'showtickvalues = "off"'
            'ticks\s*=\s*"\{[^}]*\}"'       = ''
            ' with Ticks and ToolTip'       = ' with ToolTip'
            'Sliders-Adv L Crcl Ticks Tool' = 'Sliders-Adv L Crcl Tool'
        }
    },
    @{
        NewFileName  = "Sliders-Adv L Crcl.cuiw"
        Replacements = @{
            'tooltipshowtype\s*=\s*"on"'    = 'tooltipshowtype = "off"'
            'showtickvalues\s*=\s*"on"'     = 'showtickvalues = "off"'
            'ticks\s*=\s*"\{[^}]*\}"'       = ''
            ' with Ticks and ToolTip'       = ''
            'Sliders-Adv L Crcl Ticks Tool' = 'Sliders-Adv L Crcl'
        }
    }
)

$oldGuids = Import-Csv -Path $oldSlidersGuidCsvPath
$seedContent = Get-Content -Path $SlidersSeedPath -Raw -Encoding UTF8
$seedGuid = ($seedContent -match 'Id = "([^"]+)"') ? $Matches[1] : $null

foreach ($change in $changesToMake) {
    $newFilePath = Join-Path $LightDarkPath $change.NewFileName
    if (Test-Path $newFilePath) {
        Write-Host "⚠️  File already exists, skipping: $($change.NewFileName)" -ForegroundColor Yellow
        continue
    }
    $newGuid = $oldGuids | Where-Object { $_.Filename -eq $change.NewFileName } | Select-Object -ExpandProperty GUID  
    if ($null -eq $newGuid) {
        Write-Host "⚠️  No matching GUID found for file: $($change.NewFileName), skipping." -ForegroundColor Yellow
        continue
    }
    $newContent = $seedContent;
    try {
        foreach ($pattern in $change.Replacements.Keys) {
            $replacement = $change.Replacements[$pattern]
            $newContent = [regex]::Replace($newContent, $pattern, $replacement)
        }
        # Replace the GUID
        $newContent = [regex]::Replace($newContent, [regex]::Escape($seedGuid), $newGuid)
        Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8
        Write-Host "✅ Created file: $($change.NewFileName)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error creating file: $($change.NewFileName) - $_" -ForegroundColor Red
    }
}

# Ask user to pause before proceeding to the next steps, since they depend on the files created in the previous step
Write-Host "`nPlease edit the simple sliders created to adjust their position.  Press Enter when done."
Read-Host

#2 Replace all Filenames: Sliders-Adv L Crcl xxxx.cuiw -> Sliders-Adv L Ovl xxxx.cuiw (Rec, R-Rec)
$shapesToChange = @(
    @{
        filenamePattern = "Ovl"
        Replacements    = @{
            'handleshape\s*=\s*"circle"' = 'handleshape = "oval"'
            'Crcl'                       = 'Ovl'
            'Sliders Advanced Circle'    = 'Sliders Advanced Oval'
        }
    },
    @{
        filenamePattern = "Rec"
        Replacements    = @{
            'handleshape\s*=\s*"circle"' = 'handleshape = "rectangle"'
            'Crcl'                       = 'Rec'
            'Sliders Advanced Circle'    = 'Sliders Advanced Rectangle'
        }
    },
    @{
        filenamePattern = "R-Rec"
        Replacements    = @{
            'handleshape\s*=\s*"circle"' = 'handleshape = "rounded-rectangle"'
            'Crcl'                       = 'R-Rec'
            'Sliders Advanced Circle'    = 'Sliders Advanced Rounded Rectangle'
        }
    }
)

$seedFiles = Get-ChildItem -Path $LightDarkPath -Filter "Sliders-Adv L Crcl*.cuiw" -File

foreach ($seedFile in $seedFiles) {
    $oldContent = Get-Content -Path $seedFile.FullName -Raw -Encoding UTF8
    $seedGuid = ($oldContent -match 'Id = "([^"]+)"') ? $Matches[1] : $null
    foreach ($shapeChange in $shapesToChange) {
        $newFileName = $seedFile.Name -replace 'Crcl', $shapeChange.filenamePattern
        $newFilePath = Join-Path $LightDarkPath $newFileName
        if (Test-Path $newFilePath) {
            Write-Host "⚠️  File already exists, skipping: $newFileName" -ForegroundColor Yellow
            continue
        }
        $newGuid = $oldGuids | Where-Object { $_.Filename -eq $newFileName } | Select-Object -ExpandProperty GUID  
        if ($null -eq $newGuid) {
            Write-Host "⚠️  No GUID found for file: $newFileName, skipping." -ForegroundColor Yellow
            continue
        }
        $newContent = $oldContent
        try {
            foreach ($pattern in $shapeChange.Replacements.Keys) {
                $replacement = $shapeChange.Replacements[$pattern]
                $newContent = [regex]::Replace($newContent, $pattern, $replacement)
            }
            # Replace the GUID
            $newContent = [regex]::Replace($newContent, [regex]::Escape($seedGuid), $newGuid)
            Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8
            Write-Host "✅ Created file: $newFileName" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error creating file: $newFileName - $_" -ForegroundColor Red
        }
    }
}

#3. Replace all Filenames: Sliders-Adv L *
$sizesToChange = @(
    @{
        filenamePattern = "R"
        Replacements    = @{
            'handlesize\s*=\s*"large"' = 'handlesize = "regular"'
            'Sliders-Adv L'         = 'Sliders-Adv R'
            'Large Handle'         = 'Regular Handle'
        }
    },
    @{
        filenamePattern = "S"
        Replacements    = @{
            'handlesize\s*=\s*"large"' = 'handlesize = "small"'
            'Sliders-Adv L'         = 'Sliders-Adv S'
            'Large Handle'         = 'Small Handle'
        }
    },
    @{
        filenamePattern = "XL"
        Replacements    = @{
            'handlesize\s*=\s*"large"' = 'handlesize = "x-large"'
            'Sliders-Adv L'         = 'Sliders-Adv XL'
            'Large Handle'         = 'X-Large Handle'
        }
    },
    @{
        filenamePattern = "XS"
        Replacements    = @{
            'handlesize\s*=\s*"large"' = 'handlesize = "x-small"'
            'Sliders-Adv L'         = 'Sliders-Adv XS'
            'Large Handle'         = 'X-Small Handle'
        }
    }
)

$seedFiles = Get-ChildItem -Path $LightDarkPath -Filter "Sliders-Adv L *.cuiw" -File

foreach ($seedFile in $seedFiles) {
    $oldContent = Get-Content -Path $seedFile.FullName -Raw -Encoding UTF8
    $seedGuid = ($oldContent -match 'Id = "([^"]+)"') ? $Matches[1] : $null
    foreach ($sizeChange in $sizesToChange) {
        $newFileName = $seedFile.Name -replace ' L ', " $($sizeChange.filenamePattern) "
        $newFilePath = Join-Path $LightDarkPath $newFileName
        if (Test-Path $newFilePath) {
            Write-Host "⚠️  File already exists, skipping: $newFileName" -ForegroundColor Yellow
            continue
        }
        $newGuid = $oldGuids | Where-Object { $_.Filename -eq $newFileName } | Select-Object -ExpandProperty GUID  
        if ($null -eq $newGuid) {
            Write-Host "⚠️  No GUID found for file: $newFileName, skipping." -ForegroundColor Yellow
            continue
        }
        $newContent = $oldContent
        try {
            foreach ($pattern in $sizeChange.Replacements.Keys) {
                $replacement = $sizeChange.Replacements[$pattern]
                $newContent = [regex]::Replace($newContent, $pattern, $replacement)
            }
            # Replace the GUID
            $newContent = [regex]::Replace($newContent, [regex]::Escape($seedGuid), $newGuid)
            Set-Content -Path $newFilePath -Value $newContent -Encoding UTF8
            Write-Host "✅ Created file: $newFileName" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error creating file: $newFileName - $_" -ForegroundColor Red
        }
    }
}

