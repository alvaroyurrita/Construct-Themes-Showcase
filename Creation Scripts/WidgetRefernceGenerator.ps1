$csv = Import-Csv "Sliders_Attributes.csv";
$cssOutput = @();
$elementOutput = @();
$templateOutput = @();
foreach ($row in $csv) {
    $cssEntry = @"
  #$($row.id) {
    display: none;
    left: 116px;
    top: 0;
    position: absolute;
}
"@
    $cssOutput += $cssEntry 

    $elementEntry = @"

[[Elements]]
Type = `"Ch5 Template`"
[Elements.Attributes]
transitionduration = `"1s`"
transitiondelay = `"0s`"
templateid = `"$($row.templateid)`"
id = `"$($row.id)`"
componentName = `"$($row.name)`"
ccid_ComponentType = `"Widget`"
ccid_WidgetName = `"$($row.name)`"
devicesVisited = `"[`\`"TSW-1070`\`"]`"
pd-receivestateshow="$($row.Join)"
"@
    $elementOutput += $elementEntry 

    $templateEntry = @"
<ch5-template
  transitionduration="1s"
  transitiondelay="0s"
  templateid="$($row.templateid)"
  id="$($row.id)"
  componentname="$($row.name)"
  ccid_componenttype="Widget"
  ccid_widgetname="$($row.name)"
  devicesvisited='["TSW-1070"]'
  pd-receivestateshow="$($row.join)">
</ch5-template>    
"@
    $templateOutput += $templateEntry
};
$cssOutput | Out-File -FilePath "Sliders_CSS.txt" -Encoding UTF8;
$elementOutput | Out-File -FilePath "Sliders_Elements.txt" -Encoding UTF8;
$templateOutput | Out-File -FilePath "Sliders_Templates.txt" -Encoding UTF8;