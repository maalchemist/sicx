unit SICx32_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 98336 $
// File generated on 24.06.2023 8:00:00 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\!ROOT\PING\FASM\PROJECTS\SICx\RELEASE\ActiveX\Common\SICx32 (1)
// LIBID: {523CDDDE-ABDF-4BBE-B95C-6CE485B7E206}
// LCID: 0
// Helpfile:
// HelpString: SICx32 Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SICx32MajorVersion = 6;
  SICx32MinorVersion = 2;

  LIBID_SICx32: TGUID = '{523CDDDE-ABDF-4BBE-B95C-6CE485B7E206}';

  IID_ISICx32: TGUID = '{C9482147-E4A0-4066-9228-07B2D766C9F3}';
  CLASS_SICox32: TGUID = '{2876EC62-2F32-42BF-AAD5-6FDA20BAC91C}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  ISICx32 = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  SICox32 = ISICx32;


// *********************************************************************//
// Declaration of structures, unions and aliases.
// *********************************************************************//

  TSIC_Char24 = array[0..23] of Byte;
  TSIC_Char42 = array[0..41] of Byte;
  TSIC_Char44 = array[0..43] of Byte;
  TSIC_Char50 = array[0..49] of Byte;
  TSIC_Char52 = array[0..51] of Byte;
  TSIC_Char54 = array[0..53] of Byte;

  TSIC_Config = record
    cflags: LongWord;
    memory: LongWord;
    cpu_flags: LongWord;
    section_code: LongWord;
    section_data: LongWord;
    section_idata: LongWord;
    section_edata: LongWord;
    section_rsrc: LongWord;
    section_reloc: LongWord;
    fcode_size: LongWord;
    fdata_size: LongWord;
    fdata_count: LongWord;
    cdata_size: LongWord;
    cdata_count: LongWord;
    vdata_size: LongWord;
    vdata_count: LongWord;
    rdata_size: LongWord;
    rdata_count: LongWord;
    stack_size: LongWord;
    stack_count: LongWord;
    rpn_size: LongWord;
    rpn_count: LongWord;
    code_size: LongWord;
    fitem_nsize: LongWord;
    citem_nsize: LongWord;
    vitem_nsize: LongWord;
    uddata_scount: LongWord;
  end;

  TSIC_Data = record
    fdata: LongWord;
    cdata: LongWord;
    vdata: LongWord;
    rdata: LongWord;
    code: LongWord;
    data: LongWord;
    heap: LongWord;
    entry: LongWord;
    param: LongWord;
    size: LongWord;
    cspace: LongWord;
    calign: LongWord;
    dsize: LongWord;
    dspace: LongWord;
    dalign: LongWord;
    hsize: LongWord;
    hspace: LongWord;
    halign: LongWord;
    coops: LongWord;
    tokens: LongWord;
    rpn: LongWord;
    fcount: LongWord;
    ccount: LongWord;
    vcount: LongWord;
    rcount: LongWord;
    ccurs: LongWord;
    pcurs: LongWord;
    gdata: LongWord;
    gcode: LongWord;
    ecode: LongWord;
    rcode: LongWord;
    value: Double;
  end;

  TSIC_TableHeader = record
    icount: Integer;
    mcount: Integer;
    tisize: Integer;
    tnsize: Integer;
    titype: Integer;
    oooooo: Integer;
  end;

  TSIC_FunItem = record
    name: TSIC_Char50;
    retype: Smallint;
    acount: Smallint;
    cosize: Smallint;
    offset: Largeuint;
  end;

  TSIC_FunTable = record
    header: TSIC_TableHeader;
    items: TSIC_FunItem;
  end;

  TSIC_ConItem = record
    name: TSIC_Char44;
    codata: Largeuint;
    cotype: Smallint;
    datype: Smallint;
    value: Double;
  end;

  TSIC_ConTable = record
    header: TSIC_TableHeader;
    items: TSIC_ConItem;
  end;

  TSIC_VarItem = record
    name: TSIC_Char44;
    vadata: Largeuint;
    vatype: Smallint;
    datype: Smallint;
    offset: Largeuint;
  end;

  TSIC_VarTable = record
    header: TSIC_TableHeader;
    items: TSIC_VarItem;
  end;

  TSIC_Complex = record
    re: Double;
    im: Double;
  end;

  TSIC_IDAData = record
    instr_size: Byte;
    flags: LongWord;
    prefix_size: Byte;
    rex: Byte;
    prex_size: Byte;
    prex_0: Byte;
    prex_1: Byte;
    prex_2: Byte;
    prex_3: Byte;
    modrm: Byte;
    sib: Byte;
    opcode_offset: Byte;
    opcode_size: Byte;
    disp_offset: Byte;
    disp_size: Byte;
    imm_offset: Byte;
    imm_size: Byte;
  end;


// *********************************************************************//
// Interface: ISICx32
// Flags:     (0)
// GUID:      {C9482147-E4A0-4066-9228-07B2D766C9F3}
// *********************************************************************//
  ISICx32 = interface(IUnknown)
    ['{C9482147-E4A0-4066-9228-07B2D766C9F3}']
    function Version: LongWord; stdcall;
    function CPUSupport: WordBool; stdcall;
    procedure Setup(AConfig: Pointer); stdcall;
    procedure CreateTables; stdcall;
    procedure FreeTables; stdcall;
    function FunTableCreate: LongWord; stdcall;
    procedure FunTableFree; stdcall;
    function FunLoad: LongWord; stdcall;
    procedure FunUnload; stdcall;
    function ConTableCreate: LongWord; stdcall;
    procedure ConTableFree; stdcall;
    function ConLoad: LongWord; stdcall;
    procedure ConUnload; stdcall;
    function VarTableCreate: LongWord; stdcall;
    procedure VarTableFree; stdcall;
    function VarLoad: LongWord; stdcall;
    procedure VarUnload; stdcall;
    function RunTableCreate: LongWord; stdcall;
    procedure RunTableFree; stdcall;
    procedure Init(ASic: Pointer); stdcall;
    procedure Done(ASic: Pointer); stdcall;
    function AddFun(ASic: Pointer; AFuname: PAnsiChar; AOffset: Pointer; AACount: Smallint;
                    AFlags: Word): Integer; stdcall;
    function RenameFun(ASic: Pointer; AFuname: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer; stdcall;
    function DuplicateFun(ASic: Pointer; AFuname: PAnsiChar; AOrgname: PAnsiChar): Integer; stdcall;
    function ExchangeFun(ASic: Pointer; AFuname: PAnsiChar; AFunami: PAnsiChar): Integer; stdcall;
    function AddConF(ASic: Pointer; AConame: PAnsiChar; AValue: Double): Integer; stdcall;
    function AddConI(ASic: Pointer; AConame: PAnsiChar; AValue: Integer): Integer; stdcall;
    function AddConS(ASic: Pointer; AConame: PAnsiChar; AValue: PAnsiChar): Integer; stdcall;
    function AddConO(ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function AddConP(ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function AddConPF(ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function AddConPI(ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function AddConPS(ASic: Pointer; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
    function RenameCon(ASic: Pointer; AConame: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer; stdcall;
    function DuplicateCon(ASic: Pointer; AConame: PAnsiChar; AOrgname: PAnsiChar): Integer; stdcall;
    function ExchangeCon(ASic: Pointer; AConame: PAnsiChar; AConami: PAnsiChar): Integer; stdcall;
    function AddVarF(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarI(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarS(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarO(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarP(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarPF(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarPI(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function AddVarPS(ASic: Pointer; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
    function RenameVar(ASic: Pointer; AVaname: PAnsiChar; AOrgname: PAnsiChar; AInvalidate: WordBool): Integer; stdcall;
    function DuplicateVar(ASic: Pointer; AVaname: PAnsiChar; AOrgname: PAnsiChar): Integer; stdcall;
    function ExchangeVar(ASic: Pointer; AVaname: PAnsiChar; AVanami: PAnsiChar): Integer; stdcall;
    function InvalidateFun(ASic: Pointer; AFuname: PAnsiChar): Integer; stdcall;
    function InvalidateCon(ASic: Pointer; AConame: PAnsiChar): Integer; stdcall;
    function InvalidateVar(ASic: Pointer; AVaname: PAnsiChar): Integer; stdcall;
    procedure PackTables(ASic: Pointer); stdcall;
    procedure PackFunTable(ASic: Pointer); stdcall;
    procedure PackConTable(ASic: Pointer); stdcall;
    procedure PackVarTable(ASic: Pointer); stdcall;
    function GetFunTable(ASic: Pointer): PAnsiChar; stdcall;
    function GetFunCount(ASic: Pointer): LongWord; stdcall;
    function GetFunItem(ASic: Pointer; AIndex: Integer; var AItem: TSIC_FunItem): Integer; stdcall;
    function GetFunIndex(ASic: Pointer; AFuname: PAnsiChar): Integer; stdcall;
    function GetConTable(ASic: Pointer): PAnsiChar; stdcall;
    function GetConCount(ASic: Pointer): LongWord; stdcall;
    function GetConItem(ASic: Pointer; AIndex: Integer; var AItem: TSIC_ConItem): Integer; stdcall;
    function GetConIndex(ASic: Pointer; AConame: PAnsiChar): Integer; stdcall;
    function GetVarTable(ASic: Pointer): PAnsiChar; stdcall;
    function GetVarCount(ASic: Pointer): LongWord; stdcall;
    function GetVarItem(ASic: Pointer; AIndex: Integer; var AItem: TSIC_VarItem): Integer; stdcall;
    function GetVarIndex(ASic: Pointer; AVaname: PAnsiChar): Integer; stdcall;
    function GetRunTable(ASic: Pointer): PAnsiChar; stdcall;
    function GetRunCount(ASic: Pointer): LongWord; stdcall;
    function GetRunItem(ASic: Pointer; AIndex: Integer; var AItem: TSIC_ConItem): Integer; stdcall;
    function GetRunIndex(ASic: Pointer; ARuname: PAnsiChar): Integer; stdcall;
    function Compile(ASic: Pointer; S: PAnsiChar; ASop: LongWord): LongWord; stdcall;
    function Build(ASic: Pointer; S: PAnsiChar; ASop: LongWord): LongWord; stdcall;
    function Exec(ASic: Pointer; var AError: LongWord): Double; stdcall;
    procedure Call(ASic: Pointer); stdcall;
    function CoExec(ASic: Pointer; S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function BuExec(ASic: Pointer; S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function SCoExec(S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function SBuExec(S: PAnsiChar; var ASop: LongWord; var AError: LongWord): Double; stdcall;
    function va_count: Integer; stdcall;
    function inda(ACode: Pointer; AData: Pointer; Ax64: Byte): Integer; stdcall;
    function mt19937_igen: LongWord; stdcall;
    function mt19937_fgen: Double; stdcall;
    function mt19937_fgen2pi: Double; stdcall;
    procedure mt19937_seed(ASeed: LongWord); stdcall;
    procedure mt19937_seeds(ASeeds: Pointer; ACount: LongWord); stdcall;
    function sic_erf(A: Double): Double; stdcall;
    function sic_erfc(A: Double): Double; stdcall;
    function sic_cdfnorm(A: Double): Double; stdcall;
    function sic_erfinv(A: Double): Double; stdcall;
    function sic_erfcinv(A: Double): Double; stdcall;
    function sic_cdfnorminv(A: Double): Double; stdcall;
    function sic_lgamma(A: Double): Double; stdcall;
    function sic_lgammas(A: Double; var S: LongWord): Double; stdcall;
    function sic_tgamma(A: Double): Double; stdcall;
    function sic_rgamma(A: Double): Double; stdcall;
    function sic_rtgamma(A: Double): Double; stdcall;
    function sic_beta(A: Double; B: Double): Double; stdcall;
    function AddFuns(ASic: Pointer): Integer; stdcall;
    function cpuseed: LongWord; stdcall;
    function cpuseed64: Largeuint; stdcall;
    function cpuseed32: LongWord; stdcall;
    function cpuseed16: Word; stdcall;
    function cpurand: LongWord; stdcall;
    function cpurand64: Largeuint; stdcall;
    function cpurand32: LongWord; stdcall;
    function cpurand16: Word; stdcall;
    function cpurandf: Double; stdcall;
    function cpurandf2pi: Double; stdcall;
  end;

// *********************************************************************//
// The Class CoSICox32 provides a Create and CreateRemote method to
// create instances of the default interface ISICx32 exposed by
// the CoClass SICox32. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoSICox32 = class
    class function Create: ISICx32;
    class function CreateRemote(const MachineName: string): ISICx32;
  end;

implementation

uses System.Win.ComObj;

class function CoSICox32.Create: ISICx32;
begin
  Result := CreateComObject(CLASS_SICox32) as ISICx32;
end;

class function CoSICox32.CreateRemote(const MachineName: string): ISICx32;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SICox32) as ISICx32;
end;

end.

