# Deploy da POC SAG na VPS Hostinger

## Informações do Servidor
- **IP:** 72.60.12.53
- **OS:** Ubuntu 24.04 LTS
- **Porta sugerida:** 5050 (para não conflitar com serviços existentes)

## Passo 1: Conectar via SSH

```bash
ssh root@72.60.12.53
```
Senha: (a que você me passou)

## Passo 2: Verificar portas em uso

```bash
ss -tlnp | grep LISTEN
```

## Passo 3: Instalar .NET 9 Runtime (se não instalado)

```bash
# Verificar se já tem .NET
dotnet --version

# Se não tiver, instalar:
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update
apt install -y aspnetcore-runtime-9.0
```

## Passo 4: Criar pasta da aplicação

```bash
mkdir -p /opt/sag-poc
```

## Passo 5: Fazer upload dos arquivos (no seu PC Windows)

Abra outro terminal e execute:

```bash
scp -r "C:\Users\geraldo.borges\CascadeProjects\sag\poc-web\SagPoc.Web\publish-linux\*" root@72.60.12.53:/opt/sag-poc/
```

## Passo 6: Dar permissão de execução (de volta no SSH)

```bash
chmod +x /opt/sag-poc/SagPoc.Web
```

## Passo 7: Testar a aplicação

```bash
cd /opt/sag-poc
ASPNETCORE_ENVIRONMENT=Production ./SagPoc.Web --urls "http://0.0.0.0:5050"
```

Acesse: http://72.60.12.53:5050/Form

## Passo 8: Criar serviço systemd (para rodar permanentemente)

```bash
cat > /etc/systemd/system/sag-poc.service << 'EOF'
[Unit]
Description=SAG POC Web Application
After=network.target

[Service]
WorkingDirectory=/opt/sag-poc
ExecStart=/opt/sag-poc/SagPoc.Web --urls "http://0.0.0.0:5050"
Restart=always
RestartSec=10
Environment=ASPNETCORE_ENVIRONMENT=Production
User=root

[Install]
WantedBy=multi-user.target
EOF
```

## Passo 9: Ativar e iniciar o serviço

```bash
systemctl daemon-reload
systemctl enable sag-poc
systemctl start sag-poc
systemctl status sag-poc
```

## Passo 10: (Opcional) Configurar Nginx como proxy reverso

Se quiser acessar via domínio/subdomínio:

```bash
cat > /etc/nginx/sites-available/sag-poc << 'EOF'
server {
    listen 80;
    server_name sag-poc.seu-dominio.com;

    location / {
        proxy_pass http://localhost:5050;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -s /etc/nginx/sites-available/sag-poc /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

---

## URLs de Acesso

- **Direto por IP:** http://72.60.12.53:5050/Form
- **Lista de formulários:** http://72.60.12.53:5050/Form
- **Formulário 210:** http://72.60.12.53:5050/Form/Render/210

---

## Comandos Úteis

```bash
# Ver logs
journalctl -u sag-poc -f

# Reiniciar serviço
systemctl restart sag-poc

# Parar serviço
systemctl stop sag-poc

# Ver status
systemctl status sag-poc
```
