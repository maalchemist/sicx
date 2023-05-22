unit SICs32_CO;

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.Classes, System.Win.ComObj, SICs32_TLB;

const
  B_0000 = 0;
  B_0001 = 1;
  B_0010 = 2;
  B_0011 = 3;
  B_0100 = 4;
  B_0101 = 5;
  B_0110 = 6;
  B_0111 = 7;
  B_1000 = 8;
  B_1001 = 9;
  B_1010 = 10;
  B_1011 = 11;
  B_1100 = 12;
  B_1101 = 13;
  B_1110 = 14;
  B_1111 = 15;

const
  SIC_FunNameSize = 50;
  SIC_ConNameSize = 44;
  SIC_VarNameSize = 44;

type
  TSIC__FunName = array [0..SIC_FunNameSize-1] of AnsiChar;
  TSIC__ConName = array [0..SIC_ConNameSize-1] of AnsiChar;
  TSIC__VarName = array [0..SIC_VarNameSize-1] of AnsiChar;

  TSIC__FunItem = packed record
    name   : TSIC__FunName; // Function name (zero terminated)
    retype : Int16;         // Function return type
    acount : Int16;         // Function argument count
    cosize : Int16;         // Function code size or flags
    offset : UInt64;        // Function offset
  end;

  TSIC__ConItem = packed record
    name   : TSIC__ConName; // Constant name (zero terminated)
    codata : UInt64;        // Constant data
    cotype : Int16;         // Constant type
    datype : Int16;         // Constant data type
    value  : Double;        // Constant value
  end;

  TSIC__VarItem = packed record
    name   : TSIC__VarName; // Variable name (zero terminated)
    vadata : UInt64;        // Variable data
    vatype : Int16;         // Variable type
    datype : Int16;         // Variable data type
    offset : UInt64;        // Variable offset
  end;

type
  T_SICs32 = class (TTypedComObject, ISICs32)
  protected
    function  Version: LongWord; stdcall;
    function  CPUSupport: WordBool; stdcall;
    procedure Setup (AConfig: Pointer); stdcall;
    procedure CreateTables; stdcall;
    procedure FreeTables; stdcall;
    function  FunTableCreate: LongWord; stdcall;
    procedure FunTableFree; stdcall;
    function  FunLoad: LongWord; stdcall;
    procedure FunUnload; stdcall;
    function  ConTableCreate: LongWord; stdcall;
    procedure ConTableFree; stdcall;
    function  ConLoad: LongWord; stdcall;
    procedure ConUnload; stdcall;
    function  VarTableCreate: LongWord; stdcall;
    procedure VarTableFree; stdcall;
    function  VarLoad: LongWord; stdcall;
    procedure VarUnload; stdcall;
    function  RunTableCreate: LongWord; stdcall;
    procedure RunTableFree; stdcall;
    procedure Init (ASic: Pointer); stdcall;
    procedure Done (ASic: Pointer); stdcall;
    function  AddFuns (ASic: Pointer): Integer; stdcall;
    function  AddFun (ASic: Pointer; AFuname: PAnsiChar; AOffset: Pointer; AACount: Smallint; AFlags: Word): Integer; stdcall;
    function  RenameFun (ASic: Pointer; AFuname: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer; stdcall;
    function  DuplicateFun (ASic: Pointer; AFuname: PAnsiChar; AOrgname: PAnsiChar): Integer; stdcall;
    function  ExchangeFun (ASic: Pointer; AFuname: PAnsiChar; AFunami: PAnsiChar): Integer; stdcall;
    function  AddConF (ASic: Pointer; AConame: PAnsiChar; AValue: Double): Integer; stdcall;
    function  AddConI (ASic: Pointer; AConame: PAnsiChar; AValue: Integer): Integer; stdcall;
    function  AddConS (ASic: Pointer; AConame: PAnsiChar; AValue: PAnsiChar): Integer; stdcall;
    function  AddConO (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function  AddConP (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function  AddConPF (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function  AddConPI (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function  AddConPS (ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function  RenameCon (ASic: Pointer; AConame: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer; stdcall;
    function  DuplicateCon (ASic: Pointer; AConame: PAnsiChar; AOrgname: PAnsiChar): Integer; stdcall;
    function  ExchangeCon (ASic: Pointer; AConame: PAnsiChar; AConami: PAnsiChar): Integer; stdcall;
    function  AddVarF (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarI (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarS (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarO (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarP (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarPF (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarPI (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  AddVarPS (ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function  RenameVar (ASic: Pointer; AVaname: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer; stdcall;
    function  DuplicateVar (ASic: Pointer; AVaname: PAnsiChar; AOrgname: PAnsiChar): Integer; stdcall;
    function  ExchangeVar (ASic: Pointer; AVaname: PAnsiChar; AVanami: PAnsiChar): Integer; stdcall;
    function  InvalidateFun (ASic: Pointer; AFuname: PAnsiChar): Integer; stdcall;
    function  InvalidateCon (ASic: Pointer; AConame: PAnsiChar): Integer; stdcall;
    function  InvalidateVar (ASic: Pointer; AVaname: PAnsiChar): Integer; stdcall;
    procedure PackTables (ASic: Pointer); stdcall;
    procedure PackFunTable (ASic: Pointer); stdcall;
    procedure PackConTable (ASic: Pointer); stdcall;
    procedure PackVarTable (ASic: Pointer); stdcall;
    function  GetFunTable (ASic: Pointer): PAnsiChar; stdcall;
    function  GetFunCount (ASic: Pointer): LongWord; stdcall;
    function  GetFunItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_FunItem): Integer; stdcall;
    function  GetFunIndex (ASic: Pointer; AFuname: PAnsiChar): Integer; stdcall;
    function  GetConTable (ASic: Pointer): PAnsiChar; stdcall;
    function  GetConCount (ASic: Pointer): LongWord; stdcall;
    function  GetConItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_ConItem): Integer; stdcall;
    function  GetConIndex (ASic: Pointer; AConame: PAnsiChar): Integer; stdcall;
    function  GetVarTable (ASic: Pointer): PAnsiChar; stdcall;
    function  GetVarCount (ASic: Pointer): LongWord; stdcall;
    function  GetVarItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_VarItem): Integer; stdcall;
    function  GetVarIndex (ASic: Pointer; AVaname: PAnsiChar): Integer; stdcall;
    function  GetRunTable (ASic: Pointer): PAnsiChar; stdcall;
    function  GetRunCount (ASic: Pointer): LongWord; stdcall;
    function  GetRunItem (ASic: Pointer; AIndex: Integer; var AItem: TSIC_ConItem): Integer; stdcall;
    function  GetRunIndex (ASic: Pointer; ARuname: PAnsiChar): Integer; stdcall;
    function  Compile (ASic: Pointer; S: PAnsiChar; ASop: LongWord): LongWord; stdcall;
    function  Build (ASic: Pointer; S: PAnsiChar; ASop: LongWord): LongWord; stdcall;
    function  Exec (ASic: Pointer; var AError: LongWord): Double; stdcall;
    procedure Call (ASic: Pointer); stdcall;
    function  CoExec (ASic: Pointer; S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function  BuExec (ASic: Pointer; S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function  SCoExec (S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function  SBuExec (S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function  va_count: Integer; stdcall;
    function  inda (ACode: Pointer; AData: Pointer; Ax64: Byte): Integer; stdcall;
    function  cpuseed: LongWord; stdcall;
    function  cpuseed64: Largeuint; stdcall;
    function  cpuseed32: LongWord; stdcall;
    function  cpuseed16: Word; stdcall;
    function  cpurand: LongWord; stdcall;
    function  cpurand64: Largeuint; stdcall;
    function  cpurand32: LongWord; stdcall;
    function  cpurand16: Word; stdcall;
    function  cpurandf: Double; stdcall;
    function  cpurandf2pi: Double; stdcall;
    function  mt19937_igen: LongWord; stdcall;
    function  mt19937_fgen: Double; stdcall;
    function  mt19937_fgen2pi: Double; stdcall;
    procedure mt19937_seed(ASeed: LongWord); stdcall;
    procedure mt19937_seeds(ASeeds: Pointer; ACount: LongWord); stdcall;
    function  sic_erf (A: Double): Double; stdcall;
    function  sic_erfc (A: Double): Double; stdcall;
    function  sic_cdfnorm (A: Double): Double; stdcall;
    function  sic_erfinv (A: Double): Double; stdcall;
    function  sic_erfcinv (A: Double): Double; stdcall;
    function  sic_cdfnorminv (A: Double): Double; stdcall;
    function  sic_lgamma (A: Double): Double; stdcall;
    function  sic_lgammas (A: Double; var S: LongWord): Double; stdcall;
    function  sic_tgamma (A: Double): Double; stdcall;
    function  sic_rgamma (A: Double): Double; stdcall;
    function  sic_rtgamma (A: Double): Double; stdcall;
    function  sic_beta (A, B: Double): Double; stdcall;
  end;

implementation

uses
  System.Win.ComServ, SICxDefs, SICxProcs;

{ T_SICs32 }

function T_SICs32.Version: LongWord;
begin
  Result := sic_version;
end;

function T_SICs32.CPUSupport: WordBool;
begin
  Result := sic_cpu_support;
end;

procedure T_SICs32.Setup (AConfig: Pointer);
begin
  sic_setup (AConfig);
end;

procedure T_SICs32.CreateTables;
begin
  sic_cretab;
end;

procedure T_SICs32.FreeTables;
begin
  sic_fretab;
end;

function T_SICs32.FunTableCreate: LongWord;
begin
  Result := sic_funtac;
end;

procedure T_SICs32.FunTableFree;
begin
  sic_funtaf;
end;

function T_SICs32.FunLoad: LongWord;
begin
  Result := sic_funloa;
end;

procedure T_SICs32.FunUnload;
begin
  sic_funulo;
end;

function T_SICs32.ConTableCreate: LongWord;
begin
  Result := sic_contac;
end;

procedure T_SICs32.ConTableFree;
begin
  sic_contaf;
end;

function T_SICs32.ConLoad: LongWord;
begin
  Result := sic_conloa;
end;

procedure T_SICs32.ConUnload;
begin
  sic_conulo;
end;

function T_SICs32.VarTableCreate: LongWord;
begin
  Result := sic_vartac;
end;

procedure T_SICs32.VarTableFree;
begin
  sic_vartaf;
end;

function T_SICs32.VarLoad: LongWord;
begin
  Result := sic_varloa;
end;

procedure T_SICs32.VarUnload;
begin
  sic_varulo;
end;

function T_SICs32.RunTableCreate: LongWord;
begin
  Result := sic_runtac;
end;

procedure T_SICs32.RunTableFree;
begin
  sic_runtaf;
end;

procedure T_SICs32.Init (ASic: Pointer);
begin
  sic_init (ASic);
end;

procedure T_SICs32.Done (ASic: Pointer);
begin
  sic_done (ASic);
end;

function T_SICs32.AddFuns (ASic: Pointer): Integer;
begin
  Result := 0;
  {$I T_SICx.AddFuns.pas}
end;

function T_SICs32.AddFun (ASic: Pointer; AFuname: PAnsiChar; AOffset: Pointer;
  AACount: Smallint; AFlags: Word): Integer;
begin
  Result := sic_afun (ASic, AFuname, AOffset, AACount, AFlags);
end;

function T_SICs32.RenameFun (ASic: Pointer; AFuname, AOrgname: PAnsiChar;
  AInvalidate: WordBool): Integer;
begin
  Result := sic_refun (ASic, AFuname, AOrgname, AInvalidate);
end;

function T_SICs32.DuplicateFun (ASic: Pointer; AFuname, AOrgname: PAnsiChar): Integer;
begin
  Result := sic_dufun (ASic, AFuname, AOrgname);
end;

function T_SICs32.ExchangeFun (ASic: Pointer; AFuname, AFunami: PAnsiChar): Integer;
begin
  Result := sic_exfun (ASic, AFuname, AFunami);
end;

function T_SICs32.AddConF (ASic: Pointer; AConame: PAnsiChar;
  AValue: Double): Integer;
begin
  Result := sic_aconf (ASic, AConame, AValue);
end;

function T_SICs32.AddConI (ASic: Pointer; AConame: PAnsiChar;
  AValue: Integer): Integer;
begin
  Result := sic_aconi (ASic, AConame, AValue);
end;

function T_SICs32.AddConS (ASic: Pointer; AConame,
  AValue: PAnsiChar): Integer;
begin
  Result := sic_acons (ASic, AConame, AValue);
end;

function T_SICs32.AddConO (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_acono (ASic, AConame, AValue);
end;

function T_SICs32.AddConP (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconp (ASic, AConame, AValue);
end;

function T_SICs32.AddConPF (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconpf (ASic, AConame, AValue);
end;

function T_SICs32.AddConPI(ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconpi (ASic, AConame, AValue);
end;

function T_SICs32.AddConPS (ASic: Pointer; AConame: PAnsiChar;
  AValue: Pointer): Integer;
begin
  Result := sic_aconps (ASic, AConame, AValue);
end;

function T_SICs32.RenameCon (ASic: Pointer; AConame, AOrgname: PAnsiChar;
  AInvalidate: WordBool): Integer;
begin
  Result := sic_recon (ASic, AConame, AOrgname, AInvalidate);
end;

function T_SICs32.DuplicateCon (ASic: Pointer; AConame, AOrgname: PAnsiChar): Integer;
begin
  Result := sic_ducon (ASic, AConame, AOrgname);
end;

function T_SICs32.ExchangeCon (ASic: Pointer; AConame, AConami: PAnsiChar): Integer;
begin
  Result := sic_excon (ASic, AConame, AConami);
end;

function T_SICs32.AddVarF (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarf (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarI (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avari (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarS (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avars (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarO (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avaro (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarP (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarp (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarPF (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarpf (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarPI (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarpi (ASic, AVaname, AOffset);
end;

function T_SICs32.AddVarPS (ASic: Pointer; AVaname: PAnsiChar;
  AOffset: Pointer): Integer;
begin
  Result := sic_avarps (ASic, AVaname, AOffset);
end;

function T_SICs32.RenameVar (ASic: Pointer; AVaname, AOrgname: PAnsiChar;
  AInvalidate: WordBool): Integer;
begin
  Result := sic_revar (ASic, AVaname, AOrgname, AInvalidate);
end;

function T_SICs32.DuplicateVar (ASic: Pointer; AVaname, AOrgname: PAnsiChar): Integer;
begin
  Result := sic_duvar (ASic, AVaname, AOrgname);
end;

function T_SICs32.ExchangeVar (ASic: Pointer; AVaname, AVanami: PAnsiChar): Integer;
begin
  Result := sic_exvar (ASic, AVaname, AVanami);
end;

function T_SICs32.InvalidateFun (ASic: Pointer; AFuname: PAnsiChar): Integer;
begin
  Result := sic_invaf (ASic, AFuname);
end;

function T_SICs32.InvalidateCon (ASic: Pointer; AConame: PAnsiChar): Integer;
begin
  Result := sic_invac (ASic, AConame);
end;

function T_SICs32.InvalidateVar (ASic: Pointer; AVaname: PAnsiChar): Integer;
begin
  Result := sic_invav (ASic, AVaname);
end;

procedure T_SICs32.PackTables (ASic: Pointer);
begin
  sic_patab (ASic);
end;

procedure T_SICs32.PackFunTable (ASic: Pointer);
begin
  sic_pafut (ASic);
end;

procedure T_SICs32.PackConTable (ASic: Pointer);
begin
  sic_pacot (ASic);
end;

procedure T_SICs32.PackVarTable (ASic: Pointer);
begin
  sic_pavat (ASic);
end;

function T_SICs32.GetFunTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gefut (ASic);
end;

function T_SICs32.GetFunCount (ASic: Pointer): LongWord;
begin
  Result := sic_gefuc (ASic);
end;

function T_SICs32.GetFunItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_FunItem): Integer;
var
  I : TSIC__FunItem;
begin
  Result := sic_gefui (ASic, AIndex, @I);
  {$I T_SICx.GetFunItem.pas}
end;

function T_SICs32.GetFunIndex (ASic: Pointer; AFuname: PAnsiChar): Integer;
begin
  Result := sic_gefun (ASic, AFuname);
end;

function T_SICs32.GetConTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gecot (ASic);
end;

function T_SICs32.GetConCount (ASic: Pointer): LongWord;
begin
  Result := sic_gecoc (ASic);
end;

function T_SICs32.GetConItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_ConItem): Integer;
var
  I : TSIC__ConItem;
begin
  Result := sic_gecoi (ASic, AIndex, @I);
  {$I T_SICx.GetConItem.pas}
end;

function T_SICs32.GetConIndex (ASic: Pointer; AConame: PAnsiChar): Integer;
begin
  Result := sic_gecon (ASic, AConame);
end;

function T_SICs32.GetVarTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gevat (ASic);
end;

function T_SICs32.GetVarCount (ASic: Pointer): LongWord;
begin
  Result := sic_gevac (ASic);
end;

function T_SICs32.GetVarItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_VarItem): Integer;
var
  I : TSIC__VarItem;
begin
  Result := sic_gevai (ASic, AIndex, @I);
  {$I T_SICx.GetVarItem.pas}
end;

function T_SICs32.GetVarIndex (ASic: Pointer; AVaname: PAnsiChar): Integer;
begin
  Result := sic_gevar (ASic, AVaname);
end;

function T_SICs32.GetRunTable (ASic: Pointer): PAnsiChar;
begin
  Result := sic_gerut (ASic);
end;

function T_SICs32.GetRunCount (ASic: Pointer): LongWord;
begin
  Result := sic_geruc (ASic);
end;

function T_SICs32.GetRunItem (ASic: Pointer; AIndex: Integer;
  var AItem: TSIC_ConItem): Integer;
var
  I : TSIC__ConItem;
begin
  Result := sic_gerui (ASic, AIndex, @I);
  {$I T_SICx.GetRunItem.pas}
end;

function T_SICs32.GetRunIndex (ASic: Pointer; ARuname: PAnsiChar): Integer;
begin
  Result := sic_gerun (ASic, ARuname);
end;

function T_SICs32.Compile (ASic: Pointer; S: PAnsiChar;
  ASop: LongWord): LongWord;
begin
  Result := sic_compile (ASic, S, ASop);
end;

function T_SICs32.Build (ASic: Pointer; S: PAnsiChar;
  ASop: LongWord): LongWord;
begin
  Result := sic_build (ASic, S, ASop);
end;

function T_SICs32.Exec (ASic: Pointer; var AError: LongWord): Double;
begin
  Result := sic_exec (ASic, AError);
end;

procedure T_SICs32.Call (ASic: Pointer);
begin
  sic_call (ASic);
end;

function T_SICs32.CoExec (ASic: Pointer; S: PAnsiChar; var ASop,
  AError: LongWord): Double;
begin
  Result := sic_cexec (ASic, S, ASop, AError);
end;

function T_SICs32.BuExec (ASic: Pointer; S: PAnsiChar; var ASop,
  AError: LongWord): Double;
begin
  Result := sic_bexec (ASic, S, ASop, AError);
end;

function T_SICs32.SCoExec (S: PAnsiChar; var ASop, AError: LongWord): Double;
begin
  Result := sic_scexec (S, ASop, AError);
end;

function T_SICs32.SBuExec (S: PAnsiChar; var ASop, AError: LongWord): Double;
begin
  Result := sic_sbexec (S, ASop, AError);
end;

function T_SICs32.va_count: Integer;
begin
  Result := sic_va_count;
end;

function T_SICs32.inda (ACode: Pointer; AData: Pointer; Ax64: Byte): Integer;
begin
  Result := sic_inda (ACode, AData, Ax64);
end;

function T_SICs32.cpuseed: LongWord;
begin
  Result := SICxProcs.cpuseed;
end;

function T_SICs32.cpuseed64: Largeuint;
begin
  Result := SICxProcs.cpuseed64;
end;

function T_SICs32.cpuseed32: LongWord;
begin
  Result := SICxProcs.cpuseed32;
end;

function T_SICs32.cpuseed16: Word;
begin
  Result := SICxProcs.cpuseed16;
end;

function T_SICs32.cpurand: LongWord;
begin
  Result := SICxProcs.cpurand;
end;

function T_SICs32.cpurand64: Largeuint;
begin
  Result := SICxProcs.cpurand64;
end;

function T_SICs32.cpurand32: LongWord;
begin
  Result := SICxProcs.cpurand32;
end;

function T_SICs32.cpurand16: Word;
begin
  Result := SICxProcs.cpurand16;
end;

function T_SICs32.cpurandf: Double;
begin
  Result := SICxProcs.cpurandf;
end;

function T_SICs32.cpurandf2pi: Double;
begin
  Result := SICxProcs.cpurandf2pi;
end;

function T_SICs32.mt19937_igen: LongWord;
begin
  Result := SICxProcs.mt19937_igen;
end;

function T_SICs32.mt19937_fgen: Double;
begin
  Result := SICxProcs.mt19937_fgen;
end;

function T_SICs32.mt19937_fgen2pi: Double;
begin
  Result := SICxProcs.mt19937_fgen2pi;
end;

procedure T_SICs32.mt19937_seed (ASeed: LongWord);
begin
  SICxProcs.mt19937_seed (ASeed);
end;

procedure T_SICs32.mt19937_seeds (ASeeds: Pointer; ACount: LongWord);
begin
  SICxProcs.mt19937_seeds (ASeeds, ACount);
end;

function T_SICs32.sic_erf (A: Double): Double;
begin
  Result := SICxProcs.sic_erf (A);
end;

function T_SICs32.sic_erfc (A: Double): Double;
begin
  Result := SICxProcs.sic_erfc (A);
end;

function T_SICs32.sic_cdfnorm (A: Double): Double;
begin
  Result := SICxProcs.sic_cdfnorm (A);
end;

function T_SICs32.sic_erfinv (A: Double): Double;
begin
  Result := SICxProcs.sic_erfinv (A);
end;

function T_SICs32.sic_erfcinv (A: Double): Double;
begin
  Result := SICxProcs.sic_erfcinv (A);
end;

function T_SICs32.sic_cdfnorminv (A: Double): Double;
begin
  Result := SICxProcs.sic_cdfnorminv (A);
end;

function T_SICs32.sic_lgamma (A: Double): Double;
begin
  Result := SICxProcs.sic_lgamma (A);
end;

function T_SICs32.sic_lgammas (A: Double; var S: LongWord): Double;
begin
  Result := SICxProcs.sic_lgammas (A, S);
end;

function T_SICs32.sic_tgamma (A: Double): Double;
begin
  Result := SICxProcs.sic_tgamma (A);
end;

function T_SICs32.sic_rgamma (A: Double): Double;
begin
  Result := SICxProcs.sic_rgamma (A);
end;

function T_SICs32.sic_rtgamma (A: Double): Double;
begin
  Result := SICxProcs.sic_rtgamma (A);
end;

function T_SICs32.sic_beta (A, B: Double): Double;
begin
  Result := SICxProcs.sic_beta (A, B);
end;

initialization
  {$IFDEF SIC_OCX}
  TTypedComObjectFactory.Create (ComServer, T_SICs32, CLASS_SICos32,
    ciMultiInstance, tmApartment);
  {$ENDIF}

end.

