# 📋 Regras para Geração Automática de Arquivos de Entrega

## 🎯 Objetivo
Este documento define as regras e padrões para que uma IA possa gerar automaticamente arquivos de entrega padronizados baseados em informações fornecidas pelo usuário.

## 🏷️ Nomenclatura de Arquivos

### **Padrão Obrigatório:**
Os arquivos de solução entregue devem ser nomeados seguindo o padrão:
```
entregue_[TAG]_[NUMERO]
```

**Exemplos:**
- `entregue_web_599.md` - Entrega da tarefa web número 599
- `entregue_edt_1000.md` - Entrega da tarefa edt número 1000
- `entregue_api_1234.md` - Entrega da tarefa api número 1234
- `entregue_mobile_567.md` - Entrega da tarefa mobile número 567

### **Regras de Nomenclatura:**
- **Tag**: Identificador do projeto/sistema (ex: web, edt, api, mobile, etc.)
- **Número**: Número da tarefa/issue no sistema de controle
- **Extensão**: Sempre `.md` para arquivos markdown
- **Separadores**: Usar underscore (`_`) entre os elementos

## 📝 Formato de Entrada Aceito

### 1. **Texto Corrido**
O usuário pode fornecer uma descrição livre da funcionalidade implementada.

**Exemplo:**
```
Implementei um sistema de autenticação centralizada via gateway que permite login em múltiplos sistemas (Vision e WebService).
Criei endpoints para autenticação conjunta e separada, configurando rotas via appsettings.
O gateway gerencia tokens na sessão e retorna para o cliente.
Adicionei endpoints para consumir recursos Vision e WebService através do gateway.
```

### 2. **Lista de Features**
O usuário pode fornecer uma lista estruturada de funcionalidades.

**Exemplo:**
```
- Gateway com autenticação centralizada
- Endpoints para login conjunto e separado
- Configuração de rotas via appsettings
- Gerenciamento de tokens na sessão
- Endpoints para consumo de recursos Vision/WebService
- Retorno de tokens ao cliente
```

### 3. **Formato Misto**
Combinação de texto descritivo com listas específicas.

## 🔄 Processo de Geração

### **Etapa 1: Análise da Entrada**
- [ ] Identificar o tipo de entrada (texto corrido, lista, ou misto)
- [ ] Extrair informações técnicas (APIs, endpoints, tabelas, etc.)
- [ ] Identificar funcionalidades principais
- [ ] Detectar impactos em sistemas existentes

### **Etapa 2: Mapeamento para Seções**
- [ ] **Definição**: Mapear novas entidades, tabelas, APIs
- [ ] **Fluxo**: Identificar processos e etapas
- [ ] **Endpoints**: Extrair métodos HTTP e rotas
- [ ] **Impactos**: Identificar sistemas afetados
- [ ] **Configurações**: Detectar parâmetros necessários

### **Etapa 3: Geração do Documento**
- [ ] Aplicar template padronizado
- [ ] Preencher seções com informações extraídas
- [ ] Manter formato visual consistente
- [ ] Incluir exemplos de código quando relevante

## 📋 Template de Saída

### **Estrutura Obrigatória:**
```markdown
# ✅ Solução Entregue

## 📌 Definição

### 🧩 Novas Entidades, Tabelas, Páginas, Recursos e Definições

#### **Ajustes e Implementações**

[SEÇÃO GERADA AUTOMATICAMENTE]

---

## 🔄 Fluxo

[SEÇÃO GERADA AUTOMATICAMENTE]

---

## 🌐 Endpoints REST (se aplicável)

[TABELA GERADA AUTOMATICAMENTE]

---

## 🔧 Rotinas e Eventos Afetadas

[SEÇÃO GERADA AUTOMATICAMENTE]

---

## 📊 Parâmetros e Recursos Necessários

[SEÇÃO GERADA AUTOMATICAMENTE]

---

## ⚠️ Notas Importantes

[SEÇÃO GERADA AUTOMATICAMENTE]
```

## 🎯 Regras de Mapeamento

### **Identificação de Endpoints:**
- **Padrões**: `POST`, `GET`, `PUT`, `DELETE` + URLs
- **Exemplo**: "POST /api/gateway/authorize" → Endpoint de autenticação
- **Ação**: Criar entrada na tabela de endpoints

### **Identificação de Tabelas/Entidades:**
- **Padrões**: Nomes em MAIÚSCULAS, "tabela", "entidade", "registro"
- **Exemplo**: "tabela CARGA" → Nova entidade
- **Ação**: Adicionar à seção de novas entidades

### **Identificação de Fluxos:**
- **Padrões**: "fluxo", "processo", "etapa", "passo"
- **Exemplo**: "fluxo de autenticação" → Processo principal
- **Ação**: Criar seção de fluxo

### **Identificação de Configurações:**
- **Padrões**: "appsettings", "configuração", "parâmetro"
- **Exemplo**: "configuração via appsettings" → Seção de configurações
- **Ação**: Adicionar à seção de parâmetros

## 🔧 Regras de Formatação

### **Marcadores de Implementação:**
- Usar `[+]` para novas funcionalidades
- Usar `[-]` para remoções
- Usar `[~]` para modificações

### **Código e Exemplos:**
- Envolver código JSON em blocos de código
- Incluir exemplos de requisições quando relevante
- Manter formatação consistente

### **Tabelas:**
- Usar tabelas markdown para endpoints
- Incluir colunas: Método, Rota, Ação, Status

### **Emojis:**
- Usar emojis para organização visual
- Manter consistência com template existente

## 📊 Exemplos de Mapeamento

### **Entrada:**
```
Implementei autenticação via gateway com endpoints POST /api/gateway/authorize e GET /api/gateway/vision/{serviço}/{rota}
```

### **Saída Gerada:**
```markdown
#### **Ajustes e Implementações**

- **[+] Implementação de Gateway com Autenticação**
- Criação de endpoint para autenticação centralizada.
- Endpoint: `POST /api/gateway/authorize`
- Endpoint para consumo de recursos Vision: `GET /api/gateway/vision/{serviço}/{rota}`

---

## 🌐 Endpoints REST

| Método | Rota | Ação | Status |
|--------|------|------|--------|
| POST | `/api/gateway/authorize` | Autenticação centralizada | ✅ |
| GET | `/api/gateway/vision/{serviço}/{rota}` | Consumo de recursos Vision | ✅ |
```

## ⚠️ Regras de Validação

### **Obrigatório:**
- [ ] Título da solução
- [ ] Pelo menos uma funcionalidade implementada
- [ ] Seção de definição preenchida

### **Opcional mas Recomendado:**
- [ ] Exemplos de código
- [ ] Tabela de endpoints
- [ ] Fluxo detalhado
- [ ] Notas importantes

### **Validações de Qualidade:**
- [ ] Verificar se todas as seções estão preenchidas adequadamente
- [ ] Confirmar formatação markdown correta
- [ ] Validar exemplos de código
- [ ] Verificar consistência de nomenclatura

## 🚀 Instruções para IA

### **Fluxo Obrigatório de Coleta de Informações:**

#### **Etapa 0: Identificação da Tarefa (OBRIGATÓRIO)**
**ANTES de qualquer processamento, a IA DEVE solicitar:**

```
"Por favor, informe a tag e número da tarefa para nomenclatura do arquivo:
- Tag do projeto (ex: web, edt, api, mobile, etc.)
- Número da tarefa/issue

Exemplo: web_599 ou edt_1000"
```

**Regras:**
- ✅ **OBRIGATÓRIO** solicitar antes de processar qualquer informação
- ✅ Aguardar confirmação do usuário
- ✅ Validar formato: [tag]_[numero]
- ✅ Confirmar nome do arquivo: `entregue_[tag]_[numero].md`

#### **Etapa 1: Coleta de Informações da Solução**
Após confirmação da tarefa, solicitar:

```
"Agora, por favor, forneça as informações da solução implementada.
Você pode usar:
- Texto corrido descritivo
- Lista de features
- Formato misto com detalhes técnicos"
```

### **Ao Receber Entrada do Usuário:**

1. **Confirmar** tag e número da tarefa
2. **Analisar** o tipo de entrada fornecida
3. **Extrair** informações técnicas e funcionais
4. **Mapear** para as seções do template
5. **Gerar** o documento seguindo as regras de formatação
6. **Validar** se todas as seções obrigatórias estão preenchidas
7. **Retornar** o arquivo de entrega completo com nome correto

### **Exemplo de Fluxo Completo:**

#### **Passo 1: Solicitação da Tarefa**
```
IA: "Por favor, informe a tag e número da tarefa para nomenclatura do arquivo:
- Tag do projeto (ex: web, edt, api, mobile, etc.)
- Número da tarefa/issue

Exemplo: web_599 ou edt_1000"

Usuário: "web_599"

IA: "Confirmado! O arquivo será salvo como: entregue_web_599.md"
```

#### **Passo 2: Coleta das Informações**
```
IA: "Agora, por favor, forneça as informações da solução implementada.
Você pode usar:
- Texto corrido descritivo
- Lista de features
- Formato misto com detalhes técnicos"

Usuário: [FORNECE INFORMAÇÕES DA SOLUÇÃO]
```

#### **Passo 3: Geração do Arquivo**
```
IA: "Gerando arquivo entregue_web_599.md com base nas informações fornecidas..."
```

### **Resposta Esperada:**
- Arquivo markdown completo
- Formatação consistente
- Todas as seções relevantes preenchidas
- Exemplos de código quando aplicável

## 📝 Notas Finais

- O documento gerado deve ser salvo com nome `entregue_[TAG]_[NUMERO].md` seguindo o padrão estabelecido
- **OBRIGATÓRIO**: Sempre solicitar tag e número da tarefa antes de processar informações
- Manter consistência com arquivos de entrega existentes
- Priorizar clareza e completude das informações
- Incluir exemplos práticos sempre que possível
- Validar formato da nomenclatura antes de gerar o arquivo
