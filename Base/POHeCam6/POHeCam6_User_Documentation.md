# POHeCam6 - Documentacao do Usuario

**Versao:** 1.0
**Data:** 2025-12-23
**Modulo:** SAG (Sistema de Apoio a Gestao)

---

## 1. Introducao

### 1.1 Sobre Este Documento

Este documento descreve o formulario base POHeCam6, que serve como fundacao para formularios com campos personalizados no sistema MIMS. Como este e um formulario base (classe pai), a documentacao aborda tanto o uso dos formularios derivados quanto os conceitos tecnicos necessarios para desenvolvedores.

### 1.2 Publico-Alvo

- **Desenvolvedores**: Que precisam criar ou manter formularios derivados de POHeCam6
- **Usuarios Avancados**: Que precisam entender o comportamento de formularios com campos personalizados
- **Administradores**: Que configuram telas atraves das tabelas POCaTabe e POCaCamp

### 1.3 O Que e POHeCam6?

POHeCam6 e um formulario generico que implementa:

- **Criacao dinamica de campos**: Os campos da tela sao criados automaticamente baseados em configuracao no banco de dados
- **Suporte a movimentos**: Permite ter grids filhos (movimentos) relacionados ao registro principal
- **Comunicacao serial/IP**: Integra com dispositivos externos como balancas e leitores de codigo de barras
- **Modo Web e Desktop**: Funciona tanto na versao Web (uniGUI) quanto Desktop (VCL)

---

## 2. Estrutura do Formulario

### 2.1 Layout Geral

```
+----------------------------------------------------------+
| Titulo do Formulario                            [X][_][M] |
+----------------------------------------------------------+
| [Guia 1] [Guia 2] [Movimento 1] [Movimento 2]            |
+----------------------------------------------------------+
|                                                          |
|   +--------------------------------------------------+   |
|   |                                                  |   |
|   |        Area de Campos Personalizados            |   |
|   |        (Pnl1 - criados dinamicamente)           |   |
|   |                                                  |   |
|   +--------------------------------------------------+   |
|                                                          |
|   +--------------------------------------------------+   |
|   |                                                  |   |
|   |        Area de Movimentos (PnlDado)             |   |
|   |        (Grids de itens relacionados)            |   |
|   |                                                  |   |
|   +--------------------------------------------------+   |
|                                                          |
+----------------------------------------------------------+
| [Confirma]  [Cancela]  [Outros Botoes]                   |
+----------------------------------------------------------+
```

### 2.2 Areas Principais

#### Area de Campos (Pnl1)
- Contem os campos personalizados definidos em POCaCamp
- Campos sao organizados por guias (Gui1Tabe, Gui2Tabe, etc.)
- Tipos de campos suportados: textos, numeros, datas, combos, grids, etc.

#### Area de Movimentos (PnlDado)
- Aparece quando ha tabelas filhas configuradas
- Cada movimento tem seu proprio grid editavel
- Botoes de Incluir, Alterar e Excluir por movimento

### 2.3 Navegacao

| Tecla | Acao |
|-------|------|
| Tab | Proximo campo |
| Shift+Tab | Campo anterior |
| ESC | Proxima guia ou Confirma |
| Enter | Confirma campo / Proximo campo |
| F2 | Abre pesquisa (em campos de lookup) |

---

## 3. Operacoes Basicas

### 3.1 Inclusao de Registro

1. Acesse o formulario pelo menu do sistema
2. O sistema abrira em modo de inclusao
3. Preencha os campos obrigatorios (marcados com *)
4. Se houver movimentos, adicione os itens necessarios
5. Clique em **Confirma** para gravar

**Fluxo Automatico:**
- Campos sequenciais sao preenchidos automaticamente
- Campos com valor padrao sao inicializados
- Validacoes sao executadas ao sair de cada campo

### 3.2 Alteracao de Registro

1. Selecione o registro na lista/grade
2. Clique em **Alterar** ou de duplo-clique
3. Modifique os campos desejados
4. Clique em **Confirma** para gravar

**Restricoes:**
- Alguns campos podem estar bloqueados se o registro foi gerado por outro processo
- Campos calculados nao podem ser editados manualmente

### 3.3 Exclusao de Registro

1. Selecione o registro desejado
2. Clique em **Excluir**
3. Confirme a exclusao no dialogo

**Importante:** A exclusao pode ser impedida se houver registros relacionados.

### 3.4 Cancelamento

- Clique em **Cancela** para descartar alteracoes
- Se estiver em modo inclusao, o registro temporario sera excluido
- Se estiver em modo alteracao, as mudancas serao descartadas

---

## 4. Movimentos (Grids Filhos)

### 4.1 O Que Sao Movimentos?

Movimentos sao registros filhos relacionados ao registro principal. Exemplos:
- Itens de um pedido
- Parcelas de um pagamento
- Componentes de uma formula

### 4.2 Trabalhando com Movimentos

#### Incluir Item
1. Clique no botao **Novo** (ou **Incluir**) do movimento
2. Preencha os campos do item
3. Confirme o item

#### Alterar Item
1. Selecione o item no grid
2. Clique em **Alterar**
3. Modifique os campos
4. Confirme as alteracoes

#### Excluir Item
1. Selecione o item no grid
2. Clique em **Excluir**
3. Confirme a exclusao

### 4.3 Ordenacao e Filtragem

- Clique no cabecalho da coluna para ordenar
- Use os filtros disponiveis acima do grid
- Duplo-clique em um item para edita-lo

---

## 5. Integracao com Dispositivos

### 5.1 Balancas e Leitores

O formulario pode receber dados de dispositivos externos:

- **Balancas**: Peso e capturado automaticamente
- **Leitores de codigo de barras**: Codigo e preenchido no campo
- **Terminais de coleta**: Dados sao sincronizados

### 5.2 Configuracao Serial/IP

A configuracao e feita atraves do campo SeriTabe em POCaTabe:

```
Formato: //protocolo:parametros
Exemplo: //COM1:9600,N,8,1
Exemplo: //IP:192.168.1.100:4001
```

### 5.3 Funcionamento

1. O sistema abre a porta serial/IP ao exibir o formulario
2. Dados recebidos sao processados e direcionados aos campos
3. Instrucoes configuradas sao executadas apos recepcao
4. A porta e fechada ao confirmar ou cancelar

---

## 6. Campos Personalizados

### 6.1 Tipos de Campos

| Tipo | Codigo | Descricao |
|------|--------|-----------|
| Texto | E, DE | Campo de texto simples |
| Numero | N, EN | Campo numerico |
| Data | D, DD | Campo de data |
| Combo | L, DL | Lista suspensa |
| Lookup | LC, DLC | Pesquisa em tabela |
| Checkbox | C, DC | Caixa de selecao |
| Memo | M, DM | Texto longo |
| Grid | DBG | Grade de dados |
| Botao | BTN | Botao de acao |

### 6.2 Campos Calculados

Alguns campos podem ter valores calculados automaticamente:
- Totalizadores de movimentos
- Formulas baseadas em outros campos
- Valores padrao baseados em regras

### 6.3 Validacoes

- **Obrigatoriedade**: Campos marcados como obrigatorios
- **Formato**: Validacao de formato (CPF, CNPJ, etc.)
- **Intervalo**: Valores dentro de limites definidos
- **Dependencia**: Campos habilitados baseados em outros

---

## 7. Mensagens e Erros

### 7.1 Mensagens Comuns

| Mensagem | Causa | Solucao |
|----------|-------|---------|
| "Dados Gerados por outro Processo" | Tentativa de alterar campo bloqueado | Use outro processo para modificar |
| "Campo obrigatorio" | Campo necessario nao preenchido | Preencha o campo indicado |
| "Valor fora do intervalo" | Valor digitado invalido | Use valor dentro dos limites |

### 7.2 Erros de Sistema

| Erro | Causa | Solucao |
|------|-------|---------|
| "Componente nao mais usado" | Configuracao obsoleta | Contate o suporte tecnico |
| "Erro de conexao" | Problema de rede/banco | Verifique conectividade |
| "Porta serial em uso" | Dispositivo ocupado | Feche outros programas |

---

## 8. Dicas e Boas Praticas

### 8.1 Para Usuarios

1. **Preencha campos na ordem**: O sistema pode calcular valores baseados em campos anteriores
2. **Use F2 para pesquisas**: Mais rapido que digitar o codigo
3. **Verifique movimentos**: Antes de confirmar, revise os itens incluidos
4. **Observe mensagens de status**: A barra inferior mostra o que esta acontecendo

### 8.2 Para Administradores

1. **Teste apos alteracoes**: Qualquer mudanca em POCaCamp afeta o formulario
2. **Documente instrucoes**: Campos com ExprCamp devem ter documentacao
3. **Use nomes significativos**: NameCamp deve indicar o proposito do campo
4. **Mantenha ordenacao**: OrdeCamp e GuiaCamp determinam a posicao visual

### 8.3 Para Desenvolvedores

1. **Herde corretamente**: Use TFrmPOHeCam6 como classe pai
2. **Override com cuidado**: Sempre chame inherited nos metodos override
3. **Teste ambos modos**: Verifique funcionamento Web e Desktop
4. **Use BuscaComponente**: Para localizar componentes dinamicos

---

## 9. Configuracao Avancada

### 9.1 Tabela POCaTabe

Campos principais de configuracao:

| Campo | Descricao |
|-------|-----------|
| CodiTabe | Codigo unico da tela |
| NomeTabe | Nome exibido no titulo |
| Gui1Tabe | Caption da primeira guia |
| Gui2Tabe | Caption da segunda guia |
| AltuTabe | Altura da tela em pixels |
| TamaTabe | Largura da tela em pixels |
| ShowTabe | Instrucoes executadas ao exibir |
| LancTabe | Instrucoes de lancamento |
| EGraTabe | Instrucoes pos-gravacao |
| SeriTabe | Configuracao de porta serial |

### 9.2 Tabela POCaCamp

Campos principais de configuracao:

| Campo | Descricao |
|-------|-----------|
| CodiTabe | Codigo da tela (FK) |
| CompCamp | Tipo do componente |
| NameCamp | Nome do campo |
| NomeCamp | Nome do campo no banco |
| LabeCamp | Label exibido |
| GuiaCamp | Numero da guia |
| OrdeCamp | Ordem na guia |
| ExprCamp | Expressao/instrucoes |
| InicCamp | Valor inicial |

### 9.3 Instrucoes Especiais

| Instrucao | Momento | Descricao |
|-----------|---------|-----------|
| AnteCria | Antes de criar campos | Inicializacao |
| DepoCria | Depois de criar campos | Pos-criacao |
| ShowTabe | Ao exibir formulario | Cada exibicao |
| LancTabe | Ao confirmar | Antes de gravar |
| EGraTabe | Apos gravacao | Pos-processamento |
| AposTabe | Apos confirma | Finalizacao |

---

## 10. Glossario

| Termo | Definicao |
|-------|-----------|
| CampPers | Sistema de campos personalizados |
| Movimento | Grid filho relacionado ao cabecalho |
| POCaTabe | Tabela de configuracao de telas |
| POCaCamp | Tabela de configuracao de campos |
| SeriTabe | Configuracao de porta serial/IP |
| TsgLeitSeri | Classe de leitura serial |
| TFraCaMv | Frame de cadastro de movimento |
| PSitGrav | Flag de situacao de gravacao (inclusao) |
| sgTransaction | Transacao atual do formulario |

---

## 11. Suporte

### 11.1 Contatos

- **Suporte Tecnico**: Contate a equipe de TI
- **Documentacao**: Consulte o portal interno

### 11.2 Versoes

| Versao | Data | Alteracao |
|--------|------|-----------|
| 1.0 | 2025-12-23 | Versao inicial |

---

**Documento gerado automaticamente por Claude Code**
**Modulo SAG - Sistema de Apoio a Gestao**

