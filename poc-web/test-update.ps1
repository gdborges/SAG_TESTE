$body = @{
    tableId = 210
    recordId = 9
    fields = @{
        NOMETPDO = "Teste Atualizado"
        TIPOTPDO = "TA"
        ATIVTPDO = 1
        ORDETPDO = 100
        BLCOTPDO = 1
        BLFITPDO = 0
        SF16TPDO = 0
    }
} | ConvertTo-Json -Depth 3

$response = Invoke-WebRequest -Uri 'http://localhost:5255/Form/SaveRecord' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing
Write-Output "Status: $($response.StatusCode)"
Write-Output $response.Content
