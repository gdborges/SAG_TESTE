# 📘 Documentação Técnica - Registro de Produção (PRO009)

## 🧾 Objetivo Geral
A tela **PRO009 - Registro de Produção** tem como principal objetivo realizar o registro formal da produção de itens (como cortes de suíno, frango ou bovino) para fins de controle de estoque. Esse processo é essencial para garantir a rastreabilidade e a regularidade da produção dentro dos padrões operacionais estabelecidos, além de permitir a comercialização ou a transferência interna dos produtos produzidos.

---

## 🖥️ Fluxo Operacional no MIMS

### 1. Estrutura Necessária
Para a realização de um registro de produção no sistema MIMS, é necessário que o ambiente de trabalho disponha dos seguintes equipamentos:
- **Estação de Armazenamento** – onde os dados são centralizados.
- **Balança de Pesagem** – utilizada para capturar o peso bruto do produto.
- **Impressora de Etiquetas** – responsável pela geração das etiquetas que serão fixadas nas embalagens.

### 2. Etapas do Fluxo no MIMS
1. **Configuração Inicial**
   - Definir qual será a estação de armazenamento.
   - Associar as ferramentas necessárias: balança e impressora.
2. **Pesagem do Produto**
   - O operador seleciona o produto a ser registrado.
   - O sistema carrega as informações vinculadas a esse produto.
   - O processo de pesagem é iniciado.
3. **Validação da Pesagem**
   - O sistema valida se a fórmula `Peso Bruto - Tara = Peso Líquido` está correta.
   - Essa etapa é essencial para garantir a integridade dos dados registrados.
4. **Impressão da Etiqueta**
   - Após validação, o sistema gera uma etiqueta com as informações do produto e peso.
   - A etiqueta é impressa e fixada na caixa do produto.
5. **Registro em Estoque**
   - Finalizada a etapa anterior, um novo registro de estoque é criado automaticamente.
   - Esse produto estará, então, disponível para comercialização ou movimentação interna.

---

## 🔄 Diferenças no Sistema Vision
No sistema Vision, o processo de registro de produção foi redesenhado para atender diferentes realidades operacionais e logísticas. Para isso, foram implementados dois fluxos distintos, adaptando-se à presença ou ausência de determinados recursos (como impressoras e balanças).

### 🔁 Fluxo 1: Registro por Identificação
Este fluxo foi pensado para empresas que **não possuem impressoras de etiquetas** no ambiente operacional.

**Funcionamento:**
- O usuário define o tipo de registro como **Identificação**.
- Não há impressão de etiqueta no momento da produção.
- Utiliza-se uma etiqueta previamente registrada na tela **PRO275 - Registro de Etiquetas**.
- O sistema associa um novo registro de produção a essa etiqueta já existente.
- A produção é então considerada registrada, podendo ser visualizada posteriormente na tela **PRO048 - Apontamento de Produção**.

**Diferenças em relação ao MIMS:**
- No MIMS, primeiro é feita a pesagem e depois a etiqueta é impressa.
- No Vision, a etiqueta já existe antes da produção e apenas é associada ao novo registro.

### 📥 Fluxo 2: Registro por Produto
Esse fluxo é utilizado quando o produto ainda **não possui uma etiqueta pré-registrada**, ou quando o processo operacional dispensa a utilização de etiquetas.

**Finalidade:**
- Permitir o registro de produtos que serão destinados ao estoque mesmo sem etiquetas físicas.
- Atende tanto à comercialização quanto à movimentação interna de mercadorias (transferência entre setores, por exemplo).

---

## ⚙️ Regras de Processamento

### 🔹 Regras específicas para o fluxo por Identificação
- O campo **Identificação** é obrigatório.
- A associação da etiqueta registrada previamente é essencial para que o sistema considere o produto como produzido.

### 🔹 Regras específicas para o fluxo por Produto
- É obrigatória a seleção de uma **balança** e de um **produto válido**.
- Para produtos com `type = "CO"` (ex: cortes específicos), a seleção de uma **sala de corte** é obrigatória.
- Para produtos com tipo diferente de "CO", a seleção de sala de corte é opcional.
- O ponto de pesagem padrão será exigido somente quando a opção de pesagem for "Padrão".

### 🔸 Regras gerais aplicáveis a ambos os fluxos
- O botão **“Pesar”** só estará habilitado quando a opção de pesagem for "Padrão".
- O peso bruto informado **não pode ser igual a zero** em hipótese alguma.

---

## 🗄️ Tabelas do Banco de Dados e Regras de Negócio

### 📋 Tabelas Utilizadas

#### EMBALAGEM_CONTROLE_INDIVIDUAL
Esta tabela é utilizada para buscar as identificações (etiquetas) que ainda não foram processadas no sistema.

**Query utilizada:**
```sql
SELECT TOP 100 * 
FROM EMBALAGEM_CONTROLE_INDIVIDUAL 
WHERE ID_REGIPROD IS NULL 
  AND DT_PADREMBAINDI <= CAST(GETDATE() AS DATE)
ORDER BY DT_PADREMBAINDI DESC;
```

**Regras de negócio:**
- `ID_REGIPROD IS NULL`: Identifica etiquetas que ainda não possuem um registro de produção associado
- `DT_PADREMBAINDI <= CAST(GETDATE() AS DATE)`: Filtra apenas etiquetas com data padrão igual ou anterior ao dia atual
- Ordenação por `DT_PADREMBAINDI DESC`: Prioriza as etiquetas mais recentes

#### PRODUCAO_LOTE_CORTE
Esta tabela é consultada para identificar quais salas de corte estão disponíveis para seleção.

**Query utilizada:**
```sql
SELECT TOP 100 * 
FROM PRODUCAO_LOTE_CORTE 
ORDER BY DT_CORTLOTEPROD DESC;
```

**Regras de negócio:**
- **Condição de disponibilidade**: Para que as salas de corte apareçam como disponíveis, a coluna `DT_CORTLOTEPROD` deve conter a data atual
- Apenas salas de corte com data de produção igual ao dia corrente são consideradas ativas
- A ordenação por `DT_CORTLOTEPROD DESC` garante que as salas mais recentes apareçam primeiro

### 🔧 Regras de Funcionamento

1. **Validação de Etiquetas**
   - O sistema verifica se a etiqueta informada existe na tabela `EMBALAGEM_CONTROLE_INDIVIDUAL`
   - Etiquetas já processadas (com `ID_REGIPROD` preenchido) não podem ser reutilizadas
   - A data padrão da etiqueta deve ser válida (não pode ser futura)

2. **Disponibilidade de Salas de Corte**
   - Somente salas de corte com `DT_CORTLOTEPROD` igual à data atual são exibidas
   - Esta regra garante que apenas lotes ativos estejam disponíveis para produção
   - Para produtos do tipo "CO" (cortes), a seleção de uma sala de corte é obrigatória

3. **Integridade dos Dados**
   - O sistema mantém a rastreabilidade através da associação entre etiquetas e registros de produção
   - A data de produção deve ser consistente com as regras de negócio estabelecidas
   - Validações são aplicadas tanto no frontend quanto no backend para garantir a consistência

---

## ⚖️ Simulação de Pesagem com Hercules Setup

### O que é o Hercules Setup?
O [Hercules Setup Utility](https://www.hw-group.com/software/hercules-setup-utility) é um software gratuito utilizado para simular comunicações via porta serial, TCP/IP ou UDP. No nosso caso, ele é utilizado para simular uma balança física, permitindo o envio de um valor de peso bruto para o sistema através do webservice.

### Como utilizar o Hercules para simular pesagem?
1. **Cadastro da Balança (CAD269)**
   - Cadastrar uma nova balança informando:
     - Nome
     - Tipo
     - Status
     - Campo principal: **String Exemplo** (a string que o Hercules enviará para simular o peso)
2. **Cadastro do Ponto de Pesagem (CAD387)**
   - Obter seu IP local através do comando `ipconfig` no CMD.
   - Utilizar esse IP como Host/IP no novo ponto de pesagem.
   - Porta utilizada: **23** (padrão do Hercules TCP).
   - Definir o timeout, que representa o tempo de espera para resposta.
   - Associar a Marca/Modelo com a balança cadastrada anteriormente (CAD269).
3. **Configuração no Hercules**
   - Acesse a aba **TCP Server**.
   - No campo **Send**, insira a String Exemplo configurada no CAD269 substituindo "#" por "<>", então caso a string cadastrada seja "PB: 01,001 T: 00,000#CR#LF" ela ficará no hercules no formato "PB: 01,001 T: 00,000<CR><LF>".
   - Clique em **Enviar**. Isso enviará a pesagem simulada para o webservice common.

---

## 🔌 Integrações com Webservices

### 📥 Endpoints de Consulta
- **GetCuttingRoomLotList**
  - Retorna as salas de corte disponíveis para seleção.
- **GetWeighingPointList**
  - Lista os pontos de pesagem registrados no sistema.
- **GetSlaughterStructureList**
  - Lista as estruturas de produção que podem ser utilizadas como destino.

### 📤 Endpoint de Pesagem

- **GetWeighingPointMeasure**
   - Consulta o valor de pesagem vindo da balança (ou do Hercules).

**Payload:**
```json
{
  "WeighingPointCode": 123,
  "AuthToken": "abc123"
}
```

### 📤 Endpoints de Registro
1. **PostGenerateProduction**
   - Utilizado para registrar um novo produto no estoque com base na pesagem.

**Payload:**
```json
{
  "ProductNo": "001122",
  "IsSimulated": true,
  "ProductionDate": "2025-07-18T00:00:00.000Z",
  "ElaborationDate": "2025-07-18T00:00:00.000Z",
  "WeighingPointNo": 5,
  "ChannelCode": 101,
  "CuttingRoomLotCode": 203,
  "TareWeight": 2.5,
  "GrossWeight": 15.0,
  "AuthToken": "abc123"
}
```
2. **PostGenerateProductionFromPreLabeling**
   - Utilizado para registrar a produção com base em uma etiqueta previamente registrada.

**Payload:**
```json
{
  "LabelNo": "123456789",
  "IsSimulated": false,
  "PackageVariationCode": 12,
  "GrossWeight": 18.0,
  "CuttingRoomLotCode": 203,
  "AuthToken": "abc123"
}
```

### 🔄 Endpoints do Backend
- `GET core/v1/product/branch/{branchId}`
  - Retorna todos os produtos da filial especificada.
- `GET core/v1/weighingPoint`
  - Retorna as balanças de produção cadastradas.
- `PUT core/v1/weighingPoint`
  - Atualiza as configurações das balanças existentes.

---

## ✅ Considerações Finais
O módulo de **Registro de Produção (PRO009)** é uma ferramenta essencial para o controle operacional e logístico da empresa. Com flexibilidade para operar tanto com equipamentos físicos quanto em modo simulado (via Hercules), o sistema se adapta às diferentes realidades e necessidades dos clientes. A separação em dois fluxos distintos no sistema Vision (Identificação e Produto) proporciona versatilidade e eficiência no processo produtivo, garantindo rastreabilidade, controle de qualidade e integração com o estoque. 