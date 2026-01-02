# Spec: movement-metadata

## ADDED Requirements

### Requirement: Movement Table Discovery
The system SHALL identify movement tables through the CABETABE field in SISTTABE. The system MUST load child tables where CABETABE references the parent's CodiTabe.

#### Scenario: Cabecalho com movimentos
- **WHEN** uma tabela possui CodiTabe = 120 e existe SISTTABE com CABETABE = 120
- **THEN** o sistema carrega as tabelas filhas como MovementTables do formulario

#### Scenario: Cabecalho sem movimentos
- **WHEN** uma tabela possui CodiTabe = 400 e nao existe SISTTABE com CABETABE = 400
- **THEN** MovementTables retorna lista vazia

#### Scenario: Hierarquia 2 niveis
- **WHEN** tabela 125 tem CABETABE = 120 e tabela 126 tem CABETABE = 125
- **THEN** tabela 126 e carregada como Children de 125 (sub-movimento)

### Requirement: Movement Metadata Model
The system SHALL expose a MovementMetadata model with hierarchical properties for each movement table. The model MUST contain all information needed for rendering and operation.

#### Scenario: Propriedades essenciais
- **WHEN** MovementMetadata e carregado para tabela 125
- **THEN** contem CodiTabe, CabeTabe, SeriTabe, GravTabe, NomeTabe, SiglTabe

#### Scenario: Configuracao de grid
- **WHEN** MovementMetadata e carregado
- **THEN** contem GridTabe (SQL do grid) e GrCoTabe (colunas)

#### Scenario: Lista de filhos
- **WHEN** movimento 125 possui sub-movimentos
- **THEN** MovementMetadata.Children contem lista de sub-movimentos

### Requirement: TableMetadata Extension
The system SHALL extend TableMetadata to include parent-child relationship fields needed to identify movements.

#### Scenario: Novos campos
- **WHEN** TableMetadata e carregado
- **THEN** inclui CabeTabe (pai), SeriTabe (posicao), GeTaTabe (config grid)

### Requirement: FormMetadata Extension
The system SHALL extend FormMetadata to include a list of hierarchically loaded movement tables.

#### Scenario: MovementTables property
- **WHEN** FormMetadata e carregado para tabela 120
- **THEN** MovementTables contem lista de MovementMetadata para todos os movimentos

### Requirement: Recursive Loading
The system SHALL load movement hierarchy recursively up to 2 levels. The system MUST NOT load levels beyond the second (D3).

#### Scenario: Carregamento nivel 1
- **WHEN** MetadataService.GetMovementTablesAsync(120) e chamado
- **THEN** retorna movimentos diretos (CABETABE = 120)

#### Scenario: Carregamento nivel 2
- **WHEN** movimento nivel 1 possui filhos
- **THEN** Children sao carregados automaticamente (limite 2 niveis)

#### Scenario: Limite de profundidade
- **WHEN** existe movimento nivel 3 (D3)
- **THEN** sistema NAO carrega nivel 3 (apenas D1 e D2 suportados)
