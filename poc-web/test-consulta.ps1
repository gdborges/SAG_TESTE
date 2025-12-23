$body = '{"tableId":210,"consultaId":210000,"filters":[],"page":1,"pageSize":20}'
$response = Invoke-WebRequest -Uri 'http://localhost:5255/Form/ExecuteConsulta' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing
Write-Output "Status: $($response.StatusCode)"
Write-Output $response.Content
