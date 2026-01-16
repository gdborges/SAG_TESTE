# PlusUni - Reverse Engineering

**Versao do Template:** 2.0 (Adaptado para Biblioteca)
**Data:** 2025-12-23

---

## Identificacao

- **Nome:** PlusUni
- **Unit:** PlusUni.pas
- **Modulo:** SAG (Sistema de Apoio a Gestao)
- **Versao MIMS:** V7
- **Tipo:** **Biblioteca de Funcoes** (Nao e um Formulario)

---

## Status Geral

| Artefato | Completude | Status |
|----------|------------|--------|
| Technical AS-IS | 100% | Concluido |
| Analise de Dependencias | 100% | Concluido |
| Analise de Chamadas | 100% | Concluido |
| SQL Repository | 100% | Concluido |
| User Documentation | N/A | Biblioteca |
| Components | N/A | Sem DFM |
| Functional TO-BE | 0% | Nao Iniciado |

**Completude Geral:** 80% (AS-IS + Analises + SQL)

---

## Estrutura de Arquivos

```
PlusUni/
├── README.md                           <- Este arquivo
├── BRIEFING.md                         <- Contexto do projeto
├── PlusUni_Technical_AS-IS.md          <- Documentacao tecnica completa
│
├── 01-analysis/                        <- Analises automatizadas
│   ├── dependencies_graph.json         <- Grafo de dependencias (JSON)
│   ├── dependencies_report.md          <- Relatorio de dependencias
│   ├── PlusUni_method_calls_report.md  <- Analise de chamadas de metodos
│   ├── PlusUni_procedure_calls.csv     <- Chamadas de procedures (CSV)
│   ├── PlusUni_procedure_calls.json    <- Chamadas de procedures (JSON)
│   ├── PlusUni_unit_calls.csv          <- Chamadas entre units (CSV)
│   └── PlusUni_unit_calls.json         <- Chamadas entre units (JSON)
│
├── 02-components/                      <- N/A (Biblioteca sem DFM)
│
├── 03-auxiliary-forms/                 <- N/A (Biblioteca)
│
└── 04-sql/                             <- SQL Repository
    └── PlusUni_sql_report.md           <- SQL inline extraido
```

---

## Progresso do Projeto

### FASE 1: Preparacao e Analise Inicial
- [x] BRIEFING.md criado
- [x] Estrutura de pastas criada
- [x] Analise inicial completa
- [x] Complexidade definida: ALTA

### FASE 2: Extracao Automatizada
- [x] Dependencias mapeadas (map_dependencies.py)
- [x] Chamadas de metodos mapeadas (map_method_calls.py)
- [x] SQL inline extraido (extract_sql.py)
- [ ] Componentes: N/A (Biblioteca sem DFM)

### FASE 3: Documentacao Tecnica AS-IS
- [x] Documentacao adaptada para biblioteca
- [x] Classes documentadas (TsgSenh, TMovi)
- [x] Framework CampPers documentado
- [x] 80+ funcoes publicas categorizadas
- [x] Compilacao condicional documentada
- [x] **Aguardando aprovacao Relator Tecnico**

### FASE 4: Documentacao de Usuario
- [ ] N/A - Biblioteca nao tem interface de usuario

### FASE 5: Especificacao Funcional TO-BE
- [ ] Sera parte de documentacao de formularios dependentes

---

## Caracteristicas Especiais

### Biblioteca Central do SAG

Este artefato e uma **biblioteca de funcoes**, nao um formulario:

1. **Sem DFM:** Nao possui arquivo de formulario
2. **Classes:** Define TsgSenh (licencas) e TMovi (movimentos)
3. **Framework CampPers:** Sistema de campos dinamicos
4. **80+ Funcoes:** Utilitarios usados em todo o modulo
5. **Compilacao Dual:** Suporte Web (uniGUI) e Desktop (VCL)

### Framework CampPers

O principal framework desta biblioteca permite:

- Criacao dinamica de componentes em runtime
- Configuracao via banco de dados (POCaTabe, POCaCamp)
- Execucao de instrucoes em diferentes momentos
- Validacao e regras de negocio por campo

---

## Metricas

| Metrica | Valor |
|---------|-------|
| Linhas de codigo .pas | 16,195 |
| Tamanho do arquivo | 685 KB |
| Dependencias interface | 31 |
| Dependencias implementation | 142 |
| **Total dependencias** | **173** |
| Metodos analisados | 175 |
| Chamadas de metodos | 2,805 |
| Chamadas externas | 440 |
| Cadeias de chamadas | 456 |
| Stored procedures | 2 |
| Queries SQL | 1 |
| Tabelas referenciadas | 139 |

---

## Classes Definidas

### TsgSenh
- **Proposito:** Gerenciamento de senhas, licencas e controle de acesso
- **Heranca:** TCustomSgSenh
- **Propriedades:** 14 propriedades publicas
- **Metodos:** 8 metodos publicos

### TMovi
- **Proposito:** Estrutura para movimentos (grids filhos)
- **Propriedades:** 9 propriedades
- **Uso:** Lista de movimentos em formularios POHeCam6

---

## Funcoes Principais por Categoria

| Categoria | Qtde | Descricao |
|-----------|------|-----------|
| CampPers* | 25+ | Framework de campos dinamicos |
| VeriAces* | 5 | Verificacao de acesso |
| SenhModu* | 6 | Gerenciamento de senhas |
| POCaMv* | 6 | Distribuicao de movimentos |
| Datas | 8 | Manipulacao de datas |
| Estoque | 6 | Controle de estoque |
| Lotes | 10 | Operacoes de lote/coleta |
| Utilitarios | 20+ | Funcoes diversas |

---

## Gaps e Pendencias

### Gaps Identificados
- [x] Sem DFM (e uma biblioteca)
- [x] Sem interface de usuario

### Riscos Mitigados
- [x] Complexidade Alta: Documentacao por categorias
- [x] Compilacao Condicional: Ambos os modos documentados
- [x] Muitas dependencias: Mapeamento completo

---

## Referencias

### Documentacao Oficial
- [REVERSE_ENGINEERING_STANDARD.md](../../REVERSE_ENGINEERING_STANDARD.md)
- [METHODOLOGY.md](../../2-MIMS_REVERSE_ENGINEERING_METHODOLOGY.md)

### Codigo Fonte
- **PAS:** `SAG\PlusUni.pas`
- **DFM:** N/A (Biblioteca)

### Formularios Dependentes
- **POHeCam6** - Classe base que mais utiliza esta biblioteca
- Todos os formularios do modulo SAG

### Tabelas de Configuracao
- **POCaTabe:** Configuracao de formularios
- **POCaCamp:** Configuracao de campos
- **POViAcCa:** Permissoes de acesso

---

## Notas

- Esta biblioteca e **critica** para todo o modulo SAG
- O framework CampPers e o nucleo de flexibilidade do sistema
- Alteracoes podem afetar todos os formularios derivados de POHeCam6
- A classe TsgSenh controla licenciamento - sensivel a seguranca

---

**Ultima atualizacao:** 2025-12-23
**Documentado por:** Claude Code (Automatizado)
**Versao:** 1.0
