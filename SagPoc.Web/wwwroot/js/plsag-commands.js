/**
 * PLSAG Commands - Handlers de comandos PLSAG
 *
 * Implementa os handlers para cada tipo de comando PLSAG:
 * - Comandos de Campo (CE, CN, CS, CM, CT, CF, CV + modificadores D/F/V/C/R)
 * - Comandos de Variavel (VA, VP, PU)
 * - Comandos de Mensagem (MA, MC, ME, MI, MP)
 * - Comandos de Query (QY, QN, QD, QM)
 * - Comandos de Gravacao (DG, DM, D2, D3)
 * - Comandos Especiais (EX-*)
 *
 * @version 1.0
 */
const PlsagCommands = (function() {
    'use strict';

    // ============================================================
    // FUNCOES AUXILIARES DE DOM
    // ============================================================

    /**
     * Encontra ou cria um campo hidden no formulário.
     * Usado quando um comando PLSAG (ex: DG-TIPOGERA) tenta setar um campo que não existe no form.
     * @param {string} fieldName - Nome do campo
     * @returns {HTMLElement} Campo hidden existente ou recém-criado
     */
    function getOrCreateHiddenField(fieldName) {
        const name = fieldName.trim().toUpperCase();
        const form = document.getElementById('dynamicForm') || document.querySelector('form');

        // Primeiro verifica se já existe um hidden com esse nome
        let hidden = form?.querySelector(`input[type="hidden"][name="${name}"]`);
        if (hidden) return hidden;

        // Cria um novo campo hidden
        hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = name;
        hidden.dataset.sagNomecamp = name;
        hidden.dataset.sagAutoCreated = 'true'; // Marca como criado automaticamente

        if (form) {
            form.appendChild(hidden);
            console.log(`[PLSAG] Campo hidden criado automaticamente: ${name}`);
        }

        return hidden;
    }

    /**
     * Encontra um componente de movimento pelo nome Delphi
     * Mapeia nomes como DBG<N>, BTNNOV<N>, BTNALT<N>, BTNEXC<N> para elementos do DOM
     * @param {string} componentName - Nome do componente Delphi (ex: DBG815, BTNNOV815)
     * @returns {HTMLElement|null} Elemento encontrado ou null
     */
    function findMovementComponent(componentName) {
        const name = componentName.trim().toUpperCase();

        // Padrões de componentes de movimento: DBG<N>, BTNNOV<N>, BTNALT<N>, BTNEXC<N>, BTNMES<N>
        const patterns = [
            { regex: /^DBG(\d+)$/, selector: (id) => `[data-movement="${id}"] table, [data-movement-table="${id}"]` },
            { regex: /^BTNNOV(\d+)$/, selector: (id) => `[data-movement="${id}"] .btn-add, [data-movement-add="${id}"]` },
            { regex: /^BTNALT(\d+)$/, selector: (id) => `[data-movement="${id}"] .btn-edit, [data-movement-edit="${id}"]` },
            { regex: /^BTNEXC(\d+)$/, selector: (id) => `[data-movement="${id}"] .btn-delete, [data-movement-delete="${id}"]` },
            { regex: /^BTNMES(\d+)$/, selector: (id) => `[data-movement="${id}"] .btn-mes, [data-movement-mes="${id}"]` },
            { regex: /^PNLMOV(\d+)$/, selector: (id) => `[data-movement-panel="${id}"], [data-movement="${id}"].movement-section, #movement-${id}` },
            { regex: /^TABMOV(\d+)$/, selector: (id) => `[data-movement="${id}"] .nav-tabs, #movement-tabs-${id}` }
        ];

        for (const pattern of patterns) {
            const match = name.match(pattern.regex);
            if (match) {
                const movementId = match[1];
                const selector = pattern.selector(movementId);
                const element = document.querySelector(selector);
                if (element) {
                    console.log(`[PLSAG] findMovementComponent: ${name} -> ${selector}`);
                    return element;
                }
            }
        }

        return null;
    }

    /**
     * Encontra um campo no formulario pelo nome
     * IMPORTANTE: Usa NAMECAMP (nome do componente visual) para busca, não NOMECAMP (nome do campo no banco)
     * No Delphi, FindComponent usa NAMECAMP. Campos duplicados (mesmo NOMECAMP) têm NAMECAMP diferentes.
     * Exemplo: PORTLESI aparece 2x no form 715, mas com NAMECAMP='PORTLESI' e NAMECAMP='POR_LESI'
     * @param {string} fieldName - Nome do componente (NAMECAMP)
     * @returns {HTMLElement|null} Elemento encontrado ou null
     */
    function findField(fieldName) {
        const name = fieldName.trim();

        // 0. Verifica se é componente de movimento (DBG<N>, BTNNOV<N>, etc.)
        const movementComponent = findMovementComponent(name);
        if (movementComponent) return movementComponent;

        // 1. Se modal de movimento está aberto, busca primeiro no modal
        const movementModal = document.getElementById('movementFormContent');
        if (movementModal && movementModal.offsetParent !== null) {
            // Modal está visível - busca campos dentro do modal primeiro
            let element = movementModal.querySelector(`[data-sag-namecamp="${name}"]`);
            if (element) return element;

            element = movementModal.querySelector(`[data-sag-nomecamp="${name}"]`);
            if (element) return element;

            element = movementModal.querySelector(`[name="${name}"]`);
            if (element) return element;

            element = movementModal.querySelector(`#mov_${name}`);
            if (element) return element;
        }

        // 2. Busca por data-sag-namecamp (NAMECAMP - nome do componente visual, usado pelo PLSAG)
        let element = document.querySelector(`[data-sag-namecamp="${name}"]`);
        if (element) return element;

        // 3. Fallback: Busca por data-sag-nomecamp (NOMECAMP - nome do campo no banco)
        element = document.querySelector(`[data-sag-nomecamp="${name}"]`);
        if (element) return element;

        // 4. Tenta por name attribute
        element = document.querySelector(`[name="${name}"]`);
        if (element) return element;

        // 5. Tenta por id (com prefixo field_)
        element = document.getElementById(`field_${name}`);
        if (element) return element;

        // 6. Tenta por id direto
        element = document.getElementById(name);
        if (element) return element;

        // 7. Tenta case-insensitive em data-sag-namecamp
        const allFields = document.querySelectorAll('[data-sag-namecamp], [data-sag-nomecamp], [name]');
        for (const field of allFields) {
            const sagNamecamp = field.dataset.sagNamecamp;
            if (sagNamecamp && sagNamecamp.toLowerCase() === name.toLowerCase()) {
                return field;
            }
        }

        // 8. Tenta case-insensitive em data-sag-nomecamp
        for (const field of allFields) {
            const sagNomecamp = field.dataset.sagNomecamp || field.name;
            if (sagNomecamp && sagNomecamp.toLowerCase() === name.toLowerCase()) {
                return field;
            }
        }

        return null;
    }

    /**
     * Encontra o container de um campo (para mostrar/esconder)
     * Retorna o field-wrapper, que é o container direto do campo.
     * Isso permite mostrar/esconder campos individuais mesmo quando estão na mesma row.
     * @param {string} fieldName - Nome do campo
     * @returns {HTMLElement|null} Container do campo ou null
     */
    function findFieldContainer(fieldName) {
        const field = findField(fieldName);
        if (!field) return null;

        // Primeiro tenta o field-wrapper (container individual do campo)
        const fieldWrapper = field.closest('.field-wrapper');
        if (fieldWrapper) return fieldWrapper;

        // Fallback: se não tiver field-wrapper, tenta field-row
        return field.closest('.field-row-single') ||
               field.closest('.field-row-multi') ||
               field.closest('.form-group') ||
               field.closest('.field-container') ||
               field.parentElement;
    }

    /**
     * Encontra um botao pelo nome/id
     * @param {string} buttonName - Nome do botao
     * @returns {HTMLElement|null}
     */
    function findButton(buttonName) {
        const name = buttonName.trim();

        return document.querySelector(`button[data-sag-button="${name}"]`) ||
               document.getElementById(`btn_${name}`) ||
               document.getElementById(name) ||
               document.querySelector(`button[name="${name}"]`);
    }

    /**
     * Encontra um label pelo nome/id
     * Labels sao elementos que exibem texto estatico (nao editavel)
     * @param {string} labelName - Nome do label
     * @returns {HTMLElement|null}
     */
    function findLabel(labelName) {
        const name = labelName.trim();

        // 1. Por data-sag-label
        let el = document.querySelector(`[data-sag-label="${name}"]`);
        if (el) return el;

        // 2. Por id com prefixo lbl_
        el = document.getElementById(`lbl_${name}`);
        if (el) return el;

        // 3. Por id direto
        el = document.getElementById(name);
        if (el) return el;

        // 4. Por for apontando para campo
        el = document.querySelector(`label[for="${name}"]`);
        if (el) return el;

        // 5. Label associado ao campo (label dentro do mesmo container)
        const field = findField(name);
        if (field) {
            const container = field.closest('.field-wrapper') || field.closest('.form-group');
            if (container) {
                el = container.querySelector('label');
                if (el) return el;
            }
        }

        return null;
    }

    /**
     * Garante que os containers pai (field-row, bevel-group, bevel-content) estejam visíveis
     * Quando um campo é mostrado, seus containers pai também precisam estar visíveis
     * @param {HTMLElement} element - Elemento a partir do qual buscar containers pai
     */
    function ensureParentGroupsVisible(element) {
        let parent = element.parentElement;
        while (parent) {
            // Verifica se é um container de grupo ou row
            const isContainer = parent.classList.contains('field-row-single') ||
                               parent.classList.contains('field-row-multi') ||
                               parent.classList.contains('field-row') ||
                               parent.classList.contains('bevel-content') ||
                               parent.classList.contains('bevel-group') ||
                               parent.classList.contains('orphan-fields') ||
                               parent.tagName === 'FIELDSET';

            if (isContainer) {
                // Remove estilos/classes que escondem
                parent.style.display = '';
                parent.classList.remove('hidden', 'd-none');
            }
            parent = parent.parentElement;
        }
    }

    /**
     * Executa disable/enable em componentes de movimento
     * @param {HTMLElement} element - Elemento de movimento
     * @param {boolean} enable - true = habilita, false = desabilita
     * @param {string} componentName - Nome do componente (DBG815, BTNNOV815, etc.)
     */
    function executeMovementDisable(element, enable, componentName) {
        const name = componentName.trim().toUpperCase();
        console.log(`[PLSAG] executeMovementDisable: ${name} -> ${enable ? 'enable' : 'disable'}`);

        // Detecta tipo de componente pelo nome ou atributos
        const isTable = name.startsWith('DBG') || element.tagName === 'TABLE' || element.dataset.movementTable;
        const isButton = name.startsWith('BTN') || element.tagName === 'BUTTON';
        const isPanel = name.startsWith('PNLMOV') || element.dataset.movementPanel;

        if (isTable) {
            // Para tabelas (DBG): desabilita toda a seção de movimento
            const movementSection = element.closest('.movement-section') || element.closest('[data-movement]');
            if (movementSection) {
                if (enable) {
                    movementSection.classList.remove('disabled', 'movement-disabled');
                    movementSection.style.pointerEvents = '';
                    movementSection.style.opacity = '';
                    // Habilita botões do grid
                    movementSection.querySelectorAll('button').forEach(btn => btn.disabled = false);
                } else {
                    movementSection.classList.add('disabled', 'movement-disabled');
                    movementSection.style.pointerEvents = 'none';
                    movementSection.style.opacity = '0.6';
                    // Desabilita botões do grid
                    movementSection.querySelectorAll('button').forEach(btn => btn.disabled = true);
                }
            }
        } else if (isButton) {
            // Para botões: toggle disabled
            element.disabled = !enable;
            if (enable) {
                element.classList.remove('disabled');
            } else {
                element.classList.add('disabled');
            }
        } else if (isPanel) {
            // Para painel: desabilita toda a seção
            if (enable) {
                element.classList.remove('disabled', 'movement-disabled');
                element.style.pointerEvents = '';
                element.style.opacity = '';
            } else {
                element.classList.add('disabled', 'movement-disabled');
                element.style.pointerEvents = 'none';
                element.style.opacity = '0.6';
            }
        } else {
            // Fallback: comportamento padrão
            element.disabled = !enable;
            if (enable) {
                element.classList.remove('disabled');
            } else {
                element.classList.add('disabled');
            }
        }
    }

    /**
     * Executa visible em componentes de movimento
     * @param {HTMLElement} element - Elemento de movimento
     * @param {boolean} visible - true = mostra, false = esconde
     * @param {string} componentName - Nome do componente (DBG815, BTNNOV815, etc.)
     */
    function executeMovementVisible(element, visible, componentName) {
        const name = componentName.trim().toUpperCase();
        console.log(`[PLSAG] executeMovementVisible: ${name} -> ${visible ? 'show' : 'hide'}`);

        // Detecta tipo de componente pelo nome ou atributos
        const isTable = name.startsWith('DBG') || element.tagName === 'TABLE' || element.dataset.movementTable;
        const isButton = name.startsWith('BTN') || element.tagName === 'BUTTON';
        const isPanel = name.startsWith('PNLMOV') || element.dataset.movementPanel;

        if (isTable || isPanel) {
            // Para tabelas ou painéis: esconde toda a seção de movimento
            const movementSection = element.closest('.movement-section') || element.closest('[data-movement]') || element;
            if (movementSection) {
                if (visible) {
                    movementSection.style.display = '';
                    movementSection.classList.remove('hidden', 'd-none');
                } else {
                    movementSection.style.display = 'none';
                    movementSection.classList.add('d-none');
                }
            }
        } else if (isButton) {
            // Para botões: esconde apenas o botão
            if (visible) {
                element.style.display = '';
                element.classList.remove('hidden', 'd-none');
            } else {
                element.style.display = 'none';
                element.classList.add('d-none');
            }
        } else {
            // Fallback: comportamento padrão
            if (visible) {
                element.style.display = '';
                element.classList.remove('hidden', 'd-none');
            } else {
                element.style.display = 'none';
                element.classList.add('d-none');
            }
        }
    }

    // ============================================================
    // COMANDOS DE CAMPO
    // ============================================================

    /**
     * Executa comando de campo
     * Prefixos: CE, CN, CS, CM, CT, CF, CV, IE, IN, IT, IM, IA
     * Modificadores: D (disable), F (focus), V (visible), C (color), R (readonly)
     * @param {string} prefix - Prefixo do comando (2 chars)
     * @param {string} identifier - Nome do campo
     * @param {string} parameter - Valor do parametro
     * @param {object} context - Contexto de execucao
     * @param {string} modifierFromParser - Modificador extraido pelo parser (opcional)
     */
    async function executeFieldCommand(prefix, identifier, parameter, context, modifierFromParser) {
        const fieldName = identifier;
        let element = findField(fieldName);

        // Detecta tipo base para decidir se deve criar campo hidden
        const baseType = prefix.substring(0, 2);
        const valueCommands = ['CE', 'CN', 'CS', 'CM', 'CT', 'CV', 'CC', 'CD', 'IE', 'IN', 'IT', 'IM'];

        if (!element) {
            // Para comandos que definem valor, cria um campo hidden automaticamente
            if (valueCommands.includes(baseType) && !modifierFromParser) {
                element = getOrCreateHiddenField(fieldName);
            } else {
                console.warn(`[PLSAG] Campo nao encontrado: ${fieldName}`);
                return;
            }
        }

        // Usa modificador do parser se disponivel (verifica se é string não-vazia), senao tenta extrair do prefix
        const modifier = (modifierFromParser && modifierFromParser.length > 0) ? modifierFromParser : (prefix.length > 2 ? prefix.charAt(2) : null);

        // Se tem modificador, executa acao do modificador
        if (modifier) {
            executeFieldModifier(element, modifier, parameter, fieldName);
            return;
        }

        // Executa comando base (define valor)
        switch (baseType) {
            case 'CE': // Campo Editor - define valor texto
            case 'IE': // Input Editor (sem banco)
            case 'LE': // Label Editor (campo calculado readonly)
                setFieldValue(element, parameter);
                break;

            case 'CN': // Campo Numerico - define valor numerico
            case 'IN': // Input Numerico
            case 'LN': // Label Numerico (campo calculado readonly)
                setFieldValue(element, formatNumber(parameter));
                break;

            case 'CS': // Campo Sim/Nao - checkbox
                if (element.type === 'checkbox') {
                    element.checked = isTruthy(parameter);
                } else {
                    setFieldValue(element, parameter);
                }
                break;

            case 'CM': // Campo Memo - texto longo
            case 'IM': // Input Memo
                setFieldValue(element, parameter);
                break;

            case 'CT': // Campo Tabela - lookup/combo
            case 'IT': // Input Tabela
                setFieldValue(element, parameter);
                // Dispara change para atualizar lookups
                element.dispatchEvent(new Event('change', { bubbles: true }));
                break;

            case 'CF': // Campo Foco
                element.focus();
                break;

            case 'CV': // Campo Valor (generico)
                setFieldValue(element, parameter);
                break;

            case 'CC': // Campo Combo
                setFieldValue(element, parameter);
                element.dispatchEvent(new Event('change', { bubbles: true }));
                break;

            case 'CD': // Campo Data
                setFieldValue(element, formatDate(parameter));
                break;

            case 'CA': // Campo Arquivo
            case 'EA': // Editor Arquivo
                // File inputs nao podem ter valor definido por seguranca
                // Apenas limpamos ou logamos
                if (parameter === '' || parameter === null) {
                    element.value = '';
                } else {
                    console.log(`[PLSAG] ${baseType}: Arquivo selecionado = ${parameter}`);
                }
                break;

            case 'CR': // Campo Formatado (com mascara)
                setFieldValue(element, applyMask(parameter, element.dataset.sagMask));
                break;

            case 'IL': // Lookup Numerico (similar a LN mas com lookup)
                setFieldValue(element, formatNumber(parameter));
                break;

            // ============================================================
            // EDITORES (campos volateis, sem banco)
            // ============================================================

            case 'EE': // Editor Text
                setFieldValue(element, parameter);
                break;

            case 'ES': // Editor Sim/Nao
                if (element.type === 'checkbox') {
                    element.checked = isTruthy(parameter);
                } else {
                    setFieldValue(element, parameter);
                }
                break;

            case 'ET': // Editor Memo
                setFieldValue(element, parameter);
                break;

            case 'EC': // Editor Combo
                setFieldValue(element, parameter);
                element.dispatchEvent(new Event('change', { bubbles: true }));
                break;

            case 'ED': // Editor Data
                setFieldValue(element, formatDate(parameter));
                break;

            case 'EI': // Editor Diretorio
                // Na web, trata como texto (path de diretorio)
                setFieldValue(element, parameter);
                break;

            case 'EL': // Editor Lookup
                setFieldValue(element, parameter);
                element.dispatchEvent(new Event('change', { bubbles: true }));
                break;

            default:
                console.warn(`[PLSAG] Tipo de campo desconhecido: ${baseType}`);
        }
    }

    /**
     * Executa modificador de campo
     * D = Disable/Enable, F = Focus, V = Visible, C = Color, R = Readonly
     * Suporta componentes de movimento: DBG<N>, BTNNOV<N>, BTNALT<N>, BTNEXC<N>, PNLMOV<N>
     */
    function executeFieldModifier(element, modifier, parameter, fieldName) {
        // Converte para string para suportar parâmetros numéricos (ex: resultado de IF())
        const value = parameter !== null && parameter !== undefined ? String(parameter).trim() : '';
        const isTrue = isTruthy(value);

        // Detecta se é componente de movimento
        const isMovementComponent = element.dataset.movementTable ||
                                    element.dataset.movementAdd ||
                                    element.dataset.movementEdit ||
                                    element.dataset.movementDelete ||
                                    element.dataset.movementPanel ||
                                    element.closest('[data-movement]');

        switch (modifier) {
            case 'D': // Disable/Enable
                // Para componentes de movimento, trata de forma especial
                if (isMovementComponent) {
                    executeMovementDisable(element, isTrue, fieldName);
                } else {
                    // Parametro: 0 = desabilita, != 0 = habilita
                    element.disabled = !isTrue;
                    if (isTrue) {
                        element.classList.remove('disabled');
                    } else {
                        element.classList.add('disabled');
                    }
                }
                break;

            case 'F': // Focus
                if (isTrue) {
                    element.focus();
                }
                break;

            case 'V': // Visible
                // Para componentes de movimento, usa o container de movimento
                if (isMovementComponent) {
                    executeMovementVisible(element, isTrue, fieldName);
                } else {
                    const container = findFieldContainer(fieldName);
                    if (container) {
                        // 0 = esconde, != 0 = mostra
                        if (isTrue) {
                            container.style.display = '';
                            container.classList.remove('hidden', 'd-none');
                            // Também mostra os containers pai (bevel-group/bevel-content)
                            // para garantir que o campo seja visível
                            ensureParentGroupsVisible(container);
                        } else {
                            container.style.display = 'none';
                            container.classList.add('hidden');
                        }
                    }
                }
                break;

            case 'C': // Color
                // Parametro: cor em formato hex ou nome
                if (value) {
                    element.style.backgroundColor = value.startsWith('#') ? value : `#${value}`;
                }
                break;

            case 'R': // Readonly
                element.readOnly = isTrue;
                if (isTrue) {
                    element.classList.add('readonly');
                } else {
                    element.classList.remove('readonly');
                }
                break;

            default:
                console.warn(`[PLSAG] Modificador desconhecido: ${modifier}`);
        }
    }

    /**
     * Define valor de um campo
     */
    function setFieldValue(element, value) {
        if (element.tagName === 'SELECT') {
            element.value = value;
            element.dispatchEvent(new Event('change', { bubbles: true }));
        } else if (element.type === 'checkbox') {
            element.checked = isTruthy(value);
            element.dispatchEvent(new Event('change', { bubbles: true }));
        } else {
            element.value = value ?? '';
            element.dispatchEvent(new Event('input', { bubbles: true }));
            element.dispatchEvent(new Event('change', { bubbles: true }));
        }
    }

    /**
     * Formata numero
     */
    function formatNumber(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }
        const num = parseFloat(String(value).replace(',', '.'));
        return isNaN(num) ? value : num.toString();
    }

    /**
     * Formata data para o formato do input date (YYYY-MM-DD)
     */
    function formatDate(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }
        const str = String(value).trim();

        // Se ja esta no formato YYYY-MM-DD
        if (/^\d{4}-\d{2}-\d{2}$/.test(str)) {
            return str;
        }

        // Formato DD/MM/YYYY
        if (/^\d{2}\/\d{2}\/\d{4}$/.test(str)) {
            const parts = str.split('/');
            return `${parts[2]}-${parts[1]}-${parts[0]}`;
        }

        // Formato YYYYMMDD
        if (/^\d{8}$/.test(str)) {
            return `${str.substring(0,4)}-${str.substring(4,6)}-${str.substring(6,8)}`;
        }

        // Tenta parsear como Date
        const date = new Date(str);
        if (!isNaN(date.getTime())) {
            return date.toISOString().split('T')[0];
        }

        return str;
    }

    /**
     * Aplica mascara de formatacao a um valor
     * @param {string} value - Valor a formatar
     * @param {string} mask - Mascara (ex: "###.###.###-##" para CPF)
     * @returns {string} Valor formatado
     */
    function applyMask(value, mask) {
        if (!value) return '';
        if (!mask) return String(value);

        const cleanValue = String(value).replace(/\D/g, '');
        let result = '';
        let valueIndex = 0;

        for (let i = 0; i < mask.length && valueIndex < cleanValue.length; i++) {
            const maskChar = mask[i];
            if (maskChar === '#' || maskChar === '9') {
                // Caractere numerico
                result += cleanValue[valueIndex];
                valueIndex++;
            } else if (maskChar === 'A' || maskChar === 'a') {
                // Caractere alfabetico - mantém o valor original se não for só números
                const originalValue = String(value);
                if (originalValue[valueIndex]) {
                    result += originalValue[valueIndex];
                    valueIndex++;
                }
            } else {
                // Caractere literal da mascara
                result += maskChar;
            }
        }

        return result;
    }

    /**
     * Verifica se valor e truthy
     */
    function isTruthy(value) {
        if (value === null || value === undefined) return false;
        if (value === '' || value === '0' || value === 0) return false;
        if (value === 'N' || value === 'n' || value === 'false') return false;
        if (value === false) return false;
        return true;
    }

    // ============================================================
    // COMANDOS DE LABEL (LB)
    // ============================================================

    /**
     * Executa comando de label
     * LB = Label (define caption/texto)
     * Modificadores: D (disable), V (visible), C (color)
     * @param {string} prefix - Prefixo do comando
     * @param {string} identifier - Nome do label
     * @param {string} parameter - Valor do parametro
     * @param {string} modifierFromParser - Modificador extraido pelo parser
     */
    async function executeLabelCommand(prefix, identifier, parameter, context, modifierFromParser) {
        const labelName = identifier.trim();
        const element = findLabel(labelName);

        if (!element) {
            console.warn(`[PLSAG] Label nao encontrado: ${labelName}`);
            return;
        }

        // Detecta modificador
        const modifier = (modifierFromParser && modifierFromParser.length > 0) ? modifierFromParser : (prefix.length > 2 ? prefix.charAt(2) : null);

        if (modifier) {
            const value = parameter !== null && parameter !== undefined ? String(parameter).trim() : '';
            const isTrue = isTruthy(value);

            switch (modifier) {
                case 'D': // Disable (visual only - labels nao tem disabled)
                    if (isTrue) {
                        element.classList.remove('disabled', 'text-muted');
                    } else {
                        element.classList.add('disabled', 'text-muted');
                    }
                    break;

                case 'V': // Visible
                    if (isTrue) {
                        element.style.display = '';
                        element.classList.remove('hidden', 'd-none');
                    } else {
                        element.style.display = 'none';
                        element.classList.add('hidden');
                    }
                    break;

                case 'C': // Color
                    if (value) {
                        element.style.color = value.startsWith('#') ? value : `#${value}`;
                    }
                    break;

                default:
                    console.warn(`[PLSAG] Modificador de label desconhecido: ${modifier}`);
            }
            return;
        }

        // Sem modificador: define o texto/caption
        element.textContent = parameter ?? '';
    }

    // ============================================================
    // COMANDOS DE BOTAO (BT)
    // ============================================================

    /**
     * Executa comando de botao
     * BT = Botao (define caption, enable, visible)
     * Modificadores: D (disable), V (visible), C (color)
     * @param {string} prefix - Prefixo do comando
     * @param {string} identifier - Nome do botao
     * @param {string} parameter - Valor do parametro
     * @param {string} modifierFromParser - Modificador extraido pelo parser
     */
    async function executeButtonCommand(prefix, identifier, parameter, context, modifierFromParser) {
        const buttonName = identifier.trim();
        const element = findButton(buttonName);

        if (!element) {
            console.warn(`[PLSAG] Botao nao encontrado: ${buttonName}`);
            return;
        }

        // Detecta modificador
        const modifier = (modifierFromParser && modifierFromParser.length > 0) ? modifierFromParser : (prefix.length > 2 ? prefix.charAt(2) : null);

        if (modifier) {
            const value = parameter !== null && parameter !== undefined ? String(parameter).trim() : '';
            const isTrue = isTruthy(value);

            switch (modifier) {
                case 'D': // Disable/Enable
                    element.disabled = !isTrue;
                    if (isTrue) {
                        element.classList.remove('disabled');
                    } else {
                        element.classList.add('disabled');
                    }
                    break;

                case 'V': // Visible
                    if (isTrue) {
                        element.style.display = '';
                        element.classList.remove('hidden', 'd-none');
                    } else {
                        element.style.display = 'none';
                        element.classList.add('hidden');
                    }
                    break;

                case 'C': // Color
                    if (value) {
                        element.style.backgroundColor = value.startsWith('#') ? value : `#${value}`;
                    }
                    break;

                default:
                    console.warn(`[PLSAG] Modificador de botao desconhecido: ${modifier}`);
            }
            return;
        }

        // Sem modificador: define o caption/texto do botao
        element.textContent = parameter ?? '';
    }

    /**
     * Executa comandos de acao de botao (BO, BC, BF)
     * BO = Button OK/Confirm - clica programaticamente no botao Confirmar
     * BC = Button Cancel - clica programaticamente no botao Cancelar
     * BF = Button Finish - controla quais botoes mostrar
     *
     * Formato: BO-IDENTIFIER-CONDITION onde CONDITION=0 executa o botao
     * BF: CONDITION=0 mostra so botao Fechar, CONDITION=1 mostra Confirmar+Cancelar
     *
     * @returns {string|null} 'STOP' se deve parar execucao
     */
    async function executeButtonActionCommand(prefix, identifier, parameter, context) {
        // Avalia a condicao - se parameter eh SQL, executa; senao, usa valor direto
        let condition = 0;

        if (parameter) {
            const paramStr = String(parameter).trim();

            if (paramStr.toUpperCase().startsWith('SELECT')) {
                // Executa query para obter condicao
                try {
                    const response = await fetch('/api/plsag/query', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ sql: paramStr, singleRow: true })
                    });

                    if (response.ok) {
                        const result = await response.json();
                        if (result.success && result.data) {
                            condition = parseFloat(result.data[Object.keys(result.data)[0]]) || 0;
                        }
                    }
                } catch (error) {
                    console.warn(`[PLSAG] ${prefix}: Erro executando query condicao:`, error);
                }
            } else {
                // Valor numerico direto
                condition = parseFloat(paramStr) || 0;
            }
        }

        console.log(`[PLSAG] ${prefix}: Condicao avaliada = ${condition}`);

        // Executa acao baseado na condicao
        // No Delphi, se condicao = 0, executa o botao
        if (condition === 0) {
            switch (prefix) {
                case 'BO': // Button OK/Confirm
                    return executeConfirmButton(context);

                case 'BC': // Button Cancel
                    return executeCancelButton(context);

                case 'BF': // Button Finish - condicao 0 = so mostra Fechar
                    setButtonVisibility('close-only', context);
                    return null;
            }
        } else {
            // Condicao != 0
            if (prefix === 'BF') {
                // BF com condicao != 0 = mostra Confirmar + Cancelar
                setButtonVisibility('confirm-cancel', context);
            }
            // BO/BC com condicao != 0 = nao executa, apenas continua
            return null;
        }

        return null;
    }

    /**
     * Simula click no botao Confirmar
     * Busca BtnConf, BtnGrava, ou botao de salvar no formulario
     */
    function executeConfirmButton(context) {
        const confirmSelectors = [
            'button[data-sag-button="BtnConf"]',
            'button[data-sag-button="BtnGrava"]',
            '#btn_confirmar',
            '#btn_gravar',
            '#btn_salvar',
            '.btn-confirm',
            '.btn-save',
            'button[type="submit"]'
        ];

        for (const selector of confirmSelectors) {
            const btn = document.querySelector(selector);
            if (btn && btn.offsetParent !== null) { // visivel
                console.log(`[PLSAG] BO: Clicando em ${selector}`);
                btn.click();
                return 'STOP'; // Para execucao apos confirmar
            }
        }

        console.warn('[PLSAG] BO: Botao Confirmar nao encontrado');
        return null;
    }

    /**
     * Simula click no botao Cancelar
     * Busca BtnCanc, ou botao de cancelar no formulario
     */
    function executeCancelButton(context) {
        const cancelSelectors = [
            'button[data-sag-button="BtnCanc"]',
            '#btn_cancelar',
            '.btn-cancel',
            '.btn-secondary[data-dismiss="modal"]',
            'button[type="button"].btn-cancel'
        ];

        for (const selector of cancelSelectors) {
            const btn = document.querySelector(selector);
            if (btn && btn.offsetParent !== null) { // visivel
                console.log(`[PLSAG] BC: Clicando em ${selector}`);
                btn.click();
                return 'STOP'; // Para execucao apos cancelar
            }
        }

        console.warn('[PLSAG] BC: Botao Cancelar nao encontrado');
        return null;
    }

    /**
     * Controla visibilidade dos botoes do formulario
     * @param {string} mode - 'close-only' ou 'confirm-cancel'
     */
    function setButtonVisibility(mode, context) {
        const confirmBtn = document.querySelector('button[data-sag-button="BtnConf"], #btn_confirmar, .btn-confirm');
        const cancelBtn = document.querySelector('button[data-sag-button="BtnCanc"], #btn_cancelar, .btn-cancel');
        const closeBtn = document.querySelector('button[data-sag-button="BtnFech"], #btn_fechar, .btn-close-form');

        if (mode === 'close-only') {
            // Esconde Confirmar/Cancelar, mostra Fechar
            if (confirmBtn) confirmBtn.style.display = 'none';
            if (cancelBtn) cancelBtn.style.display = 'none';
            if (closeBtn) closeBtn.style.display = '';
            console.log('[PLSAG] BF: Modo close-only (so botao Fechar)');
        } else if (mode === 'confirm-cancel') {
            // Mostra Confirmar/Cancelar, esconde Fechar
            if (confirmBtn) confirmBtn.style.display = '';
            if (cancelBtn) cancelBtn.style.display = '';
            if (closeBtn) closeBtn.style.display = 'none';
            console.log('[PLSAG] BF: Modo confirm-cancel (Confirmar + Cancelar)');
        }

        // Salva estado no contexto para referencia futura
        if (context && context.system) {
            context.system.buttonMode = mode;
        }
    }

    // ============================================================
    // COMANDOS DE VARIAVEL
    // ============================================================

    /**
     * Executa comando de variavel
     * VA = Variable Assign (local)
     * VP = Variable Persistent (sessao)
     * PU = Public (global)
     */
    async function executeVariableCommand(prefix, identifier, parameter, context) {
        const varName = identifier.trim();
        let value = parameter;

        // Avalia expressao se tiver operadores aritmeticos
        if (parameter && /[\+\-\*\/]/.test(parameter)) {
            value = PlsagInterpreter.evaluateArithmetic(parameter);
        }

        switch (prefix) {
            case 'VA': // Variable Assign - variavel local
                PlsagInterpreter.setVariable(varName, value);
                break;

            case 'VP': // Variable Persistent - persiste na sessao
                PlsagInterpreter.setVariable(varName, value);
                try {
                    sessionStorage.setItem(`plsag_vp_${varName}`, JSON.stringify(value));
                } catch (e) {
                    console.warn('[PLSAG] Erro ao persistir variavel VP:', e);
                }
                break;

            case 'PU': // Public - variavel global (entre formularios)
                context.public[varName] = value;
                try {
                    sessionStorage.setItem(`plsag_pu_${varName}`, JSON.stringify(value));
                } catch (e) {
                    console.warn('[PLSAG] Erro ao persistir variavel PU:', e);
                }
                break;
        }
    }

    // ============================================================
    // COMANDOS DE MENSAGEM
    // ============================================================

    /**
     * Executa comando de mensagem
     * MA = Message Alert
     * MB = Message Button (info modal, para execucao igual ME)
     * MC = Message Confirm (retorna S ou N)
     * ME = Message Error (para execucao) - pode ter query SQL
     * MI = Message Info
     * MP = Message Prompt (entrada do usuario)
     */
    async function executeMessageCommand(prefix, identifier, parameter, context) {
        const message = parameter || identifier;

        switch (prefix) {
            case 'MA': // Alert
                await showModal('alert', message);
                return null;

            case 'MB': // Message Button - exibe info e para execucao (igual ME mas com icone info)
                return await executeMbCommand(identifier, parameter, context);

            case 'MC': // Confirm
                const confirmed = await showModal('confirm', message);
                return confirmed ? 'S' : 'N';

            case 'ME': // Error (para execucao) - pode ter query SQL
                return await executeMeCommand(identifier, parameter, context);

            case 'MI': // Info
                await showModal('info', message);
                return null;

            case 'MP': // Prompt
                const input = await showModal('prompt', message);
                PlsagInterpreter.setVariable(identifier.trim(), input);
                return input;
        }
    }

    /**
     * Executa comando ME (Message Error) com suporte a validacao SQL.
     * Formato: ME-CAMPO---SELECT...AS VALO|||Mensagem de erro
     *
     * Se query retornar 0, mostra mensagem e retorna 'STOP' para parar execucao.
     * Se query retornar 1 (ou qualquer outro valor), continua sem mostrar mensagem.
     *
     * @returns {string|null} 'STOP' se deve parar, null se deve continuar
     */
    async function executeMeCommand(identifier, parameter, context) {
        // Garante que parameter é string (pode vir como número após avaliação IF)
        const paramStr = parameter != null ? String(parameter) : '';

        // ME-CT com resultado condicional (0 = erro, 1 = ok)
        // Quando IF retorna 1, significa que a validação passou - não mostra nada
        if (paramStr === '1' || paramStr === 'true') {
            console.log(`[PLSAG] ME: Validação condicional OK (${paramStr}), continuando`);
            return 'CONTINUE';
        }

        // Verifica se tem query SQL com mensagem separada por |||
        if (paramStr && paramStr.includes('|||')) {
            const parts = paramStr.split('|||');
            const query = parts[0].trim();
            const errorMessage = parts[1].trim();

            // Verifica se e uma query SELECT
            if (query.toUpperCase().startsWith('SELECT')) {
                try {
                    // Converte sintaxe Oracle para SQL Server
                    let sql = convertOracleToSqlServer(query);

                    console.log(`[PLSAG] ME: Executando validacao: ${sql}`);

                    const response = await fetch('/api/plsag/query', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ sql: sql, singleRow: true })
                    });

                    if (response.ok) {
                        const result = await response.json();
                        if (result.success && result.data) {
                            // Pega o valor VALO ou o primeiro campo
                            const value = result.data.VALO ?? result.data.valo ??
                                          result.data[Object.keys(result.data)[0]];

                            console.log(`[PLSAG] ME: Resultado validacao = ${value}`);

                            // Se valor = 0 (ou falsy diferente de string), mostra erro
                            if (value === 0 || value === '0' || value === false) {
                                await showModal('error', errorMessage);
                                return 'STOP'; // Sinaliza para parar execucao
                            } else {
                                // Validacao passou, continua sem mostrar mensagem
                                console.log(`[PLSAG] ME: Validacao OK, continuando`);
                                return 'CONTINUE'; // Sinaliza para continuar
                            }
                        }
                    }

                    // Se query falhou (erro de sintaxe, tabela nao existe, etc),
                    // NAO bloqueia - apenas loga e continua (validacao nao pode ser feita)
                    console.warn(`[PLSAG] ME: Query falhou (erro de SQL), continuando sem validacao`);
                    return 'CONTINUE';

                } catch (error) {
                    // Erro de rede ou outro - continua sem bloquear
                    console.warn(`[PLSAG] ME: Erro executando validacao, continuando:`, error);
                    return 'CONTINUE';
                }
            }
        }

        // ME-CT com resultado condicional 0 = erro (mas sem mensagem específica)
        if (paramStr === '0' || paramStr === 'false') {
            console.log(`[PLSAG] ME: Validação condicional FALHOU (${paramStr}), bloqueando`);
            // Não mostra modal aqui - a mensagem pode estar em outra instrução
            return 'STOP';
        }

        // Fallback: ME simples sem query, mostra mensagem diretamente
        const message = paramStr || identifier;
        await showModal('error', message);
        return 'STOP';
    }

    /**
     * Executa comando MB (Message Button) com suporte a validacao SQL.
     * Similar a ME, mas exibe mensagem com icone de informacao (mtInformation).
     * Formato: MB-CAMPO---SELECT...AS VALO|||Mensagem
     *
     * Se query retornar 0, mostra mensagem (info) e retorna 'STOP' para parar execucao.
     * Se query retornar 1 (ou qualquer outro valor), continua sem mostrar mensagem.
     *
     * @returns {string|null} 'STOP' se deve parar, null se deve continuar
     */
    async function executeMbCommand(identifier, parameter, context) {
        // Garante que parameter é string (pode vir como número após avaliação IF)
        const paramStr = parameter != null ? String(parameter) : '';

        // MB com resultado condicional (0 = info, 1 = ok)
        if (paramStr === '1' || paramStr === 'true') {
            console.log(`[PLSAG] MB: Validação condicional OK (${paramStr}), continuando`);
            return 'CONTINUE';
        }

        // Verifica se tem query SQL com mensagem separada por |||
        if (paramStr && paramStr.includes('|||')) {
            const parts = paramStr.split('|||');
            const query = parts[0].trim();
            const infoMessage = parts[1].trim();

            // Verifica se e uma query SELECT
            if (query.toUpperCase().startsWith('SELECT')) {
                try {
                    // Converte sintaxe Oracle para SQL Server
                    let sql = convertOracleToSqlServer(query);

                    console.log(`[PLSAG] MB: Executando validacao: ${sql}`);

                    const response = await fetch('/api/plsag/query', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ sql: sql, singleRow: true })
                    });

                    if (response.ok) {
                        const result = await response.json();
                        if (result.success && result.data) {
                            // Pega o valor VALO ou o primeiro campo
                            const value = result.data.VALO ?? result.data.valo ??
                                          result.data[Object.keys(result.data)[0]];

                            console.log(`[PLSAG] MB: Resultado validacao = ${value}`);

                            // Se valor = 0 (ou falsy diferente de string), mostra mensagem info
                            if (value === 0 || value === '0' || value === false) {
                                await showModal('info', infoMessage);
                                return 'STOP'; // Sinaliza para parar execucao
                            } else {
                                // Validacao passou, continua sem mostrar mensagem
                                console.log(`[PLSAG] MB: Validacao OK, continuando`);
                                return 'CONTINUE';
                            }
                        }
                    }

                    // Se query falhou, NAO bloqueia - apenas loga e continua
                    console.warn(`[PLSAG] MB: Query falhou (erro de SQL), continuando sem validacao`);
                    return 'CONTINUE';

                } catch (error) {
                    console.warn(`[PLSAG] MB: Erro executando validacao, continuando:`, error);
                    return 'CONTINUE';
                }
            }
        }

        // MB com resultado condicional 0 = info (mas sem mensagem específica)
        if (paramStr === '0' || paramStr === 'false') {
            console.log(`[PLSAG] MB: Validação condicional FALHOU (${paramStr}), bloqueando`);
            return 'STOP';
        }

        // Fallback: MB simples sem query, mostra mensagem info diretamente
        const message = paramStr || identifier;
        await showModal('info', message);
        return 'STOP';
    }

    /**
     * Exibe modal de mensagem
     * @param {string} type - Tipo: alert, confirm, error, info, prompt
     * @param {string} message - Mensagem a exibir
     * @returns {Promise<boolean|string>} Resultado
     */
    async function showModal(type, message) {
        // Verifica se existe modal customizado do Vision
        const customModal = document.getElementById('sagMessageModal');

        if (customModal) {
            return showVisionModal(type, message, customModal);
        }

        // Fallback para dialogs nativos
        return new Promise((resolve) => {
            switch (type) {
                case 'confirm':
                    resolve(confirm(message));
                    break;
                case 'prompt':
                    resolve(prompt(message) || '');
                    break;
                case 'error':
                    alert('ERRO: ' + message);
                    resolve(null);
                    break;
                case 'info':
                case 'alert':
                default:
                    alert(message);
                    resolve(null);
                    break;
            }
        });
    }

    /**
     * Exibe modal Vision customizado
     */
    function showVisionModal(type, message, modalElement) {
        return new Promise((resolve) => {
            const titleEl = modalElement.querySelector('.modal-title');
            const bodyEl = modalElement.querySelector('.modal-body');
            const confirmBtn = modalElement.querySelector('.btn-confirm');
            const cancelBtn = modalElement.querySelector('.btn-cancel');
            const inputEl = modalElement.querySelector('input');

            // Configura titulo
            const titles = {
                alert: 'Aviso',
                confirm: 'Confirmacao',
                error: 'Erro',
                info: 'Informacao',
                prompt: 'Entrada'
            };
            if (titleEl) {
                titleEl.textContent = titles[type] || 'Mensagem';
            }

            // Configura corpo
            if (bodyEl) {
                bodyEl.innerHTML = `<p>${escapeHtml(message)}</p>`;
                if (type === 'prompt' && inputEl) {
                    inputEl.value = '';
                    inputEl.style.display = '';
                } else if (inputEl) {
                    inputEl.style.display = 'none';
                }
            }

            // Configura botoes
            if (type === 'confirm' || type === 'prompt') {
                if (cancelBtn) cancelBtn.style.display = '';
            } else {
                if (cancelBtn) cancelBtn.style.display = 'none';
            }

            // Handlers
            const handleConfirm = () => {
                cleanup();
                if (type === 'prompt') {
                    resolve(inputEl ? inputEl.value : '');
                } else if (type === 'confirm') {
                    resolve(true);
                } else {
                    resolve(null);
                }
            };

            const handleCancel = () => {
                cleanup();
                if (type === 'confirm') {
                    resolve(false);
                } else {
                    resolve('');
                }
            };

            const cleanup = () => {
                if (confirmBtn) confirmBtn.removeEventListener('click', handleConfirm);
                if (cancelBtn) cancelBtn.removeEventListener('click', handleCancel);
                // Fecha modal Bootstrap
                const bsModal = bootstrap?.Modal?.getInstance(modalElement);
                if (bsModal) {
                    bsModal.hide();
                }
            };

            if (confirmBtn) confirmBtn.addEventListener('click', handleConfirm);
            if (cancelBtn) cancelBtn.addEventListener('click', handleCancel);

            // Abre modal Bootstrap
            if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                const bsModal = new bootstrap.Modal(modalElement);
                bsModal.show();
            } else {
                modalElement.style.display = 'block';
                modalElement.classList.add('show');
            }
        });
    }

    /**
     * Escapa HTML para prevenir XSS
     */
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // ============================================================
    // COMANDOS DE QUERY (Server-side)
    // ============================================================

    /**
     * Executa comando de query
     * QY = Query Yes (single row) ou navegacao
     * QN = Query N-lines (multi row)
     * QD = Query Delete
     * QM = Query Modify
     *
     * Comandos de navegacao (no parametro):
     * - ABRE = Abre/reabre query
     * - FECH = Fecha query
     * - PRIM = First() - vai para primeiro registro
     * - PROX = Next() - proximo registro
     * - ANTE = Prior() - registro anterior
     * - ULTI = FindLast() - ultimo registro
     *
     * Comandos de edicao (no parametro):
     * - EDIT = Coloca query em modo edicao
     * - INSE = Coloca query em modo insercao
     * - POST = Posta alteracoes da query
     */
    async function executeQueryCommand(prefix, identifier, parameter, context) {
        const queryName = identifier.trim();
        const command = (parameter || '').trim().toUpperCase();

        // Comandos de navegacao
        const navCommands = ['ABRE', 'FECH', 'PRIM', 'PROX', 'ANTE', 'ULTI'];
        if (navCommands.includes(command)) {
            await executeQueryNavigation(queryName, command, context);
            return;
        }

        // Comandos de edicao de dataset
        const editCommands = ['EDIT', 'INSE', 'POST'];
        if (editCommands.includes(command)) {
            await executeQueryEditMode(queryName, command, context);
            return;
        }

        // Se parametro parece um SELECT, e uma query normal
        // Armazena SQL para permitir ABRE posteriormente
        if (parameter && parameter.trim().toUpperCase().startsWith('SELECT')) {
            context.queryDefinitions = context.queryDefinitions || {};
            context.queryDefinitions[queryName] = parameter;
        }

        // SEGURANCA: NAO enviamos SQL bruto do frontend
        // O backend deve buscar o SQL do banco pela referencia

        try {
            const response = await fetch('/api/plsag/query', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    queryName: queryName,
                    type: prefix === 'QN' ? 'multi' : 'single',
                    codiTabe: context.tableId,
                    params: context.formData
                })
            });

            if (!response.ok) {
                console.error(`[PLSAG] Erro na query ${queryName}: ${response.status}`);
                return;
            }

            const result = await response.json();

            if (result.success) {
                if (prefix === 'QN') {
                    // Multi-row: armazena array
                    context.queryMultiResults[queryName] = result.data;
                    // Primeiro registro no queryResults
                    if (result.data && result.data.length > 0) {
                        context.queryResults[queryName] = result.data[0];
                    }
                } else {
                    // Single-row
                    context.queryResults[queryName] = result.data || {};
                }
            }
        } catch (error) {
            console.error(`[PLSAG] Erro ao executar query ${queryName}:`, error);
        }
    }

    /**
     * Executa comandos de navegacao de query
     * @param {string} queryName - Nome da query
     * @param {string} command - Comando (ABRE, FECH, PRIM, PROX, ANTE, ULTI)
     * @param {object} context - Contexto de execucao
     */
    async function executeQueryNavigation(queryName, command, context) {
        console.log(`[PLSAG] QY-${queryName}: ${command}`);

        // Inicializa estruturas se nao existirem
        context.queryCursors = context.queryCursors || {};
        context.queryDefinitions = context.queryDefinitions || {};

        let cursor = context.queryCursors[queryName];

        // Reset flags
        context.system.EOF = false;
        context.system.BOF = false;

        switch (command) {
            case 'ABRE':
                // Abre/reabre a query - busca dados do servidor
                try {
                    const querySql = context.queryDefinitions[queryName];
                    if (!querySql) {
                        console.warn(`[PLSAG] QY-${queryName}-ABRE: SQL da query nao encontrado`);
                        return;
                    }

                    // Substitui templates no SQL
                    const resolvedSql = PlsagInterpreter.substituteTemplatesForSQL
                        ? PlsagInterpreter.substituteTemplatesForSQL(querySql)
                        : querySql;

                    const response = await fetch('/api/plsag/query', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            sql: resolvedSql,
                            type: 'multi',
                            codiTabe: context.tableId,
                            params: context.formData
                        })
                    });

                    if (response.ok) {
                        const result = await response.json();
                        if (result.success && result.data) {
                            const data = Array.isArray(result.data) ? result.data : [result.data];
                            context.queryCursors[queryName] = {
                                data: data,
                                index: 0,
                                isOpen: true,
                                sql: querySql
                            };

                            // Carrega primeiro registro no contexto
                            if (data.length > 0) {
                                context.queryResults[queryName] = data[0];
                            } else {
                                context.queryResults[queryName] = {};
                                context.system.EOF = true;
                            }

                            console.log(`[PLSAG] QY-${queryName}-ABRE: ${data.length} registros carregados`);
                        }
                    }
                } catch (error) {
                    console.error(`[PLSAG] QY-${queryName}-ABRE: Erro`, error);
                }
                break;

            case 'FECH':
                // Fecha a query
                if (cursor) {
                    cursor.isOpen = false;
                    delete context.queryCursors[queryName];
                    delete context.queryResults[queryName];
                    console.log(`[PLSAG] QY-${queryName}-FECH: Query fechada`);
                }
                break;

            case 'PRIM':
                // Primeiro registro
                if (cursor && cursor.isOpen && cursor.data.length > 0) {
                    cursor.index = 0;
                    context.queryResults[queryName] = cursor.data[0];
                    context.system.BOF = true;
                    console.log(`[PLSAG] QY-${queryName}-PRIM: Registro 1/${cursor.data.length}`);
                } else {
                    context.system.EOF = true;
                    context.system.BOF = true;
                }
                break;

            case 'PROX':
                // Proximo registro
                if (cursor && cursor.isOpen) {
                    if (cursor.index < cursor.data.length - 1) {
                        cursor.index++;
                        context.queryResults[queryName] = cursor.data[cursor.index];
                        console.log(`[PLSAG] QY-${queryName}-PROX: Registro ${cursor.index + 1}/${cursor.data.length}`);
                    } else {
                        context.system.EOF = true;
                        console.log(`[PLSAG] QY-${queryName}-PROX: Fim dos registros (EOF)`);
                    }
                }
                break;

            case 'ANTE':
                // Registro anterior
                if (cursor && cursor.isOpen) {
                    if (cursor.index > 0) {
                        cursor.index--;
                        context.queryResults[queryName] = cursor.data[cursor.index];
                        console.log(`[PLSAG] QY-${queryName}-ANTE: Registro ${cursor.index + 1}/${cursor.data.length}`);
                    } else {
                        context.system.BOF = true;
                        console.log(`[PLSAG] QY-${queryName}-ANTE: Inicio dos registros (BOF)`);
                    }
                }
                break;

            case 'ULTI':
                // Ultimo registro
                if (cursor && cursor.isOpen && cursor.data.length > 0) {
                    cursor.index = cursor.data.length - 1;
                    context.queryResults[queryName] = cursor.data[cursor.index];
                    context.system.EOF = true;
                    console.log(`[PLSAG] QY-${queryName}-ULTI: Registro ${cursor.index + 1}/${cursor.data.length}`);
                } else {
                    context.system.EOF = true;
                    context.system.BOF = true;
                }
                break;
        }
    }

    /**
     * Executa comandos de modo de edicao de query
     * @param {string} queryName - Nome da query/dataset
     * @param {string} command - Comando (EDIT, INSE, POST)
     * @param {object} context - Contexto de execucao
     */
    async function executeQueryEditMode(queryName, command, context) {
        console.log(`[PLSAG] QY-${queryName}: ${command}`);

        // Inicializa estruturas se nao existirem
        context.queryStates = context.queryStates || {};
        context.queryPendingChanges = context.queryPendingChanges || {};

        switch (command) {
            case 'EDIT':
                // Coloca query em modo edicao
                // Em web, isso habilita a edicao do registro atual
                context.queryStates[queryName] = 'edit';

                // Ativa modo de edicao no formulario se for a query principal
                if (typeof window.enableEditMode === 'function') {
                    window.enableEditMode();
                }

                // Emite evento para permitir personalizacao
                document.dispatchEvent(new CustomEvent('sag:query-edit', {
                    detail: { queryName, context }
                }));

                console.log(`[PLSAG] QY-${queryName}-EDIT: Modo edicao ativado`);
                break;

            case 'INSE':
                // Coloca query em modo insercao
                // Em web, isso cria um novo registro vazio para edicao
                context.queryStates[queryName] = 'insert';

                // Limpa dados anteriores do registro
                context.queryResults[queryName] = {};
                context.queryPendingChanges[queryName] = {};

                // Ativa modo de inclusao no formulario se for a query principal
                if (typeof window.enableInsertMode === 'function') {
                    window.enableInsertMode();
                }

                // Emite evento para permitir personalizacao
                document.dispatchEvent(new CustomEvent('sag:query-insert', {
                    detail: { queryName, context }
                }));

                console.log(`[PLSAG] QY-${queryName}-INSE: Modo insercao ativado`);
                break;

            case 'POST':
                // Posta alteracoes da query
                // Em web, envia as alteracoes para o servidor
                const state = context.queryStates[queryName];
                const pendingData = context.queryPendingChanges[queryName] || context.queryResults[queryName];

                if (!pendingData || Object.keys(pendingData).length === 0) {
                    console.warn(`[PLSAG] QY-${queryName}-POST: Nenhum dado para postar`);
                    break;
                }

                try {
                    const response = await fetch('/api/plsag/query-post', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            queryName: queryName,
                            mode: state || 'edit',
                            data: pendingData,
                            codiTabe: context.tableId
                        })
                    });

                    if (response.ok) {
                        const result = await response.json();
                        if (result.success) {
                            console.log(`[PLSAG] QY-${queryName}-POST: Alteracoes postadas com sucesso`);

                            // Limpa estado de edicao
                            context.queryStates[queryName] = 'browse';
                            context.queryPendingChanges[queryName] = {};

                            // Se recebeu dados de volta (ex: ID gerado), atualiza contexto
                            if (result.data) {
                                context.queryResults[queryName] = {
                                    ...context.queryResults[queryName],
                                    ...result.data
                                };
                            }

                            // Emite evento de sucesso
                            document.dispatchEvent(new CustomEvent('sag:query-posted', {
                                detail: { queryName, success: true, data: result.data }
                            }));
                        } else {
                            console.error(`[PLSAG] QY-${queryName}-POST: Erro - ${result.message}`);

                            // Emite evento de erro
                            document.dispatchEvent(new CustomEvent('sag:query-post-error', {
                                detail: { queryName, error: result.message }
                            }));
                        }
                    } else {
                        console.error(`[PLSAG] QY-${queryName}-POST: HTTP ${response.status}`);
                    }
                } catch (error) {
                    console.error(`[PLSAG] QY-${queryName}-POST: Erro`, error);
                }
                break;
        }
    }

    // ============================================================
    // COMANDOS DE GRAVACAO (Server-side)
    // ============================================================

    /**
     * Executa comando de gravacao
     * DG = Data Grava (cabecalho)
     * DM = Data Movimento 1
     * D2 = Data Movimento 2
     * D3 = Data Movimento 3
     * DD = Data Detail (sem modificador = mesmo que DG, vai para header)
     *      No Delphi, DD em contexto de movimento vai para o form pai.
     *      Na web, tratamos DD igual a DG pois o header é sempre acessível.
     *
     * Se o parametro for uma query SQL (SELECT...), executa a query
     * e usa o resultado como valor do campo.
     */
    async function executeDataCommand(prefix, identifier, parameter, context) {
        // DD sem modificador é tratado como DG (header)
        const effectivePrefix = prefix === 'DD' ? 'DG' : prefix;
        // Label para logs: mostra DD->DG quando há conversão
        const logPrefix = prefix === 'DD' ? 'DD->DG' : prefix;
        const fieldName = identifier.trim();
        // Valor original do formulario (fallback)
        const originalValue = context.formData[fieldName] || '';
        let value = originalValue;
        let queryExecuted = false;

        // Se o parametro for uma query SQL, executa no servidor
        const paramStr = parameter !== null && parameter !== undefined ? String(parameter) : '';
        if (paramStr.trim().toUpperCase().startsWith('SELECT')) {
            try {
                // Converte sintaxe Oracle para SQL Server
                let sql = convertOracleToSqlServer(parameter);

                console.log(`[PLSAG] ${logPrefix}: Executando query para ${fieldName}: ${sql}`);

                const response = await fetch('/api/plsag/query', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ sql: sql, singleRow: true })
                });

                if (response.ok) {
                    const result = await response.json();
                    if (result.success && result.data) {
                        // Pega o primeiro valor do resultado
                        const firstKey = Object.keys(result.data)[0];
                        value = result.data[firstKey];
                        queryExecuted = true;
                        console.log(`[PLSAG] ${logPrefix}: ${fieldName} = ${value} (via query)`);
                    } else {
                        console.warn(`[PLSAG] ${logPrefix}: Query sem resultado para ${fieldName}, mantendo valor original: ${originalValue}`);
                    }
                } else {
                    console.warn(`[PLSAG] ${logPrefix}: Query falhou para ${fieldName}, mantendo valor original: ${originalValue}`);
                }
            } catch (error) {
                console.error(`[PLSAG] ${logPrefix}: Erro executando query, mantendo valor original:`, error);
            }
        } else if (parameter) {
            // Parametro nao-SQL: usa como valor direto (expressao ja avaliada)
            value = parameter;
        }

        // Atualiza no contexto
        context.formData[fieldName] = value;

        // Atualiza o campo no DOM (ou cria hidden field se não existe)
        let element = findField(fieldName);
        if (!element) {
            // Campo não existe no DOM - cria hidden field para enviar no POST
            element = getOrCreateHiddenField(fieldName);
        }

        if (element && value !== undefined && value !== null) {
            element.value = value;
            console.log(`[PLSAG] ${logPrefix}: ${fieldName} = ${value} (campo atualizado no DOM)`);
        } else {
            console.log(`[PLSAG] ${logPrefix}: ${fieldName} = ${value} (apenas contexto)`);
        }

        // Nota: A gravacao efetiva e feita no submit do formulario
        // Aqui apenas atualizamos o contexto
    }

    /**
     * Executa comando de gravacao direta (DDG, DDM, DD2, DD3)
     * Forca gravacao em dataset especifico independente do contexto.
     *
     * DDG = Forca DtsGrav (cabecalho)
     * DDM = Forca DtsMov1 (movimento 1)
     * DD2 = Forca DtsMov2 (movimento 2)
     * DD3 = Forca DtsMov3 (movimento 3)
     *
     * @param {string} target - 'G' (cabecalho), 'M' (mov1), '2' (mov2), '3' (mov3)
     * @param {string} identifier - Nome do campo
     * @param {string} parameter - Valor ou SQL
     * @param {object} context - Contexto de execucao
     */
    async function executeDataDiretoCommand(target, identifier, parameter, context) {
        const fieldName = identifier.trim();
        let value = null;
        let queryExecuted = false;

        // Mapeamento de target para nome do dataset
        const targetDataset = {
            'G': 'header',   // DtsGrav - cabecalho
            'M': 'mov1',     // DtsMov1 - movimento 1
            '2': 'mov2',     // DtsMov2 - movimento 2
            '3': 'mov3'      // DtsMov3 - movimento 3
        }[target] || 'header';

        const prefixDisplay = 'DD' + target;

        // Se o parametro for uma query SQL, executa no servidor
        const paramStr = parameter !== null && parameter !== undefined ? String(parameter) : '';
        if (paramStr.trim().toUpperCase().startsWith('SELECT')) {
            try {
                let sql = convertOracleToSqlServer(parameter);
                console.log(`[PLSAG] ${prefixDisplay} (${targetDataset}): Executando query para ${fieldName}: ${sql}`);

                const response = await fetch('/api/plsag/query', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ sql: sql, singleRow: true })
                });

                if (response.ok) {
                    const result = await response.json();
                    if (result.success && result.data) {
                        const firstKey = Object.keys(result.data)[0];
                        value = result.data[firstKey];
                        queryExecuted = true;
                        console.log(`[PLSAG] ${prefixDisplay} (${targetDataset}): ${fieldName} = ${value} (via query)`);
                    }
                }
            } catch (error) {
                console.error(`[PLSAG] ${prefixDisplay}: Erro executando query:`, error);
            }
        } else if (parameter) {
            value = parameter;
        }

        // Inicializa estrutura de datasets se nao existir
        if (!context.datasetFields) {
            context.datasetFields = {
                header: {},
                mov1: {},
                mov2: {},
                mov3: {}
            };
        }

        // Armazena no dataset especifico (forcado)
        context.datasetFields[targetDataset][fieldName] = value;

        // Tambem atualiza formData para compatibilidade
        context.formData[fieldName] = value;

        // Atualiza o campo no DOM se query executou com sucesso
        const element = findField(fieldName);
        if (element && value !== undefined && value !== null) {
            element.value = value;
            // Dispara eventos para bindings
            element.dispatchEvent(new Event('input', { bubbles: true }));
            element.dispatchEvent(new Event('change', { bubbles: true }));
        }

        console.log(`[PLSAG] ${prefixDisplay} (${targetDataset}): ${fieldName} = ${value}`);
    }

    /**
     * Converte sintaxe Oracle para SQL Server
     * - FROM DUAL -> remove (SQL Server nao precisa)
     * - NVL -> ISNULL
     * - SYSDATE -> GETDATE()
     * - TO_DATE -> CONVERT
     */
    function convertOracleToSqlServer(sql) {
        let converted = sql;

        // Remove FROM DUAL (case insensitive)
        converted = converted.replace(/\s+FROM\s+DUAL\s*/gi, ' ');

        // NVL(a,b) -> ISNULL(a,b)
        converted = converted.replace(/\bNVL\s*\(/gi, 'ISNULL(');

        // SYSDATE -> GETDATE()
        converted = converted.replace(/\bSYSDATE\b/gi, 'GETDATE()');

        // || (concatenacao Oracle) -> + (SQL Server)
        converted = converted.replace(/\|\|/g, '+');

        return converted.trim();
    }

    // ============================================================
    // COMANDOS ESPECIAIS EX
    // ============================================================

    /**
     * Executa comando EX especial
     */
    async function executeExCommand(identifier, parameter, context) {
        const command = identifier.trim().toUpperCase();

        console.log(`[PLSAG] EX-${command}`, parameter || '');

        switch (command) {
            // === Formulario ===
            case 'FECHFORM':
                closeForm();
                break;

            case 'GRAVAFOR':
                await saveForm();
                break;

            case 'LIMPAFOR':
                clearForm();
                break;

            case 'ATUAFORM':
                refreshForm();
                break;

            // === Botoes ===
            case 'MOSTRABT':
                showButton(parameter, true);
                break;

            case 'ESCONDBT':
                showButton(parameter, false);
                break;

            case 'HABILIBT':
                enableButton(parameter, true);
                break;

            case 'DESABIBT':
                enableButton(parameter, false);
                break;

            // === Navegacao ===
            case 'PROXREGI':
                navigateRecord('next');
                break;

            case 'ANTEREGI':
                navigateRecord('prev');
                break;

            case 'PRIMREGI':
                navigateRecord('first');
                break;

            case 'ULTIREGI':
                navigateRecord('last');
                break;

            case 'ABRETELA':
                openScreen(parameter);
                break;

            // === Validacao ===
            case 'VALICPF_':
            case 'VALICPF':
                const cpfValid = validateCPF(parameter);
                context.system.RETOFUNC = cpfValid ? 'S' : 'N';
                break;

            case 'VALICNPJ':
                const cnpjValid = validateCNPJ(parameter);
                context.system.RETOFUNC = cnpjValid ? 'S' : 'N';
                break;

            // === SQL/Banco (Server-side) ===
            case 'SQL-----':
            case 'SQL':
                await executeServerSql(parameter, context);
                break;

            case 'EXECPROC':
                await executeStoredProcedure(parameter, context);
                break;

            case 'TRANSINI':
                console.log('[PLSAG] Inicio de transacao (web: operacao no backend)');
                break;

            case 'TRANSCOM':
                console.log('[PLSAG] Commit de transacao (web: operacao no backend)');
                break;

            case 'TRANSROL':
                console.log('[PLSAG] Rollback de transacao (web: operacao no backend)');
                break;

            // === Impressao/Exportacao ===
            case 'IMPRIMIR':
            case 'PREVISAO':
                window.print();
                break;

            case 'EXPOPDF_':
            case 'EXPOPDF':
                await exportToPdf(parameter, context);
                break;

            case 'EXPOEXCE':
                await exportToExcel(parameter, context);
                break;

            // === Comandos nao suportados na web ===
            case 'LEITSER_':
            case 'LEITSER':
                console.warn('[PLSAG] EX-LEITSER nao suportado na web (porta serial)');
                handleUnsupported('EX', command);
                break;

            case 'EXECEXT_':
            case 'EXECEXT':
                console.warn('[PLSAG] EX-EXECEXT nao suportado na web (execucao externa)');
                handleUnsupported('EX', command);
                break;

            default:
                console.warn(`[PLSAG] Comando EX desconhecido: ${command}`);
                handleUnsupported('EX', command);
        }
    }

    // === Handlers EX ===

    function closeForm() {
        // Tenta fechar janela
        if (window.close) {
            window.close();
        }
        // Fallback: volta na historia
        if (!window.closed) {
            window.history.back();
        }
    }

    async function saveForm() {
        const form = document.getElementById('dynamicForm') || document.querySelector('form');
        if (form) {
            // Dispara submit - o handler em Render.cshtml já chama beforeSave() com await
            form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
        }
    }

    function clearForm() {
        const form = document.getElementById('dynamicForm') || document.querySelector('form');
        if (form) {
            form.reset();
            // Dispara eventos para atualizar bindings
            form.querySelectorAll('input, select, textarea').forEach(el => {
                el.dispatchEvent(new Event('change', { bubbles: true }));
            });
        }
    }

    function refreshForm() {
        window.location.reload();
    }

    function showButton(buttonName, show) {
        const button = findButton(buttonName);
        if (button) {
            button.style.display = show ? '' : 'none';
        }
    }

    function enableButton(buttonName, enable) {
        const button = findButton(buttonName);
        if (button) {
            button.disabled = !enable;
        }
    }

    function navigateRecord(direction) {
        console.log(`[PLSAG] Navegacao: ${direction}`);
        // TODO: Implementar navegacao via API
        document.dispatchEvent(new CustomEvent('sag:navigate-record', {
            detail: { direction }
        }));
    }

    function openScreen(screenName) {
        if (!screenName) return;

        // Verifica se e URL ou codigo de tabela
        if (screenName.startsWith('http://') || screenName.startsWith('https://') || screenName.startsWith('/')) {
            window.open(screenName, '_blank');
        } else {
            // Assume codigo de tabela
            window.open(`/Form/Render/${screenName}`, '_blank');
        }
    }

    async function executeServerSql(sqlOrCommandId, context) {
        try {
            // Verifica se e SQL direto (DELETE, UPDATE, INSERT) ou commandId
            const sqlTrimmed = (sqlOrCommandId || '').trim();
            const sqlUpper = sqlTrimmed.toUpperCase();
            const isDirectSql = sqlUpper.startsWith('DELETE') ||
                               sqlUpper.startsWith('UPDATE') ||
                               sqlUpper.startsWith('INSERT');

            if (isDirectSql) {
                // SQL direto - usa novo endpoint execute-direct-sql
                // Substitui templates antes de enviar
                const resolvedSql = PlsagInterpreter.substituteTemplatesForSQL
                    ? PlsagInterpreter.substituteTemplatesForSQL(sqlTrimmed)
                    : sqlTrimmed;

                console.log(`[PLSAG] EX-SQL (direto): ${resolvedSql.substring(0, 80)}...`);

                const response = await fetch('/api/plsag/execute-direct-sql', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        sql: resolvedSql,
                        codiTabe: context.tableId,
                        params: context.formData
                    })
                });

                const result = await response.json();
                if (result.success) {
                    console.log(`[PLSAG] SQL executado: ${result.rowsAffected} linhas afetadas`);
                    context.system.RETOFUNC = result.rowsAffected;
                } else {
                    console.error('[PLSAG] Erro SQL direto:', result.error);
                    context.system.RETOFUNC = -1;
                }
            } else {
                // CommandId - usa endpoint execute-sql (busca SQL do banco)
                const response = await fetch('/api/plsag/execute-sql', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        commandId: sqlOrCommandId,
                        codiTabe: context.tableId,
                        params: context.formData
                    })
                });

                const result = await response.json();
                if (!result.success) {
                    console.error('[PLSAG] Erro SQL:', result.error);
                }
            }
        } catch (error) {
            console.error('[PLSAG] Erro ao executar SQL:', error);
            context.system.RETOFUNC = -1;
        }
    }

    async function executeStoredProcedure(procName, context) {
        try {
            const response = await fetch('/api/plsag/execute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    type: 'procedure',
                    name: procName,
                    params: context.formData
                })
            });

            const result = await response.json();
            if (result.success && result.data) {
                context.system.RETOFUNC = result.data;
            }
        } catch (error) {
            console.error('[PLSAG] Erro ao executar procedure:', error);
        }
    }

    async function exportToPdf(reportName, context) {
        console.log('[PLSAG] Exportando para PDF:', reportName);
        // TODO: Implementar geracao de PDF via API
        document.dispatchEvent(new CustomEvent('sag:export-pdf', {
            detail: { reportName, context }
        }));
    }

    async function exportToExcel(reportName, context) {
        console.log('[PLSAG] Exportando para Excel:', reportName);
        // TODO: Implementar exportacao Excel via API
        document.dispatchEvent(new CustomEvent('sag:export-excel', {
            detail: { reportName, context }
        }));
    }

    // === Validacoes ===

    function validateCPF(cpf) {
        if (!cpf) return false;

        // Remove caracteres nao numericos
        cpf = cpf.replace(/\D/g, '');

        if (cpf.length !== 11) return false;

        // Verifica se todos digitos sao iguais
        if (/^(\d)\1+$/.test(cpf)) return false;

        // Validacao dos digitos verificadores
        let sum = 0;
        for (let i = 0; i < 9; i++) {
            sum += parseInt(cpf[i]) * (10 - i);
        }
        let digit1 = (sum * 10) % 11;
        if (digit1 === 10) digit1 = 0;
        if (digit1 !== parseInt(cpf[9])) return false;

        sum = 0;
        for (let i = 0; i < 10; i++) {
            sum += parseInt(cpf[i]) * (11 - i);
        }
        let digit2 = (sum * 10) % 11;
        if (digit2 === 10) digit2 = 0;
        if (digit2 !== parseInt(cpf[10])) return false;

        return true;
    }

    function validateCNPJ(cnpj) {
        if (!cnpj) return false;

        cnpj = cnpj.replace(/\D/g, '');

        if (cnpj.length !== 14) return false;

        if (/^(\d)\1+$/.test(cnpj)) return false;

        // Validacao dos digitos verificadores
        const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
        const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

        let sum = 0;
        for (let i = 0; i < 12; i++) {
            sum += parseInt(cnpj[i]) * weights1[i];
        }
        let digit1 = sum % 11;
        digit1 = digit1 < 2 ? 0 : 11 - digit1;
        if (digit1 !== parseInt(cnpj[12])) return false;

        sum = 0;
        for (let i = 0; i < 13; i++) {
            sum += parseInt(cnpj[i]) * weights2[i];
        }
        let digit2 = sum % 11;
        digit2 = digit2 < 2 ? 0 : 11 - digit2;
        if (digit2 !== parseInt(cnpj[13])) return false;

        return true;
    }

    // === Comando nao suportado ===

    function handleUnsupported(prefix, command) {
        document.dispatchEvent(new CustomEvent('sag:unsupported-command', {
            detail: { prefix, command }
        }));
    }

    // ============================================================
    // COMANDO EY - EXECUTE IMMEDIATELY
    // ============================================================

    /**
     * Executa SQL imediatamente, mesmo durante OnShow
     * Formato: EY-<sql>
     * Diferente de EX-SQL que pode ser enfileirado em certas situacoes
     */
    async function executeEyCommand(identifier, parameter, context) {
        // O SQL pode vir no identifier ou parameter
        const sql = parameter ? `${identifier} ${parameter}`.trim() : identifier;

        console.log('[PLSAG] EY (Execute Immediately):', sql.substring(0, 100) + (sql.length > 100 ? '...' : ''));

        if (!sql) {
            console.warn('[PLSAG] EY: SQL vazio');
            return;
        }

        try {
            const response = await fetch('/api/plsag/execute-direct-sql', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    sql: sql,
                    codiTabe: context.tableId,
                    params: context.formData || {}
                })
            });

            if (!response.ok) {
                const errorText = await response.text();
                console.error('[PLSAG] EY: Erro no servidor:', errorText);
                return;
            }

            const result = await response.json();

            if (result.success) {
                console.log('[PLSAG] EY: SQL executado com sucesso', result.affectedRows || 0, 'linhas afetadas');
            } else {
                console.error('[PLSAG] EY: Erro:', result.error || result.message);
            }
        } catch (error) {
            console.error('[PLSAG] EY: Erro de rede:', error);
        }
    }

    // ============================================================
    // COMANDOS FO/FV/FM - NAVEGACAO DE FORMULARIOS
    // ============================================================

    /**
     * Executa comandos de navegacao de formularios
     * FO: Abre formulario - FO-XXXXXXXX-YYYYYYYY onde X=tabela, Y=filtro/instrucoes
     * FV: Marca retorno do formulario (instrucoes executadas apos fechar)
     * FM: Abre formulario via menu
     */
    async function executeFormNavigationCommand(prefix, identifier, parameter, context) {
        console.log(`[PLSAG] ${prefix}-${identifier}`, parameter || '');

        switch (prefix) {
            case 'FO':
                await openFormCommand(identifier, parameter, context);
                break;

            case 'FV':
                // FV marca instrucoes pos-fechamento
                // Na web, guardamos para execucao apos fechar modal/tab
                context.postFormInstructions = context.postFormInstructions || [];
                if (parameter) {
                    context.postFormInstructions.push(parameter);
                }
                console.log('[PLSAG] FV: Instrucoes pos-fechamento registradas');
                break;

            case 'FM':
                await openMenuFormCommand(identifier, parameter, context);
                break;
        }
    }

    /**
     * Abre formulario em nova aba ou modal
     * FO-XXXXXXXX-instrucoes
     * XXXXXXXX = CodiTabe (8 digitos)
     */
    async function openFormCommand(identifier, parameter, context) {
        // identifier = CodiTabe (8 digitos, pode ter zeros a esquerda)
        const tableId = parseInt(identifier, 10);

        if (!tableId || isNaN(tableId)) {
            console.error('[PLSAG] FO: CodiTabe invalido:', identifier);
            return;
        }

        console.log('[PLSAG] FO: Abrindo formulario', tableId);

        // Guarda instrucoes pos-fechamento se houver
        const postInstructions = parameter || '';

        // Verifica se esta em modo embedded (iframe)
        const isEmbedded = window.SAG_EMBEDDED || window.parent !== window;

        if (isEmbedded) {
            // Em modo embedded, usa postMessage para comunicar com parent
            window.parent.postMessage({
                type: 'sag:open-form',
                tableId: tableId,
                postInstructions: postInstructions,
                sourceTableId: context.tableId
            }, '*');
        } else {
            // Abre em nova aba
            const formUrl = `/Form/Render/${tableId}`;

            // Guarda instrucoes para executar quando voltar
            if (postInstructions) {
                sessionStorage.setItem(`sag_post_form_${context.tableId}_${tableId}`, postInstructions);
            }

            // Abre nova aba
            const newWindow = window.open(formUrl, '_blank');

            // Listener para quando a janela fechar (se possivel)
            if (newWindow) {
                const checkClosed = setInterval(() => {
                    if (newWindow.closed) {
                        clearInterval(checkClosed);
                        executePostFormInstructions(context.tableId, tableId, context);
                    }
                }, 500);

                // Timeout de seguranca (5 minutos)
                setTimeout(() => clearInterval(checkClosed), 300000);
            }
        }
    }

    /**
     * Abre formulario via menu
     * FM-XXXXXXXX-instrucoes
     */
    async function openMenuFormCommand(identifier, parameter, context) {
        // Similar ao FO, mas usa configuracao do menu
        // identifier = CodiTabe
        const tableId = parseInt(identifier, 10);

        if (!tableId || isNaN(tableId)) {
            console.error('[PLSAG] FM: CodiTabe invalido:', identifier);
            return;
        }

        console.log('[PLSAG] FM: Abrindo formulario via menu', tableId);

        // Por enquanto, trata igual ao FO
        await openFormCommand(identifier, parameter, context);
    }

    /**
     * Executa instrucoes pos-fechamento de formulario
     */
    async function executePostFormInstructions(parentTableId, childTableId, context) {
        const key = `sag_post_form_${parentTableId}_${childTableId}`;
        const instructions = sessionStorage.getItem(key);

        if (instructions) {
            sessionStorage.removeItem(key);
            console.log('[PLSAG] Executando instrucoes pos-fechamento:', instructions);

            // Executa via PlsagInterpreter se disponivel
            if (window.PlsagInterpreter && window.PlsagInterpreter.execute) {
                try {
                    await window.PlsagInterpreter.execute(instructions, {
                        tableId: parentTableId,
                        eventType: 'PostFormClose',
                        formData: context.formData || {}
                    });
                } catch (error) {
                    console.error('[PLSAG] Erro executando instrucoes pos-fechamento:', error);
                }
            }
        }
    }

    // Listener para mensagens de forms embedded retornando
    if (typeof window !== 'undefined') {
        window.addEventListener('message', async (event) => {
            if (event.data && event.data.type === 'sag:form-closed') {
                const { sourceTableId, targetTableId, result } = event.data;
                console.log('[PLSAG] Form fechado:', targetTableId, 'resultado:', result);

                // Busca contexto atual
                const context = window.PlsagInterpreter?.getContext?.() || { tableId: sourceTableId };
                await executePostFormInstructions(sourceTableId, targetTableId, context);
            }
        });
    }

    // ============================================================
    // COMANDO TI - TIMER CONTROL
    // ============================================================

    /**
     * Controla timer (ativa/desativa)
     * Formato: TI-CAMPO-ATIV ou TI-CAMPO-DESA
     */
    async function executeTimerCommand(identifier, parameter, context) {
        const timerName = identifier;
        const action = (parameter || '').toUpperCase().substring(0, 4);

        console.log(`[PLSAG] TI-${timerName}-${action}`);

        if (!timerName) {
            console.warn('[PLSAG] TI: Nome do timer não especificado');
            return;
        }

        if (action === 'ATIV') {
            // Ativar timer
            if (window.SagEvents && window.SagEvents.setTimerEnabled) {
                window.SagEvents.setTimerEnabled(timerName, true);
            }
        } else if (action === 'DESA') {
            // Desativar timer
            if (window.SagEvents && window.SagEvents.setTimerEnabled) {
                window.SagEvents.setTimerEnabled(timerName, false);
            }
        } else {
            console.warn(`[PLSAG] TI: Ação desconhecida '${action}' (use ATIV ou DESA)`);
        }
    }

    // ============================================================
    // API PUBLICA
    // ============================================================

    return {
        // Execucao de comandos
        executeFieldCommand,
        executeVariableCommand,
        executeMessageCommand,
        executeQueryCommand,
        executeDataCommand,
        executeDataDiretoCommand,
        executeExCommand,
        executeLabelCommand,
        executeButtonCommand,
        executeButtonActionCommand,
        executeEyCommand,
        executeFormNavigationCommand,
        executeTimerCommand,

        // Utilitarios
        findField,
        findFieldContainer,
        findButton,
        findLabel,
        findMovementComponent,
        showModal,

        // Validacoes
        validateCPF,
        validateCNPJ
    };
})();

// Expoe globalmente
window.PlsagCommands = PlsagCommands;
