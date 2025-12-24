# PlusUni - Briefing de Documentacao

**Versao do Template:** 2.0 (Adaptado para Biblioteca)
**Data:** 2025-12-23
**Analista Responsavel:** Claude Code (Automatizado)
**Estimativa:** 8-12h (Documentacao Tecnica)

---

## 1. Contexto

### 1.1 Identificacao

- **Nome:** PlusUni
- **Unit:** PlusUni.pas
- **Modulo:** SAG (Sistema de Apoio a Gestao)
- **Localizacao:** `SAG\PlusUni.pas`
- **Tipo:** **Biblioteca de Funcoes Utilitarias** (Nao e um Formulario)

### 1.2 Descricao Funcional

PlusUni e uma **biblioteca central** do modulo SAG que fornece:

1. **Framework CampPers** - Sistema de criacao dinamica de campos em formularios
2. **Classe TsgSenh** - Gerenciamento de senhas e licenciamento
3. **Classe TMovi** - Estrutura para movimentos em grids filhos
4. **80+ funcoes utilitarias** - Suporte a operacoes do sistema

Esta unit e referenciada por praticamente todos os formularios do modulo SAG, sendo uma dependencia critica para o funcionamento do sistema.

### 1.3 Importancia no Sistema

- **Criticidade:** 🔴 **ALTA** - Biblioteca core do modulo SAG
- **Frequencia de uso:** Constante - Usada em toda execucao do modulo
- **Dependencias:** 173 units importadas, 265 dependencias totais
- **Processo de negocio:** Todos os processos do SAG dependem desta biblioteca

---

## 2. Caracteristicas Especiais

### 2.1 Tipo de Artefato

**IMPORTANTE:** Este nao e um formulario com DFM. E uma biblioteca (unit) contendo:

- Classes
- Constantes
- Types/Records
- Funcoes globais
- Procedures globais

### 2.2 Classes Definidas

| Classe | Descricao |
|--------|-----------|
| TsgSenh | Gerenciamento de senhas, licencas e controle de acesso |
| TMovi | Estrutura para movimentos (grids filhos) em formularios |

### 2.3 Types/Records Definidos

| Type | Tipo Base | Descricao |
|------|-----------|-----------|
| TModeloXML | Enum | mxNormal, mxSimulador |
| TBuscDia_Util | Enum | duAnte, duProx |
| TStringArray | Array of String | Array dinamico de strings |
| TColorWinControl | Type | Tipo de cor para controles |
| TsgSenhModoCons | Enum | mcTota, mcProd, mcUnion |

### 2.4 Constantes Principais

| Constante | Descricao |
|-----------|-----------|
| cFiltPessSenh | Filtro padrao para consulta de pessoas |

---

## 3. Objetivos da Documentacao

### 3.1 Entregas Esperadas

- [x] **Analise de Dependencias** - 173 dependencias mapeadas
- [x] **Analise de Chamadas de Metodos** - 175 metodos, 2805 chamadas
- [x] **Extracao SQL** - 1 query, 2 SPs, 139 tabelas
- [ ] **Technical AS-IS (Adaptado)** - Documentacao tecnica para biblioteca
- [ ] **README.md** - Indice e resumo do projeto

### 3.2 Entregas NAO Aplicaveis (Biblioteca)

- ❌ **Componentes DFM** - Nao tem DFM
- ❌ **User Documentation** - Nao e uma interface de usuario
- ❌ **Functional TO-BE** - Sera parte de outra especificacao

### 3.3 Criterios de Sucesso

- ✅ Todas as classes documentadas
- ✅ Todas as funcoes publicas documentadas
- ✅ Dependencias mapeadas
- ✅ Framework CampPers explicado
- ✅ Regras de negocio identificadas

---

## 4. Escopo do Projeto

### 4.1 Incluido

- ✅ Classe TsgSenh (gerenciamento de senhas/licencas)
- ✅ Classe TMovi (estrutura de movimentos)
- ✅ Framework CampPers* (todas as funcoes)
- ✅ Funcoes utilitarias publicas
- ✅ Types e constantes
- ✅ Dependencias interface e implementation

### 4.2 Excluido

- ❌ Implementacao detalhada de cada funcao auxiliar
- ❌ Units referenciadas (documentacao separada)
- ❌ DataModules externos (DmPoul, DmPlus, etc.)

---

## 5. Metricas Extraidas

### 5.1 Codigo Fonte

| Metrica | Valor |
|---------|-------|
| Linhas de codigo | 16,195 |
| Tamanho | 685 KB |
| Metodos analisados | 175 |
| Chamadas de metodos | 2,805 |
| Chamadas externas | 440 |
| Chamadas locais | 2,365 |

### 5.2 Dependencias

| Categoria | Quantidade |
|-----------|------------|
| Interface uses | 31 |
| Implementation uses | 142 |
| **Total** | **173** |

### 5.3 SQL

| Item | Quantidade |
|------|------------|
| Stored Procedures | 2 (Chav, Linh - contexto truncado) |
| Queries SQL | 1 (complexa, multiplos JOINs) |
| Tabelas referenciadas | 139 |

---

## 6. Framework CampPers - Visao Geral

### 6.1 O Que e CampPers?

CampPers (Campos Personalizados) e um framework que permite:

1. **Criacao dinamica de componentes** em tempo de execucao
2. **Configuracao via banco de dados** (POCaTabe, POCaCamp)
3. **Execucao de instrucoes** em diferentes momentos do ciclo de vida
4. **Validacao e regras de negocio** por campo

### 6.2 Funcoes Principais do Framework

| Funcao | Descricao |
|--------|-----------|
| MontCampPers | Monta/cria campos dinamicamente |
| CampPers_BuscSQL | Busca SQL associado ao campo |
| CampPersExecExit | Executa ao sair do campo |
| CampPersExecExitShow | Executa ao exibir/sair |
| CampPers_ExecData | Executa expressoes de data |
| CampPers_ExecLinhStri | Executa linha de instrucao |
| CampPers_EX | Execucao principal de expressoes |
| InicValoCampPers | Inicializa valores dos campos |
| CampPersInicGravPara | Inicializa parametros de gravacao |
| CampPersDuplCliq | Trata duplo-clique em campos |

### 6.3 Tabelas de Configuracao

| Tabela | Descricao |
|--------|-----------|
| POCaTabe | Configuracao da tela/formulario |
| POCaCamp | Configuracao dos campos |
| POViAcCa | Permissoes de acesso aos campos |

---

## 7. Riscos e Consideracoes

### 7.1 Risco: Complexidade Alta

**Probabilidade:** Alta
**Impacto:** Alto

**Mitigacao:**
- Documentar por grupos funcionais (CampPers, TsgSenh, TMovi, Utilitarios)
- Focar nas interfaces publicas
- Referencias cruzadas com POHeCam6 (classe que mais usa esta biblioteca)

### 7.2 Risco: Compilacao Condicional

**Probabilidade:** Alta
**Impacto:** Medio

A unit usa `{$ifdef ERPUNI}` para alternar entre Web (uniGUI) e Desktop (VCL).

**Mitigacao:**
- Documentar ambos os modos
- Identificar funcoes especificas de cada modo

### 7.3 Risco: Dependencias Circulares

**Encontrado:** 1 dependencia circular detectada

**Mitigacao:**
- Mapear cadeia de dependencias
- Documentar no AS-IS

---

## 8. Proximas Acoes

### 8.1 Acoes Imediatas

1. [x] Estrutura de pastas criada
2. [x] Dependencias mapeadas
3. [x] Chamadas de metodos mapeadas
4. [x] SQL extraido
5. [x] BRIEFING.md criado
6. [ ] Criar AS-IS adaptado para biblioteca
7. [ ] Criar README.md com metricas finais

### 8.2 Estrutura da Documentacao AS-IS

Para uma biblioteca, a estrutura AS-IS sera adaptada:

1. **Identificacao** - Nome, tipo, modulo
2. **Classes** - TsgSenh, TMovi
3. **Types e Constantes** - Enums, records, constantes
4. **Framework CampPers** - Documentacao completa
5. **Funcoes Publicas** - Por categoria funcional
6. **Dependencias** - Interface e implementation
7. **SQL e Tabelas** - Queries e tabelas referenciadas
8. **Compilacao Condicional** - Modos Web/Desktop

---

## 9. Referencias

### 9.1 Documentacao Oficial

- [REVERSE_ENGINEERING_STANDARD.md](../../REVERSE_ENGINEERING_STANDARD.md)
- [METHODOLOGY.md](../../2-MIMS_REVERSE_ENGINEERING_METHODOLOGY.md)

### 9.2 Codigo Fonte

- **PAS:** `SAG\PlusUni.pas`
- **DFM:** N/A (Biblioteca)

### 9.3 Formularios Relacionados

- **POHeCam6** - Classe base que mais utiliza esta biblioteca
- Todos os formularios do modulo SAG

---

## 10. Notas e Observacoes

1. **Esta biblioteca e critica** - Alteracoes podem afetar todo o modulo SAG
2. **Framework CampPers** - E o nucleo de flexibilidade do sistema, permitindo customizacao sem codigo
3. **TsgSenh** - Controla licenciamento e acesso, sensivel a seguranca
4. **Compilacao condicional** - Requer teste em ambos os modos (Web/Desktop)

---

**Criado em:** 2025-12-23
**Criado por:** Claude Code (Automatizado)
**Versao:** 1.0
