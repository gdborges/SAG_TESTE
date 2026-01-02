/**
 * ConsultaGrid - Gerenciador do grid de consulta
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
        this.pageSize = 20;
        this.selectedId = null;
        this.sortField = null;
        this.sortDirection = 'ASC';

        this.init();
    }

    init() {
        this.bindElements();
        this.bindEvents();
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
        this.gridHeader = document.getElementById('gridHeader');
        this.gridBody = document.getElementById('gridBody');
        this.gridInfo = document.getElementById('gridInfo');
        this.gridPagination = document.getElementById('gridPagination');
        this.btnIncluir = document.getElementById('btnIncluir');
        this.btnAlterar = document.getElementById('btnAlterar');
        this.btnExcluir = document.getElementById('btnExcluir');
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
        this.updateCrudButtons();
        this.renderActiveFilters();
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
            }
        } catch (error) {
            console.error('Erro ao carregar colunas:', error);
        }
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
        this.page = 1;
        this.loadData();
    }

    removeFilter(index) {
        this.filters.splice(index, 1);
        this.renderActiveFilters();
        this.page = 1;
        this.loadData();
    }

    clearFilters() {
        this.filters = [];
        this.filterValue.value = '';
        this.renderActiveFilters();
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

        try {
            this.showLoading();

            const response = await fetch('/Form/ExecuteConsulta', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    tableId: this.tableId,
                    consultaId: this.consultaId,
                    filters: this.filters,
                    sortField: this.sortField,
                    sortDirection: this.sortDirection,
                    page: this.page,
                    pageSize: this.pageSize
                })
            });

            const result = await response.json();

            if (result.columns && result.columns.length > 0) {
                this.columns = result.columns;
                this.updateFilterFieldOptions();
            }

            this.renderHeader();
            this.renderData(result.data);
            this.renderPagination(result);
            this.updateGridInfo(result);

        } catch (error) {
            console.error('Erro ao carregar dados:', error);
            this.showError('Erro ao carregar dados');
        }
    }

    showLoading() {
        if (this.gridBody) {
            this.gridBody.innerHTML = `
                <tr>
                    <td colspan="${this.columns.length || 10}" class="text-center py-4">
                        <div class="spinner-border spinner-border-sm" role="status"></div>
                        <span class="ms-2">Carregando...</span>
                    </td>
                </tr>
            `;
        }
    }

    showError(message) {
        if (this.gridBody) {
            this.gridBody.innerHTML = `
                <tr>
                    <td colspan="${this.columns.length || 10}" class="text-center text-danger py-4">
                        <i class="bi bi-exclamation-triangle"></i> ${message}
                    </td>
                </tr>
            `;
        }
    }

    renderHeader() {
        if (!this.gridHeader) return;

        this.gridHeader.innerHTML = this.columns.map(col => `
            <th style="width: ${col.width}px; cursor: pointer;"
                onclick="window.consultaGrid.sortBy('${col.displayName}')">
                ${col.displayName}
                ${this.getSortIcon(col.displayName)}
            </th>
        `).join('');
    }

    getSortIcon(field) {
        if (this.sortField !== field) return '';
        return this.sortDirection === 'ASC'
            ? '<i class="bi bi-sort-up"></i>'
            : '<i class="bi bi-sort-down"></i>';
    }

    sortBy(field) {
        if (this.sortField === field) {
            this.sortDirection = this.sortDirection === 'ASC' ? 'DESC' : 'ASC';
        } else {
            this.sortField = field;
            this.sortDirection = 'ASC';
        }
        this.loadData();
    }

    renderData(data) {
        if (!this.gridBody) return;

        if (!data || data.length === 0) {
            this.gridBody.innerHTML = `
                <tr>
                    <td colspan="${this.columns.length}" class="text-center text-muted py-4">
                        Nenhum registro encontrado
                    </td>
                </tr>
            `;
            return;
        }

        this.gridBody.innerHTML = data.map((row, index) => {
            // Tenta encontrar o ID do registro (primeiro campo ou campo CODI*)
            const keys = Object.keys(row);
            const idKey = keys.find(k => k.toLowerCase().startsWith('codi')) || keys[0];
            const recordId = row[idKey];

            const cells = this.columns.map(col => {
                const value = row[col.displayName] ?? row[col.fieldName] ?? '';
                return `<td>${this.formatValue(value)}</td>`;
            }).join('');

            return `
                <tr data-id="${recordId}"
                    onclick="window.consultaGrid.selectRow(${recordId}, this)"
                    ondblclick="window.consultaGrid.alterar()"
                    class="${this.selectedId === recordId ? 'table-primary' : ''}">
                    ${cells}
                </tr>
            `;
        }).join('');
    }

    formatValue(value) {
        if (value === null || value === undefined) return '';
        if (typeof value === 'boolean') return value ? 'S' : 'N';
        return String(value);
    }

    selectRow(id, row) {
        // Remove selecao anterior
        this.gridBody.querySelectorAll('tr').forEach(tr => tr.classList.remove('table-primary'));

        // Seleciona nova linha
        row.classList.add('table-primary');
        this.selectedId = id;

        this.updateCrudButtons();
    }

    updateCrudButtons() {
        const hasSelection = this.selectedId != null;
        if (this.btnAlterar) this.btnAlterar.disabled = !hasSelection;
        if (this.btnExcluir) this.btnExcluir.disabled = !hasSelection;
    }

    renderPagination(result) {
        if (!this.gridPagination) return;

        const { currentPage, totalPages } = result;

        if (totalPages <= 1) {
            this.gridPagination.innerHTML = '';
            return;
        }

        let html = '';

        // Anterior
        html += `
            <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                <a class="page-link" href="#" onclick="window.consultaGrid.goToPage(${currentPage - 1}); return false;">
                    &laquo;
                </a>
            </li>
        `;

        // Paginas
        const startPage = Math.max(1, currentPage - 2);
        const endPage = Math.min(totalPages, currentPage + 2);

        for (let i = startPage; i <= endPage; i++) {
            html += `
                <li class="page-item ${i === currentPage ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="window.consultaGrid.goToPage(${i}); return false;">${i}</a>
                </li>
            `;
        }

        // Proximo
        html += `
            <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                <a class="page-link" href="#" onclick="window.consultaGrid.goToPage(${currentPage + 1}); return false;">
                    &raquo;
                </a>
            </li>
        `;

        this.gridPagination.innerHTML = html;
    }

    goToPage(page) {
        this.page = page;
        this.loadData();
    }

    updateGridInfo(result) {
        if (!this.gridInfo) return;

        const start = (result.currentPage - 1) * result.pageSize + 1;
        const end = Math.min(result.currentPage * result.pageSize, result.totalRecords);

        this.gridInfo.textContent = result.totalRecords > 0
            ? `Mostrando ${start} a ${end} de ${result.totalRecords} registros`
            : 'Nenhum registro encontrado';
    }

    // CRUD Operations
    async incluir() {
        // Usa Saga Pattern: cria registro vazio no banco imediatamente
        // Isso permite que movimentos sejam adicionados antes do save final
        if (typeof startNewRecord === 'function') {
            console.log('[ConsultaGrid] Iniciando novo registro via Saga Pattern');
            await startNewRecord();
        } else {
            // Fallback para comportamento antigo (sem Saga)
            console.warn('[ConsultaGrid] startNewRecord não disponível, usando fallback');

            // Limpa formulario
            const form = document.getElementById('dynamicForm');
            if (form) form.reset();

            // Limpa ID de edicao
            const editingId = document.getElementById('editingRecordId');
            if (editingId) editingId.value = '';

            // Ativa tab de dados
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

            // Atualiza formState para refletir modo de edição (não é novo registro)
            if (window.formState) {
                window.formState.recordId = this.selectedId;
                window.formState.isNewRecord = false;
                window.formState.isDirty = false;
            }

            // Sincroniza MovementManager com o registro sendo editado
            if (window.MovementManager) {
                MovementManager.syncWithHeader('load', { recordId: this.selectedId });
            }

            // Ativa tab de dados
            document.getElementById('tab-dados-tab')?.click();

            // IMPORTANTE: Executa eventos de campo para aplicar regras de visibilidade/habilitação
            // Similar ao comportamento do Delphi ao carregar um registro
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

        console.log('fillForm record:', record);

        for (const [key, value] of Object.entries(record)) {
            // Tenta encontrar o campo pelo nome (case insensitive)
            const input = form.querySelector(`[name="${key}"], [name="${key.toUpperCase()}"], [name="${key.toLowerCase()}"]`);
            if (input) {
                console.log(`Setting ${key} = ${value}, input type: ${input.type}, tagName: ${input.tagName}`);

                if (input.type === 'checkbox') {
                    input.checked = value === 1 || value === true || value === 'S';
                } else if (input.tagName === 'SELECT') {
                    // Para selects, tenta encontrar a option pelo value
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
                        console.warn(`Option not found for ${key} = ${strValue}`);
                        input.value = strValue;
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
}

// Inicializa quando DOM estiver pronto
document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('consultaContainer');
    if (container) {
        window.consultaGrid = new ConsultaGrid('consultaContainer');
    }
});
