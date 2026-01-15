/**
 * PLSAG Interpreter - Interpretador de instrucoes PLSAG para Web
 *
 * Implementa a Fase 2 do sistema de eventos SAG, executando instrucoes PLSAG
 * quando eventos sao disparados pelo sag-events.js.
 *
 * Baseado em:
 * - AI_SPECIFICATION.md (Especificacao Formal PL/SAG)
 * - PlusUni.pas (Implementacao Delphi original)
 *
 * @version 1.0
 */
const PlsagInterpreter = (function() {
    'use strict';

    // ============================================================
    // CONTEXTO DE EXECUCAO
    // ============================================================

    /**
     * Contexto de execucao - mantem estado entre instrucoes
     */
    const context = {
        // Dados do formulario (header/cabeçalho)
        formData: {},
        tableName: '',
        tableId: null,
        recordId: null,

        // Dados de movimento nivel 1 (DM templates)
        movementData: {},
        movementTableId: null,
        movementRecordId: null,

        // Dados de sub-movimento nivel 2 (D2 templates)
        subMovementData: {},
        subMovementTableId: null,
        subMovementRecordId: null,

        // Variaveis PLSAG por tipo/faixa
        variables: {
            integers: {},  // VA-INTE0001 a VA-INTE0020
            floats: {},    // VA-REAL0001 a VA-REAL0020
            strings: {},   // VA-STRI0001 a VA-STRI0020
            dates: {},     // VA-DATA0001 a VA-DATA0010
            values: {},    // VA-VALO0001 a VA-VALO0010
            results: {},   // VA-RESU0001 a VA-RESU0008
            custom: {}     // Variaveis customizadas
        },

        // Variaveis persistentes (sessao)
        persistent: {},

        // Variaveis publicas (globais)
        public: {},

        // Variaveis de sistema (somente leitura)
        system: {
            'INSERIND': false,
            'ALTERIND': false,
            'VISUALIZ': false,
            'CODIPESS': null,
            'CODIEMPR': null,
            'CODIFILI': null,
            'CODIUSUA': null,
            'NOMEUSU': '',
            'DATAATUA': null,
            'HORAATUA': null,
            'CODITABE': null,
            'REGISTRO': null,
            'ULTIMOID': null,
            'RETOFUNC': null,
            'EOF': false,      // End of File - fim dos registros da query
            'BOF': false       // Beginning of File - inicio dos registros da query
        },

        // Resultados de queries
        queryResults: {},
        queryMultiResults: {},

        // Cursores de query para navegacao manual (ABRE, FECH, PRIM, PROX, ANTE, ULTI)
        queryCursors: {},      // { queryName: { data: [], index: 0, isOpen: bool, sql: '' } }
        queryDefinitions: {},  // { queryName: 'SELECT ...' } - armazena SQL das queries

        // Controle de fluxo
        control: {
            shouldStop: false,
            returnValue: null,
            blockStack: [],      // Pilha de blocos IF
            loopStack: [],       // Pilha de loops WH
            errorState: null
        },

        // Metadados da execucao
        meta: {
            eventType: '',
            triggerField: '',
            triggerValue: '',
            executionId: '',
            startTime: null,
            instructionCount: 0
        }
    };

    // Limite de instrucoes por execucao (seguranca)
    const MAX_INSTRUCTIONS = 1000;

    // ============================================================
    // PARSER
    // ============================================================

    /**
     * Tokeniza uma string de instrucoes PLSAG
     * @param {string} instructions - Instrucoes separadas por ";" ou quebra de linha
     * @returns {Array<Object>} Array de tokens
     */
    function tokenize(instructions) {
        if (!instructions || typeof instructions !== 'string') {
            return [];
        }

        // Pre-processa: junta linhas ME-...-SELECT com a mensagem na proxima linha
        const preprocessed = preprocessMeInstructions(instructions);

        // Trata quebras de linha como separadores (assim como ";")
        // Primeiro normaliza \r\n para \n, depois substitui \n por ";"
        const cleaned = preprocessed.replace(/\r\n/g, '\n').replace(/\n/g, ';').trim();

        if (!cleaned) {
            return [];
        }

        // Divide por ";" mas preserva ";" dentro de strings
        const tokens = [];
        let current = '';
        let inString = false;
        let stringChar = '';

        for (let i = 0; i < cleaned.length; i++) {
            const char = cleaned[i];

            if ((char === "'" || char === '"') && !inString) {
                inString = true;
                stringChar = char;
                current += char;
            } else if (char === stringChar && inString) {
                inString = false;
                stringChar = '';
                current += char;
            } else if (char === ';' && !inString) {
                if (current.trim()) {
                    const parsed = parseInstruction(current.trim());
                    if (parsed) {
                        tokens.push(parsed);
                    }
                }
                current = '';
            } else {
                current += char;
            }
        }

        // Ultima instrucao (sem ; no final)
        if (current.trim()) {
            const parsed = parseInstruction(current.trim());
            if (parsed) {
                tokens.push(parsed);
            }
        }

        return tokens;
    }

    /**
     * Pre-processa instrucoes ME com SELECT para juntar a mensagem da proxima linha.
     * Formato: ME-CAMPO---SELECT...VALO FROM DUAL\nMensagem de erro
     * Resultado: ME-CAMPO---SELECT...VALO FROM DUAL|||Mensagem de erro
     */
    function preprocessMeInstructions(instructions) {
        const lines = instructions.replace(/\r\n/g, '\n').split('\n');
        const result = [];

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            const upperLine = line.toUpperCase();

            // Detecta ME/MB/MI-...-SELECT (comandos de mensagem com validacao SQL)
            const isMsgWithSelect = (upperLine.startsWith('ME-') ||
                                     upperLine.startsWith('MB-') ||
                                     upperLine.startsWith('MI-')) &&
                                    upperLine.includes('SELECT');

            if (isMsgWithSelect) {
                // Proxima linha nao vazia e um comando PLSAG (2+ chars seguido de -)
                const nextLine = i + 1 < lines.length ? lines[i + 1].trim() : '';

                // Se a proxima linha nao parece ser um comando (nao tem formato XX-...)
                if (nextLine && !isPlsagCommand(nextLine)) {
                    // Junta usando ||| como separador especial
                    result.push(line + '|||' + nextLine);
                    i++; // Pula a proxima linha (ja foi consumida)
                } else {
                    result.push(line);
                }
            } else {
                result.push(line);
            }
        }

        return result.join('\n');
    }

    /**
     * Verifica se uma linha parece ser um comando PLSAG (XX-...)
     */
    function isPlsagCommand(line) {
        if (!line || line.length < 3) return false;
        if (line.startsWith('--')) return true; // Comentario
        // Verifica se comeca com 2-3 letras seguidas de hifen
        return /^[A-Za-z]{2,3}-/.test(line);
    }

    /**
     * Faz parse de uma instrucao individual seguindo a regra dos 8 caracteres
     * @param {string} raw - Instrucao bruta
     * @returns {Object|null} Token parseado ou null
     */
    function parseInstruction(raw) {
        if (!raw || raw.length < 2) {
            return null;
        }

        // Ignora comentarios (linhas que comecam com --)
        if (raw.startsWith('--')) {
            return null;
        }

        // Ignora linhas que comecam com { - sao templates nao resolvidos ou expressoes
        // Exemplos: {C-N-VLUNMV, {CN-VALOMVPO}-{CN-DCTOMVPO}
        if (raw.startsWith('{')) {
            console.warn(`[PLSAG] Ignorando linha (template/expressao): "${raw.substring(0, 50)}..."`);
            return null;
        }

        // Ignora linhas que sao apenas numeros ou expressoes aritmeticas brutas
        // Exemplos: -+, 100-50+20, etc (resultados de templates vazios)
        if (/^[\d\.\+\-\*\/\(\)\s]+$/.test(raw) || /^[\-\+]+$/.test(raw)) {
            console.warn(`[PLSAG] Ignorando linha (expressao aritmetica): "${raw}"`);
            return null;
        }

        const prefix = raw.substring(0, 2).toUpperCase();
        const prefix3 = raw.substring(0, 3).toUpperCase();

        // === Verifica comandos DD* (Data Direto): DDG, DDM, DD2, DD3 ===
        // Forcam gravacao em dataset especifico independente do contexto
        const isDataDiretoCommand = prefix === 'DD' && ['DDG', 'DDM', 'DD2', 'DD3'].includes(prefix3);
        if (isDataDiretoCommand) {
            const forcedTarget = prefix3.charAt(2); // 'G', 'M', '2', '3'
            const startPos = 3;

            // Parse do resto: DDG-CAMPO---valor ou DDG-CAMPO---SELECT...
            let identifier, parameter;
            if (raw.length > startPos && raw[startPos] === '-') {
                const afterPrefix = raw.substring(startPos + 1);
                const nextHyphen = afterPrefix.indexOf('-');
                if (nextHyphen > 0) {
                    identifier = afterPrefix.substring(0, nextHyphen);
                    parameter = afterPrefix.substring(nextHyphen + 1);
                } else {
                    identifier = afterPrefix.substring(0, 8);
                    parameter = afterPrefix.substring(8).replace(/^-/, '');
                }
            } else {
                identifier = raw.substring(startPos, startPos + 8);
                parameter = raw.substring(startPos + 8).replace(/^-/, '');
            }

            return {
                raw: raw,
                prefix: 'DD',              // Prefixo base e 'DD'
                modifier: forcedTarget,    // G, M, 2, 3 indica dataset alvo
                identifier: (identifier || '').trim(),
                identifierPadded: (identifier || '').padEnd(8, ' '),
                parameter: parameter || '',
                hasParameter: !!parameter,
                isDataDireto: true,        // Flag especial
                forcedTarget: forcedTarget // G=header, M=mov1, 2=mov2, 3=mov3
            };
        }

        // Verifica se e um comando de 3 caracteres com modificador
        // Formatos: CE, CN, CS, CV, CF, CC, CM, CT, CI, CA, CR, CD, LN, LE, IL, EE, ES, ET, EC, ED, EA, EI, EL
        // com modificadores D, V, F, C, R
        // Exemplos: CED (Campo Enable + Disable), CNV (Campo Disable + Visible), CCD (Campo Combo + Disable)
        const validBaseCommands = [
            // Campos vinculados ao banco
            'CE', 'CN', 'CS', 'CV', 'CF', 'CC', 'CM', 'CT', 'CI', 'CA', 'CR', 'CD',
            // Inputs (sem banco)
            'IE', 'IN', 'IS', 'IV', 'IF', 'IC', 'IM', 'IT', 'II', 'IL',
            // Labels calculados
            'LN', 'LE',
            // Editores (volateis, sem banco)
            'EE', 'ES', 'ET', 'EC', 'ED', 'EA', 'EI', 'EL'
        ];
        const validModifiers = ['D', 'V', 'F', 'C', 'R'];
        const baseCmd = prefix3.substring(0, 2);
        const modChar = prefix3.charAt(2);
        const isThreeCharCommand = validBaseCommands.includes(baseCmd) && validModifiers.includes(modChar);

        // Define o tamanho do prefixo e modificador
        let actualPrefix = prefix;
        let modifier = '';
        let startPos = 2;

        if (isThreeCharCommand) {
            actualPrefix = prefix; // Mantém 2 chars como prefixo base
            modifier = raw.substring(2, 3).toUpperCase(); // 3º caractere é modificador
            startPos = 3;
        }

        // Verifica se tem separador apos prefixo
        const hasSeparator = raw.length > startPos && raw[startPos] === '-';

        let identifier, parameter;

        if (hasSeparator) {
            // Formato: PP-XXXXXXXX-parametro ou PPM-XXXXXXXX-parametro
            // Identificador: posicoes (startPos+1) ate (startPos+9) (8 caracteres)

            // Caso especial: ME-DG-CAMPO, ME-DM-CAMPO, etc.
            // Onde DG/DM/D2/D3 indica a fonte de dados e CAMPO é o nome real
            const afterPrefix = raw.substring(startPos + 1);
            const dataSourcePrefixes = ['DG-', 'DM-', 'D2-', 'D3-', 'EX-'];

            let dataSource = '';
            let identStart = startPos + 1;

            for (const dsPrefix of dataSourcePrefixes) {
                if (afterPrefix.toUpperCase().startsWith(dsPrefix)) {
                    dataSource = dsPrefix.substring(0, 2);
                    identStart = startPos + 1 + dsPrefix.length;
                    break;
                }
            }

            // Encontra o proximo hifen apos o identificador
            const restFromIdent = raw.substring(identStart);
            const nextHyphen = restFromIdent.indexOf('-');

            if (nextHyphen > 0) {
                identifier = restFromIdent.substring(0, nextHyphen);
                parameter = restFromIdent.substring(nextHyphen + 1);
            } else {
                // Fallback: 8 caracteres fixos
                identifier = raw.substring(startPos + 1, startPos + 9);
                const restAfterIdent = raw.substring(startPos + 9);
                if (restAfterIdent.startsWith('-')) {
                    parameter = restAfterIdent.substring(1);
                } else {
                    parameter = restAfterIdent;
                }
            }

            // Preserva informacao da fonte de dados no identificador se necessario
            if (dataSource && !identifier.startsWith(dataSource)) {
                // Armazena metadata sobre fonte de dados
                identifier = identifier.trim();
            }
        } else {
            // Formato sem hifen: PPXXXXXXXX-parametro ou PPMXXXXXXXX-parametro
            identifier = raw.substring(startPos, startPos + 8);
            const restAfterIdent = raw.substring(startPos + 8);
            if (restAfterIdent.startsWith('-')) {
                parameter = restAfterIdent.substring(1);
            } else {
                parameter = restAfterIdent;
            }
        }

        // Padroniza identificador para 8 caracteres
        identifier = (identifier || '').padEnd(8, ' ');

        return {
            raw: raw,
            prefix: actualPrefix,
            modifier: modifier,
            identifier: identifier.trim(),
            identifierPadded: identifier,
            parameter: parameter || '',
            hasParameter: !!parameter
        };
    }

    // ============================================================
    // SUBSTITUICAO DE TEMPLATES
    // ============================================================

    /**
     * Substitui templates {TIPO-CAMPO} pelos valores do contexto
     * @param {string} text - Texto com templates
     * @returns {string} Texto com valores substituidos
     */
    function substituteTemplates(text) {
        if (!text || typeof text !== 'string') {
            return text;
        }

        // Detecta templates incompletos (abre { mas não fecha })
        // Exemplos: {C-T-CODITP, {C-S-PDGEPE, [P-ERS-AGD-
        const incompletePattern = /\{[A-Z][A-Z0-9]?-[^}]*$/;
        if (incompletePattern.test(text)) {
            console.warn(`[PLSAG] Template incompleto detectado: "${text.substring(text.lastIndexOf('{'), text.length)}"`);
        }

        // Padrao: {TIPO-CAMPO} onde TIPO = DG, DM, D2, D3, VA, VP, PU, QY, FC, LI, etc.
        const templatePattern = /\{([A-Z][A-Z0-9])-([^}]+)\}/g;

        return text.replace(templatePattern, (match, type, field) => {
            const value = resolveTemplate(type, field);
            return value !== undefined ? String(value) : match;
        });
    }

    /**
     * Substitui templates para uso em SQL (quotes em strings)
     * @param {string} text - Texto com templates (SQL)
     * @returns {string} SQL com valores substituidos e quoted corretamente
     */
    function substituteTemplatesForSQL(text) {
        if (!text || typeof text !== 'string') {
            return text;
        }

        const templatePattern = /\{([A-Z][A-Z0-9])-([^}]+)\}/g;

        return text.replace(templatePattern, (match, type, field) => {
            const value = resolveTemplate(type, field);
            if (value === undefined) {
                // Em modo INSERT, campos de dados (DG/DM/D2/D3) nao resolvidos
                // provavelmente sao PKs IDENTITY - usar -1 ao inves de NULL
                // para evitar que validacoes ME bloqueiem incorretamente
                // Nota: usar -1 porque no SQL Server 0 = '' é TRUE (conversao implicita)
                if (context.system.INSERIND && ['DG', 'DM', 'D2', 'D3'].includes(type)) {
                    console.warn(`[PLSAG] Template não resolvido em INSERT: ${match} -> -1 (PK IDENTITY)`);
                    return '-1';
                }
                // Template não resolvido vira NULL em SQL
                console.warn(`[PLSAG] Template não resolvido em SQL: ${match} -> NULL`);
                return 'NULL';
            }
            return quoteForSQL(value);
        });
    }

    /**
     * Formata um valor para uso em SQL
     * @param {*} value - Valor a formatar
     * @returns {string} Valor formatado para SQL
     */
    function quoteForSQL(value) {
        if (value === null || value === undefined || value === '') {
            return 'NULL';
        }

        const strValue = String(value);

        // Verifica se e numero puro
        if (/^-?\d+(\.\d+)?$/.test(strValue)) {
            return strValue;
        }

        // Verifica se e data no formato ISO ou DD/MM/YYYY
        if (/^\d{4}-\d{2}-\d{2}$/.test(strValue) || /^\d{2}\/\d{2}\/\d{4}$/.test(strValue)) {
            // Escapa aspas simples e retorna como string SQL
            return "'" + strValue.replace(/'/g, "''") + "'";
        }

        // Para qualquer outro valor (string), escapa aspas e envolve em quotes
        return "'" + strValue.replace(/'/g, "''") + "'";
    }

    /**
     * Resolve um template especifico
     * @param {string} type - Tipo do template (DG, VA, QY, etc.)
     * @param {string} field - Nome do campo ou variavel
     * @returns {*} Valor resolvido ou undefined
     */
    function resolveTemplate(type, field) {
        const fieldTrimmed = field.trim();

        switch (type) {
            case 'DG':
            case 'DD':
                // DG/DD: Campo do formulário principal (header/cabeçalho)
                // DD (Data Detail) sem modificador é equivalente a DG
                return getFormFieldValue(fieldTrimmed);

            case 'DM':
                // DM: Campo do movimento nível 1
                return getMovementFieldValue(fieldTrimmed);

            case 'D2':
                // D2: Campo do sub-movimento nível 2
                return getSubMovementFieldValue(fieldTrimmed);

            case 'D3':
                // D3: Alias para header ou contexto especial (legado)
                // Tenta movimento primeiro, depois header
                return getMovementFieldValue(fieldTrimmed) ?? getFormFieldValue(fieldTrimmed);

            case 'CC': // Campo Combo
            case 'CE': // Campo Editor
            case 'CN': // Campo Numerico
            case 'CT': // Campo Tabela (Lookup)
            case 'IT': // Input Tabela (Lookup Informado)
            case 'CM': // Campo Memo
            case 'CS': // Campo Sim/Nao
            case 'CD': // Campo Data
            case 'CA': // Campo Arquivo
            case 'CR': // Campo Formatado
            case 'LN': // Label Numerico
            case 'LE': // Label Editor
            case 'IL': // Lookup Numerico
            case 'EE': // Editor Text
            case 'ES': // Editor Sim/Nao
            case 'ET': // Editor Memo
            case 'EC': // Editor Combo
            case 'ED': // Editor Data
            case 'EA': // Editor Arquivo
            case 'EI': // Editor Diretorio
            case 'EL': // Editor Lookup
                // Campo/Editor - Em contexto de movimento, primeiro tenta no movimento
                // Depois fallback para o formulário principal
                if (isInMovementContext()) {
                    const movValue = getMovementFieldValue(fieldTrimmed);
                    if (movValue !== undefined) {
                        return movValue;
                    }
                }
                return getFormFieldValue(fieldTrimmed);

            case 'VA':
                // Variavel local
                return getVariable(fieldTrimmed);

            case 'VP':
                // Variavel persistente
                return context.persistent[fieldTrimmed] ??
                       getFromSessionStorage(`plsag_vp_${fieldTrimmed}`);

            case 'PU':
                // Variavel publica
                return context.public[fieldTrimmed] ??
                       getFromSessionStorage(`plsag_pu_${fieldTrimmed}`);

            case 'QY':
                // Resultado de query
                return resolveQueryTemplate(fieldTrimmed);

            case 'FC':
                // Campo formatado
                return formatFieldValue(fieldTrimmed);

            case 'CS':
                // Valor de checkbox (0 ou 1)
                return getCheckboxValue(fieldTrimmed);

            default:
                console.warn(`[PLSAG] Template tipo desconhecido: ${type}`);
                return undefined;
        }
    }

    /**
     * Obtem valor de um campo do formulario principal (header)
     */
    function getFormFieldValue(fieldName) {
        // Primeiro tenta no contexto
        if (context.formData[fieldName] !== undefined) {
            return context.formData[fieldName];
        }

        // Tenta encontrar o elemento no DOM (formulário principal)
        const element = PlsagCommands?.findField?.(fieldName);
        if (element) {
            if (element.type === 'checkbox') {
                return element.checked ? '1' : '0';
            }
            // Retorna o valor mesmo se vazio - importante para que templates
            // como {IT-CAMPO} sejam substituídos por '' em vez de ficarem como {IT-CAMPO}
            // Isso garante que IF-INIC funcione corretamente para campos vazios
            return element.value || '';
        }

        // Fallback: Se o campo é a PK e está vazio, usa editingRecordId
        // Isso é necessário no Saga Pattern onde o PK é criado antes do form ser preenchido
        const editingRecordId = document.getElementById('editingRecordId');
        if (editingRecordId && editingRecordId.value) {
            const pkFieldName = editingRecordId.getAttribute('data-pk-field');
            const upperFieldName = fieldName.toUpperCase();
            const upperPkFieldName = pkFieldName?.toUpperCase();

            // Match exato com o campo PK configurado
            if (pkFieldName && upperFieldName === upperPkFieldName) {
                console.log(`[PLSAG] getFormFieldValue: ${fieldName} usando editingRecordId (match exato) = ${editingRecordId.value}`);
                return editingRecordId.value;
            }

            // Fallback adicional: Se o campo pedido começa com "CODI" e não foi encontrado,
            // pode ser um nome alternativo para a PK (ex: CODICONT vs CODICOTR no sistema legado)
            // Isso acontece quando scripts PLSAG antigos usam nomes diferentes para a mesma PK
            if (upperFieldName.startsWith('CODI')) {
                console.log(`[PLSAG] getFormFieldValue: ${fieldName} usando editingRecordId (fallback CODI*) = ${editingRecordId.value}`);
                return editingRecordId.value;
            }
        }

        return undefined;
    }

    /**
     * Obtem valor de um campo do movimento nível 1 (DM)
     * @param {string} fieldName - Nome do campo
     * @returns {*} Valor do campo ou undefined
     */
    function getMovementFieldValue(fieldName) {
        // Primeiro tenta no contexto movementData
        if (context.movementData[fieldName] !== undefined) {
            return context.movementData[fieldName];
        }

        // Tenta case-insensitive
        const upperField = fieldName.toUpperCase();
        for (const [key, value] of Object.entries(context.movementData)) {
            if (key.toUpperCase() === upperField) {
                return value;
            }
        }

        // Tenta encontrar no modal de movimento (se aberto)
        // Usa data-sag-nomecamp que é o atributo padrao dos campos
        let modalElement = document.querySelector(`#movementFormContent [data-sag-nomecamp="${fieldName}"]`);
        // Fallback para case-insensitive
        if (!modalElement) {
            modalElement = document.querySelector(`#movementFormContent [data-sag-nomecamp="${fieldName.toUpperCase()}"]`);
        }
        // Fallback para name attribute
        if (!modalElement) {
            modalElement = document.querySelector(`#movementFormContent [name="${fieldName}"]`);
        }
        if (modalElement) {
            if (modalElement.type === 'checkbox') {
                return modalElement.checked ? '1' : '0';
            }
            return modalElement.value;
        }

        // Fallback: tenta no SagEvents se há contexto de movimento ativo
        if (window.SagEvents) {
            const movementContext = SagEvents.getActiveMovementContext?.();
            if (movementContext?.formData?.[fieldName] !== undefined) {
                return movementContext.formData[fieldName];
            }
        }

        return undefined;
    }

    /**
     * Obtem valor de um campo do sub-movimento nível 2 (D2)
     * @param {string} fieldName - Nome do campo
     * @returns {*} Valor do campo ou undefined
     */
    function getSubMovementFieldValue(fieldName) {
        // Primeiro tenta no contexto subMovementData
        if (context.subMovementData[fieldName] !== undefined) {
            return context.subMovementData[fieldName];
        }

        // Tenta case-insensitive
        const upperField = fieldName.toUpperCase();
        for (const [key, value] of Object.entries(context.subMovementData)) {
            if (key.toUpperCase() === upperField) {
                return value;
            }
        }

        return undefined;
    }

    /**
     * Verifica se estamos em contexto de movimento ativo.
     * Retorna true se:
     * - O modal de movimento está aberto
     * - OU temos dados de movimento no contexto
     * - OU o SagEvents tem contexto de movimento ativo
     * @returns {boolean}
     */
    function isInMovementContext() {
        // Verifica se o modal de movimento está aberto
        const movementModal = document.getElementById('movementModal');
        if (movementModal && movementModal.classList.contains('show')) {
            return true;
        }

        // Verifica se temos dados de movimento no contexto
        if (context.movementData && Object.keys(context.movementData).length > 0) {
            return true;
        }

        // Verifica se o SagEvents tem contexto de movimento ativo
        if (window.SagEvents) {
            const movementContext = SagEvents.getActiveMovementContext?.();
            if (movementContext?.movementTableId) {
                return true;
            }
        }

        return false;
    }

    /**
     * Obtem valor de uma variavel
     */
    function getVariable(varName) {
        // Verifica se e variavel de sistema
        if (context.system[varName] !== undefined) {
            return context.system[varName];
        }

        // Verifica faixas tipadas
        const faixaMatch = varName.match(/^(INTE|REAL|STRI|DATA|VALO|RESU)(\d{4})$/);
        if (faixaMatch) {
            const [, tipo, indice] = faixaMatch;
            switch (tipo) {
                case 'INTE':
                    return context.variables.integers[indice];
                case 'REAL':
                    return context.variables.floats[indice];
                case 'STRI':
                    return context.variables.strings[indice];
                case 'DATA':
                    return context.variables.dates[indice];
                case 'VALO':
                    return context.variables.values[indice];
                case 'RESU':
                    return context.variables.results[indice];
            }
        }

        // Variavel customizada
        return context.variables.custom[varName];
    }

    /**
     * Define valor de uma variavel
     */
    function setVariable(varName, value) {
        // Verifica faixas tipadas
        const faixaMatch = varName.match(/^(INTE|REAL|STRI|DATA|VALO|RESU)(\d{4})$/);
        if (faixaMatch) {
            const [, tipo, indice] = faixaMatch;
            switch (tipo) {
                case 'INTE':
                    context.variables.integers[indice] = parseInt(value) || 0;
                    return;
                case 'REAL':
                    context.variables.floats[indice] = parseFloat(value) || 0;
                    return;
                case 'STRI':
                    context.variables.strings[indice] = String(value);
                    return;
                case 'DATA':
                    context.variables.dates[indice] = value;
                    return;
                case 'VALO':
                    context.variables.values[indice] = value;
                    return;
                case 'RESU':
                    context.variables.results[indice] = value;
                    return;
            }
        }

        // Variavel customizada
        context.variables.custom[varName] = value;
    }

    /**
     * Resolve template de query {QY-NOME-CAMPO}
     * Inclui suporte a {QY-DAD<CodiTabe>-<expression>} para agregações de grid
     * Também busca dados do cache de lookup do SagEvents
     */
    function resolveQueryTemplate(fieldSpec) {
        const parts = fieldSpec.split('-');
        if (parts.length >= 2) {
            const queryName = parts[0].trim();
            const fieldName = parts.slice(1).join('-').trim();

            // Detecta templates QY-DAD<CodiTabe>-<expression>
            // Exemplo: DAD83603-SUM(Qtde), DAD83603-NUMEREGI
            if (queryName.startsWith('DAD')) {
                const tableId = queryName.substring(3); // "83603"
                return resolveQyDadTemplate(tableId, fieldName);
            }

            // 1. Primeiro tenta em queryResults (resultados de comandos QY)
            const queryResult = context.queryResults[queryName];
            if (queryResult && queryResult[fieldName] !== undefined) {
                return queryResult[fieldName];
            }

            // 2. Fallback: Busca no cache de lookup do SagEvents
            // Isso permite que {QY-CAMPO-Coluna} acesse dados de campos lookup
            // Exemplo: {QY-CODIINFO-Informação 1} busca coluna do lookup CODIINFO
            if (window.SagEvents && typeof SagEvents.getLookupData === 'function') {
                const lookupData = SagEvents.getLookupData(queryName);
                if (lookupData) {
                    // Tenta match exato primeiro
                    if (lookupData[fieldName] !== undefined) {
                        console.log(`[PLSAG] QY-${queryName}-${fieldName} resolvido via lookupCache (match exato)`);
                        return lookupData[fieldName];
                    }
                    // Tenta case-insensitive
                    const upperField = fieldName.toUpperCase();
                    for (const [key, value] of Object.entries(lookupData)) {
                        if (key.toUpperCase() === upperField) {
                            console.log(`[PLSAG] QY-${queryName}-${fieldName} resolvido via lookupCache (case-insensitive: ${key})`);
                            return value;
                        }
                    }
                    // Tenta match parcial (campo pode ter nome diferente do header)
                    // Ex: "Informação 1" pode ser armazenado como "INFO1"
                    const normalizedField = fieldName.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
                    for (const [key, value] of Object.entries(lookupData)) {
                        const normalizedKey = key.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
                        if (normalizedKey === normalizedField || normalizedKey.includes(normalizedField) || normalizedField.includes(normalizedKey)) {
                            console.log(`[PLSAG] QY-${queryName}-${fieldName} resolvido via lookupCache (match parcial: ${key})`);
                            return value;
                        }
                    }
                }
            }
        }
        return undefined;
    }

    /**
     * Resolve template {QY-DAD<CodiTabe>-<expression>} para agregações de grid de movimento
     *
     * Expressões suportadas:
     * - NUMEREGI: Número de linhas no grid
     * - SUM(coluna): Soma da coluna
     * - MIN(coluna): Valor mínimo
     * - MAX(coluna): Valor máximo
     * - AVG(coluna): Média
     * - COUNT(*): Contagem de registros
     *
     * @param {string} tableId - ID da tabela de movimento (ex: "83603")
     * @param {string} expression - Expressão de agregação (ex: "SUM(Qtde)")
     * @returns {number|string} Resultado da agregação
     */
    function resolveQyDadTemplate(tableId, expression) {
        const gridApi = getMovementGridApi(tableId);
        if (!gridApi) {
            console.warn(`[PLSAG] QY-DAD${tableId}: Grid não encontrado`);
            return 0;
        }

        // NUMEREGI - número de registros
        if (expression.toUpperCase() === 'NUMEREGI') {
            const count = gridApi.getDisplayedRowCount();
            console.log(`[PLSAG] QY-DAD${tableId}-NUMEREGI = ${count}`);
            return count;
        }

        // Expressões de agregação: SUM(col), MIN(col), MAX(col), AVG(col), COUNT(*)
        const aggMatch = expression.match(/^(SUM|MIN|MAX|AVG|COUNT)\((.+)\)$/i);
        if (aggMatch) {
            const func = aggMatch[1].toUpperCase();
            const column = aggMatch[2].trim();
            const result = calculateGridAggregate(gridApi, func, column);
            console.log(`[PLSAG] QY-DAD${tableId}-${func}(${column}) = ${result}`);
            return result;
        }

        // Campo direto (sem agregação) - retorna valor da primeira linha
        const firstRow = gridApi.getDisplayedRowAtIndex(0);
        if (firstRow && firstRow.data) {
            const value = getGridCellValue(firstRow.data, expression);
            console.log(`[PLSAG] QY-DAD${tableId}-${expression} = ${value}`);
            return value ?? 0;
        }

        return 0;
    }

    /**
     * Obtém referência ao AG Grid API de um movimento
     * @param {string} tableId - ID da tabela de movimento
     * @returns {Object|null} AG Grid API ou null
     */
    function getMovementGridApi(tableId) {
        // Tenta encontrar o grid pelo ID do container
        const gridElement = document.querySelector(`#movement-grid-${tableId}`);
        if (gridElement && gridElement.__agGridApi) {
            return gridElement.__agGridApi;
        }

        // Tenta via MovementManager se disponível
        if (window.MovementManager && MovementManager.getGridApi) {
            const api = MovementManager.getGridApi(tableId);
            if (api) return api;
        }

        // Fallback: procura grid no container de movimento
        const container = document.querySelector(`[data-movement="${tableId}"]`);
        if (container) {
            const gridDiv = container.querySelector('.ag-theme-quartz, .ag-theme-alpine');
            if (gridDiv && gridDiv.__agGridApi) {
                return gridDiv.__agGridApi;
            }
        }

        return null;
    }

    /**
     * Calcula agregação em dados do grid
     * @param {Object} gridApi - AG Grid API
     * @param {string} func - Função de agregação (SUM, MIN, MAX, AVG, COUNT)
     * @param {string} column - Nome ou header da coluna
     * @returns {number} Resultado da agregação
     */
    function calculateGridAggregate(gridApi, func, column) {
        const values = [];
        const rowCount = gridApi.getDisplayedRowCount();

        for (let i = 0; i < rowCount; i++) {
            const rowNode = gridApi.getDisplayedRowAtIndex(i);
            if (rowNode && rowNode.data) {
                const value = getGridCellValue(rowNode.data, column);
                if (value !== null && value !== undefined) {
                    const numValue = parseFloat(value);
                    if (!isNaN(numValue)) {
                        values.push(numValue);
                    }
                }
            }
        }

        if (values.length === 0) {
            return func === 'COUNT' ? rowCount : 0;
        }

        switch (func) {
            case 'SUM':
                return values.reduce((a, b) => a + b, 0);
            case 'MIN':
                return Math.min(...values);
            case 'MAX':
                return Math.max(...values);
            case 'AVG':
                return values.reduce((a, b) => a + b, 0) / values.length;
            case 'COUNT':
                return column === '*' ? rowCount : values.length;
            default:
                return 0;
        }
    }

    /**
     * Obtém valor de uma célula do grid por nome de campo ou header
     * @param {Object} rowData - Dados da linha
     * @param {string} column - Nome do campo ou texto do header
     * @returns {*} Valor da célula ou null
     */
    function getGridCellValue(rowData, column) {
        // Tenta match exato
        if (rowData[column] !== undefined) {
            return rowData[column];
        }

        // Tenta case-insensitive
        const upperColumn = column.toUpperCase();
        for (const [key, value] of Object.entries(rowData)) {
            if (key.toUpperCase() === upperColumn) {
                return value;
            }
        }

        // Tenta match por display name (header pode ser diferente do field)
        // Ex: "Valor Tab." pode ser o header mas o field é "VALOTABE"
        for (const [key, value] of Object.entries(rowData)) {
            // Normaliza para comparação (remove espaços, pontos, etc)
            const normalizedKey = key.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
            const normalizedColumn = column.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
            if (normalizedKey === normalizedColumn || normalizedKey.includes(normalizedColumn)) {
                return value;
            }
        }

        return null;
    }

    /**
     * Formata valor de campo
     */
    function formatFieldValue(fieldName) {
        const value = getFormFieldValue(fieldName);
        // TODO: Implementar formatacao especifica por tipo
        return value;
    }

    /**
     * Obtem valor de checkbox
     */
    function getCheckboxValue(fieldName) {
        const element = PlsagCommands?.findField?.(fieldName);
        if (element && element.type === 'checkbox') {
            return element.checked ? '1' : '0';
        }
        return getFormFieldValue(fieldName);
    }

    /**
     * Obtem valor do sessionStorage
     */
    function getFromSessionStorage(key) {
        try {
            const value = sessionStorage.getItem(key);
            return value ? JSON.parse(value) : undefined;
        } catch {
            return undefined;
        }
    }

    // ============================================================
    // AVALIACAO DE EXPRESSOES
    // ============================================================

    /**
     * Avalia uma expressao condicional
     * @param {string} expression - Expressao a avaliar
     * @returns {boolean} Resultado da avaliacao
     */
    function evaluateCondition(expression) {
        if (!expression || !expression.trim()) {
            return true; // Sem condicao = verdadeiro
        }

        // Substitui templates
        let evaluated = substituteTemplates(expression);

        // Remove aspas de strings para comparacao
        evaluated = evaluated.trim();

        // Operadores de comparacao
        const operators = ['<>', '>=', '<=', '!=', '=', '>', '<'];

        for (const op of operators) {
            const pos = evaluated.indexOf(op);
            if (pos > 0) {
                const left = evaluated.substring(0, pos).trim();
                const right = evaluated.substring(pos + op.length).trim();
                return compareValues(left, right, op);
            }
        }

        // Sem operador - verifica se e truthy
        return isTruthy(evaluated);
    }

    /**
     * Compara dois valores com operador
     */
    function compareValues(left, right, operator) {
        // Remove aspas das strings
        const leftVal = stripQuotes(left);
        const rightVal = stripQuotes(right);

        // Tenta comparar como numeros se possivel
        const leftNum = parseFloat(leftVal);
        const rightNum = parseFloat(rightVal);
        const bothNumbers = !isNaN(leftNum) && !isNaN(rightNum);

        switch (operator) {
            case '=':
                return bothNumbers ? leftNum === rightNum : leftVal === rightVal;
            case '<>':
            case '!=':
                return bothNumbers ? leftNum !== rightNum : leftVal !== rightVal;
            case '>':
                return bothNumbers ? leftNum > rightNum : leftVal > rightVal;
            case '<':
                return bothNumbers ? leftNum < rightNum : leftVal < rightVal;
            case '>=':
                return bothNumbers ? leftNum >= rightNum : leftVal >= rightVal;
            case '<=':
                return bothNumbers ? leftNum <= rightNum : leftVal <= rightVal;
            default:
                return false;
        }
    }

    /**
     * Remove aspas de uma string
     */
    function stripQuotes(value) {
        if (typeof value !== 'string') return value;
        const trimmed = value.trim();
        if ((trimmed.startsWith("'") && trimmed.endsWith("'")) ||
            (trimmed.startsWith('"') && trimmed.endsWith('"'))) {
            return trimmed.substring(1, trimmed.length - 1);
        }
        return trimmed;
    }

    /**
     * Verifica se valor e truthy no contexto PLSAG
     */
    function isTruthy(value) {
        if (value === null || value === undefined) return false;
        if (value === '' || value === '0' || value === 'N' || value === 'n') return false;
        if (value === 0 || value === false) return false;
        return true;
    }

    /**
     * Avalia funcao IF(condicao, valorTrue, valorFalse)
     * @param {string} expression - Expressao contendo IF(...)
     * @returns {string} Resultado da avaliacao
     */
    function evaluateIfFunction(expression) {
        if (!expression || typeof expression !== 'string') {
            return expression;
        }

        // Padrão para IF(condição, valorTrue, valorFalse)
        // Também captura prefixo opcional CAMPO-IF(...) - padrão SAG
        // Ex: CODIPESS-IF({QY-CODIPESS-SITUCLIE}='BQMA',0,1) -> 0 ou 1
        const ifPatternWithPrefix = /(\w+)-IF\s*\((.+)\)/i;
        const ifPatternSimple = /IF\s*\((.+)\)/i;

        // Tenta primeiro o padrão com prefixo (CAMPO-IF)
        let match = expression.match(ifPatternWithPrefix);
        let hasPrefix = false;

        if (match) {
            hasPrefix = true;
        } else {
            // Fallback para padrão simples (IF sem prefixo)
            match = expression.match(ifPatternSimple);
        }

        if (!match) {
            return expression;
        }

        const fullMatch = match[0];
        const innerContent = hasPrefix ? match[2] : match[1];

        // Divide os argumentos do IF respeitando aspas e parênteses
        const args = splitIfArguments(innerContent);

        if (args.length < 3) {
            console.warn('[PLSAG] IF com menos de 3 argumentos:', expression);
            return expression;
        }

        const condition = args[0].trim();
        const trueValue = args[1].trim();
        const falseValue = args[2].trim();

        // Avalia a condição
        const condResult = evaluateCondition(condition);
        const result = condResult ? trueValue : falseValue;

        // Debug: mostra quando prefixo foi removido
        if (hasPrefix) {
            console.log(`[PLSAG-DEBUG] IF com prefixo: "${fullMatch}" -> "${result}" (prefixo ${match[1]} removido)`);
        }

        // Substitui a função IF (com ou sem prefixo) pelo resultado
        const newExpression = expression.replace(fullMatch, result);

        // Avalia recursivamente caso haja mais IFs aninhados
        if (newExpression.toUpperCase().includes('IF(')) {
            return evaluateIfFunction(newExpression);
        }

        return newExpression;
    }

    /**
     * Divide argumentos de IF respeitando aspas e parênteses
     * @param {string} content - Conteúdo dentro do IF()
     * @returns {string[]} Array de argumentos
     */
    function splitIfArguments(content) {
        const args = [];
        let current = '';
        let depth = 0;
        let inQuotes = false;
        let quoteChar = '';

        for (let i = 0; i < content.length; i++) {
            const char = content[i];
            const prevChar = i > 0 ? content[i - 1] : '';

            // Tratamento de aspas
            if ((char === "'" || char === '"') && prevChar !== '\\') {
                if (!inQuotes) {
                    inQuotes = true;
                    quoteChar = char;
                } else if (char === quoteChar) {
                    inQuotes = false;
                    quoteChar = '';
                }
            }

            // Tratamento de parênteses
            if (!inQuotes) {
                if (char === '(') depth++;
                if (char === ')') depth--;
            }

            // Vírgula separadora (apenas no nível 0 e fora de aspas)
            if (char === ',' && depth === 0 && !inQuotes) {
                args.push(current);
                current = '';
            } else {
                current += char;
            }
        }

        // Último argumento
        if (current) {
            args.push(current);
        }

        return args;
    }

    /**
     * Avalia expressao completa (templates + funcoes IF + aritmetica)
     * @param {string} expression - Expressao a avaliar
     * @returns {*} Resultado da avaliacao
     */
    function evaluateExpression(expression) {
        if (!expression || typeof expression !== 'string') {
            return expression;
        }

        // 1. Substitui templates
        let evaluated = substituteTemplates(expression);

        // DEBUG: Log para diagnóstico
        if (expression !== evaluated) {
            console.log(`[PLSAG-DEBUG] Template: "${expression}" -> "${evaluated}"`);
        }

        // 2. Avalia funcoes IF
        if (evaluated.toUpperCase().includes('IF(')) {
            const beforeIf = evaluated;
            evaluated = evaluateIfFunction(evaluated);
            console.log(`[PLSAG-DEBUG] IF: "${beforeIf}" -> "${evaluated}"`);
        }

        // 3. Tenta avaliar como aritmetica
        const result = evaluateArithmetic(evaluated);
        if (result !== evaluated) {
            console.log(`[PLSAG-DEBUG] Arithmetic: "${evaluated}" -> ${result} (type: ${typeof result})`);
        }
        return result;
    }

    /**
     * Avalia expressao aritmetica simples
     */
    function evaluateArithmetic(expression) {
        if (!expression || typeof expression !== 'string') {
            return expression;
        }

        // Remove espacos extras
        let evaluated = expression.replace(/\s+/g, ' ').trim();

        try {
            // Avaliacao segura (apenas operacoes aritmeticas basicas)
            // Suporta: +, -, *, /, (, )
            if (/^[\d\.\+\-\*\/\(\)\s]+$/.test(evaluated)) {
                return Function('"use strict"; return (' + evaluated + ')')();
            }
        } catch (e) {
            console.warn('[PLSAG] Erro ao avaliar expressao:', expression, e);
        }

        return evaluated;
    }

    // ============================================================
    // CONTROLE DE FLUXO
    // ============================================================

    /**
     * Estados possiveis de um bloco IF
     */
    const BlockState = {
        EXECUTING: 'EXECUTING',  // Executando instrucoes
        SKIPPING: 'SKIPPING',    // Pulando instrucoes (condicao falsa)
        SATISFIED: 'SATISFIED'   // Bloco ja satisfeito, pular ELSE
    };

    /**
     * Verifica se deve executar instrucao atual
     */
    function shouldExecute() {
        // Se ha loop marcado para pular, nao executa
        if (context.control.loopStack.some(loop => loop.skipLoop)) {
            return false;
        }

        // Se nao ha blocos na pilha, executa normalmente
        if (context.control.blockStack.length === 0) {
            return true;
        }

        // Verifica todos os blocos - todos devem estar em EXECUTING
        return context.control.blockStack.every(block => block.state === BlockState.EXECUTING);
    }

    /**
     * Entra em um bloco IF
     */
    function enterIfBlock(label, condition) {
        const state = condition ? BlockState.EXECUTING : BlockState.SKIPPING;
        context.control.blockStack.push({
            type: 'IF',
            label: label,
            state: state,
            depth: context.control.blockStack.length
        });
    }

    /**
     * Processa ELSE
     */
    function handleElse(label, condition) {
        // Encontra bloco IF correspondente
        const blockIdx = context.control.blockStack.findIndex(
            b => b.type === 'IF' && b.label === label
        );

        if (blockIdx === -1) {
            console.warn(`[PLSAG] ELSE sem IF correspondente: ${label}`);
            return;
        }

        const block = context.control.blockStack[blockIdx];

        if (block.state === BlockState.EXECUTING) {
            // IF anterior executou, pular este ELSE
            block.state = BlockState.SATISFIED;
        } else if (block.state === BlockState.SKIPPING) {
            // IF anterior nao executou, verificar condicao do ELSE
            if (condition === undefined || evaluateCondition(condition)) {
                block.state = BlockState.EXECUTING;
            }
            // Se condicao ELSE falsa, continua SKIPPING
        }
        // Se SATISFIED, mantem SATISFIED
    }

    /**
     * Processa FINA (fim de IF)
     */
    function handleFina(label) {
        // Remove bloco IF correspondente da pilha
        const blockIdx = context.control.blockStack.findIndex(
            b => b.type === 'IF' && b.label === label
        );

        if (blockIdx !== -1) {
            context.control.blockStack.splice(blockIdx, 1);
        } else {
            console.warn(`[PLSAG] FINA sem IF correspondente: ${label}`);
        }
    }

    /**
     * Entra em um loop WH
     */
    function enterWhileLoop(label, queryData) {
        context.control.loopStack.push({
            type: 'WH',
            label: label,
            data: queryData,
            currentIndex: 0,
            startInstructionIndex: context.meta.instructionCount
        });
    }

    /**
     * Processa fim de loop WH
     */
    function handleWhileEnd(label) {
        const loopIdx = context.control.loopStack.findIndex(
            l => l.type === 'WH' && l.label === label
        );

        if (loopIdx === -1) {
            console.warn(`[PLSAG] FINH sem WH correspondente: ${label}`);
            return null;
        }

        const loop = context.control.loopStack[loopIdx];
        loop.currentIndex++;

        // Verifica se tem mais registros
        if (loop.data && loop.currentIndex < loop.data.length) {
            // Atualiza contexto com proximo registro
            context.queryResults[loop.label] = loop.data[loop.currentIndex];
            // Retorna indice da instrucao para voltar
            return loop.startInstructionIndex;
        }

        // Loop finalizado
        context.control.loopStack.splice(loopIdx, 1);
        return null;
    }

    // ============================================================
    // EXECUTOR PRINCIPAL
    // ============================================================

    /**
     * Executa uma lista de instrucoes PLSAG
     * @param {string} instructions - Instrucoes separadas por ";"
     * @param {Object} eventContext - Contexto do evento
     * @returns {Promise<Object>} Resultado da execucao
     */
    async function execute(instructions, eventContext = {}) {
        if (!instructions) {
            return { success: true, executed: 0 };
        }

        // Inicializa contexto de execucao
        context.meta.executionId = generateExecutionId();
        context.meta.startTime = Date.now();
        context.meta.eventType = eventContext.eventType || '';
        context.meta.triggerField = eventContext.fieldName || '';
        context.meta.triggerValue = eventContext.fieldValue || '';
        context.meta.instructionCount = 0;
        context.control.shouldStop = false;
        context.control.blockStack = [];
        context.control.loopStack = [];
        context.control.errorState = null;

        // Atualiza dados do formulario
        if (eventContext.formData) {
            context.formData = { ...eventContext.formData };
        } else {
            collectFormData();
        }

        // Atualiza variaveis de sistema
        updateSystemVariables(eventContext);

        console.log(`[PLSAG] Executando (${context.meta.executionId}):`, instructions.substring(0, 100) + '...');

        // Tokeniza instrucoes
        const tokens = tokenize(instructions);
        let executedCount = 0;

        try {
            for (let i = 0; i < tokens.length && !context.control.shouldStop; i++) {
                // Limite de seguranca
                context.meta.instructionCount++;
                if (context.meta.instructionCount > MAX_INSTRUCTIONS) {
                    console.warn(`[PLSAG] Limite de instrucoes excedido (${MAX_INSTRUCTIONS})`);
                    break;
                }

                const token = tokens[i];

                // Verifica controle de fluxo (async para suportar WH-NOVO)
                const flowResult = await handleControlFlow(token);
                if (flowResult === 'skip') {
                    continue;
                }
                if (flowResult !== null && typeof flowResult === 'number') {
                    // Jump para outra instrucao (loop)
                    i = flowResult - 1;
                    continue;
                }

                // Verifica se deve executar (considerando blocos IF)
                if (!shouldExecute()) {
                    continue;
                }

                // Executa instrucao
                await executeInstruction(token);
                executedCount++;
            }
        } catch (error) {
            console.error('[PLSAG] Erro durante execucao:', error);
            context.control.errorState = error.message;
        }

        const duration = Date.now() - context.meta.startTime;
        const wasBlocked = context.control.shouldStop;
        console.log(`[PLSAG] Execucao concluida: ${executedCount} instrucoes em ${duration}ms${wasBlocked ? ' (BLOQUEADO)' : ''}`);

        return {
            success: !context.control.errorState,
            executed: executedCount,
            duration: duration,
            error: context.control.errorState,
            returnValue: context.control.returnValue,
            blocked: wasBlocked  // true se PA ou ME parou a execucao
        };
    }

    /**
     * Trata instrucoes de controle de fluxo
     * @returns {'skip'|number|null} - 'skip' para pular, numero para jump, null para continuar
     */
    async function handleControlFlow(token) {
        const prefix = token.prefix;
        const identifier = token.identifier;

        // IF-INIC<label>-<cond>
        if (prefix === 'IF' && identifier.startsWith('INIC')) {
            const label = identifier.substring(4).trim() || '0001';
            const condition = evaluateCondition(token.parameter);
            enterIfBlock(label, condition);
            return 'skip';
        }

        // IF-ELSE<label>-<cond>
        if (prefix === 'IF' && identifier.startsWith('ELSE')) {
            const label = identifier.substring(4).trim() || '0001';
            handleElse(label, token.parameter);
            return 'skip';
        }

        // IF-FINA<label>
        if (prefix === 'IF' && identifier.startsWith('FINA')) {
            const label = identifier.substring(4).trim() || '0001';
            handleFina(label);
            return 'skip';
        }

        // Compatibilidade: ELSE e FINA como prefixos separados
        if (prefix === 'EL' && identifier.startsWith('SE')) {
            const label = token.parameter?.substring(0, 4) || '0001';
            handleElse(label, token.parameter?.substring(4));
            return 'skip';
        }

        if (prefix === 'FI' && identifier.startsWith('NA')) {
            const label = token.parameter?.substring(0, 4) || '0001';
            handleFina(label);
            return 'skip';
        }

        // PA (pare/break)
        if (prefix === 'PA') {
            // Verifica se esta em loop
            if (context.control.loopStack.length > 0) {
                // Sai do loop atual
                context.control.loopStack.pop();
            } else {
                // Para execucao completa
                context.control.shouldStop = true;
            }
            return 'skip';
        }

        // WH-INIC<label>-<queryName> - Inicia loop com dados de query
        if (prefix === 'WH' && identifier.startsWith('INIC')) {
            const label = identifier.substring(4).trim() || '0001';
            const queryName = token.parameter?.trim();

            if (!queryName) {
                console.warn(`[PLSAG] WH-INIC sem nome de query: ${token.raw}`);
                return 'skip';
            }

            // Busca dados da query multi-resultado
            const queryData = context.queryMultiResults[queryName];

            if (!queryData || !Array.isArray(queryData) || queryData.length === 0) {
                console.log(`[PLSAG] WH-INIC: Query ${queryName} sem dados, pulando loop`);
                // Marca para pular ate o FINA correspondente
                context.control.loopStack.push({
                    type: 'WH',
                    label: label,
                    data: [],
                    currentIndex: 0,
                    startInstructionIndex: context.meta.instructionCount,
                    skipLoop: true
                });
                return 'skip';
            }

            console.log(`[PLSAG] WH-INIC: Iniciando loop ${label} com ${queryData.length} registros da query ${queryName}`);

            // Inicia loop
            context.control.loopStack.push({
                type: 'WH',
                label: label,
                queryName: queryName,
                data: queryData,
                currentIndex: 0,
                startInstructionIndex: context.meta.instructionCount,
                skipLoop: false
            });

            // Carrega primeiro registro no contexto da query
            context.queryResults[queryName] = queryData[0];

            return 'skip';
        }

        // WH-FINA<label> - Fim do loop
        if (prefix === 'WH' && identifier.startsWith('FINA')) {
            const label = identifier.substring(4).trim() || '0001';

            // Encontra loop correspondente
            const loopIdx = context.control.loopStack.findIndex(
                l => l.type === 'WH' && l.label === label
            );

            if (loopIdx === -1) {
                console.warn(`[PLSAG] WH-FINA sem WH-INIC correspondente: ${label}`);
                return 'skip';
            }

            const loop = context.control.loopStack[loopIdx];

            // Se loop estava marcado para pular, apenas remove da pilha
            if (loop.skipLoop) {
                context.control.loopStack.splice(loopIdx, 1);
                console.log(`[PLSAG] WH-FINA: Loop ${label} finalizado (sem dados)`);
                return 'skip';
            }

            // Avanca para proximo registro
            loop.currentIndex++;

            if (loop.currentIndex < loop.data.length) {
                // Ainda tem registros - atualiza contexto com proximo registro
                context.queryResults[loop.queryName] = loop.data[loop.currentIndex];

                console.log(`[PLSAG] WH-FINA: Loop ${label} iteracao ${loop.currentIndex + 1}/${loop.data.length}`);

                // Retorna indice para voltar ao inicio do loop
                return loop.startInstructionIndex;
            }

            // Loop finalizado
            context.control.loopStack.splice(loopIdx, 1);
            console.log(`[PLSAG] WH-FINA: Loop ${label} finalizado apos ${loop.currentIndex} iteracoes`);
            return 'skip';
        }

        // WH-NOVO<label>-<SQL> - Loop que executa SQL diretamente
        // Formato: WH-NOVO0001-SELECT ... (inicia loop)
        //          WH-NOVO0001 ou WH-NOVO0001- (fim do loop)
        if (prefix === 'WH' && identifier.startsWith('NOVO')) {
            const label = identifier; // Ex: "NOVO0001"
            const sql = (token.parameter || '').trim();

            // Se tem SQL, e inicio de loop - executa query e inicia iteracao
            if (sql && sql.toUpperCase().startsWith('SELECT')) {
                try {
                    // Substitui templates no SQL
                    const resolvedSql = substituteTemplatesForSQL(sql);
                    console.log(`[PLSAG] WH-${label}: Executando query: ${resolvedSql.substring(0, 100)}...`);

                    const response = await fetch('/api/plsag/query', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            sql: resolvedSql,
                            type: 'multi'
                        })
                    });

                    const result = await response.json();

                    if (!result.success) {
                        console.error(`[PLSAG] WH-${label}: Erro na query:`, result.error);
                        // Marca para pular loop
                        context.control.loopStack.push({
                            type: 'WH-NOVO',
                            label: label,
                            data: [],
                            currentIndex: 0,
                            startInstructionIndex: context.meta.instructionCount,
                            skipLoop: true
                        });
                        return 'skip';
                    }

                    const queryData = result.data || [];

                    if (queryData.length === 0) {
                        console.log(`[PLSAG] WH-${label}: Query sem resultados, pulando loop`);
                        context.control.loopStack.push({
                            type: 'WH-NOVO',
                            label: label,
                            data: [],
                            currentIndex: 0,
                            startInstructionIndex: context.meta.instructionCount,
                            skipLoop: true
                        });
                        return 'skip';
                    }

                    console.log(`[PLSAG] WH-${label}: Iniciando loop com ${queryData.length} registros`);

                    // Armazena dados para iteracao
                    context.queryMultiResults[label] = queryData;
                    context.queryResults[label] = queryData[0];

                    // Inicia loop
                    context.control.loopStack.push({
                        type: 'WH-NOVO',
                        label: label,
                        data: queryData,
                        currentIndex: 0,
                        startInstructionIndex: context.meta.instructionCount,
                        skipLoop: false
                    });

                    return 'skip';
                } catch (error) {
                    console.error(`[PLSAG] WH-${label}: Excecao:`, error);
                    return 'skip';
                }
            }

            // Sem SQL ou SQL vazio = fim do loop (WH-NOVO0001 ou WH-NOVO0001-)
            const loopIdx = context.control.loopStack.findIndex(
                l => l.type === 'WH-NOVO' && l.label === label
            );

            if (loopIdx === -1) {
                console.warn(`[PLSAG] WH-${label} (fim) sem inicio correspondente`);
                return 'skip';
            }

            const loop = context.control.loopStack[loopIdx];

            // Se loop estava marcado para pular, apenas remove da pilha
            if (loop.skipLoop) {
                context.control.loopStack.splice(loopIdx, 1);
                console.log(`[PLSAG] WH-${label}: Loop finalizado (sem dados)`);
                return 'skip';
            }

            // Avanca para proximo registro
            loop.currentIndex++;

            if (loop.currentIndex < loop.data.length) {
                // Ainda tem registros - atualiza contexto com proximo registro
                context.queryResults[label] = loop.data[loop.currentIndex];

                console.log(`[PLSAG] WH-${label}: Iteracao ${loop.currentIndex + 1}/${loop.data.length}`);

                // Retorna indice para voltar ao inicio do loop
                return loop.startInstructionIndex;
            }

            // Loop finalizado
            context.control.loopStack.splice(loopIdx, 1);
            console.log(`[PLSAG] WH-${label}: Loop finalizado apos ${loop.currentIndex} iteracoes`);
            return 'skip';
        }

        // WH como prefixo generico (compatibilidade)
        if (prefix === 'WH') {
            console.warn(`[PLSAG] Comando WH nao reconhecido: ${token.raw}`);
            return 'skip';
        }

        return null;
    }

    /**
     * Executa uma instrucao individual
     */
    async function executeInstruction(token) {
        const prefix = token.prefix;
        const modifier = token.modifier || '';
        const identifier = token.identifier;
        // Usa evaluateExpression para processar templates E funções IF(...)
        const parameter = evaluateExpression(token.parameter);

        const cmdDisplay = modifier ? `${prefix}${modifier}` : prefix;
        console.log(`[PLSAG] Executando: ${cmdDisplay}-${identifier}`, parameter ? `(${parameter})` : '');

        // Delega para PlsagCommands
        if (typeof PlsagCommands === 'undefined') {
            console.warn('[PLSAG] PlsagCommands nao carregado');
            return;
        }

        try {
            // Comandos de campo (CE, CN, CS, CM, CT, CF, CV, CC, CD, CA, CR + modificadores)
            // Inclui LN (Label Numerico), LE (Label Editor), IL (Lookup Numerico) que sao campos calculados
            // Inclui Editores: EE, ES, ET, EC, ED, EA, EI, EL (campos volateis, sem banco)
            const isFieldCommand = prefix.startsWith('C') || // CE, CN, CS, CM, CT, CF, CV, CC, CD, CA, CR
                                   prefix.startsWith('I') || // IE, IN, IM, IT, IA, IL
                                   prefix === 'LN' || prefix === 'LE' || // Labels calculados
                                   prefix.startsWith('LN') || prefix.startsWith('LE') ||
                                   (prefix.startsWith('E') && prefix !== 'EX'); // Editores: EE, ES, ET, EC, ED, EA, EI, EL

            if (isFieldCommand) {
                await PlsagCommands.executeFieldCommand(prefix, identifier, parameter, context, modifier);
                return;
            }

            // Comandos de variavel (VA, VP, PU)
            if (prefix === 'VA' || prefix === 'VP' || prefix === 'PU') {
                await PlsagCommands.executeVariableCommand(prefix, identifier, parameter, context);
                return;
            }

            // Comandos de mensagem (MA, MB, MC, ME, MI, MP)
            // ME/MB/MI com SQL (validacao) precisa de substituicao SQL-aware
            if (prefix === 'MA' || prefix === 'MB' || prefix === 'MC' || prefix === 'ME' || prefix === 'MI' || prefix === 'MP') {
                let msgParam = parameter;
                if (prefix === 'ME' || prefix === 'MB' || prefix === 'MI') {
                    const rawParam = token.parameter || '';
                    // ME/MB/MI com SQL: "SELECT ... |||mensagem" - substitui SQL com quotes
                    if (rawParam.trim().toUpperCase().startsWith('SELECT')) {
                        const pipeIndex = rawParam.indexOf('|||');
                        if (pipeIndex > 0) {
                            const sqlPart = rawParam.substring(0, pipeIndex);
                            const msgPart = rawParam.substring(pipeIndex);
                            msgParam = substituteTemplatesForSQL(sqlPart) + msgPart;
                        } else {
                            msgParam = substituteTemplatesForSQL(rawParam);
                        }
                    }
                }
                const result = await PlsagCommands.executeMessageCommand(prefix, identifier, msgParam, context);
                // ME/MB (Message Error/Button) - para execucao se retornar 'STOP'
                // ME: erro com query de validacao (retornou 0) ou simples
                // MB: mensagem informativa mas tambem para execucao
                if ((prefix === 'ME' || prefix === 'MB') && result === 'STOP') {
                    context.control.shouldStop = true;
                }
                // MC retorna resultado (S ou N)
                if (prefix === 'MC') {
                    context.system.RETOFUNC = result;
                }
                return;
            }

            // Comandos de query (QY, QN, QD, QM)
            if (prefix === 'QY' || prefix === 'QN' || prefix === 'QD' || prefix === 'QM') {
                await PlsagCommands.executeQueryCommand(prefix, identifier, parameter, context);
                return;
            }

            // Comandos de gravacao direta (DDG, DDM, DD2, DD3)
            // Forcam gravacao em dataset especifico independente do contexto
            if (prefix === 'DD' && token.isDataDireto) {
                const rawParam = token.parameter || '';
                const isSQL = rawParam.trim().toUpperCase().startsWith('SELECT');
                const dataParam = isSQL ? substituteTemplatesForSQL(rawParam) : parameter;
                await PlsagCommands.executeDataDiretoCommand(
                    token.forcedTarget, // G, M, 2, 3
                    identifier,
                    dataParam,
                    context
                );
                return;
            }

            // Comandos de gravacao (DG, DM, D2, D3, DD)
            // Para SQL (SELECT...), usa substituicao SQL-aware com quotes em strings
            // DD sem modificador (DD-CAMPO-VALOR) funciona como DG mas em contexto de movimento vai para form pai
            if (prefix === 'DG' || prefix === 'DM' || prefix === 'D2' || prefix === 'D3' || prefix === 'DD') {
                const rawParam = token.parameter || '';
                const isSQL = rawParam.trim().toUpperCase().startsWith('SELECT');
                const dataParam = isSQL ? substituteTemplatesForSQL(rawParam) : parameter;
                // DD sem isDataDireto = usa logica de contexto (movimento vai para pai)
                const effectivePrefix = prefix === 'DD' ? 'DD' : prefix;
                await PlsagCommands.executeDataCommand(effectivePrefix, identifier, dataParam, context);
                return;
            }

            // Comandos especiais EX
            if (prefix === 'EX') {
                await PlsagCommands.executeExCommand(identifier, parameter, context);
                return;
            }

            // Comando EY - Execute Immediately (SQL direto, mesmo durante OnShow)
            // Diferente de EX-SQL que pode ser enfileirado, EY executa imediatamente
            if (prefix === 'EY') {
                await PlsagCommands.executeEyCommand(identifier, parameter, context);
                return;
            }

            // Comandos FO/FV/FM - Navegacao de Formularios
            // FO: Abre formulario e coleta instrucoes para executar apos fechar
            // FV: Marca retorno do formulario (instrucoes pos-fechamento)
            // FM: Abre formulario via menu
            if (prefix === 'FO' || prefix === 'FV' || prefix === 'FM') {
                await PlsagCommands.executeFormNavigationCommand(prefix, identifier, parameter, context);
                return;
            }

            // Comandos de label (LB)
            if (prefix === 'LB' || prefix.startsWith('LB')) {
                await PlsagCommands.executeLabelCommand(prefix, identifier, parameter, context, modifier);
                return;
            }

            // Comandos de botao (BT)
            if (prefix === 'BT' || prefix.startsWith('BT')) {
                await PlsagCommands.executeButtonCommand(prefix, identifier, parameter, context, modifier);
                return;
            }

            // Comandos de acao de botao (BO, BC, BF)
            // BO: Click programatico no botao Confirmar
            // BC: Click programatico no botao Cancelar
            // BF: Controla visibilidade dos botoes (0=so fecha, 1=confirma+cancela)
            if (prefix === 'BO' || prefix === 'BC' || prefix === 'BF') {
                const result = await PlsagCommands.executeButtonActionCommand(prefix, identifier, parameter, context);
                if (result === 'STOP') {
                    context.control.shouldStop = true;
                }
                return;
            }

            // Comando TI - Timer control (ATIV/DESA)
            if (prefix === 'TI') {
                await PlsagCommands.executeTimerCommand(identifier, parameter, context);
                return;
            }

            // Comando desconhecido
            console.warn(`[PLSAG] Comando desconhecido: ${prefix}-${identifier}`);
            handleUnsupportedCommand(prefix, identifier, parameter);

        } catch (error) {
            console.error(`[PLSAG] Erro executando ${prefix}-${identifier}:`, error);
            throw error;
        }
    }

    /**
     * Trata comando nao suportado
     */
    function handleUnsupportedCommand(prefix, identifier, parameter) {
        // Emite evento para possivel tratamento externo
        document.dispatchEvent(new CustomEvent('sag:unsupported-command', {
            detail: { prefix, identifier, parameter }
        }));
    }

    // ============================================================
    // FUNCOES AUXILIARES
    // ============================================================

    /**
     * Coleta dados do formulario atual
     */
    function collectFormData() {
        const form = document.getElementById('dynamicForm') || document.querySelector('form');
        if (!form) return;

        const formData = new FormData(form);
        context.formData = {};

        for (const [key, value] of formData.entries()) {
            context.formData[key] = value;
        }

        // Adiciona campos com data-sag-nomecamp
        form.querySelectorAll('[data-sag-nomecamp]').forEach(element => {
            const fieldName = element.dataset.sagNomecamp;
            if (element.type === 'checkbox') {
                context.formData[fieldName] = element.checked ? '1' : '0';
            } else {
                context.formData[fieldName] = element.value;
            }
        });
    }

    /**
     * Atualiza variaveis de sistema
     */
    function updateSystemVariables(eventContext) {
        const now = new Date();

        context.system.DATAATUA = formatDate(now);
        context.system.HORAATUA = formatTime(now);
        context.system.CODITABE = eventContext.codiTabe || context.tableId;

        // Modo do formulario
        context.system.INSERIND = eventContext.isInsert ?? !eventContext.recordId;
        context.system.ALTERIND = eventContext.isEdit ?? !!eventContext.recordId;
        context.system.VISUALIZ = eventContext.isReadOnly ?? false;

        // ID do registro
        context.system.REGISTRO = eventContext.recordId || null;
    }

    /**
     * Formata data para padrao brasileiro
     */
    function formatDate(date) {
        const d = date.getDate().toString().padStart(2, '0');
        const m = (date.getMonth() + 1).toString().padStart(2, '0');
        const y = date.getFullYear();
        return `${d}/${m}/${y}`;
    }

    /**
     * Formata hora
     */
    function formatTime(date) {
        const h = date.getHours().toString().padStart(2, '0');
        const m = date.getMinutes().toString().padStart(2, '0');
        const s = date.getSeconds().toString().padStart(2, '0');
        return `${h}:${m}:${s}`;
    }

    /**
     * Gera ID unico de execucao
     */
    function generateExecutionId() {
        return 'exec_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }

    // ============================================================
    // API PUBLICA
    // ============================================================

    /**
     * Define dados do movimento nível 1 (para templates DM)
     * @param {Object} data - Dados do movimento
     * @param {number} tableId - ID da tabela de movimento
     * @param {number} recordId - ID do registro de movimento
     */
    function setMovementData(data, tableId = null, recordId = null) {
        context.movementData = data || {};
        context.movementTableId = tableId;
        context.movementRecordId = recordId;
        console.log('[PLSAG] Movement data set:', { tableId, recordId, fieldCount: Object.keys(context.movementData).length });
    }

    /**
     * Define dados do sub-movimento nível 2 (para templates D2)
     * @param {Object} data - Dados do sub-movimento
     * @param {number} tableId - ID da tabela de sub-movimento
     * @param {number} recordId - ID do registro de sub-movimento
     */
    function setSubMovementData(data, tableId = null, recordId = null) {
        context.subMovementData = data || {};
        context.subMovementTableId = tableId;
        context.subMovementRecordId = recordId;
        console.log('[PLSAG] SubMovement data set:', { tableId, recordId, fieldCount: Object.keys(context.subMovementData).length });
    }

    /**
     * Limpa dados de movimento do contexto
     */
    function clearMovementData() {
        context.movementData = {};
        context.movementTableId = null;
        context.movementRecordId = null;
        console.log('[PLSAG] Movement data cleared');
    }

    /**
     * Limpa dados de sub-movimento do contexto
     */
    function clearSubMovementData() {
        context.subMovementData = {};
        context.subMovementTableId = null;
        context.subMovementRecordId = null;
        console.log('[PLSAG] SubMovement data cleared');
    }

    return {
        // Execucao
        execute,
        tokenize,
        parseInstruction,

        // Contexto
        getContext: () => ({ ...context }),
        getFormData: () => ({ ...context.formData }),
        getQueryResults: () => ({ ...context.queryResults }),

        // Movimento (DM/D2 templates)
        setMovementData,
        getMovementData: () => ({ ...context.movementData }),
        getMovementFieldValue,
        clearMovementData,
        setSubMovementData,
        getSubMovementData: () => ({ ...context.subMovementData }),
        getSubMovementFieldValue,
        clearSubMovementData,

        // Variaveis
        getVariable,
        setVariable,
        getSystemVar: (name) => context.system[name],
        setSystemVar: (name, value) => { context.system[name] = value; },

        // Modo INSERT/EDIT
        setInsertMode: (isInsert) => { context.system.INSERIND = !!isInsert; },
        isInsertMode: () => context.system.INSERIND,

        // Templates e Expressões
        substituteTemplates,
        substituteTemplatesForSQL,
        quoteForSQL,
        evaluateCondition,
        evaluateArithmetic,
        evaluateExpression,
        evaluateIfFunction,

        // Utilitarios
        collectFormData,

        // Para debug
        _context: context
    };
})();

// Expoe globalmente
window.PlsagInterpreter = PlsagInterpreter;
