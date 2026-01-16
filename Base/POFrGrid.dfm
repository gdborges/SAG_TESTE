object FraGrid: TFraGrid
  Left = 0
  Top = 0
  Width = 435
  Height = 266
  TabOrder = 0
  object PnlGrid: TsgPnl
    Left = 0
    Top = 19
    Width = 435
    Height = 247
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    ScrollHeight = 0
    ScrollWidth = 0
    object DbgGrid: TsgDBG
      Left = 0
      Top = 0
      Width = 435
      Height = 247
      Texto = ''
      Numero = 0.000000000000000000
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      PopupMenu = PopGrid
      TabOrder = 0
      TabStop = False
      Coluna.Strings = (
        '[Colunas]')
      sgLevel = DbgGridLeve
      sgView = DbgGridView
      DataSource = DtsGrid
      ReadOnly = False
      ShowHint = False
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgTabs]
      Columns = <>
      ColorLow = 14936544
      ColorHigh = 15790322
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      object DbgGridView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsGrid
        DataController.Filter.Active = True
        DataController.Filter.AutoDataSetFilter = True
        DataController.Filter.TranslateBetween = True
        DataController.Filter.TranslateIn = True
        DataController.Filter.TranslateLike = True
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        DateTimeHandling.Filters = [dtfRelativeDays, dtfRelativeDayPeriods, dtfRelativeWeeks, dtfRelativeMonths, dtfRelativeYears, dtfPastFuture, dtfMonths, dtfYears]
        Filtering.ColumnFilteredItemsList = True
        FilterRow.SeparatorWidth = 8
        FilterRow.ApplyChanges = fracImmediately
        FixedDataRows.SeparatorWidth = 8
        NewItemRow.SeparatorWidth = 8
        OptionsBehavior.CellHints = True
        OptionsBehavior.CopyCaptionsToClipboard = False
        OptionsBehavior.IncSearch = True
        OptionsBehavior.ImmediateEditor = False
        OptionsBehavior.PullFocusing = True
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Appending = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsSelection.CellMultiSelect = True
        OptionsView.CellEndEllipsis = True
        OptionsView.NavigatorOffset = 63
        OptionsView.ExpandButtonsForEmptyDetails = False
        OptionsView.FixedColumnSeparatorWidth = 3
        OptionsView.FooterAutoHeight = True
        OptionsView.FooterMultiSummaries = True
        OptionsView.GridLines = glVertical
        OptionsView.GroupFooterMultiSummaries = True
        OptionsView.GroupFooters = gfVisibleWhenExpanded
        OptionsView.GroupSummaryLayout = gslAlignWithColumns
        OptionsView.Indicator = True
        Preview.LeftIndent = 25
        Preview.RightIndent = 6
        Preview.Visible = True
        RowLayout.MinValueWidth = 100
      end
      object DbgGridLeve: TcxGridLevel
        GridView = DbgGridView
      end
    end
  end
  object PnlTopo: TsgPnl
    Left = 0
    Top = 0
    Width = 435
    Height = 19
    Align = alTop
    BevelInner = bvLowered
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ScrollHeight = 0
    ScrollWidth = 0
    object LblTemp: TsgLbl
      Left = 9
      Top = 4
      Hint = 'Tempo de Abertura da Tabela'
      BiDiMode = bdLeftToRight
      Enabled = True
      TabOrder = 0
      sgConf.BiDiMode = bdLeftToRight
      sgConf.Color = clWindow
      sgConf.Font.Charset = DEFAULT_CHARSET
      sgConf.Font.Color = clWindowText
      sgConf.Font.Height = -12
      sgConf.Font.Name = 'Segoe UI'
      sgConf.Font.Style = []
      sgCaption = '           '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
    end
    object LblRegi: TsgLbl
      Left = 110
      Top = 4
      Hint = 'N'#250'mero de Registros'
      BiDiMode = bdLeftToRight
      Enabled = True
      TabOrder = 1
      sgConf.BiDiMode = bdLeftToRight
      sgConf.Color = clWindow
      sgConf.Font.Charset = DEFAULT_CHARSET
      sgConf.Font.Color = clWindowText
      sgConf.Font.Height = -12
      sgConf.Font.Name = 'Segoe UI'
      sgConf.Font.Style = []
      sgCaption = '           '
      Alignment = taRightJustify
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      AnchorX = 147
    end
  end
  object DtsGrid: TDataSource
    DataSet = QryGrid
    Left = 78
    Top = 41
  end
  object QryGrid: TsgQuery
    AutoCalcFields = False
    BeforeOpen = QryGridBeforeOpen
    AfterOpen = QryGridAfterOpen
    AfterScroll = QryGridAfterScroll
    Connection = DtmPoul.DtbGene
    ResourceOptions.AssignedValues = [rvMacroExpand]
    ResourceOptions.MacroExpand = False
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    TamaCamp = 30
    Left = 24
    Top = 41
  end
  object PopGrid: TsgPop
    Left = 133
    Top = 41
    object PopGridAjud: TsgMenuItem
      Caption = 'Ajuda'
      Visible = False
      OnClick = PopGridAjudClick
      CodiTabe = 0
    end
    object PopGridAjudSepa: TsgMenuItem
      Caption = '-'
      Visible = False
      CodiTabe = 0
    end
    object PopExpoExce: TsgMenuItem
      Caption = 'Exporta Excel'
      Hint = 'Exporta Excel'
      OnClick = PopExpoExceClick
      CodiTabe = 0
    end
    object PopExpoInse: TsgMenuItem
      Caption = 'Exporta INSERT INTO'
      Hint = 'Exporta INSERT INTO'
      OnClick = PopExpoInseClick
      CodiTabe = 0
    end
    object PopExpoUpda: TsgMenuItem
      Tag = 1
      Caption = 'Exporta UPDATE'
      Hint = 'Exporta UPDATE'
      OnClick = PopExpoInseClick
      CodiTabe = 0
    end
    object N8: TsgMenuItem
      Caption = '-'
      CodiTabe = 0
    end
    object PopFiltQuer: TsgMenuItem
      Caption = 'Filtro na Query'
      Hint = 'Filtro na Query'
      OnClick = PopFiltQuerClick
      CodiTabe = 0
    end
    object N5: TsgMenuItem
      Caption = '-'
      CodiTabe = 0
    end
    object PopExpoXML: TsgMenuItem
      Caption = 'Exporta XML/ADT'
      Hint = 'Exporta XML/ADT'
      OnClick = PopExpoXMLClick
      CodiTabe = 0
    end
    object PopImpoXML: TsgMenuItem
      Caption = 'Importa XML/ADT'
      Hint = 'Importa XML/ADT'
      OnClick = PopImpoXMLClick
      CodiTabe = 0
    end
  end
end
