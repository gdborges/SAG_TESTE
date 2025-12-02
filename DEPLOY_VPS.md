# Deploy da POC SAG na VPS Hostinger

## Informações do Servidor

| Item | Valor |
|------|-------|
| **IP** | 72.60.12.53 |
| **OS** | Ubuntu 24.04 LTS |
| **Porta** | 5050 |
| **URL** | http://72.60.12.53:5050 |
| **Diretório** | /opt/sag-poc |
| **Serviço** | sag-poc.service |
| **Usuário SSH** | root |

---

## Deploy Rápido (One-liner)

Execute este comando para fazer deploy completo:

```bash
cd C:\Users\geraldo.borges\CascadeProjects\SAG\poc-web\SagPoc.Web && dotnet publish -c Release -r linux-x64 --self-contained -o ../publish-linux && cd .. && tar -czvf sag-poc.tar.gz -C publish-linux . && scp sag-poc.tar.gz root@72.60.12.53:/opt/sag-poc/ && ssh root@72.60.12.53 "cd /opt/sag-poc && systemctl stop sag-poc && tar -xzf sag-poc.tar.gz && rm sag-poc.tar.gz && chmod +x SagPoc.Web && systemctl start sag-poc && systemctl status sag-poc --no-pager"
```

---

## Deploy Passo a Passo

### 1. Build e Publicação Local

```bash
cd C:\Users\geraldo.borges\CascadeProjects\SAG\poc-web\SagPoc.Web

# Publicar para Linux x64 (self-contained)
dotnet publish -c Release -r linux-x64 --self-contained -o ../publish-linux
```

### 2. Criar Pacote para Transferência

```bash
cd C:\Users\geraldo.borges\CascadeProjects\SAG\poc-web

# Criar arquivo tar.gz
tar -czvf sag-poc.tar.gz -C publish-linux .
```

### 3. Transferir para o Servidor

```bash
# Enviar pacote
scp sag-poc.tar.gz root@72.60.12.53:/opt/sag-poc/

# Enviar script SQL (se necessário atualizar banco)
scp sqlite_init.sql root@72.60.12.53:/opt/sag-poc/
```

### 4. Deploy no Servidor

```bash
ssh root@72.60.12.53

# No servidor:
cd /opt/sag-poc
systemctl stop sag-poc
tar -xzf sag-poc.tar.gz
rm sag-poc.tar.gz
chmod +x SagPoc.Web
systemctl start sag-poc
systemctl status sag-poc
```

---

## Atualizar Banco de Dados

**IMPORTANTE:** Sempre criar o banco no Linux para manter encoding UTF-8 correto!

```bash
# Enviar SQL para o servidor
scp sqlite_init.sql root@72.60.12.53:/opt/sag-poc/

# Criar banco no servidor (Linux usa UTF-8 nativamente)
ssh root@72.60.12.53 "cd /opt/sag-poc && systemctl stop sag-poc && rm -f sag_poc.db && sqlite3 sag_poc.db < sqlite_init.sql && systemctl start sag-poc"
```

### Verificar Encoding

```bash
ssh root@72.60.12.53 "sqlite3 /opt/sag-poc/sag_poc.db \"SELECT LabeCamp FROM SistCamp WHERE LabeCamp LIKE '%Toler%' LIMIT 1\""
# Deve retornar: Tolerância Contrato (com acento)
```

---

## Comandos Úteis

### Status e Logs

```bash
# Ver status do serviço
ssh root@72.60.12.53 "systemctl status sag-poc --no-pager"

# Ver logs
ssh root@72.60.12.53 "journalctl -u sag-poc -n 50 --no-pager"

# Logs em tempo real
ssh root@72.60.12.53 "journalctl -u sag-poc -f"
```

### Controle do Serviço

```bash
# Reiniciar
ssh root@72.60.12.53 "systemctl restart sag-poc"

# Parar
ssh root@72.60.12.53 "systemctl stop sag-poc"

# Iniciar
ssh root@72.60.12.53 "systemctl start sag-poc"
```

### Banco de Dados

```bash
# Contar registros
ssh root@72.60.12.53 "sqlite3 /opt/sag-poc/sag_poc.db 'SELECT COUNT(*) FROM SistCamp'"

# Listar tabelas
ssh root@72.60.12.53 "sqlite3 /opt/sag-poc/sag_poc.db '.tables'"

# Ver estrutura de tabela
ssh root@72.60.12.53 "sqlite3 /opt/sag-poc/sag_poc.db 'PRAGMA table_info(SistCamp)'"
```

### Testar Aplicação

```bash
# Testar renderização de formulário
ssh root@72.60.12.53 "curl -s localhost:5050/Form/Render/514 | head -50"

# Verificar se aplicação responde
ssh root@72.60.12.53 "curl -s -o /dev/null -w '%{http_code}' localhost:5050/"
```

---

## Configuração Inicial (Primeira Instalação)

### Instalar .NET 9 Runtime

```bash
ssh root@72.60.12.53

# Verificar se já tem .NET
dotnet --version

# Se não tiver, instalar:
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update
apt install -y aspnetcore-runtime-9.0
```

### Criar Diretório

```bash
mkdir -p /opt/sag-poc
```

### Criar Serviço Systemd

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

systemctl daemon-reload
systemctl enable sag-poc
```

---

## Problemas Conhecidos e Soluções

### Encoding UTF-8 (Caracteres Especiais)

**Problema:** Caracteres portugueses (ã, ç, é, etc.) aparecem como `??`

**Causa:** Banco SQLite criado no Windows com encoding incorreto

**Solução:** Sempre criar o banco no servidor Linux:
```bash
scp sqlite_init.sql root@72.60.12.53:/opt/sag-poc/
ssh root@72.60.12.53 "cd /opt/sag-poc && rm -f sag_poc.db && sqlite3 sag_poc.db < sqlite_init.sql"
```

### Aplicação não inicia

1. Verificar logs: `journalctl -u sag-poc -n 100`
2. Verificar permissões: `chmod +x SagPoc.Web`
3. Verificar se porta está em uso: `netstat -tlnp | grep 5050`

### Conexão SSH lenta/timeout

```bash
# Usar opções para evitar timeout
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15 root@72.60.12.53 "comando"
```

---

## URLs de Acesso

| Página | URL |
|--------|-----|
| Home | http://72.60.12.53:5050 |
| Lista de Formulários | http://72.60.12.53:5050/Form |
| Formulário 210 | http://72.60.12.53:5050/Form/Render/210 |
| Formulário 514 | http://72.60.12.53:5050/Form/Render/514 |

---

## Histórico de Deploys

| Data | Commit | Descrição |
|------|--------|-----------|
| 2025-12-02 | - | Deploy inicial com formulários dinâmicos |
| 2025-12-02 | - | Suporte a abas e tipos estendidos |
| 2025-12-02 | 329a830 | Implementação de campos T/IT (LookupCombo) com SQL_CAMP |
| 2025-12-02 | 329a830 | Correção de encoding UTF-8 para caracteres portugueses |

---

## Configuração Nginx (Opcional)

Para acessar via domínio/subdomínio:

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
