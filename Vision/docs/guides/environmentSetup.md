# Configuração de Ambiente Flexível

Este guia explica como usar o sistema de configuração flexível que permite trabalhar tanto localmente quanto com o backend no servidor 5 via VPN.

## 🎯 Visão Geral

O sistema foi configurado para funcionar em dois cenários:
- **Desenvolvimento Local**: Usa proxy Vite para evitar problemas de CORS
- **Servidor Remoto**: Conecta diretamente ao servidor 5 via VPN

## 🚀 Como Usar

### Desenvolvimento Local (Recomendado)
```bash
npm run dev
```
- Usa proxy local (`/api/local` → `localhost:8001`)
- Evita problemas de CORS
- Ideal para desenvolvimento

### Desenvolvimento com Backend Remoto
```bash
npm run dev:remote
```
- Conecta diretamente ao servidor 5 (`192.168.1.5:8001`)
- Usado quando backend está no servidor remoto
- Requer VPN ativa

### Build para Produção
```bash
npm run build
```
- Configura automaticamente para produção
- Conecta ao servidor 5

## 🔧 Configurações Automáticas

### Desenvolvimento Local
```javascript
window._clientSettings = {
  environment: "development",
  apiUrl: "/api/local",        // Proxy local
  websocketUrl: "/ws/local",   // Proxy local
  webServiceUrl: "http://192.168.1.5:15020/datasnap/rest/RESTWebServiceMethods",
  homeToRedirect: "PAC"
};
```

### Produção/Remoto
```javascript
window._clientSettings = {
  environment: "production",
  apiUrl: "http://192.168.1.5:8001/api",      // Conexão direta
  websocketUrl: "ws://192.168.1.5:8001",      // Conexão direta
  webServiceUrl: "http://192.168.1.5:15020/datasnap/rest/RESTWebServiceMethods",
  homeToRedirect: "PAC"
};
```

## 🛠️ Arquivos Modificados

### 1. `vite.config.ts`
- Adicionado proxy para `/api/local` e `/api/remote`
- Adicionado proxy para WebSocket `/ws/local` e `/ws/remote`

### 2. `src/utils/configs/environmentDetector.ts` (NOVO)
- Sistema de detecção automática de ambiente
- Funções para obter URLs corretas

### 3. `src/composables/useFetch.ts`
- Atualizado para usar detecção automática
- Remove dependência de configuração estática

### 4. `scripts/deploy-config.ts` (NOVO)
- Script para alternar entre configurações
- Usado automaticamente pelos scripts npm

### 5. `package.json`
- Novos scripts: `dev`, `dev:remote`, `config:dev`, `config:prod`

## 🔍 Detecção Automática

O sistema detecta automaticamente o ambiente baseado em:
- Hostname (`localhost`, `127.0.0.1`, `0.0.0.0`)
- Configuração `environment` no `settings.js`

## 🚨 Troubleshooting

### Problema: CORS Error
**Solução**: Use `npm run dev` (modo desenvolvimento local)

### Problema: Não consegue conectar ao servidor 5
**Solução**:
1. Verifique se a VPN está ativa
2. Use `npm run dev:remote`
3. Verifique se o servidor 5 está acessível

### Problema: Proxy não funciona
**Solução**:
1. Verifique se o backend local está rodando na porta 8001
2. Use `npm run dev:remote` para conectar diretamente

## 📋 Checklist de Deploy

- [ ] VPN ativa (se usando servidor remoto)
- [ ] Backend acessível
- [ ] Configuração correta no `settings.js`
- [ ] Teste de conectividade

## 🎯 Benefícios

✅ **Sem CORS**: Proxy resolve problemas automaticamente
✅ **Flexibilidade**: Funciona local e remoto
✅ **Automático**: Detecção inteligente de ambiente
✅ **Simples**: Comandos npm fáceis de usar
✅ **Robusto**: Fallback para diferentes cenários
