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
     * Formata nome de coluna do banco para exibição amigável.
     * Converte padrões comuns como CODICONT -> Código, NOMECONT -> Nome, etc.
     *
     * @param {string} columnName - Nome técnico da coluna do banco
     * @returns {string} Nome formatado para exibição
     */
    function formatColumnName(columnName) {
        if (!columnName) return '';

        // Se já tem aspas ou parece um label amigável, retorna como está
        if (columnName.includes(' ') || /[áéíóúàèìòùãõâêîôû]/i.test(columnName)) {
            return columnName;
        }

        const upper = columnName.toUpperCase();

        // Padrões comuns de prefixos/sufixos do SAG
        const patterns = [
            // Padrão CODI* -> Código
            { regex: /^CODI(.+)$/, format: (match) => 'Código' },
            // Padrão NOME* -> Nome
            { regex: /^NOME(.+)$/, format: (match) => 'Nome' },
            // Padrão DESC* -> Descrição
            { regex: /^DESC(.+)$/, format: (match) => 'Descrição' },
            // Padrão SIGL* -> Sigla
            { regex: /^SIGL(.+)$/, format: (match) => 'Sigla' },
            // Padrão DATA* -> Data
            { regex: /^DATA(.+)$/, format: (match) => 'Data' },
            // Padrão VALO* -> Valor
            { regex: /^VALO(.+)$/, format: (match) => 'Valor' },
            // Padrão QUAN* ou QTDE* -> Quantidade
            { regex: /^(QUAN|QTDE)(.+)$/, format: (match) => 'Quantidade' },
            // Padrão PREC* -> Preço
            { regex: /^PREC(.+)$/, format: (match) => 'Preço' },
            // Padrão TOTA* -> Total
            { regex: /^TOTA(.+)$/, format: (match) => 'Total' },
            // Padrão TIPO* -> Tipo
            { regex: /^TIPO(.+)$/, format: (match) => 'Tipo' },
            // Padrão STAT* -> Status
            { regex: /^STAT(.+)$/, format: (match) => 'Status' },
            // Padrão OBSE* -> Observação
            { regex: /^OBSE(.+)$/, format: (match) => 'Observação' },
            // Padrão NATU* -> Natureza
            { regex: /^NATU(.+)$/, format: (match) => 'Natureza' },
            // Padrão UNID* -> Unidade
            { regex: /^UNID(.+)$/, format: (match) => 'Unidade' },
            // Padrão FONE* ou TELE* -> Telefone
            { regex: /^(FONE|TELE)(.*)$/, format: (match) => 'Telefone' },
            // Padrão EMAI* -> E-mail
            { regex: /^EMAI(.*)$/, format: (match) => 'E-mail' },
            // Padrão ENDE* -> Endereço
            { regex: /^ENDE(.*)$/, format: (match) => 'Endereço' },
            // Padrão BAIR* -> Bairro
            { regex: /^BAIR(.*)$/, format: (match) => 'Bairro' },
            // Padrão CIDA* -> Cidade
            { regex: /^CIDA(.*)$/, format: (match) => 'Cidade' },
            // Padrão ESTA* -> Estado
            { regex: /^ESTA(.*)$/, format: (match) => 'Estado' },
            // Padrão PAIS* -> País
            { regex: /^PAIS(.*)$/, format: (match) => 'País' },
            // Padrão CEP* -> CEP
            { regex: /^CEP(.*)$/, format: (match) => 'CEP' },
            // Padrão CGC_* ou *CGC* -> CPF/CNPJ
            { regex: /^CGC_(.*)$/, format: (match) => 'CPF/CNPJ' },
            { regex: /^(.*)_CGC$/, format: (match) => 'CPF/CNPJ' },
            // Padrão CNPJ* ou CPF* -> CPF/CNPJ
            { regex: /^(CNPJ|CPF)(.*)$/, format: (match) => match[1] },
            // Padrão FANT* -> Fantasia
            { regex: /^FANT(.*)$/, format: (match) => 'Fantasia' },
            // Padrão RAZA* ou RAZAO* -> Razão Social
            { regex: /^(RAZA|RAZAO)(.*)$/, format: (match) => 'Razão Social' },
            // Padrão RG_* ou *_RG -> RG
            { regex: /^RG_(.*)$/, format: (match) => 'RG' },
            { regex: /^(.*)_RG$/, format: (match) => 'RG' },
            // Padrão IE_* ou *_IE -> Insc. Estadual
            { regex: /^IE_(.*)$/, format: (match) => 'Insc. Estadual' },
            { regex: /^(.*)_IE$/, format: (match) => 'Insc. Estadual' },
            // Padrão INSC* -> Inscrição
            { regex: /^INSC(.*)$/, format: (match) => 'Inscrição' },
            // Padrão PERC* -> Percentual
            { regex: /^PERC(.+)$/, format: (match) => 'Percentual' },
            // Padrão ATIV* -> Ativo
            { regex: /^ATIV(.*)$/, format: (match) => 'Ativo' },
            // Padrão SALD* -> Saldo
            { regex: /^SALD(.+)$/, format: (match) => 'Saldo' },
            // Padrão LIMI* -> Limite
            { regex: /^LIMI(.+)$/, format: (match) => 'Limite' },
            // Padrão CLAS* -> Classificação
            { regex: /^CLAS(.+)$/, format: (match) => 'Classificação' },
            // Padrão GRUP* -> Grupo
            { regex: /^GRUP(.+)$/, format: (match) => 'Grupo' },
            // Padrão CONT* -> Conta
            { regex: /^CONT(.+)$/, format: (match) => 'Conta' },
            // Padrão BANC* -> Banco
            { regex: /^BANC(.+)$/, format: (match) => 'Banco' },
            // Padrão AGEN* -> Agência
            { regex: /^AGEN(.+)$/, format: (match) => 'Agência' },
            // Padrão REFE* -> Referência
            { regex: /^REFE(.*)$/, format: (match) => 'Referência' },
            // Padrão SITU* -> Situação
            { regex: /^SITU(.*)$/, format: (match) => 'Situação' },
            // Padrão ORIG* -> Origem
            { regex: /^ORIG(.*)$/, format: (match) => 'Origem' },
            // Padrão DEST* -> Destino
            { regex: /^DEST(.*)$/, format: (match) => 'Destino' },
            // Padrão NOTA* -> Nota
            { regex: /^NOTA(.*)$/, format: (match) => 'Nota' },
            // Padrão SERI* -> Série
            { regex: /^SERI(.*)$/, format: (match) => 'Série' },
            // Padrão NFIS* -> NF
            { regex: /^NFIS(.*)$/, format: (match) => 'NF' },
            // Padrão CFOP* -> CFOP
            { regex: /^CFOP(.*)$/, format: (match) => 'CFOP' },
            // Padrão HIST* -> Histórico
            { regex: /^HIST(.*)$/, format: (match) => 'Histórico' },
            // Padrão VENC* -> Vencimento
            { regex: /^VENC(.*)$/, format: (match) => 'Vencimento' },
            // Padrão PARC* -> Parcela
            { regex: /^PARC(.*)$/, format: (match) => 'Parcela' },
            // Padrão DOCU* -> Documento
            { regex: /^DOCU(.*)$/, format: (match) => 'Documento' },
            // Padrão PROD* -> Produto
            { regex: /^PROD(.*)$/, format: (match) => 'Produto' },
            // Padrão SERV* -> Serviço
            { regex: /^SERV(.*)$/, format: (match) => 'Serviço' },
            // Padrão EMIS* -> Emissão
            { regex: /^EMIS(.*)$/, format: (match) => 'Emissão' },
            // Padrão ENTR* -> Entrada
            { regex: /^ENTR(.*)$/, format: (match) => 'Entrada' },
            // Padrão SAID* -> Saída
            { regex: /^SAID(.*)$/, format: (match) => 'Saída' },
            // Padrão PESS* -> Pessoa
            { regex: /^PESS(.*)$/, format: (match) => 'Pessoa' },
            // Padrão CLIE* -> Cliente
            { regex: /^CLIE(.*)$/, format: (match) => 'Cliente' },
            // Padrão FORN* -> Fornecedor
            { regex: /^FORN(.*)$/, format: (match) => 'Fornecedor' },
            // Padrão VEND* -> Vendedor
            { regex: /^VEND(.*)$/, format: (match) => 'Vendedor' },
            // Padrão FUNC* -> Funcionário
            { regex: /^FUNC(.*)$/, format: (match) => 'Funcionário' },
            // Padrão HORA* -> Hora
            { regex: /^HORA(.*)$/, format: (match) => 'Hora' },
            // Padrão MENS* -> Mensagem
            { regex: /^MENS(.*)$/, format: (match) => 'Mensagem' },
            // Padrão FLAG* -> Flag
            { regex: /^FLAG(.*)$/, format: (match) => 'Flag' },
            // Padrão MARC* -> Marca
            { regex: /^MARC(.*)$/, format: (match) => 'Marca' },
            // Padrão MODE* -> Modelo
            { regex: /^MODE(.*)$/, format: (match) => 'Modelo' },
            // Padrão LOCA* -> Local
            { regex: /^LOCA(.*)$/, format: (match) => 'Local' },
            // Padrão ALMO* -> Almoxarifado
            { regex: /^ALMO(.*)$/, format: (match) => 'Almoxarifado' },
            // Padrão DEPO* -> Depósito
            { regex: /^DEPO(.*)$/, format: (match) => 'Depósito' },
            // Padrão ESTO* -> Estoque
            { regex: /^ESTO(.*)$/, format: (match) => 'Estoque' },
            // Padrão CUSTO* ou CUST* -> Custo
            { regex: /^CUST(.*)$/, format: (match) => 'Custo' },
            // Padrão PESO* -> Peso
            { regex: /^PESO(.*)$/, format: (match) => 'Peso' },
            // Padrão LARG* -> Largura
            { regex: /^LARG(.*)$/, format: (match) => 'Largura' },
            // Padrão ALTU* -> Altura
            { regex: /^ALTU(.*)$/, format: (match) => 'Altura' },
            // Padrão COMP* -> Comprimento (cuidado com CompCamp que é diferente)
            { regex: /^COMP(?!CAMP)(.*)$/, format: (match) => 'Comprimento' },
            // Padrão VOLU* -> Volume
            { regex: /^VOLU(.*)$/, format: (match) => 'Volume' },
            // Padrão MEDI* -> Medida
            { regex: /^MEDI(.*)$/, format: (match) => 'Medida' },
            // Padrão DIME* -> Dimensão
            { regex: /^DIME(.*)$/, format: (match) => 'Dimensão' },
            // Padrão USER* ou USUA* -> Usuário
            { regex: /^(USER|USUA)(.*)$/, format: (match) => 'Usuário' },
            // Padrão EMPR* -> Empresa
            { regex: /^EMPR(.*)$/, format: (match) => 'Empresa' },
            // Padrão FILI* -> Filial
            { regex: /^FILI(.*)$/, format: (match) => 'Filial' },
        ];

        for (const pattern of patterns) {
            const match = upper.match(pattern.regex);
            if (match) {
                return pattern.format(match);
            }
        }

        // Fallback: retorna o nome original com capitalização
        return columnName.charAt(0).toUpperCase() + columnName.slice(1).toLowerCase();
    }

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

        // Bind de arredondamento em campos numéricos (baseado em DeciCamp)
        bindNumericRounding();

        // Bind de duplo clique em campos lookup (T, IT, L, IL)
        bindDuplCliq();

        // Bind de auto-fetch em campos lookup (L, IL) - busca descrição ao digitar código
        bindLookupAutoFetch();

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

    // ============================================
    // NUMERIC ROUNDING - Arredondamento de campos numéricos
    // ============================================

    /**
     * Faz bind do evento blur em campos numéricos para arredondar baseado em DeciCamp.
     * Replica o comportamento do Delphi onde DecimalPrecision/DecimalPlaces define
     * quantas casas decimais o campo aceita, arredondando ao sair.
     * Ex: DeciCamp=0 e valor 3.5 => 4 (arredondamento padrão)
     * @param {HTMLElement} container - Container onde buscar os campos (default: document)
     */
    function bindNumericRounding(container = document) {
        const fields = container.querySelectorAll('input[type="number"][data-decimals]');
        let count = 0;

        fields.forEach(field => {
            // Evita duplo bind
            if (field.dataset.numericRoundingBound) return;
            field.dataset.numericRoundingBound = 'true';

            field.addEventListener('blur', function(e) {
                const decimals = parseInt(this.dataset.decimals, 10) || 0;
                const value = parseFloat(this.value);

                if (isNaN(value)) return;

                // Arredonda para o número de casas decimais definido em DeciCamp
                const factor = Math.pow(10, decimals);
                const rounded = Math.round(value * factor) / factor;

                // Atualiza o valor se mudou
                if (this.value !== '' && rounded !== value) {
                    this.value = rounded;
                    // Dispara evento de change para triggers
                    this.dispatchEvent(new Event('change', { bubbles: true }));
                }
            });
            count++;
        });

        if (count > 0) {
            console.log('[SagEvents] Campos numéricos com arredondamento:', count);
        }
    }

    // ============================================
    // DUPLCLIQ - Duplo Clique em Campos Lookup
    // ============================================

    /**
     * Faz bind do evento de duplo clique em campos de lookup (T, IT, L, IL).
     * Ao dar duplo clique, abre um modal expandido de pesquisa.
     * @param {HTMLElement} container - Container onde buscar os campos (default: document)
     */
    function bindDuplCliq(container = document) {
        const fields = container.querySelectorAll('[data-has-duplcliq="true"]');
        let count = 0;

        fields.forEach(field => {
            // Evita duplo bind
            if (field.dataset.duplcliqBound) return;
            field.dataset.duplcliqBound = 'true';

            field.addEventListener('dblclick', function(e) {
                // Previne seleção de texto no duplo clique
                e.preventDefault();

                // Não abre se campo estiver desabilitado
                if (this.disabled || this.readOnly) {
                    console.log('[SagEvents] DuplCliq ignorado - campo desabilitado/readonly');
                    return;
                }

                const codicamp = this.dataset.sagCodicamp;
                const compType = (this.dataset.sagComptype || '').toUpperCase();
                const namecamp = this.dataset.sagNamecamp || this.dataset.sagNomecamp;

                console.log(`[SagEvents] DuplCliq em campo ${namecamp} (${compType}), codicamp:`, codicamp);

                if (codicamp) {
                    openExpandedLookup(codicamp, this);
                } else {
                    console.warn('[SagEvents] Campo sem data-sag-codicamp para DuplCliq');
                }
            });
            count++;
        });

        if (count > 0) {
            console.log('[SagEvents] DuplCliq vinculado em', count, 'campos');
        }
    }

    /**
     * Abre o modal de lookup expandido para um campo.
     * Funciona para campos tipo T/IT (select) e L/IL (input).
     * @param {string|number} codiCamp - ID do campo (CodiCamp)
     * @param {HTMLElement} fieldElement - Elemento do campo que disparou o evento
     */
    async function openExpandedLookup(codiCamp, fieldElement) {
        console.log('[SagEvents] openExpandedLookup para campo', codiCamp);

        // Se não passou o elemento, busca pelo codiCamp
        if (!fieldElement) {
            fieldElement = document.querySelector(`[data-sag-codicamp="${codiCamp}"]`);
        }

        if (!fieldElement) {
            console.warn('[SagEvents] Campo não encontrado para DuplCliq:', codiCamp);
            return;
        }

        // Verifica se tem SQL de lookup no atributo data ou busca do servidor
        let sql = fieldElement.dataset.lookupSql;

        if (!sql) {
            // Busca o SQL do campo via endpoint
            try {
                const sqlResponse = await fetch(`/Form/GetFieldLookupSql?codiCamp=${codiCamp}`);
                if (!sqlResponse.ok) {
                    console.warn('[SagEvents] Campo não tem SQL de lookup configurado');
                    // Se for um select (T/IT) que não tem SQL, não faz nada
                    // pois já tem as opções no dropdown
                    if (fieldElement.tagName === 'SELECT') {
                        console.log('[SagEvents] Campo SELECT sem SQL - usando dropdown nativo');
                        fieldElement.focus();
                        // Abre o dropdown programaticamente
                        fieldElement.showPicker?.();
                        return;
                    }
                    return;
                }

                const sqlData = await sqlResponse.json();
                if (!sqlData.success || !sqlData.sql) {
                    console.warn('[SagEvents] SQL de lookup não encontrado para campo', codiCamp);
                    return;
                }
                sql = sqlData.sql;
            } catch (error) {
                console.error('[SagEvents] Erro ao buscar SQL de lookup:', error);
                return;
            }
        }

        try {
            // Executa o SQL para obter as opções
            const lookupResponse = await fetch('/Form/ExecuteLookup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ sql: sql, filter: '' })
            });

            if (!lookupResponse.ok) {
                throw new Error('Erro ao executar lookup');
            }

            const lookupData = await lookupResponse.json();
            if (!lookupData.success) {
                throw new Error(lookupData.error || 'Erro ao executar lookup');
            }

            // Mostra o modal de lookup expandido
            showExpandedLookupModal(fieldElement, lookupData.columns, lookupData.records, sql);

        } catch (error) {
            console.error('[SagEvents] Erro ao abrir lookup expandido:', error);
            alert('Erro ao abrir pesquisa: ' + error.message);
        }
    }

    /**
     * Mostra o modal de lookup expandido com pesquisa e grid.
     * Funciona para campos tipo T/IT (select) e L/IL (input).
     *
     * @param {HTMLElement} fieldElement - Elemento do campo (select ou input)
     * @param {Array<string>} columns - Lista de nomes das colunas
     * @param {Array} records - Lista de registros {key, value, data}
     * @param {string} sql - SQL para refetch com filtro
     */
    function showExpandedLookupModal(fieldElement, columns, records, sql) {
        // Remove modal anterior se existir
        const existingModal = document.getElementById('sagExpandedLookupModal');
        if (existingModal) {
            existingModal.remove();
        }

        // Prepara colunas (até 6 colunas para não ficar muito largo)
        const displayColumns = columns.slice(0, 6);

        // Obtém o label do campo
        const fieldName = fieldElement.dataset.sagNomecamp || fieldElement.name || 'Campo';
        const label = fieldElement.closest('.field-wrapper')?.querySelector('label')?.textContent || fieldName;

        const modalHtml = `
            <div class="modal fade" id="sagExpandedLookupModal" tabindex="-1">
                <div class="modal-dialog modal-lg modal-dialog-scrollable">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="bi bi-search me-2"></i>Pesquisar: ${escapeHtml(label)}
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-0">
                            <div class="p-3 pb-0">
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-funnel"></i></span>
                                    <input type="text" class="form-control" id="expandedLookupFilter"
                                           placeholder="Digite para filtrar..." autocomplete="off">
                                    <button class="btn btn-outline-secondary" type="button" id="expandedLookupClear">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>
                            </div>
                            <div id="expandedLookupAgGrid"
                                 class="ag-theme-quartz"
                                 style="height: 400px; width: 100%;"></div>
                        </div>
                        <div class="modal-footer">
                            <span class="text-muted me-auto" id="expandedLookupRecordCount"></span>
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i>Cancelar
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML('beforeend', modalHtml);

        const modal = document.getElementById('sagExpandedLookupModal');
        const bsModal = new bootstrap.Modal(modal);
        const gridContainer = document.getElementById('expandedLookupAgGrid');
        const filterInput = document.getElementById('expandedLookupFilter');
        const clearBtn = document.getElementById('expandedLookupClear');
        const recordCount = document.getElementById('expandedLookupRecordCount');

        // Variável para armazenar a API do AG Grid
        let gridApi = null;

        // Prepara dados no formato AG Grid (usa record.data como dados da linha)
        const rowData = records.map(record => ({
            ...record.data,
            _originalRecord: record // Preserva o registro original para seleção
        }));

        // Atualiza contador
        recordCount.textContent = `${records.length} registro(s)`;

        // Configura colunas do AG Grid (com labels amigáveis)
        const columnDefs = displayColumns.map(col => ({
            field: col,
            headerName: formatColumnName(col),
            sortable: true,
            resizable: true,
            minWidth: 100
        }));

        // Opções do AG Grid
        const gridOptions = {
            columnDefs: columnDefs,
            rowData: rowData,
            rowSelection: 'single',
            animateRows: true,
            enableCellTextSelection: true,

            // Column menu (AG Grid Enterprise)
            columnMenu: 'new',
            suppressMenuHide: false,

            // Painel lateral de colunas (igual ao Vision)
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
                defaultToolPanel: '',
            },

            // Barra de agrupamento no topo
            rowGroupPanelShow: 'always',
            suppressDragLeaveHidesColumns: true,

            // Overlay de loading
            overlayNoRowsTemplate: '<div class="ag-overlay-no-rows-center"><i class="bi bi-inbox fs-4 d-block mb-2"></i>Nenhum registro encontrado</div>',

            // Default column definition
            defaultColDef: {
                sortable: true,
                resizable: true,
                filter: true,
                menuTabs: ['filterMenuTab', 'generalMenuTab', 'columnsMenuTab']
            },

            // Callback de double-click para seleção
            onRowDoubleClicked: (event) => {
                const originalRecord = event.data._originalRecord;
                if (originalRecord) {
                    selectLookupRecord(fieldElement, originalRecord);
                    bsModal.hide();
                }
            },

            // Callback de single-click para seleção
            onRowClicked: (event) => {
                const originalRecord = event.data._originalRecord;
                if (originalRecord) {
                    selectLookupRecord(fieldElement, originalRecord);
                    bsModal.hide();
                }
            },

            // Callback de grid ready - autoSize das colunas
            onGridReady: (params) => {
                gridApi = params.api;
                // Auto-dimensiona colunas pelo conteúdo
                params.api.autoSizeAllColumns();
            }
        };

        // Cria o AG Grid quando o modal estiver visível
        modal.addEventListener('shown.bs.modal', () => {
            // Verifica se AG Grid está disponível
            if (typeof agGrid !== 'undefined') {
                agGrid.createGrid(gridContainer, gridOptions);
            } else {
                console.error('[SagEvents] AG Grid não disponível para lookup modal');
                // Fallback: exibe mensagem
                gridContainer.innerHTML = '<div class="p-4 text-center text-muted">AG Grid não disponível</div>';
            }
            filterInput.focus();
        });

        // Filtro em tempo real usando quickFilter do AG Grid
        let filterTimeout = null;
        filterInput.addEventListener('input', () => {
            clearTimeout(filterTimeout);
            filterTimeout = setTimeout(() => {
                const filter = filterInput.value.trim();
                if (gridApi) {
                    gridApi.setGridOption('quickFilterText', filter);
                    // Atualiza contador
                    const displayedRows = gridApi.getDisplayedRowCount();
                    recordCount.textContent = `${displayedRows} de ${records.length} registro(s)`;
                }
            }, 200);
        });

        // Botão de limpar filtro
        clearBtn.addEventListener('click', () => {
            filterInput.value = '';
            if (gridApi) {
                gridApi.setGridOption('quickFilterText', '');
                recordCount.textContent = `${records.length} registro(s)`;
            }
            filterInput.focus();
        });

        // Limpa modal ao fechar
        modal.addEventListener('hidden.bs.modal', () => {
            if (gridApi) {
                gridApi.destroy();
            }
            modal.remove();
        });

        // Abre o modal
        bsModal.show();
    }

    /**
     * Seleciona um registro do lookup e preenche o campo e campos IE associados.
     * @param {HTMLElement} fieldElement - Elemento do campo (select ou input)
     * @param {Object} record - Registro selecionado {key, value, data}
     */
    function selectLookupRecord(fieldElement, record) {
        const isSelect = fieldElement.tagName === 'SELECT';
        const fieldName = fieldElement.dataset.sagNomecamp || fieldElement.name;

        console.log('[SagEvents] Selecionado registro para', fieldName, ':', record);

        // 1. Preenche o campo principal com o valor da chave
        if (isSelect) {
            // Para select, precisa selecionar a opção correspondente ou adicionar se não existir
            let optionFound = false;
            for (const option of fieldElement.options) {
                if (option.value == record.key) {
                    fieldElement.value = record.key;
                    optionFound = true;
                    break;
                }
            }
            // Se a opção não existe no select, adiciona temporariamente
            if (!optionFound) {
                const newOption = new Option(record.value || record.key, record.key, true, true);
                fieldElement.add(newOption);
            }
        } else {
            // Para input, simplesmente define o valor
            fieldElement.value = record.key;
        }

        // 2. Preenche o campo de descrição automático (para campos L/IL)
        const descId = fieldElement.dataset.lookupDescId;
        if (descId) {
            const descField = document.getElementById(descId);
            if (descField) {
                descField.value = record.value || '';
            }
        }

        // 3. Armazena TODOS os dados no cache para campos IE
        setLookupData(fieldName, record.data);

        // 4. Preenche campos IE que referenciam este lookup
        fillLinkedIEFields(fieldElement, record.data);

        // 5. Dispara eventos change e blur para processar OnExit
        fieldElement.dispatchEvent(new Event('change', { bubbles: true }));
        fieldElement.dispatchEvent(new Event('blur', { bubbles: true }));

        console.log('[SagEvents] Campo', fieldName, 'preenchido com:', record.key);
    }

    /**
     * Preenche campos IE que estão vinculados a um campo de lookup.
     * Campos IE têm data-sag-linked-lookup apontando para o campo lookup.
     * @param {HTMLElement} lookupField - Campo de lookup que foi selecionado
     * @param {Object} recordData - Dados completos do registro selecionado
     */
    function fillLinkedIEFields(lookupField, recordData) {
        const lookupFieldName = (lookupField.dataset.sagNomecamp || lookupField.name || '').toUpperCase();
        if (!lookupFieldName) return;

        // Encontra todos os campos IE que referenciam este lookup
        const linkedFields = document.querySelectorAll(`[data-sag-linked-lookup="${lookupFieldName}"]`);

        linkedFields.forEach(ieField => {
            const sourceColumn = (ieField.dataset.sagSourceColumn || '').toUpperCase();
            if (!sourceColumn) return;

            // Busca o valor no registro (case-insensitive)
            let value = null;
            for (const [key, val] of Object.entries(recordData)) {
                if (key.toUpperCase() === sourceColumn) {
                    value = val;
                    break;
                }
            }

            if (value !== null && value !== undefined) {
                ieField.value = value;
                console.log(`[SagEvents] Campo IE ${ieField.dataset.sagNomecamp} preenchido com ${sourceColumn}:`, value);
            }
        });
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
                        // Verifica filhos - campos com duplo clique
                        const duplCliqFields = node.querySelectorAll?.('[data-has-duplcliq="true"]');
                        if (duplCliqFields && duplCliqFields.length > 0) {
                            bindDuplCliq(node);
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

        // Prepara colunas (até 5 colunas para não ficar muito largo)
        const displayColumns = columns.slice(0, 5);

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
                        <div class="modal-body p-0">
                            <div class="p-3 pb-0">
                                <input type="text" class="form-control" id="lookupFilter"
                                       placeholder="Digite para filtrar..." autocomplete="off">
                            </div>
                            <div id="lookupAgGrid"
                                 class="ag-theme-quartz"
                                 style="height: 400px; width: 100%;"></div>
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
        const gridContainer = document.getElementById('lookupAgGrid');
        const filterInput = document.getElementById('lookupFilter');
        const recordCount = document.getElementById('lookupRecordCount');

        // Variável para armazenar a API do AG Grid
        let gridApi = null;

        // Prepara dados no formato AG Grid (usa record.data como dados da linha)
        const rowData = records.map(record => ({
            ...record.data,
            _originalRecord: record // Preserva o registro original para seleção
        }));

        // Atualiza contador
        recordCount.textContent = `${records.length} registro(s)`;

        // Configura colunas do AG Grid (com labels amigáveis)
        const columnDefs = displayColumns.map(col => ({
            field: col,
            headerName: formatColumnName(col),
            sortable: true,
            resizable: true,
            minWidth: 100
        }));

        // Função para selecionar registro e fechar modal
        function selectRecord(record) {
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
        }

        // Opções do AG Grid
        const gridOptions = {
            columnDefs: columnDefs,
            rowData: rowData,
            rowSelection: 'single',
            animateRows: true,
            enableCellTextSelection: true,

            // Column menu (AG Grid Enterprise)
            columnMenu: 'new',
            suppressMenuHide: false,

            // Painel lateral de colunas (igual ao Vision)
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
                defaultToolPanel: '',
            },

            // Barra de agrupamento no topo
            rowGroupPanelShow: 'always',
            suppressDragLeaveHidesColumns: true,

            // Overlay de loading
            overlayNoRowsTemplate: '<div class="ag-overlay-no-rows-center"><i class="bi bi-inbox fs-4 d-block mb-2"></i>Nenhum registro encontrado</div>',

            // Default column definition
            defaultColDef: {
                sortable: true,
                resizable: true,
                filter: true,
                menuTabs: ['filterMenuTab', 'generalMenuTab', 'columnsMenuTab']
            },

            // Callback de click para seleção
            onRowClicked: (event) => {
                const originalRecord = event.data._originalRecord;
                if (originalRecord) {
                    selectRecord(originalRecord);
                }
            },

            // Callback de grid ready - autoSize das colunas
            onGridReady: (params) => {
                gridApi = params.api;
                // Auto-dimensiona colunas pelo conteúdo
                params.api.autoSizeAllColumns();
            }
        };

        // Cria o AG Grid quando o modal estiver visível
        modal.addEventListener('shown.bs.modal', () => {
            // Verifica se AG Grid está disponível
            if (typeof agGrid !== 'undefined') {
                agGrid.createGrid(gridContainer, gridOptions);
            } else {
                console.error('[SagEvents] AG Grid não disponível para lookup modal');
                gridContainer.innerHTML = '<div class="p-4 text-center text-muted">AG Grid não disponível</div>';
            }
            filterInput.focus();
        });

        // Filtro em tempo real usando quickFilter do AG Grid
        let filterTimeout = null;
        filterInput.addEventListener('input', () => {
            clearTimeout(filterTimeout);
            filterTimeout = setTimeout(() => {
                const filter = filterInput.value.trim();
                if (gridApi) {
                    gridApi.setGridOption('quickFilterText', filter);
                    // Atualiza contador
                    const displayedRows = gridApi.getDisplayedRowCount();
                    recordCount.textContent = `${displayedRows} de ${records.length} registro(s)`;
                }
            }, 200);
        });

        // Limpa modal ao fechar
        modal.addEventListener('hidden.bs.modal', () => {
            if (gridApi) {
                gridApi.destroy();
            }
            modal.remove();
        });

        // Mostra o modal
        bsModal.show();
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
    // LOOKUP AUTO-FETCH - Busca descrição ao digitar código
    // Similar ao TDBLookNume do Delphi que busca no OnExit
    // ============================================

    /**
     * Faz bind nos campos lookup para buscar descrição automaticamente
     * quando o usuário digita um código e sai do campo (blur).
     *
     * Comportamento similar ao TDBLookNume do Delphi:
     * - Usuário digita código diretamente
     * - Ao sair do campo (Tab/Enter/Click fora)
     * - Sistema busca descrição pelo código
     * - Preenche campo de descrição
     * - Preenche campos IE vinculados
     *
     * @param {HTMLElement} container - Container onde buscar os campos (default: document)
     */
    function bindLookupAutoFetch(container = document) {
        const lookupInputs = container.querySelectorAll('.lookup-code-input[data-lookup-sql]');
        let count = 0;

        lookupInputs.forEach(input => {
            // Evita duplo bind
            if (input.dataset.autofetchBound) return;
            input.dataset.autofetchBound = 'true';

            // Armazena valor anterior para detectar mudança
            let previousValue = input.value || '';

            // Bind no blur (quando sai do campo)
            input.addEventListener('blur', async function(e) {
                const currentValue = this.value?.trim() || '';

                // Só busca se valor mudou e não está vazio
                if (currentValue === previousValue) {
                    return;
                }

                previousValue = currentValue;

                // Se limpou o campo, limpa a descrição
                if (!currentValue) {
                    clearLookupDescForField(this);
                    return;
                }

                // Busca descrição pelo código
                await fetchLookupByCode(this, currentValue);
            });

            // Também bind no Enter para buscar imediatamente
            input.addEventListener('keydown', async function(e) {
                if (e.key === 'Enter') {
                    const currentValue = this.value?.trim() || '';
                    if (currentValue && currentValue !== previousValue) {
                        previousValue = currentValue;
                        await fetchLookupByCode(this, currentValue);
                    }
                }
            });

            count++;
        });

        if (count > 0) {
            console.log('[SagEvents] Lookup Auto-Fetch vinculado em', count, 'campos');
        }
    }

    /**
     * Busca descrição de lookup pelo código digitado.
     * @param {HTMLElement} input - Campo de input do lookup
     * @param {string} code - Código digitado
     */
    async function fetchLookupByCode(input, code) {
        const sql = input.dataset.lookupSql;
        const descId = input.dataset.lookupDescId;
        const fieldName = input.dataset.sagNomecamp || input.name;

        if (!sql) {
            console.warn('[SagEvents] Campo lookup sem data-lookup-sql');
            return;
        }

        console.log(`[SagEvents] Buscando lookup para ${fieldName}, código: ${code}`);

        try {
            const response = await fetch('/Form/LookupByCode', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ sql: sql, code: code })
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.error || 'Erro na busca');
            }

            if (data.found && data.record) {
                // Encontrou o registro
                const record = data.record;

                // 1. Preenche campo de descrição
                if (descId) {
                    const descField = document.getElementById(descId);
                    if (descField) {
                        descField.value = record.value || '';
                    }
                }

                // 2. Armazena dados no cache para campos IE
                if (fieldName && record.data) {
                    setLookupData(fieldName, record.data);
                }

                // 3. Preenche campos IE vinculados
                fillLinkedIEFields(input, record.data || {});

                console.log(`[SagEvents] Lookup encontrado: ${fieldName} = ${record.value}`);

                // 4. Dispara eventos change e blur para processar OnExit
                // Obs: não dispara blur novamente para evitar loop
                input.dispatchEvent(new Event('change', { bubbles: true }));

            } else {
                // Código não encontrado - limpa descrição
                clearLookupDescForField(input);
                console.log(`[SagEvents] Lookup não encontrado para código: ${code}`);
            }

        } catch (error) {
            console.error('[SagEvents] Erro ao buscar lookup:', error);
            // Não limpa descrição em caso de erro de rede
        }
    }

    /**
     * Limpa a descrição de um campo lookup específico.
     * @param {HTMLElement} input - Campo de input do lookup
     */
    function clearLookupDescForField(input) {
        const descId = input.dataset.lookupDescId;
        if (descId) {
            const descField = document.getElementById(descId);
            if (descField) {
                descField.value = '';
            }
        }

        // Limpa dados do cache
        const fieldName = input.dataset.sagNomecamp || input.name;
        if (fieldName) {
            setLookupData(fieldName, {});
        }
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
        bindNumericRounding,
        bindDuplCliq,
        collectFormData,
        execFieldEventsOnShow,
        onRecordLoaded,
        // Lookup API
        openLookup,
        openExpandedLookup,
        setLookupData,
        getLookupData,
        clearLookupCache,
        populateLookupDescriptions,
        clearLookupDescriptions,
        fillLinkedIEFields,
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
        validateBeforeSave,
        // Lookup Auto-Fetch API
        bindLookupAutoFetch
    };
})();

// Expõe globalmente
window.SagEvents = SagEvents;
