unit SICxClasses;

// SICx classes

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}

interface

uses
  Windows, SICxDefs, SICxTypes;

type
  T_SICx = class
  protected
    procedure Setup (AConfig: Pointer);
    procedure CreateTables;
    procedure FreeTables;
    function  FunTableCreate: LongWord;
    procedure FunTableFree;
    function  FunLoad: LongWord;
    procedure FunUnload;
    function  ConTableCreate: LongWord;
    procedure ConTableFree;
    function  ConLoad: LongWord;
    procedure ConUnload;
    function  VarTableCreate: LongWord;
    procedure VarTableFree;
    function  VarLoad: LongWord;
    procedure VarUnload;
    function  RunTableCreate: LongWord;
    procedure RunTableFree;
    procedure Init (ASic: Pointer);
    procedure Done (ASic: Pointer);
    function  AddFun (ASic: Pointer; AFuname: PAnsiChar; AOffset: Pointer; AACount: Smallint; AFlags: Word): Integer;
    function  RenameFun (ASic: Pointer; AFuname: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer;
    function  DuplicateFun (ASic: Pointer; AFuname: PAnsiChar; AOrgname: PAnsiChar): Integer;
    function  AddConF (ASic: Pointer; AConame: PAnsiChar; AValue: Double): Integer;
    function  AddConI (ASic: Pointer; AConame: PAnsiChar; AValue: Integer): Integer;
    function  AddConS (ASic: Pointer; AConame: PAnsiChar; AValue: PAnsiChar): Integer;
    function  AddConO (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer;
    function  AddConP (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer;
    function  AddConPF (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer;
    function  AddConPI (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer;
    function  AddConPS (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer;
    function  RenameCon (ASic: Pointer; AConame: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer;
    function  DuplicateCon (ASic: Pointer; AConame: PAnsiChar; AOrgname: PAnsiChar): Integer;
    function  AddVarF (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarI (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarS (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarO (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarP (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarPF (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarPI (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  AddVarPS (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer;
    function  RenameVar (ASic: Pointer; AVaname: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer;
    function  DuplicateVar (ASic: Pointer; AVaname: PAnsiChar; AOrgname: PAnsiChar): Integer;
    function  InvalidateFun (ASic: Pointer; AFuname: PAnsiChar): Integer;
    function  InvalidateCon (ASic: Pointer; AConame: PAnsiChar): Integer;
    function  InvalidateVar (ASic: Pointer; AVaname: PAnsiChar): Integer;
    procedure PackTables (ASic: Pointer);
    procedure PackFunTable (ASic: Pointer);
    procedure PackConTable (ASic: Pointer);
    procedure PackVarTable (ASic: Pointer);
    function  GetFunTable (ASic: Pointer): PAnsiChar;
    function  GetFunCount (ASic: Pointer): LongWord;
    function  GetFunItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_FunItem): Integer;
    function  GetFunIndex (ASic: Pointer; AFuname: PAnsiChar): Integer;
    function  GetConTable (ASic: Pointer): PAnsiChar;
    function  GetConCount (ASic: Pointer): LongWord;
    function  GetConItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_ConItem): Integer;
    function  GetConIndex (ASic: Pointer; AConame: PAnsiChar): Integer;
    function  GetVarTable (ASic: Pointer): PAnsiChar;
    function  GetVarCount (ASic: Pointer): LongWord;
    function  GetVarItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_VarItem): Integer;
    function  GetVarIndex (ASic: Pointer; AVaname: PAnsiChar): Integer;
    function  GetRunTable (ASic: Pointer): PAnsiChar;
    function  GetRunCount (ASic: Pointer): LongWord;
    function  GetRunItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_ConItem): Integer;
    function  GetRunIndex (ASic: Pointer; ARuname: PAnsiChar): Integer;
    function  Compile (ASic: Pointer; S: PAnsiChar; ASop: LongWord): LongWord;
    function  Build (ASic: Pointer; S: PAnsiChar; ASop: LongWord): LongWord;
    function  Exec (ASic: Pointer; var AError: LongWord): Double;
    procedure Call (ASic: Pointer);
    function  CoExec (ASic: Pointer; S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double;
    function  BuExec (ASic: Pointer; S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double;
    function  SCoExec (S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double;
    function  SBuExec (S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double;
    function  va_count: Integer;
    function  inda (ACode: Pointer; AData: Pointer; Ax64: Byte): Integer;
    function  cpuseed: UIntX;
    function  cpuseed64: UInt64;
    function  cpuseed32: UInt32;
    function  cpuseed16: UInt16;
    function  cpurand: UIntX;
    function  cpurand64: UInt64;
    function  cpurand32: UInt32;
    function  cpurand16: UInt16;
    function  cpurandf: Double;
    function  cpurandf2pi: Double;
    function  mt19937_igen: UIntX;
    function  mt19937_fgen: Double;
    function  mt19937_fgen2pi: Double;
    procedure mt19937_seed (ASeed: UIntX);
    procedure mt19937_seeds (ASeeds: PUIntX; ACount: UIntX);
    function  sic_erf (A: Double): Double;
    function  sic_erfc (A: Double): Double;
    function  sic_cdfnorm (A: Double): Double;
    function  sic_erfinv (A: Double): Double;
    function  sic_erfcinv (A: Double): Double;
    function  sic_cdfnorminv (A: Double): Double;
    function  sic_lgamma (A: Double): Double;
    function  sic_lgammas (A: Double; var S: LongWord): Double;
    function  sic_tgamma (A: Double): Double;
    function  sic_rgamma (A: Double): Double;
    function  sic_rtgamma (A: Double): Double;
    function  sic_beta (A, B: Double): Double;
  end;

implementation

uses
  {$IFDEF SIC_DYNAMIC} SICxDProcs; {$ELSE} SICxProcs; {$ENDIF}

{ T_SICx }

procedure T_SICx.Setup (AConfig: Pointer);
begin
  sic_setup (AConfig);
end;

procedure T_SICx.CreateTables;
begin
  sic_cretab;
end;

procedure T_SICx.FreeTables;
begin
  sic_fretab;
end;

function T_SICx.FunTableCreate: LongWord;
begin
  Result := sic_funtac;
end;

procedure T_SICx.FunTableFree;
begin
  sic_funtaf;
end;

function T_SICx.FunLoad: LongWord;
begin
  Result := sic_funloa;
end;

procedure T_SICx.FunUnload;
begin
  sic_funulo;
end;

function T_SICx.ConTableCreate: LongWord;
begin
  Result := sic_contac;
end;

procedure T_SICx.ConTableFree;
begin
  sic_contaf;
end;

function T_SICx.ConLoad: LongWord;
begin
  Result := sic_conloa;
end;

procedure T_SICx.ConUnload;
begin
  sic_conulo;
end;

function T_SICx.VarTableCreate: LongWord;
begin
  Result := sic_vartac;
end;

procedure T_SICx.VarTableFree;
begin
  sic_vartaf;
end;

function T_SICx.VarLoad: LongWord;
begin
  Result := sic_varloa;
end;

procedure T_SICx.VarUnload;
begin
  sic_varulo;
end;

function T_SICx.RunTableCreate: LongWord;
begin
  Result := sic_runtac;
end;

procedure T_SICx.RunTableFree;
begin
  sic_runtaf;
end;

procedure T_SICx.Init (ASic: Pointer);
begin
  sic_init (ASic);
end;

procedure T_SICx.Done (ASic: Pointer);
begin
  sic_done (ASic);
end;

function T_SICx.AddFun (ASic: Pointer; AFuname: PAnsiChar; AOffset: Pointer;
  AACount: Smallint; AFlags: Word): Integer;
begin
  Result := sic_afun (ASic, AFuname, AOffset, AACount, AFlags);
end;

function T_SICx.RenameFun (ASic: Pointer; AFuname, AOrgname: PAnsiChar;
  AInvalidate: WordBool): Integer;
begin
  Result := sic_refun (ASic, AFuname, AOrgname, AInvalidate);
end;

function T_SICx.DuplicateFun (ASic: Pointer; AFuname, AOrgname: PAnsiChar): Integer;
begin
  Result := sic_dufun (ASic, AFuname, AOrgname);
end;

function T_SICx.AddConF (ASic: Pointer; AConame: PAnsiChar;
  AValue: Double): Integer;
begin
  Result := sic_aconf (ASic, AConame, AValue);
end;

function T_SICx.AddConI (ASic: Pointer; AConame: PAnsiChar;
  AValue: Integer): Integer;
begin
  Result := sic_aconi (ASic, AConame, AValue);
end;

function T_SICx.AddConS (ASic: Pointer; AConame,
  AValue: PAnsiChar): Integer;
begin
  Result := sic_acons (ASic, AConame, AValue);
end;

function T_SICx.AddConO (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_acono (ASic, AConame, AValue);
end;

function T_SICx.AddConP (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconp (ASic, AConame, AValue);
end;

function T_SICx.AddConPF (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconpf (ASic, AConame, AValue);
end;

function T_SICx.AddConPI (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconpi (ASic, AConame, AValue);
end;

function T_SICx.AddConPS (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconps (ASic, AConame, AValue);
end;

function T_SICx.RenameCon (ASic: Pointer; AConame, AOrgname: PAnsiChar;
  AInvalidate: WordBool): Integer;
begin
  Result := sic_recon (ASic, AConame, AOrgname, AInvalidate);
end;

function T_SICx.DuplicateCon (ASic: Pointer; AConame, AOrgname: PAnsiChar): Integer;
begin
  Result := sic_ducon (ASic, AConame, AOrgname);
end;

function T_SICx.AddVarF (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarf (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarI (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avari (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarS (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avars (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarO (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avaro (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarP (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarp (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarPF (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarpf (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarPI (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarpi (ASic, AVaname, AOffset);
end;

function T_SICx.AddVarPS (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarps (ASic, AVaname, AOffset);
end;

function T_SICx.RenameVar (ASic: Pointer; AVaname, AOrgname: PAnsiChar;
  AInvalidate: WordBool): Integer;
begin
  Result := sic_revar (ASic, AVaname, AOrgname, AInvalidate);
end;

function T_SICx.DuplicateVar (ASic: Pointer; AVaname, AOrgname: PAnsiChar): Integer;
begin
  Result := sic_duvar (ASic, AVaname, AOrgname);
end;

function T_SICx.InvalidateFun (ASic: Pointer; AFuname: PAnsiChar): Integer;
begin
  Result := sic_invaf (ASic, AFuname);
end;

function T_SICx.InvalidateCon (ASic: Pointer; AConame: PAnsiChar): Integer;
begin
  Result := sic_invac (ASic, AConame);
end;

function T_SICx.InvalidateVar (ASic: Pointer; AVaname: PAnsiChar): Integer;
begin
  Result := sic_invav (ASic, AVaname);
end;

procedure T_SICx.PackTables (ASic: Pointer);
begin
  sic_patab (ASic);
end;

procedure T_SICx.PackFunTable (ASic: Pointer);
begin
  sic_pafut (ASic);
end;

procedure T_SICx.PackConTable (ASic: Pointer);
begin
  sic_pacot (ASic);
end;

procedure T_SICx.PackVarTable (ASic: Pointer);
begin
  sic_pavat (ASic);
end;

function T_SICx.GetFunTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gefut (ASic);
end;

function T_SICx.GetFunCount (ASic: Pointer): LongWord;
begin
  Result := sic_gefuc (ASic);
end;

function T_SICx.GetFunItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_FunItem): Integer;
begin
  Result := sic_gefui (ASic, AIndex, @AItem);
end;

function T_SICx.GetFunIndex (ASic: Pointer; AFuname: PAnsiChar): Integer;
begin
  Result := sic_gefun (ASic, AFuname);
end;

function T_SICx.GetConTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gecot (ASic);
end;

function T_SICx.GetConCount (ASic: Pointer): LongWord;
begin
  Result := sic_gecoc (ASic);
end;

function T_SICx.GetConItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_ConItem): Integer;
begin
  Result := sic_gecoi (ASic, AIndex, @AItem);
end;

function T_SICx.GetConIndex (ASic: Pointer; AConame: PAnsiChar): Integer;
begin
  Result := sic_gecon (ASic, AConame);
end;

function T_SICx.GetVarTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gevat (ASic);
end;

function T_SICx.GetVarCount (ASic: Pointer): LongWord;
begin
  Result := sic_gevac (ASic);
end;

function T_SICx.GetVarItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_VarItem): Integer;
begin
  Result := sic_gevai (ASic, AIndex, @AItem);
end;

function T_SICx.GetVarIndex (ASic: Pointer; AVaname: PAnsiChar): Integer;
begin
  Result := sic_gevar (ASic, AVaname);
end;

function T_SICx.GetRunTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gerut (ASic);
end;

function T_SICx.GetRunCount (ASic: Pointer): LongWord;
begin
  Result := sic_geruc (ASic);
end;

function T_SICx.GetRunItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_ConItem): Integer;
begin
  Result := sic_gerui (ASic, AIndex, @AItem);
end;

function T_SICx.GetRunIndex (ASic: Pointer; ARuname: PAnsiChar): Integer;
begin
  Result := sic_gerun (ASic, ARuname);
end;

function T_SICx.Compile (ASic: Pointer; S: PAnsiChar;
  ASop: LongWord): LongWord;
begin
  Result := sic_compile (ASic, S, ASop);
end;

function T_SICx.Build (ASic: Pointer; S: PAnsiChar;
  ASop: LongWord): LongWord;
begin
  Result := sic_build (ASic, S, ASop);
end;

function T_SICx.Exec (ASic: Pointer; var AError: LongWord): Double;
begin
  Result := sic_exec (ASic, AError);
end;

procedure T_SICx.Call (ASic: Pointer);
begin
  sic_call (ASic);
end;

function T_SICx.CoExec (ASic: Pointer; S: PAnsiChar; var ASop,
  AError: LongWord): Double;
begin
  Result := sic_cexec (ASic, S, ASop, AError);
end;

function T_SICx.BuExec (ASic: Pointer; S: PAnsiChar; var ASop,
  AError: LongWord): Double;
begin
  Result := sic_bexec (ASic, S, ASop, AError);
end;

function T_SICx.SCoExec (S: PAnsiChar; var ASop, AError: LongWord): Double;
begin
  Result := sic_scexec (S, ASop, AError);
end;

function T_SICx.SBuExec (S: PAnsiChar; var ASop, AError: LongWord): Double;
begin
  Result := sic_sbexec (S, ASop, AError);
end;

function T_SICx.va_count: Integer;
begin
  Result := sic_va_count;
end;

function T_SICx.inda (ACode: Pointer; AData: Pointer; Ax64: Byte): Integer;
begin
  Result := sic_inda (ACode, AData, Ax64);
end;

function T_SICx.cpuseed: UIntX;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpuseed;
  {$ELSE}
  Result := SICxProcs.cpuseed;
  {$ENDIF}
end;

function T_SICx.cpuseed64: UInt64;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpuseed64;
  {$ELSE}
  Result := SICxProcs.cpuseed64;
  {$ENDIF}
end;

function T_SICx.cpuseed32: UInt32;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpuseed32;
  {$ELSE}
  Result := SICxProcs.cpuseed32;
  {$ENDIF}
end;

function T_SICx.cpuseed16: UInt16;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpuseed16;
  {$ELSE}
  Result := SICxProcs.cpuseed16;
  {$ENDIF}
end;

function T_SICx.cpurand: UIntX;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpurand;
  {$ELSE}
  Result := SICxProcs.cpurand;
  {$ENDIF}
end;

function T_SICx.cpurand64: UInt64;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpurand64;
  {$ELSE}
  Result := SICxProcs.cpurand64;
  {$ENDIF}
end;

function T_SICx.cpurand32: UInt32;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpurand32;
  {$ELSE}
  Result := SICxProcs.cpurand32;
  {$ENDIF}
end;

function T_SICx.cpurand16: UInt16;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpurand16;
  {$ELSE}
  Result := SICxProcs.cpurand16;
  {$ENDIF}
end;

function T_SICx.cpurandf: Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpurandf;
  {$ELSE}
  Result := SICxProcs.cpurandf;
  {$ENDIF}
end;

function T_SICx.cpurandf2pi: Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.cpurandf2pi;
  {$ELSE}
  Result := SICxProcs.cpurandf2pi;
  {$ENDIF}
end;

function T_SICx.mt19937_igen: UIntX;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.mt19937_igen;
  {$ELSE}
  Result := SICxProcs.mt19937_igen;
  {$ENDIF}
end;

function T_SICx.mt19937_fgen: Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.mt19937_fgen;
  {$ELSE}
  Result := SICxProcs.mt19937_fgen;
  {$ENDIF}
end;

function T_SICx.mt19937_fgen2pi: Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.mt19937_fgen2pi;
  {$ELSE}
  Result := SICxProcs.mt19937_fgen2pi;
  {$ENDIF}
end;

procedure T_SICx.mt19937_seed (ASeed: UIntX);
begin
  {$IFDEF SIC_DYNAMIC}
  SICxDProcs.mt19937_seed (ASeed);
  {$ELSE}
  SICxProcs.mt19937_seed (ASeed);
  {$ENDIF}
end;

procedure T_SICx.mt19937_seeds (ASeeds: PUIntX; ACount: UIntX);
begin
  {$IFDEF SIC_DYNAMIC}
  SICxDProcs.mt19937_seeds (ASeeds, ACount);
  {$ELSE}
  SICxProcs.mt19937_seeds (ASeeds, ACount);
  {$ENDIF}
end;

function T_SICx.sic_erf (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_erf (A);
  {$ELSE}
  Result := SICxProcs.sic_erf (A);
  {$ENDIF}
end;

function T_SICx.sic_erfc (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_erfc (A);
  {$ELSE}
  Result := SICxProcs.sic_erfc (A);
  {$ENDIF}
end;

function T_SICx.sic_cdfnorm (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_cdfnorm (A);
  {$ELSE}
  Result := SICxProcs.sic_cdfnorm (A);
  {$ENDIF}
end;

function T_SICx.sic_erfinv (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_erfinv (A);
  {$ELSE}
  Result := SICxProcs.sic_erfinv (A);
  {$ENDIF}
end;

function T_SICx.sic_erfcinv (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_erfcinv (A);
  {$ELSE}
  Result := SICxProcs.sic_erfcinv (A);
  {$ENDIF}
end;

function T_SICx.sic_cdfnorminv (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_cdfnorminv (A);
  {$ELSE}
  Result := SICxProcs.sic_cdfnorminv (A);
  {$ENDIF}
end;

function T_SICx.sic_lgamma (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_lgamma (A);
  {$ELSE}
  Result := SICxProcs.sic_lgamma (A);
  {$ENDIF}
end;

function T_SICx.sic_lgammas (A: Double; var S: LongWord): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_lgammas (A, S);
  {$ELSE}
  Result := SICxProcs.sic_lgammas (A, S);
  {$ENDIF}
end;

function T_SICx.sic_tgamma (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_tgamma (A);
  {$ELSE}
  Result := SICxProcs.sic_tgamma (A);
  {$ENDIF}
end;

function T_SICx.sic_rgamma (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_rgamma (A);
  {$ELSE}
  Result := SICxProcs.sic_rgamma (A);
  {$ENDIF}
end;

function T_SICx.sic_rtgamma (A: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_rtgamma (A);
  {$ELSE}
  Result := SICxProcs.sic_rtgamma (A);
  {$ENDIF}
end;

function T_SICx.sic_beta (A, B: Double): Double;
begin
  {$IFDEF SIC_DYNAMIC}
  Result := SICxDProcs.sic_beta (A, B);
  {$ELSE}
  Result := SICxProcs.sic_beta (A, B);
  {$ENDIF}
end;

end.

