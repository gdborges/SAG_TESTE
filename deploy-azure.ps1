# Script de Deploy para VPS com Azure SQL
# Execute: .\deploy-azure.ps1

$VPS_IP = "72.60.12.53"
$VPS_USER = "root"
$VPS_PASS = "GDB0rg3s#270816"
$LOCAL_FILE = "C:\Users\geraldo.borges\CascadeProjects\SAG\poc-web\sag-poc-azure.tar.gz"

Write-Host "=== Deploy SAG POC (Azure SQL) para VPS ===" -ForegroundColor Cyan
Write-Host ""

# Passo 1: Upload
Write-Host "[1/2] Fazendo upload do arquivo..." -ForegroundColor Yellow
Write-Host "Executando: scp $LOCAL_FILE ${VPS_USER}@${VPS_IP}:/opt/" -ForegroundColor Gray
Write-Host "Digite a senha quando solicitado: $VPS_PASS" -ForegroundColor Green
Write-Host ""

scp $LOCAL_FILE "${VPS_USER}@${VPS_IP}:/opt/"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Upload concluido!" -ForegroundColor Green
} else {
    Write-Host "Erro no upload. Verifique a conexao." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/2] Executando deploy na VPS..." -ForegroundColor Yellow
Write-Host "Digite a senha novamente quando solicitado" -ForegroundColor Green
Write-Host ""

$commands = @"
systemctl stop sag-poc
rm -rf /opt/sag-poc/*
tar -xzf /opt/sag-poc-azure.tar.gz -C /opt/sag-poc
chmod +x /opt/sag-poc/SagPoc.Web
systemctl start sag-poc
sleep 2
systemctl status sag-poc
echo ''
echo '=== Deploy concluido! ==='
echo 'Acesse: http://72.60.12.53:5050/Form'
"@

ssh "${VPS_USER}@${VPS_IP}" $commands

Write-Host ""
Write-Host "=== Processo finalizado ===" -ForegroundColor Cyan
Write-Host "Acesse: http://${VPS_IP}:5050/Form" -ForegroundColor Green
