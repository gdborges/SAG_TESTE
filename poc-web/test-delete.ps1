$response = Invoke-WebRequest -Uri 'http://localhost:5255/Form/DeleteRecord?tableId=210&recordId=9' -Method DELETE -UseBasicParsing
Write-Output "Status: $($response.StatusCode)"
Write-Output $response.Content
