# 📘 Documentação Técnica - Metas Comerciais (CAD407)

## 🧾 Objetivo Geral
A tela **CAD407 - Metas Comerciais** é responsável por **vincular indicadores comerciais aos vendedores**, permitindo definir metas individuais por vendedor, por período e por indicador.  
Ela foi desenhada para facilitar o **cadastro em massa** de metas, combinando:

- **Indicadores de desempenho** (CAD394), filtrados pelo grupo "Comercial" e pela frequência.
- **Vendedores** (CAD054 - Cadastro de Vendedores).
- Uma interface de grade onde é possível informar rapidamente os **valores de metas** por vendedor e indicador.

Em resumo, essa tela responde à pergunta:  
> “Qual é a meta de cada vendedor para cada indicador comercial, em um determinado período?”

---

## 🖥️ Estrutura e Funcionalidades da Tela

### 1. Grid Principal de Metas Comerciais

A tela inicial (`commercial-goal.vue`) apresenta um `Grid` com as metas comerciais já cadastradas.

**Colunas exibidas:**
- **Valor** (`value`) – valor da meta comercial (por vendedor e indicador).
- **Indicador** (`measureDescription`) – descrição do indicador de desempenho vinculado (CAD394).
- **Data de criação** (`createdAt`) – com formatação de data.
- **Período** (`initialDate` - `finalDate`) – exibido em uma coluna que combina datas inicial e final.
- **Referência Externa** (`externalReference`) – referência associada (ex.: código do vendedor/segmento).
- **Código externo do vendedor** (`sellerExternalCode`).
- **Nome do vendedor** (`sellerName`).

**Ações disponíveis na grid:**
- **Novo** – Abre o modal principal em modo criação.
- **Atualizar** – Abre o modal de edição de valor, permitindo alterar o valor da meta para os registros selecionados.
- **Excluir** – Abre modal de confirmação para exclusão em lote das metas comerciais selecionadas.

---

## 🧩 Fluxo de Cadastro de Metas Comerciais

O cadastro de metas comerciais ocorre em **duas etapas principais**:
1. Seleção de **frequência**, **indicadores** e **vendedores**.
2. Definição de **período** e **valor da meta para cada vendedor/indicador**.

### 1. Seleção da Frequência (Frequency)

- Campo **Frequência** (`frequency`) – obrigatório na etapa de criação.
- Define o **intervalo de tempo** em que a meta será executada (ex.: Diário, Mensal).
- A lista de frequências vem do cadastro de frequências de indicadores (tela CAD394 / serviço de medida).

### 2. Seleção de Indicadores

Após selecionar a frequência:
- A tela abre um `TodoModal` para escolher os **indicadores** que serão utilizados.
- Os indicadores disponíveis são obtidos da tela **CAD394 - Indicadores de Desempenho** e filtrados pelas regras:
  - **Devem pertencer ao grupo de indicadores "Comercial"** (`indicatorGroupDescription == "Comercial"`).
  - **Devem possuir a mesma frequência** escolhida anteriormente.

Em termos práticos:
- Carregamos todos os indicadores via serviço de medidas.
- Filtramos apenas aqueles:
  - Com grupo “Comercial”.
  - Cuja lista de `frequencies` contenha a frequência selecionada.

O usuário:
- Visualiza os indicadores comerciais disponíveis.
- Move indicadores entre listas “Disponíveis” e “Selecionados”.
- Confirma a seleção (pelo menos um indicador deve ser selecionado).

### 3. Seleção de Vendedores

No segundo `TodoModal`, o usuário seleciona os **vendedores** que receberão metas.

Origem dos vendedores:
- Vêm do cadastro **CAD054 - Cadastro de Vendedores**, via endpoint específico para filial.
- A tela utiliza o serviço de vendedores para buscar os vendedores da filial atual (ex.: `getSellersBranch`).

O usuário:
- Visualiza os vendedores disponíveis.
- Seleciona um ou mais vendedores para receber metas.
- Confirma a seleção (pelo menos um vendedor deve ser selecionado).

### 4. Definição do Valor da Meta por Vendedor/Indicador

Após escolher frequência, indicadores e vendedores:
- O usuário clica em um botão que abre um **modal de metas comerciais** com uma `Grid` dinâmica:
  - Cada linha representa um **vendedor**.
  - Cada coluna dinâmica representa um **indicador selecionado**.
  - As células são **editáveis** e recebem o **valor da meta** para o par (vendedor, indicador).

Exemplo de estrutura:
- Colunas:
  - `Nome do Vendedor`
  - `Indicador A`
  - `Indicador B`
  - `Indicador C`
- Linhas:
  - Vendedor 1 – metas A, B, C
  - Vendedor 2 – metas A, B, C
  - ...

O usuário pode:
- Navegar pelas células via teclado (setas, Tab, Enter).
- Informar os valores para cada vendedor/indicador.

### 5. Período da Meta Comercial

No mesmo modal, o usuário define:
- **Data inicial** (`initialDate`).
- **Data final** (`finalDate`).

Essas datas definem o período de vigência das metas comerciais criadas em lote.

### 6. Validações Antes de Criar

Antes de enviar os dados para o backend, a tela garante:
- Frequência selecionada (`frequency` não vazia).
- Pelo menos **um indicador** selecionado.
- Pelo menos **um vendedor** selecionado.
- Valores numéricos válidos na grid (padrão de validação numérica).

Caso alguma condição não seja atendida:
- O sistema apresenta mensagens de erro amigáveis (ex.: “Selecione pelo menos um indicador e um vendedor”).

### 7. Criação em Massa de Metas Comerciais

Quando o usuário confirma o cadastro:
- A tela coleta os dados da grid dinâmica e monta um array de **metas** (`goals[]`), onde cada meta contém:
  - **Frequência** (`frequency` – descrição da frequência selecionada).
  - **Referência externa** (`externalReference`) – geralmente o código do vendedor.
  - **Período**: `initialDate` e `finalDate`.
  - **Indicadores** (`indicators[]`), cada um com:
    - `measureId` – identificador da medida.
    - `value` – valor da meta para aquele indicador.
  - `allowedDays` – lista de dias permitidos (quando aplicável; pode ser enviada vazia).

Esse array é enviado em uma única chamada de API para criar diversas metas de uma vez.

---

## ⚙️ Regras de Processamento e Validações

### Regras de Seleção
- Não é permitido:
  - Prosseguir sem selecionar **frequência**.
  - Confirmar seleção de indicadores sem ao menos **um indicador selecionado**.
  - Confirmar seleção de vendedores sem **pelo menos um vendedor selecionado**.

### Regras de Indicadores
- Somente indicadores:
  - Do grupo **“Comercial”**.
  - Com **frequência compatível** com a frequência selecionada.
- Isso evita criação de metas comerciais com indicadores de outras áreas (produção, transporte, etc.).

### Regras de Vendedores
- Os vendedores disponíveis respeitam a **filial** do usuário logado (via `SessionInfo.branchId`).
- É esperado que apenas vendedores ativos/pertencentes àquela filial sejam retornados pela API.

### Regras de Criação em Massa
- A criação utiliza uma operação de **bulk insert** de metas:
  - Cada vendedor pode receber metas para diversos indicadores.
  - O back-end faz validações adicionais (como conflitos de períodos, frequência, etc.).
- Em caso de erro:
  - O sistema exibe mensagem genérica de falha ou, se disponível, mensagens específicas retornadas pelo backend.

### Regras de Atualização e Exclusão

#### Atualização
- Ao selecionar uma ou mais linhas na grid principal e acionar “Atualizar”:
  - A tela abre um modal simples com campo **Valor**.
  - O valor informado é aplicado a todas as metas selecionadas.
  - O backend recebe uma estrutura com:
    - Lista de IDs das metas (`id[]`).
    - Novo valor (`value`).
    - Referências vazias ou conforme implementação.

#### Exclusão
- Ao selecionar uma ou mais metas e acionar “Excluir”:
  - A tela abre modal de confirmação.
  - Após confirmação, envia para a API um payload contendo a lista de IDs a serem removidos.
  - A grid é atualizada removendo as linhas correspondentes.

---

## 🔌 Integrações com API

### Endpoints de Metas Comerciais

Embora a tela implemente o conceito de “metas comerciais”, ela reutiliza o mesmo conjunto de endpoints do módulo de metas (`/goal`), com especialização via rotas de filtro:

#### 📥 Consultas
- **POST `/core/v1/goal/commercialFilter/{type}`**
  - Retorna metas comerciais para um determinado tipo/escopo (por exemplo, por filial ou outro critério definido).
  - Utilizado tanto para carregar a grid principal quanto para critérios de busca.

- **GET `/core/v1/goal/criteria`**
  - Retorna critérios de filtro usados pela grid (templates de pesquisa).

### 📤 Criação em Massa
- **POST `/core/v1/goal/bulk`**
  - Cria metas em lote.
  - Payload:
    - `goals: GoalCreate[]` (estrutura especializada para metas comerciais, contendo frequência, período, referência externa e lista de indicadores).

### Atualização e Exclusão
A tela de metas comerciais reaproveita endpoints genéricos de itens de meta (`goalItem`):

- **PUT `/core/v1/goal/goalItem`**
  - Atualiza o valor de metas selecionadas (em massa), com:
    - `id: string[]` – lista de IDs.
    - `value` – valor numérico.
    - `references` – quando aplicável.

- **DELETE `/core/v1/goal/goalItem`**
  - Exclui metas comerciais selecionadas, com:
    - `id: string[]`.

> Observação: a nomenclatura de endpoints (`goal`, `goalItem`) é compartilhada com o módulo CAD396, mas o **uso** aqui é focado no contexto comercial (vendedor x indicador).

---

## 🔌 Integração com Vendedores (CAD054)

Para a seleção de vendedores, a tela utiliza o serviço de vendedores:

### 📥 Consultas
- **GET `/core/v1/seller/branch/{branchId}`**
  - Retorna a lista de vendedores de uma filial específica.
  - Usado para alimentar o `TodoModal` de seleção de vendedores na CAD407.

Outros endpoints do cadastro de vendedores (criação, edição, exclusão, tipos, endereços) são tratados diretamente na tela **CAD054 - Cadastro de Vendedores** e não fazem parte do fluxo principal da CAD407, mas são fundamentais como **fonte de dados**.

---

## ✅ Conceitos Importantes

- **Metas Comerciais**  
  Conjunto de metas individuais associadas a vendedores, para indicadores comerciais específicos.  
  Permitem direcionar o esforço da equipe de vendas por indicador (por exemplo, “Novos clientes”, “Pedidos faturados”, “Produtos estratégicos”).

- **Indicadores Comerciais**  
  São indicadores cadastrados na CAD394, pertencentes ao grupo **“Comercial”**.  
  Definem o **tipo de resultado comercial** que se deseja controlar (ex.: volume de vendas de um determinado mix, abertura de clientes, venda de um produto-alvo).

- **Vendedores (CAD054)**  
  Representam os usuários responsáveis pela execução das metas comerciais.  
  A CAD407 consome os dados de vendedores para poder atribuir metas personalizadas.

- **Meta por Vendedor**  
  Para cada combinação vendedor x indicador, é definido um valor de meta para um período.  
  Esse valor é utilizado em relatórios e dashboards para acompanhar a performance individual da equipe.

---

## Relação com Outras Telas

- **CAD394 - Indicadores de Desempenho**
  - Fonte dos indicadores utilizados nas metas comerciais.
  - Apenas indicadores do grupo **Comercial** e com frequência compatível podem ser selecionados.

- **CAD396 - Cadastro de Metas**
  - Gerencia metas de forma mais geral por indicador (sem foco direto em vendedor).  
  - A CAD407 complementa esse módulo ao descer para o nível de vendedor.

- **CAD054 - Cadastro de Vendedores**
  - Fornece a base de vendedores para a atribuição de metas comerciais.

---

## Considerações Finais

A tela **CAD407 - Metas Comerciais** conecta indicadores comerciais, vendedores e períodos em um fluxo único e otimizado para **cadastro em massa de metas**.  
Ela aproveita o cadastro de indicadores de desempenho (CAD394), a infraestrutura de metas (CAD396) e o cadastro de vendedores (CAD054), garantindo que cada vendedor tenha metas claras por indicador, alinhadas à estratégia comercial da empresa.


