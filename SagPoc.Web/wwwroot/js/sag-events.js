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

    /**
     * Inicializa o sistema de eventos PLSAG.
     * @param {Object} formEventsData - Eventos do formulário (ciclo de vida)
     * @param {Object} fieldEventsData - Eventos dos campos (indexado por CodiCamp)
     */
    function init(formEventsData, fieldEventsData) {
        if (initialized) {
            console.warn('[SagEvents] Já inicializado');
            return;
        }

        formEvents = formEventsData || {};
        fieldEvents = fieldEventsData || {};
        initialized = true;

        console.log('[SagEvents] Inicializando sistema de eventos PLSAG');
        console.log('[SagEvents] Form Events:', formEvents);
        console.log('[SagEvents] Field Events:', Object.keys(fieldEvents).length, 'campos');

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
     * Dispara um evento de campo (loga na Fase 1).
     */
    function fireFieldEvent(eventType, fieldName, codiCamp, instructions, domEvent) {
        const eventInfo = {
            type: eventType,
            field: fieldName,
            codiCamp: codiCamp,
            value: getElementValue(domEvent.target),
            instructions: instructions,
            timestamp: new Date().toISOString()
        };

        console.log(`[SagEvents] Campo ${fieldName} disparou ${eventType}:`, eventInfo);

        // Emite evento customizado para possível integração futura
        document.dispatchEvent(new CustomEvent('sag:field-event', {
            detail: eventInfo
        }));

        // TODO: Fase 2 - Executar instruções PLSAG
        // parsePlsag(instructions, eventInfo);
    }

    /**
     * Dispara um evento de formulário (loga na Fase 1).
     */
    function fireFormEvent(eventType, instructions) {
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

        // TODO: Fase 2 - Executar instruções PLSAG
        // parsePlsag(instructions, eventInfo);
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
     * @returns {boolean} true se pode continuar, false para cancelar
     */
    function beforeSave() {
        if (formEvents && formEvents.lancTabeInstructions) {
            fireFormEvent('LancTabe', formEvents.lancTabeInstructions);
        }
        // Fase 1: sempre retorna true (não bloqueia)
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

    // API pública
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
        bindAllFields
    };
})();

// Expõe globalmente
window.SagEvents = SagEvents;
