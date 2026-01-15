# Lê CSV de frango de corte e gera INSERTs
$csv = Import-Csv -Path "C:\Users\geraldo.borges\CascadeProjects\SAG\Base\Dashboard\frango_corte.csv" -Encoding UTF8

$sql = New-Object System.Text.StringBuilder

foreach ($row in $csv) {
    $lote = $row.Lote

    # Parse data
    $dataAloj = $row.Alojamento
    if ($dataAloj -match "(\d{4})-(\d{2})-(\d{2})") {
        $dataAloj = "TO_DATE('$($Matches[1])-$($Matches[2])-$($Matches[3])', 'YYYY-MM-DD')"
    } else {
        $dataAloj = "NULL"
    }

    # Parse numbers (troca virgula por ponto)
    $alojadas = $row.Alojadas -replace ',', '.'
    $abatidas = $row.Abatidas -replace ',', '.'
    $mortePerc = $row.morte_perc -replace ',', '.'
    $idade = $row.Idade -replace ',', '.'
    $pesoMedio = $row.'P.M.' -replace ',', '.'
    $ca = $row.'C.A.' -replace ',', '.'
    $cac = $row.'C.A.C.' -replace ',', '.'
    $viabilidade = $row.viabilidade_lote -replace ',', '.'
    $gpd = $row.GPD -replace ',', '.'
    $iep = $row.IEP -replace ',', '.'
    $pesoTotal = $row.peso_total -replace ',', '.'
    $tipoGalpao = $row.tipo_galpao -replace "'", "''"
    $iel = $row.IEL -replace ',', '.'

    # Trata vazios
    if ([string]::IsNullOrWhiteSpace($alojadas)) { $alojadas = "NULL" }
    if ([string]::IsNullOrWhiteSpace($abatidas)) { $abatidas = "NULL" }
    if ([string]::IsNullOrWhiteSpace($mortePerc)) { $mortePerc = "NULL" }
    if ([string]::IsNullOrWhiteSpace($idade)) { $idade = "NULL" }
    if ([string]::IsNullOrWhiteSpace($pesoMedio)) { $pesoMedio = "NULL" }
    if ([string]::IsNullOrWhiteSpace($ca)) { $ca = "NULL" }
    if ([string]::IsNullOrWhiteSpace($cac)) { $cac = "NULL" }
    if ([string]::IsNullOrWhiteSpace($viabilidade)) { $viabilidade = "NULL" }
    if ([string]::IsNullOrWhiteSpace($gpd)) { $gpd = "NULL" }
    if ([string]::IsNullOrWhiteSpace($iep)) { $iep = "NULL" }
    if ([string]::IsNullOrWhiteSpace($pesoTotal)) { $pesoTotal = "NULL" }
    if ([string]::IsNullOrWhiteSpace($iel)) { $iel = "NULL" }
    if ([string]::IsNullOrWhiteSpace($tipoGalpao)) { $tipoGalpao = "" }

    [void]$sql.AppendLine("INSERT INTO POCWEB_DASH_FRANGO_CORTE (LOTE, DATA_ALOJAMENTO, ALOJADAS, ABATIDAS, MORTE_PERC, IDADE, PESO_MEDIO, CA, CAC, VIABILIDADE, GPD, IEP, PESO_TOTAL, TIPO_GALPAO, IEL) VALUES ($lote, $dataAloj, $alojadas, $abatidas, $mortePerc, $idade, $pesoMedio, $ca, $cac, $viabilidade, $gpd, $iep, $pesoTotal, '$tipoGalpao', $iel);")
}

[void]$sql.AppendLine("COMMIT;")
[void]$sql.AppendLine("SELECT COUNT(*) AS TOTAL FROM POCWEB_DASH_FRANGO_CORTE;")

$sql.ToString() | Out-File -FilePath "C:\Users\geraldo.borges\CascadeProjects\SAG\Base\Dashboard\insert_frango.sql" -Encoding UTF8

Write-Host "Gerado insert_frango.sql com $($csv.Count) registros"
