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
    let initialized = false;

    // Cache de elementos
    const boundElements = new Set();

    // Flag para saber se é INSERT (novo registro) ou EDIT (alteração)
    let isInsertMode = false;

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
     * Observa mudanças no DOM para vincular novos campos.
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
                        // Verifica filhos
                        const children = node.querySelectorAll?.('[data-sag-codicamp]');
                        if (children) {
                            children.forEach(bindField);
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

        // Executa LancTabe e verifica se foi bloqueado
        if (typeof PlsagInterpreter !== 'undefined') {
            try {
                const result = await PlsagInterpreter.execute(formEvents.lancTabeInstructions, {
                    type: 'form',
                    eventType: 'LancTabe',
                    codiTabe: formEvents?.codiTabe,
                    formData: collectFormData()
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

    // API publica
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
        collectFormData
    };
})();

// Expõe globalmente
window.SagEvents = SagEvents;
