# 📝 Exemplo de Uso das Regras de Geração

## 🎯 Cenário de Exemplo

Vamos simular como um usuário forneceria informações e como a IA geraria o arquivo de entrega correspondente, incluindo o fluxo obrigatório de identificação da tarefa.

---

## 📤 Fluxo Completo de Interação

### **Passo 1: Identificação da Tarefa (OBRIGATÓRIO)**

```
IA: "Por favor, informe a tag e número da tarefa para nomenclatura do arquivo:
- Tag do projeto (ex: web, edt, api, mobile, etc.)
- Número da tarefa/issue

Exemplo: web_599 ou edt_1000"

Usuário: "edt_1000"

IA: "Confirmado! O arquivo será salvo como: entregue_edt_1000.md"
```

### **Passo 2: Coleta das Informações da Solução**

```
IA: "Agora, por favor, forneça as informações da solução implementada.
Você pode usar:
- Texto corrido descritivo
- Lista de features
- Formato misto com detalhes técnicos"
```

### **Passo 3: Entrada do Usuário (Exemplo)**
```
Implementei um sistema de conferência de carga que permite criar, atualizar e excluir auditorias.
O sistema controla automaticamente o status da conferência (Open/Finished) e permite incluir identificações de pacotes conhecidos e desconhecidos.
Também implementei a inclusão de pallets completos na conferência, onde cada item do pallet é automaticamente adicionado.
Criei endpoints REST para todas as operações: POST para criar, PUT para atualizar, DELETE para excluir e GET para consultar conferências.
```

### **Opção 2: Lista de Features**
```
- Sistema de conferência de carga com CRUD completo
- Controle automático de status (Open/Finished)
- Inclusão de identificações de pacotes (conhecidos e diversos)
- Inclusão de pallets completos com itens automáticos
- Endpoints REST: POST, PUT, DELETE, GET
- Consulta por código e por ID de carga
- Consulta com filtros avançados
```

### **Opção 3: Formato Misto**
```
Sistema de conferência de carga implementado com as seguintes funcionalidades:

**Principais Features:**
- Criação e manutenção de conferências (Add, Update, Remove)
- Controle automático de status (Open quando criado, Finished quando finalizado)
- Inclusão de identificações de pacotes (conhecidos e diversos)
- Inclusão de pallets completos

**Endpoints Implementados:**
- POST /v1/ExpeditionCargoConference - Criar conferência
- PUT /v1/ExpeditionCargoConference/{code} - Atualizar conferência
- DELETE /v1/ExpeditionCargoConference/{code} - Excluir conferência
- GET /v1/ExpeditionCargoConference/{code} - Consultar por código
- GET /v1/ExpeditionCargoConference/expedition-cargo/{id} - Consultar por ID de carga
- POST /v1/ExpeditionCargoConference/criteria - Consulta com filtros
```

---

## 📥 Saída Gerada pela IA

Baseado nas regras definidas, a IA geraria o seguinte arquivo com o nome correto:

**Arquivo gerado:** `entregue_edt_1000.md`

```markdown
# ✅ Solução Entregue

## 📌 Definição

### 🧩 Novas Entidades, Tabelas, Páginas, Recursos e Definições

#### **Ajustes e Implementações**

- **[+] Criação e manutenção da conferência de carga**
  - Através de comandos `Add`, `Update` e `Remove`, é possível iniciar, atualizar (incluindo finalização) e excluir uma auditoria de carga.
  - O status da conferência é controlado automaticamente conforme as ações:
    - Ao criar: status `Open`, data de abertura e usuário.
    - Ao finalizar: registra usuário e data de fechamento.

---

- **[+] Inclusão de identificações (pacotes) na conferência**
  - Permite adicionar itens conhecidos (registrados previamente) ou desconhecidos (diversos).
  - Itens não encontrados no sistema são registrados como diversos com identificador próprio.
  - Cada identificação inclui informações como:
    - Código do item
    - Usuário e data da conferência
    - Relação com o pallet, se aplicável

---

- **[+] Inclusão de pallets na conferência**
  - Adiciona um pallet com todos os seus itens automaticamente.
  - Para cada item do pallet, é criada uma entrada de identificação na conferência.
  - Garante a rastreabilidade dos itens conferidos por pallet.
  - Também permite remover o pallet com exclusão em cascata dos itens associados.

---

## 🔄 Fluxo

- **[+] Fluxo da conferência**
  1. Criação da conferência (status `Open`)
  2. Inclusão de pacotes manualmente ou via pallet
  3. Possibilidade de tratamento de itens diversos (não cadastrados)
  4. Finalização da conferência (status `Finished`)

---

## 🌐 Endpoints REST

Todos os endpoints estão disponíveis na rota base: `/v1/ExpeditionCargoConference`

| Método | Rota | Ação | Status |
|--------|------|------|--------|
| POST | `/v1/ExpeditionCargoConference` | Criação de nova conferência | ✅ |
| PUT | `/v1/ExpeditionCargoConference/{code}` | Atualização da conferência | ✅ |
| DELETE | `/v1/ExpeditionCargoConference/{code}` | Exclusão da conferência | ✅ |
| GET | `/v1/ExpeditionCargoConference/{code}` | Consulta de conferência por código | ✅ |
| GET | `/v1/ExpeditionCargoConference/expedition-cargo/{id}` | Consulta por ID de carga | ✅ |
| POST | `/v1/ExpeditionCargoConference/criteria` | Consulta com filtros avançados | ✅ |

---

## 🔧 Rotinas e Eventos Afetadas

- **[+] Sistema de Expedição**
  - Novo módulo de conferência de carga integrado ao sistema existente.
  - Impacto na gestão de cargas e controle de qualidade.

---

## 📊 Parâmetros e Recursos Necessários

- **[+] Configurações de Conferência**
  - Parâmetros para controle de status automático.
  - Configurações para tratamento de itens diversos.

---

## ⚠️ Notas Importantes

- **[+] Comportamentos Especiais**
  - Itens não encontrados no sistema são automaticamente registrados como diversos.
  - A inclusão de pallets gera identificações automáticas para todos os itens.
  - O status é controlado automaticamente baseado nas ações do usuário.

- **[+] Considerações de Segurança**
  - Todas as operações são registradas com usuário e data.
  - Validações de permissão para operações de conferência.
```

---

## 🔄 Processo de Geração (Passo a Passo)

### **1. Análise da Entrada**
- ✅ Identificado como texto corrido com elementos técnicos
- ✅ Extraídos endpoints REST
- ✅ Identificadas funcionalidades principais
- ✅ Detectado impacto no sistema de expedição

### **2. Mapeamento para Seções**
- ✅ **Definição**: Mapeadas funcionalidades de conferência
- ✅ **Fluxo**: Identificado processo de conferência
- ✅ **Endpoints**: Extraídos 6 endpoints REST
- ✅ **Impactos**: Sistema de expedição afetado
- ✅ **Configurações**: Parâmetros de conferência

### **3. Geração do Documento**
- ✅ Template aplicado
- ✅ Seções preenchidas com informações extraídas
- ✅ Formato visual consistente
- ✅ Tabela de endpoints incluída

---

## 📋 Checklist de Validação

### **Obrigatório:**
- ✅ Título da solução
- ✅ Pelo menos uma funcionalidade implementada
- ✅ Seção de definição preenchida

### **Opcional mas Recomendado:**
- ✅ Exemplos de código (endpoints)
- ✅ Tabela de endpoints
- ✅ Fluxo detalhado
- ✅ Notas importantes

### **Validações de Qualidade:**
- ✅ Todas as seções preenchidas adequadamente
- ✅ Formatação markdown correta
- ✅ Exemplos de código válidos
- ✅ Consistência de nomenclatura

---

## 🎯 Como Usar

### **Fluxo Obrigatório:**

1. **A IA solicitará** a tag e número da tarefa primeiro
2. **Confirme** a nomenclatura do arquivo
3. **Forneça as informações** da solução no formato desejado
4. **A IA analisará** automaticamente o conteúdo
5. **O documento será gerado** seguindo as regras definidas
6. **O arquivo será salvo** com o nome correto: `entregue_[TAG]_[NUMERO].md`

### **Exemplo de Interação:**
```
Usuário: "Quero gerar um arquivo de entrega"

IA: "Por favor, informe a tag e número da tarefa para nomenclatura do arquivo:
- Tag do projeto (ex: web, edt, api, mobile, etc.)
- Número da tarefa/issue

Exemplo: web_599 ou edt_1000"

Usuário: "web_599"

IA: "Confirmado! O arquivo será salvo como: entregue_web_599.md

Agora, por favor, forneça as informações da solução implementada..."

Usuário: [FORNECE INFORMAÇÕES DA SOLUÇÃO]
```
