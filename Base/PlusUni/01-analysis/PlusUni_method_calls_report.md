# Method Calls Analysis Report - PlusUni

**Analysis Date:** 2025-12-23 13:10:01
**Analysis Mode:** FOCUSED
**Recursive Analysis:** Yes
**Max Depth:** 10
**Filtering:** Enabled

---

## 📊 Statistics

### General Metrics

| Metric | Value |
|--------|-------|
| Total Methods Analyzed | 175 |
| Total Method Calls | 2805 |
| External Calls | 440 |
| Local Calls | 2365 |
| Event Handlers | 0 |
| Units Analyzed | 2 |
| Max Depth Reached | 5 |
| Total Call Chains | 456 |
| Circular Dependencies | 1 |


### Methods by Relevance (for AS-IS Documentation)

| Category | Count | % | Description |
|----------|-------|---|-------------|
| 🔴 **Critical** | 175 | 100.0% | MUST be detailed in AS-IS Section 9.1 |
| 🟡 **Relevant** | 0 | 0.0% | Should be mentioned in AS-IS Section 9.2 |
| ⚪ **Omitted** | 0 | 0.0% | Infrastructure - not in AS-IS |

**Methods in AS-IS:** 175 (100.0%)
**Reduction:** 0.0% infrastructure omitted

### Methods by Type

| Type | Count | Description |
|------|-------|-------------|
| 💾 SQL | 3 | Database access (always critical) |
| ✅ Validation | 4 | Business rule validation |
| 🔧 Business | 4 | Core business logic |
| ⚙️ Infrastructure | 164 | UI/Framework (omitted) |

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
| Quer | 111 |
| cds | 56 |
| iQuer | 41 |
| vProc | 38 |
| Subs | 38 |
| TsgQuery | 25 |
| DataSet | 15 |
| List | 9 |
| Application | 8 |
| DtmPoul | 8 |

---

## 📞 Method Call Details

### Unit: PlusUni

#### function CampPers_BuscSQL

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:2557

**Calls Made:**

- `PlusUni.sgCopy` (line 2562) - Local
- `PlusUni.TiraEspaLinhFinaList` (line 2566) - Local
- `PlusUni.CampPersExecDireStri` (line 2569) - Local
- `PlusUni.CampPers_OD` (line 2570) - Local

#### procedure CampPersInicGravPara

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:3334

**Calls Made:**

- `PlusUni.Assigned` (line 3342) - Local
- `PlusUni.SetPsgTrans` (line 3342) - Local
- `DtmPoul.Campos_Cds` (line 3344) - External
- `PlusUni.AND` (line 3345) - Local
- `PlusUni.OR` (line 3346) - Local
- `PlusUni.OR` (line 3347) - Local
- `PlusUni.OR` (line 3348) - Local
- `PlusUni.OR` (line 3349) - Local
- `PlusUni.OR` (line 3350) - Local
- `PlusUni.OR` (line 3351) - Local
- `PlusUni.OR` (line 3352) - Local
- `PlusUni.OR` (line 3353) - Local
- `PlusUni.OR` (line 3354) - Local
- `PlusUni.OR` (line 3355) - Local
- `PlusUni.OR` (line 3356) - Local
- `PlusUni.OR` (line 3357) - Local
- `PlusUni.OR` (line 3358) - Local
- `PlusUni.not` (line 3361) - Local
- `PlusUni.SeInte` (line 3363) - Local
- `PlusUni.SeInte` (line 3363) - Local
- `cds.FieldByName` (line 3363) - External
- `cds.FieldByName` (line 3364) - External
- `cds.FieldByName` (line 3365) - External
- `cds.FieldByName` (line 3367) - External
- `PlusUni.TRxEdtLbl` (line 3370) - Local
- `PlusUni.FindComponent` (line 3370) - Local
- `PlusUni.PegaParaNume` (line 3370) - Local
- `PlusUni.GravParaNume` (line 3372) - Local
- `PlusUni.TRxEdtLbl` (line 3372) - Local
- `PlusUni.FindComponent` (line 3372) - Local
- `cds.FieldByName` (line 3372) - External
- `cds.FieldByName` (line 3375) - External
- `PlusUni.TRxDatLbl` (line 3378) - Local
- `PlusUni.FindComponent` (line 3378) - Local
- `PlusUni.PegaParaData` (line 3378) - Local
- `PlusUni.GravParaData` (line 3380) - Local
- `PlusUni.TRxDatLbl` (line 3380) - Local
- `PlusUni.FindComponent` (line 3380) - Local
- `cds.FieldByName` (line 3380) - External
- `cds.FieldByName` (line 3383) - External
- `PlusUni.TEdtLbl` (line 3386) - Local
- `PlusUni.FindComponent` (line 3386) - Local
- `PlusUni.PegaPara` (line 3386) - Local
- `PlusUni.GravPara` (line 3388) - Local
- `PlusUni.TEdtLbl` (line 3388) - Local
- `PlusUni.FindComponent` (line 3388) - Local
- `cds.FieldByName` (line 3388) - External
- `cds.FieldByName` (line 3390) - External
- `PlusUni.TFilLbl` (line 3393) - Local
- `PlusUni.FindComponent` (line 3393) - Local
- `PlusUni.PegaPara` (line 3393) - Local
- `PlusUni.GravPara` (line 3395) - Local
- `PlusUni.TFilLbl` (line 3395) - Local
- `PlusUni.FindComponent` (line 3395) - Local
- `cds.FieldByName` (line 3395) - External
- `cds.FieldByName` (line 3397) - External
- `PlusUni.TDirLbl` (line 3400) - Local
- `PlusUni.FindComponent` (line 3400) - Local
- `PlusUni.PegaPara` (line 3400) - Local
- `PlusUni.GravPara` (line 3402) - Local
- `PlusUni.TDirLbl` (line 3402) - Local
- `PlusUni.FindComponent` (line 3402) - Local
- `cds.FieldByName` (line 3402) - External
- `cds.FieldByName` (line 3405) - External
- `PlusUni.TChkLbl` (line 3408) - Local
- `PlusUni.FindComponent` (line 3408) - Local
- `PlusUni.PegaParaLogi` (line 3408) - Local
- `PlusUni.GravParaLogi` (line 3410) - Local
- `PlusUni.TChkLbl` (line 3410) - Local
- `PlusUni.FindComponent` (line 3410) - Local
- `cds.FieldByName` (line 3410) - External
- `cds.FieldByName` (line 3413) - External
- `PlusUni.TCmbLbl` (line 3416) - Local
- `PlusUni.FindComponent` (line 3416) - Local
- `PlusUni.PegaPara` (line 3416) - Local
- `PlusUni.GravPara` (line 3418) - Local
- `PlusUni.TCmbLbl` (line 3418) - Local
- `PlusUni.FindComponent` (line 3418) - Local
- `cds.FieldByName` (line 3418) - External
- `cds.FieldByName` (line 3421) - External
- `PlusUni.TMemLbl` (line 3424) - Local
- `PlusUni.FindComponent` (line 3424) - Local
- `PlusUni.PegaParaMemo` (line 3424) - Local
- `PlusUni.GravParaMemo` (line 3426) - Local
- `PlusUni.TMemLbl` (line 3426) - Local
- `PlusUni.FindComponent` (line 3426) - Local
- `cds.FieldByName` (line 3426) - External
- `cds.FieldByName` (line 3429) - External
- `cds.FieldByName` (line 3430) - External
- `cds.FieldByName` (line 3431) - External
- `cds.FieldByName` (line 3432) - External
- `cds.FieldByName` (line 3433) - External
- `PlusUni.TAdvMemLbl` (line 3436) - Local
- `PlusUni.FindComponent` (line 3436) - Local
- `PlusUni.PegaParaMemo` (line 3436) - Local
- `PlusUni.GravParaMemo` (line 3438) - Local
- `PlusUni.TAdvMemLbl` (line 3438) - Local
- `PlusUni.FindComponent` (line 3438) - Local
- `cds.FieldByName` (line 3438) - External
- `cds.FieldByName` (line 3441) - External
- `PlusUni.TLcbLbl` (line 3444) - Local
- `PlusUni.FindComponent` (line 3444) - Local
- `PlusUni.PegaParaNume` (line 3444) - Local
- `PlusUni.GravParaNume` (line 3446) - Local
- `PlusUni.TLcbLbl` (line 3446) - Local
- `PlusUni.FindComponent` (line 3446) - Local
- `cds.FieldByName` (line 3446) - External
- `cds.FieldByName` (line 3449) - External
- `PlusUni.TDBLookNume` (line 3452) - Local
- `PlusUni.FindComponent` (line 3452) - Local
- `PlusUni.PegaParaNume` (line 3452) - Local
- `PlusUni.GravParaNume` (line 3454) - Local
- `PlusUni.TDBLookNume` (line 3454) - Local
- `PlusUni.FindComponent` (line 3454) - Local
- `cds.FieldByName` (line 3454) - External
- `PlusUni.FreeAndNil` (line 3460) - Local

#### procedure InicValoCampPers

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:3466

**Calls Made:**

- `PlusUni.Assigned` (line 3476) - Local
- `PlusUni.SetPsgTrans` (line 3476) - Local
- `DtmPoul.Campos_Cds` (line 3479) - External
- `PlusUni.AND` (line 3480) - Local
- `PlusUni.OR` (line 3480) - Local
- `PlusUni.AND` (line 3481) - Local
- `PlusUni.AND` (line 3482) - Local
- `PlusUni.AND` (line 3483) - Local
- `PlusUni.AND` (line 3484) - Local
- `PlusUni.AND` (line 3485) - Local
- `PlusUni.AND` (line 3486) - Local
- `PlusUni.AND` (line 3487) - Local
- `PlusUni.AND` (line 3488) - Local
- `PlusUni.AND` (line 3489) - Local
- `PlusUni.AND` (line 3490) - Local
- `PlusUni.AND` (line 3491) - Local
- `PlusUni.AND` (line 3492) - Local
- `PlusUni.AND` (line 3493) - Local
- `PlusUni.AND` (line 3494) - Local
- `PlusUni.AND` (line 3495) - Local
- `PlusUni.AND` (line 3496) - Local
- `PlusUni.not` (line 3499) - Local
- `cds.FieldByName` (line 3501) - External
- `cds.FieldByName` (line 3502) - External
- `cds.FieldByName` (line 3503) - External
- `PlusUni.TestDataSet` (line 3505) - Local
- `PlusUni.StrIn` (line 3508) - Local
- `DataSet.FieldByName` (line 3511) - External
- `cds.FieldByName` (line 3511) - External
- `cds.FieldByName` (line 3519) - External
- `DataSet.FieldByName` (line 3520) - External
- `cds.FieldByName` (line 3529) - External
- `PlusUni.Assigned` (line 3531) - Local
- `DataSet.FieldByName` (line 3532) - External
- `PlusUni.POCaNume_ProxSequ` (line 3532) - Local
- `DtmPoul.Tabelas_Busc` (line 3532) - External
- `PlusUni.IntToStr` (line 3532) - Local
- `cds.FieldByName` (line 3532) - External
- `DataSet.FieldByName` (line 3535) - External
- `PlusUni.POCaNume_ProxSequ` (line 3535) - Local
- `DtmPoul.Tabelas_Busc` (line 3535) - External
- `PlusUni.IntToStr` (line 3535) - Local
- `cds.FieldByName` (line 3535) - External
- `DataSet.FieldByName` (line 3539) - External
- `cds.FieldByName` (line 3539) - External
- `PlusUni.TsgQuery` (line 3546) - Local
- `PlusUni.FindComponent` (line 3546) - Local
- `PlusUni.TDBLcbLbl` (line 3548) - Local
- `PlusUni.FindComponent` (line 3548) - Local
- `PlusUni.TsgQuery` (line 3551) - Local
- `PlusUni.FindComponent` (line 3551) - Local
- `PlusUni.Assigned` (line 3552) - Local
- `DataSet.FieldByName` (line 3553) - External
- `PlusUni.TsgQuery` (line 3560) - Local
- `PlusUni.FindComponent` (line 3560) - Local
- `PlusUni.TDBLookNume` (line 3562) - Local
- `PlusUni.FindComponent` (line 3562) - Local
- `PlusUni.TsgQuery` (line 3562) - Local
- `PlusUni.FindComponent` (line 3562) - Local
- `DataSet.FieldByName` (line 3571) - External
- `PlusUni.TDbRxDLbl` (line 3571) - Local
- `PlusUni.FindComponent` (line 3571) - Local
- `DataSet.FieldByName` (line 3572) - External
- `DataSet.FieldByName` (line 3573) - External
- `DataSet.FieldByName` (line 3582) - External
- `PlusUni.SeInte` (line 3582) - Local
- `cds.FieldByName` (line 3582) - External
- `PlusUni.StrIn` (line 3588) - Local
- `DataSet.FieldByName` (line 3590) - External
- `PlusUni.and` (line 3593) - Local
- `PlusUni.TDBEdtLbl` (line 3594) - Local
- `PlusUni.FindComponent` (line 3594) - Local
- `cds.FieldByName` (line 3594) - External
- `PlusUni.CalcStri` (line 3594) - Local
- `PlusUni.TDBEdtLbl` (line 3596) - Local
- `PlusUni.FindComponent` (line 3596) - Local
- `cds.FieldByName` (line 3596) - External
- `cds.FieldByName` (line 3596) - External
- `cds.FieldByName` (line 3599) - External
- `PlusUni.TDBEdtLbl` (line 3603) - Local
- `PlusUni.FindComponent` (line 3603) - Local
- `cds.FieldByName` (line 3603) - External
- `PlusUni.TDBFilLbl` (line 3605) - Local
- `PlusUni.FindComponent` (line 3605) - Local
- `cds.FieldByName` (line 3605) - External
- `PlusUni.TDBMemLbl` (line 3607) - Local
- `PlusUni.FindComponent` (line 3607) - Local
- `cds.FieldByName` (line 3607) - External
- `PlusUni.TLcbLbl` (line 3614) - Local
- `PlusUni.FindComponent` (line 3614) - Local
- `PlusUni.TsgQuery` (line 3614) - Local
- `PlusUni.FindComponent` (line 3614) - Local
- `PlusUni.TsgQuery` (line 3620) - Local
- `PlusUni.FindComponent` (line 3620) - Local
- `PlusUni.Assigned` (line 3621) - Local
- `PlusUni.TDBLookNume` (line 3622) - Local
- `PlusUni.FindComponent` (line 3622) - Local
- `PlusUni.TRxDatLbl` (line 3628) - Local
- `PlusUni.FindComponent` (line 3628) - Local
- `PlusUni.TChkLbl` (line 3634) - Local
- `PlusUni.FindComponent` (line 3634) - Local
- `cds.FieldByName` (line 3634) - External
- `PlusUni.TCmbLbl` (line 3641) - Local
- `PlusUni.FindComponent` (line 3641) - Local
- `cds.FieldByName` (line 3647) - External
- `PlusUni.TRxEdtLbl` (line 3648) - Local
- `PlusUni.FindComponent` (line 3648) - Local
- `PlusUni.POCaNume_ProxSequ` (line 3648) - Local
- `DtmPoul.Tabelas_Busc` (line 3648) - External
- `PlusUni.IntToStr` (line 3648) - Local
- `cds.FieldByName` (line 3648) - External
- `PlusUni.TRxEdtLbl` (line 3651) - Local
- `PlusUni.FindComponent` (line 3651) - Local
- `cds.FieldByName` (line 3651) - External
- `PlusUni.FreeAndNil` (line 3657) - Local

#### procedure CampPersExecExit

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:3698

**Calls Made:**

- `PlusUni.CampPersRetoListExec` (line 3704) - Local
- `PlusUni.ExibMensHint` (line 3708) - Local
- `PlusUni.CampPersExecListInst` (line 3711) - Local
- `PlusUni.ExibMensHint` (line 3713) - Local

#### procedure CampPersDuplCliq

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:5631

**Calls Made:**

- `PlusUni.Assigned` (line 5637) - Local
- `PlusUni.SetPsgTrans` (line 5637) - Local
- `PlusUni.TLstLbl` (line 5640) - Local
- `PlusUni.ListViewSele` (line 5645) - Local
- `PlusUni.TLstLbl` (line 5645) - Local
- `PlusUni.OnClick` (line 5647) - Local

#### procedure CampPersExecExitShow

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:5654

**Calls Made:**

- `DtmPoul.Campos_Cds` (line 5662) - External
- `PlusUni.AND` (line 5663) - Local
- `PlusUni.AND` (line 5664) - Local
- `PlusUni.AND` (line 5665) - Local
- `PlusUni.AND` (line 5666) - Local
- `PlusUni.AND` (line 5667) - Local
- `PlusUni.AND` (line 5668) - Local
- `PlusUni.AND` (line 5669) - Local
- `PlusUni.Trim` (line 5674) - Local
- `cds.FieldByName` (line 5674) - External
- `cds.FieldByName` (line 5678) - External
- `cds.FieldByName` (line 5679) - External
- `PlusUni.TDBLookNume` (line 5680) - Local
- `PlusUni.FindComponent` (line 5680) - Local
- `cds.FieldByName` (line 5680) - External
- `PlusUni.SetPLblAjud_Capt` (line 5687) - Local
- `cds.FieldByName` (line 5687) - External
- `cds.FieldByName` (line 5688) - External
- `PlusUni.Copy` (line 5692) - Local
- `PlusUni.Trim` (line 5692) - Local
- `PlusUni.Copy` (line 5693) - Local
- `PlusUni.Trim` (line 5693) - Local
- `PlusUni.Copy` (line 5694) - Local
- `PlusUni.Trim` (line 5694) - Local
- `PlusUni.Copy` (line 5696) - Local
- `PlusUni.Trim` (line 5696) - Local
- `PlusUni.Copy` (line 5697) - Local
- `PlusUni.Trim` (line 5697) - Local
- `PlusUni.Copy` (line 5699) - Local
- `PlusUni.Trim` (line 5699) - Local
- `List.Delete` (line 5700) - External
- `List.Delete` (line 5701) - External
- `PlusUni.Inc` (line 5704) - Local
- `PlusUni.CampPersExecListInst` (line 5706) - Local
- `PlusUni.FreeAndNil` (line 5714) - Local

#### function CampPers_ExecData

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:5733

**Calls Made:**

- `PlusUni.ExecPers_isConst` (line 5738) - Local
- `PlusUni.ExecExprMate` (line 5739) - Local
- `PlusUni.SubsPala` (line 5739) - Local
- `PlusUni.SubsPala` (line 5739) - Local
- `PlusUni.CalcData` (line 5741) - Local

#### function CampPers_ExecLinhStri

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:5747

**Calls Made:**

- `PlusUni.Copy` (line 5753) - Local
- `PlusUni.Copy` (line 5754) - Local
- `PlusUni.Trim` (line 5754) - Local
- `PlusUni.Length` (line 5754) - Local
- `PlusUni.Trim` (line 5754) - Local
- `PlusUni.sgCopy` (line 5755) - Local
- `PlusUni.sgCopy` (line 5755) - Local
- `PlusUni.FormDataSQL` (line 5755) - Local
- `PlusUni.sgCopy` (line 5756) - Local
- `PlusUni.sgCopy` (line 5756) - Local
- `PlusUni.FormHoraSQL` (line 5756) - Local
- `PlusUni.Trim` (line 5758) - Local
- `PlusUni.Copy` (line 5759) - Local
- `PlusUni.Pos` (line 5759) - Local
- `PlusUni.Copy` (line 5760) - Local
- `PlusUni.Pos` (line 5760) - Local
- `PlusUni.sgCopy` (line 5762) - Local
- `PlusUni.CalcStri` (line 5763) - Local
- `PlusUni.sgCopy` (line 5764) - Local
- `PlusUni.CalcStri` (line 5765) - Local
- `PlusUni.sgCopy` (line 5766) - Local
- `PlusUni.sgCopy` (line 5767) - Local
- `PlusUni.ExecSQL_` (line 5768) - Local
- `PlusUni.ExecPers_isConst` (line 5769) - Local
- `PlusUni.ExecExprMate` (line 5770) - Local
- `PlusUni.SubsPala` (line 5770) - Local
- `PlusUni.SubsPala` (line 5770) - Local
- `PlusUni.sgCopy` (line 5771) - Local
- `PlusUni.sgCopy` (line 5772) - Local
- `PlusUni.ExecExprMate` (line 5773) - Local

#### function CampPers_EX

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:6376

**Calls Made:**

- `PlusUni.Assigned` (line 6398) - Local
- `PlusUni.SetPsgTrans` (line 6398) - Local
- `PlusUni.CoInitialize` (line 6400) - Local
- `TADOQuery.Create` (line 6402) - External
- `TsgQuery.Create` (line 6406) - External
- `PlusUni.AnsiUpperCase` (line 6410) - Local
- `PlusUni.Trim` (line 6410) - Local
- `PlusUni.or` (line 6411) - Local
- `PlusUni.and` (line 6416) - Local
- `Quer.FieldByName` (line 6418) - External
- `PlusUni.SeInte` (line 6419) - Local
- `PlusUni.VeriExisCampTabe` (line 6419) - Local
- `Quer.FieldByName` (line 6419) - External
- `PlusUni.POChPesa_ConfPesa_RFC` (line 6420) - Local
- `Quer.FieldByName` (line 6420) - External
- `Quer.FieldByName` (line 6421) - External
- `Quer.FieldByName` (line 6422) - External
- `Quer.FieldByName` (line 6423) - External
- `Quer.FieldByName` (line 6424) - External
- `Quer.FieldByName` (line 6425) - External
- `Quer.FieldByName` (line 6426) - External
- `Quer.FieldByName` (line 6427) - External
- `Quer.FieldByName` (line 6428) - External
- `Quer.FieldByName` (line 6429) - External
- `Quer.FieldByName` (line 6430) - External
- `Quer.FieldByName` (line 6431) - External
- `Quer.FieldByName` (line 6432) - External
- `Quer.FieldByName` (line 6433) - External
- `Quer.FieldByName` (line 6434) - External
- `Quer.FieldByName` (line 6435) - External
- `Quer.FieldByName` (line 6436) - External
- `Quer.FieldByName` (line 6438) - External
- `Quer.FieldByName` (line 6439) - External
- `Quer.FieldByName` (line 6440) - External
- `Quer.FieldByName` (line 6441) - External
- `Quer.FieldByName` (line 6442) - External
- `Quer.FieldByName` (line 6443) - External
- `PlusUni.IntToStr` (line 6446) - Local
- `PlusUni.SeStri` (line 6449) - Local
- `PlusUni.and` (line 6456) - Local
- `Quer.FieldByName` (line 6458) - External
- `PlusUni.SeInte` (line 6459) - Local
- `PlusUni.VeriExisCampTabe` (line 6459) - Local
- `Quer.FieldByName` (line 6459) - External
- `PlusUni.POChPesa_ConfPesa_RFC_SAFRA` (line 6460) - Local
- `Quer.FieldByName` (line 6460) - External
- `Quer.FieldByName` (line 6461) - External
- `Quer.FieldByName` (line 6462) - External
- `Quer.FieldByName` (line 6463) - External
- `Quer.FieldByName` (line 6464) - External
- `Quer.FieldByName` (line 6465) - External
- `Quer.FieldByName` (line 6466) - External
- `Quer.FieldByName` (line 6467) - External
- `Quer.FieldByName` (line 6468) - External
- `Quer.FieldByName` (line 6469) - External
- `Quer.FieldByName` (line 6470) - External
- `Quer.FieldByName` (line 6471) - External
- `Quer.FieldByName` (line 6472) - External
- `Quer.FieldByName` (line 6473) - External
- `Quer.FieldByName` (line 6474) - External
- `Quer.FieldByName` (line 6475) - External
- `Quer.FieldByName` (line 6476) - External
- `Quer.FieldByName` (line 6478) - External
- `Quer.FieldByName` (line 6479) - External
- `Quer.FieldByName` (line 6480) - External
- `Quer.FieldByName` (line 6481) - External
- `Quer.FieldByName` (line 6482) - External
- `Quer.FieldByName` (line 6483) - External
- `PlusUni.IntToStr` (line 6486) - Local
- `PlusUni.SeStri` (line 6489) - Local
- `PlusUni.Trim` (line 6491) - Local
- `PlusUni.and` (line 6497) - Local
- `PlusUni.VeriExisCampTabe` (line 6499) - Local
- `Quer.FieldByName` (line 6500) - External
- `PlusUni.POChPesa_ConfPesa` (line 6501) - Local
- `Quer.FieldByName` (line 6502) - External
- `Quer.FieldByName` (line 6503) - External
- `Quer.FieldByName` (line 6504) - External
- `Quer.FieldByName` (line 6505) - External
- `Quer.FieldByName` (line 6506) - External
- `Quer.FieldByName` (line 6507) - External
- `Quer.FieldByName` (line 6508) - External
- `Quer.FieldByName` (line 6509) - External
- `Quer.FieldByName` (line 6510) - External
- `Quer.FieldByName` (line 6511) - External
- `Quer.FieldByName` (line 6512) - External
- `PlusUni.IntToStr` (line 6513) - Local
- `PlusUni.SeStri` (line 6516) - Local
- `PlusUni.and` (line 6523) - Local
- `Quer.FieldByName` (line 6525) - External
- `PlusUni.GeraIndu` (line 6526) - Local
- `Quer.FieldByName` (line 6526) - External
- `PlusUni.Trunc` (line 6526) - Local
- `PlusUni.PegaParaNume` (line 6526) - Local
- `PlusUni.Trunc` (line 6527) - Local
- `PlusUni.PegaParaNume` (line 6527) - Local
- `PlusUni.Trunc` (line 6527) - Local
- `PlusUni.PegaParaNume` (line 6527) - Local
- `PlusUni.Trunc` (line 6528) - Local
- `PlusUni.PegaParaNume` (line 6528) - Local
- `Quer.FieldByName` (line 6528) - External
- `Quer.FieldByName` (line 6529) - External
- `Quer.FieldByName` (line 6529) - External
- `Quer.FieldByName` (line 6530) - External
- `Quer.FieldByName` (line 6530) - External
- `Quer.FieldByName` (line 6531) - External
- `Quer.FieldByName` (line 6531) - External
- `PlusUni.VeriExisCampTabe_Valo` (line 6532) - Local
- `PlusUni.StrToInt` (line 6533) - Local
- `PlusUni.RetoZero` (line 6533) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 6533) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 6534) - Local
- `PlusUni.StrToInt` (line 6535) - Local
- `PlusUni.RetoZero` (line 6535) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 6535) - Local
- `PlusUni.StrToInt` (line 6536) - Local
- `PlusUni.RetoZero` (line 6536) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 6536) - Local
- `Quer.FieldByName` (line 6537) - External
- `PlusUni.SeStri` (line 6541) - Local
- `PlusUni.ApagIndu` (line 6549) - Local
- `Quer.FieldByName` (line 6549) - External
- `Quer.FieldByName` (line 6549) - External
- `Quer.FieldByName` (line 6549) - External
- `PlusUni.GeraPOCaData` (line 6557) - Local
- `PlusUni.FormDataBras` (line 6557) - Local
- `Quer.FieldByName` (line 6557) - External
- `PlusUni.FormDataBras` (line 6557) - Local
- `Quer.FieldByName` (line 6557) - External
- `PlusUni.POCaNume_ProxSequ` (line 6563) - Local
- `Quer.FieldByName` (line 6563) - External
- `Quer.FieldByName` (line 6563) - External
- `PlusUni.VeriExisCampTabe_Valo` (line 6564) - Local
- `PlusUni.Fret_RateEsto` (line 6572) - Local
- `Quer.FieldByName` (line 6572) - External
- `Quer.FieldByName` (line 6572) - External
- `Quer.FieldByName` (line 6573) - External
- `Quer.FieldByName` (line 6573) - External
- `Quer.FieldByName` (line 6574) - External
- `Quer.FieldByName` (line 6574) - External
- `Quer.FieldByName` (line 6575) - External
- `Quer.FieldByName` (line 6575) - External
- `PlusUni.CalcFret_MvAp` (line 6586) - Local
- `Quer.FieldByName` (line 6586) - External
- `Quer.FieldByName` (line 6586) - External
- `Quer.FieldByName` (line 6587) - External
- `Quer.FieldByName` (line 6587) - External
- `Quer.FieldByName` (line 6588) - External
- `PlusUni.ExpoArquText` (line 6594) - Local
- `PlusUni.WS_ExecPLSAG` (line 6598) - External
- `PlusUni.AnsiDequotedStr` (line 6599) - Local
- `PlusUni.sgPos` (line 6600) - Local
- `RetoFunc.Substring` (line 6602) - External
- `PlusUni.sgPos` (line 6602) - Local
- `PlusUni.ExtractStrings` (line 6606) - Local
- `PlusUni.PChar` (line 6606) - Local
- `PlusUni.Trim` (line 6609) - Local
- `RelaPlus.VisuPDF` (line 6610) - External
- `PlusUni.FreeAndNil` (line 6612) - Local
- `PlusUni.Copy` (line 6614) - Local
- `PlusUni.sgPos` (line 6614) - Local
- `PlusUni.ExecDll_` (line 6617) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 6624) - Local
- `PlusUni.FileExists` (line 6626) - Local
- `PlusUni.ArquValiEnde` (line 6626) - Local
- `Quer.FieldByName` (line 6626) - External
- `PlusUni.msgOk` (line 6628) - Local
- `PlusUni.ArquValiEnde` (line 6628) - Local
- `Quer.FieldByName` (line 6628) - External
- `PlusUni.VeriExisCampTabe` (line 6637) - Local
- `Quer.FieldByName` (line 6639) - External
- `PlusUni.VeriExisCampTabe` (line 6640) - Local
- `Quer.FieldByName` (line 6641) - External
- `PlusUni.VeriExisCampTabe` (line 6643) - Local
- `Quer.FieldByName` (line 6645) - External
- `PlusUni.VeriExisCampTabe` (line 6646) - Local
- `Quer.FieldByName` (line 6647) - External
- `PlusUni.VeriExisCampTabe_Valo` (line 6649) - Local
- `PlusUni.FindFirst` (line 6651) - Local
- `PlusUni.ArquValiEnde` (line 6651) - Local
- `Quer.FieldByName` (line 6651) - External
- `Quer.FieldByName` (line 6651) - External
- `PlusUni.not` (line 6655) - Local
- `PlusUni.ImpoArqu` (line 6656) - Local
- `PlusUni.ArquValiEnde` (line 6656) - Local
- `Quer.FieldByName` (line 6656) - External
- `Quer.FieldByName` (line 6656) - External
- `Quer.FieldByName` (line 6656) - External
- `PlusUni.FindNext` (line 6657) - Local
- `PlusUni.FindClose` (line 6659) - Local
- `PlusUni.ImpoArqu` (line 6664) - Local
- `PlusUni.ArquValiEnde` (line 6664) - Local
- `Quer.FieldByName` (line 6664) - External
- `Quer.FieldByName` (line 6664) - External
- `Quer.FieldByName` (line 6664) - External

#### function CampPers_OB

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:7600

**Calls Made:**

- `sgClass.GetsgClass` (line 7607) - External
- `PlusUni.Assigned` (line 7608) - Local
- `PlusUni.TsgDecoratorClass` (line 7609) - Local
- `PlusUni.Assigned` (line 7613) - Local
- `Prin_D.Pro_AtualizaInfo_Wher` (line 7616) - External

#### function CampPers_EP

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:7782

**Calls Made:**

- `COPlus.CalcVenc` (line 7785) - External
- `PlusUni.NuloInte` (line 7785) - Local
- `PlusUni.CampPersExec` (line 7785) - Local
- `COPlus.GeraNovaComp` (line 7787) - External
- `Proc.ProcPrin` (line 7790) - External
- `PlusUni.SeStri` (line 7791) - Local

#### function CampPers_TR

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:7796

**Calls Made:**

- `Trig.TrigPrin` (line 7798) - External
- `PlusUni.SeStri` (line 7799) - Local

#### function CampPers_ConfWeb

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:7802

**Calls Made:**

- `GetConfWeb.SetCampPers_ConfWeb` (line 7804) - External

#### function CampPers_CompCamp_Tipo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:7808

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 7810) - Local
- `PlusUni.StrIn` (line 7831) - Local
- `PlusUni.or` (line 7833) - Local
- `PlusUni.or` (line 7833) - Local
- `PlusUni.or` (line 7833) - Local
- `PlusUni.or` (line 7834) - Local
- `PlusUni.or` (line 7834) - Local
- `PlusUni.or` (line 7834) - Local
- `PlusUni.or` (line 7835) - Local
- `PlusUni.StrIn` (line 7839) - Local

#### procedure CampPersListChecColumnClick

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:7991

**Calls Made:**

- `PlusUni.and` (line 8002) - Local
- `PlusUni.and` (line 8002) - Local
- `PlusUni.TLstLbl` (line 8004) - Local
- `PlusUni.IntToStr` (line 8008) - Local
- `PlusUni.SeInte` (line 8008) - Local

#### procedure CampPersExecNoOnShow

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8022

**Calls Made:**

- `MemVal1.Add` (line 8031) - External
- `PlusUni.CampPersExecListInst` (line 8032) - Local
- `PlusUni.sgCopy` (line 8038) - Local
- `PlusUni.sgCopy` (line 8038) - Local
- `TsgQuery.Create` (line 8043) - External
- `PlusUni.ON` (line 8046) - Local
- `PlusUni.and` (line 8046) - Local
- `PlusUni.WHERE` (line 8047) - Local
- `PlusUni.IntToStr` (line 8047) - Local
- `PlusUni.AnsiUpperCase` (line 8048) - Local
- `PlusUni.AND` (line 8051) - Local
- `PlusUni.OR` (line 8051) - Local
- `PlusUni.Assigned` (line 8056) - Local
- `PlusUni.SetPsgTrans` (line 8056) - Local
- `PlusUni.not` (line 8057) - Local
- `PlusUni.CampPersCompAtua` (line 8060) - Local
- `PlusUni.TsgLbl` (line 8072) - Local
- `PlusUni.FindComponent` (line 8072) - Local
- `PlusUni.TsgLbl` (line 8074) - Local
- `PlusUni.FindComponent` (line 8074) - Local
- `PlusUni.TsgLbl` (line 8075) - Local
- `PlusUni.FindComponent` (line 8075) - Local

#### function CampPers_BuscModi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8089

**Calls Made:**

- `PlusUni.Copy` (line 8095) - Local
- `PlusUni.VeriExisCampTabe` (line 8097) - Local
- `PlusUni.VeriExisCampTabe` (line 8097) - Local
- `PlusUni.Trim` (line 8099) - Local
- `DataSet.FieldByName` (line 8099) - External
- `DataSet.FieldByName` (line 8100) - External
- `PlusUni.Assigned` (line 8104) - Local
- `PlusUni.SetPsgTrans` (line 8104) - Local
- `PlusUni.and` (line 8106) - Local
- `PlusUni.not` (line 8108) - Local
- `PlusUni.and` (line 8108) - Local
- `PlusUni.TMemLbl` (line 8108) - Local
- `PlusUni.CampPersCompAtuaGetProp` (line 8110) - Local
- `PlusUni.msgOk` (line 8112) - Local
- `PlusUni.CampPersCompAtuaGetProp` (line 8112) - Local
- `PlusUni.inc` (line 8114) - Local
- `DataSet.FieldByName` (line 8118) - External
- `DataSet.FieldByName` (line 8118) - External

#### procedure CampPers_CriaBtn_LancCont

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8124

**Calls Made:**

- `PlusUni.Assigned` (line 8136) - Local
- `PlusUni.and` (line 8139) - Local
- `PlusUni.TDataSource` (line 8141) - Local
- `PlusUni.BuscaComponente` (line 8141) - Local
- `PlusUni.Assigned` (line 8142) - Local
- `PlusUni.TestDataSet` (line 8142) - Local
- `PlusUni.and` (line 8142) - Local
- `PlusUni.RetoZero` (line 8142) - Local
- `PlusUni.SetPsgTrans` (line 8144) - Local
- `PlusUni.TsgBtn` (line 8145) - Local
- `PlusUni.FindComponent` (line 8145) - Local
- `PlusUni.Assigned` (line 8146) - Local
- `PlusUni.TsgBtn` (line 8148) - Local
- `PlusUni.FindComponent` (line 8148) - Local
- `CampJSon.POCaTabe_Para` (line 8149) - External
- `PlusUni.Assigned` (line 8154) - Local
- `TsgBtn.Create` (line 8156) - External
- `PlusUni.Assigned` (line 8167) - Local
- `PlusUni.TFrmPOHeForm` (line 8179) - Local
- `PlusUni.Assigned` (line 8184) - Local
- `Lista.Add` (line 8187) - External
- `Lista.Add` (line 8188) - External
- `PlusUni.RetoZero` (line 8188) - Local
- `PlusUni.TDataSource` (line 8188) - Local
- `PlusUni.BuscaComponente` (line 8188) - Local
- `Lista.Add` (line 8189) - External

#### function VeriEnviConf

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8198

**Calls Made:**

- `PlusUni.CampPersExecListInst` (line 8208) - Local

#### function ConfGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8216

**Calls Made:**

- `PlusUni.and` (line 8219) - Local
- `PlusUni.Trim` (line 8219) - Local
- `PlusUni.msgOk` (line 8220) - Local
- `PlusUni.Trim` (line 8220) - Local
- `PlusUni.VeriEnviConf` (line 8221) - Local
- `PlusUni.CampPers_TratExec` (line 8221) - Local
- `PlusUni.CalcStri` (line 8221) - Local
- `PlusUni.WHERE` (line 8221) - Local
- `PlusUni.IntToStr` (line 8221) - Local
- `PlusUni.CalcStri` (line 8222) - Local
- `PlusUni.WHERE` (line 8222) - Local
- `PlusUni.IntToStr` (line 8222) - Local
- `PlusUni.GetPegaPara_ConfGrav` (line 8225) - Local
- `PlusUni.msgNao` (line 8226) - Local

#### procedure RecaDadoGera

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8231

**Calls Made:**

- `PlusUni.DeleteFiles` (line 8235) - Local
- `PlusUni.msgOk` (line 8239) - Local

#### function ListCampPOCaRela

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8242

_No outgoing calls_

#### function ChamRela

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8260

**Calls Made:**

- `PlusUni.ChamRelaUnig` (line 8263) - Local
- `PlusUni.TTipoExib` (line 8263) - Local
- `PlusUni.CalcInte` (line 8267) - Local
- `PlusUni.COUNT` (line 8267) - Local
- `PlusUni.WHERE` (line 8267) - Local
- `PlusUni.IntToStr` (line 8267) - Local
- `iQryRela.FieldByName` (line 8267) - External
- `PlusUni.ClicBotaComp` (line 8268) - Local
- `PlusUni.ClicBotaVisu` (line 8270) - Local

#### function ChamRelaEspe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8274

**Calls Made:**

- `PlusUni.ChamRelaUnig` (line 8277) - Local
- `PlusUni.TTipoExib` (line 8277) - Local
- `PlusUni.ClicBotaReEs` (line 8279) - Local
- `PlusUni.TsgForm` (line 8279) - Local

#### function POCaMvEs_DistMvCx

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8503

**Calls Made:**

- `TsgQuery.Create` (line 8514) - External
- `PlusUni.Assigned` (line 8517) - Local
- `PlusUni.TsgADOConnection` (line 8518) - Local
- `PlusUni.Assigned` (line 8519) - Local
- `PlusUni.TsgADOConnection` (line 8520) - Local
- `iQuer.FieldByName` (line 8524) - External
- `PlusUni.CalcCodi` (line 8525) - Local
- `iQuer.FieldByName` (line 8527) - External
- `PlusUni.Round` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.Nulo` (line 8532) - Local
- `PlusUni.SeStri` (line 8532) - Local
- `PlusUni.NULO` (line 8532) - Local
- `PlusUni.WHERE` (line 8535) - Local
- `PlusUni.IntToStr` (line 8535) - Local
- `PlusUni.CalcInte` (line 8538) - Local
- `PlusUni.WHERE` (line 8538) - Local
- `PlusUni.IntToStr` (line 8538) - Local
- `PlusUni.SeInte` (line 8538) - Local
- `iQuer.FieldByName` (line 8538) - External
- `PlusUni.or` (line 8540) - Local
- `iQuer.FieldByName` (line 8544) - External
- `PlusUni.or` (line 8547) - Local
- `iQuer.FieldByName` (line 8551) - External
- `PlusUni.VeriExisCampTabe` (line 8558) - Local
- `iQuer.FieldByName` (line 8559) - External
- `PlusUni.POCaMvCx_Dist` (line 8563) - Local
- `iQuer.FieldByName` (line 8563) - External
- `iQuer.FieldByName` (line 8563) - External
- `PlusUni.SeInte` (line 8564) - Local
- `iQuer.FieldByName` (line 8564) - External
- `PlusUni.SeInte` (line 8565) - Local
- `iQuer.FieldByName` (line 8565) - External
- `iQuer.FieldByName` (line 8566) - External
- `iQuer.FieldByName` (line 8566) - External
- `iQuer.FieldByName` (line 8567) - External
- `iQuer.FieldByName` (line 8567) - External
- `PlusUni.WHERE` (line 8569) - Local
- `PlusUni.IntToStr` (line 8569) - Local
- `iQuer.FieldByName` (line 8571) - External
- `PlusUni.msgOk` (line 8572) - Local
- `PlusUni.Custos` (line 8572) - Local
- `PlusUni.FormInteBras` (line 8572) - Local

#### function POCaMvNo_DistMvCx

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8580

**Calls Made:**

- `TsgQuery.Create` (line 8591) - External
- `PlusUni.Assigned` (line 8594) - Local
- `PlusUni.TsgADOConnection` (line 8595) - Local
- `PlusUni.Assigned` (line 8596) - Local
- `PlusUni.TsgADOConnection` (line 8597) - Local
- `iQuer.FieldByName` (line 8601) - External
- `PlusUni.CalcCodi` (line 8602) - Local
- `iQuer.FieldByName` (line 8604) - External
- `PlusUni.Round` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.Nulo` (line 8610) - Local
- `PlusUni.SeStri` (line 8611) - Local
- `PlusUni.Nulo` (line 8611) - Local
- `PlusUni.IntToStr` (line 8615) - Local
- `PlusUni.CalcInte` (line 8618) - Local
- `PlusUni.WHERE` (line 8618) - Local
- `PlusUni.IntToStr` (line 8618) - Local
- `PlusUni.SeInte` (line 8618) - Local
- `iQuer.FieldByName` (line 8618) - External
- `PlusUni.or` (line 8620) - Local
- `iQuer.FieldByName` (line 8624) - External
- `PlusUni.or` (line 8627) - Local
- `iQuer.FieldByName` (line 8631) - External
- `PlusUni.VeriExisCampTabe` (line 8638) - Local
- `iQuer.FieldByName` (line 8639) - External
- `PlusUni.POCaMvCx_Dist` (line 8643) - Local
- `iQuer.FieldByName` (line 8643) - External
- `iQuer.FieldByName` (line 8643) - External
- `PlusUni.SeInte` (line 8644) - Local
- `iQuer.FieldByName` (line 8644) - External
- `PlusUni.SeInte` (line 8645) - Local
- `iQuer.FieldByName` (line 8645) - External
- `iQuer.FieldByName` (line 8646) - External
- `iQuer.FieldByName` (line 8646) - External
- `iQuer.FieldByName` (line 8647) - External
- `iQuer.FieldByName` (line 8647) - External
- `PlusUni.WHERE` (line 8649) - Local
- `PlusUni.IntToStr` (line 8649) - Local
- `iQuer.FieldByName` (line 8651) - External
- `PlusUni.msgOk` (line 8652) - Local
- `PlusUni.Custos` (line 8652) - Local
- `PlusUni.FormInteBras` (line 8652) - Local

#### function POCaFina_DistMvCx

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8659

**Calls Made:**

- `PlusUni.Assigned` (line 8670) - Local
- `PlusUni.TsgADOConnection` (line 8671) - Local
- `PlusUni.Assigned` (line 8672) - Local
- `PlusUni.TsgADOConnection` (line 8673) - Local
- `iQuer.FieldByName` (line 8677) - External
- `Application.CreateForm` (line 8680) - External
- `PlusUni.CalcReal` (line 8689) - Local
- `PlusUni.SUM` (line 8689) - Local
- `PlusUni.IntToStr` (line 8689) - Local
- `iQuer.FieldByName` (line 8689) - External
- `PlusUni.RegiEm__List` (line 8690) - Local
- `PlusUni.IntToStr` (line 8692) - Local
- `iQuer.FieldByName` (line 8692) - External
- `PlusUni.COUNT` (line 8693) - Local
- `PlusUni.AND` (line 8693) - Local
- `PlusUni.AS` (line 8700) - Local
- `PlusUni.FormNumeSQL` (line 8703) - Local
- `PlusUni.SUM` (line 8711) - Local
- `PlusUni.OVER` (line 8711) - Local
- `PlusUni.SUM` (line 8712) - Local
- `PlusUni.OVER` (line 8712) - Local
- `PlusUni.IN` (line 8714) - Local
- `PlusUni.RetoZero` (line 8714) - Local
- `PlusUni.ROUND` (line 8721) - Local
- `DBO.DIVEZERO` (line 8721) - External
- `PlusUni.ROUND` (line 8722) - Local
- `DBO.DIVEZERO` (line 8722) - External
- `DbgGridView.ApplyBestFit` (line 8732) - External
- `PlusUni.FreeAndNil` (line 8736) - Local

#### function POCaCaix_DistMvCx

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:8824

**Calls Made:**

- `PlusUni.Assigned` (line 8836) - Local
- `PlusUni.TsgADOConnection` (line 8837) - Local
- `PlusUni.Assigned` (line 8838) - Local
- `PlusUni.TsgADOConnection` (line 8839) - Local
- `iQuer.FieldByName` (line 8845) - External
- `PlusUni.and` (line 8845) - Local
- `iQuer.FieldByName` (line 8845) - External
- `PlusUni.CalcInte` (line 8847) - Local
- `PlusUni.IntToStr` (line 8847) - Local
- `iQuer.FieldByName` (line 8847) - External
- `PlusUni.CalcStri` (line 8848) - Local
- `PlusUni.IntToStr` (line 8849) - Local
- `Application.CreateForm` (line 8855) - External
- `PlusUni.RegiEm__List` (line 8864) - Local
- `PlusUni.IntToStr` (line 8866) - Local
- `PlusUni.COUNT` (line 8867) - Local
- `PlusUni.AND` (line 8867) - Local
- `PlusUni.AS` (line 8874) - Local
- `PlusUni.FormNumeSQL` (line 8877) - Local
- `iQuer.FieldByName` (line 8877) - External
- `PlusUni.SUM` (line 8885) - Local
- `PlusUni.OVER` (line 8885) - Local
- `PlusUni.SUM` (line 8886) - Local
- `PlusUni.OVER` (line 8886) - Local
- `PlusUni.IN` (line 8888) - Local
- `PlusUni.RetoZero` (line 8888) - Local
- `PlusUni.ROUND` (line 8895) - Local
- `DBO.DIVEZERO` (line 8895) - External
- `PlusUni.ROUND` (line 8896) - Local
- `DBO.DIVEZERO` (line 8896) - External
- `DbgGridView.ApplyBestFit` (line 8906) - External
- `PlusUni.FreeAndNil` (line 8910) - Local

#### function POCaUnFi_DistMvCx

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9014

**Calls Made:**

- `PlusUni.Assigned` (line 9022) - Local
- `PlusUni.TsgADOConnection` (line 9023) - Local
- `PlusUni.Assigned` (line 9024) - Local
- `PlusUni.TsgADOConnection` (line 9025) - Local
- `Application.CreateForm` (line 9030) - External
- `PlusUni.CalcReal` (line 9039) - Local
- `PlusUni.SUM` (line 9039) - Local
- `PlusUni.IntToStr` (line 9039) - Local
- `iQuer.FieldByName` (line 9039) - External
- `PlusUni.CalcReal` (line 9040) - Local
- `PlusUni.SUM` (line 9040) - Local
- `PlusUni.IntToStr` (line 9040) - Local
- `iQuer.FieldByName` (line 9040) - External
- `PlusUni.AS` (line 9044) - Local
- `PlusUni.and` (line 9045) - Local
- `TsgQuery.Create` (line 9048) - External
- `PlusUni.IntToStr` (line 9053) - Local
- `iQuer.FieldByName` (line 9053) - External
- `PlusUni.RegiEm__List` (line 9057) - Local
- `PlusUni.IntToStr` (line 9059) - Local
- `PlusUni.COUNT` (line 9060) - Local
- `PlusUni.AND` (line 9060) - Local
- `PlusUni.FormNumeSQL` (line 9066) - Local
- `PlusUni.SUM` (line 9074) - Local
- `PlusUni.OVER` (line 9074) - Local
- `PlusUni.SUM` (line 9075) - Local
- `PlusUni.OVER` (line 9075) - Local
- `PlusUni.RetoZero` (line 9082) - Local
- `PlusUni.Abs` (line 9093) - Local
- `PlusUni.Abs` (line 9093) - Local
- `PlusUni.RegiEm__List` (line 9095) - Local
- `PlusUni.IntToStr` (line 9097) - Local
- `iQuer.FieldByName` (line 9097) - External
- `PlusUni.COUNT` (line 9098) - Local
- `PlusUni.AND` (line 9098) - Local
- `PlusUni.sgPos` (line 9102) - Local
- `PlusUni.FormNumeSQL` (line 9106) - Local
- `PlusUni.SUM` (line 9114) - Local
- `PlusUni.OVER` (line 9114) - Local
- `PlusUni.SUM` (line 9115) - Local
- `PlusUni.OVER` (line 9115) - Local
- `PlusUni.IN` (line 9119) - Local
- `PlusUni.RetoZero` (line 9119) - Local
- `PlusUni.ROUND` (line 9127) - Local
- `DBO.DIVEZERO` (line 9127) - External
- `PlusUni.ROUND` (line 9128) - Local
- `DBO.DIVEZERO` (line 9128) - External

#### procedure Devo_DistQtde_InseTota

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9195

**Calls Made:**

- `PlusUni.InseIntoTabe` (line 9197) - Local
- `PlusUni.IntToStr` (line 9198) - Local
- `PlusUni.WHERE` (line 9203) - Local
- `PlusUni.IntToStr` (line 9203) - Local
- `PlusUni.AND` (line 9204) - Local
- `PlusUni.AND` (line 9204) - Local
- `PlusUni.InseIntoTabe` (line 9206) - Local
- `PlusUni.IntToStr` (line 9207) - Local
- `PlusUni.WHERE` (line 9212) - Local
- `PlusUni.IntToStr` (line 9212) - Local
- `PlusUni.AND` (line 9213) - Local
- `PlusUni.AND` (line 9213) - Local

#### procedure Versao_EnviTela

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9243

**Calls Made:**

- `PlusUni.Versao_EnviTela_Inse` (line 9248) - Local
- `PlusUni.Banc_ListCampTabe` (line 9252) - Local
- `PlusUni.ExecSQL_` (line 9253) - Local
- `PlusUni.RetoVers` (line 9260) - Local
- `PlusUni.InputQuery` (line 9261) - Local
- `PlusUni.ExecSQL_` (line 9263) - Local
- `PlusUni.QuotedStr` (line 9263) - Local
- `PlusUni.GetQry` (line 9265) - Local
- `TsgQuery.Create` (line 9266) - External
- `TsgQuery.Create` (line 9267) - External
- `PlusUni.GetQry` (line 9271) - Local
- `PlusUni.IntToStr` (line 9274) - Local
- `PlusUni.IN` (line 9275) - Local
- `PlusUni.IntToStr` (line 9275) - Local
- `PlusUni.COUNT` (line 9276) - Local
- `PlusUni.IntToStr` (line 9276) - Local
- `PlusUni.ExibProgPrin` (line 9279) - Local
- `PlusUni.ExibProgPrin` (line 9282) - Local
- `PlusUni.FormInteBras` (line 9282) - Local
- `PlusUni.ExecSQL_` (line 9284) - Local
- `PlusUni.IntToStr` (line 9284) - Local
- `PlusUni.ExecSQL_` (line 9285) - Local
- `PlusUni.IntToStr` (line 9285) - Local
- `PlusUni.ExecSQL_` (line 9286) - Local
- `PlusUni.IntToStr` (line 9286) - Local
- `PlusUni.ExecSQL_` (line 9287) - Local
- `PlusUni.IntToStr` (line 9287) - Local
- `PlusUni.ExecSQL_` (line 9288) - Local
- `PlusUni.IntToStr` (line 9288) - Local
- `PlusUni.ExecSQL_` (line 9289) - Local
- `PlusUni.IntToStr` (line 9289) - Local
- `PlusUni.ExecSQL_` (line 9290) - Local
- `PlusUni.IntToStr` (line 9290) - Local
- `PlusUni.ExecSQL_` (line 9291) - Local
- `PlusUni.COUNT` (line 9291) - Local
- `PlusUni.IntToStr` (line 9291) - Local
- `PlusUni.ExecSQL_` (line 9293) - Local
- `PlusUni.IntToStr` (line 9293) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9295) - Local
- `PlusUni.IntToStr` (line 9295) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9296) - Local
- `PlusUni.IntToStr` (line 9296) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9297) - Local
- `PlusUni.IntToStr` (line 9297) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9298) - Local
- `PlusUni.IntToStr` (line 9298) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9299) - Local
- `PlusUni.IntToStr` (line 9299) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9300) - Local
- `PlusUni.IntToStr` (line 9300) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9301) - Local
- `PlusUni.COUNT` (line 9301) - Local
- `PlusUni.IntToStr` (line 9301) - Local
- `PlusUni.Versao_EnviTela_Inse` (line 9303) - Local
- `PlusUni.IntToStr` (line 9303) - Local
- `PlusUni.ExecSQL_` (line 9305) - Local
- `PlusUni.SIBKTABE_ST` (line 9305) - Local
- `PlusUni.VALUES` (line 9305) - Local
- `PlusUni.IntToStr` (line 9305) - Local
- `PlusUni.GetQry` (line 9307) - Local
- `PlusUni.IntToStr` (line 9310) - Local
- `PlusUni.Versao_EnviTela` (line 9315) - Local
- `PlusUni.IntToStr` (line 9315) - Local

#### procedure Versao_EnviTela_Inse

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9248

**Calls Made:**

- `PlusUni.Banc_ListCampTabe` (line 9252) - Local
- `PlusUni.ExecSQL_` (line 9253) - Local

#### function EditTabeCabeCamp

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9338

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 9342) - Local
- `PlusUni.AnsiUpperCase` (line 9343) - Local
- `PlusUni.and` (line 9346) - Local
- `Data.FieldByName` (line 9347) - External

#### function EditTabeCabe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9374

**Calls Made:**

- `PlusUni.EditTabeCabeCamp` (line 9376) - Local
- `PlusUni.Copy` (line 9376) - Local

#### function EditTabeCabeCodi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9380

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 9384) - Local
- `PlusUni.AnsiUpperCase` (line 9385) - Local
- `PlusUni.Copy` (line 9385) - Local
- `PlusUni.WHERE` (line 9395) - Local
- `PlusUni.IntToStr` (line 9395) - Local
- `PlusUni.CalcCodi` (line 9395) - Local
- `PlusUni.WHERE` (line 9397) - Local
- `PlusUni.IntToStr` (line 9397) - Local

#### function MensConf

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9410

**Calls Made:**

- `PlusUni.SubsPala` (line 9413) - Local
- `PlusUni.IsRx9` (line 9414) - Local
- `PlusUni.SubsPalaTudo` (line 9416) - Local
- `PlusUni.GetPNomAbreSoft` (line 9416) - Local
- `PlusUni.SubsPalaTudo` (line 9417) - Local
- `PlusUni.GetPNomAbreSoft` (line 9417) - Local
- `PlusUni.SubsPalaTudo` (line 9418) - Local
- `PlusUni.GetPNomAbreSoft` (line 9418) - Local
- `PlusUni.SubsPalaTudo` (line 9419) - Local
- `PlusUni.GetPNomAbreSoft` (line 9419) - Local
- `PlusUni.SubsPalaTudo` (line 9420) - Local
- `PlusUni.GetPNomAbreSoft` (line 9420) - Local
- `Application.CreateForm` (line 9427) - External
- `PlusUni.SubsPala` (line 9433) - Local
- `PlusUni.SubsPala` (line 9439) - Local
- `PlusUni.SubsPala` (line 9442) - Local
- `PlusUni.SubsPala` (line 9448) - Local
- `PlusUni.SubsPala` (line 9451) - Local
- `PlusUni.SubsPala` (line 9454) - Local

#### function Cancela

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9462

**Calls Made:**

- `GauAgua.AddProgress` (line 9471) - External
- `PlusUni.StrToInt` (line 9488) - Local
- `PlusUni.FormatDateTime` (line 9488) - Local
- `PlusUni.and` (line 9488) - Local
- `PlusUni.StrToInt` (line 9488) - Local
- `PlusUni.FormatDateTime` (line 9488) - Local
- `PlusUni.StrToInt` (line 9491) - Local
- `PlusUni.FormatDateTime` (line 9491) - Local
- `PlusUni.DiveZero` (line 9492) - Local
- `PlusUni.StrToInt` (line 9493) - Local
- `PlusUni.FormatDateTime` (line 9493) - Local
- `PlusUni.StrToInt` (line 9494) - Local
- `PlusUni.FormatDateTime` (line 9494) - Local
- `PlusUni.StrToInt` (line 9495) - Local
- `PlusUni.FormatDateTime` (line 9495) - Local
- `PlusUni.FormInteBras` (line 9502) - Local
- `PlusUni.SeStri` (line 9502) - Local
- `PlusUni.SeStri` (line 9503) - Local
- `PlusUni.FormInteBras` (line 9503) - Local
- `PlusUni.SeStri` (line 9503) - Local
- `PlusUni.FormInteBras` (line 9506) - Local
- `PlusUni.SeStri` (line 9506) - Local
- `PlusUni.FormInteBras` (line 9510) - Local
- `PlusUni.SeStri` (line 9510) - Local
- `PlusUni.SeStri` (line 9511) - Local
- `PlusUni.FormInteBras` (line 9511) - Local
- `PlusUni.SeStri` (line 9511) - Local
- `PlusUni.FormInteBras` (line 9516) - Local
- `PlusUni.SeStri` (line 9516) - Local
- `PlusUni.SeStri` (line 9517) - Local
- `PlusUni.FormInteBras` (line 9517) - Local
- `PlusUni.SeStri` (line 9517) - Local
- `PlusUni.and` (line 9519) - Local
- `PlusUni.FormInteBras` (line 9524) - Local
- `PlusUni.FormMascNume` (line 9530) - Local
- `PlusUni.FormMascNume` (line 9530) - Local
- `PlusUni.FormatDateTime` (line 9534) - Local
- `GauAgua.AddProgress` (line 9551) - External
- `PlusUni.StrToInt` (line 9568) - Local
- `PlusUni.FormatDateTime` (line 9568) - Local
- `PlusUni.and` (line 9568) - Local
- `PlusUni.StrToInt` (line 9568) - Local
- `PlusUni.FormatDateTime` (line 9568) - Local
- `PlusUni.StrToInt` (line 9571) - Local
- `PlusUni.FormatDateTime` (line 9571) - Local
- `PlusUni.DiveZero` (line 9572) - Local
- `PlusUni.StrToInt` (line 9573) - Local
- `PlusUni.FormatDateTime` (line 9573) - Local
- `PlusUni.StrToInt` (line 9574) - Local
- `PlusUni.FormatDateTime` (line 9574) - Local
- `PlusUni.StrToInt` (line 9575) - Local
- `PlusUni.FormatDateTime` (line 9575) - Local
- `PlusUni.FormInteBras` (line 9582) - Local
- `PlusUni.SeStri` (line 9582) - Local
- `PlusUni.SeStri` (line 9583) - Local
- `PlusUni.FormInteBras` (line 9583) - Local
- `PlusUni.SeStri` (line 9583) - Local
- `PlusUni.FormInteBras` (line 9586) - Local
- `PlusUni.SeStri` (line 9586) - Local
- `PlusUni.FormInteBras` (line 9590) - Local
- `PlusUni.SeStri` (line 9590) - Local
- `PlusUni.SeStri` (line 9591) - Local
- `PlusUni.FormInteBras` (line 9591) - Local
- `PlusUni.SeStri` (line 9591) - Local
- `PlusUni.FormInteBras` (line 9596) - Local
- `PlusUni.SeStri` (line 9596) - Local
- `PlusUni.SeStri` (line 9597) - Local
- `PlusUni.FormInteBras` (line 9597) - Local
- `PlusUni.SeStri` (line 9597) - Local
- `PlusUni.and` (line 9599) - Local
- `PlusUni.FormInteBras` (line 9604) - Local
- `PlusUni.FormMascNume` (line 9610) - Local
- `PlusUni.FormMascNume` (line 9610) - Local
- `PlusUni.FormatDateTime` (line 9614) - Local

#### function ChamModa

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9624

**Calls Made:**

- `PlusUni.GetPTab` (line 9629) - Local
- `PlusUni.isDigit` (line 9632) - Local
- `PlusUni.SetPTab` (line 9633) - Local
- `PlusUni.StrToInt` (line 9633) - Local
- `PlusUni.AnsiUpperCase` (line 9636) - Local
- `PlusUni.Copy` (line 9636) - Local
- `PlusUni.SetPTab` (line 9638) - Local
- `PlusUni.StrToInt` (line 9638) - Local
- `PlusUni.RetoZero` (line 9638) - Local
- `DtmPoul.Tabelas_Busc` (line 9638) - External
- `PlusUni.QuotedStr` (line 9638) - Local
- `PlusUni.AnsiUpperCase` (line 9638) - Local
- `PlusUni.Copy` (line 9642) - Local
- `PlusUni.Length` (line 9642) - Local
- `DtmPoul.Tabelas_Busc` (line 9644) - External
- `PlusUni.IntToStr` (line 9644) - Local
- `PlusUni.TsgFormClass` (line 9645) - Local
- `PlusUni.FindClass` (line 9645) - Local
- `PlusUni.Create` (line 9645) - Local
- `PlusUni.sgCopy` (line 9647) - Local
- `PlusUni.Copy` (line 9648) - Local
- `PlusUni.IntToStr` (line 9648) - Local
- `PlusUni.GetPTab` (line 9648) - Local
- `PlusUni.GetPTab` (line 9649) - Local
- `PlusUni.GravContPOCaTabe` (line 9654) - Local
- `PlusUni.GetPTab` (line 9654) - Local
- `PlusUni.GetPTab` (line 9656) - Local
- `PlusUni.Trim` (line 9658) - Local
- `Result.AddMsg2` (line 9665) - External
- `Result.AddMsg2` (line 9667) - External
- `PlusUni.SetPTab` (line 9671) - Local

#### function VeriAlteSenhVenc

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9675

**Calls Made:**

- `PlusUni.msgSim` (line 9685) - Local
- `PlusUni.ChamModa` (line 9687) - Local
- `Result.AddMsg2` (line 9688) - External
- `Result.AddMsg2` (line 9690) - External
- `Result.AddMsg2` (line 9693) - External
- `Result.AddMsg2` (line 9696) - External
- `PlusUni.FormInteBras` (line 9705) - Local
- `PlusUni.MensConf` (line 9709) - Local
- `PlusUni.ChamModa` (line 9710) - Local

#### function VeriAcesEmpr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9723

**Calls Made:**

- `PlusUni.CalcInte` (line 9725) - Local
- `PlusUni.COUNT` (line 9725) - Local
- `PlusUni.WHERE` (line 9725) - Local
- `PlusUni.IntToStr` (line 9725) - Local

#### function VeriAcesModu

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9729

**Calls Made:**

- `PlusUni.CalcInte` (line 9734) - Local
- `PlusUni.COUNT` (line 9734) - Local
- `PlusUni.WHERE` (line 9734) - Local
- `PlusUni.IntToStr` (line 9734) - Local

#### function CarrAcesModu

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9739

**Calls Made:**

- `PlusUni.WHERE` (line 9746) - Local
- `PlusUni.WHERE` (line 9748) - Local
- `LcbProd.SetNovoValor_Query` (line 9757) - External

#### procedure LimpMoniDataModu

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9831

**Calls Made:**

- `PlusUni.to` (line 9839) - Local
- `PlusUni.TsgQuery` (line 9842) - Local

#### procedure LimpMoniGera

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9848

**Calls Made:**

- `PlusUni.LimpMoniDataModu` (line 9852) - Local
- `PlusUni.Assigned` (line 9855) - Local
- `PlusUni.SetPsgTrans` (line 9855) - Local
- `PlusUni.to` (line 9856) - Local
- `PlusUni.TsgADOConnection` (line 9859) - Local
- `PlusUni.TsgQuery` (line 9861) - Local
- `PlusUni.AnsiUpperCase` (line 9862) - Local
- `PlusUni.TDataSource` (line 9863) - Local
- `PlusUni.TDataSource` (line 9864) - Local
- `PlusUni.TsgQuery` (line 9865) - Local
- `PlusUni.TDataSource` (line 9865) - Local

#### procedure FechQuerTela

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9872

**Calls Made:**

- `PlusUni.Assigned` (line 9880) - Local
- `PlusUni.SetPsgTrans` (line 9880) - Local
- `PlusUni.to` (line 9881) - Local
- `PlusUni.TsgQuery` (line 9885) - Local
- `PlusUni.TestDataSet` (line 9890) - Local

#### function VeriSexo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9906

**Calls Made:**

- `PlusUni.Pos` (line 9910) - Local
- `PlusUni.Copy` (line 9911) - Local
- `PlusUni.Pos` (line 9911) - Local
- `PlusUni.Copy` (line 9913) - Local
- `PlusUni.Length` (line 9913) - Local
- `PlusUni.AnsiUpperCase` (line 9914) - Local
- `PlusUni.or` (line 9915) - Local

#### function NomeDupl

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9921

**Calls Made:**

- `PlusUni.msgNao` (line 9932) - Local

#### function SobrNome

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9937

**Calls Made:**

- `PlusUni.Length` (line 9942) - Local
- `PlusUni.Pos` (line 9944) - Local
- `PlusUni.Copy` (line 9945) - Local
- `PlusUni.Pos` (line 9945) - Local
- `PlusUni.Length` (line 9949) - Local

#### function TabeVazi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9954

_No outgoing calls_

#### procedure OrgaSele

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9966

**Calls Made:**

- `PlusUni.IdenCamp` (line 9972) - Local
- `PlusUni.AnsiUpperCase` (line 10018) - Local
- `PlusUni.Copy` (line 10018) - Local
- `PlusUni.Length` (line 10018) - Local
- `PlusUni.Pos` (line 10019) - Local
- `PlusUni.IdenCamp` (line 10023) - Local
- `PlusUni.Copy` (line 10023) - Local
- `PlusUni.Delete` (line 10024) - Local
- `PlusUni.Replicate` (line 10025) - Local
- `PlusUni.Trim` (line 10025) - Local
- `PlusUni.Inc` (line 10030) - Local
- `PlusUni.Trim` (line 10033) - Local
- `iRchSele.Add` (line 10034) - External
- `PlusUni.AnsiUpperCase` (line 10040) - Local
- `PlusUni.Copy` (line 10040) - Local
- `PlusUni.Trim` (line 10040) - Local
- `iRchSele.Add` (line 10042) - External
- `PlusUni.Copy` (line 10042) - Local
- `PlusUni.Pos` (line 10042) - Local
- `PlusUni.Copy` (line 10043) - Local
- `PlusUni.Pos` (line 10043) - Local
- `PlusUni.Length` (line 10043) - Local
- `iRchSele.Add` (line 10044) - External
- `PlusUni.OrgaSQL` (line 10044) - Local
- `PlusUni.OrgaSele` (line 10046) - Local
- `iRchSele.Delete` (line 10049) - External
- `iRchSele.Insert` (line 10050) - External
- `PlusUni.Copy` (line 10051) - Local
- `PlusUni.Pos` (line 10051) - Local
- `PlusUni.AnsiUpperCase` (line 10051) - Local
- `PlusUni.Copy` (line 10052) - Local
- `PlusUni.Pos` (line 10052) - Local
- `PlusUni.AnsiUpperCase` (line 10052) - Local
- `iRchSele.Add` (line 10053) - External

#### function IdenCamp

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:9972

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 10018) - Local
- `PlusUni.Copy` (line 10018) - Local
- `PlusUni.Length` (line 10018) - Local
- `PlusUni.Pos` (line 10019) - Local
- `PlusUni.IdenCamp` (line 10023) - Local
- `PlusUni.Copy` (line 10023) - Local
- `PlusUni.Delete` (line 10024) - Local
- `PlusUni.Replicate` (line 10025) - Local
- `PlusUni.Trim` (line 10025) - Local
- `PlusUni.Inc` (line 10030) - Local

#### procedure OrgaFrom

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10079

**Calls Made:**

- `PlusUni.Length` (line 10086) - Local
- `PlusUni.Pos` (line 10088) - Local
- `PlusUni.AnsiUpperCase` (line 10088) - Local
- `PlusUni.Pos` (line 10089) - Local
- `PlusUni.AnsiUpperCase` (line 10089) - Local
- `PlusUni.Pos` (line 10090) - Local
- `PlusUni.AnsiUpperCase` (line 10090) - Local
- `PlusUni.Pos` (line 10091) - Local
- `PlusUni.AnsiUpperCase` (line 10091) - Local
- `PlusUni.and` (line 10098) - Local
- `PlusUni.and` (line 10101) - Local
- `PlusUni.and` (line 10104) - Local
- `iRchFrom.Add` (line 10107) - External
- `PlusUni.Trim` (line 10107) - Local
- `PlusUni.Copy` (line 10107) - Local
- `PlusUni.Delete` (line 10108) - Local
- `PlusUni.vazio` (line 10109) - Local
- `PlusUni.Length` (line 10109) - Local
- `iRchFrom.Add` (line 10113) - External
- `PlusUni.Trim` (line 10113) - Local
- `PlusUni.Length` (line 10114) - Local

#### function ExisUsua

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10120

**Calls Made:**

- `PlusUni.WHERE` (line 10126) - Local
- `PlusUni.AND` (line 10126) - Local
- `PlusUni.IntToStr` (line 10126) - Local
- `PlusUni.GetPUsu` (line 10126) - Local
- `PlusUni.not` (line 10128) - Local
- `PlusUni.Usuário` (line 10130) - Local
- `PlusUni.not` (line 10131) - Local
- `PlusUni.FieldByName` (line 10133) - Local

#### function PegaAvia

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10141

**Calls Made:**

- `PlusUni.PalaContem` (line 10146) - Local
- `PlusUni.SubsPalaTudo` (line 10147) - Local
- `PlusUni.IN` (line 10149) - Local
- `PlusUni.AND` (line 10163) - Local
- `PlusUni.AND` (line 10163) - Local
- `PlusUni.MAX` (line 10163) - Local
- `PlusUni.WHERE` (line 10163) - Local
- `PlusUni.not` (line 10167) - Local

#### function PegaAvRe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10180

**Calls Made:**

- `PlusUni.WHERE` (line 10188) - Local
- `PlusUni.IN` (line 10188) - Local
- `PlusUni.AND` (line 10188) - Local
- `PlusUni.MIN` (line 10188) - Local
- `PlusUni.WHERE` (line 10188) - Local
- `PlusUni.not` (line 10192) - Local
- `PlusUni.FieldByName` (line 10195) - Local
- `PlusUni.FieldByName` (line 10197) - Local

#### function PegaInte

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10205

**Calls Made:**

- `PlusUni.ON` (line 10212) - Local
- `PlusUni.AND` (line 10212) - Local
- `PlusUni.WHERE` (line 10213) - Local
- `PlusUni.IN` (line 10213) - Local
- `PlusUni.AND` (line 10213) - Local
- `PlusUni.AND` (line 10213) - Local
- `PlusUni.not` (line 10217) - Local
- `PlusUni.FieldByName` (line 10220) - Local
- `PlusUni.FieldByName` (line 10222) - Local

#### function MaioIdad

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10230

**Calls Made:**

- `PlusUni.CalcReal` (line 10232) - Local
- `PlusUni.MAX` (line 10232) - Local
- `PlusUni.WHERE` (line 10232) - Local
- `PlusUni.IN` (line 10232) - Local
- `PlusUni.AND` (line 10232) - Local
- `PlusUni.FormDataSQL` (line 10232) - Local
- `PlusUni.or` (line 10233) - Local
- `PlusUni.CalcReal` (line 10234) - Local
- `PlusUni.MAX` (line 10234) - Local
- `PlusUni.WHERE` (line 10234) - Local
- `PlusUni.IN` (line 10234) - Local
- `PlusUni.AND` (line 10234) - Local
- `PlusUni.FormDataSQL` (line 10234) - Local

#### function ArreIdadPesa

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10239

**Calls Made:**

- `PlusUni.and` (line 10241) - Local
- `PlusUni.Frac` (line 10241) - Local
- `PlusUni.Trunc` (line 10242) - Local
- `PlusUni.MudaReal` (line 10245) - Local

#### function IdadEnce

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10249

**Calls Made:**

- `PlusUni.IdadLote` (line 10251) - Local
- `PlusUni.CalcData` (line 10251) - Local
- `PlusUni.MIN` (line 10251) - Local
- `PlusUni.WHERE` (line 10251) - Local
- `PlusUni.IN` (line 10251) - Local
- `PlusUni.CalcData` (line 10251) - Local
- `PlusUni.MAX` (line 10251) - Local
- `PlusUni.WHERE` (line 10251) - Local
- `PlusUni.IN` (line 10251) - Local

#### function DataCole

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10265

**Calls Made:**

- `PlusUni.FormatFloat` (line 10273) - Local
- `PlusUni.Int` (line 10273) - Local
- `PlusUni.FormatFloat` (line 10274) - Local
- `PlusUni.FormatFloat` (line 10276) - Local
- `PlusUni.FormatFloat` (line 10278) - Local
- `PlusUni.FormatFloat` (line 10280) - Local
- `PlusUni.FormatFloat` (line 10282) - Local
- `PlusUni.FormatFloat` (line 10284) - Local
- `PlusUni.FormatFloat` (line 10286) - Local
- `PlusUni.INT` (line 10288) - Local

#### function PercLivr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10340

**Calls Made:**

- `PlusUni.DiskFree` (line 10344) - Local
- `PlusUni.DiskSize` (line 10345) - Local

#### function GeraPega

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10351

**Calls Made:**

- `PlusUni.DayOfWeek` (line 10357) - Local
- `PlusUni.FormatDateTime` (line 10358) - Local
- `PlusUni.StrToInt` (line 10360) - Local
- `PlusUni.Copy` (line 10360) - Local
- `PlusUni.IntToStr` (line 10361) - Local
- `PlusUni.Copy` (line 10362) - Local

#### function PessGran

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10366

**Calls Made:**

- `PlusUni.WHERE` (line 10376) - Local
- `PlusUni.RetoZero` (line 10376) - Local
- `PlusUni.AND` (line 10376) - Local
- `PlusUni.MAX` (line 10376) - Local
- `PlusUni.RetoZero` (line 10376) - Local

#### function FuncDaGr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10394

**Calls Made:**

- `PlusUni.WHERE` (line 10404) - Local
- `PlusUni.AND` (line 10404) - Local
- `PlusUni.FormDataSQL` (line 10404) - Local

#### function FuncIncu

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10422

**Calls Made:**

- `PlusUni.WHERE` (line 10432) - Local
- `PlusUni.AND` (line 10432) - Local
- `PlusUni.MAX` (line 10432) - Local

#### function FuncDaIn

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10450

**Calls Made:**

- `PlusUni.WHERE` (line 10460) - Local
- `PlusUni.AND` (line 10460) - Local
- `PlusUni.FormDataSQL` (line 10460) - Local
- `PlusUni.TrocVirg` (line 10471) - Local

#### function Sair

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10743

**Calls Made:**

- `PlusUni.GetPBasTC` (line 10745) - Local
- `PlusUni.msgSim` (line 10745) - Local

#### function PegaSobr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10749

**Calls Made:**

- `PlusUni.Length` (line 10755) - Local
- `PlusUni.Pos` (line 10758) - Local
- `PlusUni.Copy` (line 10760) - Local
- `PlusUni.Pos` (line 10760) - Local
- `PlusUni.Length` (line 10763) - Local

#### procedure TranGraf

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10772

**Calls Made:**

- `PlusUni.WHERE` (line 10777) - Local
- `PlusUni.IntToStr` (line 10777) - Local
- `PlusUni.Length` (line 10777) - Local
- `PlusUni.QuotedStr` (line 10777) - Local
- `PlusUni.AnsiUpperCase` (line 10777) - Local
- `PlusUni.not` (line 10779) - Local
- `PlusUni.msgNao` (line 10781) - Local
- `PlusUni.IntToStr` (line 10781) - Local
- `PlusUni.gráfico` (line 10781) - Local
- `PlusUni.not` (line 10783) - Local
- `PlusUni.ExecSQL_` (line 10785) - Local
- `PlusUni.WHERE` (line 10785) - Local
- `PlusUni.RetoZero` (line 10785) - Local
- `PlusUni.ExecSQL_` (line 10788) - Local
- `PlusUni.WHERE` (line 10788) - Local
- `PlusUni.IntToStr` (line 10788) - Local
- `PlusUni.Length` (line 10788) - Local
- `PlusUni.QuotedStr` (line 10788) - Local
- `PlusUni.AnsiUpperCase` (line 10788) - Local
- `Application.CreateForm` (line 10792) - External
- `PlusUni.WHERE` (line 10797) - Local
- `PlusUni.IntToStr` (line 10797) - Local
- `PlusUni.Length` (line 10797) - Local
- `PlusUni.QuotedStr` (line 10797) - Local
- `PlusUni.AnsiUpperCase` (line 10797) - Local
- `PlusUni.WHERE` (line 10802) - Local
- `PlusUni.WHERE` (line 10806) - Local
- `PlusUni.not` (line 10809) - Local
- `PlusUni.GravRegi` (line 10812) - Local
- `PlusUni.SubsPala` (line 10813) - Local
- `PlusUni.SubsPala` (line 10814) - Local
- `PlusUni.TratErroBanc` (line 10815) - Local
- `PlusUni.RetoZero` (line 10820) - Local
- `PlusUni.not` (line 10823) - Local
- `PlusUni.GravRegi` (line 10826) - Local
- `PlusUni.SubsPala` (line 10828) - Local
- `PlusUni.SubsPala` (line 10829) - Local
- `PlusUni.SubsPala` (line 10829) - Local
- `PlusUni.TratErroBanc` (line 10830) - Local
- `GauAgua.AddProgress` (line 10835) - External

#### procedure AtuaCustCole

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10850

**Calls Made:**

- `TsgQuery.Create` (line 10855) - External
- `TsgQuery.Create` (line 10856) - External
- `PlusUni.SUM` (line 10862) - Local
- `PlusUni.WHERE` (line 10864) - Local
- `PlusUni.AND` (line 10864) - Local
- `PlusUni.AND` (line 10864) - Local
- `PlusUni.AND` (line 10864) - Local
- `PlusUni.RetoZero` (line 10865) - Local
- `PlusUni.AND` (line 10867) - Local
- `PlusUni.IdadEnce` (line 10871) - Local
- `PlusUni.not` (line 10875) - Local
- `PlusUni.WHERE` (line 10877) - Local
- `PlusUni.RetoZero` (line 10877) - Local
- `PlusUni.AND` (line 10877) - Local
- `PlusUni.FormDataStri` (line 10877) - Local
- `PlusUni.AND` (line 10877) - Local
- `PlusUni.TratErroBanc` (line 10892) - Local

#### procedure AtuaColeCust

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10905

**Calls Made:**

- `PlusUni.IntToStr` (line 10912) - Local
- `PlusUni.CalcInte` (line 10912) - Local
- `PlusUni.MAX` (line 10912) - Local
- `PlusUni.WHERE` (line 10912) - Local
- `PlusUni.AND` (line 10912) - Local
- `PlusUni.IN` (line 10912) - Local
- `PlusUni.ExecSQL_` (line 10918) - Local
- `PlusUni.WHERE` (line 10919) - Local
- `PlusUni.AND` (line 10920) - Local
- `PlusUni.ExecSQL_` (line 10929) - Local
- `PlusUni.POGeMvCx` (line 10929) - Local
- `PlusUni.ABS` (line 10931) - Local
- `PlusUni.ABS` (line 10933) - Local
- `PlusUni.WHERE` (line 10936) - Local
- `PlusUni.AND` (line 10936) - Local
- `PlusUni.AND` (line 10938) - Local
- `PlusUni.ABS` (line 10938) - Local

#### function SQL_MediPond

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10942

**Calls Made:**

- `PlusUni.BuscCampSQL` (line 10947) - Local
- `PlusUni.SubsPalaTudo` (line 10952) - Local
- `PlusUni.Pos` (line 10953) - Local
- `PlusUni.AnsiUpperCase` (line 10953) - Local
- `PlusUni.Copy` (line 10956) - Local
- `PlusUni.Pos` (line 10957) - Local
- `PlusUni.Copy` (line 10960) - Local
- `PlusUni.SubsPalaTudo` (line 10961) - Local
- `PlusUni.SubsPalaTudo` (line 10961) - Local
- `PlusUni.SubsPalaTudo` (line 10961) - Local
- `PlusUni.Pos` (line 10965) - Local
- `PlusUni.AnsiUpperCase` (line 10965) - Local
- `PlusUni.Copy` (line 10968) - Local
- `PlusUni.SubsPalaTudo` (line 10969) - Local
- `PlusUni.SubsPalaTudo` (line 10969) - Local
- `PlusUni.SubsPalaTudo` (line 10969) - Local
- `PlusUni.Pos` (line 10973) - Local
- `PlusUni.AnsiUpperCase` (line 10973) - Local
- `PlusUni.Copy` (line 10974) - Local
- `PlusUni.SubsPalaTudo` (line 10975) - Local
- `PlusUni.SubsPalaTudo` (line 10975) - Local
- `PlusUni.SubsPalaTudo` (line 10975) - Local
- `PlusUni.Pos` (line 10980) - Local
- `PlusUni.AnsiUpperCase` (line 10980) - Local
- `PlusUni.ExibMensHint` (line 10988) - Local
- `PlusUni.CalcStri` (line 10989) - Local
- `PlusUni.SELECT` (line 10989) - Local
- `PlusUni.WHERE` (line 10989) - Local
- `PlusUni.IntToStr` (line 10989) - Local
- `PlusUni.ExibMensHint` (line 10990) - Local
- `PlusUni.Pos` (line 10992) - Local
- `PlusUni.BuscCampSQL` (line 10994) - Local
- `PlusUni.Pos` (line 10999) - Local
- `PlusUni.AND` (line 10999) - Local
- `PlusUni.Copy` (line 11002) - Local
- `PlusUni.Length` (line 11002) - Local
- `PlusUni.Copy` (line 11003) - Local
- `PlusUni.SubsPalaTudo` (line 11006) - Local
- `PlusUni.WHERE` (line 11006) - Local
- `PlusUni.WHERE` (line 11006) - Local
- `PlusUni.Pos` (line 11009) - Local
- `PlusUni.Trim` (line 11012) - Local
- `PlusUni.Copy` (line 11012) - Local
- `PlusUni.Pos` (line 11012) - Local
- `PlusUni.AnsiUpperCase` (line 11012) - Local
- `PlusUni.Length` (line 11012) - Local
- `PlusUni.SubsPala` (line 11013) - Local
- `PlusUni.SubsPala` (line 11013) - Local
- `PlusUni.SubsPala` (line 11014) - Local
- `PlusUni.AnsiUpperCase` (line 11014) - Local
- `PlusUni.Delete` (line 11020) - Local
- `PlusUni.Copy` (line 11023) - Local
- `PlusUni.Pos` (line 11023) - Local
- `PlusUni.Pos` (line 11024) - Local
- `PlusUni.Pos` (line 11028) - Local
- `PlusUni.AnsiUpperCase` (line 11028) - Local
- `PlusUni.SubsPalaTudo` (line 11030) - Local
- `PlusUni.WHERE` (line 11030) - Local
- `PlusUni.WHERE` (line 11031) - Local
- `PlusUni.RetiMasc` (line 11031) - Local
- `PlusUni.SubsPalaTudo` (line 11035) - Local
- `PlusUni.MAX` (line 11035) - Local
- `PlusUni.WHERE` (line 11035) - Local
- `PlusUni.MAX` (line 11036) - Local
- `PlusUni.WHERE` (line 11036) - Local
- `PlusUni.IN` (line 11036) - Local
- `PlusUni.SubsPalaTudo` (line 11038) - Local
- `PlusUni.IN` (line 11038) - Local
- `PlusUni.SubsPalaTudo` (line 11039) - Local
- `PlusUni.IN` (line 11039) - Local
- `PlusUni.to` (line 11044) - Local
- `PlusUni.SubsPalaTudo` (line 11047) - Local
- `PlusUni.SubsPalaTudo` (line 11049) - Local
- `PlusUni.SubsPalaTudo` (line 11049) - Local
- `PlusUni.SubsPalaTudo` (line 11049) - Local
- `PlusUni.SubsPalaTudo` (line 11053) - Local
- `PlusUni.SubsPalaTudo` (line 11056) - Local
- `PlusUni.SUM` (line 11056) - Local
- `PlusUni.SubsPalaTudo` (line 11057) - Local
- `PlusUni.SUM` (line 11057) - Local

#### function BuscCampSQL

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:10947

**Calls Made:**

- `PlusUni.SubsPalaTudo` (line 10952) - Local
- `PlusUni.Pos` (line 10953) - Local
- `PlusUni.AnsiUpperCase` (line 10953) - Local
- `PlusUni.Copy` (line 10956) - Local
- `PlusUni.Pos` (line 10957) - Local
- `PlusUni.Copy` (line 10960) - Local
- `PlusUni.SubsPalaTudo` (line 10961) - Local
- `PlusUni.SubsPalaTudo` (line 10961) - Local
- `PlusUni.SubsPalaTudo` (line 10961) - Local
- `PlusUni.Pos` (line 10965) - Local
- `PlusUni.AnsiUpperCase` (line 10965) - Local
- `PlusUni.Copy` (line 10968) - Local
- `PlusUni.SubsPalaTudo` (line 10969) - Local
- `PlusUni.SubsPalaTudo` (line 10969) - Local
- `PlusUni.SubsPalaTudo` (line 10969) - Local
- `PlusUni.Pos` (line 10973) - Local
- `PlusUni.AnsiUpperCase` (line 10973) - Local
- `PlusUni.Copy` (line 10974) - Local
- `PlusUni.SubsPalaTudo` (line 10975) - Local
- `PlusUni.SubsPalaTudo` (line 10975) - Local
- `PlusUni.SubsPalaTudo` (line 10975) - Local
- `PlusUni.Pos` (line 10980) - Local
- `PlusUni.AnsiUpperCase` (line 10980) - Local

#### function SQL_MediPondIdad

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11061

**Calls Made:**

- `PlusUni.IsDigit` (line 11068) - Local
- `PlusUni.Copy` (line 11068) - Local
- `PlusUni.FormPont` (line 11069) - Local
- `PlusUni.IsDigit` (line 11070) - Local
- `PlusUni.Copy` (line 11070) - Local
- `PlusUni.FormPont` (line 11071) - Local
- `vProc.Add` (line 11075) - External
- `Subs.Add` (line 11076) - External
- `vProc.Add` (line 11078) - External
- `Subs.Add` (line 11079) - External
- `vProc.Add` (line 11081) - External
- `Subs.Add` (line 11082) - External
- `vProc.Add` (line 11084) - External
- `Subs.Add` (line 11085) - External
- `vProc.Add` (line 11088) - External
- `Subs.Add` (line 11089) - External
- `vProc.Add` (line 11091) - External
- `Subs.Add` (line 11092) - External
- `vProc.Add` (line 11094) - External
- `Subs.Add` (line 11095) - External
- `vProc.Add` (line 11099) - External
- `Subs.Add` (line 11100) - External
- `vProc.Add` (line 11102) - External
- `Subs.Add` (line 11103) - External
- `vProc.Add` (line 11105) - External
- `Subs.Add` (line 11106) - External
- `vProc.Add` (line 11109) - External
- `Subs.Add` (line 11110) - External
- `vProc.Add` (line 11113) - External
- `Subs.Add` (line 11114) - External
- `vProc.Add` (line 11116) - External
- `Subs.Add` (line 11117) - External
- `vProc.Add` (line 11120) - External
- `Subs.Add` (line 11121) - External
- `PlusUni.Copy` (line 11124) - Local
- `PlusUni.Pos` (line 11126) - Local
- `PlusUni.AND` (line 11126) - Local
- `PlusUni.Copy` (line 11129) - Local
- `PlusUni.Length` (line 11129) - Local
- `PlusUni.Copy` (line 11130) - Local
- `PlusUni.Pos` (line 11133) - Local
- `PlusUni.Trim` (line 11136) - Local
- `PlusUni.Copy` (line 11136) - Local
- `PlusUni.Pos` (line 11136) - Local
- `PlusUni.AnsiUpperCase` (line 11136) - Local
- `PlusUni.Length` (line 11136) - Local
- `PlusUni.SubsPala` (line 11137) - Local
- `PlusUni.SubsPala` (line 11137) - Local
- `PlusUni.SubsPala` (line 11138) - Local
- `PlusUni.AnsiUpperCase` (line 11138) - Local
- `PlusUni.IN` (line 11139) - Local
- `PlusUni.CalcMax_ColeLote` (line 11141) - Local
- `vProc.Add` (line 11145) - External
- `Subs.Add` (line 11146) - External
- `PlusUni.FormDataSQL` (line 11146) - Local
- `PlusUni.DataCole` (line 11146) - Local
- `PlusUni.sgStrToFloat` (line 11146) - Local
- `PlusUni.SubsPala` (line 11146) - Local
- `vProc.Add` (line 11147) - External
- `Subs.Add` (line 11148) - External
- `PlusUni.FormDataSQL` (line 11148) - Local
- `PlusUni.DataCole` (line 11148) - Local
- `PlusUni.sgStrToFloat` (line 11148) - Local
- `PlusUni.SubsPala` (line 11148) - Local
- `vProc.Add` (line 11149) - External
- `Subs.Add` (line 11150) - External
- `PlusUni.FormDataSQL` (line 11150) - Local
- `PlusUni.DataCole` (line 11150) - Local
- `PlusUni.sgStrToFloat` (line 11150) - Local
- `PlusUni.SubsPala` (line 11150) - Local
- `PlusUni.SQL_MediPond` (line 11153) - Local

#### function SQL_MediPondData

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11173

**Calls Made:**

- `PlusUni.Pos` (line 11179) - Local
- `PlusUni.AnsiUpperCase` (line 11179) - Local
- `PlusUni.CalcMax_ColeLote` (line 11181) - Local
- `PlusUni.Copy` (line 11181) - Local
- `PlusUni.Pos` (line 11181) - Local
- `PlusUni.CalcMax_ColeLote` (line 11183) - Local
- `vProc.Add` (line 11188) - External
- `Subs.Add` (line 11189) - External
- `PlusUni.BETWEEN` (line 11189) - Local
- `PlusUni.FormCastRealSQL` (line 11189) - Local
- `PlusUni.FormDataSQL` (line 11189) - Local
- `PlusUni.FormNumeSQL` (line 11189) - Local
- `PlusUni.AND` (line 11189) - Local
- `PlusUni.FormCastRealSQL` (line 11189) - Local
- `PlusUni.FormDataSQL` (line 11189) - Local
- `PlusUni.FormNumeSQL` (line 11189) - Local
- `vProc.Add` (line 11191) - External
- `Subs.Add` (line 11192) - External
- `vProc.Add` (line 11194) - External
- `Subs.Add` (line 11195) - External
- `vProc.Add` (line 11197) - External
- `Subs.Add` (line 11198) - External
- `vProc.Add` (line 11201) - External
- `PlusUni.BETWEEN` (line 11201) - Local
- `PlusUni.AND` (line 11201) - Local
- `Subs.Add` (line 11202) - External
- `PlusUni.BETWEEN` (line 11202) - Local
- `PlusUni.FormNumeSQL` (line 11202) - Local
- `vProc.Add` (line 11205) - External
- `PlusUni.BETWEEN` (line 11205) - Local
- `PlusUni.AND` (line 11205) - Local
- `Subs.Add` (line 11206) - External
- `vProc.Add` (line 11210) - External
- `Subs.Add` (line 11211) - External
- `vProc.Add` (line 11213) - External
- `Subs.Add` (line 11214) - External
- `vProc.Add` (line 11216) - External
- `Subs.Add` (line 11217) - External
- `vProc.Add` (line 11220) - External
- `PlusUni.BETWEEN` (line 11220) - Local
- `PlusUni.AND` (line 11220) - Local
- `Subs.Add` (line 11221) - External
- `PlusUni.BETWEEN` (line 11221) - Local
- `PlusUni.FormNumeSQL` (line 11221) - Local
- `vProc.Add` (line 11224) - External
- `PlusUni.BETWEEN` (line 11224) - Local
- `PlusUni.AND` (line 11224) - Local
- `Subs.Add` (line 11225) - External
- `vProc.Add` (line 11232) - External
- `Subs.Add` (line 11233) - External
- `vProc.Add` (line 11235) - External
- `Subs.Add` (line 11236) - External
- `vProc.Add` (line 11238) - External
- `Subs.Add` (line 11239) - External
- `vProc.Add` (line 11242) - External
- `PlusUni.BETWEEN` (line 11242) - Local
- `PlusUni.AND` (line 11242) - Local
- `Subs.Add` (line 11243) - External
- `PlusUni.BETWEEN` (line 11243) - Local
- `PlusUni.FormNumeSQL` (line 11243) - Local
- `vProc.Add` (line 11246) - External
- `PlusUni.BETWEEN` (line 11246) - Local
- `PlusUni.AND` (line 11246) - Local
- `Subs.Add` (line 11247) - External
- `vProc.Add` (line 11252) - External
- `Subs.Add` (line 11253) - External
- `vProc.Add` (line 11256) - External
- `Subs.Add` (line 11257) - External
- `PlusUni.FormCastRealSQL` (line 11257) - Local
- `PlusUni.FormDataSQL` (line 11257) - Local
- `PlusUni.FormNumeSQL` (line 11257) - Local
- `vProc.Add` (line 11259) - External
- `Subs.Add` (line 11260) - External
- `vProc.Add` (line 11262) - External
- `Subs.Add` (line 11263) - External
- `vProc.Add` (line 11265) - External
- `Subs.Add` (line 11266) - External
- `PlusUni.SQL_MediPond` (line 11268) - Local

#### function MediPondIdad

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11272

**Calls Made:**

- `PlusUni.SQL_MediPondIdad` (line 11277) - Local
- `PlusUni.CalcReal` (line 11278) - Local
- `PlusUni.ExibMensHint` (line 11282) - Local

#### function MediPondData

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11292

**Calls Made:**

- `PlusUni.SQL_MediPondData` (line 11297) - Local
- `PlusUni.FormDataSQL` (line 11297) - Local
- `PlusUni.FormDataSQL` (line 11297) - Local
- `PlusUni.CalcReal` (line 11298) - Local
- `PlusUni.ExibMensHint` (line 11302) - Local

#### function PegaCole

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11313

**Calls Made:**

- `PlusUni.FormPont` (line 11315) - Local
- `PlusUni.CalcReal` (line 11317) - Local
- `PlusUni.SUM` (line 11317) - Local
- `PlusUni.WHERE` (line 11317) - Local
- `PlusUni.AND` (line 11317) - Local
- `PlusUni.AND` (line 11317) - Local
- `PlusUni.CalcReal` (line 11321) - Local
- `PlusUni.SUM` (line 11321) - Local
- `PlusUni.WHERE` (line 11321) - Local
- `PlusUni.AND` (line 11321) - Local
- `PlusUni.AND` (line 11321) - Local
- `PlusUni.MAX` (line 11321) - Local
- `PlusUni.WHERE` (line 11321) - Local
- `PlusUni.AND` (line 11321) - Local
- `PlusUni.AND` (line 11321) - Local
- `PlusUni.CalcReal` (line 11323) - Local
- `PlusUni.WHERE` (line 11323) - Local
- `PlusUni.AND` (line 11323) - Local
- `PlusUni.AND` (line 11323) - Local

#### function RetoCor_Item

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11328

**Calls Made:**

- `TsgQuery.Create` (line 11335) - External
- `PlusUni.WHERE` (line 11339) - Local
- `PlusUni.IntToStr` (line 11339) - Local

#### function DuplRegiTabe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11384

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 11390) - Local
- `TsgQuery.Create` (line 11392) - External
- `TsgQuery.Create` (line 11393) - External
- `PlusUni.Assigned` (line 11395) - Local
- `PlusUni.tsgADOConnection` (line 11397) - Local
- `PlusUni.tsgADOConnection` (line 11398) - Local
- `PlusUni.WHERE` (line 11408) - Local
- `PlusUni.not` (line 11410) - Local
- `PlusUni.to` (line 11414) - Local
- `PlusUni.Pos` (line 11416) - Local
- `PlusUni.AnsiUpperCase` (line 11416) - Local
- `PlusUni.AnsiUpperCase` (line 11416) - Local
- `PlusUni.TipoDadoCara` (line 11418) - Local
- `PlusUni.AND` (line 11418) - Local
- `PlusUni.not` (line 11418) - Local
- `PlusUni.TratErroBanc` (line 11426) - Local
- `PlusUni.CalcCodi` (line 11430) - Local

#### procedure OrdeMovi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11443

**Calls Made:**

- `PlusUni.msgSim` (line 11448) - Local
- `TsgQuery.Create` (line 11450) - External
- `PlusUni.Copy` (line 11453) - Local
- `PlusUni.not` (line 11459) - Local
- `PlusUni.AlteDadoTabe` (line 11461) - Local
- `PlusUni.IntToStr` (line 11462) - Local
- `PlusUni.WHERE` (line 11463) - Local
- `PlusUni.Copy` (line 11463) - Local
- `PlusUni.IntToStr` (line 11463) - Local

#### function ValiCont

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11477

**Calls Made:**

- `PlusUni.msgOk` (line 11482) - Local

#### procedure OrdePlan

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11489

**Calls Made:**

- `PlusUni.TsgQuery` (line 11495) - Local
- `PlusUni.AnsiUpperCase` (line 11499) - Local
- `PlusUni.Copy` (line 11499) - Local
- `PlusUni.Trim` (line 11499) - Local
- `PlusUni.PegaPara` (line 11506) - Local

#### function RetoSQL_Fase

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11530

**Calls Made:**

- `PlusUni.SeStri` (line 11535) - Local
- `PlusUni.SeStri` (line 11537) - Local
- `PlusUni.SeStri` (line 11539) - Local

#### function RetoOpca

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11545

_No outgoing calls_

#### procedure MudaNomeCampTabe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11559

**Calls Made:**

- `PlusUni.msgSim` (line 11564) - Local
- `PlusUni.QuotedStr` (line 11564) - Local
- `PlusUni.QuotedStr` (line 11564) - Local
- `PlusUni.QuotedStr` (line 11564) - Local
- `TsgQuery.Create` (line 11566) - External
- `PlusUni.not` (line 11571) - Local
- `PlusUni.SubsPala` (line 11574) - Local
- `PlusUni.SubsPala` (line 11574) - Local
- `PlusUni.ZeroEsqu` (line 11574) - Local
- `PlusUni.IntToStr` (line 11574) - Local
- `PlusUni.TratErroBanc` (line 11575) - Local
- `PlusUni.Inc` (line 11576) - Local

#### function RetoGrauPlan

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11586

**Calls Made:**

- `PlusUni.Copy` (line 11588) - Local
- `PlusUni.Copy` (line 11590) - Local
- `PlusUni.Copy` (line 11592) - Local

#### function ProxNumePlan

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11599

**Calls Made:**

- `PlusUni.RetoGrauPlan` (line 11605) - Local
- `TsgQuery.Create` (line 11606) - External
- `PlusUni.WHERE` (line 11609) - Local
- `PlusUni.COPY` (line 11609) - Local
- `PlusUni.IntToStr` (line 11609) - Local
- `PlusUni.QuotedStr` (line 11609) - Local
- `PlusUni.Copy` (line 11609) - Local
- `PlusUni.StrToInt` (line 11612) - Local
- `PlusUni.RetoZero` (line 11612) - Local
- `PlusUni.Copy` (line 11612) - Local
- `PlusUni.ZeroEsqu` (line 11613) - Local
- `PlusUni.IntToStr` (line 11613) - Local

#### procedure ArreIdadTabe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11625

**Calls Made:**

- `PlusUni.GetPSis` (line 11631) - Local
- `PlusUni.and` (line 11631) - Local
- `PlusUni.GetPSis` (line 11631) - Local
- `PlusUni.and` (line 11631) - Local
- `PlusUni.GetPSis` (line 11631) - Local
- `PlusUni.and` (line 11631) - Local
- `PlusUni.GetPSis` (line 11631) - Local
- `PlusUni.GetPBas` (line 11633) - Local
- `PlusUni.ExecSQL_` (line 11636) - Local
- `PlusUni.sgFixedPoint` (line 11636) - Local
- `PlusUni.ExecSQL_` (line 11638) - Local
- `PlusUni.sgFixedPoint` (line 11638) - Local
- `PlusUni.SeInte` (line 11642) - Local
- `PlusUni.Copy` (line 11644) - Local
- `TsgQuery.Create` (line 11645) - External
- `Application.CreateForm` (line 11647) - External
- `PlusUni.not` (line 11656) - Local
- `PlusUni.ArreReal` (line 11660) - Local
- `PlusUni.TratErroBanc` (line 11661) - Local

#### function GrafCabe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11676

**Calls Made:**

- `TsgQuery.Create` (line 11680) - External
- `PlusUni.WHERE` (line 11683) - Local
- `PlusUni.GetPTab` (line 11697) - Local
- `PlusUni.GetPUsu` (line 11698) - Local
- `PlusUni.TratErroBanc` (line 11699) - Local
- `PlusUni.CalcCodi` (line 11703) - Local

#### procedure GrafSeri

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11712

**Calls Made:**

- `PlusUni.InseDadoTabe` (line 11714) - Local
- `PlusUni.IntToStr` (line 11715) - Local
- `PlusUni.IntToStr` (line 11716) - Local
- `PlusUni.IntToStr` (line 11718) - Local
- `PlusUni.QuotedStr` (line 11719) - Local
- `PlusUni.QuotedStr` (line 11720) - Local
- `PlusUni.QuotedStr` (line 11721) - Local
- `PlusUni.QuotedStr` (line 11722) - Local
- `PlusUni.IntToStr` (line 11723) - Local
- `PlusUni.QuotedStr` (line 11724) - Local
- `PlusUni.GetPBas` (line 11725) - Local

#### function ArruParaEstr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11729

**Calls Made:**

- `PlusUni.PegaPara` (line 11743) - Local
- `PlusUni.IntToStr` (line 11743) - Local
- `PlusUni.TsgLbl` (line 11746) - Local
- `PlusUni.FindComponent` (line 11746) - Local
- `PlusUni.IntToStr` (line 11746) - Local
- `PlusUni.TsgLbl` (line 11747) - Local
- `PlusUni.FindComponent` (line 11747) - Local
- `PlusUni.IntToStr` (line 11747) - Local
- `PlusUni.TDbEdtLbl` (line 11748) - Local
- `PlusUni.FindComponent` (line 11748) - Local
- `PlusUni.IntToStr` (line 11748) - Local
- `PlusUni.TDbEdtLbl` (line 11749) - Local
- `PlusUni.FindComponent` (line 11749) - Local
- `PlusUni.IntToStr` (line 11749) - Local
- `Quer.FieldByName` (line 11750) - External
- `PlusUni.IntToStr` (line 11750) - Local
- `PlusUni.PegaPara` (line 11750) - Local
- `PlusUni.IntToStr` (line 11750) - Local
- `PlusUni.PegaPara` (line 11754) - Local
- `PlusUni.IntToStr` (line 11754) - Local
- `Quer.FieldByName` (line 11757) - External
- `PlusUni.IntToStr` (line 11757) - Local
- `PlusUni.TsgLbl` (line 11758) - Local
- `PlusUni.FindComponent` (line 11758) - Local
- `PlusUni.IntToStr` (line 11758) - Local
- `PlusUni.TsgLbl` (line 11759) - Local
- `PlusUni.FindComponent` (line 11759) - Local
- `PlusUni.IntToStr` (line 11759) - Local
- `PlusUni.TDbCmbLbl` (line 11760) - Local
- `PlusUni.FindComponent` (line 11760) - Local
- `PlusUni.IntToStr` (line 11760) - Local
- `PlusUni.PegaPara` (line 11763) - Local
- `PlusUni.IntToStr` (line 11763) - Local
- `PlusUni.PegaPara` (line 11768) - Local
- `PlusUni.IntToStr` (line 11768) - Local
- `PlusUni.TsgLbl` (line 11771) - Local
- `PlusUni.FindComponent` (line 11771) - Local
- `PlusUni.IntToStr` (line 11771) - Local
- `PlusUni.TsgLbl` (line 11772) - Local
- `PlusUni.FindComponent` (line 11772) - Local
- `PlusUni.IntToStr` (line 11772) - Local
- `PlusUni.TDbRxELbl` (line 11773) - Local
- `PlusUni.FindComponent` (line 11773) - Local
- `PlusUni.IntToStr` (line 11773) - Local
- `PlusUni.TDbRxELbl` (line 11774) - Local
- `PlusUni.FindComponent` (line 11774) - Local
- `PlusUni.IntToStr` (line 11774) - Local
- `PlusUni.PegaPara` (line 11778) - Local
- `PlusUni.IntToStr` (line 11778) - Local
- `PlusUni.TDBChkLbl` (line 11781) - Local
- `PlusUni.FindComponent` (line 11781) - Local
- `PlusUni.IntToStr` (line 11781) - Local
- `PlusUni.TDBChkLbl` (line 11782) - Local
- `PlusUni.FindComponent` (line 11782) - Local
- `PlusUni.IntToStr` (line 11782) - Local
- `PlusUni.TDBChkLbl` (line 11783) - Local
- `PlusUni.FindComponent` (line 11783) - Local
- `PlusUni.IntToStr` (line 11783) - Local
- `PlusUni.PegaPara` (line 11789) - Local
- `PlusUni.IntToStr` (line 11789) - Local
- `PlusUni.TsgLbl` (line 11792) - Local
- `PlusUni.FindComponent` (line 11792) - Local
- `PlusUni.IntToStr` (line 11792) - Local
- `PlusUni.TsgLbl` (line 11793) - Local
- `PlusUni.FindComponent` (line 11793) - Local
- `PlusUni.IntToStr` (line 11793) - Local
- `PlusUni.TDbRxDLbl` (line 11794) - Local
- `PlusUni.FindComponent` (line 11794) - Local
- `PlusUni.IntToStr` (line 11794) - Local
- `PlusUni.TDbRxDLbl` (line 11795) - Local
- `PlusUni.FindComponent` (line 11795) - Local
- `PlusUni.IntToStr` (line 11795) - Local
- `Quer.FieldByName` (line 11804) - External
- `PlusUni.IntToStr` (line 11804) - Local
- `Quer.FieldByName` (line 11805) - External
- `PlusUni.IntToStr` (line 11805) - Local
- `Quer.FieldByName` (line 11813) - External
- `PlusUni.IntToStr` (line 11813) - Local

#### function DiasMes

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11820

_No outgoing calls_

#### function VeriDia_Vali

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11837

**Calls Made:**

- `PlusUni.not` (line 11840) - Local
- `PlusUni.DataFeri` (line 11840) - Local
- `PlusUni.DayOfWeek` (line 11843) - Local
- `PlusUni.DayOfWeek` (line 11844) - Local
- `PlusUni.DayOfWeek` (line 11845) - Local
- `PlusUni.DayOfWeek` (line 11846) - Local
- `PlusUni.DayOfWeek` (line 11847) - Local
- `PlusUni.DayOfWeek` (line 11848) - Local
- `PlusUni.DayOfWeek` (line 11849) - Local

#### function DifeEntrMes

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11857

_No outgoing calls_

#### function AchaDia_Util

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11866

**Calls Made:**

- `PlusUni.DiasMes` (line 11872) - Local
- `PlusUni.and` (line 11872) - Local
- `PlusUni.Inc` (line 11874) - Local
- `PlusUni.VeriDia_Vali` (line 11875) - Local
- `PlusUni.EncodeDate` (line 11875) - Local
- `PlusUni.Inc` (line 11876) - Local

#### function BuscDia_Util

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11881

**Calls Made:**

- `PlusUni.VeriDia_Vali` (line 11884) - Local

#### function ProxDia_Util

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11892

**Calls Made:**

- `PlusUni.BuscDia_Util` (line 11894) - Local

#### procedure FaixTipo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11900

_No outgoing calls_

#### function QtdeProd

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11935

**Calls Made:**

- `PlusUni.SeStri` (line 11939) - Local
- `PlusUni.AND` (line 11939) - Local
- `PlusUni.IntToStr` (line 11939) - Local
- `PlusUni.CalcReal` (line 11940) - Local
- `PlusUni.SUM` (line 11940) - Local
- `PlusUni.WHERE` (line 11942) - Local
- `PlusUni.QuotedStr` (line 11942) - Local
- `PlusUni.AND` (line 11943) - Local
- `PlusUni.FormDataSQL` (line 11943) - Local

#### function EstoProd_CalcReal

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:11997

**Calls Made:**

- `PlusUni.Assigned` (line 11999) - Local
- `PlusUni.CalcReal` (line 12000) - Local
- `PlusUni.CalcReal` (line 12002) - Local
- `PlusUni.Assigned` (line 12046) - Local
- `PlusUni.CalcReal` (line 12047) - Local
- `PlusUni.CalcReal` (line 12049) - Local

#### function BloqProdCarr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12177

**Calls Made:**

- `PlusUni.Round` (line 12183) - Local
- `PlusUni.PegaParaNume` (line 12183) - Local
- `PlusUni.CalcReal` (line 12184) - Local
- `PlusUni.COUNT` (line 12184) - Local
- `PlusUni.WHERE` (line 12184) - Local
- `PlusUni.IntToStr` (line 12184) - Local
- `PlusUni.NuloInte` (line 12184) - Local
- `PlusUni.AND` (line 12184) - Local
- `PlusUni.IntToStr` (line 12184) - Local
- `PlusUni.NuloInte` (line 12184) - Local
- `PlusUni.AND` (line 12184) - Local
- `PlusUni.CalcReal` (line 12190) - Local
- `PlusUni.COUNT` (line 12190) - Local
- `PlusUni.WHERE` (line 12190) - Local
- `PlusUni.IntToStr` (line 12190) - Local
- `PlusUni.NuloInte` (line 12190) - Local
- `PlusUni.AND` (line 12190) - Local
- `PlusUni.IntToStr` (line 12190) - Local
- `PlusUni.NuloInte` (line 12190) - Local
- `PlusUni.AND` (line 12190) - Local
- `PlusUni.msgAviso` (line 12198) - Local
- `PlusUni.msgNao` (line 12200) - Local
- `PlusUni.msgAviso` (line 12209) - Local
- `PlusUni.msgNao` (line 12211) - Local

#### function LancCole

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12238

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 12242) - Local
- `TsgQuery.Create` (line 12243) - External
- `PlusUni.WHERE` (line 12248) - Local
- `PlusUni.IntToStr` (line 12248) - Local
- `PlusUni.AND` (line 12248) - Local
- `PlusUni.IntToStr` (line 12248) - Local
- `PlusUni.AND` (line 12248) - Local
- `PlusUni.FormPont` (line 12248) - Local
- `PlusUni.FloatToStr` (line 12248) - Local
- `PlusUni.WHERE` (line 12250) - Local
- `PlusUni.IntToStr` (line 12250) - Local
- `PlusUni.not` (line 12256) - Local
- `PlusUni.or` (line 12256) - Local
- `PlusUni.TratErroBanc` (line 12267) - Local
- `PlusUni.CalcCodi` (line 12271) - Local

#### function SituRequEsto

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12280

_No outgoing calls_

#### function IndiSituRequEsto

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12293

_No outgoing calls_

#### function GeraCodiBarr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12308

**Calls Made:**

- `PlusUni.PegaPara` (line 12312) - Local
- `PlusUni.PegaPara` (line 12313) - Local
- `PlusUni.DigiVeriBarr` (line 12317) - Local

#### function ProxCodiBarr

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12324

**Calls Made:**

- `PlusUni.Trunc` (line 12329) - Local
- `PlusUni.PegaParaNume` (line 12329) - Local
- `PlusUni.and` (line 12334) - Local
- `PlusUni.Length` (line 12334) - Local
- `PlusUni.IntToStr` (line 12334) - Local
- `PlusUni.CalcInte` (line 12336) - Local
- `PlusUni.WHERE` (line 12336) - Local
- `PlusUni.RTRIM` (line 12336) - Local
- `PlusUni.IntToStr` (line 12336) - Local
- `PlusUni.IntToStr` (line 12336) - Local
- `PlusUni.IntToStr` (line 12336) - Local
- `PlusUni.ZeroEsqu` (line 12338) - Local
- `PlusUni.IntToStr` (line 12338) - Local

#### procedure GravAcesSAG_Mana

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12369

**Calls Made:**

- `PlusUni.GravAcesSAG_Mana_Empr` (line 12373) - Local
- `PlusUni.ExibProgPrin` (line 12375) - Local
- `PlusUni.InseDadoTabe` (line 12377) - Local
- `PlusUni.RetoUserBase` (line 12378) - Local
- `PlusUni.QuotedStr` (line 12379) - Local
- `PlusUni.RetoVers` (line 12379) - Local
- `PlusUni.QuotedStr` (line 12380) - Local
- `PlusUni.PegaIP` (line 12380) - Local
- `PlusUni.QuotedStr` (line 12381) - Local
- `PlusUni.PegaMaqu` (line 12381) - Local
- `PlusUni.QuotedStr` (line 12382) - Local
- `PlusUni.PegaUsuaWind` (line 12382) - Local
- `PlusUni.QuotedStr` (line 12383) - Local
- `PlusUni.QuotedStr` (line 12384) - Local
- `PlusUni.FormDataSQL` (line 12385) - Local
- `PlusUni.FormatDateTime` (line 12386) - Local
- `PlusUni.FormatDateTime` (line 12387) - Local
- `PlusUni.SetPCodMoni` (line 12389) - Local
- `PlusUni.ExibProgPrin` (line 12390) - Local
- `PlusUni.GravParaData` (line 12392) - Local
- `PlusUni.Trunc` (line 12404) - Local
- `PlusUni.PegaParaNume` (line 12404) - Local
- `PlusUni.GetPUsu` (line 12404) - Local
- `PlusUni.ExibProgPrin` (line 12410) - Local

#### function CalcNumeNota

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12449

**Calls Made:**

- `PlusUni.CalcInte` (line 12451) - Local
- `PlusUni.MAX` (line 12451) - Local
- `PlusUni.WHERE` (line 12452) - Local
- `PlusUni.IntToStr` (line 12452) - Local
- `PlusUni.AND` (line 12453) - Local
- `PlusUni.ZEROESQU` (line 12453) - Local
- `PlusUni.ZEROESQU` (line 12453) - Local
- `PlusUni.QuotedStr` (line 12453) - Local
- `PlusUni.SeStri` (line 12454) - Local
- `PlusUni.AND` (line 12454) - Local
- `PlusUni.QuotedStr` (line 12454) - Local
- `PlusUni.AND` (line 12455) - Local
- `PlusUni.AND` (line 12456) - Local
- `PlusUni.AND` (line 12457) - Local
- `PlusUni.IntToStr` (line 12457) - Local

#### function SenhModu_Todo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12465

**Calls Made:**

- `PlusUni.SenhModu_Todo_BuscNomeTipo` (line 12473) - Local
- `PlusUni.or` (line 12475) - Local
- `PlusUni.GetPUsu` (line 12490) - Local
- `PlusUni.GetPSis` (line 12491) - Local
- `PlusUni.GetPEmp` (line 12492) - Local
- `List.Add` (line 12497) - External
- `List.Add` (line 12498) - External
- `List.Add` (line 12499) - External
- `PlusUni.EspaDire` (line 12500) - Local
- `PlusUni.EspaEsqu` (line 12501) - Local
- `PlusUni.EspaEsqu` (line 12502) - Local
- `PlusUni.EspaEsqu` (line 12503) - Local
- `PlusUni.EspaEsqu` (line 12504) - Local
- `PlusUni.EspaEsqu` (line 12505) - Local
- `List.Add` (line 12507) - External
- `PlusUni.Replicate` (line 12508) - Local
- `PlusUni.Replicate` (line 12509) - Local
- `PlusUni.Replicate` (line 12510) - Local
- `PlusUni.Replicate` (line 12511) - Local
- `PlusUni.Replicate` (line 12512) - Local
- `PlusUni.Replicate` (line 12513) - Local
- `PlusUni.WHERE` (line 12520) - Local
- `PlusUni.ExibMensHint` (line 12526) - Local
- `PlusUni.SetPSis` (line 12527) - Local
- `PlusUni.GetPSis` (line 12527) - Local
- `PlusUni.GravPOCaConf` (line 12528) - Local
- `PlusUni.ZeroEsqu` (line 12530) - Local
- `PlusUni.IntToStr` (line 12530) - Local
- `PlusUni.GetPSis` (line 12530) - Local
- `PlusUni.PegaParaSenh` (line 12533) - Local
- `PlusUni.Copy` (line 12534) - Local
- `PlusUni.ZeroEsqu` (line 12534) - Local
- `PlusUni.StrToInt` (line 12535) - Local
- `PlusUni.GetSenh_A_ZparaNume` (line 12535) - Local
- `PlusUni.Copy` (line 12536) - Local
- `PlusUni.Inc` (line 12540) - Local
- `PlusUni.ValiContMultSist` (line 12543) - Local
- `PlusUni.StrToInt` (line 12545) - Local
- `PlusUni.RetoZero` (line 12545) - Local
- `PlusUni.DiviContMultSist` (line 12546) - Local
- `PlusUni.StrToInt` (line 12548) - Local
- `PlusUni.GetSenh_A_ZparaNume` (line 12548) - Local
- `PlusUni.Copy` (line 12548) - Local
- `PlusUni.EspaEsqu` (line 12551) - Local
- `PlusUni.FormInteBras` (line 12551) - Local
- `PlusUni.EspaEsqu` (line 12553) - Local
- `List.Add` (line 12554) - External
- `PlusUni.ZeroEsqu` (line 12554) - Local
- `PlusUni.EspaDire` (line 12555) - Local
- `PlusUni.EspaEsqu` (line 12556) - Local
- `PlusUni.FormInteBras` (line 12556) - Local
- `PlusUni.EspaEsqu` (line 12557) - Local
- `PlusUni.FormInteBras` (line 12557) - Local
- `PlusUni.EspaDire` (line 12559) - Local
- `PlusUni.Copy` (line 12559) - Local
- `PlusUni.SenhModu_Todo_BuscNomeTipo` (line 12559) - Local
- `PlusUni.EspaEsqu` (line 12560) - Local
- `PlusUni.FormData` (line 12560) - Local
- `PlusUni.PegaParaSenh` (line 12560) - Local
- `PlusUni.StrToInt` (line 12566) - Local
- `PlusUni.GetSenh_A_ZparaNume` (line 12566) - Local
- `PlusUni.Copy` (line 12566) - Local
- `PlusUni.EspaEsqu` (line 12568) - Local
- `PlusUni.FormInteBras` (line 12568) - Local
- `PlusUni.EspaEsqu` (line 12570) - Local
- `List.Add` (line 12571) - External
- `PlusUni.EspaEsqu` (line 12571) - Local
- `PlusUni.EspaDire` (line 12572) - Local
- `PlusUni.EspaEsqu` (line 12573) - Local
- `PlusUni.FormInteBras` (line 12573) - Local
- `PlusUni.EspaEsqu` (line 12574) - Local
- `PlusUni.FormInteBras` (line 12574) - Local
- `PlusUni.EspaDire` (line 12576) - Local
- `PlusUni.Copy` (line 12576) - Local
- `PlusUni.SenhModu_Todo_BuscNomeTipo` (line 12576) - Local
- `PlusUni.EspaEsqu` (line 12577) - Local
- `List.Add` (line 12582) - External
- `PlusUni.ZeroEsqu` (line 12582) - Local
- `PlusUni.EspaDire` (line 12583) - Local

#### function SenhModu_Todo_BuscNomeTipo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12473

**Calls Made:**

- `PlusUni.or` (line 12475) - Local

#### function SenhModu_GeraSenhClie

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12606

**Calls Made:**

- `PlusUni.FormatDateTime` (line 12613) - Local
- `PlusUni.SomaCara` (line 12616) - Local
- `PlusUni.IntToStr` (line 12616) - Local
- `PlusUni.IntToStr` (line 12616) - Local
- `PlusUni.FormNume` (line 12618) - Local
- `PlusUni.Copy` (line 12618) - Local
- `PlusUni.Copy` (line 12618) - Local
- `PlusUni.Copy` (line 12618) - Local
- `PlusUni.Copy` (line 12618) - Local
- `PlusUni.Copy` (line 12619) - Local
- `PlusUni.Copy` (line 12619) - Local
- `PlusUni.Copy` (line 12619) - Local
- `PlusUni.IntToStr` (line 12619) - Local
- `PlusUni.ZeroEsqu` (line 12619) - Local
- `PlusUni.IntToStr` (line 12619) - Local
- `PlusUni.ZeroEsqu` (line 12619) - Local
- `PlusUni.IntToStr` (line 12619) - Local

#### function SenhModu_ContSenh

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12624

**Calls Made:**

- `PlusUni.DeixLetrNume` (line 12629) - Local
- `PlusUni.Copy` (line 12633) - Local
- `PlusUni.Copy` (line 12634) - Local
- `PlusUni.StrToInt` (line 12636) - Local
- `PlusUni.Trunc` (line 12638) - Local
- `PlusUni.DiveZero` (line 12638) - Local
- `PlusUni.DiviContMultSist` (line 12638) - Local
- `PlusUni.SeInte` (line 12639) - Local
- `PlusUni.ZeroEsqu` (line 12640) - Local
- `PlusUni.IntToStr` (line 12640) - Local
- `PlusUni.ZeroEsqu` (line 12643) - Local
- `PlusUni.IntToStr` (line 12643) - Local
- `PlusUni.ZeroEsqu` (line 12645) - Local
- `PlusUni.IntToStr` (line 12645) - Local
- `PlusUni.StrToInt` (line 12648) - Local
- `PlusUni.SubsPalaTudo` (line 12648) - Local
- `PlusUni.Copy` (line 12648) - Local
- `PlusUni.SeStri` (line 12649) - Local
- `PlusUni.GetSenh_NumeParaA_Z` (line 12649) - Local
- `PlusUni.SeStri` (line 12650) - Local
- `PlusUni.GetSenh_NumeParaA_Z` (line 12650) - Local
- `PlusUni.SeStri` (line 12652) - Local
- `PlusUni.IntToStr` (line 12652) - Local
- `PlusUni.SeStri` (line 12653) - Local
- `PlusUni.IntToStr` (line 12653) - Local
- `PlusUni.ZeroEsqu` (line 12658) - Local
- `PlusUni.IntToStr` (line 12658) - Local
- `PlusUni.Trunc` (line 12658) - Local
- `PlusUni.DiveZero` (line 12658) - Local
- `PlusUni.DiviContMultSist` (line 12658) - Local
- `PlusUni.ZeroEsqu` (line 12661) - Local
- `PlusUni.IntToStr` (line 12661) - Local
- `PlusUni.ZeroEsqu` (line 12664) - Local
- `PlusUni.IntToStr` (line 12664) - Local
- `PlusUni.StrToInt` (line 12664) - Local
- `PlusUni.Copy` (line 12664) - Local
- `PlusUni.Copy` (line 12664) - Local
- `PlusUni.Copy` (line 12664) - Local
- `PlusUni.and` (line 12666) - Local
- `PlusUni.FormatDateTime` (line 12667) - Local
- `PlusUni.FormatDateTime` (line 12669) - Local
- `PlusUni.ZeroEsqu` (line 12671) - Local
- `PlusUni.IntToStr` (line 12671) - Local
- `PlusUni.ABS` (line 12671) - Local
- `PlusUni.GetSenh_CalcDigiVeri` (line 12671) - Local
- `PlusUni.SomaCara` (line 12671) - Local
- `PlusUni.Copy` (line 12671) - Local
- `PlusUni.Copy` (line 12671) - Local
- `PlusUni.Copy` (line 12671) - Local
- `PlusUni.GetSenh_A_ZparaNume` (line 12671) - Local
- `PlusUni.FormNume` (line 12673) - Local
- `PlusUni.Copy` (line 12673) - Local
- `PlusUni.Copy` (line 12673) - Local
- `PlusUni.Copy` (line 12673) - Local
- `PlusUni.Copy` (line 12673) - Local
- `PlusUni.Copy` (line 12674) - Local
- `PlusUni.Copy` (line 12674) - Local

#### function SenhModu_ContSenh_GeraWher

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12679

**Calls Made:**

- `TsgQuery.Create` (line 12684) - External
- `PlusUni.Copy` (line 12696) - Local
- `PlusUni.Copy` (line 12698) - Local
- `PlusUni.ZeroEsqu` (line 12698) - Local
- `PlusUni.Copy` (line 12699) - Local
- `PlusUni.ZeroEsqu` (line 12699) - Local
- `PlusUni.SeStri` (line 12700) - Local
- `PlusUni.SenhModu_ContSenh` (line 12701) - Local
- `PlusUni.ZeroEsqu` (line 12705) - Local
- `PlusUni.IntToStr` (line 12705) - Local
- `PlusUni.StrToInt` (line 12705) - Local

#### function GetSenh_NumeparaA_Z

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:12985

**Calls Made:**

- `PlusUni.IntToStr` (line 12988) - Local
- `PlusUni.Chr` (line 12989) - Local
- `PlusUni.Chr` (line 12990) - Local

#### function GeraArquXML_SQL

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13104

**Calls Made:**

- `PlusUni.ArquValiEnde` (line 13117) - Local
- `PlusUni.ExibProgPrin` (line 13120) - Local
- `TXMLDocument.Create` (line 13121) - External
- `XMLDoc.AddChild` (line 13130) - External
- `XMLNodersdata.AddChild` (line 13134) - External
- `PlusUni.AnsiUpperCase` (line 13137) - Local
- `XMLNode.AddChild` (line 13139) - External
- `PlusUni.FormatDateTime` (line 13143) - Local
- `PlusUni.FormatDateTime` (line 13148) - Local
- `PlusUni.FormatDateTime` (line 13148) - Local
- `PlusUni.StringReplace` (line 13157) - Local
- `PlusUni.FormatFloat` (line 13157) - Local
- `PlusUni.ExibProgPrin` (line 13166) - Local
- `XMLDoc.AddChild` (line 13176) - External
- `PrinXMLNode.AddChild` (line 13182) - External
- `XMLNodeSchema.AddChild` (line 13185) - External
- `PlusUni.AnsiUpperCase` (line 13193) - Local
- `XMLNodeElement.AddChild` (line 13195) - External
- `XMLNodeAtribute.AddChild` (line 13202) - External
- `PrinXMLNode.AddChild` (line 13222) - External
- `PlusUni.AnsiUpperCase` (line 13226) - Local
- `XMLNodersdata.AddChild` (line 13228) - External
- `PlusUni.FormatDateTime` (line 13238) - Local
- `PlusUni.FormatDateTime` (line 13238) - Local
- `PlusUni.StringReplace` (line 13247) - Local
- `PlusUni.FormatFloat` (line 13247) - Local
- `PlusUni.ExibProgPrin` (line 13256) - Local
- `XMLDoc.SaveToFile` (line 13265) - External
- `PlusUni.ExibMensHint` (line 13269) - Local
- `PlusUni.ArquValiEnde` (line 13279) - Local
- `PlusUni.ExibProgPrin` (line 13287) - Local
- `TXMLDocument.Create` (line 13288) - External
- `XMLDoc.AddChild` (line 13291) - External
- `PrinXMLNode.AddChild` (line 13297) - External
- `XMLNodeSchema.AddChild` (line 13300) - External
- `XMLNodeElement.AddChild` (line 13308) - External
- `XMLNodeAtribute.AddChild` (line 13315) - External
- `PrinXMLNode.AddChild` (line 13334) - External
- `XMLNodersdata.AddChild` (line 13338) - External
- `PlusUni.FormatDateTime` (line 13348) - Local
- `PlusUni.FormatDateTime` (line 13348) - Local
- `PlusUni.StringReplace` (line 13357) - Local
- `PlusUni.FormatFloat` (line 13357) - Local
- `PlusUni.ExibProgPrin` (line 13365) - Local
- `XMLDoc.SaveToFile` (line 13372) - External
- `PlusUni.ExibMensHint` (line 13376) - Local

#### function ImpoArquXML_

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13381

**Calls Made:**

- `PlusUni.ArquValiEnde` (line 13383) - Local
- `PlusUni.ExibProgPrin` (line 13391) - Local
- `PlusUni.NFe_XML_ImpoXML_V20` (line 13395) - Local
- `PlusUni.SubsPalaTudo` (line 13395) - Local
- `PlusUni.ExtractFileName` (line 13395) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 13396) - Local
- `PlusUni.VeriExisCampTabe_Valo` (line 13397) - Local
- `PlusUni.ExibProgPrin` (line 13398) - Local
- `PlusUni.ExibMensHint` (line 13407) - Local

#### function Ex_ManuDado

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13412

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 13419) - Local
- `PlusUni.TsgQuery` (line 13423) - Local
- `PlusUni.FindComponent` (line 13423) - Local
- `PlusUni.AnsiUpperCase` (line 13426) - Local
- `PlusUni.TDataSource` (line 13430) - Local
- `PlusUni.FindComponent` (line 13430) - Local
- `TsgQuery.Create` (line 13435) - External
- `PlusUni.DataSet_ArraList` (line 13446) - Local
- `PlusUni.DataSet_ArraList` (line 13447) - Local
- `DmPlus.ManuDadoTabe` (line 13449) - External
- `PlusUni.Copy` (line 13451) - Local

#### function DataSet_FormValoCamp_Stri

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13504

**Calls Made:**

- `PlusUni.TipoDadoCara` (line 13511) - Local
- `PlusUni.FormNumeSQL` (line 13512) - Local
- `PlusUni.TipoDadoCara` (line 13513) - Local
- `PlusUni.FormDataSQL` (line 13514) - Local
- `PlusUni.QuotedStr` (line 13516) - Local

#### procedure CompAtuaTabeGravRegi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13521

**Calls Made:**

- `Orig.FieldByName` (line 13527) - External
- `PlusUni.to` (line 13529) - Local
- `PlusUni.CompAtuaTabeQualCamp` (line 13531) - Local
- `Dest.FieldByName` (line 13533) - External
- `Dest.FieldByName` (line 13534) - External
- `Orig.FieldByName` (line 13544) - External
- `PlusUni.to` (line 13546) - Local
- `PlusUni.CompAtuaTabeQualCamp` (line 13548) - Local
- `Dest.FieldByName` (line 13550) - External
- `Dest.FieldByName` (line 13551) - External
- `Orig.FieldByName` (line 13561) - External
- `PlusUni.to` (line 13563) - Local
- `PlusUni.CompAtuaTabeQualCamp` (line 13565) - Local
- `Dest.FieldByName` (line 13567) - External
- `Dest.FieldByName` (line 13568) - External

#### function ConvCampParaFigu

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13574

**Calls Made:**

- `TDataSource.Create` (line 13581) - External
- `TDBImgLbl.Create` (line 13582) - External

#### function ConvCampParaBMP_

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13596

**Calls Made:**

- `TDataSource.Create` (line 13602) - External
- `TDBImgLbl.Create` (line 13603) - External

#### procedure AbreQuerBookMark

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13619

**Calls Made:**

- `Qry.sgRefresh` (line 13623) - External

#### function isTime

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13628

**Calls Made:**

- `PlusUni.Length` (line 13632) - Local
- `PlusUni.SubsPalaTudo` (line 13632) - Local
- `PlusUni.or` (line 13632) - Local
- `PlusUni.Length` (line 13632) - Local
- `PlusUni.SubsPalaTudo` (line 13632) - Local
- `PlusUni.StrToTime` (line 13633) - Local

#### function isDateTime

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:13641

**Calls Made:**

- `PlusUni.Length` (line 13645) - Local
- `PlusUni.SubsPalaTudo` (line 13645) - Local
- `PlusUni.or` (line 13645) - Local
- `PlusUni.Length` (line 13645) - Local
- `PlusUni.SubsPalaTudo` (line 13645) - Local
- `PlusUni.StrToDateTime` (line 13646) - Local

#### procedure AbreWebBrowser

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14396

**Calls Made:**

- `TFrmPOChWebB.Create` (line 14400) - External

#### function ValiSenhDia

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14406

**Calls Made:**

- `PlusUni.IsRx9` (line 14408) - Local
- `PlusUni.IsMaquAuto` (line 14411) - Local
- `Application.CreateForm` (line 14416) - External
- `PlusUni.GeraSenhDia` (line 14420) - Local
- `PlusUni.msgOk` (line 14421) - Local

#### function ValiSenhDia_Teste

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14432

**Calls Made:**

- `Application.CreateForm` (line 14439) - External
- `PlusUni.IntToStr` (line 14443) - Local
- `PlusUni.sgStrToInt` (line 14443) - Local
- `PlusUni.GeraSenhDia` (line 14443) - Local
- `PlusUni.msgOk` (line 14444) - Local

#### function CriaAlteUsua

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14455

**Calls Made:**

- `PlusUni.AnsiUpperCase` (line 14461) - Local
- `PlusUni.CalcInte` (line 14467) - Local
- `PlusUni.COUNT` (line 14467) - Local
- `PlusUni.WHERE` (line 14467) - Local
- `PlusUni.QuotedStr` (line 14467) - Local
- `PlusUni.ExecSQL_` (line 14470) - Local
- `PlusUni.POCACONF` (line 14470) - Local
- `PlusUni.VALUES` (line 14470) - Local
- `PlusUni.QuotedStr` (line 14470) - Local
- `PlusUni.IntToStr` (line 14470) - Local
- `PlusUni.ExecSQL_` (line 14472) - Local
- `PlusUni.POCACONF` (line 14472) - Local
- `PlusUni.VALUES` (line 14472) - Local
- `PlusUni.QuotedStr` (line 14472) - Local
- `PlusUni.Trim` (line 14477) - Local
- `PlusUni.CalcStri` (line 14477) - Local
- `PlusUni.WHERE` (line 14477) - Local
- `PlusUni.QuotedStr` (line 14477) - Local
- `TsgQuery.Create` (line 14479) - External
- `PlusUni.SeStri` (line 14486) - Local
- `PlusUni.Chr` (line 14486) - Local
- `PlusUni.getQry` (line 14487) - Local
- `PlusUni.WHERE` (line 14487) - Local
- `PlusUni.and` (line 14494) - Local
- `PlusUni.ZeroEsqu` (line 14496) - Local
- `PlusUni.InttoStr` (line 14496) - Local
- `PlusUni.Inc` (line 14497) - Local
- `PlusUni.Inc` (line 14504) - Local
- `PlusUni.Inc` (line 14510) - Local
- `PlusUni.Inc` (line 14513) - Local
- `PlusUni.ExecSQL_` (line 14518) - Local
- `PlusUni.QuotedStr` (line 14518) - Local
- `PlusUni.ZeroEsqu` (line 14518) - Local
- `PlusUni.InttoStr` (line 14518) - Local
- `PlusUni.WHERE` (line 14519) - Local
- `PlusUni.QuotedStr` (line 14519) - Local
- `PlusUni.msgOk` (line 14522) - Local
- `PlusUni.Interno` (line 14522) - Local

#### function GetsgSenh

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14536

**Calls Made:**

- `PlusUni.Assigned` (line 14538) - Local

#### function DataSenh_FormToDate

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14555

**Calls Made:**

- `PlusUni.sgStrToInt` (line 14557) - Local
- `iData.Insert` (line 14559) - External
- `iData.Insert` (line 14560) - External
- `iData.Insert` (line 14561) - External
- `iData.Insert` (line 14562) - External
- `PlusUni.StrToDate` (line 14563) - Local
- `PlusUni.FormData` (line 14563) - Local

#### procedure GravaControles

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14566

**Calls Made:**

- `PlusUni.DataSenh_FormToDate` (line 14577) - Local
- `PlusUni.sgStrToInt` (line 14579) - Local
- `PlusUni.sgStrToInt` (line 14580) - Local

#### procedure SetDataAcesGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14591

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14593) - Local
- `PlusUni.FormatDateTime` (line 14593) - Local

#### procedure SetDataValiGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14596

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14598) - Local
- `PlusUni.FormatDateTime` (line 14598) - Local

#### procedure SetDataVencNumeGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14601

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14603) - Local
- `PlusUni.FormatDateTime` (line 14603) - Local

#### procedure SetDataVeriNumeGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14606

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14608) - Local
- `PlusUni.FormatDateTime` (line 14608) - Local

#### procedure SetNumeContGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14611

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14613) - Local
- `PlusUni.IntToStr` (line 14613) - Local

#### procedure SetNum1ContGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14616

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14618) - Local
- `PlusUni.IntToStr` (line 14618) - Local

#### procedure SetNumeAcesGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14621

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14623) - Local
- `PlusUni.IntToStr` (line 14623) - Local

#### procedure SetNumeSeriGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14626

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14628) - Local

#### procedure SetTipoContGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14631

**Calls Made:**

- `PlusUni.GravParaSenh` (line 14633) - Local

#### function GeraContra

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14643

**Calls Made:**

- `PlusUni.CalcInte` (line 14649) - Local
- `PlusUni.QuotedStr` (line 14649) - Local
- `PlusUni.CalcInte` (line 14650) - Local
- `PlusUni.IntToStr` (line 14650) - Local
- `PlusUni.CalcData` (line 14653) - Local
- `PlusUni.IntToStr` (line 14653) - Local
- `PlusUni.CalcData` (line 14654) - Local
- `PlusUni.IntToStr` (line 14654) - Local
- `PlusUni.CalcInte` (line 14659) - Local
- `PlusUni.IntToStr` (line 14659) - Local
- `PlusUni.CalcInte` (line 14660) - Local
- `PlusUni.IntToStr` (line 14660) - Local
- `PlusUni.Copy` (line 14661) - Local
- `PlusUni.CalcStri` (line 14662) - Local
- `PlusUni.IntToStr` (line 14662) - Local
- `PlusUni.GeraContra` (line 14664) - Local

#### function ValidaModulo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14668

**Calls Made:**

- `PlusUni.StrToInt` (line 14670) - Local
- `PlusUni.and` (line 14670) - Local
- `PlusUni.StrToInt` (line 14670) - Local

#### function ValidaModuloReal

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14674

_No outgoing calls_

#### function GetSQL_AcesUsua

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14691

**Calls Made:**

- `PlusUni.SeStri` (line 14693) - Local
- `PlusUni.SeStri` (line 14694) - Local
- `PlusUni.COUNT` (line 14695) - Local
- `PlusUni.SubsPala` (line 14697) - Local
- `PlusUni.AND` (line 14697) - Local
- `PlusUni.AND` (line 14697) - Local
- `PlusUni.AND` (line 14698) - Local

#### function GetSQL_Nume

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14702

**Calls Made:**

- `PlusUni.SeStri` (line 14709) - Local
- `PlusUni.SeStri` (line 14710) - Local
- `PlusUni.COUNT` (line 14711) - Local
- `PlusUni.GetSQL_AcesUsua` (line 14716) - Local
- `PlusUni.GetSQL_AcesUsua` (line 14718) - Local
- `PlusUni.AND` (line 14718) - Local
- `PlusUni.OR` (line 14718) - Local
- `PlusUni.SeStri` (line 14720) - Local
- `PlusUni.SeStri` (line 14721) - Local
- `PlusUni.COUNT` (line 14722) - Local
- `PlusUni.SeStri` (line 14729) - Local
- `PlusUni.SeStri` (line 14730) - Local
- `PlusUni.IncMonth` (line 14735) - Local
- `PlusUni.EncodeDate` (line 14736) - Local
- `PlusUni.Year` (line 14736) - Local
- `PlusUni.Month` (line 14736) - Local
- `PlusUni.EncodeDate` (line 14737) - Local
- `PlusUni.Year` (line 14737) - Local
- `PlusUni.Month` (line 14737) - Local
- `PlusUni.DaysInAMonth` (line 14737) - Local
- `PlusUni.Year` (line 14737) - Local
- `PlusUni.Month` (line 14737) - Local
- `PlusUni.StrToInt` (line 14739) - Local
- `PlusUni.SeStri` (line 14741) - Local
- `PlusUni.SeStri` (line 14742) - Local
- `PlusUni.SUM` (line 14743) - Local
- `PlusUni.WHERE` (line 14745) - Local
- `PlusUni.AND` (line 14745) - Local
- `PlusUni.AND` (line 14745) - Local
- `PlusUni.SeStri` (line 14747) - Local
- `PlusUni.SeStri` (line 14748) - Local
- `PlusUni.SUM` (line 14749) - Local
- `PlusUni.WHERE` (line 14751) - Local
- `PlusUni.AND` (line 14751) - Local
- `PlusUni.AND` (line 14751) - Local
- `PlusUni.SeStri` (line 14753) - Local
- `PlusUni.SeStri` (line 14754) - Local
- `PlusUni.SUM` (line 14755) - Local
- `PlusUni.WHERE` (line 14757) - Local
- `PlusUni.AND` (line 14757) - Local
- `PlusUni.AND` (line 14757) - Local
- `PlusUni.SeStri` (line 14759) - Local
- `PlusUni.SeStri` (line 14760) - Local
- `PlusUni.SUM` (line 14761) - Local
- `PlusUni.WHERE` (line 14763) - Local
- `PlusUni.AND` (line 14763) - Local
- `PlusUni.AND` (line 14763) - Local
- `PlusUni.FormNumeSQL` (line 14766) - Local
- `PlusUni.PegaParaNume` (line 14766) - Local
- `PlusUni.AND` (line 14768) - Local
- `PlusUni.SeStri` (line 14771) - Local
- `PlusUni.SeStri` (line 14772) - Local
- `PlusUni.SUM` (line 14773) - Local
- `PlusUni.WHERE` (line 14775) - Local
- `PlusUni.AND` (line 14775) - Local
- `PlusUni.FormDataSQL` (line 14775) - Local
- `PlusUni.FormDataSQL` (line 14775) - Local
- `PlusUni.SeStri` (line 14779) - Local
- `PlusUni.SUM` (line 14779) - Local
- `PlusUni.SeStri` (line 14780) - Local
- `PlusUni.SUM` (line 14780) - Local
- `PlusUni.SUM` (line 14781) - Local
- `PlusUni.WHERE` (line 14785) - Local
- `PlusUni.AND` (line 14785) - Local
- `PlusUni.AND` (line 14785) - Local
- `PlusUni.AND` (line 14785) - Local
- `PlusUni.FormDataSQL` (line 14785) - Local
- `PlusUni.FormDataSQL` (line 14785) - Local
- `PlusUni.SeStri` (line 14786) - Local
- `PlusUni.SeStri` (line 14787) - Local
- `PlusUni.SeStri` (line 14790) - Local
- `PlusUni.SUM` (line 14790) - Local
- `PlusUni.SeStri` (line 14791) - Local
- `PlusUni.DateTimeFormat` (line 14791) - Local
- `PlusUni.SUM` (line 14791) - Local
- `PlusUni.SUM` (line 14792) - Local
- `PlusUni.WHERE` (line 14794) - Local
- `PlusUni.FormDataSQL` (line 14794) - Local
- `PlusUni.FormDataSQL` (line 14794) - Local
- `PlusUni.SeStri` (line 14795) - Local
- `PlusUni.SeStri` (line 14796) - Local
- `PlusUni.DateTimeFormat` (line 14796) - Local
- `PlusUni.SeStri` (line 14798) - Local
- `PlusUni.SeStri` (line 14799) - Local
- `PlusUni.DateTimeFormat` (line 14799) - Local
- `PlusUni.SUM` (line 14799) - Local
- `PlusUni.SUM` (line 14800) - Local
- `PlusUni.WHERE` (line 14802) - Local
- `PlusUni.AND` (line 14802) - Local
- `PlusUni.AND` (line 14803) - Local
- `PlusUni.FormDataSQL` (line 14803) - Local
- `PlusUni.FormDataSQL` (line 14803) - Local
- `PlusUni.SeStri` (line 14804) - Local
- `PlusUni.DateTimeFormat` (line 14804) - Local
- `PlusUni.SeStri` (line 14806) - Local
- `PlusUni.SeStri` (line 14807) - Local
- `PlusUni.DateTimeFormat` (line 14807) - Local
- `PlusUni.COUNT` (line 14807) - Local
- `PlusUni.COUNT` (line 14808) - Local
- `PlusUni.WHERE` (line 14810) - Local
- `PlusUni.AND` (line 14810) - Local
- `PlusUni.FormDataSQL` (line 14810) - Local
- `PlusUni.FormDataSQL` (line 14810) - Local
- `PlusUni.SeStri` (line 14811) - Local
- `PlusUni.DateTimeFormat` (line 14811) - Local
- `PlusUni.SeStri` (line 14813) - Local
- `PlusUni.SeStri` (line 14814) - Local
- `PlusUni.COUNT` (line 14815) - Local
- `PlusUni.WHERE` (line 14817) - Local
- `PlusUni.AND` (line 14817) - Local
- `PlusUni.SeStri` (line 14819) - Local
- `PlusUni.SeStri` (line 14820) - Local
- `PlusUni.COUNT` (line 14821) - Local
- `PlusUni.WHERE` (line 14823) - Local
- `PlusUni.AND` (line 14823) - Local
- `PlusUni.SeStri` (line 14825) - Local
- `PlusUni.SeStri` (line 14826) - Local
- `PlusUni.COUNT` (line 14827) - Local
- `PlusUni.WHERE` (line 14829) - Local
- `PlusUni.or` (line 14829) - Local
- `PlusUni.AND` (line 14829) - Local
- `PlusUni.AND` (line 14829) - Local
- `PlusUni.StrLen` (line 14829) - Local
- `PlusUni.SeStri` (line 14831) - Local
- `PlusUni.SeStri` (line 14832) - Local
- `PlusUni.COUNT` (line 14833) - Local
- `PlusUni.WHERE` (line 14835) - Local
- `PlusUni.or` (line 14835) - Local
- `PlusUni.AND` (line 14835) - Local
- `PlusUni.AND` (line 14835) - Local
- `PlusUni.StrLen` (line 14835) - Local
- `PlusUni.SeStri` (line 14837) - Local
- `PlusUni.SeStri` (line 14838) - Local
- `PlusUni.COUNT` (line 14839) - Local
- `PlusUni.WHERE` (line 14841) - Local
- `PlusUni.or` (line 14841) - Local
- `PlusUni.AND` (line 14841) - Local
- `PlusUni.AND` (line 14841) - Local
- `PlusUni.StrLen` (line 14841) - Local
- `PlusUni.SeStri` (line 14843) - Local
- `PlusUni.SeStri` (line 14844) - Local
- `PlusUni.SeStri` (line 14848) - Local
- `PlusUni.SeStri` (line 14849) - Local
- `PlusUni.COUNT` (line 14850) - Local
- `PlusUni.WHERE` (line 14852) - Local
- `PlusUni.GetSQL_AcesUsua` (line 14855) - Local

#### function GetSQL_Num1

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14862

**Calls Made:**

- `PlusUni.SeStri` (line 14868) - Local
- `PlusUni.SeStri` (line 14869) - Local
- `PlusUni.COUNT` (line 14870) - Local
- `PlusUni.AND` (line 14872) - Local
- `PlusUni.SeStri` (line 14876) - Local
- `PlusUni.SeStri` (line 14877) - Local
- `PlusUni.COUNT` (line 14878) - Local
- `PlusUni.WHERE` (line 14880) - Local
- `PlusUni.QuotedStr` (line 14880) - Local
- `PlusUni.AnsiUpperCase` (line 14880) - Local
- `PlusUni.GetPApePess` (line 14880) - Local
- `PlusUni.AND` (line 14880) - Local
- `PlusUni.SYS_CONTEXT` (line 14880) - Local
- `PlusUni.SeStri` (line 14882) - Local
- `PlusUni.SeStri` (line 14883) - Local
- `PlusUni.COUNT` (line 14884) - Local
- `PlusUni.WHERE` (line 14886) - Local
- `PlusUni.and` (line 14886) - Local
- `PlusUni.AND` (line 14886) - Local
- `PlusUni.IncMonth` (line 14890) - Local
- `PlusUni.EncodeDate` (line 14891) - Local
- `PlusUni.Year` (line 14891) - Local
- `PlusUni.Month` (line 14891) - Local
- `PlusUni.EncodeDate` (line 14892) - Local
- `PlusUni.Year` (line 14892) - Local
- `PlusUni.Month` (line 14892) - Local
- `PlusUni.DaysInAMonth` (line 14892) - Local
- `PlusUni.Year` (line 14892) - Local
- `PlusUni.Month` (line 14892) - Local
- `PlusUni.StrToInt` (line 14894) - Local
- `PlusUni.SeStri` (line 14900) - Local
- `PlusUni.SUM` (line 14900) - Local
- `PlusUni.SeStri` (line 14901) - Local
- `PlusUni.DateTimeFormat` (line 14901) - Local
- `PlusUni.SUM` (line 14901) - Local
- `PlusUni.SUM` (line 14902) - Local
- `PlusUni.WHERE` (line 14904) - Local
- `PlusUni.IN` (line 14904) - Local
- `PlusUni.AND` (line 14904) - Local
- `PlusUni.FormDataSQL` (line 14904) - Local
- `PlusUni.FormDataSQL` (line 14904) - Local
- `PlusUni.SeStri` (line 14905) - Local
- `PlusUni.SeStri` (line 14906) - Local
- `PlusUni.DateTimeFormat` (line 14906) - Local

#### function GetNumeContReal

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14916

**Calls Made:**

- `PlusUni.Trim` (line 14918) - Local
- `PlusUni.CalcRegi` (line 14921) - Local
- `PlusUni.CalcInte` (line 14923) - Local

#### function GetNum1ContReal

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14929

**Calls Made:**

- `PlusUni.Trim` (line 14934) - Local
- `PlusUni.sgCopy` (line 14936) - Local
- `PlusUni.Copy` (line 14937) - Local
- `PlusUni.CalcRegi` (line 14940) - Local
- `PlusUni.CalcInte` (line 14942) - Local

#### function GetDataAcesGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14948

**Calls Made:**

- `PlusUni.DataSenh_FormToDate` (line 14950) - Local
- `PlusUni.PegaParaSenh` (line 14950) - Local

#### function GetDataValiGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14953

**Calls Made:**

- `PlusUni.DataSenh_FormToDate` (line 14955) - Local
- `PlusUni.PegaParaSenh` (line 14955) - Local

#### function GetDataVencNumeGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14958

**Calls Made:**

- `PlusUni.DataSenh_FormToDate` (line 14960) - Local
- `PlusUni.PegaParaSenh` (line 14960) - Local

#### function GetDataVeriNumeGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14963

**Calls Made:**

- `PlusUni.DataSenh_FormToDate` (line 14965) - Local
- `PlusUni.PegaParaSenh` (line 14965) - Local

#### function GetNumeAcesGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14968

**Calls Made:**

- `PlusUni.sgStrToInt` (line 14970) - Local
- `PlusUni.PegaParaSenh` (line 14970) - Local

#### function GetNum1ContGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14973

**Calls Made:**

- `PlusUni.sgStrToInt` (line 14975) - Local
- `PlusUni.PegaParaSenh` (line 14975) - Local

#### function GetNumeContGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14978

**Calls Made:**

- `PlusUni.sgStrToInt` (line 14980) - Local
- `PlusUni.PegaParaSenh` (line 14980) - Local

#### function GetNumeSeriGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14983

**Calls Made:**

- `PlusUni.PegaParaSenh` (line 14985) - Local

#### function GetTipoContGrav

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:14988

**Calls Made:**

- `PlusUni.PegaParaSenh` (line 14990) - Local

#### function GetCodiTabe

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15128

_No outgoing calls_

#### function GetFraMovi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15136

_No outgoing calls_

#### function GetPnlMovi

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15141

_No outgoing calls_

#### function GetPnlResu

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15146

_No outgoing calls_

#### procedure FSXXImNF_ProcessarNotas

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15151

**Calls Made:**

- `PlusUni.InicValoNota_Valo` (line 15178) - Local
- `PlusUni.QuotedStr` (line 15183) - Local
- `PlusUni.InicValoNota_FormData` (line 15193) - Local
- `PlusUni.EspaDire` (line 15195) - Local
- `PlusUni.Copy` (line 15195) - Local
- `PlusUni.EspaDire` (line 15196) - Local
- `PlusUni.Copy` (line 15196) - Local
- `PlusUni.EspaDire` (line 15197) - Local
- `PlusUni.Copy` (line 15197) - Local
- `PlusUni.BuscValo` (line 15201) - Local
- `PlusUni.IntToStr` (line 15204) - Local
- `PlusUni.and` (line 15204) - Local
- `PlusUni.QuotedStr` (line 15204) - Local
- `PlusUni.BuscValoLike` (line 15212) - Local
- `PlusUni.IntToStr` (line 15216) - Local
- `PlusUni.CompTextTerminado` (line 15220) - Local
- `PlusUni.BuscaBandeira` (line 15233) - Local
- `PlusUni.IntToStr` (line 15265) - Local
- `PlusUni.BuscaForma` (line 15269) - Local
- `PlusUni.BuscaTipo` (line 15279) - Local
- `PlusUni.Loja` (line 15287) - Local
- `PlusUni.Instantâneo` (line 15295) - Local
- `PlusUni.Instantâneo` (line 15298) - Local
- `PlusUni.IntToStr` (line 15303) - Local
- `PlusUni.SalvaInfoPaga` (line 15307) - Local
- `PlusUni.CalcInte` (line 15315) - Local
- `PlusUni.MAX` (line 15315) - Local
- `PlusUni.WHERE` (line 15315) - Local
- `PlusUni.QuotedStr` (line 15315) - Local
- `PlusUni.AND` (line 15315) - Local
- `PlusUni.StrToIntDef` (line 15318) - Local
- `PlusUni.BuscValoLike` (line 15318) - Local
- `PlusUni.StrToIntDef` (line 15319) - Local
- `PlusUni.BuscValoLike` (line 15319) - Local
- `PlusUni.BuscValoLike` (line 15320) - Local
- `PlusUni.StrToFloat` (line 15321) - Local
- `PlusUni.FormReal` (line 15321) - Local
- `PlusUni.BuscValoLike` (line 15321) - Local
- `PlusUni.BuscValoLike` (line 15322) - Local
- `PlusUni.BuscValoLike` (line 15323) - Local
- `PlusUni.StrToIntDef` (line 15324) - Local
- `PlusUni.BuscValoLike` (line 15324) - Local
- `PlusUni.BuscValoLike` (line 15325) - Local
- `PlusUni.StrToIntDef` (line 15326) - Local
- `PlusUni.BuscValoLike` (line 15326) - Local
- `PlusUni.BuscValoLike` (line 15327) - Local
- `PlusUni.BuscValoLike` (line 15328) - Local
- `PlusUni.BuscValoLike` (line 15329) - Local
- `PlusUni.BuscValoLike` (line 15331) - Local
- `PlusUni.Trim` (line 15332) - Local
- `PlusUni.StrToDate` (line 15333) - Local
- `PlusUni.FormData` (line 15333) - Local
- `PlusUni.InicValoNota_FormData` (line 15333) - Local
- `PlusUni.BuscValoLike` (line 15335) - Local
- `PlusUni.Trim` (line 15336) - Local
- `PlusUni.StrToFloat` (line 15337) - Local
- `PlusUni.FormReal` (line 15337) - Local
- `PlusUni.BuscaForma` (line 15339) - Local
- `PlusUni.BuscaTipo` (line 15340) - Local
- `PlusUni.BuscaBandeira` (line 15341) - Local
- `PlusUni.ExecSQL_` (line 15343) - Local
- `PlusUni.WHERE` (line 15343) - Local
- `PlusUni.IntToStr` (line 15343) - Local
- `PlusUni.InseDadoTabe` (line 15345) - Local
- `PlusUni.IntToStr` (line 15346) - Local
- `PlusUni.QuotedStr` (line 15347) - Local
- `PlusUni.QuotedStr` (line 15348) - Local
- `PlusUni.QuotedStr` (line 15349) - Local
- `PlusUni.FormNumeSQL` (line 15350) - Local
- `PlusUni.FormDataSQL` (line 15351) - Local
- `PlusUni.QuotedStr` (line 15352) - Local
- `PlusUni.QuotedStr` (line 15353) - Local
- `PlusUni.IntToStr` (line 15354) - Local
- `PlusUni.QuotedStr` (line 15355) - Local
- `PlusUni.QuotedStr` (line 15356) - Local
- `PlusUni.QuotedStr` (line 15357) - Local
- `PlusUni.QuotedStr` (line 15358) - Local
- `PlusUni.QuotedStr` (line 15359) - Local
- `PlusUni.FormNumeSQL` (line 15360) - Local
- `PlusUni.ConvertDataStringToDateTime` (line 15365) - Local
- `PlusUni.Copy` (line 15373) - Local
- `PlusUni.Length` (line 15373) - Local
- `PlusUni.Copy` (line 15374) - Local
- `PlusUni.RightStr` (line 15375) - Local
- `PlusUni.AnsiUpperCase` (line 15378) - Local
- `PlusUni.Copy` (line 15378) - Local
- `PlusUni.AnsiUpperCase` (line 15379) - Local
- `PlusUni.AnsiUpperCase` (line 15380) - Local
- `PlusUni.AnsiUpperCase` (line 15381) - Local
- `PlusUni.AnsiUpperCase` (line 15382) - Local
- `PlusUni.AnsiUpperCase` (line 15383) - Local
- `PlusUni.AnsiUpperCase` (line 15384) - Local
- `PlusUni.AnsiUpperCase` (line 15385) - Local
- `PlusUni.AnsiUpperCase` (line 15386) - Local
- `PlusUni.AnsiUpperCase` (line 15387) - Local
- `PlusUni.AnsiUpperCase` (line 15388) - Local
- `PlusUni.AnsiUpperCase` (line 15389) - Local
- `PlusUni.AnsiUpperCase` (line 15390) - Local
- `PlusUni.inválido` (line 15392) - Local
- `PlusUni.EncodeDate` (line 15396) - Local
- `PlusUni.StrToInt` (line 15396) - Local
- `PlusUni.StrToInt` (line 15396) - Local
- `PlusUni.Copy` (line 15396) - Local
- `PlusUni.StrToTime` (line 15397) - Local
- `PlusUni.ValidaFinanceiro_Gera` (line 15403) - Local
- `PlusUni.CalcInte` (line 15407) - Local
- `PlusUni.MAX` (line 15407) - Local
- `PlusUni.WHERE` (line 15409) - Local
- `PlusUni.IntToStr` (line 15409) - Local
- `PlusUni.ValidaImportacao_OK` (line 15414) - Local
- `PlusUni.CalcInte` (line 15417) - Local
- `PlusUni.COUNT` (line 15417) - Local
- `PlusUni.WHERE` (line 15417) - Local
- `PlusUni.QuotedStr` (line 15417) - Local
- `PlusUni.AND` (line 15417) - Local
- `PlusUni.Pos` (line 15421) - Local
- `PlusUni.Pos` (line 15424) - Local
- `PlusUni.SubsPalaTudo` (line 15430) - Local
- `PlusUni.SeStri` (line 15430) - Local
- `PlusUni.SubsPalaTudo` (line 15431) - Local
- `TsgQuery.Create` (line 15437) - External
- `TsgQuery.Create` (line 15438) - External
- `TsgQuery.Create` (line 15439) - External
- `TsgQuery.Create` (line 15440) - External
- `PlusUni.WHERE` (line 15453) - Local
- `PlusUni.QuotedStr` (line 15453) - Local
- `PlusUni.WHERE` (line 15456) - Local
- `PlusUni.QuotedStr` (line 15456) - Local
- `vPOGeNota_D.CarregaBD` (line 15473) - External
- `PlusUni.QuotedStr` (line 15473) - Local
- `PlusUni.ValidaImportacao_OK` (line 15479) - Local
- `PlusUni.and` (line 15483) - Local
- `PlusUni.and` (line 15483) - Local
- `PlusUni.StrToIntDef` (line 15485) - Local
- `PlusUni.InicValoNota_Valo` (line 15485) - Local
- `PlusUni.InicValoNota_Valo` (line 15486) - Local
- `PlusUni.InicValoNota_Valo` (line 15487) - Local
- `PlusUni.ContainsText` (line 15488) - Local
- `PlusUni.and` (line 15488) - Local
- `PlusUni.ContainsText` (line 15488) - Local
- `PlusUni.ContainsText` (line 15488) - Local
- `PlusUni.ContainsText` (line 15490) - Local
- `PlusUni.InicValoNota_Valo` (line 15492) - Local
- `PlusUni.InicValoNota_Valo` (line 15493) - Local
- `PlusUni.InicValoNota_Valo` (line 15495) - Local
- `PlusUni.InicValoNota_Valo` (line 15496) - Local
- `vPOGeNota_D.Salv_Prepara` (line 15500) - External
- `PlusUni.ContainsText` (line 15505) - Local
- `PlusUni.AlteDadoTabe` (line 15507) - Local
- `PlusUni.QuotedStr` (line 15508) - Local
- `PlusUni.IntToStr` (line 15510) - Local

#### function InicValoNota_Valo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15178

**Calls Made:**

- `PlusUni.QuotedStr` (line 15183) - Local

#### function InicValoNota_FormData

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15193

**Calls Made:**

- `PlusUni.EspaDire` (line 15195) - Local
- `PlusUni.Copy` (line 15195) - Local
- `PlusUni.EspaDire` (line 15196) - Local
- `PlusUni.Copy` (line 15196) - Local
- `PlusUni.EspaDire` (line 15197) - Local
- `PlusUni.Copy` (line 15197) - Local

#### function BuscValo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15201

**Calls Made:**

- `PlusUni.IntToStr` (line 15204) - Local
- `PlusUni.and` (line 15204) - Local
- `PlusUni.QuotedStr` (line 15204) - Local

#### function BuscValoLike

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15212

**Calls Made:**

- `PlusUni.IntToStr` (line 15216) - Local
- `PlusUni.CompTextTerminado` (line 15220) - Local

#### function BuscaBandeira

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15233

**Calls Made:**

- `PlusUni.IntToStr` (line 15265) - Local

#### function BuscaForma

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15269

_No outgoing calls_

#### function BuscaTipo

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15279

**Calls Made:**

- `PlusUni.Loja` (line 15287) - Local
- `PlusUni.Instantâneo` (line 15295) - Local
- `PlusUni.Instantâneo` (line 15298) - Local
- `PlusUni.IntToStr` (line 15303) - Local

#### procedure SalvaInfoPaga

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15307

**Calls Made:**

- `PlusUni.CalcInte` (line 15315) - Local
- `PlusUni.MAX` (line 15315) - Local
- `PlusUni.WHERE` (line 15315) - Local
- `PlusUni.QuotedStr` (line 15315) - Local
- `PlusUni.AND` (line 15315) - Local
- `PlusUni.StrToIntDef` (line 15318) - Local
- `PlusUni.BuscValoLike` (line 15318) - Local
- `PlusUni.StrToIntDef` (line 15319) - Local
- `PlusUni.BuscValoLike` (line 15319) - Local
- `PlusUni.BuscValoLike` (line 15320) - Local
- `PlusUni.StrToFloat` (line 15321) - Local
- `PlusUni.FormReal` (line 15321) - Local
- `PlusUni.BuscValoLike` (line 15321) - Local
- `PlusUni.BuscValoLike` (line 15322) - Local
- `PlusUni.BuscValoLike` (line 15323) - Local
- `PlusUni.StrToIntDef` (line 15324) - Local
- `PlusUni.BuscValoLike` (line 15324) - Local
- `PlusUni.BuscValoLike` (line 15325) - Local
- `PlusUni.StrToIntDef` (line 15326) - Local
- `PlusUni.BuscValoLike` (line 15326) - Local
- `PlusUni.BuscValoLike` (line 15327) - Local
- `PlusUni.BuscValoLike` (line 15328) - Local
- `PlusUni.BuscValoLike` (line 15329) - Local
- `PlusUni.BuscValoLike` (line 15331) - Local
- `PlusUni.Trim` (line 15332) - Local
- `PlusUni.StrToDate` (line 15333) - Local
- `PlusUni.FormData` (line 15333) - Local
- `PlusUni.InicValoNota_FormData` (line 15333) - Local
- `PlusUni.BuscValoLike` (line 15335) - Local
- `PlusUni.Trim` (line 15336) - Local
- `PlusUni.StrToFloat` (line 15337) - Local
- `PlusUni.FormReal` (line 15337) - Local
- `PlusUni.BuscaForma` (line 15339) - Local
- `PlusUni.BuscaTipo` (line 15340) - Local
- `PlusUni.BuscaBandeira` (line 15341) - Local
- `PlusUni.ExecSQL_` (line 15343) - Local
- `PlusUni.WHERE` (line 15343) - Local
- `PlusUni.IntToStr` (line 15343) - Local
- `PlusUni.InseDadoTabe` (line 15345) - Local
- `PlusUni.IntToStr` (line 15346) - Local
- `PlusUni.QuotedStr` (line 15347) - Local
- `PlusUni.QuotedStr` (line 15348) - Local
- `PlusUni.QuotedStr` (line 15349) - Local
- `PlusUni.FormNumeSQL` (line 15350) - Local
- `PlusUni.FormDataSQL` (line 15351) - Local
- `PlusUni.QuotedStr` (line 15352) - Local
- `PlusUni.QuotedStr` (line 15353) - Local
- `PlusUni.IntToStr` (line 15354) - Local
- `PlusUni.QuotedStr` (line 15355) - Local
- `PlusUni.QuotedStr` (line 15356) - Local
- `PlusUni.QuotedStr` (line 15357) - Local
- `PlusUni.QuotedStr` (line 15358) - Local
- `PlusUni.QuotedStr` (line 15359) - Local
- `PlusUni.FormNumeSQL` (line 15360) - Local

#### function ConvertDataStringToDateTime

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15365

**Calls Made:**

- `PlusUni.Copy` (line 15373) - Local
- `PlusUni.Length` (line 15373) - Local
- `PlusUni.Copy` (line 15374) - Local
- `PlusUni.RightStr` (line 15375) - Local
- `PlusUni.AnsiUpperCase` (line 15378) - Local
- `PlusUni.Copy` (line 15378) - Local
- `PlusUni.AnsiUpperCase` (line 15379) - Local
- `PlusUni.AnsiUpperCase` (line 15380) - Local
- `PlusUni.AnsiUpperCase` (line 15381) - Local
- `PlusUni.AnsiUpperCase` (line 15382) - Local
- `PlusUni.AnsiUpperCase` (line 15383) - Local
- `PlusUni.AnsiUpperCase` (line 15384) - Local
- `PlusUni.AnsiUpperCase` (line 15385) - Local
- `PlusUni.AnsiUpperCase` (line 15386) - Local
- `PlusUni.AnsiUpperCase` (line 15387) - Local
- `PlusUni.AnsiUpperCase` (line 15388) - Local
- `PlusUni.AnsiUpperCase` (line 15389) - Local
- `PlusUni.AnsiUpperCase` (line 15390) - Local
- `PlusUni.inválido` (line 15392) - Local
- `PlusUni.EncodeDate` (line 15396) - Local
- `PlusUni.StrToInt` (line 15396) - Local
- `PlusUni.StrToInt` (line 15396) - Local
- `PlusUni.Copy` (line 15396) - Local
- `PlusUni.StrToTime` (line 15397) - Local

#### function ValidaFinanceiro_Gera

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15403

**Calls Made:**

- `PlusUni.CalcInte` (line 15407) - Local
- `PlusUni.MAX` (line 15407) - Local
- `PlusUni.WHERE` (line 15409) - Local
- `PlusUni.IntToStr` (line 15409) - Local

#### function ValidaImportacao_OK

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:15414

**Calls Made:**

- `PlusUni.CalcInte` (line 15417) - Local
- `PlusUni.COUNT` (line 15417) - Local
- `PlusUni.WHERE` (line 15417) - Local
- `PlusUni.QuotedStr` (line 15417) - Local
- `PlusUni.AND` (line 15417) - Local

#### function FSXXImNF_BuscarNotas

**Location:** C:/Trabalho/Edata/GIT/MIMS_V7/SAG/PlusUni.pas:16109

**Calls Made:**

- `PlusUni.DirectoryExists` (line 16115) - Local
- `PlusUni.IncludeTrailingPathDelimiter` (line 16115) - Local
- `PlusUni.IncludeTrailingPathDelimiter` (line 16119) - Local
- `PlusUni.ExibMensHint` (line 16123) - Local
- `TDirectory.GetFiles` (line 16124) - External
- `PlusUni.Pos` (line 16126) - Local
- `ListaAuto.Add` (line 16127) - External
- `ListaCanc.Add` (line 16129) - External
- `PlusUni.ExibMensHint` (line 16131) - Local
- `PlusUni.IntToStr` (line 16131) - Local
- `PlusUni.IntToStr` (line 16131) - Local
- `PlusUni.ExibMensHint` (line 16136) - Local
- `PlusUni.IntToStr` (line 16136) - Local
- `PlusUni.IncludeTrailingPathDelimiter` (line 16139) - Local
- `PlusUni.ExtractFilePath` (line 16139) - Local
- `PlusUni.ExtractFileName` (line 16140) - Local
- `PlusUni.FileExists` (line 16141) - Local
- `PlusUni.DeleteFile` (line 16142) - Local
- `PlusUni.NFe_XML_ImpoXML_V20` (line 16146) - Local
- `PlusUni.AnsiUpperCase` (line 16149) - Local
- `PlusUni.AnsiUpperCase` (line 16149) - Local
- `PlusUni.FSXXImNF_ProcessarNotas` (line 16155) - Local
- `PlusUni.SubsPalaTudo` (line 16155) - Local
- `PlusUni.ExibMensHint` (line 16162) - Local
- `PlusUni.IntToStr` (line 16162) - Local
- `PlusUni.IncludeTrailingPathDelimiter` (line 16165) - Local
- `PlusUni.ExtractFilePath` (line 16165) - Local
- `PlusUni.ExtractFileName` (line 16166) - Local
- `PlusUni.FileExists` (line 16167) - Local
- `PlusUni.DeleteFile` (line 16168) - Local
- `PlusUni.NFe_XML_ImpoXML_V20` (line 16172) - Local
- `PlusUni.AnsiUpperCase` (line 16175) - Local
- `PlusUni.AnsiUpperCase` (line 16175) - Local
- `PlusUni.FSXXImNF_ProcessarNotas` (line 16181) - Local
- `PlusUni.SubsPalaTudo` (line 16181) - Local
- `PlusUni.FreeAndNil` (line 16187) - Local
- `PlusUni.FreeAndNil` (line 16188) - Local


---

## 🔄 Call Chains

### Chain 1 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 2 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 3 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 4 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 5 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 6 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 7 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 8 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 9 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.SubsCampPers → PlusUni.SubsCampPers
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.SubsCampPers` (line 2670)
- `PlusUni.SubsCampPers` (line 2670)

### Chain 10 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_BuscSQL → PlusUni.CampPersExecDireStri → PlusUni.CampPersExecListInst → PlusUni.CampPers_ChamTelaDire → PlusUni.CampPersExecListInst
```

**Nodes:**

- `PlusUni.CampPers_BuscSQL` (line 2557)
- `PlusUni.CampPersExecDireStri` (line 5617)
- `PlusUni.CampPersExecListInst` (line 3731)
- `PlusUni.CampPers_ChamTelaDire` (line 5851)
- `PlusUni.CampPersExecListInst` (line 3731)

### Chain 11 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 12 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 13 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 14 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 15 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 16 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquDes_Zipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquDes_Zipa` (line 13798)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 17 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquDes_Zipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquDes_Zipa` (line 13798)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 18 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 19 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)

### Chain 20 (Depth: 5) ⚠️ CIRCULAR

```
PlusUni.CampPers_EX → PlusUni.ImpoArqu → PlusUni.ArquValiEnde → PlusUni.ArquZipa → PlusUni.ArquValiEnde
```

**Nodes:**

- `PlusUni.CampPers_EX` (line 6376)
- `PlusUni.ImpoArqu` (line 10292)
- `PlusUni.ArquValiEnde` (line 13654)
- `PlusUni.ArquZipa` (line 13719)
- `PlusUni.ArquValiEnde` (line 13654)


---

## ⚠️ Circular Dependencies

The following circular dependencies were detected:

- PlusUni ↔ PlusUni

---

**Report generated by:** `map_method_calls.py` v2.3.0 (mode: focused)
**Generation time:** 2025-12-23 13:10:01
