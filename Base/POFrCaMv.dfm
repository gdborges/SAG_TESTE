object FraCaMv: TFraCaMv
  Left = 0
  Top = 0
  Width = 676
  Height = 340
  Align = alClient
  TabOrder = 0
  object PnlMovi: TsgPnl
    Left = 0
    Top = 0
    Width = 676
    Height = 340
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    ScrollHeight = 0
    ScrollWidth = 0
    inline FraMovi: TFraGrMv
      Left = 0
      Top = 0
      Width = 676
      Height = 307
      Background.Picture.Data = {00}
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      ExplicitWidth = 676
      ExplicitHeight = 307
      inherited PnlGrid: TsgPnl
        AlignWithMargins = True
        Left = 10
        Top = 70
        Width = 656
        Height = 227
        Margins.Left = 10
        Margins.Top = 0
        Margins.Right = 10
        Margins.Bottom = 10
        ExplicitLeft = 10
        ExplicitTop = 70
        ExplicitWidth = 431
        ExplicitHeight = 192
        inherited DbgGrid: TsgDBG
          Width = 656
          Height = 227
          ShowHint = True
          OnDblClick = FraMoviDbgGridDblClick
          ExplicitWidth = 431
          ExplicitHeight = 192
          inherited DbgGridView: TcxGridDBTableView
            OnDblClick = FraMoviDbgGridDblClick
          end
        end
      end
      inherited PnlTopo: TsgPnl
        AlignWithMargins = True
        Left = 10
        Top = 10
        Width = 656
        Height = 50
        Margins.Left = 10
        Margins.Top = 10
        Margins.Right = 10
        Margins.Bottom = 10
        ScrollHeight = 50
        ScrollWidth = 485
        ExplicitLeft = 10
        ExplicitTop = 10
        ExplicitWidth = 656
        ExplicitHeight = 50
        inherited LblTemp: TsgLbl
          ExplicitHeight = 17
        end
        inherited LblRegi: TsgLbl
          ExplicitHeight = 17
          AnchorX = 147
        end
        inherited BtnNovo: TsgBtn
          Left = 15
          Top = 10
          Width = 150
          TabStop = True
          OnClick = BtnNovoClick
          DoubleBuffered = True
          ExplicitLeft = 15
          ExplicitTop = 10
          ExplicitWidth = 150
        end
        inherited BtnAlte: TsgBtn
          Left = 175
          Top = 10
          Width = 150
          TabStop = True
          OnClick = BtnNovoClick
          DoubleBuffered = True
          ExplicitLeft = 175
          ExplicitTop = 10
          ExplicitWidth = 150
        end
        inherited BtnExcl: TsgBtn
          Left = 335
          Top = 10
          Width = 150
          TabStop = True
          OnClick = FraMoviBtnExclClick
          DoubleBuffered = True
          ExplicitLeft = 335
          ExplicitTop = 10
          ExplicitWidth = 150
        end
      end
      inherited DtsGrid: TDataSource
        Left = 71
        Top = 89
      end
      inherited QryGrid: TsgQuery
        ExibChav = False
        Left = 23
        Top = 89
      end
      inherited PopGrid: TsgPop
        Left = 120
        Top = 89
      end
    end
    object PnlResu: TsgPnl
      Left = 0
      Top = 307
      Width = 676
      Height = 33
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Visible = False
      AutoScroll = True
      ScrollHeight = 33
      ScrollWidth = 451
      ExplicitTop = 272
      ExplicitWidth = 451
    end
  end
end
