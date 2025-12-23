$response = Invoke-WebRequest -Uri 'http://localhost:5255/Form/GetRecord?tableId=210&recordId=1' -UseBasicParsing
Write-Output "Status: $($response.StatusCode)"
Write-Output $response.Content
