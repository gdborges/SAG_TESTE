/**
 * ActionCellRenderer - Renderizador de celula para botoes de acao inline
 * Padrao Edata/Vision Design System
 *
 * Icones: Lucide Icons (FilePen, Trash2)
 * https://lucide.dev/
 *
 * Uso:
 * cellRenderer: ActionCellRenderer,
 * cellRendererParams: {
 *     onEdit: (data) => { ... },
 *     onDelete: (data) => { ... },
 *     showEdit: true,    // opcional, default true
 *     showDelete: true   // opcional, default true
 * }
 */

// Lucide Icons SVG paths
var LUCIDE_ICONS = {
    // FilePen icon - usado para Editar
    filePen: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12.5 22H18a2 2 0 0 0 2-2V7l-5-5H6a2 2 0 0 0-2 2v9.5"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M13.378 15.626a1 1 0 1 0-3.004-3.004l-5.01 5.012a2 2 0 0 0-.506.854l-.837 2.87a.5.5 0 0 0 .62.62l2.87-.837a2 2 0 0 0 .854-.506z"/></svg>',
    // Trash2 icon - usado para Excluir
    trash2: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/></svg>'
};

function ActionCellRenderer() {}

ActionCellRenderer.prototype.init = function(params) {
    this.params = params;
    this.eGui = document.createElement('div');
    this.eGui.className = 'action-buttons-cell';

    // Nao renderizar em linhas de grupo ou totais
    if (params.node.group || params.node.footer) {
        return;
    }

    // Botao Editar (se permitido)
    if (params.showEdit !== false) {
        var editBtn = document.createElement('button');
        editBtn.type = 'button';
        editBtn.className = 'action-btn action-btn-edit';
        editBtn.innerHTML = LUCIDE_ICONS.filePen;
        editBtn.title = 'Editar';
        editBtn.setAttribute('aria-label', 'Editar registro');
        editBtn.onclick = function(e) {
            e.stopPropagation();
            e.preventDefault();
            if (params.onEdit && typeof params.onEdit === 'function') {
                params.onEdit(params.data, params.node);
            }
        };
        this.eGui.appendChild(editBtn);
    }

    // Botao Excluir (se permitido)
    if (params.showDelete !== false) {
        var deleteBtn = document.createElement('button');
        deleteBtn.type = 'button';
        deleteBtn.className = 'action-btn action-btn-delete';
        deleteBtn.innerHTML = LUCIDE_ICONS.trash2;
        deleteBtn.title = 'Excluir';
        deleteBtn.setAttribute('aria-label', 'Excluir registro');
        deleteBtn.onclick = function(e) {
            e.stopPropagation();
            e.preventDefault();
            if (params.onDelete && typeof params.onDelete === 'function') {
                params.onDelete(params.data, params.node);
            }
        };
        this.eGui.appendChild(deleteBtn);
    }
};

ActionCellRenderer.prototype.getGui = function() {
    return this.eGui;
};

ActionCellRenderer.prototype.refresh = function(params) {
    // Retorna false para forcar re-render completo
    return false;
};

ActionCellRenderer.prototype.destroy = function() {
    // Cleanup se necessario
};
