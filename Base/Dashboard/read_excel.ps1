param([string]$file)

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $wb = $excel.Workbooks.Open($file)
    $ws = $wb.Sheets.Item(1)
    $usedRange = $ws.UsedRange
    $rows = $usedRange.Rows.Count
    $cols = $usedRange.Columns.Count

    Write-Host "Linhas: $rows, Colunas: $cols"
    Write-Host ""
    Write-Host "Cabecalhos:"
    for($c = 1; $c -le $cols; $c++) {
        $val = $ws.Cells.Item(1, $c).Text
        Write-Host "  Col$c : $val"
    }

    Write-Host ""
    Write-Host "Primeiras 5 linhas de dados:"
    for($r = 2; $r -le [Math]::Min(6, $rows); $r++) {
        $line = "Linha $r : "
        for($c = 1; $c -le [Math]::Min(10, $cols); $c++) {
            $val = $ws.Cells.Item($r, $c).Text
            $line += "$val | "
        }
        Write-Host $line
    }

    $wb.Close($false)
}
finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
