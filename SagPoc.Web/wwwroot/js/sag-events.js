/**
 * SAG Events - Sistema de Eventos PLSAG para POC Web
 *
 * Este módulo captura eventos DOM e prepara para execução futura
 * das instruções PLSAG. Na Fase 1, apenas loga os eventos capturados.
 *
 * Uso:
 *   SagEvents.init(formEventsJson, fieldEventsJson);
 */
const SagEvents = (function () {
    'use strict';

    // Configuração
    let formEvents = null;
    let fieldEvents = {};
    let movementEvents = {}; // Eventos de movimento indexados por CodiTabe
    let movementFieldEvents = {}; // Eventos de CAMPO de movimento indexados por CodiTabe
    let initialized = false;

    // Cache de elementos
    const boundElements = new Set();

    // Flag para saber se é INSERT (novo registro) ou EDIT (alteração)
    let isInsertMode = false;

    // Contexto de movimento ativo (para templates DM/D2)
    let activeMovementContext = null;

    /**
     * Inicializa o sistema de eventos PLSAG.
     * @param {Object} formEventsData - Eventos do formulário (ciclo de vida)
     * @param {Object} fieldEventsData - Eventos dos campos (indexado por CodiCamp)
     * @param {boolean} isInsert - Se é modo INSERT (novo registro)
     */
    async function init(formEventsData, fieldEventsData, isInsert = false) {
        if (initialized) {
            console.warn('[SagEvents] Já inicializado');
            return;
        }

        formEvents = formEventsData || {};
        fieldEvents = fieldEventsData || {};
        isInsertMode = isInsert;
        initialized = true;

        console.log('[SagEvents] Inicializando sistema de eventos PLSAG');
        console.log('[SagEvents] Form Events:', formEvents);
        console.log('[SagEvents] Field Events:', Object.keys(fieldEvents).length, 'campos');
        console.log('[SagEvents] Modo:', isInsertMode ? 'INSERT' : 'EDIT');

        // Bind nos campos existentes
        bindAllFields();

        // Bind nos botões de lookup existentes
        bindLookupButtons();

        // Bind nos botões SAG (BTN) com ExprCamp
        bindSagButtons();

        // Observa novos campos adicionados dinamicamente
        observeDom();

        // Dispara evento AnteCria (antes de criar campos)
        if (formEvents.antecriaInstructions) {
            fireFormEvent('AnteCria', formEvents.antecriaInstructions);
        }

        // Dispara evento DepoCria (depois de criar campos)
        if (formEvents.depocriaInstructions) {
            fireFormEvent('DepoCria', formEvents.depocriaInstructions);
        }

        // IMPORTANTE: Inicializa valores padrão dos campos (somente em INSERT)
        // Similar ao InicValoCampPers do Delphi
        if (isInsertMode) {
            initDefaultValues();
        }

        // IMPORTANTE: Executa eventos Exit de todos os campos no Show
        // Similar ao CampPersExecExitShow do Delphi
        // Isso configura visibilidade/habilitação inicial dos campos
        await execFieldEventsOnShow();

        // Dispara evento ShowTabe (formulário exibido)
        if (formEvents.showTabeInstructions) {
            fireFormEvent('ShowTabe', formEvents.showTabeInstructions);
        }

        // Dispara evento DepoShow (após ShowTabe)
        if (formEvents.depoShowInstructions) {
            fireFormEvent('DepoShow', formEvents.depoShowInstructions);
        }

        console.log('[SagEvents] Inicialização concluída');
    }

    /**
     * Inicializa valores padrão dos campos (InicValoCampPers do Delphi).
     * Executado apenas em modo INSERT (novo registro).
     *
     * Regras:
     * - InicCamp = 1: campo deve ser inicializado
     * - DefaultText (VaGrCamp): valor padrão para texto
     * - DefaultNumber (PadrCamp): valor padrão para números
     */
    function initDefaultValues() {
        console.log('[SagEvents] Inicializando valores padrão (InicValoCampPers)');

        // Tipos que não recebem valores padrão
        const excludedTypes = ['LN', 'LE', 'BVL', 'IN', 'IE', 'IM', 'IR', 'LBL', 'BTN', 'DBG', 'GRA', 'FE', 'FI', 'FF', 'LC', 'TIM'];

        let initializedCount = 0;

        for (const [codiCamp, eventData] of Object.entries(fieldEvents)) {
            // Pula campos que não devem ser inicializados
            if (eventData.inicCamp !== 1) {
                continue;
            }

            const compType = (eventData.compCamp || 'E').toUpperCase();

            // Pula tipos excluídos
            if (excludedTypes.includes(compType)) {
                continue;
            }

            // Encontra o elemento do campo
            const element = document.querySelector(`[data-sag-codicamp="${codiCamp}"]`);
            if (!element) continue;

            // Determina o valor padrão baseado no tipo
            let defaultValue = null;

            // Tipos texto: usa DefaultText (VaGrCamp)
            if (['E', 'A', 'M', 'BM', 'BS', 'BE', 'BI', 'BP', 'BX', 'RS', 'RE', 'RI', 'RP', 'RX'].includes(compType)) {
                if (eventData.defaultText) {
                    defaultValue = eventData.defaultText;
                }
            }
            // Tipos numérico: usa DefaultNumber (PadrCamp)
            else if (compType === 'N') {
                if (eventData.defaultNumber !== null && eventData.defaultNumber !== undefined) {
                    defaultValue = eventData.defaultNumber.toString();
                }
            }
            // Checkbox: usa DefaultNumber (1 = checked)
            else if (compType === 'S' || compType === 'ES') {
                if (eventData.defaultNumber !== null && eventData.defaultNumber !== undefined) {
                    if (element.type === 'checkbox') {
                        element.checked = eventData.defaultNumber !== 0;
                        initializedCount++;
                        continue;
                    }
                }
            }
            // Combo: usa primeiro valor de DefaultText
            else if (compType === 'C') {
                if (eventData.defaultText) {
                    const parts = eventData.defaultText.split(/[|\n\r]+/);
                    if (parts.length > 0) {
                        defaultValue = parts[0].trim();
                    }
                }
            }

            // Aplica valor padrão
            if (defaultValue !== null) {
                element.value = defaultValue;
                initializedCount++;
                console.log(`[SagEvents] Campo ${eventData.nomeCamp}: valor padrão = "${defaultValue}"`);
            }
        }

        // Marca campos sequenciais
        for (const [codiCamp, eventData] of Object.entries(fieldEvents)) {
            if (eventData.isSequential) {
                const element = document.querySelector(`[data-sag-codicamp="${codiCamp}"]`);
                if (element) {
                    element.placeholder = '(Automático)';
                    element.readOnly = true;
                    element.classList.add('field-sequential');
                    console.log(`[SagEvents] Campo ${eventData.nomeCamp}: sequencial (gerado no save)`);
                }
            }
        }

        console.log(`[SagEvents] InicValoCampPers: ${initializedCount} campos inicializados`);
    }

    /**
     * Faz bind em todos os campos com data-sag-codicamp.
     */
    function bindAllFields() {
        const fields = document.querySelectorAll('[data-sag-codicamp]');
        fields.forEach(bindField);
        console.log('[SagEvents] Campos vinculados:', fields.length);
    }

    /**
     * Inicializa os botões de lookup (pesquisa) em um container.
     * @param {HTMLElement} container - Container onde buscar os botões (default: document)
     */
    function bindLookupButtons(container = document) {
        const buttons = container.querySelectorAll('.btn-lookup');
        let count = 0;

        buttons.forEach(btn => {
            // Evita duplo bind
            if (btn.dataset.lookupBound) return;
            btn.dataset.lookupBound = 'true';

            btn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();

                // Encontra o input associado dentro do input-group
                const inputGroup = this.closest('.input-group');
                const input = inputGroup?.querySelector('input[data-sag-codicamp]');

                if (input) {
                    const codicamp = input.dataset.sagCodicamp;
                    if (codicamp) {
                        console.log('[SagEvents] Lookup button clicked, codicamp:', codicamp);
                        openLookup(codicamp);
                    } else {
                        console.warn('[SagEvents] Input sem data-sag-codicamp');
                    }
                } else {
                    console.warn('[SagEvents] Botão lookup sem input associado');
                }
            });
            count++;
        });

        if (count > 0) {
            console.log('[SagEvents] Botões de lookup vinculados:', count);
        }
    }

    /**
     * Inicializa os botões SAG (BTN) com instruções PLSAG no ExprCamp.
     * No Delphi, ExprCamp contém as instruções a executar no OnClick do botão.
     * @param {HTMLElement} container - Container onde buscar os botões (default: document)
     */
    function bindSagButtons(container = document) {
        const buttons = container.querySelectorAll('.sag-btn[data-plsag-onclick]');
        let count = 0;

        buttons.forEach(btn => {
            // Evita duplo bind
            if (btn.dataset.sagBtnBound) return;
            btn.dataset.sagBtnBound = 'true';

            btn.addEventListener('click', async function(e) {
                e.preventDefault();

                const instructions = this.dataset.plsagOnclick;
                const codicamp = this.dataset.sagCodicamp;
                const namecamp = this.dataset.sagNamecamp || this.dataset.sagNomecamp;

                if (!instructions) {
                    console.warn('[SagEvents] Botão sem instruções PLSAG:', namecamp);
                    return;
                }

                console.log(`[SagEvents] Botão ${namecamp} clicado, executando ExprCamp:`, instructions.substring(0, 100));

                try {
                    // Executa as instruções PLSAG
                    if (window.PlsagInterpreter) {
                        const result = await window.PlsagInterpreter.execute(instructions);
                        console.log(`[SagEvents] Botão ${namecamp} resultado:`, result);
                    } else {
                        console.error('[SagEvents] PlsagInterpreter não disponível');
                    }
                } catch (error) {
                    console.error(`[SagEvents] Erro ao executar ExprCamp do botão ${namecamp}:`, error);
                }
            });
            count++;
        });

        if (count > 0) {
            console.log('[SagEvents] Botões SAG vinculados:', count);
        }
    }

    /**
     * Faz bind em um campo específico.
     * @param {HTMLElement} element - Elemento do campo
     */
    function bindField(element) {
        if (boundElements.has(element)) {
            return; // Já vinculado
        }

        const codiCamp = element.dataset.sagCodicamp;
        if (!codiCamp) return;

        const eventData = fieldEvents[codiCamp];
        if (!eventData || !eventData.hasEvents) {
            return; // Campo sem eventos
        }

        const compType = element.dataset.sagComptype || 'E';
        const fieldName = element.dataset.sagNomecamp || codiCamp;

        // Bind baseado no tipo de componente
        if (eventData.onExitInstructions) {
            // OnExit -> blur/change
            element.addEventListener('blur', (e) => {
                fireFieldEvent('OnExit', fieldName, codiCamp, eventData.onExitInstructions, e);
            });

            // Para selects, também bind no change
            if (element.tagName === 'SELECT') {
                element.addEventListener('change', (e) => {
                    fireFieldEvent('OnChange', fieldName, codiCamp, eventData.onExitInstructions, e);
                });
            }
        }

        if (eventData.onClickInstructions) {
            // OnClick -> click
            element.addEventListener('click', (e) => {
                fireFieldEvent('OnClick', fieldName, codiCamp, eventData.onClickInstructions, e);
            });

            // Para checkboxes, também bind no change
            if (element.type === 'checkbox') {
                element.addEventListener('change', (e) => {
                    fireFieldEvent('OnChange', fieldName, codiCamp, eventData.onClickInstructions, e);
                });
            }
        }

        if (eventData.onDblClickInstructions) {
            // OnDblClick -> dblclick
            element.addEventListener('dblclick', (e) => {
                fireFieldEvent('OnDblClick', fieldName, codiCamp, eventData.onDblClickInstructions, e);
            });
        }

        boundElements.add(element);
    }

    /**
     * Observa mudanças no DOM para vincular novos campos e botões de lookup.
     */
    function observeDom() {
        const observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        // Verifica se é um campo
                        if (node.dataset && node.dataset.sagCodicamp) {
                            bindField(node);
                        }
                        // Verifica filhos - campos
                        const children = node.querySelectorAll?.('[data-sag-codicamp]');
                        if (children) {
                            children.forEach(bindField);
                        }
                        // Verifica filhos - botões de lookup
                        const lookupButtons = node.querySelectorAll?.('.btn-lookup');
                        if (lookupButtons && lookupButtons.length > 0) {
                            bindLookupButtons(node);
                        }
                    }
                });
            });
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }

    /**
     * Executa eventos Exit de todos os campos no Show.
     * Similar ao CampPersExecExitShow do Delphi.
     *
     * Isso configura a visibilidade/habilitação inicial dos campos
     * baseado nos valores atuais, sem mostrar mensagens.
     *
     * Filtra comandos: M* (mensagens), EX*, BO*, BC*, TI*
     */
    async function execFieldEventsOnShow() {
        console.log('[SagEvents] Executando eventos Exit no Show (CampPersExecExitShow)');

        // Tipos de componente que NÃO executam no show (como no Delphi)
        const excludedCompTypes = ['BTN', 'DBG', 'GRA', 'TIM', 'BVL', 'LBL', 'LC'];

        // Prefixos de comandos que são FILTRADOS (não executam no show)
        const filteredPrefixes = ['MA', 'MC', 'ME', 'MI', 'MP', 'EX', 'BO', 'BC', 'TI', 'QY', 'QN', 'QD', 'QM', 'DG', 'DM', 'D2', 'D3'];

        let executedCount = 0;

        for (const [codiCamp, eventData] of Object.entries(fieldEvents)) {
            // Pula campos sem eventos OnExit
            if (!eventData.onExitInstructions || !eventData.onExitInstructions.trim()) {
                continue;
            }

            // Encontra o elemento do campo
            const element = document.querySelector(`[data-sag-codicamp="${codiCamp}"]`);
            if (!element) continue;

            const compType = (element.dataset.sagComptype || 'E').toUpperCase();

            // Pula tipos de componente excluídos
            if (excludedCompTypes.includes(compType)) {
                continue;
            }

            // Filtra as instruções - remove M*, EX*, etc.
            const filteredInstructions = filterInstructionsForShow(eventData.onExitInstructions, filteredPrefixes);

            if (!filteredInstructions.trim()) {
                continue;
            }

            const fieldName = element.dataset.sagNomecamp || eventData.nomeCamp || codiCamp;

            // Executa as instruções filtradas
            if (typeof PlsagInterpreter !== 'undefined') {
                try {
                    await PlsagInterpreter.execute(filteredInstructions, {
                        type: 'field',
                        eventType: 'ExitShow',
                        fieldName: fieldName,
                        codiCamp: codiCamp,
                        fieldValue: getElementValue(element),
                        codiTabe: formEvents?.codiTabe,
                        formData: collectFormData(),
                        silentMode: true // Indica que é execução silenciosa
                    });
                    executedCount++;
                } catch (error) {
                    console.warn(`[SagEvents] Erro ExitShow ${fieldName}:`, error);
                }
            }
        }

        console.log(`[SagEvents] ExitShow concluído: ${executedCount} campos processados`);
    }

    /**
     * Filtra instruções removendo comandos que não devem executar no show.
     * @param {string} instructions - Instruções PLSAG
     * @param {string[]} filteredPrefixes - Prefixos a filtrar (ex: ['MA', 'ME', 'EX'])
     * @returns {string} Instruções filtradas
     */
    function filterInstructionsForShow(instructions, filteredPrefixes) {
        const lines = instructions.split('\n');
        const filtered = [];
        let skipNextLine = false;

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();

            if (!line) {
                continue;
            }

            // Se linha anterior era M* (mensagem), pula esta linha também (é o texto da mensagem)
            if (skipNextLine) {
                skipNextLine = false;
                continue;
            }

            // Verifica se a linha começa com algum prefixo filtrado
            const prefix = line.substring(0, 2).toUpperCase();

            if (filteredPrefixes.includes(prefix)) {
                // Se é M* (mensagem), a próxima linha também deve ser pulada
                if (prefix === 'MA' || prefix === 'MC' || prefix === 'ME' || prefix === 'MI' || prefix === 'MP') {
                    skipNextLine = true;
                }
                continue;
            }

            // Para prefixos de 3 caracteres (caso especial)
            const prefix3 = line.substring(0, 3).toUpperCase();
            if (prefix3 === 'IF-' || prefix3 === 'FIN' || prefix3 === 'ELS') {
                // Mantém controle de fluxo
                filtered.push(line);
                continue;
            }

            // Comentários - mantém ou ignora
            if (line.startsWith('--') || line.startsWith('//')) {
                continue;
            }

            filtered.push(line);
        }

        return filtered.join('\n');
    }

    /**
     * Dispara um evento de campo e executa instrucoes PLSAG (Fase 2).
     */
    async function fireFieldEvent(eventType, fieldName, codiCamp, instructions, domEvent) {
        const eventInfo = {
            type: eventType,
            field: fieldName,
            codiCamp: codiCamp,
            value: getElementValue(domEvent.target),
            instructions: instructions,
            timestamp: new Date().toISOString()
        };

        console.log(`[SagEvents] Campo ${fieldName} disparou ${eventType}:`, eventInfo);

        // Emite evento customizado
        document.dispatchEvent(new CustomEvent('sag:field-event', {
            detail: eventInfo
        }));

        // FASE 2: Executa instrucoes PLSAG
        if (instructions && instructions.trim() && typeof PlsagInterpreter !== 'undefined') {
            try {
                const result = await PlsagInterpreter.execute(instructions, {
                    type: 'field',
                    eventType: eventType,
                    fieldName: fieldName,
                    codiCamp: codiCamp,
                    fieldValue: eventInfo.value,
                    codiTabe: formEvents?.codiTabe,
                    formData: collectFormData()
                });

                console.log(`[SagEvents] PLSAG executado:`, result);
            } catch (error) {
                console.error(`[SagEvents] Erro PLSAG:`, error);
            }
        }
    }

    /**
     * Dispara um evento de formulario e executa instrucoes PLSAG (Fase 2).
     */
    async function fireFormEvent(eventType, instructions) {
        const eventInfo = {
            type: eventType,
            instructions: instructions,
            timestamp: new Date().toISOString()
        };

        console.log(`[SagEvents] Form disparou ${eventType}:`, eventInfo);

        // Emite evento customizado
        document.dispatchEvent(new CustomEvent('sag:form-event', {
            detail: eventInfo
        }));

        // FASE 2: Executa instrucoes PLSAG
        if (instructions && instructions.trim() && typeof PlsagInterpreter !== 'undefined') {
            try {
                const result = await PlsagInterpreter.execute(instructions, {
                    type: 'form',
                    eventType: eventType,
                    codiTabe: formEvents?.codiTabe,
                    formData: collectFormData()
                });

                console.log(`[SagEvents] PLSAG executado:`, result);
            } catch (error) {
                console.error(`[SagEvents] Erro PLSAG:`, error);
            }
        }
    }

    /**
     * Coleta dados de todos os campos do formulario.
     * @returns {Object} Objeto com nome:valor de cada campo
     */
    function collectFormData() {
        const data = {};
        const form = document.getElementById('dynamicForm') || document.querySelector('form');

        if (!form) return data;

        // Campos com data-sag-nomecamp
        form.querySelectorAll('[data-sag-nomecamp]').forEach(element => {
            const fieldName = element.dataset.sagNomecamp;
            if (element.type === 'checkbox') {
                data[fieldName] = element.checked ? '1' : '0';
            } else {
                data[fieldName] = element.value || '';
            }
        });

        // Campos com name (fallback)
        form.querySelectorAll('[name]').forEach(element => {
            const fieldName = element.name;
            if (!data[fieldName]) {
                if (element.type === 'checkbox') {
                    data[fieldName] = element.checked ? '1' : '0';
                } else {
                    data[fieldName] = element.value || '';
                }
            }
        });

        // IMPORTANTE: Inclui a PK (editingRecordId) no formData
        // Em modo EDIT, o template {DG-<PK>} precisa resolver para o ID do registro
        const editingIdElement = document.getElementById('editingRecordId');
        const pkFieldName = editingIdElement?.dataset?.pkField;
        console.log('[SagEvents] collectFormData - editingId:', editingIdElement?.value, 'pkField:', pkFieldName);
        if (editingIdElement?.value && pkFieldName) {
            data[pkFieldName] = editingIdElement.value;
            console.log('[SagEvents] collectFormData - Adicionado', pkFieldName, '=', editingIdElement.value);
        }

        return data;
    }

    /**
     * Obtém o valor de um elemento de formulário.
     */
    function getElementValue(element) {
        if (!element) return null;

        if (element.type === 'checkbox') {
            return element.checked ? '1' : '0';
        }

        if (element.type === 'radio') {
            const form = element.closest('form');
            if (form) {
                const checked = form.querySelector(`input[name="${element.name}"]:checked`);
                return checked ? checked.value : null;
            }
            return element.checked ? element.value : null;
        }

        return element.value;
    }

    /**
     * Dispara evento LancTabe antes de salvar.
     * Chamado pelo formulário antes de enviar dados.
     * Implementa VeriEnviConf do Delphi - bloqueia se PA ou ME parar execução.
     * @returns {Promise<boolean>} true se pode continuar, false para cancelar
     */
    async function beforeSave() {
        if (!formEvents || !formEvents.lancTabeInstructions) {
            return true;
        }

        // Determina se é INSERT ou EDIT baseado no editingRecordId
        const editingIdElement = document.getElementById('editingRecordId');
        const recordId = editingIdElement?.value ? parseInt(editingIdElement.value, 10) : null;
        const isInsert = !recordId || recordId === 0;

        console.log(`[SagEvents] beforeSave - recordId: ${recordId}, isInsert: ${isInsert}`);

        // Executa LancTabe e verifica se foi bloqueado
        if (typeof PlsagInterpreter !== 'undefined') {
            try {
                const result = await PlsagInterpreter.execute(formEvents.lancTabeInstructions, {
                    type: 'form',
                    eventType: 'LancTabe',
                    codiTabe: formEvents?.codiTabe,
                    formData: collectFormData(),
                    isInsert: isInsert,
                    recordId: recordId
                });

                console.log(`[SagEvents] LancTabe executado:`, result);

                // Se foi bloqueado (PA ou ME), cancela a gravação
                if (result.blocked) {
                    console.log('[SagEvents] LancTabe bloqueou a gravação');
                    return false;
                }

                return true;
            } catch (error) {
                console.error(`[SagEvents] Erro LancTabe:`, error);
                // Em caso de erro, permite continuar (comportamento seguro)
                return true;
            }
        }

        return true;
    }

    /**
     * Dispara evento EGraTabe após salvar.
     * Chamado após sucesso do salvamento.
     */
    function afterSave() {
        if (formEvents && formEvents.eGraTabeInstructions) {
            fireFormEvent('EGraTabe', formEvents.eGraTabeInstructions);
        }
    }

    /**
     * Dispara evento AposTabe ao finalizar.
     * Chamado ao fechar o formulário ou após salvar com sucesso.
     */
    function onClose() {
        if (formEvents && formEvents.aposTabeInstructions) {
            fireFormEvent('AposTabe', formEvents.aposTabeInstructions);
        }
    }

    /**
     * Dispara evento AtuaGrid para atualizar grids de movimentos.
     * Chamado após salvar ou quando necessário recarregar grids.
     */
    function refreshGrid() {
        if (formEvents && formEvents.atuaGridInstructions) {
            fireFormEvent('AtuaGrid', formEvents.atuaGridInstructions);
        }

        // Recarrega grid de consulta se existir
        if (window.consultaGrid && typeof window.consultaGrid.loadData === 'function') {
            console.log('[SagEvents] Recarregando grid de consulta');
            window.consultaGrid.loadData();
        }
    }

    /**
     * Verifica se o sistema está inicializado.
     */
    function isInitialized() {
        return initialized;
    }

    /**
     * Obtém os eventos do formulário.
     */
    function getFormEvents() {
        return formEvents;
    }

    /**
     * Obtém os eventos dos campos.
     */
    function getFieldEvents() {
        return fieldEvents;
    }

    // ============================================
    // MOVEMENT EVENTS - Eventos de Movimento
    // ============================================

    /**
     * Carrega eventos de movimento de uma tabela.
     * Busca do endpoint /api/movement/{parentTableId}/{tableId}/events
     * @param {number} parentTableId - ID da tabela pai (cabeçalho)
     * @param {number} movementTableId - ID da tabela de movimento
     * @returns {Promise<Object>} Dados de eventos do movimento
     */
    async function loadMovementEvents(parentTableId, movementTableId) {
        try {
            // Verifica cache
            if (movementEvents[movementTableId]) {
                console.log(`[SagEvents] Eventos movimento ${movementTableId} (cache)`);
                return movementEvents[movementTableId];
            }

            const response = await fetch(`/api/movement/${parentTableId}/${movementTableId}/events`);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const events = await response.json();
            movementEvents[movementTableId] = events;

            console.log(`[SagEvents] Eventos movimento ${movementTableId} carregados:`, events);
            return events;
        } catch (error) {
            console.error(`[SagEvents] Erro ao carregar eventos movimento ${movementTableId}:`, error);
            return null;
        }
    }

    /**
     * Define o contexto de movimento ativo.
     * Usado para resolução de templates DM/D2 no PLSAG.
     * @param {Object} ctx - Contexto do movimento
     * @param {number} ctx.parentTableId - ID da tabela pai
     * @param {number} ctx.movementTableId - ID da tabela de movimento
     * @param {number} ctx.parentRecordId - ID do registro pai
     * @param {number} ctx.recordId - ID do registro de movimento (se existir)
     * @param {Object} ctx.formData - Dados do formulário de movimento
     */
    function setActiveMovementContext(ctx) {
        activeMovementContext = ctx;
        console.log('[SagEvents] Contexto movimento ativo:', ctx);

        // Atualiza contexto do PLSAG interpreter para templates DM
        if (typeof PlsagInterpreter !== 'undefined' && ctx?.formData) {
            PlsagInterpreter.setMovementData(
                ctx.formData,
                ctx.movementTableId,
                ctx.recordId
            );
        }
    }

    /**
     * Obtém o contexto de movimento ativo.
     * @returns {Object|null} Contexto do movimento ou null
     */
    function getActiveMovementContext() {
        return activeMovementContext;
    }

    /**
     * Limpa o contexto de movimento ativo.
     */
    function clearMovementContext() {
        activeMovementContext = null;
        console.log('[SagEvents] Contexto movimento limpo');

        // Limpa contexto do PLSAG interpreter
        if (typeof PlsagInterpreter !== 'undefined') {
            PlsagInterpreter.clearMovementData();
        }
    }

    /**
     * Dispara um evento de movimento.
     * @param {string} eventType - Tipo de evento: 'beforeAny', 'afterAny', 'beforeInsert', 'afterInsert',
     *                             'beforeUpdate', 'afterUpdate', 'beforeDelete', 'afterDelete',
     *                             'onGridRefresh', 'onModalOpen'
     * @param {number} movementTableId - ID da tabela de movimento
     * @param {number} recordId - ID do registro de movimento (opcional para alguns eventos)
     * @param {Object} additionalContext - Contexto adicional (ex: formData)
     * @returns {Promise<{success: boolean, blocked: boolean}>}
     */
    async function triggerMovementEvent(eventType, movementTableId, recordId = null, additionalContext = {}) {
        const events = movementEvents[movementTableId];
        if (!events || !events.hasEvents) {
            console.log(`[SagEvents] Movimento ${movementTableId} sem eventos configurados`);
            return { success: true, blocked: false };
        }

        let instructions = '';
        let eventName = '';

        // Mapeia o tipo de evento para as instruções correspondentes
        switch (eventType) {
            case 'beforeAny':
                instructions = events.anteIAEMoviInstructions || '';
                eventName = 'AnteIAE_Movi';
                break;
            case 'afterAny':
                instructions = events.depoIAEMoviInstructions || '';
                eventName = 'DepoIAE_Movi';
                break;
            case 'beforeInsert':
                instructions = events.anteInclInstructions || '';
                eventName = 'AnteIncl';
                break;
            case 'afterInsert':
                instructions = events.depoInclInstructions || '';
                eventName = 'DepoIncl';
                break;
            case 'beforeUpdate':
                instructions = events.anteAlteInstructions || '';
                eventName = 'AnteAlte';
                break;
            case 'afterUpdate':
                instructions = events.depoAlteInstructions || '';
                eventName = 'DepoAlte';
                break;
            case 'beforeDelete':
                instructions = events.anteExclInstructions || '';
                eventName = 'AnteExcl';
                break;
            case 'afterDelete':
                instructions = events.depoExclInstructions || '';
                eventName = 'DepoExcl';
                break;
            case 'onGridRefresh':
                instructions = events.atuaGridInstructions || '';
                eventName = 'AtuaGrid';
                break;
            case 'onModalOpen':
                instructions = events.showPaiFilhInstructions || '';
                eventName = 'ShowPai_Filh';
                break;
            default:
                console.warn(`[SagEvents] Tipo de evento movimento desconhecido: ${eventType}`);
                return { success: true, blocked: false };
        }

        if (!instructions || !instructions.trim()) {
            console.log(`[SagEvents] Movimento ${movementTableId} sem instruções para ${eventName}`);
            return { success: true, blocked: false };
        }

        console.log(`[SagEvents] Executando ${eventName} (movimento ${movementTableId}):`, instructions.substring(0, 100));

        // Monta contexto para o interpretador
        const context = {
            type: 'movement',
            eventType: eventName,
            movementTableId: movementTableId,
            parentTableId: activeMovementContext?.parentTableId || events.parentCodiTabe,
            parentRecordId: activeMovementContext?.parentRecordId,
            recordId: recordId,
            codiTabe: movementTableId,
            formData: additionalContext.formData || activeMovementContext?.formData || {},
            ...additionalContext
        };

        // Emite evento customizado
        document.dispatchEvent(new CustomEvent('sag:movement-event', {
            detail: {
                eventType: eventName,
                movementTableId: movementTableId,
                recordId: recordId,
                instructions: instructions
            }
        }));

        // Executa PLSAG
        if (typeof PlsagInterpreter !== 'undefined') {
            try {
                const result = await PlsagInterpreter.execute(instructions, context);
                console.log(`[SagEvents] ${eventName} executado:`, result);

                // Verifica se foi bloqueado (PA ou ME)
                if (result.blocked) {
                    console.log(`[SagEvents] ${eventName} bloqueou a operação`);
                    return { success: true, blocked: true };
                }

                return { success: true, blocked: false };
            } catch (error) {
                console.error(`[SagEvents] Erro ${eventName}:`, error);
                return { success: false, blocked: false, error: error.message };
            }
        }

        return { success: true, blocked: false };
    }

    /**
     * Executa sequência de eventos antes de uma operação CRUD de movimento.
     * @param {string} operation - 'insert', 'update', 'delete'
     * @param {number} movementTableId - ID da tabela de movimento
     * @param {number} recordId - ID do registro (para update/delete)
     * @param {Object} formData - Dados do formulário
     * @returns {Promise<{canProceed: boolean}>}
     */
    async function beforeMovementOperation(operation, movementTableId, recordId, formData = {}) {
        // Define contexto
        setActiveMovementContext({
            movementTableId: movementTableId,
            recordId: recordId,
            formData: formData,
            operation: operation
        });

        // 1. Evento genérico AnteIAE_Movi
        let result = await triggerMovementEvent('beforeAny', movementTableId, recordId, { formData });
        if (result.blocked) {
            return { canProceed: false, reason: 'AnteIAE_Movi' };
        }

        // 2. Evento específico da operação
        const specificEvent = operation === 'insert' ? 'beforeInsert' :
                              operation === 'update' ? 'beforeUpdate' : 'beforeDelete';
        result = await triggerMovementEvent(specificEvent, movementTableId, recordId, { formData });
        if (result.blocked) {
            return { canProceed: false, reason: specificEvent };
        }

        return { canProceed: true };
    }

    /**
     * Executa sequência de eventos após uma operação CRUD de movimento.
     * @param {string} operation - 'insert', 'update', 'delete'
     * @param {number} movementTableId - ID da tabela de movimento
     * @param {number} recordId - ID do registro criado/atualizado/excluído
     * @param {Object} formData - Dados do formulário
     */
    async function afterMovementOperation(operation, movementTableId, recordId, formData = {}) {
        // 1. Evento específico da operação
        const specificEvent = operation === 'insert' ? 'afterInsert' :
                              operation === 'update' ? 'afterUpdate' : 'afterDelete';
        await triggerMovementEvent(specificEvent, movementTableId, recordId, { formData });

        // 2. Evento genérico DepoIAE_Movi
        await triggerMovementEvent('afterAny', movementTableId, recordId, { formData });

        // 3. Atualiza grid (AtuaGrid)
        await triggerMovementEvent('onGridRefresh', movementTableId, recordId);

        // Limpa contexto
        clearMovementContext();
    }

    /**
     * Obtém eventos carregados de um movimento.
     * @param {number} movementTableId - ID da tabela de movimento
     * @returns {Object|null} Eventos do movimento ou null
     */
    function getMovementEvents(movementTableId) {
        return movementEvents[movementTableId] || null;
    }

    /**
     * Carrega eventos de CAMPO de uma tabela de movimento.
     * @param {number} movementTableId - ID da tabela de movimento
     * @returns {Promise<Object>} Eventos dos campos indexados por CodiCamp
     */
    async function loadMovementFieldEvents(movementTableId) {
        try {
            // Verifica cache
            if (movementFieldEvents[movementTableId]) {
                console.log(`[SagEvents] Eventos de campo movimento ${movementTableId} (cache)`);
                return movementFieldEvents[movementTableId];
            }

            const response = await fetch(`/api/movement/${movementTableId}/field-events`);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const events = await response.json();
            movementFieldEvents[movementTableId] = events;

            console.log(`[SagEvents] Eventos de campo movimento ${movementTableId} carregados:`, Object.keys(events).length, 'campos');
            return events;
        } catch (error) {
            console.error(`[SagEvents] Erro ao carregar eventos de campo movimento ${movementTableId}:`, error);
            return {};
        }
    }

    /**
     * Obtém eventos de campo de movimento carregados.
     * @param {number} movementTableId - ID da tabela de movimento
     * @returns {Object|null} Eventos de campo do movimento ou null
     */
    function getMovementFieldEvents(movementTableId) {
        return movementFieldEvents[movementTableId] || null;
    }

    // ============================================
    // LOOKUP - Modal de Pesquisa
    // ============================================

    // ============================================
    // LOOKUP DATA CACHE - Cache de dados de lookup
    // Similar ao DataSource interno do TDBLookNume no Delphi
    // ============================================

    /**
     * Cache de dados de lookup por campo (NomeCamp -> data completo).
     * Quando um lookup é selecionado, armazenamos todos os dados do registro
     * para que campos IE vinculados possam acessar.
     */
    const lookupDataCache = {};

    /**
     * Armazena dados do registro selecionado no cache de lookup.
     * @param {string} fieldName - Nome do campo de lookup (ex: CODIPROD)
     * @param {Object} recordData - Dados completos do registro selecionado
     */
    function setLookupData(fieldName, recordData) {
        const upperName = fieldName.toUpperCase();
        lookupDataCache[upperName] = recordData;
        console.log(`[SagEvents] Lookup cache atualizado: ${upperName}`, recordData);

        // Notifica campos IE vinculados a este lookup
        updateLinkedIEFields(upperName);
    }

    /**
     * Obtém dados do cache de lookup.
     * @param {string} fieldName - Nome do campo de lookup
     * @returns {Object|null} Dados do registro ou null
     */
    function getLookupData(fieldName) {
        return lookupDataCache[fieldName.toUpperCase()] || null;
    }

    /**
     * Atualiza campos IE que estão vinculados a um lookup.
     * No Delphi, campos IE têm VaGrCamp com duas linhas:
     * - Linha 0: Nome do campo a exibir (ex: NOMEPROD)
     * - Linha 1: Nome do campo lookup (ex: CODIPROD → busca dados de EdtCODIPROD)
     * @param {string} lookupFieldName - Nome do campo lookup que foi atualizado
     */
    function updateLinkedIEFields(lookupFieldName) {
        const data = lookupDataCache[lookupFieldName];
        if (!data) return;

        // Busca todos os campos IE vinculados a este lookup
        // IE fields têm data-sag-linked-lookup="NOMECAMPOLOOKUP"
        document.querySelectorAll(`[data-sag-linked-lookup="${lookupFieldName}"]`).forEach(ieField => {
            const sourceColumn = ieField.dataset.sagSourceColumn;
            if (sourceColumn && data[sourceColumn.toUpperCase()]) {
                const newValue = data[sourceColumn.toUpperCase()];
                const fieldName = ieField.name || ieField.dataset.sagNomecamp || ieField.id;
                console.log(`[SagEvents] Atualizando campo IE ${fieldName}: ${newValue}`);

                // Lida com diferentes tipos de elementos
                if (ieField.tagName === 'INPUT' || ieField.tagName === 'TEXTAREA') {
                    ieField.value = newValue;
                } else if (ieField.tagName === 'DIV') {
                    // Para divs (como RichEdit), usa textContent ou innerHTML
                    ieField.textContent = newValue;
                } else if (ieField.tagName === 'SELECT') {
                    ieField.value = newValue;
                }
            }
        });
    }

    /**
     * Limpa o cache de lookup.
     * Chamado ao limpar o formulário ou mudar de registro.
     */
    function clearLookupCache() {
        for (const key in lookupDataCache) {
            delete lookupDataCache[key];
        }
        console.log('[SagEvents] Lookup cache limpo');
    }

    /**
     * Abre o modal de lookup para um campo.
     * Busca o SQL do campo e executa para mostrar opções.
     * Retorna TODOS os dados do registro para preencher campos IE.
     * @param {string|number} codiCamp - ID do campo (CodiCamp)
     */
    async function openLookup(codiCamp) {
        console.log('[SagEvents] openLookup para campo', codiCamp);

        // Encontra o elemento do campo
        const fieldElement = document.querySelector(`[data-sag-codicamp="${codiCamp}"]`);
        if (!fieldElement) {
            console.warn('[SagEvents] Campo não encontrado:', codiCamp);
            return;
        }

        try {
            // Busca o SQL do campo
            const sqlResponse = await fetch(`/Form/GetFieldLookupSql?codiCamp=${codiCamp}`);
            if (!sqlResponse.ok) {
                console.warn('[SagEvents] Campo não tem SQL de lookup');
                return;
            }

            const sqlData = await sqlResponse.json();
            if (!sqlData.success || !sqlData.sql) {
                console.warn('[SagEvents] SQL de lookup não encontrado');
                return;
            }

            // Executa o SQL para obter as opções (agora retorna dados completos)
            const lookupResponse = await fetch('/Form/ExecuteLookup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ sql: sqlData.sql, filter: '' })
            });

            if (!lookupResponse.ok) {
                throw new Error('Erro ao executar lookup');
            }

            const lookupData = await lookupResponse.json();
            if (!lookupData.success) {
                throw new Error(lookupData.error || 'Erro ao executar lookup');
            }

            // Mostra o modal de lookup com dados completos
            showLookupModal(fieldElement, lookupData.columns, lookupData.records, sqlData.sql);

        } catch (error) {
            console.error('[SagEvents] Erro ao abrir lookup:', error);
            alert('Erro ao abrir pesquisa: ' + error.message);
        }
    }

    /**
     * Mostra o modal de lookup com as opções.
     * Exibe todas as colunas retornadas pelo SQL_CAMP.
     * Ao selecionar, armazena dados completos no cache para campos IE.
     *
     * @param {HTMLElement} fieldElement - Elemento do campo de lookup
     * @param {Array<string>} columns - Lista de nomes das colunas
     * @param {Array} records - Lista de registros {key, value, data}
     * @param {string} sql - SQL para refetch com filtro
     */
    function showLookupModal(fieldElement, columns, records, sql) {
        // Remove modal anterior se existir
        const existingModal = document.getElementById('sagLookupModal');
        if (existingModal) {
            existingModal.remove();
        }

        // Prepara cabeçalhos da tabela (até 5 colunas para não ficar muito largo)
        const displayColumns = columns.slice(0, 5);
        const headerHtml = displayColumns.map(col =>
            `<th>${escapeHtml(col)}</th>`
        ).join('');

        // Cria o modal
        const fieldName = fieldElement.dataset.sagNomecamp || fieldElement.name || 'Campo';
        const labelText = fieldElement.dataset.sagLabel || fieldName;
        const modalHtml = `
            <div class="modal fade" id="sagLookupModal" tabindex="-1">
                <div class="modal-dialog modal-lg modal-dialog-scrollable">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Pesquisar: ${escapeHtml(labelText)}</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="mb-3">
                                <input type="text" class="form-control" id="lookupFilter"
                                       placeholder="Digite para filtrar..." autocomplete="off">
                            </div>
                            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                                <table class="table table-hover table-sm" id="lookupTable">
                                    <thead class="table-light sticky-top">
                                        <tr>${headerHtml}</tr>
                                    </thead>
                                    <tbody id="lookupTableBody"></tbody>
                                </table>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <span class="text-muted me-auto" id="lookupRecordCount"></span>
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML('beforeend', modalHtml);

        const modal = document.getElementById('sagLookupModal');
        const bsModal = new bootstrap.Modal(modal);
        const tableBody = document.getElementById('lookupTableBody');
        const filterInput = document.getElementById('lookupFilter');
        const recordCount = document.getElementById('lookupRecordCount');

        // Função para renderizar registros
        function renderRecords(recordList) {
            tableBody.innerHTML = '';
            recordCount.textContent = `${recordList.length} registro(s)`;

            if (!recordList || recordList.length === 0) {
                tableBody.innerHTML = `<tr><td colspan="${displayColumns.length}" class="text-muted text-center">Nenhum registro encontrado</td></tr>`;
                return;
            }

            recordList.forEach(record => {
                const row = document.createElement('tr');
                row.style.cursor = 'pointer';

                // Renderiza células para cada coluna
                let cellsHtml = '';
                displayColumns.forEach(col => {
                    const value = record.data[col] || '';
                    cellsHtml += `<td>${escapeHtml(value)}</td>`;
                });
                row.innerHTML = cellsHtml;

                // Ao clicar na linha, seleciona o registro
                row.addEventListener('click', () => {
                    // 1. Preenche o campo de lookup com a chave (primeira coluna)
                    fieldElement.value = record.key;

                    // 2. Preenche o campo de descrição automático (TDBLookNume behavior)
                    const descId = fieldElement.dataset.lookupDescId;
                    if (descId) {
                        const descField = document.getElementById(descId);
                        if (descField) {
                            // Usa a segunda coluna como descrição (record.value)
                            descField.value = record.value || '';
                        }
                    }

                    // 3. Armazena TODOS os dados no cache para campos IE
                    const lookupFieldName = fieldElement.dataset.sagNomecamp || fieldElement.name;
                    setLookupData(lookupFieldName, record.data);

                    // 4. Dispara eventos change e blur para processar OnExit
                    fieldElement.dispatchEvent(new Event('change', { bubbles: true }));
                    fieldElement.dispatchEvent(new Event('blur', { bubbles: true }));

                    // 5. Fecha o modal
                    bsModal.hide();
                });

                tableBody.appendChild(row);
            });
        }

        // Renderiza registros iniciais
        renderRecords(records);

        // Filtro em tempo real
        let filterTimeout = null;
        filterInput.addEventListener('input', () => {
            clearTimeout(filterTimeout);
            filterTimeout = setTimeout(async () => {
                const filter = filterInput.value.trim().toLowerCase();
                if (filter.length === 0) {
                    renderRecords(records);
                    return;
                }

                // Filtra por qualquer coluna exibida
                const filtered = records.filter(record =>
                    displayColumns.some(col => {
                        const value = record.data[col] || '';
                        return value.toLowerCase().includes(filter);
                    })
                );
                renderRecords(filtered);
            }, 300);
        });

        // Limpa modal ao fechar
        modal.addEventListener('hidden.bs.modal', () => {
            modal.remove();
        });

        // Mostra o modal
        bsModal.show();
        setTimeout(() => filterInput.focus(), 300);
    }

    /**
     * Escapa HTML para prevenir XSS.
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

    // ============================================
    // FIELD EXIT - Disparo Manual de OnExit
    // ============================================

    /**
     * Dispara o evento OnExit de um campo manualmente.
     * Usado quando o blur/change é chamado programaticamente.
     * Suporta campos do form principal E campos de movimento.
     * @param {string|number} codiCamp - ID do campo (CodiCamp)
     * @param {string} value - Valor atual do campo
     * @param {number} movementTableId - (Opcional) ID da tabela de movimento
     */
    async function onFieldExit(codiCamp, value, movementTableId = null) {
        // Primeiro tenta buscar em eventos do form principal
        let eventData = fieldEvents[codiCamp];

        // Se não encontrou e há contexto de movimento ativo, busca em eventos de movimento
        if (!eventData) {
            const mvtTableId = movementTableId || activeMovementContext?.movementTableId;
            if (mvtTableId && movementFieldEvents[mvtTableId]) {
                eventData = movementFieldEvents[mvtTableId][codiCamp];
            }
        }

        if (!eventData || !eventData.onExitInstructions) {
            console.log('[SagEvents] Campo', codiCamp, 'sem eventos OnExit');
            return;
        }

        const fieldElement = document.querySelector(`[data-sag-codicamp="${codiCamp}"]`);
        const fieldName = eventData.nomeCamp || fieldElement?.dataset?.sagNomecamp || codiCamp;

        console.log('[SagEvents] onFieldExit manual:', fieldName, '=', value);

        // Coleta dados do form principal
        const formData = collectFormData();

        // Coleta dados do modal de movimento se estiver aberto
        const movementFormData = {};
        const movementForm = document.getElementById('movementForm');
        if (movementForm) {
            movementForm.querySelectorAll('[data-sag-nomecamp]').forEach(el => {
                const name = el.dataset.sagNomecamp;
                if (el.type === 'checkbox') {
                    movementFormData[name] = el.checked ? '1' : '0';
                } else {
                    movementFormData[name] = el.value || '';
                }
            });
            // Também pega campos sem data-sag-nomecamp mas com name
            movementForm.querySelectorAll('[name]').forEach(el => {
                const name = el.name;
                if (!movementFormData[name]) {
                    if (el.type === 'checkbox') {
                        movementFormData[name] = el.checked ? '1' : '0';
                    } else {
                        movementFormData[name] = el.value || '';
                    }
                }
            });
        }

        // Determina se estamos em contexto de movimento
        const isMovementContext = !!movementTableId || !!activeMovementContext?.movementTableId;

        // Atualiza o PlsagInterpreter com dados de movimento
        if (isMovementContext && typeof PlsagInterpreter !== 'undefined') {
            PlsagInterpreter.setMovementData(
                movementFormData,
                movementTableId || activeMovementContext?.movementTableId,
                activeMovementContext?.recordId
            );
        }

        // Executa as instruções PLSAG
        if (eventData.onExitInstructions.trim() && typeof PlsagInterpreter !== 'undefined') {
            try {
                const codiTabe = movementTableId || activeMovementContext?.movementTableId || formEvents?.codiTabe;

                // Combina dados: header + movimento
                const combinedData = { ...formData, ...movementFormData };

                const result = await PlsagInterpreter.execute(eventData.onExitInstructions, {
                    type: 'field',
                    eventType: 'OnExit',
                    fieldName: fieldName,
                    codiCamp: codiCamp,
                    fieldValue: value,
                    codiTabe: codiTabe,
                    formData: combinedData,
                    isMovement: isMovementContext
                });

                console.log('[SagEvents] OnExit executado:', result);
            } catch (error) {
                console.error('[SagEvents] Erro OnExit:', error);
            }
        }
    }

    // ============================================
    // API publica
    // ============================================

    /**
     * Reexecuta eventos de campo após carregar registro para edição.
     * Deve ser chamado após fillForm() para aplicar regras de visibilidade/habilitação.
     */
    async function onRecordLoaded() {
        console.log('[SagEvents] Registro carregado - executando eventos de campo');

        // Atualiza contexto para modo EDIT
        if (typeof PlsagInterpreter !== 'undefined') {
            PlsagInterpreter.setInsertMode(false);
        }

        // Executa eventos Exit de todos os campos para aplicar regras
        await execFieldEventsOnShow();

        // Dispara DepoShow se existir (evento após mostrar dados)
        if (formEvents.depoShowInstructions) {
            await fireFormEvent('DepoShow', formEvents.depoShowInstructions);
        }

        console.log('[SagEvents] Eventos pós-carregamento concluídos');
    }

    // ============================================
    // LOOKUP DESCRIPTIONS - Preenche descrições ao carregar registro
    // Similar ao TDBLookNume que busca descrição automaticamente
    // ============================================

    /**
     * Preenche as descrições de todos os campos lookup que têm valor.
     * Chamado após carregar um registro para edição.
     * @param {HTMLElement} container - Container onde buscar os campos (default: document)
     */
    async function populateLookupDescriptions(container = document) {
        // Encontra todos os campos lookup com valor e campo de descrição
        const lookupInputs = container.querySelectorAll('.lookup-code-input[data-lookup-desc-id][data-lookup-sql]');

        for (const input of lookupInputs) {
            const value = input.value?.trim();
            if (!value) continue;

            const descId = input.dataset.lookupDescId;
            const sql = input.dataset.lookupSql;

            if (!descId || !sql) continue;

            const descField = document.getElementById(descId);
            if (!descField) continue;

            try {
                // Busca a descrição via API
                const response = await fetch('/Form/ExecuteLookup', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ sql: sql, filter: value })
                });

                if (!response.ok) continue;

                const data = await response.json();
                if (!data.success || !data.records || data.records.length === 0) continue;

                // Procura o registro com key correspondente
                const record = data.records.find(r =>
                    r.key === value || r.key === parseInt(value) || String(r.key) === value
                );

                if (record) {
                    descField.value = record.value || '';

                    // Também armazena no cache para campos IE
                    const fieldName = input.dataset.sagNomecamp || input.name;
                    if (fieldName && record.data) {
                        setLookupData(fieldName, record.data);
                    }

                    console.log(`[SagEvents] Descrição carregada para ${fieldName}: ${record.value}`);
                }
            } catch (error) {
                console.warn('[SagEvents] Erro ao buscar descrição lookup:', error);
            }
        }
    }

    /**
     * Limpa descrições de lookups.
     * Chamado ao limpar formulário ou iniciar novo registro.
     * @param {HTMLElement} container - Container onde buscar os campos (default: document)
     */
    function clearLookupDescriptions(container = document) {
        const descFields = container.querySelectorAll('.lookup-desc-field');
        descFields.forEach(field => {
            field.value = '';
        });
    }

    // ============================================
    // PROTECTED FIELDS - Validação de Campos Protegidos
    // Similar ao BtnConf_CampModi do Delphi
    // ============================================

    // Cache de dados originais do registro (para comparação)
    let originalRecordData = null;

    /**
     * Armazena os dados originais do registro para comparação posterior.
     * Deve ser chamado após carregar um registro para edição.
     * @param {Object} data - Dados originais do registro
     */
    function setOriginalRecordData(data) {
        originalRecordData = data ? { ...data } : null;
        console.log('[SagEvents] Dados originais armazenados:', originalRecordData ? Object.keys(originalRecordData).length + ' campos' : 'null');
    }

    /**
     * Obtém os dados originais do registro.
     * @returns {Object|null} Dados originais ou null
     */
    function getOriginalRecordData() {
        return originalRecordData;
    }

    /**
     * Limpa os dados originais do registro.
     * Chamado ao limpar formulário ou iniciar novo registro.
     */
    function clearOriginalRecordData() {
        originalRecordData = null;
        console.log('[SagEvents] Dados originais limpos');
    }

    /**
     * Obtém campos protegidos de uma tabela.
     * @param {number} tableId - ID da tabela (CodiTabe)
     * @returns {Promise<Array>} Lista de campos protegidos
     */
    async function getProtectedFields(tableId) {
        try {
            const response = await fetch(`/Form/GetProtectedFields?tableId=${tableId}`);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = await response.json();
            if (data.success) {
                return data.fields || [];
            }
            return [];
        } catch (error) {
            console.error('[SagEvents] Erro ao obter campos protegidos:', error);
            return [];
        }
    }

    /**
     * Valida se modificações em campos protegidos são permitidas.
     * Implementa a lógica do BtnConf_CampModi do Delphi.
     *
     * @param {number} tableId - ID da tabela (CodiTabe)
     * @returns {Promise<{isValid: boolean, violations: Array, message: string}>}
     */
    async function validateProtectedFields(tableId) {
        // Em modo INSERT, não precisa validar (não há dados originais)
        if (!originalRecordData || isInsertMode) {
            console.log('[SagEvents] Validação não necessária (INSERT ou sem dados originais)');
            return { isValid: true, violations: [], message: null };
        }

        const currentData = collectFormData();

        try {
            const response = await fetch('/Form/ValidateModifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    tableId: tableId,
                    originalData: originalRecordData,
                    newData: currentData
                })
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const result = await response.json();

            if (!result.success) {
                throw new Error(result.error || 'Erro na validação');
            }

            if (!result.isValid) {
                console.warn('[SagEvents] Campos protegidos modificados:', result.violations);
            }

            return {
                isValid: result.isValid,
                violations: result.violations || [],
                message: result.message,
                isFinalized: result.isFinalized
            };
        } catch (error) {
            console.error('[SagEvents] Erro ao validar campos protegidos:', error);
            // Em caso de erro, permite continuar (comportamento seguro)
            return { isValid: true, violations: [], message: null };
        }
    }

    /**
     * Exibe mensagem de violação de campos protegidos.
     * @param {Object} validationResult - Resultado da validação
     * @returns {boolean} false sempre (para cancelar operação)
     */
    function showProtectedFieldsError(validationResult) {
        if (!validationResult.violations || validationResult.violations.length === 0) {
            return false;
        }

        // Monta mensagem detalhada
        let message = validationResult.message || 'Campos protegidos foram modificados:';
        message += '\n\n';

        validationResult.violations.forEach((v, i) => {
            message += `${i + 1}. ${v.errorMessage}\n`;
            if (v.originalValue !== undefined && v.newValue !== undefined) {
                message += `   Original: "${v.originalValue}" → Novo: "${v.newValue}"\n`;
            }
        });

        if (validationResult.isFinalized) {
            message += '\nEste registro foi gerado por outro processo e não pode ser modificado diretamente.';
        }

        // Exibe alerta
        alert(message);

        // Destaca campos violados
        highlightViolatedFields(validationResult.violations);

        return false;
    }

    /**
     * Destaca visualmente os campos que violaram a regra de proteção.
     * @param {Array} violations - Lista de violações
     */
    function highlightViolatedFields(violations) {
        // Remove destaque anterior
        document.querySelectorAll('.field-violation').forEach(el => {
            el.classList.remove('field-violation');
        });

        // Adiciona destaque nos campos violados
        violations.forEach(v => {
            const field = document.querySelector(`[data-sag-nomecamp="${v.fieldName}"]`) ||
                         document.querySelector(`[name="${v.fieldName}"]`);
            if (field) {
                field.classList.add('field-violation');
                // Remove destaque após 5 segundos
                setTimeout(() => {
                    field.classList.remove('field-violation');
                }, 5000);
            }
        });
    }

    /**
     * Valida campos protegidos antes de salvar.
     * Deve ser chamado antes de beforeSave().
     * @param {number} tableId - ID da tabela
     * @returns {Promise<boolean>} true se pode continuar, false para cancelar
     */
    async function validateBeforeSave(tableId) {
        const validation = await validateProtectedFields(tableId);

        if (!validation.isValid) {
            showProtectedFieldsError(validation);
            return false;
        }

        return true;
    }

    return {
        init,
        beforeSave,
        afterSave,
        onClose,
        refreshGrid,
        isInitialized,
        getFormEvents,
        getFieldEvents,
        bindField,
        bindAllFields,
        bindLookupButtons,
        bindSagButtons,
        collectFormData,
        execFieldEventsOnShow,
        onRecordLoaded,
        // Lookup API
        openLookup,
        setLookupData,
        getLookupData,
        clearLookupCache,
        populateLookupDescriptions,
        clearLookupDescriptions,
        // Field Exit API
        onFieldExit,
        // Movement Events API
        loadMovementEvents,
        loadMovementFieldEvents,
        getMovementFieldEvents,
        triggerMovementEvent,
        beforeMovementOperation,
        afterMovementOperation,
        setActiveMovementContext,
        getActiveMovementContext,
        clearMovementContext,
        getMovementEvents,
        // Protected Fields API
        setOriginalRecordData,
        getOriginalRecordData,
        clearOriginalRecordData,
        getProtectedFields,
        validateProtectedFields,
        validateBeforeSave
    };
})();

// Expõe globalmente
window.SagEvents = SagEvents;
