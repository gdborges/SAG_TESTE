$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=tcp:gdb-testes.database.windows.net,1433;Initial Catalog=GDB_TESTE;Persist Security Info=False;User ID=gdborges;Password=GDB0rg3s#;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
$conn.Open()
$cmd = $conn.CreateCommand()

# Buscar todos os campos do form 715 ordenados por OrdeCamp
$cmd.CommandText = @"
SELECT CodiCamp, NomeCamp, LabeCamp, CompCamp, OrdeCamp, TopoCamp, EsquCamp, TamaCamp, AltuCamp
FROM SistCamp
WHERE CodiTabe = 715
ORDER BY OrdeCamp, TopoCamp, EsquCamp
"@

$reader = $cmd.ExecuteReader()
Write-Output "Ordem | Codi | NomeCamp          | Label                    | Comp | Top  | Esq  | Tama | Altu"
Write-Output "------|------|-------------------|--------------------------|------|------|------|------|------"
while ($reader.Read()) {
    $ordem = $reader['OrdeCamp'].ToString().PadLeft(5)
    $codi = $reader['CodiCamp'].ToString().PadLeft(4)
    $nome = $reader['NomeCamp'].ToString().PadRight(17).Substring(0,17)
    $label = $reader['LabeCamp'].ToString().PadRight(24).Substring(0,24)
    $comp = $reader['CompCamp'].ToString().PadRight(4)
    $top = $reader['TopoCamp'].ToString().PadLeft(4)
    $esq = $reader['EsquCamp'].ToString().PadLeft(4)
    $tama = $reader['TamaCamp'].ToString().PadLeft(4)
    $altu = $reader['AltuCamp'].ToString().PadLeft(4)
    Write-Output "$ordem | $codi | $nome | $label | $comp | $top | $esq | $tama | $altu"
}
$reader.Close()
$conn.Close()
