# Guia de Verificação de Cobertura de Testes

Este guia explica como usar o script de verificação de cobertura de testes do projeto.

## Visão Geral

O script `check-test-coverage.ts` verifica se cada arquivo `.ts` e `.vue` do projeto possui pelo menos um arquivo de teste correspondente, garantindo que a cobertura de testes esteja adequada.

## Como Executar

### Via NPM Script (Recomendado)

```bash
npm run check-test-coverage
```

### Via Comando Direto

```bash
# Navegue até a pasta scripts
cd scripts

# Execute o script
npx tsx check-test-coverage.ts
```

## O que o Script Analisa

### Pastas Analisadas
- `components` - Componentes Vue reutilizáveis
- `composables` - Funções composables do Vue
- `directives` - Diretivas customizadas
- `layouts` - Layouts da aplicação
- `plugins` - Plugins do Vue
- `server` - APIs e middleware do servidor
- `stores` - Stores do Pinia
- `utils` - Funções utilitárias
- `views` - Páginas da aplicação

### Pastas Ignoradas
- `assets` - Recursos estáticos
- `docs` - Documentação
- `interfaces` - Definições de tipos TypeScript
- `modules` - Módulos de configuração
- `router` - Configuração de rotas
- `translations` - Arquivos de tradução

### Tipos de Arquivos Verificados
- **Arquivos fonte**: `.ts` e `.vue` (exceto arquivos de teste)
- **Arquivos de teste**: `.spec.ts` e `.test.ts`

## Regras de Cobertura

### 1. Pastas de Views (Regra Especial)

Para pastas de views que contêm múltiplos arquivos (como páginas com abas), a regra é mais flexível:

- **Exemplo**: Pasta `non-compliance/` com arquivos:
  - `action-plan.vue`
  - `details.vue` 
  - `non-compliance.vue`

- **Requisito**: Basta ter pelo menos um arquivo de teste na pasta `tests/` para que todos os arquivos sejam considerados cobertos
- **Arquivo de teste aceito**: `tests/action-plan.spec.ts` (qualquer um dos três)

### 2. Outras Pastas

Para todas as outras pastas, cada arquivo individual deve ter seu próprio arquivo de teste correspondente:

- **Arquivo**: `components/Button.vue`
- **Teste necessário**: `components/tests/Button.spec.ts`

## Exemplo de Relatório

```
📊 RELATÓRIO DE COBERTURA DE TESTES

════════════════════════════════════════════════════════════

📈 RESUMO GERAL:
   📁 Pastas analisadas: 9
   📄 Total de arquivos: 310
   ✅ Arquivos com testes: 173
   📊 Cobertura geral: 55.8%

📋 RESUMO POR STATUS:
   🟢 Pastas com cobertura completa: 3
   🟡 Pastas com cobertura parcial: 6
   🔴 Pastas sem testes: 0

📁 DETALHES POR PASTA:
────────────────────────────────────────────────────────────

🟡 components
   📊 Cobertura: 35.1% ████░░░░░░
   📄 Arquivos: 27/77 com testes
   ❌ Arquivos sem testes:
      • AttachmentModal.vue
      • cards\BalanceCard.vue
      • Carousel.vue
      ...
```

## Códigos de Saída

- **0**: ✅ Sucesso - Todos os arquivos possuem cobertura de testes
- **1**: ⚠️ Falha - Alguns arquivos ainda não possuem testes

## Integração com CI/CD

O script pode ser integrado em pipelines de CI/CD para garantir que novos commits mantenham a cobertura de testes:

```yaml
# Exemplo para GitHub Actions
- name: Check Test Coverage
  run: npm run check-test-coverage
```

## Dicas para Melhorar a Cobertura

1. **Priorize componentes críticos**: Comece testando componentes que são mais utilizados
2. **Use a regra especial para views**: Para páginas com abas, crie um teste representativo
3. **Teste funções utilitárias**: São mais fáceis de testar e têm alto impacto
4. **Configure testes automáticos**: Use o script regularmente durante o desenvolvimento

## Configuração

O script utiliza o arquivo `scripts/tsconfig.json` para configuração do TypeScript, que estende a configuração principal do projeto com configurações específicas para execução de scripts Node.js.

## Dependências

- Node.js
- TypeScript
- tsx (já incluído nas devDependencies do projeto)

## Troubleshooting

### Erro: "Diretório src não encontrado"
- Certifique-se de executar o comando a partir da raiz do projeto
- Verifique se a pasta `src/` existe

### Erro: "tsx não encontrado"
- Execute `npm install` para instalar as dependências
- O tsx já está incluído nas devDependencies do projeto
