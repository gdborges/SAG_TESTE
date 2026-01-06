# GAPS: Comandos PLSAG e Eventos

**Última atualização:** 2026-01-05
**Cobertura atual:** Comandos 68% | Eventos 100%

Este documento rastreia os gaps entre a implementação Delphi original e a versão Web do SAG.

---

## BUGS DO PARSER

Problemas no parsing de instruções PLSAG que causam erros no console:

### Instruções Mal Formadas
- [x] **Templates incompletos** - `{C-T-CODITP`, `{C-S-PDGEPE`, `[P-ERS-AGD-` aparecem truncados
  - Causa: quebra de linha no meio do template ou delimitador faltando no banco
  - Solução: adicionado warning log para detectar templates incompletos

### Tipos de Template Desconhecidos
- [x] **IT** - Input Tabela (Lookup Informado) - similar a CT
  - Era tipo não reconhecido, agora tratado como alias de CT no resolveTemplate

### Componentes Referenciados Inexistentes
Nota: Não são bugs, mas componentes específicos de formulários que podem não existir:
- `DNUPDPEO`, `CODIPEDI`, `DFATUANT` - Referenciados em eventos mas ausentes no form 83600
- Comportamento atual: log de warning e continua execução (correto)

---

## PRIORIDADE ALTA

### Mensagens e Interação
- [x] **MB** - Message Button (informativo, para execução igual ME)
- [x] **BO** - Button OK (click programático no botão confirmar)
- [x] **BC** - Button Cancel (click programático no botão cancelar)
- [x] **BF** - Button Finish/Close (0=só fecha, 1=confirma+cancela)

### Queries - Modo Edição
- [x] **QY,*,EDIT** - Colocar query em modo edição
- [x] **QY,*,INSE** - Colocar query em modo inserção
- [x] **QY,*,POST** - Postar alterações da query

### Formulários e Navegação
- [x] **FO** - Open Form completo (com pós-instruções após fechar)
- [x] **FV** - Form Return marker (marca retorno do formulário)
- [x] **FM** - Menu Form (abrir formulário de menu)

### Execução Especial
- [x] **EY** - Execute Immediately (SQL mesmo durante OnShow)
- [x] **DD** - Data Detail (DD sem modificador = DG; DDG/DDM/DD2/DD3 já suportados)

### Eventos
- [x] **OnTimer** - Eventos de timer para campos TIM

---

## PRIORIDADE MÉDIA

### Variáveis Especiais
- [ ] **VA,CONFIRMA** - Texto do botão confirmar
- [ ] **VA,FECHCONF** - Flag de fechar ao confirmar
- [ ] **VA,PDA1MANU** - Data manual 1
- [ ] **VA,PDA2MANU** - Data manual 2
- [ ] **VA,CODITEST** - Código de teste
- [ ] **VA,NOMETEST** - Nome de teste

### Propriedades de Controles
- [ ] **ED,*,EDITMASK** - Máscara de edição dinâmica
- [ ] **BV** - BevelLabel Visible (separadores visuais)
- [ ] **FF** - Figure Frame (imagens)
- [ ] **GD** - Grid properties completo (ENABLED, VISIBLE, READONLY)

### Queries Avançadas
- [ ] **QY,*,FILTRA** - Filtro de query (completar implementação)
- [ ] **QD** - Grid query (completar implementação)
- [ ] **QM** - Marked position (completar implementação)
- [ ] **QT** - Query Tela (filtro do formulário)

### Validadores Brasileiros
- [ ] **VV,UF** - Validar Estado (sigla UF)
- [ ] **VV,InscEst** - Validar Inscrição Estadual
- [ ] **VV,CEP** - Validar CEP
- [ ] **VV,PIS** - Validar PIS/PASEP
- [ ] **VV,Cheque** - Validar dígito de cheque
- [ ] **VV,CartaoCredito** - Validar cartão de crédito

---

## PRIORIDADE BAIXA

### Comunicação
- [ ] **EM** - Email (envio de emails)

### Relatórios
- [ ] **IM** - Print to File (impressão em arquivo)
- [ ] **IR** - Print Report (relatório padrão)
- [ ] **IP** - Print Report Specific (relatório específico)
- [ ] **GR** - Graph/Chart (gráficos)

### Controles Especiais
- [ ] **LC** - List CheckBox (lista com checkboxes)
- [x] **TI** - Timer control (ativar/desativar timer)
- [ ] **TH** - Thread Sleep (pausa de execução)

### Objetos e Triggers
- [ ] **OB** - Object Trigger
- [ ] **OP** - Object Procedure
- [ ] **OD** - Object Decorator
- [ ] **EP** - Execute Procedure (stored procedure DB)
- [ ] **TR** - Trigger Delphi
- [ ] **EQ** - Execute via Query específica

### Execução Especial
- [ ] **EX,GERAINDU** - Gerar índice
- [ ] **EX,APAGINDU** - Apagar índice
- [ ] **EX,POCADATA** - Data picker
- [ ] **EX,POCANUME** - Numerador
- [ ] **EX,FRETRAES** - Frete rastreio
- [ ] **EX,IMPOARQU** - Importar arquivo
- [ ] **CW** - Config Web (parâmetros web)

### ERP-Specific
- [ ] **S3/GG** - Comandos ERP-específicos

---

## NÃO APLICÁVEL (Hardware/Desktop)

Estes comandos são específicos de hardware ou desktop e **não serão implementados** na versão Web:

- **TQ** - Thermal Printer (impressora térmica)
- **EX,PESA** - Balança
- **EX,DLL_*** - DLLs externas
- **SO** - Sound/Beep
- **NF** - Nota Fiscal v1 (requer certificado digital local)
- **N2** - Nota Fiscal v2 (requer certificado digital local)

---

## PARCIALMENTE IMPLEMENTADO

### Rich Text
- [ ] **RS/RE/RI/RP/RX** - Rich Text variants (implementação básica, falta formatação avançada)

### Exportação
- [ ] **EX,EXPOTEXT** - Exportar texto (básico implementado, falta formatos avançados)

### Eventos
- [ ] **OnChange** - HabiConf não totalmente mapeado

---

## ESTATÍSTICAS

| Categoria | Total | Implementado | Parcial | Faltando | N/A |
|-----------|-------|--------------|---------|----------|-----|
| Controle Fluxo | 7 | 7 | 0 | 0 | 0 |
| Mensagens | 10 | 9 | 0 | 1 | 0 |
| Campos | 32 | 29 | 2 | 1 | 0 |
| Propriedades | 9 | 6 | 1 | 2 | 0 |
| Variáveis | 17 | 10 | 0 | 7 | 0 |
| Queries | 14 | 11 | 3 | 0 | 0 |
| Forms/Nav | 3 | 3 | 0 | 0 | 0 |
| Execução | 25 | 8 | 1 | 13 | 3 |
| Impressão | 9 | 0 | 0 | 7 | 2 |
| Validação | 8 | 2 | 0 | 6 | 0 |
| Outros | 6 | 2 | 0 | 4 | 0 |
| **TOTAL** | **140** | **87** | **7** | **41** | **5** |

### Eventos

| Categoria | Total | Implementado | Parcial | Faltando |
|-----------|-------|--------------|---------|----------|
| Form | 6 | 6 | 0 | 0 |
| Campo | 6 | 5 | 1 | 0 |
| Movimento | 10 | 10 | 0 | 0 |
| **TOTAL** | **22** | **21** | **1** | **0** |

---

## HISTÓRICO DE IMPLEMENTAÇÕES

### 2026-01-05
- DD (Data Detail) implementado - DD-CAMPO-VALOR agora funciona como DG
- Template {DD-CAMPO} adicionado como alias de {DG-CAMPO}
- IT (Input Tabela) implementado como alias de CT (lookup)
- Detecção de templates incompletos adicionada com warning log
- Seção BUGS DO PARSER adicionada ao documento
- MB (Message Button) implementado - exibe info modal e para execução
- BO (Button OK) implementado - click programático no botão Confirmar
- BC (Button Cancel) implementado - click programático no botão Cancelar
- BF (Button Finish) implementado - controla visibilidade dos botões (0=fecha, 1=confirma+cancela)
- EY (Execute Immediately) implementado - executa SQL direto, mesmo durante OnShow
- FO (Form Open) implementado - abre form com suporte a pós-instruções
- FV (Form Return) implementado - marca instruções pós-fechamento
- FM (Form Menu) implementado - abre form via menu (usa mesma lógica do FO)
- OnTimer implementado para campos TIM - setInterval + execução PLSAG
- TI (Timer control) implementado - ATIV/DESA para controlar timers

### 2026-01-03
- WH-NOVO implementado (loop com SQL inline)
- Lookup Auto-Fetch corrigido (Oracle case-sensitivity)
- Documento de gaps criado

### Anteriores
- IF/ELSE/FINA, WH-INIC/FINA, PA - Controle de fluxo completo
- MA, ME, MI, MC, MP - Mensagens principais
- DG, DM, D2, D3 - Manipulação de dados
- CE, CN, CS, CC, CD, CA, CM, CT, IL, etc. - Campos
- ED ENABLED/VISIBLE/READONLY/COLOR/SETFOCUS - Propriedades
- VA, VP, PU - Variáveis
- QY navegação, QN - Queries
- VV CPF/CNPJ - Validação
- Todos eventos de movimento implementados
- Todos eventos de formulário implementados
