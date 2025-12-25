# Proposta de Implementacao do Sistema de Eventos - SAG Web

**Versao:** 1.0
**Data:** 2025-12-24
**Status:** Proposta para Aprovacao
**Fase:** Fase 1 - Infraestrutura de Eventos (sem interpretacao PLSAG)

---

## Sumario Executivo

Este documento apresenta a proposta de implementacao do sistema de eventos para a plataforma web do SAG. Na **Fase 1**, implementaremos toda a infraestrutura de captura e disparo de eventos, porem **sem interpretar o PLSAG**. Quando um evento ocorrer, o sistema emitira uma mensagem/popup informando qual evento foi disparado, permitindo validar a correta captura de todos os eventos antes de implementar o interpretador PLSAG na Fase 2.

---

## PARTE 1: Entendimento dos Eventos Delphi

### 1.1 Arquitetura Original

No Delphi, o sistema de eventos funciona da seguinte forma:

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   SISTTABE      │     │    SISTCAMP      │     │   Componente    │
│  (Config Form)  │────>│  (Config Campo)  │────>│    Visual       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                       │                        │
        │                       │                        v
        │                       │               ┌─────────────────┐
        │                       └──────────────>│   Lista.Text    │
        │                       (ExprCamp +     │  (Instrucoes    │
        │                        EPerCamp)      │   PL-SAG)       │
        │                                       └─────────────────┘
        │                                                │
        v                                                v
┌─────────────────┐                            ┌─────────────────┐
│ ShowTabe        │                            │ OnExit/OnClick/ │
│ LancTabe        │──(Eventos Form)───────────>│ OnChange        │
│ EGraTabe        │                            │ (iExecExit)     │
│ AposTabe        │                            └─────────────────┘
└─────────────────┘                                     │
                                                        v
                                              ┌─────────────────┐
                                              │CampPersExecExit │
                                              │CampPersExecList │
                                              └─────────────────┘
                                                        │
                                                        v
                                              ┌─────────────────┐
                                              │ INTERPRETA      │
                                              │   PL-SAG        │
                                              └─────────────────┘
```

### 1.2 Tipos de Eventos no Delphi

#### 1.2.1 Eventos de Componente (Campo)

| Evento Delphi | Quando Dispara | Quem Usa |
|---------------|----------------|----------|
| **OnExit** | Usuario sai do campo (blur) | TDBEdtLbl, TDBRxELbl, TDBLcbLbl, etc. |
| **OnClick** | Usuario clica no componente | TDBChkLbl, TsgBtn, TDBCmbLbl (VCL) |
| **OnChange** | Valor do campo muda | Todos componentes editaveis |
| **OnKeyPress** | Tecla pressionada | UltiCamp (ultimo campo do form) |
| **OnDblClick** | Duplo clique | TsgDBG (grid), alguns edits |
| **OnTimer** | Intervalo expira | TsgTim (timer) |

#### 1.2.2 Eventos de Formulario (Ciclo de Vida)

| Fase | Campo SISTTABE | Quando Executa |
|------|----------------|----------------|
| **Antes de Criar** | `AnteCria` (SISTCAMP) | Antes de MontCampPers |
| **Depois de Criar** | `DepoCria` (SISTCAMP) | Apos MontCampPers |
| **Ao Exibir** | `ShowTabe` | FormShow, apos campos inicializados |
| **Ao Confirmar (Pre-Grav)** | `LancTabe` | BtnConfClick, antes de gravar |
| **Pos-Gravacao** | `EGraTabe` | BtnConfClick, apos gravar |
| **Final** | `AposTabe` | BtnConfClick, apos tudo |

### 1.3 Atribuicao de Eventos por Tipo de Componente

| CompCamp | Componente Delphi | OnExit | OnClick | OnChange | Lista.Text |
|----------|-------------------|--------|---------|----------|------------|
| **E** | TDBEdtLbl | iExecExit | - | Habi | ExprCamp+EPerCamp |
| **C** | TDBCmbLbl | iExecExit* | iExecExit* | Habi | ExprCamp+EPerCamp |
| **N** | TDBRxELbl | iExecExit | - | Habi | ExprCamp+EPerCamp |
| **T/IT** | TDBLcbLbl/TLcbLbl | iExecExit* | iExecExit* | - | ExprCamp+EPerCamp |
| **L/IL** | TDBLookNume | iExecExit | - | Habi | ExprCamp+EPerCamp |
| **D** | TDBRxDLbl | iExecExit | - | Habi | ExprCamp+EPerCamp |
| **S** | TDBChkLbl | - | iExecExit | - | ExprCamp+EPerCamp |
| **M/BM** | TDBMemLbl | iExecExit | - | Habi | ExprCamp+EPerCamp |
| **BTN** | TsgBtn | - | iExecExit | - | ExprCamp+EPerCamp |
| **DBG** | TsgDBG | - | - | - | Exp1Camp (DblClick) |
| **LC** | TLstLbl | - | iExecExit | - | ExprCamp+EPerCamp |
| **TIM** | TsgTim | - | - | - | ExprCamp (OnTimer) |

> *Nota: Combos (C, T) usam OnClick no VCL e OnExit no UniGUI (web)*

---

## PARTE 2: Mapeamento Delphi → Web

### 2.1 Mapeamento de Eventos HTML/JavaScript

| Evento Delphi | Evento JavaScript | Evento HTML |
|---------------|-------------------|-------------|
| **OnExit** | `blur` / `focusout` | `onblur` / `onfocusout` |
| **OnClick** | `click` | `onclick` |
| **OnChange** | `change` / `input` | `onchange` / `oninput` |
| **OnKeyPress** | `keydown` / `keypress` | `onkeydown` / `onkeypress` |
| **OnDblClick** | `dblclick` | `ondblclick` |
| **OnTimer** | `setInterval` / `setTimeout` | N/A (JavaScript) |

### 2.2 Mapeamento de Componentes Existentes (SAG-WEB POC)

| CompCamp | Delphi | SAG-WEB (atual) | Eventos a Implementar |
|----------|--------|-----------------|----------------------|
| **E** | TDBEdtLbl | `<input type="text">` | blur, input, change |
| **N** | TDBRxELbl | `<input type="number">` | blur, input, change |
| **D** | TDBRxDLbl | `<input type="date">` | blur, change |
| **S** | TDBChkLbl | `<input type="checkbox">` | click, change |
| **C** | TDBCmbLbl | `<select>` | change (= OnExit web) |
| **T/IT** | TDBLcbLbl | `<select>` (LookupCombo) | change |
| **L/IL** | TDBLookNume | `<input> + <button>` | blur, click (botao) |
| **M/BM** | TDBMemLbl | `<textarea>` | blur, input, change |
| **BTN** | TsgBtn | `<button>` | click |
| **DBG** | TsgDBG | Grid (placeholder) | dblclick (row) |
| **BVL** | TsgBvl | `<fieldset>` | N/A (visual) |
| **LBL** | TsgLbl | `<span>` / `<label>` | N/A (visual) |

### 2.3 Estrutura de Dados para Eventos (Novo Modelo)

```csharp
// Adicionar ao FieldMetadata.cs
public class FieldEventData
{
    /// <summary>
    /// Codigo do campo (para identificacao)
    /// </summary>
    public int CodiCamp { get; set; }

    /// <summary>
    /// Nome do campo (para debug/log)
    /// </summary>
    public string NomeCamp { get; set; }

    /// <summary>
    /// Instrucoes PLSAG para OnExit/OnBlur
    /// Fonte: ExprCamp + EPerCamp
    /// </summary>
    public string OnExitInstructions { get; set; }

    /// <summary>
    /// Instrucoes PLSAG para OnClick (botoes, checkboxes)
    /// Fonte: ExprCamp + EPerCamp
    /// </summary>
    public string OnClickInstructions { get; set; }

    /// <summary>
    /// Instrucoes PLSAG para duplo clique (grids)
    /// Fonte: Exp1Camp + EPerCamp
    /// </summary>
    public string OnDblClickInstructions { get; set; }

    /// <summary>
    /// Campo obrigatorio - OnChange habilita botao Confirmar
    /// </summary>
    public bool IsRequired { get; set; }

    /// <summary>
    /// Indica se este campo possui evento configurado
    /// </summary>
    public bool HasEvents =>
        !string.IsNullOrWhiteSpace(OnExitInstructions) ||
        !string.IsNullOrWhiteSpace(OnClickInstructions) ||
        !string.IsNullOrWhiteSpace(OnDblClickInstructions);
}
```

### 2.4 Estrutura de Dados para Eventos de Formulario

```csharp
// Adicionar ao FormMetadata.cs ou criar FormEventData.cs
public class FormEventData
{
    /// <summary>
    /// Codigo da tabela/formulario
    /// </summary>
    public int CodiTabe { get; set; }

    /// <summary>
    /// Nome da tabela (debug/log)
    /// </summary>
    public string NomeTabe { get; set; }

    /// <summary>
    /// Instrucoes executadas no FormShow
    /// Fonte: SISTTABE.ShowTabe + EPerTabe
    /// </summary>
    public string ShowTabeInstructions { get; set; }

    /// <summary>
    /// Instrucoes executadas antes de gravar
    /// Fonte: SISTTABE.LancTabe + EPerTabe
    /// </summary>
    public string LancTabeInstructions { get; set; }

    /// <summary>
    /// Instrucoes executadas apos gravar
    /// Fonte: SISTTABE.EGraTabe + EPerTabe
    /// </summary>
    public string EGraTabeInstructions { get; set; }

    /// <summary>
    /// Instrucoes executadas no final
    /// Fonte: SISTTABE.AposTabe + EPerTabe
    /// </summary>
    public string AposTabeInstructions { get; set; }

    /// <summary>
    /// Instrucoes antes de criar campos
    /// Fonte: SISTCAMP.ExprCamp onde NomeCamp='AnteCria'
    /// </summary>
    public string AntecriaInstructions { get; set; }

    /// <summary>
    /// Instrucoes depois de criar campos
    /// Fonte: SISTCAMP.ExprCamp onde NomeCamp='DepoCria'
    /// </summary>
    public string DepocriaInstructions { get; set; }
}
```

---

## PARTE 3: Eventos Incompativeis / Limitacoes Web

### 3.1 Eventos sem Equivalente Direto

| Evento Delphi | Problema | Solucao Web |
|---------------|----------|-------------|
| **OnTimer** (TsgTim) | Web nao tem componente timer | Usar `setInterval()` JavaScript |
| **OnKeyPress + UltiCamp** | Tab no ultimo campo = Confirmar | Implementar via keydown + detectar Tab |
| **Leitura Serial** (TsgLeitSeri) | Navegador nao acessa porta serial | **Incompativel** - requer app nativa ou WebSerial API (experimental) |
| **OnExit simultaneo** | Delphi executa OnExit sincrono | Web e assincrono - gerenciar fila |

### 3.2 Diferencas de Comportamento

| Cenario | Delphi | Web | Impacto |
|---------|--------|-----|---------|
| **OnChange vs OnExit** | OnChange dispara a cada tecla, OnExit ao sair | `input` = cada tecla, `change` = ao sair | Usar `change` para simular OnExit |
| **Select/Combo OnClick** | VCL usa OnClick, UniGUI usa OnExit | Web: `change` e o mais proximo | Usar `change` unificado |
| **Foco sequencial** | Tab navega em ordem fixa | Web pode pular campos hidden | Configurar `tabindex` corretamente |
| **Modal blocking** | ShowModal bloqueia execucao | Web nao bloqueia - async/await | Reestruturar fluxo com Promises |
| **Validacao sincrona** | Valida campo antes de sair | Web valida apos evento | Pode haver "flash" de dado invalido |

### 3.3 Funcionalidades Incompativeis (Fase 1 - Nao Implementar)

| Funcionalidade | Motivo | Alternativa Futura |
|----------------|--------|-------------------|
| **Comunicacao Serial** | Seguranca do navegador | WebSerial API (Chrome), app auxiliar |
| **Impressao direta** | Seguranca do navegador | Gerar PDF, impressao via dialogo |
| **Acesso a arquivos locais** | Seguranca do navegador | File API com upload |
| **Execucao de programas** | Seguranca do navegador | Webhook/API para backend executar |

---

## PARTE 4: Arquitetura da Implementacao Web

### 4.1 Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           NAVEGADOR (Frontend)                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐   │
│  │  HTML/Razor      │    │  sag-events.js   │    │  Event Queue     │   │
│  │  (Componentes)   │───>│  (Gerenciador)   │───>│  (Fila Async)    │   │
│  │  data-sag-*      │    │                  │    │                  │   │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘   │
│                                   │                       │              │
│                                   v                       v              │
│                          ┌──────────────────────────────────────┐       │
│                          │      Event Handler Central           │       │
│                          │  - Identifica tipo do evento         │       │
│                          │  - Obtem instrucoes PLSAG           │       │
│                          │  - [FASE 1] Exibe popup de debug    │       │
│                          │  - [FASE 2] Chama interpretador     │       │
│                          └──────────────────────────────────────┘       │
│                                          │                               │
└──────────────────────────────────────────│───────────────────────────────┘
                                           │
                                           v (AJAX/Fetch)
┌─────────────────────────────────────────────────────────────────────────┐
│                           SERVIDOR (Backend)                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐   │
│  │  EventController │    │  EventService    │    │  PlsagService    │   │
│  │  /api/events/*   │───>│  (Logica)        │───>│  [FASE 2]        │   │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘   │
│                                   │                                      │
│                                   v                                      │
│                          ┌──────────────────┐                           │
│                          │  SQL Server      │                           │
│                          │  SISTTABE        │                           │
│                          │  SISTCAMP        │                           │
│                          └──────────────────┘                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Componentes da Solucao

#### 4.2.1 Frontend - JavaScript (sag-events.js)

```javascript
/**
 * SAG Event System - Fase 1
 * Gerencia eventos dos componentes dinamicos
 */
const SagEvents = (function() {
    'use strict';

    // Configuracao
    const config = {
        debugMode: true,  // Fase 1: sempre true
        showPopups: true, // Fase 1: mostrar popups de debug
        logToConsole: true
    };

    // Armazena dados dos eventos (populado pelo Razor)
    let fieldEvents = {};
    let formEvents = {};

    // Fila de eventos para execucao sequencial
    let eventQueue = [];
    let isProcessing = false;

    /**
     * Inicializa o sistema de eventos
     * @param {Object} options - Configuracoes
     */
    function init(options = {}) {
        Object.assign(config, options);

        // Registra eventos em todos os campos com data-sag-*
        bindFieldEvents();

        // Registra eventos do formulario
        bindFormEvents();

        log('SagEvents inicializado', { fieldCount: Object.keys(fieldEvents).length });
    }

    /**
     * Registra dados dos eventos dos campos
     * @param {Object} events - Mapa de CodiCamp -> EventData
     */
    function registerFieldEvents(events) {
        fieldEvents = events || {};
    }

    /**
     * Registra dados dos eventos do formulario
     * @param {Object} events - FormEventData
     */
    function registerFormEvents(events) {
        formEvents = events || {};
    }

    /**
     * Vincula eventos aos campos HTML
     */
    function bindFieldEvents() {
        // Campos com data-sag-field (todos os campos dinamicos)
        document.querySelectorAll('[data-sag-field]').forEach(element => {
            const codiCamp = element.dataset.sagField;
            const compType = element.dataset.sagType;

            bindElementEvents(element, codiCamp, compType);
        });
    }

    /**
     * Vincula eventos a um elemento especifico
     */
    function bindElementEvents(element, codiCamp, compType) {
        // OnExit (blur) - maioria dos campos
        if (shouldBindBlur(compType)) {
            element.addEventListener('blur', (e) => {
                handleEvent('OnExit', codiCamp, element, e);
            });
            element.addEventListener('focusout', (e) => {
                // Evita duplicacao se blur ja tratou
                if (e.target === element) return;
                handleEvent('OnExit', codiCamp, element, e);
            });
        }

        // OnClick - botoes, checkboxes
        if (shouldBindClick(compType)) {
            element.addEventListener('click', (e) => {
                handleEvent('OnClick', codiCamp, element, e);
            });
        }

        // OnChange - selects, combos
        if (shouldBindChange(compType)) {
            element.addEventListener('change', (e) => {
                handleEvent('OnChange', codiCamp, element, e);
                // Tambem valida obrigatorios
                validateRequired();
            });
        }

        // OnDblClick - grids
        if (shouldBindDblClick(compType)) {
            element.addEventListener('dblclick', (e) => {
                handleEvent('OnDblClick', codiCamp, element, e);
            });
        }

        // OnInput - para validacao em tempo real
        if (isInputField(compType)) {
            element.addEventListener('input', (e) => {
                validateRequired();
            });
        }
    }

    /**
     * Handler central de eventos
     */
    function handleEvent(eventType, codiCamp, element, originalEvent) {
        const eventData = fieldEvents[codiCamp];
        const fieldName = element.name || element.id || `field_${codiCamp}`;
        const fieldValue = getElementValue(element);

        // Obtem instrucoes PLSAG para este evento
        let instructions = '';
        switch (eventType) {
            case 'OnExit':
                instructions = eventData?.onExitInstructions || '';
                break;
            case 'OnClick':
                instructions = eventData?.onClickInstructions || '';
                break;
            case 'OnChange':
                instructions = eventData?.onExitInstructions || ''; // Change usa mesmas instrucoes de Exit
                break;
            case 'OnDblClick':
                instructions = eventData?.onDblClickInstructions || '';
                break;
        }

        // Cria objeto do evento
        const sagEvent = {
            type: eventType,
            codiCamp: codiCamp,
            fieldName: fieldName,
            fieldValue: fieldValue,
            instructions: instructions,
            hasInstructions: !!instructions && instructions.trim().length > 0,
            timestamp: new Date().toISOString(),
            element: element
        };

        // Log do evento
        log(`Evento: ${eventType}`, sagEvent);

        // FASE 1: Mostra popup de debug (sera removido na Fase 2)
        if (config.showPopups && sagEvent.hasInstructions) {
            showEventPopup(sagEvent);
        }

        // Adiciona a fila para processamento
        if (sagEvent.hasInstructions) {
            enqueueEvent(sagEvent);
        }
    }

    /**
     * Trata eventos do ciclo de vida do formulario
     */
    function bindFormEvents() {
        // FormShow - quando o formulario e exibido
        document.addEventListener('DOMContentLoaded', () => {
            // Pequeno delay para garantir que tudo carregou
            setTimeout(() => {
                triggerFormEvent('ShowTabe');
            }, 100);
        });

        // Antes de submeter (LancTabe)
        const form = document.getElementById('dynamicForm');
        if (form) {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();

                // Executa LancTabe (antes de gravar)
                await triggerFormEvent('LancTabe');

                // Aqui chamaria o saveForm() existente
                // ...

                // Executa EGraTabe (apos gravar)
                await triggerFormEvent('EGraTabe');

                // Executa AposTabe (final)
                await triggerFormEvent('AposTabe');
            });
        }
    }

    /**
     * Dispara evento de formulario
     */
    async function triggerFormEvent(eventName) {
        let instructions = '';
        switch (eventName) {
            case 'ShowTabe':
                instructions = formEvents.showTabeInstructions || '';
                break;
            case 'LancTabe':
                instructions = formEvents.lancTabeInstructions || '';
                break;
            case 'EGraTabe':
                instructions = formEvents.eGraTabeInstructions || '';
                break;
            case 'AposTabe':
                instructions = formEvents.aposTabeInstructions || '';
                break;
        }

        if (instructions && instructions.trim().length > 0) {
            const sagEvent = {
                type: eventName,
                codiTabe: formEvents.codiTabe,
                instructions: instructions,
                hasInstructions: true,
                timestamp: new Date().toISOString(),
                isFormEvent: true
            };

            log(`Evento Form: ${eventName}`, sagEvent);

            if (config.showPopups) {
                showEventPopup(sagEvent);
            }

            // Aguarda processamento
            await processEvent(sagEvent);
        }
    }

    /**
     * Adiciona evento a fila
     */
    function enqueueEvent(sagEvent) {
        eventQueue.push(sagEvent);
        processQueue();
    }

    /**
     * Processa fila de eventos sequencialmente
     */
    async function processQueue() {
        if (isProcessing || eventQueue.length === 0) return;

        isProcessing = true;

        while (eventQueue.length > 0) {
            const event = eventQueue.shift();
            await processEvent(event);
        }

        isProcessing = false;
    }

    /**
     * Processa um evento individual
     * FASE 1: Apenas loga e mostra debug
     * FASE 2: Chamara o interpretador PLSAG
     */
    async function processEvent(sagEvent) {
        log('Processando evento', sagEvent);

        // FASE 1: Nao interpreta PLSAG, apenas registra
        // Futuramente aqui chamara:
        // await PlsagInterpreter.execute(sagEvent.instructions, getFormContext());

        // Simula pequeno delay para demonstrar processamento
        await new Promise(resolve => setTimeout(resolve, 50));

        return true;
    }

    /**
     * Mostra popup de debug do evento (FASE 1)
     */
    function showEventPopup(sagEvent) {
        // Cria ou reutiliza container de notificacoes
        let container = document.getElementById('sag-event-notifications');
        if (!container) {
            container = document.createElement('div');
            container.id = 'sag-event-notifications';
            container.style.cssText = `
                position: fixed;
                top: 10px;
                right: 10px;
                z-index: 9999;
                max-width: 400px;
                max-height: 80vh;
                overflow-y: auto;
            `;
            document.body.appendChild(container);
        }

        // Cria notificacao
        const notification = document.createElement('div');
        notification.className = 'sag-event-notification';
        notification.style.cssText = `
            background: #1a1a2e;
            color: #eee;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            border-left: 4px solid ${getEventColor(sagEvent.type)};
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            animation: slideIn 0.3s ease;
        `;

        const isFormEvent = sagEvent.isFormEvent;
        const title = isFormEvent ? `Form: ${sagEvent.type}` : `${sagEvent.type}: ${sagEvent.fieldName}`;
        const details = isFormEvent
            ? `CodiTabe: ${sagEvent.codiTabe}`
            : `CodiCamp: ${sagEvent.codiCamp} | Valor: "${sagEvent.fieldValue || ''}"`;

        notification.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: start;">
                <div>
                    <strong style="color: ${getEventColor(sagEvent.type)};">${title}</strong>
                    <div style="font-size: 11px; color: #aaa; margin-top: 4px;">${details}</div>
                    ${sagEvent.hasInstructions ? `
                        <div style="margin-top: 8px; padding: 8px; background: #0d0d15; border-radius: 4px; font-family: monospace; font-size: 11px; max-height: 100px; overflow-y: auto; white-space: pre-wrap;">
                            ${escapeHtml(sagEvent.instructions.substring(0, 200))}${sagEvent.instructions.length > 200 ? '...' : ''}
                        </div>
                    ` : '<div style="font-size: 11px; color: #666; margin-top: 4px;">(Sem instrucoes PLSAG)</div>'}
                </div>
                <button onclick="this.parentElement.parentElement.remove()"
                        style="background: none; border: none; color: #666; cursor: pointer; font-size: 16px; padding: 0 0 0 8px;">×</button>
            </div>
        `;

        container.insertBefore(notification, container.firstChild);

        // Auto-remove apos 5 segundos
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 5000);
    }

    // ========== FUNCOES AUXILIARES ==========

    function shouldBindBlur(compType) {
        return ['E', 'N', 'D', 'M', 'BM', 'A', 'EE', 'EN', 'ED', 'EA', 'EI', 'ET'].includes(compType);
    }

    function shouldBindClick(compType) {
        return ['S', 'ES', 'BTN', 'LC'].includes(compType);
    }

    function shouldBindChange(compType) {
        return ['C', 'T', 'IT', 'EC', 'L', 'IL'].includes(compType);
    }

    function shouldBindDblClick(compType) {
        return ['DBG'].includes(compType);
    }

    function isInputField(compType) {
        return ['E', 'N', 'D', 'M', 'BM', 'C', 'T', 'IT', 'L', 'IL', 'EE', 'EN', 'ED', 'EC'].includes(compType);
    }

    function getElementValue(element) {
        if (element.type === 'checkbox') {
            return element.checked ? '1' : '0';
        }
        if (element.type === 'select-multiple') {
            return Array.from(element.selectedOptions).map(o => o.value).join(',');
        }
        return element.value || '';
    }

    function getEventColor(eventType) {
        const colors = {
            'OnExit': '#4fc3f7',
            'OnClick': '#81c784',
            'OnChange': '#ffb74d',
            'OnDblClick': '#ba68c8',
            'ShowTabe': '#4db6ac',
            'LancTabe': '#f06292',
            'EGraTabe': '#aed581',
            'AposTabe': '#9575cd'
        };
        return colors[eventType] || '#90a4ae';
    }

    function validateRequired() {
        // Verifica todos os campos obrigatorios
        let allValid = true;
        document.querySelectorAll('[data-sag-required="true"]').forEach(el => {
            const value = getElementValue(el);
            if (!value || value.trim() === '') {
                allValid = false;
            }
        });

        // Habilita/desabilita botao Confirmar
        const btnConfirm = document.querySelector('[data-sag-btn-confirm]');
        if (btnConfirm) {
            btnConfirm.disabled = !allValid;
        }
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function log(message, data = null) {
        if (config.logToConsole) {
            console.log(`[SagEvents] ${message}`, data || '');
        }
    }

    // ========== API PUBLICA ==========

    return {
        init,
        registerFieldEvents,
        registerFormEvents,
        triggerFormEvent,
        getConfig: () => ({ ...config }),
        setConfig: (key, value) => { config[key] = value; }
    };
})();

// CSS para animacoes
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);

// Exporta para uso global
window.SagEvents = SagEvents;
```

#### 4.2.2 Backend - Servico de Eventos (EventService.cs)

```csharp
using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using SagPoc.Web.Models;

namespace SagPoc.Web.Services;

/// <summary>
/// Servico para carregar dados de eventos do banco
/// </summary>
public interface IEventService
{
    Task<FormEventData> GetFormEventsAsync(int codiTabe);
    Task<Dictionary<int, FieldEventData>> GetFieldEventsAsync(int codiTabe);
}

public class EventService : IEventService
{
    private readonly string _connectionString;
    private readonly ILogger<EventService> _logger;

    public EventService(IConfiguration configuration, ILogger<EventService> logger)
    {
        _connectionString = configuration.GetConnectionString("SagDb")
            ?? throw new InvalidOperationException("Connection string 'SagDb' not found.");
        _logger = logger;
    }

    private IDbConnection CreateConnection() => new SqlConnection(_connectionString);

    /// <summary>
    /// Carrega eventos do formulario (SISTTABE)
    /// </summary>
    public async Task<FormEventData> GetFormEventsAsync(int codiTabe)
    {
        var sql = @"
            SELECT
                CODITABE as CodiTabe,
                ISNULL(NOMETABE, '') as NomeTabe,
                CAST(SHOWTABE as NVARCHAR(MAX)) as ShowTabeInstructions,
                CAST(LANCTABE as NVARCHAR(MAX)) as LancTabeInstructions,
                CAST(EGRATABE as NVARCHAR(MAX)) as EGraTabeInstructions,
                CAST(APOSTABE as NVARCHAR(MAX)) as AposTabeInstructions,
                CAST(EPERTABE as NVARCHAR(MAX)) as EPerTabeInstructions
            FROM SISTTABE
            WHERE CODITABE = @CodiTabe";

        try
        {
            using var connection = CreateConnection();
            connection.Open();
            var result = await connection.QueryFirstOrDefaultAsync<FormEventData>(sql, new { CodiTabe = codiTabe });

            if (result != null)
            {
                // Mescla EPerTabe com cada instrucao (similar ao Delphi)
                result.ShowTabeInstructions = MergeInstructions(result.ShowTabeInstructions, result.EPerTabeInstructions);
                result.LancTabeInstructions = MergeInstructions(result.LancTabeInstructions, result.EPerTabeInstructions);
                result.EGraTabeInstructions = MergeInstructions(result.EGraTabeInstructions, result.EPerTabeInstructions);
                result.AposTabeInstructions = MergeInstructions(result.AposTabeInstructions, result.EPerTabeInstructions);

                // Carrega AnteCria e DepoCria do SISTCAMP
                await LoadSpecialFieldEvents(connection, codiTabe, result);
            }

            _logger.LogInformation("Eventos do form {CodiTabe} carregados", codiTabe);
            return result ?? new FormEventData { CodiTabe = codiTabe };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar eventos do form {CodiTabe}", codiTabe);
            throw;
        }
    }

    /// <summary>
    /// Carrega eventos dos campos (SISTCAMP)
    /// </summary>
    public async Task<Dictionary<int, FieldEventData>> GetFieldEventsAsync(int codiTabe)
    {
        var sql = @"
            SELECT
                CODICAMP as CodiCamp,
                ISNULL(NOMECAMP, '') as NomeCamp,
                ISNULL(COMPCAMP, 'E') as CompCamp,
                ISNULL(OBRICAMP, 0) as ObriCamp,
                CAST(EXPRCAMP as NVARCHAR(MAX)) as ExprCamp,
                CAST(EPERCAMP as NVARCHAR(MAX)) as EPerCamp,
                CAST(EXP1CAMP as NVARCHAR(MAX)) as Exp1Camp
            FROM SISTCAMP
            WHERE CODITABE = @CodiTabe
              AND NOMECAMP NOT IN ('AnteCria', 'DepoCria', 'DEPOSHOW', 'ATUAGRID')
            ORDER BY ORDECAMP";

        try
        {
            using var connection = CreateConnection();
            connection.Open();
            var fields = await connection.QueryAsync<dynamic>(sql, new { CodiTabe = codiTabe });

            var result = new Dictionary<int, FieldEventData>();

            foreach (var field in fields)
            {
                var eventData = new FieldEventData
                {
                    CodiCamp = (int)field.CodiCamp,
                    NomeCamp = (string)field.NomeCamp,
                    IsRequired = (int)field.ObriCamp != 0
                };

                // Mescla ExprCamp + EPerCamp
                var instructions = MergeInstructions(
                    (string)field.ExprCamp,
                    (string)field.EPerCamp);

                // Atribui instrucoes baseado no tipo de componente
                var compType = ((string)field.CompCamp)?.ToUpper()?.Trim() ?? "E";

                if (IsClickComponent(compType))
                {
                    eventData.OnClickInstructions = instructions;
                }
                else
                {
                    eventData.OnExitInstructions = instructions;
                }

                // Grid usa Exp1Camp para DblClick
                if (compType == "DBG")
                {
                    eventData.OnDblClickInstructions = MergeInstructions(
                        (string)field.Exp1Camp,
                        (string)field.EPerCamp);
                }

                result[eventData.CodiCamp] = eventData;
            }

            _logger.LogInformation("Eventos de {Count} campos carregados para tabela {CodiTabe}",
                result.Count, codiTabe);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao carregar eventos dos campos da tabela {CodiTabe}", codiTabe);
            throw;
        }
    }

    private async Task LoadSpecialFieldEvents(IDbConnection connection, int codiTabe, FormEventData result)
    {
        var sql = @"
            SELECT
                NOMECAMP as NomeCamp,
                CAST(EXPRCAMP as NVARCHAR(MAX)) as ExprCamp
            FROM SISTCAMP
            WHERE CODITABE = @CodiTabe
              AND NOMECAMP IN ('AnteCria', 'DepoCria')";

        var specialFields = await connection.QueryAsync<dynamic>(sql, new { CodiTabe = codiTabe });

        foreach (var field in specialFields)
        {
            var nome = ((string)field.NomeCamp)?.ToUpper()?.Trim();
            var expr = (string)field.ExprCamp;

            if (nome == "ANTECRIA")
                result.AntecriaInstructions = expr;
            else if (nome == "DEPOCRIA")
                result.DepocriaInstructions = expr;
        }
    }

    private string MergeInstructions(string primary, string permanent)
    {
        if (string.IsNullOrWhiteSpace(primary) && string.IsNullOrWhiteSpace(permanent))
            return string.Empty;

        if (string.IsNullOrWhiteSpace(primary))
            return permanent?.Trim() ?? string.Empty;

        if (string.IsNullOrWhiteSpace(permanent))
            return primary?.Trim() ?? string.Empty;

        // Mescla: primary primeiro, depois permanent
        return $"{primary.Trim()}\n{permanent.Trim()}";
    }

    private bool IsClickComponent(string compType)
    {
        return compType switch
        {
            "S" or "ES" or "BTN" or "LC" => true,
            _ => false
        };
    }
}

/// <summary>
/// Dados de eventos de um campo
/// </summary>
public class FieldEventData
{
    public int CodiCamp { get; set; }
    public string NomeCamp { get; set; } = string.Empty;
    public string OnExitInstructions { get; set; } = string.Empty;
    public string OnClickInstructions { get; set; } = string.Empty;
    public string OnDblClickInstructions { get; set; } = string.Empty;
    public bool IsRequired { get; set; }

    public bool HasEvents =>
        !string.IsNullOrWhiteSpace(OnExitInstructions) ||
        !string.IsNullOrWhiteSpace(OnClickInstructions) ||
        !string.IsNullOrWhiteSpace(OnDblClickInstructions);
}

/// <summary>
/// Dados de eventos do formulario
/// </summary>
public class FormEventData
{
    public int CodiTabe { get; set; }
    public string NomeTabe { get; set; } = string.Empty;
    public string ShowTabeInstructions { get; set; } = string.Empty;
    public string LancTabeInstructions { get; set; } = string.Empty;
    public string EGraTabeInstructions { get; set; } = string.Empty;
    public string AposTabeInstructions { get; set; } = string.Empty;
    public string AntecriaInstructions { get; set; } = string.Empty;
    public string DepocriaInstructions { get; set; } = string.Empty;

    // Usado internamente para merge
    internal string EPerTabeInstructions { get; set; } = string.Empty;
}
```

#### 4.2.3 Modificacoes no Razor (_FieldRendererV2.cshtml)

```html
@* Adicionar data attributes para o sistema de eventos *@

@* No input de texto (exemplo): *@
<input type="text"
       class="form-control"
       id="@fieldId"
       name="@fieldName"
       data-sag-field="@field.CodiCamp"
       data-sag-type="@field.CompCamp"
       data-sag-required="@field.IsRequired.ToString().ToLower()"
       title="@hint"
       placeholder="@hint"
       @(isRequired ? "required" : "")
       @(isDisabled ? "disabled" : "") />

@* Padrao aplicado a todos os componentes *@
```

---

## PARTE 5: Passo a Passo de Implementacao

### 5.1 Visao Geral das Fases

```
┌─────────────────────────────────────────────────────────────────┐
│  FASE 1: Infraestrutura de Eventos (Este Documento)             │
│  - Captura de eventos                                           │
│  - Popup de debug                                               │
│  - Carregamento de instrucoes PLSAG (sem interpretar)          │
│  Duracao Estimada: 1-2 semanas                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  FASE 2: Interpretador PLSAG (Documento Futuro)                 │
│  - Parser de instrucoes PLSAG                                   │
│  - Execucao de comandos (CS, VA, IF, EX, etc.)                 │
│  - Integracao com backend                                       │
│  Duracao Estimada: 3-4 semanas                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              v
┌─────────────────────────────────────────────────────────────────┐
│  FASE 3: Validacao e Testes                                     │
│  - Testes comparativos Delphi vs Web                            │
│  - Ajustes de comportamento                                     │
│  - Documentacao de diferencas                                   │
│  Duracao Estimada: 1-2 semanas                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Passo a Passo - Fase 1

#### Etapa 1: Criar Modelos de Dados (Backend)

**Arquivos a criar/modificar:**
- `Models/FieldEventData.cs` (novo)
- `Models/FormEventData.cs` (novo)
- `Models/FieldMetadata.cs` (modificar - adicionar propriedades de evento)

**Tarefas:**
1. Criar classe `FieldEventData` com propriedades de instrucoes PLSAG
2. Criar classe `FormEventData` com eventos de ciclo de vida
3. Adicionar propriedade `EventData` ao `FieldMetadata` existente

#### Etapa 2: Criar Servico de Eventos (Backend)

**Arquivos a criar:**
- `Services/IEventService.cs`
- `Services/EventService.cs`

**Tarefas:**
1. Implementar `GetFormEventsAsync(int codiTabe)` - carrega SISTTABE
2. Implementar `GetFieldEventsAsync(int codiTabe)` - carrega SISTCAMP
3. Implementar logica de merge ExprCamp + EPerCamp
4. Registrar servico no `Program.cs`

#### Etapa 3: Modificar FormController (Backend)

**Arquivos a modificar:**
- `Controllers/FormController.cs`

**Tarefas:**
1. Injetar `IEventService`
2. Modificar action `Render` para carregar eventos
3. Passar eventos para a View via ViewModel

#### Etapa 4: Criar JavaScript de Eventos (Frontend)

**Arquivos a criar:**
- `wwwroot/js/sag-events.js`

**Tarefas:**
1. Implementar modulo `SagEvents` conforme especificacao
2. Implementar sistema de binding de eventos
3. Implementar popups de debug
4. Implementar fila de eventos

#### Etapa 5: Modificar Views (Frontend)

**Arquivos a modificar:**
- `Views/Form/_FieldRendererV2.cshtml`
- `Views/Form/Render.cshtml`
- `Views/Shared/_Layout.cshtml`

**Tarefas:**
1. Adicionar `data-sag-*` attributes em todos os componentes
2. Incluir script `sag-events.js` no layout
3. Inicializar `SagEvents` com dados do servidor
4. Passar eventos como JSON para o JavaScript

#### Etapa 6: Testes e Validacao

**Tarefas:**
1. Testar todos os tipos de componentes (E, N, D, S, C, T, BTN, etc.)
2. Verificar popups de debug para cada evento
3. Validar carregamento correto das instrucoes PLSAG
4. Testar eventos de formulario (ShowTabe, LancTabe, etc.)

### 5.3 Checklist de Implementacao

```
[ ] Etapa 1: Modelos de Dados
    [ ] FieldEventData.cs criado
    [ ] FormEventData.cs criado
    [ ] FieldMetadata.cs atualizado

[ ] Etapa 2: Servico de Eventos
    [ ] IEventService.cs criado
    [ ] EventService.cs implementado
    [ ] Queries SQL funcionando
    [ ] Servico registrado no DI

[ ] Etapa 3: FormController
    [ ] IEventService injetado
    [ ] Eventos carregados na action Render
    [ ] ViewModel atualizado com eventos

[ ] Etapa 4: JavaScript
    [ ] sag-events.js criado
    [ ] Binding de eventos funcionando
    [ ] Popups de debug exibindo
    [ ] Fila de eventos processando

[ ] Etapa 5: Views
    [ ] data-sag-* em todos componentes
    [ ] Script incluido no layout
    [ ] Inicializacao com dados do servidor

[ ] Etapa 6: Testes
    [ ] Componente E (TextInput) - OnExit
    [ ] Componente N (NumberInput) - OnExit
    [ ] Componente D (DateInput) - OnExit
    [ ] Componente S (Checkbox) - OnClick
    [ ] Componente C (ComboBox) - OnChange
    [ ] Componente T/IT (LookupCombo) - OnChange
    [ ] Componente BTN (Button) - OnClick
    [ ] Componente M (Textarea) - OnExit
    [ ] Evento ShowTabe (FormShow)
    [ ] Evento LancTabe (Pre-Submit)
    [ ] Evento EGraTabe (Pos-Submit)
    [ ] Evento AposTabe (Final)
```

---

## PARTE 6: Exemplos de Uso

### 6.1 Exemplo: Campo com OnExit

**Configuracao no banco (SISTCAMP):**
```
CODICAMP: 1001
NOMECAMP: NOMETPDO
COMPCAMP: E
EXPRCAMP: CS-SIGLTPDO-{DG-NOMETPDO};IF-INIC0001-'{DG-SIGLTPDO}'='';VA-STRI0001-'Nome obrigatorio!';IF-FINA0001
EPERCAMP: VA-LASTFIELD-NOMETPDO
```

**Renderizacao HTML (com data attributes):**
```html
<input type="text"
       class="form-control"
       id="field_1001"
       name="NOMETPDO"
       data-sag-field="1001"
       data-sag-type="E"
       data-sag-required="true"
       placeholder="Nome" />
```

**Popup de Debug (Fase 1):**
```
┌─────────────────────────────────────────┐
│ OnExit: NOMETPDO                        │
│ CodiCamp: 1001 | Valor: "Teste"         │
│ ┌─────────────────────────────────────┐ │
│ │ CS-SIGLTPDO-{DG-NOMETPDO};          │ │
│ │ IF-INIC0001-'{DG-SIGLTPDO}'='';    │ │
│ │ VA-STRI0001-'Nome obrigatorio!';   │ │
│ │ IF-FINA0001                        │ │
│ │ VA-LASTFIELD-NOMETPDO               │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 6.2 Exemplo: Botao com OnClick

**Configuracao no banco (SISTCAMP):**
```
CODICAMP: 1002
NOMECAMP: BTNCALC
COMPCAMP: BTN
LABECAMP: Calcular
EXPRCAMP: EX-DTBGENE-UPDATE POCA SET TOTAL = QTD * PRECO WHERE ID = {DG-ID}
```

**Renderizacao HTML:**
```html
<button type="button"
        class="btn btn-secondary"
        id="field_1002"
        data-sag-field="1002"
        data-sag-type="BTN">
    Calcular
</button>
```

**Popup de Debug (Fase 1):**
```
┌─────────────────────────────────────────┐
│ OnClick: BTNCALC                        │
│ CodiCamp: 1002                          │
│ ┌─────────────────────────────────────┐ │
│ │ EX-SQL-UPDATE POCA SET TOTAL =      │ │
│ │ QTD * PRECO WHERE ID = {DG-ID}      │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 6.3 Exemplo: Evento de Formulario (ShowTabe)

**Configuracao no banco (SISTTABE):**
```
CODITABE: 120
SHOWTABE: VA-DATA0001-{VA-DATAATUA};CE-DATAINI-{VA-DATA0001}
EPERTABE: VA-INTE0001-{VA-CODIUSUA}
```

**Popup de Debug (Fase 1):**
```
┌─────────────────────────────────────────┐
│ Form: ShowTabe                          │
│ CodiTabe: 120                           │
│ ┌─────────────────────────────────────┐ │
│ │ VA-DATA0001-{VA-DATAATUA};          │ │
│ │ CE-DATAINI-{VA-DATA0001};           │ │
│ │ VA-INTE0001-{VA-CODIUSUA}           │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## PARTE 7: Proximos Passos (Fase 2)

Apos a conclusao da Fase 1 (infraestrutura de eventos), a Fase 2 focara em:

### 7.1 Interpretador PLSAG

1. **Parser de Instrucoes**
   - Tokenizacao de comandos (CS, VA, IF, EX, etc.)
   - Arvore de sintaxe abstrata (AST)
   - Tratamento de variaveis {TIPO-CAMPO} (ex: {DG-NomeProd}, {VA-INTE0001})

2. **Executor de Comandos**
   - CS (Component Set) - Setar valor em componente
   - VA (Variable Assign) - Atribuir variavel
   - IF/ELSE/FINA - Condicionais
   - EX-SQL - Executar SQL (via API)
   - AB-TELA - Abrir tela
   - MG/MS - Mensagens

3. **Contexto de Execucao**
   - Variaveis de formulario
   - Valores de campos
   - Dados do usuario/sessao

### 7.2 Documentacao Necessaria para Fase 2

- Manual do PLSAG (comandos e sintaxe)
- Exemplos de instrucoes reais do banco de producao
- Mapeamento de funcoes Delphi para JavaScript

---

## Conclusao

Esta proposta apresenta um caminho claro para implementar o sistema de eventos do SAG na plataforma web. A estrategia de dividir em fases (Fase 1: infraestrutura com debug, Fase 2: interpretador PLSAG) permite:

1. **Validar a captura de eventos** antes de implementar logica complexa
2. **Identificar incompatibilidades** atraves dos popups de debug
3. **Iterar rapidamente** sobre a implementacao
4. **Documentar diferenas** entre Delphi e Web

O sistema de popups de debug da Fase 1 servira como ferramenta de validacao, garantindo que todos os eventos estao sendo capturados corretamente antes de prosseguir para a interpretacao do PLSAG.

---

*Documento gerado em: 2025-12-24*
*Versao: 1.0*
*Status: Aguardando Aprovacao*
