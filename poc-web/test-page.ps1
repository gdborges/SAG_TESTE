$response = Invoke-WebRequest -Uri 'http://localhost:5255/Form/Render/210' -UseBasicParsing
$html = $response.Content
# Extract select options
if ($html -match '<select id="consultaSelect"[^>]*>([\s\S]*?)</select>') {
    Write-Output "Consulta Select Options:"
    Write-Output $Matches[1]
}
