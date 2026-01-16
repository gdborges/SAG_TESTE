# Method Calls Analysis Report - POHeCam6

**Analysis Date:** 2025-12-23 12:35:27
**Analysis Mode:** FOCUSED
**Recursive Analysis:** Yes
**Max Depth:** 10
**Filtering:** Enabled

---

## 📊 Statistics

### General Metrics

| Metric | Value |
|--------|-------|
| Total Methods Analyzed | 20 |
| Total Method Calls | 292 |
| External Calls | 46 |
| Local Calls | 246 |
| Event Handlers | 1 |
| Units Analyzed | 2 |
| Max Depth Reached | 5 |
| Total Call Chains | 9 |
| Circular Dependencies | 1 |


### Methods by Relevance (for AS-IS Documentation)

| Category | Count | % | Description |
|----------|-------|---|-------------|
| 🔴 **Critical** | 20 | 100.0% | MUST be detailed in AS-IS Section 9.1 |
| 🟡 **Relevant** | 0 | 0.0% | Should be mentioned in AS-IS Section 9.2 |
| ⚪ **Omitted** | 0 | 0.0% | Infrastructure - not in AS-IS |

**Methods in AS-IS:** 20 (100.0%)
**Reduction:** 0.0% infrastructure omitted

### Methods by Type

| Type | Count | Description |
|------|-------|-------------|
| 💾 SQL | 1 | Database access (always critical) |
| ✅ Validation | 0 | Business rule validation |
| 🔧 Business | 0 | Core business logic |
| ⚙️ Infrastructure | 19 | UI/Framework (omitted) |

### Units by Type

| Type | Count |
|------|-------|
| 🔧 Business | 0 |
| ⚙️ Infrastructure | 1 |


---


## Call Graph Overview

### Top External Units Called

| Unit | Call Count |
|------|------------|
| DataSet | 14 |
| cds | 8 |
| DtmPoul | 4 |
| Func | 3 |
| New | 2 |
| Old | 2 |
| TsgLeitSeri | 2 |
| ListLeitSeri | 2 |
| ListPrin | 1 |
| Pai_Tabe | 1 |

---

## 📞 Method Call Details

### Unit: POHeCam6

#### function GetPgcMovi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:112

**Calls Made:**

- `POHeCam6.Assigned` (line 114) - Local
- `TsgPgc.Create` (line 116) - External

#### function CriaTbs

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:125

**Calls Made:**

- `TsgTbs.Create` (line 127) - External

#### function BuscaComponente

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:138

**Calls Made:**

- `POHeCam6.AnsiUpperCase` (line 143) - Local
- `POHeCam6.Assigned` (line 148) - Local
- `POHeCam6.and` (line 148) - Local
- `POHeCam6.Assigned` (line 160) - Local
- `POHeCam6.and` (line 160) - Local
- `POHeCam6.StrIn` (line 168) - Local
- `POHeCam6.Copy` (line 168) - Local
- `POHeCam6.StrIn` (line 172) - Local
- `POHeCam6.IntToStr` (line 172) - Local
- `POHeCam6.IntToStr` (line 172) - Local
- `POHeCam6.IntToStr` (line 172) - Local
- `POHeCam6.IntToStr` (line 172) - Local
- `POHeCam6.IntToStr` (line 172) - Local
- `POHeCam6.StrIn` (line 177) - Local
- `POHeCam6.IntToStr` (line 177) - Local
- `POHeCam6.IntToStr` (line 177) - Local
- `POHeCam6.IntToStr` (line 177) - Local
- `POHeCam6.IntToStr` (line 177) - Local
- `POHeCam6.IntToStr` (line 177) - Local
- `POHeCam6.IntToStr` (line 179) - Local
- `POHeCam6.StrIn` (line 182) - Local
- `POHeCam6.IntToStr` (line 182) - Local
- `POHeCam6.IntToStr` (line 182) - Local
- `POHeCam6.IntToStr` (line 182) - Local
- `POHeCam6.IntToStr` (line 182) - Local
- `POHeCam6.IntToStr` (line 182) - Local
- `POHeCam6.IntToStr` (line 184) - Local
- `POHeCam6.StrIn` (line 186) - Local
- `POHeCam6.IntToStr` (line 186) - Local
- `POHeCam6.IntToStr` (line 186) - Local
- `POHeCam6.IntToStr` (line 186) - Local
- `POHeCam6.IntToStr` (line 186) - Local
- `POHeCam6.IntToStr` (line 186) - Local
- `POHeCam6.StrIn` (line 191) - Local
- `POHeCam6.IntToStr` (line 191) - Local
- `POHeCam6.IntToStr` (line 191) - Local
- `POHeCam6.IntToStr` (line 191) - Local
- `POHeCam6.IntToStr` (line 192) - Local
- `POHeCam6.IntToStr` (line 193) - Local
- `POHeCam6.IntToStr` (line 193) - Local
- `POHeCam6.IntToStr` (line 193) - Local
- `POHeCam6.IntToStr` (line 194) - Local
- `POHeCam6.StrIn` (line 199) - Local
- `POHeCam6.IntToStr` (line 199) - Local
- `POHeCam6.IntToStr` (line 199) - Local
- `POHeCam6.IntToStr` (line 199) - Local
- `POHeCam6.IntToStr` (line 199) - Local
- `POHeCam6.StrIn` (line 204) - Local
- `POHeCam6.IntToStr` (line 204) - Local
- `POHeCam6.IntToStr` (line 204) - Local
- `POHeCam6.IntToStr` (line 204) - Local
- `POHeCam6.IntToStr` (line 204) - Local
- `POHeCam6.StrIn` (line 209) - Local
- `POHeCam6.IntToStr` (line 209) - Local
- `POHeCam6.IntToStr` (line 209) - Local
- `POHeCam6.Assigned` (line 222) - Local
- `POHeCam6.BuscaComponente` (line 223) - Local

#### procedure MudaTab2

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:227

**Calls Made:**

- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234) - Local
- `POHeCam6.AnsiUpperCase` (line 238) - Local
- `POHeCam6.AnsiUpperCase` (line 238) - Local
- `POHeCam6.TsgTbs` (line 239) - Local
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 241) - Local
- `POHeCam6.TWinControl` (line 241) - Local
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 254) - Local
- `POHeCam6.and` (line 255) - Local
- `POHeCam6.not` (line 255) - Local
- `POHeCam6.UltiConf` (line 258) - Local
- `POHeCam6.UltiConf` (line 271) - Local
- `POHeCam6.Perform` (line 276) - Local

#### function MudaTabe2_BuscTbs_Index

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:234

**Calls Made:**

- `POHeCam6.AnsiUpperCase` (line 238) - Local
- `POHeCam6.AnsiUpperCase` (line 238) - Local
- `POHeCam6.TsgTbs` (line 239) - Local
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 241) - Local
- `POHeCam6.TWinControl` (line 241) - Local

#### procedure QryTabeConfBeforeOpen

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:285

**Calls Made:**

- `POHeCam6.isMobi_POCaCamp_Sele` (line 288) - Local

#### procedure ConfPortSeri

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:292

**Calls Made:**

- `POHeCam6.Pos` (line 307) - Local
- `TsgLeitSeri.Create_Owner` (line 309) - External
- `ListLeitSeri.Add` (line 316) - External
- `DtmPoul.Campos_Cds` (line 323) - External
- `Func.PegaMaqu` (line 326) - External
- `POHeCam6.ExibMensHint` (line 327) - Local
- `cds.FieldByName` (line 330) - External
- `POHeCam6.or` (line 330) - Local
- `POHeCam6.sgPos` (line 330) - Local
- `cds.FieldByName` (line 330) - External
- `cds.FieldByName` (line 332) - External
- `POHeCam6.Pos` (line 333) - Local
- `TsgLeitSeri.Create_Owner` (line 335) - External
- `cds.FieldByName` (line 340) - External
- `POHeCam6.TEdtLbl` (line 343) - Local
- `POHeCam6.BuscaComponente` (line 343) - Local
- `cds.FieldByName` (line 343) - External
- `POHeCam6.Assigned` (line 344) - Local
- `TEdtLbl.Create` (line 346) - External
- `cds.FieldByName` (line 347) - External
- `cds.FieldByName` (line 351) - External
- `cds.FieldByName` (line 352) - External
- `ListLeitSeri.Add` (line 355) - External
- `POHeCam6.FreeAndNil` (line 361) - Local

#### procedure AtuaGrid

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:369

**Calls Made:**

- `FraMovi.AtuaGridMovi` (line 379) - External

#### procedure DuplClic

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:388

**Calls Made:**

- `POHeCam6.CampPersDuplCliq` (line 390) - Local

#### procedure ListChecColumnClick

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:394

**Calls Made:**

- `POHeCam6.CampPersListChecColumnClick` (line 396) - Local

#### procedure LoadCompleted

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:402

**Calls Made:**

- `POHeCam6.to` (line 408) - Local
- `POHeCam6.Assigned` (line 412) - Local
- `POHeCam6.TLstLbl` (line 412) - Local
- `POHeCam6.and` (line 412) - Local
- `POHeCam6.TLstLbl` (line 412) - Local
- `POHeCam6.TLstLbl` (line 414) - Local
- `POHeCam6.TLstLbl` (line 415) - Local
- `POHeCam6.TLstLbl` (line 417) - Local
- `POHeCam6.TLstLbl` (line 419) - Local
- `POHeCam6.TLstLbl` (line 420) - Local
- `POHeCam6.TLstLbl` (line 423) - Local
- `POHeCam6.CarregaDados` (line 423) - Local
- `POHeCam6.TLstLbl` (line 424) - Local

#### procedure BtnConfClick 🎯

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:436

**Calls Made:**

- `POHeCam6.BtnConf_CampModi` (line 442) - Local
- `POHeCam6.Assigned` (line 447) - Local
- `New.getPropTableValue` (line 450) - External
- `Old.getPropTableValue` (line 450) - External
- `POHeCam6.and` (line 454) - Local
- `POHeCam6.Assigned` (line 456) - Local
- `POHeCam6.and` (line 457) - Local
- `DataSet.FindField` (line 457) - External
- `POHeCam6.and` (line 458) - Local
- `DataSet.FindField` (line 458) - External
- `POHeCam6.Trim` (line 460) - Local
- `DataSet.FieldByName` (line 460) - External
- `DataSet.FieldByName` (line 461) - External
- `POHeCam6.WHERE` (line 468) - Local
- `POHeCam6.IntToStr` (line 468) - Local
- `POHeCam6.AND` (line 469) - Local
- `POHeCam6.IN` (line 469) - Local
- `POHeCam6.AND` (line 470) - Local
- `POHeCam6.and` (line 473) - Local
- `POHeCam6.CampPersCompAtuaGetProp` (line 475) - Local
- `POHeCam6.CampPersCompAtua` (line 475) - Local
- `POHeCam6.CampPersAcao` (line 478) - Local
- `POHeCam6.EspaDire` (line 478) - Local
- `POHeCam6.sgMessageDlg` (line 479) - Local
- `POHeCam6.SubsPala` (line 479) - Local
- `DataSet.FieldByName` (line 491) - External
- `DataSet.FieldByName` (line 491) - External
- `POHeCam6.and` (line 506) - Local
- `POHeCam6.BtnConf_Ante` (line 509) - Local
- `POHeCam6.msgAviso` (line 512) - Local
- `POHeCam6.Compras` (line 512) - Local
- `POHeCam6.msgAviso` (line 514) - Local
- `POHeCam6.Diretoria` (line 514) - Local
- `POHeCam6.ExibMensHint` (line 517) - Local
- `POHeCam6.Perform` (line 521) - Local
- `POHeCam6.ConfGrav` (line 522) - Local
- `POHeCam6.StrIn` (line 524) - Local
- `POHeCam6.CampPersInicGravPara` (line 526) - Local
- `POHeCam6.RecaDadoGera` (line 527) - Local
- `POHeCam6.VeriEnviConf` (line 528) - Local
- `POHeCam6.CampPers_TratExec` (line 528) - Local
- `POHeCam6.CampPers_TratExec` (line 537) - Local
- `POHeCam6.CampPersValiExecLinh` (line 542) - Local
- `POHeCam6.Copy` (line 544) - Local
- `POHeCam6.BuscPareWin` (line 548) - Local
- `POHeCam6.Copy` (line 553) - Local
- `POHeCam6.Inc` (line 554) - Local
- `POHeCam6.Inc` (line 556) - Local
- `POHeCam6.InicCampSequ` (line 563) - Local
- `DataSet.FieldByName` (line 568) - External
- `DataSet.FieldByName` (line 569) - External
- `POHeCam6.GravSemC` (line 571) - Local
- `POHeCam6.msgOk` (line 577) - Local
- `POHeCam6.VeriEnviConf` (line 581) - Local
- `POHeCam6.CampPers_TratExec` (line 581) - Local
- `POHeCam6.FormShow` (line 583) - Local
- `POHeCam6.and` (line 586) - Local
- `POHeCam6.VeriEnviConf` (line 592) - Local
- `POHeCam6.CampPers_TratExec` (line 592) - Local
- `POHeCam6.to` (line 594) - Local
- `POHeCam6.and` (line 596) - Local
- `POHeCam6.TDbLcbLbl` (line 598) - Local
- `POHeCam6.FindComponent` (line 598) - Local
- `POHeCam6.Copy` (line 598) - Local
- `POHeCam6.Assigned` (line 599) - Local
- `POHeCam6.TsgQuery` (line 602) - Local
- `POHeCam6.TsgQuery` (line 604) - Local
- `POHeCam6.ExibMensHint` (line 618) - Local
- `POHeCam6.BtnConf_Depo` (line 622) - Local

#### function BtnConf_CampModi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:442

**Calls Made:**

- `POHeCam6.Assigned` (line 447) - Local
- `New.getPropTableValue` (line 450) - External
- `Old.getPropTableValue` (line 450) - External
- `POHeCam6.and` (line 454) - Local
- `POHeCam6.Assigned` (line 456) - Local
- `POHeCam6.and` (line 457) - Local
- `DataSet.FindField` (line 457) - External
- `POHeCam6.and` (line 458) - Local
- `DataSet.FindField` (line 458) - External
- `POHeCam6.Trim` (line 460) - Local
- `DataSet.FieldByName` (line 460) - External
- `DataSet.FieldByName` (line 461) - External
- `POHeCam6.WHERE` (line 468) - Local
- `POHeCam6.IntToStr` (line 468) - Local
- `POHeCam6.AND` (line 469) - Local
- `POHeCam6.IN` (line 469) - Local
- `POHeCam6.AND` (line 470) - Local
- `POHeCam6.and` (line 473) - Local
- `POHeCam6.CampPersCompAtuaGetProp` (line 475) - Local
- `POHeCam6.CampPersCompAtua` (line 475) - Local
- `POHeCam6.CampPersAcao` (line 478) - Local
- `POHeCam6.EspaDire` (line 478) - Local
- `POHeCam6.sgMessageDlg` (line 479) - Local
- `POHeCam6.SubsPala` (line 479) - Local
- `DataSet.FieldByName` (line 491) - External
- `DataSet.FieldByName` (line 491) - External

#### procedure FormCreate

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:627

**Calls Made:**

- `POHeCam6.Assigned` (line 636) - Local
- `TsgConn.Create` (line 638) - External
- `POHeCam6.ConfConnectionString` (line 642) - Local
- `POHeCam6.TsgTransaction` (line 643) - Local
- `POHeCam6.Create` (line 652) - Local
- `POHeCam6.not` (line 654) - Local
- `POHeCam6.IntToStr` (line 660) - Local
- `POHeCam6.sgStrToInt` (line 669) - Local
- `POHeCam6.CriaTbs` (line 673) - Local
- `POHeCam6.IntToStr` (line 673) - Local
- `POHeCam6.CriaTbs` (line 675) - Local
- `POHeCam6.IntToStr` (line 675) - Local
- `TFraCaMv.Create` (line 677) - External
- `POHeCam6.IntToStr` (line 679) - Local
- `POHeCam6.FormInteBras` (line 681) - Local
- `POHeCam6.CampPers_TratNome` (line 709) - Local
- `POHeCam6.TradSQL_Cons` (line 714) - Local
- `POHeCam6.TradSQL_Cons` (line 715) - Local
- `ListMovi.Add` (line 719) - External

#### procedure FormClose

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:740

**Calls Made:**

- `POHeCam6.and` (line 752) - Local
- `POHeCam6.not` (line 752) - Local
- `POHeCam6.ExecSQL_` (line 753) - Local
- `POHeCam6.IntToStr` (line 753) - Local
- `POHeCam6.Assigned` (line 755) - Local
- `POHeCam6.SetPsgTrans` (line 760) - Local
- `POHeCam6.Assigned` (line 773) - Local

#### procedure FormDestroy

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:780

**Calls Made:**

- `POHeCam6.Assigned` (line 786) - Local
- `POHeCam6.SetPsgTrans` (line 791) - Local
- `POHeCam6.FreeAndNil` (line 793) - Local
- `POHeCam6.Assigned` (line 797) - Local
- `POHeCam6.Assigned` (line 800) - Local
- `POHeCam6.FreeAndNil` (line 802) - Local
- `POHeCam6.Assigned` (line 805) - Local
- `POHeCam6.FreeAndNil` (line 813) - Local

#### function IsWeb

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:1056

_No outgoing calls_

#### procedure AfterCreate

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:1065

**Calls Made:**

- `POHeCam6.and` (line 1073) - Local
- `POHeCam6.Assigned` (line 1080) - Local
- `POHeCam6.ExibMensHint` (line 1083) - Local
- `POHeCam6.CampPersExecDireStri` (line 1084) - Local
- `DtmPoul.Campos_Busc` (line 1084) - External
- `POHeCam6.ExibMensHint` (line 1091) - Local
- `POHeCam6.MontCampPers` (line 1094) - Local
- `POHeCam6.msgRaiseTratada` (line 1100) - Local
- `POHeCam6.CampPers_TratNome` (line 1103) - Local
- `POHeCam6.Assigned` (line 1104) - Local
- `POHeCam6.TsgTbs` (line 1104) - Local
- `POHeCam6.FindComponent` (line 1104) - Local
- `POHeCam6.TsgTbs` (line 1105) - Local
- `POHeCam6.FindComponent` (line 1105) - Local
- `POHeCam6.CampPers_TratNome` (line 1105) - Local
- `POHeCam6.Assigned` (line 1108) - Local
- `POHeCam6.Trim` (line 1113) - Local
- `POHeCam6.Assigned` (line 1117) - Local
- `POHeCam6.Assigned` (line 1117) - Local
- `ListPrin.Add` (line 1118) - External
- `Pai_Tabe.Assign` (line 1124) - External
- `POHeCam6.StrToInt` (line 1128) - Local
- `POHeCam6.RetoZero` (line 1128) - Local
- `DtmPoul.Campos_Busc` (line 1128) - External
- `POHeCam6.IntToStr` (line 1128) - Local
- `POHeCam6.Inc` (line 1146) - Local
- `POHeCam6.and` (line 1166) - Local
- `POHeCam6.SeInte` (line 1178) - Local
- `POHeCam6.ExibMensHint` (line 1196) - Local
- `POHeCam6.PopAtuaClick` (line 1197) - Local
- `POHeCam6.ExibMensHint` (line 1199) - Local
- `POHeCam6.CampPersExecDireStri` (line 1200) - Local
- `DtmPoul.Campos_Busc` (line 1200) - External
- `POHeCam6.ExibMensHint` (line 1201) - Local

#### procedure Grav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:1218

**Calls Made:**

- `POHeCam6.Assigned` (line 1220) - Local
- `POHeCam6.Assigned` (line 1220) - Local
- `POHeCam6.and` (line 1220) - Local
- `Func.GravLog_Mens` (line 1222) - External
- `POHeCam6.CampPersExecListInst` (line 1224) - Local

#### procedure LePeso

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/POHeCam6.pas:1228

**Calls Made:**

- `POHeCam6.NumeroInRange` (line 1230) - Local
- `POHeCam6.Assigned` (line 1232) - Local
- `POHeCam6.and` (line 1232) - Local
- `Func.GravLog_Mens` (line 1234) - External
- `POHeCam6.FormRealBras` (line 1234) - Local
- `POHeCam6.CampPersExecListInst` (line 1236) - Local


---

## 🔄 Call Chains

### Chain 1 (Depth: 5) ⚠️ CIRCULAR

```
POHeCam6.BtnConfClick → POHeCam6.FormShow → POHeCam6.ConfPortSeri → POHeCam6.BuscaComponente → POHeCam6.BuscaComponente
```

**Nodes:**

- `POHeCam6.BtnConfClick` (line 436)
- `POHeCam6.FormShow` (line 883)
- `POHeCam6.ConfPortSeri` (line 292)
- `POHeCam6.BuscaComponente` (line 138)
- `POHeCam6.BuscaComponente` (line 138)

### Chain 2 (Depth: 4) ⚠️ CIRCULAR

```
POHeCam6.FormShow → POHeCam6.ConfPortSeri → POHeCam6.BuscaComponente → POHeCam6.BuscaComponente
```

**Nodes:**

- `POHeCam6.FormShow` (line 883)
- `POHeCam6.ConfPortSeri` (line 292)
- `POHeCam6.BuscaComponente` (line 138)
- `POHeCam6.BuscaComponente` (line 138)

### Chain 3 (Depth: 3) ⚠️ CIRCULAR

```
POHeCam6.MudaTab2 → POHeCam6.MudaTabe2_BuscTbs_Index → POHeCam6.MudaTabe2_BuscTbs_Index
```

**Nodes:**

- `POHeCam6.MudaTab2` (line 227)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)

### Chain 4 (Depth: 3) ⚠️ CIRCULAR

```
POHeCam6.MudaTab2 → POHeCam6.MudaTabe2_BuscTbs_Index → POHeCam6.MudaTabe2_BuscTbs_Index
```

**Nodes:**

- `POHeCam6.MudaTab2` (line 227)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)

### Chain 5 (Depth: 3) ⚠️ CIRCULAR

```
POHeCam6.MudaTab2 → POHeCam6.MudaTabe2_BuscTbs_Index → POHeCam6.MudaTabe2_BuscTbs_Index
```

**Nodes:**

- `POHeCam6.MudaTab2` (line 227)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)

### Chain 6 (Depth: 3) ⚠️ CIRCULAR

```
POHeCam6.ConfPortSeri → POHeCam6.BuscaComponente → POHeCam6.BuscaComponente
```

**Nodes:**

- `POHeCam6.ConfPortSeri` (line 292)
- `POHeCam6.BuscaComponente` (line 138)
- `POHeCam6.BuscaComponente` (line 138)

### Chain 7 (Depth: 2) ⚠️ CIRCULAR

```
POHeCam6.BuscaComponente → POHeCam6.BuscaComponente
```

**Nodes:**

- `POHeCam6.BuscaComponente` (line 138)
- `POHeCam6.BuscaComponente` (line 138)

### Chain 8 (Depth: 2) ⚠️ CIRCULAR

```
POHeCam6.MudaTabe2_BuscTbs_Index → POHeCam6.MudaTabe2_BuscTbs_Index
```

**Nodes:**

- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)
- `POHeCam6.MudaTabe2_BuscTbs_Index` (line 234)

### Chain 9 (Depth: 1)

```
POHeCam6.IsWeb
```

**Nodes:**

- `POHeCam6.IsWeb` (line 1056)


---

## ⚠️ Circular Dependencies

The following circular dependencies were detected:

- POHeCam6 ↔ POHeCam6

---

**Report generated by:** `map_method_calls.py` v2.3.0 (mode: focused)
**Generation time:** 2025-12-23 12:35:27
