# Sistema de Movimentos - Diagramas e Fluxos

## 1. Diagrama de Classes Simplificado

```mermaid
classDiagram
    class TFrmPOHeCam6 {
        <<Formulario Principal>>
        -ListMovi: TObjectList~TMovi~
        -PgcGene: TsgPgc
        -PgcMovi: TsgPgc
        -Pnl1: TsgPnl
        -PnlDado: TsgPnl
        -DtsGrav: TDataSource
        -Prin_D: TsgDecorator
        +FormCreate()
        +FormShow()
        +AfterCreate()
        +AtuaGrid(iPara, iCodiTabe)
        +BuscaComponente(iNome) TObject
    }

    class TMovi {
        <<Wrapper de Movimento>>
        -CodiTabe: Integer
        -SeriTabe: Integer
        -GeTaTabe: Integer
        -TbsMovi: TsgTbs
        -FraCaMv: TFraCaMv
        +FraMovi: TFraGrMv
        +PnlResu: TsgPnl
        +PnlMovi: TsgPnl
    }

    class TFraCaMv {
        <<Frame Container>>
        -PnlMovi: TsgPnl
        -FraMovi: TFraGrMv
        -PnlResu: TsgPnl
    }

    class TFraGrid {
        <<Base do Grid>>
        -QryGrid: TsgQuery
        -DtsGrid: TDataSource
        -DbgGrid: TsgDBG
        -PopGrid: TsgPop
        +PopExpoExceClick()
        +PopFiltQuerClick()
    }

    class TFraGrMv {
        <<Frame Grid Movimento>>
        -BtnNovo: TsgBtn
        -BtnAlte: TsgBtn
        -BtnExcl: TsgBtn
        -ConfTabe: TConfTabe
        -Pai_Tabe: TConfTabe
        -Prin_D: TsgDecorator
        -FormParent: TsgForm
        -FormRelaModal: TsgForm
        -sgTransaction: TsgTransaction
        +BtnNovoClick()
        +BtnExclClick()
        +DbgGridDblClick()
        +AtuaGridMovi()
        +CriaFormManu() Boolean
    }

    class TConfTabe {
        <<Configuracao Tabela>>
        -CodiTabe: Integer
        -NomeTabe: String
        -FormTabe: String
        -GravTabe: String
        -SituGrav: Boolean
        -CodiGrav: Integer
        +Assign()
    }

    TFrmPOHeCam6 "1" *-- "N" TMovi : ListMovi
    TMovi "1" *-- "1" TFraCaMv : FraCaMv
    TFraCaMv "1" *-- "1" TFraGrMv : FraMovi
    TFraGrid <|-- TFraGrMv
    TFraGrMv "1" *-- "1" TConfTabe : ConfTabe
    TFraGrMv "1" *-- "1" TConfTabe : Pai_Tabe
```

---

## 2. Diagrama de Sequencia - Abertura do Formulario

```mermaid
sequenceDiagram
    autonumber
    participant U as Usuario
    participant F as POHeCam6
    participant DB as Database
    participant M as TMovi
    participant FR as FraGrMv

    U->>F: Abre Form (CodiTabe=120)

    rect rgb(240, 248, 255)
        Note over F: FormCreate
        F->>F: Cria sgTransaction
        F->>F: Cria ListMovi

        F->>DB: SELECT FROM POCATABE WHERE CabeTabe = 120

        loop Para cada movimento
            DB-->>F: Registro movimento
            F->>M: Cria TMovi
            F->>F: Cria TsgTbs (aba)

            alt SeriTabe > 50
                F->>F: Adiciona em PgcMovi mesma guia
            else SeriTabe menor ou igual a 50
                F->>F: Adiciona em PgcGene guia separada
            end

            F->>FR: Cria TFraCaMv + FraGrMv
            F->>DB: SELECT GridTabe GrCoTabe FROM POCATABE WHERE CodiTabe = N
            DB-->>F: SQL e colunas do grid
            F->>FR: Configura QryGrid.SQL
            F->>M: Adiciona a ListMovi
        end
    end

    rect rgb(240, 255, 240)
        Note over F: FormShow
        F->>F: Carrega cabecalho

        loop Para cada movimento
            F->>FR: Pai_Tabe.CodiGrav = CodiCab
            F->>FR: sgTransaction = Self.sgTransaction
            F->>FR: AtuaGridMovi
            FR->>DB: SELECT FROM TABMOV WHERE CodiPai = Codi
            DB-->>FR: Dados do movimento
        end

        F->>F: Executa OnShow
    end

    F-->>U: Formulario exibido
```

---

## 3. Diagrama de Sequencia - Incluir Movimento

```mermaid
sequenceDiagram
    autonumber
    participant U as Usuario
    participant FR as FraGrMv
    participant P as POHeCam6
    participant M as FormModal
    participant DB as Database

    U->>FR: Click Novo
    FR->>FR: Tag = 0 Inclusao

    rect rgb(255, 240, 240)
        Note over FR,P: Eventos ANTES
        FR->>P: AnteIAE_Movi_CodiTabe
        P-->>FR: OK / Bloqueia

        alt Validacao OK
            FR->>P: AnteIncl_CodiTabe
            P-->>FR: OK / Bloqueia
        end
    end

    alt Todas validacoes OK
        rect rgb(240, 255, 240)
            Note over FR,M: Criacao do Form Modal
            FR->>FR: CriaFormManu
            Note over FR: FindClass FClassName e Cria instancia

            FR->>M: sgTransaction = pai.sgTransaction
            FR->>M: ConfTabe.SituGrav = True
            FR->>M: ConfTabe.CodiGrav = 0
            FR->>P: Carrega ShowPai_Filh_CodiTabe
            FR->>M: ShowModal
        end

        rect rgb(240, 240, 255)
            Note over U,M: Usuario preenche dados
            U->>M: Preenche campos
            U->>M: Click Confirmar
            M->>DB: INSERT INTO TabMov
            DB-->>M: OK
            M-->>FR: mrOk
        end

        rect rgb(255, 255, 220)
            Note over FR,P: Eventos DEPOIS
            FR->>P: DepoIAE_Movi_CodiTabe
            FR->>P: DepoIncl_CodiTabe
            FR->>FR: AtuaGridMovi
        end
    end

    FR-->>U: Grid Atualizado
```

---

## 4. Diagrama de Sequencia - Excluir Movimento

```mermaid
sequenceDiagram
    autonumber
    participant U as Usuario
    participant FR as FraGrMv
    participant P as POHeCam6
    participant D as Prin_D
    participant DB as Database

    U->>FR: Seleciona linha no grid
    U->>FR: Click Excluir

    rect rgb(255, 240, 240)
        Note over FR,P: Eventos ANTES
        FR->>P: AnteIAE_Movi_CodiTabe
        P-->>FR: OK / Bloqueia

        alt Validacao OK
            FR->>P: AnteExcl_CodiTabe
            P-->>FR: OK / Bloqueia
        end
    end

    alt Todas validacoes OK
        rect rgb(240, 255, 240)
            Note over FR,DB: Execucao da Exclusao

            alt Tem Prin_D Decorator
                FR->>D: BuscaPorCodi codigo
                D-->>FR: vTabe
                FR->>D: TabNewOld.Assign vTabe
                FR->>D: Remo_Tab
                D->>DB: DELETE FROM TabMov
            else Nao tem Prin_D
                FR->>DB: ExecSQL DELETE FROM
            end

            DB-->>FR: OK
        end

        rect rgb(255, 255, 220)
            Note over FR,P: Eventos DEPOIS
            FR->>FR: AtuaGridMovi
            FR->>P: DepoIAE_Movi_CodiTabe
            FR->>P: DepoExcl_CodiTabe
        end
    end

    FR-->>U: Grid Atualizado
```

---

## 5. Fluxo de Eventos nos Movimentos

```mermaid
flowchart TD
    START((Operacao IAE)) --> A1

    subgraph ANTES[1. EVENTOS ANTES]
        direction TB
        A1[AnteIAE_Movi_CodiTabe]
        A1 --> A2{Validacao OK?}
        A2 -->|Sim| A3[AnteIncl / AnteAlte / AnteExcl]
        A2 -->|Nao| BLOCK((Bloqueada))
        A3 --> A4{Validacao OK?}
        A4 -->|Nao| BLOCK
    end

    A4 -->|Sim| B1

    subgraph EXECUCAO[2. EXECUCAO]
        direction TB
        B1[INSERT / UPDATE / DELETE]
    end

    B1 --> C1

    subgraph DEPOIS[3. EVENTOS DEPOIS]
        direction TB
        C1[DepoIAE_Movi_CodiTabe]
        C1 --> C2[DepoIncl / DepoAlte / DepoExcl]
        C2 --> C3[AtuaGrid_CodiTabe]
    end

    C3 --> FIM((Fim))
    BLOCK --> FIM
```

---

## 6. Fluxo de Criacao do Form Modal

```mermaid
flowchart TD
    A[BtnNovoClick] --> B{Form ja<br/>existe?}

    B -->|Sim Desktop| C[Reutiliza FormRelaModal]
    B -->|Nao| D[CriaFormManu]

    D --> E[Determina FClassName]
    E --> F{Pai tem<br/>POHeCam?}

    F -->|Sim| G[FClassName = Pai_Tabe.FormTabe]
    F -->|Nao| H[FClassName = ConfTabe.FormTabe]

    G --> I{Modo<br/>Mobile?}
    H --> I

    I -->|Sim| J[Adiciona 'Mobi' ao nome]
    I -->|Nao| K[Mantem nome]

    J --> L{ERPUNI?}
    K --> L

    L -->|Sim| M[Adiciona 'Modal' ao nome]
    L -->|Nao| N[Mantem nome]

    M --> O[FindClass FClassName]
    N --> O

    O --> P{Classe<br/>encontrada?}

    P -->|Nao| Q[Retorna False]
    P -->|Sim| R[Cria instancia]

    R --> S[Configura sgTransaction]
    S --> T[Configura FormRela/FormParent]
    T --> U[Define sgIsMovi = True]
    U --> V[Define HelpContext = CodiTabe]
    V --> W[Retorna True]

    C --> W
```

---

## 7. Relacionamento de Dados

```mermaid
erDiagram
    POCATABE_CAB ||--o{ POCATABE_MOV : "CabeTabe"
    TABELA_CAB ||--o{ TABELA_MOV : "CodiPai"

    POCATABE_CAB {
        int CODITABE PK "120"
        varchar NOMETABE "Contrato"
        varchar FORMTABE "TFrmPOHeCam6"
        varchar GRAVTABE "POCACONT"
        int CABETABE "null"
    }

    POCATABE_MOV {
        int CODITABE PK "125"
        varchar NOMETABE "Mov. Contratos"
        varchar FORMTABE "TFrmPOHeCam6"
        varchar GRAVTABE "POCAMVCT"
        int CABETABE FK "120"
        varchar SERITABE "2"
        varchar GUI1TABE "Produtos"
        text GRIDTABE "SQL do Grid"
    }

    TABELA_CAB {
        int CODICONT PK "1"
        date DATACONT
        int CLIECONT FK
        varchar STATUS
    }

    TABELA_MOV {
        int CODIMVCT PK "1"
        int CODICONT FK "1"
        int PRODMVCT FK
        decimal QTDEMVCT
        decimal VALOMVCT
    }
```

---

## 8. Maquina de Estados do Movimento

```mermaid
stateDiagram-v2
    [*] --> Inexistente

    Inexistente --> Criado: FormCreate

    Criado --> Carregado: FormShow AtuaGridMovi

    Carregado --> Incluindo: Click Novo
    Carregado --> Alterando: Click Alterar ou DblClick
    Carregado --> Excluindo: Click Excluir

    Incluindo --> Atualizado: Confirma mrOk
    Incluindo --> Carregado: Cancela mrCancel

    Alterando --> Atualizado: Confirma mrOk
    Alterando --> Carregado: Cancela mrCancel

    Excluindo --> Atualizado: Confirma exclusao

    Atualizado --> Carregado: AtuaGridMovi

    Carregado --> [*]: FormClose
```

---

## 9. Hierarquia de Decorators

```mermaid
flowchart TD
    subgraph CAB["Formulario Cabecalho"]
        A[Prin_D do Cabecalho]
        B[ListPrin]
        C[DataSet: DtsGrav]
        D[Conn: sgTransaction]
    end

    subgraph MOV1["Movimento 1"]
        E[Prin_D Mov1]
        F[DataSet: QryGrid]
    end

    subgraph MOV2["Movimento 2"]
        G[Prin_D Mov2]
        H[DataSet: QryGrid]
    end

    subgraph MOVN["Movimento N"]
        I[Prin_D MovN]
        J[DataSet: QryGrid]
    end

    A --> B
    A --> C
    A --> D

    B --> E
    B --> G
    B --> I

    E -.->|Pai_Prin_D| A
    G -.->|Pai_Prin_D| A
    I -.->|Pai_Prin_D| A

    E -.->|Conn| D
    G -.->|Conn| D
    I -.->|Conn| D

    style A fill:#f9f,stroke:#333
    style E fill:#bbf,stroke:#333
    style G fill:#bbf,stroke:#333
    style I fill:#bbf,stroke:#333
```

---

## 10. Layout Visual - Tipos de Exibicao

### 10.1 SERITABE maior que 50 - Movimento na Mesma Guia

```mermaid
flowchart TD
    subgraph FORM[Formulario de Contrato]
        direction TB

        subgraph TOOLBAR[Barra de Ferramentas]
            BTN1[Confirmar]
            BTN2[Cancelar]
            BTN3[Fechar]
        end

        subgraph TABS[Guias]
            TAB1[Dados Gerais - Ativa]
            TAB2[Observacoes]
        end

        subgraph CONTENT[Conteudo da Guia]
            direction TB

            subgraph PNL1[Pnl1 - Campos do Cabecalho]
                F1[Numero]
                F2[Data]
                F3[Cliente]
            end

            subgraph PNLDADO[PnlDado - Movimento abaixo]
                direction TB

                subgraph BTNS[Botoes]
                    B1[Novo]
                    B2[Alterar]
                    B3[Excluir]
                end

                GRID[Grid - Cod / Produto / Qtde / Valor]
                RESUME[PnlResu - Total R$ 1.500]
            end
        end
    end

    style TAB1 fill:#90EE90
    style PNL1 fill:#E6E6FA
    style PNLDADO fill:#FFE4B5
```

### 10.2 SERITABE menor ou igual a 50 - Movimento em Guia Separada

```mermaid
flowchart TD
    subgraph FORM[Formulario de Contrato]
        direction TB

        subgraph TOOLBAR[Barra de Ferramentas]
            BTN1[Confirmar]
            BTN2[Cancelar]
            BTN3[Fechar]
        end

        subgraph TABS[Guias]
            TAB1[Dados Gerais]
            TAB2[Produtos - Ativa]
            TAB3[Observacoes]
        end

        subgraph CONTENT[Conteudo da Guia Produtos]
            direction TB

            subgraph BTNS[Botoes do Movimento]
                B1[Novo]
                B2[Alterar]
                B3[Excluir]
            end

            GRID[Grid - Codigo / Descricao / Qtde / VlUnit / Total]
            RESUME[PnlResu - Qtd Itens 35 - Total R$ 1.500]
        end
    end

    style TAB2 fill:#90EE90
    style CONTENT fill:#FFE4B5
```

---

## 11. Fluxo Completo - Ciclo de Vida

```mermaid
flowchart LR
    subgraph INIT["Inicializacao"]
        A1[Usuario abre<br/>formulario]
        A2[FormCreate]
        A3[Cria estrutura<br/>de movimentos]
        A4[FormShow]
        A5[Carrega dados<br/>do cabecalho]
        A6[AtuaGridMovi<br/>para cada mov]
    end

    subgraph CRUD["Operacoes CRUD"]
        B1[Click Novo]
        B2[Click Alterar]
        B3[Click Excluir]
        B4[Abre Form Modal]
        B5[Usuario edita]
        B6[Confirma/Cancela]
        B7[Executa operacao]
        B8[AtuaGridMovi]
    end

    subgraph FIM["Finalizacao"]
        C1[Usuario fecha<br/>formulario]
        C2[FormClose]
        C3[Libera recursos]
    end

    A1 --> A2 --> A3 --> A4 --> A5 --> A6
    A6 --> B1
    A6 --> B2
    A6 --> B3

    B1 --> B4
    B2 --> B4
    B4 --> B5 --> B6

    B6 -->|Confirma| B7 --> B8
    B6 -->|Cancela| A6

    B3 --> B7
    B8 --> A6

    A6 --> C1 --> C2 --> C3
```

---

## 12. Acesso a Componentes por Nome

```mermaid
flowchart TD
    A[BuscaComponente iNome] --> B{Prefixo do nome?}

    B -->|QRYDAD, QRY+CodiTabe| C[Retorna QryGrid<br/>do movimento]
    B -->|DBGDAD, DBG+CodiTabe| D[Retorna DbgGrid<br/>do movimento]
    B -->|BTNNOV, BTNINC| E[Retorna BtnNovo<br/>do movimento]
    B -->|BTNALT| F[Retorna BtnAlte<br/>do movimento]
    B -->|BTNEXC| G[Retorna BtnExcl<br/>do movimento]
    B -->|PNL+CodiTabe| H[Retorna PnlResu<br/>do movimento]
    B -->|DTSGRAV| I[Retorna DtsGrav<br/>do cabecalho]
    B -->|QRYGRAV| J[Retorna QryGrav<br/>do cabecalho]
    B -->|Outro| K[inherited<br/>BuscaComponente]

    C --> L{Encontrou?}
    D --> L
    E --> L
    F --> L
    G --> L
    H --> L
    I --> M[Retorna componente]
    J --> M
    K --> M

    L -->|Sim| M
    L -->|Nao| N[Continua loop<br/>ListMovi]
    N --> B
```

---

## 13. Checklist de Validacao

### 13.1 Estrutura Geral
- [ ] Um cabecalho (POCATABE com CabeTabe = null) pode ter N movimentos?
- [ ] SeriTabe > 50 significa movimento na MESMA guia do cabecalho?
- [ ] SeriTabe <= 50 significa movimento em guia SEPARADA?
- [ ] Multiplos movimentos podem aparecer em multiplas guias?

### 13.2 Comportamento CRUD
- [ ] Ao incluir movimento, o CodiGrav do pai eh automaticamente setado?
- [ ] A query do grid sempre filtra pelo codigo do cabecalho (:Codi)?
- [ ] Excluir usa Prin_D.Remo_Tab() quando decorator existe?
- [ ] Excluir usa DELETE direto quando nao ha decorator?

### 13.3 Sistema de Eventos
- [ ] AnteIAE_Movi_CodiTabe executa ANTES de qualquer operacao?
- [ ] Os eventos podem BLOQUEAR a operacao retornando False?
- [ ] DepoIAE_Movi_CodiTabe executa DEPOIS de qualquer operacao?
- [ ] AtuaGrid_CodiTabe executa apos o grid ser carregado?

### 13.4 Form Modal
- [ ] O form modal de edicao do movimento eh o MESMO form do cabecalho?
- [ ] A flag sgIsMovi = True indica que o form esta em modo de movimento?
- [ ] O form modal compartilha a mesma sgTransaction do pai?

### 13.5 Decorator (Prin_D)
- [ ] Pai_Prin_D do movimento aponta para Prin_D do cabecalho?
- [ ] ListPrin do cabecalho contem os Prin_D dos movimentos?
- [ ] O commit eh feito em bloco (cabecalho + movimentos)?

---

## 14. Comparativo Desktop vs Web

```mermaid
flowchart LR
    subgraph DESKTOP["Desktop (VCL)"]
        D1[TsgForm]
        D2[TsgFrame]
        D3[sgCreate]
        D4[TForm Parent]
        D5[ShowModal<br/>Sincrono]
    end

    subgraph WEB["Web (UniGUI)"]
        W1[TUniForm]
        W2[TUniFrame]
        W3[Create]
        W4[TUniFrame Parent]
        W5[ShowModal<br/>Assincrono]
    end

    subgraph ASPNET["ASP.NET MVC (Proposta)"]
        A1[Partial View]
        A2[ViewComponent]
        A3[Controller Action]
        A4[div container]
        A5[Modal Bootstrap<br/>AJAX]
    end

    D1 -.-> W1 -.-> A1
    D2 -.-> W2 -.-> A2
    D3 -.-> W3 -.-> A3
    D4 -.-> W4 -.-> A4
    D5 -.-> W5 -.-> A5
```

---

*Documento complementar para validacao visual do sistema de Movimentos*
*Versao: 1.0 - Mermaid*
