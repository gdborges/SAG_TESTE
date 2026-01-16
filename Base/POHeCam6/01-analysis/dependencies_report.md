# Análise de Dependências - SAG

**Diretório analisado:** `C:\Trabalho\Edata\GIT\MIMS_V7\SAG`

## 📊 Estatísticas

- **Total de units:** 2
- **Total de dependências:** 265
- **Média de dependências por unit:** 132.5
- **Units sem dependências:** 0

### Dependencies by Relevance

**Units:**
- Business Logic Units: 0
- Infrastructure Units: 2

**Interface Dependencies (Architecture):**
- Business: 0
- Infrastructure: 113
- **Relevance for AS-IS:** Low (architectural decisions)

**Implementation Dependencies (Business Logic):**
- **Business: 1** <- **FOCUS FOR AS-IS**
- Infrastructure: 154
- **Relevance for AS-IS:** High (business rules)

---

### Recommendation

**For AS-IS Documentation, prioritize:**
1. Implementation dependencies marked as Business (1 units)
2. Methods from business units: DataModuPesaProd, DesbRegiPend, etc.
3. Omit interface dependencies (architecture, not business rules)

**Business Units Identified:**


---

## 🔝 Units Mais Usadas (Top 10)

*Units que aparecem como dependência de muitas outras*

| # | Unit | Vezes Usada |
|---|------|-------------|
| 1 | `MemLbl` | 2 |
| 2 | `DB` | 2 |
| 3 | `sgQuery` | 2 |
| 4 | `Funcoes` | 2 |
| 5 | `DmPlus` | 2 |
| 6 | `sgTypes` | 2 |
| 7 | `uniPanel` | 2 |
| 8 | `uniGUIApplication` | 2 |
| 9 | `Forms` | 2 |
| 10 | `sgPnl` | 2 |

## 📦 Units com Mais Dependências (Top 10)

*Units que dependem de muitas outras*

| # | Unit | Num Dependências |
|---|------|------------------|
| 1 | `PlusUni` | 173 |
| 2 | `POHeCam6` | 92 |

## 🗂️ Detalhamento de Dependências

### POHeCam6

**Arquivo:** `POHeCam6.pas`

**Debug Info:**
- Interface section: line 4
- Implementation section: line 96

**Interface uses:**
- ADODB
- Async
- Classes
- Client
- Collections
- ComCtrls
- Controls
- DApt
- DB
- DatS
- DataSet
- Def
- Dialogs
- EdtExtControls
- EdtLbl
- EnviMail
- Error
- ExtCtrls
- Forms
- Func
- Graphics
- Intf
- Intf
- Intf
- Intf
- Mask
- MaskEdEx
- MemLbl
- Menus
- Messages
- Option
- POFrCaMv
- POFrGrMv
- POFrGrid
- POHeForm
- POHeFormModal
- POHeGera
- POHeGeraModal
- Param
- Phys
- PlusUni
- Pool
- StdCtrls
- SysUtils
- Variants
- Wait
- Windows
- cxButtons
- cxContainer
- cxControls
- cxEdit
- cxLookAndFeelPainters
- cxLookAndFeels
- cxMaskEdit
- cxTextEdit
- dxUIAClasses
- sgBtn
- sgBvl
- sgClass
- sgClientDataSet
- sgDBG
- sgDBG2
- sgFormModal
- sgFrame
- sgLeitSeri
- sgPgc
- sgPnl
- sgPop
- sgQuery
- sgScrollBox
- sgTbs
- sgTypes
- uniButton
- uniEdit
- uniGUIBaseClasses
- uniGUIClasses
- uniGUIFrame
- uniGroupBox
- uniMemo
- uniPageControl
- uniPanel

**Implementation uses:**
- DBClient
- DBEdtLbl
- DBLcbLbl
- DmCall
- DmPlus
- DmPoul
- Funcoes
- LcbLbl
- Log
- PlusUnig
- RxEdtLbl
- sgConsts
- sgPrinDecorator
- uniGUIApplication

**Total:** 92 dependências

---

### PlusUni

**Arquivo:** `PlusUni.pas`

**Debug Info:**
- Interface section: line 8
- Implementation section: line 460

**Interface uses:**
- ACBrBAL
- ADODB
- CPort
- Classes
- ComCtrls
- Controls
- DB
- DBImgLbl
- Dialogs
- Forms
- Func
- Graphics
- LcbLbl
- LstLbl
- Messages
- Option
- POChRela_D
- POFrCaMv
- POFrGrMv
- POFrSeri_D
- POGeAgCa
- Param
- UniGuiForm
- Windows
- idTelNet
- sgClientDataSet
- sgCompUnig
- sgForm
- sgPnl
- sgQuery
- sgTbs
- sgTypes

**Implementation uses:**
- ACBrDevice
- ACBrETQ
- ACBrETQClass
- ACBrValidador
- ActiveX
- AdvMemLbl
- BancFunc
- BancView
- CLPlus
- COPlus
- CampJSon
- ChkLbl
- CmbLbl
- DBAdvMemLbl
- DBChkLbl
- DBClient
- DBCmbLbl
- DBCtrls
- DBEdtLbl
- DBFilLbl
- DBIniMemo
- DBLcbLbl
- DBLookNume
- DBLookText
- DBRchLbl
- DBRxDLbl
- DBRxELbl
- DateUtils
- DbMemLbl
- DirLbl
- DmEsti
- DmImag
- DmPlus
- DmPoul
- EdtLbl
- EnviMail
- ExtCtrls
- FiPlus
- FilLbl
- FuncPlus
- Funcoes
- INPlus
- IOUtils
- ImgLbl
- Log
- MPPlus
- Mask
- MaskUtils
- Math
- MemLbl
- Menus
- POCaMvC2
- POCaMvCx
- POCaMvND
- POChGrid
- POChSenh
- POChWebB
- POFrGraf
- POGeAgua
- POGeConf
- POGeCons
- POGeFina_D
- POGeNota_D
- POHeGer6
- PlusERP
- PlusUni
- PlusUniModal
- Proc
- QRCtrls
- QuickRpt
- RAPlus
- RchLbl
- RelaPlus
- RxDatLbl
- RxEdtLbl
- RxPlacemnt
- SCPlus
- StdCtrls
- StrUtils
- SysUtils
- TFlatCheckBoxUnit
- TFlatComboBoxUnit
- TFlatGaugeUnit
- TFlatGroupBoxUnit
- TFlatRadioButtonUnit
- TePlus
- Threading
- Trad
- TradConsts
- TradNamed
- Trig
- Types
- UITypes
- UniComboBox
- UniDBComboBox
- UniDBRadioGroup
- UniGroupBox
- UniPageControl
- UniRadioButton
- UniRadioGroup
- Variants
- WSPlus
- XMLDoc
- XMLIntf
- XSBuiltIns
- Zip
- cxGridCustomTableView
- cxGridCustomView
- cxGridDBTableView
- cxGridTableView
- cxListView
- cxLookAndFeels
- sgArquivo
- sgBtn
- sgBvl
- sgConsts
- sgConstsMsg
- sgDBG
- sgDBRgb
- sgFormStorage
- sgGroupBox
- sgLbl
- sgPgc
- sgPop
- sgPrinDecorator
- sgProgBar
- sgRTTI
- sgRadioButton
- sgRgb
- sgStyles
- sgTim
- sgTreeList
- sgUtil
- shellapi
- uLkJSON
- uniDBLookupHelper
- uniGUIApplication
- uniGuiFont
- uniLabel
- uniMainMenu
- uniPanel

**Total:** 173 dependências

---

