# Script de Deploy para VPS Hostinger
# Execute no PowerShell: .\deploy.ps1

$VPS_IP = "72.60.12.53"
$VPS_USER = "root"
$APP_PATH = "/opt/sag-poc"
$LOCAL_PATH = "C:\Users\geraldo.borges\CascadeProjects\sag\poc-web\SagPoc.Web\publish-linux"

Write-Host "=== Deploy SAG POC para VPS ===" -ForegroundColor Cyan
Write-Host ""

# Passo 1: Upload dos arquivos
Write-Host "[1/3] Fazendo upload dos arquivos..." -ForegroundColor Yellow
Write-Host "Execute o comando SCP abaixo e digite a senha quando solicitado:"
Write-Host ""
Write-Host "scp -r `"$LOCAL_PATH\*`" ${VPS_USER}@${VPS_IP}:${APP_PATH}/" -ForegroundColor Green
Write-Host ""

Read-Host "Pressione ENTER após concluir o upload"

# Passo 2: Conectar via SSH
Write-Host ""
Write-Host "[2/3] Conectando via SSH para configurar..." -ForegroundColor Yellow
Write-Host "Execute o comando SSH abaixo:"
Write-Host ""
Write-Host "ssh ${VPS_USER}@${VPS_IP}" -ForegroundColor Green
Write-Host ""

Write-Host "Depois de conectado, execute estes comandos:" -ForegroundColor Yellow
Write-Host @"

# Criar pasta (se não existir)
mkdir -p $APP_PATH

# Dar permissão
chmod +x $APP_PATH/SagPoc.Web

# Criar serviço
cat > /etc/systemd/system/sag-poc.service << 'EOF'
[Unit]
Description=SAG POC Web Application
After=network.target

[Service]
WorkingDirectory=$APP_PATH
ExecStart=$APP_PATH/SagPoc.Web --urls "http://0.0.0.0:5050"
Restart=always
RestartSec=10
Environment=ASPNETCORE_ENVIRONMENT=Production
User=root

[Install]
WantedBy=multi-user.target
EOF

# Ativar e iniciar
systemctl daemon-reload
systemctl enable sag-poc
systemctl start sag-poc
systemctl status sag-poc

"@ -ForegroundColor Cyan

Write-Host ""
Write-Host "[3/3] Após executar os comandos acima, acesse:" -ForegroundColor Yellow
Write-Host "http://${VPS_IP}:5050/Form" -ForegroundColor Green
Write-Host ""
