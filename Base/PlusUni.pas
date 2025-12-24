{$DEFINE ERPUNI_FRAME}
unit PlusUni;

{$if Defined(SAGLIB) or Defined(LIBUNI)}
 Não pode ser usado no SAGLib ou  LibUni
{$endif}

interface

Uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs, DB, ComCtrls, ADODB, sgTypes,
  LstLbl, sgClientDataSet, DBImgLbl, LcbLbl, POGeAgCa, sgForm, sgPnl, sgQuery, Func, sgTbs, POFrCaMv, POFrGrMv, POFrSeri_D,
  {$IFDEF ERPUNI}
    uniGUIClasses, sgCompUnig, UniGuiForm,
  {$ELSE}
    sgComPort, idTelNet, ACBrBAL, CPort,
  {$ENDIF}
  sgClass, POChRela_D, FireDAC.Stan.Option, FireDAC.Stan.Param;

const
  cFiltPessSenh = '(POGePess.AtivPess <> 0) AND (POGePess.UsuaPess <> 0) AND (COPY(POGePess.PCodPess,02,02) <> ''99'')';

type
  TModeloXML = (mxNormal, mxSimulador);
  TBuscDia_Util = (duAnte, duProx);
  TStringArray = array of string;
  TColorWinControl = class({$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif});
  TsgSenhModoCons = (mcTota, mcProd, mcUnion);

  TsgSenh = class(TCustomSgSenh)
  private
    FWherPers: String;
    FModoConsulta: TsgSenhModoCons;
    function GetSQL_Num1: String;
    function GetSQL_Nume: String;
    function GetNum1ContReal: Integer;
    function GetNumeContReal: Integer;
    function GetSQL_AcesUsua(iWher: String = ''): String;
    function GetDataAcesGrav: TDateTime;
    function GetDataValiGrav: TDateTime;
    function GetNumeAcesGrav: Integer;
    function GetNum1ContGrav: Integer;
    function GetNumeContGrav: Integer;
    function GetNumeSeriGrav: String;
    function GetTipoContGrav: String;
    procedure SetDataAcesGrav(const Value: TDateTime);
    procedure SetDataValiGrav(const Value: TDateTime);
    procedure SetNum1ContGrav(const Value: Integer);
    procedure SetNumeAcesGrav(const Value: Integer);
    procedure SetNumeContGrav(const Value: Integer);
    procedure SetNumeSeriGrav(const Value: String);
    procedure SetTipoContGrav(const Value: String);
    function GetDataVeriNumeGrav: TDateTime;
    procedure SetDataVeriNumeGrav(const Value: TDateTime);
    function GetDataVencNumeGrav: TDateTime;
    procedure SetDataVencNumeGrav(const Value: TDateTime);
  public
    constructor Create(); override;
    function ValiCont(iMens: Boolean = True; iGeral: Boolean = False): Boolean; override;
    function GeraContra(iMens: Boolean=True): String; override;

    procedure GravaControles;
    function ValidaModulo: Boolean;
    function ValidaModuloReal: Boolean;
    function DataSenh_FormToDate(iData: String): TDateTime;
    function SenhModu_Todo: String;

    property WherPers: String read FWherPers write FWherPers;
    property SQL_Nume: String read GetSQL_Nume;
    property SQL_Num1: String read GetSQL_Num1;
    property NumeContReal: Integer read GetNumeContReal;
    property Num1ContReal: Integer read GetNum1ContReal;

    property DataAcesGrav: TDateTime read GetDataAcesGrav write SetDataAcesGrav;
    property NumeSeriGrav: String    read GetNumeSeriGrav write SetNumeSeriGrav;
    property DataValiGrav: TDateTime read GetDataValiGrav write SetDataValiGrav;
    property TipoContGrav: String    read GetTipoContGrav write SetTipoContGrav;
    property NumeContGrav: Integer   read GetNumeContGrav write SetNumeContGrav;
    property Num1ContGrav: Integer   read GetNum1ContGrav write SetNum1ContGrav;
    property NumeAcesGrav: Integer   read GetNumeAcesGrav write SetNumeAcesGrav;
    property DataVeriNumeGrav: TDateTime read GetDataVeriNumeGrav write SetDataVeriNumeGrav;
    property DataVencNumeGrav: TDateTime read GetDataVencNumeGrav write SetDataVencNumeGrav;
    property ModoConsulta: TsgSenhModoCons read FModoConsulta write FModoConsulta;
  end;

  function GetsgSenh(): TsgSenh;

type
  TMovi = class
  private
    fTbsMovi: TsgTbs;
    fFraCaMv: TFraCaMv;
    fCodiTabe: Integer;
    fSeriTabe: Integer;
    fGeTaTabe: Integer;
    function GetFraMovi: TFraGrMv;
    function GetPnlResu: TsgPnl;
    function GetPnlMovi: TsgPnl;
    function GetCodiTabe: Integer;
  public
    destructor Destroy; override;
    property CodiTabe: Integer read GetCodiTabe write fCodiTabe;
    property GeTaTabe: Integer read fGeTaTabe write fGeTaTabe;
    property SeriTabe: Integer read fSeriTabe write fSeriTabe;   //TabeIndex
    property TbsMovi: TsgTbs read fTbsMovi write fTbsMovi;
    property FraCaMv: TFraCaMv read fFraCaMv write fFraCaMv;

    property FraMovi: TFraGrMv read GetFraMovi;
    property PnlResu: TsgPnl read GetPnlResu;
    property PnlMovi: TsgPnl read GetPnlMovi;
  end;

  //******************************************************************************************
  //************* M E N U   P E R S O N A L I Z A D O  ***************************************
  procedure MontCampPers(CodiTabe: Integer; Tag_Obri: Integer; iForm: TsgForm;
                         DataSour: TDataSource;
                         MudaTab2, MudaTab3, ClicGrav: TKeyPressEvent;
                         Habi, ClicBota, iExecExit: TNotifyEvent;
                         Pnl1, Pnl2, Pnl3: TsgPnl;
                         ArruTama: TDataSetNotifyEvent;
                         DeleCons, ClicObs: TKeyEvent;
                         var PrimGui1, PrimGui2, PrimGui3: {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif};
                         Guia: Integer; TeclCons: TKeyEvent;
                         DuplClic: TNotifyEvent;
                         ListChecColumnClick: TLVColumnClickEvent;
                         ClicBusc: TNotifyEvent = nil
                         );
  function CampPers_BuscSQL(iForm: TsgForm; const iSQL: String): String;
  function CampPers_TratExec(iForm: TsgForm; Valo, Pers: String): String;
  function WS_ExecPLSAG(iForm: TsgForm; iPL: String): sgCustomActionResult;
  Function SubsCampPers(iForm: TsgForm; Inst: String; TipoInfo: String = 'VALO'):String;
  Procedure CampPersInicGravPara(iForm: TsgForm; CodiTabe: Integer; Gera, Inic: Boolean);
  Procedure InicValoCampPers(iForm: TsgForm; CodiTabe: Integer; DataSour: TDataSource; Inse: Boolean);
  function CampPersRetoExecOutrCamp(Exec, Chav: String): String;
  procedure CampPersExecExit(iForm: TsgForm; Sender: TObject; ExecShow: Boolean = False);
  function CampPersRetoListExec(iForm: TsgForm; Sender: TObject): String;
  Function CampPersExecListInst(iForm: TsgForm; List: TStrings; const iComp: TObject = nil): Boolean;
  Function CampPersCompAtuaGetProp(iForm: TsgForm; Comp: TObject; Prop: String): Variant;
  function CampPersExecDireStri(iForm: TsgForm; Valo, Pers: String; const iComp: TObject = nil): Boolean;
  procedure CampPersDuplCliq(iForm: TsgForm; Sender: TObject; ExecShow: Boolean = False);
  Procedure CampPersExecExitShow(iForm: TsgForm; CodiTabe: Integer);
  function CampPersValiExecLinh(Linh: String): Boolean;
  function CampPersExec(Inst: String): Variant;
  Function CampPers_ExecData(Inst: String): TDateTime;
  function CampPers_ChamTelaDire(iForm: TsgForm; Quer: TsgQuery; Cham: String; Inst: String): Boolean;
  Function ClicPast(Form, Camp, Sele: String; Quer: TsgQuery):Boolean;
  procedure CampPersAcao(iForm: TsgForm; Inst, Acao: String);
  Function CampPers_ExecLinhStri(Inst, Camp: String): String;
  Function CampPers_EX(iForm: TsgForm; Camp, Linh: String): Boolean;
  Function CampPers_OB(iForm: TsgForm; Camp, Linh: String; iAcao: String = ''): Boolean;
  Function CampPers_OD(iForm: TsgForm; iLinh: String): String;
  Function CampPers_EP(iForm: TsgForm; Camp, Linh: String): Boolean;
  Function CampPers_TR(iForm: TsgForm; Camp, Linh: String): Boolean;
  Function CampPers_ConfWeb(iForm: TsgForm; Camp, Linh: String): Boolean;
  Function CampPers_CompCamp_Tipo(Comp: String): String;
  Function CampPersCompAtua(iForm: TsgForm; Tipo, Camp: String): TObject;
  procedure CampPersListChecColumnClick(Sender: TObject; Column: TListColumn);
  procedure CampPersExecNoOnShow(iForm: TsgForm; List: String; VeriAces: Boolean = False; WherCampMovi: String = '');
  function CampPers_BuscModi(iForm: TsgForm; DataSet: TDataSet; Tabe: String): Boolean;
  procedure CampPers_CriaBtn_LancCont(iForm: TsgForm);

  Function VeriEnviConf(iForm: TsgForm; Inst: String):Boolean;
  Function ConfGrav(iForm: TsgForm = nil; Tabe: Integer=0):Boolean;
  procedure RecaDadoGera(iExibMens: Boolean = True);

  function ListCampPOCaRela(iTipo: String = 'TODOS'): String;
  Function ChamRela(iQryRela, iQrySQL: TsgQuery; iTipoExib: Integer; iConf:String=''; iCodiRela: Integer=0; iForm: TsgForm = nil):String;
  Function ChamRelaEspe(iForm: TsgForm; iQryRela: TsgQuery; iTipoExib: Integer; iConf:String=''; iCodiRela: Integer=0):String;
  Function ChamRelaUnig(iForm: TsgForm; iQryRela, iQrySQL: TsgQuery; iTipoExib: TTipoExib; iConf:String=''; iCodiRela: Integer=0; isRelaEspe: Boolean = False):String;

  function POCaMvCx_Dist(iForm: TsgForm; iCodiTabe, iCodiMvEs, iCodiPess, iCodiTpMv, iCodiSeto, iCodiTran, iCodiPlan, iCodiCent: Integer;
                         iData: TDateTime; iPermCanc: Boolean = False; iQry: TsgQuery = nil;
                         Tabe: String = 'POCaMvEs'; Camp: String = 'CodiMvEs';
                         Qtde: Real = 0; Debi: Real = 0; Cred: Real = 0;
                         Cons: Boolean = False; iWher: String = '';
                         iCodiProd: Integer = 0): Boolean;
  function POCaMvEs_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil; iDctoVaDe: Boolean = True): Boolean;
  function POCaMvNo_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil; iDctoVaDe: Boolean = True): Boolean;
  function POCaFina_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil): Boolean;
  function POCaCaix_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil): Boolean;
  function POCaUnFi_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil): Boolean;

  function POCaMvND_ChamTela(Form: TsgForm; CodiTabe, CodiMovi, CodiProd: Integer; Qtde, Peso, Valo: Real;
                             CampTabe, ListNota, ListEsto: String; PermCanc: Boolean = False; const iComp: TObject = nil): Boolean;
  Function POCaMvND_Dist(Form: TsgForm; CodiTabe, CodiMovi, CodiProd: Integer;
                         Qtde, QtdeReal, Peso, PesoReal, Valo, ValoReal: Real;
                         CampTabe, ListNota, ListEsto: String;
                         PermCanc: Boolean=False; const iComp: TObject = nil): Boolean;

  procedure Versao_EnviTela(iWher: String; iOwner: String);

  //****************************************************************************************
  //************* M U L T I   B A S E S ****************************************************

  //Editar no SQL Server as Tabelas Pai, passando o Campo Código
  Function EditTabeCabeCamp(Data: TDataSet; QryCabe: TsgQuery; Tabe, Camp: string; Inse: Boolean = True): TDataSet;
  //Editar no SQL Server as Tabelas Pai
  Function EditTabeCabe(Data: TDataSet; QryCabe: TsgQuery; Tabe: string; Inse: Boolean = True): TDataSet;
  Function EditTabeCabeCodi(Data: TDataSet; QryCabe: TsgQuery; Tabe: string; Codi: Integer = 0): TDataSet;


  //********** F I M   D O   M U L T I   B A S E S *****************************************
  //****************************************************************************************


  //Objetivo:Montar uma tela para mensagens com um, dois ou trjs botues
  Function MensConf(Mens,Nom1,Nom2,Nom3:String;Nume,Focu:Byte):Byte;
  Function Cancela: Boolean; overload;
  Function Cancela(FrmPOGeAgCa: TFrmPOGeAgCa): Boolean; overload;
  function ChamModa(Form: String): sgActionResult;
  Function VeriAlteSenhVenc(Data: TDateTime): sgActionResult;

  //******************************************************************************************
  //*************             A C E S S O S             **************************************

  //Objetivo: Verifica se o Usuário tem acesso a Empresa
  function VeriAcesEmpr(CodiEmpr: Integer):Boolean;
  //Objetivo: Verifica se o Usuário tem acesso ao Módulo
  function VeriAcesModu(CodiProd: Integer):Boolean;
  //Carrega os Produtos que o Usuário tem Acesso
  Function CarrAcesModu(QryProd: TSgQuery; LcbProd: TLcbLbl; Usua, Empr, Sist, GrUs: Integer): Integer;
  //Retorna uma string com os acessos do Usuário para essa tabela
  function VeriAcesTabeTota(Tabe: Integer; iTipoClic: TTipoClic = tcClicManu): String;
  //---> Verifica se o Usuário tem acesso na Tabela TABE usando a opção OPCA
  function VeriAcesTabe(Tabe: Integer; Opca: Byte; iTipoClic: TTipoClic = tcClicManu): Boolean;

  //********** F I M   D O S    A C E S S O S                *********************************
  //******************************************************************************************

  //******************************************************************************************
  //*************      M O N I T O R   *******************************************************

  //Limpar o Monitor dos querys do DtmPoul
  Procedure LimpMoniDataModu();
  //Limpar o Monitor dos querys do DtmPoul e Demais
  Procedure LimpMoniGera(iForm: TsgForm);
  //Fechar os Querys da Tela Fechada e Limpa os Monitor do DtmPoul
  Procedure FechQuerTela(iForm: TsgForm);


  //********** F I M   M O N I T O R  **************************************************
  //******************************************************************************************
  Function VeriSexo(Nome:String):Char;
  Function NomeDupl(TextSQL:String;Codi:Integer):Boolean;
  Function SobrNome(Nome:String):String;
  Function TabeVazi(TextSQL:String):Boolean;
  Procedure OrgaSele(Sele: String; iRchSele: TStringList; Iden: Boolean);
  Procedure OrgaFrom(From: String; iRchFrom: TStringList);

  Function ExisUsua(Tabe : String):String;
  function PegaAvia(Lote, Camp: String):String;
  function PegaAvRe(Lote:String):String;
  function PegaInte(Lote:String):String;
  Function MaioIdad(Lote: String; Data: TDateTime):Real;
  function ArreIdadPesa(Idad: Real; iDiarPesa: Boolean): Real;
  Function IdadEnce(CodiLote:String):Real;
  Function IdadLote(ColeLote, Data: TDateTime; PeriIdad: Real = 0):Real;
  Function DataCole(ColeLote: TDateTime; Idad: Real; PeriIdad: Real = 0):TDateTime;

  //Importa arquivo
  function ImpoArqu(Arqu, Tabe, Camp, Fix1, Val1, Fix2, Val2: String): Boolean;
  // Retorna o Percentual de espaço livre no disco rígido
  Function PercLivr(Driv :Byte): Real;
  //---> Gerar Senha para usuário Supervisor dos Sistemas SAG
  Function GeraPega(Data : TDateTime): String;
  //---> Retorna a(s) Granja(s) em que o Funcionários esta Alocado no MPCaTrFu
  Function PessGran(Func: String):String;
 // Retorna a(s) Granja(s) em que o Funcionários esta Alocado na Data Específica
  Function FuncDaGr(Func: String; Data: TDateTime):String;
  //---> Retorna o(s) Incubatórios(s) em que o Funcionários esta Alocado no INCaTrIn
  Function FuncIncu(Func: String):String;
  // Retorna o(s) Incubatórios(s) em que o Funcionário esta Alocado na Data Específica
  Function FuncDaIn(Func: String; Data: TDateTime):String;

  procedure CampCalc(Lote, IdadInic, IdadFina, NomeLote: String; SubI: Integer;
                     Rela, Recr, Prod, Incu, Ence: Boolean;
                     iCodiAloj: Integer = 0;
                     iComp: TObject = nil);
  //===> Mensagem Padrão para o Sair
  Function Sair:Boolean;
  //Pega Sobrenome de um Nome passado
  Function PegaSobr(Nome:String):String;
  //Copiar os Graficos do Lote origem para o destino
  //Precisa-se dos NomeOrig e NomeDest, porque é pelos mesmos que sabe-se qual são os seus gráficos
  procedure TranGraf(NomeOrig, NomeDest, CodiOrig, CodiDest, StanOrig, StanDest:String);
  //Objetivo: Fazer os lançamentos conforme parametrizado dos valores dos custos para
  //          Coleta de dados.
  Procedure AtuaCustCole(CodiLote:String);
  //Objetivo: Fazer os lançamentos conforme parametrizado dos valores da Coleta de Dados para
  //          Movimentos dos Custos.
  Procedure AtuaColeCust(CodiLote:String; DataInic, DataFina: TDateTime; iComp: TObject = nil);
  //Objetivo: Retornar o SQL nos campos totais dos resultados quando a opção for Média Ponderada
  Function SQL_MediPond(Codi:Integer; Lote: String; vProc, Subs:TStringList): String;
  //Objetivo: Substituir os Itens quando a Média Ponderada for por Idade
  Function SQL_MediPondIdad(Codi:Integer; Lote: String; IdadInic, IdadFina: String): String;
  //Objetivo: Substituir os Itens quando a Média Ponderada for por Data
  Function SQL_MediPondData(Codi:Integer; Lote: String; DataInic, DataFina: String): String;
  //Objetivo: Executar o SQL quando a Médio Ponderada for por Idade
  Function MediPondIdad(Codi:Integer; Lote: String; IdadInic, IdadFina: String): Real;
  //Objetivo: Executar o SQL quando a Médio Ponderada for por Data
  Function MediPondData(Codi:Integer; Lote: String; DataInic, DataFina: TDateTime): Real;
  //Pega o valor do parâmetro informado na Coleta. Se não existir na idade passada
  //tenta a última informada e por último no standard.
  function CalcMax_ColeLote(iLote: String): TDateTime;
  Function PegaCole(TabeCole, TabeLote, TabeMvSt, Stan, Lote, Idad, CodiReal, CodiStan: String):Real;
  //Colorir os valores nos relatórios de Itens e Sub-Itens
  Function RetoCor_Item(CodiLote, Item, CodSMvIs, CoAc, CoAb: Integer; Valo, Idad, PeAc, PeAb, ValoStan: Real):Integer;
  //Objetivo: Duplicar o(s) Registro(s) da Tabela passada conforme Where passado
  //Retorna : O valor do primeiro campo do novo registro (Normalmente o Código do Destino)
  //Parâm...: Tabe : Tabela de origeme e destino
  //          Wher : Campos para duplicar (Condição selecionando os campos
  //          MarcNovo: Tipo de marca para os novos campos (NOVO)
  //          Camp : Campo que receberá o ''VALO''
  //          Valo : Valor que será atribuido ao ''CAMP''
  Function DuplRegiTabe(Tabe, Wher, MarcNovo, Camp: string; Valo:Integer; const iComp: TObject = nil):Integer;
  //Colocar a ordem dos campo passado de 10 em 10 conforme Order by (passado no Orde)
  procedure OrdeMovi(Camp, Tabe, Wher, Orde: string; Qry: TsgQuery);
  //Validar se a conta é de Grau 4
  Function ValiCont(Grau:Byte):Boolean;
  //Ordenar o QryPlan conforme o parâmetro, já coloca o ListFieldIndex no Lcb e abre o Qry
  //Regra: O ORDER BY deve estar na Linha 3 (4ª linha)
  Procedure OrdePlan(Lcb:TLcbLbl);
  //Retorna o SQL conforme a Fase passada por parâmetro
  Function RetoSQL_Fase(Recr, Prod, Incu:Boolean):String;
  //Retornar os valor Res0, Res1 ou Res2 conforme o valor de Valo
  Function RetoOpca(Valo:Integer; Res0, Res1, Res2, Res3:String):String;
  //Mudar o nome de um determinado nome de uma tabela, por exemplo NomeAvia para Avia-001, Avia-002, etc...
  Procedure MudaNomeCampTabe(Tabe, Camp, Nome: String);
  //Passado o Número da  Conta, retorna o seu respectivo grau
  Function RetoGrauPlan(NumePlan: String):Integer;
  //Retornar o próximo número do plano de contas
  Function ProxNumePlan(NumePlan: string):String;
  //Caso a idade na Tabela (MPCaCole, MPCaMvSt...) não estiver com uma casa decimal,
  //executa esta rotina para ficar
  Procedure ArreIdadTabe(Tabe, Camp: String);
  //Gravar o Cabeçalho do Gráfico Simples, retornando o Código do Gráfico
  Function GrafCabe(NomeGraf: String):Integer;
  //Gravar as Séries do Gráfico Simples
  Procedure GrafSeri(CodiGraf, Orde, Seri: Integer; Nome, NomX, ValX, ValY, SQL: String; Cor: Integer = 0);
  Function ArruParaEstr(Form: TForm; Quer: TDataSet; Tabe, Inic: String): Boolean;

  //Retorna os Dias do Mês, conforme o Ano (Para o Fevereiro)
  Function DiasMes(Mes: Byte; Ano:Integer):Byte;
  Function VeriDia_Vali(Data: TDateTime; Domi, Segu, Terc, Quar, Quin, Sext, Saba, Feri: Boolean): Boolean;
  Function DifeEntrMes(Mes_Inic, Ano_Inic, Mes_Fina, Ano_Fina: Integer):Integer;
  Function AchaDia_Util(Dia, Mes, Ano: Integer): Integer;
  Function BuscDia_Util(iData: TDateTime; iBusc: TBuscDia_Util = duProx): TDateTime;
  Function ProxDia_Util(iData: TDateTime; iBusc: TBuscDia_Util = duProx): TDateTime;

  //Retorna nas variáveis a faixa do Tipo passado (E,S,R,N)
  procedure FaixTipo(Tipo:string; var ValoInic, ValoFina: Integer);
  //Retornar a quantidade do Produto conforme o Tipo (E, S, R, N)
  Function QtdeProd(CodiProd: Integer; Tipo, Wher, Oper: string; Data: TDateTime):Real;
  //Retornar o valor do Produto
  Function ValoProd(CodiProd: Integer; Tipo, Wher, Oper: string; Data: TDateTime;
                    CodiSeto: Integer = 0; CodiLoPr: Integer = 0;
                    Qry: TsgQuery = nil; iComp: TObject = nil;
                    iCodEProd: Integer = 0):Real;

  Function EstoProd(CodiProd: Integer; Wher, Oper: String; Data: TDateTime;
                    CodiSeto: Integer = 0; CodiLoPr: Integer = 0;
                    Qry: TsgQuery = nil; iComp: TObject = nil;
                    iCodEProd: Integer = 0):Real;
  Function EstoProd_Pedi(CodiProd: Integer; Wher, Oper: String; Data: TDateTime;
                         CodiSeto: Integer = 0; CodiLoPr: Integer = 0;
                         Qry: TsgQuery = nil; iComp: TObject = nil;
                         iCodEProd: Integer = 0):Real;

  Function LibeMovi(Movi:String; Prod:Integer; Qtde, Esto:Real; Data:TDateTime; VeriEsto: Boolean; CodiSeto: Integer = 0; CodiLoPr: Integer = 0; iComp: TObject = nil): SgActionResult;
  //Finalidade: Validar se o produto está previsto no pedido ou não foi carregado além
  //do solicitado Bloqueando, Avisando ou Liberando a continuação
  //da movimentação conforme parâmetro 'PPProdBloqCarr' em POPaProd;
  Function BloqProdCarr(Nome: String; Pedi, Carr, Prod:Integer):Boolean;

  Function Fun_CustProd_Calc(CodiProd: Integer; Data: TDateTime; iCodiSeto: Integer; iAtualiza:Boolean = True; iCustoPronto:Boolean = False;
                             iComp: TObject = nil; GeraCusto: Boolean = False): Real;

  //Validar se uma String é Hora/Data
  Function isTime(Linh: String):Boolean;
  Function isDateTime(Linh: String):Boolean;

  //Atualiza os Custos dos produtos que possuem o produto passado como parâmetro
  //na sua composição.
  Function LancCole(TabeCole: String; CodiCole, CodiLote, CodiMvIS: Integer; Idad, NumeCole: Real; Data: TDateTime; PesqChav: Boolean): Integer;
  //Situação da Requisição ao Almoxarifado
  Function SituRequEsto(Indi: Integer): String;
  //Indice da Situação da Requisição ao Almoxarifado
  Function IndiSituRequEsto(Situ: String): Integer;
  //Gera um código de Barras conforme parâmetros em POPaBarr
  function GeraCodiBarr:String;
  // Retorna a próxima sequência de números de produtos em Códigos de Barras conforme
  // parâmetros em POPaBarr
  function ProxCodiBarr: String;
  // Gera um dígito verificador para o código de barras passado
  function DigiVeriBarr(CodiBarr:String):String;
  //Gravar dados no Conf, Moni e abrir tabelas necessárias para o Acesso
  procedure GravAcesSAG_Mana(EndeConf: string; Data: TDateTime);
  procedure GravAcesSAG_Mana_Empr(Data: TDateTime);
  //Calcula a Última Nota da empresa e série passada, não sendo o CodiNota passado
  function CalcNumeNota(CodiEmpr, CodiNota: Integer; SeriNota, ModeNota: string):Integer;

  function SenhModu_Todo(): String;
  function SenhModu_GeraSenhClie(Opca: Integer; Hora: String): String;
  function SenhModu_ContSenh(OpcaRece, Sist, ValoSenh: Integer; Tipo: String; FinaMvPr: TDateTime; VersSenh: String; Nu01Pess: Integer; ClieSenh: String; PrazSenh: TDateTime):String;
  Function SenhModu_ContSenh_GeraWher(WherModu, VersSenh, ClieSenh: String; OpcaRece: Integer; PrazSenh: TDateTime): String;
  Function DiviContMultSist(Sist: Integer): Integer;
  Function ValiContMultSist(NumeRealPara: String; var NumeRea1, NumeRea2: Real; Sist: Integer=0; NumeLibe: Integer = 0): Boolean;
  Function NumeContMultSist(Sist: Integer; RetoSQL: Boolean; var SQL1, SQL2: String; Wher: String=''): Integer;
  function GetSenh_CalcDigiVeri(Vers: String): Integer;
  function GetSenh_A_ZparaNume(Valo: String): String;
  function GetSenh_NumeparaA_Z(Nume: Integer): String;

  //Calcular a Rastreabilidade Genericamente
  procedure CalcRastGera(TabeRast, SaidRast, EntrRast, QtdeRast: String;
                         SQL_Apag, SQL_Said, SQL_Entr: WideString);
  //Calcular a Rastreabilidade: Buscar a Origem na mesma Tabela (sequencia de processos)
  procedure CalcRast_BuscOrig(TabeOrig, CampPrin, CampOrig, TabeRast: String;
                              CodiPrin: Integer; CodiOrig: Integer = 0; Orde: Integer = 0);
  //Gera um arquivo XML baseado o SQL Enviado
  Function GeraArquXML_SQL(EndeArqu: String; SQL: String; iMode: TModeloXML): Boolean; overload;
  Function GeraArquXML_SQL(EndeArqu: String; SQL: String): Boolean; overload;
  Function ImpoArquXML_(EndeArqu: String; SQL: String): String;

  Function Ex_ManuDado(iForm: TsgForm; Linh: String): Boolean;
  function DataSet_ArraList(Dts: TDataSet; var ArraList: TStringArray; Chav: Boolean = False): Boolean;
  function DataSet_FormValoCamp_Stri(Dts: TDataSet; Camp: String): String;

  Procedure CompAtuaTabeGravRegi(Orig, Dest: TADOQuery; CampInic: Byte; Fina, CompMenuTabe: String; AtuaTudo: Boolean); overload;
  Procedure CompAtuaTabeGravRegi(Orig, Dest: TsgQuery;  CampInic: Byte; Fina, CompMenuTabe: String; AtuaTudo: Boolean); overload;
  Procedure CompAtuaTabeGravRegi(Orig: TADOQuery; Dest: TsgQuery; CampInic: Byte; Fina, CompMenuTabe:String; AtuaTudo: Boolean); overload;

  function ConvCampParaFigu(Qry: TsgQuery; Camp: String): TDBImgLbl;
  function ConvCampParaBMP_(Qry: TsgQuery; Camp: String): TBitMap;
  procedure AbreQuerBookMark(Qry: TsgQuery; Contr: Boolean = True);

  //Tirar problema com barras quando se tem o diretorio e adiciona o Arquivo
  function ArquValiEnde(iEnde: String; iCriaDire: Boolean = True): String;

  function ArquZipa(const iEnde: String; const iDest: String = ''): String;
  function ArquDes_Zipa(const iEnde: String; const iDest: String=''; const iSubs: Boolean=False): Boolean;

  procedure POHeForm_AtuaCria(iForm: TsgForm; Fech: Boolean = True);

  procedure AbreWebBrowser(iURL: String);

  procedure Trad_Componente_Form(iForm: TComponent; const iCodiTabe: Integer = 0);
  procedure Trad_Componente(iComp: TComponent; iCodiTabe: Integer = 0; iNomeCompPrin: String = '');
  Function Trad_Combo(iCodiTabe: Integer; iNameCamp: String): String;

  function ValiSenhDia(): Boolean;
  function ValiSenhDia_Teste(): Boolean;
  Function CriaAlteUsua(Usua, Senh: String; iConn: TObject=nil):Boolean;

  procedure FSXXImNF_ProcessarNotas(Prot: String; Arqu: String='');
  function  FSXXImNF_BuscarNotas(Linh: String): Boolean;

var
  FsgSenh : TsgSenh;

implementation

Uses POGeAgua, Funcoes, DmPoul, INPlus, DmPlus, FuncPlus, RAPlus, sgConsts, DmImag, System.Threading, sgConstsMsg,
     MPPlus, Proc, Trig, sgTim, TePlus, SCPlus, POGeConf, sgLbl, sgBvl, sgRgb, FiPlus,
     sgBtn, DBLcbLbl, DBEdtLbl, DBRxELbl, DBRxDLbl, EdtLbl, ImgLbl, DateUtils,
     DBCmbLbl, DBChkLbl, ChkLbl, DBFilLbl, FilLbl, DirLbl, DBRchLbl, DbMemLbl,
     RxDatLbl, DBAdvMemLbl, MemLbl, CmbLbl, sgDBG, sgPgc, AdvMemLbl, StdCtrls, EnviMail, shellapi, CLPlus,
     RxEdtLbl, sgProgBar, TradConsts, WSPlus, Log, sgRadioButton, sgGroupBox,
     //precisa ser "sgFormModal ," para ocorrer o replace correto
     sgFormModal , sgStyles,
     ACBrDevice, ACBrValidador, ACBrETQ, ACBrETQClass, sgDBRgb, sgTreeList, sgFormStorage,
     {$IFDEF ERPUNI_MODAL}
       NFeV20Modal, PlusUni ,
     {$ELSE}
       NFeV20, PlusUniModal,
     {$ENDIF}

     {$IFDEF ERPUNI}
       uniGUITypes, uniDBLookupHelper, uniGuiFont, uniGUIApplication, uniLabel, UniPageControl,
       uniPanel, UniRadioGroup, uniMainMenu, UniDBComboBox, UniComboBox, UniDBRadioGroup, UniGroupBox, UniRadioButton,
       {$ifndef LIBUNI}
         ServerModule,
       {$ENDIF}
     {$ELSE}
       FSPlus, cxGridCustomView, cxGridTableView, cxGridDBTableView, cxGridCustomTableView, QRCtrls, QuickRpt, Mask,
       DmEsti, PlusERP, POGeCons, cxListView, Menus, DBCtrls, cxLookAndFeels, uLkJSON, RxPlacemnt,
       TFlatComboBoxUnit,TFlatCheckBoxUnit, TFlatGaugeUnit, TFlatRadioButtonUnit, TFlatGroupBoxUnit,
     {$ENDIF}
     {$ifndef LIBUNI}
       POHeForm, POChGrid, POCaMvCx, POCaMvC2,
     {$ENDIF}
     {$ifdef SAGSINC}
       dmRemo,
     {$ENDIF}
     {$ifdef WS}
      Winapi.ActiveX,
     {$ENDIF}
     POGeCon2, RelaPlus, BancView, BancFunc, DBClient, COPlus, sgUtil, POCaMvND, POHeGer6,
     TradNamed, DBLookNume, DBLookText, sgPop, DBIniMemo, ExtCtrls, MaskUtils, SysUtils, XMLDoc, XMLIntf, RchLbl,
     sgArquivo, Variants, System.UITypes, POChWebB, sgPrinDecorator, StrUtils, POChSenh, CampJSon, POFrGraf, sgRTTI,
     System.IOUtils, POGeNota_D, POGeFina_D, System.Math, Soap.XSBuiltIns, System.Types, System.Zip,
     Trad;


//******************************************************************************************
//************* M E N U   P E R S O N A L I Z A D O  ***************************************
//Tipo de Componente
//1 - E - Edit
//2 - C - Combo
//3 - S - SimNão
//4 - D - Data
//5 - N - Número
//6 - T - Tabela
//7 - M - Memorando (M - BM - BF)
//8 - R - RichEdit (RB - RF)
//9 - L - Calculado
//Montar Campos Personalizados
procedure MontCampPers(CodiTabe: Integer; Tag_Obri: Integer; iForm: TsgForm;
                       DataSour: TDataSource;
                       MudaTab2, MudaTab3, ClicGrav: TKeyPressEvent;
                       Habi, ClicBota, iExecExit: TNotifyEvent;
                       Pnl1, Pnl2, Pnl3: TsgPnl;
                       ArruTama: TDataSetNotifyEvent;
                       DeleCons, ClicObs: TKeyEvent;
                       var PrimGui1, PrimGui2, PrimGui3: {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif};
                       Guia: Integer; TeclCons: TKeyEvent;
                       DuplClic: TNotifyEvent;
                       ListChecColumnClick: TLVColumnClickEvent;
                       ClicBusc: TNotifyEvent = nil
                       );
var
  j, l, NumeRegi, TotaRegi : Integer;
  Valo, Auxi: String;
  CompAtua: {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif};
  Pane: TsgPnl;
  Labe: TsgLbl;
  Edit: TDBEdtLbl;
  Comb: TDBCmbLbl;
  Data: TDBRxDLbl;
  Nume: TDBRxELbl;
  CalcEdit: TEdtLbl;
  CalcNume: TRxEdtLbl;
  CalcData: TRxDatLbl;
  CalcComb: TCmbLbl;
  CalcChec: TChkLbl;
  LookNume: TDBLookNume;
  Chec: TDBChkLbl;
  Look: TLcbLbl;
  DBLook: TDBLcbLbl;
  Dts : TDataSource;
  Qry : TsgQuery;
  Bota: TsgBtn;
  Memo: TDBMemLbl;
  AdvMemo: TDBAdvMemLbl;
  Rich: TDBRchLbl;
  Beve: TsgBvl;
  Grid: TsgDBG;
  Graf: TFraGraf;
  Btn : TsgBtn;
  Img : TDBImgLbl;
  ImgF: TImgLbl;
  UltiCamp: TKeyPressEvent;
  EMem: TMemLbl;
  Lst : TLstLbl;
  Pict: TPicture;
  Fil : TFilLbl;
  DBFil : TDBFilLbl;
  Dir : TDirLbl;
  Tbs: TsgTbs;
  Tim: TsgTim;
  BvlLabel : TsgLbl;
  vFontLabe: {$ifdef ERPUNI} TUniFont {$else} TFont {$endif};
  vFontCamp: {$ifdef ERPUNI} TUniFont {$else} TFont {$endif};
  vNomeGuia: array [4..9] of string;
  cds, cdsCont: TClientDataSet;
  vGuiaAnte: Integer;
begin
  if CodiTabe = 0 then Exit;

  with iForm do
  begin
    {$ifdef ERPUNI}
      vFontCamp := TUniFont.Create(iForm);
      vFontLabe := TUniFont.Create(iForm);
    {$else}
      vFontCamp := TFont.Create();
      vFontLabe := TFont.Create();
    {$endif}
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    try
      for j := 4 to 9 do
        vNomeGuia[j] := '';

      cds := DtmPoul.Campos_Cds(CodiTabe, '', '(NameCamp > ''GUI'') AND (NameCamp < ''GUI99'')');
      while not cds.Eof do
      begin
        if IsDigit(Copy(cds.FieldByName('NameCamp').AsString,04,01)) then
          vNomeGuia[StrToInt(Copy(cds.FieldByName('NameCamp').AsString,04,01))] := CampPers_TratNome(cds.FieldByName('LabeCamp').AsString);

        cds.Next;
      end;
      cds.Close;
      FreeAndNil(cds);

      cds := DtmPoul.Campos_Cds(CodiTabe, '', '(ExisCamp = 0)');
      if Tag_Obri = 50 then
      begin
        cds.IndexFieldNames := 'GuiaCamp;OrdeCamp';
        Guia := 0; //Forçar entrar para contar campos
      end
      else
        cds.IndexFieldNames := 'OrdeCamp'; //Quando for movimento, não importa ordenar por guia

      if not cds.IsEmpty then
      begin
        NumeRegi := 1;
        UltiCamp := nil;
        PrimGui1 := nil;
        PrimGui2 := nil;
        PrimGui3 := nil;
        TotaRegi := 0;

        cds.First;
        vGuiaAnte := -98989;
        Pane := nil;
        while not(cds.Eof) do
        begin
          //SetPLblAjud_Capt(cds.FieldByName('NameCamp').AsString);
          if Tag_Obri <> 50 then  //Campos movimento, nunca mudam de tab, portanto clicgrav=clicenvi
          begin
            if TotaRegi = 0 then
            begin
              cdsCont := DtmPoul.Campos_Cds(CodiTabe, '', ' (ExisCamp = 0) '+
                                                          'AND (OrdeCamp <> 9999) '+
                                                          'AND (CompCamp <> ''LN'') '+
                                                          'AND (CompCamp <> ''LE'') '+
                                                          'AND (CompCamp <> ''BVL'') '+
                                                          'AND (CompCamp <> ''IN'') '+
                                                          'AND (CompCamp <> ''IE'') '+
                                                          'AND (CompCamp <> ''IM'') '+
                                                          'AND (CompCamp <> ''IR'') '+
                                                          'AND (CompCamp <> ''LBL'') '+
                                                          'AND (CompCamp <> ''BTN'') '+
                                                          'AND (CompCamp <> ''DBG'') '+
                                                          'AND (CompCamp <> ''GRA'') '+
                                                          'AND (CompCamp <> ''FI'') '+
                                                          'AND (CompCamp <> ''FF'') '+
                                                          'AND (CompCamp <> ''TIM'')');
              TotaRegi := cdsCont.RecordCount;
              UltiCamp := ClicGrav;
            end;
          end
          else
          begin
            if Guia <> cds.FieldByName('GuiaCamp').AsInteger then
            begin
              Guia := cds.FieldByName('GuiaCamp').AsInteger;

              NumeRegi := 1;

              cdsCont := DtmPoul.Campos_Cds(CodiTabe, '', '(ExisCamp = 0) '+
                                                          'AND (GuiaCamp = '+IntToStr(Guia)+')'+
                                                          'AND (OrdeCamp <> 9999) '+
                                                          'AND (CompCamp <> ''LN'') '+
                                                          'AND (CompCamp <> ''LE'') '+
                                                          'AND (CompCamp <> ''BVL'') '+
                                                          'AND (CompCamp <> ''IN'') '+
                                                          'AND (CompCamp <> ''IE'') '+
                                                          'AND (CompCamp <> ''IM'') '+
                                                          'AND (CompCamp <> ''IR'') '+
                                                          'AND (CompCamp <> ''LBL'') '+
                                                          'AND (CompCamp <> ''BTN'') '+
                                                          'AND (CompCamp <> ''DBG'') '+
                                                          'AND (CompCamp <> ''GRA'') '+
                                                          'AND (CompCamp <> ''FI'') '+
                                                          'AND (CompCamp <> ''FF'') '+
                                                          'AND (CompCamp <> ''TIM'')');
              TotaRegi := cdsCont.RecordCount;
              UltiCamp := MudaTab2; //Foi tratado todas as mudanças de Tab no MudaTab2 (POHeCamp)
            end;
          end;

          if vGuiaAnte <> Guia then
          begin
            vGuiaAnte := Guia;
            Pane := nil;
            //Guias
            if Guia = 99 then
              Pane := TsgPnl(FindComponent('PnlPers'))
            else if NumeroInRange(Guia, 21, 23) then
              Pane := TsgPnl(FindComponent('PnlRes'+IntToStr(Guia-20)))
            else if Guia >= 10 then
              Pane := Pnl3  //PnlMovi
            else if Guia = 3 then
              Pane := Pnl3
            else if Guia = 2 then
              Pane := Pnl2
            else if Guia = 1 then
              Pane := Pnl1;

            if not Assigned(Pane) then
            begin
              Pane := TsgPnl(BuscaComponente('Pnl'+ZeroEsqu(IntToStr(Guia),02,False)));
              if Pane = nil then
              begin
                Tbs := TsgTbs.Create(iForm);
                Tbs.PageControl := TsgPgc(FindComponent('PgcGene'));
                Tbs.Name    := 'Tbs'+ZeroEsqu(IntToStr(Guia),02,False);
                if (Guia in [4..9]) and (vNomeGuia[Guia] <> '') then
                  Tbs.Caption := vNomeGuia[Guia]
                else if Guia = 99 then
                  Tbs.Caption := '&'+resMnuPers_Caption
                else
                  Tbs.Caption := CampPers_TratNome('&'+IntToStr(Guia)+'. '+resTbsDado_Caption);

                if (Guia - 1) > (Tbs.PageControl.PageCount-1) then
                  Tbs.PageIndex := Tbs.PageControl.PageCount-1
                else
                  Tbs.PageIndex := Guia - 1;

                Pane := TsgPnl.Create(iForm);
                Pane.Name   := 'Pnl'+ZeroEsqu(IntToStr(Guia),02,False);
                Pane.Caption:= '';
                Pane.Align  := alClient;
                Pane.BevelOuter := bvNone;
                Pane.AutoScroll := True;
                Pane.Parent := Tbs;
              end;
            end;

            if Pane = nil then
              Pane := Pnl1;
            Pane.Visible := True;
          end;

          CompAtua := nil;

          vFontCamp.Name  := cds.FieldByName('CFonCamp').AsString;
          vFontCamp.Size  := cds.FieldByName('CTamCamp').AsInteger;
          vFontCamp.Color := cds.FieldByName('CCorCamp').AsInteger;
          if cds.FieldByName('CEstCamp').AsInteger = 0 then  //Normal
            vFontCamp.Style := []
          else if cds.FieldByName('CEstCamp').AsInteger = 1 then  //Negrito
            vFontCamp.Style := [fsBold]
          else if cds.FieldByName('CEstCamp').AsInteger = 2 then  //Itálico
            vFontCamp.Style := [fsItalic]
          else                                                  //Negrito/Italico
            vFontCamp.Style := [fsBold,fsItalic];
          if cds.FieldByName('CEfeCamp').AsInteger = 2 then  //Sublinhado
            vFontCamp.Style := vFontCamp.Style+[fsUnderline]
          else if cds.FieldByName('CEfeCamp').AsInteger = 3 then  //Riscado
            vFontCamp.Style := vFontCamp.Style+[fsStrikeOut]
          else  if cds.FieldByName('CEfeCamp').AsInteger = 1 then  //Riscado e Sublinhado
            vFontCamp.Style := vFontCamp.Style+[fsUnderline,fsStrikeOut]; //Senão não é nada

          vFontLabe.Name  := cds.FieldByName('LFonCamp').AsString;
          vFontLabe.Size  := cds.FieldByName('LTamCamp').AsInteger;
          vFontLabe.Color := cds.FieldByName('LCorCamp').AsInteger;
          if cds.FieldByName('LEstCamp').AsInteger = 0 then  //Normal
            vFontLabe.Style := []
          else if cds.FieldByName('LEstCamp').AsInteger = 1 then  //Negrito
            vFontLabe.Style := [fsBold]
          else if cds.FieldByName('LEstCamp').AsInteger = 2 then  //Itálico
            vFontLabe.Style := [fsItalic]
          else                                                  //Negrito/Italico
            vFontLabe.Style := [fsBold,fsItalic];
          if cds.FieldByName('LEfeCamp').AsInteger = 2 then  //Sublinhado
            vFontLabe.Style := vFontLabe.Style+[fsUnderline]
          else if cds.FieldByName('LEfeCamp').AsInteger = 3 then  //Riscado
            vFontLabe.Style := vFontLabe.Style+[fsStrikeOut]
          else  if cds.FieldByName('LEfeCamp').AsInteger = 1 then  //Riscado e Sublinhado
            vFontLabe.Style := vFontLabe.Style+[fsUnderline,fsStrikeOut]; //Senão não é nada

          if not StrIn(cds.FieldByName('CompCamp').AsString, ['DBG', 'GRA', 'S', 'BVL', 'BTN', 'FI', 'FF', 'FE', 'ES', 'LC', 'TIM']) then
          begin
            Labe := TsgLbl.Create(iForm);
            Labe.Name       := 'Lbl'+cds.FieldByName('NameCamp').AsString;
            Labe.Left       := cds.FieldByName('EsquCamp').AsInteger;
            Labe.Top        := cds.FieldByName('TopoCamp').AsInteger - 13;
            Labe.Caption    := cds.FieldByName('LabeCamp').AsString;
            Labe.Transparent:= True;
            //Fonte
            Labe.Font.Assign(vFontLabe);
            Labe.Parent     := Pane;
          end
          else
            Labe := nil;

          //*******************************************************************
          //NÃO FAZ O CONFIRMA/ENVIA, NAO RECEBE FOCUS
          if StrIn(cds.FieldByName('CompCamp').AsString, ['DBG', 'GRA', 'LE', 'LN', 'BVL', 'LBL', 'IE', 'IM', 'IR', 'IN', 'BTN', 'FI', 'FF', 'TIM']) OR
             (cds.FieldByName('OrdeCamp').AsInteger = 9999)then
            Dec(NumeRegi);

          //************************************************************************************
          //E d i t o r
          if (cds.FieldByName('CompCamp').AsString = 'E') then  //CE
          begin
            Edit := TDBEdtLbl.Create(iForm);
            CompAtua := Edit;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            Edit.DataField  := cds.FieldByName('NomeCamp').AsString;
            Edit.DataSource := DataSour;
            Edit.OnExit     := iExecExit;
            Edit.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            if cds.FieldByName('MascCamp').AsString = '*' then
              Edit.PasswordChar := '*';

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Edit.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              Edit.OnChange := Habi;

            Edit.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Edit.sgConf.OnHabi      := Habi;

            Edit.LblAssoc := Labe;
            Edit.Numero   := Guia;

            Edit.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //C o m b o
          else if (cds.FieldByName('CompCamp').AsString = 'C') then  //CC
          begin
            Comb     := TDBCmbLbl.Create(iForm);
            Comb.Parent     := Pane;
            CompAtua := Comb;
            Comb.Name:= 'Cmb'+cds.FieldByName('NameCamp').AsString;

            Comb.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Comb.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              Comb.OnChange := Habi;

            Comb.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Comb.sgConf.OnHabi        := Habi;

            //** EXTRAS ***
            Comb.LblAssoc   := Labe;
            Comb.sgStyle    := csDropDownList;
            Comb.Values.Text:= cds.FieldByName('VaGrCamp').AsString;
            if GetCodiIdio() > 0 then
            begin
              Comb.Items.Text := Trad_Combo(CodiTabe, cds.FieldByName('NameCamp').AsString);
              if Comb.Items.Text = '' then
                Comb.Items.Text := cds.FieldByName('VaReCamp').AsString;
            end
            else
              Comb.Items.Text := cds.FieldByName('VaReCamp').AsString;
            Comb.Numero   := Guia;
            if cds.FieldByName('DropCamp').AsInteger > cds.FieldByName('TamaCamp').AsInteger then
              Comb.DropDownWidth := cds.FieldByName('DropCamp').AsInteger;

            //Coloca aqui depois dos Values e Items que não estava carregando o valor na combo quando alterando
            Comb.DataField  := cds.FieldByName('NomeCamp').AsString;
            Comb.DataSource := DataSour;

            Comb.Font.Assign(vFontCamp);

            {$ifdef ERPUNI}
              Comb.OnExit   := iExecExit;
            {$else}
              Comb.OnClick    := iExecExit;
            {$endif}
          end
          //************************************************************************************
          //E d i t o r - Arquivo
          else if (cds.FieldByName('CompCamp').AsString = 'A') then   //CA
          begin
            DBFil := TDBFilLbl.Create(iForm);
            CompAtua := DBFil;
            CompAtua.Name   := 'Fil'+cds.FieldByName('NameCamp').AsString;

            DBFil.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            DBFil.CampArqu   := cds.FieldByName('MascCamp').AsString;
            DBFil.DataField  := cds.FieldByName('NomeCamp').AsString;
            DBFil.DataSource := DataSour;

            {$ifdef ERPUNI}
            {$else}
              DBFil.OnExit     := iExecExit;

              //Último - Confirma
              if NumeRegi = TotaRegi then
                DBFil.OnKeyPress := UltiCamp;

              //Obrigatório
                if cds.FieldByName('ObriCamp').Value <> 0 then
                  DBFil.OnChange := Habi;
            {$endif}

            DBFil.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            DBFil.sgConf.OnHabi        := Habi;

            DBFil.LblAssoc := Labe;
            DBFil.Numero   := Guia;


            {$ifdef ERPUNI}
              DBFil.Caption := Labe.Caption;
            {$else}
              DBFil.Hint     := sgLn + '(F2 - Abre Arquivo)';
              DBFil.Font.Assign(vFontCamp);
            {$endif}
          end
          //************************************************************************************
          //N ú m e r o
          else if (cds.FieldByName('CompCamp').AsString = 'N') then   //CN
          begin
            Nume := TDBRxELbl.Create(iForm);
            CompAtua := Nume;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            Nume.DataField  := cds.FieldByName('NomeCamp').AsString;
            Nume.DataSource := DataSour;
            Nume.OnExit     := iExecExit;
            Nume.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Nume.OnKeyPress := UltiCamp;

            //Obrigatório
            Nume.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Nume.sgConf.OnHabi      := Habi;
            if Nume.sgConf.Obrigatorio then
              Nume.OnChange := Habi;

            Nume.LblAssoc   := Labe;
            {$ifdef ERPUNI}
              Nume.DecimalPrecision  := cds.FieldByName('DeciCamp').AsInteger;
              Nume.DecimalSeparator  := ',';
              Nume.ThousandSeparator := '.';
            {$else}
              Nume.DecimalPlaces   := cds.FieldByName('DeciCamp').AsInteger;
              if cds.FieldByName('MascCamp').AsString <> '' then
                Nume.DisplayFormat   := RetoMasc(cds.FieldByName('MascCamp').AsString);
            {$endif}

            if (cds.FieldByName('InicCamp').AsInteger = 1) AND (cds.FieldByName('TagQCamp').AsInteger = 1) then
            begin
              Nume.TabStop  := False;
              Nume.ReadOnly := True;
              Nume.sgConf.Style := stlInformativo;
              Nume.ButtonWidth  := 0;
            end
            else
            begin
              Nume.MinValue := cds.FieldByName('MiniCamp').AsFloat;
              Nume.MaxValue := cds.FieldByName('MaxiCamp').AsFloat;
            end;
            Nume.Numero   := Guia;

            Nume.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //T a b e l a
          else if (cds.FieldByName('CompCamp').AsString = 'T') or       //IT
                  (cds.FieldByName('CompCamp').AsString = 'IT') then
          begin
            if (cds.FieldByName('CompCamp').AsString = 'T') then
            begin
              Look := TDBLcbLbl.Create(iForm);
              Look.DataField  := cds.FieldByName('NomeCamp').AsString;
              Look.DataSource := DataSour;
            end
            else
              Look := TLcbLbl.Create(iForm);
            CompAtua := Look;
            CompAtua.Name   := 'Lcb'+cds.FieldByName('NameCamp').AsString;
            Bota := TsgBtn.Create(iForm);

            {$ifdef ERPUNI}
              Look.GridMode    := lgmPostKeyValue;
              Look.ListOnlyMode:= lmNoFollow;
              //Look.Mode := umNameValue;
              Look.RemoteQueryDelay:= 0;
              Look.OnExit  := iExecExit;
            {$else}
              Look.OnClick := iExecExit;
            {$endif}
            Look.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            Look.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Look.sgConf.OnHabi        := Habi;

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Look.OnKeyPress := UltiCamp;

            //** EXTRAS ***
            //Botão - Btn
            if cds.FieldByName('CodTTabe').AsInteger <> 0 then
            begin
              Bota.Name   := 'Btn'+cds.FieldByName('NameCamp').AsString;
              Bota.Hint   := 'Clique para Cadastrar ou Exportar';
              Bota.Flat   := True;
              Bota.CodTTabe := cds.FieldByName('CodTTabe').AsInteger;
              //Bota.Caption:= DtmPoul.Tabelas_Busc('MenuTabe', '(CodiTabe = '+IntToStr(cds.FieldByName('CodTTabe').AsInteger)+')');
              {$ifdef ERPUNI}
                Bota.IconCls := 'search';
                Bota.OnClick:= ClicBusc;
              {$else}
                Bota.Colors.Hot     := clWhite;
                Bota.Colors.Pressed := clWhite;
                Bota.OnClick:= ClicBota;
              {$endif}
              //Bota.Margin := 5;
              //Bota.Width  := 25;
              //Bota.Height := 19;
              //Bota.sgBotaCons := True;
              if cds.FieldByName('ObriCamp').AsInteger <> 0 then
                Look.OnKeyDown    := TeclCons
              else
                Look.OnKeyDown    := DeleCons;
              Look.BtnAssoc     := Bota;
              Bota.Parent := Pane;
            end;

            //Query
            Qry := TsgQuery.Create(iForm);
            Qry.sgConnection := GetPADOConn;
            Qry.Name := 'Qry'+cds.FieldByName('NameCamp').AsString;
            Qry.AfterOpen := ArruTama;
            Qry.Tag      := cds.FieldByName('TagQCamp').AsInteger;
            Qry.SQL_Back.Text := CampPers_BuscSQL(iForm, cds.FieldByName('SQL_Camp').AsString);
            Qry.SQL.Text      := SubsCampPers(iForm, Qry.SQL_Back.Text);
            Qry.Coluna.Text   := cds.FieldByName('GrCoCamp').AsString;
            if cds.FieldByName('DeciCamp').AsInteger = 1 then
              Qry.sgConnection := sgTransaction;

            {$ifdef ERPUNI}  //Se o codi não estiver nos primeiros 50, não traz na alteração
              Qry.FetchOptions.Mode := fmAll;
              Look.RemoteFilter := False;
            {$else}
              //Desabilita na Alteração
              if TestDataSet(DataSour) then
              begin
                if (cds.FieldByName('DesaCamp').AsInteger <> 0) and (DataSour.DataSet.State = dsEdit) then
                begin
                  Qry.SQL.Strings[2] := '';
                  Qry.SQL.Strings[3] := '';
                  if VeriExisCampTabe(DataSour.DataSet, cds.FieldByName('NomeCamp').AsString) then
                    Qry.SQL.Strings[4] := 'WHERE ('+PegaCampManuGene(Qry.SQL.Strings[0], 01)+' = '+
                                            QuotedStr(RetoZero(DataSour.DataSet.FieldByName(cds.FieldByName('NomeCamp').AsString).AsString))+')'
                  else
                    Qry.SQL.Strings[4] := 'WHERE ('+PegaCampManuGene(Qry.SQL.Strings[0], 01)+' = ''0'')';
                  Bota.Enabled       := False;
                  Qry.Tag := 0;
                end;
              end;
            {$endif}

            //Sidi: Para não dar problema, mas o correto é ficar desativado, para todos
            {$ifndef DATASNAP}
              Qry.SQL.Text := SubsCampPers(iForm, Qry.SQL.Text);
              Qry.Open;
              Look.KeyField     := Qry.Fields[0].FieldName;
//              {$ifdef ERPUNI}  //Se o codi não estiver nos primeiros 50, não traz na alteração
//                Look.ListField    := Qry.Fields[1].FieldName;
//              {$else}
                Valo := '';
                for j := 2 to Qry.Fields.Count - 1 do
                  if J <= 6 then
                    Valo := Valo + ';'+Qry.Fields[J].FieldName;
                Look.ListField    := Qry.Fields[1].FieldName + Valo;
//              {$endif}
            {$else}
              Look.KeyField     := PegaNomeCampSele(Qry.SQL.Strings[0], 01, False);
              Valo := '';
              for j := 3 to 7 do
              begin
                Auxi := PegaNomeCampSele(Qry.SQL.Strings[0], j, False);
                if Auxi <> '' then
                  Valo := Valo + ';'+Auxi;
              end;
              Look.ListField    := PegaNomeCampSele(Qry.SQL.Strings[0], 02, False) + Valo;
            {$endif}
            //ListSource
            Dts := TDataSource.Create(iForm);
            Dts.Name := 'Dts'+cds.FieldByName('NameCamp').AsString;
            Dts.DataSet := Qry;

            //LcbLbl
            Look.LblAssoc     := Labe;
            if cds.FieldByName('DropCamp').AsInteger > cds.FieldByName('TamaCamp').AsInteger then
              Look.DropDownWidth:= cds.FieldByName('DropCamp').AsInteger;
            Look.ListSource   := Dts;

            Look.ListFieldIndex:=cds.FieldByName('PesqCamp').AsInteger;
            Look.Numero       := Guia;


            {$ifdef ERPUNI}  //Se o codi não estiver nos primeiros 50, não traz na alteração
              //Fonte
              Look.Font.Name  := cds.FieldByName('CFonCamp').AsString;
              Look.Font.Size  := cds.FieldByName('CTamCamp').AsInteger;
              Look.Font.Color := cds.FieldByName('CCorCamp').AsInteger;
              if cds.FieldByName('CEstCamp').AsInteger = 0 then  //Normal
                Look.Font.Style := []
              else if cds.FieldByName('CEstCamp').AsInteger = 1 then  //Negrito
                Look.Font.Style := [fsBold]
              else if cds.FieldByName('CEstCamp').AsInteger = 2 then  //Itálico
                Look.Font.Style := [fsItalic]
              else                                                  //Negrito/Italico
                Look.Font.Style := [fsBold,fsItalic];
              if cds.FieldByName('CEfeCamp').AsInteger = 2 then  //Sublinhado
                Look.Font.Style := Look.Font.Style+[fsUnderline]
              else if cds.FieldByName('CEfeCamp').AsInteger = 3 then  //Riscado
                Look.Font.Style := Look.Font.Style+[fsStrikeOut]
              else  if cds.FieldByName('CEfeCamp').AsInteger = 1 then  //Riscado e Sublinhado
                Look.Font.Style := Look.Font.Style+[fsUnderline,fsStrikeOut]; //Senão não é nada
            {$else}
              Look.Font.Assign(vFontCamp);
//              Look.Style.LookAndFeel.NativeStyle := False;
//              Look.Style.LookAndFeel.Kind := lfUltraFlat;
//              Look.Style.BorderStyle := ebsUltraFlat;
            {$endif}
            Look.Parent     := Pane;
          end
          //************************************************************************************
          //Campo Busca (lookup)
          else if (cds.FieldByName('CompCamp').AsString = 'L') or      //IL
                  (cds.FieldByName('CompCamp').AsString = 'IL') then
          begin
            LookNume := TDBLookNume.Create(iForm);
            LookNume.OnExit     := iExecExit;
            LookNume.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            //Último - Confirma
            if NumeRegi = TotaRegi then
              LookNume.OnKeyPress := UltiCamp;
            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
            begin
              LookNume.OnChange := Habi;
              LookNume.Obrigatorio := True;
            end;
            LookNume.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            LookNume.sgConf.OnHabi        := Habi;

            LookNume.Width         := {$ifdef ERPUNI} 60 {$else} 43 {$ENDIF};
            LookNume.WidthOriginal := cds.FieldByName('TamaCamp').AsInteger;

            LookNume.LblAssoc     := Labe;
            LookNume.Numero       := Guia;
            LookNume.OnKeyDown    := TeclCons;

            CompAtua := LookNume;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            LookNume.ExibeBotao := cds.FieldByName('LbCxCamp').AsInteger <> 0;
            LookNume.CodTTabe   := cds.FieldByName('CodTTabe').AsInteger;
            LookNume.CriaComp   := True;

            LookNume.BtnLook.CodTTabe := cds.FieldByName('CodTTabe').AsInteger;
            LookNume.BtnLook.OnClick  := ClicBusc;

            LookNume.DataLook  := cds.FieldByName('EstiCamp').AsString;
            LookNume.ListField := cds.FieldByName('FormCamp').AsString;

            //LookNume.Qry.Tag      := cds.FieldByName('TagQCamp').AsInteger;
            LookNume.Qry.Tag      := 10;  //Abre só pelo componente
            LookNume.Qry.SQL.Text := SubsCampPers(iForm, CampPers_BuscSQL(iForm, cds.FieldByName('SQL_Camp').AsString));
            if LookNume.Qry.SQL.Count > 2 then
            begin
              if Pos('WHERE',AnsiUpperCase(LookNume.Qry.SQL.Strings[2])) > 0 then
                LookNume.Qry.SQL.Strings[3] := 'AND ('+LookNume.DataLook+' = 0)'
              else
                LookNume.Qry.SQL.Strings[3] := 'WHERE ('+LookNume.DataLook+' = 0)';
            end;
            LookNume.Qry.SQL_Back.Text := LookNume.Qry.SQL.Text;
            LookNume.Qry.Coluna.Text   := cds.FieldByName('GrCoCamp').AsString;
            if cds.FieldByName('DeciCamp').AsInteger = 1 then
              LookNume.Qry.sgConnection := sgTransaction;
            //LookNume.DataLook   := cds.FieldByName('NomeCamp').AsString;
            //if (LookNume.Qry.SQL.Count > 0) and (cds.FieldByName('PesqCamp').AsInteger > 0) then
            //if (LookNume.Qry.SQL.Count > 0) then
            //begin
            //  LookNume.DataLook := PegaCampManuGene(LookNume.Qry.SQL.Strings[0],SeInte(cds.FieldByName('PesqCamp').AsInteger=0,1,cds.FieldByName('PesqCamp').AsInteger));
            //end;
            LookNume.Font.Assign(vFontCamp);

            //Fica no final para já ter o KeyField, ncessário no DataChange, quando é um campo ligado, para trazer a informação quando alterando (ocorreu na tela 21510)
            if cds.FieldByName('CompCamp').AsString = 'L' then
            begin
              LookNume.DataField  := cds.FieldByName('NomeCamp').AsString;
              LookNume.DataSource := DataSour;
            end;
          end
          //************************************************************************************
          //D a t a
          else if (cds.FieldByName('CompCamp').AsString = 'D') then    //CD
          begin
            Data := TDBRxDLbl.Create(iForm);
            Data.Parent     := Pane;
            CompAtua := Data;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            Data.DataField  := cds.FieldByName('NomeCamp').AsString;
            Data.DataSource := DataSour;
            Data.OnExit     := iExecExit;
            Data.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            Data.DataEntr   := Date;

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Data.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              Data.OnChange := Habi;
            Data.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Data.sgConf.OnHabi        := Habi;

            //** EXTRAS ***
            Data.LblAssoc   := Labe;
            Data.Numero   := Guia;

            Data.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //S i m   /   N ã o
          else if (cds.FieldByName('CompCamp').AsString = 'S') then   //CS
          begin
            Chec := TDBChkLbl.Create(iForm);
            Chec.Parent  := Pane;
            CompAtua     := Chec;
            CompAtua.Name:= 'Chk'+cds.FieldByName('NameCamp').AsString;

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Chec.OnKeyPress := UltiCamp;

            //** EXTRAS ***
            //Primeiro Campo
            case Guia of
              1 : if PrimGui1 = nil then PrimGui1 := Chec;
              2 : if PrimGui2 = nil then PrimGui2 := Chec;
              3 : if PrimGui3 = nil then PrimGui3 := Chec;
              11 : if PrimGui3 = nil then PrimGui3 := Chec;
              12 : if PrimGui3 = nil then PrimGui3 := Chec;
            end;

            Chec.Caption        := cds.FieldByName('LabeCamp').AsString;
            Chec.ValueChecked   := '1';
            Chec.ValueUnchecked := '0';
            Chec.Numero   := Guia;

            //if (cds.FieldByName('AltuCamp').AsInteger <> 100) then
            //  Chec.Height := cds.FieldByName('AltuCamp').AsInteger;

            Chec.DataField  := cds.FieldByName('NomeCamp').AsString;
            Chec.DataSource := DataSour;
            Chec.OnClick    := iExecExit;
            Chec.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            Chec.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //M E M O
          else if (cds.FieldByName('CompCamp').AsString = 'M') or        //CM
                  (cds.FieldByName('CompCamp').AsString = 'BM') then
          begin
            Memo := TDBMemLbl.Create(iForm);
            Memo.Parent     := Pane;   //No Inicio por causa do Lines
            CompAtua := Memo;
            CompAtua.Name   := 'Mem'+cds.FieldByName('NameCamp').AsString;

            Memo.DataField  := cds.FieldByName('NomeCamp').AsString;
            Memo.DataSource := DataSour;
            Memo.OnExit     := iExecExit;
            Memo.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Memo.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              Memo.OnChange := Habi;
            Memo.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Memo.sgConf.OnHabi        := Habi;


            //** EXTRAS ***
            Memo.LblAssoc     := Labe;
            if cds.FieldByName('InteCamp').AsInteger <> 0 then
            begin
              {$ifdef ERPUNI}
              {$else}
                Memo.ScrollBars := ssVertical;
              {$endif}
              Memo.WordWrap   := True;
            end
            else
            begin
              {$ifdef ERPUNI}
              {$else}
                Memo.ScrollBars := ssBoth;
              {$endif}
              Memo.WordWrap   := False;
            end;
            Memo.Hint       := Memo.Hint + sgLn + 'F2 = Editor e F3 = Gerenciador de Observação';
            Memo.OnKeyDown  := ClicObs;
            Memo.Height     := cds.FieldByName('AltuCamp').AsInteger;
            Memo.Numero   := Guia;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Labe.Visible := False;
              Memo.Align := alClient;
              Memo.AlignWithMargins := True;
              Memo.Margins.Top   := 10;
              Memo.Margins.Bottom:= 10;
              Memo.Margins.Left  := 10;
              Memo.Margins.Right := 10;
            end;

            Memo.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //M E M O   A D V
          else if (cds.FieldByName('CompCamp').AsString = 'BS') or    //BS
                  (cds.FieldByName('CompCamp').AsString = 'BE') or
                  (cds.FieldByName('CompCamp').AsString = 'BI') or
                  (cds.FieldByName('CompCamp').AsString = 'BP') or
                  (cds.FieldByName('CompCamp').AsString = 'BX') or
                  (cds.FieldByName('CompCamp').AsString = 'RS') or
                  (cds.FieldByName('CompCamp').AsString = 'RE') or
                  (cds.FieldByName('CompCamp').AsString = 'RI') or
                  (cds.FieldByName('CompCamp').AsString = 'RP') or
                  (cds.FieldByName('CompCamp').AsString = 'RX') then
          begin
            AdvMemo := TDBAdvMemLbl.Create(iForm);
            AdvMemo.Parent     := Pane;
            CompAtua := AdvMemo;
            CompAtua.Name   := 'Mem'+cds.FieldByName('NameCamp').AsString;

            if Copy(cds.FieldByName('CompCamp').AsString,01,01) = 'B' then  //Gravado - Blob
            begin
              AdvMemo.DataField  := cds.FieldByName('NomeCamp').AsString;
              AdvMemo.DataSource := DataSour;
            end;
            AdvMemo.OnExit     := iExecExit;
            AdvMemo.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              AdvMemo.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              AdvMemo.OnChange := Habi;
            AdvMemo.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            AdvMemo.sgConf.OnHabi        := Habi;


            //** EXTRAS ***
            AdvMemo.LblAssoc     := Labe;
            {$ifdef ERPUNI}
            {$else}
              if cds.FieldByName('InteCamp').AsInteger <> 0 then
                AdvMemo.ScrollBars := ssVertical
              else
                AdvMemo.ScrollBars := ssBoth;
            {$endif}
            //AdvMemo.Hint       := AdvMemo.Hint + sgLn + 'F2 = Editor e F3 = Gerenciador de Observação';
            AdvMemo.OnKeyDown  := ClicObs;
            AdvMemo.Height     := cds.FieldByName('AltuCamp').AsInteger;
            AdvMemo.Numero   := Guia;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Labe.Visible := False;
              AdvMemo.Align := alClient;
              AdvMemo.AlignWithMargins := True;
              AdvMemo.Margins.Top   := 10;
              AdvMemo.Margins.Bottom:= 10;
              AdvMemo.Margins.Left  := 10;
              AdvMemo.Margins.Right := 10;
            end;

            {$ifdef ERPUNI}
            {$else}
              if Copy(cds.FieldByName('CompCamp').AsString,02,01) = 'S' then
                AdvMemo.sgEstilo := DBAdvMemLbl.esSQL
              else if Copy(cds.FieldByName('CompCamp').AsString,02,01) = 'I' then
                AdvMemo.sgEstilo := DBAdvMemLbl.esIni
              else if Copy(cds.FieldByName('CompCamp').AsString,02,01) = 'X' then
                AdvMemo.sgEstilo := DBAdvMemLbl.esXML
              else if Copy(cds.FieldByName('CompCamp').AsString,02,01) = 'P' then
                AdvMemo.sgEstilo := DBAdvMemLbl.esPascal
              else
                AdvMemo.sgEstilo := DBAdvMemLbl.esPLSAG;
            {$endif}

            AdvMemo.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //E D I T O R   M E M O
          else if (cds.FieldByName('CompCamp').AsString = 'ET') then   //ET
          begin
            EMem := TMemLbl.Create(iForm);
            EMem.Parent     := Pane;   //No inicio por causa do Lines
            CompAtua := EMem;
            CompAtua.Name   := 'Mem'+cds.FieldByName('NameCamp').AsString;

            EMem.OnExit     := iExecExit;
            EMem.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            EMem.Lines.Clear;

            //Último - Confirma
            if NumeRegi = TotaRegi then
              EMem.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              EMem.OnChange := Habi;
            EMem.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            EMem.sgConf.OnHabi        := Habi;


            //** EXTRAS ***
            EMem.LblAssoc     := Labe;
            if cds.FieldByName('InteCamp').AsInteger <> 0 then
            begin
              {$ifdef ERPUNI}
              {$else}
                EMem.ScrollBars := ssVertical;
              {$endif}
              EMem.WordWrap   := True;
            end
            else
            begin
              {$ifdef ERPUNI}
              {$else}
                EMem.ScrollBars := ssBoth;
              {$endif}
              EMem.WordWrap   := False;
            end;
            EMem.Hint       := EMem.Hint + sgLn + 'F2 = Editor e F3 = Gerenciador de Observação';
            EMem.OnKeyDown  := ClicObs;
            EMem.Height     := cds.FieldByName('AltuCamp').AsInteger;
            EMem.Numero   := Guia;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              EMem.Align := alClient;
              EMem.AlignWithMargins := True;
              EMem.Margins.Top   := 10;
              EMem.Margins.Bottom:= 10;
              EMem.Margins.Left  := 10;
              EMem.Margins.Right := 10;
            end;

            EMem.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //R I C H E D I T
          else if (cds.FieldByName('CompCamp').AsString = 'RM') or     //CR
                  (cds.FieldByName('CompCamp').AsString = 'RB') then
          begin
            Rich := TDBRchLbl.Create(iForm);
            CompAtua := Rich;
            CompAtua.Name   := 'Rch'+cds.FieldByName('NameCamp').AsString;

            Rich.DataField  := cds.FieldByName('NomeCamp').AsString;
            Rich.DataSource := DataSour;
            Rich.OnExit     := iExecExit;
            Rich.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Rich.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              Rich.OnChange := Habi;
            Rich.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Rich.sgConf.OnHabi        := Habi;

            //** EXTRAS ***
            Rich.LblAssoc   := Labe;
            if cds.FieldByName('InteCamp').AsInteger <> 0 then
            begin
              {$ifdef ERPUNI}
              {$else}
                Rich.ScrollBars := ssVertical;
              {$endif}
              Rich.WordWrap   := True;
            end
            else
            begin
              {$ifdef ERPUNI}
              {$else}
                Rich.ScrollBars := ssBoth;
              {$endif}
              Rich.WordWrap   := False;
            end;
            Rich.Hint       := Rich.Hint + sgLn + 'F2 = Editor e F3 = Gerenciador de Observação';
            Rich.OnKeyDown  := ClicObs;
            Rich.Height     := cds.FieldByName('AltuCamp').AsInteger;
            Rich.Numero   := Guia;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Labe.Visible := False;
              Rich.Align := alClient;
              Rich.AlignWithMargins := True;
              Rich.Margins.Top   := 10;
              Rich.Margins.Bottom:= 10;
              Rich.Margins.Left  := 10;
              Rich.Margins.Right := 10;
            end;

            Rich.Font.Assign(vFontCamp);
            Rich.Parent     := Pane;
          end
          //************************************************************************************
          //C a l c u l a d o - Editor
          else if (cds.FieldByName('CompCamp').AsString = 'EE') OR       //EE
                  (cds.FieldByName('CompCamp').AsString = 'LE') then
          begin
            CalcEdit := TEdtLbl.Create(iForm);
            CompAtua := CalcEdit;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;
            if cds.FieldByName('MascCamp').AsString = '*' then
              CalcEdit.PasswordChar := '*'
            else
              CalcEdit.EditMask := RetoMasc(cds.FieldByName('MascCamp').AsString);
            CalcEdit.Name       := 'Edt'+cds.FieldByName('NameCamp').AsString;  //Por causa do Text
            if cds.FieldByName('CompCamp').AsString = 'LE' then
              CalcEdit.OnChange   := iExecExit
            else
            begin
              CalcEdit.OnExit     := iExecExit;

              //Último - Confirma
              if NumeRegi = TotaRegi then
                CalcEdit.OnKeyPress := UltiCamp;

              //Obrigatório
              if cds.FieldByName('ObriCamp').Value <> 0 then
                CalcEdit.OnChange := Habi;
            end;
            CalcEdit.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            CalcEdit.sgConf.OnHabi        := Habi;

            CalcEdit.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            //** EXTRAS ***
            CalcEdit.LblAssoc   := Labe;
            CalcEdit.AutoSize   := True;


            if (cds.FieldByName('CompCamp').AsString = 'LE') then
            begin
              CalcEdit.TabStop         := False;
              CalcEdit.ReadOnly        := True;
              CalcEdit.Color           := clBtnFace;
            end;

            CalcEdit.Text     := '';
            CalcEdit.Numero   := Guia;

            CalcEdit.Font.Assign(vFontCamp);
            CalcEdit.Parent     := Pane;
          end
          //************************************************************************************
          // Editor - Data
          else if (cds.FieldByName('CompCamp').AsString = 'ED') then      //ED
          begin
            CalcData := TRxDatLbl.Create(iForm);
            CompAtua := CalcData;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            CalcData.Name       := 'Edt'+cds.FieldByName('NameCamp').AsString;  //Por causa do Text
            CalcData.OnExit     := iExecExit;
            CalcData.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            //** EXTRAS ***
            {$ifdef ERPUNI}
            {$else}
            {$endif}

            CalcData.LblAssoc   := Labe;
            CalcData.Numero     := Guia;

            //Último - Confirma
            if NumeRegi = TotaRegi then
              CalcData.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              CalcData.OnChange := Habi;
            CalcData.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            CalcData.sgConf.OnHabi        := Habi;

            CalcData.Font.Assign(vFontCamp);
            CalcData.Parent     := Pane;
          end
          //************************************************************************************
          // Editor - Combo
          else if (cds.FieldByName('CompCamp').AsString = 'EC') then        //EC
          begin
            CalcComb := TCmbLbl.Create(iForm);
            CalcComb.Parent     := Pane;
            CompAtua := CalcComb;
            CompAtua.Name   := 'Cmb'+cds.FieldByName('NameCamp').AsString;

            CalcComb.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              CalcComb.OnKeyPress := UltiCamp;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              CalcComb.OnChange := Habi;
            CalcComb.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            CalcComb.sgConf.OnHabi        := Habi;

            //** EXTRAS ***
            CalcComb.LblAssoc   := Labe;
            CalcComb.sgStyle    := csDropDownList;
            CalcComb.Values.Text := cds.FieldByName('VaGrCamp').AsString;
            if GetCodiIdio() > 0 then
            begin
              CalcComb.Items.Text := Trad_Combo(CodiTabe, cds.FieldByName('NameCamp').AsString);
              if CalcComb.Items.Text = '' then
                CalcComb.Items.Text := cds.FieldByName('VaReCamp').AsString;
            end
            else
              CalcComb.Items.Text := cds.FieldByName('VaReCamp').AsString;
            //CalcComb.ItemIndex  := 0;
            CalcComb.Numero     := Guia;
            if cds.FieldByName('DropCamp').AsInteger > cds.FieldByName('TamaCamp').AsInteger then
              CalcComb.DropDownWidth := cds.FieldByName('DropCamp').AsInteger;

            CalcComb.Font.Assign(vFontCamp);

            {$ifdef ERPUNI}
              CalcComb.OnChange   := iExecExit;
            {$else}
              CalcComb.OnClick    := iExecExit;
            {$endif}
          end
          //************************************************************************************
          //Editor - Sim/Não
          else if (cds.FieldByName('CompCamp').AsString = 'ES') then    //ES
          begin
            CalcChec := TChkLbl.Create(iForm);
            CalcChec.Parent:= Pane;
            CompAtua       := CalcChec;
            CompAtua.Name  := 'Chk'+cds.FieldByName('NameCamp').AsString;

            CalcChec.OnClick    := iExecExit;
            CalcChec.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);

            //Último - Confirma
            if NumeRegi = TotaRegi then
              CalcChec.OnKeyPress := UltiCamp;

            //** EXTRAS ***
            //Primeiro Campo
            case Guia of
              1 : if PrimGui1 = nil then PrimGui1 := CalcChec;
              2 : if PrimGui2 = nil then PrimGui2 := CalcChec;
              3 : if PrimGui3 = nil then PrimGui3 := CalcChec;
              11 : if PrimGui3 = nil then PrimGui3 := CalcChec;
              12 : if PrimGui3 = nil then PrimGui3 := CalcChec;
            end;

            CalcChec.Caption  := cds.FieldByName('LabeCamp').AsString;
            CalcChec.Numero   := Guia;

            //if (cds.FieldByName('AltuCamp').AsInteger <> 100) then
            //  CalcChec.Height := cds.FieldByName('AltuCamp').AsInteger;

            CalcChec.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //E d i t o r - Nome Arquivo
          else if (cds.FieldByName('CompCamp').AsString = 'EA') then      //EA
          begin
            Fil := TFilLbl.Create(iForm);
            Fil.Parent     := Pane;
            CompAtua := Fil;
            CompAtua.Name   := 'Fil'+cds.FieldByName('NameCamp').AsString;

            //** EXTRAS ***
            Fil.LblAssoc   := Labe;

            Fil.Text     := '';
            Fil.Hint     := sgLn + '(F2 - Abre Arquivo)';

            Fil.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            Fil.Numero   := Guia;

            {$ifdef ERPUNI}
            {$else}
              Fil.OnExit     := iExecExit;

              //Último - Confirma
              if NumeRegi = TotaRegi then
                Fil.OnKeyPress := UltiCamp;

              //Obrigatório
              if cds.FieldByName('ObriCamp').Value <> 0 then
                Fil.OnChange := Habi;

              Fil.Font.Assign(vFontCamp);
            {$endif}
            Fil.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Fil.sgConf.OnHabi        := Habi;
          end
          //************************************************************************************
          //E d i t o r - Pasta
          else if (cds.FieldByName('CompCamp').AsString = 'EI') then       //EI
          begin
            Dir := TDirLbl.Create(iForm);
            Dir.Parent     := Pane;
            CompAtua := Dir;
            CompAtua.Name   := 'Dir'+cds.FieldByName('NameCamp').AsString;

            Dir.Hint     := sgLn + '(F2 - Abre Arquivo)';
            Dir.Numero   := Guia;

            Dir.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            Dir.LblAssoc   := Labe;

            {$ifdef ERPUNI}
            {$else}
              Dir.OnExit     := iExecExit;

              //Último - Confirma
              if NumeRegi = TotaRegi then
                Dir.OnKeyPress := UltiCamp;

              //Obrigatório
              if cds.FieldByName('ObriCamp').Value <> 0 then
                Dir.OnChange := Habi;

              Dir.Text     := '';

              Dir.Font.Assign(vFontCamp);
            {$endif}
            Dir.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
            Dir.sgConf.OnHabi        := Habi;
          end
          //************************************************************************************
          //C a l c u l a d o - Número
          else if (cds.FieldByName('CompCamp').AsString = 'LN') or           //EN
                  (cds.FieldByName('CompCamp').AsString = 'EN') then
          begin
            CalcNume := TRxEdtLbl.Create(iForm);
            CalcNume.Parent     := Pane;
            CompAtua := CalcNume;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            CalcNume.Lista.Text      := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            CalcNume.LblAssoc        := Labe;
            CalcNume.FormatOnEditing := True;
            CalcNume.MinValue        := cds.FieldByName('MiniCamp').AsFloat;
            CalcNume.MaxValue        := cds.FieldByName('MaxiCamp').AsFloat;
            CalcNume.Numero          := Guia;
            CalcNume.AutoSize        := True;

            if cds.FieldByName('CompCamp').AsString = 'LN' then
            begin
              CalcNume.OnChange   := iExecExit;    //ST: deixado por ultimo que quando joga o DisplayFormat dispara o onchange do campo, as vezes com PLSAG em campo que ainda não existe
              CalcNume.TabStop      := False;
              CalcNume.ReadOnly     := True;
              CalcNume.sgConf.Style := stlInformativo;
              CalcNume.ButtonWidth  := 0;
            end
            else
            begin
              CalcNume.sgConf.Obrigatorio := cds.FieldByName('ObriCamp').AsInteger <> 0;
              CalcNume.sgConf.OnHabi      := Habi;
              CalcNume.OnExit             := iExecExit;

              //Último - Confirma
              if NumeRegi = TotaRegi then
                CalcNume.OnKeyPress := UltiCamp;

              //Obrigatório
              if CalcNume.sgConf.Obrigatorio then
                CalcNume.OnChange := Habi;
            end;

            {$ifdef ERPUNI}
              CalcNume.DecimalPrecision  := cds.FieldByName('DeciCamp').AsInteger;
              CalcNume.DecimalSeparator  := ',';
              CalcNume.ThousandSeparator := '.';
            {$else}
              CalcNume.CheckOnExit     := True;
              CalcNume.DecimalPrecision   := cds.FieldByName('DeciCamp').AsInteger;
              if cds.FieldByName('MascCamp').AsString <> '' then
                CalcNume.DisplayFormat   := RetoMasc(cds.FieldByName('MascCamp').AsString);
            {$endif}

            CalcNume.Font.Assign(vFontCamp);
          end
          //************************************************************************************
          //B E V E L
          else if (cds.FieldByName('CompCamp').AsString = 'BVL') then    //BV
          begin
            Beve := TsgBvl.Create(iForm);

            if not Assigned(TsgBvl(FindComponent('Bvl'+cds.FieldByName('NameCamp').AsString))) then
              Beve.Name       := 'Bvl'+cds.FieldByName('NameCamp').AsString;
            Beve.Width      := cds.FieldByName('TamaCamp').AsInteger;
            Beve.Left       := cds.FieldByName('EsquCamp').AsInteger;

            {$ifdef ERPUNI}
              Beve.TabStop := False;
              if cds.FieldByName('LbcxCamp').AsInteger <> 0 then
              begin
                Beve.Caption := cds.FieldByName('LabeCamp').AsString;
                Beve.Font.Assign(vFontLabe);
                Beve.Height     := cds.FieldByName('AltuCamp').AsInteger+9;
                Beve.Top        := cds.FieldByName('TopoCamp').AsInteger-9;
              end
              else
              begin
                Beve.Height     := cds.FieldByName('AltuCamp').AsInteger;
                Beve.Top        := cds.FieldByName('TopoCamp').AsInteger;
              end;
            {$else}
              Beve.Height     := cds.FieldByName('AltuCamp').AsInteger;
              Beve.Top        := cds.FieldByName('TopoCamp').AsInteger;
              Beve.Shape      := TBevelShape(StrToInt(RetoZero(cds.FieldByName('FormCamp').AsString)));
              Beve.Style      := TBevelStyle(StrToInt(RetoZero(cds.FieldByName('EstiCamp').AsString)));
              if cds.FieldByName('LbcxCamp').AsInteger = 1 then
              begin
                BvlLabel := TsgLbl.Create(iForm);
                if not Assigned(TsgLbl(FindComponent('Lbl'+cds.FieldByName('NameCamp').AsString))) then
                  BvlLabel.Name       := 'Lbl'+cds.FieldByName('NameCamp').AsString;
                BvlLabel.Transparent := false;
                BvlLabel.Caption := ' '+cds.FieldByName('LabeCamp').AsString+' ';
                //Beve.Top := Beve.Top+8;
                BvlLabel.Left := Beve.Left+4;
                BvlLabel.Top  := Beve.Top-8;
                //BvlLabel.Transparent:= True; //Sidiney: se ficar transparente, apereceo "risco" do Bevel
                BvlLabel.Font.Assign(vFontLabe);
                BvlLabel.Parent := pane;
              end;
            {$endif}
            Beve.Parent     := Pane;
          end
          //************************************************************************************
          //L A B E L
          else if (cds.FieldByName('CompCamp').AsString = 'LBL') then      //LB
          begin
          end
          //************************************************************************************
          //I n f o r m a ç ã o -  E d i t o r
          else if (cds.FieldByName('CompCamp').AsString = 'IE') then    //CE
          begin
            Edit := TDBEdtLbl.Create(iForm);
            CompAtua := Edit;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;
            Edit.Text   := '';

            Edit.LblAssoc := Labe;

            Edit.Lista.Text := cds.FieldByName('VaGrCamp').AsString;
            if Edit.Lista.Count < 2 then
               msgAviso('Campo '+cds.FieldByName('NameCamp').AsString+' (Informação) com dados incompletos para exibir informações (necessário preencher na guia Editor, campo "Valores Padrão": 1ª Linha: Campo e na 2ª Linha: Campo Tabela)')
            else
            begin
              Edit.DataField  := Edit.Lista.Strings[0];
              Edit.DataSource := TDataSource(BuscaComponente('Dts'+Edit.Lista.Strings[1]));
            end;
            Edit.Lista.Clear;

            Edit.TabStop  := False;
            Edit.ReadOnly := True;
            Edit.Color    := clBtnFace;
            Edit.Numero   := Guia;
            Edit.AutoSize := True;

            Edit.Font.Assign(vFontCamp);
            Edit.Parent   := Pane;
          end
          //************************************************************************************
          //I n f o r m a ç ã o -  M E M O
          else if (cds.FieldByName('CompCamp').AsString = 'IM') then    //CM
          begin
            Memo := TDBMemLbl.Create(iForm);
            Memo.Parent     := Pane;
            CompAtua := Memo;
            CompAtua.Name   := 'Mem'+cds.FieldByName('NameCamp').AsString;

            Memo.Lista.Text := cds.FieldByName('VaGrCamp').AsString;
            if Memo.Lista.Count < 2 then
               msgAviso('Campo '+cds.FieldByName('NameCamp').AsString+' (Informação) com dados incompletos para exibir informações (necessário preencher na guia Editor, campo "Valores Padrão": 1ª Linha: Campo e na 2ª Linha: Campo Tabela)')
            else
            begin
              Memo.DataField  := Memo.Lista.Strings[0];
              Memo.DataSource := TDataSource(BuscaComponente('Dts'+Memo.Lista.Strings[1]));
            end;
            Memo.Lista.Clear;

            Memo.LblAssoc     := Labe;
            if cds.FieldByName('InteCamp').AsInteger <> 0 then
            begin
              {$ifdef ERPUNI}
              {$else}
                Memo.ScrollBars := ssVertical;
              {$endif}
              Memo.WordWrap   := True;
            end
            else
            begin
              {$ifdef ERPUNI}
              {$else}
                Memo.ScrollBars := ssBoth;
              {$endif}
              Memo.WordWrap   := False;
            end;
            Memo.Height     := cds.FieldByName('AltuCamp').AsInteger;
            Memo.Numero   := Guia;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Labe.Visible := False;
              Memo.Align := alClient;
              Memo.AlignWithMargins := True;
              Memo.Margins.Top   := 10;
              Memo.Margins.Bottom:= 10;
              Memo.Margins.Left  := 10;
              Memo.Margins.Right := 10;
            end;

            Memo.Font.Assign(vFontCamp);

            Memo.TabStop  := False;
            Memo.ReadOnly := True;
            Memo.Color    := clBtnFace;
          end
          //************************************************************************************
          //I n f o r m a ç ã o -  R I C H E D I T
          else if (cds.FieldByName('CompCamp').AsString = 'IR') then  //CR
          begin
            Rich := TDBRchLbl.Create(iForm);
            CompAtua := Rich;
            CompAtua.Name   := 'Rch'+cds.FieldByName('NameCamp').AsString;

            Rich.Lista.Text := cds.FieldByName('VaGrCamp').AsString;
            if Rich.Lista.Count < 2 then
               msgAviso('Campo '+cds.FieldByName('NameCamp').AsString+' (Informação) com dados incompletos para exibir informações (necessário preencher na guia Editor, campo "Valores Padrão": 1ª Linha: Campo e na 2ª Linha: Campo Tabela)')
            else
            begin
              Rich.DataField  := Rich.Lista.Strings[0];
              Rich.DataSource := TDataSource(BuscaComponente('Dts'+Rich.Lista.Strings[1]));
            end;
            Rich.Lista.Clear;

            Rich.LblAssoc   := Labe;
            if cds.FieldByName('InteCamp').AsInteger <> 0 then
            begin
              {$ifdef ERPUNI}
              {$else}
                Rich.ScrollBars := ssVertical;
              {$endif}
              Rich.WordWrap   := True;
            end
            else
            begin
              {$ifdef ERPUNI}
              {$else}
                Rich.ScrollBars := ssBoth;
              {$endif}
              Rich.WordWrap   := False;
            end;
            Rich.Height     := cds.FieldByName('AltuCamp').AsInteger;
            Rich.Numero   := Guia;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Labe.Visible := False;
              Rich.Align := alClient;
              Rich.AlignWithMargins := True;
              Rich.Margins.Top   := 10;
              Rich.Margins.Bottom:= 10;
              Rich.Margins.Left  := 10;
              Rich.Margins.Right := 10;
            end;

            Rich.Font.Assign(vFontCamp);

            Rich.TabStop  := False;
            Rich.ReadOnly := True;
            Rich.Color    := clBtnFace;
            Rich.Parent     := Pane;
          end
          //************************************************************************************
          //I n f o r m a ç ã o -  N ú m e r o
          else if (cds.FieldByName('CompCamp').AsString = 'IN') then    //CN
          begin
            Nume := TDBRxELbl.Create(iForm);
            CompAtua := Nume;
            CompAtua.Name   := 'Edt'+cds.FieldByName('NameCamp').AsString;

            Nume.Lista.Text := cds.FieldByName('VaGrCamp').AsString;
            if Nume.Lista.Count < 2 then
               msgAviso('Campo '+cds.FieldByName('NameCamp').AsString+' (Informação) com dados incompletos para exibir informações (necessário preencher na guia Editor, campo "Valores Padrão": 1ª Linha: Campo e na 2ª Linha: Campo Tabela)')
            else
            begin
              Nume.DataField  := Nume.Lista.Strings[0];
              Nume.DataSource := TDataSource(BuscaComponente('Dts'+Nume.Lista.Strings[1]));
            end;
            Nume.Lista.Clear;

            Nume.TabStop      := False;
            Nume.ReadOnly     := True;
            Nume.sgConf.Style := stlInformativo;

            Nume.LblAssoc        := Labe;
            {$ifdef ERPUNI}
              Nume.DecimalPrecision  := cds.FieldByName('DeciCamp').AsInteger;
              Nume.DecimalSeparator  := ',';
              Nume.ThousandSeparator := '.';
            {$else}
              Nume.ButtonWidth  := 0;
              Nume.DecimalPlaces   := cds.FieldByName('DeciCamp').AsInteger;
              if cds.FieldByName('MascCamp').AsString <> '' then
                  Nume.DisplayFormat   := RetoMasc(cds.FieldByName('MascCamp').AsString);
            {$endif}

            Nume.MinValue        := cds.FieldByName('MiniCamp').AsFloat;
            Nume.MaxValue        := cds.FieldByName('MaxiCamp').AsFloat;
            Nume.Numero   := Guia;

            Nume.Font.Assign(vFontCamp);
            Nume.Parent     := Pane;
          end
          //************************************************************************************
          //D B G r i d
          else if (cds.FieldByName('CompCamp').AsString = 'DBG') then   //GC
          begin
            Grid := TsgDBG.Create(iForm);
            CompAtua := Grid;
            CompAtua.Name   := 'Dbg'+cds.FieldByName('NameCamp').AsString;
            CompAtua.Tag    := 10; //Já Traduzido

            //Query
            Qry              := TsgQuery.Create(iForm);
            Qry.Name         := 'Qry'+cds.FieldByName('NameCamp').AsString;
            Qry.AfterOpen    := ArruTama;

            Grid.Coluna.Text := TradSQL_Cons(0, cds.FieldByName('GrCoCamp').AsString, True, cds.FieldByName('NameCamp').AsString, CodiTabe);
            Grid.ConfTabe.GravTabe := cds.FieldByName('FormCamp').AsString;
            Grid.ConfTabe.SGTBGrav := cds.FieldByName('CodiTabe').AsInteger;
            Qry.ConfTabe.GravTabe  := cds.FieldByName('FormCamp').AsString;
            Qry.ConfTabe.SGTBGrav  := cds.FieldByName('CodiTabe').AsInteger;

            Qry.Tag          := cds.FieldByName('TagQCamp').AsInteger;
            Qry.SQL_Back.Text:= TradSQL_Cons(0, CampPers_BuscSQL(iForm, cds.FieldByName('SQL_Camp').AsString),
                                             False, cds.FieldByName('NameCamp').AsString, CodiTabe);
            Qry.Lista.Text   := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            if cds.FieldByName('DeciCamp').AsInteger <> 0 then
              Qry.sgConnection := sgTransaction
            else
              Qry.sgConnection := GetPADOConn;

            //DataSource
            Dts := TDataSource.Create(iForm);
            Dts.Name := 'Dts'+cds.FieldByName('NameCamp').AsString;
            Dts.DataSet := Qry;
            Grid.DataSource := Dts;
            Grid.Edita      := cds.FieldByName('InteCamp').AsInteger <> 0; //Editar (deixar depois do DataSource que aí criou o sgView e pode setar as configurações)

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Grid.Align := alClient;
              Grid.AlignWithMargins := True;
              Grid.Margins.Top   := 10;
              Grid.Margins.Bottom:= 10;
              Grid.Margins.Left  := 10;
              Grid.Margins.Right := 10;
            end
            else
            begin
              Grid.Height     := cds.FieldByName('AltuCamp').AsInteger;
              {$ifdef ERPUNI}
                Grid.WebOptions.Paged := False;
                Grid.Options := Grid.Options + [dgRowNumbers];
              {$else}
                if Grid.sgView.ClassType = TcxGridDBTableView then
                  TcxGridDBTableView(Grid.sgView).OptionsView.GroupByBox := False;
              {$endif}
            end;


            //??? - Unigui
            //{$ifdef ERPUNI}
              Qry.SQL.Text := SubsCampPers(iForm, Qry.SQL_Back.Text);
            //{$endif}

            if sgPos('/Lookup=S',Grid.Coluna.Text) > 0 then
            begin
              Qry.ExibChav := True;
              Qry.Coluna.Text := Grid.Coluna.Text;
              Qry.CriaCampos(TForm(iForm));
            end
            else
            begin
              //Ocultar Primeiro Campo, daí, depois que abro, se o Número for 10, oculto o primeiro campo
              Qry.ExibChav := False;
              //  Qry.Numero := 10;
            end;

            Grid.Lista.Text   := CampPers_TratExec(nil, cds.FieldByName('Exp1Camp').AsString, cds.FieldByName('EPerCamp').AsString);
            Grid.Numero       := Guia;

            {$ifdef ERPUNI}
              //Quando tem edição, tem que abrir quando cria o componente/tela
              if (Qry.Tag <> 10) or StrInPos(Grid.Coluna.Text, ['/TotaGrup=S', '/TotaRoda=S']) then
              begin
                //??? Qry.SQL.Text := Qry.SQL_Back.Text;
                Qry.Open;
                Grid.ReGeraCamp;
              end;
            {$else}
              //??? Qry.SQL.Text := Qry.SQL_Back.Text;
              Grid.sgView.OnDblClick   := iExecExit;
              Grid.sgView.OnKeyDown    := ClicObs;
              Grid.sgView.OptionsBehavior.HintHidePause := 99999;
              if Qry.Tag <> 10 then
                Qry.Open;
            {$endif}

            Grid.TabStop      := False;

            Grid.sgTamaFont  := cds.FieldByName('CTamCamp').AsInteger;

            Grid.Font.Assign(vFontCamp);
            Grid.Parent     := Pane;
          end
          //************************************************************************************
          //G R A F I C O
          else if (cds.FieldByName('CompCamp').AsString = 'GRA') then       //GR
          begin
            Graf := TFraGraf.Create(iForm);
            {$ifdef ERPUNI}
            {$else}
              CompAtua := Graf;
            {$endif}
            Graf.Name   := 'Gra'+cds.FieldByName('NameCamp').AsString;
            //Graf.Tag    := 10; //Já Traduzido

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Graf.Align := alClient;
              Graf.AlignWithMargins := True;
              Graf.Margins.Top   := 10;
              Graf.Margins.Bottom:= 10;
              Graf.Margins.Left  := 10;
              Graf.Margins.Right := 10;
            end
            else
            begin
              Graf.Height := cds.FieldByName('AltuCamp').AsInteger;
              Graf.Width  := cds.FieldByName('TamaCamp').AsInteger;
              Graf.Top    := cds.FieldByName('TopoCamp').AsInteger;
              Graf.Left   := cds.FieldByName('EsquCamp').AsInteger;
            end;

            Graf.Numero       := Guia;
            //Graf.OnDblClick   := iExecExit;

            Graf.sgConf.Lista.Text:= CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            Graf.sgConf.ConfXML.Text := CampPers_BuscSQL(iForm, cds.FieldByName('SQL_Camp').AsString);
            Graf.sgConf.ConfComp_XML;
            Graf.Parent     := Pane;
          end
          //************************************************************************************
          //B O T Ã O
          else if (cds.FieldByName('CompCamp').AsString = 'BTN') then   //BT
          begin
            Btn  := TsgBtn.Create(iForm);

            //Fora do Normal
            Btn.Name       := 'Btn'+cds.FieldByName('NameCamp').AsString;
            Btn.Width      := cds.FieldByName('TamaCamp').AsInteger;
            Btn.Left       := cds.FieldByName('EsquCamp').AsInteger;
            Btn.Hint       := cds.FieldByName('HintCamp').AsString;

            Btn.OnClick   := iExecExit;
            Btn.Lista.Text:= CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            Btn.Caption   := cds.FieldByName('LabeCamp').AsString;
            Btn.Numero    := Guia;
            Btn.Margin    := -1;

            //Btn.Font.Name  := cds.FieldByName('CFonCamp').AsString;
            //Btn.Font.Size  := cds.FieldByName('CTamCamp').AsInteger;
            Btn_Formata(Btn);
            Btn.Font.Color := cds.FieldByName('CCorCamp').AsInteger;

            Btn.sgIconCls := cds.FieldByName('MascCamp').AsString;

            {$ifdef ERPUNI}
            {$else}
              if Btn.sgImageIndex < 0 then
              begin
                //Btn.Colors.Hot     := clWhite;
                //Btn.Colors.Pressed := clWhite;
                DtmPoul.DtsCampos.DataSet := cds;
                Btn.Glyph.Assign(PegaFiguCampBmp_(DtmPoul.DtsCampos, 'FiguCamp'));
              end;
              if (not Btn.Glyph.Empty) or (Btn.sgImageIndex >= 0) then
              begin
                if Btn.Caption <> '' then
                begin
                  Btn.Spacing := 6;
                  Btn.Margin  := -1;
                  Btn.Top     := cds.FieldByName('TopoCamp').AsInteger - 10;
                  Btn.Height  := 31;
                end
                else
                begin
                  Btn.Spacing := 6;
                  Btn.Margin  := -1;
                  Btn.Top     := cds.FieldByName('TopoCamp').AsInteger-10;
                  Btn.Height  := 31;
                  //Btn.Height  := cds.FieldByName('AltuCamp').AsInteger;
                  //Btn.LookAndFeel.Kind := lfFlat;
                end;
              end
              else
            {$endif}
            begin
              Btn.Top     := cds.FieldByName('TopoCamp').AsInteger - 10;
              if Btn.Caption <> '' then
                Btn.Height  := 31
              else
              begin
                Btn.Height  := 31;
                //Btn.Height  := cds.FieldByName('AltuCamp').AsInteger;
                Btn.Margin  := -1;
              end;
            end;
            Btn.Parent     := Pane;
          end
          //************************************************************************************
          //F I G U R A   D O   B A N C O
          else if (cds.FieldByName('CompCamp').AsString = 'FE') or        //FI
                  (cds.FieldByName('CompCamp').AsString = 'FI') then
          begin
            Img  := TDBImgLbl.Create(iForm);
            CompAtua := Img;

            CompAtua.Name   := 'Img'+cds.FieldByName('NameCamp').AsString;
            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Img.Align := alClient;
              Img.AlignWithMargins := True;
              Img.Margins.Top   := 10;
              Img.Margins.Bottom:= 10;
              Img.Margins.Left  := 10;
              Img.Margins.Right := 10;
            end
            else
            begin
              Img.Width  := cds.FieldByName('TamaCamp').AsInteger;
              Img.Height := cds.FieldByName('AltuCamp').AsInteger;
              Img.Top    := cds.FieldByName('TopoCamp').AsInteger;
              Img.Left   := cds.FieldByName('EsquCamp').AsInteger;
            end;
            Img.Numero := Guia;
            //Img.Stretch:= True;

            if (cds.FieldByName('CompCamp').AsString = 'FE') then
            begin
              Img.DataField  := cds.FieldByName('NomeCamp').AsString;
              Img.DataSource := DataSour;
              {$ifdef ERPUNI}
                DBFil := TDBFilLbl.Create(iForm);
                DBFil.Name   := 'Fil'+cds.FieldByName('NameCamp').AsString;
                DBFil.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
                DBFil.CampArqu   := cds.FieldByName('NomeCamp').AsString;
                DBFil.DataField  := '';
                DBFil.DataSource := DataSour;
                DBFil.Numero   := Guia;
                DBFil.Caption := 'Importa '+cds.FieldByName('LabeCamp').AsString;
                DBFil.Height := 25;
                DBFil.Top    := Img.Top;
                DBFil.Left   := Img.Left;
                DBFil.Width  := SeInte(Img.Width<110, Img.Width, 110);
                DBFil.Title  := DBFil.Caption;
                DBFil.Filter := 'image/*';
                //Img.Height := Img.Height - 28;
                //Img.Top    := Img.Top + 28;
                DBFil.Parent := Pane;
              {$endif}
            end
            else
            begin
              Img.Lista.Text := cds.FieldByName('VaGrCamp').AsString;
              if Img.Lista.Count < 2 then
                 msgAviso('Campo '+cds.FieldByName('NameCamp').AsString+' (Informação) com dados incompletos para exibir informações (necessário preencher na guia Editor, campo "Valores Padrão": 1ª Linha: Campo e na 2ª Linha: Campo Tabela)')
              else
              begin
                Img.DataField  := Img.Lista.Strings[0];
                Img.DataSource := TDataSource(BuscaComponente('Dts'+Img.Lista.Strings[1]));
              end;
              Img.Lista.Clear;

              Img.TabStop  := False;
              {$ifdef ERPUNI}
              {$else}
                Img.ReadOnly := True;
                Img.BorderStyle := bsNone;
              {$endif}
            end;
            CompAtua.Parent := Pane;
          end
          //************************************************************************************
          //F I G U R A   F I X A
          else if (cds.FieldByName('CompCamp').AsString = 'FF') then    //FF
          begin
            ImgF := TImgLbl.Create(iForm);
            ImgF.Name   := 'Img'+cds.FieldByName('NameCamp').AsString;
            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              ImgF.Align := alClient;
              ImgF.AlignWithMargins := True;
              ImgF.Margins.Top   := 10;
              ImgF.Margins.Bottom:= 10;
              ImgF.Margins.Left  := 10;
              ImgF.Margins.Right := 10;
            end
            else
            begin
              ImgF.Width  := cds.FieldByName('TamaCamp').AsInteger;
              ImgF.Height := cds.FieldByName('AltuCamp').AsInteger;
              ImgF.Top    := cds.FieldByName('TopoCamp').AsInteger;
              ImgF.Left   := cds.FieldByName('EsquCamp').AsInteger;
            end;
            ImgF.Hint   := cds.FieldByName('HintCamp').AsString;
            ImgF.Numero := Guia;
  //          ImgF.AutoSize   := True;
            ImgF.Center     := True;
            ImgF.Transparent:= True;
            ImgF.Stretch    := True;
            DtmPoul.DtsCampos.DataSet := cds;
            ImgF.Picture.Assign(PegaFiguCampPict(DtmPoul.DtsCampos, 'FiguCamp'));
            ImgF.Parent := Pane;
          end
          //************************************************************************************
          //L I S T A (CHECK BOX)
          else if (cds.FieldByName('CompCamp').AsString = 'LC') then          //LC
          begin
            Lst  := TLstLbl.Create(iForm);
            Lst.Parent := Pane;
            Lst.Name   := 'Lst'+cds.FieldByName('NameCamp').AsString;
            Lst.Tag    := 10; //Já Traduzido
            CompAtua := Lst;

            if (cds.FieldByName('AltuCamp').AsInteger = 999) then
            begin
              Lst.Align := alClient;
              Lst.AlignWithMargins := True;
              Lst.Margins.Top   := 10;
              Lst.Margins.Bottom:= 10;
              Lst.Margins.Left  := 10;
              Lst.Margins.Right := 10;
            end
            else
              Lst.Height := cds.FieldByName('AltuCamp').AsInteger;
            Lst.Numero   := Guia;
            Lst.ReadOnly := True;

            Lst.OnClick    := iExecExit;
            Lst.OnDblClick := DuplClic;
            {$ifdef ERPUNI}
              Lst.OnDblClick    := iExecExit;
              Lst.TabStop      := False;
              //Lst.CheckBoxOnly := True;
            {$else}
              Lst.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
              Lst.ColumnClick:= True;
              Lst.OnColumnClick := ListChecColumnClick;
              Lst.Checkboxes := True;
              Lst.ViewStyle  := vsReport;
            {$endif}
            Lst.Lista2.Text:= cds.FieldByName('Exp1Camp').AsString;

            //Último - Confirma
            if NumeRegi = TotaRegi then
              Lst.OnKeyPress := UltiCamp;

            //** EXTRAS ***
            Lst.Hint       := Lst.Hint + sgLn + '(Duplo Clique: Seleciona ou Limpa Tudo)';
            //Lst.OnKeyDown  := ClicObs;

            Qry              := TsgQuery.Create(iForm);
            Qry.Name         := 'Qry'+cds.FieldByName('NameCamp').AsString;
            Qry.AfterOpen    := ArruTama;
            Qry.Tag          := cds.FieldByName('TagQCamp').AsInteger;
            Qry.SQL_Back.Text:= TradSQL_Cons(0, CampPers_BuscSQL(iForm, cds.FieldByName('SQL_Camp').AsString),
                                             False, cds.FieldByName('NameCamp').AsString, CodiTabe);
            Qry.SQL.Text     := SubsCampPers(iForm, Qry.SQL_Back.Text);
            {$ifdef ERPUNI}
              Lst.Coluna.Text  := TradSQL_Cons(0, cds.FieldByName('GrCoCamp').AsString, True, cds.FieldByName('NameCamp').AsString, CodiTabe);
              Qry.Coluna.Text  := Lst.Coluna.Text;
              Qry.Lista.Text   := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            {$else}
              Qry.Coluna.Text  := TradSQL_Cons(0, cds.FieldByName('GrCoCamp').AsString, True, cds.FieldByName('NameCamp').AsString, CodiTabe);
            {$endif}
            if cds.FieldByName('DeciCamp').AsInteger = 1 then
              Qry.sgConnection := sgTransaction
            else
              Qry.sgConnection   := GetPADOConn;
            Lst.Query := Qry;

            {$ifdef ERPUNI}
              Lst.sgTamaFont  := cds.FieldByName('CTamCamp').AsInteger;
              Lst.Font.Assign(vFontCamp);
              Qry.ExibChav := False;
            {$else}
              if Qry.Tag <> 10 then
                Lst.CarregaDados();
            {$endif}
          end
          //************************************************************************************
          //T I M E R
          else if (cds.FieldByName('CompCamp').AsString = 'TIM') then    //TI
          begin
            Tim := TsgTim.Create(iForm);
            Tim.Name    := 'Tim'+cds.FieldByName('NameCamp').AsString;
            Tim.Numero  := Guia;
            Tim.OnTimer := iExecExit;
            Tim.Lista.Text := CampPers_TratExec(nil, cds.FieldByName('ExprCamp').AsString, cds.FieldByName('EPerCamp').AsString);
            Tim.Interval  := cds.FieldByName('PadrCamp').AsInteger * 1000;
          end;


          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          //Configuração Geral
          if Assigned(CompAtua) and (not StrIn(cds.FieldByName('CompCamp').AsString, ['BVL', 'LBL', 'BTN', 'FI', 'FF', 'TIM'])) then
          begin
            CompAtua.Parent     := Pane;
            if (CompAtua.ClassType <> TDBLookNume) and (CompAtua.ClassType <> TDBLookText) then
              CompAtua.Width      := cds.FieldByName('TamaCamp').AsInteger;
            CompAtua.Left       := cds.FieldByName('EsquCamp').AsInteger;
            CompAtua.Top        := cds.FieldByName('TopoCamp').AsInteger;
            CompAtua.Hint       := cds.FieldByName('HintCamp').AsString + CompAtua.Hint;  //A imagem tem um Hint especifico

            if cds.FieldByName('OrdeCamp').AsInteger = 9999 then
              CompAtua.TabStop := False
            else
              {$ifdef ERPUNI}
                CompAtua.TabOrder:= NumeRegi;
              {$else}
                CompAtua.TabOrder:= 1000;
              {$endif}

              //Sidiney (15/02/2022 17:55): Segue a formatação do Func.Componentes_Formata
//            if (CompAtua.ClassType <> TCmbLbl) and
//               (CompAtua.ClassType <> TDBCmbLbl) and
//               (CompAtua.ClassType <> TDBLcbLbl) and
//               (CompAtua.ClassType <> TLcbLbl) and
//               (CompAtua.ClassType <> TChkLbl) and
//               (CompAtua.ClassType <> TDBChkLbl) then
//            begin
//              {$ifdef ERPUNI}
//              {$else}
//                TEdtLbl(CompAtua).BevelKind  := bkFlat;
//                TEdtLbl(CompAtua).BorderStyle:= bsNone;
//              {$endif}
//            end;

            //Obrigatório
            if cds.FieldByName('ObriCamp').Value <> 0 then
              CompAtua.Tag := Tag_Obri;

            //Desabilita na Alteração
            if TestDataSet(DataSour) then
              CompAtua.Enabled := not ((cds.FieldByName('DesaCamp').AsInteger <> 0) and (DataSour.DataSet.State = dsEdit));

            //Label
            if Labe <> Nil then
            begin
              Labe.FocusControl := CompAtua;
              Labe.Enabled      := CompAtua.Enabled;
            end;

            //Primeiro Campo
            if CompAtua.Enabled and (NumeRegi > 0) then
            begin
              if (Labe <> nil) then
              begin
                case Guia of
                  1 : if PrimGui1 = nil then PrimGui1 := Labe.FocusControl;
                  2 : if PrimGui2 = nil then PrimGui2 := Labe.FocusControl;
                  3 : if PrimGui3 = nil then PrimGui3 := Labe.FocusControl;
                  11: if PrimGui3 = nil then PrimGui3 := Labe.FocusControl;
                  12: if PrimGui3 = nil then PrimGui3 := Labe.FocusControl;
                end;
              end;
            end;
          end;

          if GetPUppeCase() and (CompAtua <> nil) then
          begin
            if (CompAtua.ClassType = TDBEdtLbl) or
               (CompAtua.ClassType = TEdtLbl) or
               (CompAtua.ClassType = TDBMemLbl) or
               (CompAtua.ClassType = TDBRchLbl) or
               (CompAtua.ClassType = TMemLbl) or
               {$ifdef ERPUNI}
               {$else}
                 (CompAtua.ClassType = TMaskEdit) or
               {$endif}
               (CompAtua.ClassType = TFilLbl) or
               (CompAtua.ClassType = TDirLbl) then
            begin
              with TEdtLbl(CompAtua) do
              begin
                {$ifdef ERPUNI}
                {$else}
                  if PasswordChar = '' then
                    CharCase := ecUpperCase;
                {$endif}
              end;
            end;
          end;
          cds.Next;
          Inc(NumeRegi);
        end;
        //cds.Close;
        POHeForm_AtuaCria(iForm, False);
      end;
    finally
      cds.Close;
      FreeAndNil(cds);
      vFontCamp.Free;
      vFontLabe.Free;
      Componentes_Formata(iForm);
    end;
  end;
end;

//Busca SQL caso seja uma proriedade
function CampPers_BuscSQL(iForm: TsgForm; const iSQL: String): String;
var
  Exec: TStringList;
  vUltiLinh: String;
begin
  if sgCopy(iSQL, 01, 10) = 'OD-PRIN_D.' then
  begin
    Exec := TStringList.Create;
    try
      Exec.Text := TiraEspaLinhFinaList(iSQL);
      vUltiLinh := Exec.Strings[Exec.Count-1];
      Exec.Strings[Exec.Count-1] := '';
      CampPersExecDireStri(iForm, Exec.Text, '');
      Result := CampPers_OD(iForm, vUltiLinh).DeQuotedString;
    finally
      Exec.Free;
    end;
  end
  else
    Result := iSQL;
end;

//Tratar os personalizados nos Executas
function CampPers_TratExec(iForm: TsgForm; Valo, Pers: String): String;
var
  i: Integer;
  ListValo: TStringList;
  Seca: String;
  Exec, ExecOutr: TStringList;
  j: Integer;
  Acho : Boolean;
begin
  Result := Valo;
  if (Trim(Pers) <> '') and (Trim(Valo) <> '') then
  begin
    ListValo := TStringList.Create();
    Exec := TStringList.Create;
    try
      ListValo.Text := Valo;
      i := 0;
      while i < (ListValo.Count) do  //Tem que ser o While porque muda o .Count durante o processo
      begin
        if Copy(Trim(ListValo[i]),01,01) = '[' then
        begin
          Seca := ListValo[i];
          ListValo.Delete(i);
          //ListValo.Insert(i, SubsPalaTudo(Ini_BuscValo(Pers, Seca),#$A#$D,sgLn));

          Exec.Text := SubsPalaTudo(Ini_BuscValo(Pers, Seca),#$A#$D,sgLn);
          for j := 0 to Exec.Count - 1 do
          begin
            ListValo.Insert(i, Exec[j]);
            Inc(i);
          end;
          if Exec.Count > 0 then
            Dec(i);
        end;
        Inc(i);
      end;
      Result := ListValo.Text;
    finally
      ListValo.Free;
      Exec.Free;
    end;
  end;

  if (iForm <> nil) {$IfDef TESTMODE} and (iForm.HelpContext <> 15260) {$endif} then  //15.260 é o CodiTabe do Teste-Executa
  begin
    Exec := TStringList.Create;
    ExecOutr := TStringList.Create;
    try
      Acho := False;
      Exec.Text := Result;
      i := 0;
      while i < (Exec.Count) do //Tem que ser o While porque muda o .Count durante o processo
      begin
        if Copy(Trim(Exec[i]),01,01) = '{' then
        begin
          ExecOutr.Text := SubsCampPers(iForm, Exec[i], 'EXEC');
          ExecOutr.Add('');  //Sidney 07/04/2021: Se não encontrou, força a substituição
          Exec.Delete(i);
          for j := 0 to ExecOutr.Count - 1 do
            Exec.Insert(i+j, CampPers_TratExec(iForm, ExecOutr[j], ''));
          Acho := ExecOutr.Count > 0;
        end;
        Inc(i);
      end;
      if Acho then  //Quando passava só uma linha, retornava com ENTER no final, assim, se não fez nada, retorna a própria entrada
        Result := Exec.Text;
    finally
      Exec.Free;
      ExecOutr.Free;
    end;
  end;
end;

function WS_ExecPLSAG(iForm: TsgForm; iPL: String): sgCustomActionResult;
begin
  if Assigned(iForm) then
  begin
    iForm.ShowMask(SProcessando);
    Application_ProcessMessages;
  end;
  try
    Result := WSPlus.WS_ExecPLSAG(iPL);
  finally
    if Assigned(iForm) then
      iForm.HideMask;
  end;
end;
//Substituir os Campos dentro das expressões entre Colchetes {}
//Tipo: VALO - Retorna o valor do componente
//      EXEC - Retorna o executa na saída do campo
Function SubsCampPers(iForm: TsgForm; Inst: String; TipoInfo: String = 'VALO'):String;
var
  CampOrig, Camp, Valo, NameCamp, Orig, Acao: String;
  vTipo: String;
  Lst: TLstLbl;
  i: Integer;
  ListValo: TStringList;
  Look: TLcbLbl;
  vQuer: TsgQuery;
  vDts: TDataSource;
  vMensagem: String;

  function CampPersTratDadoBanc(lTipo: TField): String;
  begin
//    if Tipo.IsNull and (sgCopy(Tipo.FieldName,01,04) = 'CODI') then
//      Result := 'NULL'
//    else
    if TipoDadoCara(lTipo) IN ['N','I','S'] then
      Result := FormNumeSQL(lTipo.AsFloat)
    else if TipoDadoCara(lTipo) = 'D' then
      Result := FormDataSQL(lTipo.AsDateTime)
    else
      Result := QuotedStr(lTipo.AsString);
  end;

begin
  vMensagem := '';
  ListValo := TStringList.Create();
  try
    with iForm do
    begin
      if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
      ListValo.Text := Inst;
      i := 0;
      while i < (ListValo.Count) do  //Tem que ser o While porque muda o .Count durante o processo
      begin
        Inst := ListValo[i];
        if (Copy(Trim(Inst),01,02) <> '--') and
           (Copy(Trim(Inst),01,02) <> '//') and
           (Trim(Inst) <> '') and (Pos('{',Inst) > 0) and (Pos('}',Inst) > 0) then
        begin
          while (Pos('{',Inst) > 0) and (Pos('}',Inst) > 0) do
          begin
            CampOrig := Copy(Inst, Pos('{',Inst) + 1, Pos('}',Inst) - Pos('{',Inst) - 1);  //Com espaço e tudo, para substituir no final

            if StrIn(sgCopy(CampOrig,01,08), ['FORMPARE','FORMRELA']) then  //Pega do formulario parente
            begin
              case Func.sgTipoForm(iForm.FormRela) of
                tfsgFrm     : Valo :=      PlusUni.SubsCampPers(     TsgForm(iForm.FormRela), '{'+sgCopy(CampOrig, 10, MaxInt)+'}', TipoInfo);
                tfsgFrmModal: Valo := PlusUniModal.SubsCampPers(TsgFormModal(iForm.FormRela), '{'+sgCopy(CampOrig, 10, MaxInt)+'}', TipoInfo);
                tfNil: case Func.sgTipoForm(iForm.Parent) of
                         tfsgFrm     : Valo :=      PlusUni.SubsCampPers(     TsgForm(iForm.Parent), '{'+sgCopy(CampOrig, 10, MaxInt)+'}', TipoInfo);
                         tfsgFrmModal: Valo := PlusUniModal.SubsCampPers(TsgFormModal(iForm.Parent), '{'+sgCopy(CampOrig, 10, MaxInt)+'}', TipoInfo);
                       end;
              else
                raise Exception.Create('[MENSSAG_EXIB]: Formulário Parente/Relacionado não Atribuído: '+CampOrig);
              end;

              Inst := SubsPala(Inst,'{'+CampOrig+'}',Valo);
            end
            else
            begin
              Camp := Trim(CampOrig);
              vTipo := Copy(Camp,01,02);
              Acao := Copy(Camp,03,01);
              NameCamp := Trim(Copy(Camp,04,MaxInt));
              Orig     := '';
              if Pos('-',NameCamp) > 0 then
              begin
                Orig     := Trim(Copy(NameCamp,Pos('-',NameCamp)+1,MaxInt));
                NameCamp := Trim(Copy(NameCamp,01,Pos('-',NameCamp)-1));
              end;

              try
                if AnsiUpperCase(Copy(Orig,01,4)) = 'PROC' then //Espécie de Procedure, que busca o executa em outro campo
                begin
                  if vTipo = 'PR' then   //Campos Proc0001, Proc0002 e Proc0003
                    Valo := DtmPoul.Campos_Busc(ConfTabe.CodiTabe, NameCamp, '', 'ExprCamp')
                  else
                    Valo := SubsCampPers(iForm, '{'+vTipo+'-'+NameCamp+'}', 'EXEC');
                  if AnsiUpperCase(Copy(Orig,01,08)) <> 'PROCTUDO' then //Substitui o campo Pelo Executa do Campo (usado para executar todo o executa do outro campo neste local)
                    Valo := CampPersRetoExecOutrCamp(Valo, Orig);
                end
                else if (vTipo = 'DG') then
                begin
                  vDts := nil;
                  if (sgIsMovi) and Assigned(iForm.FormRela) then  //Se for movimento e foi usado o DG, busca o campo no formulário Pai
                  begin
                    //ST: Não alterar a identação abaixo, por causa do replace no Modal.bat
                    case Func.sgTipoForm(iForm.FormRela) of
                      tfsgFrm     : vDts := TDataSource( TsgForm(iForm.FormRela).BuscaComponente('DtsGrav'));
                      tfsgFrmModal: vDts := TDataSource(TsgFormModal(iForm.FormRela).BuscaComponente('DtsGrav'));
                    end;
                    //ST: Fim
                  end
                  else
                    vDts := TDataSource(BuscaComponente('DtsGrav'));

                  if Assigned(vDts) and Assigned(vDts.DataSet) then
                    Valo := CampPersTratDadoBanc(vDts.DataSet.FieldByName(NameCamp))
                  else
                    Valo := '0'
                end
                else if StrIn(vTipo,['DM','D2','D3']) and sgIsMovi then
                begin
                  if TDataSource(BuscaComponente('DtsGrav')).DataSet <> nil then
                    Valo := CampPersTratDadoBanc(TDataSource(BuscaComponente('DtsGrav')).DataSet.FieldByName(NameCamp))
                  else
                    Valo := '0'
                end
                else if vTipo = 'DM' then
                    Valo := CampPersTratDadoBanc(TDataSource(BuscaComponente('DtsMov1')).DataSet.FieldByName(NameCamp))
                else if vTipo = 'D2' then
                    Valo := CampPersTratDadoBanc(TDataSource(BuscaComponente('DtsMov2')).DataSet.FieldByName(NameCamp))
                else if vTipo = 'D3' then
                    Valo := CampPersTratDadoBanc(TDataSource(BuscaComponente('DtsMov3')).DataSet.FieldByName(NameCamp))
                else if vTipo = 'CE' then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TDbEdtLbl(FindComponent('Edt'+NameCamp)).Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TDbEdtLbl(FindComponent('Edt'+NameCamp)).Text)
                  else
                    Valo := TDbEdtLbl(FindComponent('Edt'+NameCamp)).Lista.Text;
                end
                else if vTipo = 'CC' then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TDbCmbLbl(FindComponent('Cmb'+NameCamp)).Value)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TDbCmbLbl(FindComponent('Cmb'+NameCamp)).Value)
                  else
                    Valo := TDbCmbLbl(FindComponent('Cmb'+NameCamp)).Lista.Text
                end
                else if vTipo = 'CA' then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TDbFilLbl(FindComponent('Fil'+NameCamp)).Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TDbFilLbl(FindComponent('Fil'+NameCamp)).Text)
                  else
                    Valo := TDbFilLbl(FindComponent('Fil'+NameCamp)).Lista.Text;
                end
                else if vTipo = 'CD' then
                begin
                  if TipoInfo = 'VALO' then
                  begin
                    if Acao = 'S' then //SQLServer
                      Valo := FormDataSQL(TDbRxDLbl(FindComponent('Edt'+NameCamp)).Date)
                    else
                      Valo := FormDataSQL(TDbRxDLbl(FindComponent('Edt'+NameCamp)).Date)
                  end
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-SELECT '+FormDataSQL (TDbRxDLbl(FindComponent('Edt'+NameCamp)).Date)+' FROM DUAL'
                  else
                    Valo := TDbRxDLbl(FindComponent('Edt'+NameCamp)).Lista.Text;
                end
                else if (vTipo = 'CN') or (vTipo = 'IN') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := FormNumeSQL(TDbRxELbl(FindComponent('Edt'+NameCamp)).Value)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+FormNumeSQL(TDbRxELbl(FindComponent('Edt'+NameCamp)).Value)
                  else
                    Valo := TDbRxELbl(FindComponent('Edt'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'IL') then
                begin
                  if TipoInfo = 'VALO' then
                  begin
                    Valo := FormNumeSQL(TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado);
                    if Valo = '0' then
                      Valo := 'NULL';
                  end
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+FormNumeSQL(TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado)
                  else
                    Valo := TDBLookNume(FindComponent('Edt'+NameCamp)).Lista.Text
                end
                else if vTipo = 'CS' then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := SeStri(TDbChkLbl(FindComponent('Chk'+NameCamp)).Checked,'1','0')
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+SeStri(TDbChkLbl(FindComponent('Chk'+NameCamp)).Checked,'1','0')
                  else
                    Valo := TDbChkLbl(FindComponent('Chk'+NameCamp)).Lista.Text
                end
                else if vTipo = 'ES' then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := SeStri(TChkLbl(FindComponent('Chk'+NameCamp)).Checked,'1','0')
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+SeStri(TChkLbl(FindComponent('Chk'+NameCamp)).Checked,'1','0')
                   else
                     Valo := TChkLbl(FindComponent('Chk'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'CT') or (vTipo = 'IT') then
                begin
                  Look := TLcbLbl(FindComponent('Lcb'+NameCamp));
                  if TipoInfo = 'VALO' then
                  begin
                    if Assigned(Look) then
                    begin
                      if Look.Text = '' then
                        Valo :=   'NULL'
                      else
                        Valo := QuotedStr(NuloStri(Look.KeyValue))
                    end
                    else //Se não era um ComboLook era um NumeLook
                    begin
                      Valo := FormNumeSQL(TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado);
                      if Valo = '0' then
                        Valo :=   'NULL';
                    end;
                  end
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-{QY-'+NameCamp+'-Codi'+Copy(NameCamp,05,04)+'}'
                  else if Assigned(Look) then
                    Valo := Look.Lista.Text
                  else
                    Valo := TDBLookNume(FindComponent('Edt'+NameCamp)).Lista.Text;
                end
                else if StrIn(vTipo, ['CR','IR']) then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TDbRchLbl(FindComponent('Rch'+NameCamp)).Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TDbRchLbl(FindComponent('Rch'+NameCamp)).Text)
                  else
                    Valo := TDbRchLbl(FindComponent('Rch'+NameCamp)).Lista.Text
                end
                else if StrIn(vTipo, ['CM','IM']) then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TDbMemLbl(FindComponent('Mem'+NameCamp)).Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TDbMemLbl(FindComponent('Mem'+NameCamp)).Text)
                  else
                    Valo := TDbMemLbl(FindComponent('Mem'+NameCamp)).Lista.Text;
                  //retorna para sql
                  if Acao = 'S' then
                    Valo := SubsPalaTudo(Valo,sgLn,'''|| chr(13) ||''');
                end
                else if StrIn(vTipo, ['ET']) then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TMemLbl(FindComponent('Mem'+NameCamp)).Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TMemLbl(FindComponent('Mem'+NameCamp)).Text)
                  else
                    Valo := TMemLbl(FindComponent('Mem'+NameCamp)).Lista.Text;
                  //retorna para sql
                  if Acao = 'S' then
                    Valo := SubsPalaTudo(Valo, sgLn,'''|| chr(13) ||''');
                end
                else if (vTipo = 'RS') or (vTipo = 'RE') or (vTipo = 'RI') or
                        (vTipo = 'RP') or (vTipo = 'RX') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TAdvMemLbl(FindComponent('Mem'+NameCamp)).Lines.Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TAdvMemLbl(FindComponent('Mem'+NameCamp)).Lines.Text)
                  else
                    Valo := TAdvMemLbl(FindComponent('Mem'+NameCamp)).Lista.Text;
                  //retorna para sql
                  if Acao = 'S' then
                    Valo := SubsPalaTudo(Valo, sgLn,'''|| chr(13) ||''');
                end
                else if (vTipo = 'LE') or (vTipo = 'IE') or (vTipo = 'EE') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TEdtLbl(FindComponent('Edt'+NameCamp)).Text)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TEdtLbl(FindComponent('Edt'+NameCamp)).Text)
                  else
                    Valo := TEdtLbl(FindComponent('Edt'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'EA')  then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(SubsPala(TFilLbl(FindComponent('Fil'+NameCamp)).Text,'"',''))
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(SubsPala(TFilLbl(FindComponent('Fil'+NameCamp)).Text,'"',''))
                  else
                    Valo := TFilLbl(FindComponent('Fil'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'EI')  then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(SubsPala(TDirLbl(FindComponent('Dir'+NameCamp)).Text,'"',''))
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(SubsPala(TDirLbl(FindComponent('Dir'+NameCamp)).Text,'"',''))
                  else
                    Valo := TDirLbl(FindComponent('Dir'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'EC') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := QuotedStr(TCmbLbl(FindComponent('Cmb'+NameCamp)).Value)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+QuotedStr(TCmbLbl(FindComponent('Cmb'+NameCamp)).Value)
                  else
                    Valo := TCmbLbl(FindComponent('Cmb'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'ED') then
                begin
                  if TipoInfo = 'VALO' then
                    if Acao = 'S' then
                      Valo := FormDataStri(TRXDatLbl(FindComponent('Edt'+NameCamp)).Date)
                    else
                      Valo := FormDataSQL (TRXDatLbl(FindComponent('Edt'+NameCamp)).Date)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-SELECT '+FormDataSQL (TRXDatLbl(FindComponent('Edt'+NameCamp)).Date)+' FROM DUAL'
                  else
                    Valo := TRXDatLbl(FindComponent('Edt'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'LN') or (vTipo = 'EN') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := FormNumeSQL(TRxEdtLbl(FindComponent('Edt'+NameCamp)).Value)
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+FormNumeSQL(TRxEdtLbl(FindComponent('Edt'+NameCamp)).Value)
                  else
                    Valo := TRxEdtLbl(FindComponent('Edt'+NameCamp)).Lista.Text;
                end
                else if (vTipo = 'EL') then
                begin
                  if TipoInfo = 'VALO' then
                  begin
                    Valo := FormNumeSQL(TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado);
                    if Valo = '0' then
                      Valo :=   'NULL';
                  end
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-'+FormNumeSQL(TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado)
                  else
                    Valo := TDBLookNume(FindComponent('Edt'+NameCamp)).Lista.Text;
                end
                else if (vTipo = 'BT') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := ''
                  else if TipoInfo = 'TEST' then
                    Valo := ''
                  else
                    Valo := TsgBtn(FindComponent('Btn'+NameCamp)).Lista.Text;
                end
                else if (vTipo = 'QY') then
                begin
                  if Pos('.',NameCamp) > 0 then
                  begin
                    Orig     := Copy(NameCamp, Pos('.',NameCamp)+1, MaxInt);
                    NameCamp := Copy(NameCamp, 01, Pos('.',NameCamp)-1);
                  end;
                  vQuer := TsgQuery(iForm.BuscaComponente('Qry'+NameCamp));
                  //vQuer := TsgQuery(FindComponent('Qry'+NameCamp));
                  if TipoInfo = 'VALO' then
                  begin
                    Orig := Trim(Orig);
                    if not vQuer.Active then
                      Valo := QuotedStr('0') //FormNumeSQL(0)
                    else if AnsiUpperCase(Orig) = 'NUMEREGI' then
                      Valo := FormNumeSQL(vQuer.RecordCount)
                    else if AnsiUpperCase(Copy(Orig,01,Length('SUM('))) = 'SUM(' then
                      Valo := FormNumeSQL(vQuer.Soma(SubsPala(Copy(Orig,Pos('(',Orig)+1,MaxInt),')','')))
                    else if AnsiUpperCase(Copy(Orig,01,Length('SOMA('))) = 'SOMA(' then
                      Valo := FormNumeSQL(vQuer.Soma(SubsPala(Copy(Orig,Pos('(',Orig)+1,MaxInt),')','')))
                    else if AnsiUpperCase(Copy(Orig,01,Length('LISTAIN('))) = 'LISTAIN(' then
                      Valo := vQuer.ListaIn(SubsPala(Copy(Orig,Pos('(',Orig)+1,MaxInt),')',''))
                    else if AnsiUpperCase(Copy(Orig,01,Length('EXIBDADO'))) = 'EXIBDADO' then
                      Valo := ExibDadoQuer(vQuer, True, True)
                    else if IsDigit(Orig) then
                      Valo := CampPersTratDadoBanc(vQuer.Fields[sgStrToInt(Orig)])
                    else
                      Valo := CampPersTratDadoBanc(vQuer.FieldByName(Orig))
                  end
                  else
                    Valo := vQuer.Lista.Text;
                end
                else if (vTipo = 'QC') then
                begin
                  if TipoInfo = 'VALO' then
                  begin
                    if AnsiUpperCase(Orig) = 'NUMEREGI' then
                      Valo := FormNumeSQL(DtmPoul.cdsBaseAuxi.RecordCount)
                    else if DtmPoul.cdsBaseAuxi.Active then
                      Valo := CampPersTratDadoBanc(DtmPoul.cdsBaseAuxi.FieldByName(Orig))
                    else
                      Valo := 'NULL';  //Query Fechada
                  end
                  else
                    Valo := DtmPoul.cdsBaseAuxi.Lista.Text;
                end
                else if (vTipo = 'LB') then
                  Valo := QuotedStr(TsgLbl(FindComponent('Lbl'+NameCamp)).Caption)

                {$ifdef ERPUNI}
                {$else}
                  else if (vTipo = 'QE') then  //QuickReport - Edit
                    Valo := TQRDBText(FindComponent('Edt'+Camp)).Caption
                  else if (vTipo = 'QL') then  //QuickReport - Label
                    Valo := TQRLabel(FindComponent('Lbl'+Camp)).Caption
                  else if (vTipo = 'QS') then  //QuickReport - Sys
                    Valo := TQRSysData(FindComponent('Sys'+Camp)).Caption
                  else if (vTipo = 'QX') then  //QuickReport - Exp
                    Valo := TQRExpr(FindComponent('Exp'+Camp)).Caption
                {$endif}

                else if (vTipo = 'GC') then
                begin
                  if TipoInfo = 'VALO' then
                    Valo := IntToStr(TsgDBG(BuscaComponente('Dbg'+NameCamp)).sgColuIndi)
                  else
                    Valo := TsgDBG(BuscaComponente('Dbg'+NameCamp)).Lista.Text
                end
                else if (vTipo = 'VA') then
                begin
                  NameCamp := AnsiUpperCase(NameCamp);
                  if NameCamp = 'INSERIND' then
                    {$ifdef ERPUNI}
                      Valo := SeStri(PSitGrav, '1', '0')
                    {$else}
                      Valo := SeStri(sgCopy(Caption,01,06) = sgCopy(sAlteracao,01,06), '0', '1')
                    {$endif}
                  else if StrIn(NameCamp, ['DATE', 'DATA']) then  //tem que ser antes do Data00XX
                    Valo := FormDataSQL(SysUtils.Date)
                  else if StrIn(NameCamp, ['DATEBRAS', 'DATABRAS']) then
                    Valo := FormDataBras(SysUtils.Date)
                  else if StrIn(NameCamp, ['TIME', 'HORA']) then
                    Valo := QuotedStr(TimeToStr(SysUtils.Time))
                  else if NameCamp = 'OPERACAO' then
                    Valo := SeStri(ConfTabe.Operacao=opIncl,'I',SeStri(ConfTabe.Operacao=opAlte,'A','E'))
                  else if NameCamp = 'OPERMOVI' then
                    Valo := SeStri(ConfTabe.ConfMovi.Operacao=opIncl,'I',SeStri(ConfTabe.ConfMovi.Operacao=opAlte,'A','E'))
                  else if NameCamp = 'INSEMOV1' then
                    Valo := SeStri(TDataSource(BuscaComponente('DtsMov1')).DataSet.State = dsInsert, '1', '0')
                  else if NameCamp = 'INSEMOV2' then
                    Valo := SeStri(TDataSource(BuscaComponente('DtsMov2')).DataSet.State = dsInsert, '1', '0')
                  else if NameCamp = 'INSEMOV3' then
                    Valo := SeStri(TDataSource(BuscaComponente('DtsMov3')).DataSet.State = dsInsert, '1', '0')
                  else if NameCamp = 'CONFIRMA' then
                    Valo := QuotedStr(iForm.Confirma)
                  else if Copy(NameCamp,01,04) = 'STRI' then
                    Valo := QuotedStr(iForm.VariStri[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'VALO' then
                    Valo :=           iForm.VariValo[StrToInt(Copy(Trim(NameCamp),05,04))]
                  else if Copy(NameCamp,01,04) = 'RESU' then
                    Valo :=           iForm.VariResu[StrToInt(Copy(Trim(NameCamp),05,04))]
                  else if Copy(NameCamp,01,04) = 'INTE' then
                    Valo := FormNumeSQL(iForm.VariInte[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'DATA' then
                    Valo := FormDataSQL(iForm.VariData[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'REAL' then
                    Valo := FormNumeSQL(iForm.VariReal[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if NameCamp = 'PDA1MANU' then
                    Valo := FormDataSQL(GetConfWeb.PDa1Manu)
                  else if NameCamp = 'PDA2MANU' then
                    Valo := FormDataSQL(GetConfWeb.PDa2Manu)
                  else if NameCamp = 'RETOFUNC' then
                    Valo := QuotedStr(iForm.RetoFunc)
                  else if NameCamp = 'NUMEBASE' then
                    Valo := FormNumeSQL(GetPBas())
                  else if NameCamp = 'FECHCONF' then
                    Valo := SeStri(iForm.ConfTabe.FechaConfirma, '1', '0')
                  else if NameCamp = 'CODITABE' then
                    //Sidi - Quando abre outro formulario, perde o CodiTabe do Origem
                    //Valo := FormNumeSQL(GetPTab())
                    Valo := FormNumeSQL(iForm.HelpContext)
                  else if NameCamp = 'CODIMOVI' then
                    Valo := FormNumeSQL(iForm.ConfTabe.ConfMovi.CodiTabe)
                  else if NameCamp = 'CODIUSUA' then
                    Valo := FormNumeSQL(GetPUsu())
                  else if NameCamp = 'CODIPESS' then
                    Valo := FormNumeSQL(GetPUsu())
                  else if StrIn(NameCamp, ['PCODPESS', 'RETOPUSU']) then
                    Valo := QuotedStr(GetPCodPess())
                  else if StrIn(NameCamp, ['CODISIST','CODIPROD']) then
                    Valo := FormNumeSQL(GetPSis())
                  else if StrIn(NameCamp, ['PCODSIST','PSIS','GETPSIS','RETOPSIS']) then
                    Valo := QuotedStr(GetPCodSist())
                  else if NameCamp = 'NOMESIST' then
                    Valo := QuotedStr(GetPNomAbreSoft())
                  else if NameCamp = 'EMPRESA' then
                    Valo := QuotedStr(GetEmpresa())
                  else if NameCamp = 'CODITEST' then
                    Valo := IntToStr(GetConfWeb.pCodTest)
                  else if NameCamp = 'NOMETEST' then
                    Valo := QuotedStr(GetConfWeb.PNomTest)
                  else if NameCamp = 'CODIEMPR' then
                    Valo := IntToSTR(GetPEmp())
                  else if StrIn(NameCamp, ['PCODEMPR', 'RETOPEMP']) then
                    Valo := QuotedStr(GetPCodEmpr())
                  else if NameCamp = 'USUAMONI' then
                    Valo := QuotedStr(RetoUserBase())
                  else if NameCamp = 'VERSMONI' then
                    Valo := QuotedStr(RetoVers())
                  else if NameCamp = 'IP__MONI' then
                    Valo := QuotedStr(PegaIP())
                  else if NameCamp = 'MAQUMONI' then
                    Valo := QuotedStr(PegaMaqu())
                  else if NameCamp = 'WINDMONI' then
                    Valo := QuotedStr(PegaUsuaWind())
                  else if NameCamp = 'ENDEMONI' then
                    Valo := QuotedStr(GetPEndExecOrig+GetPNomExec)
                  else if NameCamp = 'TRANSACT' then
                    Valo := SeStri(GetPADOConn.InTransaction,'1','0')
                  else if StrIn(NameCamp, ['DATETIME', 'DATAHORA']) then
                    Valo := QuotedStr(DateTimeToStr(Now))
                  else if NameCamp = 'CODIIDIO' then
                    Valo := FormNumeSQL(GetCodiIdio())
                  else if NameCamp = 'CODIPAIS' then
                    Valo := FormNumeSQL(GetConfWeb.CodiPais)
                  else if NameCamp = 'PSAGCHAV' then
                    Valo := QuotedStr(iForm.ConfTabe.ValoSgCh)
                  else if StrIn(NameCamp, ['ERP_UNIG', 'ERPUNI']) then
                    Valo := {$ifdef ERPUNI} '1' {$else} '0' {$endif}
                  else if StrIn(NameCamp, ['ISMOBILE', 'MOBILE']) then
                    Valo := SeStri(GetConfWeb.Modo = cwModoMobile, '1', '0')
                  else if StrIn(NameCamp, ['ISBROWSE', 'BROWSER']) then
                    Valo := SeStri(GetConfWeb.Modo = cwModoBrowser, '1', '0')
                  else if StrIn(NameCamp, ['ISDESKTO', 'DESKTOP']) then
                    Valo := SeStri(GetConfWeb.Modo = cwDesktop, '1', '0')
                  else if NameCamp = 'PRATICA' then
                    Valo := {$ifdef Pratica} '1' {$else} '0' {$endif}
                  else if NameCamp = 'ENDEEXEC' then
                    Valo := QuotedStr(GetPEndExec)
                  else if NameCamp = 'ENDEORIG' then
                    Valo := QuotedStr(GetPEndExecOrig)
                  else if NameCamp = 'PROJETO' then
                    Valo := QuotedStr(PegaPara(0,'Projeto'))
                  else if NameCamp = 'ESTOSETO' then
                    Valo := SeStri(DmPlus.GetPegaPara_CalcEstoSeto(),'1','0');
                  ;
                end
                else if (vTipo = 'VP') then
                begin
                  NameCamp := AnsiUpperCase(NameCamp);
                       if Copy(NameCamp,01,04) = 'STRI' then
                    Valo := QuotedStr(iForm.PersStri[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'VALO' then
                    Valo :=           iForm.PersValo[StrToInt(Copy(Trim(NameCamp),05,04))]
                  else if Copy(NameCamp,01,04) = 'RESU' then
                    Valo :=           iForm.PersResu[StrToInt(Copy(Trim(NameCamp),05,04))]
                  else if Copy(NameCamp,01,04) = 'INTE' then
                    Valo := FormNumeSQL(iForm.PersInte[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'DATA' then
                    Valo := FormDataSQL(iForm.PersData[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'REAL' then
                    Valo := FormNumeSQL(iForm.PersReal[StrToInt(Copy(Trim(NameCamp),05,04))]);
                end
                else if (vTipo = 'PU') then
                begin
                  NameCamp := AnsiUpperCase(NameCamp);
                       if Copy(NameCamp,01,04) = 'STRI' then
                    Valo := QuotedStr(GetConfWeb.PublStri[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'VALO' then
                    Valo :=           GetConfWeb.PublValo[StrToInt(Copy(Trim(NameCamp),05,04))]
                  else if Copy(NameCamp,01,04) = 'INTE' then
                    Valo := FormNumeSQL(GetConfWeb.PublInte[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'DATA' then
                    Valo := FormDataSQL(GetConfWeb.PublData[StrToInt(Copy(Trim(NameCamp),05,04))])
                  else if Copy(NameCamp,01,04) = 'REAL' then
                    Valo := FormNumeSQL(GetConfWeb.PublReal[StrToInt(Copy(Trim(NameCamp),05,04))])
                end
                else if (vTipo = 'LC') then
                begin
                  Lst := TLstLbl(FindComponent('Lst'+NameCamp));
                  if TipoInfo = 'VALO' then
                  begin
                    if AnsiUpperCase(Orig) = 'NUMETOTA' then
                      Valo := FormNumeSQL(Lst.NumeTota)
                    else if AnsiUpperCase(Orig) = 'NUMESELE' then
                      Valo := FormNumeSQL(Lst.NumeSele)
                    else if AnsiUpperCase(Orig) = 'NUMENAOS' then
                      Valo := FormNumeSQL(Lst.NumeNao_Sele)
                    else if AnsiUpperCase(Orig) = 'CODIATUA' then
                      Valo := Lst.CodiAtua
                    else if AnsiUpperCase(Copy(Orig,01,Length('SUM('))) = 'SUM(' then
                      Valo := FormNumeSQL(Lst.Soma(SubsPala(Copy(Orig,Pos('(',Orig)+1,MaxInt),')','')))
                    else if AnsiUpperCase(Copy(Orig,01,Length('SOMA('))) = 'SOMA(' then
                      Valo := FormNumeSQL(Lst.Soma(SubsPala(Copy(Orig,Pos('(',Orig)+1,MaxInt),')','')))
                    else if AnsiUpperCase(Copy(Orig,01,Length('LISTAIN('))) = 'LISTAIN(' then
                      Valo := Lst.ListaIn(SubsPala(Copy(Orig,Pos('(',Orig)+1,MaxInt),')',''))
                    else if AnsiUpperCase(Copy(Orig,01,Length('EXIBDADO'))) = 'EXIBDADO' then
                      Valo := ExibDadoQuer(Lst.Query, True, True)
                    else
                      Valo := Lst.ListaIn(Orig);
                  end
                  else if TipoInfo = 'TEST' then
                    Valo := vTipo+'-'+NameCamp+'-(0)'
                  else
                    Valo := Lst.Lista.Text;
                end
                else if (vTipo = 'NF') then
                begin
                  {$ifdef ERPUNI}
                    Valo := PlusUni.WS_ExecPLSAG(iForm, Inst).Msg;
                  {$else}
                    if AnsiUpperCase(NameCamp) = 'CERTDIGI' then  //Certificado Digital
                      Valo := QuotedStr(NFe_XML_PegaCertDigi());
                  {$endif}
                end
                else if (vTipo = 'N2') then
                begin
                  {$ifdef ERPUNI}
                    Valo := PlusUni.WS_ExecPLSAG(iForm, Inst).Msg;
                  {$else}
                    if AnsiUpperCase(NameCamp) = 'CERTDIGI' then  //Certificado Digital
                      Valo := QuotedStr(NFe_XML_PegaCertDigi_V20());
                  {$endif}
                end
                else if (vTipo = 'OD') then
                begin
                  //OD-Prin_D.VDCaMvPo.ValoMvPo
                  Valo := CampPers_OD(iForm, '{'+CampOrig+'}');
                end
                else
                begin
                  Inst := SubsPala(Inst,'{'+CampOrig+'}','[/]'+CampOrig+'[\]');
                  Continue;  //Não caiu em nada, deixa a string como estava
                end;

                if TipoInfo = 'EXEC' then
                  Valo := SubsPala(SubsPala(Valo,'{','[/]'),'}','[\]');

                if Copy(AnsiUpperCase(CampOrig),01,07) <> 'VA-VALO' then  //Deixar as "aspas" quando não for o Valo
                begin
                  Inst := SubsPala(Inst,'''{','{');
                  Inst := SubsPala(Inst,'}''','}');
                end;
                Inst := SubsPala(Inst,'{'+CampOrig+'}',Valo);
              except
                on E: Exception do
                  vMensagem := E.Message;
              end;
              if msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema no Campo ''{'+CampOrig+'}'' na instrução'+sgLn+
                                             Inst+sgLn+
                                             sgLn+
                                             'Mensagem Interna:'+sgLn+
                                             vMensagem) then
              begin
                Inst := '';
                Exit;
              end;
            end;
          end;
          ListValo[i] := SubsPala(SubsPala(Inst, '[/]','{'),'[\]','}');  //Para resolver o problema dos campos expressão na instrução SQL
        end;

        Inc(i);
      end;
    end;
    if ListValo.Count = 1 then
      Result := ListValo[0]
    else
      Result := ListValo.Text;
  finally
    ListValo.Free;
  end;
end;

//Inicializa e Grava Valores de Campos Personalizados Parâmetros
//Inic: True, Inicializa, senão, grava
Procedure CampPersInicGravPara(iForm: TsgForm; CodiTabe: Integer; Gera, Inic: Boolean);
var
  NomeCamp, NameCamp: string;
  lCodiTabe: integer;
  cds: TClientDataSet;
begin
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    try
      cds := DtmPoul.Campos_Cds(CodiTabe, '', '(ExisCamp = 0) '+
                                              'AND ((CompCamp <> ''EN'') '+
                                              'OR (CompCamp <> ''ED'') '+
                                              'OR (CompCamp <> ''EE'') '+
                                              'OR (CompCamp <> ''EC'') '+
                                              'OR (CompCamp <> ''EA'') '+
                                              'OR (CompCamp <> ''EI'') '+
                                              'OR (CompCamp <> ''ES'') '+
                                              'OR (CompCamp <> ''IT'') '+
                                              'OR (CompCamp <> ''ET'') '+
                                              'OR (CompCamp <> ''RS'') '+
                                              'OR (CompCamp <> ''RE'') '+
                                              'OR (CompCamp <> ''RI'') '+
                                              'OR (CompCamp <> ''RP'') '+
                                              'OR (CompCamp <> ''RX''))');
      cds.IndexFieldNames := 'GuiaCamp;OrdeCamp';
      cds.First;
      while not(cds.Eof) do
      begin
        lCodiTabe := SeInte(Gera,0,SeInte(cds.FieldByName('InteCamp').AsInteger=0,CodiTabe,0));  //Se for gera, não passa o CodiTabe, passa 0, que só ira buscar pelo nome
        NomeCamp := cds.FieldByName('NomeCamp').AsString;
        NameCamp := cds.FieldByName('NameCamp').AsString;
        //************************************************************************************
        if (cds.FieldByName('CompCamp').AsString = 'EN') then
        begin
          if Inic then
            TRxEdtLbl(FindComponent('Edt'+NameCamp)).Value := PegaParaNume(lCodiTabe, NomeCamp)
          else
            GravParaNume(lCodiTabe, NomeCamp, TRxEdtLbl(FindComponent('Edt'+NameCamp)).Value, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'ED') then
        begin
          if Inic then
            TRxDatLbl(FindComponent('Edt'+NameCamp)).Date := PegaParaData(lCodiTabe, NomeCamp)
          else
            GravParaData(lCodiTabe, NomeCamp, TRxDatLbl(FindComponent('Edt'+NameCamp)).Date, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'EE') then
        begin
          if Inic then
            TEdtLbl(FindComponent('Edt'+NameCamp)).Text := PegaPara(lCodiTabe, NomeCamp)
          else
            GravPara(lCodiTabe, NomeCamp, TEdtLbl(FindComponent('Edt'+NameCamp)).Text, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        else if (cds.FieldByName('CompCamp').AsString = 'EA') then
        begin
          if Inic then
            TFilLbl(FindComponent('Fil'+NameCamp)).Text := PegaPara(lCodiTabe, NomeCamp)
          else
            GravPara(lCodiTabe, NomeCamp, TFilLbl(FindComponent('Fil'+NameCamp)).Text, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        else if (cds.FieldByName('CompCamp').AsString = 'EI') then
        begin
          if Inic then
            TDirLbl(FindComponent('Dir'+NameCamp)).Text := PegaPara(lCodiTabe, NomeCamp)
          else
            GravPara(lCodiTabe, NomeCamp, TDirLbl(FindComponent('Dir'+NameCamp)).Text, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'ES') then
        begin
          if Inic then
            TChkLbl(FindComponent('Chk'+NameCamp)).Checked := PegaParaLogi(lCodiTabe, NomeCamp)
          else
            GravParaLogi(lCodiTabe, NomeCamp, TChkLbl(FindComponent('Chk'+NameCamp)).Checked, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'EC') then
        begin
          if Inic then
            TCmbLbl(FindComponent('Cmb'+NameCamp)).Value := PegaPara(lCodiTabe, NomeCamp)
          else
            GravPara(lCodiTabe, NomeCamp, TCmbLbl(FindComponent('Cmb'+NameCamp)).Value, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0)
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'ET') then
        begin
          if Inic then
            TMemLbl(FindComponent('Mem'+NameCamp)).Text := PegaParaMemo(lCodiTabe, NomeCamp)
          else
            GravParaMemo(lCodiTabe, NomeCamp, TMemLbl(FindComponent('Mem'+NameCamp)).Lines, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'RS') or
                (cds.FieldByName('CompCamp').AsString = 'RE') or
                (cds.FieldByName('CompCamp').AsString = 'RI') or
                (cds.FieldByName('CompCamp').AsString = 'RP') or
                (cds.FieldByName('CompCamp').AsString = 'RX') then
        begin
          if Inic then
            TAdvMemLbl(FindComponent('Mem'+NameCamp)).Lines.Text := PegaParaMemo(lCodiTabe, NomeCamp)
          else
            GravParaMemo(lCodiTabe, NomeCamp, TAdvMemLbl(FindComponent('Mem'+NameCamp)).Lines, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'IT') then
        begin
          if Inic then
            TLcbLbl(FindComponent('Lcb'+NameCamp)).KeyValue := PegaParaNume(lCodiTabe, NomeCamp)
          else
            GravParaNume(lCodiTabe, NomeCamp, TLcbLbl(FindComponent('Lcb'+NameCamp)).ValorInteiro, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end
        //************************************************************************************
        else if (cds.FieldByName('CompCamp').AsString = 'IL') then
        begin
          if Inic then
            TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado := PegaParaNume(lCodiTabe, NomeCamp)
          else
            GravParaNume(lCodiTabe, NomeCamp, TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado, 0, cds.FieldByName('PoEmCamp').AsInteger <> 0);
        end;
        cds.Next;
      end;
    finally
      cds.Close;
      FreeAndNil(cds);
    end;
  end;
end;

//Inicializa Valores de Campos Personalizados
Procedure InicValoCampPers(iForm: TsgForm; CodiTabe: Integer; DataSour: TDataSource; Inse: Boolean);
var
  NomeCamp, NameCamp, CompCamp: String;
  Auxi: TStringList;
  Look: TDBLcbLbl;
  cds: TClientDataSet;
  Qry: TsgQuery;
begin
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    Auxi := TStringList.Create;
    try
      cds := DtmPoul.Campos_Cds(CodiTabe, '', '(ExisCamp = 0) '+
                                    'AND (InicCamp = 1 OR (MascCamp IS NOT NULL AND MascCamp <> ''''))'+
                                    'AND (CompCamp <> ''LN'') '+
                                    'AND (CompCamp <> ''LE'') '+
                                    'AND (CompCamp <> ''BVL'') '+
                                    'AND (CompCamp <> ''IN'') '+
                                    'AND (CompCamp <> ''IE'') '+
                                    'AND (CompCamp <> ''IM'') '+
                                    'AND (CompCamp <> ''IR'') '+
                                    'AND (CompCamp <> ''LBL'') '+
                                    'AND (CompCamp <> ''BTN'') '+
                                    'AND (CompCamp <> ''DBG'') '+
                                    'AND (CompCamp <> ''GRA'') '+
                                    'AND (CompCamp <> ''FE'') '+
                                    'AND (CompCamp <> ''FI'') '+
                                    'AND (CompCamp <> ''FF'') '+
                                    'AND (CompCamp <> ''LC'') '+
                                    'AND (CompCamp <> ''TIM'')');
      cds.IndexFieldNames := 'GuiaCamp;OrdeCamp';
      cds.First;
      while not(cds.Eof) do
      begin
        NomeCamp := cds.FieldByName('NomeCamp').AsString;
        NameCamp := cds.FieldByName('NameCamp').AsString;
        CompCamp := cds.FieldByName('CompCamp').AsString;

        if TestDataSet(DataSour) then
        begin
          //E d i t o r
          if StrIn(CompCamp, ['E', 'A', 'M', 'BM', 'BS', 'BE', 'BI', 'BP', 'BX', 'RS', 'RE', 'RI', 'RP', 'RX']) then
          begin
            if Inse then
              DataSour.DataSet.FieldByName(NomeCamp).AsString := cds.FieldByName('VaGrCamp').AsString;
          end
          //************************************************************************************
          //C o m b o
          else if (CompCamp = 'C') then
          begin
            if Inse then
            begin
              Auxi.Text := cds.FieldByName('VaGrCamp').AsString;
              DataSour.DataSet.FieldByName(NomeCamp).AsString := Auxi.Strings[0];
            end;
          end
          //************************************************************************************
          //N ú m e r o
          else if (CompCamp = 'N') then
          begin
            if Inse then
            begin
              if (cds.FieldByName('TagQCamp').AsInteger = 1) then  //Sequencial
              begin
                if Assigned(iForm) then
                  DataSour.DataSet.FieldByName(NomeCamp).AsFloat := POCaNume_ProxSequ(DtmPoul.Tabelas_Busc('GravTabe', '(CodiTabe = '+IntToStr(cds.FieldByName('CodiTabe').AsInteger)+')'),
                                                                                      NomeCamp, False, iForm.sgTransaction)
                else
                  DataSour.DataSet.FieldByName(NomeCamp).AsFloat := POCaNume_ProxSequ(DtmPoul.Tabelas_Busc('GravTabe', '(CodiTabe = '+IntToStr(cds.FieldByName('CodiTabe').AsInteger)+')'),
                                                                                      NomeCamp, False, nil);
              end
              else
                DataSour.DataSet.FieldByName(NomeCamp).AsFloat := cds.FieldByName('PadrCamp').AsFloat;
            end;
          end
          //************************************************************************************
          //T a b e l a
          else if (CompCamp = 'T') then
          begin
            if Inse and TsgQuery(FindComponent('Qry'+NameCamp)).Active then //Não obrigatório
            begin
               Look := TDBLcbLbl(FindComponent('Lcb'+NameCamp));
               Look.SetNovoValor_Query;
               Look.Text := Look.Text;
               Look.KeyValue := TsgQuery(FindComponent('Qry'+NameCamp)).Fields[0].Value;
               if Assigned(DataSour.DataSet) then
                 DataSour.DataSet.FieldByName(NomeCamp).Value := Look.KeyValue;
            end;
          end
          //************************************************************************************
          //N ú m e r o   T a b e l a
          else if (CompCamp = 'L') then
          begin
            if Inse and TsgQuery(FindComponent('Qry'+NameCamp)).Active then //Não obrigatório
            begin
              TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado := TsgQuery(FindComponent('Qry'+NameCamp)).Fields[0].AsFloat;
            end;
          end
          //************************************************************************************
          //D a t a
          else if (CompCamp = 'D') then
          begin
            if Inse then
            begin
              DataSour.DataSet.FieldByName(NomeCamp).AsDateTime := TDbRxDLbl(FindComponent('Edt'+NameCamp)).DataEntr;
              if DataSour.DataSet.FieldByName(NomeCamp).AsDateTime = 0 then
                DataSour.DataSet.FieldByName(NomeCamp).AsDateTime := Date;
            end
          end
          //************************************************************************************
          //S i m   /   N ã o
          else if (CompCamp = 'S') then
          begin
            if Inse then
            begin
              DataSour.DataSet.FieldByName(NomeCamp).Value := SeInte(cds.FieldByName('PadrCamp').AsInteger = 0, 0, 1);
            end;
          end
        end;  //DataSet <> nil

        //E d i t o r  (Máscara)
        if StrIn(CompCamp, ['E', 'A', 'M', 'BM']) then
        begin
          DataSour.DataSet.FieldByName(NomeCamp).Tag := 10;
          if (CompCamp = 'E') then
          begin
            if (CodiTabe = 50020) and (NomeCamp.ToUpper = 'NUMEPLAN') then
              TDBEdtLbl(FindComponent('Edt'+cds.FieldByName('NameCamp').AsString)).sgConf.Mask := CalcStri('SELECT TEXTMASC FROM CTCAMASC')
            else
              TDBEdtLbl(FindComponent('Edt'+cds.FieldByName('NameCamp').AsString)).sgConf.Mask   := cds.FieldByName('MascCamp').AsString;
          end;

          if cds.FieldByName('MascCamp').AsString <> '' then
          begin
            //Estava setando para Modificado na alteração
            if (CompCamp = 'E') then
              TDBEdtLbl(FindComponent('Edt'+cds.FieldByName('NameCamp').AsString)).Modified := False
            else if (CompCamp = 'A') then
              TDBFilLbl(FindComponent('Fil'+cds.FieldByName('NameCamp').AsString)).Modified := False
            else
              TDBMemLbl(FindComponent('Mem'+cds.FieldByName('NameCamp').AsString)).Modified := False
          end;
        end
        //************************************************************************************
        //T a b e l a   I n f o r m a d a
        else if (CompCamp = 'IT') then
        begin
          TLcbLbl(FindComponent('Lcb'+NameCamp)).KeyValue := TsgQuery(FindComponent('Qry'+NameCamp)).Fields[0].Value;
        end
        //************************************************************************************
        //N ú m e r  o   T a b e l a   I n f o r m a d a
        else if (CompCamp = 'IL') then
        begin
          Qry := TsgQuery(FindComponent('Qry'+NameCamp));
          if Assigned(Qry) and Qry.Active then
            TDBLookNume(FindComponent('Edt'+NameCamp)).ValorGravado := Qry.Fields[0].AsFloat;
        end
        //************************************************************************************
        //E d i t o r - D a t a
        else if (CompCamp = 'ED') then
        begin
          TRxDatLbl(FindComponent('Edt'+NameCamp)).Date := Date;
        end
        //************************************************************************************
        //Editor Sim/Não
        else if (CompCamp = 'ES') then
        begin
          TChkLbl(FindComponent('Chk'+NameCamp)).Checked := (cds.FieldByName('PadrCamp').AsInteger = 1);
        end
        //************************************************************************************
        //Editor C o m b o
        else if (CompCamp = 'EC') then
        begin
          //Para executar o onchange
          TCmbLbl(FindComponent('Cmb'+NameCamp)).ItemIndex  := 0;
        end
        //************************************************************************************
        //Editor Número
        else if (CompCamp = 'EN') then
        begin
          if (cds.FieldByName('TagQCamp').AsInteger = 1) then  //Sequencial
            TRxEdtLbl(FindComponent('Edt'+NameCamp)).Value := POCaNume_ProxSequ(DtmPoul.Tabelas_Busc('GravTabe', '(CodiTabe = '+IntToStr(cds.FieldByName('CodiTabe').AsInteger)+')'),
                                                                                NomeCamp, False)
          else
            TRxEdtLbl(FindComponent('Edt'+NameCamp)).Value := cds.FieldByName('PadrCamp').AsFloat;
        end;
        cds.Next;
      end;
    finally
      cds.Close;
      FreeAndNil(cds);
      Auxi.Free;
    end;
    //ST (06/09/2023): Estava chmando duas vezes, aqui e no TFrmPOsgForm.FormShow
    //iForm.AnteShow();
  end;
end;

//Buscar no outro campo o execute conforme tag enviada na linha
function CampPersRetoExecOutrCamp(Exec, Chav: String): String;
var
  i: Integer;
  ListExec, ListReto: TStringList;
  Acho : Boolean;
begin
  ListExec := TStringList.Create();
  ListReto := TStringList.Create();
  try
    //Pega somente as linhas deste EXEC
    Chav := AnsiUpperCase(Chav);
    ListExec.Text := Exec;
    Acho := False;
    for i := 0 to ListExec.Count-1 do
    begin
      if AnsiUpperCase(Trim(ListExec[i])) = '--'+Chav+'INIC' then
        Acho := True
      else if AnsiUpperCase(Trim(ListExec[i])) = '--'+Chav+'FINA' then
        Acho := False;

      if Acho and (AnsiUpperCase(Trim(ListExec[i])) <> '--'+Chav+'INIC') then
        ListReto.Add(ListExec[i]);
    end;
    //Fim do Pega linhas
    Result := ListReto.Text;
  finally
    ListExec.Free;
    ListReto.Free;
  end;
end;

//Executar o Exit, chamando a função para executar as instruções contidas na Lista
procedure CampPersExecExit(iForm: TsgForm; Sender: TObject; ExecShow: Boolean = False);
var
  List: TStrings;
begin
  List := TStringList.Create;
  try
    List.Text := CampPersRetoListExec(iForm, Sender);
    if List.Count > 0 then
    begin
      try
        ExibMensHint('Executa na Saída do Campo '+TComponent(Sender).Name);
      except
      end;
      CampPersExecListInst(iForm, List);
      try
        ExibMensHint('Fim Executa na Saída do Campo '+TComponent(Sender).Name);
      except
      end;
      ExibMensHint('');
    end;
  finally
    List.Free;
  end;
end;

//Retornar a lista de execução do componente passado
function CampPersRetoListExec(iForm: TsgForm; Sender: TObject): String;
begin
  Result := CampPersCompAtuaGetProp(iForm, Sender, 'Lista');
  Result := CampPers_TratExec(iForm, Result, '');
end;

//Executar a Lista de Instruções na Saída do Campo
Function CampPersExecListInst(iForm: TsgForm; List: TStrings; const iComp: TObject = nil): Boolean;
var
  NumeLinh : Integer;
  Linh, vLinh: String;
  Camp, Acao: string;
  sAux1, sAux2, sAux3, sAux4, sAux5: String;
  iAux1, iAux2, iAux3, iAux4: Integer;
  vCodiGraf: Integer;
  bAux1: Boolean;
  vTipo: String;
  Quer, Qry1: TsgQuery;
  QuerRemo: TDataSet;
  Look: TLcbLbl;
  LookNume: TDBLookNume;
  CodiAtua: Variant;
  Indi: Integer;
  DtsGrav, vDts:  TDataSource;
  Grid: TsgDBG;
  AchoFO: Boolean;
  If0001: Boolean;
  Lst: TLstLbl;
  sList: TStringList;
  vBtn: TsgBtn;

  Mark : TBookMark;
  Arqu : TextFile;

  Pnl: TsgPnl;
  Tim: TsgTim;

  ListAuxi: TStringList;
  ContFO: Integer;

  MaiEnvi : TEnviMail;

  vMensagem: String;

  RTTI1: TsgRTTI;

  //Etiquetas
  ACBrETQ : TACBrETQ;
  NomeImagem: String;

  AcbVali: TACBrValidador;

  {$ifdef ERPUNI}
  {$else}
  {$endif}
begin
  vMensagem := '';
  sList := TStringList.Create;
  try
    sAux1 := '';
    sAux2 := '';
    sAux3 := '';
    sAux4 := '';
    sAux5 := '';
    //iAux1 := 0;
    //iAux2 := 0;
    //iAux3 := 0;

    Result := True;
    with iForm do
    begin
           if Assigned(iComp) then SetPsgTrans(TsgTransaction(iComp))
      else if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction);  //{$ifdef FD} {$endif}
      If0001 := True;
      NumeLinh := 0;
      List.Text := CampPers_TratExec(iForm, List.Text, '');
      while NumeLinh < List.Count do
      begin
        Linh := Trim(List.Strings[NumeLinh]);
        if (Linh <> '') and (sgLog.Tipo IN [2,3]) then
          GetPADOConn.AddMonitor('PL-SAG: '+Linh);

        if AnsiUpperCase(Linh) = '<COMPS>' then
        begin
          sList.Clear;
          sList.Add(Linh);
          Inc(NumeLinh);  //Começa da Linha Seguinte do <comps>
          while (NumeLinh < List.Count) do
          begin
            vLinh := SubsCampPers(iForm, Trim(List.Strings[NumeLinh]));
            sList.Add(vLinh);
            if  AnsiUpperCase(Trim(vLinh)) = '</COMPS>' then
              Break
            else
              Inc(NumeLinh);
          end;
          if sList.Count > 2 then
          begin
            try
              RTTI1 := TsgRTTI.Create(iForm);
              //RTTI1.RegisterClass(TControlClass(Parent.ClassType));
              RTTI1.loadFromXML(sList.Text);
            finally
              FreeAndNil(RTTI1);
            end;
          end;
        end
        else if CampPersValiExecLinh(Linh) then
        begin
          Linh := SubsCampPers(iForm, Linh);
          vLinh := Linh;
          if (sgLog.Tipo IN [2,3]) and (Linh <> Trim(List.Strings[NumeLinh])) then
            GetPADOConn.AddMonitor('PL-SAG: '+Linh);

          vTipo := sgCopy(Linh,01,02);

          if vTipo = 'IF' then
          begin
            Camp := AnsiUpperCase(Trim(Copy(Linh,04,08)));
            if (Copy(Camp,01,04) = 'INIC') OR
               (Copy(Camp,01,04) = 'ELSE') then
            begin
              Linh := Trim(Copy(Linh,13, Length(Linh)-12));

              if (Copy(Camp,01,04) = 'INIC') then
                If0001 := NuloReal(CampPersExec(Linh)) <> 0
              else if Copy(Camp,01,04) = 'ELSE' then
              begin
                if Linh <> '' then
                  If0001 := (not If0001) and (NuloReal(CampPersExec(Linh)) <> 0)
                else
                  If0001 := not If0001;
              end;

              sList.Clear;
              Inc(NumeLinh);  //Começa da Linha Seguinte do IF-INIC ou IF-ELSE
              iAux1 := 1;  //Números de mesmo IF-INIC0001, caso tenha um dentro do outro
              while (NumeLinh < List.Count) do
              begin
                Linh := Trim(List.Strings[NumeLinh]);
                sAux1 := Copy(Linh,01,02);
                sAux2 := AnsiUpperCase(Trim(Copy(Linh,04,04)));
                sAux3 := AnsiUpperCase(Trim(Copy(Linh,08,04)));

                if (sAux1 = 'IF') then  //Contar os IF
                begin
                   if (sAux3 = Copy(Camp,05,04)) and (sAux2 = 'INIC') then //Cada INIC, incrementa
                     Inc(iAux1);
                   if (sAux3 = Copy(Camp,05,04)) and ((sAux2 = 'ELSE') OR (sAux2 = 'FINA')) then //Cada ELSE ou FINA, decrementa
                     Dec(iAux1);
                end;

                if (sAux1 = 'IF') and
                  ((sAux2 = 'ELSE') OR (sAux2 = 'FINA')) and
                   (sAux3 = Copy(Camp,05,04)) and
                   (iAux1 = 0) then
                begin
                  Dec(NumeLinh);
                  Break;
                end
                else
                  sList.Add(List.Strings[NumeLinh]);
                Inc(NumeLinh);
              end;

              if If0001 and (sList.Count > 0) then
              begin
                Result := CampPersExecListInst(iForm, sList);
                if not Result then
                  Exit;
              end;
            end
            else if Copy(Camp,01,04) = 'FINA' then
              If0001 := True;
          end
          else if vTipo = 'WH' then
          begin
            Camp := AnsiUpperCase(Trim(Copy(Linh,04,08)));
            sAux3 := Trim(Copy(Linh,13, Length(Linh)-12));

            sList.Clear;
            Inc(NumeLinh);  //Começa da Linha Seguinte do WH
            while (NumeLinh < List.Count) do
            begin
              Linh := Trim(List.Strings[NumeLinh]);
              sAux1 := Copy(Linh,01,02);
              sAux2 := AnsiUpperCase(Trim(Copy(Linh,04,08)));
              if (sAux1 = 'WH') and
                 (sAux2 = Camp) then
                Break
              else
              begin
                sList.Add(List.Strings[NumeLinh]);
                Inc(NumeLinh);
              end;
            end;

            if (sList.Count > 0) then
            begin
              try
                if Copy(Camp,01,04) = 'NOVO' then
                begin
                  Quer := TsgQuery.Create(iForm);
                  Quer.sgConnection := iForm.sgTransaction;
                  Quer.Name := 'Qry'+Camp;
                  Quer.SQL.Add(sAux3);
                  QuerRemo := Quer;
                  QuerRemo.Open;
                end
                else if Copy(Camp,01,08) = 'BASEAUXI' then
                begin
//                  DtmPoul.cdsBaseAuxi;
                  DtmPoul.cdsBaseAuxi.Close;
                  DtmPoul.cdsBaseAuxi.SQL.Text := sAux3;
                  DtmPoul.cdsBaseAuxi.Open;
                  QuerRemo := DtmPoul.cdsBaseAuxi;
                end
                else
                begin
                  Quer := TsgQuery(BuscaComponente('Qry'+Camp));
                  //Quer.DisableControls;
                  Quer.First;
                  QuerRemo := Quer;
                end;

                if GetPPrgPrin.Visible then
                begin
                  ExibProgPri1(1, QuerRemo.RecordCount+1);
                  bAux1 := False;
                end
                else
                begin
                  ExibProgPrin(1, QuerRemo.RecordCount+1);
                  bAux1 := True;
                end;

                while not QuerRemo.Eof do
                begin
                  ExibMensHint(sList.Text);
                  Result := CampPersExecListInst(iForm, sList);
                  if not Result then
                  begin
                    if bAux1 then
                      ExibProgPrin(QuerRemo.RecordCount)   //Para finalizar o Progress
                    else
                      ExibProgPri1(QuerRemo.RecordCount);  //Para finalizar o Progress
                    Exit;
                  end;

                  if bAux1 then
                    ExibProgPrin(1)
                  else
                    ExibProgPri1(1);

                  QuerRemo.Next;
                end;
              finally
                if Assigned(QuerRemo) then
                begin
                  if (Copy(Camp,01,04) = 'NOVO') then
                  begin
                    QuerRemo.Close;
                    FreeAndNil(QuerRemo);
                  end
                  else if Copy(Camp,01,08) = 'BASEAUXI' then
                    QuerRemo.Close
                  //else
                  //  QuerRemo.EnableControls;
                end;
              end;
            end;
    		  end
          else
          begin
            if If0001 and (vTipo <> '') then
            begin
              if vTipo = 'FO' then  //Formulário
              begin
                ListAuxi := TStringList.Create;
                try
                  Quer := TsgQuery(BuscaComponente('QryTela'));
                  if Assigned(iForm) and Assigned(iForm.sgTransaction) then
                    Quer.sgConnection := iForm.sgTransaction;
                  AchoFO := False;
                  for ContFO := NumeLinh to List.Count - 1 do
                  begin
                    if (ContFO <> NumeLinh) and (Copy(Trim(List.Strings[ContFO]),01,02) = 'FO') then  //Busca se tem outro FO
                    begin
                      NumeLinh := ContFO-1;
                      AchoFO := True;
                      Break;
                    end
                    else
                    begin
                      sAux1 := List.Strings[ContFO];
                      if (Copy(Trim(sAux1),01,02) <> 'FV') then  //FV substitui só quando volta do Formulario
                        sAux1 := SubsCampPers(iForm, sAux1);
                      ListAuxi.Add(sAux1);
                    end;
                  end;
                  ListAuxi.Text := SubsPalaTudo(SubsPalaTudo(ListAuxi.Text,'''[','x1x2x3{xx'),']''','3x2x1}xx');
                  ListAuxi.Text := SubsPalaTudo(SubsPalaTudo(ListAuxi.Text,'[','{'),']','}');
                  ListAuxi.Text := SubsPalaTudo(SubsPalaTudo(ListAuxi.Text,'x1x2x3{xx','''['),'3x2x1}xx',']''');
                  Result := CampPers_ChamTelaDire(iForm, Quer, Trim(Linh), ListAuxi.Text);
                  if not AchoFO then
                    NumeLinh := List.Count;  //Força Saída
                  Quer.SQL.Strings[4] := 'WHERE (1 = 2)'; //Limpa o Query Tela
                finally
                  ListAuxi.Free;
                end;
              end
              else if vTipo = 'FM' then  //Formulário Manfutenção Genérica
              begin
                sAux1 := DtmPoul.Tabelas_Busc('MenuTabe', '(CodiTabe = '+Copy(Linh,04,08)+')');
                ClicPast(sAux1, '', Trim(Copy(Linh,13, Length(Linh)-12)), nil);
              end
              else if (vTipo <> 'NF') and (vTipo <> 'N2') and StrIn(Linh[3], ['D','F','V','C','R']) then  //Desabilita, Focus, Visible e Cor
                CampPersAcao(iForm, Linh, Copy(Linh,03,01))
              else if (Copy(vTipo,01,02) = 'BO') or
                      (Copy(vTipo,01,02) = 'BC') or
                      (Copy(vTipo,01,02) = 'BF') then  //Botão
              begin
                try
                  if (NuloReal(CampPersExec(Copy(Linh, 13, Length(Linh)-12))) = 0) then  //Executar o Botão
                  begin
                    if vTipo = 'BO' then   //Botão Confirma
                    BEGIN
                      //Precisavamos usar o BO com o comando BF
                      vBtn := TsgBtn(FindComponent('BtnConf'));
                      bAux1 := vBtn.Visible;
                      vBtn.Visible := True;
                      try
                        vBtn.OnClick(TsgBtn(FindComponent('BtnConf')));
                      finally
                        vBtn.Visible := bAux1;
                      end;
                    end
                    else if vTipo = 'BC' then   //Botão Cancela
                    begin
                      //Precisavamos usar o BC com o comando BF
                      vBtn := TsgBtn(FindComponent('BtnCanc'));
                      bAux1 := vBtn.Visible;
                      vBtn.Visible := True;
                      try
                        vBtn.OnClick(TsgBtn(FindComponent('BtnCanc')));
                      finally
                        vBtn.Visible := bAux1;
                      end;
                    end
                    else if vTipo = 'BF' then   //Botão Fecha
                      ExibBtnFech := [btFech];
                  end
                  else  //Resultado = 1
                  begin
                    if vTipo = 'BF' then   //Botão Fecha
                      ExibBtnFech := [btConfCanc];
                  end;
                except
                  on E: Exception do
                     vMensagem := E.Message;
                end;
                if vMensagem <> '' then
                begin
                  Result := False;
                  SetPADOConn(DtmPoul.DtbGene);
                  msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema no Botão (Cancela ou Confirma) na Instrução'+sgLn+
                                              List.Strings[NumeLinh]+sgLn+
                                              sgLn+
                                              'Mensagem Interna:'+sgLn+
                                              vMensagem);
                  Exit;
                end;
              end
              else if Copy(vTipo,01,01) = 'M' then  //Mensagem
              begin
                try
                  sAux1 := Copy(Linh,03,01);
                  sAux5 := Copy(Linh,03,01);
                  Linh := Copy(Linh,04,Length(Linh)-03);
                  Inc(NumeLinh);
                  if vTipo = 'MP' then  //Mensagem Personalizada
                  begin
                    Acao := sAux5;
                    sAux1 := CampPers_ExecLinhStri(Copy(Linh, 13, Length(Linh)-12), Camp);
                    if Trim(sAux1) <> '' then
                    begin
                      msgOk(sAux1);
                      if Acao = 'P' then
                      begin
                        Result := False;
                        SetPADOConn(DtmPoul.DtbGene);
                        Exit;
                      end;
                    end;
                  end
                  else if (NuloReal(CampPersExec(Copy(Linh, 13, Length(Linh)-12))) = 0) then  //Exibir a Mensagem
                  begin
                    sAux2 := Trim(SubsCampPers(iForm, List.Strings[NumeLinh]));
                    if sgCopy(sAux2,01,07) = 'SELECT ' then
                      sAux2 := NuloStri2(CampPersExec(sAux2));

                    if vTipo = 'MA' then   //Mensagem de Alerta
                      msgAviso(sAux2)
                    else if (vTipo = 'ME') Or (vTipo = 'MB') then //Mensagem de Erro ou Mensagem Botão
                    begin
                      if IsDigit(sAux1) then
                        BeepTemp(StrToInt(sAux1));
                      if vTipo = 'MB' then
                        sgMessageDlg(sAux2, mtInformation, [], 0)
                      else
                        msgOk(sAux2);
                      CampPersAcao(iForm, Linh, 'S');  //Executa o Setfocus no campo
                      Result := False;
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end
                    else if vTipo = 'MI' then //Mensagem de Informação
                      msgOk(sAux2)
                    else                 //'MC' Mensagem de Confirmação
                      Result := msgSim(sAux2);

                    if not Result then
                    begin
                      CampPersAcao(iForm, Linh, 'S');  //Executa o Setfocus no campo
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;

                  end;
                except
                  on E: Exception do
                     vMensagem := E.Message;
                end;
                if vMensagem <> '' then
                begin
                  Result := False;
                  SetPADOConn(DtmPoul.DtbGene);
                  msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema na Mensagem na Instrução'+sgLn+
                                              List.Strings[NumeLinh]+sgLn+
                                              sgLn+
                                              'Mensagem Interna:'+sgLn+
                                              vMensagem);
                  Exit;
                end;
              end
              else if vTipo = 'NF' then  //Nota Fiscal Eletrônica
              begin
                {$ifdef ERPUNI}
                  iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, Linh).Msg;
                {$else}
                  Acao := Copy(Linh,03,01);
                  Camp := Trim(Copy(Linh,04,08));
                  Linh := Trim(Copy(Linh,13, Length(Linh)-12));
                  if Acao = 'G' then //Gera NFe
                  begin
                    DtmPoul.QryPlus.SQL.Text := CalcStri('SELECT SQL_Cons FROM POCACONS WHERE (CodiCons = '+Camp+')');
                    DtmPoul.QryPlus.SQL.Strings[4] := Linh;
                    NFe_XML_Gera(iForm, DtmPoul.QryPlus.SQL.Text);
                    DtmPoul.QryPlus.SQL.Clear;
                  end
                  else if Acao = 'A' then //Assina NFe
                  begin
                    sAux2 := SubsPala(BuscValoChavText(Linh, 'EndeArqu'),'''','');
                    sAux3 := SubsPala(BuscValoChavText(Linh, 'CertDigi'),'''','');
                    iAux2 := StrToInt(RetoZero(BuscValoChavText(Linh, 'TipoAssi')));
                    sAux4 := BuscValoChavText(Linh, 'CodiNota');
                    iForm.RetoFunc := QuotedStr(NFe_XML_Assina(sAux2, sAux3, iAux2, sAux4));
                  end
                  else if Acao = 'P' then //Processa NFe
                  begin
                    sAux1 := BuscValoChavText(Linh, 'CodiNota');
                    iForm.RetoFunc := QuotedStr(NFe_XML_Gera_Proc(sAux1));
                  end
                  else if Acao = 'V' then //Valida Esquema NFe
                  begin
                    sAux2 := SubsPala(BuscValoChavText(Linh, 'EndeArqu'),'''','');
                    sAux3 := BuscValoChavText(Linh, 'CodiNota');
                    iAux2 := StrToInt(RetoZero(BuscValoChavText(Linh, 'TipoVali')));
                    iForm.RetoFunc := QuotedStr(NFe_XML_ValiEsqu(sAux2, sAux3, iAux2));
                  end
                  else if Acao = 'W' then //WS - Busca Lote
                    iForm.RetoFunc := QuotedStr(NFe_XML_WS_Comu(Linh))
                  else if Acao = 'I' then //Importa XML para o Banco
                  begin
                    sAux2 := CampPers_ExecLinhStri(Linh, Camp);
                    iForm.RetoFunc := QuotedStr(NFe_XML_ImpoXML(iForm, Camp, sAux2));
                  end;
                {$endif}
              end
              else if vTipo = 'N2' then  //Nota Fiscal Eletrônica (Versão 2.0)
              begin
                {$ifdef ERPUNI}
                  iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, Linh).Msg;
                {$else}
                  Acao := Copy(Linh,03,01);
                  Camp := Trim(Copy(Linh,04,08));
                  Linh := Trim(Copy(Linh,13, Length(Linh)-12));
                  if Acao = 'G' then //Gera NFe (Versão 2.0)
                  begin
                    DtmPoul.QryPlus.SQL.Text := CalcStri('SELECT SQL_Cons FROM POCACONS WHERE (CodiCons = '+Camp+')');
                    DtmPoul.QryPlus.SQL.Strings[4] := Linh;
                    NFe_XML_Gera_V20(iForm, DtmPoul.QryPlus.SQL.Text);
                    DtmPoul.QryPlus.SQL.Clear;
                  end
                  else if Acao = 'A' then //Assina NFe
                  begin
                    sAux2 := SubsPala(BuscValoChavText(Linh, 'EndeArqu'),'''','');
                    sAux3 := SubsPala(BuscValoChavText(Linh, 'CertDigi'),'''','');
                    iAux2 := StrToInt(RetoZero(BuscValoChavText(Linh, 'TipoAssi')));
                    sAux4 := BuscValoChavText(Linh, 'CodiNota');
                    iForm.RetoFunc := QuotedStr(NFe_XML_Assina_V20(sAux2, sAux3, iAux2, sAux4));
                  end
                  else if Acao = 'P' then //Processa NFe
                  begin
                    sAux1 := BuscValoChavText(Linh, 'CodiNota');
                    sAux2 := BuscValoChavText(Linh, 'ReciNota');
                    sAux3 := BuscValoChavText(Linh, 'PathNota');
                    iForm.RetoFunc := QuotedStr(NFe_XML_Gera_Proc_V20(sAux1, sAux2, sAux3));
                  end
                  else if Acao = 'V' then //Valida Esquema NFe
                  begin
                    sAux2 := SubsPala(BuscValoChavText(Linh, 'EndeArqu'),'''','');
                    sAux3 := BuscValoChavText(Linh, 'CodiNota');
                    iAux2 := StrToInt(RetoZero(BuscValoChavText(Linh, 'TipoVali')));
                    iForm.RetoFunc := QuotedStr(NFe_XML_ValiEsqu_V20(sAux2, sAux3, iAux2));
                  end
                  else if Acao = 'W' then //W - Comunicação em Geral (Busca, Envia, Cancela, Consulta Cadastro...)
                    iForm.RetoFunc := QuotedStr(NFe_XML_WS_Comu_V20(iForm, Linh))
                  else if Acao = 'I' then //Importa XML para o Banco
                  begin
                    sAux2 := CampPers_ExecLinhStri(Linh, Camp);
                    iForm.RetoFunc := QuotedStr(NFe_XML_ImpoXML_V20(sAux2));
                  end
                  else if Acao = 'X' then //Outras Funções
                  begin
                    iForm.RetoFunc := QuotedStr(NFe_XML_OutrFunc_V20(iForm, Camp, Linh));
                  end;
                {$endif}
              end
              else //Demais Testes
              begin
                Acao := Copy(Linh,03,01);
                Camp := Trim(Copy(Linh,04,08));
                Linh := Trim(Copy(Linh,13, Length(Linh)-12));
                try
                 if (vTipo = 'DG') then
                  begin
                    vDts := nil;
                    if (sgIsMovi) and Assigned(iForm.FormRela) then  //Se for movimento e foi usado o DG, busca o campo no formulário Pai
                    begin
                      //ST: Não alterar a identação abaixo, por causa do replace no Modal.bat
                      case Func.sgTipoForm(iForm.FormRela) of
                        tfsgFrm     : vDts := TDataSource( TsgForm(iForm.FormRela).BuscaComponente('DtsGrav'));
                        tfsgFrmModal: vDts := TDataSource(TsgFormModal(iForm.FormRela).BuscaComponente('DtsGrav'));
                      end;
                      //ST: Fim
                    end
                    else
                      vDts := TDataSource(BuscaComponente('DtsGrav'));

                    if TestDataSet(vDts) and PSitGrav then
                    begin
                      if (sgCopy(Camp,01,03) = 'COD') and (Linh = '0') then
                        vDts.DataSet.FieldByName(Camp).Value := NULL
                      else
                        vDts.DataSet.FieldByName(Camp).Value := CampPersExec(Linh);
                    end;
                  end
                  else if vTipo = 'DD' then
                  begin
                    vDts := nil;
                    if (Acao = 'G') then
                      vDts := TDataSource(BuscaComponente('DtsGrav'))
                    else if (Acao = 'M') then
                      vDts := TDataSource(BuscaComponente('DtsMov1'))
                    else if (Acao = '2') or (Acao = '3') then
                      vDts := TDataSource(BuscaComponente('DtsMov'+Acao))
                    else if (sgIsMovi) and Assigned(iForm.FormRela) then  //Se for movimento e foi usado o DG, busca o campo no formulário Pai
                    begin
                      case Func.sgTipoForm(iForm.FormRela) of
                        tfsgFrm     : vDts := TDataSource( TsgForm(     iForm.FormRela).BuscaComponente('DtsGrav'));
                        tfsgFrmModal: vDts := TDataSource( TsgFormModal(iForm.FormRela).BuscaComponente('DtsGrav'));
                      end;
                    end
                    else
                      vDts := TDataSource(BuscaComponente('DtsGrav'));

                    if TestDataSet(vDts) then
                    begin
                      if (sgCopy(Camp,01,03) = 'COD') and (Linh = '0') then
                        vDts.DataSet.FieldByName(Camp).Value := NULL
                      else
                        vDts.DataSet.FieldByName(Camp).Value := CampPersExec(Linh);
                    end;
                  end
                  else if vTipo = 'DM' then
                  begin
                    if sgIsMovi then
                      vDts := TDataSource(BuscaComponente('DtsGrav'))
                    else
                      vDts := TDataSource(BuscaComponente('DtsMov1'));

                    if (vDts.DataSet.State = dsInsert) or (Acao = 'D') then
                    begin
                      if (sgCopy(Camp,01,03) = 'COD') and (Linh = '0') then
                        vDts.DataSet.FieldByName(Camp).Value := NULL
                      else
                        vDts.DataSet.FieldByName(Camp).Value := CampPersExec(Linh);
                    end;
                  end
                  else if vTipo = 'D2' then
                  begin
                    if sgIsMovi then
                      vDts := TDataSource(BuscaComponente('DtsGrav'))
                    else
                      vDts := TDataSource(BuscaComponente('DtsMov2'));

                    if vDts.DataSet.State = dsInsert then
                    begin
                      if (sgCopy(Camp,01,03) = 'COD') and (Linh = '0') then
                        vDts.DataSet.FieldByName(Camp).Value := NULL
                      else
                        vDts.DataSet.FieldByName(Camp).Value := CampPersExec(Linh);
                    end;
                  end
                  else if vTipo = 'D3' then
                  begin
                    if sgIsMovi then
                      vDts := TDataSource(BuscaComponente('DtsGrav'))
                    else
                      vDts := TDataSource(BuscaComponente('DtsMov3'));

                    if vDts.DataSet.State = dsInsert then
                    begin
                      if (sgCopy(Camp,01,03) = 'COD') and (Linh = '0') then
                        vDts.DataSet.FieldByName(Camp).Value := NULL
                      else
                        vDts.DataSet.FieldByName(Camp).Value := CampPersExec(Linh);
                    end;
                  end
                  else if vTipo = 'CE' then
                    TDBEdtLbl(FindComponent('Edt'+Camp)).Text     := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'CC' then
                    TDBCmbLbl(FindComponent('Cmb'+Camp)).Value    := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'CA' then
                    TDBFilLbl(FindComponent('Fil'+Camp)).Text     := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'CD' then
                    TDBRxDLbl(FindComponent('Edt'+Camp)).Date     := CampPers_ExecData(Linh)
                  else if (vTipo = 'CN') then
                    TDBRxELbl(FindComponent('Edt'+Camp)).Value    := NuloReal(CampPersExec(Linh))
                  else if (vTipo = 'IL') then
                    TDBLookNume(FindComponent('Edt'+Camp)).SetValores(NuloReal(CampPersExec(Linh)), 0)
                  else if vTipo = 'CS' then
                  begin
                    TDBChkLbl(FindComponent('Chk'+Camp)).Checked  := NuloReal(CampPersExec(Linh)) <> 0;
                    if Assigned(TDBChkLbl(FindComponent('Chk'+Camp)).DataSource) and Assigned(TDBChkLbl(FindComponent('Chk'+Camp)).DataSource.DataSet) then
                      TDBChkLbl(FindComponent('Chk'+Camp)).DataSource.DataSet.FieldByName(TDBChkLbl(FindComponent('Chk'+Camp)).DataField).AsInteger := SeInte(TDBChkLbl(FindComponent('Chk'+Camp)).Checked, 1, 0);
                  end
                  else if vTipo = 'ES' then
                    TChkLbl(FindComponent('Chk'+Camp)).Checked    := NuloReal(CampPersExec(Linh)) <> 0
                  else if (vTipo = 'CT') or (vTipo = 'IT') then
                  begin
                    Look := TLcbLbl(FindComponent('Lcb'+Camp));
                    if Assigned(Look) then
                      Look.KeyValue := CampPersExec(Linh)
                    else
                      TDBLookNume(FindComponent('Edt'+Camp)).ValorGravado := NuloReal(CampPersExec(Linh))
                  end
                  else if vTipo = 'CR' then
                    TDBRchLbl(FindComponent('Rch'+Camp)).Text     := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'CM' then
                    TDBMemLbl(FindComponent('Mem'+Camp)).Text     := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'ET' then
                    TMemLbl(FindComponent('Mem'+Camp)).Text       := CampPers_ExecLinhStri(Linh, Camp)
                  else if (vTipo = 'RS') or (vTipo = 'RE') or (vTipo = 'RI') or
                          (vTipo = 'RP') or (vTipo = 'RX') then
                    TAdvMemLbl(FindComponent('Mem'+Camp)).Lines.Text:= CampPers_ExecLinhStri(Linh, Camp)
                  else if (vTipo = 'EL') then
                    TDBLookNume(FindComponent('Edt'+Camp)).ValorGravado  := NuloReal(CampPersExec(Linh))
                  else if (vTipo = 'LN') or (vTipo = 'EN')  then
                    TRxEdtLbl(FindComponent('Edt'+Camp)).Value    := NuloReal(CampPersExec(Linh))
                  else if (vTipo = 'LE') or (vTipo = 'EE') then
                    TEdtLbl(FindComponent('Edt'+Camp)).Text       := CampPers_ExecLinhStri(Linh, Camp)
                  else if (vTipo = 'EA') then
                    TFilLbl(FindComponent('Fil'+Camp)).Text       := CampPers_ExecLinhStri(Linh, Camp)
                  else if (vTipo = 'EI') then
                    TDirLbl(FindComponent('Dir'+Camp)).Text       := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'EC' then
                    TCmbLbl(FindComponent('Cmb'+Camp)).Value      := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'ED' then
                    TRxDatLbl(FindComponent('Edt'+Camp)).Date     := CampPers_ExecData(Linh)
                  else if vTipo = 'LB' then
                  begin
                    if Assigned(TsgLbl(FindComponent('Lbl'+Camp))) then
                      TsgLbl(FindComponent('Lbl'+Camp)).Caption     := CampPers_ExecLinhStri(Linh, Camp)
                    else if Assigned(TsgLbl(FindComponent('chk'+Camp))) then
                      TsgLbl(FindComponent('chk'+Camp)).Caption     := CampPers_ExecLinhStri(Linh, Camp)
                  end

                  {$ifdef ERPUNI}
                  {$else}
                    else if (vTipo = 'QE') then  //QuickReport - Edit
                      TQRDBText(FindComponent('Edt'+Camp)).Caption := CampPers_ExecLinhStri(Linh, Camp)
                    else if (vTipo = 'QL') then  //QuickReport - Label
                      TQRLabel(FindComponent('Lbl'+Camp)).Caption := CampPers_ExecLinhStri(Linh, Camp)
                    else if (vTipo = 'QS') then  //QuickReport - Sys
                      TQRSysData(FindComponent('Sys'+Camp)).Data := TQRSysDataType(NuloInte(CampPersExec(Linh)))
                    else if (vTipo = 'QX') then  //QuickReport - Exp
                      TQRExpr(FindComponent('Exp'+Camp)).Expression := CampPers_ExecLinhStri(Linh, Camp)
                  {$endif}

                  else if vTipo = 'BT' then
                    TsgBtn(FindComponent('Btn'+Camp)).Caption     := CampPers_ExecLinhStri(Linh, Camp)
                  else if vTipo = 'VA' then
                  begin
                    if AnsiUpperCase(Camp) = 'CONFIRMA' then
                      iForm.Confirma := CampPers_ExecLinhStri(Linh, Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'STRI' then
                      iForm.VariStri[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecLinhStri(Linh,Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'VALO' then
                      iForm.VariValo[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecLinhStri(Linh, Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'INTE' then
                      iForm.VariInte[StrToInt(Copy(Trim(Camp),05,04))] := NuloInte(CampPersExec(Linh))
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'DATA' then
                      iForm.VariData[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecData(Linh)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'REAL' then
                      iForm.VariReal[StrToInt(Copy(Trim(Camp),05,04))] := NuloReal(CampPersExec(Linh))
                    else if AnsiUpperCase(Camp) = 'PDA1MANU' then
                      GetConfWeb.PDa1Manu := CampPers_ExecData(Linh)
                    else if AnsiUpperCase(Camp) = 'PDA2MANU' then
                      GetConfWeb.PDa2Manu := CampPers_ExecData(Linh)
                    else if AnsiUpperCase(Camp) = 'RETOFUNC' then
                      iForm.RetoFunc := CampPers_ExecLinhStri(Linh, Camp)
                    else if AnsiUpperCase(Camp) = 'FECHCONF' then
                      iForm.ConfTabe.FechaConfirma := NuloReal(CampPersExec(Linh)) <> 0
                    else if AnsiUpperCase(Camp) = 'CODITEST' then
                      GetConfWeb.pCodTest := NuloInte(CampPersExec(Linh))
                    else if AnsiUpperCase(Camp) = 'NOMETEST' then
                      GetConfWeb.pNomTest := CampPers_ExecLinhStri(Linh, Camp);
                  end
                  else if vTipo = 'VP' then
                  begin
                         if AnsiUpperCase(Copy(Camp,01,04)) = 'STRI' then
                      iForm.PersStri[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecLinhStri(Linh,Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'VALO' then
                      iForm.PersValo[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecLinhStri(Linh, Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'INTE' then
                      iForm.PersInte[StrToInt(Copy(Trim(Camp),05,04))] := NuloInte(CampPersExec(Linh))
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'DATA' then
                      iForm.PersData[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecData(Linh)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'REAL' then
                      iForm.PersReal[StrToInt(Copy(Trim(Camp),05,04))] := NuloReal(CampPersExec(Linh));
                  end
                  else if vTipo = 'PU' then
                  begin
                    if not NumeroInRange(StrToInt(Copy(Trim(Camp),05,04)),1,5) then
                      raise Exception.Create('Variável Publica deve ser de 0001 a 0005: '+Copy(Trim(Camp),01,08))
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'STRI' then
                      GetConfWeb.PublStri[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecLinhStri(Linh,Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'VALO' then
                      GetConfWeb.PublValo[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecLinhStri(Linh, Camp)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'INTE' then
                      GetConfWeb.PublInte[StrToInt(Copy(Trim(Camp),05,04))] := NuloInte(CampPersExec(Linh))
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'DATA' then
                      GetConfWeb.PublData[StrToInt(Copy(Trim(Camp),05,04))] := CampPers_ExecData(Linh)
                    else if AnsiUpperCase(Copy(Camp,01,04)) = 'REAL' then
                      GetConfWeb.PublReal[StrToInt(Copy(Trim(Camp),05,04))] := NuloReal(CampPersExec(Linh))
                  end
                  else if (vTipo = 'GR') then
                  begin
                    //if AnsiUpperCase(Linh) = 'ABRE' then
                      TFraGraf(FindComponent('Gra'+Camp)).CarregaDados(TsgForm( (iForm) ), Linh);
                  end
                  else if vTipo = 'QY' then  //Query
                  begin
                    Quer := TsgQuery(BuscaComponente('Qry'+Camp));
                    Linh := Trim(Linh);
                    if Assigned(Quer) then
                    begin
                      if AnsiUpperCase(Linh) = 'PRIM' then
                      begin
                        Quer.DisableControls;
                        Quer.First;
                        Look := TDBLcbLbl(FindComponent('Lcb'+Camp));
                        if Assigned(Look) then
                        begin
                          if (Look.DataField <> '') then
                            CodiAtua := Quer.FieldByName(Look.DataField).Value
                          else
                            CodiAtua := Quer.Fields[0].Value;
                        end;
                        Quer.EnableControls;
                        if Assigned(Look) then
                          Look.KeyValue := CodiAtua;
                      end
                      else if AnsiUpperCase(Linh) = 'PROX' then
                        Quer.Next
                      else if AnsiUpperCase(Linh) = 'ANTE' then
                        Quer.Prior
                      else if AnsiUpperCase(Linh) = 'ULTI' then
                        Quer.FindLast
                      else if AnsiUpperCase(Linh) = 'FECH' then
                        Quer.Close
                      else if AnsiUpperCase(Linh) = 'EDIT' then
                        Quer.Edit
                      else if AnsiUpperCase(Linh) = 'INSE' then
                        Quer.Insert
                      else if AnsiUpperCase(Linh) = 'POST' then
                        TratErroBanc(Quer)
                      else if AnsiUpperCase(Copy(Linh,01,Length('FILTRA('))) = 'FILTRA(' then
                        Quer.Filtra(SubsPala(Copy(Linh,Pos('(',Linh)+1,MaxInt),')',''))
                      else
                      begin
                        Look := TDBLcbLbl(FindComponent('Lcb'+Camp));
                        if Assigned(Look) then
                        begin
                          if (Look.DataField <> '') and TestDataSet(Look.DataSource) then
                            CodiAtua := Look.DataSource.DataSet.FieldByName(Look.DataField).Value
                          else
                            CodiAtua := Look.KeyValue;
                          Quer.Close;
                          if AnsiUpperCase(Linh) <> 'ABRE' then
                          begin
                            Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                            Quer.SQL.Strings[4] := Linh;
                          end
                          else if Quer.SQL.Count = 0 then
                            Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                          if Quer.SQL.Count > 0 then
                            Quer.Open;

                          //ST 21/02/2023 06:03: Se for para iniciar o Look deve ter instrução para isso
                          //if (CodiAtua = null) or (Quer.Tag = 0) then  //Quando o Tag = 0, é porque foi necessário abrir o Query de novo, pode ser que o registro que estava no Codi, não esteja mais (Saldo, Codi IN)...
                          //  CodiAtua := Quer.Fields[0].Value;

                         {$IFDEF ERPUNI}
                           //27/11/2020 - Sidiney: Em Unigui, se entrar alterando e depois incluindo, dava o erro de Field '' não existe (???)
                         {$ELSE}
                            if (Look.DataField <> '') and TestDataSet(Look.DataSource) then
                              Look.DataSource.DataSet.FieldByName(Look.DataField).Value := CodiAtua;
                         {$ENDIF}
                          Look.KeyValue := CodiAtua;

                          if (Look.Text = '') and (CodiAtua <> null) then  //Se não tiver o CodiAuta, joga o primeiro da Qry
                          begin
                            if (Look.DataField <> '') and TestDataSet(Look.DataSource) then
                              Look.DataSource.DataSet.FieldByName(Look.DataField).Value := Quer.Fields[0].Value;

                            Look.KeyValue := Quer.Fields[0].Value;
                          end;
                        end
                        else
                        begin
                          LookNume := TDBLookNume(FindComponent('Edt'+Camp));
                          if Assigned(LookNume) then
                          begin
                            if (LookNume.DataField <> '') and TestDataSet(LookNume.DataSource) then
                              CodiAtua := LookNume.DataSource.DataSet.FieldByName(LookNume.DataField).Value
                            else
                              CodiAtua := LookNume.ValorGravado;
                            Quer.Close;
                            if AnsiUpperCase(Linh) <> 'ABRE' then
                            begin
                              Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                              Quer.SQL.Strings[4] := Linh;
                            end
                            else if Quer.SQL.Count = 0 then
                              Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                            if Quer.SQL.Count > 0 then
                              Quer.Open;

                            //Se for para Iniciar com o primeiro valor, deve ter uma instrução para isso
                            //if (CodiAtua = null) or (Quer.Tag = 0) then  //Quando o Tag = 0, é porque foi necessário abrir o Query de novo, pode ser que o registro que estava no Codi, não esteja mais (Saldo, Codi IN)...
                            //  CodiAtua := Quer.Fields[0].Value;

                            if (CodiAtua <> null) then
                            begin
                              if (LookNume.DataField <> '') and TestDataSet(LookNume.DataSource) then
                                LookNume.DataSource.DataSet.FieldByName(LookNume.DataField).Value := CodiAtua
                              else
                                LookNume.ValorGravado := CodiAtua;
                            end;

                            if (LookNume.Value = 0) and (not Quer.isEmpty) and (CodiAtua <> null) then  //Se não tiver o CodiAuta, joga o primeiro da Qry
                            begin
                              if (LookNume.DataField <> '') and TestDataSet(LookNume.DataSource) then
                                LookNume.DataSource.DataSet.FieldByName(LookNume.DataField).Value := Quer.Fields[0].Value
                              else
                                LookNume.ValorGravado := Quer.Fields[0].AsFloat;
                            end;
                          end
                          else if AnsiUpperCase(Linh) = 'ABRE' then
                            Quer.Open();
                        end;
                      end;
                    end;
                  end
                  else if vTipo = 'QD' then  //Query do Grid
                  begin
                    Quer := TsgQuery(BuscaComponente('Qry'+Camp));
                    if AnsiUpperCase(Linh) = 'FECH' then
                      Quer.Close
                    else if AnsiUpperCase(Copy(Linh,01,Length('FILTRA('))) = 'FILTRA(' then
                      Quer.Filtra(SubsPala(Copy(Linh,Pos('(',Linh)+1,MaxInt),')',''))
                    else
                    begin
                      Grid := TsgDBG(BuscaComponente('Dbg'+Camp));
                      Indi := Grid.sgColuIndi;
                      Mark := Quer.GetBookmark;
                      Quer.Close;
                      if AnsiUpperCase(Linh) <> 'ABRE' then
                      begin
                        Quer.SQL.Clear;
                        Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                        Quer.SQL.Strings[4] := Linh;
                      end
                      else if Quer.SQL.Count = 0 then
                        Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                      if Quer.SQL.Count > 0 then
                        Quer.Open;
                      try
                        if (Mark <> nil) and Quer.BookmarkValid(Mark) then
                          Quer.GotoBookmark(Mark);
                      except
                      end;
                      Grid.AutoAjuste := GetPMelAjus();
                      {$ifdef ERPUNI}
                        if Grid.Coluna.Count > 1 then
                          Grid.ReGeraCamp();
                      {$else}
                        if (Indi >= 0) and (Grid.sgView.ClassType = TcxGridDBTableView) and (TcxGridDBTableView(Grid.sgView).Controller.SelectedColumnCount > 0) then
                          TcxGridDBTableView(Grid.sgView).Controller.SelectedColumns[0].Index := Indi;
                      {$endif}
                      Quer.FreeBookmark(Mark);
                    end;
                  end
                  else if vTipo = 'QM' then  //Qualquer Query, sendo que Marca a Posição que estava, e retorna nela
                  begin
                    Quer := TsgQuery(BuscaComponente('Qry'+Camp));
                    if AnsiUpperCase(Linh) = 'FECH' then
                      Quer.Close
                    else if AnsiUpperCase(Copy(Linh,01,Length('FILTRA('))) = 'FILTRA(' then
                      Quer.Filtra(SubsPala(Copy(Linh,Pos('(',Linh)+1,MaxInt),')',''))
                    else
                    begin
                      Mark := Quer.GetBookmark;
                      Quer.Close;
                      if AnsiUpperCase(Linh) <> 'ABRE' then
                      begin
                        if Trim(Quer.SQL_Back.Text) <> '' then
                          Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                        Quer.SQL.Strings[4] := Linh;
                      end
                      else if Quer.SQL.Count = 0 then
                        Quer.SQL.Text := SubsCampPers(iForm, Quer.SQL_Back.Text);
                      if Quer.SQL.Count > 0 then
                        Quer.Open;
                      try
                        if Quer.BookmarkValid(Mark) then
                          Quer.GotoBookmark(Mark);
                      except
                      end;
                      Quer.FreeBookmark(Mark);
                    end;
                  end
                  else if vTipo = 'QT' then  //Query do Chama tela
                    TsgQuery(BuscaComponente('QryTela')).SQL.Strings[4] := Linh
                  else if vTipo = 'QN' then
                  begin
                    Quer := TsgQuery(BuscaComponente('Qry'+Camp));

                    if AnsiUpperCase(Linh) = 'DESTROI' then
                    begin
                      if Quer <> nil then
                      begin
                        Quer.Close;
                        FreeAndNil(Quer);
                      end;
                    end
                    else
                    begin
                      if Quer = nil then
                      begin
                        Quer := TsgQuery.Create(iForm);
                        Quer.sgConnection := iForm.sgTransaction;
                        Quer.Name := 'Qry'+Camp;
                      end;
                      Quer.SQL.Text := Linh;
                      Quer.Open;
                    end;
                  end
                  else if vTipo = 'EX' then  //Executa
                  begin
                    Result := CampPers_EX(iForm, Camp, Linh);
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'OB' then  //Executa Triggers Objetos
                  begin
                    Result := CampPers_OB(iForm, Camp, Linh);
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'OP' then  //Executa Procedures Objetos
                  begin
                    Result := CampPers_OB(iForm, Camp, Linh);
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'OD' then  //Objeto Decorator
                  begin
                    Result := CampPers_OD(iForm, vLinh) <> '#ERRO#';
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'JS' then  //JavaScript
                  begin
                    {$ifdef ERPUNI}
                      UniSession.AddJS(CampPers_ExecLinhStri(Linh, Camp));
                    {$else}
                      msgOk('Operação somente tratada na WEB: '+vTipo);
                    {$endif}
                  end
                  else if vTipo = 'CW' then  //Executa Configuração WEB
                  begin
                    if Camp = 'ATUACONF' then
                      AtuaPOCaConf(SubsPala(Linh,'''',''))
                    else if Camp = 'PCODPESS' then
                      SetPCodPess(SubsPala(Linh,'''',''))
                    else if StrIn(Camp, ['PAPEPESS', 'APELPESS']) then
                      SetPApePess(SubsPala(Linh,'''',''))
                    else
                      Result := CampPers_ConfWeb(iForm, Camp, Linh);
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'EP' then  //Executa Procedures
                  begin
                    Result := CampPers_EP(iForm, Camp, Linh);
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'TR' then  //Executa Triggers (Delphi)
                  begin
                    Result := CampPers_TR(iForm, Camp, Linh);
                    if not Result then
                    begin
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'EY' then  //5.0.32.888 - Executa direto, até mesmo no On-Show
                    ExecSQL_(Linh)
                  else if vTipo = 'EQ' then  //Executa na query passada, feito para fazer executa no DtbCada (outra Transação)
                  begin
                    Quer := TsgQuery(BuscaComponente('Qry'+Camp));
                    if Assigned(Quer) and Assigned(Quer.Connection) and (Quer.Connection.ClassType = TsgADOConnection) then
                    begin
                      ExecSQL_(Linh, Quer.Connection);
                    end
                    else
                    begin
                      MostErro(nil, 'Componente não Localizado ('+Camp+')'+sgLn+sgLn+vTipo+'-'+Camp+'-'+Linh);
                      Result := False;
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
//                  else if vTipo = 'DS' then  //DataSnap
//                  begin
//                    Result := DS_AtuaTabe(iForm, Camp, Linh, 'ERPSAG_DESENV') <> 'ERRO';
//                    if not Result then
//                    begin
//                      SetPADOConn(DtmPoul.DtbGene);
//                      Exit;
//                    end;
//                  end
                  else if vTipo = 'IM' then  //Imprime
                  begin
                    try
                      AssignFile(Arqu, Camp);
                      ReWrite(Arqu);
                      Writeln(Arqu, TiraAcen(CampPers_ExecLinhStri(Linh, Camp)));
                    finally
                      CloseFile(Arqu);
                    end;
                  end
                  else if (vTipo = 'IR') then  //Imprime Relatório
                  begin
                    Quer := TsgQuery.Create(nil);
                    Qry1 := GetQry('SELECT '+PlusUni.ListCampPOCaRela()+
                                   'FROM POCaRela WHERE CodiRela = '+RetoZero(Camp)+
                                   ' AND (CodiCons IS NOT NULL)' //Ter IR na Mensagem (para entrar no VeriRela) e ter Consulta Padrão
                                 , 'QryIR_Rela');
                    try
                      Quer.Name := 'QryIR';
                      Quer.sgConnection   := GetPADOConn;
                      if Qry1.RecordCount = 0 then
                        Raise Exception.Create('Relatório não encontrado (Cód: '+RetoZero(Camp)+')');

                      try
                        GetConfWeb.PWheRela := Linh;
                        if IsDigit(Acao) then
                        begin
                          iAux1 := StrToInt(Acao);
                          TsgForm(iForm).VariStri[8] := PlusUni.ChamRela(Qry1, Quer, iAux1, TsgForm(iForm).VariStri[7]);
                        end
                        else
                          PlusUni.ChamRela(Qry1, Quer, 2, TsgForm(iForm).VariStri[7]);
                      finally
                        GetConfWeb.PWheRela := '';
                      end;
                      Qry1.Close;
                    finally
                      FreeAndNil(Qry1);
                      FreeAndNil(Quer);
                    end;
                  end
                  else if (vTipo = 'IP') then  //Imprime Relatório Personalizado (Especifico)
                  begin
                    Quer := TsgQuery.Create(nil);
                    Qry1 := GetQry('SELECT * FROM POCaReEs WHERE CodiReEs = '+RetoZero(Camp), 'QryIP_ReEs');
                    try
                      Quer.Name := 'QryIP';
                      Quer.sgConnection   := GetPADOConn;
                      if Qry1.RecordCount = 0 then
                        Raise Exception.Create('Relatório não encontrado (Cód: '+RetoZero(Camp)+')');

                      GetConfWeb.PWheRela := Linh;
                      if IsDigit(Acao) then
                      begin
                        iAux1 := StrToInt(Acao);
                        if iAux1 in [4,5] then  //Vai retornar o endereço do Arquivo
                          TsgForm(iForm).VariStri[8] := PlusUni.ChamRelaEspe(TsgForm(iForm), Qry1, iAux1, TsgForm(iForm).VariStri[7])
                        else
                          PlusUni.ChamRelaEspe(TsgForm(iForm), Qry1, iAux1, TsgForm(iForm).VariStri[7])
                      end
                      else
                        PlusUni.ChamRelaEspe(TsgForm(iForm), Qry1, 2, TsgForm(iForm).VariStri[7]);
                      Qry1.Close;
                    finally
                      FreeAndNil(Qry1);
                      FreeAndNil(Quer);
                    end;
                  end
                  else if vTipo = 'VV' then  //Validador
                  begin
                    AcbVali := TACBrValidador.Create(nil);
                    try
                      //0-docCPF
                      //1-docCNPJ
                      //2-docUF
                      //3-docInscEst
                      //4-docNumCheque
                      //5-docPIS
                      //6-docCEP
                      //7-docCartaoCredito
                      sAux2 := CampPers_ExecLinhStri(vLinh, Camp);
                      sAux3 := BuscValoChavText(sAux2,'Doc_');
                      iAux2 := StrToInt(RetoZero(BuscValoChavText(sAux2, 'Tipo')));
                      sAux4 := BuscValoChavText(sAux2,'UF');
                      AcbVali.TipoDocto := TACBrValTipoDocto(iAux2) ;
                      if (AcbVali.TipoDocto <> docInscEst) and
                         (AcbVali.TipoDocto <> docCEP) then
                        AcbVali.Complemento := ''
                      else
                        AcbVali.Complemento := sAux4;
                      AcbVali.Documento   := sAux3;

                      if not AcbVali.Validar then
                      begin
                        sgMessageDlg(AcbVali.MsgErro, mtInformation, [mbOK], 0);
                        Result := False;
                        SetPADOConn(DtmPoul.DtbGene);
                        Exit;
                      end;
                    finally
                      AcbVali.Free;
                    end;
                  end
                  else if vTipo = 'TQ' then  //Etiqueta
                  begin
                    with iForm do
                      ACBrETQ := TACBrETQ(FindComponent('EtqCamp'));
                    if ACBrETQ = nil then
                    begin
                      ACBrETQ := TACBrETQ.Create(iForm);
                      ACBrETQ.Name := 'EtqCamp';
                    end;
                    if Camp = 'DPI' then
                      ACBrETQ.DPI           := TACBrETQDPI(StrToInt(RetoZero(CampPers_ExecLinhStri(vLinh, Camp))))
                    else if Camp = 'MODELO' then
                      ACBrETQ.Modelo        := TACBrETQModelo(StrToInt(RetoZero(CampPers_ExecLinhStri(vLinh, Camp))))
                    else if Camp = 'PORTA' then
                      ACBrETQ.Porta         := CampPers_ExecLinhStri(vLinh, Camp)
                    else if Camp = 'LIMPMEMO' then
                    begin
                      ACBrETQ.LimparMemoria := StrToInt(RetoZero(CampPers_ExecLinhStri(vLinh, Camp))) <> 0;
                    end
                    else if (Copy(Camp,01,04) = 'IMAG') and (Camp <> 'IMAG') then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      TsgForm(iForm).VariResu[20] := Quer.FieldByName('Ende').AsString;
                      TsgForm(iForm).VariResu[19] := Quer.FieldByName('Inve').AsString;
                      Quer.Close;
                    end
                    else if Camp = 'ATIVA' then
                      ACBrETQ.Ativar
                    else if Camp = 'DESATIVA' then
                      ACBrETQ.Desativar
                    else if Camp = 'IMAG' then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      NomeImagem := AnsiUpperCase(Trim(Quer.FieldByName('Nome').AsString));
                      ACBrETQ.CarregarImagem(TsgForm(iForm).VariResu[20], NomeImagem,
                                             TsgForm(iForm).VariResu[19] <> '0');
                      //ImprimirImagem(1,10,10,Edit1.Text);
                      ACBrETQ.ImprimirImagem(Quer.FieldByName('Mult').AsInteger
                                            ,Quer.FieldByName('Topo').AsInteger
                                            ,Quer.FieldByName('Esqu').AsInteger
                                            ,AnsiUpperCase(Trim(Quer.FieldByName('Nome').AsString)));
                      Quer.Close;
                    end
                    else if Camp = 'TEXT' then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      //ImprimirTexto(orNormal, 2, 1, 3, 15, 670, 'BISCOITO RECH 335G');
                      ACBrETQ.ImprimirTexto(TACBrETQOrientacao(Quer.FieldByName('Orie').AsInteger)
                                           ,Quer.FieldByName('Font').AsInteger
                                           ,Quer.FieldByName('MulH').AsInteger
                                           ,Quer.FieldByName('MulV').AsInteger
                                           ,Quer.FieldByName('Topo').AsInteger
                                           ,Quer.FieldByName('Esqu').AsInteger
                                           ,Quer.FieldByName('Text').AsString
                                           ,Quer.FieldByName('Sub_Font').AsInteger
                                           ,Quer.FieldByName('ImprReve').AsInteger<>0);
                      Quer.Close;
                    end
                    else if Camp = 'BARR' then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      //ACBrETQ.ImprimirBarras(orNormal, 'E30', '2', '2', 120, 670, '7896003701685', 080, becSIM)
                      ACBrETQ.ImprimirBarras(TACBrETQOrientacao(Quer.FieldByName('Orie').AsInteger)
                                            ,Quer.FieldByName('TipoBarr').AsString
                                            ,Quer.FieldByName('LargBarrLarg').AsString
                                            ,Quer.FieldByName('LargBarrFina').AsString
                                            ,Quer.FieldByName('Topo').AsInteger
                                            ,Quer.FieldByName('Esqu').AsInteger
                                            ,Quer.FieldByName('Text').AsString
                                            ,Quer.FieldByName('AltuCodiBarr').AsInteger
                                            ,TACBrETQBarraExibeCodigo(Quer.FieldByName('ExibCodi').AsInteger));
                      Quer.Close;
                    end
                    else if Camp = 'LINH' then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      //ImprimirLinha(Vertical, Horizontal, Largura, Altura: Integer);
                      ACBrETQ.ImprimirLinha( Quer.FieldByName('Topo').AsInteger
                                            ,Quer.FieldByName('Esqu').AsInteger
                                            ,Quer.FieldByName('Larg').AsInteger
                                            ,Quer.FieldByName('Altu').AsInteger);
                      Quer.Close;
                    end
                    else if Camp = 'CAIX' then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      //ImprimirCaixa(Vertical, Horizontal, Largura, Altura, EspessuraVertical, EspessuraHorizontal: Integer);
                      ACBrETQ.ImprimirCaixa( Quer.FieldByName('Topo').AsInteger
                                            ,Quer.FieldByName('Esqu').AsInteger
                                            ,Quer.FieldByName('Larg').AsInteger
                                            ,Quer.FieldByName('Altu').AsInteger
                                            ,Quer.FieldByName('LargVert').AsInteger
                                            ,Quer.FieldByName('LargHori').AsInteger);
                      Quer.Close;
                    end
                    else if Camp = 'IMPR' then
                    begin
                      Quer.SQL.Text := vLinh;
                      Quer.Open;
                      ACBrETQ.Imprimir(Quer.FieldByName('Qtde').AsInteger
                                      ,Quer.FieldByName('Avan').AsInteger);
                      //ACBrETQ.Desativar;
                      Quer.Close;
                      //ACBrETQ.Free;
                      //Break;
                    end;
                  end
                  else if (StrIn(vTipo,['S3','GG'])) then
                  begin
                    {$ifdef ERPUNI}
                      msgOk('Operação não tratada na WEB: '+vTipo);
                    {$else}
                      Result := ERP_CampPersExecListInst( TsgForm(iForm), vLinh);
                    {$endif}
                  end
                  else if vTipo = 'PA' then  //Pare
                  begin
                    if (NuloReal(CampPersExec(Linh)) = 0) then  //Parar
                    begin
                      Result := False;
                      SetPADOConn(DtmPoul.DtbGene);
                      Exit;
                    end;
                  end
                  else if vTipo = 'SO' then //SOm - Beep
                  begin
                    sAux1 := Copy(Linh,01,01);
                    if IsDigit(sAux1) then
                      BeepTemp(StrToInt(sAux1));
                  end
                  else if vTipo = 'EM' then  //E-Mail
                  begin
                    MaiEnvi := TEnviMail(FindComponent('MaiEnvi'));
                    if not Assigned(MaiEnvi) then
                    begin
                      MaiEnvi := TEnviMail.Create(iForm);
                      MaiEnvi.Name := 'MaiEnvi';
                    end;

                    {$ifdef ERPUNI}
                      if PalaContem(Camp, 'ENVIAR') then
                      begin
                        MaiEnvi.TipoEnviar := Camp;
                        iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, MaiEnvi.PLSAG).Msg;
                      end
                      else
                    {$endif}
                    begin
                      Result := MaiEnvi.SetPLSAG(vLinh).Result;
                      iForm.RetoFunc := MaiEnvi.sgResult.Msg;
                    end;
                  end
                  else if vTipo = 'LC' then  //Lista CheckBox
                  begin
                    Lst := TLstLbl(FindComponent('Lst'+Camp));
                    if Copy(AnsiUpperCase(Linh),01,04) = 'EXEC' then  //Faz o Loop
                    begin
                      //Pega somente as linhas deste EXEC
                      Linh := AnsiUpperCase(Linh);
                      GetConfWeb.MemVal1.Clear;
                      iAux2 := 0;
                      for iAux1 := 0 to Lst.Lista2.Count-1 do
                      begin
                        if AnsiUpperCase(Trim(Lst.Lista2[iAux1])) = '--'+Linh+'INIC' then
                          iAux2 := 1
                        else if AnsiUpperCase(Trim(Lst.Lista2[iAux1])) = '--'+Linh+'FINA' then
                          iAux2 := 0;

                        if iAux2 = 1 then
                         GetConfWeb.MemVal1.Add(Lst.Lista2[iAux1]);
                      end;
                      //Fim do Pega linhas

                      {$ifdef ERPUNI}
                        Lst.Query.DisableControls;
                        try
                          for iAux2 := 0 to Lst.SelectedRows.Count - 1 do
                          begin
                            Lst.Query.Bookmark := Lst.SelectedRows[iAux2];
                            Result := CampPersExecListInst(iForm, GetConfWeb.MemVal1);
                          end;
                        finally
                          Lst.Query.EnableControls;
                          //iAux2 := 0;
                        end;
                      {$else}
                        //Executa para cada item Selecionado
                        for iAux1 := 0 to Lst.Items.Count-1 do
                        begin
                          if Lst.Items.Item[iAux1].Checked then
                          begin
                            Lst.ItemIndex := iAux1; //Posiciona no item selecionado
                            Result := CampPersExecListInst(iForm, GetConfWeb.MemVal1);
                            if not Result then
                              Exit;
                          end;
                        end;
                        //Fim Executa para cada item Selecionado
                      {$endif}

                      GetConfWeb.MemVal1.Clear;
                    end
                    else
                    begin
                      Quer := TsgQuery.Create(iForm);
                      try
                        if Acao = 'M' then  //Marcar os itens conforme filtro passado
                        begin
                          Quer.SQL.Text := SubsCampPers(iForm, Lst.Query.SQL_Back.Text);
                          if AnsiUpperCase(Linh) <> 'ABRE' then
                            Quer.SQL.Strings[4] := Linh;
                          if Quer.SQL.Count > 0 then
                            Quer.Open;
                          {$ifdef ERPUNI}
                            Lst.SelectedRows.Delete;
                            while not Quer.Eof do
                            begin
//                              if Lst.Query.Fields[0].AsString = Quer.Fields[0].AsString then
//                                Lst.seleciona;
                              Quer.Next;
                            end;
                          {$else}
                            ListViewSele(Lst, False);
                            iAux1 := 0;
                            while iAux1 < Lst.Items.Count  do
                            begin
                              iAux2 := 0;
                              Quer.First;
                              while not (Quer.eof) and (iAux2 = 0) do
                              begin
                                if Lst.Items.Item[iAux1].SubItems[0] = Quer.Fields[0].AsString then
                                begin
                                  Lst.Items.Item[iAux1].Checked := True;
                                  iAux2 := 1;
                                end;
                                Quer.Next;
                              end;
                              Inc(iAux1);
                            end;
                          {$endif}
                        end
                        else
                        begin
                          Lst.Query.Close;
                          if Lst.Query.SQL.Count >= 4 then
                            sAux1 := Lst.Query.SQL.Strings[4]
                          else
                            sAux1 := '';
                          Lst.Query.SQL.Text := SubsCampPers(iForm, Lst.Query.SQL_Back.Text);
                          if AnsiUpperCase(Linh) <> 'ABRE' then
                            Lst.Query.SQL.Strings[4] := Linh
                          else
                            Lst.Query.SQL.Strings[4] := sAux1;
                          Lst.CarregaDados;
                        end;
                      finally
                        Quer.sgClose;
                        Quer.Free;
                      end;
                      //Quer.Close;
                      if Assigned(Lst.Onclick) then
                        Lst.OnClick(Lst);
                    end;
                  end
                  else if vTipo = 'TI' then  //Timmer
                  begin
                    Tim := TsgTim(FindComponent('Tim'+Camp));
                    if AnsiUpperCase(Copy(Linh,01,04)) = 'ATIV' then
                      Tim.Enabled := True
                    else if AnsiUpperCase(Copy(Linh,01,04)) = 'DESA' then
                      Tim.Enabled := False;
                  end
                  else if vTipo = 'TH' then
                  begin
                    if Camp = 'SLEEP' then
                    begin
                      Sleep(StrToInt(Linh));
                    end;
                  end;
                except
                  on E: Exception do
                     vMensagem := E.Message;
                end;
                if vMensagem <> '' then
                begin
                  if vTipo <> 'OD' then
                  begin
                    if sgPos('[MENSSAG_EXIB]', vMensagem) > 0 then
                      vMensagem := vMensagem+sgLn+
                                   'Problema no Campo '''+Camp+''' na instrução'+sgLn+
                                   List.Strings[NumeLinh]+sgLn+
                                   sgLn+
                                   'Linha: '+Linh
                    else
                      vMensagem := '[MENSSAG_EXIB]: Problema no Campo '''+Camp+''' na instrução'+sgLn+
                                   List.Strings[NumeLinh]+sgLn+
                                   sgLn+
                                   'Linha: '+Linh+sgLn+
                                   sgLn+
                                   'Mensagem Interna:'+sgLn+
                                   vMensagem;
                  end;

                  Result := False;
                  SetPADOConn(DtmPoul.DtbGene);
                  msgRaiseTratada(vMensagem, vMensagem);
                  Exit;
                end;
              end;
            end;
          end;
        end;
        Inc(NumeLinh);
        //SeStri(DtsGrav.DataSet.Modified,'','');
      end;
    end;
  finally
    sList.Free;
  end;
end;

//Retorna uma propriedade do Campo
Function CampPersCompAtuaGetProp(iForm: TsgForm; Comp: TObject; Prop: String): Variant;
var
  Labe: TsgLbl;
begin
  Labe := nil;
  Prop := AnsiUpperCase(Prop);
  if Prop = 'NUMERO' then
    Result := 0
  else if Prop = 'MODIFIED' then
    Result := False
  else if Prop = 'LISTA' then
    Result := ''
  else if Prop = 'CAPTION' then
    Result := '';

  if Comp <> nil then
  begin
    if Comp.ClassType = TDbEdtLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDbEdtLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := TDbEdtLbl(Comp).Modified
      else if Prop = 'LISTA' then
        Result := TDbEdtLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDbEdtLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBCmbLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBCmbLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := VarToStr(TDBCmbLbl(Comp).Field.OldValue) <> VarToStr(TDBCmbLbl(Comp).Field.NewValue)
      else if Prop = 'LISTA' then
        Result := TDBCmbLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBCmbLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBFilLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBFilLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := TDBFilLbl(Comp).Modified
      else if Prop = 'LISTA' then
        Result := TDBFilLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBFilLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBRxDLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBRxDLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TDBRxDLbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TDBRxDLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBRxDLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBRxELbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBRxELbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TDBRxELbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TDBRxELbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBRxELbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBChkLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBChkLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := VarToStr(TDBChkLbl(Comp).Field.OldValue) <> VarToStr(TDBChkLbl(Comp).Field.NewValue)
      else if Prop = 'LISTA' then
        Result := TDBChkLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Result := TDBChkLbl(Comp).Caption
    end
    else if Comp.ClassType = TChkLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TChkLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := True
      else if Prop = 'LISTA' then
        Result := TChkLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Result := TChkLbl(Comp).Caption
    end
    else if Comp.ClassType = TDBLcbLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBLcbLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := VarToStr(TDBLcbLbl(Comp).DataBinding.Field.OldValue) <> VarToStr(TDBLcbLbl(Comp).DataBinding.Field.NewValue)
      {$endif}
      else if Prop = 'LISTA' then
        Result := TDBLcbLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBLcbLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TLcbLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TLcbLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := True
      else if Prop = 'LISTA' then
        Result := TLcbLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TLcbLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBLookNume then
    begin
      if Prop = 'NUMERO' then
        Result := TDBLookNume(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := TDBLookNume(Comp).Modified
      else if Prop = 'LISTA' then
        Result := TDBLookNume(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBLookNume(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBRchLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBRchLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False //Sempre estava true -> TDBRchLbl(Comp).Modified
      else if Prop = 'LISTA' then
        Result := TDBRchLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBRchLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBMemLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBMemLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := TDBMemLbl(Comp).Modified
      else if Prop = 'LISTA' then
        Result := TDBMemLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBMemLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TMemLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TMemLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TMemLbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TMemLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TMemLbl(Comp).LblAssoc
    end
    else if (Comp.ClassType = TDBAdvMemLbl)  then
    begin
      if Prop = 'NUMERO' then
        Result := TDBAdvMemLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TDBAdvMemLbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TDBAdvMemLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBAdvMemLbl(Comp).LblAssoc
    end
    else if (Comp.ClassType = TAdvMemLbl)  then
    begin
      if Prop = 'NUMERO' then
        Result := TAdvMemLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TAdvMemLbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TAdvMemLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TAdvMemLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TRxEdtLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TRxEdtLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TRxEdtLbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TRxEdtLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TRxEdtLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TEdtLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TEdtLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
        else if Prop = 'MODIFIED' then
          Result := TEdtLbl(Comp).Modified
      {$endif}
      else if Prop = 'LISTA' then
        Result := TEdtLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TEdtLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TFilLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TFilLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := TFilLbl(Comp).Modified
      else if Prop = 'LISTA' then
        Result := TFilLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TFilLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TCmbLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TCmbLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := True
      else if Prop = 'LISTA' then
        Result := TCmbLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TCmbLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TRxDatLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TRxDatLbl(Comp).Numero
      {$ifdef ERPUNI}
      {$else}
      {$endif}
      else if Prop = 'LISTA' then
        Result := TRxDatLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TRxDatLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TDBImgLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TDBImgLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False        //VarToStr(TDBChkLbl(Comp).Field.OldValue) <> VarToStr(TDBChkLbl(Comp).Field.NewValue)
      else if Prop = 'LISTA' then
        Result := TDBImgLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TDBImgLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TsgBtn then
    begin
      if Prop = 'NUMERO' then
        Result := TsgBtn(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False
      else if Prop = 'LISTA' then
        Result := TsgBtn(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := nil
    end
    else if Comp.ClassType = TLstLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TLstLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False
      else if Prop = 'LISTA' then
        Result := TLstLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TLstLbl(Comp).LblAssoc
    end
    else if (Comp is TsgDBG) {$ifdef ERPUNI} {$else} or (Comp.ClassType = TcxGridSite) {$endif} then
    begin
      if Prop = 'MODIFIED' then
        Result := false
      else if Prop = 'CAPTION' then
        Labe := nil
      else
      begin
        with iForm do
        begin
          if (sgActiveGrid is TsgDBG) {$ifdef ERPUNI} {$else} or (sgActiveGrid.ClassType = TcxGridSite) {$endif} then
          begin
          if Prop = 'NUMERO' then
            Result := TsgDBG(sgActiveGrid).Numero
          else if Prop = 'LISTA' then
            Result := TsgDBG(sgActiveGrid).Lista.Text
          end
          else if (Comp is TsgDBG) then
          begin
            if Prop = 'NUMERO' then
              Result := TsgDBG(Comp).Numero
            else if Prop = 'LISTA' then
              Result := TsgDBG(Comp).Lista.Text
          end;
        end;
      end;
    end
    else if Comp.ClassType = TImgLbl then
    begin
      if Prop = 'NUMERO' then
        Result := TImgLbl(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False
      else if Prop = 'LISTA' then
        Result := TImgLbl(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := TImgLbl(Comp).LblAssoc
    end
    else if Comp.ClassType = TsgQuery then
    begin
      if Prop = 'NUMERO' then
        Result := TsgQuery(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False
      else if Prop = 'LISTA' then
        Result := TsgQuery(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := nil
    end
    else if Comp.ClassType = TsgTim then
    begin
      if Prop = 'NUMERO' then
        Result := TsgTim(Comp).Numero
      else if Prop = 'MODIFIED' then
        Result := False
      else if Prop = 'LISTA' then
        Result := TsgTim(Comp).Lista.Text
      else if Prop = 'CAPTION' then
        Labe := nil
    end;
  end;

  if (Prop = 'CAPTION') then
  begin
    if (Labe <> nil) then
      Result := Labe.Caption;
    Result := SubsPalaTudo(Result,'&','');
  end;
end;

//Executar direto pela tela, passando a String
//quando passa uma string para ser executada, feita no código, não no componente (na unha)
function CampPersExecDireStri(iForm: TsgForm; Valo, Pers: String; const iComp: TObject = nil): Boolean;
var
  List: TStrings;
begin
  List := TStringList.Create;
  try
    List.Text := CampPers_TratExec(iForm, Valo, Pers);
  finally
    Result := CampPersExecListInst(iForm, List);
    List.Free;
  end;
end;

//Executar o Exit, chamando a função para executar as instruções contidas na Lista
procedure CampPersDuplCliq(iForm: TsgForm; Sender: TObject; ExecShow: Boolean = False);
//var
//  Lst: TLstLbl;
begin
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    if Sender.ClassType = TLstLbl then
    begin
      with TLstLbl(Sender) do
      begin
        {$ifdef ERPUNI}
        {$else}
          if Items.Count > 0 then
            ListViewSele(TLstLbl(Sender), not Items.Item[0].Checked); //Pega o primeiro item e marca todos invertido
        {$endif}
        OnClick(Sender);
      end;
    end;
  end;
end;

//Executar os Exit's dos campos no OnShow
Procedure CampPersExecExitShow(iForm: TsgForm; CodiTabe: Integer);
var
  List: TStrings;
  i: Integer;
  cds: TClientDataSet;
begin
  List := TStringList.Create;
  try
    cds := DtmPoul.Campos_Cds(CodiTabe, '', '(ExisCamp = 0) '+
                                  'AND (CompCamp <> ''BTN'') '+
                                  'AND (CompCamp <> ''DBG'') '+
                                  'AND (CompCamp <> ''GRA'') '+
                                  'AND (CompCamp <> ''TIM'') '+
                                  'AND (CompCamp <> ''BVL'') '+
                                  'AND (CompCamp <> ''LBL'') '+
                                  'AND (CompCamp <> ''LC'') ');
    cds.IndexFieldNames := 'GuiaCamp;OrdeCamp';
    cds.First;
    while not cds.Eof do
    begin
      if Trim(cds.FieldByName('ExprCamp').AsString) <> '' then
      begin
        with iForm do
        begin
          if ((cds.FieldByName('CompCamp').AsString = 'L') or
              (cds.FieldByName('CompCamp').AsString = 'IL')) and
             (TDBLookNume(FindComponent('Edt'+cds.FieldByName('NameCamp').AsString)).ValorGravado = 0) then
          begin
            cds.Next;
            Continue;
          end
          else
          begin
            SetPLblAjud_Capt('Exit-Show: '+cds.FieldByName('NameCamp').AsString);
            List.Text := cds.FieldByName('ExprCamp').AsString;
            i := 0;
            while i < List.Count do
            begin
              if (Copy(Trim(List[i]),01,01) = 'M') or
                 (Copy(Trim(List[i]),01,02) = 'EX') or
                 (Copy(Trim(List[i]),01,02) = 'BO') or
                 //(Copy(Trim(List[i]),01,02) = 'BF') or  //Botão fecha é só para habilitar ou não o mesmo, então, pode executar a instrução
                 (Copy(Trim(List[i]),01,02) = 'BC') or
                 (Copy(Trim(List[i]),01,02) = 'TI') then
              begin
                if (Copy(Trim(List[i]),01,01) = 'M') then
                  List.Delete(i); //e delete a linha que contém a Mensagem
                List.Delete(i); //Deleta a linha que contém a Instrução
              end
              else
                Inc(i);
            end;
            CampPersExecListInst(iForm, List);
          end;
        end;
      end;
      cds.Next;
    end;
  finally
    cds.Close;
    FreeAndNil(cds);
    List.Free;
  end;
end;

//Verificar se executa a linha ou não
function CampPersValiExecLinh(Linh: String): Boolean;
begin
  Linh := Trim(Linh);
  Result := ((Copy(Linh,01,02) <> '--') and //Comentário
             (Copy(Linh,01,02) <> '//') and //Comentário
             (Linh <> '') and
             (Pos('-', Linh) > 0)) OR  //Feito isso porque os campo Informação, os Campo e a Tabela é jogada na Lista Também. E eles não Executa na Saída
            (Copy(Linh,01,03) = 'FOM') or  //Executa na saída que não tem traço. FOM1010
            (Copy(Linh,01,03) = 'FOS') or  //Executa na saída que não tem traço. FOS1010
            (Copy(Linh,01,03) = 'FOC'); //Executa na saída que não tem traço. FOC1010
end;

//Executa os SQL (faz as validações)
Function CampPers_ExecData(Inst: String): TDateTime;
begin
  try
    if Inst = 'NULL' then
      Result := 0
    else if ExecPers_isConst(Inst) then
      Result := ExecExprMate('['+SubsPala(SubsPala(Inst,'[',''),']','')+']')
    else
      Result := CalcData(Inst);
  finally
  end;
end;

//Executa linha
Function CampPers_ExecLinhStri(Inst, Camp: String): String;
var
  vMensagem: String;
begin
  vMensagem := '';
  try
    if (Copy(Inst,01,01) = '''') then //Aspas Simples
      Result := Copy(Trim(Inst),02,Length(Trim(Inst))-02)
    else if (sgCopy(Inst,01,05) = sgCopy(FormDataSQL(Date),01,05)) or
            (sgCopy(Inst,01,05) = sgCopy(FormHoraSQL(Date),01,05)) then
    begin
      Result := Trim(Inst);
      Result := Copy(Result, Pos('''',Result)+1, MaxInt);
      Result := Copy(Result, 01, Pos('''',Result)-1);
    end
    else if (sgCopy(Inst,01,06) = 'SELECT') then //SELECT
      Result := CalcStri(Inst)
    else if (sgCopy(Inst,01,05) = 'WITH ') then
      Result := CalcStri(Inst)
    else if (sgCopy(Inst,01,06) = 'UPDATE') or   //UPDATE
            (sgCopy(Inst,01,06) = 'DELETE') then //DELETE
      ExecSQL_(Inst)
    else if ExecPers_isConst(Inst) then
      Result := ExecExprMate('['+SubsPala(SubsPala(Inst,'[',''),']','')+']')
    else if (sgCopy(Inst,01,03) = 'IF(') or    //Funcoes
            (sgCopy(Inst,01,04) = 'FUN_') then
      Result := ExecExprMate(Inst)
    //?? Sidi else if Inst = 'NULL' then
    //  Result := ''
    else
      Result := Inst;
  except
    on E: Exception do
       vMensagem := E.Message;
  end;

  if msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema no Campo '''+Camp+''' ao executar Linha String'+sgLn+
                                 Inst+sgLn+
                                 sgLn+
                                 'Mensagem Interna:'+sgLn+
                                 vMensagem) then
    Result := '#ERRO#'
  else
    Result := SubsPala(Result, #10, sgLn);
end;

//Executa os SQL (faz as validações)
Function CampPersExec(Inst: String): Variant;
var
  vMensagem: String;
begin
  vMensagem := '';
  try
    Result := Null;
    if Inst = 'NULL' then
      Result := Null
    else if ExecPers_isConst(Inst) then
      Result := ExecExprMate('['+SubsPala(SubsPala(Inst,'[',''),']','')+']')
    else if (Copy(Inst,01,01) = '''') then //Aspas Simples
      Result := Copy(Trim(Inst),02,Length(Trim(Inst))-02)
    else if (AnsiUpperCase(Copy(Inst,01,01)) = 'S') or (AnsiUpperCase(Copy(Inst,01,08)) = '/*ABRE*/') then //SELECT
    begin
      if (AnsiUpperCase(Copy(Inst,01,12)) = '/*ABRE*/EXEC') then
      begin
        if (GetPBas() = 4) then
          Inst := SubsPalaTudo(Inst,'/*ABRE*/EXEC','SELECT')+ ' FROM DUAL'
        else if (GetPBas() = 2) then
          Inst := TiraPare(Inst);
      end;

      Result := CalcCamp(Inst);
      //if VarIsNull(Result) then
      //  Result := '';
    end
    else if (AnsiUpperCase(Copy(Inst,01,06)) = 'UPDATE') or   //UPDATE
            (AnsiUpperCase(Copy(Inst,01,06)) = 'DELETE') or   //DELETE
            (AnsiUpperCase(Copy(Inst,01,06)) = 'EXECUT') or   //Execute
            (AnsiUpperCase(Copy(Inst,01,08)) = '/*EXEC*/') then //Execute
      ExecSQL_(Inst)
    else  //Expressão
    begin
      Result := ExecExprMate(Inst);
      if NuloStri(Result) = 'NULL' then
        Result := Null;
    end;
  except
    on E: Exception do
       vMensagem := E.Message;
  end;
  if msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema ao executar SQL'+sgLn+
                             Inst+sgLn+
                             sgLn+
                             'Mensagem Interna:'+sgLn+
                             vMensagem) then
  begin
    Result := Null;
  end;
end;

//---> Procedimento para Chamar Telas com o SHOWMODAL com definição de Acesso e Abrindo Query para Inclusão
//---> Parâmetros: Form: Formulário a Ser Criado e Chamado
//---->            Quer: Query Tela do formulário Atual
//---->            Cham: Linha que tem a instrução para Chamar o Formulário
//---->            Inst: Instruções que estão executadas (o que será executado enquanto chama e após voltar)
Function CampPers_ChamTelaDire(iForm: TsgForm; Quer: TsgQuery; Cham: String; Inst: String): Boolean;
var
  NomeForm, vAcao, vExec: string;
  vClic: TTipoClic;
  i : Integer;
  {$ifdef ERPUNI}
    FormRelaModal: TUniForm;
  {$else}
    FormTabe: TForm;
    vPare: TComponent;
    AchoFO, vCriaPare: Boolean;
    vNomePare: string;
  {$endif}
  PTabAnte: Integer;
begin
  Result := True;
  Screen.Cursor:=crHourGlass;

  PTabAnte := GetPTab;
  if (PTabAnte = 0) and Assigned(iForm) and Assigned(iForm.sgTransaction) then
      PTabAnte := iForm.sgTransaction.CodiTabe; //Ticket 21018 - ALI
  try
    SetPTab(StrToInt(Trim(Copy(Cham,04,08))));
    if (GetPTab = 0) then
      MsgAviso('Tabela não Informada (CodiTabe = 0)')
    else
    begin
      vClic := ClicTabe_To_TipoClic(DtmPoul.Tabelas_Busc('ClicTabe', '(CodiTabe = '+IntToStr(GetPTab)+')'));

      if VeriAcesTabe(GetPTab, 3, vClic) then
      begin
        vAcao := sgCopy(Cham,03,01);
        vExec := Copy(Cham, 13, MaxInt);
        if vAcao = 'C' then  //Chama Consulta
        begin
          DtmPoul.QryTabelas.Close;
          DtmPoul.QryTabelas.Params[0].Value := GetPTab;
          DtmPoul.QryTabelas.Open;
          {$ifdef ERPUNI}
            FrmPOGeCon2 := TFrmPOGeCon2.Create(UniApplication);
            FrmPOGeCon2.Parent := iForm;
          {$else}
            FrmPOGeCon2 := TFrmPOGeCon2.Create(iForm);
          {$endif}
          FrmPOGeCon2.MemVlor.Text := Inst;
          FrmPOGeCon2.SQL_Bot_ := vExec;
          if Assigned(iForm) then
            FrmPOGeCon2.sgTransaction := iForm.sgTransaction;
          FrmPOGeCon2.ShowModal;
        end
        else
        begin
          NomeForm := DtmPoul.Tabelas_Busc('FormTabe', '(CodiTabe = '+IntToStr(GetPTab)+')');
          if Trim(NomeForm) = '' then
            msgOk('Formulário não Encontrado ('+FormInteBras(GetPTab())+')')
          else
          begin
            {$ifdef ERPUNI}
              FormRelaModal := TUniFormClass(FindClass(NomeForm+'Modal')).Create(uniGUIApplication.UniApplication);
              try
                with FormRelaModal do
                begin
                  FormRelaModal.HelpContext := GetPTab();
                  if Assigned(iForm) then
                  begin
                    FormRelaModal.Parent := iForm;
                    TsgFormModal(FormRelaModal).sgTransaction := iForm.sgTransaction;
                    SetPsgTrans(iForm.sgTransaction);
                  end;
                  TsgFormModal(FormRelaModal).FormRela := iForm;
                  TsgFormModal(FormRelaModal).sgIsMovi := False;

                  if Assigned(iForm) then
                    iForm.AcaoPnls := False;

                  with TsgFormModal(FormRelaModal) do
                  begin
                    ConfTabe.CodiTabe := GetPTab;
                    TsgFormModal(FormRelaModal).sgTipoClic := vClic;
                    if vAcao <> 'M' then
                    begin
                      TsgFormModal(FormRelaModal).ConfTabe.FechaConfirma := True;
                      if Trim(Quer.SQL.Strings[2]+Quer.SQL.Strings[3]+Quer.SQL.Strings[4]) = '' then
                        ConfTabe.CodiGrav := 0
                      else
                        ConfTabe.CodiGrav := CalcInte('SELECT '+ConfTabe.NomeCodi+' FROM '+ConfTabe.GravTabe+' '+
                                                      Quer.SQL.Strings[2]+Quer.SQL.Strings[3]+Quer.SQL.Strings[4]);
                      PSitGrav := ConfTabe.CodiGrav = 0;
                      ConfTabe.SituGrav := PSitGrav;
                    end;
                  end;
                  with iForm do
                    TsgQuery(BuscaComponente('QryTela')).SQL.Strings[4] := 'WHERE (1 = 2)'; //Limpa o Query Tela

                  TsgFormModal(FormRelaModal).SetExecShowClosTela(Inst);

                  FormRelaModal.ShowModal;
                end;
              finally
              end;
            {$else}
              vCriaPare := sgPos('CRIAPARE.',vExec) > 0;
              vPare := nil;
              if vCriaPare then
              begin
                vNomePare := Copy(vExec, sgPos('CRIAPARE.',vExec)+9, MaxInt);
                vPare := iForm.FindComponent(vNomePare);
                if not Assigned(vPare) then
                  raise Exception.Create('[MENSSAG_EXIB]: Componente Parente não Encontrado: '+vNomePare+sgLn+Cham);
              end;

              FormTabe := TFormClass(FindClass(NomeForm)).Create(vPare);
              try
                with FormTabe do
                begin
                  if vCriaPare then
                  begin
                    FormTabe.Parent  := TWinControl(vPare);
                    FormTabe.Align   := alClient;
                    FormTabe.BorderStyle := bsNone;
                  end;
                  HelpContext := GetPTab();
                  if Assigned(iForm) and Assigned(iForm.sgTransaction) and iForm.sgTransaction.InTransaction then
                  begin
                    TsgForm(FormTabe).sgTransaction := iForm.sgTransaction;
                    SetPsgTrans(iForm.sgTransaction);
                  end;
                  TsgForm(FormTabe).ConfTabe.CodiTabe := GetPTab();
                  TsgForm(FormTabe).sgIsMovi   := False;
                  TsgForm(FormTabe).sgTipoClic := vClic;

                  TMemo(FindComponent('MemGene')).Lines[0] := TsgForm(FormTabe).ConfTabe.GravTabe;

                  if (vAcao <> 'M') and (not (vClic in [tcClicShow, tcClicShowAces])) then
                  begin
                    TsgForm(FormTabe).ConfTabe.FechaConfirma := True;
                    if FormTabe is TFrmPOHeGer6 then //TFrmPOHeGer6 inicializa o sgTransaction proprio
                      Quer.sgConnection := TsgForm(FormTabe).sgTransaction;
                    if Assigned(TDataSource(FindComponent('DtsGrav')).DataSet) then
                      TDataSource(FindComponent('DtsGrav')).DataSet.DisableControls;
                    Quer.DisableControls;
                    Quer.SQL.Strings[0] := 'SELECT *';
                    Quer.SQL.Strings[1] := 'FROM '+TsgForm(FormTabe).ConfTabe.GravTabe;
                    if Trim(Quer.SQL.Strings[2]+Quer.SQL.Strings[3]+Quer.SQL.Strings[4]) = '' then
                      Quer.SQL.Strings[4] := 'WHERE (1 = 2)';
                    Quer.Open;
                    TsgForm(FormTabe).ConfTabe.SituGrav := Quer.IsEmpty;
                    if Quer.IsEmpty then
                    begin
                      Quer.Append;
                      Caption := sInclusao+' de ';
                    end
                    else
                    begin
                      Quer.Edit;
                      Caption := sAlteracao+' de ';
                    end;
                    TDataSource(FindComponent('DtsGrav')).DataSet := Quer;
                    Quer.EnableControls;
                  end
                  else
                  begin
                    TsgForm(FormTabe).sgTipoClic := vClic;
                    Caption := '';
                  end;

                  Caption := Caption + TsgForm(FormTabe).ConfTabe.NomeTabe;

                  GetConfWeb.MemVal1.Clear;
                  GetConfWeb.MemVal1.Text := Inst;
                  i := 0;
                  AchoFO := False;  //Exclui todas as linhas antes do FO, para ser executado no on-show, só as linhas que estiverem após criar a tela.
                  while i < GetConfWeb.MemVal1.Count do
                  begin
                    if (Copy(Trim(GetConfWeb.MemVal1.Strings[i]),01,02) = 'FO') then  //Apago tudo até o FO
                    begin
                      GetConfWeb.MemVal1.Delete(i);
                      AchoFO := True;
                    end
                    else if (Copy(Trim(GetConfWeb.MemVal1.Strings[i]),01,02) = 'QT') OR
                            (Copy(Trim(GetConfWeb.MemVal1.Strings[i]),01,02) = 'FV') or
                            (not AchoFO) then
                      GetConfWeb.MemVal1.Delete(i)
                    else
                      Inc(i);
                  end;
        //          CampPersExecListInst(FormTabe, MemVal1);
        //          MemVal1.Clear;

                  if vAcao = 'S' then  //Show
                  begin
                    Inst := ''; //Não existe o Executa após formulário (FV)
                    if not Visible then
                      Visible := True;
                    if FormStyle <> fsMDIChild then
                      FormStyle := fsMDIChild;
                    Show;
                  end
                  else
                  begin
                    if FormStyle <> fsNormal then
                      FormStyle := fsNormal;

                    if vCriaPare then
                    begin
                      if not FormTabe.Visible then
                        FormTabe.Visible := True;
                      Show;
                    end
                    else
                    begin
                      if Visible then
                        Visible := False;
                      ShowModal;

                      //Executa após voltar da tela
                      TsgQuery(FindComponent('QryTela')).SQL.Strings[4] := 'WHERE (1 = 2)'; //Limpa o Query Tela
                    end;
                  end;
                end;
              finally
                if not vCriaPare then
                  FormTabe.Free;
              end;
            {$endif}
          end;
        end;

        //{$ifdef ERPUNI}
        //{$else}
          if Result then
          begin
            ExibMensHint('Executa após Formulário');
            GetConfWeb.MemVal1.Clear;
            GetConfWeb.MemVal1.Text := Inst;
            i := 0;
            while i < GetConfWeb.MemVal1.Count do
            begin
              if (Copy(Trim(GetConfWeb.MemVal1.Strings[i]),01,02) <> 'FV') then
                GetConfWeb.MemVal1.Delete(i)
              else
              begin
                GetConfWeb.MemVal1.Strings[i] := Copy(Trim(GetConfWeb.MemVal1.Strings[i]),04,Length(Trim(GetConfWeb.MemVal1.Strings[i]))-03);
                Inc(i);
              end;
            end;
            Result := CampPersExecListInst(iForm, GetConfWeb.MemVal1);
            GetConfWeb.MemVal1.Clear;
          end;
        //{$endif}
      end
      else
      begin
        Result := False;
        msgOk('Acesso negado para Consulta!');
      end;
    end;
  finally
    Screen.Cursor:=crDefault;
    SetPTab(PTabAnte);
    if Assigned(iForm) and Assigned(iForm.sgTransaction) then
      iForm.sgTransaction.CodiTabe := PTabAnte;
  end;
end;

//---> Função para o Clique nas Pastas das Tabelas Relacionadas
Function ClicPast(Form, Camp, Sele: String; Quer: TsgQuery):Boolean;
var
  vCodiTabeAnte: Integer;
begin
  vCodiTabeAnte := GetPTab();
  try
    Result := False;
    if IsDigit(Form) then
      SetPTab(StrToInt(Form))
    else
    begin
      if AnsiUpperCase(Copy(Form,01,03)) <> 'MNU' then
        Form := 'MNU'+Form;

      SetPTab(StrToInt(RetoZero(DtmPoul.Tabelas_Busc('CodiTabe', '(MenuTabe = '+QuotedStr(AnsiUpperCase(Form))+')'))));
    end;

    if GetPTab = 0 then
      msgOk('Tabela não encontrada ('+Form+')!')
    else if not VeriAcesTabe(GetPTab,3) then
      msgOk('Acesso negado para Consulta!!')
    else
    begin
      Screen.Cursor := crHourGlass;
      DtmPoul.QryTabelas.Close;
      DtmPoul.QryTabelas.Params[0].Value := GetPTab;
      DtmPoul.QryTabelas.Open;
      {$IFDEF ERPUNI}
      {$else}
        Application.CreateForm(TFrmPOGeCons,FrmPOGeCons);  //Abre o Formulário Genérico
        FrmPOGeCons.MemVlor.Lines.Text := Camp;
        FrmPOGeCons.SQL_Bot_ := Sele;
        if Quer <> nil then
          Quer.Close;
        Result := (FrmPOGeCons.ShowModal = mrOk);
      {$ENDIF}
      if Quer <> nil then
        Quer.Open;
    end;
  finally
    Screen.Cursor := crDefault;
    SetPTab(vCodiTabeAnte);
  end;
end;

//Executa uma ação no campo
procedure CampPersAcao(iForm: TsgForm; Inst, Acao: String);
var
  vTipo : String;
  Camp: String;
  vText: String;
  CompAtua: {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif};
  Nume: Real;
  Resu: Boolean;
  Cor: Integer;
  vTbsActive: TsgTbs;
  vTbs: TsgTbs;
  vPgc: TsgPgc;
  vCampFocuTbs: {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif};
  vMensagem: String;
begin
  vMensagem := '';
  Resu := False;
  vTipo := Copy(Inst,01,02);
  Nume := 1;
  Camp := Trim(Copy(Inst,04,08));
  CompAtua := nil;
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    try
      vText := RetoZero(Copy(Inst, 13, MaxInt));

      if vText = '0' then
        Resu := False
      else if vText = '1' then
        Resu := True
      else
        Resu := NuloReal(CampPersExec(vText)) <> 0;

      if (vTipo = 'BV')  then
      begin
        if Acao = 'V' then
          TsgBvl(FindComponent('Bvl'+Camp)).Visible := Resu;
      end
      else if (vTipo = 'FF')  then
      begin
        if Acao = 'D' then
          TImgLbl(FindComponent('Img'+Camp)).Enabled := Resu
        else if Acao = 'V' then
          TImgLbl(FindComponent('Img'+Camp)).Visible := Resu
        else if Acao = 'R' then  //Não tem REadOnly
          TImgLbl(FindComponent('Img'+Camp)).Enabled := Resu
      end
      else if (vTipo = 'GD')  then
      begin
        if Acao = 'D' then
          TsgDBG(BuscaComponente('Dbg'+Camp)).Enabled := Resu
        else if Acao = 'V' then
          TsgDBG(BuscaComponente('Dbg'+Camp)).Visible := Resu
        else if Acao = 'R' then  //Não tem REadOnly
        begin
          TsgDBG(BuscaComponente('Dbg'+Camp)).ReadOnly := Resu;
          TsgDBG(BuscaComponente('Dbg'+Camp)).Color := SeInte(Resu, clBtnFace, clWindow);
        end;
      end
      else
      begin
        CompAtua := {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif}(CampPersCompAtua(iForm, vTipo, Camp));
        Nume := CampPersCompAtuaGetProp(iForm, CompAtua, 'Numero');
      end
    except
      on E: Exception do
         vMensagem := E.Message;
    end;
    if msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema no Campo ''{'+Camp+'}'' na instrução'+sgLn+
                                   Inst+sgLn+
                                   sgLn+
                                   'Mensagem Interna:'+sgLn+
                                   vMensagem) then
    begin
      CompAtua := nil;
    end;

    if CompAtua <> nil then
    begin
      try
        if Acao = 'M' then
        begin
          if (CompAtua.ClassType = TEdtLbl) then
            TEdtLbl(CompAtua).EditMask := vText
          else if (CompAtua.ClassType = TDbEdtLbl) then
          begin
            if Assigned(TDbEdtLbl(CompAtua).DataSource.DataSet.FindField(TDbEdtLbl(CompAtua).DataField)) then
              TDbEdtLbl(CompAtua).DataSource.DataSet.FieldByName(TDbEdtLbl(CompAtua).DataField).EditMask := vText;
          end;
        end
        else if Acao = 'C' then
        begin
          with TColorWinControl(CompAtua) do
          begin
            Cor := NuloInte(CampPersExec(Copy(Inst, 13, Length(Inst)-12)));
            Font.Color := Cor;
          end;
          if TsgLbl(FindComponent('Lbl'+Camp)) <> nil then
            TsgLbl(FindComponent('Lbl'+Camp)).Font.Color  := Cor;
        end
        else
        begin
          if Acao = 'D' then
          begin
            if CompAtua is TsgBtn then
            begin
              if Resu then
                TsgBtn(CompAtua).NovoEnabled := neTrue
              else
                TsgBtn(CompAtua).NovoEnabled := neFalse;
            end;
            CompAtua.Enabled := Resu;

            if TsgLbl(FindComponent('Lbl'+Camp)) <> nil then
              TsgLbl(FindComponent('Lbl'+Camp)).Enabled  := CompAtua.Enabled;

            if ((vTipo = 'CT') or (vTipo = 'IT')) and (TsgBtn(FindComponent('Btn'+Camp)) <> nil) then  //Campo Tabela tem o Btn
              TsgBtn(FindComponent('Btn'+Camp)).Enabled  := CompAtua.Enabled
          end
          else if Acao = 'R' then  //ReadOnly é o contrário do Enable and Visible
          begin
            try
              if (vTipo = 'CR') or (vTipo = 'RM') or (vTipo = 'RB') then
                TDBRchLbl(CompAtua).ReadOnly := not Resu
              else if (vTipo = 'CM') or (vTipo = 'M') or (vTipo = 'BM') then
                TDBMemLbl(CompAtua).ReadOnly := not Resu
              else
                TCustomEdit(CompAtua).ReadOnly := not Resu;
              TColorWinControl(CompAtua).Color := SeInte(not Resu, clBtnFace, clWindow);
            except
            end;
          end
          else if Acao = 'V' then
          begin
            CompAtua.Visible := Resu;

            if TsgLbl(FindComponent('Lbl'+Camp)) <> nil then
              TsgLbl(FindComponent('Lbl'+Camp)).Visible  := CompAtua.Visible;

            if ((vTipo = 'CT') or (vTipo = 'IT')) then
              TLcbLbl(FindComponent('Lcb'+Camp)).sgVisible := CompAtua.Visible
            else if (vTipo = 'IL') then
              TDBLookNume(FindComponent('Edt'+Camp)).sgConf.Visible := CompAtua.Visible
            else if (vTipo = 'TS') Then  //Campo TabSheet
            begin
              //{$if defined(LIBUNI) or defined(ERPUNI)}
              //  TsgTbs(FindComponent('Tbs'+Camp)).TabVisible := Resu;
              //{$ELSE}
                vCampFocuTbs := {$ifdef ERPUNI}sgActiveControl{$else}ActiveControl{$endif};
                vPgc := TsgPgc(TsgTbs(FindComponent('Tbs'+Camp)).Parent);
                vTbsActive := TsgTbs(vPgc.ActivePage);
                vTbs := TsgTbs(FindComponent('Tbs'+Camp));
                if Resu and (not vTbs.Ja__Visi) then
                begin
                  vTbs.TabVisible := Resu;
                  vTbs.Ja__Visi := True;
                  vPgc.ActivePage := vTbs;
                  if Assigned(vTbsActive) and vTbsActive.TabVisible then
                    vPgc.ActivePage := vTbsActive;
                  SetaFocu(vCampFocuTbs);
                end
                else
                  vTbs.TabVisible := Resu;
                vTbs.Ja__Visi := Resu;
                //vCampFocuTbs := nil;
                //vPgc := nil;
                //vTbsActive := nil;
                //vTbs := nil;
              //{$endif}
            end;
          end
          else if (Acao = 'S') or //SetFocus depois de uma mensagem
                 ((Acao = 'F') and Resu) then //Focus no campo conforme condição
          begin
            if CompAtua.Enabled and CompAtua.Visible then
            begin
              if Nume < 10 then  //Não são Movimento
              begin
                if NumeroIn(Nume,[1,3]) then //Movimento na primeira página
                  vTbs := TsgTbs(FindComponent('Tbs1'))
                else
                  vTbs := TsgTbs(FindComponent('Tbs'+ZeroEsqu(IntToStr(Trunc(Nume)),02,False)))
              end
              else if Nume = 99 then  //Personalizado
                vTbs := TsgTbs(FindComponent('TbsPers'))
              else
                vTbs := TsgTbs(FindComponent('TbsMov'+IntToStr(Trunc(Nume-10))));

              if not Assigned(vTbs) then
                vTbs := TsgTbs(FindComponent('Tbs'+ZeroEsqu(IntToStr(Trunc(Nume)),02,False)));

              if Assigned(vTbs) then
                TsgPgc(FindComponent('PgcGene')).ActivePage := vTbs;

              SetaFocu(CompAtua);
            end;
          end;
        end;
      except
        on E: Exception do
           vMensagem := E.Message;
      end;
      msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Problema no Campo '''+Camp+''' ao executar uma ação (Desabilitar ou Setar o Foco) na instrução'+sgLn+
                                 Inst+sgLn+
                                 sgLn+
                                 'Mensagem Interna:'+sgLn+
                                 vMensagem);
    end;
  end;
end;

//Executar os 'EX'
Function CampPers_EX(iForm: TsgForm; Camp, Linh: String): Boolean;
var
  Quer, QuerAuxi, QuerMvCx: TsgQuery;
  QryAbre: TADOQuery;
  bAux1: Boolean;
  iAux1, iAux2: Integer;
  sAux1, sAux2, sAux3, sAux4, sAux5: String;
  rAux1: Real;
  ArraStri: array of String;
  lAux1: TStringList;
  Find: TSearchRec;
  dAux1, dAux2: TDateTime;
  vMensagem: String;
  {$ifdef ERPUNI}
    vArquivos: TStringList;
    vArquivo, vLista: String;
  {$endif}
begin
  Result := True;
  try
    with iForm do
    begin
      if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
      {$ifdef WS}
        CoInitialize(nil);
      {$endif}
      QryAbre  := TADOQuery.Create(nil);
      {$ifdef WS}
        CoUninitialize;
      {$endif}
      Quer  := TsgQuery.Create(nil);
      Quer.sgConnection := GetPADOConn;
      lAux1 := TStringList.Create;
      try
        Camp := AnsiUpperCase(Trim(Camp));
        if (Camp = 'PESA_RFC') {or (Camp = 'PESARFCS')} then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          bAux1 := True;
          while (not Quer.Eof){ and (bAux1)} do
          begin
            iAux1 := Quer.FieldByName('CodiEsto').AsInteger;
            iAux2 := SeInte(VeriExisCampTabe(Quer,'CodiMvOc'),Quer.FieldByName('CodiMvOc').AsInteger, 0);
            bAux1 := POChPesa_ConfPesa_RFC(Quer.FieldByName('PesoLiqu').AsFloat
                                         , Quer.FieldByName('DistOrCa').AsFloat
                                         , Quer.FieldByName('CodiProd').AsInteger
                                         , Quer.FieldByName('CodiUnid').AsInteger
                                         , Quer.FieldByName('CodiPlan').AsInteger
                                         , Quer.FieldByName('CodiCent').AsInteger
                                         , Quer.FieldByName('SequPesa').AsInteger
                                         , Quer.FieldByName('CodiOrCa').AsInteger
                                         , Quer.FieldByName('OrCaCodiGene').AsInteger
                                         , Quer.FieldByName('OrCaCodiCida').AsInteger
                                         , Quer.FieldByName('NumeOrca').AsInteger
                                         , Quer.FieldByName('CodiPess').AsInteger
                                         , Quer.FieldByName('CodiSeto').AsInteger
                                         , Quer.FieldByName('CodiTpMv').AsInteger
                                         , Quer.FieldByName('NotaPesa').AsInteger
                                         , Quer.FieldByName('CodiTran').AsInteger
                                         , Quer.FieldByName('DataPesa').AsDateTime
                                         , iAux1
                                         , Quer.FieldByName('TabeOrCa').AsString
                                         , Quer.FieldByName('HistOrCa').AsString
                                         , Quer.FieldByName('UltiPesa').AsInteger <> 0
                                         , Quer.FieldByName('EstoCodiGene').AsInteger
                                         , Quer.FieldByName('TabeEsto').AsString
                                         , Quer.FieldByName('PEmpEsto').AsString
                                         , iAux2
                                         );
            iForm.VariResu[2] := IntToStr(iAux1);
            Quer.Next;
          end;
          iForm.VariResu[1] := SeStri(bAux1,'1','0');
        end
        else if Camp = 'PESARFCS' then //Personalização SAFRA
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          bAux1 := True;
          while (not Quer.Eof){ and (bAux1)} do
          begin
            iAux1 := Quer.FieldByName('CodiEsto').AsInteger;
            iAux2 := SeInte(VeriExisCampTabe(Quer,'CodiMvOc'),Quer.FieldByName('CodiMvOc').AsInteger, 0);
            bAux1 := POChPesa_ConfPesa_RFC_SAFRA(Quer.FieldByName('PesoLiqu').AsFloat
                                         , Quer.FieldByName('DistOrCa').AsFloat
                                         , Quer.FieldByName('CodiProd').AsInteger
                                         , Quer.FieldByName('CodiUnid').AsInteger
                                         , Quer.FieldByName('CodiPlan').AsInteger
                                         , Quer.FieldByName('CodiCent').AsInteger
                                         , Quer.FieldByName('SequPesa').AsInteger
                                         , Quer.FieldByName('CodiOrCa').AsInteger
                                         , Quer.FieldByName('OrCaCodiGene').AsInteger
                                         , Quer.FieldByName('OrCaCodiCida').AsInteger
                                         , Quer.FieldByName('NumeOrca').AsInteger
                                         , Quer.FieldByName('CodiPess').AsInteger
                                         , Quer.FieldByName('CodiSeto').AsInteger
                                         , Quer.FieldByName('CodiTpMv').AsInteger
                                         , Quer.FieldByName('NotaPesa').AsInteger
                                         , Quer.FieldByName('CodiTran').AsInteger
                                         , Quer.FieldByName('DataPesa').AsDateTime
                                         , iAux1
                                         , Quer.FieldByName('TabeOrCa').AsString
                                         , Quer.FieldByName('HistOrCa').AsString
                                         , Quer.FieldByName('UltiPesa').AsInteger <> 0
                                         , Quer.FieldByName('EstoCodiGene').AsInteger
                                         , Quer.FieldByName('TabeEsto').AsString
                                         , Quer.FieldByName('PEmpEsto').AsString
                                         , iAux2
                                         );
            iForm.VariResu[2] := IntToStr(iAux1);
            Quer.Next;
          end;
          iForm.VariResu[1] := SeStri(bAux1,'1','0');
        end
        else if Trim(Camp) = 'PESA' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          bAux1 := True;
          iAux1 := 0;
          while (not Quer.Eof){ and (bAux1)} do
          begin
            if VeriExisCampTabe(Quer, 'CodiPesa') then
              iAux1 := Quer.FieldByName('CodiPesa').AsInteger;
            bAux1 := POChPesa_ConfPesa(iAux1
                                      ,Quer.FieldByName('CodiTran').AsInteger
                                      ,Quer.FieldByName('CODIGENE').AsInteger
                                      ,Quer.FieldByName('CODIMOVI').AsInteger
                                      ,Quer.FieldByName('ULTIPESA').AsInteger
                                      ,Quer.FieldByName('TIPOPESA').AsString
                                      ,Quer.FieldByName('TABEPESA').AsString
                                      ,Quer.FieldByName('HISTPESA').AsString
                                      ,Quer.FieldByName('LACRPESA').AsString
                                      ,Quer.FieldByName('PEMPPESA').AsString
                                      ,Quer.FieldByName('PESOPESA').AsFloat
                                      ,Quer.FieldByName('LIQUPESA').AsFloat);
            iForm.VariResu[2] := IntToStr(iAux1);
            Quer.Next;
          end;
          iForm.VariResu[1] := SeStri(bAux1,'1','0');
        end
        else if Camp = 'GERAINDU' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          bAux1 := True;
          while (not Quer.Eof) and (bAux1) do
          begin
            iAux1 := Quer.FieldByName('CodiEsto').AsInteger;
            bAux1 := GeraIndu(iAux1, 0, Quer.FieldByName('CodiProd').AsInteger, Trunc(PegaParaNume(000,'PPCotaInduCodiPess')),
                             Trunc(PegaParaNume(000,'PPCotaInduCodiSeto')), Trunc(PegaParaNume(000,'PPCotaInduMoviEntr')),
                             Trunc(PegaParaNume(000,'PPCotaInduMoviSaid')), Quer.FieldByName('Data').AsDateTime,
                             Quer.FieldByName('QtdeReal').AsFloat, Quer.FieldByName('QtdePrev').AsFloat, True,
                             Quer.FieldByName('CompEsto').AsString, Quer.FieldByName('TabeEsto').AsString,
                             Quer.FieldByName('CodiGene').AsInteger, GetPADOConn, Quer.FieldByName('CodiCent').AsInteger,
                             VeriExisCampTabe_Valo(Quer,'PEmpEsto',''),
                             StrToInt(RetoZero(VeriExisCampTabe_Valo(Quer,'CodiMvOc','0'))),
                             VeriExisCampTabe_Valo(Quer,'InduSald','0')<>'0',
                             StrToInt(RetoZero(VeriExisCampTabe_Valo(Quer,'CodiPeOu','0'))),
                             StrToInt(RetoZero(VeriExisCampTabe_Valo(Quer,'CodiBtPr','0'))),
                             0, 0, nil, 0, Quer.FieldByName('CodCCent').AsInteger
                             );
            Quer.Next;
          end;
          iForm.VariResu[1] := SeStri(bAux1,'1','0');
        end
        else if Camp = 'APAGINDU' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while not Quer.Eof do
          begin
            ApagIndu(Quer.FieldByName('CodiIndu').AsInteger, Quer.FieldByName('CodiGene').AsInteger, Quer.FieldByName('TabeIndu').AsString, GetPADOConn);
            Quer.Next;
          end;
        end
        else if Camp = 'POCADATA' then  //Gera o POCaData
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          GeraPOCaData(FormDataBras(Quer.FieldByName('DataInic').AsDateTime), FormDataBras(Quer.FieldByName('DataFina').AsDateTime));
        end
        else if Camp = 'POCANUME' then  //Pega o Próximo Nume do POCaNume
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.VariInte[1] := POCaNume_ProxSequ(Quer.FieldByName('Tabe').AsString, Quer.FieldByName('Camp').AsString,
                                                         VeriExisCampTabe_Valo(Quer,'Incr','1') <> '0');
        end
        else if Camp = 'FRETRAES' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            Fret_RateEsto(Quer.FieldByName('CodiEsto').AsInteger, Quer.FieldByName('CodiCida').AsInteger,
                             Quer.FieldByName('CodiTran').AsInteger, Quer.FieldByName('TabeEsto').AsString,
                             Quer.FieldByName('DistTota').asFloat, Quer.FieldByName('GravDist').asBoolean,
                             Quer.FieldByName('Cam1Rate').AsString, Quer.FieldByName('Val1Rate').asFloat
                             );
            Quer.Next;
          end;
        end
        else if Camp = 'CAFRMVAP' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            CalcFret_MvAp(Quer.FieldByName('CodiMvAp').AsInteger, Quer.FieldByName('CodiTran').AsInteger,
                             Quer.FieldByName('DistTota').asFloat, Quer.FieldByName('PesoMvAp').asFloat,
                             Quer.FieldByName('GravDist').asBoolean
                             );
            Quer.Next;
          end;
        end
        else if Camp = 'EXPOTEXT' then  //Exporta Arquivo Texto
          ExpoArquText(Linh)
        else if Camp = 'DLL_' then
        begin
          {$ifdef ERPUNI}
            iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm,'EX-DLL_    -'+Linh).Msg;
            iForm.RetoFunc := AnsiDequotedStr(iForm.RetoFunc,'''');
            if sgPos('::LIST::',iForm.RetoFunc) > 0 then
            begin
              vLista := iForm.RetoFunc.Substring(sgPos('::LIST::',iForm.RetoFunc)+7);
              vArquivos := TStringList.Create;
              try
                vArquivos.Clear;
                ExtractStrings([';'],[], PChar(vLista), vArquivos);

                for vArquivo in vArquivos do
                  if Trim(vArquivo) <> '' then
                    RelaPlus.VisuPDF(vArquivo);
              finally
                FreeAndNil(vArquivos);
              end;
              iForm.RetoFunc := Copy(iForm.RetoFunc, 0, sgPos('::LIST::',iForm.RetoFunc)-1);
            end;
          {$else}
            iForm.RetoFunc := ExecDll_(Linh)
          {$endif}
        end
        else if Camp = 'IMPOARQU' then  //Importa Arquivo
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          if (VeriExisCampTabe_Valo(Quer, 'Dire', '') = '') then
          begin
            if not FileExists(ArquValiEnde(Quer.FieldByName('Arqu').AsString)) then
            begin
              msgOk('Arquivo não Existe! ('+ArquValiEnde(Quer.FieldByName('Arqu').AsString)+')');
              Result := False;
              Exit;
            end;
          end;
          sAux1 := '';
          sAux2 := '';
          sAux3 := '';
          sAux4 := '';
          if VeriExisCampTabe(Quer, 'Fix1') then
          begin
            sAux1 := Quer.FieldByName('Fix1').AsString;
            if VeriExisCampTabe(Quer, 'Val1') then
              sAux2 := Quer.FieldByName('Val1').AsString;
          end;
          if VeriExisCampTabe(Quer, 'Fix2') then
          begin
            sAux3 := Quer.FieldByName('Fix2').AsString;
            if VeriExisCampTabe(Quer, 'Val2') then
              sAux4 := Quer.FieldByName('Val2').AsString;
          end;
          if (VeriExisCampTabe_Valo(Quer, 'Dire', '') <> '') then
          begin
            if FindFirst(ArquValiEnde(Quer.FieldByName('Dire').AsString)+'\'+Quer.FieldByName('Exte').AsString, faAnyFile, Find) = 0 then
            begin
              try
                repeat
                  if not (Find.Attr and faDirectory <> 0) then
                    Result := ImpoArqu(ArquValiEnde(Quer.FieldByName('Dire').AsString)+'\'+Find.Name, Quer.FieldByName('Tabe').AsString, Quer.FieldByName('Camp').AsString, sAux1, sAux2, sAux3, sAux4);
                until FindNext(Find) <> 0;
              finally
                FindClose(Find);
              end;
            end;
          end
          else
            Result := ImpoArqu(ArquValiEnde(Quer.FieldByName('Arqu').AsString), Quer.FieldByName('Tabe').AsString, Quer.FieldByName('Camp').AsString, sAux1, sAux2, sAux3, sAux4);
        end
        else if Trim(Camp) = 'COPYARQU' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            try
              // Para não criar pastas quando o arquivo de origem nao existe
              bAux1 := FileExists(ArquValiEnde(ArquValiEnde(Quer.FieldByName('Origem').AsString)));
            except
              bAux1 := True;
            end;
            if bAux1 then
              CopyArqu(ArquValiEnde(Quer.FieldByName('Origem').AsString)
                      ,ArquValiEnde(Quer.FieldByName('Destino').AsString))
            else
              ExibMensHint('Arquivo Origem não existe: '+ArquValiEnde(ArquValiEnde(Quer.FieldByName('Origem').AsString)));
            Quer.Next;
          end;
        end
        else if Camp = 'COPIARQU' then  //Copia Arquivo
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            if not FileExists(ArquValiEnde(Quer.FieldByName('Orig').AsString)) then
            begin
              msgOk('Arquivo Origem não Existe! ('+ArquValiEnde(Quer.FieldByName('Orig').AsString)+')');
              Result := False;
              Exit;
            end;
            try
              if not CopyFile(PChar(ArquValiEnde(Quer.FieldByName('Orig').AsString)), PChar(ArquValiEnde(Quer.FieldByName('Dest').AsString)), True) then
                RaiseLastOSError;
            except
              on E: Exception do
                 vMensagem := E.Message;
            end;
            if msgRaiseTratada(vMensagem, 'Erro ao copiar arquivo: ' +vMensagem) then
              Exit;
            Quer.Next;
          end;
        end
        else if Camp = 'DELEARQU' then  //Deleta Arquivo
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            if Pos('*',Quer.FieldByName('Arqu').AsString) > 0 then
              Deletefiles(ArquValiEnde(Quer.FieldByName('Arqu').AsString))
            else
              DeleteFile(ArquValiEnde(Quer.FieldByName('Arqu').AsString));
            Quer.Next;
          end;
        end
        else if Camp = 'RENOARQU' then  //Renomeia Arquivo
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            if not FileExists(ArquValiEnde(Quer.FieldByName('Orig').AsString)) then
            begin
              msgOk('Arquivo Origem não Existe! ('+ArquValiEnde(Quer.FieldByName('Orig').AsString)+')');
              Result := False;
              Exit;
            end;
            if FileExists(ArquValiEnde(Quer.FieldByName('Dest').AsString)) then
              DeleteFile(ArquValiEnde(Quer.FieldByName('Dest').AsString));
            RenameFile(ArquValiEnde(Quer.FieldByName('Orig').AsString), ArquValiEnde(Quer.FieldByName('Dest').AsString));
            Quer.Next;
          end;
        end
        else if Camp = 'ARMAARQU' then  //Armazena Arquivo no Banco de Dados
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            if Trim(Quer.FieldByName('Orig').AsString) = '' then
              TDataSource(BuscaComponente('Dts'+Quer.FieldByName('Quer').AsString)).DataSet.FieldByName(Quer.FieldByName('Camp').AsString).Value := null
            else
            begin
              if not FileExists(ArquValiEnde(Quer.FieldByName('Orig').AsString)) then
              begin
                msgOk('Arquivo origem não existe! ('+ArquValiEnde(Quer.FieldByName('Orig').AsString)+')');
                Result := False;
                Exit;
              end;
              TBlobField(TDataSource(BuscaComponente('Dts'+Quer.FieldByName('Quer').AsString)).DataSet.FieldByName(Quer.FieldByName('Camp').AsString)).LoadFromFile(ArquValiEnde(Quer.FieldByName('Orig').AsString));
            end;
            Quer.Next;
          end;
        end
        else if Camp = 'CARRARQU' then  //Carrega o Arquivo do Banco e Salva em Arquivo físico
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            if FileExists(ArquValiEnde(Quer.FieldByName('Dest').AsString)) then
            begin
              if VeriExisCampTabe(Quer,'Subs') and (Quer.FieldByName('Subs').AsInteger <> 0) then
                DeleteFile(ArquValiEnde(Quer.FieldByName('Dest').AsString))
              else if msgNao('Arquivo destino já existe! Substituir? ('+ArquValiEnde(Quer.FieldByName('Dest').AsString)+')') then
              begin
                Result := False;
                Exit;
              end
              else
                DeleteFile(ArquValiEnde(Quer.FieldByName('Dest').AsString));
            end;

            try
              if (TsgQuery(BuscaComponente('Qry'+Quer.FieldByName('Quer').AsString)) <> nil) then
                sAux1 := TsgQuery(BuscaComponente('Qry'+Quer.FieldByName('Quer').AsString)).FieldByName(Quer.FieldByName('Camp').AsString).AsString
              else
                sAux1 := TDataSource(BuscaComponente('Dts'+Quer.FieldByName('Quer').AsString)).DataSet.FieldByName(Quer.FieldByName('Camp').AsString).AsString;

              // XML precisa salvar com o encoding UTF8
              if Pos('encoding="UTF-8"', sAux1) > 0 then
              begin
                lAux1.Clear;
                lAux1.Add(sAux1);
                lAux1.SaveToFile(ArquValiEnde(Quer.FieldByName('Dest').AsString), TEncoding.UTF8);
              end
              else
              begin
                if (TsgQuery(BuscaComponente('Qry'+Quer.FieldByName('Quer').AsString)) <> nil) then
                  TBlobField(TsgQuery(BuscaComponente('Qry'+Quer.FieldByName('Quer').AsString)).FieldByName(Quer.FieldByName('Camp').AsString)).SaveToFile(ArquValiEnde(Quer.FieldByName('Dest').AsString))
                else
                  TBlobField(TDataSource(BuscaComponente('Dts'+Quer.FieldByName('Quer').AsString)).DataSet.FieldByName(Quer.FieldByName('Camp').AsString)).SaveToFile(ArquValiEnde(Quer.FieldByName('Dest').AsString))
              end;
            except
              on E: Exception do
                 vMensagem := E.Message;
            end;
            if vMensagem <> '' then
            begin
              msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: Falha ao criar arquivo: '+ArquValiEnde(Quer.FieldByName('Dest').AsString)+sgLn+
                                         Linh+sgLn+
                                         sgLn+
                                         'Mensagem Interna:'+sgLn+
                                         vMensagem);
              Result := False;
              Exit;
            end;
            Quer.Next;
          end;
        end
        else if Camp = 'EXISARQU' then  //Verifica de Existe o Arquivo
        begin
          Linh := ArquValiEnde(CampPers_ExecLinhStri(Linh, Camp));
          if FileExists(Linh) then
            iForm.RetoFunc := '1'
          else
            iForm.RetoFunc := '0';
        end
        else if Camp = 'ARQUZIPA' then  //Zipa Arquivo
        begin
          Linh := ArquValiEnde(CampPers_ExecLinhStri(Linh, Camp));
          iForm.RetoFunc := ArquZipa(Linh);
          if iForm.RetoFunc = '' then
          begin
            Result := False;
            Exit;
          end;
        end
        else if Camp = 'ZIPAARQU' then  //Zipa Arquivo (loop no SQL)
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while not Quer.Eof do
          begin
            ExibMensHint('Compactando: '+ArquValiEnde(Quer.FieldByName('Origem').AsString));
            iForm.RetoFunc := ArquZipa(Quer.FieldByName('Origem').AsString, Quer.FieldByName('Destino').AsString);
            if iForm.RetoFunc = '' then
            begin
              Result := False;
              Exit;
            end;
            Quer.Next;
          end;
          ExibMensHint('');
        end
        else if Camp = 'DES_ZIPA' then  //Decompacta Arquivo (loop no SQL)
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while not Quer.Eof do
          begin
            ExibMensHint('Descompactando: '+ArquValiEnde(Quer.FieldByName('Origem').AsString));
            bAux1 := ArquDes_Zipa(Quer.FieldByName('Origem').AsString, Quer.FieldByName('Destino').AsString);
            iForm.RetoFunc := SeStri(bAux1, '1','0');
            if not bAux1 then
            begin
              Result := False;
              Exit;
            end;
            Quer.Next;
          end;
          ExibMensHint('');
        end
        else if Camp = 'EXTREXTE' then  //Extrai Extensão do Arquivo
        begin
          Linh := ArquValiEnde(CampPers_ExecLinhStri(Linh, Camp), False);
          iForm.RetoFunc := ExtractFileExt(Linh);
        end
        else if Camp = 'EXTRNOME' then  //Extrai Nome do Arquivo
        begin
          Linh := ArquValiEnde(CampPers_ExecLinhStri(Linh, Camp), False);
          iForm.RetoFunc := ExtractFileName(Linh);
        end
        else if Camp = 'EXTRPATH' then  //Extrai Path do Arquivo
        begin
          Linh := ArquValiEnde(CampPers_ExecLinhStri(Linh, Camp), False);
          iForm.RetoFunc := ExtractFilePath(Linh);
        end
        else if Camp = 'COPIREGI' then  //Copia o Registro, alterando os campos determinados
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while (not Quer.Eof) do
          begin
            SetLength(ArraStri,(Quer.FieldCount - 5) *2);  //Tira os 5 campos obrigatórios abaixo
            iAux2 := 0;
            for iAux1 := 0 To Quer.FieldCount - 1 do
            begin
              if AnsiUpperCase(Copy(Quer.fields[iAux1].FieldName,01,05)) <> 'COPI_' then
              begin
                ArraStri[iAux2] := Quer.Fields[iAux1].FieldName;
                Inc(iAux2);
                if Quer.Fields[iAux1].IsNull then
                  ArraStri[iAux2] := 'NULL'
                else if TipoDadoCara(Quer.Fields[iAux1]) in ['N','I'] then
                  ArraStri[iAux2] := FormNumeSQL(Quer.Fields[iAux1].AsFloat)
                else if TipoDadoCara(Quer.Fields[iAux1]) in ['D'] then
                  ArraStri[iAux2] := FormDataSQL(Quer.Fields[iAux1].AsDateTime)
                else
                  ArraStri[iAux2] := QuotedStr(Quer.Fields[iAux1].AsString);
                Inc(iAux2);
              end;
            end;

            CopiRegi(Quer.FieldByName('Copi_OrigTabe').AsString, Quer.FieldByName('Copi_DestTabe').AsString,
                     'WHERE ('+Quer.FieldByName('Copi_CampChav').AsString+' = '+Quer.FieldByName('Copi_ValoChav').AsString+')',
                     ArraStri, Quer.FieldByName('Copi_CampInic').AsInteger);
            Quer.Next;
          end;
        end
        else if Camp = 'CARRREGI' then  //Carrega o Registros de uma Query para Outra
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          if Quer.IsEmpty then
            raise Exception.Create(SSemDados)
          else
          begin
            sAux1 := Quer.FieldByName('QuerDest').AsString;
            if sAux1.Trim.ToUpper = 'DTSGRAV' then
              QuerAuxi := TsgQuery(TDataSource(iForm.BuscaComponente(sAux1)).DataSet)
            else if sAux1.Trim.ToUpper = 'QRYGRAV' then
              QuerAuxi := TsgQuery(iForm.BuscaComponente(sAux1))
            else
              QuerAuxi := TsgQuery(FindComponent(sAux1));
            if Assigned(QuerAuxi) then
              GravRegi(Quer, QuerAuxi, 1)
            else
              raise Exception.Create('Query Destino não encontrada: '+Quer.FieldByName('QuerDest').AsString);
          end
        end
        else if Camp = 'GECADEMO' then  //Gera Demonstrativo
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          //Implementar
        end
        else if Camp = 'CAMPCALC' then  //Calcula MPCACole
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          while not Quer.Eof do
          begin
            CampCalc(Quer.FieldByName('CodiLote').AsString, Quer.FieldByName('IdadInic').AsString,Quer.FieldByName('IdadFina').AsString,
                     Quer.FieldByName('NomeLote').AsString, 0, False, Quer.FieldByName('TipoCalc').AsString='R',Quer.FieldByName('TipoCalc').AsString='P',
                     Quer.FieldByName('TipoCalc').AsString='I',Quer.FieldByName('TipoCalc').AsString='E');
            Quer.Next;
          end;
        end
        else if Camp = 'GERARAST' then  //Rastreabilidade
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          CalcRastGera(Quer.FieldByName('TabeRast').AsString, Quer.FieldByName('SaidRast').AsString,
                       Quer.FieldByName('EntrRast').AsString, Quer.FieldByName('QtdeRast').AsString,
                       iForm.VariStri[1], iForm.VariStri[2], iForm.VariStri[3]);
        end
        else if Camp = 'ORIGRAST' then  //Buscar a Origem na Própria Tabela
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          CalcRast_BuscOrig(Quer.FieldByName('TabeOrig').AsString, Quer.FieldByName('CampPrin').AsString,
                            Quer.FieldByName('CampOrig').AsString, Quer.FieldByName('TabeRast').AsString,
                            Quer.FieldByName('CodiPrin').AsInteger,Quer.FieldByName('CodiOrig').AsInteger);
        end
        else if Camp = 'ARQUXML_' then  //Gera Arquivo XML
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          Result := GeraArquXML_SQL(Quer.FieldByName('EndeArqu').AsString, Quer.FieldByName('SQL').AsString, mxNormal);
          iForm.VariResu[1] := SeStri(Result, '1', '0');
        end
        else if Camp = 'ARQUXML0' then  //Gera Arquivo XML
        begin
          Result := GeraArquXML_SQL('', Linh, mxNormal);
          iForm.VariResu[1] := SeStri(Result, '1', '0');
        end
        else if Camp = 'ARQUXML1' then  //Gera Arquivo XML (Modelo XML)
        begin
          Result := GeraArquXML_SQL('', Linh, mxSimulador);
          iForm.VariResu[1] := SeStri(Result, '1', '0');
        end
        else if Camp = 'IMPOXML_' then  //Importa Arquivo XML
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.VariResu[1] := ImpoArquXML_(Quer.FieldByName('EndeArqu').AsString, Quer.FieldByName('SQL').AsString);
        end
        else if Camp = 'ABREXMLN' then  //Importa Arquivo XML
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          AbreWebBrowser(Quer.FieldByName('Arquivo').AsString);
          iForm.RetoFunc := '1';
        end
        else if Camp = 'OPERARQU' then  //Operação com Arquivo
        begin
          {$ifdef ERPUNI}
            iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, 'EX-'+Camp+'-'+Linh).Msg;
          {$else}
            Quer.Close;
            Quer.SQL.Clear;
            Quer.SQL.Add(Linh);
            Quer.Open;
            //Operação: print, open
            //Tipo: SW_HIDE = 0; SW_SHOWNORMAL = 1;SW_NORMAL = 1;SW_SHOWMINIMIZED = 2;SW_SHOWMAXIMIZED = 3;SW_MAXIMIZE = 3;SW_SHOWNOACTIVATE = 4;SW_SHOW = 5;SW_MINIMIZE = 6;SW_SHOWMINNOACTIVE = 7;SW_SHOWNA = 8;SW_RESTORE = 9;SW_SHOWDEFAULT = 10;SW_MAX = 10;
            if VeriExisCampTabe(Quer,'Parametro') and (Trim(Quer.FieldByName('Parametro').AsString) <> '') then
            begin
              sAux1 := Quer.FieldByName('Parametro').AsString;
              ExibMensHint(Quer.FieldByName('Operacao').AsString+
                           ' '+Quer.FieldByName('Endereco').AsString+
                           ' '+sAux1+
                           ' '+IntToStr(Quer.FieldByName('Tipo').AsInteger));
              ShellExecute(Handle, PChar(Quer.FieldByName('Operacao').AsString),
                                   PChar(ArquValiEnde(Quer.FieldByName('Endereco').AsString)),
                                   PChar(sAux1), nil,
                                   Quer.FieldByName('Tipo').AsInteger);
            end
            else
            begin
              ExibMensHint(Quer.FieldByName('Operacao').AsString+
                           ' '+Quer.FieldByName('Endereco').AsString+
                           //' '+sAux1+
                           ' '+IntToStr(Quer.FieldByName('Tipo').AsInteger));
              ShellExecute(Handle, PChar(Quer.FieldByName('Operacao').AsString),
                                   PChar(ArquValiEnde(Quer.FieldByName('Endereco').AsString)),
                                   nil, nil,
                                   Quer.FieldByName('Tipo').AsInteger);
            end;
          {$endif}
        end
        else if StrIn(Camp, ['UNE_PDF_', 'UNE_PDF', 'UNE_PDF1']) then  //Une PDF
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          lAux1.Clear;
          while not Quer.Eof do
          begin
            sAux1 := ArquValiEnde(Quer.FieldByName('ArquivoPDF').AsString);
            if FileExists(sAux1) then
              lAux1.Add(sAux1);
            Quer.Next;
          end;
          if lAux1.Count = 0 then
          begin
            msgOk(Camp+': Arquivos não encontrados ou não informados!');
            Result := False;
            Exit;
          end;
          if (Camp <> 'UNE_PDF1') then
          begin
            sAux1 := Copy(Quer.FieldByName('Parametro').AsString,Pos('@',Quer.FieldByName('Parametro').AsString)+1,100);
            sAux1 := Copy(sAux1, 01, Pos('.TXT',AnsiUpperCase(sAux1))+4);
            lAux1.SaveToFile(ArquValiEnde(sAux1));
            //Operação: print, open
            //Tipo: SW_HIDE = 0; SW_SHOWNORMAL = 1;SW_NORMAL = 1;SW_SHOWMINIMIZED = 2;SW_SHOWMAXIMIZED = 3;SW_MAXIMIZE = 3;SW_SHOWNOACTIVATE = 4;SW_SHOW = 5;SW_MINIMIZE = 6;SW_SHOWMINNOACTIVE = 7;SW_SHOWNA = 8;SW_RESTORE = 9;SW_SHOWDEFAULT = 10;SW_MAX = 10;
            //ExecComaDOS_Agua()
            {$ifdef ERPUNI}
              iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, 'EX-OPERARQU-SELECT '+QuotedStr(Quer.FieldByName('Operacao').AsString) +' AS Operacao'
                                                                                 +QuotedStr(Quer.FieldByName('Endereco').AsString) +' AS Endereco'
                                                                                 +QuotedStr(Quer.FieldByName('Parametro').AsString)+' AS Parametro'
                                                                                 +QuotedStr(Quer.FieldByName('Tipo').AsString)     +' AS Tipo'
                                                                                 +' FROM POCAAUXI'
                                                                                ).Msg;
            {$else}
              ShellExecute(Handle, PChar(Quer.FieldByName('Operacao').AsString),
                                   PChar(ArquValiEnde(Quer.FieldByName('Endereco').AsString)),
                                   PChar(Quer.FieldByName('Parametro').AsString), nil,
                                   Quer.FieldByName('Tipo').AsInteger);
            {$endif}
          end
          else //Une PDF1, só gera o txt
            lAux1.SaveToFile(ArquValiEnde(Quer.FieldByName('EndeLista').AsString));
        end
        else if Camp = 'VALICPF_' then  //Valida CPF
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.RetoFunc := SeStri(Val_CPF(Quer.FieldByName('CPF').AsString),'1','0');
        end
        else if Camp = 'VALICNPJ' then  //Valida CNPJ
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.RetoFunc := SeStri(Val_CNPJ(Quer.FieldByName('CNPJ').AsString),'1','0');
        end
        else if Camp = 'VALIIE__' then  //Valida IE
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.RetoFunc := SeStri(ValiIE(Quer.FieldByName('IE').AsString,Quer.FieldByName('UF').AsString),'1','0');
        end
        else if Camp = 'VALIUF__' then  //Valida UF
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.RetoFunc := SeStri(Val_UF(Quer.FieldByName('UF').AsString),'1','0');
        end
        else if Camp = 'SUBSPATU' then  //Substitui todas as palavras
        begin
          iForm.RetoFunc := SubsPalaTudo(Linh, iForm.VariStri[01], iForm.VariStri[02]);
        end
        else if Camp = 'SUBSPALA' then  //Substitui as palavras (case sensitive)
        begin
          iForm.RetoFunc := SubsPala(Linh, iForm.VariStri[01], iForm.VariStri[02]);
        end
        else if Camp = 'SUBSPAUM' then  //Substitui uma palavra
        begin
          iForm.RetoFunc := SubsPalaUma(Linh, iForm.VariStri[01], iForm.VariStri[02]);
        end
        else if Camp = 'BANCVIEW' then  //(Re)Criar a View nos Bancos
          iForm.RetoFunc := SeStri(BancViewPrin(CampPers_ExecLinhStri(Linh, Camp)),'1','0')
        else if Camp = 'BANCFUNC' then  //(Re)Criar a Function nos Bancos
          iForm.RetoFunc := SeStri(BancFuncPrin(CampPers_ExecLinhStri(Linh, Camp)),'1','0')
        else if Camp = 'BANCPROC' then  //(Re)Criar Procedures nos Bancos
          iForm.RetoFunc := SeStri(BancViewPrin(CampPers_ExecLinhStri(Linh, Camp)),'1','0')
        {$IFDEF FD}
          else if Camp = 'MUDADTB_' then  //Muda de DataBase
          begin
          end
        {$ELSE}
          else if Camp = 'MUDADTB_' then  //Muda de DataBase
          begin
            sAux1 := AnsiUpperCase(CampPers_ExecLinhStri(Linh, Camp));
            if sAux1 = 'DTBCADA' then
              SetPADOConn(TsgADOConnection(BuscaComponente('DtbCada')))
            {$ifdef SAGSINC}
              else if sAux1 = 'DTBREMO' then
                SetPADOConn(DtmRemo.DtbRemo)
            {$endif}
            else
              SetPADOConn(DtmPoul.DtbGene);
          end
        {$ENDIF}
        else if Camp = 'TRANSACT' then
        begin
          case AnsiIndexStr(AnsiUpperCase(CampPers_ExecLinhStri(Linh, Camp)),['BEGIN','COMMIT','ROLLBACK']) of
            0: GetPsgTrans.sgBeginTrans(False);
            1: GetPsgTrans.sgCommitTrans;
            2: GetPsgTrans.sgRollbackTrans;
          end;
        end
        else if Camp = 'CALCFRET' then  //Calcula Frete
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          rAux1 := Quer.FieldByName('Dist').AsFloat;
          if (rAux1 = 0) and (AnsiUpperCase(Quer.FieldByName('Tabe').AsString) = 'POCAESTO') then
          begin
            rAux1 := Fret_DistTota_Esto(Quer.FieldByName('Codi').AsInteger, -1);
          end;

          rAux1:= CalcFret(Quer.FieldByName('CodiTran').AsInteger,
                           Quer.FieldByName('CodiFret').AsInteger,
                           Quer.FieldByName('CodiCida').AsInteger,
                           rAux1,
                           Quer.FieldByName('QtTo').AsFloat, True,
                           Quer.FieldByName('Codi').AsInteger,
                           Quer.FieldByName('Tabe').AsString);

          if (AnsiUpperCase(Quer.FieldByName('Tabe').AsString) = 'POCAESTO') then
            Fret_RateMvEs(Quer.FieldByName('Codi').AsInteger, 'Fret', rAux1);
          iForm.VariReal[10] := rAux1;
        end
        else if Camp = 'RECACUST' then  //Recalcula os Custos dos Produtos
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          bAux1 := False;
          dAux1 := 0;
          dAux2 := 0;
          if VeriExisCampTabe(Quer, 'CustEntr') then
          begin
            bAux1 := Quer.FieldByName('CustEntr').AsInteger = 1;
            if VeriExisCampTabe(Quer, 'CustEntrDtIn') then
              dAux1 := Quer.FieldByName('CustEntrDtIn').AsDateTime;
            if VeriExisCampTabe(Quer, 'CustEntrDtFi') then
              dAux2 := Quer.FieldByName('CustEntrDtFi').AsDateTime;
          end;

          rAux1 := RaPlus.RecaCustEsto(Quer.FieldByName('DataInic').AsDateTime, Quer.FieldByName('DataFina').AsDateTime, Quer.FieldByName('Loca').AsString
                                      , AnsiUpperCase(VeriExisCampTabe_Valo(Quer, 'Tipo', 'DIAR'))
                                      , VeriExisCampTabe_Valo(Quer, 'Wher', '')
                                      , '', 0
                                      , StrToInt(RetoZero(VeriExisCampTabe_Valo(Quer, 'CodiGrEm', '0')))
                                      , StrToInt(RetoZero(VeriExisCampTabe_Valo(Quer, 'ExibMens', '1')))
                                      , bAux1
                                      , dAux1
                                      , dAux2
                                      , StrToInt(RetoZero(VeriExisCampTabe_Valo(Quer, 'CodiSeto', '0')))
                                     );

          if rAux1 = 9999 then
            Result := False;

          if Assigned(iForm) then
            iForm.VariReal[10] := rAux1;
        end
        else if Camp = 'MPRECOLE' then  //Gera a MPReCole e a MPReCola
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.VariReal[10] := MPPlus.GeraMPReCole(Quer.FieldByName('DataInic').AsDateTime, Quer.FieldByName('DataFina').AsDateTime, Quer.FieldByName('Loca').AsString);
        end
        else if Camp = 'GECAMVCX' then  //Gera a GECaMvCx
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.RetoFunc := SeStri(FiPlus.GeraGECaMvCx(TsgForm( (iForm) ), Quer.FieldByName('DataInic').AsDateTime, Quer.FieldByName('DataFina').AsDateTime, nil).Result, '1', '0');
        end
        else if Camp = 'RETOVERS' then  //Retorna a Versão
        begin
          iForm.RetoFunc := RetoVers();
        end
        else if Camp = 'CALCCODI' then  //Calcula o Código
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.RetoFunc := IntToStr(CalcCodi(Quer.FieldByName('Camp').AsString, Quer.FieldByName('Tabe').AsString));
        end
        else if Camp = 'TECLENTE' then  //Simula a tecla Enter
        begin
          Application_ProcessMessages;
          keybd_event(VK_RETURN, 0, 0, 0);
        end
        else if Camp = 'PROXCAMP' then  //Vai para o Próximo Campo
        begin
          Perform(Wm_NextDlgCtl,0,0);
        end
        {$IfDef TESTMODE}
          else if Camp = 'EXECTEST' then  //Executa teste
          begin
            TePlus.Executa(iForm, Linh);
          end
        {$endif}
        else if Camp = 'SC__PESO' then  //Relatório de Pesos (NÃO Agrupa os pesos do mesmo valor, qtde sempre = 1)
        begin
          SCPlus.GeraRelaPeso(Linh, False);
        end
        else if Camp = 'SCAGPESO' then  //Relatório de Pesos (Agrupa os pesos do mesmo valor, somando na Qtde)
        begin
          SCPlus.GeraRelaPeso(Linh, True);
        end
        else if Camp = 'VERIACES' then  //Acessos de uma Tabela
        begin
          iForm.RetoFunc := VeriAcesTabeTota(StrToInt(RetoZero(RetiMascTota(Linh))));
          //1-Inclusão, 2-Alteração, 3-Consulta, 4-Exclusão, 5-Consulta, 6-Relatório
        end
        else if Camp = 'EXECPLSG' then  //Executa PL-SAG
        begin
          Result := CampPersExecDireStri(iForm, CampPers_ExecLinhStri(Linh, Camp), '');
        end
        {$ifndef LIBUNI}
          else if Camp = 'POCHGRID' then
          begin
            Application.CreateForm(TFrmPOChGrid,FrmPOChGrid);
            with FrmPOChGrid do
            begin
              FraGrid.DbgGrid.Coluna.Add('[Colunas]');
              FraGrid.DbgGrid.Coluna.Add('AutoAjuste=/Visi=N');
              FraGrid.DbgGrid.Coluna.Add('Alterar=/Edit=S');
              FraGrid.DbgGrid.Coluna.Add('Coluna=/Tama=100');
              QrySQL.Close;
              QrySQL.SQL.Clear;
              QrySQL.SQL.Add(Linh);
              QrySQL.Open;
              if VeriExisCampTabe(QrySQL, 'AutoAjuste') then
                FraGrid.DbgGrid.AutoAjuste := QrySQL.FieldByName('AutoAjuste').AsInteger = 1;
              ShowModal;
            end;
            FreeAndNil(FrmPOChGrid);
          end
        {$ENDIF}
        else if Camp = 'CUSTPROD' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          iForm.VariResu[1] := FormNumeSQL(Fun_CustProd_Calc(Quer.FieldByName('CODIPROD').AsInteger,Quer.FieldByName('DATA').AsDateTime, Quer.FieldByName('CODISETO').AsInteger));
        end
        else if Camp = 'LISTAGRU' then
        begin
          Quer.SQL.Add(Linh);
          Quer.Open;
          sAux5 := '';
          while not Quer.Eof do
          begin
            sAux5 := sAux5 + Quer.FieldByName('LISTA').AsString;
            Quer.Next;
            if not Quer.Eof then
              sAux5 := sAux5 +', ';
          end;
          iForm.VariResu[1] := QuotedStr(sAux5)
        end
        else if Camp = 'VALIHORA' then
          iForm.VariResu[1] := SeStri(isTime(SubsPalaTudo(Trim(Linh),'''','')),'1','0')
        else if Camp = 'VALIDATA' then
          iForm.VariResu[1] := SeStri(isDateTime(SubsPalaTudo(Trim(Linh),'''','')),'1','0')
        else if Camp = 'BASEAUXI' then
        begin
          DtmPoul.cdsBaseAuxi.Close;
          DtmPoul.cdsBaseAuxi.CommandText := Linh;
          DtmPoul.cdsBaseAuxi.Execute;
        end
        else if Camp = 'BASEAUXI' then
        begin
          DtmPoul.cdsBaseAuxi.Close;
          DtmPoul.cdsBaseAuxi.CommandText := Linh;
          DtmPoul.cdsBaseAuxi.Execute;
        end
        else if Camp = 'PROGRACA' then
        begin
          Quer.SQL.Text := Linh;
          Quer.Open;
          sAux5 := '';
          while not Quer.Eof do
          begin
            RACaProg_CalcProg(Quer.FieldByName('CodiLote').AsInteger,
                              Quer.FieldByName('NomeLote').AsString, Quer.FieldByName('SexoLote').AsString,
                              Quer.FieldByName('DataInic').AsDateTime, Quer.FieldByName('DataFina').AsDateTime, Quer.FieldByName('ColeLote').AsDateTime,
                              Quer.FieldByName('CodiTabe').AsString,
                              Quer.FieldByName('MantProgManu').AsInteger <> 0, //Mantem Programação Manual
                              Quer.FieldByName('LoteFran').AsInteger     <> 0, //Lote de Frango de Corte (0 = Matrizes)
                              Quer.FieldByName('MortProg').AsInteger     <> 0, //Considera Mortalidade
                              Quer.FieldByName('ContMens').AsInteger     <> 0, //Continua mesmo com mensagem (erro ou alerta)
                              Quer.FieldByName('FaseSobr').AsInteger     <> 0, //Considera Fase da Sobra a Fase Atual
                              Quer.FieldByName('CorrLote').AsInteger     <> 0, //Utiliza % Correção Automático
                              Quer.FieldByName('ConsProg').AsInteger     <> 0, //Calcular Previsão de Consumo Diário
                              Quer.FieldByName('SobrProg').AsInteger     <> 0, //Programar Sobra de Ração para Fase Seguinte
                              Quer.FieldByName('AvesLote').AsInteger,
                              Quer.FieldByName('FinaLote').AsFloat,
                              Quer.FieldByName('MargProg').AsFloat,  //Margem Segurança
                              Quer.FieldByName('Feri').AsInteger <> 0, //Feriado
                              Quer.FieldByName('Domi').AsInteger <> 0,
                              Quer.FieldByName('Segu').AsInteger <> 0,
                              Quer.FieldByName('Terc').AsInteger <> 0,
                              Quer.FieldByName('Quar').AsInteger <> 0,
                              Quer.FieldByName('Quin').AsInteger <> 0,
                              Quer.FieldByName('Sext').AsInteger <> 0,
                              Quer.FieldByName('Saba').AsInteger <> 0,
                              Quer.FieldByName('CapaTranOrde').AsInteger <> 0, //Utiliza Capacidade do Transporte para Gerar as Ordens
                              Quer.FieldByName('CapaSilo').AsInteger <> 0, //Utiliza Capacidade do Transporte para Gerar as Ordens
                              Quer.FieldByName('SaldAnte').AsInteger <> 0, //Utiliza Saldo do Dia Anterior
                              Quer.FieldByName('CapaProg').AsFloat,  //Cap. Transporte (Kg)
                              Quer.FieldByName('MaxiCons').AsInteger,  //Dias Máximo de Consumo
                              Quer.FieldByName('VidaLote').AsInteger <> 0, //Programa para a Vida do Lote
                              Quer.FieldByName('Ate_FinaLote').AsInteger <> 0, //Até Final do Lote
                              Quer.FieldByName('EnviProg').AsInteger <> 0, //Calcular Previsão de Envios de Ração
                              Quer.FieldByName('ValoCorrLote').AsFloat,  //Valor da Correção do Lote (campo da mpcalote.corrlote)
                              sAux5,                                     //ListVerificaProgramacao (retorno)
                              TTipoAcaoMvOc(Quer.FieldByName('AcaoOrdeCarr').AsInteger),  //0-Exibem Mensagem, 1-Continua, 2-Ignora e 3-Cancela
                              StrToInt(VeriExisCampTabe_Valo(Quer, 'ConsHoraAloj', '0')) <> 0);  //Considera Hora do Alojamento
            Quer.Next;
          end;
          iForm.RetoFunc := sAux5;
          Quer.Close;
        end
        else if Camp = 'PROGENTR' then
        begin
          Quer.SQL.Text := Linh;
          Quer.Open;
          sAux5 := '';
          while not Quer.Eof do
          begin
            RACaProg_AtuaEntr(Quer.FieldByName('CodiLote').AsInteger,
                              Quer.FieldByName('ExibMens').AsInteger <> 0, //Exibe Mensagem
                              Quer.FieldByName('ContMens').AsInteger <> 0, //Continua mesmo com mensagem (erro ou alerta)
                              Quer.FieldByName('LoteFran').AsInteger <> 0, //Lote de Frango de Corte (0 = Matrizes)
                              Quer.FieldByName('FaseSobr').AsInteger <> 0, //Considera Fase da Sobra a Fase Atual
                              TTipoAcaoMvOc(Quer.FieldByName('AcaoOrdeCarr').AsInteger));  //0-Exibem Mensagem, 1-Continua, 2-Ignora e 3-Cancela
            Quer.Next;
          end;
          Quer.Close;
        end
        else if Camp = 'PROGORDE' then
        begin
          Quer.SQL.Text := Linh;
          Quer.Open;
          while not Quer.Eof do
          begin
            RACaProg_GeraOrde(Quer.FieldByName('iWher').AsString,
                              Quer.FieldByName('CapaTranOrde').AsInteger <> 0, //CapaTranOrde, usa a capacidade do transporte para gerar as ordens (quebra as entregas)
                              Quer.FieldByName('CapaTran').AsFloat);           //Capacidade do Transporte
            Quer.Next;
          end;
          Quer.Close;
        end
        else if Camp = 'GERACHAV' then
        begin
          iForm.RetoFunc := Func.GeraChavGrav();
        end
        else if Camp = 'MANUDADO' then
        begin
          iForm.RetoFunc := SeStri(Ex_ManuDado(iForm, Linh),'1','0');
        end
        else if Camp = 'MOTIBLOQ' then
        begin
          // Busca o texto e retorna com as quebras de linha
          if Linh <> '' then
          begin
            Quer.SQL.Text := Linh;
            Quer.Open;
            sAux1 := '';
            sAux2 := '';
            sAux3 := '';
            while not Quer.Eof do
            begin
              if (Trim(Quer.Fields[0].AsString) <> '') and (Trim(Quer.Fields[0].AsString) <> sAux3) then
              begin
                sAux1 := Trim(Quer.Fields[0].AsString);
                sAux1 := StringReplace(sAux1,#$A, '', [rfReplaceAll]);
                sAux1 := StringReplace(sAux1,#$D, sgLn, [rfReplaceAll]);
                sAux2 := sAux2 +Trim(sAux1) +sgLn;
                sAux3 := Trim(Quer.Fields[0].AsString);
              end;
              Quer.Next;
            end;
            Quer.Close;
            iForm.RetoFunc := sAux2;
          end
          else
            iForm.RetoFunc := '';
        end
        else if Camp = 'DISTMVCX' then  //Distribuição do MvCx
        begin
          QuerAuxi := TsgQuery.Create(iForm);
          QuerMvCx := TsgQuery.Create(iForm);
          try
            QuerAuxi.sgConnection := iForm.sgTransaction;
            QuerMvCx.sgConnection := iForm.sgTransaction;
            QuerMvCx.SQL.Add(Linh);
            QuerMvCx.Open;
            while not QuerMvCx.Eof do
            begin
              sAux1 := VeriExisCampTabe_Valo(QuerMvCx, 'Tabe', 'POCAMVES');
              if sAux1 = 'POCAMVES' then
              begin
                //EX-DISTMVCX-SELECT 'POCAMVES' AS Tabe, {VA-CODITABE} AS CodiTabe, POCaMvEs.CodiMvEs AS CodiMvEs, POCaEsto.CodiPess, POCaEsto.CodiTpMv, POCaEsto.CodiSeto, POCaESto.CodiTran, POCAProd.CodiPlan, 0 AS CodiCent, EmisEsto AS Emis, ReceEsto AS Rece, 0 AS PermCanc from pocamves inner join pogeesto pocaesto on pocamves.codiesto = pocaesto.codiesto inner join pogeprod pocaprod on pocamves.codiprod = pocaprod.codiprod WHERE CODIMVES = 5206
                Result := POCaMvEs_DistMvCx(iForm, QuerMvCx, QuerAuxi);
              end
              else if sAux1 = 'POCAFINA' then
              begin
                //EX-DISTMVCX-SELECT 'POCAFINA' AS Tabe, {VA-CODITABE} AS CodiTabe, POCAFINA.CODIFINA AS CodiFINA, POCaFINA.CodiPess, POCaFINA.CodiTpMv, 0 AS CodiSeto, 0 AS CodiTran, 0 AS CodiPlan, 0 AS CodiCent, DATAFINA AS Emis, DATAFINA AS Rece, 0 AS PermCanc from pocafina WHERE CODIfina = 5206
                Result := POCaFina_DistMvCx(iForm, QuerMvCx, QuerAuxi);
              end
              else if sAux1 = 'POCACAIX' then
              begin
                //EX-DISTMVCX-SELECT 'POCAFINA' AS Tabe, {VA-CODITABE} AS CodiTabe, POCAFINA.CODIFINA AS CodiFINA, POCaFINA.CodiPess, POCaFINA.CodiTpMv, 0 AS CodiSeto, 0 AS CodiTran, 0 AS CodiPlan, 0 AS CodiCent, DATAFINA AS Emis, DATAFINA AS Rece, 0 AS PermCanc from pocafina WHERE CODIfina = 5206
                Result := POCaCaix_DistMvCx(iForm, QuerMvCx, QuerAuxi);
              end
              else if sAux1 = 'POCAUNFI' then
              begin
                //EX-DISTMVCX-SELECT 'POCAUNFI' AS Tabe, {VA-CODITABE} AS CodiTabe, {DG-CODIFINA} AS CODIFINA FROM DUAL
                Result := POCaUnFi_DistMvCx(iForm, QuerMvCx, QuerAuxi);
              end;
              QuerMvCx.Next;
            end;
            QuerMvCx.Close;
            TsgForm(iForm).RetoFunc := SeStri(Result,'1','0');
          finally
            QuerAuxi.sgClose;
            QuerAuxi.Free;
            QuerMvCx.sgClose;
            QuerMvCx.Free;
          end;
        end
        else if StrIn(Camp, ['PAG_FOR_','PAGFOR__']) then  //Gera arquivo do PAG-FOR
        begin
          //Inte0001 = Codigo da Consulta
          //Linh = Where para a Consulta
          TsgForm(iForm).RetoFunc := IntToStr(GeraPag_For_(iForm.VariInte[1], Linh));
        end
        else if StrIn(Camp, ['REMEBLOQ','REMEBOLE']) then  //Gera Arquivo Remessa Boleto
        begin
          {$ifdef ERPUNI}
            iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, 'EX-'+Camp+'-'+Linh).Msg;
          {$else}
            //Stri0001 = Nome da Query
            //Linh = Endereço do Arquivo
            Quer := TsgQuery(BuscaComponente('Qry'+iForm.VariStri[1]));
            TsgForm(iForm).RetoFunc := SeStri(GeraReme(Quer, CampPers_ExecLinhStri(Linh, Camp))='','0','1');  //Resultado é a mensagem do arquivo gerado
          {$endif}
        end
        else if StrIn(Camp, ['REMEBLO1','REMEBOL1']) then  //Gera Arquivo Remessa Boleto
        begin
          {$ifdef ERPUNI}
            iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, 'EX-'+Camp+'-'+Linh).Msg;
          {$else}
            //Inte0001 = Codigo da Consulta
            //Stri0001 = Where
            //Linh = Endereço do Arquivo
            Quer.SQL.Text := CalcStri('SELECT SQL_CONS FROM POCaCons WHERE CodiCons = '+IntToStr(iForm.VariInte[1]));
            Quer.SQL.Strings[4] := iForm.VariStri[1];
            TsgForm(iForm).RetoFunc := SeStri(GeraReme(Quer, CampPers_ExecLinhStri(Linh, Camp))='','0','1');  //Resultado é a mensagem do arquivo gerado
          {$endif}
        end
        else if StrIn(Camp,['VDCHMAPA','PROGFINA','PROGINIC','CHAMBI__','POCHORGA','ATUARELA','ADT_XML_',
                            'FTP_ENVI','IMPOSPED','SENHLIBE','PCCHENVI']) then
        begin
          {$ifdef ERPUNI}
            iForm.RetoFunc := PlusUni.WS_ExecPLSAG(iForm, 'EX-'+Camp+'-'+Linh).Msg;
          {$else}
            Result := ERP_CampPers_EX( TsgForm(iForm), Camp, Linh);
          {$endif}
        end
        else if Camp = 'DTBCADA' then  //Executa no DTBCada
          ExecSQL_(Linh, TsgADOConnection(BuscaComponente('DtbCada')))
        else if Camp = 'DTBGENE' then  //Executa no DtbGene
          ExecSQL_(Linh, DtmPoul.DtbGene)
        else if Camp = 'IDADLOTE' then  //Calcula a Idade do Lote
        begin
          Quer.SQL.Text := Linh;
          Quer.Open;
          iAux1 := 0;
          if VeriExisCampTabe(Quer, 'PSisLote') then
          begin
            if StrIn(Quer.FieldByName('PSisLote').AsString, ['S01','S02','S20']) then
              iAux1 := 7
            else
              iAux1 := 1;
          end;
          TsgForm(iForm).VariReal[01] := IdadLote(Quer.FieldByName('ColeLote').AsDateTime
                                                        , Quer.FieldByName('DataAtua').AsDateTime
                                                        , iAux1);
          TsgForm(iForm).RetoFunc := FormNumeSQL(TsgForm(iForm).VariReal[01]);
          Quer.Close;
        end
        else if Camp = 'EXECRETO' then
        begin
          if sgCopy(Linh,01,07) = 'UPDATE ' then
          begin
            if Assigned(iForm) then
              iForm.VariReal[1] := ExecSQL_Update_Returning(Linh, iForm.VariStri[1], iForm.sgTransaction)
            else
              iForm.VariReal[1] := ExecSQL_Update_Returning(Linh, iForm.VariStri[1]);
          end
          else
          begin
            if Assigned(iForm) then
              iForm.VariReal[1] := ExecSQL_Insert_Returning(Linh, iForm.VariStri[1], iForm.sgTransaction)
            else
              iForm.VariReal[1] := ExecSQL_Insert_Returning(Linh, iForm.VariStri[1]);
          end;
        end
        else if Camp = 'FSXXIMNF' then
        begin
          Result := FSXXImNF_BuscarNotas(Linh);
        end
        else if StrIn(Camp, ['VISUPDF_','VISUPDF']) then
        begin
          Quer.SQL.Text := Linh;
          Quer.Open;
          while not Quer.Eof do
          begin
            if VeriExisCampTabe(Quer, 'Tempo') then
              Result := RelaPlus.VisuPDF(Quer.Fields[0].AsString, Quer.FieldByName('Tempo').AsInteger).Result
            else
              Result := RelaPlus.VisuPDF(Quer.Fields[0].AsString).Result;
            if not Result then
            begin
              Result := False;
              Exit;
            end;
            Quer.Next;
          end;
        end
        else
        begin
          if Assigned(iForm) then
            ExecSQL_(Linh, iForm.sgTransaction)
          else
            ExecSQL_(Linh);
        end;
      finally
        Quer.Close;
        FreeAndNil(Quer);
        FreeAndNil(QryAbre);
        lAux1.Free;
      end;
    end;
  except
    on E: Exception do
       vMensagem := E.Message;
  end;

  if msgRaiseTratada(vMensagem, '[MENSSAG_EXIB]: '+vMensagem+sgLn+
                                 'Falha na Instrução EX-'+Camp+'-'+Linh+sgLn+
                                 'Mensagem Interna:'+sgLn+
                                 vMensagem) then
    Result := False;
end;

//Executar os 'OB' Triggers
Function CampPers_OB(iForm: TsgForm; Camp, Linh: String; iAcao: String = ''): Boolean;
var
  sgClas: TPersistentClass;
  Prin_D : TSgDecorator;
begin
  Result := False;
  try
    sgClas := sgClass.GetsgClass(Camp+'_D');
    if Assigned(sgClas) then
      Prin_D := TsgDecoratorClass(sgClas).Create
    else
      Prin_D := nil;

    if Assigned(Prin_D) then
    begin
      Prin_D.UsaTrans := True;
      Prin_D.Pro_AtualizaInfo_Wher(Linh);
      Prin_D.Free;
      Result := True;
    end;
  finally
  end;
end;

//Executar os commando do Decorator
Function CampPers_OD(iForm: TsgForm; iLinh: String): String;
type
   TExec = procedure of object;
var
  vLinh, vObje, vObj2, vTabe, vProp, vValo: String;
  Prin_D : TSgDecorator;
  ClasObj: TsgClasObj;
  prinObj, tempObj : TObject;
  sgClas: TPersistentClass;
  GetValo: Boolean;

  procedure CampPers_OD_ExecMethod(OnObject: TObject; MethodName: string);
  var
    Routine: TMethod;
    Exec: TExec;
  begin
    MethodName := MethodName.Replace('(','').Replace(')','');
    Routine.Data := Pointer(OnObject);
    Routine.Code := OnObject.MethodAddress(MethodName);
    if Assigned(Routine.Code) then
    begin
      Exec := TExec(Routine);
      Exec;
    end
    else
      raise Exception.Create('[MENSSAG_EXIB]: Problema no Método: '+MethodName+sgLn+
                             'Linha: '+iLinh);
  end;

var
  vMensagem: String;
begin
  vMensagem := '';
  try
    Result := '#ERRO#';
    GetValo := False;
    if sgCopy(iLinh,01,01) = '{' then
    begin
      GetValo := True;
      iLinh := SubsPala(SubsPala(iLinh,'{',''),'}','');
    end;

    if GetValo and (Pos(':=',vLinh) > 0) then
      raise Exception.Create('Erro de Sintaxe (busca valor com operador :=)');

    Result := '';
    Prin_D := nil;
    ClasObj := nil;
    vLinh := iLinh.Substring(03);
    vObje := Copy(vLinh, 01, Pos('.',vLinh)-1).Trim.ToUpper;
    if vObje = 'PRIN_D' then
    begin
      if not Assigned(iForm) then
      begin
        //Prin_D.POGeRequ.onBeforeSave;
        //vLinh = POGeRequ.onBeforeSave;
        vLinh := Copy(vLinh, Pos('.', vLinh)+1, MaxInt).Trim;
        //vTabe = POGeRequ
        vTabe := Copy(vLinh, 01, Pos('.',vLinh)-1);
        sgClas := sgClass.GetsgClass(vTabe+'_D');
        if Assigned(sgClas) then
          Prin_D := TsgDecoratorClass(sgClas).Create;
      end
      else if Assigned(iForm.Prin_D) then
        Prin_D := iForm.Prin_D;

      vLinh := Copy(vLinh, Pos('.', vLinh)+1, MaxInt).Trim;

      prinObj := Prin_D;
    end
    else if vObje = 'CLASOBJ' then  //Classe dos Objetos Tabela
    begin
      //ClasObj.POGeRequ.CriaCampBD;
      //vLinh = POGeRequ.CriaCampBD;
      vLinh := Copy(vLinh, Pos('.', vLinh)+1, MaxInt).Trim;
      //vTabe = POGeRequ
      vTabe := Copy(vLinh, 01, Pos('.',vLinh)-1);
      //vLinh = CriaCampBD;
      vLinh := Copy(vLinh, Pos('.', vLinh)+1, MaxInt).Trim;

      if Assigned(iForm) and Assigned(iForm.Prin_D) then
      begin
        if iForm.Prin_D.NewObj.GravTabe.ToUpper.Equals(vTabe.ToUpper) then
          ClasObj := iForm.Prin_D.NewObj;
      end;

      if not Assigned(ClasObj) then
      begin
        sgClas := sgClass.GetsgClass(vTabe);
        if Assigned(sgClas) then
          ClasObj := TsgClasObjClass(sgClas).Create;
      end;

      prinObj := ClasObj;
    end
    else
      raise Exception.Create('Objeto não tratado!');


    if GetValo and (Pos(':=',vLinh) > 0) then
      raise Exception.Create('Erro de Sintaxe (busca valor com operador :=)');

    vLinh := SubsPala(vLinh,';','');
    if Pos(':=',vLinh) > 0 then
      vProp := Copy(vLinh, 01, Pos(':=',vLinh)-1).Trim
    else
      vProp := vLinh.Trim;
    tempObj := prinObj;
    while Assigned(tempObj) and (Pos('.', vProp) > 0) do
    begin
      vObj2 := Copy(vProp, 01, Pos('.',vProp)-1).Trim;
      //ST (24/08/2023): Quando o Prin_D.XXX e o Prin_D é o XXX (caso do Leitor, que tem várias classes)
      if AnsiUpperCase(tempObj.ClassName) <> 'T'+vObj2.ToUpper then
        tempObj := sgRTTI.getPropObj(tempObj, vObj2, True);

      if Pos('.',vProp) > 0 then
        vProp := Copy(vProp, Pos('.',vProp)+1, MaxInt).Trim;
    end;

    if not Assigned(tempObj) then
      tempObj := prinObj;

    if GetValo then
    begin
      Result :=  sgRTTI.getProp(tempObj, vProp, True, True);
      if Result = sgNull then
        Result := '';
    end
    else if Pos(':=',vLinh) > 0 then
    begin
      //vProp := Copy(vProp, 01, Pos(':=',vProp)-1).Trim;
      vValo := Copy(vLinh, Pos(':=',vLinh)+2, MaxInt).Trim.DeQuotedString;
      sgRTTI.setProp(tempObj, vProp, vValo, True);
    end
    else
      CampPers_OD_ExecMethod(tempObj, vProp);
  except
    on E: Exception do
       vMensagem := E.Message;
  end;
  if vMensagem <> '' then
  begin
    if sgPos('[MENSSAG',vMensagem) > 0 then
      vMensagem := vMensagem+sgLn+sgLn+'Problema no Objeto na Linha: '+iLinh
    else
      vMensagem := '[MENSSAG_EXIB]: Problema no Objeto na Linha: '+iLinh+sgLn+
                   sgLn+
                   'Mensagem Interna:'+sgLn+
                   vMensagem;

    msgRaiseTratada(vMensagem, vMensagem);
    Result := '#ERRO#';
    SetPADOConn(DtmPoul.DtbGene);
  end;
end;

//Executar os 'EP' Procedures
Function CampPers_EP(iForm: TsgForm; Camp, Linh: String): Boolean;
begin
  if Camp = 'CALCVENC' then
    Result := COPlus.CalcVenc(NuloInte(CampPersExec(Linh)))
  else if Camp = 'NOVACOMP' then
    Result := COPlus.GeraNovaComp(Linh)
  else
  begin
    Result := Proc.ProcPrin(iForm, Camp, Linh);
    iForm.RetoFunc := SeStri(Result,'1','0');
  end;
end;

//Executar os 'TR' Triggers
Function CampPers_TR(iForm: TsgForm; Camp, Linh: String): Boolean;
begin
  Result := Trig.TrigPrin(Camp, Linh);
  iForm.RetoFunc := SeStri(Result,'1','0');
end;

Function CampPers_ConfWeb(iForm: TsgForm; Camp, Linh: String): Boolean;
begin
  Result := GetConfWeb.SetCampPers_ConfWeb(Camp, Linh);
end;

//Retornar o Tipo do Componente baseado no CompCamp
Function CampPers_CompCamp_Tipo(Comp: String): String;
begin
  Comp := AnsiUpperCase(Comp);
  if (Comp = 'E') then
    Result := 'CE'
  else if (Comp = 'C') then
    Result := 'CC'
  else if (Comp = 'A') then
    Result := 'CA'
  else if (Comp = 'N') then
    Result := 'CN'
  else if (Comp = 'T') then
    Result := 'CT'
  else if (Comp = 'L') then
    Result := 'IL'
  else if (Comp = 'IT') then
    Result := 'IT'
  else if (Comp = 'IL') then
    Result := 'IL'
  else if (Comp = 'D') then
    Result := 'CD'
  else if (Comp = 'S') then
    Result := 'CS'
  else if StrIn(Comp, ['M','IM','BM']) then
    Result := 'CM'
  else if (Comp = 'BS') or (Comp = 'BE') or (Comp = 'BI') or (Comp = 'BP') or
          (Comp = 'BX') or (Comp = 'RS') or (Comp = 'RE') or (Comp = 'RI') or
          (Comp = 'RP') or (Comp = 'RX') then
    Result := 'BS'
  else if (Comp = 'ET') then
    Result := 'ET'
  else if StrIn(Comp, ['RM','IR','RB']) then
    Result := 'CR'
  else if (Comp = 'EE') then
    Result := 'LE'
  else if (Comp = 'LE') then
    Result := 'LE'
  else if (Comp = 'ED') then
    Result := 'ED'
  else if (Comp = 'EC') then
    Result := 'EC'
  else if (Comp = 'ES') then
    Result := 'ES'
  else if (Comp = 'EA') then
    Result := 'EA'
  else if (Comp = 'EI') then
    Result := 'EI'
  else if (Comp = 'EN') then
    Result := 'EN'
  else if (Comp = 'LN') then
    Result := 'EN'
  else if (Comp = 'BVL') then
    Result := 'BV'
  else if (Comp = 'LBL') then
    Result := 'LB'
  else if (Comp = 'IE') then
    Result := 'CE'
  else if (Comp = 'IN') then
    Result := 'CN'
  else if (Comp = 'DBG') then
    Result := 'GC'
  else if (Comp = 'GRA') then
    Result := 'GR'
  else if (Comp = 'BTN') then
    Result := 'BT'
  else if (Comp = 'FE') then
    Result := 'FI'
  else if (Comp = 'FI') then
    Result := 'FI'
  else if (Comp = 'FF') then
    Result := 'FF'
  else if (Comp = 'LC') then
    Result := 'LC'
  else if (Comp = 'TIM') then
    Result := 'TI'
  else
    Result := Comp;
end;


//Retorna o campo, conforme o tipo
Function CampPersCompAtua(iForm: TsgForm; Tipo, Camp: String): TObject;
var
  Look: TLcbLbl;
begin
  Result := nil;
  Tipo := AnsiUpperCase(Tipo);
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    if (Tipo = 'CE') or (Tipo = 'E') or (Tipo = 'IE') then
      Result := TDBEdtLbl(FindComponent('Edt'+Camp))
    else if (Tipo = 'CC') or (Tipo = 'C') then
      Result := TDBCmbLbl(FindComponent('Cmb'+Camp))
    else if (Tipo = 'CA') or (Tipo = 'A') then
      Result := TDBFilLbl(FindComponent('Fil'+Camp))
    else if (Tipo = 'CD') or (Tipo = 'D') then
      Result := TDBRxDLbl(FindComponent('Edt'+Camp))
    else if (Tipo = 'IL') then
      Result := TDBLookNume(FindComponent('Edt'+Camp))
    else if (Tipo = 'CN') or (Tipo = 'N') or (Tipo = 'IN') then
      Result := TDBRxELbl(FindComponent('Edt'+Camp))
    else if (Tipo = 'CS') or (Tipo = 'S') then
      Result := TDBChkLbl(FindComponent('Chk'+Camp))
    else if Tipo = 'ES' then
      Result := TChkLbl(FindComponent('Chk'+Camp))
    else if (Tipo = 'CT') or (Tipo = 'T') then
    begin
      Look := TLcbLbl(FindComponent('Lcb'+Camp));
      if Assigned(Look) then
        Result := Look
      else
        Result := TDBLookNume(FindComponent('Edt'+Camp))
    end
    else if (Tipo = 'IT') then
    begin
      Look := TLcbLbl(FindComponent('Lcb'+Camp));
      if Assigned(Look) then
        Result := Look
      else
        Result := TDBLookNume(FindComponent('Edt'+Camp))
    end
    else if StrIn(Tipo , ['CR', 'RM', 'RB', 'IR']) then
      Result := TDBRchLbl(FindComponent('Rch'+Camp))
    else if StrIn(Tipo , ['CM', 'M', 'BM', 'IM']) then
      Result := TDBMemLbl(FindComponent('Mem'+Camp))
    else if (Tipo = 'BS') or (Tipo = 'BE') or (Tipo = 'BI') or (Tipo = 'BP') or
            (Tipo = 'BX') or (Tipo = 'RS') or (Tipo = 'RE') or (Tipo = 'RI') or
            (Tipo = 'RP') or (Tipo = 'RX') then
      Result := TDBAdvMemLbl(FindComponent('Mem'+Camp))
    else if Tipo = 'ET' then
      Result := TMemLbl(FindComponent('Mem'+Camp))
    else if (Tipo = 'LB') then
      Result := TsgLbl(FindComponent('Lbl'+Camp))

    {$ifdef ERPUNI}
    {$else}
      else if (Tipo = 'QE') then  //QuickReport - Edit
        Result := TQRDBText(FindComponent('Edt'+Camp))
      else if (Tipo = 'QL') then  //QuickReport - Label
        Result := TQRLabel(FindComponent('Lbl'+Camp))
      else if (Tipo = 'QS') then  //QuickReport - Sys
        Result := TQRSysData(FindComponent('Sys'+Camp))
      else if (Tipo = 'QX') then  //QuickReport - exp
        Result := TQRExpr(FindComponent('Exp'+Camp))
    {$endif}

    else if (Tipo = 'L') or (Tipo = 'EL') then
      Result := TDBLookNume(FindComponent('Edt'+Camp))
    else if (Tipo = 'LN') or (Tipo = 'EN') then
      Result := TRXEdtLbl(FindComponent('Edt'+Camp))
    else if (Tipo = 'LE') or (Tipo = 'EE')  then
      Result := TEdtLbl(FindComponent('Edt'+Camp))
    else if (Tipo = 'EA') then
      Result := TFilLbl(FindComponent('Fil'+Camp))
    else if (Tipo = 'EI') then
      Result := TDirLbl(FindComponent('Dir'+Camp))
    else if (Tipo = 'EC')  then
      Result := TCmbLbl(FindComponent('Cmb'+Camp))
    else if (Tipo = 'ED')  then
      Result := TRxDatLbl(FindComponent('Edt'+Camp))
    else if (Tipo = 'FI')  then
      Result := TDBImgLbl(FindComponent('Img'+Camp))
    else if (Tipo = 'FF')  then
      Result := TImgLbl(FindComponent('Img'+Camp))
    else if (Tipo = 'BT') or (Tipo = 'BTN') then  //Botão
      Result := TsgBtn(BuscaComponente('Btn'+Camp))
    else if (Tipo = 'LC') then  //List Box
      Result := TLstLbl(FindComponent('Lst'+Camp))
    else if (Tipo= 'DBG') then
      Result := TsgDBG(BuscaComponente('Dbg'+Camp))
    else if (Tipo= 'GRA') then
      Result := TFraGraf(BuscaComponente('Gra'+Camp))
    else if (Tipo= 'TIM') then
      Result := TsgTim(FindComponent('Tim'+Camp))
    else if (Tipo= 'TS') then
      Result := TsgTbs(FindComponent('Tbs'+Camp))
    else if (Tipo= 'BVL') or (Tipo= 'BV') then
      Result := TsgBvl(FindComponent('Bvl'+Camp))
  end;
end;

//LisTChkLbl, clique na coluna para ordenar
procedure CampPersListChecColumnClick(Sender: TObject; Column: TListColumn);
{$ifdef ERPUNI}
{$else}
  var
    Orde: string;
    Quer: TsgQuery;
    Lst : TLstLbl;
  {$endif}
begin
  {$ifdef ERPUNI}
  {$else}
    if (Sender.ClassType = TcxCustomInnerListView) and (TcxCustomInnerListView(Sender).Parent <> nil) and (TcxCustomInnerListView(Sender).Parent.ClassType = TLstLbl) then
    begin
      Lst := TLstLbl(TcxCustomInnerListView(Sender).Parent);
      Quer := Lst.Query;
      if Quer <> nil then
      begin
        Orde := 'ORDER BY '+IntToStr(SeInte(Column.Index=0,2,Column.Index+1));
        Quer.Close;
        if Quer.SQL.Strings[5] = Orde then
          Quer.SQL.Strings[5] := Orde + ' DESC'
        else
          Quer.SQL.Strings[5] := Orde;
        Lst.CarregaDados;
      end;
    end;
  {$endif}
end;


//Executa as Instruções que estão no ShowTabe (o que é pra ser executado no OnShow). VeriAces - Verifica acessos para os Campos
procedure CampPersExecNoOnShow(iForm: TsgForm; List: String; VeriAces: Boolean = False; WherCampMovi: string = '');
var
  NameCamp, TipoOper: String;
  CompAtua: {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif};
  QryAcCa: TsgQuery;
begin
  if List <> '' then
  begin
    GetConfWeb.MemVal1.Clear;
    GetConfWeb.MemVal1.Add(List);
    CampPersExecListInst(iForm, GetConfWeb.MemVal1);
    GetConfWeb.MemVal1.Clear;
  end;

  if VeriAces then
  begin
    if sgCopy(iForm.Caption,01,06) = sgCopy(sInclusao,01,06) then
      TipoOper := 'InclAcCa'
    else
      TipoOper := 'AlteAcCa';

    QryAcCa := TsgQuery.Create(nil);
    try
      QryAcCa.SQL.Add('SELECT CompCamp, NameCamp, InclAcCa, AlteAcCa, ConsAcCa');
      QryAcCa.SQL.Add('FROM POViAcCa INNER JOIN POCaCamp ON (POViAcCa.NameAcCa = POCaCamp.NameCamp) and (POViAcCa.CodiTabe = POCaCamp.CodiTabe)');
      QryAcCa.SQL.Add('WHERE ((POCaCamp.CodiTabe = '+IntToStr(iForm.HelpContext)+')');
      if AnsiUpperCase(iForm.ClassName) <> 'TFRMPOHECAM6' then
        QryAcCa.SQL.Add(WherCampMovi);
      QryAcCa.SQL.Add(')');
      QryAcCa.SQL.Add('AND (('+TipoOper+' = 0) OR (ConsAcCa = 0))');
      //QryAcCa.SQL.Add('AND (CompCamp <> ''BVL'') AND (CompCamp <> ''LBL'')');
      QryAcCa.Open;
      with iForm do
      begin
        if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
        while not(QryAcCa.Eof) do
        begin
          NameCamp := QryAcCa.FieldByName('NameCamp').AsString;
          CompAtua := {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif}(CampPersCompAtua(iForm, QryAcCa.FieldByName('CompCamp').AsString, NameCamp));

          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          //Configuração Geral
          if CompAtua <> Nil then
          begin
            if QryAcCa.FieldByName('ConsAcCa').AsInteger = 0 then
              CompAtua.Visible := False
            else if QryAcCa.FieldByName(TipoOper).AsInteger = 0 then  //Inclusão ou Alteração
              CompAtua.Enabled := False;

            //Campos sem LBL
            if TsgLbl(FindComponent('Lbl'+NameCamp)) <> nil then
            begin
              TsgLbl(FindComponent('Lbl'+NameCamp)).Enabled  := CompAtua.Enabled;
              TsgLbl(FindComponent('Lbl'+NameCamp)).Visible  := CompAtua.Visible;
            end;
          end;
          QryAcCa.Next;
        end;
      end;
    finally
      QryAcCa.Close;
      QryAcCa.Free;
    end;
  end;
end;

//Buscar os campos que são modificados e que não podem ser (Camp: ApAtXXXX)
function CampPers_BuscModi(iForm: TsgForm; DataSet: TDataSet; Tabe: String): Boolean;
var
  i: integer;
  Camp: String;
begin
  Result := False;
  Camp   := Copy(Tabe,05,04);
  if (DataSet.State = dsEdit) and DataSet.Modified and
     VeriExisCampTabe(DataSet,'Tabe'+Camp) and VeriExisCampTabe(DataSet,'CodiGene') then
  begin
    if (Trim(DataSet.FieldByName('Tabe'+Camp).AsString) <> '') and
            (DataSet.FieldByName('CodiGene').AsInteger <> 0) then
    begin
      with iForm do
      begin
        if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
        i := 0;
        while (i < ComponentCount) and (not Result) do
        begin
          if not ((Components[i].ClassType = TMemLbl) and (TMemLbl(Components[i]).Name = 'MemGene')) then
          begin
            Result := (Components[i].Tag <> 15) and CampPersCompAtuaGetProp(iForm, Components[i], 'Modified');
            if Result then
              msgOk('Dados Gerados por outro Processo.'+sgLn+'Informação não pode ser modificada: "'+CampPersCompAtuaGetProp(iForm, Components[i], 'Caption')+'"');
          end;
          inc(i);
        end;
      end;
      if (not Result) then
        DataSet.FieldByName('ApAt'+Camp).AsInteger := DataSet.FieldByName('ApAt'+Camp).AsInteger + 1;
    end;
  end;
end;

//Criar o botão para visualizar o Lanç. Contábil
procedure CampPers_CriaBtn_LancCont(iForm: TsgForm);
{$IFDEF ERPUNI_MODAL}
{$ELSE}
var
  bBtnLanc: Boolean;
  vBtnLanc, vBtnConf: TsgBtn;
  vDts: TDataSource;
{$ENDIF}
begin
  {$IFDEF ERPUNI_MODAL}
    //Modal não deixa criar botão enquanto está no show
  {$ELSE}
    if Assigned(iForm) then
    with iForm do
    begin
      if (not PSitGrav) and (HelpContext > 0) then
      begin
        vDts := TDataSource(BuscaComponente('DtsGrav'));
        if Assigned(vDts) and TestDataSet(vDts.DataSet) and (RetoZero(vDts.DataSet.Fields[0].AsString) <> '0') then
        begin
          SetPsgTrans(iForm.sgTransaction);
          vBtnLanc := TsgBtn(FindComponent('BtnVisuLanc'));
          if not Assigned(vBtnLanc) then
          begin
            vBtnConf := TsgBtn(FindComponent('BtnCanc'));
            with CampJSon.POCaTabe_Para(GetPTab) do
            begin
              bBtnLanc := BtnLanc;
              Free;
            end;
            if Assigned(vBtnConf) and bBtnLanc then
            begin
              vBtnLanc := TsgBtn.Create(iForm);
              vBtnLanc.Parent := vBtnConf.Parent;
              vBtnLanc.Name   := 'BtnVisuLanc';
              {$ifdef ERPUNI}
              {$else}
                vBtnLanc.Caption:= 'Lançamento Contábil';
                vBtnLanc.Margin := vBtnConf.Margin;
                vBtnLanc.Spacing:= vBtnConf.Spacing;
              {$endif}
              vBtnLanc.sgImageIndex := 24;
              vBtnLanc.Left := vBtnConf.Left;
              if Assigned(vBtnConf.Parent) then
                vBtnLanc.Top  := vBtnConf.Parent.ClientHeight - 31
              else
                vBtnLanc.Top  := vBtnConf.Top + 100;
              vBtnLanc.Height := vBtnConf.Height;
              vBtnLanc.Width  := vBtnConf.Width;

              {$ifdef ERPUNI}
                vBtnLanc.Top  := vBtnLanc.Top - 50;
              {$else}
              {$endif}
              {$ifndef LIBUNI}
                vBtnLanc.OnClick := TFrmPOHeForm(iForm).ExecExit;
              {$ENDIF}
            end;
          end;

          if Assigned(vBtnLanc) then
          begin
            vBtnLanc.Lista.Clear;
            vBtnLanc.Lista.Add('FOM50830');
            vBtnLanc.Lista.Add('VA-INTE0011-'+RetoZero(TDataSource(BuscaComponente('DtsGrav')).DataSet.Fields[0].AsString));
            vBtnLanc.Lista.Add('VA-STRI0011-'''+iForm.ConfTabe.GravTabe+'''');
          end;
        end;
      end;
    end;
  {$ENDIF}
end;

//Verifica no momento de Enviar ou Confirmar as instruções a serem executadas
Function VeriEnviConf(iForm: TsgForm; Inst: String):Boolean;
var
  Valo: TStringList;
begin
  Result := True;
  if iForm <> nil then
  begin
    Valo := TStringList.Create;
    try
      Valo.Text := Inst;
      Result := CampPersExecListInst(iForm, Valo);
    finally
      Valo.Free;
    end;
  end;
end;

//Objetivo: Caso parametrizado, pede confirmação na Hora de Gravar, exibindo uma tela pedindo sim ou não
Function ConfGrav(iForm: TsgForm = nil; Tabe: Integer=0):Boolean;
begin
  Result := False;
  if (iForm <> nil) and (Trim(iForm.Confirma) <> '') then
    msgOk(Trim(iForm.Confirma))
  else if VeriEnviConf(iForm, CampPers_TratExec(iForm, CalcStri('SELECT LancTabe FROM POCaTabe WHERE (CodiTabe = '+IntToStr(Tabe)+')'),
                                                     CalcStri('SELECT EPerTabe FROM POCaTabe WHERE (CodiTabe = '+IntToStr(Tabe)+')'))) then
  begin
    Result := True;
    if GetPegaPara_ConfGrav() then
      if msgNao('Confirma Gravação?') then
        Result := False;
  end;
end;

procedure RecaDadoGera(iExibMens: Boolean = True);
begin
  //DeleteFiles(GetPEndExec+'BancoDS\0*.xml');
  //DeleteFiles(GetPEndExec+'BancoDS\Dtm*.xml');
  DeleteFiles(GetPEndExec+'BancoDS\*.xml');
  DtmPoul.QryTabe.sgRefresh;
  DtmPoul.RecaEstr;
  if iExibMens then
    msgOk('Processo Concluído!');
end;

function ListCampPOCaRela(iTipo: String = 'TODOS'): String;
begin
  if iTipo = 'TODOS' then
    Result := 'CODIRELA, CODITABE, NOMERELA, TIPORELA, CONTRELA, RESQRELA, RDIRRELA, RSUPRELA, RINFRELA, RCORRELA, RESTRELA, '+
              'RLARRELA, CESQRELA, CDIRRELA, CSUPRELA, CINFRELA, CCORRELA, CESTRELA, CLARRELA, TITURELA, ESQURELA, DIRERELA, '+
              'SUPERELA, INFERELA, COLURELA, ESPARELA, ALTURELA, LARGRELA, ORIERELA, LFONRELA, LESTRELA, LTAMRELA, LCORRELA, '+
              'LEFERELA, PAPERELA, TOGRRELA, TOTARELA, ESCARELA, TATIRELA, TARORELA, TAMORELA, CAPGRELA, CABERELA, RODARELA, '+
              'MOVIRELA, COT1RELA, COT2RELA, COT3RELA, TTMORELA, DUPLRELA, PERIRELA, CODRRELA, CODICONS, CONFRELA, CAMPRELA, '+
              'TEXTRELA, ARMARELA, FILTRELA, COR1RELA, COR2RELA, COR3RELA, CORFRELA, FOR1RELA, FOR2RELA, FOR3RELA, FORFRELA, '+
              'ALT1RELA, ALT2RELA, ALT3RELA, IMPRRELA, RELARELA, NDESRELA, IMDIRELA, MENSRELA, EXECRELA, ALR1RELA, ALR2RELA, '+
              'ALR3RELA, BUSCRELA, ORDERELA '
  else
    Result := 'CodiRela ';
end;

//Chamada dos relatórios
//TipoExib: 0 - Visualiza, 1 = Imprime, 2 = Composto, 3 impressão direta, (4 ou 5) Salva QRP e 6 Salva PDFCreator
//Conf=Configurações
Function ChamRela(iQryRela, iQrySQL: TsgQuery; iTipoExib: Integer; iConf:String=''; iCodiRela: Integer=0; iForm: TsgForm = nil):String;
begin
  {$ifdef ERPUNI}
    Result := ChamRelaUnig(iForm, iQryRela, iQrySQL, TTipoExib(iTipoExib), iConf, iCodiRela, False);
  {$else}
    //Feito isso, por causa do Exporta para PDF, HTML, etc, que o Composto não exporta
    //Se tem filhos esse relatório, chama o Composto
    if (0 <> CalcInte('SELECT COUNT(*) FROM POCaRela WHERE (CodRRela = '+IntToStr(iQryRela.FieldByName('CodiRela').AsInteger)+')')) then
      Result := ClicBotaComp(iQryRela, iQrySQL, iTipoExib, iConf, iCodiRela)
    else  //Senão, só visualiza
      Result := ClicBotaVisu(iQryRela, iQrySQL, iTipoExib, iConf, iCodiRela);
  {$endif}
end;

Function ChamRelaEspe(iForm: TsgForm; iQryRela: TsgQuery; iTipoExib: Integer; iConf:String=''; iCodiRela: Integer=0):String;
begin
  {$ifdef ERPUNI}
    Result := ChamRelaUnig(iForm, iQryRela, nil, TTipoExib(iTipoExib), iConf, iCodiRela, True);
  {$else}
    Result := ClicBotaReEs( TsgForm(iForm), iQryRela, iTipoExib, iConf, iCodiRela);
  {$endif}
end;

//TipoExib: 0 - Visualiza, 1 = Imprime, 2 = Composto, 3 impressão direta, (4 ou 5) Salva QRP e 6 Salva PDFCreator
Function ChamRelaUnig(iForm: TsgForm; iQryRela, iQrySQL: TsgQuery; iTipoExib: TTipoExib; iConf:String=''; iCodiRela: Integer=0; isRelaEspe: Boolean = False):String;
var
  vMensagem: String;
{$ifdef ERPUNI}
    vEndeArqu: String;
    POChRela_D: TPOChRela_D;
{$else}
{$endif}
begin
  vMensagem := '';
  {$if not Defined(SAGLIB) and not Defined(LIBUNI)}
    {$ifdef ERPUNI}
      Result := '';
      POChRela_D := TPOChRela_D.Create;
      if Assigned(iForm) then
      begin
        iForm.ShowMask(sProcessando);
        Application_ProcessMessages;
      end;
      try
        POChRela_D.Ler_Conf(iConf);
        POChRela_D.QryDado   := iQrySQL;
        POChRela_D.QryRela   := iQryRela;
        POChRela_D.TipoExib  := iTipoExib;
        POChRela_D.IsRelaEspe:= isRelaEspe;
        if isRelaEspe then
          POChRela_D.POChRela.CodiRela := iQryRela.FieldByName('CodiReEs').AsInteger
        else
          POChRela_D.POChRela.CodiRela := iQryRela.FieldByName('CodiRela').AsInteger;
        POChRela_D.DataInic := GetConfWeb.PDa1Manu;
        POChRela_D.DataFina := GetConfWeb.PDa2Manu;
        POChRela_D.FiltPWhe := True;

        if POChRela_D.GeraRelaWS.Result and POChRela_D.Visu then
        begin
          {$ifdef DEBUG}
            vEndeArqu := GetPEndExecOrig()+'files\WSRelatorio\'+POChRela_D.NomeArqu;
            if FileExists(vEndeArqu) then DeleteFile(vEndeArqu);
            CopyFile(PWideChar(POChRela_D.EndeArqu), PWideChar(vEndeArqu), False);
            Result := UniServerModule.FilesFolderURL+'WSRelatorio/'+POChRela_D.NomeArqu;
          {$else}
            Result := 'files\WSRelatorio\'+POChRela_D.NomeArqu;
          {$endif}
        end;
      finally
        POChRela_D.Free;
        if Assigned(iForm) then
          iForm.HideMask;
      end;

      if Result <> '' then
      begin
        RelaPlus.VisuPDF(Result);
        //UniServerModule.EraseCacheFile(Result);
      end;
    {$else}
    {$endif}
  {$endif}
end;

//Distribuição de Centro de Custo, Plano de Contas e demais
function POCaMvCx_Dist(iForm: TsgForm; iCodiTabe, iCodiMvEs, iCodiPess, iCodiTpMv, iCodiSeto, iCodiTran, iCodiPlan, iCodiCent: Integer;
                       iData: TDateTime; iPermCanc: Boolean = False; iQry: TsgQuery = nil;
                       Tabe: String = 'POCaMvEs'; Camp: String = 'CodiMvEs';
                       Qtde: Real = 0; Debi: Real = 0; Cred: Real = 0;
                       Cons: Boolean = False; iWher: String = '';
                       iCodiProd: Integer = 0): Boolean;
var
  Dtb: TsgADOConnection;
  TipoTpMv : Integer;
  {$ifndef LIBUNI}
    FormMvCx : TFrmPOCaMvCx;
  {$ENDIF}
  QryMovi : TsgQuery;
begin
  Result := True;
  {$ifndef LIBUNI}
    {$ifdef ERPUNI}
      if (GetEmpresa() = 'AGD') or
         (GetEmpresa() = 'RNX') then
        FormMvCx := TFrmPOCaMvC2.Create(UniApplication)
      else
        FormMvCx := TFrmPOCaMvCx.Create(UniApplication);
      FormMvCx.Parent := iForm;
    {$else}
      if (GetEmpresa() = 'AGD') or
         (GetEmpresa() = 'RNX') then
        FormMvCx := TFrmPOCaMvC2.Create(iForm)
      else
        FormMvCx := TFrmPOCaMvCx.Create(iForm);
    {$endif}

    FormMvCx.FormRela := iForm;
    FormMvCx.sgIsMovi := True;
    iForm.AcaoPnls := False;
    try
      FormMvCx.HelpContext := iCodiTabe;
      FormMvCx.Caption := 'Distribuição dos Valores (Conta e Centro de Custos)';
      if iCodiMvEs = 0 then
        iCodiMvEs := CalcCodi(Camp, Tabe, iQry);
      if Assigned(iQry) then
        Dtb := TsgADOConnection(iQry.Connection)
      else if Assigned(iForm) then
        Dtb := TsgADOConnection(iForm.sgTransaction)
      else
        Dtb := nil;

      FormMvCx.proDtb := Dtb;

      FormMvCx.FraGrid.DbgGrid.Edita   := not Cons;
      FormMvCx.proDecorator.NewPOGeMvCx.CampOrig := Camp;
      FormMvCx.proDecorator.NewPOGeMvCx.CodiOrig := iCodiMvEs;

      //Executa a consulta e também gera os campos conforme o banco de dados
      FormMvCx.QryDistCons.SQL.Text := FormMvCx.QryDist.SQL.Text;
      //FormMvCx.QryDistCons.SQL.Strings[1] := ', POGeMvCx.'+Camp+', POGeMvCx.'+Camp+' AS CodiOrig';
      FormMvCx.QryDistCons.SQL.Strings[1] := ', POGeMvCx.'+Camp+' AS CodiOrig';
      if Cons then
        FormMvCx.QryDistCons.SQL.Strings[4] := iWher
      else
        FormMvCx.QryDistCons.SQL.Strings[4] := 'WHERE (POGeMvCx.'+Camp+' = ' + IntToStr(iCodiMvEs) + ')';
      FormMvCx.QryDistCons.Open;
      if Cons and FormMvCx.QryDistCons.IsEmpty then  //Só para consulta, mas não tem nada para consultar
      begin
        msgOk(SSemDados);
        Exit;
      end;

      FormMvCx.QryDist.SQL.Text := FormMvCx.QryDistCons.SQL.Text;
      FormMvCx.QryDist.Open;
      if not Cons then
      begin
        if Tabe = 'POCAFINA' then
        begin
          if PegaParaLogi(513, 'CUSTPARA', 0, False) then
          begin
            QryMovi := GetQry('SELECT DTCOMVFI AS Data, SUM(VALOMVFI) AS Valo'+sgLn+
                              'FROM POCAMVFI'+sgLn+
                              'WHERE NOT EXISTS(SELECT 1 FROM POGEMVCX WHERE POGEMVCX.CODIFINA = POCAMVFI.CODIFINA)'+sgLn+
                              '  AND CODIFINA = ' + IntToStr(iCodiMvEs)+sgLn+
                              'GROUP BY DTCOMVFI', 'QryDistMvCx_MvFi', Dtb);
            try
              while not QryMovi.Eof do
              begin
                FormMvCx.QryDist.Insert;
                FormMvCx.QryDist.FieldByName('DataMvcX').AsDateTime := QryMovi.FieldByName('Data').AsDateTime;
                if Cred > 0 then
                  FormMvCx.QryDist.FieldByName('VlCrMvCx').AsFloat := QryMovi.FieldByName('Valo').AsFloat
                else
                  FormMvCx.QryDist.FieldByName('VlDeMvCx').AsFloat := QryMovi.FieldByName('Valo').AsFloat;
                FormMvCx.QryDist.FieldByName('SituMvCx').AsString := 'NORM';
                FormMvCx.uConf := True; //Não valida a geração dos MVCX
                TratErroBanc(FormMvCx.QryDist);
                FormMvCx.uConf := False;
                QryMovi.Next;
              end;
            finally
              QryMovi.Close;
              QryMovi.Free;
            end;
          end;
        end;
      end;
      FormMvCx.EdtQtdeTota.Value := Qtde;
      FormMvCx.uVeriQtde := True;
      FormMvCx.proDecorator.NewPOGeMvCx.TabeOrig := Tabe;

      FormMvCx.EdtDebiTota.Value := Debi;
      FormMvCx.EdtCredTota.Value := Cred;
      FormMvCx.proDecorator.NewPOGeMvCx.DataMvCx := iData;

      FormMvCx.proDecorator.NewPOGeMvCx.CodiPlan := iCodiPlan;
      FormMvCx.proDecorator.NewPOGeMvCx.CodiCent := iCodiCent;

      FormMvCx.QryCent.Close;

      TipoTpMv := CalcInte('SELECT TipoTpMv FROM POCATpMv WHERE (CodiTpMv = '+IntToStr(iCodiTpMv)+')');

      if GetEmpresa() = 'AGD' then
      begin
        if (NumeroInRange(TipoTpMv, 11, 20) or (TipoTpMv IN [32])) then //Saída ou Nenhum saída
          FormMvCx.proDecorator.NewPOGeMvCx.CodiPlan := 0;
      end;

      if iCodiCent <> 0 then
        FormMvCx.QryCent.SQL.Strings[4] :=  'AND (FromCent.CodiCent = '+IntToStr(iCodiCent)+')'
      else if (TipoTpMv <> 35) and (AnsiUpperCase(Tabe) = 'POCAMVES') then  //Só filtra quando for E ou S e for POCaMvEs (Caix e Fina, liberado)
        FormMvCx.QryCent.SQL.Strings[4] :=  'AND ((NULO(FromCent.CoFiCent) = 0 OR FromCent.FiltCent IS NULL OR FromCent.FiltCent = '''')'+
            '   OR ((FromCent.FiltCent = ''PESS'') AND (FromCent.CoFiCent = '+IntToStr(iCodiPess)+
            ')) OR ((FromCent.FiltCent = ''SETO'') AND (FromCent.CoFiCent = '+IntToStr(iCodiSeto)+
            ')) OR ((FromCent.FiltCent = ''TRAN'') AND (FromCent.CoFiCent = '+IntToStr(iCodiTran)+
            ')))'
      else
        FormMvCx.QryCent.SQL.Strings[4] :=  '';
      FormMvCx.QryCent.Open;

      if Cons then
      begin
        iPermCanc := True;
        FormMvCx.BtnSalv.Visible := False;
        FormMvCx.BtnIncl.Visible := False;
        FormMvCx.BtnDesc.Visible := False;
        FormMvCx.BtnExcl.Visible := False;
        FormMvCx.BtnConf.Visible := False;
        FormMvCx.FraGrid.DbgGrid.Edita   := False;
      end;

      FormMvCx.uVeriQtde := True;
      FormMvCx.uPermCanc := iPermCanc;
      FormMvCx.proDecorator.NewPOGeMvCx.CodiProd := iCodiProd;

      Result := (FormMvCx.ShowModal = mrOk) or iPermCanc;
    finally
      FreeAndNil(FormMvCx);
    end;
  {$endif}
end;

//Distribuição de Centro de Custo, Plano de Contas e demais
function POCaMvEs_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil; iDctoVaDe: Boolean = True): Boolean;
var
  Dtb: TsgADOConnection;
  TipoTpMv : Integer;
  QryMvEs: TsgQuery;
  Debi, Cred: Real;
  Data: TDateTime;
  CodiMvEs: Integer;
  vCons : Boolean;
begin
  Result := True;
  QryMvEs := TsgQuery.Create(Nil);
  try
    QryMvEs.Name := 'QryMvEs_DistMvCx';
    if Assigned(iQry) then
      Dtb := TsgADOConnection(iQry.Connection)
    else if Assigned(iForm) then
      Dtb := TsgADOConnection(iForm.sgTransaction)
    else
      Dtb := nil;

    if iQuer.FieldByName('CodiMvEs').AsInteger = 0 then
      CodiMvEs := CalcCodi('CodiMvEs', 'POCaMvEs', iQry)
    else
      CodiMvEs := iQuer.FieldByName('CodiMvEs').AsInteger;

    QryMvEs.sgConnection := Dtb;

    QryMvEs.SQL.Add('SELECT POCaMvEs.CodiEsto, QtNoMvEs AS Qtde'+
                         ', Round(Nulo(ValoMvEs)-Nulo(DctoMvEs)+Nulo(VIPIMvEs)+Nulo(VaITMvEs)+Nulo(FretMvEs)+Nulo(SeguMvEs)+Nulo(OutrMvEs)'+SeStri(iDctoVaDe,' - NULO(VaDeMvEs)','')+',2) AS Valo'+
                         ', POCaMvEs.CodiTpMv, POCaMvEs.CodiSeto, POCaMvEs.CodiProd');
    QryMvEs.SQL.Add('FROM POCAMvEs');
    QryMvEs.SQL.Add('WHERE (POCaMvEs.CodiMvEs = '+IntToStr(CodiMvEs)+')');
    QryMvEs.Open;

    TipoTpMv := CalcInte('SELECT TipoTpMv FROM POCaTpMv WHERE (CodiTpMv = '+IntToStr(SeInte(QryMvEs.FieldByName('CodiTpMv').AsInteger <> 0, QryMvEs.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiTpMv').AsInteger))+')');
    //Entrada
    if (TipoTpMv <= 10) or (TipoTpMv IN [32,35]) then  //32=Nenhum Entradas - 35=Consumo Direto
    begin
      Cred := 0;
      Debi := QryMvEs.FieldByName('Valo').AsFloat;
      Data := iQuer.FieldByName('Rece').AsDateTime;
    end
    //Saídas
    else if (TipoTpMv <= 20) or (TipoTpMv = 33) then //33=Nenhum Saídas
    begin
      Debi := 0;
      Cred := QryMvEs.FieldByName('Valo').AsFloat;
      Data := iQuer.FieldByName('Emis').AsDateTime;
    end
    else
      Exit;

    if (Cred+Debi) <> 0 then
    begin
      if VeriExisCampTabe(iQuer, 'Cons') then
        vCons := iQuer.FieldByName('Cons').AsInteger = 1
      else
        vCons := False;

      Result := POCaMvCx_Dist(iForm, iQuer.FieldByName('CodiTabe').AsInteger, CodiMvEs, iQuer.FieldByName('CodiPess').AsInteger,
                              SeInte(QryMvEs.FieldByName('CodiTpMv').AsInteger <> 0, QryMvEs.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiTpMv').AsInteger),
                              SeInte(QryMvEs.FieldByName('CodiSeto').AsInteger <> 0, QryMvEs.FieldByName('CodiSeto').AsInteger, iQuer.FieldByName('CodiSeto').AsInteger),
                              iQuer.FieldByName('CodiTran').AsInteger, iQuer.FieldByName('CodiPlan').AsInteger,
                              iQuer.FieldByName('CodiCent').AsInteger, Data, iQuer.FieldByName('PermCanc').AsInteger <> 0,
                              iQry, 'POCAMVES', 'CODIMVES', QryMvEs.FieldByName('Qtde').AsFloat, Debi, Cred, vCons,
                              'WHERE (POGeMvCx.CodiMvEs = '+IntToStr(CodiMvEs)+')', QryMvEs.FieldByName('CodiProd').AsInteger);
    end
    else if iQuer.FieldByName('PermCanc').AsInteger <> 0 then
      msgOk('Valor Zerado ou Tipo de Movimento não requer Rateio de Custos (Tipo = '+FormInteBras(TipoTpMv)+')!');
  finally
    QryMvEs.Close;
    QryMvEs.Free;
  end;
end;

//Distribuição de Centro de Custo, Plano de Contas e demais
function POCaMvNo_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil; iDctoVaDe: Boolean = True): Boolean;
var
  Dtb: TsgADOConnection;
  TipoTpMv : Integer;
  QryMvNo: TsgQuery;
  Debi, Cred: Real;
  Data: TDateTime;
  CodiMvNo: Integer;
  vCons : Boolean;
begin
  Result := True;
  QryMvNo := TsgQuery.Create(Nil);
  try
    QryMvNo.Name := 'QryMvNo_DistMvCx';
    if Assigned(iQry) then
      Dtb := TsgADOConnection(iQry.Connection)
    else if Assigned(iForm) then
      Dtb := TsgADOConnection(iForm.sgTransaction)
    else
      Dtb := nil;

    if iQuer.FieldByName('CodiMvNo').AsInteger = 0 then
      CodiMvNo := CalcCodi('CodiMvNo', 'POCaMvNo', iQry)
    else
      CodiMvNo := iQuer.FieldByName('CodiMvNo').AsInteger;

    QryMvNo.sgConnection := Dtb;

    QryMvNo.SQL.Add('SELECT POCaMvNo.CodiNota'+
                         ', POCaMvNo.QtdeMvNo AS Qtde'+
                         ', Round(Nulo(ValoMvNo)-Nulo(DctoMvNo)+Nulo(VaIpMvNo)+Nulo(VaITMvNo)+Nulo(FretMvNo)+Nulo(SeguMvNo)+Nulo(OutrMvNo)'+
                                SeStri(GetEmpresa='MAR','', '+Nulo(VaDeMvNo)')+
                            ',2) AS Valo'+
                         ', POCaMvNo.CodiTpMv, POCaMvNo.CodiSeto, POCaMvNo.CodiProd');
    QryMvNo.SQL.Add('FROM POCAMvNo');
    QryMvNo.SQL.Add('WHERE POCaMvNo.CodiMvNo = '+IntToStr(CodiMvNo));
    QryMvNo.Open;

    TipoTpMv := CalcInte('SELECT TipoTpMv FROM POCaTpMv WHERE (CodiTpMv = '+IntToStr(SeInte(QryMvNo.FieldByName('CodiTpMv').AsInteger <> 0, QryMvNo.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiTpMv').AsInteger))+')');
    //Entrada
    if (TipoTpMv <= 10) or (TipoTpMv IN [32,35]) then  //32=Nenhum Entradas - 35=Consumo Direto
    begin
      Cred := 0;
      Debi := QryMvNo.FieldByName('Valo').AsFloat;
      Data := iQuer.FieldByName('Rece').AsDateTime;
    end
    //Saídas
    else if (TipoTpMv <= 20) or (TipoTpMv = 33) then //33=Nenhum Saídas
    begin
      Debi := 0;
      Cred := QryMvNo.FieldByName('Valo').AsFloat;
      Data := iQuer.FieldByName('Emis').AsDateTime;
    end
    else
      Exit;

    if (Cred+Debi) <> 0 then
    begin
      if VeriExisCampTabe(iQuer, 'Cons') then
        vCons := iQuer.FieldByName('Cons').AsInteger = 1
      else
        vCons := False;

      Result := POCaMvCx_Dist(iForm, iQuer.FieldByName('CodiTabe').AsInteger, CodiMvNo, iQuer.FieldByName('CodiPess').AsInteger,
                              SeInte(QryMvNo.FieldByName('CodiTpMv').AsInteger <> 0, QryMvNo.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiTpMv').AsInteger),
                              SeInte(QryMvNo.FieldByName('CodiSeto').AsInteger <> 0, QryMvNo.FieldByName('CodiSeto').AsInteger, iQuer.FieldByName('CodiSeto').AsInteger),
                              iQuer.FieldByName('CodiTran').AsInteger, iQuer.FieldByName('CodiPlan').AsInteger,
                              iQuer.FieldByName('CodiCent').AsInteger, Data, iQuer.FieldByName('PermCanc').AsInteger <> 0,
                              iQry, 'POCAMvNo', 'CODIMvNo', QryMvNo.FieldByName('Qtde').AsFloat, Debi, Cred, vCons,
                              'WHERE (POGeMvCx.CodiMvNo = '+IntToStr(CodiMvNo)+')', QryMvNo.FieldByName('CodiProd').AsInteger);
    end
    else if iQuer.FieldByName('PermCanc').AsInteger <> 0 then
      msgOk('Valor Zerado ou Tipo de Movimento não requer Rateio de Custos (Tipo = '+FormInteBras(TipoTpMv)+')!');
  finally
    QryMvNo.Close;
    QryMvNo.Free;
  end;
end;

function POCaFina_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil): Boolean;
var
  Dtb: TsgADOConnection;
  TipoTpMv : Integer;
  QryCalc: TsgQuery;
  Valo, ValoMvCx, Debi, Cred: Real;
  Data: TDateTime;
  CodiGene, CodiFina: Integer;
  vList: String;
begin
  Result := True;
  if Assigned(iQry) then
    Dtb := TsgADOConnection(iQry.Connection)
  else if Assigned(iForm) then
    Dtb := TsgADOConnection(iForm.sgTransaction)
  else
    Dtb := nil;

  if iQuer.FieldByName('TabeFina').AsString = 'UNIR' then
  begin
    {$ifndef LIBUNI}
      Application.CreateForm(TFrmPOChGrid,FrmPOChGrid);
      try
        with FrmPOChGrid do
        begin
          FraGrid.DbgGrid.Coluna.Text := '[Colunas]'+sgLn
                                +'Débito=/TotaGrup=S/TotaRoda=S/Masc=#,###,##0.00'+sgLn
                                +'Crédito=/TotaGrup=S/TotaRoda=S/Masc=#,###,##0.00'+sgLn
                                 ;

          Valo  := CalcReal('SELECT SUM(ValoMvFi) FROM POCAMVFI WHERE POCAMVFI.CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina').AsInteger), Dtb);
          vList := RegiEm__List('SELECT FINASUPE'+sgLn
                               +'FROM POREUNFI'+sgLn
                               +'WHERE POREUNFI.CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina').AsInteger)+sgLn
                               +'  AND 0 < (SELECT COUNT(*) FROM POGEFINA WHERE POREUNFI.FINASUPE = POGEFINA.CODIFINA AND (POGEFINA.TABEFINA IS NULL OR POGEFINA.TABEFINA <> ''UNIR''))'+sgLn
                               +'GROUP BY FINASUPE'
                               ,',', ',', True, Dtb);

          QrySQL.sgConnection := Dtb;
          QrySQL.Close;
          QrySQL.SQL.Clear;
          QrySQL.SQL.Add('WITH TABE AS (');
          QrySQL.SQL.Add('SELECT ');
          QrySQL.SQL.Add('  POVIMVCX.CODIFINA');
          QrySQL.SQL.Add(', '+FormNumeSQL(Valo)+' AS VALOFINA');
          QrySQL.SQL.Add(', POVIMVCX.CODIPLAN');
          QrySQL.SQL.Add(', POVIMVCX.CODICENT');
          QrySQL.SQL.Add(', POVIMVCX.CODIRAMO');
          QrySQL.SQL.Add(', POVIMVCX.CODIPRCC');
          QrySQL.SQL.Add(', POVIMVCX.DATAMVCX');
          QrySQL.SQL.Add(', POVIMVCX.VLDEMVCX AS VLDE');
          QrySQL.SQL.Add(', POVIMVCX.VLCRMVCX AS VLCR');
          QrySQL.SQL.Add(', SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX');
          QrySQL.SQL.Add(', SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX');
          QrySQL.SQL.Add('FROM POVIMVCX');
          QrySQL.SQL.Add('WHERE POVIMVCX.CODIFINA IN ('+RetoZero(vList)+')');
          QrySQL.SQL.Add(')');
          QrySQL.SQL.Add('SELECT NomePlan AS "Conta"');
          QrySQL.SQL.Add(', NomeCent AS "Centro de Custo"');
          QrySQL.SQL.Add(', DataMvCx AS "Data"');
          QrySQL.SQL.Add(', NomeRamo AS "Ramo de Atividade"');
          QrySQL.SQL.Add(', NomePrCC AS "Projeto"');
          QrySQL.SQL.Add(', ROUND(DBO.DIVEZERO(VLDE, TTDEMVCX) * VALOFINA,02) AS "Débito"');
          QrySQL.SQL.Add(', ROUND(DBO.DIVEZERO(VLCR, TTCRMVCX) * VALOFINA,02) AS "Crédito"');
          QrySQL.SQL.Add('FROM TABE INNER JOIN MPGEPLAN MPCAPLAN ON TABE.CODIPLAN = MPCAPLAN.CODIPLAN');
          QrySQL.SQL.Add('          INNER JOIN POGECENT POCACENT ON TABE.CODICENT = POCACENT.CODICENT');
          QrySQL.SQL.Add('          LEFT  JOIN POCARAMO ON TABE.CODIRAMO = POCARAMO.CODIRAMO');
          QrySQL.SQL.Add('          LEFT  JOIN POCAPRCC ON TABE.CODIPRCC = POCAPRCC.CODIPRCC');
          QrySQL.SQL.Add('ORDER BY CODIFINA, NumeCent');
          QrySQL.Open;
        end;
        {$IFDEF ERPUNI}
        {$ELSE}
          FrmPOChGrid.FraGrid.DbgGridView.ApplyBestFit(nil, True, True);
        {$ENDIF}
        FrmPOChGrid.ShowModal;
      finally
        FreeAndNil(FrmPOChGrid);
      end;
    {$ENDIF}
  end
  else
  begin
    TipoTpMv := CalcInte('SELECT TipoTpMv FROM POCATpMv WHERE (CodiTpMv = '+IntToStr(iQuer.FieldByName('CodiTpMv').AsInteger)+')');
    if (TipoTpMv <= 20) or (TipoTpMv IN [32,33,35]) then
    begin
      ValoMvCx := 0;
      QryCalc := TsgQuery.Create(Nil);
      try
        QryCalc.Name := 'QryCalc_DistMvCx';
        if iQuer.FieldByName('CodiFina').AsInteger = 0 then
          CodiFina := CalcCodi('CodiFina', 'POCaFina', iQry)
        else
          CodiFina := iQuer.FieldByName('CodiFina').AsInteger;

        QryCalc.sgConnection := Dtb;

        Valo := CalcReal('SELECT SUM(ValoMvFi) FROM POCAMVFI WHERE (POCAMVFI.CODIFINA = '+IntToStr(CodiFina)+')', QryCalc);
        Cred := 0;
        Debi := 0;
        Data := iQuer.FieldByName('Emis').AsDateTime;

        if (iQuer.FieldByName('TabeFina').AsString = 'POCAESTO') or
           (iQuer.FieldByName('TabeFina').AsString = 'POCANOTA') then
        begin
          ExecSQL_('DELETE FROM POGEMVCX WHERE (CodiFina = '+IntToStr(CodiFina)+')', Dtb);
          if iQuer.FieldByName('PermCanc').AsInteger <> 0 then  //Clicado botão custos
          begin
            CodiGene := StrToInt(VeriExisCampTabe_Valo(iQuer, 'CodiGene', '0'));
            if CodiGene = 0 then
              CodiGene := CalcInte('SELECT CodiGene FROM POGeFina WHERE (CodiFina = '+IntToStr(CodiFina)+')', 0, iQry);
            if CodiGene <> 0 then
            begin
              Result := POCaMvCx_Dist(iForm, iQuer.FieldByName('CodiTabe').AsInteger, CodiFina, iQuer.FieldByName('CodiPess').AsInteger,
                                      iQuer.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiSeto').AsInteger,
                                      iQuer.FieldByName('CodiTran').AsInteger, iQuer.FieldByName('CodiPlan').AsInteger,
                                      iQuer.FieldByName('CodiCent').AsInteger, Data, iQuer.FieldByName('PermCanc').AsInteger <> 0,
                                      iQry, 'POCAFINA', 'CODIFINA', 0, Debi, Cred, True,
                                      SeStri((iQuer.FieldByName('TabeFina').AsString = 'POCANOTA')
                                             ,'WHERE (0 < (SELECT COUNT(*) FROM POCAMVNO WHERE (POCAMVNO.CODIMVNO = POGEMVCX.CODIMVNO) AND (POCAMVNO.CODINOTA = '+IntToStr(CodiGene)+')))'
                                             ,'WHERE (0 < (SELECT COUNT(*) FROM POCAMVES WHERE (POCAMVES.CODIMVES = POGEMVCX.CODIMVES) AND (POCAMVES.CODIESTO = '+IntToStr(CodiGene)+')))'));
            end
            else
              msgOk('Custos lançados em outro processo ('+iQuer.FieldByName('TabeFina').AsString+')!');
          end;
        end
        else
        begin
          if iQuer.FieldByName('PermCanc').AsInteger = 0 then
            ValoMvCx := CalcReal('SELECT SUM(NULO(VlCrMvCx)-NULO(VlDeMvCx)) AS VALO FROM POGEMVCX WHERE (POGEMVCX.CODIFINA = '+IntToStr(CodiFina)+')', QryCalc);

          if (iQuer.FieldByName('PermCanc').AsInteger <> 0) or
             (Round(Valo*100) <> Round(Abs(ValoMvCx)*100)) then
          begin
            if (TipoTpMv <= 10) or (TipoTpMv IN [32,35]) then  //32=Nenhum Entradas - 35Consumo Direto
            begin
              Cred := Valo;
              Data := iQuer.FieldByName('Emis').AsDateTime;
            end
            else if (TipoTpMv <= 20) or (TipoTpMv = 33) then //33=Nenhum Saídas
            begin
              Debi := Valo;
              Data := iQuer.FieldByName('Rece').AsDateTime;
            end;

            if Valo <> 0 then
              Result := POCaMvCx_Dist(iForm, iQuer.FieldByName('CodiTabe').AsInteger, CodiFina, iQuer.FieldByName('CodiPess').AsInteger,
                                      iQuer.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiSeto').AsInteger,
                                      iQuer.FieldByName('CodiTran').AsInteger, iQuer.FieldByName('CodiPlan').AsInteger,
                                      iQuer.FieldByName('CodiCent').AsInteger, Data, iQuer.FieldByName('PermCanc').AsInteger <> 0,
                                      iQry, 'POCAFINA', 'CODIFINA', 0, Debi, Cred)
            else
              msgOk('Sem valores para o Rateio de Custos!');
          end;
        end;
      finally
        QryCalc.Close;
        QryCalc.Free;
      end;
    end
    else if iQuer.FieldByName('PermCanc').AsInteger <> 0 then //Clicado botão custos
      msgOk('Tipo de Movimento não requer Rateio de Custos (Tipo = '+FormInteBras(TipoTpMv)+')!');
  end;
end;

function POCaCaix_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil): Boolean;
var
  Dtb: TsgADOConnection;
  CodiCaix, TipoTpMv : Integer;
  QryCalc: TsgQuery;
  Valo, ValoMvCx, Debi, Cred: Real;
  Data: TDateTime;
  CodiGene: Integer;
  Cod_, Tab_, vList: String;
  vOutros: Real;
begin
  Result := True;
  if Assigned(iQry) then
    Dtb := TsgADOConnection(iQry.Connection)
  else if Assigned(iForm) then
    Dtb := TsgADOConnection(iForm.sgTransaction)
  else
    Dtb := nil;

  Tab_ := '';
  CodiGene := 0;
  if (iQuer.FieldByName('TabeCaix').AsString = 'POCAMVFI') and (iQuer.FieldByName('CodiCaix').AsInteger <> 0) then
  begin
    CodiGene := CalcInte('SELECT CodiGene FROM POGeCaix WHERE CodiCaix = '+IntToStr(iQuer.FieldByName('CodiCaix').AsInteger), Dtb);
    Tab_ := CalcStri('SELECT TabeFina FROM POCAMVFI INNER JOIN POGEFINA ON POCAMVFI.CODIFINA = POGEFINA.CODIFINA'+sgLn
                    +'WHERE POCAMVFI.CodiMvFi = '+IntToStr(CodiGene), Dtb);
  end;

  if Tab_ = 'UNIR' then
  begin
    {$ifndef LIBUNI}
      Application.CreateForm(TFrmPOChGrid,FrmPOChGrid);
      try
        with FrmPOChGrid do
        begin
          FraGrid.DbgGrid.Coluna.Text := '[Colunas]'+sgLn
                                +'Débito=/TotaGrup=S/TotaRoda=S/Masc=#,###,##0.00'+sgLn
                                +'Crédito=/TotaGrup=S/TotaRoda=S/Masc=#,###,##0.00'+sgLn
                                 ;

          vList := RegiEm__List('SELECT FINASUPE'+sgLn
                               +'FROM POREUNFI'+sgLn
                               +'WHERE POREUNFI.CODIMVFI = '+IntToStr(CodiGene)+sgLn
                               +'  AND 0 < (SELECT COUNT(*) FROM POGEFINA WHERE POREUNFI.FINASUPE = POGEFINA.CODIFINA AND (POGEFINA.TABEFINA IS NULL OR POGEFINA.TABEFINA <> ''UNIR''))'+sgLn
                               +'GROUP BY FINASUPE'
                               ,',', ',', True, Dtb);

          QrySQL.sgConnection := Dtb;
          QrySQL.Close;
          QrySQL.SQL.Clear;
          QrySQL.SQL.Add('WITH TABE AS (');
          QrySQL.SQL.Add('SELECT ');
          QrySQL.SQL.Add('  POVIMVCX.CODIFINA');
          QrySQL.SQL.Add(', '+FormNumeSQL(iQuer.FieldByName('Valo').AsFloat)+' AS VALOFINA');
          QrySQL.SQL.Add(', POVIMVCX.CODIPLAN');
          QrySQL.SQL.Add(', POVIMVCX.CODICENT');
          QrySQL.SQL.Add(', POVIMVCX.CODIRAMO');
          QrySQL.SQL.Add(', POVIMVCX.CODIPRCC');
          QrySQL.SQL.Add(', POVIMVCX.DATAMVCX');
          QrySQL.SQL.Add(', POVIMVCX.VLDEMVCX AS VLDE');
          QrySQL.SQL.Add(', POVIMVCX.VLCRMVCX AS VLCR');
          QrySQL.SQL.Add(', SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX');
          QrySQL.SQL.Add(', SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX');
          QrySQL.SQL.Add('FROM POVIMVCX');
          QrySQL.SQL.Add('WHERE POVIMVCX.CODIFINA IN ('+RetoZero(vList)+')');
          QrySQL.SQL.Add(')');
          QrySQL.SQL.Add('SELECT NomePlan AS "Conta"');
          QrySQL.SQL.Add(', NomeCent AS "Centro de Custo"');
          QrySQL.SQL.Add(', DataMvCx AS "Data"');
          QrySQL.SQL.Add(', NomeRamo AS "Ramo de Atividade"');
          QrySQL.SQL.Add(', NomePrCC AS "Projeto"');
          QrySQL.SQL.Add(', ROUND(DBO.DIVEZERO(VLDE, TTDEMVCX) * VALOFINA,02) AS "Débito"');
          QrySQL.SQL.Add(', ROUND(DBO.DIVEZERO(VLCR, TTCRMVCX) * VALOFINA,02) AS "Crédito"');
          QrySQL.SQL.Add('FROM TABE INNER JOIN MPGEPLAN MPCAPLAN ON TABE.CODIPLAN = MPCAPLAN.CODIPLAN');
          QrySQL.SQL.Add('          INNER JOIN POGECENT POCACENT ON TABE.CODICENT = POCACENT.CODICENT');
          QrySQL.SQL.Add('          LEFT  JOIN POCARAMO ON TABE.CODIRAMO = POCARAMO.CODIRAMO');
          QrySQL.SQL.Add('          LEFT  JOIN POCAPRCC ON TABE.CODIPRCC = POCAPRCC.CODIPRCC');
          QrySQL.SQL.Add('ORDER BY CODIFINA, NumeCent');
          QrySQL.Open;
        end;
        {$IFDEF ERPUNI}
        {$ELSE}
          FrmPOChGrid.FraGrid.DbgGridView.ApplyBestFit(nil, True, True);
        {$ENDIF}
        FrmPOChGrid.ShowModal;
      finally
        FreeAndNil(FrmPOChGrid);
      end;
    {$ENDIF}
  end
  else
  begin
    TipoTpMv := CalcInte('SELECT TipoTpMv FROM POCATpMv WHERE (CodiTpMv = '+IntToStr(iQuer.FieldByName('CodiTpMv').AsInteger)+')');
    if (TipoTpMv <= 20) or (TipoTpMv IN [32,33,35]) then
    begin
      ValoMvCx := 0;
      QryCalc := TsgQuery.Create(Nil);
      try
        QryCalc.Name := 'QryCalc_DistMvCx';
        QryCalc.sgConnection := Dtb;

        Debi := 0;
        Cred := 0;
        Data := iQuer.FieldByName('Emis').AsDateTime;

        if iQuer.FieldByName('CodiCaix').AsInteger = 0 then
          CodiCaix := CalcCodi('CodiCaix', 'POCaCaix', QryCalc)
        else
          CodiCaix := iQuer.FieldByName('CodiCaix').AsInteger;

        if VeriExisCampTabe(iQuer, 'CodiGene') then
          vOutros := iQuer.FieldByName('Outros').AsFloat
        else
          vOutros := 0;

        if (iQuer.FieldByName('TabeCaix').AsString <> '') and (vOutros = 0) then
        begin
          ExecSQL_('DELETE FROM POGEMVCX WHERE (CodiCaix = '+IntToStr(CodiCaix)+')', Dtb);
          if iQuer.FieldByName('TabeCaix').AsString = 'POCAMVFI' then
          begin
            CodiGene := StrToInt(VeriExisCampTabe_Valo(iQuer, 'CodiGene', '0'));
            if CodiGene = 0 then
              CodiGene := CalcInte('SELECT CodiGene FROM POGeCaix WHERE (CodiCaix = '+IntToStr(CodiCaix)+')');

            if CodiGene <> 0 then
            begin
              CalcDoisCamp('SELECT CodiGene, TabeFina FROM POGeFina '+
                             'WHERE (CodiFina = (SELECT MAX(CodiFina) FROM POCaMvFi WHERE (CodiMvFi = '+IntToStr(CodiGene)+')))', Cod_, Tab_);
              if Tab_ = 'POCAESTO' then
                Tab_ := 'WHERE (0 < (SELECT COUNT(*) FROM POCAMVES WHERE (POCAMVES.CODIMVES = POGEMVCX.CODIMVES) AND (POCAMVES.CODIESTO = '+RetoZero(Cod_)+')))'
              else if Tab_ = 'POCANOTA' then
                Tab_ := 'WHERE (0 < (SELECT COUNT(*) FROM POCAMVNO WHERE (POCAMVNO.CODIMVNO = POGEMVCX.CODIMVNO) AND (POCAMVNO.CODINOTA = '+RetoZero(Cod_)+')))'
              else //Financeiro direto
                Tab_ := 'WHERE (0 < (SELECT COUNT(*) FROM POCAMVFI WHERE (POCAMVFI.CODIFINA = POGEMVCX.CODIFINA) AND (POCAMVFI.CODIMVFI = '+IntToStr(CodiGene)+')))';

              Result := POCaMvCx_Dist(iForm, iQuer.FieldByName('CodiTabe').AsInteger, CodiCaix, iQuer.FieldByName('CodiPess').AsInteger,
                                      iQuer.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiSeto').AsInteger,
                                      iQuer.FieldByName('CodiTran').AsInteger, iQuer.FieldByName('CodiPlan').AsInteger,
                                      iQuer.FieldByName('CodiCent').AsInteger, Data, iQuer.FieldByName('PermCanc').AsInteger <> 0,
                                      iQry, 'POCACAIX', 'CODICAIX', 0, Debi, Cred, True, Tab_);
            end
            else if (iQuer.FieldByName('PermCanc').AsInteger <> 0) then  //Pelo botão Confirma, não avisa nada
              msgOk('Custos lançados em outro processo ('+iQuer.FieldByName('TabeCaix').AsString+')!');
          end
          else if (iQuer.FieldByName('PermCanc').AsInteger <> 0) then  //Pelo botão Confirma, não avisa nada
            msgOk('Custos lançados em outro processo ('+iQuer.FieldByName('TabeCaix').AsString+')!');
        end
        else
        begin
          if vOutros = 0 then
            Valo := iQuer.FieldByName('Valo').AsFloat
          else
            Valo := vOutros;

          if iQuer.FieldByName('PermCanc').AsInteger = 0 then
            ValoMvCx := CalcReal('SELECT SUM(NULO(VlCrMvCx)-NULO(VlDeMvCx)) AS VALO FROM POGEMVCX WHERE (POGEMVCX.CODICaix = '+IntToStr(CodiCaix)+')', QryCalc);

          if (iQuer.FieldByName('PermCanc').AsInteger <> 0) or (Round(Valo*100) <> Round(Abs(ValoMvCx)*100)) then
          begin
            if (TipoTpMv <= 10) or (TipoTpMv IN [32,35]) then  //32=Nenhum Entradas - 35Consumo Direto
            begin
              Cred := Valo;
              Data := iQuer.FieldByName('Emis').AsDateTime;
            end
            else if (TipoTpMv <= 20) or (TipoTpMv = 33) then //33=Nenhum Saídas
            begin
              Debi := Valo;
              Data := iQuer.FieldByName('Rece').AsDateTime;
            end;

            if Valo <> 0 then
              Result := POCaMvCx_Dist(iForm, iQuer.FieldByName('CodiTabe').AsInteger, CodiCaix, iQuer.FieldByName('CodiPess').AsInteger,
                                      iQuer.FieldByName('CodiTpMv').AsInteger, iQuer.FieldByName('CodiSeto').AsInteger,
                                      iQuer.FieldByName('CodiTran').AsInteger, iQuer.FieldByName('CodiPlan').AsInteger,
                                      iQuer.FieldByName('CodiCent').AsInteger, Data, iQuer.FieldByName('PermCanc').AsInteger <> 0,
                                      iQry, 'POCACAIX', 'CODICAIX', 0, Debi, Cred)
            else
              msgOk('Sem valores para o Rateio de Custos!');
          end;
        end;
      finally
        QryCalc.Close;
        QryCalc.Free;
      end;
    end
    else if iQuer.FieldByName('PermCanc').AsInteger <> 0 then //Clicado botão custos
      msgOk('Tipo de Movimento não requer Rateio de Custos (Tipo = '+FormInteBras(TipoTpMv)+')!');
  end;
end;

function POCaUnFi_DistMvCx(iForm: TsgForm; iQuer: TsgQuery; iQry: TsgQuery = nil): Boolean;
var
  Dtb: TsgADOConnection;
  vList, vListBaix: String;
  Debi, Cred: Real;
  QryUnFi: TsgQuery;
begin
  Result := True;
  if Assigned(iQry) then
    Dtb := TsgADOConnection(iQry.Connection)
  else if Assigned(iForm) then
    Dtb := TsgADOConnection(iForm.sgTransaction)
  else
    Dtb := nil;

  {$ifndef LIBUNI}
    Application.CreateForm(TFrmPOChGrid,FrmPOChGrid);
    try
      with FrmPOChGrid do
      begin
        FraGrid.DbgGrid.Coluna.Text := '[Colunas]'+sgLn
                              +'Débito=/TotaGrup=S/TotaRoda=S/Masc=#,###,##0.00'+sgLn
                              +'Crédito=/TotaGrup=S/TotaRoda=S/Masc=#,###,##0.00'+sgLn
                               ;

        Debi := CalcReal('SELECT SUM(CalcUnFi) FROM POCAUNFI WHERE CalcUnFi < 0 AND CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina').AsInteger), Dtb);
        Cred := CalcReal('SELECT SUM(CalcUnFi) FROM POCAUNFI WHERE CalcUnFi > 0 AND CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina').AsInteger), Dtb);
        QrySQL.sgConnection := Dtb;
        QrySQL.Close;
        QrySQL.SQL.Clear;
        QrySQL.SQL.Add('WITH TABE AS (');
        if (Debi <> 0) and (Cred <> 0) then
        begin
          //Lista dos financeiros baixados pela UnFi
          QryUnFi := TsgQuery.Create(nil);
          try
            QryUnFi.sgConnection := Dtb;
            QryUnFi.SQL.Add('SELECT POCAMVFI.CODIFINA, CALCUNFI');
            QryUnFi.SQL.Add('FROM POVIUNFI_BAIX CAIX INNER JOIN POCAMVFI ON CAIX.CODIMVFI = POCAMVFI.CODIMVFI');
            QryUnFi.SQL.Add('WHERE CAIX.CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina').AsInteger));
            QryUnFi.Open;
            while not QryUnFi.Eof do
            begin
              vListBaix := RegiEm__List('SELECT FINASUPE'+sgLn
                                       +'FROM POREUNFI'+sgLn
                                       +'WHERE POREUNFI.CODIFINA = '+IntToStr(QryUnFi.FieldByName('CodiFina').AsInteger)+sgLn
                                       +'  AND 0 < (SELECT COUNT(*) FROM POGEFINA WHERE POREUNFI.FINASUPE = POGEFINA.CODIFINA AND (POGEFINA.TABEFINA IS NULL OR POGEFINA.TABEFINA <> ''UNIR''))'+sgLn
                                       +'GROUP BY FINASUPE'
                                       ,',', ',', True, Dtb);

              QrySQL.SQL.Add('SELECT ');
              QrySQL.SQL.Add('  POVIMVCX.CODIFINA');
              QrySQL.SQL.Add(', '+FormNumeSQL(QryUnFi.FieldByName('CALCUNFI').AsFloat)+' AS VALOFINA');
              QrySQL.SQL.Add(', POVIMVCX.CODIPLAN');
              QrySQL.SQL.Add(', POVIMVCX.CODICENT');
              QrySQL.SQL.Add(', POVIMVCX.CODIRAMO');
              QrySQL.SQL.Add(', POVIMVCX.CODIPRCC');
              QrySQL.SQL.Add(', POVIMVCX.DATAMVCX');
              QrySQL.SQL.Add(', POVIMVCX.VLDEMVCX AS VLDE');
              QrySQL.SQL.Add(', POVIMVCX.VLCRMVCX AS VLCR');
              QrySQL.SQL.Add(', SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX');
              QrySQL.SQL.Add(', SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX');
              QrySQL.SQL.Add(', ''Baixado'' AS Tipo');
              if QryUnFi.FieldByName('CALCUNFI').AsFloat > 0 then
                QrySQL.SQL.Add(', ''VERDE_FRACO'' AS Linh_')
              else
                QrySQL.SQL.Add(', ''LARANJA_FRACO'' AS Linh_');
              QrySQL.SQL.Add('FROM POVIMVCX');
              QrySQL.SQL.Add('WHERE POVIMVCX.CODIFINA = '+RetoZero(vListBaix));
              if QryUnFi.RecordCount <> QryUnFi.RecNo then
                QrySQL.SQL.Add('UNION ALL');

              QryUnFi.Next;
            end;
          finally
            QryUnfi.Close;
            QryUnFi.Free;
          end;
        end;
        if (Abs(Debi) <> Abs(Cred)) then
        begin
          vList := RegiEm__List('SELECT FINASUPE'+sgLn
                               +'FROM POREUNFI'+sgLn
                               +'WHERE POREUNFI.CODIFINA = '+IntToStr(iQuer.FieldByName('CodiFina').AsInteger)+sgLn
                               +'  AND 0 < (SELECT COUNT(*) FROM POGEFINA WHERE POREUNFI.FINASUPE = POGEFINA.CODIFINA AND (POGEFINA.TABEFINA IS NULL OR POGEFINA.TABEFINA <> ''UNIR''))'+sgLn
                               +'GROUP BY FINASUPE'
                               ,',', ',', True, Dtb);

          if sgPos('SELECT ',QrySQL.SQL.Text) > 0 then
            QrySQL.SQL.Add('UNION ALL');
          QrySQL.SQL.Add('SELECT ');
          QrySQL.SQL.Add('  POVIMVCX.CODIFINA');
          QrySQL.SQL.Add(', '+FormNumeSQL(Debi+Cred)+' AS VALOFINA');
          QrySQL.SQL.Add(', POVIMVCX.CODIPLAN');
          QrySQL.SQL.Add(', POVIMVCX.CODICENT');
          QrySQL.SQL.Add(', POVIMVCX.CODIRAMO');
          QrySQL.SQL.Add(', POVIMVCX.CODIPRCC');
          QrySQL.SQL.Add(', POVIMVCX.DATAMVCX');
          QrySQL.SQL.Add(', POVIMVCX.VLDEMVCX AS VLDE');
          QrySQL.SQL.Add(', POVIMVCX.VLCRMVCX AS VLCR');
          QrySQL.SQL.Add(', SUM(POVIMVCX.VLDEMVCX) OVER (PARTITION BY NULL) AS TTDEMVCX');
          QrySQL.SQL.Add(', SUM(POVIMVCX.VLCRMVCX) OVER (PARTITION BY NULL) AS TTCRMVCX');
          QrySQL.SQL.Add(', ''Parcelado'' AS Tipo');
          QrySQL.SQL.Add(', ''0'' AS Linh_');
          QrySQL.SQL.Add('FROM POVIMVCX');
          QrySQL.SQL.Add('WHERE POVIMVCX.CODIFINA IN ('+RetoZero(vList)+')');
        end;
        QrySQL.SQL.Add(')');
        QrySQL.SQL.Add('SELECT NomePlan AS "Conta"');
        QrySQL.SQL.Add(', NomeCent AS "Centro de Custo"');
        QrySQL.SQL.Add(', DataMvCx AS "Data"');
        QrySQL.SQL.Add(', NomeRamo AS "Ramo de Atividade"');
        QrySQL.SQL.Add(', NomePrCC AS "Projeto"');
        QrySQL.SQL.Add(', ROUND(DBO.DIVEZERO(VLDE, TTDEMVCX) * VALOFINA,02) AS "Débito"');
        QrySQL.SQL.Add(', ROUND(DBO.DIVEZERO(VLCR, TTCRMVCX) * VALOFINA,02) AS "Crédito"');
        QrySQL.SQL.Add(', Tipo AS "Tipo"');
        QrySQL.SQL.Add(', Linh_');
        QrySQL.SQL.Add('FROM TABE INNER JOIN MPGEPLAN MPCAPLAN ON TABE.CODIPLAN = MPCAPLAN.CODIPLAN');
        QrySQL.SQL.Add('          INNER JOIN POGECENT POCACENT ON TABE.CODICENT = POCACENT.CODICENT');
        QrySQL.SQL.Add('          LEFT  JOIN POCARAMO ON TABE.CODIRAMO = POCARAMO.CODIRAMO');
        QrySQL.SQL.Add('          LEFT  JOIN POCAPRCC ON TABE.CODIPRCC = POCAPRCC.CODIPRCC');
        QrySQL.SQL.Add('ORDER BY TIPO, Linh_, CODIFINA, NumeCent');
        QrySQL.Open;
      end;
      {$IFDEF ERPUNI}
      {$ELSE}
        FrmPOChGrid.FraGrid.DbgGridView.ApplyBestFit(nil, True, True);
      {$ENDIF}
      FrmPOChGrid.ShowModal;
    finally
      FreeAndNil(FrmPOChGrid);
    end;
  {$ENDIF}
end;

function POCaMvND_ChamTela(Form: TsgForm; CodiTabe, CodiMovi, CodiProd: Integer; Qtde, Peso, Valo: Real;
                           CampTabe, ListNota, ListEsto: String; PermCanc: Boolean = False; const iComp: TObject = nil): Boolean;
begin
  {$ifdef ERPUNI}
    FrmPOCaMvND := TFrmPOCaMvND.Create(UniApplication);
    FrmPOCaMvND.Parent := Form;
  {$else}
    FrmPOCaMvND := TFrmPOCaMvND.Create(Form);
  {$endif}
  FrmPOCaMvND.HelpContext := CodiTabe;
  FrmPOCaMvND.Caption     := 'Distribuição dos itens Devolvidos/Terceiros';
  FrmPOCaMvND.uCodiMvNo   := CodiMovi;
  FrmPOCaMvND.uCampTabe   := CampTabe;
  FrmPOCaMvND.QryDist.SQL.Strings[14] := 'WHERE (POCaMvND.'+CampTabe+' = '+IntToStr(CodiMovi)+')';
  FrmPOCaMvND.QryCodi.SQL.Strings[ 5] := 'WHERE (POViMvND.CodiProd = ' + IntToStr(CodiProd) +
                                         ') AND (POViMvND.OrigMvND = ''POCANOTA'') AND (POViMvND.CodiNota IN ' + ListNota +
                                         ')';
  FrmPOCaMvND.QryCodi.SQL.Strings[15] := 'WHERE (POViMvND.CodiProd = ' + IntToStr(CodiProd) +
                                         ') AND (POViMvND.OrigMvND = ''POCAESTO'') AND (POViMvND.CodiEsto IN ' + ListEsto +
                                         ')';
  FrmPOCaMvND.EdtQtdeTota.Value := Qtde;
  FrmPOCaMvND.EdtPesoTota.Value := Peso;
  FrmPOCaMvND.EdtValoTota.Value := Valo;
  FrmPOCaMvND.uPermCanc := PermCanc;
  if Assigned(iComp) then
    FrmPOCaMvND.sgTransaction := TsgTransaction(iComp);
  Result := FrmPOCaMvND.ShowModal = mrOk;
  FreeAndNil(FrmPOCaMvND);
  if (not Result) and (not PermCanc) then
  begin
    Result := False;
    if AnsiUpperCase(CampTabe) = 'CODIMVNO' then
      ExecSQL_('DELETE FROM POCaMvNo WHERE CodiMvNo = '+IntToStr(CodiMovi), iComp)
    else
      ExecSQL_('DELETE FROM POCaMvEs WHERE CodiMvEs = '+IntToStr(CodiMovi), iComp);
  end;
end;

//Distribuir as Qtde das Notas Devolvidas
Function POCaMvND_Dist(Form: TsgForm; CodiTabe, CodiMovi, CodiProd: Integer;
                       Qtde, QtdeReal, Peso, PesoReal, Valo, ValoReal: Real;
                       CampTabe, ListNota, ListEsto: String;
                       PermCanc: Boolean=False; const iComp: TObject = nil): Boolean;
var
  ContMvNo: Integer;

  procedure Devo_DistQtde_InseTota(Qtde, Peso, Valo: String);
  begin
    InseIntoTabe('POCaMvND',
                [CampTabe,IntToStr(CodiMovi),
                 'CodDMvNo','CodiMvNo',
                 'QtdeMvND',Qtde,
                 'PesoMvND',Peso,
                 'ValoMvND',Valo
                ],'FROM POViMvND WHERE (POViMvND.CodiProd = ' + IntToStr(CodiProd) +
                                ') AND (POViMvND.OrigMvND = ''POCANOTA'') AND (POViMvND.CodiNota IN ' + ListNota +
                                ')', iComp);
    InseIntoTabe('POCaMvND',
                [CampTabe,IntToStr(CodiMovi),
                 'CodDMvEs','CodiMvEs',
                 'QtdeMvND',Qtde,
                 'PesoMvND',Peso,
                 'ValoMvND',Valo
                ],'FROM POViMvND WHERE (POViMvND.CodiProd = ' + IntToStr(CodiProd) +
                                ') AND (POViMvND.OrigMvND = ''POCAESTO'') AND (POViMvND.CodiEsto IN ' + ListEsto +
                                ')', iComp);
  end;
begin
  Result := True;

  //Valores informados são iguais aos somatórios das notas devolvidas
  if (Round(QtdeReal*100000) = Round(Qtde*100000)) and
     (Round(PesoReal*100000) = Round(Peso*100000)) and
     (Round(ValoReal*100000) = Round(Valo*100000)) then
  begin
    Devo_DistQtde_InseTota('QtdeMvND', 'PesoMvND', 'ValoMvND');
  end
  else
  begin
    ContMvNo := CalcInte('SELECT COUNT(*) FROM POViMvND WHERE (POViMvND.CodiProd = ' + IntToStr(CodiProd) +
                                                       ') AND ((POViMvND.OrigMvND = ''POCANOTA'') AND (POViMvND.CodiNota IN ' + ListNota +
                                                       ')  OR  (POViMvND.OrigMvND = ''POCAESTO'') AND (POViMvND.CodiEsto IN ' + ListEsto +
                                                       '))', iComp);
    if (ContMvNo = 1) then  //Se tiver só um MvNo, insere direto também
    begin
      Devo_DistQtde_InseTota(FormNumeSQL(QtdeReal), FormNumeSQL(PesoReal), FormNumeSQL(ValoReal));
    end
    else  //Usuário deverá informar as qtdes para cada nota devolvida
    begin
      Result := POCaMvND_ChamTela(Form, CodiTabe, CodiMovi, CodiProd, QtdeReal, PesoReal, ValoReal, CampTabe, ListNota, ListEsto, False, iComp);
    end;
  end;
end;

procedure Versao_EnviTela(iWher: String; iOwner: String);
var
  QryTabe, QryTab2, QryCabe: TsgQuery;
  vVers: String;

  procedure Versao_EnviTela_Inse(iTabe: String; iWher: String);
  var
    vListCamp: String;
  begin
    vListCamp  := Banc_ListCampTabe(iTabe, False, True);
    ExecSQL_('INSERT INTO '+iOwner+'.'+iTabe+' ('+vListCamp+
                                      ') SELECT '+vListCamp+
                                      ' FROM ERPSAG_DESENV.'+iTabe+
                                      ' WHERE '+iWher);
  end;

begin
  vVers := RetoVers();
  if InputQuery('Versão','Versão',vVers) then
  begin
    ExecSQL_('UPDATE SISTTABE SET VersTabe = '+QuotedStr(vVers)+', PDatTabe = CURRENT_DATE WHERE '+iWher);

    QryTabe := GetQry('SELECT CODITABE FROM SISTTABE WHERE '+iWher+' ORDER BY CODITABE', 'QryTabe');
    QryTab2 := TsgQuery.Create(nil);
    QryCabe := TsgQuery.Create(nil);
    try
      while not QryTabe.Eof do
      begin
        QryTab2 := GetQry(QryTab2,
                          'SELECT CODITABE, CABETABE, GETATABE'+sgLn+
                          'FROM SISTTABE'+sgLn+
                          'WHERE CODITABE = '+IntToStr(QryTabe.FieldByName('CodiTabe').AsInteger)+sgLn+
                          '   OR CODITABE IN (SELECT GETATABE FROM SISTTABE PAI_ WHERE PAI_.CODITABE = '+IntToStr(QryTabe.FieldByName('CodiTabe').AsInteger)+')'+sgLn+
                          '   OR 0 < (SELECT COUNT(*) FROM SISTOBRE WHERE SISTOBRE.CODITABE = '+IntToStr(QryTabe.FieldByName('CodiTabe').AsInteger)+sgLn+
                                                                    ' AND SISTTABE.CODITABE = SISTOBRE.CODRTABE)'+sgLn+
                          'ORDER BY CODITABE');
        ExibProgPrin(0, QryTab2.RecordCount);
        while not QryTab2.Eof do
        begin
          ExibProgPrin(1, 0, 'Tabela: '+FormInteBras(QryTab2.FieldByName('CodiTabe').AsInteger));

          ExecSQL_('DELETE FROM '+iOwner+'.SISTCONS WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTCAMP WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTRELA WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTREES WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTOBRE WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTTABE WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTLINK WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          ExecSQL_('DELETE FROM '+iOwner+'.SISTLINK WHERE 0 < (SELECT COUNT(*) FROM SISTRELA WHERE SISTLINK.CODIRELA = SISTRELA.CODIRELA AND SISTRELA.CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger)+')');
          //ExecSQL_('DELETE FROM '+iOwner+'.SISTOBJE');
          ExecSQL_('DELETE FROM '+iOwner+'.SISTOBRE WHERE CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));

          Versao_EnviTela_Inse('SISTTABE', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          Versao_EnviTela_Inse('SISTCAMP', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          Versao_EnviTela_Inse('SISTRELA', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          Versao_EnviTela_Inse('SISTREES', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          Versao_EnviTela_Inse('SISTCONS', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          Versao_EnviTela_Inse('SISTLINK', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));
          Versao_EnviTela_Inse('SISTLINK', '0 < (SELECT COUNT(*) FROM ERPSAG_DESENV.SISTRELA WHERE SISTLINK.CODIRELA = SISTRELA.CODIRELA AND SISTRELA.CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger)+')');
          //Versao_EnviTela_Inse('SISTOBJE', '');
          Versao_EnviTela_Inse('SISTOBRE', 'CODITABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger));

          ExecSQL_('INSERT INTO SIBKTABE_ST (CODMTABE) VALUES ('+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger)+')');

          QryCabe := GetQry(QryCabe,
                           'SELECT CODITABE'+sgLn+
                           'FROM SISTTABE'+sgLn+
                           'WHERE CABETABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger)+sgLn+
                           //'  OR  GETATABE = '+IntToStr(QryTab2.FieldByName('CodiTabe').AsInteger)+sgLn+
                           'ORDER BY CODITABE');
          while not QryCabe.Eof do
          begin
            Versao_EnviTela('CodiTabe = '+IntToStr(QryCabe.FieldByName('CodiTabe').AsInteger), iOwner);
            QryCabe.Next;
          end;
          QryCabe.Close;
          QryTab2.Next;
        end;
        QryTab2.Close;
        QryTabe.Next;
      end;
    finally
      QryCabe.Close;
      QryCabe.Free;
      QryTab2.Close;
      QryTab2.Free;
      QryTabe.Close;
      QryTabe.Free;
    end;
  end;
end;
//******************************************************************************************
//************* M U L T I   B A S E S ******************************************************

//Editar no SQL Server as Tabelas Pai, passando o Campo Código
Function EditTabeCabeCamp(Data: TDataSet; QryCabe: TsgQuery; Tabe, Camp: string; Inse: Boolean = True): TDataSet;
var
  Codi: Integer;
begin
  Tabe := AnsiUpperCase(Tabe);
  Camp := AnsiUpperCase(Camp);
  Codi := 0;
  try //Colocado o Try por que no Oracle estava retornando erro ao chamar o Campo Zero
    if (Data.Active) and (not Inse) then
      Codi := Data.FieldByName(Camp).AsInteger;
  except
    Codi := 0;
  end;
  Data.DisableControls;
  Data.Cancel;
  Data.Close;
  QryCabe.Close;
  QryCabe.SQL.Clear;
  QryCabe.SQL.Add('SELECT *');
  QryCabe.SQL.Add('FROM ' + Tabe);
  QryCabe.SQL.Add('');
  QryCabe.SQL.Add('');
  if Codi = 0 then
    QryCabe.SQL.Add('WHERE ('+Camp+' = '+IntToStr(CalcCodi(Camp,Tabe))+')')
  else
    QryCabe.SQL.Add('WHERE ('+Camp+' = '+IntToStr(Codi)+')');
  QryCabe.SQL.Add('');
  QryCabe.SQL.Add('');
  QryCabe.Open;
  Data := QryCabe;
  Data.Edit;
  Data.EnableControls;
  Result := Data;
end;

//Editar no SQL Server as Tabelas Pai
Function EditTabeCabe(Data: TDataSet; QryCabe: TsgQuery; Tabe: string; Inse: Boolean = True): TDataSet;
begin
  Result := EditTabeCabeCamp(Data, QryCabe, Tabe, 'Codi'+Copy(Tabe,05,04), Inse);
end;

//Editar a tabela com Codi
Function EditTabeCabeCodi(Data: TDataSet; QryCabe: TsgQuery; Tabe: string; Codi: Integer = 0): TDataSet;
var
  Camp: String;
begin
  Tabe := AnsiUpperCase(Tabe);
  Camp := AnsiUpperCase('Codi'+Copy(Tabe,05,100));
  Data.Cancel;
  Data.Close;
  QryCabe.Close;
  QryCabe.SQL.Clear;
  QryCabe.SQL.Add('SELECT *');
  QryCabe.SQL.Add('FROM ' + Tabe);
  QryCabe.SQL.Add('');
  QryCabe.SQL.Add('');
  if Codi = 0 then
    QryCabe.SQL.Add('WHERE ('+Camp+' = '+IntToStr(CalcCodi(Camp,Tabe))+')')
  else
    QryCabe.SQL.Add('WHERE ('+Camp+' = '+IntToStr(Codi)+')');
  QryCabe.SQL.Add('');
  QryCabe.SQL.Add('');
  QryCabe.Open;
  Data := QryCabe;
  Data.Edit;
  Result := Data;
end;


//********** F I M   D O   M U L T I   B A S E S *******************************************
//******************************************************************************************

Function MensConf(Mens,Nom1,Nom2,Nom3:String;Nume,Focu:Byte):Byte;
//Objetivo:Montar uma tela para mensagens com um, dois ou trjs botues
begin
  Mens := SubsPala(Mens,'|',sgLn);
  if IsRx9() then
  begin
    Mens := SubsPalaTudo(Mens,' SAG ',' '+GetPNomAbreSoft()+' ');
    Mens := SubsPalaTudo(Mens,' SAG.',' '+GetPNomAbreSoft()+'.');
    Mens := SubsPalaTudo(Mens,' SAG,',' '+GetPNomAbreSoft()+',');
    Mens := SubsPalaTudo(Mens,' SAG!',' '+GetPNomAbreSoft()+'!');
    Mens := SubsPalaTudo(Mens,' SAG?',' '+GetPNomAbreSoft()+'?');
  end;

  Result := 1;
  {$ifdef WS}
    raise Exception.Create(Mens);
  {$else}
    Application.CreateForm(TFrmPOGeConf,FrmPOGeConf);
    FrmPOGeConf.LblMens.Caption := Mens;
    if Nume = 1 then
    begin
      FrmPOGeConf.Bot3.Visible := True;
      FrmPOGeConf.Bot3.Caption := Nom1;
      FrmPOGeConf.Bot3.Hint := SubsPala(Nom1,'&','') ;
    end
    else if Nume = 2 then
    begin
      FrmPOGeConf.Bot2.Visible := True;
      FrmPOGeConf.Bot2.Caption := Nom1;
      FrmPOGeConf.Bot2.Hint := SubsPala(Nom1,'&','');
      FrmPOGeConf.Bot4.Visible := True;
      FrmPOGeConf.Bot4.Caption := Nom2;
      FrmPOGeConf.Bot4.Hint := SubsPala(Nom2,'&','');
    end
    else
    begin
      FrmPOGeConf.Bot1.Visible := True;
      FrmPOGeConf.Bot1.Caption := Nom1;
      FrmPOGeConf.Bot1.Hint := SubsPala(Nom1,'&','');
      FrmPOGeConf.Bot3.Visible := True;
      FrmPOGeConf.Bot3.Caption := Nom2;
      FrmPOGeConf.Bot3.Hint := SubsPala(Nom2,'&','');
      FrmPOGeConf.Bot5.Visible := True;
      FrmPOGeConf.Bot5.Caption := Nom3;
      FrmPOGeConf.Bot5.Hint := SubsPala(Nom3,'&','');
    end;
    FrmPOGeConf.Focu := Focu;
    if FrmPOGeConf.ShowModal = mrOK then
      Result := FrmPOGeConf.Nume;
  {$endif}
end;

Function Cancela: Boolean;
const Regi = 5;
var
  Temp: Real;
  Hora, Minu, Segu: Integer;
  Desc: String;
begin
  with FrmPOGeAgCa do
  begin
    GauAgua.AddProgress(1);
    Application_ProcessMessages;
    Result := Canc;

    if (GauAgua.Progress = 1) then
    begin
      HoraInic := SysUtils.Time;
      Ulti := GetTickCount;
      LblMedi.Caption := '';
      LblMedi.Update;
      LblEsti.Caption := '';
      LblEsti.Update;
      LblTemp.Caption := '';
      LblTemp.Update;
    end;

    Temp := (SysUtils.Time - HoraInic);
    if ((StrToInt(FormatDateTime('ss',Temp)) mod 5) = 0) and (Ulti <> StrToInt(FormatDateTime('ss',Temp))) then  //a cada 5 seg
    begin
      Show;
      Ulti := StrToInt(FormatDateTime('ss',Temp));
      Temp := DiveZero(Temp, GauAgua.Progress) * (GauAgua.MaxValue-GauAgua.Progress);  //Tempo em segundos
      Hora := StrToInt(FormatDateTime('hh',Temp));
      Minu := StrToInt(FormatDateTime('nn',Temp));
      Segu := StrToInt(FormatDateTime('ss',Temp));
      //LblMedi.Caption := FormInteBras(Hora)+':'+ FormInteBras(Minu)+':'+ FormInteBras(Segu);
      //Lblmedi.Update;

      if Hora > 0 then
      begin
        Minu := (Minu div 5) * 5;
        Desc := FormInteBras(Hora) +' hora'+  SeStri(Hora>1,'s','') +
                SeStri(Minu>0,' e '+FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s',''),'');
      end
      else if (Minu >= 10) then
        Desc := FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s','')
      else if (Minu >= 05) then
      begin
        Segu := (Segu div 30) * 30;
        Desc := FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s','') +
                SeStri(Segu>0,' e '+FormInteBras(Segu)+' segundo'+SeStri(Segu>1,'s',''),'')
      end
      else if (Minu > 0) then
      begin
        Segu := (Segu div 15) * 15;
        Desc := FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s','') +
                SeStri(Segu>0,' e '+FormInteBras(Segu)+' segundo'+SeStri(Segu>1,'s',''),'')
      end
      else //if (Hora = 0) and (Minu = 0) then
      begin
        Segu := (Segu div 5) * 5;
        if Segu = 0 then
          Segu := 5;
        Desc := FormInteBras(Segu)+' segundos';
      end;

      LblEsti.Caption := 'Restante: Cerca de '+Desc;
      LblEsti.Update;

      LblRegi.Caption := FormMascNume(GauAgua.Progress) +' de '+ FormMascNume(GauAgua.MaxValue);
      LblRegi.Update;
    end;

    LblTemp.Caption := 'Tempo: '+FormatDateTime('hh:nn:ss',SysUtils.Time - HoraInic);
    LblTemp.Update;

    Update;
  end;
end;

// Corrige o erro: A component named FrmPOGeAgCa already exists
Function Cancela(FrmPOGeAgCa: TFrmPOGeAgCa): Boolean;
const Regi = 5;
var
  Temp: Real;
  Hora, Minu, Segu: Integer;
  Desc: String;
begin
  with FrmPOGeAgCa do
  begin
    GauAgua.AddProgress(1);
    Application_ProcessMessages;
    Result := Canc;

    if (GauAgua.Progress = 1) then
    begin
      HoraInic := SysUtils.Time;
      Ulti := GetTickCount;
      LblMedi.Caption := '';
      LblMedi.Update;
      LblEsti.Caption := '';
      LblEsti.Update;
      LblTemp.Caption := '';
      LblTemp.Update;
    end;

    Temp := (SysUtils.Time - HoraInic);
    if ((StrToInt(FormatDateTime('ss',Temp)) mod 5) = 0) and (Ulti <> StrToInt(FormatDateTime('ss',Temp))) then  //a cada 5 seg
    begin
      Show;
      Ulti := StrToInt(FormatDateTime('ss',Temp));
      Temp := DiveZero(Temp, GauAgua.Progress) * (GauAgua.MaxValue-GauAgua.Progress);  //Tempo em segundos
      Hora := StrToInt(FormatDateTime('hh',Temp));
      Minu := StrToInt(FormatDateTime('nn',Temp));
      Segu := StrToInt(FormatDateTime('ss',Temp));
      //LblMedi.Caption := FormInteBras(Hora)+':'+ FormInteBras(Minu)+':'+ FormInteBras(Segu);
      //Lblmedi.Update;

      if Hora > 0 then
      begin
        Minu := (Minu div 5) * 5;
        Desc := FormInteBras(Hora) +' hora'+  SeStri(Hora>1,'s','') +
                SeStri(Minu>0,' e '+FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s',''),'');
      end
      else if (Minu >= 10) then
        Desc := FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s','')
      else if (Minu >= 05) then
      begin
        Segu := (Segu div 30) * 30;
        Desc := FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s','') +
                SeStri(Segu>0,' e '+FormInteBras(Segu)+' segundo'+SeStri(Segu>1,'s',''),'')
      end
      else if (Minu > 0) then
      begin
        Segu := (Segu div 15) * 15;
        Desc := FormInteBras(Minu)+' minuto'+SeStri(Minu>1,'s','') +
                SeStri(Segu>0,' e '+FormInteBras(Segu)+' segundo'+SeStri(Segu>1,'s',''),'')
      end
      else //if (Hora = 0) and (Minu = 0) then
      begin
        Segu := (Segu div 5) * 5;
        if Segu = 0 then
          Segu := 5;
        Desc := FormInteBras(Segu)+' segundos';
      end;

      LblEsti.Caption := 'Restante: Cerca de '+Desc;
      LblEsti.Update;

      LblRegi.Caption := FormMascNume(GauAgua.Progress) +' de '+ FormMascNume(GauAgua.MaxValue);
      LblRegi.Update;
    end;

    LblTemp.Caption := 'Tempo: '+FormatDateTime('hh:nn:ss',SysUtils.Time - HoraInic);
    LblTemp.Update;

    Update;
  end;
end;


//---> Procedimento para Chamar Telas com o SHOWMODAL sem a definição de Acesso
//---> Parâmetros: Form: Formulário a Ser Criado e Chamado
function ChamModa(Form: String): sgActionResult;
var
  vCodiTabeAnte: Integer;
begin
  Result := sgActionResult.Create;
  vCodiTabeAnte := GetPTab();
  Screen.Cursor:=crHourGlass;
  try
    if isDigit(Form) then
      SetPTab(StrToInt(Form))
    else
    begin
      if AnsiUpperCase(Copy(Form,01,03)) <> 'MNU' then
        Form := 'MNU'+Form;
      SetPTab(StrToInt(RetoZero(DtmPoul.Tabelas_Busc('CodiTabe', '(MenuTabe = '+QuotedStr(AnsiUpperCase(Form))+')'))));
    end;

    if GetPTab = 0 then
      Form := 'TFRM'+Copy(Form,04,Length(Form)-03)
    else
      Form := DtmPoul.Tabelas_Busc('FormTabe', 'CodiTabe = '+IntToStr(GetPTab));
    with TsgFormClass(FindClass(Form)).Create(Nil) do
    begin
      if sgCopy(Form,01,11) = 'TFRMPOHECAM' then
        Name := Copy(Form,02,11)+'_'+IntToStr(GetPTab());
      ConfTabe.CodiTabe := GetPTab();
      ConfTabe.FormTabe := Form;
      sgTipoClic := tcClicShow;
      {$ifdef ERPUNI}
      {$else}
        GravContPOCaTabe(GetPTab());
      {$endif}
      HelpContext := GetPTab();
      if Caption = 'Campos' then
        Caption := Trim(ConfTabe.CaptTabe);
      {$ifdef ERPUNI}
      {$else}
        FormStyle := fsNormal;
      {$endif}
      Visible := False;
      if ShowModal = mrOk then
        Result.AddMsg2(0010, 'PlusUni', 'ChamModa', 'Ok')
      else
        Result.AddMsg2(2510, 'PlusUni', 'ChamModa', 'Ok')
    end;
  finally
    Screen.Cursor:=crDefault;
    SetPTab(vCodiTabeAnte);
  end;
end;

Function VeriAlteSenhVenc(Data: TDateTime): sgActionResult;
var
  Mens: String;
  vData: TDateTime;
begin
  Result := sgActionResult.Create;
  //vData := PDataServ;
  vData := Date;
  if (Data = 0) then
  begin
    if msgSim('Necessário definir Nova Senha no Primeiro Acesso. Deseja definir agora?') then
    begin
      if ChamModa('POGeTroc').Result then
        Result.AddMsg2(0100, 'PlusUni', 'VeriAlteSenhVenc', 'Senha de Primeiro Acesso Alterada!')
      else
        Result.AddMsg2(2010, 'PlusUni', 'VeriAlteSenhVenc', 'Senha de Primeiro Acesso não Alterada!')
    end
    else
      Result.AddMsg2(2020, 'PlusUni', 'VeriAlteSenhVenc', 'Senha de Primeiro Acesso não Alterada!')
  end
  else if (Data < vData) then
    Result.AddMsg2(2000, 'PlusUni', 'VeriAlteSenhVenc', 'Senha Vencida!')
  else
  if (Data-vData) <= 4 then
  begin
    if (Data-vData) = 1 then
      Mens := 'Senha vencerá amanhã.'
    else if (Data = vData) then
      Mens := 'Senha vence hoje.'
    else
      Mens := 'Senha vencerá em '+FormInteBras(Data-vData)+' dias.';

    {$IFDEF ERPUNI}
    {$ELSE}
      if MensConf(Mens+sgLn+' Utilize a opção "Utilitários/Troca de Senha" para renová-la ou clique em "Altera"!', '&OK','&Altera','',2,2) = 2 then
        ChamModa('POGeTroc');
    {$ENDIF}
  end;
end;

//********** F I M   D O   C H A M A R    F O R M U L A R I O S ****************************
//******************************************************************************************


//******************************************************************************************
//*************             A C E S S O S             **************************************

//Objetivo: Verifica se o Usuário tem acesso a Empresa
function VeriAcesEmpr(CodiEmpr: Integer):Boolean;
begin
  Result := CalcInte('SELECT COUNT(*) FROM POViAcEm WHERE (POViAcEm.CodiEmpr = '+IntToStr(CodiEmpr)+')') > 0;
end;

//Objetivo: Verifica se o Usuário tem acesso ao Módulo
function VeriAcesModu(CodiProd: Integer):Boolean;
begin
  {$ifdef Pratica}
    Result := True;
  {$else}
    Result := CalcInte('SELECT COUNT(*) FROM POViAcPr WHERE (POViAcPr.CodiProd = '+IntToStr(CodiProd)+')') > 0;
  {$endif}
end;

//Carrega os Produtos que o Usuário tem Acesso
Function CarrAcesModu(QryProd: TSgQuery; LcbProd: TLcbLbl; Usua, Empr, Sist, GrUs: Integer): Integer;
begin
  Result := 0;
  QryProd.Close;
  {$ifdef Pratica}
    QryProd.SQL.Strings[1] := 'FROM CLCaProd';
    {$ifdef CW}
      QryProd.SQL.Strings[2] := 'WHERE (CLCaProd.CodiProd = 60)';
    {$else}
      QryProd.SQL.Strings[2] := 'WHERE (CLCaProd.CodiProd = 55)';
    {$endif}
  {$else}
    QryProd.SQL.Strings[1] := 'FROM POViAcPr INNER JOIN CLCaProd ON POViAcPr.CodiProd = CLCaProd.CodiProd';
    QryProd.SQL.Strings[2] := '';
  {$endif}
  QryProd.Open;

  LcbProd.KeyValue := Sist;
  LcbProd.SetNovoValor_Query();

//  msgOk('RetoPusu: '+CalcStri('SELECT RETOPUSU() FROM DUAL'), mtInformation, [mbOK]);
//  msgOk('RetoPEmp: '+CalcStri('SELECT RETOPEMP() FROM DUAL'), mtInformation, [mbOK]);
//  msgOk('RetoPSis: '+CalcStri('SELECT RETOPSIS() FROM DUAL'), mtInformation, [mbOK]);
//  msgOk('codiprat: '+CalcStri('SELECT SESSION_CONTEXT(N''codiprat'') FROM DUAL'), mtInformation, [mbOK]);

  LcbProd.Enabled := (QryProd.RecordCount > 1);
  if LcbProd.LblAssoc <> nil then
    LcbProd.LblAssoc.Enabled := LcbProd.Enabled;
end;

//Retorna uma string com os acessos do Usuário para essa tabela
function VeriAcesTabeTota(Tabe: Integer; iTipoClic: TTipoClic = tcClicManu): String;
var
  Qry: TsgQuery;
begin
  if (IsAdmiSAG or isAdmiClie) or (iTipoClic in [tcClicManuSem_Aces, tcClicShow]) or
     NumeroIn(Tabe , [15450]) then
    Result := '123456'
  else
  begin
    Result := '';
    Qry := TsgQuery.Create(nil);
    try
      Qry.Name := 'QryVeriAcesTabeTota';
      Qry.Close;
      Qry.SQL.Clear;
      Qry.SQL.Add('SELECT InclAces, AlteAces, ConsAces, ExclAces, SeleAces, RelaAces');
      Qry.SQL.Add('FROM TABLE(FUN_ACES_TABE(0,'+IntToStr(Tabe)+')) POViAces');
      //SQL.Add('WHERE (CodiTabe = '+IntToStr(Tabe)+')');
      Qry.Open;
      if not Qry.IsEmpty then //Caso exista Permissão para o Usuário
      begin
        if Qry.FieldByName('InclAces').AsInteger <> 0 then
          Result := '1';
        if Qry.FieldByName('AlteAces').AsInteger <> 0 then
          Result := Result + '2';
        if Qry.FieldByName('ConsAces').AsInteger <> 0 then
          Result := Result + '3';
        if Qry.FieldByName('ExclAces').AsInteger <> 0 then
          Result := Result + '4';
        if Qry.FieldByName('SeleAces').AsInteger <> 0 then
          Result := Result + '5';
        if Qry.FieldByName('RelaAces').AsInteger <> 0 then
          Result := Result + '6';
      end;
    finally
      Qry.Close;
      Qry.Free;
    end;
  end;
end;

//Objetivo..: Verificar acesso dos usuários
// Parâmetros: Tabe   -> Código do módulo operado
//             Opcao    -> (S/N se grupo tem acesso no módulo nesta opcao
//                         (1=Incluir,2=Alterar,3=Consultar,4=Excluir;5=Seleção;6=Relatório)
function VeriAcesTabe(Tabe: Integer; Opca: Byte; iTipoClic: TTipoClic = tcClicManu): Boolean;
begin
  if isAdmiSAG() then
    Result := True
  else
    Result := Pos(IntToStr(Opca), VeriAcesTabeTota(Tabe, iTipoClic)) > 0;
end;

//********** F I M   D O S    A C E S S O S                *********************************
//******************************************************************************************


//******************************************************************************************
//*************      M O N I T O R   *******************************************************

//Limpar o Monitor dos querys do DtmPoul
Procedure LimpMoniDataModu();
var
  i : Integer;
begin
  with DtmPoul do
  begin
    if GetPADOConn <> nil then
      GetPADOConn.Monitor.Clear;
    for i := 0 to (ComponentCount - 1) do
    begin
      If (Components[i].ClassType = TsgQuery) then
        TsgQuery(Components[i]).Monitor.Clear;
    end;
  end;
end;

//Limpar o Monitor dos querys do DtmPoul e Demais
Procedure LimpMoniGera(iForm: TsgForm);
var
  i : Integer;
begin
  LimpMoniDataModu();
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    for i := 0 to (ComponentCount - 1) do
    begin
      If (Components[i].ClassType = TsgADOConnection) then
        TsgADOConnection(Components[i]).Monitor.Clear
      else if (Components[i].ClassType = TsgQuery) then
        TsgQuery(Components[i]).Monitor.Clear
      else if AnsiUpperCase(Components[i].Name) = 'DTSGRAV' then
        if (TDataSource(Components[i]).DataSet <> nil) and
           (TDataSource(Components[i]).DataSet.ClassType = TsgQuery) then
          TsgQuery(TDataSource(Components[i]).DataSet).Monitor.Clear;
    end;
  end;
end;


//Fechar os Querys da Tela Fechada e Limpa os Monitor do DtmPoul
Procedure FechQuerTela(iForm: TsgForm);
var
  i : integer;
  Qry: TsgQuery;
begin
  //Fecha os Query's
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    for i := 0 to (ComponentCount - 1) do
    begin
      If (Components[i].ClassType = TsgQuery) then
      begin
        Qry := TsgQuery(iForm.Components[i]);
        //TsgQuery(Components[i]).DisableControls;  //30/05/2014 17:41 - Dá erro de memoria, mas seria bom...
        if Qry.Active then
        begin
          try    //Mesmo testando tudo, ainda dava erro como se não estivesse aberto a qry
            if TestDataSet(Qry) then
              Qry.Cancel;
            Qry.Close;
          except
          end;
        end;
      end;
    end;
  end;

  LimpMoniDataModu();
end;

//********** F I M   M O N I T O R  **************************************************
//******************************************************************************************

Function VeriSexo(Nome:String):Char;
var
  Aux : String;
begin
  if Pos(' ',Nome) > 0 then
    Aux := Copy(Nome,Pos(' ',Nome)-1,1)
  else
    Aux := Copy(Nome,Length(Nome),1);
  Aux := AnsiUpperCase(Aux);
  if (Aux = 'A') or (Aux = 'E')then
    Result := 'F'
  else
    Result := 'M';
end;

Function NomeDupl(TextSQL:String;Codi:Integer):Boolean;
//Objetivo: Alertar ao usuário quando a duplicação de nomes ou outros
begin
  Result := False;
  with DtmPoul.QryPlus do
  begin
    SQL.Clear;
    SQL.Add(TextSQL);
    Open;
    if Fields[0].AsInteger <> Codi then
      if RecordCount > 0 then
        if msgNao('Campo digitado já Existe : '+Fields[1].AsString+sgLn+'Deseja continuar?') then
          Result := True;
  end;
end;

Function SobrNome(Nome:String):String;
var
  i : byte;
begin
  Result := '';
  for i := Length(Nome) Downto 1 do
    Result := Result + Nome[i];
  if Pos(' ',Result) > 0 then
    Nome := Copy(Result,1,Pos(' ',Result)-1)
  else
    Nome := '';
  Result := '';
  for i := Length(Nome) Downto 1 do
    Result := Result + Nome[i];
end;

//Objetivo: Executar o SQL passado, e retornar se a Tabela está vazia ou não
Function TabeVazi(TextSQL:String):Boolean;
begin
  with DtmPoul.QryCalcPlus do
  begin
    Close;
    SQL.Clear;
    SQL.Add(TextSQL);
    Open;
    Result := IsEmpty;
  end;
end;

Procedure OrgaSele(Sele: String; iRchSele: TStringList; Iden: Boolean);
var
  j: Integer;
  Aux1, Aux2: String;

  //Identar os campos
  Function IdenCamp(Camp: String): Boolean;
  const NumePala = 14;
        TamaCopy = 06;
  type
    TPala = Record
      Nome: String;
      Espa: Integer;
    end;
  var
    ContPala, Posi: Integer;
    Auxi: String;
    Pala: array[1..NumePala] of TPala;
  begin
    Result := True;
    Pala[1].Nome := 'aSELECT';
    Pala[1].Espa := 0;
    Pala[2].Nome := 'FROM';
    Pala[2].Espa := 2;
    Pala[3].Nome := 'INNER';
    Pala[3].Espa := 04;
    Pala[4].Nome := 'LEFT';
    Pala[4].Espa := 04;
    Pala[5].Nome := 'WHERE';
    Pala[5].Espa := 2;
    Pala[6].Nome := ' AND ';
    Pala[6].Espa := 4;
    Pala[7].Nome := ' OR ';
    Pala[7].Espa := 4;
    Pala[8].Nome := 'GROUP BY';
    Pala[8].Espa := 2;
    Pala[9].Nome := 'ORDER BY';
    Pala[9].Espa := 2;
    Pala[10].Nome:= 'HAVING';
    Pala[10].Espa := 2;
    Pala[11].Nome:= 'WHEN';
    Pala[11].Espa := 2;
    Pala[12].Nome:= 'THEN';
    Pala[12].Espa := 4;
    Pala[13].Nome:= 'ELSE';
    Pala[13].Espa := 2;
    Pala[14].Nome := 'CROSS';
    Pala[14].Espa := 04;

    ContPala := 1;
    while (ContPala <= NumePala) do
    begin
      Auxi := AnsiUpperCase(Copy(Camp,TamaCopy,Length(Camp)-TamaCopy-01));
      Posi := Pos(Pala[ContPala].Nome, Auxi);
      if Posi > 0 then
      begin
        //FrmPOChCamp.RchSele.Lines.Add(Copy(Camp,01,Posi+TamaCopy-02));
        IdenCamp(Copy(Camp,01,Posi+TamaCopy-02));
        Delete(Camp,01,Posi+TamaCopy-02);
        Camp := Replicate(' ',Pala[ContPala].Espa)+Trim(Camp);
        ContPala := 1;
      end
      else
        //ContPala := NumePala;
        Inc(ContPala);
    end;

    if (Trim(Camp) <> '') then
      iRchSele.Add(Camp);
  end;

begin
  j := 0;
  iRchSele.Clear;
  if AnsiUpperCase(Copy(Trim(Sele),01,04)) = 'WITH' then
  begin
    iRchSele.Add(Copy(Sele, 01, Pos('(SELECT',Sele)+07));
    Sele := Copy(Sele,Pos('(SELECT',Sele)+07,Length(Sele)-7);
    iRchSele.Add(OrgaSQL(Sele));
    Aux1 := iRchSele.Text;
    OrgaSele(iRchSele[1], iRchSele, Iden);
    Aux2 := iRchSele.Text;
    iRchSele.Text := Aux1;
    iRchSele.Delete(1);
    iRchSele.Insert(1, Aux2);
    Sele := Copy(iRchSele[iRchSele.Count-1], Pos('SELECT', AnsiUpperCase(iRchSele[iRchSele.Count-1])), MaxInt);
    iRchSele[iRchSele.Count-1] := Copy(iRchSele[iRchSele.Count-1], 01, Pos('SELECT', AnsiUpperCase(iRchSele[iRchSele.Count-1]))-1);
    iRchSele.Add('');
  end;

  while j <= Length(Sele) do
  begin
    if Pos(',',Sele) > 0 then
    begin
      j := PosiProxVirg(Sele);
      if Iden then
        IdenCamp(Trim(Copy(Sele,01,j)))
      else
        iRchSele.Add(Trim(Copy(Sele,01,j)));
      Delete(Sele,01,j);
      j := 1;  //Caso o Sele estiver vazio (Length(Sele) = 0), sai porque o j i 1
    end
    else
    begin
      if Iden then
        IdenCamp(Trim(Sele))
      else
        iRchSele.Add(Trim(Sele));
      j := Length(Sele)+1;
    end;
  end;
end;

Procedure OrgaFrom(From: String; iRchFrom: TStringList);
var
  j : Integer;
  PosiCros, PosiLeft, PosiInne, PosiRigh: Integer;
begin
  j := 0;
  iRchFrom.Clear;
  while j <= Length(From) do
  begin
    PosiLeft := Pos(' LEFT',AnsiUpperCase(From));
    PosiInne := Pos(' INNER',AnsiUpperCase(From));
    PosiRigh := Pos(' RIGHT',AnsiUpperCase(From));
    PosiCros := Pos(' CROSS',AnsiUpperCase(From));
    if (PosiLeft + PosiInne + PosiRigh + PosiCros) > 0 then
    begin
      j := PosiLeft;
      if PosiLeft = 0 then
        j := (PosiLeft + PosiInne + PosiRigh + PosiCros);

      if (j > PosiInne) and (PosiInne > 0) then
        j := PosiInne;

      if (j > PosiRigh) and (PosiRigh > 0) then
        j := PosiRigh;

      if (j > PosiCros) and (PosiCros > 0) then
        j := PosiCros;

      iRchFrom.Add(Trim(Copy(From,01,j)));
      Delete(From,01,j);
      j := 1;  //Caso o Sele estiver vazio (Length(Sele) = 0), sai porque o j i 1
    end
    else
    begin
      iRchFrom.Add(Trim(From));
      j := Length(From)+1;
    end;
  end;
end;

// Verificar se existe mais usuários acessando a Tabe, retornando os possíveis usuários
Function ExisUsua(Tabe : String):String;
begin
  Result := '';
{  with DtmPoul.QryCalcPlus do
  begin
    SQL.Clear;
    SQL.Add('SELECT NomePess FROM '+Tabe+' INNER JOIN POCaPess ON '+Tabe+'.CodiUsua = POCaPess.CodiPess WHERE (CodiUsua <> 0) AND (CodiUsua <> '+IntToStr(GetPUsu())+') GROUP BY CodiUsua, NomePess');
    Open;
    if not(IsEmpty) then
    begin
      Result := 'Usuário(s):';
      While not(Eof) do
      begin
        Result := Result+sgLn+FieldByName('NomePess').AsString;
        Next;
      end;
    end;
  end;}
end;

//----> Pegar os Aviários onde o Lote está Alojado
function PegaAvia(Lote, Camp: String):String;
var
  vCodiLote: String;
begin
  Result := '';
  if PalaContem(Lote, 'IN') then
    vCodiLote := SubsPalaTudo(Lote, 'MPCaLote', 'MPCaAloj')
  else
    vCodiLote := '(MPCaAloj.CodiLote IN ('+Lote+'))';

  with DtmPoul.QryCalcPlus do
  begin
    SQL.Clear;
    SQL.Add('SELECT '+Camp);
    SQL.Add('FROM MPCaAloj INNER JOIN MPGeBox MPCaBox ON MPCaAloj.CodiBox = MPCaBox.CodiBox '+
                          'INNER JOIN MPGeAvia MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia '+
                          'INNER JOIN MPGeNucl MPCaNucl ON MPCaNucl.CodiNucl = MPCaAvia.CodiNucl '+
                          'INNER JOIN MPGeGran MPCaGran ON MPCaGran.CodiGran = MPCaNucl.CodiGran '+
                          'INNER JOIN MPGeLote MPCaLote ON MPCaAloj.CodiLote = MPCaLote.CodiLote '+
                          'LEFT JOIN POGePess Inte ON Inte.CodiPess = MPCaLote.CodiPess '+
                          'LEFT JOIN POGePess Resp ON Resp.CodiPess = MPCaAvia.CodRPess '+
                          'LEFT JOIN MPViLote Orig ON Orig.CodiLote = MPCaAloj.CodMLote');
    SQL.Add('WHERE '+vCodiLote+' AND (MPCaBox.AtivBox <> 0) AND (MPCAAloj.DataAloj = (SELECT MAX(DataAloj) FROM MPCaAloj Aloj WHERE (Aloj.CodiLote = MPCaAloj.CodiLote)))');
    SQL.Add('GROUP BY '+Camp);
    SQL.Add('ORDER BY '+Camp);
    Open;
    While not(Eof) do
    begin
      if Result = '' then
        Result := Fields[0].AsString
      else
        Result := Result+' | '+Fields[0].AsString;
      Next;
    end;
    Close;
  end;
end;

//----> Pegar os Aviários de Recria onde o Lote está Alojado
function PegaAvRe(Lote:String):String;
begin
  Result := '';
  with DtmPoul.QryCalcPlus do
  begin
    SQL.Clear;
    SQL.Add('SELECT MPCaAvia.CodiAvia, MPCaAvia.NomeAvia');
    SQL.Add('FROM MPCaAloj INNER JOIN MPCaBox ON MPCaAloj.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia');
    SQL.Add('WHERE (MPCaAloj.CodiLote IN ('+Lote+')) AND (DataAloj = (SELECT MIN(Aloj.DataAloj) FROM MPCaAloj Aloj WHERE (Aloj.CodiLote = MPCaAloj.CodiLote)))');
    SQL.Add('GROUP BY MPCaAvia.CodiAvia, MPCaAvia.NomeAvia');
    SQL.Add('ORDER BY MPCaAvia.NomeAvia');
    Open;
    While not(Eof) do
    begin
      if Result = '' then
        Result := FieldByName('NomeAvia').AsString
      else
        Result := Result+' | '+FieldByName('NomeAvia').AsString;
      Next;
    end;
    Close;
  end;
end;

//----> Pegar os Integrados onde o Lote está Alojado
function PegaInte(Lote:String):String;
begin
  Result := '';
  with DtmPoul.QryCalcPlus do
  begin
    SQL.Clear;
    SQL.Add('SELECT POCaPess.CodiPess, NomePess');
    SQL.Add('FROM MPCaAloj INNER JOIN MPCaBox ON MPCaAloj.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia INNER JOIN POCaPess ON MPCaAvia.CodiPess = POCaPess.CodiPess'+' INNER JOIN MPCaLote ON ((MPCaAloj.CodiLote = MPCaLote.CodiLote) AND (MPCaAloj.DataAloj = MPCaLote.UltiLote))');
    SQL.Add('WHERE (MPCaAloj.CodiLote IN ('+Lote+')) AND (POCaPess.IntePess <> 0) AND (MPCaBox.AtivBox <> 0)');
    SQL.Add('GROUP BY POCaPess.CodiPess, NomePess');
    SQL.Add('ORDER BY NomePess');
    Open;
    While not(Eof) do
    begin
      if Result = '' then
        Result := Result+FieldByName('NomePess').AsString
      else
        Result := Result+' | '+FieldByName('NomePess').AsString;
      Next;
    end;
    Close;
  end;
end;

//---> Pega maior Idade até a data Passada
Function MaioIdad(Lote: String; Data: TDateTime):Real;
begin
  Result := CalcReal('SELECT MAX(IdadCole) FROM MPCaCole WHERE (MPCaCole.CodiLote IN ('+Lote+')) AND (DataCole <= '+FormDataSQL(Data)+')');
  if (Result = 0) or (Result = 99) then
    Result := CalcReal('SELECT MAX(IdadCole) FROM POCaCole WHERE (POCaCole.CodiLote IN ('+Lote+')) AND (DataCole <= '+FormDataSQL(Data)+')');
end;

//Caso seja diário e não seja fechamento de semana, retorna o fechamento
//iDiarPesa: Pesagem diária
function ArreIdadPesa(Idad: Real; iDiarPesa: Boolean): Real;
begin
  if (not iDiarPesa) and (Frac(Idad) <> 0) then
    Result := Trunc(Idad) + 1
  else
    Result := Idad;
  Result := MudaReal('0.0',Result);
end;

//---> Pega Idade de Encerramento do Lote Passado
Function IdadEnce(CodiLote:String):Real;
begin
  Result := IdadLote(CalcData('SELECT MIN(ColeLote) FROM MPCaLote WHERE (CodiLote IN ('+CodiLote+'))'), CalcData('SELECT MAX(EnceLote) FROM MPCaLote WHERE (CodiLote IN ('+CodiLote+'))'));
end;

//---> Pega Idade do Lote, com base no ColeLote passado
Function IdadLote(ColeLote, Data: TDateTime; PeriIdad: Real = 0):Real;
begin
  if PeriIdad = 0 then
    PeriIdad := GetPPerIdad;
  if PeriIdad = 0 then
    PeriIdad := 1;
  Result := ArreReal(DiveZero((Data - (ColeLote-1)),PeriIdad),1);
end;

//---> Pega Data atual, com base na Idade e no ColeLote passado
Function DataCole(ColeLote: TDateTime; Idad: Real; PeriIdad: Real = 0):TDateTime;
var
  Auxi : Integer;
  Dife : String;
begin
  if PeriIdad = 0 then
    PeriIdad := GetPPerIdad;
  Auxi := 0;
  Dife := FormatFloat('0.0',Idad - Int(Idad));
  if Dife = FormatFloat('0.0',0.0) then
    Auxi := 0
  else if Dife = FormatFloat('0.0',0.1) then
    Auxi := 1
  else if Dife = FormatFloat('0.0',0.3) then
    Auxi := 2
  else if Dife = FormatFloat('0.0',0.4) then
    Auxi := 3
  else if Dife = FormatFloat('0.0',0.6) then
    Auxi := 4
  else if Dife = FormatFloat('0.0',0.7) then
    Auxi := 5
  else if Dife = FormatFloat('0.0',0.9) then
    Auxi := 6;
  Result := ColeLote - 1 + ((INT(Idad) * PeriIdad)+ Auxi);
end;

//Importa arquivo
function ImpoArqu(Arqu, Tabe, Camp, Fix1, Val1, Fix2, Val2: String): Boolean;
var
  ArquPesq : TextFile;
  Linh : String;
  inTran: Boolean;
begin
  Result := False;
  if not FileExists(ArquValiEnde(Arqu)) then
  begin
    msgOk('Arquivo não Existe! ('+ArquValiEnde(Arqu)+')');
    Exit;
  end;

  Application.CreateForm(TFrmPOGeAgCa,FrmPOGeAgCa);
  FrmPOGeAgCa.Caption := 'Aguarde, importando...';
  FrmPOGeAgCa.Show;
  FrmPOGeAgCa.GauAgua.MaxValue := CalcLinhArquText(Arqu);
  inTran := GetPADOConn.InTransaction;
  try
    if not inTran then
      GetPADOConn.sgBeginTrans(False);

    AssignFile(ArquPesq, Arqu);
    Reset(ArquPesq);                                //Prepara para Leitura
    while not(EOF(ArquPesq)) do
    begin
      ReadLn(ArquPesq, Linh);
      //InseDadoTabe(Tabe,[Camp, QuotedStr(Linh)],'');
      ExecSQL_('INSERT INTO '+ Tabe + '('+Camp+ SeStri(Trim(Fix1)<>'',', '+Fix1,'')
                                              + SeStri(Trim(Fix2)<>'',', '+Fix2,'')
                                    + ') VALUES (' + QuotedStr(Linh)
                                              + SeStri(Trim(Fix1)<>'',', '+QuotedStr(Val1),'')
                                              + SeStri(Trim(Fix2)<>'',', '+QuotedStr(Val2),'')
                                    + ')');
      if PlusUni.Cancela then Exit;
    end;
    if not inTran then
      GetPADOConn.sgCommitTrans;
    CloseFile(ArquPesq);
    Result := True;
  finally
    FrmPOGeAgCa.Free;
    if not inTran then
      GetPADOConn.sgRollbackTrans;
  end;
end;

// Retorna o Percentual de espaço livre no disco rígido
Function PercLivr(Driv :Byte): Real;
var
  Livr,Tota : Int64;
begin
  Livr := DiskFree(Driv);
  Tota := DiskSize(Driv);
  Result := ((Livr * 100) / Tota);
end;


// Gerar Senha para usuário Supervisor do Sistema
function GeraPega(Data : TDateTime): String;
var
  i, Soma, Dia_Sema : Integer;
  DataStri : String;
begin
  Soma := 0;
  Dia_Sema := DayOfWeek(Data);
  DataStri := FormatDateTime('DDMMYYYY',Data);
  for i := 1 to 8 do
    Soma := Soma + (StrToInt(Copy(DataStri,i,1)) * Dia_Sema);
  Result := IntToStr(Soma*(1000-Dia_Sema));
  Result := Copy(Result,02,03);
end;

// Retorna a(s) Granja(s) em que o Funcionários esta Alocado no MPCaTrFu (Última)
Function PessGran(Func: String):String;
var
  i : Integer;
begin
  Result := '';
  with DtmPoul.QryCalc do
  begin
    SQL.Clear;
    SQL.Add('SELECT MPCaGran.CodiGran, NomeGran');
    SQL.Add('FROM MPCaTrFu INNER JOIN MPCaBox ON MPCaTrFu.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia INNER JOIN MPCaNucl ON MPCaAvia.CodiNucl = MPCaNucl.CodiNucl '+'INNER JOIN MPCaGran ON MPCaNucl.CodiGran = MPCaGran.CodiGran');
    SQL.Add('WHERE (MPCaTrFu.CodiPess = '+RetoZero(Func)+') AND (DataTrFu = (SELECT MAX(DataTrFu) FROM MPCaTrFu WHERE MPCaTrFu.CodiPess = '+RetoZero(Func)+'))');
    SQL.Add('GROUP BY MPCaGran.CodiGran, NomeGran');
    SQL.Add('ORDER BY MPCaGran.CodiGran, NomeGran');
    Open;
    Result := Fields[1].AsString;
    Next;
    for i := 2 to RecordCount do
    begin
      if i = RecordCount then
        Result := Result + ' e ' + Fields[1].AsString
      else
        Result := Result + ', ' + Fields[1].AsString;
      Next;
    end;
  end;
end;

// Retorna a(s) Granja(s) em que o Funcionários esta Alocado na Data Específica
Function FuncDaGr(Func: String; Data: TDateTime):String;
var
  i : Integer;
begin
  Result := '';
  with DtmPoul.QryCalc do
  begin
    SQL.Clear;
    SQL.Add('SELECT MPCaGran.CodiGran, NomeGran');
    SQL.Add('FROM MPCaTrFu INNER JOIN MPCaBox ON MPCaTrFu.CodiBox = MPCaBox.CodiBox INNER JOIN MPCaAvia ON MPCaBox.CodiAvia = MPCaAvia.CodiAvia INNER JOIN MPCaNucl ON MPCaAvia.CodiNucl = MPCaNucl.CodiNucl '+'INNER JOIN MPCaGran ON MPCaNucl.CodiGran = MPCaGran.CodiGran');
    SQL.Add('WHERE (MPCaTrFu.CodiPess = '+Func+') AND (DataTrFu = '+FormDataSQL(Data)+')');
    SQL.Add('GROUP BY MPCaGran.CodiGran, NomeGran');
    SQL.Add('ORDER BY MPCaGran.CodiGran, NomeGran');
    Open;
    Result := Fields[1].AsString;
    Next;
    for i := 2 to RecordCount do
    begin
      if i = RecordCount then
        Result := Result + ' e ' + Fields[1].AsString
      else
        Result := Result + ', ' + Fields[1].AsString;
      Next;
    end;
  end;
end;

// Retorna o(s) Incubatórios(s) em que o Funcionário esta Alocado no INCaTrIn
Function FuncIncu(Func: String):String;
var
  i : Integer;
begin
  Result := '';
  with DtmPoul.QryCalc do
  begin
    SQL.Clear;
    SQL.Add('SELECT INCaIncu.CodiIncu, NomeIncu');
    SQL.Add('FROM INCaTrIn INNER JOIN INCaIncu ON INCaTrIn.CodiIncu = INCaIncu.CodiIncu ');
    SQL.Add('WHERE (INCaTrIn.CodiPess = '+Func+') AND (DataTrIn = (SELECT MAX(DataTrIn) FROM INCaTrIn WHERE INCaTrIn.CodiPess = '+Func+'))');
    SQL.Add('GROUP BY INCaIncu.CodiIncu, NomeIncu');
    SQL.Add('ORDER BY INCaIncu.CodiIncu, NomeIncu');
    Open;
    Result := Fields[1].AsString;
    Next;
    for i := 2 to RecordCount do
    begin
      if i = RecordCount then
        Result := Result + ' e ' + Fields[1].AsString
      else
        Result := Result + ', ' + Fields[1].AsString;
      Next;
    end;
  end;
end;

// Retorna o(s) Incubatórios(s) em que o Funcionário esta Alocado na Data Específica
Function FuncDaIn(Func: String; Data: TDateTime):String;
var
  i : Integer;
begin
  Result := '';
  with DtmPoul.QryCalc do
  begin
    SQL.Clear;
    SQL.Add('SELECT INCaIncu.CodiIncu, NomeIncu');
    SQL.Add('FROM INCaTrIn INNER JOIN INCaIncu ON INCaTrIn.CodiIncu = INCaIncu.CodiIncu ');
    SQL.Add('WHERE (INCaTrIn.CodiPess = '+Func+') AND (DataTrIn = '+FormDataSQL(Data)+')');
    SQL.Add('GROUP BY INCaIncu.CodiIncu, NomeIncu');
    SQL.Add('ORDER BY INCaIncu.CodiIncu, NomeIncu');
    Open;
    Result := Fields[1].AsString;
    Next;
    for i := 2 to RecordCount do
    begin
      Result := Result + Fields[1].AsString + ', ';
      Next;
    end;
    Result := TrocVirg(Result);
  end;
end;

//---> Realiza os cálculos do Lote passado para os Itens/Sub-Itens Calculados
//---> Rela: Emite-se o relatório de inconsistências. Ence: Calculo os itens de encerramento
  //---> Realiza os cálculos do Lote passado para os Itens/Sub-Itens Calculados
  //---> Rela: Emite-se o relatório de inconsistências. Ence: Calculo os itens de encerramento
procedure CampCalc(Lote, IdadInic, IdadFina, NomeLote: String; SubI: Integer;
                   Rela, Recr, Prod, Incu, Ence: Boolean;
                   iCodiAloj: Integer = 0;
                   iComp: TObject = nil);
var
  Valo, ProdLote : Real;
  Wher, ValoStri, Camp : String;
  Form : String;
  QryCole, QryIdad, QrySiSt : TsgQuery;
  DataInic, {ColeLote,} Data: TDateTime;
  vMensagem: String;
begin
  vMensagem := '';
  Lote := RetoZero(Lote);
  QryIdad := DmPlus.CriaQuery(iComp, 'QryCampCalIdad');
  QrySiSt := DmPlus.CriaQuery(iComp, 'QryCampCalSiSt');
  QryCole := DmPlus.CriaQuery(iComp, 'QryCampCalCole');
  try
    {$ifdef ERPUNI}
    {$else}
      FrmPOGeAgCa := TFrmPOGeAgCa.Create(nil);
      FrmPOGeAgCa.Caption := NomeLote;
      FrmPOGeAgCa.Show;
    {$endif}

    Wher := '';
    Wher := Wher + SeStri(Recr,' OR (RecrSiSt <> 0)','');
    Wher := Wher + SeStri(Prod,' OR (ProdSiSt <> 0)','');
    Wher := Wher + SeStri(Incu,' OR (IncuSiSt <> 0)','');
    Wher := Wher + SeStri(Ence,' OR (EnceSiSt <> 0)','');
    if Wher <> '' then
      Wher := 'AND ('+Copy(Wher,05,Length(Wher)-04)+')';

    //Saber as Idades do Lote para o Cálculo
    QryIdad.SQL.Clear;
    QryIdad.SQL.Add('SELECT IdadCole AS Idad, DataCole, ChavCole, ProdLote');
    QryIdad.SQL.Add('FROM MPCaCole INNER JOIN MPCaLote ON MPCaCole.CodiLote = MPCaLote.CodiLote');
    QryIdad.SQL.Add('WHERE (MPCaCole.CodiLote = '+Lote+
                    ') AND (IdadCole BETWEEN '+FormPont(IdadInic)+' AND '+FormPont(IdadFina)+')');
    if iCodiAloj <> 0 then
      QryIdad.SQL.Add('AND (MPCaCole.CodiAloj = '+IntToStr(iCodiAloj)+')');
    QryIdad.SQL.Add('GROUP BY IdadCole, DataCole, ChavCole, ProdLote');
    QryIdad.SQL.Add('ORDER BY IdadCole, ChavCole');
    QryIdad.Open;
    DataInic := QryIdad.FieldByName('DataCole').AsDateTime;
    Data     := QryIdad.FieldByName('DataCole').AsDateTime;

    ProdLote := CalcReal('SELECT ProdLote FROM MPCaLote WHERE (CodiLote = '+Lote+')', iComp);
//    ColeLote := CalcData('SELECT ColeLote FROM MPCaLote WHERE (CodiLote = '+Lote+')', iComp);

{    QryIdad.SQL.Clear;
    QryIdad.SQL.Add('SELECT IdadIdad AS Idad');
    QryIdad.SQL.Add('FROM POCaIdad');
    QryIdad.SQL.Add('WHERE (IdadIdad BETWEEN '+FormPont(IdadInic)+' AND '+FormPont(IdadFina)+')');
    QryIdad.SQL.Add('ORDER BY IdadIdad');
    QryIdad.Open;
    DataInic := DataCole(ColeLote, QryIdad.FieldByName('Idad').AsFloat);}

    //Pega-se os Sub-Itens calculados  ---> que tenham pelo menos um sub-item no Stardard daquele lote
    QrySiSt.SQL.Clear;
    QrySiSt.SQL.Add('SELECT SQL_SiSt, MPCaMvIs.CodiMvIs, RecrSist, ProdSiSt, NomeItSt, NomeSiSt, IncuSiSt, DiarSiSt, EnceSiSt, ZeroSiSt, MiniSiSt, MaxiSiSt, TipoSiSt');
    QrySiSt.SQL.Add('FROM MPCaSiSt INNER JOIN MPCaMvIS ON MPCaSiSt.CodiSiSt = MPCaMvIS.CodiSiSt INNER JOIN MPCaItSt ON MPCaMvIs.CodiItSt = MPCaItSt.CodiItSt');
    QrySiSt.SQL.Add('WHERE (EstiSiSt = ''C'') AND (AtivSiSt <> 0) AND (MPCaMvIS.CodiMvIs <> 0) '+Wher);
    if SubI <> 0 then
      QrySiSt.SQL.Add(' AND (MPCaMvIs.CodiMvIs = '+IntToStr(SubI)+')')
    else
      QrySiSt.SQL.Add('');
    QrySiSt.SQL.Add('ORDER BY OrdeItSt, OrdeMvIs');
    QrySiSt.Open;

    {$ifdef ERPUNI}
      ExibProgPrin(0, CalcInte('SELECT COUNT(*) '+QrySiSt.SQL.Strings[1]+' '+QrySiSt.SQL.Strings[2]+' '+QrySiSt.SQL.Strings[3],iComp) * SeInte(QryIdad.RecordCount > 0, QryIdad.RecordCount, 1));
    {$else}
      FrmPOGeAgCa.GauAgua.MaxValue := CalcInte('SELECT COUNT(*) '+QrySiSt.SQL.Strings[1]+' '+QrySiSt.SQL.Strings[2]+' '+QrySiSt.SQL.Strings[3],iComp) * SeInte(QryIdad.RecordCount > 0, QryIdad.RecordCount, 1);
    {$endif}

    //Prepara para gravação
    QryCole.SQL.Clear;
    QryCole.SQL.Add('SELECT CodiCole FROM MPCaCole');
    QryCole.SQL.Add('WHERE (CodiLote = '+Lote+')');
    QryCole.SQL.Add('');
    if iCodiAloj <> 0 then
      QryCole.SQL.Add('AND (MPCaCole.CodiAloj = '+IntToStr(iCodiAloj)+')');

    // Passa Idade a Idade
    while not(QryIdad.Eof) do
    begin
      QrySiSt.First;
      // Passa o Sub-Item em Todas as Idades do Lote
      while not(QrySiSt.Eof) do
      begin
        try
          Form := SubsPalaTudo(QrySiSt.FieldByName('SQL_SiSt').AsString, 'SELECT MAX(MPCaLote.CodiStan) FROM MPCaLote WHERE (CodiLote = :Lote)'
                                                                       , 'SELECT MAX(MPCaLote.CodiStan) FROM MPCaLote WHERE (CodiLote = '+Lote+')');
          Form := SubsPalaTudo(Form, 'FROM MPCaLote WHERE (CodiLote = :Lote)'
                                   , 'FROM MPCaLote WHERE (CodiLote = '+Lote+')');
          if iCodiAloj <> 0 then
          begin
            Form := SubsPalaTudo(Form, ':LOTE',Lote+' AND (MPCaCole.CodiAloj = '+IntToStr(iCodiAloj)+')');
            Form := SubsPalaTudo(Form, 'Pesa) FROM MPCaPesa WHERE (CodiLote', 'MvPb) FROM MPCaMvPB INNER JOIN MPCaPesa ON MPCaMvPB.CodiPesa = MPCaPesa.CodiPesa INNER JOIN MPCaAloj MPCaCole ON MPCaCole.CodiBox = MPCaMvPb.CodiBox AND MPCaCole.CodiLote = MPCaPesa.CodiLote WHERE (MPCaPesa.CodiLote');
          end
          else
            Form := SubsPalaTudo(Form,':LOTE',Lote);
          if GetPBas() = 3 then
            Form := SubsPalaTudo(Form,'IDADCOLE','ROUNDDEC(IDADCOLE,03)');

          ExibMensHint(NomeLote + ' ('+FormatFloat('#,##0.0',QryIdad.FieldByName('Idad').AsFloat)+' - '+QrySiSt.FieldByName('NomeSiSt').AsString+')');
          {$ifdef ERPUNI}
          {$else}
            FrmPOGeAgCa.Caption := NomeLote + ' ('+FormatFloat('#,##0.0',QryIdad.FieldByName('Idad').AsFloat)+' - '+QrySiSt.FieldByName('NomeSiSt').AsString+')';
          {$endif}
          // [Caso a Idade seja de um dia (Ex. 1,1) e o Item seja diario]                                                                                      OU [caso a idade seja do período (Ex. 2) (Independete se o ítem é diário ou não)]                           OU [o seja um encerramento], aí pode-se calcular o campo
          if ((QryIdad.FieldByName('Idad').AsFloat <> Int(QryIdad.FieldByName('Idad').AsFloat)) and (QrySiSt.FieldByName('DiarSiSt').Value <> 0) OR (QryIdad.FieldByName('Idad').AsFloat = Int(QryIdad.FieldByName('Idad').AsFloat)) OR (QrySiSt.FieldByName('EnceSiSt').Value <> 0)) then
          begin
            // [Se a Idade for menor que a Produção e o Item for Recria]                                                                                     OU [Se a idade for maior ou igual a Produção e o item for (produção ou Incubatório)]                                                                                                   OU [Seja um Encerramento]
            if ((QryIdad.FieldByName('Idad').AsFloat < ProdLote) and (QrySiSt.FieldByName('RecrSiSt').Value <> 0)) or ((QryIdad.FieldByName('Idad').AsFloat >= ProdLote) and (QrySiSt.FieldByName('ProdSiSt').Value <> 0) or (QrySiSt.FieldByName('IncuSiSt').Value <> 0) OR (QrySiSt.FieldByName('EnceSiSt').Value <> 0)) then
            begin
              try
                //Data := DataCole(ColeLote,QryIdad.FieldByName('Idad').AsFloat);
                Data := QryIdad.FieldByName('DataCole').AsDateTime;

                Valo := 1;
                if QrySiSt.FieldByName('TipoSiSt').AsString = 'C' then
                begin
                  ValoStri := QuotedStr(CalcStri(SubsPalaTudo(SubsPalaTudo(
                                                 SubsPalaTudo(SubsPalaTudo(Form,':IDAD',FormPont(QryIdad.FieldByName('Idad').AsString)),
                                                                                ':DATAINIC',FormDataSQL(Data)),
                                                                                ':DATAFINA',FormDataSQL(Data)),
                                                                                ':DATA',FormDataSQL(Data))
                                                                                , iComp));
                  Camp     := 'ValoCole';
                end
                else
                begin
                  Valo := CalcReal(SubsPalaTudo(SubsPalaTudo(
                                   SubsPalaTudo(SubsPalaTudo(Form,':IDAD',FormPont(QryIdad.FieldByName('Idad').AsString)),
                                                                  ':DATAINIC',FormDataSQL(Data)),
                                                                  ':DATAFINA',FormDataSQL(Data)),
                                                                  ':DATA',FormDataSQL(Data))
                                                                  , iComp);
                  if QrySiSt.FieldByName('TipoSiSt').AsString = 'D' then
                  begin
                    ValoStri := FormDataSQL(Valo);
                    Camp     := 'TimeCole';
                  end
                  else
                  begin
                    ValoStri := FormNumeSQL(Valo);
                    Camp     := 'NumeCole';
                  end;
                end;

                // [Permita zero ou o Valor seja diferente de zero] e [Esteja entre o Mínimo e o Máximo]
                if ((QrySiSt.FieldByName('ZeroSiSt').Value <> 0) OR (Valo <> 0)) AND
                   (((QrySiSt.FieldByName('MiniSiSt').AsFloat+QrySiSt.FieldByName('MaxiSiSt').AsFloat)=0) or  //Minimo+Maximo = 0
                    ((Valo >= QrySiSt.FieldByName('MiniSiSt').AsFloat) AND (Valo <= QrySiSt.FieldByName('MaxiSiSt').AsFloat))) then
                begin
                  QryCole.SQL.Strings[2] := 'AND (IdadCole = '+FormNumeSQL(QryIdad.FieldByName('Idad').AsFloat)+
                                          ') AND (CodiMvIs = '+ IntToStr(QrySiSt.FieldByName('CodiMvIs').AsInteger)+')';
                  QryCole.Open;
                  if QryCole.IsEmpty then
                  begin
                    InseDadoTabe('MPCaCole',
                                ['CodiLote',Lote,
                                 'CodiMvIs',IntToStr(QrySiSt.FieldByName('CodiMvIs').AsInteger),
                                 'CodiAloj',SeStri(iCodiAloj=0,'NULL',IntToStr(iCodiAloj)),
                                 'IdadCole',FormNumeSQL(QryIdad.FieldByName('Idad').AsFloat),
                                 'DataCole',FormDataStri(Data),
                                 'ChavCole',QuotedStr(QryIdad.FieldByName('ChavCole').AsString),
                                 'MarcCole','0',
                                 'CodiUsua','0',
                                 Camp,      ValoStri
                                ],'', False, iComp);
                  end
                  else
                  begin
                    AlteDadoTabe('MPCaCole',
                                 [ Camp, ValoStri,
                                  'ChavCole',QuotedStr(QryIdad.FieldByName('ChavCole').AsString)
                                 ],'WHERE (CodiCole = '+IntToStr(QryCole.FieldByName('CodiCole').AsInteger)+')', False, iComp);
                  end;

                  QryCole.Close;
                end
                else  //Caso o valor calculado seja Zero e não permite zero, apaga o valor antigo
                  ExecSQL_('DELETE FROM MPCaCole WHERE (CodiLote = '+Lote+
                                                ') AND (IdadCole = '+FormNumeSQL(QryIdad.FieldByName('Idad').AsFloat)+
                                                ') AND (CodiMvIs = '+IntToStr(QrySiSt.FieldByName('CodiMvIs').AsInteger)+')'+
                            SeStri(iCodiAloj=0,'','AND (CodiAloj = '+IntToStr(iCodiAloj)+')'), iComp);
              except
                //Caso ocorreu algum erro com o campo, apaga-se o mesmo, Linha identica acima
                ExecSQL_('DELETE FROM MPCaCole WHERE (CodiLote = '+Lote+
                                              ') AND (IdadCole = '+FormNumeSQL(QryIdad.FieldByName('Idad').AsFloat)+
                                              ') AND (CodiMvIs = '+IntToStr(QrySiSt.FieldByName('CodiMvIs').AsInteger)+')'+
                          SeStri(iCodiAloj=0,'','AND (CodiAloj = '+IntToStr(iCodiAloj)+')'), iComp);
              end;
            end;
          end;
        except
          on E: Exception do
             vMensagem := E.Message;
        end;
        if vMensagem <> '' then
        begin
          msgRaiseTratada(vMensagem, 'Problema no Sub-Item: '+QrySiSt.FieldByName('NomeSiSt').AsString+sgLn+sgLn+
                                     vMensagem);
          vMensagem := '';
        end;
        {$ifdef ERPUNI}
           if ExibProgPrin() then Exit;
        {$else}
          if PlusUni.Cancela(FrmPOGeAgCa) then Exit;
        {$endif}
        QrySiSt.Next;
      end;
      QryIdad.Next;
    end;
    //COLETA ==> CUSTOS
    if (GetPSis() = 3) or (GetPSis() = 30) then
      AtuaColeCust(Lote, DataInic, Data, iComp);
    //COLETA ==> AMBIENTES
    if ((GetPSis() = 1) or (GetPSis() = 2) or (GetPSis() = 20) or (GetPSis() = 81)) and
       (Prod or Incu) and
       ((SubI = 0) or (QrySiSt.FieldByName('DiarSiSt').AsInteger <> 0)) then
      ColeAmbi(StrToInt(Lote), DataInic, Data);

  finally
    QryIdad.Close;
    QryIdad.Free;
    QrySiSt.Close;
    QrySiSt.Free;
    QryCole.Close;
    QryCole.Free;
    {$ifdef ERPUNI}
    {$else}
      FreeAndNil(FrmPOGeAgCa);
    {$endif}
    if Rela then  //Caso seja para emitir o Relatório de Inconsistências
    begin
{      if MemValo.Lines.Count > 3 then
      begin
        Screen.Cursor := crDefault;
        Valo := Confirma('Escolha a opção para o Relatório de Inconsistência do Lote '+NomeLote+'!!!','&Visualiza','&Imprime','&Cancela',3,5);
        if Valo < 3 then  //Cancelar
        begin
          try
            FrmPOReMost := TFrmPOReMost.Create(Nil);
            FrmPOReMost.RchMost.Lines.Add(MemValo.Text);
            FrmPOReMost.QreRela.ReportTitle := 'Inconsistências nos Cálculos';
            FrmPOReMost.LblNome.Caption := 'Inconsistências nos Cálculos';
            if Valo = 1 then              //Visualizar
                FrmPOReMost.QreRela.PreviewModal
            else                          //Imprimir
              FrmPOReMost.QreRela.Print;
          finally
            FrmPOReMost.Free;
          end;
        end;
      end;}
    end;
  end;
end;

//===> Mensagem Padrão para o Sair
Function Sair:Boolean;
begin
  Result := GetPBasTC() or msgSim('Deseja  Realmente  Sair?');
end;

//Pega Sobrenome de um Nome passado
Function PegaSobr(Nome:String):String;
var
  i : Integer;
begin
  Result := '';
  //Inverto o Nome Ex. Sidiney Tartari => iratraT yenidiS
  for i := Length(Nome) downto 1 do
    Result := Result + Nome[i];
  //Copio até o Primeiro espaço
  if Pos(' ',Result) > 0 then
  begin
    Nome := Copy(Result,01,Pos(' ',Result)-1);  //Sem o Espaço
    Result := '';
    //Volto o Nome ao normal
    for i := Length(Nome) downto 1 do
      Result := Result + Nome[i];
  end
  else  //caso não tenha espaço, não tem Sobrenome
    Result := '';
end;

//Copiar os Graficos do Lote origem para o destino
//Precisa-se dos NomeOrig e NomeDest, porque é pelos nomes que sabe-se qual são os seus gráficos
procedure TranGraf(NomeOrig, NomeDest, CodiOrig, CodiDest, StanOrig, StanDest:String);
begin
  With DtmPoul do
  begin
    QryCalcPlus.SQL.Clear;
    QryCalcPlus.SQL.Add('SELECT CodiGraf FROM MPCaGraf WHERE ('+FormUppeSQL+'('+FormLeftSQL+'(NomeGraf,'+IntToStr(Length(NomeDest))+')) = '+QuotedStr(AnsiUpperCase(NomeDest))+')');
    QryCalcPlus.Open;
    if not(QryCalcPlus.IsEmpty) then
    begin
      if msgNao('O Lote '+NomeDest+' possui '+IntToStr(QryCalcPlus.RecordCount)+' gráfico(s), deseja mantê-los?') then
      begin
        While not(QryCalcPlus.Eof) do
        begin
          ExecSQL_('DELETE FROM MPCaMvGr WHERE (CodiGraf = '+RetoZero(QryCalcPlus.Fields[0].AsString)+')');
          QryCalcPlus.Next;
        end;
        ExecSQL_('DELETE FROM MPCaGraf WHERE ('+FormUppeSQL+'('+FormLeftSQL+'(NomeGraf,'+IntToStr(Length(NomeDest))+')) = '+QuotedStr(AnsiUpperCase(NomeDest))+')');
      end;
    end;
    try
      Application.CreateForm(TFrmPOGeAgua,FrmPOGeAgua);
      FrmPOGeAgua.Caption := 'Aguarde, Copiando Gráficos...';
      FrmPOGeAgua.Show;

      QryCalcPlus.SQL.Clear;
      QryCalcPlus.SQL.Add('SELECT * FROM MPCAGRAF WHERE ('+FormUppeSQL+'('+FormLeftSQL+'(NOMEGRAF,'+IntToStr(Length(NomeOrig))+')) = '+QuotedStr(AnsiUpperCase(NomeOrig))+')');
      QryCalcPlus.Open;
      FrmPOGeAgua.GauAgua.MaxValue := QryCalcPlus.RecordCount;

      QryAuxiliar.SQL.Clear;
      QryAuxiliar.SQL.Add('SELECT * FROM MPCAGRAF WHERE (CODIGRAF = 0)'); //(1=2)
      QryAuxiliar.Open;

      QryPlus.SQL.Clear;
      QryPlus.SQL.Add('SELECT * FROM MPCAMVGR WHERE (CODIMVGR = 0)'); //(1=2)
      QryPlus.Open;
      // Copia-se os Gráficos
      While not(QryCalcPlus.Eof) do
      begin
        QryAuxiliar.Append;
        GravRegi(QryCalcPlus, QryAuxiliar, 1);
        QryAuxiliar.FieldByName('NomeGraf').AsString  := SubsPala(QryCalcPlus.FieldByName('NomeGraf').AsString,NomeOrig,NomeDest);
        QryAuxiliar.FieldByName('TituGraf').AsString  := SubsPala(QryCalcPlus.FieldByName('TituGraf').AsString,NomeOrig,NomeDest);
        TratErroBanc(QryAuxiliar);

        // Seleciona-se as Séries para serem copiadas
        QryPoul.SQL.Clear;
        QryPoul.SQL.Add('SELECT * FROM MPCAMVGR');
        QryPoul.SQL.Add('WHERE CodiGraf = '+RetoZero(QryCalcPlus.FieldByName('CodiGraf').AsString));
        QryPoul.Open;
        // Copia-se as Séries
        While not(QryPoul.Eof) do
        begin
          QryPlus.Append;
          GravRegi(QryPoul, QryPlus, 1);
          QryPlus.FieldByName('CodiGraf').AsInteger := QryAuxiliar.FieldByName('CodiGraf').AsInteger;
          QryPlus.FieldByName('NomeMvGr').AsString  := SubsPala(QryPoul.FieldByName('NomeMvGr').AsString,NomeOrig,NomeDest);
          QryPlus.FieldByName('SQL_MvGr').AsString  := SubsPala(SubsPala(QryPoul.FieldByName('SQL_MvGr').AsString,'CodiLote = '+CodiOrig,'CodiLote = '+CodiDest),'CodiStan = '+StanOrig,'CodiStan = '+StanDest);
          TratErroBanc(QryPlus);

          QryPoul.Next;
        end;
        QryPoul.Close;
        FrmPOGeAgua.GauAgua.AddProgress(1);
        QryCalcPlus.Next;
      end;
    finally
      QryCalcPlus.Close;
      QryPoul.Close;
      QryPlus.Close;
      QryAuxiliar.Close;
      FrmPOGeAgua.Free;
    end;
  end;
end;

//Objetivo: Fazer os lançamentos conforme parametrizado dos valores dos custos para
//          Coleta de dados.
Procedure AtuaCustCole(CodiLote:String);
var
  IdadCole : Real;
  QryCole, QryCust : TsgQuery;
begin
  QryCust := TsgQuery.Create(Nil);
  QryCole := TsgQuery.Create(Nil);
  try
    //====================================================
    //CUSTOS (MOVIMENTO) -->  COLETA DE DADOS
    //Somente os valores do lote específico, as contas que tenham Ítem/Sub-Ítem e os sub-ítens de encerramento (Por que é lançado o acumulado desta conta) e que seja para lançar dos Movimentos de Custos para a Coleta de Dados
    QryCust.SQL.Clear;
    QryCust.SQL.Add('SELECT MPCaLote.CodiLote, MPCaLote.EnceLote, MPCaPlan.CuCoPlan, SUM(CalcMvCu) AS Valo');
    QryCust.SQL.Add('FROM MPCaMvCu INNER JOIN MPCaPlan ON MPCaMvCu.CodiPlan = MPCaPlan.CodiPlan INNER JOIN MPCaMvIs ON MPCaPlan.CuCoPlan = MPCaMvIs.CodiMvIs INNER JOIN MPCaSiSt ON MPCaMvIs.CodiSiSt = MPCaSiSt.CodiSiSt '+'INNER JOIN MPCaLote ON MPCaLote.CodiLote = MPCaMvCu.CodiLote');
    QryCust.SQL.Add('WHERE (AtivPlan <> 0) AND (CuCoPlan > 0) AND (EnceSiSt <> 0) AND (AtivLote = 0)');
    CodiLote := RetoZero(CodiLote);
    if CodiLote <> '0' then
      QryCust.SQL.Add('AND (MPCaLote.CodiLote = '+CodiLote+')');
    QryCust.SQL.Add('GROUP BY MPCaLote.CodiLote, MPCaLote.EnceLote, MPCaPlan.CuCoPlan');
    QryCust.Open;
    //Idade do Encerramento do Lote -> Deve ter pelo menor um ítem de encerramento para poder pegar a idade
    IdadCole := IdadEnce(CodiLote);
    QryCole.SQL.Clear;
    QryCole.SQL.Add('SELECT * FROM MPCACOLE');
    QryCole.SQL.Add('');
    while not(QryCust.Eof) do
    begin
      QryCole.SQL.Strings[1] := 'WHERE (CODILOTE = '+RetoZero(QryCust.FieldByName('CodiLote').AsString)+') AND (DATACOLE = '+FormDataStri(QryCust.FieldByName('EnceLote').AsDateTime)+') AND (CODIMVIS = '+QryCust.FieldByName('CuCoPlan').AsString+')';
      QryCole.Open;
      if QryCole.IsEmpty then //Inclusão
      begin
        QryCole.Append;
        QryCole.FieldByName('CodiLote').AsString   := QryCust.FieldByName('CodiLote').AsString;
        QryCole.FieldByName('CodiMvIs').AsInteger  := QryCust.FieldByName('CuCoPlan').AsInteger;
        QryCole.FieldByName('DataCole').AsDateTime := QryCust.FieldByName('EnceLote').AsDateTime;
        QryCole.FieldByName('IdadCole').AsFloat    := IdadCole;
      end
      else
        QryCole.Edit;
      QryCole.FieldByName('NumeCole').AsFloat   := QryCust.FieldByName('Valo').AsFloat;
      QryCole.FieldByName('MarcCole').AsInteger := 0;
      QryCole.FieldByName('CodiUsua').AsInteger := 0;
      TratErroBanc(QryCole);
      QryCust.Next;
    end;
  finally
    QryCole.Close;
    QryCole.Free;
    QryCust.Close;
    QryCust.Free;
  end;
end;

//Objetivo: Fazer os lançamentos conforme parametrizado dos valores da Coleta de Dados para
//          Movimentos dos Custos.
Procedure AtuaColeCust(CodiLote: String; DataInic, DataFina: TDateTime; iComp: TObject = nil);
var
  CodiCent : string;
begin
  //==========================================================================
  //C O L E T A   D E   D A D O S  -->  C U S T O S  (MOVIMENTO)

  CodiCent := IntToStr(CalcInte('SELECT MAX(CodiCent) FROM POCaCent WHERE (CodiGene = '+CodiLote+') AND (TabeCent IN (''MPCALOTE'',''FCCALOTE''))', iComp));
//CodiBox := RetoZero(CalcStri('SELECT MAX(CodiBox) FROM MPCaAloj INNER JOIN MPCaLote ON ((MPCaAloj.CodiLote = MPCaLote.CodiLote) AND (MPCaAloj.DataAloj = MPCaLote.UltiLote)) WHERE (MPCaAloj.CodiLote = '+CodiLote+')'));

  //Apago os dados lançados deste Lote onde o InteMvCu = 4 e o ítem for de encerramento
//  ExecSQL_('DELETE FROM MPCaMvCu '+
//           'WHERE (CodiLote = '+CodiLote+') AND (InteMvCu = 4) AND (CodiPlan IN (SELECT CodiPlan FROM MPCaPlan INNER JOIN MPCaMvIs ON MPCaPlan.CoCuPlan = MPCaMvIs.CodiMvIs INNER JOIN MPCaSiSt ON MPCaSiSt.CodiSiSt = MPCaMvIs.CodiSist WHERE (EnceSiSt <> 0)))');
  ExecSQL_('DELETE FROM POGeMvCx '+
           'WHERE (CodiCent = '+CodiCent+
           ') AND (TabeMvCx = ''COLEENCE'')', iComp);

  //Somente os valores do lote específico, na data específica, as contas que tenham Ítem/Sub-Ítem e que seja para lançar do MPCaCole para o MPCaMvCu
//  ExecSQL_('INSERT INTO MPCaMvCu (CodiLote,   CodiPlan,          DataMvCu, InteMvCu, MarcMvCu, CodiUsua, ValoMvCu,        CodiBox) '+
//           'SELECT              '+CodiLote+', MPCaPlan.CodiPlan, DataCole, 4,        0,        0,        SUM(NumeCole), '+CodiBox+
//           ' FROM MPCaCole INNER JOIN MPCaPlan ON MPCaCole.CodiMvIs = MPCaPlan.CoCuPlan '+
//           'WHERE (AtivPlan <> 0) AND (CoCuPlan <> 0) AND (MPCaCole.CodiLote = '+CodiLote+') AND (DataCole BETWEEN '+FormDataSQL(DataInic)+' AND '+FormDataSQL(DataFina)+') '+
//           'GROUP BY MPCaCole.CodiMvIs, MPCaPlan.CodiPlan, TipoPlan, DataCole '+
//           'HAVING (ABS(SUM(NumeCole)) > 0)');
  ExecSQL_('INSERT INTO POGeMvCx (CodiCent,   CodiPlan,          DataMvCx, CodiGene, TabeMvCx,     VlCrMvCx, CredMvCx, VlDeMvCx, DebiMvCx) '+
           'SELECT              '+CodiCent+', MPCaPlan.CodiPlan, DataCole, CodiCole, ''COLEENCE'', '+
           '(CASE WHEN NumeCole > 0 THEN ABS(NumeCole) ELSE 0 END), '+  //VlCrMvCx
           '(CASE WHEN NumeCole > 0 THEN 100           ELSE 0 END), '+  //CredMvCx
           '(CASE WHEN NumeCole < 0 THEN ABS(NumeCole) ELSE 0 END), '+  //VlDeMvCx
           '(CASE WHEN NumeCole < 0 THEN 100           ELSE 0 END)  '+  //DebiMvCx
           'FROM MPCaCole INNER JOIN MPCaPlan ON MPCaCole.CodiMvIs = MPCaPlan.CoCuPlan '+
           'WHERE (AtivPlan <> 0) AND (MPCaCole.CodiLote = '+CodiLote+
//         ') AND (DataCole BETWEEN '+FormDataSQL(DataInic)+' AND '+FormDataSQL(DataFina)+
           ') AND (ABS(NumeCole) > 0)', iComp);
end;

//Objetivo: Retornar o SQL nos campos totais dos resultados quando a opção for Média Ponderada
Function SQL_MediPond(Codi:Integer; Lote: String; vProc, Subs:TStringList): String;
var
  i : Integer;
  SQL_Lote: String;

  function BuscCampSQL(SQL, Lote: String): String;
  var
    Posi, PosiPare : Integer;
    Camp : String;
  begin
    Lote := SubsPalaTudo(Lote, 'CodiLote', 'XYXY');
    Posi := Pos(':LOTE', AnsiUpperCase(SQL));
    while Posi > 0 do
    begin
      Camp := Copy(SQL, Posi - 25, 25);
      PosiPare := Pos('(', Camp);
      if PosiPare > 0 then
      begin
        Camp := Copy(Camp, PosiPare+1, 25);
        SQL := SubsPalaTudo(SQL, '('+Camp+':LOTE', '('+SubsPalaTudo(Lote, 'XYXY', SubsPalaTudo(Camp,'=',''))); //Estava ficando com o = no final
      end
      else  //'AN WHERE CODILOTE = '
      begin
        PosiPare := Pos('WHERE ', AnsiUpperCase(Camp));
        if PosiPare > 0 then
        begin
          Camp := Copy(Camp, PosiPare+6, 25);
          SQL := SubsPalaTudo(SQL, 'WHERE '+Camp+':LOTE', 'WHERE '+SubsPalaTudo(Lote, 'XYXY', SubsPalaTudo(Camp,'=',''))); //Estava ficando com o = no final
        end
        else
        begin
          PosiPare := Pos(' AND ', AnsiUpperCase(Camp));
          Camp := Copy(Camp, PosiPare+5, 25);
          SQL := SubsPalaTudo(SQL, ' AND '+Camp+':LOTE', ' AND '+SubsPalaTudo(Lote, 'XYXY', SubsPalaTudo(Camp,'=',''))); //Estava ficando com o = no final
        end;
      end;


      Posi := Pos(':LOTE', AnsiUpperCase(SQL));
    end;
    Result := SQL;
  end;

var
  LoteAloj: String;
begin
  ExibMensHint('.');
  Result := CalcStri('SELECT (SELECT SQL_SiSt FROM MPGESIST MPCASIST WHERE MPCASIST.CODISIST = MPCAMVIS.CODISIST) FROM MPCaMvIs WHERE (MPCaMvIs.CodiMvIs = '+IntToStr(Codi)+')');
  ExibMensHint(Result);
  SQL_Lote := '';
  if Pos('LOTEMVDE',Lote) > 0 then //Análise de Desempenho
  begin
    Result := BuscCampSQL(Result, Lote);
  end
  else
  begin
    LoteAloj := '';
    i := Pos(' AND (MPCaCole.CodiAloj',Lote);
    if (i > 0) then
    begin
      LoteAloj := Copy(Lote, i, Length(Lote));
      Lote := Copy(Lote, 1, i-1);

      //Quando é por CodiAloj (Box ou Aviário), pega da MPCaMvPB
      Result := SubsPalaTudo(Result, 'Pesa) FROM MPCaPesa WHERE (CodiLote', 'MvPb) FROM MPCaMvPB INNER JOIN MPCaPesa ON MPCaMvPB.CodiPesa = MPCaPesa.CodiPesa INNER JOIN MPCaAloj MPCaCole ON MPCaCole.CodiBox = MPCaMvPb.CodiBox AND MPCaCole.CodiLote = MPCaPesa.CodiLote WHERE (MPCaPesa.CodiLote');
    end;

    i := Pos('=',Lote);
    if (i = 0) then
    begin
      SQL_Lote := Trim(Copy(Lote, Pos('IN',AnsiUpperCase(Lote)) + 2, Length(Lote)));
      SQL_Lote := SubsPala(SubsPala(SQL_Lote,'(',''),')','');
      SQL_Lote := SubsPala(AnsiUpperCase(SQL_Lote),' OR CODILOTE IN',',');
    end
    else
    begin
      while i > 0 do
      begin
        Delete(Lote,01,i);
        if SQL_Lote <> '' then
          SQL_Lote := SQL_Lote + ',';
        SQL_Lote := SQL_Lote + Copy(Lote,01,Pos(')',Lote)-1);
        i := Pos('=',Lote);
      end;
    end;

    if Pos(',',AnsiUpperCase(SQL_Lote)) = 0 then
    begin
      Result := SubsPalaTudo(Result, 'FROM MPCaLote WHERE (CodiLote = :Lote)'
                                   , 'FROM MPCaLote WHERE (CodiLote = '+RetiMasc(SQL_Lote)+')');
    end;

    //Por causa do Standard (MvSt) que não tem o CodiAloj
    Result := SubsPalaTudo(Result, 'SELECT MAX(MPCaLote.CodiStan) FROM MPCaLote WHERE (CodiLote = :Lote)'
                                 , 'SELECT MAX(MPCaLote.CodiStan) FROM MPCaLote WHERE (CodiLote IN ('+SQL_Lote+'))');

    Result := SubsPalaTudo(Result,'= :LOTE',' IN ('+SQL_Lote+')'+LoteAloj);
    Result := SubsPalaTudo(Result,'=:LOTE' ,' IN ('+SQL_Lote+')'+LoteAloj);
    Lote := Lote + LoteAloj;
  end;

  //Para quando for um item isolado ''Somatório de morte / DESCARTE''
  for i := 0 to (vProc.Count - 1) do
  begin
    //Para os Cole
    Result := SubsPalaTudo(Result,vProc.Strings[i],Subs.Strings[i]);
    //Para os MvSt quando for por Idade, pois a tabela MPCaMvSt não tem DATA
    Result := SubsPalaTudo(Result,SubsPalaTudo(vProc.Strings[i],'IDADCOLE','IDADMVST'),SubsPalaTudo(Subs.Strings[i],'IDADCOLE','IDADMVST'));
  end;

  //Caso sobre alguma idade (Pode ocorrer quando for por data e for um ítem de standard que não possui data)
  Result := SubsPalaTudo(Result,':IDAD','0');

  //Somar Valores da Coleta
  Result := SubsPalaTudo(Result,' NUMECOLE ',' SUM(NUMECOLE) ');
  Result := SubsPalaTudo(Result,' NUMEMVST ',' SUM(NUMEMVST) ');
end;

//Objetivo: Substituir os Itens quando a Média Ponderada for por Idade
Function SQL_MediPondIdad(Codi:Integer; Lote: String; IdadInic, IdadFina: String): String;
var
  vProc, Subs : TStringList;
  ColeLote: TDateTime;
  i: Integer;
  LoteAloj: String;
begin
  if IsDigit(Copy(IdadInic,01,01)) then  //No caso de POCaIdad.IdadIdad, não fará a substituição
    IdadInic := FormPont(IdadInic);
  if IsDigit(Copy(IdadFina,01,01)) then  //No caso de POCaIdad.IdadIdad, não fará a substituição
    IdadFina := FormPont(IdadFina);
  vProc := TStringList.Create;
  Subs := TStringList.Create;

  vProc.Add('IDADMVST = :IDAD');
  Subs.Add('IDADMVST BETWEEN '+IdadInic+' AND '+IdadFina);

  vProc.Add('IDADCOLE = :IDAD) AND');
  Subs.Add('IDADCOLE BETWEEN '+IdadInic+' AND '+IdadFina+') AND');

  vProc.Add('IDADCOLE = :IDAD');
  Subs.Add('IDADCOLE = '+IdadFina);

  vProc.Add('IDADCOLE <= :IDAD');
  Subs.Add('IDADCOLE <= '+IdadFina);

  //*********************************
  vProc.Add('IDADTRAM = :IDAD) AND');
  Subs.Add('IDADTRAM BETWEEN '+IdadInic+' AND '+IdadFina+') AND');

  vProc.Add('IDADTRAM = :IDAD');
  Subs.Add('IDADTRAM = '+IdadFina);

  vProc.Add('IDADTRAM <= :IDAD');
  Subs.Add('IDADTRAM <= '+IdadFina);
  //*********************************

  //*********************************
  vProc.Add('IDADOVOS = :IDAD) AND');
  Subs.Add('IDADOVOS BETWEEN '+IdadInic+' AND '+IdadFina+') AND');

  vProc.Add('IDADOVOS = :IDAD');
  Subs.Add('IDADOVOS = '+IdadFina);

  vProc.Add('IDADOVOS <= :IDAD');
  Subs.Add('IDADOVOS <= '+IdadFina);
  //*********************************

  vProc.Add('IDADPESA = :IDAD) AND');
  Subs.Add('IDADPESA BETWEEN '+IdadInic+' AND '+IdadFina+') AND');

  //Período
  vProc.Add(FormInteSQL+'(:IDAD)');
  Subs.Add(FormInteSQL+'('+IdadInic+')');

  vProc.Add('AND :IDAD');
  Subs.Add('AND '+IdadFina);

  //Caso de uso da :IDAD => 1, ou qualquer coisa em sub-consulta
  vProc.Add(':IDAD');
  Subs.Add(IdadFina);

  LoteAloj := '';
  if Copy(IdadFina,01,01) <> 'P' then  //POCaIdad.IdadIdad
  begin
    i := Pos(' AND (MPCaCole.CodiAloj',Lote);
    if (i > 0) then
    begin
      LoteAloj := Copy(Lote, i, Length(Lote));
      Lote := Copy(Lote, 1, i-1);
    end;

    i := Pos('=',Lote);
    if (i = 0) then
    begin
      Lote := Trim(Copy(Lote, Pos('IN',AnsiUpperCase(Lote)) + 2, Length(Lote)));
      Lote := SubsPala(SubsPala(Lote,'(',''),')','');
      Lote := SubsPala(AnsiUpperCase(Lote),' OR CODILOTE IN',',');
      Lote := '(CodiLote IN ('+Lote+'))';
    end;
    ColeLote := CalcMax_ColeLote(Lote);  //Não diminui 1 porque na Função DataCole já diminui

    Lote := Lote + LoteAloj;

    vProc.Add(':DATAINIC');
    Subs.Add(FormDataSQL(DataCole(ColeLote, sgStrToFloat(SubsPala(IdadInic,'.',',')))));
    vProc.Add(':DATAFINA');
    Subs.Add(FormDataSQL(DataCole(ColeLote, sgStrToFloat(SubsPala(IdadFina,'.',',')))));
    vProc.Add(':DATA');
    Subs.Add(FormDataSQL(DataCole(ColeLote, sgStrToFloat(SubsPala(IdadFina,'.',',')))));
  end;

  Result := SQL_MediPond(Codi, Lote, vProc, Subs);
end;

//Guarda o SQL e o Resultado para evitar multiplas buscas no banco de dados da mesma instrução
function CalcMax_ColeLote(iLote: String): TDateTime;
var
  vSQL: String;
begin
  vSQL := 'SELECT MAX(ColeLote) FROM MPCaLote WHERE '+iLote;
  if vSQL = GetConfWeb.CalcMax_ColeLote_SQL_ then
    Result := GetConfWeb.CalcMax_ColeLote_Data
  else
  begin
    Result := CalcData(vSQL);
    GetConfWeb.CalcMax_ColeLote_SQL_ := vSQL;
    GetConfWeb.CalcMax_ColeLote_Data := Result;
  end;
end;

//Objetivo: Substituir os Itens quando a Média Ponderada for por Data
Function SQL_MediPondData(Codi:Integer; Lote: String; DataInic, DataFina: String): String;
var
  vProc, Subs : TStringList;
  ColeLote: TDateTime;
  veriAloj : Boolean;
begin
  veriAloj := Pos('CODIALOJ',AnsiUpperCase(Lote)) > 0;
  if veriAloj then
    ColeLote := CalcMax_ColeLote(Copy(Lote,01,Pos(' AND ',Lote))) - 1
  else
    ColeLote := CalcMax_ColeLote(Lote) - 1;

  vProc := TStringList.Create;
  Subs := TStringList.Create;

  vProc.Add('IDADMVST = :IDAD');
  Subs.Add('IDADMVST BETWEEN (('+FormCastRealSQL('('+ DataInic +' - '+ FormDataSQL(ColeLote) +')')+' / '+FormNumeSQL(GetPPerIdad)+')-0.09) AND (('+FormCastRealSQL('('+ DataFina +' - '+ FormDataSQL(ColeLote) +')')+' / '+FormNumeSQL(GetPPerIdad)+')+0.09)');

  vProc.Add('IDADCOLE = :IDAD) AND');
  Subs.Add('DATACOLE BETWEEN '+DataInic+' AND '+DataFina+') AND');

  vProc.Add('IDADCOLE = :IDAD');
  Subs.Add('DATACOLE = '+DataFina);

  vProc.Add('IDADCOLE <= :IDAD');
  Subs.Add('DATACOLE <= '+DataFina);

  //Período
  vProc.Add('(IDADCOLE BETWEEN (('+FormInteSQL+'(:IDAD)-1)+0.0999) AND ((:IDAD)+0.0999))');
  Subs.Add('(DATACOLE BETWEEN (('+DataInic+') - '+FormNumeSQL(GetPPerIdad-1)+') AND '+DataFina+')');

  //Totaliza Dia
  vProc.Add('(IDADCOLE BETWEEN ((:IDAD)+0.0009) AND ((:IDAD)+0.0999))');
  Subs.Add('(DATACOLE BETWEEN '+DataInic+' AND '+DataFina+')');

  //******************************
  //TRAM
  vProc.Add('IDADTRAM = :IDAD) AND');
  Subs.Add('DATATRAM BETWEEN '+DataInic+' AND '+DataFina+') AND');

  vProc.Add('IDADTRAM = :IDAD');
  Subs.Add('DATATRAM = '+DataFina);

  vProc.Add('IDADTRAM <= :IDAD');
  Subs.Add('DATATRAM <= '+DataFina);

  //Período
  vProc.Add('IDADTRAM BETWEEN (('+FormInteSQL+'(:IDAD)-1)+0.0999) AND ((:IDAD)+0.0999))');
  Subs.Add('DATATRAM BETWEEN (('+DataInic+') - '+FormNumeSQL(GetPPerIdad-1)+') AND '+DataFina+')');

  //Totaliza Dia
  vProc.Add('IDADTRAM BETWEEN ((:IDAD)+0.0009) AND ((:IDAD)+0.0999))');
  Subs.Add('DATATRAM BETWEEN '+DataInic+' AND '+DataFina+')');

  //FIM TRAM
  //******************************

  //******************************
  //OVOS
  vProc.Add('IDADOVOS = :IDAD) AND');
  Subs.Add('DATAOVOS BETWEEN '+DataInic+' AND '+DataFina+') AND');

  vProc.Add('IDADOVOS = :IDAD');
  Subs.Add('DATAOVOS = '+DataFina);

  vProc.Add('IDADOVOS <= :IDAD');
  Subs.Add('DATAOVOS <= '+DataFina);

  //Período
  vProc.Add('IDADOVOS BETWEEN (('+FormInteSQL+'(:IDAD)-1)+0.0999) AND ((:IDAD)+0.0999))');
  Subs.Add('DATAOVOS BETWEEN (('+DataInic+') - '+FormNumeSQL(GetPPerIdad-1)+') AND '+DataFina+')');

  //Totaliza Dia
  vProc.Add('IDADOVOS BETWEEN ((:IDAD)+0.0009) AND ((:IDAD)+0.0999))');
  Subs.Add('DATAOVOS BETWEEN '+DataInic+' AND '+DataFina+')');

  //FIM OVOS
  //******************************

  vProc.Add('IDADPESA = :IDAD) AND');
  Subs.Add('DATAPESA BETWEEN '+DataInic+' AND '+DataFina+') AND');

  //Caso de uso da :IDAD => 1, ou qualquer coisa em sub-consulta
  vProc.Add(':IDAD');
  Subs.Add('('+FormCastRealSQL('('+ DataFina +' - '+ FormDataSQL(ColeLote) +')')+' / '+FormNumeSQL(GetPPerIdad)+')');

  vProc.Add(':DATAINIC');
  Subs.Add(DataInic);

  vProc.Add(':DATAFINA');
  Subs.Add(DataFina);

  vProc.Add(':DATA');
  Subs.Add(DataFina);

  Result := SQL_MediPond(Codi, Lote, vProc, Subs);
end;

//Objetivo: Executar o SQL quando a Médio Ponderada for por Idade
Function MediPondIdad(Codi:Integer; Lote: String; IdadInic, IdadFina: String): Real;
var
  vSQL: String;
begin
  try
    vSQL := SQL_MediPondIdad(Codi, Lote, IdadInic, IdadFina);
    Result := CalcReal(vSQL);
  except
    on E: Exception do
    begin
      ExibMensHint('--------------------'+sgLn+
                                  '**Erro** CalcReal'+sgLn+
                                  //vSQL+sgLn+
                                  E.Message);
      Result := 0;
    end;
  end;
end;

//Objetivo: Executar o SQL quando a Médio Ponderada for por Data
Function MediPondData(Codi:Integer; Lote: String; DataInic, DataFina: TDateTime): Real;
var
  vSQL: String;
begin
  try
    vSQL := SQL_MediPondData(Codi, Lote, FormDataSQL(DataInic), FormDataSQL(DataFina));
    Result := CalcReal(vSQL);
  except
    on E: Exception do
    begin
      ExibMensHint('--------------------'+sgLn+
                                  '**Erro** CalcReal'+sgLn+
                                  //vSQL+sgLn+
                                  E.Message);
      Result := 0;
    end;
  end;
end;

//Pega o valor do parâmetro informado na Coleta. Se não existir na idade passada
//tenta a última informada e por último no standard.
Function PegaCole(TabeCole, TabeLote, TabeMvSt, Stan, Lote, Idad, CodiReal, CodiStan: String):Real;
begin
  Idad := FormPont(Idad);
  //Baseado na semana informada
  Result := CalcReal('SELECT SUM(NumeCole) FROM '+ TabeCole+' WHERE ('+ TabeCole+'.CodiLote = '+Lote+') AND ('+ TabeCole+'.CodiMvIs = '+CodiReal+') AND (IdadCole = '+Idad+')');
  if Result = 0 then
  begin
    //Considerando a última coleta antes da idade informada
    Result := CalcReal('SELECT SUM(NumeCole) FROM '+ TabeCole+' WHERE ('+ TabeCole+'.CodiLote = '+Lote+') AND ('+ TabeCole+'.CodiMvIs = '+CodiReal+') AND (IdadCole = (SELECT MAX(IdadCole) FROM '+ TabeCole+' WHERE ('+ TabeCole+'.CodiLote = '+Lote+') AND ('+ TabeCole+'.CodiMvIs = '+CodiReal+') AND (IdadCole <= '+Idad+')))');
    if Result = 0 then  //Não existe coleta, pega-se do Standard
      Result := CalcReal('SELECT NumeMvSt FROM '+ TabeMvSt+' WHERE (CodiStan = '+Stan+') AND (CodiMvIs = '+CodiStan+')AND (IdadMvSt = '+Idad+')');
  end;
end;

//Colorir os valores nos relatórios de Itens e Sub-Itens
Function RetoCor_Item(CodiLote, Item, CodSMvIs, CoAc, CoAb: Integer; Valo, Idad, PeAc, PeAb, ValoStan: Real):Integer;
var
  Dife : Real;
  QryCor : TsgQuery;
begin
  if Item <> 0 then
  begin
    QryCor := TsgQuery.Create(Nil);
    try
      QryCor.SQL.Add('SELECT CodSMvIs, PeAcSiSt, PeAbSiSt, CoAcSiSt, CoAbSiSt');
      QryCor.SQL.Add('FROM MPGESIST MPCaSiSt INNER JOIN MPCaMvIs ON MPCaSiSt.CodiSiSt = MPCaMvIs.CodiSiSt');
      QryCor.SQL.Add('WHERE (MPCaMvIs.CodiMvIs = '+IntToStr(Item)+')');
      QryCor.Open;
      CodSMvIs := QryCor.FieldByName('CodSMvIs').AsInteger;
      PeAc := QryCor.FieldByName('PeAcSiSt').AsInteger;
      PeAb := QryCor.FieldByName('PeAbSiSt').AsInteger;
      CoAc := QryCor.FieldByName('CoAcSiSt').AsInteger;
      CoAb := QryCor.FieldByName('CoAbSiSt').AsInteger;
    finally
      QryCor.Close;
      QryCor.Free;
    end;
  end;
  Result := 0;
  if (CodSMvIs <> 0) OR (ValoStan <> 0) then  //Percentuais sobre o Padrão (Acima ou Abaixo)
  begin
    if ValoStan = 0 then
      ValoStan := CalcReal('SELECT NumeMvSt FROM MPCaMvSt INNER JOIN MPGeLote ON MPCaMvSt.CodiStan = MPGeLote.CodiStan WHERE (CodiLote = '+IntToStr(CodiLote)+') AND (IdadMvSt = '+FormPont(FloatToStr(Idad))+') AND (CodiMvIs = '+IntToStr(CodSMvIs)+')');
    Dife := DiveZero((Valo-ValoStan),ValoStan) * 100;
    if Dife > 0 then
    begin
      if Dife > PeAc then
        Result := CoAc;
    end
    else
    begin
      if Dife < PeAb then
        Result := CoAb;
    end;
  end
  else  //Valores acima ou Abaixo
  begin
    if Valo > PeAc then
      Result := CoAc
    else if Valo < PeAb then
      Result := CoAb;
  end;
end;

//Objetivo: Duplicar o(s) Registro(s) da Tabela passada conforme Where passado
//Retorna : O valor do primeiro campo do novo registro (Normalmente o Código do Destino)
//Parâm...: Tabe : Tabela de origem e destino
//          Wher : Campos para duplicar (Condição selecionando os campos)
//          MarcNovo: Tipo de marca para os novos campos (NOVO)
//          Camp : Campo que receberá o ''VALO''
//          Valo : Valor que será atribuido ao ''CAMP''
Function DuplRegiTabe(Tabe, Wher, MarcNovo, Camp: String; Valo:Integer; const iComp: TObject = nil):Integer;
var
  i : Integer;
  QryOrig, QryDest : TsgQuery;
  Marc : Boolean;
begin
  Tabe := AnsiUpperCase(Tabe);
  Result := 0;
  QryOrig := TsgQuery.Create(nil);
  QryDest := TsgQuery.Create(nil);
  try
    if Assigned(iComp) then
    begin
      QryOrig.sgConnection := tsgADOConnection(iComp);
      QryDest.sgConnection := tsgADOConnection(iComp);
    end;

    QryOrig.SQL.Clear;
    QryOrig.SQL.Add('SELECT * FROM '+Tabe);
    QryOrig.SQL.Add(Wher);
    QryOrig.Open;
    //Abro para a Duplicação
    QryDest.SQL.Clear;
    QryDest.SQL.Add('SELECT * FROM '+Tabe);
    QryDest.SQL.Add('WHERE (1 = 2)');
    QryDest.Open;
    while not(QryOrig.Eof) do
    begin
      QryDest.Append;
      Marc := False;
      for i := 1 to (QryOrig.Fields.Count-1) do
      begin
        if Pos(AnsiUpperCase(Camp),AnsiUpperCase(QryOrig.Fields[i].FieldName)) > 0  then  //Caso seja o campo para receber valor
          QryDest.Fields[i].AsInteger := Valo
        else if (TipoDadoCara(QryOrig.Fields[i]) = 'C') AND (not(Marc)) then //Caracter
        begin
          QryDest.Fields[i].AsString := QryOrig.Fields[i].AsString + MarcNovo;
          Marc := True;
        end
        else
          QryDest.Fields[i].Value := QryOrig.Fields[i].Value;
      end;
      TratErroBanc(QryDest);

      Result := QryDest.Fields[0].AsInteger;
      if Result = 0 then
        Result := CalcCodi(QryDest.Fields[0].FieldName, Tabe);

      QryOrig.Next;
    end;
  finally
    QryOrig.Close;
    QryDest.Close;
    QryOrig.Free;
    QryDest.Free;
  end;
end;

//Colocar a ordem dos campo passado de 10 em 10 conforme Order by (passado no Orde)
Procedure OrdeMovi(Camp, Tabe, Wher, Orde: string; Qry: TsgQuery);
var
  i : Integer;
  QryOrde : TsgQuery;
begin
  if msgSim('Este processo é inrreversível. Deseja continuar?') then
  begin
    QryOrde := TsgQuery.Create(nil);
    try
      QryOrde.SQL.Clear;
      QryOrde.SQL.Add('SELECT Codi'+Copy(Tabe,05,04)+', '+Camp);
      QryOrde.SQL.Add('FROM '+Tabe);
      QryOrde.SQL.Add('WHERE '+Wher);
      QryOrde.SQL.Add('ORDER BY '+Orde);
      QryOrde.Open;
      i := 10;
      while not(QryOrde.Eof) do
      begin
        AlteDadoTabe(Tabe,
                    [Camp, IntToStr(i)
                    ],'WHERE (Codi'+Copy(Tabe,05,04)+' = '+IntToStr(QryOrde.Fields[0].AsInteger)+')');
        i := i + 10;
        QryOrde.Next;
      end;
      Qry.Close;
      Qry.Open;
    finally
      QryOrde.Close;
      QryOrde.Free;
    end;
  end;
end;

//Validar se a conta é de Grau 4
Function ValiCont(Grau:Byte):Boolean;
begin
  Result := True;
  if Grau <> 4 then
  begin
    msgOk('A Conta deve ser de Grau 04. Ex.: 1.01.01.01!');
    Result := False;
  end;
end;

//Ordenar o QryPlan conforme o parâmetro, já coloca o ListFieldIndex no Lcb e abre o Qry
//Regra: O ORDER BY deve estar na Linha 3 (4ª linha)
Procedure OrdePlan(Lcb:TLcbLbl);
var
  Orde: String;
  i, IndiOrde, Inde: Integer;
  Qry: TsgQuery;
begin
  Qry := TsgQuery(Lcb.ListSource.DataSet);
  IndiOrde := -1;
  for I := 0 to Qry.SQL.Count - 1 do
  begin
    if (AnsiUpperCase(Copy(Trim(Qry.SQL.Strings[i]),01,08)) = 'ORDER BY') then
    begin
      IndiOrde := i;
      Break;
    end;
  end;

  Orde := PegaPara(000,'MPGeraOrdePlanCont');
  if Orde = 'N' then
  begin
    Orde := 'ORDER BY NumePlan';
    Inde := 0;
  end
  else if Orde = 'C' then
  begin
    Orde := 'ORDER BY NomePlan';
    Inde := 1;
  end
  else
  begin
    Orde := 'ORDER BY ReduPlan';
    Inde := 2;
  end;
  if (IndiOrde >= 0) then
    Qry.SQL.Strings[IndiOrde] := Orde;

  Lcb.ListFieldIndex := Inde;
  Lcb.ListSource.DataSet.Open;
end;

//Retorna o SQL conforme a Fase passada por parâmetro
Function RetoSQL_Fase(Recr, Prod, Incu:Boolean):String;
begin
  Result := '(MPCaSiSt.CodiSiSt = 0)'; //(1=2)
  if Recr or Prod or Incu then
  begin
    Result := SeStri(Recr,'(RecrSiSt <> 0)','');
    if Prod then
      Result := SeStri(Result <> '',Result+' OR ','')+'(ProdSiSt <> 0)';
    if Incu then
      Result := SeStri(Result <> '',Result+' OR ','')+'(IncuSiSt <> 0)';
    Result := '('+Result+')';
  end;
end;

//Retornar os valor Res0, Res1 ou Res2 conforme o valor de Valo
Function RetoOpca(Valo:Integer; Res0, Res1, Res2, Res3:String):String;
begin
  if Valo = 0 then
    Result := Res0
  else if Valo = 1 then
    Result := Res1
  else if Valo = 2 then
    Result := Res2
  else
    Result := Res3
end;

//Mudar o nome de um determinado nome de uma tabela
//Exemplo: NomeAvia para Avia-001, Avia-002, etc..., ou usando as mascaras %NUME% para o número e %NOME% para o nome existente
Procedure MudaNomeCampTabe(Tabe, Camp, Nome: String);
var
  i : Integer;
  QryCria : TsgQuery;
begin
  if msgSim('Deseja realmente mudar o Campo '+QuotedStr(Camp)+' da tabela '+QuotedStr(Tabe)+' para '+QuotedStr(Nome)+'...''?') then
  begin
    QryCria := TsgQuery.Create(Nil);
    try
      QryCria.SQL.Add('SELECT '+Camp+' FROM '+Tabe+' ORDER BY '+Camp);
      QryCria.Open;
      i := 1;
      while not(QryCria.Eof) do
      begin
        QryCria.Edit;
        QryCria.Fields[0].AsString := SubsPala(SubsPala(Nome,'%NUME%',ZeroEsqu(IntToStr(i),03)),'%NOME%',QryCria.Fields[0].AsString);
        TratErroBanc(QryCria);
        Inc(i);
        QryCria.Next;
      end;
    finally
      QryCria.Free;
    end;
  end;
end;

//Passado o Número da  Conta, retorna o seu respectivo grau
Function RetoGrauPlan(NumePlan: String):Integer;
begin
  if (Copy(NumePlan,10,02) <> '00') then
    Result := 4
  else if (Copy(NumePlan,07,02) <> '00') then
    Result := 3
  else if (Copy(NumePlan,04,02) <> '00') then
    Result := 2
  else
    Result := 1;
end;

//Retornar o próximo número do plano de contas
Function ProxNumePlan(NumePlan: string):String;
var
  QryPlan: TsgQuery;
  Nume, Grau: Integer;
  Auxi: string;
begin
  Grau := RetoGrauPlan(NumePlan);
  QryPlan := TsgQuery.Create(Nil);
  try
    QryPlan.SQL.Add('SELECT NumePlan FROM MPCaPlan');
    QryPlan.SQL.Add('WHERE (COPY(NumePlan,01,'+IntToStr(Grau*3)+') = '+QuotedStr(Copy(NumePlan,01,(Grau*3)))+')');
    QryPlan.SQL.Add('ORDER BY NumePlan DESC');
    QryPlan.Open;
    Nume := StrToInt(RetoZero(Copy(QryPlan.FieldByName('NumePlan').AsString,((Grau+1)*3)+1,02)))+1;
    Auxi := ZeroEsqu(IntToStr(Nume),02);
    NumePlan[(Grau*3)+1] := Auxi[1];
    NumePlan[(Grau*3)+2] := Auxi[2];
    Result := NumePlan;
  finally
    QryPlan.Close;
    QryPlan.Free;
  end;
end;

//Caso a idade na Tabela (MPCaCole, MPCaMvSt) não estiver com uma casa decimal,
//executa esta rotina para ficar
Procedure ArreIdadTabe(Tabe, Camp: String);
var
  QryIdad: TsgQuery;
  NumeCasa : Byte;
begin
  //Não pode-se arrendondar as idades do Frango de Corte por causa do Abatedouro que usa 2 digitos
  if (GetPSis() <> 3) and (GetPSis() <> 6) and (GetPSis() <> 7) and (GetPSis() <> 8) then
  begin
    if GetPBas() = 3 then
    begin
      if GetPPerIdad = 1 then
        ExecSQL_('UPDATE '+Tabe+' SET '+Camp+' = sgFixedPoint('+Camp+',0)')
      else
        ExecSQL_('UPDATE '+Tabe+' SET '+Camp+' = sgFixedPoint('+Camp+',1) / 10');
    end
    else
    begin
      NumeCasa := SeInte(GetPPerIdad = 1, 0, 1);  //Porque somente a divisão por um será exata
      if Camp = '' then
        Camp := Copy(Tabe,05,04);
      QryIdad := TsgQuery.Create(nil);
      try
        Application.CreateForm(TFrmPOGeAgCa,FrmPOGeAgCa);
        FrmPOGeAgCa.Caption := 'Aguarde, Calculando Idades...';
        FrmPOGeAgCa.Show;
        QryIdad.SQL.Clear;
        QryIdad.SQL.Add('SELECT '+Camp);
        QryIdad.SQL.Add('FROM '+Tabe);
    //    QryIdad.SQL.Add('GROUP BY '+Camp);
        QryIdad.Open;
        FrmPOGeAgCa.GauAgua.MaxValue := QryIdad.RecordCount;
        while not(QryIdad.Eof) do
        begin
    //      AtuaTabe('UPDATE '+Tabe+' SET '+Camp+' = '+FormPont(FloatToStr(AredReal(QryIdad.Fields[0].AsFloat,NumeCasa)))+' WHERE ('+Camp+' = '+FormPont(QryIdad.Fields[0].AsString)+')');
          QryIdad.Edit;
          QryIdad.Fields[0].AsFloat := ArreReal(QryIdad.Fields[0].AsFloat,NumeCasa);
          TratErroBanc(QryIdad);
          if PlusUni.Cancela then Exit;
          QryIdad.Next;
        end;
        QryIdad.Cancel;
      finally
        QryIdad.Close;
        QryIdad.Free;
        FrmPOGeAgCa.Free;
      end;
    end;
  end;
end;

//Gravar o Cabeçalho do Gráfico Simples, retornando o Código do Gráfico
Function GrafCabe(NomeGraf: String):Integer;
var
  QryGraf: TsgQuery;
begin
  QryGraf := TsgQuery.Create(Nil);
  try
    QryGraf.SQL.Clear;
    QryGraf.SQL.Add('SELECT * FROM MPCAGRAF WHERE (CODIGRAF = 0)');
    QryGraf.Open;
    QryGraf.Append;
    QryGraf.FieldByName('NomeGraf').AsString := NomeGraf;
    QryGraf.FieldByName('TituGraf').AsString := NomeGraf;
    QryGraf.FieldByName('Dim3Graf').Value := 0;
    QryGraf.FieldByName('AuInGraf').Value := 1;
    QryGraf.FieldByName('AIInGraf').Value := 1;
    QryGraf.FieldByName('AAInGraf').Value := 1;
    QryGraf.FieldByName('AuEsGraf').Value := 1;
    QryGraf.FieldByName('AIEsGraf').Value := 1;
    QryGraf.FieldByName('AAEsGraf').Value := 1;
    QryGraf.FieldByName('LegeGraf').AsInteger := 3;
    QryGraf.FieldByName('MarcGraf').AsInteger := 1;
    QryGraf.FieldByName('CodiTabe').AsInteger := GetPTab();
    QryGraf.FieldByName('CodiUsua').AsInteger := GetPUsu();
    TratErroBanc(QryGraf);

    Result := QryGraf.FieldByName('CodiGraf').AsInteger;
    if Result = 0 then
      Result := CalcCodi('CodiGraf','MPCaGraf');

  finally
    QryGraf.Close;
    QryGraf.Free;
  end;
end;

//Gravar as Séries do Gráfico Simples
Procedure GrafSeri(CodiGraf, Orde, Seri: Integer; Nome, NomX, ValX, ValY, SQL: String; Cor: Integer = 0);
begin
  InseDadoTabe('MPCaMvGr',
              ['CodiGraf',IntToStr(CodiGraf),
               'OrdeMvGr',IntToStr(Orde),
               'AtivMvGr','1',
               'SeriMvGr',IntToStr(Seri),
               'NomeMvGr',QuotedStr(Nome),
               'NomXMvGr',QuotedStr(NomX),
               'ValXMvGr',QuotedStr(ValX),
               'ValYMvGr',QuotedStr(ValY),
               'Cor_MvGr',IntToStr(Cor),
               'SQL_MvGr',QuotedStr(SQL)
              ],'', GetPBas()=4);
end;

//Arrumar os Parametros (Uso Futuro) personalizados (Te0, Nu0, Ch0 e Da0...) nos formulários
Function ArruParaEstr(Form: TForm; Quer: TDataSet; Tabe, Inic: String): Boolean;
var
  ValoComb: array [1..8] of String;
  i, NumePara : Integer;
  NomePara : String;
  Comb : TDBCmbLbl;
begin
  Result := False;
  NumePara := 8;
  with Form do
  begin
    for i := 1 to NumePara  do
    begin
      //Para os Textos
      NomePara := PegaPara(000,Inic+'Te0'+IntToStr(i));
      if NomePara <> '' then
      begin
        TsgLbl(FindComponent('LblTe0'+IntToStr(i)+Tabe)).Caption := NomePara;
        TsgLbl(FindComponent('LblTe0'+IntToStr(i)+Tabe)).Enabled := True;
        TDbEdtLbl(FindComponent('EdtTe0'+IntToStr(i)+Tabe)).Hint    := NomePara;
        TDbEdtLbl(FindComponent('EdtTe0'+IntToStr(i)+Tabe)).Enabled := True;
        Quer.FieldByName('Te0'+IntToStr(i)+Tabe).EditMask := PegaPara(000,Inic+'Ma0'+IntToStr(i));
        Result := True;
      end;
      //Para os Combos
      NomePara := PegaPara(000,Inic+'Co0'+IntToStr(i));
      if NomePara <> '' then
      begin
        ValoComb[i] := Quer.FieldByName('Co0'+IntToStr(i)+Tabe).AsString;
        TsgLbl(FindComponent('LblCo0'+IntToStr(i)+Tabe)).Caption := NomePara;
        TsgLbl(FindComponent('LblCo0'+IntToStr(i)+Tabe)).Enabled := True;
        Comb := TDbCmbLbl(FindComponent('CmbCo0'+IntToStr(i)+Tabe));
        Comb.Hint    := NomePara;
        Comb.Enabled := True;
        Comb.Items.Text := PegaPara(000,Inic+'Dd0'+IntToStr(i));
        Comb.Values.Text := Comb.Items.Text;
        Result := True;
      end;
      //Para os Números
      NomePara := PegaPara(000,Inic+'Nu0'+IntToStr(i));
      if NomePara <> '' then
      begin
        TsgLbl(FindComponent('LblNu0'+IntToStr(i)+Tabe)).Caption := NomePara;
        TsgLbl(FindComponent('LblNu0'+IntToStr(i)+Tabe)).Enabled := True;
        TDbRxELbl(FindComponent('EdtNu0'+IntToStr(i)+Tabe)).Hint    := NomePara;
        TDbRxELbl(FindComponent('EdtNu0'+IntToStr(i)+Tabe)).Enabled := True;
        Result := True;
      end;
      //Para os CheckBox
      NomePara := PegaPara(000,Inic+'Ck0'+IntToStr(i));
      if NomePara <> '' then
      begin
        TDBChkLbl(FindComponent('ChkCk0'+IntToStr(i)+Tabe)).Caption := NomePara;
        TDBChkLbl(FindComponent('ChkCk0'+IntToStr(i)+Tabe)).Hint    := NomePara;
        TDBChkLbl(FindComponent('ChkCk0'+IntToStr(i)+Tabe)).Enabled := True;
        Result := True;
      end;
      //Para a Data
      if i <= (NumePara div 2) then
      begin
        NomePara := PegaPara(000,Inic+'Da0'+IntToStr(i));
        if NomePara <> '' then
        begin
          TsgLbl(FindComponent('LblDa0'+IntToStr(i)+Tabe)).Caption := NomePara;
          TsgLbl(FindComponent('LblDa0'+IntToStr(i)+Tabe)).Enabled := True;
          TDbRxDLbl(FindComponent('EdtDa0'+IntToStr(i)+Tabe)).Hint    := NomePara;
          TDbRxDLbl(FindComponent('EdtDa0'+IntToStr(i)+Tabe)).Enabled := True;
          Result := True;
        end;
      end;
    end;
    if Quer.State = dsInsert then  //Para inicializar os CheckBox e os Números
    begin
      for i := 1 to NumePara do
      begin
        Quer.FieldByName('Ck0'+IntToStr(i)+Tabe).Value := 0;
        Quer.FieldByName('Nu0'+IntToStr(i)+Tabe).AsFloat   := 0;
      end;
    end
    else
    begin
      for i := 1 to NumePara do  //Quando joga as Strings no Combo, apaga o valor original
      begin
        if ValoComb[i] <> '' then
          Quer.FieldByName('Co0'+IntToStr(i)+Tabe).AsString := ValoComb[i];
      end;
    end;
  end;
end;

//Retorna os Dias do Mês, conforme o Ano (Para o Fevereiro)
Function DiasMes(Mes: Byte; Ano:Integer):Byte;
begin
  if Mes > 12 then
    Mes := 12;
  if Mes in [04,06,09,11] then
    Result := 30
  else if Mes = 2 then
  begin
    Result := 28;
    if (Ano div 4) = 0 then
      Result := 29;
  end
  else
    Result := 31;
end;

//Verificar se o dia é válido conforme as opções passadas (Domingos, Sábados, Feriados, etc...)
Function VeriDia_Vali(Data: TDateTime; Domi, Segu, Terc, Quar, Quin, Sext, Saba, Feri: Boolean): Boolean;
begin
  Result := False;
  if (not(DataFeri(Data)) or Feri) then  //Somente não irá Entrar quando For Feriado e não for para Abater em Feriado
  begin
    //1->Domingo, 2-> Segunda, etc...
    if (((DayOfWeek(Data)=1) and Domi) or
        ((DayOfWeek(Data)=2) and Segu) or
        ((DayOfWeek(Data)=3) and Terc) or
        ((DayOfWeek(Data)=4) and Quar) or
        ((DayOfWeek(Data)=5) and Quin) or
        ((DayOfWeek(Data)=6) and Sext) or
        ((DayOfWeek(Data)=7) and Saba)) then
    begin
      Result := True;
    end
  end;
end;

//Passa Mes/Ano Inicial e Mes/Ano final, retorna o número de meses entre os dois
Function DifeEntrMes(Mes_Inic, Ano_Inic, Mes_Fina, Ano_Fina: Integer):Integer;
// Primeiro Vencimento 07/2002
// Mês/Ano Atual 02/2003
// ((((2003-2002)*12)+02)-07)+1
begin
  Result := ((((Ano_Fina - Ano_Inic)*12)+Mes_Fina)-Mes_Inic)+1;
end;

//Procura o Dia Util, exemplo Dia=5, Quinto dia Útil, tira sábados, domingos e feriados
Function AchaDia_Util(Dia, Mes, Ano: Integer): Integer;
var
  ContDias : Integer;
begin
  Result := 0;
  ContDias := 0;
  while (Result < DiasMes(Mes, Ano)) and (ContDias < Dia) do
  begin
    Inc(Result);
    if VeriDia_Vali(EncodeDate(Ano, Mes, Result), False, True, True, True, True, True, False, False) then
      Inc(ContDias);
  end;
end;

//ProxDia_Util/BuscDia_Util: Verifica se a data atual é dia útil, caso contrario busca a proxima ou anterior
Function BuscDia_Util(iData: TDateTime; iBusc: TBuscDia_Util = duProx): TDateTime;
begin
  Result := iData;
  while not VeriDia_Vali(Result, False, True, True, True, True, True, False, False) do
  begin
    if iBusc = duProx then
      Result := Result+1
    else
      Result := Result-1;
  end;
end;
Function ProxDia_Util(iData: TDateTime; iBusc: TBuscDia_Util = duProx): TDateTime;
begin
  Result := BuscDia_Util(iData, duProx);
end;

//==============================================================================
//IMPLEMENTAÇÕES PARA A VERSÃO3
//Retorna nas variáveis a faixa do Tipo passado (E,S,R,N)
procedure FaixTipo(Tipo:string; var ValoInic, ValoFina: Integer);
begin
  if Tipo = 'E' then
  begin
    ValoInic := 0;
    ValoFina := 10;
  end
  else if Tipo = 'S' then
  begin
    ValoInic := 11;
    ValoFina := 20;
  end
  else if Tipo = 'R' then
  begin
    ValoInic := 21;
    ValoFina := 30;
  end
  else if Tipo = 'M' then
  begin
    ValoInic := 35;
    ValoFina := 35;
  end
  else
  begin
    ValoInic := 31;
    ValoFina := 40;
  end;
end;

//Retornar a quantidade do Produto
//Parametros:
// Tipo: E, S, R, N
// Wher: Passado pelo Usuário
// Oper: Operador (=, <=, etc...)
// Data: Data para o Operador
Function QtdeProd(CodiProd: Integer; Tipo, Wher, Oper: string; Data: TDateTime):Real;
var
  WherProd: String;
begin
  WherProd := SeStri(CodiProd <> 0,' AND (EsCaEsto.CodiProd = '+IntToStr(CodiProd)+')','');
  Result := CalcReal('SELECT SUM(QtdeEsto) '+
                     'FROM EsCaEsto '+
                     'WHERE (TipoEsto = '+QuotedStr(Tipo)+
                     ') AND (DataEsto '+ Oper +' ' + FormDataSQL(Data)+ ') '+ WherProd + Wher);
end;


//Retornar o valor do Produto
//Parametros:
// Tipo: E, S, R, N
// Wher: Passado pelo Usuário
// Oper: Operador (=, <=, etc...)
// Data: Data para o Operador
//iCodEProd: Se informado, será usado esse código para a busca do Valor de Estoque
Function ValoProd(CodiProd: Integer; Tipo, Wher, Oper: string; Data: TDateTime;
                  CodiSeto: Integer = 0; CodiLoPr: Integer = 0;
                  Qry: TsgQuery = nil; iComp: TObject = nil;
                  iCodEProd: Integer = 0):Real;
var
  WherProd: String;
begin
  if iCodEProd <> 0 then
    CodiProd := iCodEProd
  else
  begin
    iCodEProd := CalcInte('SELECT CodEProd FROM POGeProd WHERE CodiProd = '+IntToStr(CodiProd));
    if iCodEProd <> 0 then
      CodiProd := iCodEProd;
  end;

  WherProd :=            SeStri(CodiProd <> 0,' AND (EsCaEsto.CodiProd = '+IntToStr(CodiProd)+')','');
  if DmPlus.GetPegaPara_CalcEstoSeto(iComp) then
    WherProd := WherProd + SeStri(CodiSeto <> 0,' AND (EsCaEsto.CodiSeto = '+IntToStr(CodiSeto)+')','');
  if DmPlus.GetPegaPara_CalcEstoLoPr(iComp) then
    WherProd := WherProd + SeStri(CodiLoPr <> 0,' AND (EsCaEsto.CodiLoPr = '+IntToStr(CodiLoPr)+')','');

  if Assigned(Qry) then
    Result := CalcReal('SELECT SUM(ValoEsto) AS Valo '+
                       'FROM EsCaEsto '+
                       'WHERE (ESCaEsto.TipoEsto = '+QuotedStr(Tipo)+
                       ') AND (ESCaEsto.DataEsto '+ Oper +' ' + FormDataSQL(Data)+ ') '+ WherProd + Wher, Qry)
  else
    Result := CalcReal('SELECT SUM(ValoEsto) AS Valo '+
                       'FROM EsCaEsto '+
                       'WHERE (ESCaEsto.TipoEsto = '+QuotedStr(Tipo)+
                       ') AND (ESCaEsto.DataEsto '+ Oper +' ' + FormDataSQL(Data)+ ') '+ WherProd + Wher, iComp);
end;

//Calcular o Estoque do Produto (Entrada - Saída)
//iCodEProd: Se informado, será usado esse código para a busca do Estoque
Function EstoProd(CodiProd: Integer; Wher, Oper: String; Data: TDateTime;
                  CodiSeto: Integer = 0; CodiLoPr: Integer = 0;
                  Qry: TsgQuery = nil; iComp: TObject = nil;
                  iCodEProd: Integer = 0):Real;
var
  Seto: string;

  function EstoProd_CalcReal(iSQL: String): Real;
  begin
    if Assigned(Qry) then
      Result := CalcReal(iSQL, Qry)
    else
      Result := CalcReal(iSQL, iComp);
  end;

begin
  Seto := '';
  if (CodiSeto <> 0) and DmPlus.GetPegaPara_CalcEstoSeto(iComp) then
      Seto := ' AND (ESCaEsto.CodiSeto = '+IntToStr(CodiSeto)+')';

  if (CodiLoPr <> 0) and DmPlus.GetPegaPara_CalcEstoLoPr(iComp) then
    Seto := Seto + ' AND (ESCaEsto.CodiLoPr = '+IntToStr(CodiLoPr)+')';

  if Data <> 0 then
    Seto := Seto + ' AND (ESCaEsto.DataEsto '+Oper+' ' + FormDataSQL(Data)+ ')';

  if iCodEProd <> 0 then
    CodiProd := iCodEProd
  else
  begin
    iCodEProd := CalcInte('SELECT CodEProd FROM POGeProd WHERE CodiProd = '+IntToStr(CodiProd), iComp);
    if iCodEProd <> 0 then
      CodiProd := iCodEProd;
  end;

  Result := EstoProd_CalcReal('SELECT SUM(CalcEsto)'+
                              ' FROM ESCaEsto'+
                              ' WHERE (ESCaEsto.CodiProd = '+IntToStr(CodiProd)+')'+
                              Wher + Seto);

  {
   Essa função é para o estoque real do Produto (usado para vários relatórios, inclusive o Inventário
   Assim, será diferente do FUN_ESTOPROD
   ***   Sendo que a igual é a EstoProd_Pedi  ****
   }
end;

Function EstoProd_Pedi(CodiProd: Integer; Wher, Oper: String; Data: TDateTime;
                       CodiSeto: Integer = 0; CodiLoPr: Integer = 0;
                       Qry: TsgQuery = nil; iComp: TObject = nil;
                       iCodEProd: Integer = 0):Real;
var
  vQtdePedi, vQtdePeOu: Real;

  function EstoProd_CalcReal(iSQL: String): Real;
  begin
    if Assigned(Qry) then
      Result := CalcReal(iSQL, Qry)
    else
      Result := CalcReal(iSQL, iComp);
  end;

begin
  Result := EstoProd(CodiProd, Wher, Oper, Data, CodiSeto, CodiLoPr, Qry, iComp, iCodEProd);
  vQtdePedi := 0;
  if GetEmpresa <> 'SA3' then
  begin
    vQtdePedi := EstoProd_CalcReal('SELECT SUM((CASE WHEN UPPER(TRIM((SELECT POCAUNID.NOMEUNID FROM POCAUNID WHERE POCAUNID.CODIUNID = (SELECT POCAPROD.CODIUNID FROM POCAPROD WHERE POCAPROD.CODIPROD = MVPE.CodiProd)))) IN (''LT'',''KG'')'+
                                     ' THEN MVPE.QTACMVPE*MVPE.PESOMVPE'+
                                     ' ELSE MVPE.QTACMVPE END))'+sgLn+
                                   ' FROM VDCAMVPE MVPE INNER JOIN VDCAPEDI PEDI ON MVPE.CODIPEDI = PEDI.CODIPEDI'+sgLn+
                                   ' WHERE (PEDI.SITUPEDI NOT IN (''CANC'', ''FECH''))'+sgLn+
                                   '   AND (MVPE.CODIPROD = '+IntToStr(CodiProd)+')'+sgLn+
                                   SeStri(CodiLoPr<>0,'   AND (MVPE.CODILOPR = '+IntToStr(CodiLoPr)+')','')+
                                   '   AND (PEDI.EMISPEDI <= '+FormDataSQL(Data)+')'+sgLn+
                                   '   AND (MVPE.MARCMVPE < 2)');
  end;
  vQtdePeOu := EstoProd_CalcReal('SELECT SUM((CASE WHEN UPPER(TRIM((SELECT POCAUNID.NOMEUNID FROM POCAUNID WHERE POCAUNID.CODIUNID = (SELECT POCAPROD.CODIUNID FROM POCAPROD WHERE POCAPROD.CODIPROD = MVPO.CodiProd)))) IN (''LT'',''KG'')'+
                                   ' THEN MVPO.QTACMVPO*MVPO.PESOMVPO'+
                                   ' ELSE MVPO.QTACMVPO END))'+sgLn+
                                 ' FROM VDCAMVPO MVPO INNER JOIN VDCAPEOU PEDI ON MVPO.CODIPEOU = PEDI.CODIPEOU'+sgLn+
                                 ' WHERE (PEDI.SITUPEOU NOT IN (''CANC'', ''FECH''))'+sgLn+
                                 '   AND (MVPO.CODIPROD = '+IntToStr(CodiProd)+')'+sgLn+
                                 SeStri(CodiLoPr<>0,'   AND (MVPO.CODILOPR = '+IntToStr(CodiLoPr)+')','')+
                                 '   AND (PEDI.EMISPEOU <= '+FormDataSQL(Data)+')'+sgLn+
                                 '   AND (MVPO.MARCMVPO < 2)');
  Result := Result - vQtdePedi - vQtdePeOu;
end;

//Finalidade: Validar o Estoque do Produto Bloqueando, Avisando ou Liberando a continuação
//da movimentação conforme parâmetro 'GetPegaPara_BloqProd' em RAPaGera/DmPlus.
Function LibeMovi(Movi:String; Prod:Integer; Qtde, Esto:Real; Data:TDateTime; VeriEsto: Boolean;
                  CodiSeto: Integer = 0; CodiLoPr: Integer = 0; iComp: TObject = nil): SgActionResult;
var
  Maxi:Real;
  Nome, Unid: String;
  Tipo: Integer;
  Qry: TsgQuery;
begin
  Result := SgActionResult.Create;

  Func.GravLog_Mens( 'Produto : '+IntToStr(Prod)+sgLn
                    +'TipoMovi: '+Movi+sgLn
                    +'Qtde    : '+FormRealBras(Qtde)+sgLn
                    +'Esto    : '+FormRealBras(Esto)+sgLn
                    +'Data    : '+FormDataBras(Data)+sgLn
                    +'VeriEsto: '+SeStri(VeriEsto, 'S', 'N')+sgLn
                    +'CodiSeto: '+IntToStr(CodiSeto)+sgLn
                    +'CodiLoPr: '+IntToStr(CodiLoPr)+sgLn
                    +'Condição: "(TipoMovi IN [S, R, E]) e (NvEsProd = 0)"'+sgLn

              );
  if ((Movi = 'S') Or (Movi = 'R') Or (Movi = 'E')) and (CalcInte('SELECT NVEsProd FROM POGeProd WHERE (CodiProd = '+IntToStr(Prod)+')', iComp) = 0) then
  begin
    Tipo := GetPegaPara_BloqProd(iComp);
    if Tipo <> 0 then
    begin
      if VeriEsto then
      begin
        //Esto := EstoProd(Prod,'','<=',Data, CodiSeto, CodiLoPr);
        //EstoAtua := EstoProd(Prod,'','<=',Data+99999, CodiSeto, CodiLoPr);
        //if EstoAtua < Esto then
        //  Esto := EstoAtua;
        Esto := EstoProd(Prod,'','<=', Data, CodiSeto, CodiLoPr, nil, iComp);
      end;

      Qry := DmPlus.CriaQuery(iComp, 'QryLibeMovi');
      try
        with Qry do
        begin
          SQL.Clear;
          SQL.Add('SELECT NomeProd, NomeUnid, MiniDePr as MiniProd, MaxidePr as MaxiProd');
          SQL.Add('FROM POGeProd INNER JOIN POCaUnid ON POGeProd.CodiUnid = POCaUnid.CodiUnid');
          SQL.Add('              LEFT  JOIN POCADEPR ON POGeProd.CodiProd = POCADEPR.CodiProd');
          SQL.Add('WHERE (POGeProd.CodiProd = '+IntToStr(Prod)+')');
          Open;
          Nome := FieldByName('NomeProd').AsString;
          Unid := FieldByName('NomeUnid').AsString;
          Maxi := FieldByName('MaxiProd').AsFloat;
          //Mini := FieldByName('MiniProd').AsFloat;
          Close;
        end;
      finally
        Qry.Free;
      end;

      if (Movi = 'S') Or (Movi = 'R') then
      begin
        ExibMensHint('Estoque: '+FormRealBras(Esto));
        ExibMensHint('Qtde: '+FormRealBras(Qtde));
        Esto := Esto - Qtde;

        if Tipo > 0 then  //Não é para Liberar
        begin
          if (Esto < -0.006) then
          begin
            if Tipo = 1 then //É para Bloquear Saldo Negativo
            begin
              {$ifNdef PDADATASNAP}
                Result.AddMsg(3000, 'Local: PlusUni.LibeMovi<br>'+
                                    '[MENSSAG_EXIB]: '+Nome+': Ficará com Saldo de Estoque Negativo em '+ FormRealBras(Esto)+' '+ Unid + '!<br>Movimentação não Autorizada!');
              {$endif}
              ExibMensHint('Erro: ' +Nome+': Ficará com Saldo de Estoque Negativo em '+ FormRealBras(Esto)+' '+ Unid + '!<br>Movimentação não Autorizada!');
            end
            //else //2-Avisa...
            //  Result := msgOkNome+' - Ficará com saldo de estoque negativo em '+ FormRealBras(Esto)+ ' '+ Unid + '!'+sgLn+'Deseja Prosseguir?', mtConfirmation, [mbYes, mbNo], 0) = mrNo;
          end
          //else if Esto < Mini then
          //  Result := msgOkNome+' - Ficará com Saldo abaixo do estoque mínimo !'+sgLn+'Deseja Prosseguir?', mtConfirmation, [mbYes, mbNo], 0) = mrNo;
        end;
      end
      else if (Movi = 'E') then
      begin
        if (Tipo > 0) and ((Esto+Qtde) > Maxi) then //Verifica se o saldo ficará acima do Est. Máximo
          Result.AddMsg(1500, 'Local: PlusUni.LibeMovi<br>'+
                              '[MENSSAG_EXIB]: '+Nome+': Ficará com Saldo acima do Estoque Máximo!<br>Deseja Prosseguir?');
      end;
    end;
  end
  else
    Result.AddMsg(0020, 'Local: PlusUni.LibeMovi<br>'+
                        '[MENSSAG_EXIB]: Tipo de Movimento ou Produto não Valida Estoque Negativo');
end;

//Finalidade: Validar se o produto está previsto no pedido ou não foi carregado além
//do solicitado Bloqueando, Avisando ou Liberando a continuação
//da movimentação conforme parâmetro 'PPProdBloqCarr' em POPaProd;
Function BloqProdCarr(Nome: String; Pedi, Carr, Prod:Integer):Boolean;
var
  Tipo: Integer;
  ProdPedi, ProdCarr: Real;
begin
  Result := False;
  Tipo := Round(PegaParaNume(000,'PPProdBloqCarr'));
  ProdPedi := CalcReal('SELECT COUNT(*) FROM POCaMvEs WHERE (CodiEsto = '+ IntToStr(NuloInte(Pedi)) + ') AND (CodiProd = '+ IntToStr(NuloInte(Prod))+') AND (MarcMvEs < 2)');

  if Tipo > 0 then  //Não é para Liberar
  begin
    if ProdPedi > 0 then
    begin
      ProdCarr := CalcReal('SELECT COUNT(*) FROM POCaMvEs WHERE (CodiEsto = '+ IntToStr(NuloInte(Carr)) + ') AND (CodiProd = '+ IntToStr(NuloInte(Prod))+') AND (MarcMvEs < 2)');

      if ProdCarr > ProdPedi then
      begin
        if Tipo = 1 then //É para Bloquear o Produto carregado a mais que o pedido
        begin
          Result := True;
          GetPADOConn.sgRollbackTrans;
          msgAviso(Nome+' - Pedido já atendido para este Produto! Movimentação não Autorizada!');
        end  //Senão Avisa...
        else if msgNao(Nome+' - Pedido já atendido para este Produto!'+sgLn+'Deseja Prosseguir?') then
          Result := True;
      end;
    end
    else
    begin
      if Tipo = 1 then
      begin
        Result := True;
        msgAviso(Nome+' - Não Informado no Pedido!'+sgLn+'Movimentação não Autorizada!');
      end  //Senão Avisa...
      else if msgNao(Nome+' - Não Informado no Pedido!'+sgLn+'Deseja Prosseguir?') then
        Result := True;
    end;
  end;
end;

//Calcular o custo do produto On-Line
Function Fun_CustProd_Calc(CodiProd: Integer; Data: TDateTime; iCodiSeto: Integer; iAtualiza:Boolean = True; iCustoPronto:Boolean = False;
                              iComp: TObject = nil; GeraCusto: Boolean = False): Real;
var
  vDataEsto : TDate;
begin
  ExibMensHint('Calculando custo do produto...');
  vDataEsto := Trunc(Data);

  Result := CalcReal('SELECT FUN_CUSTPROD_CALC_V4('+IntToStr(CodiProd)+
                                               ', '+FormDataSQL(vDataEsto)+
                                               ', '+SeStri(iAtualiza,'1','0')+
                                               ', '+SeStri(iCustoPronto,'1','0')+
                                               ', '+SeStri(GeraCusto,'1','0')+
                                               ', '+SeStri(DmPlus.GetPegaPara_CalcEstoSeto(), IntToStr(iCodiSeto), 'NULL')+
                                               ') AS CUSTPROD FROM POCAAUXI', iComp);

  ExibMensHint('Data: '+FormDataBras(vDataEsto)+' Custo: '+FloatToStr(Result));
end;

//Gravar dados da Coleta de Dados
Function LancCole(TabeCole: String; CodiCole, CodiLote, CodiMvIS: Integer; Idad, NumeCole: Real; Data: TDateTime; PesqChav: Boolean): Integer;
var
  QryCole : TsgQuery;
begin
  TabeCole := AnsiUpperCase(TabeCole);
  QryCole := TsgQuery.Create(Nil);
  try
    QryCole.SQL.Clear;
    QryCole.SQL.Add('SELECT * FROM '+ TabeCole);
    if PesqChav then
      QryCole.SQL.Add('WHERE (CODILOTE = '+ IntToStr(CodiLote)+') AND (CODIMVIS = '+ IntToStr(CodiMvIS)+') AND (IDADCOLE = '+ FormPont(FloatToStr(Idad))+')')
    else
      QryCole.SQL.Add('WHERE (CODICOLE = '+IntToStr(CodiCole)+')');
    QryCole.Open;
    if QryCole.IsEmpty then //Inclusão
      QryCole.Append
    else
      QryCole.Edit;
    if not(PesqChav) or (QryCole.State = dsInsert) then
    begin
      QryCole.FieldByName('CodiLote').AsInteger  := CodiLote;
      QryCole.FieldByName('CodiMvIS').AsInteger  := CodiMvIS;
      QryCole.FieldByName('DataCole').AsDateTime := Data;
      QryCole.FieldByName('IdadCole').AsFloat    := Idad;
      QryCole.FieldByName('CodiGene').AsInteger  := 0;
      QryCole.FieldByName('MarcCole').AsInteger  := 0;
      QryCole.FieldByName('CodiUsua').AsInteger  := 0;
    end;
    QryCole.FieldByName('NumeCole').AsFloat := NumeCole;
    TratErroBanc(QryCole);

    Result := QryCole.FieldByName('CodiCole').AsInteger;
    if Result = 0 then
      Result := CalcCodi('CodiCole','MPCaCole');

  finally
    QryCole.Close;
    QryCole.Free;
  end;
end;

//Situação da Requisição ao Almoxarifado
Function SituRequEsto(Indi: Integer): String;
var
  Situ : array [0..4] of string;
begin
  Situ[0] := 'A';
  Situ[1] := 'C';
  Situ[2] := 'E';
  Situ[3] := 'O';
  Situ[4] := 'F';
  Result := Situ[Indi];
end;

//Indice da Situação da Requisição ao Almoxarifado
Function IndiSituRequEsto(Situ: String): Integer;
begin
  if Situ = 'A' then
    Result := 0
  else if Situ = 'C' then
    Result := 1
  else if Situ = 'E' then
    Result := 2
  else if Situ = 'O' then
    Result := 3
  else
    Result := 4;
end;

//Gera um código de Barras conforme parâmetros em POPaBarr
function GeraCodiBarr:String;
var
  CodiEAN, CodiEmpr, CodiProd :String;
begin
  CodiEAN  := PegaPara(000,'PPBarrCodiEAN_Barr');
  CodiEmpr := PegaPara(000,'PPBarrCodiEmprBarr');
  CodiProd := ProxCodiBarr;

  if CodiProd <> '0' then
    Result := CodiEAN + CodiEmpr + CodiProd + DigiVeriBarr(CodiEAN+CodiEmpr+CodiProd)
  else
    Result := '0';
end;

// Retorna a próxima sequência de números de produtos em Códigos de Barras conforme
// parâmetros em POPaBarr
function ProxCodiBarr: String;
var
  DigiProd, Codi:Integer;
  Segu: Boolean;
begin
  DigiProd := Trunc(PegaParaNume(000,'PPBarrNumeDigiProd'));
  Segu     := True;
  Codi     := 1;
  Result   := '0';

  while Segu and (Length(IntToStr(Codi)) <= DigiProd) do
  begin
    if CalcInte('SELECT CodiProd FROM POGeProd WHERE ('+FormLeftSQL+'('+FormRightSQL+'(RTRIM(BarrProd),'+ IntToStr(DigiProd+1) +'),'+ IntToStr(DigiProd)+') = '+ IntToStr(Codi)+')') = 0 then
    begin
      Result := ZeroEsqu( IntToStr(Codi), DigiProd);
      Segu   := False;
    end
    else
      Codi   := Codi + 1;
  end;
end;

// Gera um dígito verificador para o código de barras passado
function DigiVeriBarr(CodiBarr:String):String;
var
  i,Soma,Peso,Auxi: Integer;
begin
  Peso := 3;
  Soma := 0;
  for i := Length(CodiBarr) downto 1 do
  begin
    Soma := Soma + StrToInt(CodiBarr[i]) * Peso;
    Peso := SeInte(Peso = 3,1,3);
  end;

  Auxi := Soma;
  while (Auxi mod 10) <> 0 do
  begin
    Auxi := Auxi + 1;
  end;

  Result := IntToStr(NuloInte(Auxi-Soma));
end;

//Gravar dados no Conf, Moni e abrir tabelas necessárias para o Acesso
procedure GravAcesSAG_Mana(EndeConf: string; Data: TDateTime);
var
  Codi: Integer;
begin
  GravAcesSAG_Mana_Empr(Data);

  ExibProgPrin(0, 5, 'Acessando...');

  Codi := InseDadoTabe('POCaMoni',
                      ['UsuaMoni',RetoUserBase(),
                       'VersMoni',QuotedStr(RetoVers()),
                       'IP__Moni',QuotedStr(PegaIP()),
                       'MaquMoni',QuotedStr(PegaMaqu()),
                       'WindMoni',QuotedStr(PegaUsuaWind()),
                       'EndeMoni',QuotedStr(GetPEndExecOrig+GetPNomExec),
                       'ConfMoni',QuotedStr(EndeConf),
                       'DataMoni',FormDataSQL(Date),
                       'HoraMoni',FormatDateTime('h',SysUtils.Time),
                       'MinuMoni',FormatDateTime('n',SysUtils.Time)
                      ],{$ifdef DATASNAP}''{$else}'CodiMoni'{$endif});
  SetPCodMoni(Codi);
  ExibProgPrin();

  GravParaData(000,'DataAces',Data);

  {$if Defined(ERPUNI) and Defined(DEBUG)}
    sgLog.Tipo := 3;
  {$else}
    //ExibProgPrin(1, 0, 'Parâmetros');
    //DtmPoul.QryPara.Open;
    //ExibProgPrin();

    {$ifdef WS}
    {$else}
      if (IsAdmiSAG or IsAdmiClie) then
        sgLog.Tipo := Trunc(PegaParaNume(0,'MCParaTipoLog_',GetPUsu(),0))
      else
        sgLog.Tipo := 0;
    {$endif}
  {$endif}

  ExibProgPrin(5, 0, SBemVindo+GetPNomSoft);
end;

//Troca de Empresa
procedure GravAcesSAG_Mana_Empr(Data: TDateTime);
begin
  ExibProgPrin(0, 4, 'Configuração');
  GravPOCaConf();
  ExibProgPrin();

  if (not DtmPoul.QryEmpr.Active) or (NuloInte(DtmPoul.QryEmpr.Params[0].Value) <> GetPEmp()) then
  begin
     {$ifdef FDTASK} TTask.Run(procedure {$else} {$endif}
      begin
        //ExibProgPrin(1, 0, 'Empresa');
        DtmPoul.QryEmpr.Close;
        {$ifdef WS}
          DtmPoul.QryEmpr.sgConnection := GetPsgTrans;
        {$else}
        {$endif}
        DtmPoul.QryEmpr.Params[0].Value := GetPEmp();
        DtmPoul.QryEmpr.Open;

        {$ifdef WS}
        {$else}
          //ExibProgPrin(1, 0, 'Moedas');
          DtmPoul.QryIndi.Close;
          //DtmPoul.QryIndi.sgConnection := GetPsgTrans;
          DtmPoul.QryIndi.Params.ParamByName('Moed').Value := DtmPoul.QryEmpr.FieldByName('CodiMoed').AsInteger;
          DtmPoul.QryIndi.Params.ParamByName('Moe1').Value := DtmPoul.QryEmpr.FieldByName('CodiMoed').AsInteger;
          DtmPoul.QryIndi.Params.ParamByName('Data').Value := Data;
          DtmPoul.QryIndi.Open;
        {$endif}
      end {$ifdef FDTASK} ) {$else} {$endif};
  end;
  ExibProgPrin(4, 0, ' ');
end;

//Calcula a Última Nota da empresa e série passada, não sendo o CodiNota passado
function CalcNumeNota(CodiEmpr, CodiNota: Integer; SeriNota, ModeNota: string):Integer;
begin
  Result := CalcInte('SELECT MAX(NumeNota) FROM POCaNota '+
                     'WHERE (CodiEmpr = '+IntToStr(CodiEmpr)+
                     ') AND (ZEROESQU(SeriNota,3) = ZEROESQU('+QuotedStr(SeriNota)+',3)'+
                     SeStri(ModeNota<>'',') AND (ModeNota = '+QuotedStr(ModeNota),'')+
                     ') AND (TipoNota <> ''E'''+  //Não for NF de Entrada
                     ') AND (TipoNota <> ''DS'''+  //Não for NF de Devolução de Saída
                     ') AND (CodiNota <> '+IntToStr(CodiNota)+
                     ')');
end;

//******************************************************************************************
//  V A L I D A Ç Ã O   D A S   S E N H A S

//Buscar a situação de todos os módulos liberados
function SenhModu_Todo(): String;
var
  Usua, Sist, Empr, NumeLibe, NumeModu: Integer;
  NumeRea1, NumeRea2: Real;
  NumeSist, Tipo, Dife, Libe: String;
  Valido: Boolean;
  List: TStringList;

  function SenhModu_Todo_BuscNomeTipo(Tipo: String): String;
  begin
    if (Tipo = '1') or (Tipo = '0') then
      Result := '1-Por Volume'
    else if (Tipo = '2') then
      Result := '2-Por Usuário'
    else if (Tipo = '3') then
      Result := '3-Por Usuário no Módulo'
    else if (Tipo = '4') then
      Result := '4-Por Usuário no Módulo e Acesso Completo'
    else if (Tipo = '5') then
      Result := '5-Acesso Completo'
    else
      Result := '';
  end;

begin
  Usua := GetPUsu();
  Sist := GetPSis() ;
  Empr := GetPEmp();
  NumeModu := 0;
  List := TStringList.Create;
  try
    List.Clear;
    List.Add(GetPNomSoft+' - Versão '+RetoVers);
    List.Add('');
    List.Add('Mod- '+
                      EspaDire('Nome Módulo',30)+ ' - '+
                      EspaEsqu('Valor Atual',12)+ ' - '+
                      EspaEsqu('Valor Liberado',12)+ ' - '+
                      EspaEsqu('Diferença',12)+ '   - '+
                      EspaEsqu('Tipo',20)+ ' - '+
                      EspaEsqu('Data',10)
                      );
    List.Add('---- '+
                      Replicate('-',30)+ ' - '+
                      Replicate('-',12)+ ' - '+
                      Replicate('-',12)+ ' - '+
                      Replicate('-',12)+ '   - '+
                      Replicate('-',20)+ ' - '+
                      Replicate('-',10)
                      );
    with DtmPoul do
    begin
      QryAuxi.SQL.Clear;
      QryAuxi.SQL.Add('SELECT CLCaProd.CodiProd, NomeProd');
      QryAuxi.SQL.Add('FROM CLCaProd');
      QryAuxi.SQL.Add('WHERE (AtivProd <> 0)');
      QryAuxi.SQL.Add('GROUP BY CLCaProd.CodiProd, NomeProd');
      QryAuxi.SQL.Add('ORDER BY CLCaProd.CodiProd');
      QryAuxi.Open;
      while not QryAuxi.Eof do
      begin
        ExibMensHint(QryAuxi.FieldByName('NomeProd').AsString);
        SetPSis(GetPSis(QryAuxi.FieldByName('CodiProd').AsInteger));
        GravPOCaConf();

        NumeSist := ZeroEsqu(IntToStr(GetPSis()),03);

        try
          Tipo := PegaParaSenh(000,'NumeContModu0'+NumeSist);
          Libe := Copy(ZeroEsqu(Tipo,03),02,02);
          NumeLibe := StrToInt(GetSenh_A_ZparaNume(Libe));
          Tipo := Copy(Tipo,01,01);

          if NumeLibe > 0 then  //Se tiver valor liberado, mostra
          begin
            Inc(NumeModu);

            //Busca Numero Real do Controle
            Valido := ValiContMultSist(Tipo+Libe, NumeRea1, NumeRea2, QryAuxi.FieldByName('CodiProd').AsInteger);

            if StrToInt(RetoZero(Tipo)) <= 1 then //por Volume
              NumeLibe := NumeLibe * DiviContMultSist(QryAuxi.FieldByName('CodiProd').AsInteger)
            else if Tipo = '4' then
              NumeLibe := StrToInt(GetSenh_A_ZparaNume(Copy(Tipo+Libe,03,01)));  //Posição 03, tem o usuário por Módulo

            if not Valido then
              Dife := EspaEsqu(FormInteBras(NumeRea1 - NumeLibe),12) + ' *'
            else
              Dife := EspaEsqu('0',12)+'  ';
            List.Add(ZeroEsqu(QryAuxi.FieldByName('CodiProd').AsString,02)+ ' - '+
                              EspaDire(QryAuxi.FieldByName('NomeProd').AsString,30)+ ' - '+
                              EspaEsqu(FormInteBras(NumeRea1),12)+ ' - '+
                              EspaEsqu(FormInteBras(NumeLibe),12)+ ' - '+
                              Dife+ ' - '+
                              EspaDire(Copy(SenhModu_Todo_BuscNomeTipo(Tipo),01,20),20)+ ' - '+
                              EspaEsqu(FormData(PegaParaSenh(000,'DataValiModu0'+NumeSist)),10)
                              );

            //O tipo 4 tem dois controles, que é o usuário por módulo e o acesso completo
            if Tipo = '4' then
            begin
              NumeLibe := StrToInt(GetSenh_A_ZparaNume(Copy(Tipo+Libe,02,01)));  //Acesso Completo, Posição 02
              if not Valido then
                Dife := EspaEsqu(FormInteBras(NumeRea2 - NumeLibe),12) + ' *'
              else
                Dife := EspaEsqu('0',12)+'  ';
              List.Add(EspaEsqu('',02)+ '   '+
                                EspaDire('',30)+ '   '+
                                EspaEsqu(FormInteBras(NumeRea2),12)+ ' - '+
                                EspaEsqu(FormInteBras(NumeLibe),12)+ ' - '+
                                Dife+ ' - '+
                                EspaDire(Copy(SenhModu_Todo_BuscNomeTipo('5'),01,20),20)+ '   '+
                                EspaEsqu('',10)
                                );
            end;
          end;
        except
          List.Add(ZeroEsqu(QryAuxi.FieldByName('CodiProd').AsString,02)+ ' - '+
                            EspaDire(QryAuxi.FieldByName('NomeProd').AsString,30)+ ' - '+
                            '*** ERRO ***');
        end;
        QryAuxi.Next;
      end;
      QryAuxi.Close;
    end;

  finally
    List.Add(Replicate('-',118));
    List.Add('Módulos: '+FormInteBras(NumeModu));
    Result := List.Text;
    List.Free;
    SetPUsu(Usua);
    SetPCodPess(CalcStri('SELECT PCodPess FROM POGePess WHERE (CodiPess = '+IntToStr(GetPUsu())+')'));
    SetPSis(Sist);
    SetPEmp(Empr);
    SetPCodEmpr(CalcStri('SELECT PCodEmpr FROM POCaEmpr WHERE (CodiEmpr = '+IntToStr(GetPEmp())+')'));
    GravPOCaConf();
  end;
end;

//Gerar a Senha do Cliente
function SenhModu_GeraSenhClie(Opca: Integer; Hora: String): String;
var
  Seri: String;
  Digi : Integer;
  Sist : Integer;
begin
  Seri := PegaSeri;
  Hora := FormatDateTime('HHNNSS',SysUtils.Time);
  Sist := GetPSis;
  //  Dígito verificador = 99 - [Opção + Sistema + HH + MM + SS]
  Digi := 99 - SomaCara(IntToStr(Opca) + IntToStr(Sist) + Hora);
  //                            1 e 2 Serie      3 e 4 Minuto       5 e 6 Serie     7 e 8 Hora
  Result := FormNume(Copy(Seri,01,02)+Copy(Hora,03,02)+Copy(Seri,03,02)+Copy(Hora,01,02)+
                     Copy(Seri,05,02)+Copy(Hora,05,02)+Copy(Seri,07,02)+IntToStr(Opca)+ZeroEsqu(IntToStr(Sist),02) + ZeroEsqu(IntToStr(Digi),02),17);
  //                   9 e 10 Serie   11 e 12 Segundo   13 e 14 Série      15 Opção         16 e 17 Sistema                  18 e 19 Dígito
end;

//Contra Senha do Módulo
function SenhModu_ContSenh(OpcaRece, Sist, ValoSenh: Integer; Tipo: String; FinaMvPr: TDateTime; VersSenh: String; Nu01Pess: Integer; ClieSenh: String; PrazSenh: TDateTime):String;
var
  Opca, DataPraz, Digi: String;
  iAux: Integer;
begin
  ClieSenh := DeixLetrNume(ClieSenh);
  //Solicitação de Número de Controle
  if OpcaRece = 3 then
  begin
    if (Copy(VersSenh,01,03) = '6.1') or
       (Copy(VersSenh,01,01) = '7') then
    begin
      if StrToInt(Tipo) <= 1 then
      begin
        iAux := Trunc(DiveZero(ValoSenh, DiviContMultSist(Sist)));
        iAux := SeInte(iAux > 99, 99, iAux);
        Opca := ZeroEsqu(IntToStr(iAux),02)
      end
      else if Tipo = '2' then
        Opca := ZeroEsqu(IntToStr(ValoSenh),02)
      else if Tipo = '3' then
        Opca := ZeroEsqu(IntToStr(ValoSenh),02)
      else if Tipo = '4' then //Por usuário e por usuário no módulo
      begin
        if StrToInt(SubsPalaTudo(Copy(VersSenh,01,06),'.','')) >= 6105 then
          Opca := SeStri(Nu01Pess > 35, 'Z', GetSenh_NumeParaA_Z(Nu01Pess)) + //Acesso Completo
                  SeStri(ValoSenh > 35, 'Z', GetSenh_NumeParaA_Z(ValoSenh)) //Usuário por Módulo
        else
          Opca := SeStri(Nu01Pess > 9, '9', IntToStr(Nu01Pess)) + //Acesso Completo
                  SeStri(ValoSenh > 9, '9', IntToStr(ValoSenh)); //Usuário por Módulo
      end;
      Opca := Tipo + Opca;
    end
    else
      Opca := ZeroEsqu(IntToStr(Trunc(DiveZero(ValoSenh, DiviContMultSist(Sist)))),03)
  end
  else
    Opca := ZeroEsqu(IntToStr(Sist),03);

  //Dígitos da Hora * 199
  Result := ZeroEsqu(IntToStr(StrToInt(Copy(ClieSenh,07,02)+Copy(ClieSenh,03,02)+Copy(ClieSenh,11,02))*199),09);
  //Data de prazo
  if (FinaMvPr > 0) and (PrazSenh > FinaMvPr) then
    DataPraz := FormatDateTime('DD/MM/YYYY',FinaMvPr)
  else
    DataPraz := FormatDateTime('DD/MM/YYYY',PrazSenh);
  //Digito Verificador  ===> [DigiVeriVers - (Soma os Dígitos da DataAuxi + Opcao)] com zeros à esquerda
  Digi := ZeroEsqu(IntToStr(ABS(GetSenh_CalcDigiVeri(VersSenh) - SomaCara(Copy(DataPraz,01,02)+Copy(DataPraz,04,02)+Copy(DataPraz,09,02)+GetSenh_A_ZparaNume(Opca)))),03);
  //                   1, 2 e 3 Cálculo | 4 e 5 Mês            | 6, 7 e 8 Cálculo | 9 e 10 Dia
  Result := FormNume(Copy(Result,01,03) + Copy(DataPraz,04,02) + Copy(Result,04,03) + Copy(DataPraz,01,02)+
                     Copy(Result,07,03) +       Opca           + Digi               + Copy(DataPraz,09,02),19);
  //                11, 12 e 13 Cálculo |14, 15 e 16 Opção  |17, 18 e 19 Dígitos|20 e 21 Ano
end;

//Gerar a senha pelo Where passado (produto, produtos, cliente)
Function SenhModu_ContSenh_GeraWher(WherModu, VersSenh, ClieSenh: String; OpcaRece: Integer; PrazSenh: TDateTime): String;
var
  QryProd : TsgQuery;
  TipoSenh, Modu: String;
begin
  QryProd := TsgQuery.Create(nil);
  try
    QryProd.Close;
    QryProd.SQL.Add('SELECT CLCaProd.CodiProd, NomeProd AS "Módulo", FinaMvPr AS "Final", TipoMvPr AS "Tipo", '+
                    'LibeMvPr AS "Liberado", POCaPess.Nu01Pess');
    QryProd.SQL.Add('FROM CLCaProd INNER JOIN CLCaMvPr          ON CLCaProd.CodiProd = CLCaMvPr.CodiProd');
    QryProd.SQL.Add(              'INNER JOIN POGePess POCaPess ON CLCaMvPr.CodiPess = POCaPess.CodiPess');
    QryProd.SQL.Add(WherModu);
    QryProd.Open;
    Result := '';
    while not QryProd.Eof do
    begin
      TipoSenh := Copy(QryProd.FieldByName('Tipo').AsString,1,1);
      Modu := TipoSenh+
              Copy(ZeroEsqu(QryProd.FieldByName('CodiProd').AsString,02),02,01)+
              Copy(ZeroEsqu(QryProd.FieldByName('CodiProd').AsString,02),01,01);
      Result := Result + SeStri(Result='','',sgLn)
                       + SenhModu_ContSenh(OpcaRece, QryProd.FieldByName('CodiProd').AsInteger,
                                           QryProd.FieldByName('Liberado').AsInteger,
                                           TipoSenh, QryProd.FieldByName('Final').AsDateTime, VersSenh,
                                           QryProd.FieldByName('Nu01Pess').AsInteger, ClieSenh, PrazSenh)+
                           '.'+ZeroEsqu(IntToStr(StrToInt(Modu)*2),03);
      QryProd.Next
    end;
  finally
    QryProd.Close;
    QryProd.Free;
  end;
end;

//Retornar o Divisor do Número de Controle para cada Módulos
Function DiviContMultSist(Sist: Integer): Integer;
begin
  if Sist = 0 then
    Sist := GetPSis() ;

  case Sist of
    81: Result :=  10*1000;  //Genética Pesada
    01: Result :=  10*1000;  //Matrizes Pesadas
    02: Result := 100*1000;  //Incubatório
    03: Result := 100*1000;  //Frango de Corte
    06: Result :=      500;  //Fábrica de Ração
    11: Result :=        4;  //Gerencial
    17: Result :=        4;  //Requisição/Pedidos
    82: Result :=      500;  //Expedição
    07: Result :=   5*1000;  //Abatedouro
    20: Result :=  10*1000;  //Postura Comercial
    23: Result := 100;       //NFe
    28: Result := 100;       //Folha de Pagamento
    29: Result := 100;       //Cartão Ponto
    89: Result := 100;       //Call Center
    41: Result := 100;       //Pecuaria
  else
    Result := 1;
  end;
end;

//Retornar se o Módulo é válido ou não
Function ValiContMultSist(NumeRealPara: String; var NumeRea1, NumeRea2: Real; Sist: Integer=0; NumeLibe: Integer = 0): Boolean;
var
  NumeLibeComp, Tipo: Integer;
  SQL1, SQL2: String;
  PassLibe: Boolean;
begin
  if Sist = 0 then
    Sist := GetPSis();

  PassLibe := NumeLibe > 0;
  if not PassLibe then  //Não foi passado o número Liberado
    NumeLibe := StrToInt(GetSenh_A_ZparaNume(RetoZero(Copy(EspaEsqu(NumeRealPara,03),02,02))));
  Tipo     := StrToInt(                      RetoZero(Copy(EspaEsqu(NumeRealPara,03),01,01)));

  if NumeLibe = 0 then
  begin
    Result := False;
    NumeRea1 := 0;
    NumeRea2 := 0;
  end
  else
  begin
    NumeRea1 := 0;
    NumeRea2 := 0;
    if Tipo <= 1 then  //Por Volume
    begin
      if not PassLibe then
        NumeLibe := NumeLibe * DiviContMultSist(Sist);
      NumeRea1 := NumeContMultSist(Sist, False, SQL1, SQL2);
      Result   := NumeLibe >= NumeRea1;
    end
    else if Tipo = 2 then  //Por Usuário
    begin
      NumeRea1 := NumeContMultSist(98, False, SQL1, SQL2);
      Result   := NumeLibe >= NumeRea1;
    end
    else if Tipo = 3 then  //Por Usuário no módulo
    begin
      NumeRea1 := NumeContMultSist(100+Sist, False, SQL1, SQL2);
      Result   := NumeLibe >= NumeRea1;
    end
    else if Tipo = 4 then  //Por Usuário e por Usuário no Módulo
    begin
      if not PassLibe then
        NumeLibe := StrToInt(GetSenh_A_ZparaNume(RetoZero(Copy(NumeRealPara,03,01)))); //Na posição 03, tem usuário por módulo
      NumeRea1 := NumeContMultSist(100+Sist, False, SQL1, SQL2, ' AND ((CorrPess IS NULL) OR (CorrPess <> ''Completo''))');  //100+Prod vai entrar no Else que é verificado por módulo
      Result   := NumeLibe >= NumeRea1;
      if Result then
      begin
        NumeLibeComp := StrToInt(GetSenh_A_ZparaNume(RetoZero(Copy(NumeRealPara,02,01))));  //Acesso Completo (posição 02)
        NumeRea2     := NumeContMultSist(98, False, SQL1, SQL2, ' AND (CorrPess = ''Completo'')');
        Result       := NumeLibeComp >= NumeRea2;
      end;
    end
    else
      Result := False;
  end;
end;

//Retornar o Número de Controle para cada Módulo
//Wher: Where opcional, para o caso dos acesso para usuários
Function NumeContMultSist(Sist: Integer; RetoSQL: Boolean; var SQL1, SQL2: String; Wher: String=''): Integer;
var
  Valo, Val1: Real;
  Auxi: String;
  DataAtua: TDateTime;
  InicMes, FinaMes: TDateTime;
  Tipo: Integer; //0=Maior, 1=Soma, 2=Menor, 3=Média, 4=Primeiro Zerado
begin
  Result := 0;
  if Sist = 0 then
    Sist := GetPSis;

  //DataAtua := 40330;
  DataAtua := CalcData('SELECT '+DataAtuaSQL()+' FROM DUAL');
  DataAtua := IncMonth(DataAtua,-1);
  InicMes  := EncodeDate(Year(DataAtua),Month(DataAtua),01);
  FinaMes  := EncodeDate(Year(DataAtua),Month(DataAtua),DaysInAMonth(Year(DataAtua),Month(DataAtua)));

  Val1 := 0;
  Tipo := 0; //Maior
  SQL1 := '';
  SQL2 := '';
  case Sist of
    //Matrizes Pesadas
    01: SQL1 := 'SELECT SUM(FemeLote+MachLote) FROM MPViLote WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
    //Genética Pesada
    81: SQL1 := 'SELECT SUM(FemeLote+MachLote) FROM MPViLote WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
    //Frango de Corte
    03: SQL1 := 'SELECT SUM(FemeLote+MachLote) FROM FCViLote WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
    //Postura Comercial
    20: SQL1 := 'SELECT SUM(FemeLote+MachLote) FROM MPViLote WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
    //Incubatório
    02: begin
          Auxi := FormNumeSQL(PegaParaNume(000,'IPGeraTipoIncu'));
          if Auxi <> '0' then
            Auxi := ' AND (INGeAmbi.CodiSeto = '+Auxi+')'
          else
            Auxi := '';
          SQL1 := 'SELECT SUM(QtEnTrAm) FROM INCaTrAm INNER JOIN INGeAmbi ON INCaTrAm.CodiAmbi = INGeAmbi.CodiAmbi '+
                  'WHERE (MarcTrAm < 2) AND (DataTrAm BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+
                  ')'+Auxi;
        end;
    //Fábrica de Ração
    06: SQL1 := 'SELECT SUM(QTTOMVES)/1000 FROM POCAMVES INNER JOIN POGEESTO ON POCAMVES.CODIESTO = POGEESTO.CODIESTO '+
                                                        'INNER JOIN POGEPROD ON POGEPROD.CODIPROD = POCAMVES.CODIPROD '+
                                                        'INNER JOIN POCATPMV ON POCATPMV.CODITPMV = POGEESTO.CODITPMV '+
                'WHERE (SistProd LIKE ''%06%'') AND (TipoTpMv BETWEEN 0 AND 10) AND (CompProd = 1) AND (ReceEsto BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')';
    //Abatedouro
    07: begin
          SQL1 := 'SELECT SUM(AVESFEPR)/4.33 FROM ABGEFEPR '+
                  'WHERE (DataFePr BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')';
          SQL2 := 'SELECT SUM(EntrApon*LiquApon)/2.5/4.33 FROM ABCAAPON '+
                  'WHERE (SituApon IN (''APON'',''ACER'')) AND (DataApon BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')';
          Tipo := 4; //Retorna o segundo, se o primeiro estiver Zerado
        end;
    //Expedição
    82: SQL1 := 'SELECT SUM(LiquPesa)/1000 FROM POGePesa '+
                  'WHERE (TextPesa = ''Peso Final'') AND (TipoPesa <> ''CER'')'+
                  '  AND (DataPesa BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+
                  ')';
    //NFe
    23: SQL1 := 'SELECT COUNT(*) FROM POGeNota WHERE (ChavNota IS NOT NULL) AND (EmisNota BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')';
    //Folha de Pagamanto --Colaboradores Ativos
    28: SQL1 := 'SELECT COUNT(*) FROM FPGeCola INNER JOIN POGePess ON FPGeCola.CodiPess = POGePess.CodiPess WHERE (AtivPess <> 0) AND (AtivCola <> 0)';
    //Cartão Ponto --Colaboradores Ativos
    29: SQL1 := 'SELECT COUNT(*) FROM FPGeCola INNER JOIN POGePess ON FPGeCola.CodiPess = POGePess.CodiPess WHERE (AtivPess <> 0) AND (AtivCola <> 0)';
    //PDA Coletor --Vendedores/Supervisores
    70: SQL1 := 'SELECT COUNT(*) FROM POGePess WHERE ((SupePess <> 0) or (VendPess <> 0)) AND (AtivPess <> 0)  AND (StrLen(CorrPess) > 0)';
    71: SQL1 := 'SELECT COUNT(*) FROM POGePess WHERE ((SupePess <> 0) or (VendPess <> 0)) AND (AtivPess <> 0)  AND (StrLen(CorrPess) > 0)';
    88: SQL1 := 'SELECT COUNT(*) FROM POGePess WHERE ((SupePess <> 0) or (VendPess <> 0)) AND (AtivPess <> 0)  AND (StrLen(CorrPess) > 0)';
    //SAG Coletor - Liberado
    87: SQL1 := 'SELECT 0 FROM POCaAuxi';
    //POR USUÁRIO
    98: SQL1 := 'SELECT COUNT(*) FROM POGePess WHERE '+cFiltPessSenh + Wher;
    //Pecuária
    41: SQL1 := 'SELECT COUNT(*) FROM PECaGado WHERE (AtivGado <> 0)';
  else  //Usuários
    //Acessos para o Usuário (deste Módulo)
    SQL1 := 'SELECT COUNT(DISTINCT ACPR.CODIPESS) FROM POCAACPR ACPR INNER JOIN POGEPESS PESS ON ACPR.CODIPESS = PESS.CODIPESS '+
            'WHERE  '+SubsPala(cFiltPessSenh, 'POGePess.', 'Pess.')+' AND (ACPR.CODIPESS IS NOT NULL) AND (ACPR.ACESACPR <> 0) AND (ACPR.CODIPROD = '+IntToStr(SeInte(Sist>100,Sist-100,Sist))+')'
            +Wher;
    //Acessos para o Grupo (deste Módulo)
    SQL2 := 'SELECT COUNT(DISTINCT POGEPESS.CODIPESS) FROM POCAACPR INNER JOIN POGEPESS ON POCAACPR.CODIGRUS = POGEPESS.CODIGRUS '+
            'WHERE  '+cFiltPessSenh+' AND (POCAACPR.CODIGRUS IS NOT NULL) AND (POCAACPR.ACESACPR <> 0) AND (POCAACPR.CODIPROD = '+IntToStr(SeInte(Sist>100,Sist-100,Sist))+')'+
            '  AND (0 = (SELECT COUNT(*) FROM POCAACPR ACPR INNER JOIN POGEPESS PESS ON ACPR.CODIPESS = PESS.CODIPESS '+
                           'WHERE  '+SubsPala(cFiltPessSenh, 'POGePess.', 'Pess.')+' AND (ACPR.CODIPESS = POGePess.CodiPess) AND (ACPR.ACESACPR <> 0) AND (ACPR.CODIPROD = '+IntToStr(SeInte(Sist>100,Sist-100,Sist))+')))'
            +Wher;
    Tipo := 1; //Soma
  end;

  if not RetoSQL then
  begin
    Valo := CalcInte(SQL1);
    if Trim(SQL2) <> '' then
    begin
      if (Tipo <> 4) or ((Tipo = 4) and (Valo = 0)) then  //Só retorna o segundo, se o primeiro estiver Zerado
        Val1 := CalcInte(SQL2);

      //0=Maior, 1=Soma, 2=Menor, 3=Média, 4=Primeiro Zerado
      if Tipo = 0 then
      begin
        if Valo < Val1 then
          Valo := Val1;
      end
      else if Tipo = 1 then
        Valo := Valo + Val1
      else if Tipo = 2 then
      begin
        if Valo > Val1 then
          Valo := Val1;
      end
      else if Tipo = 3 then
        Valo := (Valo + Val1) / 2
      else if (Tipo = 4) and (Valo = 0) then
        Valo := Val1;
    end;
    //Result := Trunc(DiveZero(Valo, DiviContMultSist(Sist)));
    Result := Trunc(Valo);
  end;
end;

//Retornar o Calculo do Digito Verificador da Senha
function GetSenh_CalcDigiVeri(Vers: String): Integer;
var
  Valo: Integer;
  Digi: Integer;
begin
  //6.1.25.012
  Delete(Vers,Pos('.',Vers),01);
  Delete(Vers,Pos('.',Vers),01);
  Vers := Copy(Vers, 01, Pos('.',Vers)-1); //Vers = 6125


  Valo := 0;
  if StrToInt(Copy(Vers,01,02)) < 61 then
    Valo := 999
  else
  begin
    if isRx9() then  //INTOTUM
    begin
      if StrToInt(Copy(Vers,01,02)) = 61 then
        Valo := 987
      else if StrToInt(Copy(Vers,01,02)) = 71 then
        Valo := 789;
    end
    else if StrToInt(Copy(Vers,01,02)) = 61 then
      Valo := 610
    else if StrToInt(Copy(Vers,01,02)) = 70 then
      Valo := 700
    else if StrToInt(Copy(Vers,01,02)) = 71 then
      Valo := 710;
  end;

  //Valo - Soma dos 3 primeiro nmveis - Quadrado da Soma do Quarto Dmgito + 4
  //Exemplo: 6.1.25 = 999 - (6+1+2+5) - (5*5) + 4
  Digi := StrToInt(Copy(Vers,04,01));
  Result := ABS(Valo - SomaCara(Vers) - Sqr(Digi + Digi) + 4);
  if (Result > 999) then
    Result := 999;
end;

//Letras de A a Z para Nzmero (10 a 35)
function GetSenh_A_ZparaNume(Valo: String): String;
var
  i : Integer;
begin
  Result := '';
  for I := 1 to Length(Valo) do
  begin
    case Ord(Valo[i]) of
      48..057: Result := Result + Valo[i];
      65..090: Result := Result + IntToStr(Ord(Valo[i]) - 55); //A =  65 - 55 = 10  --26 letras do alfabeto
                                                               //Z =  90 - 55 = 35
      97..122: Result := Result + IntToStr(Ord(Valo[i]) - 87); //a =  97 - 61 = 36
                                                               //z = 122 - 61 = 61
    else
      Result := Result + '0';
    end;
  end;
end;

//Nzmero para Letra (10 a 35, A a Z)
function GetSenh_NumeparaA_Z(Nume: Integer): String;
begin
  case Nume of
    00..09: Result := IntToStr(Nume);
    10..35: Result := Chr(Nume+55);
    36..61: Result := Chr(Nume+61);
  else
    Result := '0';
  end;
end;

//******************************************************************************************
//  F I M   D A   V A L I D A Ç Ã O   D A S   S E N H A S
//******************************************************************************************

//Calcular a Rastreabilidade Genericamente
procedure CalcRastGera(TabeRast, SaidRast, EntrRast, QtdeRast: String;
                       SQL_Apag, SQL_Said, SQL_Entr: WideString);
var
  Sald, ValoFina: Real;
begin
  ExibMensHint('Apagando Rastreabilidades');
  ExecSQL_(SQL_Apag);
  with DtmPoul do
  begin
    ExibMensHint('Abrindo Dados');
    QryCalc.SQL.Clear;
    QryCalc.SQL.Add(SQL_Said);
    QryCalc.Open;
    ExibProgPrin(0, QryCalc.RecordCount);
    while not(QryCalc.Eof) do
    begin
      if ExibProgPrin(1, 0, QryCalc.FieldByName('Prod').AsString+' - ' + FormDataBras(QryCalc.FieldByName('Data').AsDateTime)) then Exit;
      Sald := QryCalc.FieldByName('Qtde').AsFloat;
      ExibProgPri1(0, Trunc(Sald));
      while Sald > 0 do
      begin
        QryAuxi.SQL.Clear;
        QryAuxi.SQL.Add(SQL_Entr);
        QryAuxi.Open;
        if QryAuxi.IsEmpty then
        begin
          Sald := 0;
          QryCalc.FindLast; //Sai do Loop deste Produto, pois não tem mais Entradas para as Saídas
        end
        else
        begin
          if Sald < QryAuxi.FieldByName('Sald').AsFloat then
          begin
            ValoFina := Sald;
            Sald := 0;
          end
          else
          begin
            ValoFina := QryAuxi.FieldByName('Sald').AsFloat;
            Sald     := Sald - QryAuxi.FieldByName('Sald').AsFloat;
          end;
          InseDadoTabe(TabeRast,
                      [SaidRast,QuotedStr(QryCalc.FieldByName('Codi').AsString),
                       EntrRast,QuotedStr(QryAuxi.FieldByName('Codi').AsString),
                       QtdeRast,FormNumeSQL(ValoFina)
                      ],'');
        end;
        if ExibProgPri1(Trunc(QryCalc.FieldByName('Qtde').AsFloat - Sald), 0, QryAuxi.FieldByName('Codi').AsString, True) then Exit;
        QryAuxi.Close;
      end;
      QryCalc.Next;
    end;
    QryCalc.Close;
  end;
  ExibMensHint('Rastreabilidade Concluído!');
end;

//Calcular a Rastreabilidade: Buscar a Origem na mesma Tabela (sequencia de processos)
//TabeOrig: SECaPrBe
//CampPrin: CodiPrBe
//CampOrig: CodAPrBe -> Tem o Anterior (Origem)
//TabeRast: SECaRaPB
//CodiPrin: 100 -> Código a ser rastreado
//CodiOrig:  99 -> Código Origem (Anterior)
//Orde: Ordem do Processo (Orde = 0, processo inicial, apagará os dados para gerar novamente)
procedure CalcRast_BuscOrig(TabeOrig, CampPrin, CampOrig, TabeRast: String;
                            CodiPrin: Integer; CodiOrig: Integer = 0; Orde: Integer = 0);
var
  NovoOrig: Integer;
begin
  if Orde = 0 then
  begin
    ExibMensHint('Apagando Rastreabilidades');
    ExecSQL_('DELETE FROM '+TabeRast+' WHERE ('+CampPrin+' = '+IntToStr(CodiPrin)+')');

    if CodiOrig = 0 then
      CodiOrig := CalcInte('SELECT '+CampOrig+' FROM '+TabeOrig+' WHERE ('+CampPrin+' = '+IntToStr(CodiPrin)+')');

    InseDadoTabe(TabeRast,
                [CampPrin, IntToStr(CodiPrin),
                 CampOrig, IntToStr(CodiOrig),
                 'Orde'+Copy(TabeRast,05,04), IntToStr(Orde)
                ],'');
  end;
  ExibMensHint('Rastreabiliade: '+FormInteBras(CodiPrin)+ '  -  '+FormInteBras(Orde));

  //Busca quem Originou a Origem Passada (passo antes do anterior)
  NovoOrig := CalcInte('SELECT '+CampOrig+' FROM '+TabeOrig+' WHERE ('+CampPrin+' = '+IntToStr(CodiOrig)+')');

  if NovoOrig <> 0 then
  begin
    InseDadoTabe(TabeRast,
                [CampPrin, IntToStr(CodiPrin),
                 CampOrig, IntToStr(NovoOrig),
                 'Orde'+Copy(TabeRast,05,04), IntToStr(Orde+10)
                ],'');
    //Chama a Recursividade para buscar os passos anteriores
    CalcRast_BuscOrig(TabeOrig, CampPrin, CampOrig, TabeRast,
                      CodiPrin, NovoOrig, Orde+10);
  end;
end;

//Gera um arquivo XML baseado no SQL Enviado
Function GeraArquXML_SQL(EndeArqu: String; SQL: String; iMode: TModeloXML): Boolean;
var
  x :integer;
  XMLDoc : TXMLDocument;
  XMLNode, XMLData, XMLNodeSchema, XMLNodeAtribute, XMLNodeElement, XMLNodeDataType, XMLNodersdata, PrinXMLNode : IXMLNode;
begin
  Result := True;
  with DtmPoul do
  begin
    QryAuxi.SQL.Text := SQL;
    QryAuxi.Open;
    if EndeArqu = '' then
      EndeArqu := QryAuxi.FieldByName('EndeArqu').AsString;
    EndeArqu := ArquValiEnde(EndeArqu);
    if QryAuxi.RecordCount > 0 then
    begin
      ExibProgPrin(0, QryAuxi.RecordCount, 'Gerando arquivo '+EndeArqu);
      XMLDoc := TXMLDocument.Create(nil);
      XMLDoc.Active := True;

      if iMode = mxSimulador then
      begin
        XMLDoc.Version := '1.0';
//        PrinXMLNode := XMLDoc.AddChild('xml');
//        PrinXMLNode.Attributes['version'] := '1.0';
//        XMLNodersdata := PrinXMLNode.AddChild('data');
        XMLNodersdata := XMLDoc.AddChild('data');

        while not QryAuxi.Eof do
        begin
          XMLNode := XMLNodersdata.AddChild('row');
          for x := 0 to QryAuxi.Fields.Count - 1 do
          begin
            if (AnsiUpperCase(QryAuxi.Fields[x].DisplayName) <> 'ENDEARQU') then
            begin
              XMLData := XMLNode.AddChild(QryAuxi.Fields[x].DisplayName);
              if QryAuxi.Fields[x].IsNull then
                XMLData.NodeValue := '(NULL)'
              else if (QryAuxi.Fields[x].DataType = ftDate) then
                XMLData.NodeValue := FormatDateTime('YYYY-MM-DD',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime)
              else if (QryAuxi.Fields[x].DataType = ftDate) or
                 (QryAuxi.Fields[x].DataType = ftDateTime) or
                 (QryAuxi.Fields[x].DataType = ftTime) then
              begin
                XMLData.NodeValue := FormatDateTime('YYYY-MM-DD',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime) + 'T' + FormatDateTime('hh:mm:ss',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime);
              end
              else
              begin
                if (QryAuxi.Fields[x].DataType = ftCurrency) or
                   (QryAuxi.Fields[x].DataType = ftFloat) or
                   (QryAuxi.Fields[x].DataType = ftFMTBCD) or
                   (QryAuxi.Fields[x].DataType = ftBCD) then
                begin
                  XMLData.NodeValue := StringReplace(FormatFloat('############.####;0',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsFloat),',','.',[rfReplaceAll]);
                end
                else
                begin
                  XMLData.NodeValue := QryAuxi[QryAuxi.Fields[x].DisplayName];
                end;
              end;
            end;
          end;
          if ExibProgPrin(1) then
          begin
            Result := False;
            Exit;
          end;
          QryAuxi.Next;
        end;
      end
      else
      begin
        PrinXMLNode := XMLDoc.AddChild('xml');
        PrinXMLNode.Attributes['xmlns:s'] := 'uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882';
        PrinXMLNode.Attributes['xmlns:dt'] := 'uuid:C2F41010-65B3-11d1-A29F-00AA00C14882';
        PrinXMLNode.Attributes['xmlns:rs'] := 'urn:schemas-microsoft-com:rowset';
        PrinXMLNode.Attributes['xmlns:z'] := '#RowsetSchema';

        XMLNodeSchema := PrinXMLNode.AddChild('s:Schema');
        XMLNodeSchema.Attributes['id'] := 'RowsetSchema';

        XMLNodeElement := XMLNodeSchema.AddChild('s:ElementType');
        XMLNodeElement.Attributes['name'] := 'row';
        XMLNodeElement.Attributes['content'] := 'eltOnly';
        XMLNodeElement.Attributes['rs:updatable'] :='true';
        XMLNodeElement.Attributes['rs:UpdateCriteria'] := '0';

        for x := 0 to QryAuxi.Fields.Count - 1 do
        begin
          if (AnsiUpperCase(QryAuxi.Fields[x].DisplayName) <> 'ENDEARQU') then
          begin
            XMLNodeAtribute := XMLNodeElement.AddChild('s:AttributeType');
            XMLNodeAtribute.Attributes['name'] := QryAuxi.Fields[x].DisplayName;
            XMLNodeAtribute.Attributes['rs:number'] := x+1;
            XMLNodeAtribute.Attributes['rs:writeunknown'] := 'true';
            XMLNodeAtribute.Attributes['rs:basetable'] := 'TABELA';
            XMLNodeAtribute.Attributes['rs:basecolumn'] := QryAuxi.Fields[x].DisplayName;

            XMLNodeDataType := XMLNodeAtribute.AddChild('s:datatype');
            //data
            if (QryAuxi.Fields[x].DataType = ftDate) or
               (QryAuxi.Fields[x].DataType = ftDateTime) or
               (QryAuxi.Fields[x].DataType = ftTime) then
            begin
              XMLNodeDataType.Attributes['dt:type'] := 'dateTime';
              XMLNodeDataType.Attributes['rs:dbtype'] := 'timestamp';
              XMLNodeDataType.Attributes['dt:maxLength'] := '16';
              XMLNodeDataType.Attributes['rs:scale'] := '0';
              XMLNodeDataType.Attributes['rs:precision'] := '19';
              XMLNodeDataType.Attributes['rs:fixlenght'] := 'true';
            end
            else
            begin
              XMLNodeDataType.Attributes['dt:type'] := 'string';
              XMLNodeDataType.Attributes['dt:maxLength'] := '4000';
            end;
          end;
        end;
        XMLNodersdata := PrinXMLNode.AddChild('rs:data');

        while not QryAuxi.Eof do
        begin
          if (AnsiUpperCase(QryAuxi.Fields[0].DisplayName) <> 'ENDEARQU') then
          begin
            XMLNode := XMLNodersdata.AddChild('z:row');
            for x := 0 to QryAuxi.Fields.Count - 1 do
            begin
              if (QryAuxi.Fields[x].DataType = ftDate) or
                 (QryAuxi.Fields[x].DataType = ftDateTime) or
                 (QryAuxi.Fields[x].DataType = ftTime) then
              begin
                if QryAuxi.Fields[x].IsNull then
                  XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := ''
                else
                  XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := FormatDateTime('YYYY-MM-DD',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime) + 'T' + FormatDateTime('hh:mm:ss',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime);
              end
              else
              begin
                if (QryAuxi.Fields[x].DataType = ftCurrency) or
                   (QryAuxi.Fields[x].DataType = ftFloat) or
                   (QryAuxi.Fields[x].DataType = ftFMTBCD) or
                   (QryAuxi.Fields[x].DataType = ftBCD) then
                begin
                  XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := StringReplace(FormatFloat('############.####;0',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsFloat),',','.',[rfReplaceAll]);
                end
                else
                begin
                  XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := QryAuxi[QryAuxi.Fields[x].DisplayName];
                end;
              end;
            end;
          end;
          if ExibProgPrin(1) then
          begin
            Result := False;
            Exit;
          end;
          QryAuxi.Next;
        end;
      end;

      XMLDoc.SaveToFile(EndeArqu);
      XMLDoc.CleanupInstance;
    end;
    QryAuxi.Close;
    ExibMensHint('...');
  end;
end;

Function GeraArquXML_SQL(EndeArqu: String; SQL: String): Boolean;
var
  x :integer;
  XMLDoc : TXMLDocument;
  XMLNode,XMLNodeSchema, XMLNodeAtribute, XMLNodeElement, XMLNodeDataType, XMLNodersdata, PrinXMLNode : IXMLNode;
begin
  EndeArqu := ArquValiEnde(EndeArqu);
  Result := True;
  with DtmPoul do
  begin
    QryAuxi.SQL.Text := SQL;
    QryAuxi.Open;
    if QryAuxi.RecordCount > 0 then
    begin
      ExibProgPrin(0, QryAuxi.RecordCount, 'Gerando arquivo '+EndeArqu);
      XMLDoc := TXMLDocument.Create(nil);
      XMLDoc.Active := True;

      PrinXMLNode := XMLDoc.AddChild('xml');
      PrinXMLNode.Attributes['xmlns:s'] := 'uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882';
      PrinXMLNode.Attributes['xmlns:dt'] := 'uuid:C2F41010-65B3-11d1-A29F-00AA00C14882';
      PrinXMLNode.Attributes['xmlns:rs'] := 'urn:schemas-microsoft-com:rowset';
      PrinXMLNode.Attributes['xmlns:z'] := '#RowsetSchema';

      XMLNodeSchema := PrinXMLNode.AddChild('s:Schema');
      XMLNodeSchema.Attributes['id'] := 'RowsetSchema';

      XMLNodeElement := XMLNodeSchema.AddChild('s:ElementType');
      XMLNodeElement.Attributes['name'] := 'row';
      XMLNodeElement.Attributes['content'] := 'eltOnly';
      XMLNodeElement.Attributes['rs:updatable'] :='true';
      XMLNodeElement.Attributes['rs:UpdateCriteria'] := '0';

      for x := 0 to QryAuxi.Fields.Count - 1 do
      begin
        XMLNodeAtribute := XMLNodeElement.AddChild('s:AttributeType');
        XMLNodeAtribute.Attributes['name'] := QryAuxi.Fields[x].DisplayName;
        XMLNodeAtribute.Attributes['rs:number'] := x+1;
        XMLNodeAtribute.Attributes['rs:writeunknown'] := 'true';
        XMLNodeAtribute.Attributes['rs:basetable'] := 'TABELA';
        XMLNodeAtribute.Attributes['rs:basecolumn'] := QryAuxi.Fields[x].DisplayName;

        XMLNodeDataType := XMLNodeAtribute.AddChild('s:datatype');
        //data
        if (QryAuxi.Fields[x].DataType = ftDate) or
           (QryAuxi.Fields[x].DataType = ftDateTime) or
           (QryAuxi.Fields[x].DataType = ftTime) then
        begin
          XMLNodeDataType.Attributes['dt:type'] := 'dateTime';
          XMLNodeDataType.Attributes['rs:dbtype'] := 'timestamp';
          XMLNodeDataType.Attributes['dt:maxLength'] := '16';
          XMLNodeDataType.Attributes['rs:scale'] := '0';
          XMLNodeDataType.Attributes['rs:precision'] := '19';
          XMLNodeDataType.Attributes['rs:fixlenght'] := 'true';
        end
        else
        begin
          XMLNodeDataType.Attributes['dt:type'] := 'string';
          XMLNodeDataType.Attributes['dt:maxLength'] := '4000';
        end;
      end;
      XMLNodersdata := PrinXMLNode.AddChild('rs:data');

      while not QryAuxi.Eof do
      begin
        XMLNode := XMLNodersdata.AddChild('z:row');
        for x := 0 to QryAuxi.Fields.Count - 1 do
        begin
          if (QryAuxi.Fields[x].DataType = ftDate) or
             (QryAuxi.Fields[x].DataType = ftDateTime) or
             (QryAuxi.Fields[x].DataType = ftTime) then
          begin
            if QryAuxi.Fields[x].IsNull then
              XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := ''
            else
              XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := FormatDateTime('YYYY-MM-DD',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime) + 'T' + FormatDateTime('hh:mm:ss',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsDateTime);
          end
          else
          begin
            if (QryAuxi.Fields[x].DataType = ftCurrency) or
               (QryAuxi.Fields[x].DataType = ftFloat) or
               (QryAuxi.Fields[x].DataType = ftFMTBCD) or
               (QryAuxi.Fields[x].DataType = ftBCD) then
            begin
              XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := StringReplace(FormatFloat('############.####;0',QryAuxi.FieldByName(QryAuxi.Fields[x].DisplayName).AsFloat),',','.',[rfReplaceAll]);
            end
            else
            begin
              XMLNode.Attributes[QryAuxi.Fields[x].DisplayName] := QryAuxi[QryAuxi.Fields[x].DisplayName];
            end;
          end;
        end;
        if ExibProgPrin(1) then
        begin
          Result := False;
          Exit;
        end;
        QryAuxi.Next;
      end;
      XMLDoc.SaveToFile(EndeArqu);
      XMLDoc.CleanupInstance;
    end;
    QryAuxi.Close;
    ExibMensHint('...');
  end;
end;

//Importa arquivo XML
Function ImpoArquXML_(EndeArqu: String; SQL: String): String;
begin
  EndeArqu := ArquValiEnde(EndeArqu);
  Result := '';
  with DtmPoul do
  begin
    QryAuxi.SQL.Text := SQL;
    QryAuxi.Open;
    if QryAuxi.RecordCount > 0 then
    begin
      ExibProgPrin(0, QryAuxi.RecordCount, 'Importando arquivo '+EndeArqu);

      while not QryAuxi.Eof do
      begin
        Result := NFe_XML_ImpoXML_V20(EndeArqu, True, SubsPalaTudo(ExtractFileName(EndeArqu),'.xml',''),
                                      VeriExisCampTabe_Valo(QryAuxi, 'Tabela', 'FSCaImNF'),
                                      VeriExisCampTabe_Valo(QryAuxi, 'Movimento', 'FSCaMvIN'));
        if ExibProgPrin(1) then
        begin
          Result := 'Cancelado';
          Exit;
        end;
        QryAuxi.Next;
      end;
    end;
    QryAuxi.Close;
    ExibMensHint('...');
  end;
end;

//Executa a ManuDadoTabe pelo PLSAG
Function Ex_ManuDado(iForm: TsgForm; Linh: String): Boolean;
var
  Quer: TsgQuery;
  vDataSet: TDataSet;
  ListCamp, ListCampChav: PlusUni.TStringArray;
  NomeTabe: String;
begin
  if AnsiUpperCase(iForm.VariStri[0011]) = 'QY' then
  begin
    NomeTabe := Linh;
    with iForm do
      Quer := TsgQuery(FindComponent(iForm.VariStri[0011]));
    vDataSet := Quer;
  end
  else if AnsiUpperCase(iForm.VariStri[0011]) = 'DG' then
  begin
    NomeTabe := Linh;
    with iForm do
      vDataSet := TDataSource(FindComponent(iForm.VariStri[0011])).DataSet;
  end
  else
  begin
    NomeTabe := iForm.VariStri[0011];
    Quer := TsgQuery.Create(nil);
    Quer.Name := 'QryEx_ManuDado';
    Quer.SQL.Text := Linh;
    Quer.Open;
    vDataSet := Quer;
  end;

  try
    vDataSet.First;
    while not vDataSet.Eof do
    begin
      DataSet_ArraList(vDataSet, ListCampChav, True);
      DataSet_ArraList(vDataSet, ListCamp    , False);
      //Sidiney: Passado o Camp para executar as Triggers
      DmPlus.ManuDadoTabe(NomeTabe,
                          ListCampChav,
                          ListCamp, 'Codi'+Copy(NomeTabe,05,100));
      vDataSet.Next;
    end;
  finally
  end;
  Result := True;
end;

//Converter os dados do DataSet na lista de campos valores (para os InseDadoTabe)
//Chav: se verdadeiro, retorna a lista de campos chaves (chav_), caso contrário, ´so
function DataSet_ArraList(Dts: TDataSet; var ArraList: TStringArray; Chav: Boolean = False): Boolean;
var
  i: Integer;
  Tama: Integer;
  NomeCamp: String;
begin
  Result := True;
  Tama := 0;
  for I := 0 to Dts.Fields.Count - 1 do
  begin
    if (not Dts.Fields[i].IsNull) then
    begin
	  if GetPBas() = 2 then
        if ((AnsiUpperCase(Copy(Dts.Fields[i].FieldName,01,04)) =  'CODI') and (Dts.Fields[i].AsFloat < 0)) then
          Continue; //SQL Server inclui valores negativos como placeholder dos campos código, que causa erro ao incluir;

	  if (    Chav and (AnsiUpperCase(Copy(Dts.Fields[i].FieldName,01,05)) =  'CHAV_')) or
	     (not Chav and (AnsiUpperCase(Copy(Dts.Fields[i].FieldName,01,05)) <> 'CHAV_'))then
	  begin
	    if Chav then
	      NomeCamp := Copy(Dts.Fields[i].FieldName,06,100)
	    else
	      NomeCamp := Dts.Fields[i].FieldName;
	    Inc(Tama, 2);
	    SetLength(ArraList, Tama);
	    ArraList[Tama-2] := NomeCamp;
	    if TipoDadoCara(Dts.Fields[i]) in ['N','I'] then
	      ArraList[Tama-1] := FormNumeSQL(Dts.Fields[i].AsFloat)
	    else if TipoDadoCara(Dts.Fields[i]) = 'D' then
	      ArraList[Tama-1] := FormDataSQL(Dts.Fields[i].AsDateTime)
	    else
	    begin
	  	  if (GetPBas() = 4) and (NomeCamp = 'HISTESTO') and (Length(dts.FieldByName('HISTESTO').AsString) > 4000) then
	  	    ArraList[Tama-1] := QuotedStr('')
	  	  else
	  	    ArraList[Tama-1] := QuotedStr(Dts.Fields[i].AsString);
	    end;
	  end;
    end;
  end;
end;

//Formatar o valor do campo conforme o tipo dele para String, para ser usado em um Update ou Insert (SQL)
function DataSet_FormValoCamp_Stri(Dts: TDataSet; Camp: String): String;
begin
  Result := '';
  if Dts.FieldByName(Camp).IsNull then
    Result := 'NULL'
  else
  begin
    if TipoDadoCara(Dts.FieldByName(Camp)) in ['N','I'] then
      Result := FormNumeSQL(Dts.FieldByName(Camp).AsFloat)
    else if TipoDadoCara(Dts.FieldByName(Camp)) = 'D' then
      Result := FormDataSQL(Dts.FieldByName(Camp).AsDateTime)
    else
      Result := QuotedStr(Dts.FieldByName(Camp).AsString);
  end;
end;

//Gravar todos os registros do Origem no Destino, a partir do indicado (CampInic)
Procedure CompAtuaTabeGravRegi(Orig, Dest: TADOQuery; CampInic: Byte; Fina, CompMenuTabe:String; AtuaTudo: Boolean); overload;
var
  i : Integer;
  MenuTabe: String;
begin
  if Fina='TABE' then
    MenuTabe := Orig.FieldByName('MenuTabe').AsString;

  for i := CampInic to (Orig.FieldCount - 1) do
  begin
    if CompAtuaTabeQualCamp(Orig.Fields[i].FieldName, Fina, MenuTabe, CompMenuTabe, AtuaTudo) then
    begin
      Dest.FieldByName(Orig.Fields[i].FieldName).ReadOnly := False;
      Dest.FieldByName(Orig.Fields[i].FieldName).AsString := Orig.Fields[i].AsString;
    end;
  end;
end;
Procedure CompAtuaTabeGravRegi(Orig, Dest: TsgQuery; CampInic: Byte; Fina, CompMenuTabe:String; AtuaTudo: Boolean); overload;
var
  i : Integer;
  MenuTabe: String;
begin
  if Fina='TABE' then
    MenuTabe := Orig.FieldByName('MenuTabe').AsString;

  for i := CampInic to (Orig.FieldCount - 1) do
  begin
    if CompAtuaTabeQualCamp(Orig.Fields[i].FieldName, Fina, MenuTabe, CompMenuTabe, AtuaTudo) then
    begin
      Dest.FieldByName(Orig.Fields[i].FieldName).ReadOnly := False;
      Dest.FieldByName(Orig.Fields[i].FieldName).AsString := Orig.Fields[i].AsString;
    end;
  end;
end;
Procedure CompAtuaTabeGravRegi(Orig: TADOQuery; Dest: TsgQuery; CampInic: Byte; Fina, CompMenuTabe:String; AtuaTudo: Boolean); overload;
var
  i : Integer;
  MenuTabe: String;
begin
  if Fina='TABE' then
    MenuTabe := Orig.FieldByName('MenuTabe').AsString;

  for i := CampInic to (Orig.FieldCount - 1) do
  begin
    if CompAtuaTabeQualCamp(Orig.Fields[i].FieldName, Fina, MenuTabe, CompMenuTabe, AtuaTudo) then
    begin
      Dest.FieldByName(Orig.Fields[i].FieldName).ReadOnly := False;
      Dest.FieldByName(Orig.Fields[i].FieldName).AsString := Orig.Fields[i].AsString;
    end;
  end;
end;

//Converte o campo que esta na Query do Tipo Imagem para Picture
function ConvCampParaFigu(Qry: TsgQuery; Camp: String): TDBImgLbl;
var
  Dts: TDataSource;
  Img: TDBImgLbl;
//  Imag: TImgLbl;
begin
  Result := nil;
  Dts := TDataSource.Create(nil);
  Img := TDBImgLbl.Create(nil);
  try
    Dts.DataSet   := Qry;
    Img.DataField := Camp;
    Img.DataSource:= Dts;
    if not Qry.FieldByName(Camp).IsNull then
      Result := Img;
  finally
    Dts.Free;
    Img.Free;
  end;
end;

//Converte o campo que esta na Query para BMP
function ConvCampParaBMP_(Qry: TsgQuery; Camp: String): TBitmap;
var
  Dts: TDataSource;
  Img: TDBImgLbl;
begin
  Result := nil;
  Dts := TDataSource.Create(nil);
  Img := TDBImgLbl.Create(nil);
  try
    Dts.DataSet   := Qry;
    Img.DataField := Camp;
    Img.DataSource:= Dts;
    if not Qry.FieldByName(Camp).IsNull then
    begin
      Result := Img.Picture.Bitmap;
    end;
  finally
    Dts.Free;
    Img.Free;
  end;
end;


procedure AbreQuerBookMark(Qry: TsgQuery; Contr: Boolean = True);
begin
  if Contr then
    Qry.DisableControls;
  Qry.sgRefresh(True);
  if Contr then
    Qry.EnableControls;
end;

Function isTime(Linh: String):Boolean; //Valida se o dado é mesmo do tipo hora
begin
  Result := True;
  try
    if (Length(SubsPalaTudo(Linh,' ','')) = 5) or (Length(SubsPalaTudo(Linh,' ','')) >= 8) then
      StrToTime(Linh)
    else
      Result := False;
  except
    Result := False;
  end;
end;

Function isDateTime(Linh: String):Boolean; //Valida se o dado é mesmo do tipo data
begin
  Result := True;
  try
    if (Length(SubsPalaTudo(Linh,' ','')) = 15) or (Length(SubsPalaTudo(Linh,' ','')) >= 18)  then
      StrToDateTime(Linh)
    else
      Result := False;
  except
    Result := False;
  end;
end;

function ArquValiEnde(iEnde: String; iCriaDire: Boolean = True): String;

  function ArquValiEnde_Empr(Ende: String): String;
  begin
    Result := Ende;
    if PalaContem(Ende, '$PEMP$') or
       PalaContem(Ende, '$PCODEMPR$') or
       PalaContem(Ende, '$CNPJEMPR$') then
    begin
      with GetQry('SELECT PCODEMPR, CGC_EMPR FROM POCAEMPR WHERE CODIEMPR = '+IntToStr(GetPEmp()), 'QryEmpr_ArquValiEnde') do
      try
        Result := SubsPalaTudo(Ende,
                               [ '$PEMP$',     FieldByName('PCodEmpr').AsString
                               , '$PCODEMPR$', FieldByName('PCodEmpr').AsString
                               , '$CNPJEMPR$', FieldByName('CGC_Empr').AsString
                               ]);
      finally
        Close;
        Free;
      end;
    end;
  end;

begin
  Result := iEnde;
  if Result = '' then Exit;
  Result := SubsPalaTudo(iEnde,
                  [ '$EndeExec$'    , GetPEndExec()
                  , '$EndeExecOrig$', GetPEndExecOrig()
                  , '$YY$',       FormatDateTime('YY',PDataServ)
                  , '$YYYY$',     FormatDateTime('YYYY',PDataServ)
                  , '$MM$',       FormatDateTime('MM',PDataServ)
                  , '$MMM$',      FormatDateTime('MMM',PDataServ)
                  , '$DD$',       FormatDateTime('DD',PDataServ)
                  , '$HH$',       FormatDateTime('HH',Now)
                  , '$NN$',       FormatDateTime('NN',Now)
                  , '$CODIEMPR$', IntToStr(GetPEmp())
                  , '$CODIPRAT$', {$ifdef Pratica} IntToStr(GetCodiPrat()) {$else} IntToStr(GetPEmp()) {$endif}
                  ]);
              ;
  Result := ArquValiEnde_Empr(Result).Trim;

  {$ifdef WS}
    {$if Defined(DEBUG) and Defined(DEBUG_UNIGUI)}
      Result := SubsPalaTudo(Result, 'D:\SAG\ERPSAG_Web\Win32\Debug\', 'U:\');
    {$endif}
  {$else}
  {$endif}

  //Deixa sempre os dois primeiros caracteres, que pode ser por rede, e começar com \\192...
  //Mauricio - 18/08/2016 -Adicionados 3 copys diferentes
  //Exemplos de caminhos:
  // \\\\192.168.0.25\\iReport
  // /////192.168.0.25//iReport
  Result := Copy(Result,01,02)+SubsPala(Copy(Result,03,Length(Result)-2),'\\','\');
  Result := Copy(Result,01,02)+SubsPala(Copy(Result,03,Length(Result)-2),'//','/');
  Result := SubsPala(Result,'\\\','\\');
  Result := SubsPala(Result,'///','//');
//    if PalaContem(Result, ' ') and (not PalaContem(Result, '"')) then //Ticket comentado, não sei pq foi incluido esse if mas o delphi não tem problema com caminhos que tem espaços
//      Result := '"'+Result+'"';
  if iCriaDire then
    CriaDire(Result);
end;

//Zipa o arquivo
function ArquZipa(const iEnde: String; const iDest: String = ''): String;
var
  i: integer;
  Zipa: TZipFile;
  aEnde: TsgArrayString;
  vEnde: String;
begin
  Result := '';
  //Zipar Diretório
  //ZipFile.ZipDirectoryContents('C:\DiretorioCompactado.zip', 'C:\Diretorio');

  aEnde := Split(SubsPala(SubsPala(iEnde,',',';') , sgLn,';'), ';');
  if Length(aEnde) = 0 then
  begin
    msgOk('Arquivo para Compactar não Informado');
    Exit;
  end
  else
  begin
    for i := 0 to Length(aEnde) - 1 do
    begin
      vEnde := ArquValiEnde(aEnde[i]);
      if (not PalaContem(vEnde,'*')) and (not FileExists(vEnde)) then
      begin
        msgOk('Falha ao Compactar: Arquivo não Existe! ('+vEnde+')');
        Exit;
      end;
    end;
  end;

  if iDest.Trim = '' then
    Result := ChangeFileExt(ArquValiEnde(aEnde[0]),'.zip')
  else
    Result := ArquValiEnde(iDest);

  Zipa := TZipFile.Create();
  try
    //https://www.andrecelestino.com/delphi-compactacao-de-arquivos-com-a-classe-nativa-tzipfile/
    {$ifdef ERPUNI}
      Zipa.OnProgress := DtmPoul.Zip_OnProgress;
    {$else}
    {$endif}

    Zipa.Open(Result, zmWrite);
    for i := 0 to Length(aEnde) - 1 do
    begin
    {$ifdef ERPUNI}
        Zipa.Add(ArquValiEnde(aEnde[i]));
    {$else}
      if PalaContem(vEnde,'*') then
      begin
        var lSearchRec:TSearchRec;
        var APath := ExtractFilePath(aEnde[i]);
        var AFileSpec := ExtractFileName(aEnde[i]);
        var lPath := IncludeTrailingPathDelimiter(APath);
        var lFind := FindFirst(lPath+AFileSpec,faAnyFile,lSearchRec);
        while lFind = 0 do
        begin
          Zipa.Add(lPath+lSearchRec.Name);
          lFind := System.SysUtils.FindNext(lSearchRec);
        end;
        FindClose(lSearchRec);
      end
      else
        Zipa.Add(ArquValiEnde(aEnde[i]));
    {$endif}
    end;
    Zipa.Close;

    {$ifdef ERPUNI}
      UniSession.SendFile(Result);
    {$else}
    {$endif}
  finally
    Zipa.Free;
  end;
end;

//DesZipa o arquivo (Descompacta)
function ArquDes_Zipa(const iEnde: String; const iDest: String=''; const iSubs: Boolean=False): Boolean;
var
  Zipa: TZipFile;
  vEnde, vDest: String;
begin
  vEnde := ArquValiEnde(iEnde);
  if not FileExists(vEnde) then
  begin
    msgOk('Falha ao Descompactar: Arquivo não Existe! ('+vEnde+')');
    Result := False;
  end
  else
  begin
    Zipa := TZipFile.Create;
    try
      //if Subs then
      Zipa.Open(vEnde, zmReadWrite);
      vDest := iDest;
      if vDest.Trim = '' then
        vDest := ExtractFilePath(vEnde);
      ExibMensHint(vDest);
      Zipa.ExtractAll(ArquValiEnde(vDest));
      Zipa.Close;
      Result := True;
    finally
      Zipa.Free;
    end;
  end;
end;

procedure POHeForm_AtuaCria(iForm: TsgForm; Fech: Boolean = True);
var
  i : integer;
  Qry: TsgQuery;
  {$ifdef DATASNAP}
    ii : integer;
    ListQuer: String;
    js:TlkJSONobject;
    itjs: TlkJSONobject;
  {$endif}
begin
  {$ifdef DATASNAP}
    with iForm do
    begin
      ListQuer := '';
      for i := 0 to (ComponentCount - 1) do
      begin
        If (Components[i].ClassType = TsgQuery) then
        begin
          if (TsgQuery(Components[i]).ProviderName = '') then
          begin
            if ListQuer <> '' then
              ListQuer := ListQuer + ', ';
            ListQuer := ListQuer + '{"nome":"'+TsgQuery(Components[i]).Name+'","acao":"cria"}';
          end;
        end;
      end;
    end;
      if ListQuer <> '' then
      begin
        if Assigned(GetPClientCria()) and Assigned(GetPClientCria.RemoteServer) and GetPClientCria.RemoteServer.Connected then
        begin
          GetPClientCria.Close;
          GetPClientCria.ListaQuery := '{"result":['+ListQuer+']}';
          GetPClientCria.Open;
          ListQuer := GetPClientCria.Texto;
          js := TlkJSON.ParseText(ListQuer) as TlkJsonObject;
          for ii:=0 to js.Field['result'].Count-1 do
          begin
            itjs := (js.Field['result'].Child[ii] as TlkJSONobject);
            with iForm do
              Qry :=  TsgQuery(FindComponent(itjs.getString('nomequer')));
            if Qry <> nil then
            begin
              Qry.uVersCone := GetPClientCria.RemoteServer.Tag;
              Qry.RemoteServer := GetPClientCria.RemoteServer;
              Qry.ProviderName := itjs.getString('nome');
              Qry.uCrioCompServ:= True;
            end;
          end;
          js.Free;
        end;
      end;
  {$endif}
  with iForm do
  begin
    if Assigned(iForm) then SetPsgTrans(iForm.sgTransaction); //{$ifdef FD} {$endif}
    for i := 0 to (ComponentCount - 1) do
    begin
      If (Components[i].ClassType = TsgQuery) or (Components[i].ClassType = TDataSource) then
      begin
        Qry := nil;
        if Components[i].ClassType = TDataSource then
        begin
          if (Components[i].Tag < 10) and (AnsiUpperCase(Components[i].Name) <> 'DTSGRAV') then
          begin
            if Assigned(TDataSource(Components[i]).DataSet) and (TDataSource(Components[i]).DataSet.ClassType = TsgQuery) then
              Qry := TsgQuery(TDataSource(Components[i]).DataSet);
          end;
        end
        else
          Qry := TsgQuery(Components[i]);

        if Assigned(Qry) then
        begin
          Qry.PBas := GetPBas();
          if (not Qry.Active) and (not Assigned(Qry.Transaction)) and Assigned(iForm.sgTransaction) and (iForm.sgTransaction.Active) then
            Qry.sgTransaction := iForm.sgTransaction;
          if (Qry.Tag < 10) then
          begin
            if Qry.SQL.Text <> '' then
            begin
              if Fech then
              begin
                ExibMensHint('Atualizando: '+Qry.Name);
                //Sem os Disabled e EnabledControls consegue pegar o erro da Data < 1900 no Active da Query (MULTIPLE-STEP OPERATION GENERATED ERRORS. CHECK EACH STATUS VALUE)
                //Qry.DisableControls;
                Qry.Close;
                Qry.Open;
                //Qry.EnableControls;
                ExibMensHint('');
              end
              else if not Qry.Active then
              begin
                ExibMensHint('Atualizando: '+Qry.Name);
                //Sem os Disabled e EnabledControls consegue pegar o erro da Data < 1900 no Active da Query (MULTIPLE-STEP OPERATION GENERATED ERRORS. CHECK EACH STATUS VALUE)
                //Qry.DisableControls;
                Qry.Open;
                //Qry.EnableControls;
                ExibMensHint('');
              end;
            end;
            {$IFDEF ERPUNI}
              Qry.Tag := 10;
            {$ELSE}
            {$ENDIF}
          end;
        end;
      end;
    end;
  end;
end;

procedure Trad_Componente_Form(iForm: TComponent; const iCodiTabe: Integer = 0);
var
  i, vCodiTabe: Integer;
  vTrad: Boolean;
begin
  if not Assigned(iForm) then Exit;

  with iForm do
  begin
    {$if not Defined(SAGLIB) and not Defined(LIBUNI)}
      vTrad := False;
      vCodiTabe := 0;
      if iForm is TsgForm then
      begin
        vTrad := TsgForm(iForm).Traduzido;
        vCodiTabe := TsgForm(iForm).HelpContext;
      end
      else if iForm is TsgFormModal then
      begin
        vTrad := TsgFormModal(iForm).Traduzido;
        vCodiTabe := TsgFormModal(iForm).HelpContext;
      end;

      if (not vTrad) and (GetCodiIdio() > 0) then
      begin
        if iCodiTabe <> 0 then
          vCodiTabe := iCodiTabe;
        //SetPLogTipo(3);
        ExibMensHint('Traduzindo...(F)');
        for I  := 0 to ComponentCount - 1 do
        begin
          //ExibMensHint(Components[i].Name);
          Trad_Componente(Components[i], vCodiTabe);
        end;
        ExibMensHint('');
      end;

      if iForm is TsgForm then
        TsgForm(iForm).Traduzido := True
      else if iForm is TsgFormModal then
        TsgFormModal(iForm).Traduzido := True;
    {$endif}
  end;
end;

procedure Trad_Componente(iComp: TComponent; iCodiTabe: Integer = 0; iNomeCompPrin: String = '');
var
  {$ifdef ERPUNI}
    vCompAtua: TUniControl;
  {$else}
    vCompAtua: TWinControl;
  {$endif}
  k: Integer;
  vAuxi: String;
  vIndex: Integer;
  vQuer: TsgQuery;
  isOpen: Boolean;
  vList: TLstLbl;
  {$ifNdef ERPUNI} vListView: TListView ;{$endif}

  function Trad_Componente_Busc(iName, iCamp: String): String;
  begin
    if (iCodiTabe <> 0) and DtmPoul.DtbGene.Connected then
    begin
      DtmPoul.QryTradCamp.Filtered:= False; //Antes do open para o filtro não confundir no log
      if (not DtmPoul.QryTradCamp.Active) or
         (DtmPoul.QryTradCamp.Params.ParamByName('CodiTabe').AsInteger <> iCodiTabe) or
         (DtmPoul.QryTradCamp.Params.ParamByName('CodiIdio').AsInteger <> GetCodiIdio) then
      begin
        DtmPoul.QryTradCamp.Close;
        DtmPoul.QryTradCamp.Params.ParamByName('CodiIdio').AsInteger := GetCodiIdio;
        DtmPoul.QryTradCamp.Params.ParamByName('CodiTabe').AsInteger := iCodiTabe;
        DtmPoul.QryTradCamp.Open;
      end;
      DtmPoul.QryTradCamp.Filter  := '(NameTrad = '+QuotedStr(sgCopy(iName,04,MaxInt))+' OR NameTrad = '+QuotedStr('TRAD_'+SeStri(iNomeCompPrin='','',iNomeCompPrin+'_')+iName.ToUpper)+') '+
                                     'AND (CampTrad = '+QuotedStr(iCamp)+')';
      DtmPoul.QryTradCamp.Filtered:= True;
      Result := DtmPoul.QryTradCamp.FieldByName('NomeTrad').AsString;
      //DtmPoul.QryTradCamp.Close;
    end
    else
      Result := '';
  end;

  function Trad_Componente_Veri(iName, iText, iCamp, iRes: String): String;
  var
    vAuxi: String;
  begin
    Result := '';
    if (iRes.ToUpper = '_HINT') then
    begin
      if ((SubsPala(iText,sgLn,'').Trim.ToUpper = '(F2 - EDITOR; F3 - OBSERVAÇÕES PADRÃO; F4 - DATA/HORA)') or
          (SubsPala(iText,sgLn,'').Trim.ToUpper = resMemTextSele_Hint.ToUpper)) then
      begin
        {$ifdef ERPUNI}
          Result := resMnuPOGeEdit_Hint;
        {$else}
          Result := resMemTextSele_Hint;
        {$endif}
      end
      else if (SubsPala(iText,sgLn,'').Trim.ToUpper = resBtnCadaExpo_Hint.ToUpper) then
      begin
        Result := resBtnCadaExpo_Hint;
      end;
    end;

    if (Result = '') then
    begin
      Result := iText;
      vAuxi := Trad_Componente_Busc(iName, iCamp);
      if vAuxi = '' then
        vAuxi := sgLoadResString('res'+iName+iRes);
      if vAuxi <> '' then
        Result := vAuxi
      else //if GetPApePess = 'TRADUCAO' then
        with Trad.TradInfoNao_Trad('PlusUni', 'Trad_Componente_Veri', iCodiTabe, 0, GetCodiIdio(), iName, iCamp, iText, iRes) do Free;
    end;
  end;

var
  vName: string;
  vTradColu: Boolean;
begin
  //ST (14/05/2024): PlusUni.Trad_Componente = Plus.PopTela_GeraCamp_Comp
  if GetCodiIdio() <= 0 then Exit;
  if iCodiTabe = 0 then Exit;
  try
    if not Trad.TradVeriTrad(iComp.Name, 'sag') then Exit;

    if (iComp is TDataSource)
         or (iComp is TsgPgc)
         or (iComp is {$ifdef ERPUNI} TUniPageControl  {$else} TPageControl  {$endif})
         or (iComp is {$ifdef ERPUNI} TsgFormStorage   {$else} TFormStorage  {$endif})
         or (iComp is TsgPop)
         or (iComp is {$ifdef ERPUNI} TuniPopupMenu    {$else} TPopupMenu    {$endif})
         or (iComp is {$ifdef ERPUNI} TUniHiddenPanel  {$else} TPopupMenu    {$endif})
         or ((iComp is TsgMenuItem) and (StrIn(TsgMenuItem(iComp).Caption, ['','-'])))
         or (iComp is TField)
    then  //Não Traduz
      Exit;

    //********************
    if (iComp is {$ifdef ERPUNI}TuniLabel{$else}TLabel{$endif}) or (iComp is TsgLbl) then
      TsgLbl(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgLbl(iComp).Caption, 'LABECAMP', '_Caption')

    //********************
    else if (iComp is TsgBtn) then
    begin
      TsgBtn(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgBtn(iComp).Caption, 'LABECAMP', '_Caption');
      TsgBtn(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgBtn(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    else if (iComp is TDBChkLbl) then
    begin
      TDBChkLbl(iComp).Caption := Trad_Componente_Veri(iComp.Name, TDBChkLbl(iComp).Caption, 'LABECAMP', '_Caption');
      TDBChkLbl(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TDBChkLbl(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    else if (iComp is TChkLbl) then
    begin
      TChkLbl(iComp).Caption := Trad_Componente_Veri(iComp.Name, TChkLbl(iComp).Caption, 'LABECAMP', '_Caption');
      TChkLbl(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TChkLbl(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    else if  {$ifdef ERPUNI} {$else} (iComp is TMenuItem) or {$endif}
            (iComp is TsgMenuItem) then
    begin
      TsgMenuItem(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgMenuItem(iComp).Caption, 'LABECAMP', '_Caption');
      TsgMenuItem(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgMenuItem(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    else if (iComp is TsgTbs) or
            (iComp is {$ifdef ERPUNI} TuniTabSheet {$else} TTabSheet {$endif}) then
    begin
      TsgTbs(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgTbs(iComp).Caption, 'LABECAMP', '_Caption');
      TsgTbs(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgTbs(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    else if (iComp is TCmbLbl) or
            {$ifdef ERPUNI} (iComp is TUniComboBox) {$else} {$endif}
            (iComp is TDBCmbLbl) or
            {$ifdef ERPUNI} (iComp is TUniDBComboBox) {$else} {$endif}
            (iComp is TDBCmbLbl) then
    begin
      //TCmbLbl(iComp).Caption := Trad_Componente_Veri(iComp.Name, TCmbLbl(iComp).Caption, 'LABECAMP', '_Caption');
      TCmbLbl(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TCmbLbl(iComp).Hint   , 'HINTCAMP', '_Hint');

      if TCmbLbl(iComp).Items.Count > 0 then
      begin
        vIndex := TCmbLbl(iComp).ItemIndex;
        //if TCmbLbl(iComp).Hint <> '' then  //ST (11/05/2024): Não entendi por que só traduzir quem tem Hint
        begin
          vAuxi := Trad_Combo(iCodiTabe, Copy(iComp.Name,04,MaxInt));  //Tira o CMB
          if vAuxi = '' then
            vAuxi := Trad_Componente_Veri(iComp.Name, TCmbLbl(iComp).Items.Text, 'LABECAMP', '_Caption');
          //if vAuxi = '' then
          //  vAuxi := Trad_Componente_Veri(iComp.Name+'_Itens', TCmbLbl(iComp).Items.Text, 'LABECAMP', '');
          if vAuxi <> '' then
            TCmbLbl(iComp).Items.Text := SubsPalaTudo(vAuxi,'||',sgLn);
        end;
        TCmbLbl(iComp).ItemIndex := vIndex;
      end;
    end

    //********************
    else if (iComp is {$ifdef ERPUNI} TUniComboBox {$else} TComboBox     {$endif}) or
            (iComp is {$ifdef ERPUNI} TUniComboBox {$else} TFlatComboBox {$endif}) or
            (iComp is {$ifdef ERPUNI} TUniDBComboBox {$else} TDBComboBox   {$endif}) or
            (iComp is {$ifdef ERPUNI} TUniDBComboBox {$else} TFlatComboBox {$endif}) then
    begin
      //TComboBox(iComp).Caption := Trad_Componente_Veri(iComp.Name, TComboBox(iComp).Caption, 'LABECAMP', '_Caption');
      TComboBox(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TComboBox(iComp).Hint   , 'HINTCAMP', '_Hint');

      if TComboBox(iComp).Items.Count > 0 then
      begin
        vIndex := TComboBox(iComp).ItemIndex;
        //if TComboBox(iComp).Hint <> '' then  //ST (11/05/2024): Não entendi por que só traduzir quem tem Hint
        begin
          vAuxi := Trad_Combo(iCodiTabe, Copy(iComp.Name,04,MaxInt));  //Tira o CMB
          if vAuxi = '' then
            vAuxi := Trad_Componente_Veri(iComp.Name, TComboBox(iComp).Items.Text, 'LABECAMP', '_Caption');
          //if vAuxi = '' then
          //  vAuxi := Trad_Componente_Veri(iComp.Name+'_Itens', TComboBox(iComp).Items.Text, 'LABECAMP', '');
          if vAuxi <> '' then
            TComboBox(iComp).Items.Text := SubsPalaTudo(vAuxi,'||',sgLn);
        end;
        TComboBox(iComp).ItemIndex := vIndex;
      end;
    end

    //********************
    else if (iComp is TsgRadioButton) or
            (iComp is {$ifdef ERPUNI} TuniRadioButton {$else} TRadioButton   {$endif}) then
    begin
      TsgRadioButton(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgRadioButton(iComp).Caption, 'LABECAMP', '_Caption');
      TsgRadioButton(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgRadioButton(iComp).Hint   , 'HINTCAMP', '_Hint');
    end


    //********************
    else if (iComp is TsgRgb) or
            (iComp is {$ifdef ERPUNI} TuniRadioGroup {$else} TRadioGroup      {$endif}) then
    begin
      TsgRgb(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgRgb(iComp).Caption, 'LABECAMP', '_Caption');
      TsgRgb(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgRgb(iComp).Hint   , 'HINTCAMP', '_Hint');

      if TsgRgb(iComp).Items.Count > 0 then
      begin
        vIndex := TsgRgb(iComp).ItemIndex;
        vAuxi := Trad_Combo(iCodiTabe, Copy(iComp.Name,04,MaxInt)+'_ITENS');  //Tira o CMB
        if vAuxi = '' then
          vAuxi := Trad_Componente_Veri(iComp.Name+'_Itens', TsgRgb(iComp).Items.Text, 'LABECAMP', '');
        if vAuxi <> '' then
          TsgRgb(iComp).Items.Text := SubsPalaTudo(vAuxi,'||',sgLn);
        TsgRgb(iComp).ItemIndex := vIndex;
      end;
    end

    //********************
    else if (iComp is TsgDBRgb) or
            (iComp is {$ifdef ERPUNI} TuniDBRadioGroup {$else} TDBRadioGroup {$endif}) then
    begin
      TsgDBRgb(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgDBRgb(iComp).Caption, 'LABECAMP', '_Caption');
      TsgDBRgb(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgDBRgb(iComp).Hint   , 'HINTCAMP', '_Hint');

      if TsgDBRgb(iComp).Items.Count > 0 then
      begin
        vIndex := TsgDBRgb(iComp).ItemIndex;
        vAuxi := Trad_Combo(iCodiTabe, Copy(iComp.Name,04,MaxInt)+'_ITENS');  //Tira o CMB
        if vAuxi = '' then
          vAuxi := Trad_Componente_Veri(iComp.Name+'_Itens', TsgDBRgb(iComp).Items.Text, 'LABECAMP', '');
        if vAuxi <> '' then
          TsgDBRgb(iComp).Items.Text := SubsPalaTudo(vAuxi,'||',sgLn);
        TsgDBRgb(iComp).ItemIndex := vIndex;
      end;
    end

    //********************
    else if (iComp is TsgGroupBox) or
            (iComp is {$ifdef ERPUNI} TUniGroupBox {$else} TGroupBox     {$endif}) or
            (iComp is {$ifdef ERPUNI} TUniGroupBox {$else} TFlatGroupBox {$endif}) then
    begin
      TsgGroupBox(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgGroupBox(iComp).Caption, 'LABECAMP', '_Caption');
      TsgGroupBox(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgGroupBox(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    else if (iComp is TsgRadioButton) or
            (iComp is {$ifdef ERPUNI} TuniRadioButton {$else} TRadioButton {$endif}) then
    begin
      TsgRadioButton(iComp).Caption := Trad_Componente_Veri(iComp.Name, TsgRadioButton(iComp).Caption, 'LABECAMP', '_Caption');
      TsgRadioButton(iComp).Hint    := Trad_Componente_Veri(iComp.Name, TsgRadioButton(iComp).Hint   , 'HINTCAMP', '_Hint');
    end

    //********************
    //Tag <> 0 que como 0 é traduzido (TFraGrid.QryGridBeforeOpen)
    else if (iComp is TcxGridDBTableView) and (iComp.Tag <> 0) then
    begin
      if Assigned(TcxGridDBTableView(iComp).DataController.DataSource) and
         Assigned(TcxGridDBTableView(iComp).DataController.DataSource.DataSet) and
                 (TcxGridDBTableView(iComp).DataController.DataSource.DataSet is TsgQuery) then
      begin
        vQuer := TsgQuery(TcxGridDBTableView(iComp).DataController.DataSource.DataSet);
        vName := 'TRAD_'+SeStri(iNomeCompPrin='','',iNomeCompPrin+'_')+TcxGridDBTableView(iComp).Name;

        if vQuer.FieldCount > 0 then
          TradQuer_FieldObj(iCodiTabe, vQuer, vName)
        else
        begin
          isOpen := vQuer.Active;
          {$ifdef ERPUNI}
            //TradUnig
            //TsgDBG(TcxGridDBTableView(iComp).Control).Coluna.Text := TradSQL_Cons(0, TsgDBG(TcxGridDBTableView(iComp).Control).Coluna.Text, True, vName, iCodiTabe);
          {$else}
            TsgDBG(TcxGridDBTableView(iComp).Control).Coluna.Text := TradSQL_Cons(0, TsgDBG(TcxGridDBTableView(iComp).Control).Coluna.Text, True, vName, iCodiTabe);
          {$endif}
          vAuxi := TradSQL_Cons(0, vQuer.SQL.Text, False, vName, iCodiTabe);
          if vAuxi <> vQuer.SQL.Text then
          begin
            vQuer.SQL.Text := vAuxi;
            if isOpen then
              vQuer.Open;
          end;
        end;
      end;
    end

    //********************
    else if (iComp is TsgDBG) then
    begin
      TsgDBG(iComp).Hint := '';    //Não traduz o Hint
      vTradColu := True;
      for k := 0 to TsgDBG(iComp).Columns.Count - 1 do
      begin
        with TradGrid_Colu(iCodiTabe, 'TRAD_'+iComp.Name, TsgDBG(iComp).Columns[k].FieldName) do
        try
          if Result then
            TsgDBG(iComp).Columns[k].Title.Caption := Texto
          else if vTradColu then
            vTradColu := False;
        finally
          Free;
        end;
      end;
      if not vTradColu then
      begin
        //ST (13/10/2024): Quando os campos estão com os alias nas DBG.Columns, não acha na consulta para traduzir e não acha só com o TRAD_Tabela
        for k := 0 to TsgDBG(iComp).Columns.Count - 1 do
        begin
          with TradGrid_Colu(iCodiTabe, 'TRAD_'+iComp.Name, TsgDBG(iComp).Columns[k].Title.Caption) do
          //with TradGrid_Colu(iCodiTabe, 'TRAD_VIEW'+iComp.Name, TsgDBG(iComp).Columns[k].Title.Caption) do
          try
            if Result then
              TsgDBG(iComp).Columns[k].Title.Caption := Texto;
          finally
            Free;
          end;
        end;
      end;
    end

    //********************
    else if (iComp is TLstLbl) then
    begin
      vList := TLstLbl(iComp);
      vList.Hint := '';
      for k := 0 to vList.Columns.Count - 1 do
      begin
        {$ifdef ERPUNI}
        {$else}
          with TradGrid_Colu(iCodiTabe, 'TRAD_'+iComp.Name, vList.Columns[k].Caption) do
          begin
            if Result then
              vList.Columns[k].Caption := Texto;
            Free;
          end;
        {$endif}
      end;
    end

    {$ifNdef ERPUNI}
      //********************
      else if (iComp is TListView) then
      begin
        vListView := TListView(iComp);
        vListView.Hint := '';
        for k := 0 to vListView.Columns.Count - 1 do
        begin
          with TradGrid_Colu(iCodiTabe, 'TRAD_'+iComp.Name, vListView.Columns[k].Caption) do
          begin
            if Result then
              vListView.Columns[k].Caption := Texto;
            Free;
          end;
        end;
      end
      //********************
      else if (iComp is TsgTreeList) then
      begin
        TsgTreeList(iComp).Hint := '';    //Não traduz o Hint
        for k := 0 to TsgTreeList(iComp).ColumnCount - 1 do
        begin
          with TradGrid_Colu(iCodiTabe, 'TRAD_'+iComp.Name, TsgTreeList(iComp).Columns[k].Caption.Text) do
          begin
            if Result then
              TsgTreeList(iComp).Columns[k].Caption.Text := Texto;
            Free;
          end;
        end;
      end
    {$endif}

    //******************************************************************************
    //Geral
    else if BuscPareWin(iComp.ClassType) then
    begin
      vCompAtua := {$ifdef ERPUNI} TUniControl {$else} TWinControl {$endif}(iComp);
      //vCompAtua.Caption := Trad_Componente_Veri(iComp.Name, iComp.Caption, 'LABECAMP', '_Caption');
      vCompAtua.Hint    := Trad_Componente_Veri(iComp.Name, vCompAtua.Hint   , 'HINTCAMP', '_Hint');
    end;
    //******************************************************************************

  finally
    //DtmPoul.QryTradCamp.sgClose;
  end;
end;

Function Trad_Combo(iCodiTabe: Integer; iNameCamp: String): String;
begin
  if DtmPoul.DtbGene.Connected then
  begin
    DtmPoul.QryTradComb.Filtered:= False;
    if (not DtmPoul.QryTradComb.Active) or
       (DtmPoul.QryTradComb.Params.ParamByName('CodiTabe').AsInteger <> iCodiTabe) or
       (DtmPoul.QryTradComb.Params.ParamByName('CodiIdio').AsInteger <> GetCodiIdio) then
    begin
      DtmPoul.QryTradComb.Close;
      DtmPoul.QryTradComb.Params.ParamByName('CodiIdio').AsInteger := GetCodiIdio;
      DtmPoul.QryTradComb.Params.ParamByName('CodiTabe').AsInteger := iCodiTabe;
      DtmPoul.QryTradComb.Open;
    end;
    DtmPoul.QryTradComb.Filter  := '(NameTrad = '+QuotedStr(iNameCamp.ToUpper)+')';
    DtmPoul.QryTradComb.Filtered:= True;
    Result := SubsPalaTudo(DtmPoul.QryTradComb.FieldByName('NomeTrad').AsString,'||',sgLn);
    //DtmPoul.QryTradComb.Close;
  end
  else
    Result := '';
end;

procedure AbreWebBrowser(iURL: String);
var
  FrmPOChWebB: TFrmPOChWebB;
begin
  FrmPOChWebB := TFrmPOChWebB.Create(Application);
  FrmPOChWebB.URL := iURL;
  FrmPOChWebB.Show;
end;

//Pede e Valida a Senha do Dia
function ValiSenhDia(): Boolean;
begin
  if IsRx9() then
    Result := True
  else
    if IsMaquAuto() then
      Result := True
    else
    begin
      Result := False;
      Application.CreateForm(TFrmPOChSenh, FrmPOChSenh);
      try
        if FrmPOChSenh.ShowModal = mrOk then
        begin
          if FrmPOChSenh.EdtSenh.Text <> GeraSenhDia(Date) then
            msgOk('Senha invalida!')
          else
            Result := True;
        end;
      finally
        FrmPOChSenh.Free;
    end;
  end;
end;

//Pede e Valida a Senha do Dia do Teste
function ValiSenhDia_Teste(): Boolean;
begin
//  if IsMaquAuto() then
//    Result := True
//  else
  begin
    Result := False;
    Application.CreateForm(TFrmPOChSenh, FrmPOChSenh);
    try
      if FrmPOChSenh.ShowModal = mrOk then
      begin
        if FrmPOChSenh.EdtSenh.Text <> IntToStr(sgStrToInt(GeraSenhDia(Date))+25) then
          msgOk('Senha invalida!')
        else
          Result := True;
      end;
    finally
      FrmPOChSenh.Free;
    end;
  end;
end;

//Criar ou alterar os Usuários, conforme banco de dados
Function CriaAlteUsua(Usua, Senh: String; iConn: TObject=nil):Boolean;
var
  QryCodi: TsgQuery;
  j, i, k: Integer;
  Letr: String;
begin
  Usua := AnsiUpperCase(Usua);
  Result := True;

  if Result then
  begin
    //INSERE NO POCACONF
    if CalcInte('SELECT COUNT(*) FROM POCACONF WHERE (USERCONF = '+QuotedStr(Usua)+')', iConn) = 0 then
    begin
      {$ifdef Pratica}
        ExecSQL_('INSERT INTO POCACONF (USERCONF, CODIPRAT) VALUES ('+QuotedStr(Usua)+', '+IntToStr(GetCodiPrat)+')', iConn);
      {$else}
        ExecSQL_('INSERT INTO POCACONF (USERCONF) VALUES ('+QuotedStr(Usua)+')', iConn);
      {$endif}
    end;

    //Calcula o PCodPess
    if Trim(CalcStri('SELECT PCODPESS FROM POGEPESS WHERE (APELPESS = '+QuotedStr(Usua)+')', iConn)) = '' then
    begin
      QryCodi := TsgQuery.Create(nil);
      try
        j := 64;  //64 será o U, sendo que na 65 será o A, segue...
        i := 100;
        k := 0;
        while j <= 90 do
        begin
          Letr := SeStri(j=64,'U',Chr(j));
          QryCodi := getQry('SELECT PCodPess FROM POGePess WHERE (PCodPess LIKE '''+Letr+'%'') GROUP BY PCodPess ORDER BY PCodPess', 'QryCodi', iConn);
          i := 1;
          if QryCodi.IsEmpty then
          begin
            QryCodi.FindLast;
            j := 100; //Sai do outro loop também
          end;
          while (not QryCodi.Eof) and (i < 90) do
          begin
            if QryCodi.FieldByName('PCodPess').AsString = Letr+ZeroEsqu(InttoStr(i),02) then
              Inc(i)
            else
            begin
              QryCodi.FindLast;
              j := 100; //Sai do outro loop também
            end;

            Inc(k);
            if k > 1000 then Exit;

            QryCodi.Next;
          end;

          Inc(k);
          if k > 1000 then Exit;

          Inc(j);
        end;
        QryCodi.Close;

        if i <= 97 then
          ExecSQL_('UPDATE POGEPESS SET PCODPESS = '+QuotedStr(Letr+ZeroEsqu(InttoStr(i),02))+
                  ' WHERE (APELPESS = '+QuotedStr(Usua)+')')
        else
        begin
          msgOk('Sem Faixa para Código Interno (PCodPess)!');
          Result := False;
        end;
      finally
        QryCodi.Close;
        QryCodi.Free;
      end;
    end;
  end;
end;

//******************************************************************************************
{ TsgSenh }

function GetsgSenh(): TsgSenh;
begin
  if not Assigned(FsgSenh) then
    FsgSenh := TsgSenh.Create;

  Result := FsgSenh
end;

constructor TsgSenh.Create;
begin
  inherited;
  EmprCont := getEmpresa;
  EmprSenh := getEmpresa;
  SistCont := IntToStr(GetPSis());
  SistSenh := IntToStr(GetPSis());
  VersSenh := RetoVers();
  FModoConsulta := mcTota;
end;

function TsgSenh.DataSenh_FormToDate(iData: String): TDateTime;
begin
  if sgStrToInt(iData) = 0 then
    iData := '010100';   //01/01/2000
  iData.Insert(4,'0');
  iData.Insert(4,'2');
  iData.Insert(4,'/');
  iData.Insert(2,'/');
  Result := StrToDate(FormData(iData));
end;

procedure TsgSenh.GravaControles();
begin
  //Data de Acesso
  if OpcaSenh = '2' then
  begin
    DataAcesGrav := Date;
    NumeSeriGrav := PegaSeri;
  end
  //Número e Data de Controle
  else if OpcaSenh = '3' then
  begin
    DataValiGrav := DataSenh_FormToDate(DataCont);
    TipoContGrav := TipoCont;
    NumeContGrav := sgStrToInt(NumeCont);
    Num1ContGrav := sgStrToInt(Num1Cont);
    NumeAcesGrav := 0;
  end
  //Série do HD
  else if OpcaSenh = '5' then
    NumeSeriGrav := PegaSeri
   //Número de Acessos
  else if OpcaSenh = '6' then
    NumeAcesGrav := 0;
end;

procedure TsgSenh.SetDataAcesGrav(const Value: TDateTime);
begin
  GravParaSenh(000,'DataAcesSAG_Mana', FormatDateTime('DDMMYY',Value));
end;

procedure TsgSenh.SetDataValiGrav(const Value: TDateTime);
begin
  GravParaSenh(000,'DataValiModu0'+SistCont, FormatDateTime('DDMMYY',Value));
end;

procedure TsgSenh.SetDataVencNumeGrav(const Value: TDateTime);
begin
  GravParaSenh(000,'DataVencNume0'+SistCont, FormatDateTime('DDMMYY',Value));
end;

procedure TsgSenh.SetDataVeriNumeGrav(const Value: TDateTime);
begin
  GravParaSenh(000,'DataVeriNume0'+SistCont, FormatDateTime('DDMMYY',Value));
end;

procedure TsgSenh.SetNumeContGrav(const Value: Integer);
begin
  GravParaSenh(000,'NumeContModu0'+SistCont, IntToStr(Value));
end;

procedure TsgSenh.SetNum1ContGrav(const Value: Integer);
begin
  GravParaSenh(000,'Num1ContModu0'+SistCont, IntToStr(Value));
end;

procedure TsgSenh.SetNumeAcesGrav(const Value: Integer);
begin
  GravParaSenh(000,'NumeAcesModu0'+SistCont, IntToStr(Value));
end;

procedure TsgSenh.SetNumeSeriGrav(const Value: String);
begin
  GravParaSenh(000,'NumeSeriSAG_Mana', Value)
end;

procedure TsgSenh.SetTipoContGrav(const Value: String);
begin
  GravParaSenh(000,'TipoContModu0'+SistCont, Value);
end;

function TsgSenh.ValiCont(iMens: Boolean = True; iGeral: Boolean = False): Boolean;
begin
  Result := inherited ValiCont(iMens, iGeral);
  if Result then
    GravaControles;
end;

function TsgSenh.GeraContra(iMens: Boolean = True): String;
var
  vDataPess: TDateTime;
begin
  if TipoCont <> '7' then  //Senha do Dia
  begin
    CodiPess := CalcInte('SELECT CodiPess FROM CALLCENTER.POCAPess WHERE AtivPess <> 0 AND Te01Pess = '+QuotedStr(EmprCont));
    DiasCont := CalcInte('SELECT Nu02Pess FROM CALLCENTER.POCAPess WHERE CodiPess = '+IntToStr(CodiPess));
    if DiasCont = 0 then
      DiasCont := 80;
    EnceModu := CalcData('SELECT FinaMvPr FROM CALLCENTER.CLCaMvPr WHERE CodiPess = '+IntToStr(CodiPess)+' AND CodiProd = '+SistCont);
    vDataPess:= CalcData('SELECT Da03Pess FROM CALLCENTER.POCAPess WHERE CodiPess = '+IntToStr(CodiPess));
    if EnceModu < vDataPess then
      EnceModu := vDataPess;
    if (EnceModu - Date) > DiasCont then
      EnceModu := Date + DiasCont;
    MaxiCont := CalcInte('SELECT LibeMvPr FROM CALLCENTER.CLCaMvPr WHERE CodiPess = '+IntToStr(CodiPess)+' AND CodiProd = '+SistCont);
    Max1Cont := CalcInte('SELECT Nu04Pess FROM CALLCENTER.POCAPess WHERE CodiPess = '+IntToStr(CodiPess));
    TipoCont := Copy(
                CalcStri('SELECT TipoMvPr FROM CALLCENTER.CLCaMvPr WHERE CodiPess = '+IntToStr(CodiPess)+' AND CodiProd = '+SistCont),01,01);
  end;
  Result := inherited GeraContra(iMens);
end;

//Retornar se o Módulo é válido ou não (com números previstos)
Function TsgSenh.ValidaModulo(): Boolean;
begin
  Result := (StrToInt(NumeCont) >= NumeContReal) and (StrToInt(Num1Cont) >= Num1ContReal);
end;

//Retornar se o Módulo é válido ou não (com números previstos)
Function TsgSenh.ValidaModuloReal(): Boolean;
var
  vNumeContGrav, vNum1ContGrav: Integer;
begin
  TipoCont := TipoContGrav;
  vNumeContGrav := NumeContGrav;
  Result := (vNumeContGrav >= NumeContReal);
  if Result then
  begin
    vNum1ContGrav := Num1ContGrav;
    if vNum1ContGrav = 0 then
      vNum1ContGrav := vNumeContGrav;
    Result := (vNum1ContGrav >= Num1ContReal);
  end;
end;

//Retorna o SQL dos acessos dos usuários no módulo
function TsgSenh.GetSQL_AcesUsua(iWher: String = ''): String;
begin
  Result := SeStri(ModoConsulta=mcProd, 'SELECT DISTINCT NomePess AS "Pessoa", 1 AS "Qtde", ''Usuário'' AS "Tipo"',
            SeStri(ModoConsulta=mcUnion,'SELECT DISTINCT ''Pessoa'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Usuário'' AS "Tipo" /*PERS*/',
                                        'SELECT COUNT(DISTINCT ACPR.CODIPESS)'))+sgLn+
                                        ' FROM POCAACPR ACPR INNER JOIN POGEPESS PESS ON ACPR.CODIPESS = PESS.CODIPESS '+sgLn+
                                        ' WHERE  '+SubsPala(cFiltPessSenh, 'POGePess.', 'Pess.')+' AND (ACPR.CODIPESS IS NOT NULL) AND (ACPR.ACESACPR <> 0) '+sgLn+
                                        '    AND (ACPR.CODIPROD = '+SistCont+')'+sgLn+
                                        iWher;
end;

function TsgSenh.GetSQL_Nume: String;
var
  Auxi: String;
  DataAtua: TDateTime;
  InicMes, FinaMes: TDateTime;
begin
  if TipoCont = '2' then   //Controle por Usuário
    Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Pessoa", 1 AS "Qtde", ''Usuário'' AS "Tipo"',
              SeStri(ModoConsulta=mcUnion, 'SELECT ''Pessoa'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Usuário'' AS "Tipo" /*PERS*/',
                                           'SELECT COUNT(*)'))+sgLn+
                                           ' FROM POGePess'+sgLn+
                                           ' WHERE '+cFiltPessSenh+sgLn+
                                           WherPers
  else if TipoCont = '3' then  //Por Usuário no módulo
    Result := GetSQL_AcesUsua()
  else if TipoCont = '4' then  //Por Usuário no módulo, tirando os usuários que são Completo
    Result := GetSQL_AcesUsua(' AND ((CorrPess IS NULL) OR (CorrPess <> ''Completo''))')
  else if TipoCont = '5' then  //Por Acesso Completo
    Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Pessoa", 1 AS "Qtde", ''Usuário'' AS "Tipo"',
              SeStri(ModoConsulta=mcUnion, 'SELECT ''Pessoa'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Usuário'' AS "Tipo" /*PERS*/',
                                           'SELECT COUNT(*)'))+sgLn+
                                           ' FROM POGePess'+sgLn+
                                           ' WHERE '+cFiltPessSenh+sgLn+
                                           WherPers
  else if TipoCont = '6' then  //Acesso Simultaneo
    Result := ''
  else if TipoCont = '7' then  //Senha do Dia - Liberado
    Result := SeStri(ModoConsulta=mcProd,  'SELECT '''' AS "Pessoa", 0 AS "Qtde"',
              SeStri(ModoConsulta=mcUnion, 'SELECT ''Pessoa'' AS "Controle", '''' AS "Pessoa", 0 AS "Qtde", ''SenhaDoDia'' AS "Tipo" /*PERS*/',
                                           'SELECT 0'))+sgLn+
                                           ' FROM POCaAuxi'
  else if TipoCont = '1' then //Por Volume
  begin
    DataAtua := IncMonth(PDataServ,-1);
    InicMes  := EncodeDate(Year(DataAtua),Month(DataAtua),01);
    FinaMes  := EncodeDate(Year(DataAtua),Month(DataAtua),DaysInAMonth(Year(DataAtua),Month(DataAtua)));

    case StrToInt(SistCont) of
      //Matrizes Pesadas
      01: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomeLote AS "Lote", (FemeLote+MachLote) AS "Qtde", FemeLote AS "Fêmeas",        MachLote AS "Machos", DataLote AS "Data"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Lote'' AS "Controle", NomeLote AS "Nome", (FemeLote+MachLote) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(FemeLote+MachLote)'))+sgLn+
                                                 ' FROM MPViLote'+sgLn+
                                                 ' WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
      //Genética Pesada
      81: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomeLote AS "Lote", (FemeLote+MachLote) AS "Qtde", FemeLote AS "Fêmeas",        MachLote AS "Machos", DataLote AS "Data"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Lote'' AS "Controle", NomeLote AS "Nome", (FemeLote+MachLote) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(FemeLote+MachLote)'))+sgLn+
                                                 ' FROM MPViLote'+sgLn+
                                                 ' WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
      //Frango de Corte
      03: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomeLote AS "Lote", (FemeLote+MachLote) AS "Qtde", FemeLote AS "Fêmeas/Mistos", MachLote AS "Machos", DataLote AS "Data"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Lote'' AS "Controle", NomeLote AS "Nome", (FemeLote+MachLote) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(FemeLote+MachLote)'))+sgLn+
                                                 ' FROM FCViLote'+sgLn+
                                                 ' WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
      //Postura Comercial
      20: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomeLote AS "Lote", (FemeLote+MachLote) AS "Qtde", FemeLote AS "Fêmeas"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Lote'' AS "Controle", NomeLote AS "Nome", (FemeLote+MachLote) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(FemeLote+MachLote)'))+sgLn+
                                                 ' FROM MPViLote'+sgLn+
                                                 ' WHERE (AtivLote <> 0) AND (LoImLote = 0) AND (GeraLote = 0)';
      //Incubatório
      02: begin
            Auxi := FormNumeSQL(PegaParaNume(000,'IPGeraTipoIncu'));
            if Auxi <> '0' then
              Auxi := ' AND (INGeAmbi.CodiSeto = '+Auxi+')'
            else
              Auxi := '';
            Result := SeStri(ModoConsulta=mcProd,  'SELECT NomeAmbi AS "Ambiente", QtEnTrAm AS "Qtde", DataTrAm AS "Data"',
                      SeStri(ModoConsulta=mcUnion, 'SELECT ''Ovos Incubados'' AS "Controle", NomeAmbi AS "Nome", QtEnTrAm AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                   'SELECT SUM(QtEnTrAm)'))+sgLn+
                                                   ' FROM INCaTrAm INNER JOIN INGeAmbi ON INCaTrAm.CodiAmbi = INGeAmbi.CodiAmbi'+sgLn+
                                                   ' WHERE (MarcTrAm < 2) AND (DataTrAm BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+sgLn+
                                                   ')'+Auxi;
          end;
      //Fábrica de Ração
      06: Result := SeStri(ModoConsulta=mcProd,  'SELECT ReceEsto AS "Data", SUM(QTTOMVES) AS "Qtde", NomeProd AS "Produto", NomeTpMv As "Tipo Movim."',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Ton Produzidas'' AS "Controle", NomeProd AS "Nome", SUM(QTTOMVES) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(QTTOMVES)/1000'))+sgLn+
                                                 ' FROM POCAMVES INNER JOIN POGEESTO ON POCAMVES.CODIESTO = POGEESTO.CODIESTO'+sgLn+
                                                 '               INNER JOIN POGEPROD ON POGEPROD.CODIPROD = POCAMVES.CODIPROD'+sgLn+
                                                 '               INNER JOIN POCATPMV ON POCATPMV.CODITPMV = POGEESTO.CODITPMV'+sgLn+
                                                 'WHERE (SistProd LIKE ''%06%'') AND (TipoTpMv BETWEEN 0 AND 10) AND (CompProd = 1) AND (ReceEsto BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')'+sgLn+
                    SeStri(ModoConsulta=mcUnion, 'GROUP BY ReceEsto, NomeProd, NomeTpMv',
                    SeStri(ModoConsulta=mcUnion, 'GROUP BY NomeProd',''))
                                                 ;
      //Abatedouro
      07: Result := SeStri(ModoConsulta=mcProd,  'SELECT DataFePr AS "Data", SUM(AVESFEPR) AS "Qtde"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Aves Abatidas'' AS "Controle", DateTimeFormat(''DD/MM/YYYY'',DataFePr) AS "Nome", SUM(AVESFEPR) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(AVESFEPR)/4.33'))+sgLn+
                                                 ' FROM ABGEFEPR'+sgLn+
                                                 ' WHERE (DataFePr BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')'+sgLn+
                    SeStri(ModoConsulta=mcProd,  'GROUP BY DataFePr',
                    SeStri(ModoConsulta=mcUnion, 'GROUP BY DateTimeFormat(''DD/MM/YYYY'',DataFePr)',''));
      //Expedição
      82: Result := SeStri(ModoConsulta=mcProd,  'SELECT DataPesa AS "Data", LiquPesa/1000 AS "Qtde", NumePesa AS "Pesagem", TipoPesa AS "Tipo"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Ton Expedidas'' AS "Controle", DateTimeFormat(''DD/MM/YYYY'',DataPesa) AS "Nome", SUM(LiquPesa)/1000 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT SUM(LiquPesa)/1000'))+sgLn+
                                                 ' FROM POGePesa'+sgLn+
                                                 ' WHERE (TextPesa = ''Peso Final'') AND (TipoPesa <> ''CER'')'+sgLn+
                                                 '   AND (DataPesa BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')'+sgLn+
                    SeStri(ModoConsulta=mcUnion, 'GROUP BY DateTimeFormat(''DD/MM/YYYY'',DataPesa)','');
      //NFe
      23: Result := SeStri(ModoConsulta=mcProd,  'SELECT EmisNota AS "Data", 1 AS "Qtde", ChavNota AS "Chave"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Notas Emitidas'' AS "Controle", DateTimeFormat(''DD/MM/YYYY'',EmisNota) AS "Nome", COUNT(*) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM POGeNota'+sgLn+
                                                 ' WHERE (ChavNota IS NOT NULL) AND (EmisNota BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')'+sgLn+
                    SeStri(ModoConsulta=mcUnion, 'GROUP BY DateTimeFormat(''DD/MM/YYYY'',EmisNota)','');
      //Folha de Pagamanto --Colaboradores Ativos
      28: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Colaborador", 1 AS "Qtde", AdmiCola AS "Admissão"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Colaborador'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM FPGeCola INNER JOIN POGePess ON FPGeCola.CodiPess = POGePess.CodiPess'+sgLn+
                                                 ' WHERE (AtivPess <> 0) AND (AtivCola <> 0)';
      //Cartão Ponto --Colaboradores Ativos
      29: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Colaborador", 1 AS "Qtde", AdmiCola AS "Admissão"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Colaborador'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM FPGeCola INNER JOIN POGePess ON FPGeCola.CodiPess = POGePess.CodiPess'+sgLn+
                                                 ' WHERE (AtivPess <> 0) AND (AtivCola <> 0)';
      //PDA Coleta --Vendedores/Supervisores
      70: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Pessoa", 1 AS "Qtde"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Técnico/Supervisor'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM POGePess'+sgLn+
                                                 ' WHERE ((SupePess <> 0) or (VendPess <> 0)) AND (AtivPess <> 0)  AND (StrLen(CorrPess) > 0)';
      //PDA Vendas
      71: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Pessoa", 1 AS "Qtde"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Vendedor'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM POGePess'+sgLn+
                                                 ' WHERE ((SupePess <> 0) or (VendPess <> 0)) AND (AtivPess <> 0)  AND (StrLen(CorrPess) > 0)';
      //PDA Coletor
      88: Result := SeStri(ModoConsulta=mcProd,  'SELECT NomePess AS "Pessoa", 1 AS "Qtde"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Técnico/Supervisor'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM POGePess'+sgLn+
                                                 ' WHERE ((SupePess <> 0) or (VendPess <> 0)) AND (AtivPess <> 0)  AND (StrLen(CorrPess) > 0)';
      //SAG Coletor - Liberado
      87: Result := SeStri(ModoConsulta=mcProd,  'SELECT '''' AS "Pessoa", 0 AS "Qtde"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Livre'' AS "Controle", '''' AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT 0'))+sgLn+
                                                 ' FROM POCaAuxi';
      //Pecuária
      41: Result := SeStri(ModoConsulta=mcProd,  'SELECT RegiGado AS "Registro", 1 As "Qtde", NomeGado AS "Nome"',
                    SeStri(ModoConsulta=mcUnion, 'SELECT ''Gado'' AS "Controle", NomeGado AS "Nome", 1 AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                 'SELECT COUNT(*)'))+sgLn+
                                                 ' FROM PECAGADO PEGeGado'+sgLn+
                                                 ' WHERE (AtivGado <> 0)';
    else  //Usuários
      //Acessos para o Usuário (deste Módulo)
      Result := GetSQL_AcesUsua();
    end;
  end
  else
    Result := ''
end;

function TsgSenh.GetSQL_Num1: String;
var
  DataAtua: TDateTime;
  InicMes, FinaMes: TDateTime;
begin
  if TipoCont = '4' then  //Retorna os usuários com acesso completo
    Result := SeStri(ModoConsulta=mcProd,  'UNION ALL SELECT NomePess AS "Pessoa", 1 AS "Qtde", ''Completo'' AS "Tipo"',
              SeStri(ModoConsulta=mcUnion, 'SELECT ''Pessoa'' AS "Controle", NomePess AS "Nome", 1 AS "Qtde", ''Acesso Completo'' AS "Tipo" /*PERS*/',
                                           'SELECT COUNT(*)'))+sgLn+
                                          ' FROM POGePess'+sgLn+
                                          ' WHERE '+cFiltPessSenh+' AND (CorrPess = ''Completo'')'
  else if TipoCont = '6' then  //Acesso Simultaneo
  begin
    if GetPBas = 4 then
      Result := SeStri(ModoConsulta=mcProd,  'SELECT USERNAME AS "Pessoa", 1 AS "Qtde"',
                SeStri(ModoConsulta=mcUnion, 'SELECT ''Pessoa'' AS "Controle", USERNAME AS "Nome", 1 AS "Qtde", ''Acesso Simultâneo'' AS "Tipo" /*PERS*/',
                                             'SELECT COUNT(*)'))+sgLn+
                                             ' FROM VSESSION'+sgLn+
                                             ' WHERE (USERNAME <> '+QuotedStr(AnsiUpperCase(GetPApePess()))+') AND (AUDSID <> (SYS_CONTEXT(''USERENV'', ''SESSIONID'')))'
    else
      Result := SeStri(ModoConsulta=mcProd,  'SELECT Loginame AS "Pessoa", 1 AS "Qtde"',
                SeStri(ModoConsulta=mcUnion, 'SELECT ''Pessoa'' AS "Controle", Loginame AS "Nome", 1 AS "Qtde", ''Acesso Simultâneo'' AS "Tipo" /*PERS*/',
                                             'SELECT COUNT(*) AS VALO'))+sgLn+
                                             ' FROM MASTER.DBO.SYSPROCESSES'+sgLn+
                                             ' WHERE (loginame <> SYSTEM_USER) and (spid <> @@SPID) AND (Program_Name LIKE ''ERP SAG%'')';
  end
  else if TipoCont = '1' then
  begin
    DataAtua := IncMonth(PDataServ,-1);
    InicMes  := EncodeDate(Year(DataAtua),Month(DataAtua),01);
    FinaMes  := EncodeDate(Year(DataAtua),Month(DataAtua),DaysInAMonth(Year(DataAtua),Month(DataAtua)));

    case StrToInt(SistCont) of
      //Abatedouro (quando retorna zero no ABGEFEPR testa esse segundo SQL
      07: begin
            if (NumeContReal > 0) then  //Quando for por volume, verifica se o ContNumeRal > 0, se for, não precisa da segunda parte
              Result := ''
            else
              Result := SeStri(ModoConsulta=mcProd,  'UNION ALL SELECT DataApon AS "Data", SUM(EntrApon*LiquApon) AS "Qtde"',
                        SeStri(ModoConsulta=mcUnion, 'SELECT ''Aves Abatidas'' AS "Controle", DateTimeFormat(''DD/MM/YYYY'',DataApon) AS "Nome", SUM(EntrApon*LiquApon) AS "Qtde", ''Volume'' AS "Tipo" /*PERS*/',
                                                     'SELECT SUM(EntrApon*LiquApon)/2.5/4.33'))+sgLn+
                                                     ' FROM ABGEAPON'+sgLn+
                                                     ' WHERE (SituApon IN (''APON'',''ACER'')) AND (DataApon BETWEEN '+FormDataSQL(InicMes)+' AND '+FormDataSQL(FinaMes)+')'+sgLn+
                        SeStri(ModoConsulta=mcProd,  'GROUP BY DataApon',
                        SeStri(ModoConsulta=mcUnion, 'GROUP BY DateTimeFormat(''DD/MM/YYYY'',DataApon)',''));
          end;
    else
      Result := '';
    end;
  end
  else
    Result := '';
end;

function TsgSenh.GetNumeContReal: Integer;
begin
  if Trim(SQL_Nume) <> '' then
  begin
    if ModoConsulta <> mcTota then
      Result := CalcRegi(SQL_Nume)
    else
      Result := CalcInte(SQL_Nume);
  end
  else
    Result := 0;
end;

function TsgSenh.GetNum1ContReal: Integer;
var
  vSQL: String;
begin
  vSQL := SQL_Num1;
  if Trim(vSQL) <> '' then
  begin
    if sgCopy(vSQL, 01, 09) = 'UNION ALL' then
      vSQL := Copy(vSQL, 10, MaxInt);

    if ModoConsulta <> mcTota then
      Result := CalcRegi(vSQL)
    else
      Result := CalcInte(vSQL);
  end
  else
    Result := 0;
end;

function TsgSenh.GetDataAcesGrav: TDateTime;
begin
  Result := DataSenh_FormToDate(PegaParaSenh(000,'DataAcesSAG_Mana'));
end;

function TsgSenh.GetDataValiGrav: TDateTime;
begin
  Result := DataSenh_FormToDate(PegaParaSenh(000,'DataValiModu0'+SistCont));
end;

function TsgSenh.GetDataVencNumeGrav: TDateTime;
begin
  Result := DataSenh_FormToDate(PegaParaSenh(000,'DataVencNume0'+SistCont));
end;

function TsgSenh.GetDataVeriNumeGrav: TDateTime;
begin
  Result := DataSenh_FormToDate(PegaParaSenh(000,'DataVeriNume0'+SistCont));
end;

function TsgSenh.GetNumeAcesGrav: Integer;
begin
  Result := sgStrToInt(PegaParaSenh(000,'NumeAcesModu0'+SistCont));
end;

function TsgSenh.GetNum1ContGrav: Integer;
begin
  Result := sgStrToInt(PegaParaSenh(000,'Num1ContModu0'+SistCont));
end;

function TsgSenh.GetNumeContGrav: Integer;
begin
  Result := sgStrToInt(PegaParaSenh(000,'NumeContModu0'+SistCont));
end;

function TsgSenh.GetNumeSeriGrav: String;
begin
  Result := PegaParaSenh(000,'NumeSeriSAG_Mana');
end;

function TsgSenh.GetTipoContGrav: String;
begin
  Result := PegaParaSenh(000,'TipoContModu0'+SistCont);
end;

//Buscar a situação de todos os módulos liberados
function TsgSenh.SenhModu_Todo(): String;
var
  Usua, Sist, Empr, NumeModu, vNumeContReal, vNumeContGrav, vNum1ContGrav: Integer;
  Dife: String;
  //Valido: Boolean;
  List: TStringList;
begin
  Usua := GetPUsu();
  Sist := GetPSis() ;
  Empr := GetPEmp();
  NumeModu := 0;
  List := TStringList.Create;
  try
    List.Clear;
    List.Add(GetPNomSoft+' - Versão '+RetoVers);
    List.Add('');
    List.Add('Mod - '+
              EspaDire('Nome Módulo',30)+ ' - '+
              EspaEsqu('Valor Atual',12)+ ' - '+
              EspaEsqu('Valor Liberado',12)+ ' - '+
              EspaEsqu('Diferença',12)+ '   - '+
              EspaDire('Tipo',20)+ ' - '+
              EspaDire('Data',10)
              );
    List.Add('----  '+
              Replicate('-',30)+ ' - '+
              Replicate('-',12)+ ' - '+
              Replicate('-',12)+ ' - '+
              Replicate('-',12)+ '   - '+
              Replicate('-',20)+ ' - '+
              Replicate('-',10)
              );
    with DtmPoul do
    begin
      QryAuxi.SQL.Clear;
      QryAuxi.SQL.Add('SELECT CLCaProd.CodiProd, NomeProd');
      QryAuxi.SQL.Add('FROM CLCaProd');
      QryAuxi.SQL.Add('WHERE (AtivProd <> 0)');
      //QryAuxi.SQL.Add('GROUP BY CLCaProd.CodiProd, NomeProd');
      QryAuxi.SQL.Add('ORDER BY CLCaProd.CodiProd');
      QryAuxi.Open;
      while not QryAuxi.Eof do
      begin
        ExibMensHint(QryAuxi.FieldByName('NomeProd').AsString);
        SetPSis(QryAuxi.FieldByName('CodiProd').AsInteger);
        GravPOCaConf();

        SistCont := IntToStr(GetPSis());

        try
          TipoCont := TipoContGrav;

          vNumeContGrav := NumeContGrav;
          vNum1ContGrav := Num1ContGrav;
          if (vNumeContGrav+vNum1ContGrav) > 0 then  //Se tiver valor liberado, mostra
          begin
            Inc(NumeModu);

            if SQL_Nume <> '' then
            begin
              vNumeContReal := NumeContReal;
              if (vNumeContReal > 0) or (SQL_Num1 = '') then  //Senão pode ter uma segunda verificação
              begin
                if not ValidaModuloReal then
                  Dife := EspaEsqu(FormInteBras(vNumeContReal - vNumeContGrav),12) + ' *'
                else
                  Dife := EspaEsqu('0',12)+'  ';

                List.Add( SistCont+ ' - '+
                          EspaDire(QryAuxi.FieldByName('NomeProd').AsString,30)+ ' - '+
                          EspaEsqu(FormInteBras(vNumeContReal),12)+ ' - '+
                          EspaEsqu(FormInteBras(vNumeContGrav),12)+ ' - '+
                          Dife+ ' - '+
                          EspaDire(TipoLicenca,20)+ ' - '+
                          EspaEsqu(FormDataBras(DataValiGrav),10)
                          );
              end;
            end;
            if SQL_Num1 <> '' then
            begin
              vNumeContReal := Num1ContReal;
              if vNum1ContGrav = 0 then
                vNumeContGrav := NumeContGrav
              else
                vNumeContGrav := vNum1ContGrav;

              if not ValidaModuloReal then
                Dife := EspaEsqu(FormInteBras(vNumeContReal - vNumeContGrav),12) + ' *'
              else
                Dife := EspaEsqu('0',12)+'  ';

              List.Add( SistCont+ ' - '+
                        EspaDire(QryAuxi.FieldByName('NomeProd').AsString,30)+ ' - '+
                        EspaEsqu(FormInteBras(vNumeContReal),12)+ ' - '+
                        EspaEsqu(FormInteBras(vNumeContGrav),12)+ ' - '+
                        Dife+ ' - '+
                        EspaDire(TipoLicenca,20)+ ' - '+
                        EspaEsqu(FormDataBras(DataValiGrav),10)
                        );
            end;
          end;
        except
          List.Add(ZeroEsqu(QryAuxi.FieldByName('CodiProd').AsString,03)+ ' - '+
                            EspaDire(QryAuxi.FieldByName('NomeProd').AsString,30)+ ' - '+
                            '*** ERRO ***');
        end;
        QryAuxi.Next;
      end;
      QryAuxi.Close;
    end;

  finally
    List.Add(Replicate('-',118));
    List.Add('Módulos: '+FormInteBras(NumeModu));
    Result := List.Text;
    List.Free;
    SetPUsu(Usua);
    SetPCodPess(CalcStri('SELECT PCodPess FROM POGePess WHERE (CodiPess = '+IntToStr(GetPUsu())+')'));
    SetPSis(Sist);
    SetPEmp(Empr);
    SetPCodEmpr(CalcStri('SELECT PCodEmpr FROM POCaEmpr WHERE (CodiEmpr = '+IntToStr(GetPEmp())+')'));
    GravPOCaConf();
  end;
end;

{ TMovi }

destructor TMovi.Destroy;
begin
  FreeAndNil(fTbsMovi);
  FreeAndNil(fFraCaMv);
  inherited;
end;

function TMovi.GetCodiTabe: Integer;
begin
  if fGeTaTabe = 0 then
    Result := fCodiTabe
  else
    Result := fGeTaTabe;
end;

function TMovi.GetFraMovi: TFraGrMv;
begin
  Result := FraCaMv.FraMovi;
end;

function TMovi.GetPnlMovi: TsgPnl;
begin
  Result := FraCaMv.PnlMovi;
end;

function TMovi.GetPnlResu: TsgPnl;
begin
  Result := FraCaMv.PnlResu;
end;

procedure FSXXImNF_ProcessarNotas(Prot: String; Arqu: String='');
{ Processa as notas e insere os dados na POGENOTA, POCAMVNO, POGEFINA e POCAMVFI }
var
  QryImpo, QryMvIn, QryImPr, QryUnMe: TsgQuery;
  Codi, IntAuxi, Cont, I: Integer;
  bEvento, bExcluir, bNota_OK, bValiLoPr: Boolean;
  vChave, vErro, vErroTpMv, vErroSeto, vErroLoPr: String;

  // Nota Fiscal
  vPOGeNota_D: TPOGeNota_D;
  vCodiSeto, vCodiTpMv: Integer;
  vFato, pDif: Real;
  vCGC, vOrig, vNomeNatu: String;
  bMvNo_OK: Boolean;

  // Financeiro
  vPOGeFina_D: TPOGeFina_D;
  vCodiCond, vCodCTpMv, vCodiTpDo, vCodiCard, tBand, tPag, indPag, tpIntegra: Integer;
  vPag, vTroco, vPag_Total: Real;
  Bandeira, CNPJ, cAut, Tipo, Forma, xPag, CNPJPag, UFPag, CNPJRec, idTermPag: String;
  dPag: TDateTime;

  // Evento
  cStat: Integer;
  tpEvento, xEvento, xJust: String;

  // IMNF
  function InicValoNota_Valo(Filt: String):String;
  begin
    if (Filt = 'ide_dEmi') then
      QryImpo.Filter := '(CampImNF = ''ide_dEmi'' or CampImNF = ''ide_dhEmi'')'
    else
      QryImpo.Filter := '(CampImNF = '+QuotedStr(Filt) +')';

    QryImpo.Filtered := True;

    if QryImpo.FieldByName('ValoImNF').AsString <> '' then
      Result := QryImpo.FieldByName('ValoImNF').AsString
    else
      Result := QryImpo.FieldByName('Val1ImNF').AsString;
  end;

  function InicValoNota_FormData(Data: String): String; //YYYY-MM-DD para DD/MM/YYYY
  begin
    Result := EspaDire(Copy(Data,09,02),02) + '/' +
              EspaDire(Copy(Data,06,02),02) + '/' +
              EspaDire(Copy(Data,01,04),04);
  end;

  // MVIN
  function BuscValo(Item: Integer; Filt: STring):String;
  begin
    QryMvIn.Filtered := False;
    QryMvIn.Filter := '(ItemMvIN = '+IntToStr(Item)+') and (CampMvIN = '+QuotedStr(Filt)+')';
    QryMvIn.Filtered := True;
    if QryMvIn.FieldByName('ValoMvIN').AsString <> '' then
      Result := QryMvIn.FieldByName('ValoMvIN').AsString
    else
      Result := QryMvIn.FieldByName('Val1MvIN').AsString;
  end;

  function BuscValoLike(Item: Integer; Filt: STring; Terminado: String = ''):String;
  begin
    Result := '';
    QryMvIn.Filtered := False;
    QryMvIn.Filter := '(ItemMvIN = '+IntToStr(Item)+') and '+Filt;
    QryMvIn.Filtered := True;
    while not QryMvIn.Eof do
    begin
      if (Terminado = '') or CompTextTerminado(QryMvIn.FieldByName('CampMvIN').AsString, Terminado) then
      begin
        if QryMvIn.FieldByName('ValoMvIN').AsString <> '' then
          Result := QryMvIn.FieldByName('ValoMvIN').AsString
        else
          Result := QryMvIn.FieldByName('Val1MvIN').AsString;
        Exit;
      end;
      QryMvIn.Next;
    end;
  end;

  // FINA
  function BuscaBandeira(aValo: Integer): String;
  { tBand - Bandeira da Operadora de cartão de crédito e/ou débito }
  begin
    case aValo of
      01: Result := '01=Visa';
      02: Result := '02=Mastercard';
      03: Result := '03=American Express';
      04: Result := '04=Sorocred';
      05: Result := '05=Diners Club';
      06: Result := '06=Elo';
      07: Result := '07=Hipercard';
      08: Result := '08=Aura';
      09: Result := '09=Cabal';
      10: Result := '10=Alelo';
      11: Result := '11=Banes Card';
      12: Result := '12=CalCard';
      13: Result := '13=Credz';
      14: Result := '14=Discover';
      15: Result := '15=GoodCard';
      16: Result := '16=GreenCard';
      17: Result := '17=Hiper';
      18: Result := '18=JcB';
      19: Result := '19=Mais';
      20: Result := '20=MaxVan';
      21: Result := '21=Policard';
      22: Result := '22=RedeCompras';
      23: Result := '23=Sodexo';
      24: Result := '24=ValeCard';
      25: Result := '25=Verocheque';
      26: Result := '26=VR';
      27: Result := '27=Ticket';
      99: Result := '99=Outros';
      else Result := IntToStr(aValo);
    end;
  end;

  function BuscaForma(aValo: Integer): String;
  { indPag - Indicador da Forma de Pagamento }
  begin
    case aValo of
      00: Result := '0=Pagamento à Vista';
      01: Result := '1=Pagamento à Prazo';
      else Result := '';
    end;
  end;

  function BuscaTipo(aValo: Integer): String;
  { tPag - Meio de Pagamento }
  begin
    case aValo of
      01: Result := '01=Dinheiro';
      02: Result := '02=Cheque';
      03: Result := '03=Cartão de Crédito';
      04: Result := '04=Cartão de Débito';
      05: Result := '05=Cartão da Loja (Private Label), Crediário Digital, Outros Crediários';
      10: Result := '10=Vale Alimentação';
      11: Result := '11=Vale Refeição';
      12: Result := '12=Vale Presente';
      13: Result := '13=Vale Combustível';
      14: Result := '14=Duplicata Mercantil';
      15: Result := '15=Boleto Bancário';
      16: Result := '16=Depósito Bancário';
      17: Result := '17=Pagamento Instantâneo (PIX) - Dinâmico';
      18: Result := '18=Transferência bancária, Carteira Digital';
      19: Result := '19=Programa de fidelidade, Cashback, Crédito Virtual';
      20: Result := '20=Pagamento Instantâneo (PIX) - Estático';
      21: Result := '21=Crédito em Loja';
      22: Result := '22=Pagamento Eletrônico não Informado - falha de hardware do sistema emissor';
      90: Result := '90=Sem Pagamento';
      99: Result := '99=Outros';
      else Result := IntToStr(aValo);
    end;
  end;

  procedure SalvaInfoPaga(aCodiNota: Integer);
  { Salva as informações de pagamento }
  var
    i: Integer;
    sAuxi: String;
  begin
    if aCodiNota = 0 then Exit;

    Cont := CalcInte('SELECT MAX(ItemMvIN) FROM FSXXMvIN WHERE (ProtMvIN = '+QuotedStr(Prot)+') AND (CAMPMVIN = ''pag_detPag_vPag'')');
    for i := 1 to Cont do
    begin
      indPag  := StrToIntDef(        BuscValoLike(i,'(CampMvIN = ''pag_detPag_indPag'')'),99);     // Forma de Pagamento
      tPag    := StrToIntDef(        BuscValoLike(i,'(CampMvIN = ''pag_detPag_tPag'')'),99);       // Meio de Pagamento
      xPag    :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_xPag'')');           // Descrição do Meio de Pagamento
      vPag    := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN = ''pag_detPag_vPag'')')));         // Valor do Pagamento
      CNPJPag :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_CNPJPag'')');        // CNPJ transacional do pagamento
      UFPag   :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_UFPag'')');          // UF do CNPJ do estabelecimento onde o pagamento foi processado/transacionado/recebido
      tpIntegra := StrToIntDef(      BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_tpIntegra'')'),99); // Tipo de Integração para pagamento
      CNPJ    :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_CNPJ'')');      // CNPJ da instituição de pagamento
      tBand   := StrToIntDef(        BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_tBand'')'),99); // Bandeira da operadora de cartão de crédito e/ou débito
      cAut    :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_cAut'')');      // Número de autorização da operação com cartões, PIX, boletos e outros pagamentos eletrônicos
      CNPJRec :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_CNPJReceb'')'); // CNPJ do beneficiário do pagamento
      idTermPag :=                   BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_idTermPag'')'); // Identificador do terminal de pagamento

      sAuxi := BuscValoLike(i,'(CampMvIN = ''pag_detPag_dPag'')');
      if Trim(sAuxi) <> '' then
        dPag := StrToDate(FormData(InicValoNota_FormData(sAuxi))); // Data do Pagamento

      sAuxi := BuscValoLike(i,'(CampMvIN = ''pag_vTroco'')'); // Valor do Troco
      if Trim(sAuxi) <> '' then
        vTroco := StrToFloat(FormReal(sAuxi));

      Forma    := BuscaForma(indPag);
      Tipo     := BuscaTipo(tPag);
      Bandeira := BuscaBandeira(tBand);

      ExecSQL_('DELETE FROM POXXMVFI WHERE (CODINOTA = '+IntToStr(aCodiNota)+')', vPOGeNota_D.Conn);

      InseDadoTabe('POXXMVFI',
                  ['CODINOTA', IntToStr(aCodiNota),
                   'INDPMVFI', QuotedStr(Forma),
                   'TPAGMVFI', QuotedStr(Tipo),
                   'XPAGMVFI', QuotedStr(xPag),
                   'VPAGMVFI', FormNumeSQL(vPag),
                   'DPAGMVFI', FormDataSQL(dPag),
                   'CPAGMVFI', QuotedStr(CNPJPag),
                   'UPAGMVFI', QuotedStr(UFPag),
                   'TPINMVFI', IntToStr(tpIntegra),
                   'CNPJMVFI', QuotedStr(CNPJ),
                   'BANDMVFI', QuotedStr(Bandeira),
                   'CAUTMVFI', QuotedStr(cAut),
                   'CRECMVFI', QuotedStr(CNPJRec),
                   'IDTEMVFI', QuotedStr(idTermPag),
                   'VTROMVFI', FormNumeSQL(vTroco)
                  ],'');
    end;
  end;

  function ConvertDataStringToDateTime(const aDateStr: string): TDateTime;
  { A string de entrada é algo como "Sun Dec 01 13:29:20 BRT 2024" }
  var
    MesDiaParte, HoraParte, AnoParte: String;
    MesParte: String;
    Mes: Integer;
  begin
    // Extraímos o mês, o dia, a hora, o minuto, o segundo e o ano
    MesDiaParte := Copy(aDateStr, 5, Length(aDateStr) - 22);  // "Dec 01"
    HoraParte := Copy(aDateStr, 12, 8);  // "13:29:20"
    AnoParte := RightStr(aDateStr,4);  //"2024"

    // Pegue o mês de forma textual (Ex: 'Dec' para '12')
    MesParte := AnsiUpperCase(Copy(MesDiaParte, 1, 3));
    if MesParte = AnsiUpperCase('Jan') then Mes := 1
    else if MesParte = AnsiUpperCase('Feb') then Mes := 2
    else if MesParte = AnsiUpperCase('Mar') then Mes := 3
    else if MesParte = AnsiUpperCase('Apr') then Mes := 4
    else if MesParte = AnsiUpperCase('May') then Mes := 5
    else if MesParte = AnsiUpperCase('Jun') then Mes := 6
    else if MesParte = AnsiUpperCase('Jul') then Mes := 7
    else if MesParte = AnsiUpperCase('Aug') then Mes := 8
    else if MesParte = AnsiUpperCase('Sep') then Mes := 9
    else if MesParte = AnsiUpperCase('Oct') then Mes := 10
    else if MesParte = AnsiUpperCase('Nov') then Mes := 11
    else if MesParte = AnsiUpperCase('Dec') then Mes := 12
    else
      raise Exception.Create('Mês inválido (' +aDateStr +')');

    // Combina as partes para criar o valor TDateTime
    try
      Result := EncodeDate(StrToInt(AnoParte), Mes, StrToInt(Copy(MesDiaParte, 5, 2))) +
                StrToTime(HoraParte);
    except
      raise Exception.Create('Data inválida: ' +aDateStr);
    end;
  end;

  function ValidaFinanceiro_Gera(CodiNota: Integer; Conn: TObject=nil): Boolean;
  { Valida se o CFOP gera financeiro }
  begin
    if CodiNota > 0 then
      Result := CalcInte('SELECT MAX(FATUNATU) FROM POCaNatu Natu ' +
                                              'INNER JOIN POCAMVNO MvNo ON Natu.CodiNatu = MvNo.CodiNatu ' +
                                              'WHERE (MvNo.CodiNota = ' +IntToStr(CodiNota) +')', Conn) > 0
    else
      Result := False;
  end;

  function ValidaImportacao_OK(Prot: String): Boolean;
  { Valida se a importacao não teve erros }
  begin
    Result := CalcInte('SELECT COUNT(0) FROM FSXXImNF ImNF WHERE (ImNF.ProtImNF = ' +QuotedStr(Prot) +') AND (ImNF.CampImNF = ''SAG_ERRO'')') = 0;
  end;

begin
  if Pos('ID',Prot) = 0 then
  begin
    bEvento := False;
    if (Pos('NFe',Prot) = 0) then
      Prot := 'NFe'+Prot;
  end
  else
    bEvento := True;

  vChave := SubsPalaTudo(SeStri(bEvento,Arqu,Prot),'NFe','');
  vChave := SubsPalaTudo(vChave,'canc','');
  if vChave = '' then
    Exit;

  vPOGeNota_D := TPOGeNota_D.Create;
  vPOGeFina_D := TPOGeFina_D.Create;
  QryImpo := TsgQuery.Create(nil);
  QryMvIn := TsgQuery.Create(nil);
  QryImPr := TsgQuery.Create(nil);
  QryUnMe := TsgQuery.Create(nil);
  QryImpo.Name := 'QryImpo';
  QryMvIn.Name := 'QryMvIn';
  QryImPr.Name := 'QryImPr';
  QryUnMe.Name := 'QryUnMe';
  try
    vPOGeNota_D.Conn     := GetPADOConn;
    vPOGeNota_D.sgForm   := nil;
    vPOGeNota_D.MetoSave := msObj;
    vPOGeNota_D.UsaTrans := True;
    vPOGeNota_D.LimparDts:= True;

    QryImpo.SQL.Add('SELECT * FROM FSXXImNF');
    QryImpo.SQL.Add(' WHERE (ProtImNF = '+QuotedStr(Prot)+')');

    QryMvIn.SQL.Add('SELECT * FROM FSXXMvIN');
    QryMvIn.SQL.Add(' WHERE (ProtMvIN = '+QuotedStr(Prot)+')');

    QryImPr.SQL.Add('SELECT POCAPROD.CODIPROD, POCATPMV.CODITPMV, POCASETO.CODISETO, FSXXIMPR.CODITPMV AS VALITPMV, FSXXIMPR.CODISETO AS VALISETO');
    QryImPr.SQL.Add(' FROM FSXXIMPR');
    QryImPr.SQL.Add(' INNER JOIN POCAPROD ON FSXXIMPR.CODIPROD = POCAPROD.CODIPROD');
    QryImPr.SQL.Add(' LEFT  JOIN POCATPMV ON FSXXIMPR.CODITPMV = POCATPMV.CODITPMV');
    QryImPr.SQL.Add(' LEFT  JOIN POCASETO ON FSXXIMPR.CODISETO = POCASETO.CODISETO');
    QryImPr.SQL.Add(' WHERE FSXXIMPR.PRODIMPR = 0');
    QryImPr.SQL.Add(' ORDER BY PDATIMPR DESC');

    QryUnMe.SQL.Add('SELECT CODIUNID, FATOUNME FROM POGEUNME');
    QryUnMe.SQL.Add(' WHERE CODINUNME = 0');

    QryImpo.Open;
    QryMvIn.Open;

    try
      vPOGeNota_D.CarregaBD(0, '*', 'WHERE CHAVNOTA = ' +QuotedStr(vChave));
      if bEvento then
      begin
        // INÍCIO Evento
        with vPOGeNota_D.NewPOGeNota_ do
        begin
          bNota_OK := ValidaImportacao_OK('NFe' +vChave);
          if not bNota_OK then
            vErro := 'Nota original não importada corretamente';

          if (CODINOTA > 0) and (SITUNOTA <> 'C') and (bNota_OK) then
          begin
            cStat := StrToIntDef(InicValoNota_Valo('retEvento_infEvento_cStat'),-1); // Código do status do registro do evento
            xEvento  := InicValoNota_Valo('retEvento_infEvento_xEvento');            // Descrição do evento
            tpEvento := InicValoNota_Valo('retEvento_infEvento_tpEvento');           // Tipo do evento
            if (not ContainsText(xEvento,'CANCELA')) and (ContainsText(tpEvento,'110111') or ContainsText(tpEvento,'110112')) then
              xEvento := 'CANCELA';
            if (cStat in [135,155]) and ContainsText(xEvento,'CANCELA') then
            begin
              NPRONOTA := InicValoNota_Valo('evento_infEvento_detEvento_nProt'); // Número do protocolo de autorização da NF-e
              MOCANOTA := InicValoNota_Valo('evento_infEvento_detEvento_xJust'); // Justificativa do cancelamento
              NFETNOTA := '4-CANCELADA';
              NMOTNOTA := InicValoNota_Valo('retEvento_infEvento_xMotivo'); // Motivo
              NPRCNOTA := InicValoNota_Valo('retEvento_infEvento_nProt');   // Número do protocolo de registro do evento
              SITUNOTA := 'C';
              APATNOTA := APATNOTA+1;
            end;
            vPOGeNota_D.Salv_Prepara(vPOGeNota_D.MetoSave, vPOGeNota_D.UsaTrans, True, opIncl, vPOGeNota_D.Conn, nil, True);
            vPOGeNota_D.Save_Obj;

            // Cancela o financeiro
            try
              if (cStat in [135,155]) and ContainsText(xEvento,'CANCELA') then
              begin
                AlteDadoTabe('POGEFINA',
                            ['SITUFINA', QuotedStr('C'),
                             'APATFINA', 'APATFINA + 1'
                            ],'WHERE CODIGENE = ' +IntToStr(CODINOTA) +' AND TABEFINA = ''POCANOTA''');
              end;
            except
            end;
          end;
        end;
        //FIM Evento
      end
      else
      begin
        // INÍCIO Nota Fiscal
        with vPOGeNota_D.NewPOGeNota_ do
        begin
          if (CODINOTA = 0) or (CODIEMPR = 0) or (CODIPESS = 0) or (ESTOTPMV = 0) or (ESTOSETO = 0) or (CalcInte('SELECT COUNT(0) FROM POCaMvNo WHERE (POCaMvNo.CodiNota = '+IntToStr(CODINOTA) +') AND (POCaMvNo.MarcMvNo = 1)' ) > 0) then
          begin
            CHAVNOTA := vChave;
            if SITUNOTA = '' then
              SITUNOTA := 'G';

//            vCGC := InicValoNota_Valo('dest_CNPJ').Trim;
//            if vCGC = '' then
//              vCGC := InicValoNota_Valo('dest_CPF').Trim;
//
//            if vCGC = '' then
//              Codi := Trunc(PegaParaNume(26350, 'IMNF_PESS_API'))
//            else
//              Codi := 0;
//
//            if vCGC <> '' then
//              CODIPESS := CalcInte('SELECT MAX(CODIPESS) FROM POGEPESS WHERE CGC_PESS = ' +QuotedStr(vCGC))
//            else if Codi > 0 then
//              CODIPESS := CalcInte('SELECT MAX(CODIPESS) FROM POGEPESS WHERE CodiPess = ' +IntToStr(Codi))
//            else
//              CODIPESS := 0;

            // Alterado para considerar sempre o consumidor do parametro
            Codi := Trunc(PegaParaNume(26350, 'IMNF_PESS_API'));
            if Codi > 0 then
              CODIPESS := CalcInte('SELECT MAX(CODIPESS) FROM POGEPESS WHERE CodiPess = ' +IntToStr(Codi))
            else
              CODIPESS := 0;

            // Condição e Tipo de Movimento do Financeiro
            if CODIPESS > 0 then
            begin
              CalcInteDoisCamp('SELECT POCaClie.CodiCond, POCaClie.CodCTpMv FROM POCaClie'
                              +' WHERE (POCaClie.CodiPess = '+IntToStr(CODIPESS)+')', vCodiCond, vCodCTpMv);

              if vCodiCond = 0 then
                vCodiCond := CalcInte('SELECT MAX(CODICOND) FROM POCACOND WHERE VISTCOND = 1');

              if vCodCTpMv = 0 then
                vCodCTpMv := CalcInte('SELECT MAX(CodiTpMv) FROM POCaTpMv WHERE DESCTPMV = ''E'' AND LOCATPMV = ''F''');

              CODICOND := vCodiCond;
              CODITPMV := vCodCTpMv;
            end;

            //Emitente
            vCGC := InicValoNota_Valo('emit_CNPJ').Trim;
            if vCGC <> '' then
              CODIEMPR := CalcInte('SELECT MAX(CODIEMPR) FROM POCAEMPR WHERE CGC_EMPR = ' +QuotedStr(vCGC));

            SIDONOTA := '00';
            TIPONOTA := SeStri(InicValoNota_Valo('ide_mod')='0','E','S'); // Tipo (0=Entrada 1=Saída)
            SERINOTA := InicValoNota_Valo('ide_serie');                   // Série
            MODENOTA := InicValoNota_Valo('ide_mod');                     // Código do Modelo do Documento Fiscal
            FINANOTA := StrToIntDef(InicValoNota_Valo('ide_indFinal'),0); // Finalidade (1=NF-e normal 2=Complementar 3=Ajuste 4=Devolução)
            NUMENOTA := StrToIntDef(InicValoNota_Valo('ide_nNF'),0);      // Número do Documento Fiscal
            EMISNOTA := StrToDate(FormData(InicValoNota_FormData(InicValoNota_Valo('ide_dEmi'))));
            SAIDNOTA := StrToDate(FormData(InicValoNota_FormData(InicValoNota_Valo('ide_dEmi'))));
            HORANOTA := Copy(InicValoNota_Valo('ide_dEmi'),12,8); // Exemplo: 2022-03-09T12:17:51-03:00
            PSISNOTA := 'S23';

            EMITNOTA:= 'T'; // Emitente (P=Própria T=Terceiros)

            CFOPNOTA := '';
            CODINATU := 0;

            VALONOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vNF'))); // Valor Total da NF-e

            IntAuxi := StrToIntDef(InicValoNota_Valo('transp_modFrete'),9);
            FRCONOTA := SeStri(IntAuxi=9,'0',IntToStr(IntAuxi+1)); // Modalidade do Frete (9=Sem Ocorrência de Transporte)
            BAICNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vBC')));    // Base de Cálculo do ICMS
            VAICNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vICMS')));  // Valor Total do ICMS
            BASUNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vBCST')));  // Base de Cálculo do ICMS ST
            ICSUNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vST')));    // Valor Total do ICMS ST
            FRETNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vFrete'))); // Valor Total do Frete
            SEGUNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vSeg')));   // Valor Total do Seguro
            DCTONOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vDesc')));  // Valor Total do Desconto
            OUTRNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vOutro'))); // Outras Despesas acessórias
            VAIPNOTA := StrToFloat(FormReal(InicValoNota_Valo('total_ICMSTot_vIPI')));   // Valor Total do IPI
            ADI1NOTA := InicValoNota_Valo('infAdic_infCpl');
            OBS1NOTA := InicValoNota_Valo('infAdic_infAdFisco');
            TABENOTA := 'IMPONFCE';

            QRCONOTA := InicValoNota_Valo('NFe_infNFeSupl_qrCode');
            try
              NDATNOTA := XMLTimeToDateTime(InicValoNota_Valo('infProt_dhRecbto')); //Copy(InicValoNota_Valo('ide_dEmi'),12,8); // Exemplo: 2022-03-09T12:17:51-03:00
            except
              if Pos('BRT', InicValoNota_Valo('infProt_dhRecbto')) > 0 then  // Alguns XMLs estão com a tag no formato: Sun Dec 01 13:29:20 BRT 2024
                NDATNOTA := ConvertDataStringToDateTime(InicValoNota_Valo('infProt_dhRecbto'));
            end;
            NMOTNOTA := InicValoNota_Valo('infProt_cStat') +' - ' +InicValoNota_Valo('infProt_xMotivo');

            CODITRAN := 0;

            // INÍCIO Itens Nota Fiscal (POCAMVNO)
            bMvNo_OK  := True;
            bValiLoPr := PegaParaLogi(26350,'IMNF_SALV_LOPR');
            vCodiTpMv := 0;
            vCodiSeto := 0;
            vErroTpMv := '';
            vErroSeto := '';
            vErroLoPr := '';
            // Se está inserindo OU Inseriu os itens mas contém erros OU Inseriu mas não contem itens
            if (CODINOTA = 0)
              or (CalcInte('SELECT COUNT(0) FROM POCaMvNo WHERE (POCaMvNo.CodiNota = '+IntToStr(CODINOTA) +') AND (POCaMvNo.MarcMvNo = 1)' ) > 0)
              or (CalcInte('SELECT COUNT(0) FROM POCaMvNo WHERE (POCaMvNo.CodiNota = '+IntToStr(CODINOTA) +')' ) = 0) then
            begin
              if CODINOTA > 0 then
              begin
                APATNOTA  := APATNOTA + 1;
                ExecSQL_('DELETE FROM POCAMVNO WHERE (CODINOTA = '+IntToStr(CODINOTA)+')', vPOGeNota_D.Conn);
              end;

              Cont := CalcInte('SELECT MAX(ItemMvIN) FROM FSXXMvIN WHERE (ProtMvIN = '+QuotedStr(Prot)+') AND CAMPMVIN = ''prod_vProd''');
              for i := 1 to Cont do
              begin
                if Trim(BuscValo(i,'prod_cProd')) <> '' then
                begin
                  with vPOGeNota_D.pPOCaMvNo_D.NewPOCaMvNo_ do
                  begin
                    // Busca na FSXXIMPR
                    QryImPr.SQL.Strings[5] := ' WHERE FSXXIMPR.PRODIMPR = ' +QuotedStr(BuscValo(i,'prod_cProd'));
                    QryImPr.Open;
                    if (QryImPr.IsEmpty) then
                    begin
                      CODIPROD := 0;
                      CODISETO := 0;
                      CODITPMV := 0;
                    end
                    else
                    begin
                      CODIPROD := QryImPr.FieldByName('CodiProd').AsInteger; // Produto
                      CODISETO := QryImPr.FieldByName('CodiSeto').AsInteger; // Setor
                      CODITPMV := QryImPr.FieldByName('CodiTpMv').AsInteger; // Tipo de Movimento
                      if QryImPr.FieldByName('CodiTpMv').AsInteger > vCodiTpMv then
                        vCodiTpMv := QryImPr.FieldByName('CodiTpMv').AsInteger;
                      if QryImPr.FieldByName('CodiSeto').AsInteger > vCodiSeto then
                        vCodiSeto := QryImPr.FieldByName('CodiSeto').AsInteger;

                      // Validar se está na empresa logada
                      if (QryImPr.FieldByName('CodiTpMv').AsInteger = 0) and (QryImPr.FieldByName('ValiTpMv').AsInteger > 0) then
                        vErroTpMv := ' Tipo de Movimento não disponível para a empresa logada!';

                      if (QryImPr.FieldByName('CodiSeto').AsInteger = 0) and (QryImPr.FieldByName('ValiSeto').AsInteger > 0) then
                        vErroSeto := ' Setor não disponível para a empresa logada!';
                    end;
                    QryImPr.Close;

                    //xProd - Descrição do Produto ou Serviço
                    PRODMVNO := BuscValo(i,'prod_xProd') +' - ' +BuscValo(i,'prod_cProd');

                    // Busca a unidade
                    QryUnMe.SQL.Strings[1] := ' WHERE CODIPROD = ' +IntToStr(CODIPROD) +' AND CODIPESS = ' +IntToStr(CODIPESS) +' AND UPPER(FOUNUNME) LIKE ' +QuotedStr(AnsiUpperCase(Trim(BuscValo(i,'prod_uCom'))));
                    QryUnMe.Open;
                    // Tela de Unidade de Medidas (CODITABE 860)
                    vFato := 0;
                    if (QryUnMe.IsEmpty) or (QryUnMe.Fields[0].IsNull) then
                    begin
                      QryUnMe.Close;
                      QryUnMe.SQL.Strings[1] := ' WHERE CODIPROD IS NULL AND CODIPESS = ' + IntToStr(CODIPESS) + ' AND UPPER(FOUNUNME) LIKE '+ QuotedStr(AnsiUpperCase(Trim(BuscValo(i,'prod_uCom'))));
                      QryUnMe.Open;
                      if not (QryUnMe.IsEmpty) and not (QryUnMe.Fields[0].IsNull) then
                      begin
                        CODIUNID := QryUnMe.FieldByName('CODIUNID').AsInteger;
                        vFato    := QryUnMe.FieldByName('FATOUNME').AsFloat; //Fator Sag
                      end;
                    end
                    else
                    begin
                      CODIUNID := QryUnMe.FieldByName('CODIUNID').AsInteger;
                      vFato    := QryUnMe.FieldByName('FATOUNME').AsFloat; //Fator Sag
                    end;
                    QryUnMe.Close;

                    // Tela de Unidades (CODITABE 760)
                    if CODIUNID = 0 then
                      CODIUNID := CalcInte('SELECT MAX(CodiUnid) FROM POCaUnid WHERE (UPPER(NomeUnid) = ' +QuotedStr(AnsiUpperCase(Trim(BuscValo(i,'prod_uCom')))) +')');
                    UNIDMVNO := AnsiUpperCase(Trim(BuscValo(i,'prod_uCom')));

                    if vFato > 0 then
                      QTDEMVNO := StrToFloat(FormReal(BuscValo(i,'prod_qCom')))*vFato
                    else
                      QTDEMVNO := StrToFloat(FormReal(BuscValo(i,'prod_qCom')));
                    PESOMVNO := QTDEMVNO;
                    VALOMVNO := StrToFloat(FormReal(BuscValo(i,'prod_vProd')));
                    DCTOMVNO := StrToFloat(FormReal(BuscValo(i,'prod_vDesc')));

                    //vFrete - Valor do Frete
                    if FRETMVNO = 0 then
                      FRETMVNO := StrToFloat(FormReal(BuscValo(i,'prod_vFrete')));

                    // CFOP
                    //CFOP - Código Fiscal de Operações e Prestações
                    CFOPMVNO := StrToInt(RetoZero(BuscValo(i,'prod_CFOP')));
                    //natOp - Descrição da Natureza da Operação
                    vNomeNatu := CalcStri('SELECT MAX(ValoImNF) FROM FSXXImNF WHERE ProtImNF = ' +QuotedStr(Prot) +' AND CampImNF = ''ide_natOp''');
                    CODINATU  := CalcInte('SELECT MAX(CODINATU) FROM POCANATU WHERE CFOPNATU = ' +IntToStr(CFOPMVNO) +' AND UPPER(NOMENATU) = '  +QuotedStr(AnsiUpperCase(vNomeNatu)));

                    // COFINS
                    //CST - Código de Situação Tributária do COFINS
                    CSCOMVNO := ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_COFINS_COFINS%'') and ' +
                                                        '(CampMvIN LIKE ''%_CST%'')'),02);
                    //vBC - Valor da Base de Cálculo da COFINS
                    BACOMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_COFINS_COFINS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vBC%'')')));
                    //pCOFINS - Alíquota da COFINS (em percentual)
                    ALCOMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_COFINS_COFINS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_pCOFINS%'')')));
                    //vCOFINS - Valor da COFINS
                    COFIMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_COFINS_COFINS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vCOFINS%'')')));

                    // PIS
                    //CST - Código de Situação Tributária do PIS
                    CSPIMVNO := ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_PIS_PIS%'') and ' +
                                                        '(CampMvIN LIKE ''%_CST%'')'),02);
                    //pPIS - Alíquota do PIS (em percentual)
                    ALPIMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_PIS_PIS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_pPIS%'')')));
                    //vBC - Valor da Base de Cálculo do PIS
                    BAPIMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_PIS_PIS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vBC%'')')));
                    //vPIS - Valor do PIS
                    PIS_MVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_PIS_PIS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vPIS%'')')));

                    // IPI
                    //CST - Código de Situação Tributária do IPI
                    CSIPMVNO := ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                        '(CampMvIN LIKE ''%_CST%'')'),02);
                    if CSIPMVNO = '00' then
                      CSIPMVNO := ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                          '(CampMvIN LIKE ''%IPITrib_CST%'')'),02);
                    //vBC - Valor da Base de Cálculo do IPI
                    BAIPMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vBC%'')')));
                    if BAIPMVNO = 0 then
                      BAIPMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                                     '(CampMvIN LIKE ''%IPITrib_vBC%'')')));
                    //pIPI - Alíquota do IPI
                    ALIPMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                                   '(CampMvIN LIKE ''%_pIPI%'')')));
                    if ALIPMVNO = 0 then
                      ALIPMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                                     '(CampMvIN LIKE ''%IPITrib_pIPI%'')')));
                    //vIPI - Valor do IPI
                    VAIPMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vIPI%'')')));
                    if VAIPMVNO = 0 then
                      VAIPMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_IPI%'') and ' +
                                                                     '(CampMvIN LIKE ''%IPITrib_vIPI%'')')));

                    // Impostos 2
                    //orig - Origem da mercadoria
                    vOrig := ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and (CampMvIN LIKE ''%_orig%'')'),01);

                    //CST - Tributação do ICMS
                    CST_MVNO := vOrig +ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                               '(CampMvIN LIKE ''%_CST%'')'),02);

                    //pRedBC - Percentual da Redução de BC
                    ISENMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                                                  '(CampMvIN LIKE ''%_pRedBC%'')'
                                                                                                 ,'_pRedBC')));
                    //vBC - Valor da Base de Cálculo do ICMS
                    BAICMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                                                  '(CampMvIN LIKE ''%_vBC%'')'
                                                                                                 ,'_vBC')));
                    //pICMS - Alíquota do imposto
                    ALICMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                                                  '(CampMvIN LIKE ''%_pICMS%'')'
                                                                                                 ,'_pICMS')));
                    //vICMS - Valor do ICMS
                    VAICMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                                                  '(CampMvIN LIKE ''%_vICMS%'')'
                                                                                                 ,'_vICMS')));
                    // Diferimento
                    //pDif - Percentual do Diferimento
                    pDif := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                               '(CampMvIN LIKE ''%_pDif%'')'
                                                              ,'_pDif')));
                    DIBAMVNO := 0; // Base Dif. Alíquota
                    DIALMVNO := 0; // Dif. Alíquota
                    DIAVMVNO := 0; // Valor ICMS Diferencial
                    if pDif > 0 then
                    begin
                      // Diferimento Parcial
                      if pDif < 100 then
                      begin
                        DIBAMVNO := BAICMVNO;
                        DIALMVNO := RoundTo(DiveZero(VAICMVNO, BAICMVNO) * 100, -2);
                      end
                      else
                      // Diferimento Total
                      begin
                        DIBAMVNO := BAICMVNO;
                        DIALMVNO := ALICMVNO;
                      end;
                      //vICMSDif - Valor do ICMS diferido
                      DIAVMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                     '(CampMvIN LIKE ''%_vICMSDif%'')'
                                                                    ,'_vICMSDif')));
                    end;
                    //vBCST - Valor da Base de Cálculo do ICMS ST
                    BAITMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vBCST%'')')));
                    //pICMSST - Alíquota do imposto do ICMS ST
                    ALITMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_pICMSST%'')')));
                    //vICMSST - Valor do ICMS ST
                    VAITMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vICMSST%'')')));
                    //vICMSDeson - Valor do ICMS desonerado
                    VADEMVNO := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                                   '(CampMvIN LIKE ''%_vICMSDeson%'')'
                                                                  ,'_vICMSDeson')));
                    ALIDMVNO := 0; // % ICMS Desonerado (tela)
                    if VADEMVNO > 0 then
                      ALIDMVNO := RoundTo(DiveZero(VADEMVNO, VALOMVNO) * 100, -2);

                    //motDesICMS - Motivo da desoneração do ICMS
                    MODEMVNO := ZeroEsqu(BuscValoLike(i,'(CampMvIN LIKE ''imposto_ICMS_ICMS%'') and ' +
                                                        '(CampMvIN LIKE ''%_motDesICMS%'')'
                                                       ,'_motDesICMS'),02);
                    //infAdProd - Informações Adicionais do Produto
                    ADICMVNO := Trim(BuscValo(i,'_infAdProd'));

                    CODILOPR := CalcInte('SELECT CODILOPR ' +
                                           'FROM POCALOPR ' +
                                          'WHERE (NULO((SELECT SUM(ESTO.CALCESTO) FROM ESCAESTO ESTO WHERE ESTO.CODILOPR = POCALOPR.CODILOPR AND ESTO.CODIPROD = POCALOPR.CODIPROD)) ' +
                                                  '- ' +FormNumeSQL(QTDEMVNO) +' >= 1) ' +
                                            'AND (VALILOPR >= ' +FormDataSQL(EMISNOTA) +') ' +
                                          'ORDER BY DATALOPR ASC', vPOGeNota_D.Conn);
                    if bValiLoPr and (CODILOPR = 0) then
                      vErroLoPr := ' Parâmetro de vínculo de Lote está marcado e não foi encontrado lote disponível!';

                    if (CODIPROD > 0) and (CODISETO > 0) and (CODITPMV > 0) and (CODIUNID > 0) and (CODINATU > 0) and ((CODILOPR > 0) or not bValiLoPr) then
                      MARCMVNO := 0
                    else
                    begin
                      MARCMVNO := 1;
                      bMvNo_OK := False;
                    end;
                    CODIUSUA := 0;
                  end;
                  vPOGeNota_D.pPOCaMvNo_D.Salv_Prepara(vPOGeNota_D.MetoSave, vPOGeNota_D.UsaTrans, False, opIncl, vPOGeNota_D.Conn, nil, True);
                  vPOGeNota_D.pPOCaMvNo_D.Envi_Obj;
                end;
              end;
            end;
            // FIM Itens Nota Fiscal (POCAMVNO)

            // Tipo de Movimento e Setor (Cabeçalho)
            if CODINOTA > 0 then
            begin
              if vCodiTpMv = 0 then
                vCodiTpMv := CalcInte('SELECT MAX(CODITPMV) FROM POCAMVNO WHERE CODINOTA = ' +IntToStr(CODINOTA), vPOGeNota_D.Conn);

              if vCodiSeto = 0 then
                vCodiSeto := CalcInte('SELECT MAX(CODISETO) FROM POCAMVNO WHERE CODINOTA = ' +IntToStr(CODINOTA), vPOGeNota_D.Conn);
            end;

            ESTOTPMV := vCodiTpMv;
            ESTOSETO := vCodiSeto;

            // Se tudo esta ok
            if (CODIEMPR > 0) and (CODIPESS > 0) and (ESTOTPMV > 0) and (ESTOSETO > 0) and bMvNo_OK then
            begin
              NPRONOTA := InicValoNota_Valo('infProt_nProt');
              if Copy(NFETNOTA,1,1) <> '4' then
                NFETNOTA := CalcStri('SELECT MAX(FSCANFEE.MENSNFEE) FROM FSCANFEE WHERE FSCANFEE.NUMENFEE = ' +InicValoNota_Valo('infProt_cStat'));
            end
            else
            begin
              if not bMvNo_OK then
                vErro := 'Itens das notas não importados corretamente.' +vErroTpMv +vErroSeto +vErroLoPr
              else
                vErro := 'Nota não importada corretamente.' +vErroTpMv +vErroSeto +vErroLoPr;
            end;
          end;
          if CODINOTA > 0 then
            APATNOTA  := APATNOTA + 1;
        end;
        vPOGeNota_D.Salv_Prepara(vPOGeNota_D.MetoSave, vPOGeNota_D.UsaTrans, True, opIncl, vPOGeNota_D.Conn, nil, True);
        vPOGeNota_D.Save_Obj;
        // FIM Nota Fiscal

        if vPOGeNota_D.NewSavedPOGeNota.CODINOTA > 0 then
          Codi := vPOGeNota_D.NewSavedPOGeNota.CODINOTA
        else if vPOGeNota_D.NewPOGeNota_.CODINOTA > 0 then
          Codi := vPOGeNota_D.NewPOGeNota_.CODINOTA
        else
          Codi := 0;

        try
          SalvaInfoPaga(Codi);
        except
        end;

        // Se o CFOP gera financeiro
        if ValidaFinanceiro_Gera(Codi, vPOGeNota_D.Conn) then
        begin
          // INÍCIO Financeiro
          vPOGeFina_D.Conn    := GetPADOConn;
          vPOGeFina_D.sgForm  := nil;
          vPOGeFina_D.MetoSave:= msObj;
          vPOGeFina_D.UsaTrans:= True;
          vPOGeFina_D.LimparDts:= True;

          vPOGeFina_D.Salv_Prepara(vPOGeFina_D.MetoSave, vPOGeFina_D.UsaTrans, True, opIncl, vPOGeFina_D.Conn, nil, True);
          if (Codi > 0) and (vErro = '') then
          begin
            InseDadoTabe('POCADELE',
                        ['TABEDELE', QuotedStr('POGEFINA'),
                         'COORDELE', IntToStr(Codi),
                         'TBORDELE', QuotedStr('POCANOTA')
                        ],'');

            ExecSQL_('DELETE FROM POGEFINA WHERE CODIGENE = ' +IntToStr(Codi) +' AND TABEFINA = ''POCANOTA''', vPOGeFina_D.Conn);

            with vPOGeFina_D.NewPOGeFina_ do
            begin
              NUMEFINA := CalcInte('SELECT FUN_NUME_CALCPROX_V2(''POCAFINA'',''NUMEFINA'',0) FROM DUAL');
              CODIPESS := vPOGeNota_D.NewSavedPOGeNota.CODIPESS;
              SITUFINA := 'N';
              NOTAFINA := vPOGeNota_D.NewSavedPOGeNota.NUMENOTA;
              SERIFINA := vPOGeNota_D.NewSavedPOGeNota.SERINOTA;
              CODIGENE := vPOGeNota_D.NewSavedPOGeNota.CODINOTA;
              TABEFINA := 'POCANOTA';
              DATAFINA := vPOGeNota_D.NewSavedPOGeNota.EMISNOTA;
              DTCOFINA := vPOGeNota_D.NewSavedPOGeNota.EMISNOTA;
              CADAFINA := Date;
              DESCFINA := 'Referente NFC-e: ' +IntToStr(vPOGeNota_D.NewSavedPOGeNota.NUMENOTA) +sgLn +sgLn;

              // Condição de Pagamento e Tipo de Movimento do Financeiro
              CODICOND := vPOGeNota_D.NewSavedPOGeNota.CODICOND;
              CODITPMV := vPOGeNota_D.NewSavedPOGeNota.CODITPMV;
              if (vPOGeNota_D.NewSavedPOGeNota.CODIPESS > 0) and ((CODICOND = 0) or (CODITPMV = 0)) then
                CalcInteDoisCamp('SELECT POCaClie.CodiCond, POCaClie.CodCTpMv FROM POCaClie'
                                +' WHERE (POCaClie.CodiPess = '+IntToStr(vPOGeNota_D.NewSavedPOGeNota.CODIPESS)+')', vCodiCond, vCodCTpMv);

              if (CODICOND = 0) and (vCodiCond = 0) then
                vCodiCond := CalcInte('SELECT MAX(CodiCond) FROM POCaCond WHERE VistCond = 1');

              if (CODITPMV = 0) and (vCodCTpMv = 0) then
                vCodCTpMv := CalcInte('SELECT MAX(CodiTpMv) FROM POCaTpMv WHERE DescTpMv = ''E'' AND LocaTpMv = ''F''');

              if CODICOND = 0 then
                CODICOND := vCodiCond;

              if CODITPMV = 0 then
                CODITPMV := vCodCTpMv;

              // Troco
              Cont := CalcInte('SELECT MAX(ItemMvIN) FROM FSXXMvIN WHERE (ProtMvIN = '+QuotedStr(Prot)+') AND (CAMPMVIN = ''pag_vTroco'')');
              if Cont > 0 then
              begin
                DCTOFINA := StrToFloat(FormReal(BuscValoLike(Cont,'(CampMvIN = ''pag_vTroco'')'))); // Valor do Troco
                DESCFINA := DESCFINA +'Troco: R$ ' +FormRealBras(DCTOFINA) +sgLn;
              end;

              // Pagamentos
              vPag_Total := 0;
              Cont := CalcInte('SELECT MAX(ItemMvIN) FROM FSXXMvIN WHERE (ProtMvIN = '+QuotedStr(Prot)+') AND (CAMPMVIN = ''pag_detPag_vPag'')');
              for i := 1 to Cont do
              begin
                indPag := StrToIntDef(        BuscValoLike(i,'(CampMvIN = ''pag_detPag_indPag'')'),0);      // Forma de Pagamento
                tPag   := StrToIntDef(        BuscValoLike(i,'(CampMvIN = ''pag_detPag_tPag'')'),99);       // Meio de Pagamento
                vPag   := StrToFloat(FormReal(BuscValoLike(i,'(CampMvIN = ''pag_detPag_vPag'')')));         // Valor do Pagamento
                CNPJ   :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_CNPJ'')');      // CNPJ da instituição de pagamento
                tBand  := StrToIntDef(        BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_tBand'')'),99); // Bandeira da operadora de cartão de crédito e/ou débito
                cAut   :=                     BuscValoLike(i,'(CampMvIN = ''pag_detPag_card_cAut'')');      // Número de autorização da operação cartão de crédito e/ou débito

                Forma    := BuscaForma(indPag);
                Tipo     := BuscaTipo(tPag);
                Bandeira := BuscaBandeira(tBand);
                vPag_Total := vPag_Total + vPag;

                // Tipo de Documento e Cartão de Crédito
                vCodiTpDo := CalcInte('SELECT MAX(CODITPDO) FROM FSXXImDo WHERE tPagImDo = ' +IntToStr(tPag));
                vCodiCard := CalcInte('SELECT MAX(CODICARD) FROM POCaCard WHERE SiglCard = ' +QuotedStr(ZeroEsqu(IntToStr(tBand),2)) +SeStri(CNPJ='',' AND CNPJCard IS NULL',' AND CNPJCard = ' +QuotedStr(CNPJ)) +' AND AtivCard = 1');
                if vCodiTpDo > CODITPDO then
                  CODITPDO := vCodiTpDo;
                if vCodiCard > CODICARD then
                  CODICARD := vCodiCard;

                if (CODICARD = 0) and (tPag in [03,04]) then
                  vErro := SeStri(vErro='','',vErro +'. ') +'Não encontrado cadastro do Cartão com bandeira ' +Bandeira +SeStri(CNPJ='','',' (CNPJ '+CNPJ+')');

                // Descricao do financeiro.
                DESCFINA := DESCFINA +'// Detalhamento do pagamento ' +SeStri(i>1,IntToStr(i),'') +' => ' +sgLn
                                       +'Forma: ' +Forma +sgLn
                                       +'Meio: ' +Tipo +sgLn
                                       +'Valor: R$ ' +FormNumeSQL(vPag) +sgLn
                                       +SeStri(CNPJ='','','CNPJ: ' +CNPJ +sgLn)
                                       +SeStri(Bandeira='','','Bandeira: ' +Bandeira +sgLn)
                                       +SeStri(cAut='','','Autorização: ' +cAut +sgLn) +sgLn;
              end;
              VALOFINA := vPag_Total - DCTOFINA;
              SALDFINA := vPag_Total - DCTOFINA;

              if CODITPDO = 0 then
                vErro := SeStri(vErro='','',vErro +'. ') +'Não encontrado o Tipo de Documento parametrizado para o Meio de Pagamento informado no XML';

              try
                vPOGeFina_D.Save_Obj;
              except
                on E: Exception do
                  vErro := 'Erro ao gerar o financeiro: ' +E.Message;
              end;
            end;

            if vPOGeFina_D.NewSavedPOGeFina.CODIFINA = 0 then
              vErro := SeStri(vErro='','',vErro +'. ') +'Financeiro não gerado corretamente.';
          end;
          // FIM Financeiro
        end;

        // Cancela a nota se baixou o xml com a opção '2 - Notas Canceladas'
        if (vErro = '') and (Codi > 0) and (vPOGeNota_D.NewSavedPOGeNota.NFETNOTA = '4-CANCELADA') then
        begin
          // Cancela a nota
          AlteDadoTabe('POGENOTA',
                      ['SITUNOTA', QuotedStr('C'),
                       'NFETNOTA', QuotedStr('4-CANCELADA')
                      ],'WHERE CODINOTA = ' +IntToStr(Codi), False, vPOGeNota_D.Conn, True);

          // Cancela o financeiro
          AlteDadoTabe('POGEFINA',
                      ['SITUFINA', QuotedStr('C'),
                       'APATFINA', 'APATFINA + 1'
                      ],'WHERE CODIGENE = ' +IntToStr(Codi) +' AND TABEFINA = ''POCANOTA''', False, vPOGeFina_D.Conn, True);
        end;
      end;

      if vErro <> '' then
      begin
        bExcluir := False;
        InseDadoTabe('FSXXIMNF',
                    ['PROTIMNF',QuotedStr(Prot),
                     'CAMPIMNF',QuotedStr('SAG_ERRO'),
                     'VALOIMNF',QuotedStr(vErro)
                    ],'');
      end
      else
        bExcluir := True;

    except
      on E: Exception do
      begin
        bExcluir := False;
        InseDadoTabe('FSXXIMNF',
                    ['PROTIMNF',QuotedStr(Prot),
                     'CAMPIMNF',QuotedStr('SAG_ERRO'),
                     'VALOIMNF',QuotedStr(E.Message +sgLn +vErro)
                    ],'');
      end;
    end;
  finally
    QryImpo.Close;
    QryImpo.Free;
    QryMvIn.Free;
    QryImPr.Free;
    QryUnMe.Free;
    FreeAndNil(vPOGeNota_D);
    FreeAndNil(vPOGeFina_D);
  end;

  if bExcluir then
  begin
    ExecSQL_('DELETE FROM FSXXIMNF WHERE PROTIMNF = ' +QuotedStr(Prot)
                                  +' AND NOT EXISTS (SELECT 0 FROM FSXXImNF ImNF WHERE (ImNF.ProtImNF = FSXXIMNF.PROTIMNF) AND (ImNF.CampImNF = ''SAG_ERRO''))');
    ExecSQL_('DELETE FROM FSXXMVIN WHERE PROTMVIN = ' +QuotedStr(Prot)
                                  +' AND NOT EXISTS (SELECT 0 FROM FSXXImNF ImNF WHERE (ImNF.ProtImNF = FSXXMVIN.PROTMVIN) AND (ImNF.CampImNF = ''SAG_ERRO''))');

    if bEvento then
    begin
      ExecSQL_('DELETE FROM FSXXIMNF WHERE PROTIMNF = ' +QuotedStr('NFe'+vChave)
                                  +' AND NOT EXISTS (SELECT 0 FROM FSXXImNF ImNF WHERE (ImNF.ProtImNF = FSXXIMNF.PROTIMNF) AND (ImNF.CampImNF = ''SAG_ERRO''))');
      ExecSQL_('DELETE FROM FSXXMVIN WHERE PROTMVIN = ' +QuotedStr('NFe'+vChave)
                                    +' AND NOT EXISTS (SELECT 0 FROM FSXXImNF ImNF WHERE (ImNF.ProtImNF = FSXXMVIN.PROTMVIN) AND (ImNF.CampImNF = ''SAG_ERRO''))');

    end;
  end;
end;

function FSXXImNF_BuscarNotas(Linh: String): Boolean;
var
  Arquivo, Pasta, Prot: String;
  ListaAuto, ListaCanc: TStringList;
  i, Log: Integer;
begin
  if (Linh <> '') and DirectoryExists(IncludeTrailingPathDelimiter(Linh)) then
  begin
    //ContErro := 0;
    Log := sgLog.Tipo;
    Linh := IncludeTrailingPathDelimiter(Linh);
    ListaAuto := TStringList.Create;
    ListaCanc := TStringList.Create;
    try
      ExibMensHint('Buscando Notas do Diretório: ' +Linh);
      for Arquivo in TDirectory.GetFiles(Linh, '*.xml') do
      begin
        if (Pos('canc', Arquivo) = 0) then
          ListaAuto.Add(Arquivo) // Notas Autorizadas
        else
          ListaCanc.Add(Arquivo); // Notas Canceladas
      end;
      ExibMensHint('Encontrado: ' +IntToStr(ListaAuto.Count) +' notas autorizadas e ' +IntToStr(ListaCanc.Count) +' notas canceladas.');

      // Processa as notas autorizadas primeiro
      if ListaAuto.Count > 0 then
      begin
        ExibMensHint('Processando ' +IntToStr(ListaAuto.Count) +' notas autorizadas. ');
        for i := 0 to ListaAuto.Count - 1 do
        begin
          Pasta := IncludeTrailingPathDelimiter(ExtractFilePath(ListaAuto[i]));
          Arquivo := ExtractFileName(ListaAuto[i]);
          if FileExists(Pasta +'Processado\' +Arquivo) then
            DeleteFile(ListaAuto[i])
          else
          begin
            if Log > 0 then sgLog.Tipo := 0;
            Prot := NFe_XML_ImpoXML_V20(ListaAuto[i], False, '', 'FSXXIMNF', 'FSXXMVIN');
            if Log > 0 then sgLog.Tipo := Log;

            if AnsiUpperCase(Prot) = AnsiUpperCase('Erro') then
            begin
              //Inc(ContErro);
            //  NomeArqu := Linh +ListaAuto[i];
            end
            else
              FSXXImNF_ProcessarNotas(Prot, SubsPalaTudo(Arquivo,'.xml',''));
          end;
        end;
      end;
      // Processa as nota canceladas
      if ListaCanc.Count > 0 then
      begin
        ExibMensHint('Processando ' +IntToStr(ListaCanc.Count) +' notas canceladas. ');
        for i := 0 to ListaCanc.Count - 1 do
        begin
          Pasta := IncludeTrailingPathDelimiter(ExtractFilePath(ListaCanc[i]));
          Arquivo := ExtractFileName(ListaCanc[i]);
          if FileExists(Pasta +'Processado\' +Arquivo) then
            DeleteFile(ListaCanc[i])
          else
          begin
            if Log > 0 then sgLog.Tipo := 0;
            Prot := NFe_XML_ImpoXML_V20(ListaCanc[i], False, '', 'FSXXIMNF', 'FSXXMVIN');
            if Log > 0 then sgLog.Tipo := Log;

            if AnsiUpperCase(Prot) = AnsiUpperCase('Erro') then
            begin
              //Inc(ContErro);
            //  NomeArqu := Linh +ListaCanc[i];
            end
            else
              FSXXImNF_ProcessarNotas(Prot, SubsPalaTudo(Arquivo,'.xml',''));
          end;
        end;
      end;
    finally
      Result := True;
      FreeAndNil(ListaAuto);
      FreeAndNil(ListaCanc);
    end;
  end
  else
    Result := False;
end;

end.
