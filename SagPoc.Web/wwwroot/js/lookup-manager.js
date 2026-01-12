/**
 * LookupManager - Gerenciador de Lookups Dinâmicos
 *
 * Gerencia o estado e recarga de lookups que suportam injeção dinâmica
 * de condições SQL via comando PLSAG QY-CAMPO-CONDIÇÃO.
 *
 * Comportamento Delphi:
 * - SQL_CAMP é estruturado como array de linhas (TStringList)
 * - Linha 3 contém "campo = 0" que desabilita a query por padrão
 * - Linha 4 é reservada para injeção dinâmica de filtro
 * - Comando QY-CAMPO-CONDIÇÃO injeta filtro na linha 4 e recarrega lookup
 */
const LookupManager = {
    // Cache de elementos lookup para acesso rápido
    _cache: new Map(),

    /**
     * Inicializa um lookup com SqlLines para suporte a injeção dinâmica.
     * Chamado durante renderização do formulário.
     *
     * @param {string} fieldName - Nome do campo (NOMECAMP)
     * @param {string[]} sqlLines - Array de linhas do SQL_CAMP
     * @param {number} codiCamp - ID do campo (CODICAMP)
     * @param {number} codiTabe - ID da tabela (CODITABE)
     */
    initializeLookup(fieldName, sqlLines, codiCamp, codiTabe) {
        // Busca elemento por data-field ou name
        const element = document.querySelector(`[data-field="${fieldName}"]`) ||
                       document.querySelector(`[name="${fieldName}"]`) ||
                       document.querySelector(`select[name="${fieldName}"]`);

        if (!element) {
            console.warn(`[LookupManager] Campo ${fieldName} não encontrado no DOM`);
            return;
        }

        // Armazena SqlLines e metadata no elemento
        element.dataset.sqlLines = JSON.stringify(sqlLines);
        element.dataset.codiCamp = codiCamp;
        element.dataset.codiTabe = codiTabe;
        element.dataset.loaded = 'false';
        element.dataset.dynamicLookup = 'true';

        // Adiciona ao cache
        this._cache.set(fieldName.toUpperCase(), element);

        console.log(`[LookupManager] Lookup ${fieldName} inicializado: ${sqlLines.length} linhas SQL, CodiCamp=${codiCamp}`);
    },

    /**
     * Recarrega lookup com condição dinâmica injetada.
     * Chamado pelo comando PLSAG QY-CAMPO-CONDIÇÃO.
     *
     * @param {string} fieldName - Nome do campo (ex: "CODIPROD")
     * @param {string} condition - Condição SQL (ex: "AND EXISTS(SELECT 1 FROM T)")
     * @param {Object} parameters - Parâmetros para substituição de placeholders
     * @returns {Promise<boolean>} - True se reload bem sucedido
     */
    async reloadLookup(fieldName, condition, parameters = {}) {
        const fieldNameUpper = fieldName.toUpperCase();

        // Busca elemento no cache ou DOM
        let element = this._cache.get(fieldNameUpper);
        if (!element) {
            element = document.querySelector(`[data-field="${fieldName}"]`) ||
                     document.querySelector(`[name="${fieldName}"]`) ||
                     document.querySelector(`select[name="${fieldName}"]`);
        }

        if (!element) {
            console.error(`[LookupManager] Campo ${fieldName} não encontrado`);
            return false;
        }

        // Obtém CodiCamp e CodiTabe do elemento
        const codiCamp = parseInt(element.dataset.codiCamp);
        const codiTabe = parseInt(element.dataset.codiTabe);

        if (!codiCamp) {
            console.error(`[LookupManager] CodiCamp não definido para ${fieldName}`);
            return false;
        }

        if (!codiTabe) {
            console.error(`[LookupManager] CodiTabe não definido para ${fieldName}`);
            return false;
        }

        try {
            console.log(`[LookupManager] Recarregando lookup ${fieldName}:`, {
                codiCamp,
                codiTabe,
                condition,
                parameters
            });

            // Mostra indicador de loading
            element.disabled = true;
            const originalText = element.options[0]?.text;
            if (element.options[0]) {
                element.options[0].text = 'Carregando...';
            }

            // Chama API de lookup dinâmico
            const response = await fetch('/api/plsag/execute-dynamic-lookup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    codiCamp: codiCamp,
                    codiTabe: codiTabe,
                    condition: condition,
                    parameters: parameters
                })
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                const errorMsg = errorData.error || `HTTP ${response.status}`;
                console.error(`[LookupManager] Erro ao recarregar ${fieldName}:`, errorMsg);

                // Restaura estado
                element.disabled = false;
                if (element.options[0] && originalText) {
                    element.options[0].text = originalText;
                }
                return false;
            }

            const result = await response.json();

            if (!result.success) {
                console.error(`[LookupManager] API retornou erro:`, result.error);
                element.disabled = false;
                if (element.options[0] && originalText) {
                    element.options[0].text = originalText;
                }
                return false;
            }

            // Atualiza options do select
            this._updateSelectOptions(element, result.data);
            element.dataset.loaded = 'true';
            element.disabled = false;

            console.log(`[LookupManager] Lookup ${fieldName} recarregado: ${result.data.length} itens`);

            // Dispara evento customizado
            element.dispatchEvent(new CustomEvent('lookupReloaded', {
                detail: { fieldName, items: result.data, condition }
            }));

            return true;
        } catch (error) {
            console.error(`[LookupManager] Exceção ao recarregar ${fieldName}:`, error);
            element.disabled = false;
            return false;
        }
    },

    /**
     * Atualiza options de um elemento select com novos itens.
     *
     * @param {HTMLSelectElement} selectElement
     * @param {Array<{key: string, value: string}>} items
     */
    _updateSelectOptions(selectElement, items) {
        // Guarda valor selecionado atual
        const currentValue = selectElement.value;

        // Limpa options (mantém primeira option vazia se existir)
        const firstOption = selectElement.options[0];
        const hasEmptyOption = firstOption && !firstOption.value;

        selectElement.innerHTML = '';

        // Restaura option vazia
        if (hasEmptyOption) {
            const emptyOption = document.createElement('option');
            emptyOption.value = '';
            emptyOption.textContent = '-- Selecione --';
            selectElement.appendChild(emptyOption);
        }

        // Adiciona novos items
        items.forEach(item => {
            const option = document.createElement('option');
            option.value = item.key;
            option.textContent = item.value;
            selectElement.appendChild(option);
        });

        // Tenta restaurar valor selecionado se ainda existir
        if (currentValue) {
            const optionExists = Array.from(selectElement.options).some(o => o.value === currentValue);
            if (optionExists) {
                selectElement.value = currentValue;
            }
        }
    },

    /**
     * Obtém estado atual de um lookup (para debug).
     *
     * @param {string} fieldName
     * @returns {Object|null}
     */
    getLookupState(fieldName) {
        const element = this._cache.get(fieldName.toUpperCase()) ||
                       document.querySelector(`[data-field="${fieldName}"]`) ||
                       document.querySelector(`[name="${fieldName}"]`);

        if (!element) {
            return null;
        }

        return {
            fieldName,
            codiCamp: element.dataset.codiCamp,
            codiTabe: element.dataset.codiTabe,
            loaded: element.dataset.loaded === 'true',
            isDynamic: element.dataset.dynamicLookup === 'true',
            optionsCount: element.options?.length || 0,
            currentValue: element.value,
            sqlLines: element.dataset.sqlLines ? JSON.parse(element.dataset.sqlLines) : null
        };
    },

    /**
     * Verifica se um lookup está carregado.
     *
     * @param {string} fieldName
     * @returns {boolean}
     */
    isLoaded(fieldName) {
        const state = this.getLookupState(fieldName);
        return state?.loaded === true;
    },

    /**
     * Limpa cache de elementos.
     */
    clearCache() {
        this._cache.clear();
    }
};

// Exporta globalmente
window.LookupManager = LookupManager;

// Log de inicialização
console.log('[LookupManager] Módulo carregado');
