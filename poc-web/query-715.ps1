$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=MOOVEFY-0150\SQLEXPRESS;Database=SAG_TESTE;Trusted_Connection=True;TrustServerCertificate=True"
$conn.Open()
$cmd = $conn.CreateCommand()

# Buscar campos do formulario 715 que possam estar no bevel errado
$cmd.CommandText = @"
SELECT CodiCamp, NomeCamp, LEFT(LabeCamp, 25) as Label, CompCamp, OrdeCamp, TopoCamp, EsquCamp, TamaCamp, AltuCamp
FROM SistCamp
WHERE CodiTabe = 715
ORDER BY OrdeCamp
"@

$reader = $cmd.ExecuteReader()
Write-Output "Campos ordenados por OrdeCamp:"
Write-Output "Ordem | CodiCamp | NomeCamp | Label | Comp | Top | Esq"
Write-Output "------|----------|----------|-------|------|-----|----"
while ($reader.Read()) {
    $line = "$($reader['OrdeCamp']) | $($reader['CodiCamp']) | $($reader['NomeCamp']) | $($reader['Label']) | $($reader['CompCamp']) | $($reader['TopoCamp']) | $($reader['EsquCamp'])"
    Write-Output $line
}
$reader.Close()
$conn.Close()
