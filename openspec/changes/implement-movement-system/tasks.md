# Tasks: Implement Movement System

## 1. Metadados (movement-metadata)

- [x] 1.1 Adicionar campos CabeTabe, SeriTabe, GeTaTabe em TableMetadata.cs
- [x] 1.2 Criar model MovementMetadata.cs com propriedades hierarquicas
- [x] 1.3 Modificar query em MetadataService.GetTableMetadataAsync para incluir novos campos
- [x] 1.4 Implementar MetadataService.GetMovementTablesAsync(int parentCodiTabe)
- [x] 1.5 Carregar GRIDTABE e GRCOTABE para configuracao de grids
- [x] 1.6 Implementar carregamento recursivo para 2 niveis de hierarquia
- [x] 1.7 Adicionar MovementTables list em FormMetadata.cs

## 2. Service Layer (movement-crud)

- [x] 2.1 Criar interface IMovementService.cs
- [x] 2.2 Implementar MovementService.cs com injecao de dependencia
- [x] 2.3 Implementar GetMovementDataAsync(int parentId, int movementTableId)
- [x] 2.4 Implementar InsertMovementAsync com validacao de campos
- [x] 2.5 Implementar UpdateMovementAsync com validacao
- [x] 2.6 Implementar DeleteMovementAsync
- [x] 2.7 Adicionar suporte a PK strategy (Identity/MaxPlusOne/UserProvided)
- [x] 2.8 Registrar MovementService no DI container (Program.cs)

## 3. API Controller (movement-crud)

- [x] 3.1 Criar MovementController.cs
- [x] 3.2 Implementar GET /api/movement/{parentId}/tables - lista tabelas de movimento
- [x] 3.3 Implementar GET /api/movement/{parentId}/{tableId}/data - dados do grid
- [x] 3.4 Implementar GET /api/movement/{tableId}/form/{recordId} - dados para edicao
- [x] 3.5 Implementar POST /api/movement/{tableId} - insert
- [x] 3.6 Implementar PUT /api/movement/{tableId}/{recordId} - update
- [x] 3.7 Implementar DELETE /api/movement/{tableId}/{recordId} - delete
- [x] 3.8 Adicionar validacao de seguranca (tabela na whitelist)

## 4. Views - Estrutura (movement-rendering)

- [x] 4.1 Criar _MovementSection.cshtml - container principal do movimento
- [x] 4.2 Criar _MovementGrid.cshtml - tabela com dados e botoes CRUD
- [x] 4.3 Criar _MovementModal.cshtml - modal de edicao com campos do movimento
- [x] 4.4 Criar _MovementFieldRenderer.cshtml - renderizador de campos do modal
- [x] 4.5 Adicionar CSS para movement-grid, movement-modal em form-renderer.css

## 5. Views - Integracao (movement-rendering)

- [x] 5.1 Modificar Render.cshtml para detectar movimentos via MovementTables
- [x] 5.2 Implementar logica SERITABE (>50 inline, <=50 nova tab)
- [x] 5.3 Gerar tabs dinamicas para movimentos com SERITABE <= 50
- [x] 5.4 Renderizar secoes inline para movimentos com SERITABE > 50
- [x] 5.5 Passar dados de movimento via Model para partial views
- [x] 5.6 Suporte a sub-movimentos (nivel 2) dentro do modal

## 6. JavaScript - Core (movement-rendering)

- [x] 6.1 Criar movement-manager.js com classe MovementManager
- [x] 6.2 Implementar initMovements() - inicializacao no load
- [x] 6.3 Implementar loadMovementGrid(tableId, parentId) - carrega dados
- [x] 6.4 Implementar refreshMovementGrid(tableId) - atualiza grid
- [x] 6.5 Implementar selectMovementRow(tableId, recordId) - selecao
- [x] 6.6 Adicionar paginacao client-side ou server-side

## 7. JavaScript - Modal (movement-rendering)

- [x] 7.1 Implementar openMovementModal(mode, tableId, recordId) - abre modal
- [x] 7.2 Implementar closeMovementModal() - fecha modal
- [x] 7.3 Implementar loadMovementForm(tableId, recordId) - carrega campos
- [x] 7.4 Implementar submitMovementForm() - envia dados
- [x] 7.5 Configurar modal nao-bloqueante (backdrop: false)
- [x] 7.6 Implementar dirty check para unsaved changes

## 8. JavaScript - CRUD (movement-crud)

- [x] 8.1 Implementar createMovement(tableId, data) - POST para API
- [x] 8.2 Implementar updateMovement(tableId, recordId, data) - PUT para API
- [x] 8.3 Implementar deleteMovement(tableId, recordId) - DELETE para API
- [x] 8.4 Adicionar confirmacao antes de DELETE
- [x] 8.5 Tratamento de erros com feedback visual
- [x] 8.6 Loading indicator durante operacoes

## 9. Eventos de Movimento (movement-events)

- [x] 9.1 Implementar EventService.GetMovementEventsAsync(int movementTableId)
- [x] 9.2 Carregar eventos AnteIAE_Movi_<CodiTabe> do SISTCAMP
- [x] 9.3 Carregar eventos especificos (AnteIncl, AnteAlte, AnteExcl)
- [x] 9.4 Carregar eventos DepoIAE_Movi e DepoIncl/Alte/Excl
- [x] 9.5 Carregar evento AtuaGrid_<CodiTabe>
- [x] 9.6 Carregar evento ShowPai_Filh_<CodiTabe>

## 10. Eventos - Execucao (movement-events)

- [x] 10.1 Modificar sag-events.js para suportar eventos de movimento
- [x] 10.2 Implementar fireMovementEvent(eventType, tableId, data)
- [x] 10.3 Executar eventos "Ante" antes de operacoes CRUD
- [x] 10.4 Bloquear operacao se evento retornar false
- [x] 10.5 Executar eventos "Depo" apos operacoes CRUD
- [x] 10.6 Executar AtuaGrid apos refresh

## 11. Integracao PLSAG (movement-integration)

- [x] 11.1 Adicionar contexto movementData (DM) no plsag-interpreter.js
- [x] 11.2 Adicionar contexto subMovementData (D2) no interpreter
- [x] 11.3 Implementar substituicao de templates {DM-Campo}
- [x] 11.4 Implementar substituicao de templates {D2-Campo}
- [x] 11.5 Atualizar contexto ao trocar linha no grid
- [x] 11.6 Atualizar contexto ao abrir modal

## 12. Integracao Forms (movement-integration)

- [x] 12.1 Implementar BuscaComponente via document.querySelector
- [x] 12.2 Mapear nomes Delphi para seletores CSS (DBG125 -> [data-movement="125"] table)
- [x] 12.3 Suporte a ED,DBG<N>,ENABLED,0 via PLSAG
- [x] 12.4 Suporte a ED,BTNNOV<N>,VISIBLE,0 via PLSAG
- [x] 12.5 Sincronizar estado do cabecalho com movimentos

## 13. Testes e Validacao

- [x] 13.1 Testar com tabela de movimento real (ex: 120 -> 125)
- [ ] 13.2 Testar CRUD completo no grid
- [ ] 13.3 Testar eventos AnteIncl bloqueando operacao
- [ ] 13.4 Testar eventos DepoIncl executando pos-processamento
- [ ] 13.5 Testar templates {DM-Campo} em instrucoes PLSAG
- [ ] 13.6 Testar hierarquia 2 niveis com sub-movimento
- [ ] 13.7 Testar layout SERITABE (inline vs tab separada)
- [ ] 13.8 Testar modal nao-bloqueante (multiplos abertos)

## 14. Documentacao

- [x] 14.1 Atualizar CLAUDE.md com informacoes de movimentos
- [x] 14.2 Documentar API endpoints em comments
- [x] 14.3 Adicionar exemplos de uso em comentarios JS
