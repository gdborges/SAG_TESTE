# 📘 Documentação Técnica - Cota de Vendas (CAD404)

## 🧾 Objetivo Geral
A tela **CAD404 - Cota de Vendas** tem como principal objetivo organizar e administrar a quantidade de itens/cotas vendidos diariamente por cada equipe de vendedores. O sistema permite definir metas de venda diárias, distribuir essas metas entre diferentes times de vendas e controlar o desempenho de cada equipe. Esse processo é essencial para garantir uma distribuição equilibrada de produtos entre as equipes, otimizar o planejamento de vendas e manter o controle operacional das metas estabelecidas.

---

## 🖥️ Estrutura e Funcionalidades da Tela

### 1. Organização em Abas
A tela está dividida em três abas principais que representam diferentes níveis de configuração da cota:

1. **Detalhes** - Configuração inicial da cota
2. **Produtos (SKU)** - Seleção e definição de produtos
3. **Cota** - Distribuição de metas por equipes

### 2. Aba de Detalhes
Na primeira aba, é realizada a criação inicial da cota com as seguintes funcionalidades:

**Campos disponíveis:**
- **Código** - Gerado automaticamente pelo sistema (somente leitura)
- **Filial** - Seleção obrigatória da filial à qual a cota será vinculada
- **Data** - Data de referência da cota (obrigatória)
- **Descrição** - Texto descritivo da cota (máximo 40 caracteres)

**Regras de negócio:**
- Apenas é possível criar uma cota por dia para cada filial
- Não é permitido ter mais de uma cota ativa para a mesma combinação de filial e data
- Após a criação, o sistema automaticamente habilita as abas de Produtos e Cota

### 3. Aba de Produtos (SKU - Stock Keeping Unit)
Esta aba apresenta a listagem de produtos vinculados à filial selecionada.

**Funcionalidades:**
- **Lista de produtos disponíveis** - Exibe todos os produtos cadastrados para a filial
- **Lista de cotas diárias** - Produtos que compõem a cota de vendas
- **Quantidade** - Campo editável que define a meta de venda diária para cada produto

**Colunas exibidas:**
- Código do produto
- Código externo
- Descrição do produto
- Quantidade (editável)

**Regras de negócio:**
- A quantidade do produto não pode ser negativa ou igual a zero
- A quantidade não pode ser menor que a soma das cotas já distribuídas entre as equipes na aba Cota
- Produtos podem ser adicionados ou removidos da cota antes da distribuição entre equipes

### 4. Aba de Cota
Esta aba exibe a relação das equipes (times) associadas à filial e permite a distribuição da meta de vendas de cada produto para cada equipe.

**Estrutura do Grid:**
- **Colunas fixas à esquerda:**
  - Descrição do produto (com data de referência)
  - Código do produto
- **Colunas dinâmicas por equipe:**
  - **Cota** - Meta de venda atribuída à equipe (editável)
  - **Vendido** - Quantidade já vendida pela equipe (somente leitura)
  - **Disponível** - Quantidade disponível para venda (calculada)
  - **Preço** - Preço do produto para a equipe (formatado em moeda)
- **Colunas fixas à direita (totais):**
  - **Total Cota** - Soma total de cota do produto
  - **Total Vendido** - Soma total vendida por todas as equipes
  - **Disponível para Venda** - Diferença entre total cota e total vendido
  - **Cota Disponível** - Diferença entre o total de cota e a soma das cotas das equipes (com validação visual)

**Funcionalidades especiais:**
- **Botão Refresh** - Recarrega os dados salvos no banco de dados, descartando alterações locais não salvas
- **Botão Sugestão de Cota** - Realiza distribuição automática de cotas entre equipes com base em:
  - Quantidade de dias informada no campo numérico ao lado
  - Histórico de produção/vendas de cada vendedor
  - Distribuição proporcional baseada no desempenho
- **Duplo clique na coluna "Vendido"** - Abre modal com detalhamento de vendedores da equipe, exibindo:
  - Nome do vendedor
  - Cota do vendedor
  - Cota vendida pelo vendedor
  - Preço

**Regras de negócio:**
- A cota definida para cada equipe não pode ser negativa ou igual a zero
- A soma das cotas por equipe não pode ultrapassar o total estabelecido na aba de Produtos
- O sistema valida visualmente quando a soma das cotas das equipes excede a cota total do produto
- Valores negativos são destacados visualmente com borda vermelha

---

## ⚙️ Regras de Processamento e Validações

### 🔹 Regras de Criação e Edição

#### Aba de Detalhes
- **Filial** é obrigatória
- **Data** é obrigatória e deve ser única por filial (não pode haver duplicatas)
- **Descrição** é obrigatória e limitada a 40 caracteres
- Após criar a cota, o sistema muda automaticamente para o modo de atualização e habilita as outras abas

#### Aba de Produtos (SKU)
- A **Quantidade** do produto é obrigatória e deve ser maior que zero
- Não é permitido definir a quantidade menor que a soma das cotas já distribuídas entre equipes
- Produtos podem ser adicionados ou removidos da cota antes da distribuição
- Após distribuir cotas entre equipes, não é possível reduzir a quantidade abaixo do valor já distribuído

#### Aba de Cota
- A **Cota** de cada equipe não pode ser negativa ou igual a zero
- A soma de todas as cotas das equipes não pode exceder a cota total do produto
- O sistema calcula automaticamente a **Cota Disponível** (totalQuota - soma das cotas das equipes)
- Quando a cota disponível fica negativa, o campo é destacado visualmente com borda vermelha

### 🔸 Controle de Concorrência

O sistema implementa um controle de concorrência para evitar edições simultâneas:

**Estados da cota:**
- **Status 0 ou 1** - Cota disponível para edição
- **Status 2** - Cota em modo de edição (bloqueada)

**Fluxo de edição:**
1. Ao clicar duas vezes na cota ou usar o ícone de edição, a cota é aberta em modo de visualização
2. Para editar nas abas de Produtos ou Cota, é necessário:
   - Ter permissões específicas (`INCLUIR-COTA` ou `EDITAR-COTA`)
   - Clicar no botão **"Alterar"** (aba Produtos) ou no ícone de lápis (aba Cota)
3. Ao iniciar a edição, o sistema:
   - Altera o status da cota para 2 (editando)
   - Registra o ID do usuário que está editando
   - Bloqueia a edição para outros usuários
4. Se outro usuário tentar editar:
   - A cota é aberta apenas em modo de visualização
   - Ao tentar ativar o modo de edição, um alerta é exibido informando qual usuário está editando
5. Ao salvar ou fechar, o status retorna para 1 (disponível)

**Proteção contra perda de dados:**
- O sistema monitora eventos `beforeunload` e `visibilitychange` do navegador
- Se o usuário fechar a aba/janela durante a edição, o sistema tenta liberar a cota automaticamente
- Utiliza `navigator.sendBeacon` para garantir o envio da requisição mesmo durante o fechamento

### 🔹 Validações de Integridade

1. **Validação de Cota Total vs Distribuição**
   - A cota total do produto deve ser sempre maior ou igual à soma das cotas distribuídas
   - Se a distribuição já foi feita, não é possível reduzir a cota total abaixo do valor distribuído
   - Exemplo: Se a cota total é 100 e foram distribuídos 90, não é possível reduzir abaixo de 90

2. **Validação de Valores Negativos**
   - Valores negativos não são permitidos em nenhum campo numérico
   - O sistema valida tanto no frontend (durante a digitação) quanto no backend (antes de salvar)

3. **Validação de Cota Disponível**
   - O sistema calcula em tempo real: `Cota Disponível = Total Cota - Soma das Cotas das Equipes`
   - Quando o resultado é negativo, o campo é destacado visualmente
   - Não é permitido salvar quando há cota disponível negativa

---

## 🔄 Funcionalidade de Clonagem

O sistema permite clonar uma cota existente, facilitando a criação de novas cotas com base em referências anteriores.

**Funcionalidades do clone:**
- Copia todos os produtos associados à cota original
- Mantém a estrutura de equipes e produtos
- Permite alterar:
  - Descrição da nova cota
  - Data da nova cota
  - Filial (se necessário)
- **Não copia** a distribuição de cotas entre equipes (deve ser feita manualmente)

**Fluxo de clonagem:**
1. Na grid principal, selecionar a cota a ser clonada
2. Clicar no botão de clonar (ícone de cópia)
3. Preencher os dados da nova cota no modal
4. Validar e confirmar a criação
5. A nova cota é criada com os produtos já associados
6. É necessário fazer a distribuição de cotas na aba Cota

---

## ⌨️ Otimizações de Usabilidade

### Navegação por Teclado
O grid possui suporte completo para entrada de dados via teclado:
- **Enter** - Confirma a edição da célula e move para a próxima célula editável
- **Tab** - Move para a próxima célula editável
- **Shift + Tab** - Move para a célula editável anterior
- **Setas** - Navega entre células
- **Escape** - Cancela a edição da célula atual

### Edição Inline
- Todas as células editáveis permitem edição direta (sem necessidade de modal)
- A validação ocorre em tempo real durante a digitação
- Feedback visual imediato para valores inválidos

---

## 🔌 Integrações com API

### 📥 Endpoints de Consulta

#### GET `/core/v1/quota`
Retorna todas as cotas cadastradas no sistema.

**Parâmetros de query (opcional):**
- Filtros de paginação
- Ordenação
- Filtros customizados

**Resposta:**
```typescript
{
  data: Quota[];
  // Quota: { id, code, description, date, branchId, status }
}
```

#### GET `/core/v1/quota/{quotaId}`
Retorna os detalhes de uma cota específica, incluindo produtos e distribuição por equipes.

**Resposta:**
```typescript
{
  data: DailyQuota[];
  // DailyQuota: { code, externalCode, description, totalQuota, teams[] }
}
```

#### POST `/core/v1/quota/filter`
Busca cotas com critérios específicos utilizando filtros customizados.

**Payload:**
```json
{
  "criteria": {
    "field": "description",
    "operator": "contains",
    "value": "texto"
  }
}
```

#### GET `/core/v1/quota/criteria`
Retorna os critérios disponíveis para filtros e templates de busca.

**Resposta:**
```typescript
{
  data: ColumnGrid[];
}
```

#### GET `/core/v1/quota/quotastatus/{quotaId}`
Retorna o status atual da cota, incluindo informações sobre edição simultânea.

**Resposta:**
```typescript
{
  value: {
    quotaId: string;
    quotaStatus: number; // 0, 1 ou 2
    userName?: string | null;
    currentUserEditingId?: string | null;
  }
}
```

#### GET `/core/v1/quota/suggestion/{quotaId}?days={number}`
Retorna sugestão de distribuição de cotas baseada em histórico de vendas.

**Nota:** Os nomes dos endpoints e campos técnicos mantêm "quota" por questões de compatibilidade com a API, mas nas explicações em português utilizamos "cota".

**Parâmetros:**
- `days` - Número de dias para análise do histórico

**Resposta:**
```typescript
{
  value: DailyQuota[];
}
```

#### GET `/core/v1/quota/{quotaId}/{teamId}/{productCode}`
Retorna detalhamento de vendedores de uma equipe para um produto específico.

**Resposta:**
```typescript
{
  data: {
    teamId: string;
    sellers: {
      id: string;
      name: string;
      quotaValue: number; // Valor da cota do vendedor
      quotaSold: number;   // Cota vendida pelo vendedor
      price: number;
    }[];
  }
}
```

### 📤 Endpoints de Criação e Atualização

#### POST `/core/v1/quota`
Cria uma nova cota de vendas.

**Payload:**
```json
{
  "description": "Cota Janeiro 2025",
  "date": "2025-01-15",
  "branchId": "123"
}
```

**Resposta:**
```typescript
{
  value: Quota; // Inclui id e code gerados
}
```

#### PUT `/core/v1/quota/{quotaId}`
Atualiza os detalhes da cota (descrição e filial).

**Payload:**
```json
{
  "quotaId": "456",
  "description": "Cota Janeiro 2025 - Atualizada",
  "branchId": "123"
}
```

#### POST `/core/v1/quota/copy`
Duplica uma cota existente.

**Payload:**
```json
{
  "quotaId": "456",
  "description": "Cota Fevereiro 2025",
  "date": "2025-02-15",
  "branchId": "123"
}
```

#### PUT `/core/v1/quota/products/{quotaId}`
Adiciona ou atualiza produtos na cota.

**Payload:**
```json
{
  "id": "456",
  "products": [
    {
      "id": "PROD001",
      "value": 100
    },
    {
      "id": "PROD002",
      "value": 200
    }
  ]
}
```

#### DELETE `/core/v1/quota/products/{quotaId}`
Remove produtos da cota.

**Payload:**
```json
{
  "id": "456",
  "products": [
    {
      "id": "PROD001"
    }
  ]
}
```

#### PUT `/core/v1/quota/quotastatus/{quotaId}`
Atualiza o status da cota (controle de concorrência).

**Payload:**
```json
{
  "quotaId": "456",
  "status": 2 // 0 ou 1 = disponível, 2 = editando
}
```

#### PUT `/core/v1/quota/item`
Atualiza os itens da cota (distribuição por equipes).

**Payload:**
```json
{
  "quotaId": "456",
  "quotaTeamItems": [
    {
      "teamId": "TEAM001",
      "value": 50,
      "productId": "PROD001"
    },
    {
      "teamId": "TEAM002",
      "value": 50,
      "productId": "PROD001"
    }
  ]
}
```

### 🗑️ Endpoints de Exclusão

#### DELETE `/core/v1/quota/{quotaId}`
Remove uma cota do sistema.

---

## 🔐 Sistema de Permissões

O módulo utiliza as seguintes permissões para controle de acesso:

- **`INCLUIR-COTA`** - Permite criar novas cotas e editar produtos
- **`EDITAR-COTA`** - Permite editar cotas existentes e distribuir cotas entre equipes

**Comportamento:**
- Usuários sem permissão `INCLUIR-COTA` não podem criar novas cotas
- Usuários sem permissão `EDITAR-COTA` não podem ativar o modo de edição nas abas de Produtos e Cota
- O botão "Alterar" e o ícone de lápis são exibidos condicionalmente baseado nas permissões

---

## ✅ Considerações Finais

O módulo de **Cota de Vendas (CAD404)** é uma ferramenta essencial para o planejamento e controle de vendas da empresa. Com funcionalidades que permitem desde a criação de cotas até a distribuição detalhada entre equipes, o sistema oferece:

- **Controle de metas** - Definição clara de objetivos de venda por produto e equipe
- **Distribuição inteligente** - Sugestão automática baseada em histórico de desempenho
- **Rastreabilidade** - Acompanhamento de vendas realizadas vs metas estabelecidas
- **Segurança** - Controle de concorrência para evitar edições simultâneas
- **Usabilidade** - Interface otimizada para entrada rápida de dados via teclado
- **Validações robustas** - Garantia de integridade dos dados em todas as etapas

A estrutura em abas facilita o fluxo de trabalho, permitindo que o usuário configure primeiro os produtos e depois distribua as metas entre as equipes, garantindo uma gestão eficiente e organizada das cotas de vendas.

