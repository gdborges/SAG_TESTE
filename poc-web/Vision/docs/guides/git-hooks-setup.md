# Configuração de Git Hooks

## 🎯 Objetivo

Este guia explica como configurar o Git Hook que executa automaticamente o `check-pipeline` antes de cada push, garantindo que apenas código validado seja enviado ao repositório.

## 📋 O que o Hook faz?

Quando configurado, o hook `pre-push` irá:

1. Executar automaticamente o comando `npm run check-pipeline` antes de cada `git push`
2. Se o comando passar: permite o push normalmente ✅
3. Se o comando falhar: bloqueia o push e exibe os erros ❌

## 🚀 Como Instalar

### Método 1: Script Automático (Recomendado)

Execute o comando na raiz do projeto:

```bash
npm run setup-hooks
```

Pronto! O hook está configurado e funcionando.

### Método 2: Instalação Manual

Se preferir instalar manualmente ou tiver problemas com o método automático:

1. Navegue até a pasta de hooks do Git:
   ```bash
   cd .git/hooks
   ```

2. Crie um arquivo chamado `pre-push` (sem extensão):
   ```bash
   # Windows (PowerShell)
   New-Item -ItemType File -Name "pre-push"
   
   # Linux/Mac
   touch pre-push
   ```

3. Edite o arquivo `pre-push` e adicione o seguinte conteúdo:

   ```bash
   #!/bin/sh

   # Hook pre-push para executar verificações antes do push
   # Este hook executa o comando check-pipeline antes de permitir o push

   echo "🔍 Executando verificações antes do push..."
   echo "📋 Rodando: npm run check-pipeline"
   echo ""

   # Executa o check-pipeline
   npm run check-pipeline

   # Captura o código de saída
   EXIT_CODE=$?

   if [ $EXIT_CODE -ne 0 ]; then
     echo ""
     echo "❌ ERRO: O check-pipeline falhou!"
     echo "🚫 Push bloqueado. Corrija os problemas acima antes de fazer push."
     echo ""
     exit 1
   fi

   echo ""
   echo "✅ Todas as verificações passaram!"
   echo "🚀 Prosseguindo com o push..."
   echo ""

   exit 0
   ```

4. Dê permissão de execução ao arquivo (Linux/Mac):
   ```bash
   chmod +x pre-push
   ```

## 🧪 Como Testar

Antes de fazer um push real, teste se está funcionando:

```bash
npm run check-pipeline
```

Se o comando executar corretamente, o hook também funcionará.

## 🔧 Solução de Problemas

### O hook não está executando

1. Verifique se o arquivo existe em `.git/hooks/pre-push`
2. Verifique se o arquivo tem permissão de execução (Linux/Mac)
3. Certifique-se de que não há espaços em branco extras no nome do arquivo

### O hook está bloqueando meu push e não deveria

Se você precisar fazer um push urgente pulando as verificações (não recomendado):

```bash
git push --no-verify
```

**⚠️ Atenção:** Use isso apenas em emergências! O ideal é corrigir os problemas apontados pelo `check-pipeline`.

### Como remover o hook

Se precisar desabilitar o hook:

```bash
# Windows (PowerShell)
Remove-Item .git/hooks/pre-push

# Linux/Mac
rm .git/hooks/pre-push
```

## 📤 Distribuindo para a Equipe

### Arquivos para Compartilhar

Para que outros membros da equipe configurem o hook, compartilhe:

1. O arquivo `scripts/setup-git-hooks.ts`
2. Este guia (`docs/guides/git-hooks-setup.md`)
3. Instrução para executar: `npm run setup-hooks`

### Passo a Passo para Novos Desenvolvedores

1. Clone o repositório
2. Instale as dependências: `npm install`
3. Configure os hooks: `npm run setup-hooks`
4. Pronto! O hook está ativo

## 💡 Boas Práticas

- ✅ Execute `npm run check-pipeline` localmente antes de fazer commit
- ✅ Corrija os erros apontados pelo pipeline antes de tentar push
- ✅ Não use `--no-verify` a menos que seja absolutamente necessário
- ✅ Mantenha o hook sempre ativo para garantir qualidade do código

## 📚 Mais Informações

Para mais detalhes sobre o que o `check-pipeline` verifica, consulte o arquivo `scripts/check-pipeline.ts`.

## 🤝 Suporte

Se encontrar problemas na configuração do hook, entre em contato com a equipe de desenvolvimento.

