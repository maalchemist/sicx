unit SICxDProcs;

// SICx.DLL procs
// Dynamic

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
  T_sic_version = function: DWORD; stdcall;
  T_sic_cpu_support = function: BOOL; stdcall;
  T_sic_setup = procedure (AConfig: PSIC_Config); stdcall;
  T_sic_cretab = procedure; stdcall;
  T_sic_fretab = procedure; stdcall;
  T_sic_funtac = function: DWORD; stdcall;
  T_sic_funtaf = procedure; stdcall;
  T_sic_funloa = function: DWORD; stdcall;
  T_sic_funulo = procedure; stdcall;
  T_sic_contac = function: DWORD; stdcall;
  T_sic_contaf = procedure ; stdcall;
  T_sic_conloa = function: DWORD; stdcall;
  T_sic_conulo = procedure; stdcall;
  T_sic_vartac = function: DWORD; stdcall;
  T_sic_vartaf = procedure; stdcall;
  T_sic_varloa = function: DWORD; stdcall;
  T_sic_varulo = procedure; stdcall;
  T_sic_runtac = function: DWORD; stdcall;
  T_sic_runtaf = procedure; stdcall;
  T_sic_init = procedure (ASic: PSIC_Data); stdcall;
  T_sic_done = procedure (ASic: PSIC_Data); stdcall;
  T_sic_afun = function (ASic: PSIC_Data; AFuname: PAnsiChar; AOffset: Pointer; AACount: Int16; AFlags: UInt16): Integer; stdcall;
  T_sic_refun = function (ASic: PSIC_Data; AFuname, AOrgname: PAnsiChar; AInvalidate: BOOL): Integer; stdcall;
  T_sic_dufun = function (ASic: PSIC_Data; AFuname, AOrgname: PAnsiChar): Integer; stdcall;
  T_sic_exfun = function (ASic: PSIC_Data; AFuname, AFunami: PAnsiChar): Integer; stdcall;
  T_sic_aconf = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Double): Integer; stdcall;
  T_sic_aconi = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: INT_PTR): Integer; stdcall;
  T_sic_acons = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: PAnsiChar): Integer; stdcall;
  T_sic_acono = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
  T_sic_aconp = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
  T_sic_aconpf = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
  T_sic_aconpi = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
  T_sic_aconps = function (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
  T_sic_recon = function (ASic: PSIC_Data; AConame, AOrgname: PAnsiChar; AInvalidate: BOOL): Integer; stdcall;
  T_sic_ducon = function (ASic: PSIC_Data; AConame, AOrgname: PAnsiChar): Integer; stdcall;
  T_sic_excon = function (ASic: PSIC_Data; AConame, AConami: PAnsiChar): Integer; stdcall;
  T_sic_avarf = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avari = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avars = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avaro = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avarp = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avarpf = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avarpi = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_avarps = function (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
  T_sic_revar = function (ASic: PSIC_Data; AVaname, AOrgname: PAnsiChar; AInvalidate: BOOL): Integer; stdcall;
  T_sic_duvar = function (ASic: PSIC_Data; AVaname, AOrgname: PAnsiChar): Integer; stdcall;
  T_sic_exvar = function (ASic: PSIC_Data; AVaname, AVanami: PAnsiChar): Integer; stdcall;
  T_sic_invaf = function (ASic: PSIC_Data; AFuname: PAnsiChar): Integer; stdcall;
  T_sic_invac = function (ASic: PSIC_Data; AConame: PAnsiChar): Integer; stdcall;
  T_sic_invav = function (ASic: PSIC_Data; AVaname: PAnsiChar): Integer; stdcall;
  T_sic_patab = procedure (ASic: PSIC_Data); stdcall;
  T_sic_pafut = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_pacot = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_pavat = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_gefut = function (ASic: PSIC_Data): Pointer; stdcall;
  T_sic_gefuc = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_gefui = function (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_FunItem): Integer; stdcall;
  T_sic_gefun = function (ASic: PSIC_Data; AFuname: PAnsiChar): Integer; stdcall;
  T_sic_gecot = function (ASic: PSIC_Data): Pointer; stdcall;
  T_sic_gecoc = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_gecoi = function (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_ConItem): Integer; stdcall;
  T_sic_gecon = function (ASic: PSIC_Data; AConame: PAnsiChar): Integer; stdcall;
  T_sic_gevat = function (ASic: PSIC_Data): Pointer; stdcall;
  T_sic_gevac = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_gevai = function (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_VarItem): Integer; stdcall;
  T_sic_gevar = function (ASic: PSIC_Data; AVaname: PAnsiChar): Integer; stdcall;
  T_sic_gerut = function (ASic: PSIC_Data): Pointer; stdcall;
  T_sic_geruc = function (ASic: PSIC_Data): DWORD; stdcall;
  T_sic_gerui = function (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_ConItem): Integer; stdcall;
  T_sic_gerun = function (ASic: PSIC_Data; ARuname: PAnsiChar): Integer; stdcall;
  T_sic_compile = function (ASic: PSIC_Data; S: PAnsiChar; ASop: DWORD): DWORD; stdcall;
  T_sic_build = function (ASic: PSIC_Data; S: PAnsiChar; ASop: DWORD): DWORD; stdcall;
  T_sic_exec = function (ASic: PSIC_Data; var AError: DWORD): Double; stdcall;
  T_sic_call = procedure (ASic: PSIC_Data); stdcall;
  T_sic_cexec = function (ASic: PSIC_Data; S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
  T_sic_bexec = function (ASic: PSIC_Data; S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
  T_sic_scexec = function (S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
  T_sic_sbexec = function (S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
  T_sic_va_count = function: Integer; stdcall;
  T_sic_inda = function (code: Pointer; data: Pointer; x64: Byte): Integer; stdcall;

  T_cpuseed = function: UIntX; stdcall;
  T_cpuseed64 = function: UInt64; stdcall;
  T_cpuseed32 = function: UInt32; stdcall;
  T_cpuseed16 = function: UInt16; stdcall;
  T_cpurand = function: UIntX; stdcall;
  T_cpurand64 = function: UInt64; stdcall;
  T_cpurand32 = function: UInt32; stdcall;
  T_cpurand16 = function: UInt16; stdcall;
  T_cpurandf = function: Double; stdcall;
  T_cpurandf2pi = function: Double; stdcall;

  T_mt19937_igen = function: UIntX; stdcall;
  T_mt19937_fgen = function: Double; stdcall;
  T_mt19937_fgen2pi = function: Double; stdcall;
  T_mt19937_seed = procedure (ASeed: UIntX); stdcall;
  T_mt19937_seeds = procedure (ASeeds: PUIntX; ACount: UIntX); stdcall;

  T_sic_erf = function (A: Double): Double; stdcall;
  T_sic_erfc = function (A: Double): Double; stdcall;
  T_sic_cdfnorm = function (A: Double): Double; stdcall;
  T_sic_erfinv = function (A: Double): Double; stdcall;
  T_sic_erfcinv = function (A: Double): Double; stdcall;
  T_sic_cdfnorminv = function (A: Double): Double; stdcall;
  T_sic_lgamma = function (A: Double): Double; stdcall;
  T_sic_lgammas = function (A: Double; var S: DWORD): Double; stdcall;
  T_sic_tgamma = function (A: Double): Double; stdcall;
  T_sic_rgamma = function (A: Double): Double; stdcall;
  T_sic_rtgamma = function (A: Double): Double; stdcall;
  T_sic_beta = function (A, B: Double): Double; stdcall;

var
  sic_version: T_sic_version = nil;
  sic_cpu_support: T_sic_cpu_support = nil;
  sic_setup: T_sic_setup = nil;
  sic_cretab: T_sic_cretab = nil;
  sic_fretab: T_sic_fretab = nil;
  sic_funtac: T_sic_funtac = nil;
  sic_funtaf: T_sic_funtaf = nil;
  sic_funloa: T_sic_funloa = nil;
  sic_funulo: T_sic_funulo = nil;
  sic_contac: T_sic_contac = nil;
  sic_contaf: T_sic_contaf = nil;
  sic_conloa: T_sic_conloa = nil;
  sic_conulo: T_sic_conulo = nil;
  sic_vartac: T_sic_vartac = nil;
  sic_vartaf: T_sic_vartaf = nil;
  sic_varloa: T_sic_varloa = nil;
  sic_varulo: T_sic_varulo = nil;
  sic_runtac: T_sic_runtac = nil;
  sic_runtaf: T_sic_runtaf = nil;
  sic_init: T_sic_init = nil;
  sic_done: T_sic_done = nil;
  sic_afun: T_sic_afun = nil;
  sic_refun: T_sic_refun = nil;
  sic_dufun: T_sic_dufun = nil;
  sic_exfun: T_sic_exfun = nil;
  sic_aconf: T_sic_aconf = nil;
  sic_aconi: T_sic_aconi = nil;
  sic_acons: T_sic_acons = nil;
  sic_acono: T_sic_acono = nil;
  sic_aconp: T_sic_aconp = nil;
  sic_aconpf: T_sic_aconpf = nil;
  sic_aconpi: T_sic_aconpi = nil;
  sic_aconps: T_sic_aconps = nil;
  sic_recon: T_sic_recon = nil;
  sic_ducon: T_sic_ducon = nil;
  sic_excon: T_sic_excon = nil;
  sic_avarf: T_sic_avarf = nil;
  sic_avari: T_sic_avari = nil;
  sic_avars: T_sic_avars = nil;
  sic_avaro: T_sic_avaro = nil;
  sic_avarp: T_sic_avarp = nil;
  sic_avarpf: T_sic_avarpf = nil;
  sic_avarpi: T_sic_avarpi = nil;
  sic_avarps: T_sic_avarps = nil;
  sic_revar: T_sic_revar = nil;
  sic_duvar: T_sic_duvar = nil;
  sic_exvar: T_sic_exvar = nil;
  sic_invaf: T_sic_invaf = nil;
  sic_invac: T_sic_invac = nil;
  sic_invav: T_sic_invav = nil;
  sic_patab: T_sic_patab = nil;
  sic_pafut: T_sic_pafut = nil;
  sic_pacot: T_sic_pacot = nil;
  sic_pavat: T_sic_pavat = nil;
  sic_gefut: T_sic_gefut = nil;
  sic_gefuc: T_sic_gefuc = nil;
  sic_gefui: T_sic_gefui = nil;
  sic_gefun: T_sic_gefun = nil;
  sic_gecot: T_sic_gecot = nil;
  sic_gecoc: T_sic_gecoc = nil;
  sic_gecoi: T_sic_gecoi = nil;
  sic_gecon: T_sic_gecon = nil;
  sic_gevat: T_sic_gevat = nil;
  sic_gevac: T_sic_gevac = nil;
  sic_gevai: T_sic_gevai = nil;
  sic_gevar: T_sic_gevar = nil;
  sic_gerut: T_sic_gerut = nil;
  sic_geruc: T_sic_geruc = nil;
  sic_gerui: T_sic_gerui = nil;
  sic_gerun: T_sic_gerun = nil;
  sic_compile: T_sic_compile = nil;
  sic_build: T_sic_build = nil;
  sic_exec: T_sic_exec = nil;
  sic_call: T_sic_call = nil;
  sic_cexec: T_sic_cexec = nil;
  sic_bexec: T_sic_bexec = nil;
  sic_scexec: T_sic_scexec = nil;
  sic_sbexec: T_sic_sbexec = nil;
  sic_va_count: T_sic_va_count = nil;
  sic_inda: T_sic_inda = nil;

  cpuseed : T_cpuseed = nil;
  cpuseed64 : T_cpuseed64 = nil;
  cpuseed32 : T_cpuseed32 = nil;
  cpuseed16 : T_cpuseed16 = nil;
  cpurand : T_cpurand = nil;
  cpurand64 : T_cpurand64 = nil;
  cpurand32 : T_cpurand32 = nil;
  cpurand16 : T_cpurand16 = nil;
  cpurandf : T_cpurandf = nil;
  cpurandf2pi : T_cpurandf2pi = nil;

  mt19937_igen: T_mt19937_igen = nil;
  mt19937_fgen: T_mt19937_fgen = nil;
  mt19937_fgen2pi: T_mt19937_fgen2pi = nil;
  mt19937_seed: T_mt19937_seed = nil;
  mt19937_seeds: T_mt19937_seeds = nil;

  sic_erf: T_sic_erf = nil;
  sic_erfc: T_sic_erfc = nil;
  sic_cdfnorm: T_sic_cdfnorm = nil;
  sic_erfinv: T_sic_erfinv = nil;
  sic_erfcinv: T_sic_erfcinv = nil;
  sic_cdfnorminv: T_sic_cdfnorminv = nil;
  sic_lgamma: T_sic_lgamma = nil;
  sic_lgammas: T_sic_lgammas = nil;
  sic_tgamma: T_sic_tgamma = nil;
  sic_rgamma: T_sic_rgamma = nil;
  sic_rtgamma: T_sic_rtgamma = nil;
  sic_beta: T_sic_beta = nil;

function  SICxDLL: string;
procedure SICxLoad (const SDLL: string);
procedure SICxUnLoad;

implementation

var
  HSICx : THandle = 0;

  {$IFDEF SIC_SSE}
  {$IFDEF CPUX64}
  SSICx : string = 'SICs64.DLL';
  {$ELSE}
  SSICx : string = 'SICs32.DLL';
  {$ENDIF}
  {$ELSE}
  {$IFDEF CPUX64}
  SSICx : string = 'SICx64.DLL';
  {$ELSE}
  SSICx : string = 'SICx32.DLL';
  {$ENDIF}
  {$ENDIF}

{
}
function SICxDLL: string;
begin
  Result := SSICx;
end;

{
}
procedure FreeLibrary_(var ALibrary: THandle);
var
  H : THandle;
begin
  if ALibrary = 0 then Exit;

  try
    H := ALibrary;
    ALibrary := 0;
    FreeLibrary (H);
  except
    //
  end;
end;

{
}
procedure SICxReset;
begin
  @sic_version := nil;
  @sic_cpu_support := nil;
  @sic_setup := nil;
  @sic_cretab := nil;
  @sic_fretab := nil;
  @sic_funtac := nil;
  @sic_funtaf := nil;
  @sic_funloa := nil;
  @sic_funulo := nil;
  @sic_contac := nil;
  @sic_contaf := nil;
  @sic_conloa := nil;
  @sic_conulo := nil;
  @sic_vartac := nil;
  @sic_vartaf := nil;
  @sic_varloa := nil;
  @sic_varulo := nil;
  @sic_runtac := nil;
  @sic_runtaf := nil;
  @sic_init := nil;
  @sic_done := nil;
  @sic_afun := nil;
  @sic_refun := nil;
  @sic_dufun := nil;
  @sic_exfun := nil;
  @sic_aconf := nil;
  @sic_aconi := nil;
  @sic_acons := nil;
  @sic_acono := nil;
  @sic_aconp := nil;
  @sic_aconpf := nil;
  @sic_aconpi := nil;
  @sic_aconps := nil;
  @sic_recon := nil;
  @sic_ducon := nil;
  @sic_excon := nil;
  @sic_avarf := nil;
  @sic_avari := nil;
  @sic_avars := nil;
  @sic_avaro := nil;
  @sic_avarp := nil;
  @sic_avarpf := nil;
  @sic_avarpi := nil;
  @sic_avarps := nil;
  @sic_revar := nil;
  @sic_duvar := nil;
  @sic_exvar := nil;
  @sic_invaf := nil;
  @sic_invac := nil;
  @sic_invav := nil;
  @sic_patab := nil;
  @sic_pafut := nil;
  @sic_pacot := nil;
  @sic_pavat := nil;
  @sic_gefut := nil;
  @sic_gefuc := nil;
  @sic_gefui := nil;
  @sic_gefun := nil;
  @sic_gecot := nil;
  @sic_gecoc := nil;
  @sic_gecoi := nil;
  @sic_gecon := nil;
  @sic_gevat := nil;
  @sic_gevac := nil;
  @sic_gevai := nil;
  @sic_gevar := nil;
  @sic_gerut := nil;
  @sic_geruc := nil;
  @sic_gerui := nil;
  @sic_gerun := nil;
  @sic_compile := nil;
  @sic_build := nil;
  @sic_exec := nil;
  @sic_call := nil;
  @sic_cexec := nil;
  @sic_bexec := nil;
  @sic_scexec := nil;
  @sic_sbexec := nil;
  @sic_va_count := nil;
  @sic_inda := nil;

  @cpuseed := nil;
  @cpuseed64 := nil;
  @cpuseed32 := nil;
  @cpuseed16 := nil;
  @cpurand := nil;
  @cpurand64 := nil;
  @cpurand32 := nil;
  @cpurand16 := nil;
  @cpurandf := nil;
  @cpurandf2pi := nil;

  @mt19937_igen := nil;
  @mt19937_fgen := nil;
  @mt19937_fgen2pi := nil;
  @mt19937_seed := nil;
  @mt19937_seeds := nil;

  @sic_erf := nil;
  @sic_erfc := nil;
  @sic_cdfnorm := nil;
  @sic_erfinv := nil;
  @sic_erfcinv := nil;
  @sic_cdfnorminv := nil;
  @sic_lgamma := nil;
  @sic_lgammas := nil;
  @sic_tgamma := nil;
  @sic_rgamma := nil;
  @sic_rtgamma := nil;
  @sic_beta := nil;
end;

{
}
procedure SICxAssign;
begin
  @sic_version := GetProcAddress (HSICx, 'sic_version');
  @sic_cpu_support := GetProcAddress (HSICx, 'sic_cpu_support');
  @sic_setup := GetProcAddress (HSICx, 'sic_setup');
  @sic_cretab := GetProcAddress (HSICx, 'sic_cretab');
  @sic_fretab := GetProcAddress (HSICx, 'sic_fretab');
  @sic_funtac := GetProcAddress (HSICx, 'sic_funtac');
  @sic_funtaf := GetProcAddress (HSICx, 'sic_funtaf');
  @sic_funloa := GetProcAddress (HSICx, 'sic_funloa');
  @sic_funulo := GetProcAddress (HSICx, 'sic_funulo');
  @sic_contac := GetProcAddress (HSICx, 'sic_contac');
  @sic_contaf := GetProcAddress (HSICx, 'sic_contaf');
  @sic_conloa := GetProcAddress (HSICx, 'sic_conloa');
  @sic_conulo := GetProcAddress (HSICx, 'sic_conulo');
  @sic_vartac := GetProcAddress (HSICx, 'sic_vartac');
  @sic_vartaf := GetProcAddress (HSICx, 'sic_vartaf');
  @sic_varloa := GetProcAddress (HSICx, 'sic_varloa');
  @sic_varulo := GetProcAddress (HSICx, 'sic_varulo');
  @sic_runtac := GetProcAddress (HSICx, 'sic_runtac');
  @sic_runtaf := GetProcAddress (HSICx, 'sic_runtaf');
  @sic_init := GetProcAddress (HSICx, 'sic_init');
  @sic_done := GetProcAddress (HSICx, 'sic_done');
  @sic_afun := GetProcAddress (HSICx, 'sic_afun');
  @sic_refun := GetProcAddress (HSICx, 'sic_refun');
  @sic_dufun := GetProcAddress (HSICx, 'sic_dufun');
  @sic_exfun := GetProcAddress (HSICx, 'sic_exfun');
  @sic_aconf := GetProcAddress (HSICx, 'sic_aconf');
  @sic_aconi := GetProcAddress (HSICx, 'sic_aconi');
  @sic_acons := GetProcAddress (HSICx, 'sic_acons');
  @sic_acono := GetProcAddress (HSICx, 'sic_acono');
  @sic_aconp := GetProcAddress (HSICx, 'sic_aconp');
  @sic_aconpf := GetProcAddress (HSICx, 'sic_aconpf');
  @sic_aconpi := GetProcAddress (HSICx, 'sic_aconpi');
  @sic_aconps := GetProcAddress (HSICx, 'sic_aconps');
  @sic_recon := GetProcAddress (HSICx, 'sic_recon');
  @sic_ducon := GetProcAddress (HSICx, 'sic_ducon');
  @sic_excon := GetProcAddress (HSICx, 'sic_excon');
  @sic_avarf := GetProcAddress (HSICx, 'sic_avarf');
  @sic_avari := GetProcAddress (HSICx, 'sic_avari');
  @sic_avars := GetProcAddress (HSICx, 'sic_avars');
  @sic_avaro := GetProcAddress (HSICx, 'sic_avaro');
  @sic_avarp := GetProcAddress (HSICx, 'sic_avarp');
  @sic_avarpf := GetProcAddress (HSICx, 'sic_avarpf');
  @sic_avarpi := GetProcAddress (HSICx, 'sic_avarpi');
  @sic_avarps := GetProcAddress (HSICx, 'sic_avarps');
  @sic_revar := GetProcAddress (HSICx, 'sic_revar');
  @sic_duvar := GetProcAddress (HSICx, 'sic_duvar');
  @sic_exvar := GetProcAddress (HSICx, 'sic_exvar');
  @sic_invaf := GetProcAddress (HSICx, 'sic_invaf');
  @sic_invac := GetProcAddress (HSICx, 'sic_invac');
  @sic_invav := GetProcAddress (HSICx, 'sic_invav');
  @sic_patab := GetProcAddress (HSICx, 'sic_patab');
  @sic_pafut := GetProcAddress (HSICx, 'sic_pafut');
  @sic_pacot := GetProcAddress (HSICx, 'sic_pacot');
  @sic_pavat := GetProcAddress (HSICx, 'sic_pavat');
  @sic_gefut := GetProcAddress (HSICx, 'sic_gefut');
  @sic_gefuc := GetProcAddress (HSICx, 'sic_gefuc');
  @sic_gefui := GetProcAddress (HSICx, 'sic_gefui');
  @sic_gefun := GetProcAddress (HSICx, 'sic_gefun');
  @sic_gecot := GetProcAddress (HSICx, 'sic_gecot');
  @sic_gecoc := GetProcAddress (HSICx, 'sic_gecoc');
  @sic_gecoi := GetProcAddress (HSICx, 'sic_gecoi');
  @sic_gecon := GetProcAddress (HSICx, 'sic_gecon');
  @sic_gevat := GetProcAddress (HSICx, 'sic_gevat');
  @sic_gevac := GetProcAddress (HSICx, 'sic_gevac');
  @sic_gevai := GetProcAddress (HSICx, 'sic_gevai');
  @sic_gevar := GetProcAddress (HSICx, 'sic_gevar');
  @sic_gerut := GetProcAddress (HSICx, 'sic_gerut');
  @sic_geruc := GetProcAddress (HSICx, 'sic_geruc');
  @sic_gerui := GetProcAddress (HSICx, 'sic_gerui');
  @sic_gerun := GetProcAddress (HSICx, 'sic_gerun');
  @sic_compile := GetProcAddress (HSICx, 'sic_compile');
  @sic_build := GetProcAddress (HSICx, 'sic_build');
  @sic_exec := GetProcAddress (HSICx, 'sic_exec');
  @sic_call := GetProcAddress (HSICx, 'sic_call');
  @sic_cexec := GetProcAddress (HSICx, 'sic_cexec');
  @sic_bexec := GetProcAddress (HSICx, 'sic_bexec');
  @sic_scexec := GetProcAddress (HSICx, 'sic_scexec');
  @sic_sbexec := GetProcAddress (HSICx, 'sic_sbexec');
  @sic_va_count := GetProcAddress (HSICx, 'sic_va_count');
  @sic_inda := GetProcAddress (HSICx, 'sic_inda');

  @cpuseed := GetProcAddress (HSICx, 'cpuseed');
  @cpuseed64 := GetProcAddress (HSICx, 'cpuseed64');
  @cpuseed32 := GetProcAddress (HSICx, 'cpuseed32');
  @cpuseed16 := GetProcAddress (HSICx, 'cpuseed16');
  @cpurand := GetProcAddress (HSICx, 'cpurand');
  @cpurand64 := GetProcAddress (HSICx, 'cpurand64');
  @cpurand32 := GetProcAddress (HSICx, 'cpurand32');
  @cpurand16 := GetProcAddress (HSICx, 'cpurand16');
  @cpurandf := GetProcAddress (HSICx, 'cpurandf');
  @cpurandf2pi := GetProcAddress (HSICx, 'cpurandf2pi');

  @mt19937_igen := GetProcAddress (HSICx, 'mt19937_igen');
  @mt19937_fgen := GetProcAddress (HSICx, 'mt19937_fgen');
  @mt19937_fgen2pi := GetProcAddress (HSICx, 'mt19937_fgen2pi');
  @mt19937_seed := GetProcAddress (HSICx, 'mt19937_seed');
  @mt19937_seeds := GetProcAddress (HSICx, 'mt19937_seeds');

  @sic_erf := GetProcAddress (HSICx, 'sic_erf');
  @sic_erfc := GetProcAddress (HSICx, 'sic_erfc');
  @sic_cdfnorm := GetProcAddress (HSICx, 'sic_cdfnorm');
  @sic_erfinv := GetProcAddress (HSICx, 'sic_erfinv');
  @sic_erfcinv := GetProcAddress (HSICx, 'sic_erfcinv');
  @sic_cdfnorminv := GetProcAddress (HSICx, 'sic_cdfnorminv');
  @sic_lgamma := GetProcAddress (HSICx, 'sic_lgamma');
  @sic_lgammas := GetProcAddress (HSICx, 'sic_lgammas');
  @sic_tgamma := GetProcAddress (HSICx, 'sic_tgamma');
  @sic_rgamma := GetProcAddress (HSICx, 'sic_rgamma');
  @sic_rtgamma := GetProcAddress (HSICx, 'sic_rtgamma');
  @sic_beta := GetProcAddress (HSICx, 'sic_beta');
end;

{
}
procedure SICxLoad (const SDLL: string);
begin
  if HSICx <> 0 then SICxUnLoad;

  if SDLL = '' then begin
    {$IFDEF SIC_SSE}
    {$IFDEF CPUX64}
    SSICx := 'SICs64.DLL';
    {$ELSE}
    SSICx := 'SICs32.DLL';
    {$ENDIF}
    {$ELSE}
    {$IFDEF CPUX64}
    SSICx := 'SICx64.DLL';
    {$ELSE}
    SSICx := 'SICx32.DLL';
    {$ENDIF}
    {$ENDIF}
  end else begin
    SSICx := SDLL;
  end;

  HSICx := LoadLibrary (PChar(SSICx));
  if HSICx < 32 then HSICx := 0;
  if HSICx = 0 then Exit;

  SICxAssign;
end;

{
}
procedure SICxUnLoad;
begin
  if HSICx = 0 then Exit;

  SICxReset;
  FreeLibrary_(HSICx);
end;

{
}
procedure Enter;
begin
  // SICxLoad ('');
end;

{
}
procedure Leave;
begin
  SICxUnLoad;
end;

initialization
  SICxDProcs.Enter;

finalization
  SICxDProcs.Leave;

end.

