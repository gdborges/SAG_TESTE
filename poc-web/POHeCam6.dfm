inherited FrmPOHeCam6: TFrmPOHeCam6
  Caption = 'Campos'
  ClientHeight = 1329
  ClientWidth = 1896
  Position = poOwnerFormCenter
  ExplicitWidth = 1912
  ExplicitHeight = 1368
  TextHeight = 15
  inherited MemGene: TMemLbl
    Lines.Strings = (
      'Tabela de Grava'#231#227'o'
      'Tabela Mov1'
      'Tabela Mov2'
      'Tabela Mov3')
  end
  inherited PnlGene: TsgPnl
    Left = 37
    Width = 1859
    Height = 1329
    AutoScroll = False
    ExplicitLeft = 37
    ExplicitWidth = 1859
    ExplicitHeight = 1329
    inherited PgcGene: TsgPgc
      Width = 1859
      Height = 1329
      TabBarVisible = True
      ExplicitWidth = 1859
      ExplicitHeight = 1329
      inherited Tbs1: TsgTbs
        ExplicitWidth = 1851
        ExplicitHeight = 1299
        object PnlDado: TsgPnl
          Left = 0
          Top = 1265
          Width = 1851
          Height = 34
          Align = alClient
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 1
          Visible = False
          AutoScroll = True
          ScrollHeight = 29
          ScrollWidth = 1851
        end
        object Pnl1: TsgPnl
          Left = 0
          Top = 0
          Width = 1851
          Height = 1265
          Align = alTop
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 0
          AutoScroll = True
          ScrollHeight = 1265
          ScrollWidth = 1851
        end
      end
    end
  end
  inherited PnlConf: TsgPnl
    Width = 37
    Height = 1329
    ExplicitWidth = 37
    ExplicitHeight = 1329
    object EdtSeriRece: TEdtLbl [0]
      Left = 2
      Top = 259
      AutoSize = False
      ParentFont = False
      TabOrder = 5
      Visible = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8416096
      Font.Height = -11
      Font.Name = 'Roboto'
      Font.Style = []
      PasswordChar = #0
      Alignment = taLeftJustify
      sgConf.Visible = False
      Height = 21
      Width = 20
    end
    object EdtSeriEnvi: TEdtLbl [1]
      Left = 2
      Top = 281
      AutoSize = False
      ParentFont = False
      TabOrder = 4
      Visible = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8416096
      Font.Height = -11
      Font.Name = 'Roboto'
      Font.Style = []
      PasswordChar = #0
      Alignment = taLeftJustify
      sgConf.Visible = False
      Height = 21
      Width = 20
    end
    inherited BtnConf: TsgBtn
      Left = 1
      Top = 1
      Width = 33
      Height = 28
      Enabled = True
      DoubleBuffered = True
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 33
      ExplicitHeight = 28
    end
    inherited BtnCanc: TsgBtn
      Left = 1
      Top = 29
      Width = 33
      Height = 28
      DoubleBuffered = True
      ExplicitLeft = 1
      ExplicitTop = 29
      ExplicitWidth = 33
      ExplicitHeight = 28
    end
    inherited BtnFech: TsgBtn
      Left = 1
      Top = 57
      Width = 33
      Height = 28
      DoubleBuffered = True
      ExplicitLeft = 1
      ExplicitTop = 57
      ExplicitWidth = 33
      ExplicitHeight = 28
    end
    inherited BtnSupo_InfoTela: TsgBtn
      DoubleBuffered = True
    end
  end
  inherited PopRede: TsgPop
    Left = 637
    Top = 111
    inherited PopCopiGene: TsgMenuItem
      Visible = True
    end
  end
  inherited DtsGrav: TDataSource
    DataSet = nil
    Left = 591
    Top = 108
  end
  inherited QrySQL: TsgQuery
    Left = 636
    Top = 152
  end
  inherited QryTela: TsgQuery
    Left = 591
    Top = 152
  end
  object QryTabeConf: TsgQuery
    Tag = 15
    BeforeOpen = QryTabeConfBeforeOpen
    ResourceOptions.AssignedValues = [rvMacroExpand]
    ResourceOptions.MacroExpand = False
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    SQL.Strings = (
      
        'SELECT LancTabe, AposTabe, SeriTabe, InSeTabe, ShowTabe, Gui1Tab' +
        'e, Gui2Tabe, GravTabe, TamaTabe, AltuTabe, GridTabe, ClicTabe, E' +
        'PerTabe, EGraTabe, TpGrTabe'
      'FROM POCaTabe'
      'WHERE (CodiTabe = :Tabe)')
    TamaCamp = 30
    Left = 551
    Top = 251
    ParamData = <
      item
        Name = 'Tabe'
        DataType = ftInteger
        Value = Null
      end>
  end
  object DtsTabeConf: TDataSource
    DataSet = QryTabeConf
    Left = 631
    Top = 251
  end
  object MaiEnvi: TEnviMail
    Left = 642
    Top = 307
  end
end
