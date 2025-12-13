# 📘 Documentação Técnica - Cadastro de Metas (CAD396)

## 🧾 Objetivo Geral
A tela **CAD396 - Cadastro de Metas** é responsável por definir as **metas por indicador**, determinando o fluxo esperado (objetivo) ao longo de um período.  
Nesta tela escolhemos **qual indicador desejamos controlar/mensurar** e atribuímos um **valor de meta** para um intervalo de datas específico, podendo ainda definir faixas de referência e dias da semana em que a meta se aplica.

Em resumo:
- **Indicador** – Vinculado à tela **CAD394 - Indicadores de Desempenho**, representa o que será controlado/mensurado.
- **Meta (valor)** – A quantidade/valor objetivo do indicador em um período (sem unidade fixa; interpretada pelo cliente).
- **Frequência** – Vem automaticamente do indicador selecionado.
- **AllowedDays (dias permitidos)** – Em metas diárias, define em quais dias da semana a meta se aplica.

As metas cadastradas aqui podem ser utilizadas:
- Para acompanhamento geral de resultados por indicador.
- Como base para análises gerenciais e relatórios (como a RDU).

---

## 🖥️ Estrutura e Funcionalidades da Tela

### 1. TreeList de Metas

A tela utiliza um componente de árvore (`TreeListSelection`) para organizar as metas em três níveis:

1. **Indicador (Medida)**  
   - Nível de agrupamento principal.  
   - Representa o indicador cadastrado na CAD394 (ex.: "Novos clientes").
   - Campos exibidos:
     - Nome do indicador (descrição).
     - Código interno do indicador (`measureId`).

2. **Meta (Goal)**  
   - Meta associada ao indicador, com valor e período.  
   - Campos exibidos na linha:
     - **Valor** (`value`)
     - **Referência** (`reference`) – texto associado à meta
     - **Frequência** (`frequency`)
     - **Data de criação** (`createdAt`)
     - **Período** (`initialDate` - `finalDate`)
     - **Referência externa** (`externalReference`)

3. **Item de Meta / Segmento (GoalItem)**  
   - Detalhamento da meta por segmento, canal, ou outro recorte definido pelo cliente.  
   - Campos exibidos na linha:
     - Nome do item (ex.: segmento, canal, referência do item).
     - Código externo do item (`externalReference`).
     - Valor da meta (`value`).
     - Mesmo período/frequência da meta principal.

---

## 🧩 Fluxo de Cadastro de Meta

### 1. Seleção do Indicador
No modal de criação:
- Seleciona-se o **Indicador** (`measureId`) a partir da lista de indicadores cadastrados na CAD394.
- Ao selecionar o indicador:
  - O sistema carrega os dados completos da medida.
  - A **frequência da meta** (`frequency`) é preenchida automaticamente com a frequência configurada no indicador.

### 2. Definição do Valor da Meta
- Campo **Valor** (`value`)
  - Obrigatório.
  - Representa a quantidade/valor da meta para o indicador no período.
  - Não há unidade de medida fixa; a interpretação é do cliente (ex.: quantidade, valor monetário, percentual etc.).
  - Esse valor é posteriormente utilizado em relatórios (como RDU) para acompanhamento.

### 3. Frequência da Meta
- Campo **Frequência** (`frequency`)
  - **Preenchido automaticamente** com base na medida selecionada.
  - Não é editável diretamente na criação (vem do indicador).
  - Determina o intervalo de medição (ex.: Diário, Mensal).

### 4. Referência Externa
- Campo **Referência Externa** (`externalReference`)
  - Opcional.
  - Pode ser utilizado para integração, codificação ou agrupamentos específicos definidos pelo cliente.

### 5. Período da Meta
- **Data Inicial** (`initialDate`) – obrigatória.
- **Data Final** (`finalDate`) – obrigatória.
- As datas delimitam o período em que o valor da meta será considerado.

### 6. Dias da Semana (Metas Diárias)
Quando a frequência da meta é **Diário**:
- Campo **Dias Permitidos** (`allowedDays`).
- Interface com botões para cada dia da semana (segunda a domingo).
- Regras:
  - O usuário pode marcar/destacar os dias da semana em que aquela meta se aplica.
  - Os dias selecionados são armazenados em `allowedDays` como lista de strings (ex.: `["Monday", "Tuesday"]`).
  - Caso não haja seleção, entende-se que a meta vale para todos os dias (conforme regra de negócio estabelecida pelo backend).

### 7. Referências de Qualidade da Meta
Se o indicador possuir **referências de qualidade**:
- A tela exibe uma seção de **Referências** com uma lista ordenada por importância.
- Para cada referência:
  - Descrição da faixa.
  - Campos de **Valor Inferior** (`lowerValue`) e **Valor Superior** (`upperValue`).
- Regra de encadeamento:
  - Ao preencher o `upperValue` de uma faixa, o sistema sugere automaticamente o `lowerValue` da próxima faixa.
  - Garante continuidade e coerência entre intervalos.

---

## ⚙️ Regras de Processamento e Validações

### 1. Criação de Meta
- Campos obrigatórios:
  - `measureId` (indicador).
  - `value` (valor da meta).
  - `initialDate` e `finalDate`.
  - Quando houver referências de qualidade associadas à medida, os campos `lowerValue` e `upperValue` de cada referência tornam-se obrigatórios.
- A **frequência** da meta deve ser compatível com a frequência do indicador selecionado (validado pela própria seleção de medida).
- Caso a API identifique conflito de frequência (por exemplo, duas metas ativas conflitantes):
  - Retorna uma notificação com código (ex.: `"Frequency"`).
  - A tela apresenta uma mensagem específica informando que a frequência já está em uso para aquele indicador.

### 2. Atualização de Meta (Goal)
- Permite alteração:
  - Do **valor da meta** (`value`).
  - Das **referências associadas** (faixas `lowerValue` / `upperValue`).
- Regras:
  - A atualização é feita para **uma meta por vez** (meta selecionada na árvore).
  - As referências são mapeadas e persistidas como parte da meta:
    - `id` (qualidade / referência de qualidade).
    - `importance`
    - `lowerValue`
    - `upperValue`
- Após atualizar, a linha correspondente na árvore é atualizada sem necessidade de recarregar toda a lista.

### 3. Atualização de Itens de Meta (GoalItem)
- Quando o usuário seleciona um ou mais **itens de meta** (segmentos) e escolhe atualizar:
  - É possível alterar o **valor** (`value`) e as **referências** associadas a esses itens.
- A operação pode atualizar **vários itens de meta em lote**.
- Caso a API não retorne os itens atualizados, o frontend ajusta os valores localmente mantendo:
  - `value` atualizado.
  - `externalReference`, `initialDate`, `finalDate` preservados.

### 4. Exclusão de Metas
- É possível excluir:
  - Uma ou mais metas (Goal) de uma vez.
  - Um ou mais itens de meta (GoalItem) associados às metas.
- Regras:
  - Ao excluir metas, são chamadas APIs específicas para:
    - Exclusão **em lote** (quando há múltiplas metas selecionadas).
    - Exclusão **unitária** (quando apenas uma meta está selecionada).
  - Ao excluir itens de meta:
    - Os itens são removidos da lista interna da meta.
    - As linhas correspondentes são removidas da árvore (`TreeListSelection`).

### 5. Seleção e Consistência
- A tela controla cuidadosamente o tipo de item selecionado na árvore:
  - **Medida (indicador)** – nível de agrupamento, não gera meta direta.
  - **Meta (goal)** – nível de meta principal.
  - **Item de meta (goalItem)** – nível de segmentos/itens.
- Ao tentar atualizar metas de **indicadores diferentes** ao mesmo tempo:
  - O sistema identifica a inconsistência e exibe mensagem informando que não é possível atualizar metas de indicadores distintos em uma única operação (evita conflito de contexto).

---

## 🔌 Integrações com API

### Endpoints de Metas (`/goal`)

#### 📥 Consultas
- **GET `/core/v1/goal`**
  - Retorna lista de metas cadastradas.
  - Usado para montar a árvore de metas (indicador → metas → itens).

- **GET `/core/v1/goal/{id}`**
  - Retorna os detalhes completos de uma meta específica, incluindo referências associadas ao indicador.

- **GET `/core/v1/goal/goalItem/{goalItemId}`**
  - Retorna detalhes de um item de meta específico, incluindo referências.

- **GET `/core/v1/goal/criteria`**
  - Retorna os critérios para filtros na tela (Templates de busca).

- **POST `/core/v1/goal/filter`**
  - Retorna metas com base em critérios específicos (`Criteria[]`), normalizando a resposta para estrutura da árvore.

#### 📤 Criação e Atualização
- **POST `/core/v1/goal`**
  - Cria uma nova meta (`GoalCreate`).
  - Campos principais:
    - `measureId`, `value`, `frequency`, `initialDate`, `finalDate`, `externalReference`, `references`, `allowedDays`.

- **PUT `/core/v1/goal/{goalId}`**
  - Atualiza uma meta existente (`GoalUpdate`).
  - Campos:
    - `id`, `value`, `references`.

- **PUT `/core/v1/goal/goalItem`**
  - Atualiza itens de meta em lote.
  - Payload:
    - `id: string[]` (lista de IDs de itens).
    - `value` (novo valor).
    - `references` (faixas atualizadas).

#### 🗑️ Exclusões
- **DELETE `/core/v1/goal/{goalId}`**
  - Exclui uma meta específica.

- **DELETE `/core/v1/goal/goal`**
  - Exclui metas em lote (payload com lista de IDs).

- **DELETE `/core/v1/goal/goalItem`**
  - Exclui itens de meta em lote (payload com `id: string[]`).

---

## ✅ Conceitos Importantes

- **Meta**  
  Valor que representa a **quantidade/resultado esperado** de um indicador em determinado período.  
  Não possui unidade fixa – é interpretado conforme a natureza do indicador (quantidade, valor, índice, percentual etc.).  
  É utilizada em relatórios (como RDU) para comparar o realizado versus o planejado.

- **Indicador**  
  Origina-se da CAD394 e representa o **que** está sendo mensurado (ex.: “Novos clientes”, “Pedidos faturados”).  
  Cada meta sempre está ligada a um indicador.

- **Frequência**  
  Define **com que intervalo** uma meta é avaliada (Diário, Mensal, etc.).  
  Na CAD396, é herdada do indicador e não é alterada diretamente pelo usuário.

- **Itens de Meta / Segmentos**  
  Permitem detalhar uma meta geral em subcomponentes (por exemplo, por segmento de cliente, região, canal etc.), mantendo coerência de valor, período e referências.

---

## Relação com Outras Telas

- **CAD394 - Indicadores de Desempenho**
  - Fornece os indicadores (medidas) que serão usados na criação de metas.
  - Define frequência, polaridade, formato e referências de qualidade que impactam diretamente o comportamento das metas.

- **CAD407 - Metas Comerciais**
  - Se concentra em metas por **vendedor**, utilizando indicadores do grupo “Comercial”.
  - Complementa a CAD396 com um foco mais operacional e massivo (metas por vendedor e indicador).

- **CAD054 - Cadastro de Vendedores**
  - Fornece a base de vendedores para associações indiretas em metas comerciais (embora CAD396 não faça vínculo direto com vendedores).

---

## Considerações Finais

A tela **CAD396 - Cadastro de Metas** é o núcleo da definição de objetivos por indicador.  
Ela conecta os indicadores (CAD394) a períodos e valores específicos, permitindo ainda detalhamento por referências e segmentos.  
Em conjunto com a CAD407 (Metas Comerciais) e a CAD394 (Indicadores), forma o alicerce para o acompanhamento estruturado de desempenho dentro do sistema.


