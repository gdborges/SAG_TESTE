/**
 * ConsultaGrid - Gerenciador do grid de consulta com AG Grid Enterprise
 * Versão 2.0 - Migrado para AG Grid
 */
class ConsultaGrid {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            console.warn('Container not found:', containerId);
            return;
        }

        this.tableId = parseInt(this.container.dataset.tableId) || 0;
        this.consultaId = 0;
        this.columns = [];
        this.filters = [];
        this.page = 1;
        this.pageSize = 25;
        this.selectedId = null;
        this.selectedRow = null;
        this.sortField = null;
        this.sortDirection = 'ASC';

        // AG Grid references
        this.gridApi = null;
        this.gridElement = document.getElementById('consultaAgGrid');

        this.init();
    }

    init() {
        this.bindElements();
        this.bindEvents();
        this.initAgGrid();
        this.loadInitialData();
    }

    bindElements() {
        this.consultaSelect = document.getElementById('consultaSelect');
        this.filterField = document.getElementById('filterField');
        this.filterCondition = document.getElementById('filterCondition');
        this.filterValue = document.getElementById('filterValue');
        this.btnAddFilter = document.getElementById('btnAddFilter');
        this.btnClearFilters = document.getElementById('btnClearFilters');
        this.btnRefresh = document.getElementById('btnRefresh');
        this.activeFilters = document.getElementById('activeFilters');
        this.filterBadge = document.getElementById('filterBadge');
        this.btnIncluir = document.getElementById('btnIncluir');
        this.btnAlterar = document.getElementById('btnAlterar');
        this.btnExcluir = document.getElementById('btnExcluir');
    }

    initAgGrid() {
        if (!this.gridElement || typeof agGrid === 'undefined') {
            console.error('AG Grid not available');
            return;
        }

        const gridOptions = {
            // Configurações básicas
            rowSelection: 'single',
            animateRows: true,
            enableCellTextSelection: true,
            suppressCopyRowsToClipboard: true,

            // Paginação
            pagination: true,
            paginationPageSize: this.pageSize,
            paginationPageSizeSelector: [10, 25, 50, 100],

            // === ENTERPRISE FEATURES (igual ao Vision) ===
            // Menu de coluna moderno
            columnMenu: 'new',

            // Painel lateral de colunas (direita)
            sideBar: {
                toolPanels: [
                    {
                        id: 'columns',
                        labelDefault: 'Colunas',
                        labelKey: 'columns',
                        iconKey: 'columns',
                        toolPanel: 'agColumnsToolPanel',
                        toolPanelParams: {
                            suppressRowGroups: false,
                            suppressValues: true,
                            suppressPivots: true,
                            suppressPivotMode: true,
                        }
                    }
                ],
                defaultToolPanel: '', // Começa fechado
            },

            // Barra de agrupamento de linhas (topo)
            rowGroupPanelShow: 'always',

            // Permitir arrastar colunas para agrupar
            suppressDragLeaveHidesColumns: true,

            // Overlay de loading
            overlayLoadingTemplate: '<div class="ag-overlay-loading-center"><div class="spinner-border spinner-border-sm me-2"></div> Carregando...</div>',
            overlayNoRowsTemplate: '<div class="ag-overlay-no-rows-center">Nenhum registro encontrado</div>',

            // Callbacks de eventos
            onRowSelected: (event) => this.onRowSelected(event),
            onRowDoubleClicked: (event) => this.onRowDoubleClicked(event),
            onSortChanged: (event) => this.onSortChanged(event),
            onPaginationChanged: (event) => this.onPaginationChanged(event),
            onGridReady: (event) => this.onGridReady(event),

            // Definição de colunas (será atualizada dinamicamente)
            columnDefs: [],
            rowData: [],

            // Default column definition (igual ao Vision)
            defaultColDef: {
                sortable: true,
                resizable: true,
                filter: true, // Habilita filtro nas colunas
                floatingFilter: false, // Sem filtro flutuante
                minWidth: 80,
                // Menu de coluna com todas as opções
                menuTabs: ['filterMenuTab', 'generalMenuTab', 'columnsMenuTab'],
            },

            // Identificador de linha
            getRowId: (params) => {
                // Tenta encontrar o ID do registro
                const keys = Object.keys(params.data);
                const idKey = keys.find(k => k.toLowerCase().startsWith('codi')) || keys[0];
                return String(params.data[idKey] ?? params.node.rowIndex);
            },
        };

        // Cria o grid
        this.gridApi = agGrid.createGrid(this.gridElement, gridOptions);
    }

    onGridReady(event) {
        console.log('[AG Grid] Grid ready');
    }

    onRowSelected(event) {
        if (event.node.isSelected()) {
            const data = event.data;
            const keys = Object.keys(data);
            const idKey = keys.find(k => k.toLowerCase().startsWith('codi')) || keys[0];
            this.selectedId = data[idKey];
            this.selectedRow = data;
            this.updateCrudButtons();
        }
    }

    onRowDoubleClicked(event) {
        if (this.selectedId) {
            this.alterar();
        }
    }

    onSortChanged(event) {
        const sortModel = this.gridApi.getColumnState()
            .filter(col => col.sort)
            .map(col => ({ colId: col.colId, sort: col.sort }));

        if (sortModel.length > 0) {
            this.sortField = sortModel[0].colId;
            this.sortDirection = sortModel[0].sort.toUpperCase();
        } else {
            this.sortField = null;
            this.sortDirection = 'ASC';
        }
    }

    onPaginationChanged(event) {
        // AG Grid native pagination handles display
    }

    bindEvents() {
        // Mudanca de consulta
        this.consultaSelect?.addEventListener('change', () => this.onConsultaChange());

        // Filtros
        this.btnAddFilter?.addEventListener('click', () => this.addFilter());
        this.btnClearFilters?.addEventListener('click', () => this.clearFilters());
        this.filterValue?.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addFilter();
        });

        // Refresh
        this.btnRefresh?.addEventListener('click', () => this.loadData());

        // CRUD
        this.btnIncluir?.addEventListener('click', () => this.incluir());
        this.btnAlterar?.addEventListener('click', () => this.alterar());
        this.btnExcluir?.addEventListener('click', () => this.excluir());
    }

    async loadInitialData() {
        if (this.consultaSelect && this.consultaSelect.options.length > 0) {
            this.consultaId = parseInt(this.consultaSelect.value) || 0;
            await this.loadConsultaColumns();
            await this.loadData();
        }
    }

    async onConsultaChange() {
        this.consultaId = parseInt(this.consultaSelect.value) || 0;
        this.page = 1;
        this.filters = [];
        this.selectedId = null;
        this.selectedRow = null;
        this.updateCrudButtons();
        this.renderActiveFilters();
        this.updateFilterBadge();
        await this.loadConsultaColumns();
        await this.loadData();
    }

    async loadConsultaColumns() {
        try {
            const response = await fetch(`/Form/GetConsultas?tableId=${this.tableId}`);
            const consultas = await response.json();
            const current = consultas.find(c => c.codiCons === this.consultaId);

            if (current && current.columns) {
                this.columns = current.columns;
                this.updateFilterFieldOptions();
                this.updateAgGridColumns();
            }
        } catch (error) {
            console.error('Erro ao carregar colunas:', error);
        }
    }

    updateAgGridColumns() {
        if (!this.gridApi || !this.columns.length) return;

        const columnDefs = this.columns.map((col, index) => ({
            field: col.fieldName || col.displayName,
            headerName: col.displayName,
            width: col.width || 120,
            sortable: true,
            resizable: true,
            // Formata valores
            valueFormatter: (params) => this.formatCellValue(params.value),
        }));

        this.gridApi.setGridOption('columnDefs', columnDefs);
    }

    formatCellValue(value) {
        if (value === null || value === undefined) return '';
        if (typeof value === 'boolean') return value ? 'S' : 'N';
        return String(value);
    }

    updateFilterFieldOptions() {
        if (!this.filterField) return;

        this.filterField.innerHTML = '<option value="">-- Campo --</option>';
        this.columns.forEach(col => {
            const option = document.createElement('option');
            option.value = col.displayName;
            option.textContent = col.displayName;
            this.filterField.appendChild(option);
        });
    }

    addFilter() {
        const field = this.filterField?.value;
        const condition = this.filterCondition?.value;
        const value = this.filterValue?.value?.trim();

        if (!field || !value) {
            return;
        }

        // Adiciona filtro
        this.filters.push({ field, condition, value });

        // Limpa input
        this.filterValue.value = '';

        // Atualiza UI
        this.renderActiveFilters();
        this.updateFilterBadge();
        this.page = 1;
        this.loadData();
    }

    removeFilter(index) {
        this.filters.splice(index, 1);
        this.renderActiveFilters();
        this.updateFilterBadge();
        this.page = 1;
        this.loadData();
    }

    clearFilters() {
        this.filters = [];
        if (this.filterValue) this.filterValue.value = '';
        this.renderActiveFilters();
        this.updateFilterBadge();
        this.page = 1;
        this.loadData();
    }

    renderActiveFilters() {
        if (!this.activeFilters) return;

        if (this.filters.length === 0) {
            this.activeFilters.innerHTML = '';
            return;
        }

        const conditionNames = {
            'startswith': 'iniciado por',
            'contains': 'contém',
            'equals': 'igual a',
            'notequals': 'diferente de'
        };

        this.activeFilters.innerHTML = this.filters.map((f, i) => `
            <span class="badge bg-primary me-1 filter-tag">
                ${f.field} ${conditionNames[f.condition] || f.condition} "${f.value}"
                <button type="button" class="btn-close btn-close-white ms-1"
                        style="font-size: 0.6rem;"
                        onclick="window.consultaGrid.removeFilter(${i})"></button>
            </span>
        `).join('');
    }

    async loadData() {
        if (!this.consultaId) return;
        if (!this.gridApi) {
            console.warn('AG Grid not initialized');
            return;
        }

        try {
            this.gridApi.showLoadingOverlay();

            const response = await fetch('/Form/ExecuteConsulta', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    tableId: this.tableId,
                    consultaId: this.consultaId,
                    filters: this.filters,
                    sortField: this.sortField,
                    sortDirection: this.sortDirection,
                    page: 1,
                    pageSize: 10000 // Carrega todos e deixa AG Grid paginar
                })
            });

            const result = await response.json();

            if (result.columns && result.columns.length > 0) {
                this.columns = result.columns;
                this.updateFilterFieldOptions();
                this.updateAgGridColumns();
            }

            // Atualiza dados do grid
            if (result.data && result.data.length > 0) {
                this.gridApi.setGridOption('rowData', result.data);

                // Auto-dimensiona colunas pelo conteúdo (igual Vision)
                setTimeout(() => {
                    this.gridApi.autoSizeAllColumns();
                }, 100);
            } else {
                this.gridApi.setGridOption('rowData', []);
                this.gridApi.showNoRowsOverlay();
            }

            // Limpa seleção
            this.selectedId = null;
            this.selectedRow = null;
            this.updateCrudButtons();

        } catch (error) {
            console.error('Erro ao carregar dados:', error);
            this.gridApi.showNoRowsOverlay();
        }
    }

    updateFilterBadge() {
        if (!this.filterBadge) return;
        const count = this.filters.length;
        this.filterBadge.textContent = count;
        this.filterBadge.style.display = count > 0 ? 'inline' : 'none';
    }

    updateCrudButtons() {
        const hasSelection = this.selectedId != null;
        if (this.btnAlterar) this.btnAlterar.disabled = !hasSelection;
        if (this.btnExcluir) this.btnExcluir.disabled = !hasSelection;
    }

    // CRUD Operations
    async incluir() {
        // Usa Saga Pattern: cria registro vazio no banco imediatamente
        if (typeof startNewRecord === 'function') {
            console.log('[ConsultaGrid] Iniciando novo registro via Saga Pattern');
            await startNewRecord();
        } else {
            // Fallback para comportamento antigo
            console.warn('[ConsultaGrid] startNewRecord não disponível, usando fallback');
            const form = document.getElementById('dynamicForm');
            if (form) form.reset();

            const editingId = document.getElementById('editingRecordId');
            if (editingId) editingId.value = '';

            document.getElementById('tab-dados-tab')?.click();
        }
    }

    async alterar() {
        if (!this.selectedId) return;

        try {
            const response = await fetch(`/Form/GetRecord?tableId=${this.tableId}&recordId=${this.selectedId}`);
            if (!response.ok) {
                throw new Error('Registro nao encontrado');
            }

            const record = await response.json();

            // Preenche formulario
            this.fillForm(record);

            // Define ID de edicao
            const editingId = document.getElementById('editingRecordId');
            if (editingId) editingId.value = this.selectedId;

            // Atualiza formState
            if (window.formState) {
                window.formState.recordId = this.selectedId;
                window.formState.isNewRecord = false;
                window.formState.isDirty = false;
            }

            // Sincroniza MovementManager
            if (window.MovementManager) {
                MovementManager.syncWithHeader('load', { recordId: this.selectedId });
            }

            // Ativa tab de dados
            document.getElementById('tab-dados-tab')?.click();

            // Habilita modo de edição
            if (typeof enableEditMode === 'function') {
                enableEditMode();
            }

            // Executa eventos de campo
            if (typeof SagEvents !== 'undefined' && SagEvents.onRecordLoaded) {
                await SagEvents.onRecordLoaded();
            }

        } catch (error) {
            console.error('Erro ao carregar registro:', error);
            alert('Erro ao carregar registro para edicao');
        }
    }

    fillForm(record) {
        const form = document.getElementById('dynamicForm');
        if (!form) return;

        for (const [key, value] of Object.entries(record)) {
            const input = form.querySelector(`[name="${key}"], [name="${key.toUpperCase()}"], [name="${key.toLowerCase()}"]`);
            if (input) {
                if (input.type === 'checkbox') {
                    input.checked = value === 1 || value === true || value === 'S';
                } else if (input.tagName === 'SELECT') {
                    const strValue = String(value ?? '');
                    let found = false;

                    for (const option of input.options) {
                        if (option.value === strValue || option.value.toUpperCase() === strValue.toUpperCase()) {
                            input.value = option.value;
                            found = true;
                            break;
                        }
                    }

                    if (!found) {
                        input.value = strValue;
                    }
                } else if (input.type === 'date') {
                    if (value) {
                        const dateStr = String(value);
                        const datePart = dateStr.substring(0, 10);
                        input.value = datePart;
                    } else {
                        input.value = '';
                    }
                } else {
                    input.value = value ?? '';
                }
            }
        }
    }

    async excluir() {
        if (!this.selectedId) return;

        if (!confirm('Deseja realmente excluir este registro?')) {
            return;
        }

        try {
            const response = await fetch(`/Form/DeleteRecord?tableId=${this.tableId}&recordId=${this.selectedId}`, {
                method: 'DELETE'
            });

            const result = await response.json();

            if (result.success) {
                alert(result.message);
                this.selectedId = null;
                this.selectedRow = null;
                this.updateCrudButtons();
                this.loadData();
            } else {
                alert('Erro: ' + result.message);
            }

        } catch (error) {
            console.error('Erro ao excluir:', error);
            alert('Erro ao excluir registro');
        }
    }

    // Método público para refresh (usado por SagEvents)
    refresh() {
        this.loadData();
    }
}

// Inicializa quando DOM estiver pronto
document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('consultaContainer');
    if (container) {
        // Aguarda um tick para garantir que AG Grid está carregado
        setTimeout(() => {
            window.consultaGrid = new ConsultaGrid('consultaContainer');
        }, 100);
    }
});
