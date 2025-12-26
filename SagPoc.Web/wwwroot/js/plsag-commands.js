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
     * Encontra um campo no formulario pelo nome
     * IMPORTANTE: Usa NAMECAMP (nome do componente visual) para busca, não NOMECAMP (nome do campo no banco)
     * No Delphi, FindComponent usa NAMECAMP. Campos duplicados (mesmo NOMECAMP) têm NAMECAMP diferentes.
     * Exemplo: PORTLESI aparece 2x no form 715, mas com NAMECAMP='PORTLESI' e NAMECAMP='POR_LESI'
     * @param {string} fieldName - Nome do componente (NAMECAMP)
     * @returns {HTMLElement|null} Elemento encontrado ou null
     */
    function findField(fieldName) {
        const name = fieldName.trim();

        // 1. Busca por data-sag-namecamp (NAMECAMP - nome do componente visual, usado pelo PLSAG)
        let element = document.querySelector(`[data-sag-namecamp="${name}"]`);
        if (element) return element;

        // 2. Fallback: Busca por data-sag-nomecamp (NOMECAMP - nome do campo no banco)
        element = document.querySelector(`[data-sag-nomecamp="${name}"]`);
        if (element) return element;

        // 3. Tenta por name attribute
        element = document.querySelector(`[name="${name}"]`);
        if (element) return element;

        // 4. Tenta por id (com prefixo field_)
        element = document.getElementById(`field_${name}`);
        if (element) return element;

        // 5. Tenta por id direto
        element = document.getElementById(name);
        if (element) return element;

        // 6. Tenta case-insensitive em data-sag-namecamp
        const allFields = document.querySelectorAll('[data-sag-namecamp], [data-sag-nomecamp], [name]');
        for (const field of allFields) {
            const sagNamecamp = field.dataset.sagNamecamp;
            if (sagNamecamp && sagNamecamp.toLowerCase() === name.toLowerCase()) {
                return field;
            }
        }

        // 7. Tenta case-insensitive em data-sag-nomecamp
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
        const element = findField(fieldName);

        if (!element) {
            console.warn(`[PLSAG] Campo nao encontrado: ${fieldName}`);
            return;
        }

        // Detecta tipo base e modificador
        const baseType = prefix.substring(0, 2); // CE, CN, CS, CM, CT, CF, CV, IE, IN, etc.
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
     */
    function executeFieldModifier(element, modifier, parameter, fieldName) {
        // Converte para string para suportar parâmetros numéricos (ex: resultado de IF())
        const value = parameter !== null && parameter !== undefined ? String(parameter).trim() : '';
        const isTrue = isTruthy(value);

        switch (modifier) {
            case 'D': // Disable/Enable
                // Parametro: 0 = desabilita, != 0 = habilita
                element.disabled = !isTrue;
                if (isTrue) {
                    element.classList.remove('disabled');
                } else {
                    element.classList.add('disabled');
                }
                break;

            case 'F': // Focus
                if (isTrue) {
                    element.focus();
                }
                break;

            case 'V': // Visible
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
        // Verifica se tem query SQL com mensagem separada por |||
        if (parameter && parameter.includes('|||')) {
            const parts = parameter.split('|||');
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

        // Fallback: ME simples sem query, mostra mensagem diretamente
        const message = parameter || identifier;
        await showModal('error', message);
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

    // ============================================================
    // COMANDOS DE GRAVACAO (Server-side)
    // ============================================================

    /**
     * Executa comando de gravacao
     * DG = Data Grava (cabecalho)
     * DM = Data Movimento 1
     * D2 = Data Movimento 2
     * D3 = Data Movimento 3
     *
     * Se o parametro for uma query SQL (SELECT...), executa a query
     * e usa o resultado como valor do campo.
     */
    async function executeDataCommand(prefix, identifier, parameter, context) {
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

                console.log(`[PLSAG] ${prefix}: Executando query para ${fieldName}: ${sql}`);

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
                        console.log(`[PLSAG] ${prefix}: ${fieldName} = ${value} (via query)`);
                    } else {
                        console.warn(`[PLSAG] ${prefix}: Query sem resultado para ${fieldName}, mantendo valor original: ${originalValue}`);
                    }
                } else {
                    console.warn(`[PLSAG] ${prefix}: Query falhou para ${fieldName}, mantendo valor original: ${originalValue}`);
                }
            } catch (error) {
                console.error(`[PLSAG] ${prefix}: Erro executando query, mantendo valor original:`, error);
            }
        } else if (parameter) {
            // Parametro nao-SQL: usa como valor direto (expressao ja avaliada)
            value = parameter;
        }

        // Atualiza no contexto
        context.formData[fieldName] = value;

        // Atualiza o campo no DOM tambem (apenas se query foi executada com sucesso)
        const element = findField(fieldName);
        if (element && queryExecuted && value !== undefined && value !== null) {
            element.value = value;
        }

        console.log(`[PLSAG] ${prefix}: ${fieldName} = ${value}`);

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

        // Utilitarios
        findField,
        findFieldContainer,
        findButton,
        findLabel,
        showModal,

        // Validacoes
        validateCPF,
        validateCNPJ
    };
})();

// Expoe globalmente
window.PlsagCommands = PlsagCommands;
