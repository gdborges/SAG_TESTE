# Tasks: Implement Missing Delphi Features

**Status Geral:** 68/82 tarefas concluidas
**Ultima Atualizacao:** 2026-01-02

---

## Fase 1: Completar InicValoCampPers (Baixa) - CONCLUIDA

**Objetivo:** Adicionar inicializacao de valores default para S, E, N
**Arquivos:** ConsultaService.cs
**Estimativa:** 1 hora

- [x] 1.1 Ler implementacao atual de ApplyFieldDefaultsAsync em ConsultaService.cs
- [x] 1.2 Adicionar case para CompCamp = 'S' (checkbox) usando PadrCamp
- [x] 1.3 Adicionar case para CompCamp = 'E' (texto) usando PadrCamp se definido
- [x] 1.4 Adicionar case para CompCamp IN ('N', 'EN') usando PadrCamp se definido
- [x] 1.5 Testar com formulario que tenha campos S/E/N com InicCamp=1
- [x] 1.6 Verificar que valores aparecem corretamente na UI ao clicar Novo

**Alteracoes realizadas:**
- Modificado GetFieldsWithDefaultsAsync para retornar PadrCamp como object? (suporta texto e numero)
- Adicionado tratamento explicito para CompCamp='E' (texto) usando PadrCamp.ToString()
- Adicionado tratamento explicito para CompCamp='N'/'EN' (numerico) aplicando PadrCamp mesmo se for 0
- Adicionado metodo auxiliar ConvertToDecimal() para conversao segura
- Atualizado GetFieldDefaultsAsync com a mesma logica

---

## Fase 2: InicCampSequ - Numeracao Automatica (Alta) - IMPLEMENTACAO CONCLUIDA

**Objetivo:** Gerar numeros sequenciais automaticamente para campos configurados
**Arquivos:** Novos services, MetadataService, ConsultaService, FieldMetadata
**Estimativa:** 4-6 horas

### 2.1 Model e Metadados - CONCLUIDO
- [x] 2.1.1 Adicionar propriedade TagQCamp em FieldMetadata.cs
- [x] 2.1.2 Adicionar propriedade ExisCamp em FieldMetadata.cs
- [x] 2.1.3 Modificar query em MetadataService para carregar TagQCamp, ExisCamp
- [x] 2.1.4 Criar model SequenceMetadata.cs (CodiNume, NomeNume, AtualNume, etc)

### 2.2 Service Layer - CONCLUIDO
- [x] 2.2.1 Criar interface ISequenceService.cs
- [x] 2.2.2 Criar SequenceService.cs com injecao de IDbProvider
- [x] 2.2.3 Implementar GetNextSequenceAsync(int codiNume) - tipo _UN_
- [x] 2.2.4 Implementar GetNextMaxPlusOneAsync(string tableName, string columnName) - tipo SEQU
- [x] 2.2.5 Implementar GetFieldsRequiringSequenceAsync(int tableId)
- [x] 2.2.6 Registrar ISequenceService no DI container (Program.cs)

### 2.3 Integracao com CRUD - CONCLUIDO
- [x] 2.3.1 Injetar ISequenceService no ConsultaService
- [x] 2.3.2 Modificar CreateEmptyRecordAsync para chamar geracao de sequencia
- [x] 2.3.3 Implementar logica: IF InicCamp=1 AND TagQCamp=1 AND CompCamp IN ('N','EN')
- [x] 2.3.4 Aplicar sequencia ao campo antes de retornar record
- [x] 2.3.5 Adicionar modo 'VERI' no SaveRecordAsync (verificar e gerar se vazio)

### 2.4 Testes - PENDENTE (Oracle connection timeout)
- [x] 2.4.1 Verificar estrutura da tabela POCaNume no banco
- [x] 2.4.2 Identificar campos com TagQCamp=1 e InicCamp=1 (NUMEPECE, NUMEFINA, etc)
- [ ] 2.4.3 Testar geracao de numero ao criar novo registro (bloqueado por timeout Oracle)
- [ ] 2.4.4 Testar modo VERI ao salvar registro sem numero (bloqueado por timeout Oracle)

**Nota:** Implementacao completa e compilada. Testes pendentes devido a instabilidade da conexao Oracle.

---

## Fase 3: BtnConf_CampModi - Validacao de Modificacao (Media) - CONCLUIDA

**Objetivo:** Impedir alteracao de campos protegidos
**Arquivos:** Novos services, FormController, MetadataService
**Estimativa:** 3-4 horas

### 3.1 Metadados - CONCLUIDO
- [x] 3.1.1 Adicionar propriedade MarcCamp em FieldMetadata.cs
- [x] 3.1.2 Modificar query em MetadataService para carregar MarcCamp
- [x] 3.1.3 Identificar campos com prefixo ApAt{SiglTabe}

### 3.2 Service Layer - CONCLUIDO
- [x] 3.2.1 Criar interface IValidationService.cs
- [x] 3.2.2 Criar ValidationService.cs
- [x] 3.2.3 Implementar GetProtectedFieldsAsync(int tableId)
- [x] 3.2.4 Implementar ValidateModificationsAsync(tableId, originalData, newData)
- [x] 3.2.5 Retornar lista de campos violados com mensagens
- [x] 3.2.6 Registrar IValidationService no DI container

### 3.3 Integracao com Controller - CONCLUIDO
- [x] 3.3.1 Injetar IValidationService no FormController
- [x] 3.3.2 Adicionar endpoint POST /Form/ValidateModifications
- [x] 3.3.3 Se validacao falhar, retornar BadRequest com mensagens
- [x] 3.3.4 Adicionar endpoint GET /Form/GetProtectedFields?tableId={id}

### 3.4 Frontend - CONCLUIDO
- [x] 3.4.1 Modificar sag-events.js com funcoes de validacao de campos protegidos
- [x] 3.4.2 Exibir mensagem especifica de campo protegido (showProtectedFieldsError)
- [x] 3.4.3 Destacar visualmente campo que causou erro (highlightViolatedFields)

**Alteracoes realizadas:**
- FieldMetadata.cs: Adicionado MarcCamp, InteCamp, IsProtected, RequiresModificationValidation
- FormMetadata.cs: Adicionado FinaTabe para controle de finalizacao
- MetadataService.cs: Query atualizada para carregar MarcCamp, InteCamp, FinaTabe
- IValidationService.cs: Interface com ProtectedFieldInfo, ValidationResult, ValidationViolation
- ValidationService.cs: Implementacao completa da logica BtnConf_CampModi do Delphi
- ValidateModificationsRequest.cs: Request model para endpoint de validacao
- FormController.cs: Endpoints GetProtectedFields e ValidateModifications
- Program.cs: Registrado IValidationService no DI container
- sag-events.js: API completa de validacao de campos protegidos

**Logica de protecao:**
- Campos com MarcCamp=1: Sempre protegidos
- Campos ApAt{FinaTabe}: Protegidos se registro finalizado (Tabe{FinaTabe} != '' AND CodiGene != 0)
- Campos calculados (EE/LE/EN/LN): Sempre protegidos

---

## Fase 4: Tipos de Componente (Media) - CONCLUIDA

**Objetivo:** Renderizar componentes faltantes
**Arquivos:** _FieldRendererV2.cshtml, FieldMetadata.cs, form-renderer.css
**Estimativa:** 3-4 horas

### 4.1 Model - CONCLUIDO (ja existia)
- [x] 4.1.1 Adicionar BTN ao enum ComponentType em FieldMetadata.cs
- [x] 4.1.2 Adicionar InfoField (IE/IM/IR/IN) ao enum ComponentType
- [x] 4.1.3 Adicionar Label (LBL) ao enum ComponentType
- [x] 4.1.4 Adicionar CalculatedEdit (EE/LE) ao enum ComponentType
- [x] 4.1.5 Adicionar CalculatedNumeric (EN/LN) ao enum ComponentType
- [x] 4.1.6 Atualizar GetComponentType() para mapear novos tipos

### 4.2 View - Botao (BTN) - CONCLUIDO
- [x] 4.2.1 Adicionar case BTN em _FieldRendererV2.cshtml
- [x] 4.2.2 Renderizar como <button class="btn btn-secondary sag-btn">
- [x] 4.2.3 Adicionar atributo data-plsag-onclick com ExprCamp
- [x] 4.2.4 Adicionar handler de click em sag-events.js (bindSagButtons)

### 4.3 View - Info Fields (IE/IM/IR/IN) - CONCLUIDO (ja existia)
- [x] 4.3.1 Adicionar case InfoField em _FieldRendererV2.cshtml
- [x] 4.3.2 Renderizar como input/textarea com class form-control-info
- [x] 4.3.3 Aplicar readonly e data-info="true"
- [x] 4.3.4 Estilizar para parecer campo desabilitado (.field-info)

### 4.4 View - Label (LBL) - CONCLUIDO (ja existia)
- [x] 4.4.1 Adicionar case Label em _FieldRendererV2.cshtml
- [x] 4.4.2 Renderizar como <span class="field-static-label">
- [x] 4.4.3 Usar LabeCamp como conteudo

### 4.5 View - Campos Calculados (EE/LE/EN/LN) - CONCLUIDO (ja existia)
- [x] 4.5.1 Adicionar cases em _FieldRendererV2.cshtml
- [x] 4.5.2 Renderizar como input (readonly para LE/LN)
- [x] 4.5.3 Adicionar classe visual diferenciada (.form-control-calc, fundo cinza)

### 4.6 CSS - CONCLUIDO (ja existia)
- [x] 4.6.1 Adicionar estilos para .field-button em form-renderer.css
- [x] 4.6.2 Adicionar estilos para .form-control-info
- [x] 4.6.3 Adicionar estilos para .form-control-calc e .field-calc

**Nota:** A maior parte da Fase 4 ja estava implementada. O unico item faltante era:
- 4.2.3: Adicionado data-plsag-onclick com ExprCamp ao botao BTN
- 4.2.4: Criada funcao bindSagButtons() em sag-events.js que executa PlsagInterpreter.execute()

---

## Fase 5: DuplCliq - Duplo Clique (Baixa) - CONCLUIDA

**Objetivo:** Abrir lookup expandido ao duplo-clicar em campos T/IT/L/IL
**Arquivos:** sag-events.js, _FieldRendererV2.cshtml
**Estimativa:** 2 horas

- [x] 5.1 Adicionar data-has-duplcliq em campos T/IT/L/IL em _FieldRendererV2.cshtml
- [x] 5.2 Criar funcao openExpandedLookup(fieldId, sqlCamp) em sag-events.js
- [x] 5.3 Registrar evento dblclick em campos com data-has-duplcliq
- [x] 5.4 Criar modal de lookup expandido (reutilizar consulta-grid)
- [x] 5.5 Ao selecionar, preencher campo e campos IE associados
- [x] 5.6 Fechar modal apos selecao

**Alteracoes realizadas:**
- _FieldRendererV2.cshtml: Adicionado `data-has-duplcliq="true"` em campos T/IT (LookupCombo) e L/IL (LookupModal)
- _FieldRendererV2.cshtml: Adicionado `data-lookup-sql` em campos T/IT para busca direta do SQL
- sag-events.js: Nova funcao `bindDuplCliq()` para registrar evento dblclick
- sag-events.js: Nova funcao `openExpandedLookup()` para abrir modal com busca
- sag-events.js: Nova funcao `showExpandedLookupModal()` com grid filtravel
- sag-events.js: Nova funcao `selectLookupRecord()` para processar selecao
- sag-events.js: Nova funcao `fillLinkedIEFields()` para preencher campos IE associados
- Observador DOM atualizado para bind em elementos dinamicos
- Todas as funcoes exportadas na API publica do modulo

---

## Fase 6: Eventos de Movimento Completos (Media) - CONCLUIDA

**Objetivo:** Completar sistema de eventos de movimento
**Arquivos:** movement-manager.js, EventService.cs, sag-events.js
**Estimativa:** 3-4 horas

### 6.1 Backend - CONCLUIDO
- [x] 6.1.1 Verificar se EventService carrega AnteIAE_Movi_{CodiTabe}
- [x] 6.1.2 Verificar carregamento de AnteIncl_{CodiTabe}
- [x] 6.1.3 Verificar carregamento de DepoIncl_{CodiTabe}
- [x] 6.1.4 Verificar carregamento de AtuaGrid_{CodiTabe}
- [x] 6.1.5 Adicionar endpoint GET /api/movement/{tableId}/events

### 6.2 Frontend - Execucao - CONCLUIDO
- [x] 6.2.1 Implementar fireAnteIAE em movement-manager.js
- [x] 6.2.2 Executar AnteIAE antes de qualquer operacao CRUD
- [x] 6.2.3 Bloquear operacao se AnteIAE retornar false
- [x] 6.2.4 Implementar fireAnteIncl antes de INSERT
- [x] 6.2.5 Implementar fireDepoIncl apos INSERT bem-sucedido
- [x] 6.2.6 Implementar fireAtuaGrid apos refresh do grid

### 6.3 Testes - PENDENTE (requer teste manual)
- [ ] 6.3.1 Configurar evento AnteIncl que bloqueia operacao
- [ ] 6.3.2 Testar que INSERT e bloqueado
- [ ] 6.3.3 Configurar evento DepoIncl com MSG
- [ ] 6.3.4 Testar que MSG aparece apos INSERT

**Alteracoes ja implementadas (verificadas em 2026-01-02):**
- EventService.cs:GetMovementEventsAsync() - Carrega todos os eventos de movimento
- MovementEventData.cs - Model com todos os tipos de evento
- MovementController.cs - Endpoint GET /api/movement/{parentTableId}/{tableId}/events
- sag-events.js:
  - loadMovementEvents() - Carrega eventos via API
  - triggerMovementEvent() - Dispara eventos individuais
  - beforeMovementOperation() - Executa AnteIAE + AnteIncl/AnteAlte/AnteExcl
  - afterMovementOperation() - Executa DepoIncl/DepoAlte/DepoExcl + AtuaGrid
- movement-manager.js:
  - Carrega eventos no init via SagEvents.loadMovementEvents()
  - Chama SagEvents.beforeMovementOperation() antes de salvar/excluir
  - Verifica canProceed e bloqueia operacao se necessario
  - Chama SagEvents.afterMovementOperation() apos salvar/excluir

---

## Fase 7: MudaTab2 - Navegacao ESC (Baixa)

**Objetivo:** Navegar entre abas usando tecla ESC
**Arquivos:** sag-events.js ou novo arquivo, Render.cshtml
**Estimativa:** 1-2 horas

- [ ] 7.1 Criar funcao handleEscNavigation() em sag-events.js
- [ ] 7.2 Detectar aba ativa atual via Bootstrap tab API
- [ ] 7.3 Encontrar proxima aba visivel (ignorar hidden)
- [ ] 7.4 Ativar proxima aba se existir
- [ ] 7.5 Se ultima aba, focar no botao Confirmar
- [ ] 7.6 Registrar event listener global para keydown ESC
- [ ] 7.7 Ignorar ESC se modal estiver aberto
- [ ] 7.8 Testar navegacao com 3+ abas

---

## Resumo de Progresso

| Fase | Descricao | Status | Progresso |
|------|-----------|--------|-----------|
| 1 | InicValoCampPers | **Concluida** | 6/6 |
| 2 | InicCampSequ | **Impl. Concluida** | 15/17 |
| 3 | BtnConf_CampModi | **Concluida** | 14/14 |
| 4 | Tipos Componente | **Concluida** | 17/17 |
| 5 | DuplCliq | **Concluida** | 6/6 |
| 6 | Eventos Movimento | **Impl. Concluida** | 10/14 |
| 7 | MudaTab2 | Pendente | 0/8 |
| **TOTAL** | | | **68/82** |

---

## Notas para Proximas Sessoes

### Como Continuar
1. Abrir este arquivo
2. Localizar primeira tarefa nao marcada [ ]
3. Ler contexto da fase correspondente
4. Implementar tarefa
5. Marcar como [x] quando concluida
6. Fazer commit se bloco logico completo

### Dependencias entre Fases
- Fase 1 -> Fase 2 (defaults antes de sequencias)
- Fases 3, 4, 5, 7 sao independentes
- Fase 6 depende do movement system existente

### Arquivos Chave para Contexto
- `Base/SISTEMA_EVENTOS_PLSAG.md` - Documentacao tecnica completa
- `SagPoc.Web/Services/ConsultaService.cs` - CRUD principal
- `SagPoc.Web/Services/MetadataService.cs` - Carregamento de metadados
- `SagPoc.Web/Services/ValidationService.cs` - Validacao de campos protegidos
- `SagPoc.Web/Models/FieldMetadata.cs` - Metadados de campos
- `SagPoc.Web/Views/Form/_FieldRendererV2.cshtml` - Renderizacao de campos
- `SagPoc.Web/wwwroot/js/sag-events.js` - Sistema de eventos JS
