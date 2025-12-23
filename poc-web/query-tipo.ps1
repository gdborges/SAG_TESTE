$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=MOOVEFY-0150\SQLEXPRESS;Database=SAG_TESTE;Trusted_Connection=True;TrustServerCertificate=True"
$conn.Open()
$cmd = $conn.CreateCommand()

# Atualizar FILTCONS para incluir coluna Nome
$newFiltcons = @"
[COLUNAS]
Nome=/Tama=200
Tipo=/Tama=150
Ordem=/Tama=60
Ativo=/Tama=50
Bloqueio Comercial=/Tama=90
Bloqueio Financeiro=/Tama=90
Reg. 1601 (SPED Fiscal)=/Tama=90
Codigo=/Tama=60
"@

$cmd.CommandText = "UPDATE SISTCONS SET FILTCONS = @Filt WHERE CODITABE = 210"
$cmd.Parameters.AddWithValue("@Filt", $newFiltcons) | Out-Null
$rows = $cmd.ExecuteNonQuery()
Write-Output "FILTCONS atualizado: $rows rows"

$conn.Close()
