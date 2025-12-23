# Script para exportar tabela 120 do Azure SQL para SQL Express local
$azureConn = "Server=tcp:gdb-testes.database.windows.net,1433;Initial Catalog=GDB_TESTE;Persist Security Info=False;User ID=gdborges;Password=GDB0rg3s#;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
$localConn = "Server=MOOVEFY-0150\SQLEXPRESS;Database=SAG_TESTE;Trusted_Connection=True;TrustServerCertificate=True"

# Conectar ao Azure
$azure = New-Object System.Data.SqlClient.SqlConnection
$azure.ConnectionString = $azureConn
$azure.Open()
Write-Host "Conectado ao Azure SQL"

# Buscar dados SISTTABE da tabela 120
$cmd = $azure.CreateCommand()
$cmd.CommandText = "SELECT * FROM SISTTABE WHERE CODITABE = 120"
$reader = $cmd.ExecuteReader()
$sisttabe = @()
while ($reader.Read()) {
    $row = @{}
    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
        $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
    }
    $sisttabe += $row
}
$reader.Close()
Write-Host "SISTTABE: $($sisttabe.Count) registros encontrados"

# Buscar dados SISTCAMP da tabela 120
$cmd.CommandText = "SELECT * FROM SISTCAMP WHERE CODITABE = 120"
$reader = $cmd.ExecuteReader()
$sistcamp = @()
while ($reader.Read()) {
    $row = @{}
    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
        $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
    }
    $sistcamp += $row
}
$reader.Close()
Write-Host "SISTCAMP: $($sistcamp.Count) registros encontrados"

# Buscar SISTCONS da tabela 120
$cmd.CommandText = "SELECT * FROM SISTCONS WHERE CODITABE = 120"
$reader = $cmd.ExecuteReader()
$sistcons = @()
while ($reader.Read()) {
    $row = @{}
    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
        $row[$reader.GetName($i)] = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
    }
    $sistcons += $row
}
$reader.Close()
Write-Host "SISTCONS: $($sistcons.Count) registros encontrados"

$azure.Close()

# Exibir alguns campos para debug
Write-Host "`n--- Campos SISTCAMP (tabela 120) ---"
foreach ($c in $sistcamp | Sort-Object ORDECAMP) {
    Write-Host "ORDE: $($c.ORDECAMP) | NOME: $($c.NOMECAMP) | LABE: '$($c.LABECAMP)' | COMP: $($c.COMPCAMP)"
}

# Conectar ao local
$local = New-Object System.Data.SqlClient.SqlConnection
$local.ConnectionString = $localConn
$local.Open()
Write-Host "`nConectado ao SQL Express local"

# Inserir SISTTABE
if ($sisttabe.Count -gt 0) {
    $cmd = $local.CreateCommand()
    $cmd.CommandText = "DELETE FROM SISTTABE WHERE CODITABE = 120"
    $cmd.ExecuteNonQuery() | Out-Null

    foreach ($row in $sisttabe) {
        $cols = $row.Keys -join ","
        $params = ($row.Keys | ForEach-Object { "@$_" }) -join ","
        $cmd.CommandText = "INSERT INTO SISTTABE ($cols) VALUES ($params)"
        $cmd.Parameters.Clear()
        foreach ($key in $row.Keys) {
            $cmd.Parameters.AddWithValue("@$key", $(if ($null -eq $row[$key]) { [DBNull]::Value } else { $row[$key] })) | Out-Null
        }
        $cmd.ExecuteNonQuery() | Out-Null
    }
    Write-Host "SISTTABE: $($sisttabe.Count) registros inseridos"
}

# Inserir SISTCAMP
if ($sistcamp.Count -gt 0) {
    $cmd = $local.CreateCommand()
    $cmd.CommandText = "DELETE FROM SISTCAMP WHERE CODITABE = 120"
    $cmd.ExecuteNonQuery() | Out-Null

    foreach ($row in $sistcamp) {
        $cols = $row.Keys -join ","
        $params = ($row.Keys | ForEach-Object { "@$_" }) -join ","
        $cmd.CommandText = "INSERT INTO SISTCAMP ($cols) VALUES ($params)"
        $cmd.Parameters.Clear()
        foreach ($key in $row.Keys) {
            $cmd.Parameters.AddWithValue("@$key", $(if ($null -eq $row[$key]) { [DBNull]::Value } else { $row[$key] })) | Out-Null
        }
        $cmd.ExecuteNonQuery() | Out-Null
    }
    Write-Host "SISTCAMP: $($sistcamp.Count) registros inseridos"
}

# Inserir SISTCONS
if ($sistcons.Count -gt 0) {
    $cmd = $local.CreateCommand()
    $cmd.CommandText = "DELETE FROM SISTCONS WHERE CODITABE = 120"
    $cmd.ExecuteNonQuery() | Out-Null

    foreach ($row in $sistcons) {
        $cols = $row.Keys -join ","
        $params = ($row.Keys | ForEach-Object { "@$_" }) -join ","
        $cmd.CommandText = "INSERT INTO SISTCONS ($cols) VALUES ($params)"
        $cmd.Parameters.Clear()
        foreach ($key in $row.Keys) {
            $cmd.Parameters.AddWithValue("@$key", $(if ($null -eq $row[$key]) { [DBNull]::Value } else { $row[$key] })) | Out-Null
        }
        $cmd.ExecuteNonQuery() | Out-Null
    }
    Write-Host "SISTCONS: $($sistcons.Count) registros inseridos"
}

$local.Close()
Write-Host "`nExportacao concluida!"
