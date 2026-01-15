param([string]$inputFile, [string]$outputFile)

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $wb = $excel.Workbooks.Open($inputFile)
    $ws = $wb.Sheets.Item(1)
    $usedRange = $ws.UsedRange
    $rows = $usedRange.Rows.Count
    $cols = $usedRange.Columns.Count

    $output = New-Object System.Text.StringBuilder

    for($r = 1; $r -le $rows; $r++) {
        $line = @()
        for($c = 1; $c -le $cols; $c++) {
            $val = $ws.Cells.Item($r, $c).Text
            $val = $val -replace '"', '""'
            $val = $val.Trim()
            $line += "`"$val`""
        }
        [void]$output.AppendLine($line -join ",")
    }

    $output.ToString() | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host "Exportado: $rows linhas, $cols colunas para $outputFile"

    $wb.Close($false)
}
finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
