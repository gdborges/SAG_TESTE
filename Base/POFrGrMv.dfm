inherited FraGrMv: TFraGrMv
  inherited PnlGrid: TsgPnl
    Top = 42
    Height = 224
    ExplicitTop = 42
    ExplicitHeight = 224
    inherited DbgGrid: TsgDBG
      Height = 224
      ExplicitHeight = 224
      inherited DbgGridView: TcxGridDBTableView
        OnDblClick = DbgGridDblClick
      end
    end
  end
  inherited PnlTopo: TsgPnl
    Height = 42
    ExplicitHeight = 42
    inherited LblTemp: TsgLbl
      Left = 417
      Top = 17
      TabOrder = 3
      Visible = False
      ExplicitLeft = 417
      ExplicitTop = 17
    end
    inherited LblRegi: TsgLbl
      Top = 17
      TabOrder = 4
      Visible = False
      ExplicitTop = 17
      AnchorX = 147
    end
    object BtnNovo: TsgBtn
      Left = 5
      Top = 5
      Width = 129
      Height = 33
      IconCls = 'BtnNovo'
      Images = DtmImag.LstImagGene
      ImageIndex = 40
      BiDiMode = bdLeftToRight
      Caption = '&Novo'
      ParentBiDiMode = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TabStop = False
      OnClick = BtnNovoClick
      ColorBorder = clBlack
      sgImages = DtmImag.LstImagGene
      sgImageIndex = 40
      sgIconCls = 'BtnNovo'
      DoubleBuffered = True
      ParentDoubleBuffered = False
    end
    object BtnAlte: TsgBtn
      Tag = 1
      Left = 137
      Top = 5
      Width = 129
      Height = 33
      IconCls = 'BtnAlte'
      Images = DtmImag.LstImagGene
      ImageIndex = 41
      BiDiMode = bdLeftToRight
      Caption = '&Altera'
      Enabled = False
      ParentBiDiMode = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      TabStop = False
      OnClick = BtnNovoClick
      ColorBorder = clBlack
      sgImages = DtmImag.LstImagGene
      sgImageIndex = 41
      sgIconCls = 'BtnAlte'
      DoubleBuffered = True
      ParentDoubleBuffered = False
    end
    object BtnExcl: TsgBtn
      Left = 269
      Top = 5
      Width = 129
      Height = 33
      IconCls = 'BtnExcl'
      Images = DtmImag.LstImagGene
      ImageIndex = 42
      BiDiMode = bdLeftToRight
      Caption = '&Exclui'
      Enabled = False
      ParentBiDiMode = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      TabStop = False
      OnClick = BtnExclClick
      ColorBorder = clBlack
      sgImages = DtmImag.LstImagGene
      sgImageIndex = 42
      sgIconCls = 'BtnExcl'
      DoubleBuffered = True
      ParentDoubleBuffered = False
    end
  end
  inherited DtsGrid: TDataSource
    Left = 551
  end
  inherited QryGrid: TsgQuery
    Tag = 10
    Left = 501
  end
end
