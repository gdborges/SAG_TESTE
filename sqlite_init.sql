-- Script SQLite para SAG POC
-- Criação da tabela e inserção de dados

-- Drop tabela se existir
DROP TABLE IF EXISTS SistCamp;

-- Criar tabela SistCamp
CREATE TABLE SistCamp (
    CodiCamp INTEGER PRIMARY KEY AUTOINCREMENT,
    CodiTabe INTEGER,
    NomeCamp TEXT,
    LabeCamp TEXT,
    HintCamp TEXT,
    NosqCamp TEXT,
    TopoCamp INTEGER DEFAULT 0,
    MtopCamp INTEGER DEFAULT 0,
    EsquCamp INTEGER DEFAULT 0,
    MesqCamp INTEGER DEFAULT 0,
    TamaCamp INTEGER DEFAULT 100,
    TipoCamp TEXT,
    OrdeCamp INTEGER DEFAULT 0,
    ObriCamp INTEGER DEFAULT 0,
    GuiaCamp INTEGER DEFAULT 1,
    CompCamp TEXT DEFAULT 'E',
    MascCamp TEXT,
    MiniCamp REAL,
    MaxiCamp REAL,
    DeciCamp INTEGER DEFAULT 0,
    DropCamp INTEGER DEFAULT 0,
    PesqCamp INTEGER DEFAULT 0,
    PadrCamp REAL,
    AltuCamp INTEGER DEFAULT 21,
    FormCamp TEXT,
    EstiCamp TEXT,
    DesaCamp INTEGER DEFAULT 0,
    FixoCamp INTEGER DEFAULT 0,
    ColuCamp INTEGER DEFAULT 0,
    CoesCamp INTEGER DEFAULT 0,
    LinhCamp INTEGER DEFAULT 0,
    LiesCamp INTEGER DEFAULT 0,
    LfonCamp TEXT,
    LcorCamp INTEGER,
    LestCamp INTEGER,
    LefeCamp INTEGER,
    CfonCamp TEXT,
    CtamCamp INTEGER,
    CcorCamp INTEGER,
    CestCamp INTEGER,
    CefeCamp INTEGER,
    LtamCamp INTEGER,
    InteCamp INTEGER DEFAULT 0,
    ExisCamp INTEGER DEFAULT 0,
    TagqCamp INTEGER DEFAULT 0,
    PersCamp INTEGER DEFAULT 0,
    NameCamp TEXT,
    NoanCamp TEXT,
    ExprCamp TEXT,
    SqlCamp TEXT,
    InicCamp INTEGER DEFAULT 0,
    CodiTabe2 INTEGER,
    Id__Camp INTEGER,
    LbcxCamp INTEGER,
    VareCamp TEXT,
    VagrCamp TEXT,
    SgchCamp TEXT,
    StopCamp REAL,
    SmtoCamp REAL,
    SesqCamp REAL,
    SmesCamp REAL,
    StamCamp REAL,
    SaltCamp REAL,
    SguiCamp REAL,
    ScolCamp REAL,
    ScoeCamp REAL,
    SlinCamp REAL,
    SliesCamp REAL,
    SfixCamp REAL,
    EperCamp TEXT
);

-- =====================================================
-- DADOS DA TABELA 210 (Tipo de Documento)
-- =====================================================

-- BVL - Caixa (GroupBox) principal
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, FormCamp)
VALUES (210, 'CAIXCA01', '-', 'Caixa', 15, 10, 340, 10, 1, 'BVL', 175, '1');

-- E - Campo Nome
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (210, 'NOMETPDO', 'Nome', 'Nome do Documento', 40, 25, 310, 20, 1, 'E', 100);

-- C - Campo Tipo (ComboBox)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, VareCamp, VagrCamp)
VALUES (210, 'TIPOTPDO', 'Tipo', 'Tipo do Documento', 95, 25, 150, 30, 1, 'C', 100,
'Dinheiro
Duplicata
Boleto
Cheque
Crédito em Conta
Débito em Conta
DOC/TED
Expedição
Cartão Crédito
Cartão Débito
Nota de Débito
Ordem de Pagamento',
'DI
DU
BO
CH
CR
DE
DT
EX
CC
CD
ND
OP');

-- N - Campo Ordem (Numérico)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp)
VALUES (210, 'ORDETPDO', 'Ordem', 'Ordem', 95, 185, 150, 40, 1, 'N', 100, ',0;-,0');

-- S - Campo Ativo (Checkbox)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (210, 'ATIVTPDO', 'Ativo', 'Tipo de Documento Ativo', 150, 25, 150, 50, 1, 'S', 100);

-- C - Campo Disponível no SAGMob (ComboBox)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, VareCamp, VagrCamp)
VALUES (210, 'PDA_TPDO', 'Disponível no SAGMob', 'Disponível no SAGMob', 150, 185, 150, 60, 1, 'C', 100,
'Sim
Não',
'1
0');

-- BVL - Caixa 02
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, FormCamp)
VALUES (210, 'CAIXCA02', '-', 'Caixa 02', 205, 10, 340, 70, 1, 'BVL', 65, '1');

-- S - Campo Bloqueio Comercial
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp)
VALUES (210, 'BLCOTPDO', 'Bloqueio Comercial', 'Bloqueio Comercial', 230, 25, 150, 80, 1, 'S', 40, ',0;-,0');

-- S - Campo Bloqueio Financeiro
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (210, 'BLFITPDO', 'Bloqueio Financeiro', 'Bloqueio Financeiro', 230, 185, 150, 90, 1, 'S', 40);

-- BVL - Caixa 03
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, FormCamp)
VALUES (210, 'CAIXCA03', '-', '-', 285, 10, 340, 100, 1, 'BVL', 65, '1');

-- S - Campo Reg. 1601 (SPED Fiscal)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (210, 'SF16TPDO', 'Reg. 1601 (SPED Fiscal)', 'Inclui no Reg. 1601 - Operações com instrumentos de pagamentos eletrônicos do SPED Fiscal os pagamentos lançados com esse tipo', 310, 25, 150, 110, 1, 'S', 40);


-- =====================================================
-- DADOS DA TABELA 514 (Parâmetros de Estoque)
-- GUIACAMP=1: Dados Gerais
-- GUIACAMP=2: Dados Adicionais
-- =====================================================

-- GUIA 1 - Tolerância Contrato (BVL)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp, LbcxCamp)
VALUES (514, 'CA01PARA', 'Tolerância Contrato', 'Caixa', 15, 10, 660, 10, 1, 'BVL', 65, ',0;-,0', 1);

-- EC - Campo Tolerância Contrato (Combo fixo sem label)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, VareCamp, VagrCamp)
VALUES (514, 'CONTPARA', NULL, 'Tolerância Contrato', 40, 25, 150, 20, 1, 'EC', 100,
'Não Validar
Avisar
Bloquear',
'NAO
AVISAR
BLOQUEAR');

-- GUIA 1 - Entradas e Entrada Pedido de Compra (BVL)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp, LbcxCamp)
VALUES (514, 'CA02PARA', 'Entradas e Entrada Pedido de Compra', 'Caixa', 95, 10, 660, 25, 1, 'BVL', 395, ',0;-,0', 1);

-- ES - Separa Custos por Mov. de Estoque
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'SEPAMVCX', 'Separa Custos por Mov. de Estoque', 'Separa Custos por Mov. de Estoque', 120, 25, 310, 40, 1, 'ES', 100);

-- ES - Oculta Informação do Estoque no Inventário
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'ESTOINVE', 'Oculta Informação do Estoque no Inventário', 'Oculta Informação do Estoque no Inventário', 120, 345, 310, 45, 1, 'ES', 100);

-- ES - Libera Bloqueio de Valor na Entrada de Moeda Diferente
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'LIMOENPE', 'Libera Bloqueio de Valor na Entrada de Moeda Diferente', 'Libera Valor na Entrada de Moeda Diferente', 175, 25, 310, 50, 1, 'ES', 100);

-- ES - Não Sugerir atualizar NCM do produto
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'ATUANCM_', 'Não Sugerir atualizar NCM do produto', 'Não Sugerir atualizar NCM quando for divergente do informado pelo forncedor no XML', 175, 345, 310, 53, 1, 'ES', 100);

-- ES - Valida Preenchimento de CFOP, Natureza, CST, ICMS, IPI, PIS e COFINS
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'VLPRIMPO', 'Valida Preenchimento de CFOP, Natureza, CST, ICMS, IPI, PIS e COFINS', 'Valida Preenchimento de CST, ICMS, IPI, PIS e COFINS. (Também verifica o preenchimento do campo CFOP e Natureza)', 230, 25, 470, 55, 1, 'ES', 100);

-- ES - Valida Chave da NF-e
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'VLCH_NFE', 'Valida Chave da NF-e', 'Valida Chave da NF-e', 285, 25, 310, 60, 1, 'ES', 100);

-- ES - Obrigatoriedade Chave NF-e
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp)
VALUES (514, 'OBCH_NFE', 'Obrigatoriedade Chave NF-e', 'Obrigatoriedade Chave NF-e', 340, 25, 310, 63, 1, 'ES', 100, ',0.00;-,0.00');

-- ES - Análise Laboratorial
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'ANLBPARA', 'Análise Laboratorial', 'Análise Laboratorial', 395, 25, 310, 65, 1, 'ES', 100);

-- ES - Libera Pessoa ISSQN
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'VLPSSISS', 'Libera Pessoa ISSQN', 'Libera pessoa ISSQN', 450, 25, 310, 67, 1, 'ES', 100);


-- =====================================================
-- GUIA 2 - Dados Adicionais (Parâmetros de Estoque)
-- =====================================================

-- BVL - Custo de Produção
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, LbcxCamp)
VALUES (514, 'CA03PARA', 'Custo de Produção', 'Caixa', 15, 10, 340, 69, 2, 'BVL', 120, 1);

-- IT - Tipo de Mov. Entrada de Produção (Lookup)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp, SqlCamp)
VALUES (514, 'TPMVCUPR', 'Tipo de Mov. Entrada de Produção', 'Tipo de Mov. Entrada de Produção', 40, 25, 282, 70, 2, 'IT', 100, ',0;-,0',
'SELECT POCATPMV.CODITPMV, POCATPMV.NOMETPMV
FROM POCATPMV LEFT JOIN POCATPDO ON POCATPDO.CODITPDO = POCATPMV.CODITPDO
WHERE (POCATPMV.ATIVTPMV = 1) AND (POCATPMV.LOCATPMV = ''E'') AND (POCATPMV.DESCTPMV = ''E'')
ORDER BY POCATPMV.NOMETPMV');

-- BVL - Grupos de Usuário
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, LbcxCamp)
VALUES (514, 'CA04PARA', 'Grupos de Usuário p/', 'Caixa', 15, 360, 340, 75, 2, 'BVL', 120, 1);

-- IT - Movimentar Estoque Retroativo (Lookup)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp, SqlCamp)
VALUES (514, 'PE_MV_ES', 'Movimentar Estoque Retroativo', 'Grupo de Usuários que podem Movimentar Estoque Retroativo', 40, 375, 282, 100, 2, 'IT', 100, ',0;-,0',
'SELECT POCAGRUS.CODIGRUS, POCAGRUS.NOMEGRUS
FROM POCAGRUS
WHERE (POCAGRUS.ATIVGRUS = 1)
ORDER BY POCAGRUS.NOMEGRUS');

-- ES - Configurar por Pessoa
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'ESPEESTO', 'Configurar por Pessoa', 'Configurar por Pessoa: Quando marcado, permite cadastrar a pessoa que irá poder Movimentar Estoque Retroativo através do botão Configurar', 95, 375, 150, 105, 2, 'ES', 40);

-- BTN - Botão Configurar
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, MascCamp)
VALUES (514, 'ESPEGRPE', 'Configura', 'Configurar individualmente os usuários que podem Movimentar Estoque Retroativo', 95, 535, 150, 106, 2, 'BTN', 21, '131');

-- BVL - Nota Fiscal
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, LbcxCamp)
VALUES (514, 'CA05PARA', 'Nota Fiscal', 'Caixa', 150, 10, 690, 109, 2, 'BVL', 175, 1);

-- ES - Baixar Estoque na Geração da Nota
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'GEESEMIS', 'Baixar Estoque na Geração da Nota', 'Baixar estoque na geração da nota', 175, 25, 310, 120, 2, 'ES', 100);

-- ES - Usa Tipo Movimento Devolução no Caso de Integrado
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'USTPMVDV', 'Usa Tipo Movimento Devolução no Caso de Integrado', 'Caso esta opção esteja marcado quando for realizar uma entrada o Tipo Movimento será de Devolução', 175, 345, 310, 130, 2, 'ES', 100);

-- ES - Filtra Ramo Ativ./Plano de Contas
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'FILTRAPL', 'Filtra Ramo Ativ./Plano de Contas', 'Filtra Ramo Ativ./Plano de Contas', 230, 25, 310, 140, 2, 'ES', 100);

-- ES - Realizar a operação de Manifesto de Recebimento
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'OBRIGAMANIFESTO', 'Realizar a operação de Manifesto de Recebimento', 'Realizar a operação de Manifesto de Recebimento', 230, 345, 310, 142, 2, 'ES', 40);

-- ES - Inativar Contrato Zerado
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'INATCONT', 'Inativar Contrato Zerado', 'Inativar Contrato Zerado', 285, 25, 310, 143, 2, 'ES', 40);

-- ES - Não Faz Retenção de PIS e COFINS
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'RETPISCO', 'Não Faz Retenção de PIS e COFINS', 'Não Faz Retenção de PIS e COFINS', 285, 345, 310, 144, 2, 'ES', 40);

-- BVL - Industrialização
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, LbcxCamp)
VALUES (514, 'CA06PARA', 'Industrialização', 'Caixa', 340, 10, 690, 145, 2, 'BVL', 65, 1);

-- ES - Filtrar Apenas Produtos Não Acabados
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'FILTACAB', 'Filtrar Apenas Produtos Não Acabados', 'Não irá mostrar produtos acabados na tela da industrialização', 365, 25, 310, 151, 2, 'ES', 100);

-- BVL - Importação de NFe
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, LbcxCamp)
VALUES (514, 'CAIMPARA', 'Importação de NFe', 'Importação de NFe', 420, 10, 690, 200, 2, 'BVL', 65, 1);

-- ES - Filtrar ao abrir Tela - Importação NFe(Padrão)
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp)
VALUES (514, 'FIABNFIN', 'Filtrar ao abrir Tela - Importação NFe(Padrão)', 'Filtrar ao abrir Tela - Importação NFe(Padrão)', 445, 25, 310, 210, 2, 'ES', 40);

-- EC - Tipo Competência (Parcelas) - Combo fixo
INSERT INTO SistCamp (CodiTabe, NomeCamp, LabeCamp, HintCamp, TopoCamp, EsquCamp, TamaCamp, OrdeCamp, GuiaCamp, CompCamp, AltuCamp, VareCamp, VagrCamp)
VALUES (514, 'TPCOMVFI', 'Tipo Competência (Parcelas)', 'Tipo Competência (Parcelas)', 445, 345, 310, 220, 2, 'EC', 40,
'Vencimento
Emissão
Recebimento',
'V
E
R');

-- Confirmar inserções
SELECT 'Total de registros inseridos: ' || COUNT(*) FROM SistCamp;
SELECT 'Tabela 210: ' || COUNT(*) || ' campos' FROM SistCamp WHERE CodiTabe = 210;
SELECT 'Tabela 514: ' || COUNT(*) || ' campos' FROM SistCamp WHERE CodiTabe = 514;
SELECT 'Tabela 514 Guia 1: ' || COUNT(*) || ' campos' FROM SistCamp WHERE CodiTabe = 514 AND GuiaCamp = 1;
SELECT 'Tabela 514 Guia 2: ' || COUNT(*) || ' campos' FROM SistCamp WHERE CodiTabe = 514 AND GuiaCamp = 2;
