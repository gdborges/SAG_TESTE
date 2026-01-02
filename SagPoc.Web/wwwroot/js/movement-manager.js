/**
 * MovementManager - Gerenciador de movimentos (registros filhos) para SAG Web
 *
 * Responsável por:
 * - Carregar dados dos grids de movimento
 * - Gerenciar seleção de linhas
 * - Abrir modal para inserir/editar
 * - Executar operações CRUD via API
 * - Integrar com sistema de eventos PLSAG
 */
var MovementManager = (function() {
    'use strict';

    // Estado do gerenciador
    var state = {
        parentTableId: null,
        parentRecordId: null,
        movements: {},        // Metadados indexados por CodiTabe
        selectedRows: {},     // Linhas selecionadas por CodiTabe
        currentPage: {},      // Página atual por CodiTabe
        pageSize: 50,
        modalInstance: null,
        deleteModalInstance: null
    };

    /**
     * Inicializa o gerenciador de movimentos
     * @param {number} parentTableId - ID da tabela pai (cabeçalho)
     * @param {number|null} parentRecordId - ID do registro pai (null se novo)
     * @param {Array} movementMetadata - Array de metadados dos movimentos
     */
    function init(parentTableId, parentRecordId, movementMetadata) {
        console.log('[MovementManager] Inicializando...', { parentTableId, parentRecordId, movements: movementMetadata?.length });

        state.parentTableId = parentTableId;
        state.parentRecordId = parentRecordId;

        // Indexa metadados por CodiTabe
        if (movementMetadata && Array.isArray(movementMetadata)) {
            movementMetadata.forEach(function(m) {
                state.movements[m.codiTabe] = m;
                state.currentPage[m.codiTabe] = 1;
                state.selectedRows[m.codiTabe] = null;
            });

            // Carrega eventos PLSAG de cada movimento
            loadAllMovementEvents();
        }

        // Inicializa modais Bootstrap
        initModals();

        // Configura event listeners
        setupEventListeners();

        // Carrega dados se há registro pai
        if (parentRecordId) {
            loadAllMovements();
        }

        console.log('[MovementManager] Inicialização completa');
    }

    /**
     * Inicializa as instâncias dos modais Bootstrap
     */
    function initModals() {
        var movementModalEl = document.getElementById('movementModal');
        var deleteModalEl = document.getElementById('movementDeleteModal');

        if (movementModalEl) {
            state.modalInstance = new bootstrap.Modal(movementModalEl, {
                backdrop: false, // Non-blocking
                keyboard: true
            });
        }

        if (deleteModalEl) {
            state.deleteModalInstance = new bootstrap.Modal(deleteModalEl);
        }
    }

    /**
     * Configura os event listeners para botões e grid
     */
    function setupEventListeners() {
        // Botões Novo
        document.querySelectorAll('.btn-movement-new').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var movementId = parseInt(this.dataset.movement);
                openNewMovement(movementId);
            });
        });

        // Botões Editar
        document.querySelectorAll('.btn-movement-edit').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var movementId = parseInt(this.dataset.movement);
                openEditMovement(movementId);
            });
        });

        // Botões Excluir
        document.querySelectorAll('.btn-movement-delete').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var movementId = parseInt(this.dataset.movement);
                openDeleteConfirm(movementId);
            });
        });

        // Botão Salvar do Modal
        var btnSave = document.getElementById('btnMovementSave');
        if (btnSave) {
            btnSave.addEventListener('click', saveMovement);
        }

        // Botão Confirmar Exclusão
        var btnDelete = document.getElementById('btnMovementConfirmDelete');
        if (btnDelete) {
            btnDelete.addEventListener('click', confirmDelete);
        }

        // Click nas linhas do grid (delegação de eventos)
        document.querySelectorAll('.movement-grid-table tbody').forEach(function(tbody) {
            tbody.addEventListener('click', function(e) {
                var row = e.target.closest('tr');
                if (row && row.dataset.recordId) {
                    var movementId = parseInt(tbody.closest('.movement-grid-container').dataset.movement);
                    selectRow(movementId, row);
                }
            });

            // Double-click para editar
            tbody.addEventListener('dblclick', function(e) {
                var row = e.target.closest('tr');
                if (row && row.dataset.recordId) {
                    var movementId = parseInt(tbody.closest('.movement-grid-container').dataset.movement);
                    selectRow(movementId, row);
                    openEditMovement(movementId);
                }
            });
        });

        // Paginação
        document.querySelectorAll('.movement-pagination .page-link').forEach(function(link) {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                var paginationNav = this.closest('.movement-pagination');
                var movementId = parseInt(paginationNav.id.replace('pagination-', ''));
                var action = this.dataset.page;

                if (action === 'prev') {
                    changePage(movementId, state.currentPage[movementId] - 1);
                } else if (action === 'next') {
                    changePage(movementId, state.currentPage[movementId] + 1);
                }
            });
        });
    }

    /**
     * Carrega dados de todos os movimentos
     */
    function loadAllMovements() {
        Object.keys(state.movements).forEach(function(movementId) {
            loadMovementData(parseInt(movementId));
        });
    }

    /**
     * Carrega eventos PLSAG de todos os movimentos
     */
    function loadAllMovementEvents() {
        if (!window.SagEvents) {
            console.log('[MovementManager] SagEvents não disponível, eventos não carregados');
            return;
        }

        Object.keys(state.movements).forEach(function(movementId) {
            SagEvents.loadMovementEvents(state.parentTableId, parseInt(movementId))
                .then(function(events) {
                    if (events && events.hasEvents) {
                        console.log('[MovementManager] Eventos carregados para movimento', movementId);
                    }
                })
                .catch(function(error) {
                    console.warn('[MovementManager] Erro ao carregar eventos do movimento', movementId, error);
                });
        });
    }

    /**
     * Carrega dados de um movimento específico
     * @param {number} movementId - ID da tabela de movimento (CodiTabe)
     * @param {number} page - Página a carregar (default: 1)
     */
    function loadMovementData(movementId, page) {
        page = page || state.currentPage[movementId] || 1;

        if (!state.parentRecordId) {
            console.log('[MovementManager] Sem registro pai, não carrega dados');
            return;
        }

        var loading = document.getElementById('loading-' + movementId);
        var tbody = document.getElementById('tbody-' + movementId);
        var emptyRow = document.getElementById('empty-' + movementId);

        if (loading) loading.classList.remove('d-none');

        var url = '/api/movement/' + state.parentRecordId + '/' + movementId + '/data?page=' + page + '&pageSize=' + state.pageSize;

        fetch(url)
            .then(function(response) {
                if (!response.ok) throw new Error('Erro ao carregar dados');
                return response.json();
            })
            .then(function(data) {
                if (loading) loading.classList.add('d-none');
                renderGrid(movementId, data);
                state.currentPage[movementId] = page;
                updatePagination(movementId, data);
            })
            .catch(function(error) {
                console.error('[MovementManager] Erro ao carregar movimento:', error);
                if (loading) loading.classList.add('d-none');
                showError('Erro ao carregar dados: ' + error.message);
            });
    }

    /**
     * Renderiza o grid com os dados recebidos
     * @param {number} movementId - ID do movimento
     * @param {object} data - Dados retornados pela API
     */
    function renderGrid(movementId, apiData) {
        var tbody = document.getElementById('tbody-' + movementId);
        var emptyRow = document.getElementById('empty-' + movementId);
        var metadata = state.movements[movementId];

        if (!tbody || !metadata) return;

        // API retorna 'data' (camelCase de 'Data'), não 'records'
        var records = apiData.data || apiData.records || [];
        var columns = apiData.columns || metadata.columns || [];

        // Limpa tbody
        tbody.innerHTML = '';

        if (records.length === 0) {
            // Mostra linha vazia
            var colCount = metadata.columns ? metadata.columns.length : 3;
            tbody.innerHTML = '<tr class="text-center text-muted empty-row">' +
                '<td colspan="' + colCount + '">' +
                '<div class="py-4">' +
                '<i class="bi bi-inbox fs-2 d-block mb-2 text-secondary"></i>' +
                '<span>Nenhum registro</span><br/>' +
                '<small class="text-muted">Clique em "Novo" para adicionar</small>' +
                '</div></td></tr>';
            return;
        }

        // Usa colunas da API ou do metadata (já com fallback acima)
        var pkColumn = apiData.pkColumnName || metadata.pkColumnName || 'id';

        // Renderiza linhas
        records.forEach(function(record) {
            var tr = document.createElement('tr');
            tr.dataset.recordId = record[pkColumn] || record[pkColumn.toUpperCase()] || record.id;
            tr.classList.add('movement-row');

            // Renderiza colunas
            if (columns.length > 0) {
                columns.forEach(function(col) {
                    var td = document.createElement('td');
                    // Tenta fieldName, depois uppercase (Oracle retorna maiúsculo)
                    var fieldName = col.fieldName || col.FieldName || '';
                    var value = record[fieldName] || record[fieldName.toUpperCase()] || '';
                    td.textContent = formatValue(value, col);
                    tr.appendChild(td);
                });
            } else {
                // Fallback: usa todas as propriedades do registro
                Object.keys(record).forEach(function(key) {
                    if (key !== pkColumn && key !== 'id') {
                        var td = document.createElement('td');
                        td.textContent = record[key] || '';
                        tr.appendChild(td);
                    }
                });
            }

            tbody.appendChild(tr);
        });

        // Atualiza contagem
        var summaryCount = document.getElementById('summary-count-' + movementId);
        if (summaryCount) {
            summaryCount.textContent = apiData.totalRecords || records.length;
        }
        var summary = document.getElementById('summary-' + movementId);
        if (summary && records.length > 0) {
            summary.style.display = 'block';
        }

        // Atualiza campos de totais (TOQTMVCT, TOVLMVCT, etc.)
        updateTotalsFields(apiData.totals || {});
    }

    /**
     * Atualiza os campos de totais no formulário do cabeçalho
     * @param {object} totals - Objeto com nome do campo e valor calculado
     */
    function updateTotalsFields(totals) {
        if (!totals || Object.keys(totals).length === 0) {
            return;
        }

        console.log('[MovementManager] Atualizando totais:', totals);

        Object.keys(totals).forEach(function(fieldName) {
            var value = totals[fieldName];

            // Busca o campo pelo name ou data-sag-nomecamp
            var field = document.querySelector('input[name="' + fieldName + '"]') ||
                        document.querySelector('input[data-sag-nomecamp="' + fieldName + '"]') ||
                        document.querySelector('[name="' + fieldName.toUpperCase() + '"]') ||
                        document.querySelector('[name="' + fieldName.toLowerCase() + '"]');

            if (field) {
                // Formata o valor (números com decimais)
                var formattedValue = value;
                if (typeof value === 'number') {
                    formattedValue = value.toFixed(2);
                } else if (value !== null && value !== undefined) {
                    formattedValue = String(value);
                } else {
                    formattedValue = '0';
                }

                field.value = formattedValue;
                console.log('[MovementManager] Campo ' + fieldName + ' atualizado para:', formattedValue);
            } else {
                console.log('[MovementManager] Campo ' + fieldName + ' não encontrado no DOM');
            }
        });
    }

    /**
     * Formata valor para exibição no grid
     * @param {*} value - Valor a formatar
     * @param {object} col - Configuração da coluna
     */
    function formatValue(value, col) {
        if (value === null || value === undefined) return '';

        // TODO: Adicionar formatação baseada no tipo da coluna
        // Por enquanto, apenas converte para string
        return String(value);
    }

    /**
     * Atualiza a paginação
     * @param {number} movementId - ID do movimento
     * @param {object} data - Dados da API com info de paginação
     */
    function updatePagination(movementId, apiData) {
        var pagination = document.getElementById('pagination-' + movementId);
        if (!pagination) return;

        var records = apiData.data || apiData.records || [];
        var totalRecords = apiData.totalRecords || apiData.totalCount || 0;
        var totalPages = Math.ceil(totalRecords / state.pageSize);
        var currentPage = state.currentPage[movementId];

        if (totalPages > 1) {
            pagination.classList.remove('d-none');

            var prev = document.getElementById('prev-' + movementId);
            var next = document.getElementById('next-' + movementId);
            var pageInfo = document.getElementById('page-info-' + movementId);
            var totalInfo = document.getElementById('total-info-' + movementId);
            var currentPageEl = document.getElementById('current-page-' + movementId);

            if (prev) prev.classList.toggle('disabled', currentPage <= 1);
            if (next) next.classList.toggle('disabled', currentPage >= totalPages);
            if (currentPageEl) currentPageEl.querySelector('.page-link').textContent = currentPage;
            if (pageInfo) pageInfo.textContent = records.length || 0;
            if (totalInfo) totalInfo.textContent = totalRecords;
        } else {
            pagination.classList.add('d-none');
        }
    }

    /**
     * Muda para outra página
     * @param {number} movementId - ID do movimento
     * @param {number} page - Nova página
     */
    function changePage(movementId, page) {
        if (page < 1) return;
        loadMovementData(movementId, page);
    }

    /**
     * Seleciona uma linha do grid
     * @param {number} movementId - ID do movimento
     * @param {HTMLElement} row - Elemento TR selecionado
     */
    function selectRow(movementId, row) {
        // Remove seleção anterior
        var tbody = row.closest('tbody');
        tbody.querySelectorAll('tr.selected').forEach(function(tr) {
            tr.classList.remove('selected', 'table-primary');
        });

        // Seleciona nova linha
        row.classList.add('selected', 'table-primary');
        state.selectedRows[movementId] = parseInt(row.dataset.recordId);

        // Habilita botões de editar/excluir
        var btnGroup = document.getElementById('btn-group-' + movementId);
        if (btnGroup) {
            btnGroup.querySelector('.btn-movement-edit').disabled = false;
            btnGroup.querySelector('.btn-movement-delete').disabled = false;
        }
    }

    /**
     * Abre modal para novo registro
     * @param {number} movementId - ID do movimento
     */
    function openNewMovement(movementId) {
        if (!state.parentRecordId) {
            showError('Salve o registro principal antes de adicionar movimentos.');
            return;
        }

        var metadata = state.movements[movementId];
        if (!metadata) return;

        // Configura modal
        document.getElementById('movementModalTitle').textContent = 'Novo ' + metadata.tabName;
        document.getElementById('movementModalTableId').value = movementId;
        document.getElementById('movementModalRecordId').value = '';
        document.getElementById('movementModalParentId').value = state.parentRecordId;
        document.getElementById('movementModalMode').value = 'insert';
        document.getElementById('movementModalInfo').textContent = '';

        // Carrega campos do formulário
        loadMovementForm(movementId, null);

        // Abre modal
        if (state.modalInstance) {
            state.modalInstance.show();
        }
    }

    /**
     * Abre modal para editar registro selecionado
     * @param {number} movementId - ID do movimento
     */
    function openEditMovement(movementId) {
        var recordId = state.selectedRows[movementId];
        if (!recordId) {
            showError('Selecione um registro para editar.');
            return;
        }

        var metadata = state.movements[movementId];
        if (!metadata) return;

        // Configura modal
        document.getElementById('movementModalTitle').textContent = 'Editar ' + metadata.tabName;
        document.getElementById('movementModalTableId').value = movementId;
        document.getElementById('movementModalRecordId').value = recordId;
        document.getElementById('movementModalParentId').value = state.parentRecordId;
        document.getElementById('movementModalMode').value = 'edit';
        document.getElementById('movementModalInfo').textContent = 'Registro #' + recordId;

        // Carrega campos e dados
        loadMovementForm(movementId, recordId);

        // Abre modal
        if (state.modalInstance) {
            state.modalInstance.show();
        }
    }

    /**
     * Carrega o formulário de movimento via server-side rendering
     * @param {number} movementId - ID do movimento
     * @param {number|null} recordId - ID do registro (null para novo)
     */
    function loadMovementForm(movementId, recordId) {
        var formContent = document.getElementById('movementFormContent');
        var loading = document.getElementById('movementModalLoading');

        if (loading) loading.classList.remove('d-none');
        if (formContent) formContent.innerHTML = '';

        // Usa endpoint server-side que retorna HTML renderizado
        var url = '/Form/MovementFormHtml/' + movementId;
        if (recordId) {
            url += '?recordId=' + recordId;
        }

        // Carrega eventos de campo de movimento em paralelo
        var fieldEventsPromise = null;
        if (window.SagEvents && typeof SagEvents.loadMovementFieldEvents === 'function') {
            fieldEventsPromise = SagEvents.loadMovementFieldEvents(movementId);
        }

        fetch(url)
            .then(function(response) {
                if (!response.ok) throw new Error('Erro ao carregar formulário');
                return response.text(); // Retorna HTML, não JSON
            })
            .then(async function(html) {
                // Aguarda eventos de campo carregarem
                if (fieldEventsPromise) {
                    await fieldEventsPromise;
                }

                if (loading) loading.classList.add('d-none');
                if (formContent) {
                    formContent.innerHTML = html;

                    // Define contexto de movimento ativo para eventos PLSAG
                    if (window.SagEvents) {
                        SagEvents.setActiveMovementContext({
                            parentTableId: state.parentTableId,
                            movementTableId: movementId,
                            parentRecordId: state.parentRecordId,
                            recordId: recordId,
                            formData: {}
                        });
                    }

                    // Inicializa componentes após inserir HTML
                    initFormComponents(formContent, movementId);

                    // Se é edição, preenche descrições de campos lookup existentes
                    if (recordId && window.SagEvents && typeof SagEvents.populateLookupDescriptions === 'function') {
                        await SagEvents.populateLookupDescriptions(formContent);
                    }
                }
            })
            .catch(function(error) {
                console.error('[MovementManager] Erro ao carregar formulário:', error);
                if (loading) loading.classList.add('d-none');
                if (formContent) {
                    formContent.innerHTML = '<div class="alert alert-danger">' +
                        '<i class="bi bi-exclamation-triangle me-2"></i>' +
                        'Erro ao carregar formulário: ' + error.message +
                        '</div>';
                }
            });
    }

    /**
     * Inicializa componentes do formulário após renderização
     * @param {HTMLElement} container - Container do formulário
     * @param {number} movementTableId - ID da tabela de movimento (para contexto OnExit)
     */
    function initFormComponents(container, movementTableId) {
        // Inicializa botões de lookup via SagEvents
        if (window.SagEvents && typeof SagEvents.bindLookupButtons === 'function') {
            SagEvents.bindLookupButtons(container);
        }

        // Inicializa máscaras se disponível
        if (window.IMask) {
            container.querySelectorAll('[data-mask]').forEach(function(input) {
                var mask = input.dataset.mask;
                if (mask) {
                    IMask(input, { mask: mask });
                }
            });
        }

        // Registra campos para eventos OnExit (com contexto de movimento)
        container.querySelectorAll('[data-sag-codicamp]').forEach(function(field) {
            // Evita duplo bind
            if (field.dataset.exitBound) return;
            field.dataset.exitBound = 'true';

            field.addEventListener('blur', function() {
                if (window.SagEvents) {
                    // Passa movementTableId para resolver eventos de campo de movimento
                    SagEvents.onFieldExit(this.dataset.sagCodicamp, this.value, movementTableId);
                }
            });

            // Para select/combo, também trigger no change
            if (field.tagName === 'SELECT') {
                field.addEventListener('change', function() {
                    if (window.SagEvents) {
                        SagEvents.onFieldExit(this.dataset.sagCodicamp, this.value, movementTableId);
                    }
                });
            }
        });
    }

    /**
     * Escapa HTML para prevenir XSS
     * @param {string} str - String a escapar
     * @returns {string} String escapada
     */
    function escapeHtml(str) {
        if (str === null || str === undefined) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    /**
     * Salva o registro de movimento
     */
    async function saveMovement() {
        var form = document.getElementById('movementForm');
        if (!form) return;

        // Valida formulário
        if (!form.checkValidity()) {
            form.classList.add('was-validated');
            return;
        }

        var tableId = parseInt(document.getElementById('movementModalTableId').value);
        var recordId = document.getElementById('movementModalRecordId').value;
        var parentId = parseInt(document.getElementById('movementModalParentId').value);
        var mode = document.getElementById('movementModalMode').value;

        // Coleta campos
        var formData = new FormData(form);
        var fields = {};
        formData.forEach(function(value, key) {
            if (!key.startsWith('_')) { // Ignora campos hidden do form
                fields[key] = value;
            }
        });

        // Garante checkboxes não marcados
        form.querySelectorAll('input[type="checkbox"]').forEach(function(cb) {
            if (!cb.checked && cb.name) {
                fields[cb.name] = '0';
            }
        });

        // Executa eventos PLSAG antes de salvar
        if (window.SagEvents) {
            var operation = mode === 'insert' ? 'insert' : 'update';
            var beforeResult = await SagEvents.beforeMovementOperation(
                operation,
                tableId,
                recordId ? parseInt(recordId) : null,
                fields
            );

            if (!beforeResult.canProceed) {
                console.log('[MovementManager] Operação bloqueada por evento:', beforeResult.reason);
                return; // Evento bloqueou a operação
            }
        }

        var url, method, body;

        if (mode === 'insert') {
            url = '/api/movement/' + tableId;
            method = 'POST';
            body = JSON.stringify({
                parentId: parentId,
                fields: fields
            });
        } else {
            url = '/api/movement/' + tableId + '/' + recordId;
            method = 'PUT';
            body = JSON.stringify({
                fields: fields
            });
        }

        // Desabilita botão enquanto salva
        var btnSave = document.getElementById('btnMovementSave');
        if (btnSave) {
            btnSave.disabled = true;
            btnSave.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Salvando...';
        }

        try {
            var response = await fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json' },
                body: body
            });

            var result = await response.json();

            if (result.success) {
                // Fecha modal
                if (state.modalInstance) {
                    state.modalInstance.hide();
                }

                // Recarrega grid
                loadMovementData(tableId);

                // Dispara eventos PLSAG após salvar
                if (window.SagEvents) {
                    var savedRecordId = mode === 'insert' ? result.recordId : parseInt(recordId);
                    await SagEvents.afterMovementOperation(
                        mode === 'insert' ? 'insert' : 'update',
                        tableId,
                        savedRecordId,
                        fields
                    );
                }
            } else {
                showError(result.message || 'Erro ao salvar registro');
            }
        } catch (error) {
            console.error('[MovementManager] Erro ao salvar:', error);
            showError('Erro ao salvar: ' + error.message);
        } finally {
            if (btnSave) {
                btnSave.disabled = false;
                btnSave.innerHTML = '<i class="bi bi-check-lg"></i> Confirmar';
            }
        }
    }

    /**
     * Abre confirmação de exclusão
     * @param {number} movementId - ID do movimento
     */
    function openDeleteConfirm(movementId) {
        var recordId = state.selectedRows[movementId];
        if (!recordId) {
            showError('Selecione um registro para excluir.');
            return;
        }

        document.getElementById('deleteModalTableId').value = movementId;
        document.getElementById('deleteModalRecordId').value = recordId;

        var metadata = state.movements[movementId];
        var info = document.getElementById('deleteModalInfo');
        if (info && metadata) {
            info.textContent = metadata.tabName + ' - Registro #' + recordId;
        }

        if (state.deleteModalInstance) {
            state.deleteModalInstance.show();
        }
    }

    /**
     * Confirma e executa a exclusão
     */
    async function confirmDelete() {
        var tableId = parseInt(document.getElementById('deleteModalTableId').value);
        var recordId = parseInt(document.getElementById('deleteModalRecordId').value);

        // Executa eventos PLSAG antes de excluir
        if (window.SagEvents) {
            var beforeResult = await SagEvents.beforeMovementOperation('delete', tableId, recordId, {});

            if (!beforeResult.canProceed) {
                console.log('[MovementManager] Exclusão bloqueada por evento:', beforeResult.reason);
                // Fecha modal de confirmação já que foi bloqueado
                if (state.deleteModalInstance) {
                    state.deleteModalInstance.hide();
                }
                return;
            }
        }

        var btnDelete = document.getElementById('btnMovementConfirmDelete');
        if (btnDelete) {
            btnDelete.disabled = true;
            btnDelete.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Excluindo...';
        }

        try {
            var response = await fetch('/api/movement/' + tableId + '/' + recordId, {
                method: 'DELETE'
            });

            var result = await response.json();

            if (result.success) {
                // Fecha modal
                if (state.deleteModalInstance) {
                    state.deleteModalInstance.hide();
                }

                // Limpa seleção
                state.selectedRows[tableId] = null;
                var btnGroup = document.getElementById('btn-group-' + tableId);
                if (btnGroup) {
                    btnGroup.querySelector('.btn-movement-edit').disabled = true;
                    btnGroup.querySelector('.btn-movement-delete').disabled = true;
                }

                // Recarrega grid
                loadMovementData(tableId);

                // Dispara eventos PLSAG após excluir
                if (window.SagEvents) {
                    await SagEvents.afterMovementOperation('delete', tableId, recordId, {});
                }
            } else {
                showError(result.message || 'Erro ao excluir registro');
            }
        } catch (error) {
            console.error('[MovementManager] Erro ao excluir:', error);
            showError('Erro ao excluir: ' + error.message);
        } finally {
            if (btnDelete) {
                btnDelete.disabled = false;
                btnDelete.innerHTML = '<i class="bi bi-trash"></i> Excluir';
            }
        }
    }

    /**
     * Exibe mensagem de erro
     * @param {string} message - Mensagem de erro
     */
    function showError(message) {
        alert(message); // TODO: Usar toast ou notificação mais elegante
    }

    /**
     * Atualiza o ID do registro pai (chamado após salvar o cabeçalho)
     * @param {number} newParentId - Novo ID do registro pai
     */
    function setParentRecordId(newParentId) {
        state.parentRecordId = newParentId;
        // Após definir o pai, carrega os movimentos
        if (newParentId) {
            loadAllMovements();
        }
    }

    /**
     * Obtém o ID do registro pai atual
     * @returns {number|null} ID do registro pai
     */
    function getParentRecordId() {
        return state.parentRecordId;
    }

    /**
     * Recarrega um movimento específico
     * @param {number} movementId - ID do movimento
     */
    function refreshMovement(movementId) {
        loadMovementData(movementId);
    }

    /**
     * Recarrega todos os movimentos
     */
    function refreshAll() {
        loadAllMovements();
    }

    /**
     * Sincroniza estado do cabeçalho com movimentos
     * Chamado quando o registro do cabeçalho muda (navegação, load, save)
     * @param {string} action - Tipo de ação: 'navigate', 'load', 'save', 'new', 'clear'
     * @param {object} headerData - Dados do cabeçalho (opcional)
     */
    function syncWithHeader(action, headerData) {
        console.log('[MovementManager] syncWithHeader:', action, headerData?.recordId || 'no record');

        switch (action) {
            case 'navigate':
            case 'load':
                // Registro do cabeçalho mudou - atualiza e recarrega movimentos
                if (headerData && headerData.recordId) {
                    if (state.parentRecordId !== headerData.recordId) {
                        state.parentRecordId = headerData.recordId;
                        // Limpa seleções anteriores
                        Object.keys(state.selectedRows).forEach(function(key) {
                            state.selectedRows[key] = null;
                        });
                        // Desabilita botões de editar/excluir
                        document.querySelectorAll('.btn-movement-edit, .btn-movement-delete').forEach(function(btn) {
                            btn.disabled = true;
                        });
                        // Recarrega movimentos
                        loadAllMovements();
                    }
                } else {
                    // Sem registro pai - limpa movimentos
                    clearAllMovements();
                }
                break;

            case 'save':
                // Após salvar cabeçalho - atualiza parentRecordId se era novo
                if (headerData && headerData.recordId && !state.parentRecordId) {
                    state.parentRecordId = headerData.recordId;
                    console.log('[MovementManager] Parent ID definido após save:', state.parentRecordId);
                    // Habilita área de movimentos (botões Novo)
                    document.querySelectorAll('.btn-movement-new').forEach(function(btn) {
                        btn.disabled = false;
                    });
                }
                break;

            case 'new':
            case 'clear':
                // Novo registro ou limpar - desabilita movimentos
                clearAllMovements();
                state.parentRecordId = null;
                // Desabilita todos os botões de movimento
                document.querySelectorAll('.movement-toolbar button').forEach(function(btn) {
                    btn.disabled = true;
                });
                break;

            default:
                console.warn('[MovementManager] Ação desconhecida:', action);
        }
    }

    /**
     * Limpa todos os grids de movimento
     */
    function clearAllMovements() {
        Object.keys(state.movements).forEach(function(movementId) {
            var tbody = document.getElementById('tbody-' + movementId);
            var metadata = state.movements[movementId];

            if (tbody && metadata) {
                var colCount = metadata.columns ? metadata.columns.length : 3;
                tbody.innerHTML = '<tr class="text-center text-muted empty-row">' +
                    '<td colspan="' + colCount + '">' +
                    '<div class="py-4">' +
                    '<i class="bi bi-inbox fs-2 d-block mb-2 text-secondary"></i>' +
                    '<span>Nenhum registro</span><br/>' +
                    '<small class="text-muted">Salve o cabeçalho para adicionar movimentos</small>' +
                    '</div></td></tr>';
            }

            // Limpa seleção
            state.selectedRows[movementId] = null;

            // Oculta paginação
            var pagination = document.getElementById('pagination-' + movementId);
            if (pagination) pagination.classList.add('d-none');

            // Oculta resumo
            var summary = document.getElementById('summary-' + movementId);
            if (summary) summary.style.display = 'none';
        });

        // Desabilita botões de editar/excluir
        document.querySelectorAll('.btn-movement-edit, .btn-movement-delete').forEach(function(btn) {
            btn.disabled = true;
        });
    }

    /**
     * Obtém estado atual
     * @returns {object} Estado do gerenciador
     */
    function getState() {
        return {
            parentTableId: state.parentTableId,
            parentRecordId: state.parentRecordId,
            movements: Object.keys(state.movements),
            selectedRows: { ...state.selectedRows }
        };
    }

    // API pública
    return {
        init: init,
        loadMovementData: loadMovementData,
        refreshMovement: refreshMovement,
        refreshAll: refreshAll,
        setParentRecordId: setParentRecordId,
        getParentRecordId: getParentRecordId,
        openNewMovement: openNewMovement,
        openEditMovement: openEditMovement,
        syncWithHeader: syncWithHeader,
        clearAllMovements: clearAllMovements,
        getState: getState
    };

})();
