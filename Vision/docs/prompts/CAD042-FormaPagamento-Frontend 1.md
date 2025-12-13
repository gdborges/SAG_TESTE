# [Front-end] Vision - CAD042 - Cadastro de Formas de Pagamento

Descrição:

Foi criada na API do Core a entidade PaymentMethod. O desenvolvedor deverá criar, no módulo de Registro, a tela CAD042 - Cadastro de Formas de Pagamento, realizando o consumo dos dados expostos pela API.

## 🗂️ Estrutura de Telas e Guias (CRUD)

### **Tela Principal: Cadastro de Formas de Pagamento**
- **Guia Detalhes:** Formulário de cadastro/edição da forma de pagamento
- **Guia Parcelas:** Configuração das parcelas da forma de pagamento

### **Componentes da Interface:**
- **Grid Principal:** Lista com colunas: Código, Descrição, Nº Parcelas, Var. Dias Parcelas, Var. Valor Parcelas (%), Ativo?
- **Formulário Detalhes:** Campos de entrada para dados da forma de pagamento
- **Formulário Parcelas:** Grid e campos para configuração das parcelas
- **Barra de Ferramentas:** Botões de navegação, inclusão, exclusão, gravação, cancelamento

## 🗂️ Mapeamento de Campos (Frontend ↔ Backend)

| Campo Frontend | Campo Backend | Tipo/Dados | Obrigatório | Regras/Validações Específicas |
|----------------|---------------|------------|-------------|-------------------------------|
| `Código` | `code` | Numérico | Sim (Automático) | Campo gerado automaticamente pelo sistema, não editável |
| `Código Interno` | `internalCode` | Numérico | Não | Campo interno para integração |
| `Código Externo` | `externalCode` | Texto (15) | Não | Código para integração externa |
| `Descrição da Forma de Pagamento` | `description` | Texto (40) | Sim | Nome descritivo da forma de pagamento |
| `Nº de Parcelas` | `parcelNumber` | Numérico | Sim | Valor entre 1 e 120 |
| `Centavos na 1ª Parcela` | `firstParcelCent` | ComboBox | Sim | Valores: 'S' (Sim), 'N' (Não) |
| `Dias do Vencimento` | `daysToPayment` | Numérico | Não | Valor entre 0 e 999 |
| `Valor das Parcelas (%)` | `percentageOfParcelValue` | Decimal | Não | Percentual entre 0 e 100 |
| `Ativo?` | `active` | ComboBox | Sim | Valores: 'S' (Sim), 'N' (Não) |
| `Envia ao Palm?` | `sendToPalm` | ComboBox | Sim | Valores: 'S' (Sim), 'N' (Não) |
| `Indicador Forma Pagto.` | `indicatorFormPayment` | ComboBox | Sim | Valores: '0' (Pagamento à Vista), '1' (Pagamento à Prazo), '2' (Outros), '3' (Pré-Pago) |

### **Campos de Parcelas:**
| Campo Frontend | Campo Backend | Tipo/Dados | Obrigatório | Regras/Validações Específicas |
|----------------|---------------|------------|-------------|-------------------------------|
| `Nº Parcela` | `parcelNumber` | Texto (3) | Sim | Número sequencial da parcela |
| `Perc. Parcela` | `percentageOfParcel` | Decimal | Sim | Percentual da parcela (soma deve ser 100%) |
| `Dias da Parcela` | `daysOfParcel` | Numérico | Sim | Dias para vencimento da parcela |

## 🚦 Regras de UI e Validações

### **Validações de Negócio:**
1. **Parcelas:** A soma das porcentagens das parcelas deve ser igual a 100%
2. **Dias das Parcelas:** A quantidade de dias da parcela deve ser superior à da parcela anterior
3. **Parcela Única:** Se for parcela única, os centavos devem estar contidos nela
4. **Forma Ativa:** Se a forma de pagamento não estiver ativa, não pode enviar ao Palm
5. **Registro Fixo:** Registros marcados como fixos não podem ser excluídos

### **Validações de Interface:**
1. **Campos Obrigatórios:** Todos os campos marcados como obrigatórios devem ser preenchidos
2. **Formatação:** Valores monetários devem ser formatados adequadamente
3. **Navegação:** Usuário deve poder navegar entre as guias de forma intuitiva
4. **Feedback:** Mensagens de erro e sucesso devem ser claras e objetivas

### **Comportamentos Especiais:**
1. **Geração Automática de Parcelas:** Ao alterar o número de parcelas, o sistema deve gerar automaticamente as parcelas
2. **Validação de Parcelas:** Botão "Validar" deve verificar se as parcelas estão corretas
3. **Status de Validação:** Formas de pagamento podem ter status "Aguardando Verificação" (AV) ou "Liberado" (LB)
4. **Integração Middleware:** Campo código externo pode ser bloqueado se houver integração ativa

## 🚀 Ações

### **Ações Principais:**
1. **Incluir:** Criar nova forma de pagamento
2. **Editar:** Modificar forma de pagamento existente
3. **Excluir:** Remover forma de pagamento (exceto registros fixos)
4. **Validar:** Verificar se as parcelas estão corretas
5. **Navegar:** Mover entre registros usando botões de navegação

### **Ações de Parcelas:**
1. **Configurar Parcelas:** Definir número, percentual e dias de cada parcela
2. **Validar Parcelas:** Verificar se a soma dos percentuais é 100%
3. **Gerar Parcelas:** Criar automaticamente as parcelas baseado no número informado

## ✅ Critérios de Aceitação

### **Funcionalidades Básicas:**
- [ ] Usuário pode visualizar lista de formas de pagamento em grid
- [ ] Usuário pode filtrar formas de pagamento por critérios
- [ ] Usuário pode incluir nova forma de pagamento
- [ ] Usuário pode editar forma de pagamento existente
- [ ] Usuário pode excluir forma de pagamento (exceto registros fixos)

### **Validações:**
- [ ] Sistema valida campos obrigatórios antes de gravar
- [ ] Sistema valida se soma das parcelas é 100%
- [ ] Sistema valida se dias das parcelas são crescentes
- [ ] Sistema impede exclusão de registros fixos
- [ ] Sistema valida se forma ativa pode enviar ao Palm

### **Interface:**
- [ ] Interface é responsiva e intuitiva
- [ ] Mensagens de erro são claras e objetivas
- [ ] Navegação entre guias funciona corretamente
- [ ] Grid permite ordenação e filtros
- [ ] Formulários têm validação em tempo real