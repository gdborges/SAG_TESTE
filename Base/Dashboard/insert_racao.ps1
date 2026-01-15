# Lê CSV de ração insumo e gera INSERTs
$csv = Import-Csv -Path "C:\Users\geraldo.borges\CascadeProjects\SAG\Base\Dashboard\racao_insumo.csv" -Encoding UTF8

$sql = New-Object System.Text.StringBuilder

foreach ($row in $csv) {
    $produtoFinal = $row.produto_final.Trim() -replace "'", "''"
    $ingrediente = $row.ingrediente.Trim() -replace "'", "''"
    $qtdDosada = $row.qtd_dosada -replace ',', '.'
    $custo = $row.custo -replace ',', '.'

    # Trata vazios
    if ([string]::IsNullOrWhiteSpace($qtdDosada)) { $qtdDosada = "NULL" }
    if ([string]::IsNullOrWhiteSpace($custo)) { $custo = "NULL" }

    [void]$sql.AppendLine("INSERT INTO POCWEB_DASH_RACAO_INSUMO (PRODUTO_FINAL, INGREDIENTE, QTD_DOSADA, CUSTO) VALUES ('$produtoFinal', '$ingrediente', $qtdDosada, $custo);")
}

[void]$sql.AppendLine("COMMIT;")
[void]$sql.AppendLine("SELECT COUNT(*) AS TOTAL FROM POCWEB_DASH_RACAO_INSUMO;")

$sql.ToString() | Out-File -FilePath "C:\Users\geraldo.borges\CascadeProjects\SAG\Base\Dashboard\insert_racao.sql" -Encoding UTF8

Write-Host "Gerado insert_racao.sql com $($csv.Count) registros"
