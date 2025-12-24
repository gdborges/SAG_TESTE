INSERT INTO SISTTABE (CODITABE, NOMETABE, FORMTABE, CAPTTABE, HINTTABE, GRAVTABE, CHAVTABE, BOT1TABE, BOT2TABE, BOT3TABE, ULTITABE, CONSTABE, MENUTABE, ORDETABE, SISTTABE, ALTUTABE, TAMATABE, CABETABE, SUB_TABE, PAOKTABE, MEPETABE, CLICTABE, TPGRTABE, EDITTABE, OK__TABE, CLONTABE, GUI1TABE, GUI2TABE, FIXOTABE, ULNUTABE, ULDATABE, SIGLTABE, APATTABE, PARATABE, ATCATABE, ID__TABE, SGCHTABE, SGTBTABE, STAMTABE, SALTTABE, SFIXTABE, AJUDTABE, GRIDTABE
) VALUES ('210', 'Tipo Documento', 'TFRMPOHECAM6', 'Tipo Documento', 'Manutenção de Tipo Documento', 'POCATPDO', '1', '0', '0', '0', '210000', '0', 'MNUPOCATPDO', '296', 'S09S25S75 S74S55', '421', '475', '0', '0', '0', '1', 'ClicMan2', '0', '0', '10', '0', '&Dados Gerais', 'Dados &Adicionais', '0', '30', '28/09/2021 15:23:02', 'TPDO', '0', '{"campColu":1,"campTama":1,"btnIncl":true,"btnAlte":true,"btnExcl":true,"btnGraf":true,"btnEspe":true,"btnBI":true,"btnLanc":false,"imagem":0,"campColuMobi":2,"campTamaMobi":150}', 'Tipo Documento', '0', '210', '15010', '475', '420', '0', '', 'SELECT POCATPDO.CODITPDO, POCATPDO.NOMETPDO AS "Nome", POCATPDO.TIPOTPDO AS "Tipo"'
)
--EXEC

INSERT INTO SISTTABE (CODITABE, NOMETABE, FORMTABE, CAPTTABE, HINTTABE, GRAVTABE, CHAVTABE, BOT1TABE, BOT2TABE, BOT3TABE, ULTITABE, CONSTABE, MENUTABE, ORDETABE, SISTTABE, ALTUTABE, TAMATABE, CABETABE, SUB_TABE, PAOKTABE, MEPETABE, CLICTABE, TPGRTABE, EDITTABE, OK__TABE, CLONTABE, GUI1TABE, GUI2TABE, FIXOTABE, ULNUTABE, ULDATABE, SIGLTABE, APATTABE, PARATABE, VERSTABE, ATCATABE, ID__TABE, SGCHTABE, STAMTABE, SALTTABE, SFIXTABE
) VALUES ('514', 'Parâm. Estoque', 'TFRMPOHECAM6', 'Parâm. Estoque', 'Manutenção de Parâm. Estoque', 'MPCAPARA', '1', '0', '0', '0', '0', '0', 'MNUESCAPARA', '2430', 'S08S06S20', '555', '825', '0', '1', '0', '1', 'ClicModaAces', '0', '0', '10', '0', '&Dados Gerais', 'Dados &Adicionais', '0', '58', '27/07/2021 16:12:28', 'PARA', '0', '{"campColu":4,"campTama":150,"btnIncl":true,"btnAlte":true,"btnExcl":true,"btnGraf":true,"btnEspe":true,"btnBI":true,"btnLanc":false,"imagem":0,"linkBI":"","linkAjudSAG":"","linkAjudPrat":"","linkBI__Mobi":"","linkAjudAgen":"","campColuMobi":1,"campTamaMobi":1}', '7.1.05.247', 'Parâm. Estoque', '0', '514', '826', '558', '0'
)
--EXEC

INSERT INTO SISTCONS ( CODICONS, CODITABE, NOMECONS, ACCECONS, SERVCONS, ULNUCONS, ULDACONS, SQL_CONS, BUSCCONS, APATCONS, ATIVCONS, FILTCONS, ID__CONS, SAG_CONS, SGCHCONS
) VALUES ('210000', '210', 'Padrão', '1', '1', '228', '13/03/2023 10:37:18', 'SELECT POCATPDO.CODITPDO, POCATPDO.NOMETPDO AS "Nome", (CASE POCATPDO.TIPOTPDO WHEN ''DI'' THEN ''DI - Dinheiro'' WHEN ''DU'' THEN ''DU - Duplicata'' WHEN ''BO'' THEN ''BO - Boleto'' WHEN ''CH'' THEN ''CH - Cheque'' WHEN ''CR'' THEN ''CR - Crédito em Conta'' WHEN ''DE'' THEN ''DE - Débito em Conta'' WHEN ''DT'' THEN ''DT - DOC/TED'' WHEN ''EX'' THEN ''EX - Expedição'' WHEN ''CC'' THEN ''CC - Cartão Crédito'' WHEN ''CD'' THEN ''CD - Cartão Débito'' WHEN ''ND'' THEN ''ND - Nota de Débito'' WHEN ''OP'' THEN ''OP - Ordem de Pagamento'' ELSE POCATPDO.TIPOTPDO END) AS "Tipo", POCATPDO.ORDETPDO AS "Ordem", FUN_LOGI(POCATPDO.ATIVTPDO) AS "Ativo", FUN_LOGI(POCATPDO.BLCOTPDO) AS "Bloqueio Comercial", FUN_LOGI(POCATPDO.BLFITPDO) AS "Bloqueio Financeiro", FUN_LOGI(POCATPDO.SF16TPDO) AS "Reg. 1601 (SPED Fiscal)", POCATPDO.CODITPDO AS "Código"
FROM POCATPDO


WHERE (POCATPDO.ATIVTPDO = 1)
ORDER BY POCATPDO.ORDETPDO, POCATPDO.NOMETPDO
', 'TPDO000-Padrão', '4', '1', '[COLUNAS]
Tipo=/Tama=200
Ativo=/Tama=50
Bloqueio Comercial=/Tama=90
Bloqueio Financeiro=/Tama=90
Reg. 1601 (SPED Fiscal)=/Tama=90
', '0', '210000', '210000'
)
--EXEC

