# Script to extract GUIDs from Old Sliders files
# Creates a CSV with filename and GUID from [Attributes] section

# Set the path to the Old Sliders folder
$showcasePath = "c:\GIT Development\Alvaro Tools\Construct Themes Showcase"
$oldSlidersPath = Join-Path $showcasePath "\Old Sliders"
$outputCsvPath = Join-Path $PSScriptRoot "OldSliders_GUIDs.csv"

# Initialize array to store results
$results = @()

# Get all files in the Old Sliders folder
$files = Get-ChildItem -Path $oldSlidersPath -File

Write-Host "Processing $($files.Count) files from Old Sliders folder..."

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)"
    
    # Read the file content
    $content = Get-Content -Path $file.FullName -Raw
    
    # Initialize variables
    $guid = $null
    
    # Parse the file to find the [Attributes] section and extract the Id
    $lines = Get-Content -Path $file.FullName
    $inAttributesSection = $false
    
    foreach ($line in $lines) {
        # Check if we're entering the [Attributes] section
        if ($line -match '^\[Attributes\]') {
            $inAttributesSection = $true
            continue
        }
        
        # Check if we're leaving the [Attributes] section (new section starts)
        if ($inAttributesSection -and $line -match '^\[.*\]') {
            $inAttributesSection = $false
            break
        }
        
        # If we're in the [Attributes] section, look for the Id property
        if ($inAttributesSection -and $line -match '^Id\s*=\s*"([^"]+)"') {
            $guid = $Matches[1]
            break
        }
    }
    
    # Add the result to the array
    $results += [PSCustomObject]@{
        FileName = $file.Name
        GUID = $guid
    }
}

# Export to CSV
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "`nComplete! CSV file created at: $outputCsvPath"
Write-Host "Total files processed: $($results.Count)"
Write-Host "Files with GUIDs: $(($results | Where-Object { $_.GUID -ne $null }).Count)"
