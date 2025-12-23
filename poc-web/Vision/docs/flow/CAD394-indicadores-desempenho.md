# 📘 Documentação Técnica - Indicadores de Desempenho (CAD394)

## 🧾 Objetivo Geral
A tela **CAD394 - Indicadores de Desempenho** é responsável pelo cadastro e manutenção dos **indicadores** que serão utilizados em todo o módulo de metas e acompanhamentos de performance.  
Esses indicadores representam **o que será medido** (ex.: “Frango a passarinho produzido”, “Novos clientes”, “Pedidos faturados”) e não estão necessariamente ligados a um produto específico, mas sim a um **tipo de controle** definido pelo cliente.

Os indicadores cadastrados aqui são utilizados:
- Na tela de **Metas (CAD396)** para definição de metas por indicador.
- Na tela de **Metas Comerciais (CAD407)** para vincular metas a vendedores.
- Em relatórios e telas de acompanhamento (como a **RDU**) para monitoramento dos resultados.

---

## 🖥️ Estrutura e Funcionalidades da Tela

### Modal de Cadastro/Edição

O modal é utilizado tanto para **criar** quanto para **editar** indicadores.

#### Campos principais
- **Código** (`code`)
  - Gerado pelo sistema.
  - Campo somente leitura.

- **Referência Externa** (`externalReference`)
  - Código de referência amigável/usado em integrações.
  - Pode ser preenchido manualmente ou sugerido automaticamente a partir do grupo.
  - Ex.: `COM0010`, `PRO0005`.

- **Descrição** (`description`)
  - Nome do indicador (ex.: “Novos clientes”, “Pedidos faturados”).
  - Campo obrigatório.

- **Grupo de Indicadores** (`indicatorGroupId`, `indicatorGroupDescription`, `indicatorGroupPrefix`)
  - Selecionado via componente de **Lookup**, que consulta a entidade `indicatorGroup`.
  - Campo obrigatório.
  - Ao selecionar o grupo, o sistema:
    - Preenche `indicatorGroupId`, `indicatorGroupDescription` e `indicatorGroupPrefix`.
    - Opcionalmente, **sugere a referência externa** concatenando o prefixo com um número sequencial (`prefix + número sequencial`), caso o grupo informe o total de indicadores já cadastrados.

- **Tipo de Indicador** (`indicatorType`)
  - Campo obrigatório.
  - Define a área/uso do indicador:
    - Produção
    - Comercial
    - Balança
    - Transporte
    - Expedição
    - Custos
  - Essa informação é usada, por exemplo, para filtrar **indicadores comerciais** na tela de Metas Comerciais (CAD407).

- **Frequência** (`frequencies`)
  - Representa **em que intervalo de tempo** o indicador será medido (ex.: Diário, Semanal, Mensal).
  - Na prática, nesta tela é selecionada **uma frequência principal** via `Select` (`frequencySelected`), que é enviada como um array de frequências (`frequencies: [frequencySelected]`).
  - A frequência selecionada é reutilizada em outras telas:
    - Na tela de Metas (CAD396), para preencher automaticamente o campo **Frequência** da meta.
    - Na tela de Metas Comerciais (CAD407), para filtrar indicadores compatíveis com a frequência escolhida.

- **Polaridade** (`polarityType`)
  - Campo obrigatório.
  - Indica se, para esse indicador, **valores maiores** são desejáveis ou se **valores menores** são melhores:
    - **Maior é melhor** – Ex.: “Vendas realizadas”, “Novos clientes”.
    - **Menor é melhor** – Ex.: “Devoluções”, “Quebras”, “Reclamações”.
  - Essa informação é usada em análises e relatórios para interpretar corretamente o desempenho.

- **Formato** (`formatType`)
  - Define como o valor do indicador será exibido:
    - Moeda
    - Numérico
    - Decimal
    - Percentual
  - Combinado com `decimalPlaces` para controle de casa decimal.

- **Casas Decimais** (`decimalPlaces`)
  - Quantidade de casas decimais a serem exibidas para o indicador.

- **Fórmula** (`formula`)
  - Campo textual para informar uma fórmula ou regra de cálculo explicativa do indicador.
  - Uso opcional, mas recomendado para documentação de como o indicador é obtido.

- **Referências de Qualidade** (`references`)
  - Lista de faixas ou referências de qualidade associadas ao indicador.
  - Utilizadas em módulos de qualidade/metas para definir faixas (por exemplo, Ruim / Regular / Bom).
  - Gerenciadas via componente `Multiselect`, com:
    - Seleção múltipla de referências existentes.
    - Botão de **criar** novas referências.
    - Botão de **excluir** referências.

---

## ⚙️ Regras de Processamento e Validações

### Regras de Cadastro/Edição
- **Descrição** é obrigatória.
- **Grupo de Indicadores** é obrigatório.
- **Tipo de Indicador** é obrigatório.
- **Polaridade** é obrigatória.
- **Frequência** é obrigatória (pelo menos uma frequência deve ser selecionada).
- Ao selecionar um grupo de indicadores:
  - O sistema preenche automaticamente os campos internos (`indicatorGroupId`, `indicatorGroupDescription`, `indicatorGroupPrefix`).
  - Caso o grupo informe `totalIndicators`, o sistema sugere a **referência externa** no formato `PREFIX000X` (prefixo + número sequencial com 4 dígitos).

### Regras de Frequência
- O indicador deve possuir ao menos **uma frequência** configurada.
- A frequência do indicador é utilizada:
  - Na tela de Metas (CAD396) para **preencher automaticamente** o campo `frequency` da meta.
  - Na tela de Metas Comerciais (CAD407) para **filtrar quais indicadores podem ser selecionados**, garantindo compatibilidade entre indicador e frequência escolhida na meta comercial.

### Regras de Exclusão
- A exclusão de um indicador pode ser bloqueada pelo backend caso existam entidades relacionadas (ex.: metas ou metas comerciais já vinculadas).
- Ao tentar excluir um indicador com vínculos:
  - O sistema apresenta mensagem específica (“não é possível excluir porque existem entidades vinculadas”), conforme retorno da API.

### Referências de Qualidade
- As referências de qualidade (`Reference`) são compartilhadas entre indicadores.
- Antes de excluir uma referência, o backend pode vetar a operação se houver vínculos existentes.
- Ao tentar excluir uma referência utilizada em algum indicador/meta:
  - O sistema exibe mensagem de erro específica.

---

## 🔌 Integrações com API

### Endpoints de Indicadores (`/measure`)

#### 📥 Consultas
- **GET `/core/v1/measure`**
  - Retorna lista paginada/filtrada de indicadores.
  - Usado para carregar a grid principal.

- **GET `/core/v1/measure/{id}`**
  - Retorna os detalhes de um indicador específico, incluindo frequências e referências.

- **GET `/core/v1/measure/criteria`**
  - Retorna colunas e critérios disponíveis para filtros/templates na grid de indicadores.

- **POST `/core/v1/measure/filter`**
  - Busca indicadores de acordo com critérios customizados.

- **GET `/core/v1/measure/frequency`**
  - Retorna as frequências disponíveis para seleção (ex.: Diário, Mensal).

- **GET `/core/v1/measure/quality-reference`**
  - Retorna as referências de qualidade disponíveis (faixas/códigos que podem ser associadas a um indicador).

#### 📤 Criação e Atualização
- **POST `/core/v1/measure`**
  - Cria um novo indicador de desempenho.
  - Payload inclui:
    - `description`, `indicatorGroupId`, `indicatorType`, `polarityType`
    - `frequencies` (array de IDs de frequência)
    - `formatType`, `decimalPlaces`, `formula`
    - `externalReference`
    - `references` selecionadas.

- **PUT `/core/v1/measure/{id}`**
  - Atualiza um indicador existente.
  - Mesma estrutura de payload da criação, sem alteração do `id`.

- **POST `/core/v1/measure/quality-reference`**
  - Cria uma nova referência de qualidade.

- **PUT `/core/v1/measure/quality-reference`**
  - Atualiza uma referência de qualidade existente.

#### 🗑️ Exclusões
- **DELETE `/core/v1/measure/{id}`**
  - Exclui um indicador de desempenho.
  - Pode falhar caso existam entidades associadas (metas, metas comerciais etc.).

- **DELETE `/core/v1/measure/quality-reference/{referenceId}`**
  - Exclui uma referência de qualidade.
  - Pode falhar se houver vínculos com indicadores ou metas.

---

## ✅ Conceitos Importantes

- **Indicador**  
  Representa **o que será controlado/mensurado** (por exemplo, “Frango a passarinho”, “Novos clientes”, “Pedidos faturados”).  
  Esse cadastro não necessariamente está atrelado a um produto, e sim a um tipo de controle definido pelo cliente.

- **Meta (valor)**  
  A meta em si é o **valor numérico** definido para um indicador em um determinado período (configurada nas telas CAD396 e CAD407).  
  **Não possui unidade de medida fixa**; a interpretação é feita pelo cliente e pelos relatórios (ex.: quantidade, valor, percentual).  
  Esse valor é usado posteriormente em relatórios como a **RDU** para acompanhamento das metas.

- **Polaridade**  
  Define se **valores maiores são melhores** ou se **valores menores são desejáveis**, permitindo que o sistema e os relatórios interpretem corretamente a performance:
  - Maior é melhor (ex.: vendas, produtividade).
  - Menor é melhor (ex.: perdas, devoluções).

---

## 🧩 Relação com Outras Telas

- **CAD396 - Cadastro de Metas**
  - Utiliza os indicadores cadastrados aqui (`measureId`) para criar metas por período.
  - A **frequência do indicador** é usada para preencher automaticamente a frequência da meta.

- **CAD407 - Metas Comerciais**
  - Usa exclusivamente indicadores cujo **grupo** é “Comercial”.
  - Filtra os indicadores de acordo com a **frequência** selecionada na tela de metas comerciais.

- **CAD054 - Cadastro de Vendedores**
  - Embora não consuma diretamente os indicadores, é a origem dos vendedores que receberão metas comerciais associadas a esses indicadores.

---

## Considerações Finais

O módulo **CAD394 - Indicadores de Desempenho** é a base para todo o ecossistema de metas e acompanhamento de resultados.  
Ao definir claramente **o que será medido**, **como será medido** (frequência e formato) e **como será avaliado** (polaridade e referências de qualidade), a tela garante consistência para as metas gerais (CAD396), metas comerciais por vendedor (CAD407) e demais relatórios e dashboards do sistema.


