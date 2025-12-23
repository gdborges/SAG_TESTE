$body = @{
    tableId = 210
    recordId = $null
    fields = @{
        NOMETPDO = "Teste Novo"
        TIPOTPDO = "TN"
        ATIVTPDO = 1
        ORDETPDO = 99
        BLCOTPDO = 0
        BLFITPDO = 0
        SF16TPDO = 0
    }
} | ConvertTo-Json -Depth 3

$response = Invoke-WebRequest -Uri 'http://localhost:5255/Form/SaveRecord' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing
Write-Output "Status: $($response.StatusCode)"
Write-Output $response.Content
