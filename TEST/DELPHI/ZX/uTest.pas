unit uTest;

// SICx.DLL test
// main form

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}
{.$DEFINE DEBUG_int3}

{$IFDEF FPC} // Lazarus
  {$ASMMODE INTEL}
{$ENDIF}

{$UNDEF __ExecuteOnStartup_TRUE}
{$DEFINE __ExecuteOnStartup_TRUE}

{$UNDEF __TEST_VERBOSE_TRUE}
{.$DEFINE __TEST_VERBOSE_TRUE}

{$UNDEF __MultiLinePreBuild}
{.$DEFINE __MultiLinePreBuild}

{$UNDEF __BuildTest}
{.$DEFINE __BuildTest}

{$DEFINE __MXCSR}
{$IFDEF VER120} {$UNDEF __MXCSR} {$ENDIF} // Delphi 4.0
{$IFDEF VER130} {$UNDEF __MXCSR} {$ENDIF} // Delphi 5.0

{$UNDEF __SFMT}
{$UNDEF __SFMT_AVX2}
{$UNDEF __SFMT_SSE2}

{$DEFINE __SFMT_AVX2}
{.$DEFINE __SFMT_SSE2}

{$IFDEF VER_LDX11} {$UNDEF __SFMT_AVX2} {$ENDIF} // Delphi 11 required for AVX2/AVX512 instructions
{$IFDEF VER_LDXE2} {$UNDEF __SFMT_SSE2} {$ENDIF} // Delphi XE2 required for SSE2 instructions

{$IFDEF __SFMT_AVX2} {$DEFINE __SFMT} {$UNDEF __SFMT_SSE2} {$ENDIF}
{$IFDEF __SFMT_SSE2} {$DEFINE __SFMT} {$UNDEF __SFMT_AVX2} {$ENDIF}

// Example of correct folding
(*
{$DEFINE __FOLDING}
{$IFDEF CPUX64}
  {$IFDEF __FOLDING}
    {$REGION}
    // ...
    {$ENDREGION}
    {$REGION}
    // ...
    {$ENDREGION}
  {$ENDIF}
{$ELSE}
  {$IFDEF __FOLDING}
    {$REGION}
    // ...
    {$ENDREGION}
    {$REGION}
    // ...
    {$ENDREGION}
  {$ENDIF}
{$ENDIF}
// *)

interface

uses
  Windows, Messages, Classes, Controls, Forms, StdCtrls, ActnList, Dialogs,
  {$IFDEF UNICODE} System.Actions, {$ENDIF}
  {$IFDEF VER_DXE3H} System.UITypes, {$ENDIF}
  SICxDefs, SICxTypes, SICxUtils,
  {$IFDEF SIC_OCX}
  {$IFDEF SIC_SSE}
  {$IFDEF CPUX64} SICs64_TLB, {$ELSE} SICs32_TLB, {$ENDIF}
  {$ELSE}
  {$IFDEF CPUX64} SICx64_TLB, {$ELSE} SICx32_TLB, {$ENDIF}
  {$ENDIF}
  {$ELSE}
  {$IFDEF SIC_DYNAMIC} SICxDProcs, {$ELSE} SICxProcs, {$ENDIF}
  {$ENDIF}
  SICxIDA,
  Math, Buttons, ComCtrls, ExtCtrls, Menus, Masks, ShellApi;

const
  CAst80 = '********************************************************************************';

const
  SIC_DS = '.'; // SIC decimal separator

const
  count  = 2000;
  count2 =  400;

type
  TmForm = class(TForm)
    BT_SicCompile: TButton;
    BT_SicExecute: TButton;
    ED_Result: TEdit;
    ED_VarA: TEdit;
    ED_mcsTime: TEdit;
    ED_VarB: TEdit;
    L_VarA: TLabel;
    L_VarB: TLabel;
    BT_DelphiExec: TButton;
    ED_Expression: TMemo;
    ED_CodeSize: TEdit;
    L_VarC: TLabel;
    ED_VarC: TEdit;
    L_Result: TLabel;
    L_mcsTime: TLabel;
    L_CodeSize: TLabel;
    Actions: TActionList;
    acSicExecute: TAction;
    acDelphiExec: TAction;
    acSicCompile: TAction;
    L_VarX: TLabel;
    ED_VarX: TEdit;
    L_VarY: TLabel;
    ED_VarY: TEdit;
    L_VarZ: TLabel;
    ED_VarZ: TEdit;
    L_Error: TLabel;
    acGFunTable: TAction;
    acGVarTable: TAction;
    acGConTable: TAction;
    BT_SicCompileExec: TButton;
    acSicCompileExec: TAction;
    acLConTable: TAction;
    acLVarTable: TAction;
    BT_SaveCode: TButton;
    acSaveCode: TAction;
    CB_Expression: TComboBox;
    L_ZE: TLabel;
    L_ZE_F: TLabel;
    L_OE: TLabel;
    L_OE_F: TLabel;
    L_IE: TLabel;
    L_IE_F: TLabel;
    GB_Options: TGroupBox;
    ED_TokensRpn: TEdit;
    GB_MultiLineExpression: TGroupBox;
    ED_MultiLine: TMemo;
    BT_MultiLineExecute: TButton;
    acMultiLineExecute: TAction;
    acMultiLineBuild: TAction;
    BT_MultiLineBuild: TButton;
    acMultiLineBuildExec: TAction;
    BT_MultiLineBuildExec: TButton;
    GB_Global: TGroupBox;
    BT_GFunTable: TButton;
    BT_GConTable: TButton;
    BT_GVarTable: TButton;
    GB_Local: TGroupBox;
    BT_LConTable: TButton;
    BT_LVarTable: TButton;
    acLFunTable: TAction;
    BT_LFunTable: TButton;
    ED_VarU_0: TEdit;
    ED_VarU_1: TEdit;
    ED_VarU_2: TEdit;
    ED_VarU_3: TEdit;
    L_VarU: TLabel;
    BT_Bu01: TSpeedButton;
    BT_Bu02: TSpeedButton;
    BT_Bu03: TSpeedButton;
    L_secTime: TLabel;
    ED_sTime: TEdit;
    L_Cycles: TLabel;
    CB_Cycles: TComboBox;
    BT_Bu04: TSpeedButton;
    BT_Bu05: TSpeedButton;
    BT_LRunTable: TButton;
    acLRunTable: TAction;
    acGRunTable: TAction;
    BT_GRunTable: TButton;
    BT_Bu06: TSpeedButton;
    acEscape: TAction;
    BT_Bu07: TSpeedButton;
    BT_Bu08: TSpeedButton;
    acSelectAll: TAction;
    BT_Bu09: TSpeedButton;
    BT_Bu10: TSpeedButton;
    BT_Bu11: TSpeedButton;
    BT_Bu12: TSpeedButton;
    BT_Bu13: TSpeedButton;
    BT_Bu14: TSpeedButton;
    BT_Bu15: TSpeedButton;
    BT_Bu16: TSpeedButton;
    acMultiLinePreBuild: TAction;
    acSicConfig: TAction;
    P_COP_T: TPanel;
    SB_COP: TScrollBox;
    P_COP: TPanel;
    CB_SIC_OPT_FLAG_OPTIMIZATION: TCheckBox;
    CB_SIC_OPT_FLAG_STACK_FRAME: TCheckBox;
    CB_SIC_OPT_FLAG_FP_FRAME: TCheckBox;
    CB_SIC_OPT_FLAG_NO_CALIGN: TCheckBox;
    BT_SicConfig: TButton;
    acIDA: TAction;
    ED_IntHexResult: TEdit;
    L_0x: TLabel;
    BT_Bu17: TSpeedButton;
    BT_Bu18: TSpeedButton;
    BT_Bu19: TSpeedButton;
    BT_Bu20: TSpeedButton;
    BT_Bu21: TSpeedButton;
    BT_Bu22: TSpeedButton;
    BT_Bu23: TSpeedButton;
    BT_Bu24: TSpeedButton;
    BT_Bu25: TSpeedButton;
    CB_SIC_OPT_FLAG_LOCALS: TCheckBox;
    ED_RpnItems: TEdit;
    L_VarD: TLabel;
    ED_VarD: TEdit;
    L_VarT: TLabel;
    ED_VarT: TEdit;
    BT_MultiLineClipboard: TSpeedButton;
    BT_ExpressionClipboard: TSpeedButton;
    BT_ExpressionClear: TSpeedButton;
    BT_MultiLineClear: TSpeedButton;
    BT_ExpressionPasteFromClipboard: TSpeedButton;
    BT_MultiLinePasteFromClipboard: TSpeedButton;
    acDefaultOptions: TAction;
    BT_DefaultOptions: TSpeedButton;
    ac_TEST_LIST: TAction;
    acDefaultVars: TAction;
    ac_TEST_VOC: TAction;
    MainMenu: TMainMenu;
    mmi_TEST: TMenuItem;
    ac_TEST: TAction;
    mmi_TEST_LIST: TMenuItem;
    mmi_TEST_VOC: TMenuItem;
    ac_TEST_mt19937_SICx: TAction;
    ac_TEST_mt19937_Delphi: TAction;
    NOP: TMenuItem;
    mmi_TEST_mt19937_SICx: TMenuItem;
    mmi_TEST_mt19937_Delphi: TMenuItem;
    CB_SIC_OPT_FLAG_DEBUG: TCheckBox;
    ED_HexResult: TEdit;
    L_HexResult: TLabel;
    BT_Bench: TSpeedButton;
    BT_DefaultVars: TSpeedButton;
    ac_TEST_SICx: TAction;
    mmi_TEST_SICx: TMenuItem;
    acRecreateSICx: TAction;
    NUP: TMenuItem;
    mmiRecreateSICx: TMenuItem;
    ac_TEST_sfmt: TAction;
    ac_TEST_sfmt_a: TAction;
    NUB: TMenuItem;
    mmi_TEST_sfmt: TMenuItem;
    mmi_TEST_sfmt_a: TMenuItem;
    StatusBar: TStatusBar;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acSicExecuteExecute(Sender: TObject);
    procedure acDelphiExecExecute(Sender: TObject);
    procedure acSicCompileExecute(Sender: TObject);
    procedure acGFunTableExecute(Sender: TObject);
    procedure acGVarTableExecute(Sender: TObject);
    procedure edKeyPress(Sender: TObject; var Key: Char);
    procedure acGConTableExecute(Sender: TObject);
    procedure acSicCompileExecExecute(Sender: TObject);
    procedure acLConTableExecute(Sender: TObject);
    procedure acLVarTableExecute(Sender: TObject);
    procedure acSaveCodeExecute(Sender: TObject);
    procedure CB_ExpressionChange(Sender: TObject);
    procedure acMultiLineExecuteExecute(Sender: TObject);
    procedure acMultiLineBuildExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ED_MultiLineChange(Sender: TObject);
    procedure acMultiLineBuildExecExecute(Sender: TObject);
    procedure acLFunTableExecute(Sender: TObject);
    procedure BT_Bu01Click(Sender: TObject);
    procedure BT_Bu02Click(Sender: TObject);
    procedure BT_Bu03Click(Sender: TObject);
    procedure BT_Bu04Click(Sender: TObject);
    procedure BT_Bu05Click(Sender: TObject);
    procedure acLRunTableExecute(Sender: TObject);
    procedure acGRunTableExecute(Sender: TObject);
    procedure BT_Bu06Click(Sender: TObject);
    procedure acEscapeExecute(Sender: TObject);
    procedure BT_Bu07Click(Sender: TObject);
    procedure BT_Bu08Click(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure BT_Bu09Click(Sender: TObject);
    procedure BT_Bu10Click(Sender: TObject);
    procedure BT_Bu11Click(Sender: TObject);
    procedure BT_Bu12Click(Sender: TObject);
    procedure BT_Bu13Click(Sender: TObject);
    procedure BT_Bu14Click(Sender: TObject);
    procedure BT_Bu15Click(Sender: TObject);
    procedure BT_Bu16Click(Sender: TObject);
    procedure acMultiLinePreBuildExecute(Sender: TObject);
    procedure acSicConfigExecute(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormClick(Sender: TObject);
    procedure acIDAExecute(Sender: TObject);
    procedure BT_Bu17Click(Sender: TObject);
    procedure BT_Bu18Click(Sender: TObject);
    procedure BT_Bu19Click(Sender: TObject);
    procedure BT_Bu20Click(Sender: TObject);
    procedure BT_Bu21Click(Sender: TObject);
    procedure BT_Bu22Click(Sender: TObject);
    procedure BT_Bu23Click(Sender: TObject);
    procedure BT_Bu24Click(Sender: TObject);
    procedure BT_Bu25Click(Sender: TObject);
    procedure CB_SIC_OPT_FLAG_Click(Sender: TObject);
    procedure BT_MultiLineClipboardClick(Sender: TObject);
    procedure BT_ExpressionClipboardClick(Sender: TObject);
    procedure BT_ExpressionClearClick(Sender: TObject);
    procedure BT_MultiLineClearClick(Sender: TObject);
    procedure BT_ExpressionPasteFromClipboardClick(Sender: TObject);
    procedure BT_MultiLinePasteFromClipboardClick(Sender: TObject);
    procedure acDefaultOptionsExecute(Sender: TObject);
    procedure ac_TEST_LISTExecute(Sender: TObject);
    procedure acDefaultVarsExecute(Sender: TObject);
    procedure ac_TEST_VOCExecute(Sender: TObject);
    procedure ac_TESTExecute(Sender: TObject);
    procedure ac_TEST_mt19937_SICxExecute(Sender: TObject);
    procedure ac_TEST_mt19937_DelphiExecute(Sender: TObject);
    procedure ED_HexResultChange(Sender: TObject);
    procedure ED_HexResultKeyPress(Sender: TObject; var Key: Char);
    procedure BT_BenchClick(Sender: TObject);
    procedure ac_TEST_SICxExecute(Sender: TObject);
    procedure acRecreateSICxExecute(Sender: TObject);
    procedure ac_TEST_sfmtExecute(Sender: TObject);
    procedure ac_TEST_sfmt_aExecute(Sender: TObject);
  private
    FacSicExecuteLock         : Integer;
    FacSicCompileExecLock     : Integer;
    FacSicCompileLock         : Integer;
    FacMultiLineExecuteLock   : Integer;
    FacMultiLineBuildExecLock : Integer;
    FacMultiLineBuildLock     : Integer;

    FED_HexResultLock         : Integer;

    procedure WMAppMouseWheel (var AMessage: TMessage); message WM_APP_MOUSE_WHEEL;
    procedure WMAppMouseWheelUp (var AMessage: TMessage); message WM_APP_MOUSE_WHEEL_UP;
    procedure WMAppMouseWheelDown (var AMessage: TMessage); message WM_APP_MOUSE_WHEEL_DOWN;
    procedure WMAppTestStatus (var AMessage: TMessage); message WM_APP_TEST_STATUS;

    function  BypassMouseWheel: Boolean;
    procedure PrintResult (D: Double);

    procedure GetIDAStrings (ATXT, ARTF: TStringList);

    procedure TEST_(const AHeader: string; const AExpr: string; AExecute: Boolean; var ARCount, AECount: Integer; var AROutput, AEOutput: string);
  public
    CodeSize   : UInt32;
    Escape     : Boolean;
    DefOptions : Boolean;
    {$IFDEF SIC_OCX}
    {$IFDEF SIC_SSE}
    {$IFDEF CPUX64}
    SIC : ISICs64;
    {$ELSE}
    SIC : ISICs32;
    {$ENDIF}
    {$ELSE}
    {$IFDEF CPUX64}
    SIC : ISICx64;
    {$ELSE}
    SIC : ISICx32;
    {$ENDIF}
    {$ENDIF}
    {$ENDIF}

    procedure SIC_Create;
    procedure SIC_Create_DLL;
    procedure SIC_Create_OCX;
    procedure SIC_Free;
    procedure SIC_Free_DLL;
    procedure SIC_Free_OCX;

    procedure AssignCaption;
    function  GetCycles (ADefault: Integer): Integer;
    procedure UpdateVars;
    procedure PrintVars;
    function  GetCompilerOptions: DWORD;
    procedure SetCompilerOptions (ASic_coops: DWORD);
    procedure GetAnsiText (AEdit: TCustomEdit; var S: AnsiString);
    procedure LocateError (var ASic: TSIC_Data; AEdit: TCustomEdit; AStartFrom: Integer);
    function  CompileTest (var S: AnsiString; var AOptions: DWORD): PAnsiChar;
    function  BuildTest (var S: AnsiString; var AOptions: DWORD): PAnsiChar;
    procedure ClearError;
    procedure PrintError (AOptions: DWORD; AError: DWORD);
    procedure SetStatusText (const AText: string);
    procedure ClearStatus;
    procedure PrintStatus (var ASic: TSIC_Data);
    procedure ClearTime;
    procedure PrintTime (var APData: TPerformanceData; ACycles: Integer);
    procedure ClearRpnItems;
    procedure PrintRpnItems (var ASic: TSIC_Data);
    procedure ClearHexResult;

    procedure AssignCodeSize (ASize: UInt32; ASpace: UInt32);
  end;

var
  mForm: TmForm;

implementation

{$R *.dfm}

uses
  SysUtils, IniFiles, ClipBrd, SICxTable, SICxUDF, SICxFPU, SICxSSE,
  SICxTest, mt19937,
  {$IFDEF __SFMT} sfmt, {$ENDIF}
  {$IFDEF __SFMT_AVX2} sfmt_avx2, {$ENDIF}
  {$IFDEF __SFMT_SSE2} sfmt_sse2, {$ENDIF}
  cordic, msvcrt;

var
  VPData : TPerformanceData;
  SAPPPath : string = '.\';

var
  {$IFDEF __ExecuteOnStartup_TRUE}
  ExecuteOnStartup : Boolean = true;
  {$ELSE}
  ExecuteOnStartup : Boolean = false;
  {$ENDIF}

{$IFDEF CPUX64}
procedure asma;
asm
end;
{$ELSE}
procedure asma;
asm
end;
{$ENDIF}

{
}
procedure Refresh_(var T: DWORD; AForce: Boolean = false);
begin
  if AForce then begin
    Application.ProcessMessages;
    T := GetTickCount;
    Exit;
  end;

  if GetTickCount - T > 400 then begin
    Application.ProcessMessages;
    T := GetTickCount;
  end;
end;

{
}
procedure SetEditText (AEdit: TEdit; const AText: string);
begin
  AEdit.Text := AText;
  AEdit.Refresh;
end;

var
  SSE_MXCSR : DWORD = 0;
  SSE_MXCSR_Counter : Integer = 0;

{
}
procedure SSE_mask_exceptions;
{$IFDEF __MXCSR}
var
  V : DWORD;
asm
        STMXCSR SSE_MXCSR       // save MXCSR register
        MOV     V, $7F80        // mask all exceptions, round toward zero ; 11 111111 0 000000
        LDMXCSR V               // load MXCSR register
end;
{$ELSE}
asm
end;
{$ENDIF}

{
}
procedure SSE_restore_MXCSR;
{$IFDEF __MXCSR}
asm
        LDMXCSR SSE_MXCSR       // restore MXCSR register
end;
{$ELSE}
asm
end;
{$ENDIF}

{
}
procedure FPUInit;
const
// Cmask = $0C00; // full precision   0000 1100 0000 0000
   Cmask = $0800; // double precision 0000 1000 0000 0000
var
  C : WORD;
asm
        fninit
        fnstcw  [C]
        and     word ptr [C], $FCFF
        or      word ptr [C], Cmask
        fldcw   [C]
end;

{
}
procedure TmForm.acRecreateSICxExecute(Sender: TObject);
begin
  SIC_Free;
  SIC_Create;
end;

{
}
procedure TmForm.SIC_Create;
begin
  // FPUInit;

  {$IFDEF SIC_OCX}
  SIC_Create_OCX;
  {$ELSE}
  SIC_Create_DLL;
  {$ENDIF}

  ac_TEST_SICx.Execute;

  AssignCaption;
end;

{
}
procedure TmForm.ac_TEST_SICxExecute(Sender: TObject);
begin
end;

{
}
procedure asm__();
asm
end;

{
}
function derand: Integer; cdecl;
begin
  Result := Random (maxInt);
end;

{
}
function depower (Base, Exponent: Double): Double; cdecl;
begin
  Result := Power (Base, Exponent);
end;

{
}
procedure TmForm.SIC_Create_DLL;
{$IFDEF SIC_OCX}
begin
end;
{$ELSE}
var
  RT : WORD;
  (*
  s0 : array [0..32] of AnsiChar;
  i0 : NativeInt absolute s0[0];
  i1 : NativeInt;
  i2 : NativeInt;
  // *)
begin
  asm__();

  (*
  FillChar (s0, SizeOf(s0), 0);
  s0 := '12345678';
  i1 := i0;
  FillChar (s0, SizeOf(s0), 0);
  s0 := '1234';
  i2 := i0;
  // *)

  // setup compiler
  FillChar (SIC_Config, SizeOf(SIC_Config), 0);
  // SIC_Config.cflags := SIC_CFG_FLAG_CASE_SENSITIVE;
  // SIC_Config.cflags := SIC_CFG_FLAG_NO_UDF;
  // SIC_Config.memory := $00100000;
  sic_setup (@SIC_Config);

  // create global tables
  sic_cretab;

  // initialize T_sic_data structures
  sic_init (@vsic);
  sic_init (@vsic2);

  // STDCALL function flag : $00FF
  // Dynamic function flag : ($20 shl 8)
  // VOID result flag      : ($0F shl 8)
  // Int64 result flag     : ($08 shl 8)
  // Int32 result flag     : ($04 shl 8)

  sic_afuns (nil);

  // sic_afun (nil, 'derand', @derand, 0, 0 or (4 shl 8));
  (*
  {$IFDEF CPUX64}
  sic_afun (nil, 'depower', @power, 2, 0);
  {$ELSE}
  sic_afun (nil, 'depower', @depower, 2, 0);
  {$ENDIF}
  // *)

  // add user defined global functions
  {$IFDEF CPUX64}
  sic_afun (nil, 'UF_2x2x', @UF_2x2x, 4, B_0101);
  sic_afun (nil, 'UF_REF', @UF_REF, 1, B_0001);
  sic_afun (nil, 'UF_REFF', @UF_REFF, 5, B_0101);
  sic_afun (nil, 'UF_IREF', @UF_IREF, 3, B_0111);
  sic_afun (nil, 'UF_Int64', @UF_Int64, 1, B_0001);
  {$ELSE}
  sic_afun (nil, 'UF_2x2x', @UF_2x2x, 4, 2);
  sic_afun (nil, 'UF_REF', @UF_REF, 1, 1);
  sic_afun (nil, 'UF_REFF', @UF_REFF, 5, 3);
  sic_afun (nil, 'UF_IREF', @UF_IREF, 3, 3);
  sic_afun (nil, 'UF_Int64', @UF_Int64, 1, 0);
  {$ENDIF}

  // size of return value = 4 (INT)
  {$IFDEF CPUX64}
  sic_afun (nil, 'c_np_i4r', @c_np_i4r, 0, 0 or (4 shl 8));
  sic_afun (nil, 'c_dp_i4r', @c_dp_i4r, 1, 0 or (4 shl 8));
  sic_afun (nil, 's_np_i4r', @s_np_i4r, 0, 0 or (4 shl 8));
  sic_afun (nil, 's_dp_i4r', @s_dp_i4r, 1, 0 or (4 shl 8));
  {$ELSE}
  sic_afun (nil, 'c_np_i4r', @c_np_i4r, 0, 0 or (4 shl 8));
  sic_afun (nil, 'c_dp_i4r', @c_dp_i4r, 1, 0 or (4 shl 8));
  sic_afun (nil, 's_np_i4r', @s_np_i4r, 0, $00FF or (4 shl 8));
  sic_afun (nil, 's_dp_i4r', @s_dp_i4r, 1, $00FF);
  {$ENDIF}

  // dynamic function flag $20 = 00100000
  {$IFDEF CPUX64}
  sic_afun (nil, 'random_c', @random_c, 0, 0 or ($20 shl 8));
  sic_afun (nil, 'random_s', @random_s, 0, 0 or ($20 shl 8));
  {$ELSE}
  sic_afun (nil, 'random_c', @random_c, 0, 0 or ($20 shl 8));
  sic_afun (nil, 'random_s', @random_s, 0, $00FF or ($20 shl 8));
  {$ENDIF}

  (*
  {$IFDEF CPUX64}
  // cdecl, no result, size of return value = $0F (00001111)
  sic_afun (nil, 'nope_c', @nope_c, 0, 0 or ($0F shl 8));
  // stdcall, no result, size of return value = $0F (00001111)
  sic_afun (nil, 'nope_s', @nope_s, 0, 0 or ($0F shl 8));
  {$ELSE}
  // cdecl, no result, size of return value = $0F (00001111)
  sic_afun (nil, 'nope_c', @nope_c, 0, ($0F shl 8));
  // stdcall, no result, size of return value = $0F (00001111)
  sic_afun (nil, 'nope_s', @nope_s, 0, $00FF or ($0F shl 8));
  {$ENDIF}
  // *)

  (*
  {$IFDEF CPUX64}
  sic_afun (nil, 'sin', @sinn, 1, 0);
  sic_afun (nil, 'cos', @coss, 1, 0);
  // sic_afun (@vsic, 'sin', @coss, 1, 0);
  {$ENDIF}
  // *)
  (*
  sic_afun (nil, 'sin', @sinnn, 1, $00FF);
  sic_afun (nil, 'cos', @cosss, 1, $00FF);
  // *)

  sic_afun (nil, 'UF_0P', @UF_0P, 0, 0);
  sic_afun (nil, 'UF_1P', @UF_1P, 1, 0);
  sic_afun (nil, 'UF_2P', @UF_2P, 2, 0);
  sic_afun (nil, 'UF_3P', @UF_3P, 3, 0);
  sic_afun (nil, 'UF_4P', @UF_4P, 4, 0);
  sic_afun (nil, 'UF_5P', @UF_5P, 5, 0);
  sic_afun (nil, 'UF_6P', @UF_6P, 6, 0);

  // rename or duplicate global functions
  sic_refun (nil, 'log', 'ln', false);      // duplicate
  sic_refun (nil, 'dou', 'double', false);  // duplicate
  sic_refun (nil, 'power2', 'pow2', false); // duplicate
  sic_refun (nil, 'power4', 'pow4', true);  // rename

  (*
  sic_exfun (nil, 'cos', 'fcos');
  sic_exfun (nil, 'sin', 'fsin');
  sic_exfun (nil, 'tan', 'ftan');
  sic_exfun (nil, 'log', 'fln');
  // *)

  // invalidate "meander" global function
  sic_invaf (nil, 'meander');

  (*
  // exchange global functions
  sic_exfun (nil, 'logn', 'lognr');
  // *)

  (*

  // duplicate if.ne global function // Not equal
  sic_dufun (nil, 'if.ba', 'if.ne'); // Below or above
  sic_dufun (nil, 'if.lg', 'if.ne'); // Less or greater

  // duplicate if.a global function // Above
  sic_dufun (nil, 'if.g'  , 'if.a'); // Greater
  sic_dufun (nil, 'if.gt' , 'if.a'); // Greater
  sic_dufun (nil, 'if.nbe', 'if.a'); // Not below and equal
  sic_dufun (nil, 'if.nle', 'if.a'); // Not less and equal

  // duplicate if.ae global function // Above or equal
  sic_dufun (nil, 'if.ge', 'if.ae'); // Greater or equal
  sic_dufun (nil, 'if.nb', 'if.ae'); // Not below
  sic_dufun (nil, 'if.nl', 'if.ae'); // Not less

  // duplicate if.b global function // Below
  sic_dufun (nil, 'if.l'  , 'if.b'); // Less
  sic_dufun (nil, 'if.lt' , 'if.b'); // Less
  sic_dufun (nil, 'if.nae', 'if.b'); // Not above and equal
  sic_dufun (nil, 'if.nge', 'if.b'); // Not greater and equal

  // duplicate if.be global function // Below or equal
  sic_dufun (nil, 'if.le', 'if.be'); // Less or equal
  sic_dufun (nil, 'if.na', 'if.be'); // Not above
  sic_dufun (nil, 'if.ng', 'if.be'); // Not greater

  // *)

  // add user defined global variables
  sic_avarf (nil, '.', @a); // error
  sic_avarf (nil, 'a', @a);
  sic_avarf (nil, 'b', @b);
  sic_avarf (nil, 'c', @c);
  sic_avarf (nil, 'd', @d);
  sic_avarf (nil, 'x', @x);
  sic_avarf (nil, 'y', @y);
  sic_avarf (nil, 'z', @z);
  sic_avarf (nil, 't', @t);
  sic_avarf (nil, 'u', @u[0]);
  sic_avarf (nil, 'v', @u[3]);

  // sic_avarf (@vsic, 'x', @xL);

  sic_avari (nil, 'JJJ', @JJJ);

  sic_avarf (nil, 'l', @l);
  sic_avarf (nil, 's', @s);
  sic_avarf (nil, 'h', @h);

  // add user defined global constants
  sic_aconf (nil, '@aaa', 555);
  sic_aconf (nil, '@bbb', 0.1);
  sic_aconi (nil, '@10', 10);

  // rename or duplicate global constants
  sic_recon (nil, 'pi', '@pi', false);   // duplicate
  sic_recon (nil, '2pi', '@2pi', true);  // rename (error)
  sic_recon (nil, 'pipi', '@2pi', true); // rename

  // add user defined local functions
  {$IFDEF CPUX64}
  sic_afun (@vsic, 'PTEST', @PTEST, 1, B_0001);
  sic_afun (@vsic, 'NRTEST', @NRTEST, 1, B_0001 or ($0F shl 8)); // no result, size of return value = $0F (00001111)
  sic_afun (@vsic, 'NRTEST2', @NRTEST2, 1, ($0F shl 8)); // no result, size of return value = $0F (00001111)
  sic_afun (@vsic, 'ITEST', @ITEST, 1, B_0001);
  sic_afun (@vsic, 'IITEST', @IITEST, 4, B_1111 or (8 shl 8)); // size of return value = 8 (INT_PTR)
  sic_afun (@vsic, 'STEST', @STEST, 1, B_0001);
  sic_afun (@vsic, 'VTEST', @VTEST, -1, B_0000);
  sic_afun (@vsic, 'CoTest', @CoTest, 2, B_0011);
  {$ELSE}
  sic_afun (@vsic, 'PTEST', @PTEST, 1, 1);
  sic_afun (@vsic, 'NRTEST', @NRTEST, 1, 1 or ($0F shl 8)); // no result, size of return value = $0F (00001111)
  sic_afun (@vsic, 'NRTEST2', @NRTEST2, 1, ($0F shl 8)); // no result, size of return value = $0F (00001111)
  sic_afun (@vsic, 'ITEST', @ITEST, 1, 1);
  sic_afun (@vsic, 'IITEST', @IITEST, 4, 4 or (4 shl 8)); // size of return value = 4 (INT_PTR)
  sic_afun (@vsic, 'STEST', @STEST, 1, 1);
  sic_afun (@vsic, 'VTEST', @VTEST, -1, 0);
  sic_afun (@vsic, 'CoTest', @CoTest, 2, 2);
  {$ENDIF}
  sic_afun (@vsic, 'STDCALL_TEST', @STDCALL_TEST, 1, $00FF);
  sic_afun (@vsic, 'STDCALL_ITEST', @STDCALL_ITEST, 1, $00FF or (4 shl 8)); // size of return value = 4 (INT)

  // size of return value = 8 (INT64)
  RT := 8 shl 8;
  sic_afun (@vsic, 'CDECL_I64', @CDECL_I64, 1, 1 or RT);
  sic_afun (@vsic, 'STDCALL_I64', @STDCALL_I64, 1, $00FF or RT);

  // return 2 double values
  RT := B_1001 shl 8;
  sic_afun (@vsic, 'CDECL_RE2', @CDECL_RE2, 1, RT);
  sic_afun (@vsic, 'STDCALL_RE2', @STDCALL_RE2, 1, $00FF or RT);
  sic_afun (@vsic, 'CDECL_2P_RE2', @CDECL_2P_RE2, 2, RT);
  sic_afun (@vsic, 'STDCALL_2P_RE2', @STDCALL_2P_RE2, 2, $00FF or RT);
  // return 3 double values
  RT := B_1010 shl 8;
  sic_afun (@vsic, 'CDECL_RE3', @CDECL_RE3, 1, RT);
  sic_afun (@vsic, 'STDCALL_RE3', @STDCALL_RE3, 1, $00FF or RT);
  sic_afun (@vsic, 'CDECL_2P_RE3', @CDECL_2P_RE3, 2, RT);
  sic_afun (@vsic, 'STDCALL_2P_RE3', @STDCALL_2P_RE3, 2, $00FF or RT);
  // return 4 double values
  RT := B_1100 shl 8;
  sic_afun (@vsic, 'CDECL_RE4', @CDECL_RE4, 1, RT);
  sic_afun (@vsic, 'STDCALL_RE4', @STDCALL_RE4, 1, $00FF or RT);
  sic_afun (@vsic, 'CDECL_2P_RE4', @CDECL_2P_RE4, 2, RT);
  sic_afun (@vsic, 'STDCALL_2P_RE4', @STDCALL_2P_RE4, 2, $00FF or RT);
  sic_afun (@vsic, 'CDECL_4P_RE4', @CDECL_4P_RE4, 4, RT);
  sic_afun (@vsic, 'STDCALL_4P_RE4', @STDCALL_4P_RE4, 4, $00FF or RT);

  // add user defined local variables
  sic_avarf (@vsic, '__a', @a);
  sic_avarf (@vsic, '__b', @b);
  sic_avarf (@vsic, '__c', @c);
  sic_avarf (@vsic, '__d', @d);
  sic_avarf (@vsic, '__x', @x);
  sic_avarf (@vsic, '__y', @y);
  sic_avarf (@vsic, '__z', @z);
  sic_avarf (@vsic, '__t', @t);
  sic_avari (@vsic, 'III', @III);

  // add user defined local constants
  sic_aconf (@vsic, '_AAA', 0.1);
  sic_aconf (@vsic, '_BBB', 1.2);
  sic_aconf (@vsic, '_CCC', 2.3);
  sic_aconp (@vsic, 'PPP', @PPP);

  sic_acons (@vsic, 'CSTR', PAnsiChar(STR));
  sic_acons (@vsic, 'CSTR8', PAnsiChar(STR8));

  sic_acons (@vsic, 'C_STR', PAnsiChar(STR));
  sic_acons (@vsic, 'C_STR8', PAnsiChar(STR8));
  sic_avars (@vsic, 'V_STR', @STR);
  sic_avars (@vsic, 'V_STR8', @STR8);

  sic_aconp (@vsic, 'coa', @coa);
  sic_aconp (@vsic, 'cob', @cob);
  sic_avarf (@vsic, 'coa.re', @coa.re);
  sic_avarf (@vsic, 'coa.im', @coa.im);
  sic_avarf (@vsic, 'cob.re', @cob.re);
  sic_avarf (@vsic, 'cob.im', @cob.im);

  sic_acono (@vsic, 'CallProc', @CallProc);
  sic_acono (@vsic, 'Sic2Proc', @Sic2Proc);
  sic_avaro (@vsic, 'Sic2_Proc', @vsic2_proc);
  // sic_avaro (@vsic, 'Sic2_Proc', @vsic2.entry);

  // pack global tables
  sic_patab (nil);
  // pack local tables
  sic_patab (@vsic);
  sic_patab (@vsic2);
end;
{$ENDIF}

{
}
procedure TmForm.SIC_Create_OCX;
{$IFDEF SIC_OCX}
var
  RT : WORD;
begin
  {$IFDEF SIC_SSE}
  {$IFDEF CPUX64}
  SIC := CoSICos64.Create;
  {$ELSE}
  SIC := CoSICos32.Create;
  {$ENDIF}
  {$ELSE}
  {$IFDEF CPUX64}
  SIC := CoSICox64.Create;
  {$ELSE}
  SIC := CoSICox32.Create;
  {$ENDIF}
  {$ENDIF}
  SICxUtils.SIC := SIC;

  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    SetEditText (ED_Result, 'SIC = nil');
    ClearHexResult;
    Exit;
  end;
  {$ENDIF}

  // setup compiler
  FillChar (SIC_Config, SizeOf(SIC_Config), 0);
  // SIC_Config.cflags := SIC_CFG_FLAG_CASE_SENSITIVE;
  // SIC_Config.memory := $00100000;
  SIC.Setup (@SIC_Config);

  SIC.CreateTables;
  SIC.Init (@vsic);
  SIC.Init (@vsic2);

  SIC.AddFuns (nil);

  // add user defined global functions
  {$IFDEF CPUX64}
  SIC.AddFun (nil, 'UF_2x2x', @UF_2x2x, 4, B_0101);
  SIC.AddFun (nil, 'UF_REF', @UF_REF, 1, B_0001);
  SIC.AddFun (nil, 'UF_REFF', @UF_REFF, 5, B_0101);
  SIC.AddFun (nil, 'UF_IREF', @UF_IREF, 3, B_0111);
  SIC.AddFun (nil, 'UF_Int64', @UF_Int64, 1, B_0001);
  {$ELSE}
  SIC.AddFun (nil, 'UF_2x2x', @UF_2x2x, 4, 2);
  SIC.AddFun (nil, 'UF_REF', @UF_REF, 1, 1);
  SIC.AddFun (nil, 'UF_REFF', @UF_REFF, 5, 3);
  SIC.AddFun (nil, 'UF_IREF', @UF_IREF, 3, 3);
  SIC.AddFun (nil, 'UF_Int64', @UF_Int64, 1, 0);
  {$ENDIF}

  // size of return value = 4 (INT)
  {$IFDEF CPUX64}
  SIC.AddFun (nil, 'c_np_i4r', @c_np_i4r, 0, 0 or (4 shl 8));
  SIC.AddFun (nil, 'c_dp_i4r', @c_dp_i4r, 1, 0 or (4 shl 8));
  SIC.AddFun (nil, 's_np_i4r', @s_np_i4r, 0, 0 or (4 shl 8));
  SIC.AddFun (nil, 's_dp_i4r', @s_dp_i4r, 1, 0 or (4 shl 8));
  {$ELSE}
  SIC.AddFun (nil, 'c_np_i4r', @c_np_i4r, 0, 0 or (4 shl 8));
  SIC.AddFun (nil, 'c_dp_i4r', @c_dp_i4r, 1, 0 or (4 shl 8));
  SIC.AddFun (nil, 's_np_i4r', @s_np_i4r, 0, $00FF or (4 shl 8));
  SIC.AddFun (nil, 's_dp_i4r', @s_dp_i4r, 1, $00FF or (4 shl 8));
  {$ENDIF}

  // dynamic function flag $20 = 00100000
  {$IFDEF CPUX64}
  SIC.AddFun (nil, 'random_c', @random_c, 0, 0 or ($20 shl 8));
  SIC.AddFun (nil, 'random_s', @random_s, 0, 0 or ($20 shl 8));
  {$ELSE}
  SIC.AddFun (nil, 'random_c', @random_c, 0, 0 or ($20 shl 8));
  SIC.AddFun (nil, 'random_s', @random_s, 0, $00FF or ($20 shl 8));
  {$ENDIF}

  (*
  {$IFDEF CPUX64}
  SIC.AddFun (nil, 'sin', @sinn, 1, 0);
  SIC.AddFun (nil, 'cos', @coss, 1, 0);
  {$ENDIF}
  // *)

  SIC.AddFun (nil, 'UF_0P', @UF_0P, 0, 0);
  SIC.AddFun (nil, 'UF_1P', @UF_1P, 1, 0);
  SIC.AddFun (nil, 'UF_2P', @UF_2P, 2, 0);
  SIC.AddFun (nil, 'UF_3P', @UF_3P, 3, 0);
  SIC.AddFun (nil, 'UF_4P', @UF_4P, 4, 0);
  SIC.AddFun (nil, 'UF_5P', @UF_5P, 5, 0);
  SIC.AddFun (nil, 'UF_6P', @UF_6P, 6, 0);

  // rename or duplicate global functions
  SIC.RenameFun (nil, 'log', 'ln', false);      // duplicate
  SIC.RenameFun (nil, 'dou', 'double', false);  // duplicate
  SIC.RenameFun (nil, 'power2', 'pow2', false); // duplicate
  SIC.RenameFun (nil, 'power4', 'pow4', true);  // rename

  // invalidate "meander" global function
  SIC.InvalidateFun (nil, 'meander');

  (*
  // exchange global functions
  SIC.ExchangeFun (nil, 'logn', 'lognr');
  // *)

  (*

  // duplicate if.ne global function // Not equal
  SIC.DuplicateFun (nil, 'if.ba', 'if.ne'); // Below or above
  SIC.DuplicateFun (nil, 'if.lg', 'if.ne'); // Less or greater

  // duplicate if.a global function // Above
  SIC.DuplicateFun (nil, 'if.g'  , 'if.a'); // Greater
  SIC.DuplicateFun (nil, 'if.gt' , 'if.a'); // Greater
  SIC.DuplicateFun (nil, 'if.nbe', 'if.a'); // Not below and equal
  SIC.DuplicateFun (nil, 'if.nle', 'if.a'); // Not less and equal

  // duplicate if.ae global function // Above or equal
  SIC.DuplicateFun (nil, 'if.ge', 'if.ae'); // Greater or equal
  SIC.DuplicateFun (nil, 'if.nb', 'if.ae'); // Not below
  SIC.DuplicateFun (nil, 'if.nl', 'if.ae'); // Not less

  // duplicate if.b global function // Below
  SIC.DuplicateFun (nil, 'if.l'  , 'if.b'); // Less
  SIC.DuplicateFun (nil, 'if.lt' , 'if.b'); // Less
  SIC.DuplicateFun (nil, 'if.nae', 'if.b'); // Not above and equal
  SIC.DuplicateFun (nil, 'if.nge', 'if.b'); // Not greater and equal

  // duplicate if.be global function // Below or equal
  SIC.DuplicateFun (nil, 'if.le', 'if.be'); // Less or equal
  SIC.DuplicateFun (nil, 'if.na', 'if.be'); // Not above
  SIC.DuplicateFun (nil, 'if.ng', 'if.be'); // Not greater

  // *)

  // add user defined global variables
  SIC.AddVarF (nil, 'a', @a);
  SIC.AddVarF (nil, 'b', @b);
  SIC.AddVarF (nil, 'c', @c);
  SIC.AddVarF (nil, 'd', @d);
  SIC.AddVarF (nil, 'x', @x);
  SIC.AddVarF (nil, 'y', @y);
  SIC.AddVarF (nil, 'z', @z);
  SIC.AddVarF (nil, 't', @t);
  SIC.AddVarF (nil, 'u', @u[0]);
  SIC.AddVarF (nil, 'v', @u[3]);

  SIC.AddVarI (nil, 'JJJ', @JJJ);

  SIC.AddVarF (nil, 'l', @l);
  SIC.AddVarF (nil, 's', @s);
  SIC.AddVarF (nil, 'h', @h);

  // add user defined global constants
  SIC.AddConF (nil, '@aaa', 555);
  SIC.AddConF (nil, '@bbb', 0.1);

  // rename or duplicate global constants
  SIC.RenameCon (nil, 'pi', '@pi', false);   // duplicate
  SIC.RenameCon (nil, '2pi', '@2pi', true);  // rename (error)
  SIC.RenameCon (nil, 'pipi', '@2pi', true); // rename

  // add user defined local functions
  {$IFDEF CPUX64}
  SIC.AddFun (@vsic, 'PTEST', @PTEST, 1, B_0001);
  SIC.AddFun (@vsic, 'NRTEST', @NRTEST, 1, B_0001 or ($0F shl 8)); // no result, size of return value = $0F (00001111)
  SIC.AddFun (@vsic, 'NRTEST2', @NRTEST2, 1, ($0F shl 8)); // no result, size of return value = $0F (00001111)
  SIC.AddFun (@vsic, 'ITEST', @ITEST, 1, B_0001);
  SIC.AddFun (@vsic, 'IITEST', @IITEST, 4, B_1111 or (8 shl 8)); // size of return value = 8 (INT_PTR)
  SIC.AddFun (@vsic, 'STEST', @STEST, 1, B_0001);
  SIC.AddFun (@vsic, 'VTEST', @VTEST, -1, B_0000);
  SIC.AddFun (@vsic, 'CoTest', @CoTest, 2, B_0011);
  {$ELSE}
  SIC.AddFun (@vsic, 'PTEST', @PTEST, 1, 1);
  SIC.AddFun (@vsic, 'NRTEST', @NRTEST, 1, 1 or ($0F shl 8)); // no result, size of return value = $0F (00001111)
  SIC.AddFun (@vsic, 'NRTEST2', @NRTEST2, 1, ($0F shl 8)); // no result, size of return value = $0F (00001111)
  SIC.AddFun (@vsic, 'ITEST', @ITEST, 1, 1);
  SIC.AddFun (@vsic, 'IITEST', @IITEST, 4, 4 or (4 shl 8)); // size of return value = 4 (INT_PTR)
  SIC.AddFun (@vsic, 'STEST', @STEST, 1, 1);
  SIC.AddFun (@vsic, 'VTEST', @VTEST, -1, 0);
  SIC.AddFun (@vsic, 'CoTest', @CoTest, 2, 2);
  {$ENDIF}
  SIC.AddFun (@vsic, 'STDCALL_TEST', @STDCALL_TEST, 1, $00FF);
  SIC.AddFun (@vsic, 'STDCALL_ITEST', @STDCALL_ITEST, 1, $00FF or (4 shl 8)); // size of return value = 4 (INT)

  // size of return value = 8 (INT64)
  RT := 8 shl 8;
  SIC.AddFun (@vsic, 'CDECL_I64', @CDECL_I64, 1, 1 or RT);
  SIC.AddFun (@vsic, 'STDCALL_I64', @STDCALL_I64, 1, $00FF or RT);

  // return 2 double values
  // return 2 double values
  RT := B_1001 shl 8;
  SIC.AddFun (@vsic, 'CDECL_RE2', @CDECL_RE2, 1, RT);
  SIC.AddFun (@vsic, 'STDCALL_RE2', @STDCALL_RE2, 1, $00FF or RT);
  SIC.AddFun (@vsic, 'CDECL_2P_RE2', @CDECL_2P_RE2, 2, RT);
  SIC.AddFun (@vsic, 'STDCALL_2P_RE2', @STDCALL_2P_RE2, 2, $00FF or RT);
  // return 3 double values
  RT := B_1010 shl 8;
  SIC.AddFun (@vsic, 'CDECL_RE3', @CDECL_RE3, 1, RT);
  SIC.AddFun (@vsic, 'STDCALL_RE3', @STDCALL_RE3, 1, $00FF or RT);
  SIC.AddFun (@vsic, 'CDECL_2P_RE3', @CDECL_2P_RE3, 2, RT);
  SIC.AddFun (@vsic, 'STDCALL_2P_RE3', @STDCALL_2P_RE3, 2, $00FF or RT);
  // return 4 double values
  RT := B_1100 shl 8;
  SIC.AddFun (@vsic, 'CDECL_RE4', @CDECL_RE4, 1, RT);
  SIC.AddFun (@vsic, 'STDCALL_RE4', @STDCALL_RE4, 1, $00FF or RT);
  SIC.AddFun (@vsic, 'CDECL_2P_RE4', @CDECL_2P_RE4, 2, RT);
  SIC.AddFun (@vsic, 'STDCALL_2P_RE4', @STDCALL_2P_RE4, 2, $00FF or RT);
  SIC.AddFun (@vsic, 'CDECL_4P_RE4', @CDECL_4P_RE4, 4, RT);
  SIC.AddFun (@vsic, 'STDCALL_4P_RE4', @STDCALL_4P_RE4, 4, $00FF or RT);

  // add user defined local variables
  SIC.AddVarF (@vsic, '__a', @a);
  SIC.AddVarF (@vsic, '__b', @b);
  SIC.AddVarF (@vsic, '__c', @c);
  SIC.AddVarF (@vsic, '__d', @d);
  SIC.AddVarF (@vsic, '__x', @x);
  SIC.AddVarF (@vsic, '__y', @y);
  SIC.AddVarF (@vsic, '__z', @z);
  SIC.AddVarF (@vsic, '__t', @t);
  SIC.AddVarI (@vsic, 'III', @III);

  // add user defined local constants
  SIC.AddConF (@vsic, '_AAA', 0.1);
  SIC.AddConF (@vsic, '_BBB', 1.2);
  SIC.AddConF (@vsic, '_CCC', 2.3);
  SIC.AddConP (@vsic, 'PPP', @PPP);

  SIC.AddConS (@vsic, 'C_STR', PAnsiChar(STR));
  SIC.AddConS (@vsic, 'C_STR8', PAnsiChar(STR8));
  SIC.AddVarS (@vsic, 'V_STR', @STR);
  SIC.AddVarS (@vsic, 'V_STR8', @STR8);

  SIC.AddConP (@vsic, 'coa', @coa);
  SIC.AddConP (@vsic, 'cob', @cob);
  SIC.AddVarF (@vsic, 'coa.re', @coa.re);
  SIC.AddVarF (@vsic, 'coa.im', @coa.im);
  SIC.AddVarF (@vsic, 'cob.re', @cob.re);
  SIC.AddVarF (@vsic, 'cob.im', @cob.im);

  SIC.AddConO (@vsic, 'CallProc', @CallProc);
  SIC.AddConO (@vsic, 'Sic2Proc', @Sic2Proc);
  SIC.AddVarO (@vsic, 'Sic2_Proc', @vsic2_proc);

  // pack global tables
  SIC.PackTables (nil);
  // pack local tables
  SIC.PackTables (@vsic);
  SIC.PackTables (@vsic2);
end;
{$ELSE}
begin
end;
{$ENDIF}

{
}
procedure TmForm.SIC_Free;
begin
  {$IFDEF SIC_OCX}
  SIC_Free_OCX;
  {$ELSE}
  SIC_Free_DLL;
  {$ENDIF}
end;

{
}
procedure TmForm.SIC_Free_DLL;
begin
  {$IFNDEF SIC_OCX}
  // free T_sic_data structures
  sic_done (@vsic);
  sic_done (@vsic2);
  // free global tables
  sic_fretab;
  {$ENDIF}
end;

{
}
procedure TmForm.SIC_Free_OCX;
begin
  {$IFDEF SIC_OCX}
  if SIC = nil then Exit;
  {$ENDIF}

  {$IFDEF SIC_OCX}
  // free T_sic_data structures
  SIC.Done (@vsic);
  SIC.Done (@vsic2);
  // free global tables
  SIC.FreeTables;
  {$ENDIF}
end;

{
}
function FUGET_Default: string;
begin
  Result :=
    'sin(logn(10,ln(33.33)*sqrt(abs(' + #13#10 +
    'sin(a)*tan(11.11)+' + #13#10 +
    'cos(b)*cotan(22.22)))+' + #13#10 +
    'exp(c)+power(x,y))-a/b+x*y+z**10)-' + #13#10 +
    'log10(100*a)+logn(x,y)*z-' + #13#10 +
    'sqr(a*b)+sqrt(abs(atan2(a,x)))+' + #13#10 +
    'cos(a*b/c-x*y/z)+hypot(x,y)+' + #13#10 +
    'arcsin(cos(a*b*c))+arccos(sin(x*y*z))+' + #13#10 +
    'sh(x)+ch(y)+th(z)+cth(a)+sch(b)+csh(c)+' + #13#10 +
    'a-b+c-d+int(x)-frac(y)+round(z)-t';
end;

// for Delphi 4 & Lasarus compatibility
{$IFDEF VER_LD5} {$DEFINE __XH} {$ENDIF}
{$IFDEF FPC} {$DEFINE __XH} {$ENDIF}

{$IFDEF __XH}
function CotH (const X: Extended): Extended;
begin
  Result := 1 / TanH(X);
end;

function CscH (const X: Extended): Extended;
begin
  Result := 1 / SinH(X);
end;

function SecH (const X: Extended): Extended;
begin
  Result := 1 / CosH(X);
end;
{$ENDIF}

{
}
function FUTEST: Double;
begin
  Result :=
    sin(logn(10,ln(33.33)*sqrt(abs(sin(a)*tan(11.11)+
    cos(b)*cotan(22.22)))+
    exp(c)+power(x,y))-
    a/b+x*y+power(z,10))-log10(100*a)+logn(x,y)*z-
    sqr(a*b)+sqrt(abs(arctan2(a,x)))+cos(a*b/c-x*y/z)+hypot(x,y)+
    arcsin(cos(a*b*c))+arccos(sin(x*y*z))+
    sinh(x)+cosh(y)+tanh(z)+coth(a)+sech(b)+csch(c)+
    a-b+c-d+int(x)-frac(y)+round(z)-t;
end;

{
}
procedure FUTEST_Leave;
begin
end;

{
}
procedure IDATest (ACount: Integer = 1);
var
  I   : Integer;
  L   : Integer;
  D   : Integer;
  P   : PAnsiChar;
  LD  : TSIC_IDAData;
  x64 : Byte;
begin
  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    Exit;
  end;
  {$ENDIF}

  {$IFDEF CPUX64} x64 := 1; {$ELSE} x64 := 0; {$ENDIF}

  D := 0;
  P := PAnsiChar(@asma);
  for I := 1 to ACount do begin
    {$IFDEF SIC_OCX}
    L := SIC.inda (P + D, @LD, x64);
    {$ELSE}
    L := sic_inda (P + D, @LD, x64);
    {$ENDIF}
    // L := inda (P + D, LD, x64);
    Inc (D, L);
  end;
end;

{
}
procedure TmForm.AssignCaption;
var
  SDLL     : string;
  VVersion : DWORD;
  SVersion : string;
  SCaption : string;
  VSupport : Boolean;
begin
  {$IFDEF SIC_OCX}
  VVersion := 0;
  if Assigned (SIC) then VVersion := SIC.Version;
  {$ELSE}
  VVersion := sic_version;
  {$ENDIF}
  SVersion := Format ('(%u.%u.%u)', [
    (VVersion and $000000FF),
    (VVersion and $0000FF00) shr 8,
    (VVersion and $00FF0000) shr 16
  ]);

  {$IFDEF SIC_SSE}
  {$IFDEF CPUX64}
  SDLL := 'SICs64 (SSE)';
  {$ELSE}
  SDLL := 'SICs32 (SSE)';
  {$ENDIF}
  {$ELSE}
  {$IFDEF CPUX64}
  SDLL := 'SICx64';
  {$ELSE}
  SDLL := 'SICx32';
  {$ENDIF}
  {$ENDIF}

  SCaption := SDLL + ' ' + SVersion + ' TEST';

  {$IFDEF SIC_STATIC}
  SCaption := SCaption + ' Х STATIC';
  {$ENDIF}
  {$IFDEF DEBUG}
  SCaption := SCaption + ' (DEBUG)';
  {$ENDIF}
  {$IFDEF SIC_OCX}
  SCaption := SCaption + ' Х ActiveX';
  {$ENDIF}

  {$IFDEF SIC_OCX}
  VSupport := false;
  if Assigned (SIC) then VSupport := SIC.CPUSupport;
  {$ELSE}
  VSupport := sic_cpu_support;
  {$ENDIF}
  if VSupport then begin
    SCaption := SCaption + ' Х CPU supported';
  end else begin
    SCaption := SCaption + ' Х CPU not supported';
  end;

  Caption := SCaption;
  Application.Title := SCaption;
end;

function FPU_fsin (a: Double): Double;
{$IFDEF CPUX64}
asm
  sub     rsp, 16
  movupd  dqword ptr [rsp], xmm0
  fld     qword ptr [rsp]
  fsin
  fstp    qword ptr [rsp]
  movupd  xmm0, dqword ptr [rsp]
  add     rsp, 16
end;
{$ELSE}
begin
  Result := 0;
end;
{$ENDIF}

function FPU_fcos (a: Double): Double;
{$IFDEF CPUX64}
asm
  sub     rsp, 16
  movupd  dqword ptr [rsp], xmm0
  fld     qword ptr [rsp]
  fcos
  fstp    qword ptr [rsp]
  movupd  xmm0, dqword ptr [rsp]
  add     rsp, 16
end;
{$ELSE}
begin
  Result := 0;
end;
{$ENDIF}

procedure sin_TEST_();
var
  V  : Double;
  V1 : Double;
  V2 : Double;
  I  : Int64;
  I1 : Int64 absolute V1;
  I2 : Int64 absolute V2;
  (*
  J  : Double;
  // *)
begin
  V := 18004;
  V1 := sin(V);
  V2 := FPU_fsin (V);
  I := I2 - I1; // I = 1
  if I = 0 then ;

  V := 18003;
  V1 := sin(V);
  V2 := FPU_fsin (V);
  I := I2 - I1; // I = 0
  if I = 0 then ;

  (*
  J := 1.0;
  while true do begin
    V := V + J;
    V1 := sin(V);
    V2 := FPU_fsin (V);
    I := I2 - I1;
    if I <> 0 then begin
      sleep (1);
      Break;
    end;
  end;
  // *)
end;

procedure cos_TEST_();
var
  V  : Double;
  V1 : Double;
  V2 : Double;
  I  : Int64;
  I1 : Int64 absolute V1;
  I2 : Int64 absolute V2;
  (*
  J  : Double;
  // *)
begin
  V := 17909;
  V1 := cos(V);
  V2 := FPU_fcos (V);
  I := I2 - I1; // I = 1
  if I = 0 then ;

  V := 17908;
  V1 := cos(V);
  V2 := FPU_fcos (V);
  I := I2 - I1; // I = 0
  if I = 0 then ;

  (*
  J := 1;
  while true do begin
    V := V + J;
    V1 := cos(V);
    V2 := FPU_fcos (V);
    I := I2 - I1;
    if I <> 0 then begin
      sleep (1);
      Break;
    end;
  end;
  // *)
end;

{$IFDEF VER_D7L} {$DEFINE __LDResult} {$ENDIF}
{$IFDEF FPC} {$DEFINE __LDResult} {$ENDIF}
{$IFDEF __LDResult}
var
  LDResult : Double;
{$ENDIF}

function FPU_SSE_sin_TEST (a: Double): Double;
var
  I      : Integer;
  I1, I2 : Int64;
  J1, J2 : Int64;
  ID, JD : Double;
  Ratio  : Double;
begin
  QueryPerformanceCounter (I1);
  for I := 1 to 10000000 do begin
    FPU_fsin (a);
  end;
  QueryPerformanceCounter (I2);
  ID := I2 - I1;

  QueryPerformanceCounter (J1);
  for I := 1 to 10000000 do begin
    {$IFDEF __LDResult}
    LDResult := sin (a);
    {$ELSE}
    sin (a);
    {$ENDIF}
  end;
  QueryPerformanceCounter (J2);
  JD := J2 - J1;

  Ratio := ID / JD;
  Result := Ratio;
end;

function FPU_SSE_sin_TEST_(a: Double): Double;
var
  I      : Integer;
  I1, I2 : Int64;
  J1, J2 : Int64;
  ID, JD : Double;
  Ratio  : Double;
begin
  I1 := GetTickCount;
  for I := 1 to 10000000 do begin
    FPU_fsin (a);
  end;
  I2 := GetTickCount;
  ID := I2 - I1;

  J1 := GetTickCount;
  for I := 1 to 10000000 do begin
    {$IFDEF __LDResult}
    LDResult := sin (a);
    {$ELSE}
    sin (a);
    {$ENDIF}
  end;
  J2 := GetTickCount;
  JD := J2 - J1;

  Ratio := ID / JD;
  Result := Ratio;
end;

{
}
procedure asm_test;
asm
end;

{
}
procedure TmForm.FormCreate(Sender: TObject);
begin
  (*
  // _set_error_mode (0{_OUT_TO_DEFAULT});
  // _set_error_mode (1{_OUT_TO_STDERR});
  _set_error_mode (2{_OUT_TO_MSGBOX});
  // _set_error_mode (3{_REPORT_ERRMODE});
  _assert ('oops', 'SICx', 0);
  // *)

  asm_test;

  (*
  sin_TEST_();
  cos_TEST_();

  FPU_SSE_sin_TEST (0.1);
  FPU_SSE_sin_TEST_(0.1);
  // *)

  {$IFDEF SIC_DYNAMIC}
  SICxDProcs.SICxLoad ('');
  {$ENDIF}

  {$IFDEF SIC_SSE}
  SSE_mask_exceptions;
  {$ENDIF}

  // FPUInit;
  // IDATest;
  // asma;

  // cordic_sincos_test;
  // cordic_atan_test;

  SetThreadAffinityMask (GetCurrentThread, 1);
  PerformanceInit (VPData, false);

  {$IFDEF VER_DXEH}
  FormatSettings.DecimalSeparator := SIC_DS;
  {$ELSE}
  DecimalSeparator := SIC_DS;
  {$ENDIF}

  {$IFDEF SIC_SSE}
  ac_TEST_LIST.Hint :=
    'Test all expressions from TEST.LIST file'#13#10 +
    'Save results to TEST_LIST_S.OUTPUT file'#13#10 +
    'Save errors to TEST_LIST_S_ERRORS.OUTPUT file';
  {$ELSE}
  ac_TEST_LIST.Hint :=
    'Test all expressions from TEST.LIST file'#13#10 +
    'Save results to TEST_LIST_X.OUTPUT file'#13#10 +
    'Save errors to TEST_LIST_X_ERRORS.OUTPUT file';
  {$ENDIF}

  BT_DefaultOptions.GroupIndex := 11;

  FacSicExecuteLock := 0;
  FacSicCompileExecLock := 0;
  FacSicCompileLock := 0;
  FacMultiLineExecuteLock := 0;
  FacMultiLineBuildExecLock := 0;
  FacMultiLineBuildLock := 0;

  FED_HexResultLock := 0;

  Escape := false;
  DefOptions := true;
  BT_DefaultOptions.Down := DefOptions;

  CB_Cycles.ItemIndex := 0;
  {$IFNDEF VER_D4L}
  CB_Cycles.AutoComplete := false;
  {$ENDIF}
  CB_Expression.ItemIndex := 0;
  ED_Expression.Text := FUGET_Default;
  ClearError;

  PrintVars;

  {$IFDEF CPUX64}
  (*
  CB_SIC_OPT_STACK_FRAME.Checked := true;
  CB_SIC_OPT_STACK_FRAME.Enabled := false;

  CB_SIC_OPT_STACK_ALIGN.Checked := true;
  CB_SIC_OPT_STACK_ALIGN.Enabled := false;
  // *)
  {$ENDIF}

  BT_Bu01.Down := true;
  BT_Bu01.Click;

  AssignCodeSize (0, 0);
  acDefaultOptions.Execute;
  SIC_Create;

  {$IFDEF DEBUG_int3}
  Exit;
  {$ENDIF}

  ED_VarA.Hint := '"A" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@a));
  ED_VarB.Hint := '"B" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@b));
  ED_VarC.Hint := '"C" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@c));
  ED_VarD.Hint := '"D" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@d));
  ED_VarX.Hint := '"X" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@x));
  ED_VarY.Hint := '"Y" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@y));
  ED_VarZ.Hint := '"Z" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@z));
  ED_VarT.Hint := '"T" variable'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@t));
  ED_VarU_0.Hint := '"U" array variable'#13#10 + 'Item #0'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@u[0]));
  ED_VarU_1.Hint := '"U" array variable'#13#10 + 'Item #1'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@u[1]));
  ED_VarU_2.Hint := '"U" array variable'#13#10 + 'Item #2'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@u[2]));
  ED_VarU_3.Hint := '"U" array variable'#13#10 + 'Item #3'#13#10 + 'ADDR: ' + AsHex_(INT_PTR(@u[3]));

  CB_Expression.Items.ADD ('Default');
  CB_Expression.Items.ADD ('sin(30'#176')+cos(60'#176')');
  CB_Expression.Items.ADD ('!(-a)');
  CB_Expression.Items.ADD ('vmin (4,3,2,1,2,3,4)');
  CB_Expression.Items.ADD ('vmax (1,2,3,4,3,2,1)');
  CB_Expression.Items.ADD ('vsum (1,2,3,4)');
  CB_Expression.Items.ADD ('vmul (1,2,3,4)');
  CB_Expression.Items.ADD ('(u->0 + u->1 + u->2) * u->3');
  CB_Expression.Items.ADD ('crt_rand');
  CB_Expression.Items.ADD ('crt_jn (2:int, 2.387000)');
  CB_Expression.Items.ADD ('crt_yn (2:int, 2.387000)');
  CB_Expression.Items.ADD ('@_izoom2x (2:int, 3:int, 10.0)');
  CB_Expression.Items.ADD ('@_izoom2x2x (2:int, 20.0, 3:int, 30.0)');
  CB_Expression.Items.ADD ('UF_2x2x (2:int, 20.0, 3:int, 30.0)');
  CB_Expression.Items.ADD ('UF_REF (&z)');
  CB_Expression.Items.ADD ('UF_REFF (2:int, 20.0, 3:int, 30.0, &z)');
  CB_Expression.Items.ADD ('UF_5P (1, 2, 3*cos(0), 4, 5)');
  CB_Expression.Items.ADD ('strtod ("123.456", null)');
  CB_Expression.Items.ADD ('PTEST (PPP)');
  CB_Expression.Items.ADD ('STEST ("1234567890")');
  CB_Expression.Items.ADD ('VTEST (1,2,3,4,5,6,7,8,9,10)');
  CB_Expression.Items.ADD ('ie.true (a, x,y)');
  CB_Expression.Items.ADD ('ie.bea (a,2, x,y,z)');
  CB_Expression.Items.ADD ('case (a, 2,x, 3,y, 4,z, 200)');
  CB_Expression.ItemIndex := 0;

  if ExecuteOnStartup then
  acSicExecute.Execute;
end;

{
}
procedure TmForm.FormDestroy(Sender: TObject);
begin
  SIC_Free;

  {$IFDEF SIC_SSE}
  SSE_restore_MXCSR;
  {$ENDIF}
end;

{
}
procedure TmForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

{
}
procedure TmForm.acSicConfigExecute(Sender: TObject);

  function SSEFlag_(AFlags, AFlag: UInt32): string;
  begin
    if (AFlags and AFlag) = AFlag then begin
      Result := '+';
    end else begin
      Result := '-';
    end;
  end;

  function IntToStr_(AValue: UInt32): string; overload;
  begin
    Result := IntToStr (AValue);
    if Length (Result) >= 6 then begin
      Result := Result + #09;
    end else begin
      Result := Result + #09#09;
    end;
  end;

  {$IFDEF CPUX64}
  function IntToStr_(AValue: UInt64): string; overload;
  begin
    Result := IntToStr (AValue);
    if Length (Result) >= 6 then begin
      Result := Result + #09;
    end else begin
      Result := Result + #09#09;
    end;
  end;
  {$ENDIF}

var
  S : string;
begin
  S := 'cflags' + #09#09': ' + IntToStr_(SIC_Config.cflags) + 'Compiler flags' + #13#10;

  if SIC_Config.cflags and SIC_CFG_FLAG_CASE_SENSITIVE = SIC_CFG_FLAG_CASE_SENSITIVE then begin
    S := S + 'SIC_CFG_FLAG_CASE_SENSITIVE' + #13#10;
  end;

  S := S + #13#10;

  S := S + 'memory' + #09#09': ' + IntToStr_(SIC_Config.memory) + 'Memory block size' + #13#10;
  S := S + #13#10;

  S := S + 'SSE' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_SSE) + #13#10;
  S := S + 'SSE-2' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_SSE2) + #13#10;
  S := S + 'SSE-3' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_SSE3) + #13#10;
  S := S + 'SSSE-3' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_SSSE3) + #13#10;
  S := S + 'SSE4.1' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_SSE4_1) + #13#10;
  S := S + 'SSE4.2' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_SSE4_2) + #13#10;
  S := S + 'AVX' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_AVX) + #13#10;
  S := S + 'AVX2' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_AVX2) + #13#10;
  S := S + 'AVX-512' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_AVX512) + #13#10;
  S := S + 'AVX-512F' + #09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_AVX512F) + #13#10;
  S := S + 'AVX-512VL' + #09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_AVX512VL) + #13#10;
  S := S + 'BMI1' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_BMI1) + #13#10;
  S := S + 'BMI2' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_BMI2) + #13#10;
  S := S + 'POPCNT' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_POPCNT) + #13#10;
  S := S + 'LZCNT' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_LZCNT) + #13#10;
  S := S + 'FMA' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_FMA) + #13#10;
  S := S + 'ADX' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_ADX) + #13#10;
  S := S + 'RDRAND' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_RDRAND) + #13#10;
  S := S + 'RDSEED' + #09#09': ' + SSEFlag_(SIC_Config.cpu_flags, SIC_CPU_FLAG_RDSEED) + #13#10;
  S := S + #13#10;

  S := S + 'section_code' + #09': ' + IntToStr_(SIC_Config.section_code) + 'Size of .code section' + #13#10;
  S := S + 'section_data' + #09': ' + IntToStr_(SIC_Config.section_data) + 'Size of .data section' + #13#10;
  S := S + 'section_idata' + #09': ' + IntToStr_(SIC_Config.section_idata) + 'Size of .idata section' + #13#10;
  S := S + 'section_edata' + #09': ' + IntToStr_(SIC_Config.section_edata) + 'Size of .edata section' + #13#10;
  S := S + 'section_rsrc' + #09': ' + IntToStr_(SIC_Config.section_rsrc) + 'Size of .rsrc section' + #13#10;
  S := S + 'section_reloc' + #09': ' + IntToStr_(SIC_Config.section_reloc) + 'Size of .reloc section' + #13#10;
  S := S + #13#10;

  S := S + 'fcode_size' + #09': ' + IntToStr_(SIC_Config.fcode_size) + 'Size of built-in functions' + #13#10;
  S := S + #13#10;

  S := S + 'fdata_size' + #09': ' + IntToStr_(SIC_Config.fdata_size) + 'Function data segment size' + #13#10;
  S := S + 'fdata_count' + #09': ' + IntToStr_(SIC_Config.fdata_count) + 'Maximum function count' + #13#10;
  S := S + 'cdata_size' + #09': ' + IntToStr_(SIC_Config.cdata_size) + 'Constant data segment size' + #13#10;
  S := S + 'cdata_count' + #09': ' + IntToStr_(SIC_Config.cdata_count) + 'Maximum constant count' + #13#10;
  S := S + 'vdata_size' + #09': ' + IntToStr_(SIC_Config.vdata_size) + 'Variable data segment size' + #13#10;
  S := S + 'vdata_count' + #09': ' + IntToStr_(SIC_Config.vdata_count) + 'Maximum variable count' + #13#10;
  S := S + 'rdata_size' + #09': ' + IntToStr_(SIC_Config.rdata_size) + 'Runtime data segment size' + #13#10;
  S := S + 'rdata_count' + #09': ' + IntToStr_(SIC_Config.rdata_count) + 'Maximum runtime count' + #13#10;
  S := S + 'stack_size' + #09': ' + IntToStr_(SIC_Config.stack_size) + 'Stack array size' + #13#10;
  S := S + 'stack_count' + #09': ' + IntToStr_(SIC_Config.stack_count) + 'Maximum token count' + #13#10;
  S := S + 'rpn_size' + #09': ' + IntToStr_(SIC_Config.rpn_size) + 'Rpn array size' + #13#10;
  S := S + 'rpn_count' + #09': ' + IntToStr_(SIC_Config.rpn_count) + 'Maximum rpn item count' + #13#10;
  S := S + 'code_size' + #09': ' + IntToStr_(SIC_Config.code_size) + 'Code segment size' + #13#10;
  S := S + #13#10;

  S := S + 'fitem_nsize' + #09': ' + IntToStr_(SIC_Config.fitem_nsize) + 'Maximum length of function name' + #13#10;
  S := S + 'citem_nsize' + #09': ' + IntToStr_(SIC_Config.citem_nsize) + 'Maximum length of constant name' + #13#10;
  S := S + 'vitem_nsize' + #09': ' + IntToStr_(SIC_Config.vitem_nsize) + 'Maximum length of variable name' + #13#10;
  S := S + #13#10;

  S := S + 'uddata_scount' + #09': ' + IntToStr_(SIC_Config.uddata_scount) + 'Maximum section count in user-defined data files (SIC.UDF, SIC.UDV)' + #13#10;
  S := S + #13#10;

  ShowSicTable (S, 'Compiler Config');
end;

{
}
procedure TmForm.acSelectAllExecute(Sender: TObject);
var
  E : TCustomEdit;
begin
  if ActiveControl = nil then Exit;
  if ActiveControl is TCustomEdit then begin
    E := TCustomEdit(ActiveControl);
    E.SelectAll;
  end;
end;

{
}
procedure TmForm.AssignCodeSize (ASize: UInt32; ASpace: UInt32);
var
  S : string;
begin
  CodeSize := ASize;

  if ASpace > 0 then begin
    S := IntToStr (CodeSize) + ' (' + IntToStr (ASpace) + ')';
  end else begin
    S := IntToStr (CodeSize);
  end;
  SetEditText (ED_CodeSize, S);
  acSaveCode.Enabled := CodeSize > 0;
  acIDA.Enabled := CodeSize > 0;
end;

var
  CB_ExpressionChanging : Boolean = false;

{
}
procedure TmForm.CB_ExpressionChange(Sender: TObject);
var
  Se, S : string;
begin
  if CB_ExpressionChanging then Exit;
  if not IsWindowVisible (Handle) then Exit;

  CB_ExpressionChanging := true;
  try
    Se := CB_Expression.SelText;
    if Se = '' then begin
      S := CB_Expression.Text;
    end else begin
      S := Se;
    end;
    if S = 'Default' then S := FUGET_Default else ;
    ED_Expression.Text := S;

    acSicExecute.Execute;
  finally
    CB_ExpressionChanging := false;
  end;
end;

{
}
procedure TmForm.ED_MultiLineChange(Sender: TObject);
begin
  // acMultiLineExecute.Execute;
end;

{
}
procedure TmForm.acSaveCodeExecute(Sender: TObject);
var
  SFile  : string;
  SData  : AnsiString;
  VFile  : THandle;
  VBytes : DWORD;
begin
  if vsic.entry = 0 then Exit;
  if vsic.size <= 0 then Exit;

  (*
  {$IFDEF CPUX64}
  SFile := 'SICx64.bin';
  {$ELSE}
  SFile := 'SICx32.bin';
  {$ENDIF}
  // *)
  SFile := 'CODE.bin';

  VFile := CreateFile (PChar(SFile), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0);

  if VFile <> INVALID_HANDLE_VALUE then try
    WriteFile (VFile, Pointer(vsic.entry)^, vsic.size, VBytes, nil);
  finally
    CloseHandle (VFile);
  end;

  {$IFDEF CPUX64}
  // SFile := 'SICx64.bin.asm';
  SFile := 'CODE.asm';
  SData := '; http://flatassembler.net '#13#10 +
  //       '; disassemble output file (SICx64.bin.exe) to verify code '#13#10 +
           '; disassemble output file (CODE.exe) to verify code '#13#10 +
           'format PE64 as ''bin_exe'' '#13#10 +
           'entry zentry '#13#10 +
           'section ''.code'' code readable '#13#10 +
           'zentry: '#13#10 +
           'file "CODE.bin" '#13#10 ;
  //       'file "SICx64.bin" '#13#10 ;
  {$ELSE}
  // SFile := 'SICx32.bin.asm';
  SFile := 'CODE.asm';
  SData := '; http://flatassembler.net '#13#10 +
  //       '; disassemble output file (SICx32.bin.exe) to verify code '#13#10 +
           '; disassemble output file (CODE.exe) to verify code '#13#10 +
           'format PE as ''bin_exe'' '#13#10 +
           'entry zentry '#13#10 +
           'section ''.code'' code readable '#13#10 +
           'zentry: '#13#10 +
           'file "CODE.bin" '#13#10 ;
  //       'file "SICx32.bin" '#13#10 ;
  {$ENDIF}

  VFile := CreateFile (PChar(SFile), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0);

  if VFile <> INVALID_HANDLE_VALUE then try
    WriteFile (VFile, PAnsiChar(SData)^, Length (SData), VBytes, nil);
  finally
    CloseHandle (VFile);
  end;

  acIDA.Execute;
end;

{
}
procedure TmForm.SetStatusText (const AText: string);
begin
  (*
  if AText = '' then begin
    StatusBar.Caption := '';
  end else begin
    StatusBar.Caption := ' ' + AText;
  end;
  // *)
  StatusBar.SimpleText := AText;
end;

{
}
procedure TmForm.ClearStatus;
begin
  SetStatusText ('');
end;

{
}
procedure TmForm.PrintStatus (var ASic: TSIC_Data);
begin
  if ASic.ecode <> 0 then begin
    SetStatusText (SicErrorAsString (ASic.ecode));
  end else begin
    SetStatusText ('');
  end;
end;

{
}
procedure TmForm.ClearTime;
begin
  SetEditText (ED_mcsTime, '');
  SetEditText (ED_sTime, '');
end;

{
}
procedure TmForm.PrintTime (var APData: TPerformanceData; ACycles: Integer);
begin
  SetEditText (ED_mcsTime, FloatToStrF (APData.mcSeconds / ACycles, ffFixed, 15, 3));
  SetEditText (ED_sTime, FloatToStrF (APData.Seconds / ACycles, ffFixed, 15, 3));
end;

{
}
procedure TmForm.UpdateVars;

  function StrToFloat_(const S: string): Double;
  var
    V : string;
    C : Char;
    I : Integer;
  begin
    V := S;
    for I := 1 to Length(V) do begin
      C := V[I];
      {$IFDEF VER_DXEH}
      if (C = '.') or (C = ',') then V[I] := FormatSettings.DecimalSeparator;
      {$ELSE}
      if (C = '.') or (C = ',') then V[I] := DecimalSeparator;
      {$ENDIF}
    end;
    Result := StrToFloat (V);
  end;

begin
  a := StrToFloat_(ED_VarA.Text);
  b := StrToFloat_(ED_VarB.Text);
  c := StrToFloat_(ED_VarC.Text);
  d := StrToFloat_(ED_VarD.Text);
  x := StrToFloat_(ED_VarX.Text);
  y := StrToFloat_(ED_VarY.Text);
  z := StrToFloat_(ED_VarZ.Text);
  t := StrToFloat_(ED_VarT.Text);

  u[0] := StrToFloat_(ED_VarU_0.Text);
  u[1] := StrToFloat_(ED_VarU_1.Text);
  u[2] := StrToFloat_(ED_VarU_2.Text);
  u[3] := StrToFloat_(ED_VarU_3.Text);
end;

{
}
procedure TmForm.PrintVars;
begin
  ED_VarA.Text := FloatToStr (a);
  ED_VarB.Text := FloatToStr (b);
  ED_VarC.Text := FloatToStr (c);
  ED_VarD.Text := FloatToStr (d);
  ED_VarX.Text := FloatToStr (x);
  ED_VarY.Text := FloatToStr (y);
  ED_VarZ.Text := FloatToStr (z);
  ED_VarT.Text := FloatToStr (t);

  ED_VarU_0.Text := FloatToStr (u[0]);
  ED_VarU_1.Text := FloatToStr (u[1]);
  ED_VarU_2.Text := FloatToStr (u[2]);
  ED_VarU_3.Text := FloatToStr (u[3]);
end;

{
}
function TmForm.GetCompilerOptions: DWORD;

  procedure GET_(var AResult: DWORD; ACheckBox: TCheckBox; AFlag: DWORD);
  begin
    if ACheckBox.Checked then AResult := AResult or AFlag;
  end;

begin
  Result := 0;
  GET_(Result, CB_SIC_OPT_FLAG_OPTIMIZATION, SIC_OPT_FLAG_OPTIMIZATION);
  GET_(Result, CB_SIC_OPT_FLAG_STACK_FRAME, SIC_OPT_FLAG_STACK_FRAME);
  GET_(Result, CB_SIC_OPT_FLAG_LOCALS, SIC_OPT_FLAG_LOCALS);
  GET_(Result, CB_SIC_OPT_FLAG_FP_FRAME, SIC_OPT_FLAG_FP_FRAME);
  GET_(Result, CB_SIC_OPT_FLAG_NO_CALIGN, SIC_OPT_FLAG_NO_CALIGN);
  GET_(Result, CB_SIC_OPT_FLAG_DEBUG, SIC_OPT_FLAG_DEBUG);
end;

{
}
procedure TmForm.SetCompilerOptions (ASic_coops: DWORD);

  procedure SET_(ACheckBox: TCheckBox; AFlag: DWORD);
  begin
    ACheckBox.Checked := (ASic_coops and AFlag) = AFlag;
  end;

begin
  SET_(CB_SIC_OPT_FLAG_OPTIMIZATION, SIC_OPT_FLAG_OPTIMIZATION);
  SET_(CB_SIC_OPT_FLAG_STACK_FRAME, SIC_OPT_FLAG_STACK_FRAME);
  SET_(CB_SIC_OPT_FLAG_LOCALS, SIC_OPT_FLAG_LOCALS);
  SET_(CB_SIC_OPT_FLAG_FP_FRAME, SIC_OPT_FLAG_FP_FRAME);
  SET_(CB_SIC_OPT_FLAG_NO_CALIGN, SIC_OPT_FLAG_NO_CALIGN);
  SET_(CB_SIC_OPT_FLAG_DEBUG, SIC_OPT_FLAG_DEBUG);
end;

{
}
procedure TmForm.acDefaultOptionsExecute(Sender: TObject);
begin
  DefOptions := BT_DefaultOptions.Down;

  if DefOptions then begin
    {$IFDEF CPUX64}
    SetCompilerOptions (SIC_OPT_DEFAULT_X64);
    {$ELSE}
    SetCompilerOptions (SIC_OPT_DEFAULT_X32);
    {$ENDIF}
  end;
end;

{
}
procedure TmForm.acDefaultVarsExecute(Sender: TObject);
begin
  a := 2;
  b := 8;
  c := 16;
  d := 32;
  x := 1.1;
  y := 2.2;
  z := 3.3;
  t := 4.4;
  u[0] := 1;
  u[1] := 2;
  u[2] := 4;
  u[3] := 8;
  u[4] := 1;
  u[5] := 2;
  u[6] := 4;
  u[7] := 8;

  PrintVars;
end;

{
}
procedure TmForm.ED_HexResultKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

{
}
procedure TmForm.ED_HexResultChange(Sender: TObject);
var
  I : Int64;
  D : Double absolute I;
begin
  if FED_HexResultLock > 0 then Exit;

  Inc (FED_HexResultLock);
  try
    try
      I := StrToInt64 ('$' + ED_HexResult.Text);
      SetEditText (ED_Result, FloatToStrF (D, ffGeneral, 10, 4));
    except
      SetEditText (ED_HexResult, '');
    end;
  finally
    Dec (FED_HexResultLock);
  end;
end;

{$IFDEF VER120} // Delphi 4.0
function TryStrToFloat (const S: string; out Value: Double): Boolean;
begin
  try
    Value := StrToFloat (S);
    Result := true;
  except
    Result := false;
  end;
end;
{$ENDIF}

{
}
procedure TmForm.PrintResult (D: Double);
const
  C_HI = $FFFFFFFF00000000;
var
  S : string;
  V : Double;
  I : Int64;
  H : Int64 absolute D;
  P : Boolean;
begin
  SetEditText (ED_Result, FloatToStrF (D, ffGeneral, 10, 4));

  Inc (FED_HexResultLock);
  try
    try
      S := AnsiUpperCase (Format ('%.16X', [H]));
      SetEditText (ED_HexResult, S);
    except
      SetEditText (ED_HexResult, '');
    end;
  finally
    Dec (FED_HexResultLock);
  end;

  try
    S := ED_Result.Text;

    P := false;
    if AnsiUpperCase (S) = 'INF' then P := true else
    if AnsiUpperCase (S) = '-INF' then P := true else
    if AnsiUpperCase (S) = 'PINF' then P := true else
    if AnsiUpperCase (S) = 'NINF' then P := true else
    if AnsiUpperCase (S) = 'NAN' then P := true ;

    if P then begin
      SetEditText (ED_IntHexResult, '');
    end else begin
      if TryStrToFloat (S, V) then begin
        I := Trunc (V);
        if (I and C_HI) <> C_HI then begin
          S := AnsiUpperCase (Format ('%X', [I]));
        end else begin
          S := AnsiUpperCase (Format ('%X', [Integer(I)]));
        end;
        if (Length (S) mod 2) = 1 then S := '0' + S;
      end else begin
        S := '';
      end;
      SetEditText (ED_IntHexResult, S);
    end;
  except
    SetEditText (ED_IntHexResult, '');
  end;
end;

{
}
procedure TmForm.ClearError;
begin
  L_Error.Visible := false;

  L_OE.Visible := false;
  L_OE_F.Visible := false;
  L_ZE.Visible := false;
  L_ZE_F.Visible := false;
  L_IE.Visible := false;
  L_IE_F.Visible := false;
end;

{
}
procedure TmForm.ClearHexResult;
begin
  Inc (FED_HexResultLock);
  try
    SetEditText (ED_HexResult, '');
  finally
    Dec (FED_HexResultLock);
  end;

  SetEditText (ED_IntHexResult, '');
end;

{
}
procedure TmForm.PrintError (AOptions: DWORD; AError: DWORD);
const
  CF : array [Boolean] of Char = ('0', '1');
var
  V    : Boolean;
  V_OE : Boolean;
  V_ZE : Boolean;
  V_IE : Boolean;
  VCO  : DWORD;
begin
  VCO := AOptions and SIC_OPT_FLAG_FP_FRAME;
  if VCO = 0 then begin
    ClearError;
    Exit;
  end;

  GetFPUExceptionFlags (AError, V_OE, V_ZE, V_IE);
  V := AError <> 0;

  L_Error.Visible := V;

  L_OE.Visible := V;
  L_OE_F.Visible := V;
  L_OE_F.Caption := CF[V_OE];

  L_ZE.Visible := V;
  L_ZE_F.Visible := V;
  L_ZE_F.Caption := CF[V_ZE];

  L_IE.Visible := V;
  L_IE_F.Visible := V;
  L_IE_F.Caption := CF[V_IE];
end;

{
}
procedure TmForm.GetAnsiText (AEdit: TCustomEdit; var S: AnsiString);
var
  Su : string;
begin
  Su := AEdit.SelText;
  if Su = '' then Su := AEdit.Text;
  S := AnsiString (Su);
end;

{
}
procedure TmForm.LocateError (var ASic: TSIC_Data; AEdit: TCustomEdit;
  AStartFrom: Integer);
var
  L  : Integer;
  S  : string;
  nS : Integer;
  nE : Integer;
begin
  if vsic.size > 0 then Exit;

  nS := vsic.pcurs;
  nE := vsic.ccurs;
  if (nS = 0) and (nE = 0) then nE := 1 else
  if (nS > 0) and (nS = nE) then nE := nS + 1;

  if AStartFrom = 0 then begin
    if AEdit.SelLength > 0 then AStartFrom := AEdit.SelStart;
  end;
  Inc (nS, AStartFrom);
  Inc (nE, AStartFrom);

  L := nE - nS;
  if L > 0 then begin
    // S := Copy (AEdit.Text, nS + 1, L);
    S := Copy (AEdit.Text, nS, L);
    // if Trim (S) <> '' then begin
      SendMessage (AEdit.Handle, EM_SETSEL, nS, nE);
    // end;
  end;
end;

{
}
function TmForm.CompileTest (var S: AnsiString; var AOptions: DWORD): PAnsiChar;
begin
  ClearError;

  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    SetEditText (ED_Result, 'SIC = nil');
    ClearHexResult;
    Result := nil;
    Exit;
  end;
  {$ENDIF}

  GetAnsiText (ED_Expression, S);
  Result := PAnsiChar(S);

  AOptions := GetCompilerOptions;
  {$IFDEF SIC_OCX}
  SIC.Compile (@vsic, Result, AOptions);
  {$ELSE}
  sic_compile (@vsic, Result, AOptions);
  {$ENDIF}
  AOptions := vsic.coops;

  SetCompilerOptions (AOptions);
  LocateError (vsic, ED_Expression, 0);
end;

{
}
function TmForm.BuildTest (var S: AnsiString; var AOptions: DWORD): PAnsiChar;
begin
  ClearError;

  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    SetEditText (ED_Result, 'SIC = nil');
    ClearHexResult;
    Result := nil;
    Exit;
  end;
  {$ENDIF}

  GetAnsiText (ED_MultiLine, S);
  Result := PAnsiChar(S);

  AOptions := GetCompilerOptions;
  {$IFDEF SIC_OCX}
  SIC.Build (@vsic, Result, AOptions);
  {$ELSE}
  sic_build (@vsic, Result, AOptions);
  {$ENDIF}
  AOptions := vsic.coops;

  SetCompilerOptions (AOptions);
  LocateError (vsic, ED_MultiLine, 0);
end;

{
}
function TmForm.GetCycles (ADefault: Integer): Integer;
begin
  Result := StrToIntDef (CB_Cycles.Text, ADefault);
  if Result <= 0 then Result := 1;
  CB_Cycles.Text := IntToStr (Result);
end;

{
}
procedure TmForm.ClearRpnItems;
begin
  SetEditText (ED_TokensRpn, '');
  SetEditText (ED_RpnItems, '');
end;

{
}
procedure TmForm.PrintRpnItems (var ASic: TSIC_Data);
begin
  SetEditText (ED_TokensRpn, Format ('%u:%u', [
    ASic.tokens, ASic.rpn]));
  SetEditText (ED_RpnItems, Format ('%u:%u:%u:%u', [
    ASic.fcount, ASic.ccount, ASic.vcount, ASic.rcount]));
end;

{
}
procedure TmForm.acSicExecuteExecute(Sender: TObject);
var
  S    : AnsiString;
  I    : Integer;
  Imax : Integer;
  E    : DWORD;
  D    : Double;
  CO   : DWORD;
  CU   : TCursor;
begin
  if FacSicExecuteLock > 0 then Exit;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Inc (FacSicExecuteLock);
    try

    if DefOptions then acDefaultOptions.Execute;

    D := 0;
    Escape := false;

    {$IFDEF SIC_OCX}
    if SIC = nil then begin
      SetEditText (ED_Result, 'SIC = nil');
      ClearHexResult;
      Exit;
    end;
    {$ENDIF}

    try
      UpdateVars;
      ClearStatus;
      ClearTime;
      CompileTest (S, CO);

      E := 0;
      Imax := GetCycles (count);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        {$IFDEF SIC_OCX}
        D := SIC.Exec (@vsic, E);
        {$ELSE}
        D := sic_exec (@vsic, E);
        {$ENDIF}
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        {$IFDEF SIC_OCX}
        D := SIC.Exec (@vsic, E);
        {$ELSE}
        D := sic_exec (@vsic, E);
        {$ENDIF}
        PerformanceLeave (VPData);

        if E <> 0 then Break;
        if Escape then Break;
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);

      PrintStatus (vsic);
      PrintError (CO, E);
      PrintVars;
    finally
      AssignCodeSize (vsic.size, vsic.cspace);
      PrintRpnItems (vsic);
      PrintResult (D);
    end;

    finally
      Dec (FacSicExecuteLock);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acSicCompileExecExecute(Sender: TObject);
var
  S    : AnsiString;
  P    : PAnsiChar;
  I    : Integer;
  Imax : Integer;
  E    : DWORD;
  D    : Double;
  CO   : DWORD;
  CU   : TCursor;
begin
  if FacSicCompileExecLock > 0 then Exit;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Inc (FacSicCompileExecLock);
    try

    if DefOptions then acDefaultOptions.Execute;

    D := 0;
    Escape := false;

    {$IFDEF SIC_OCX}
    if SIC = nil then begin
      SetEditText (ED_Result, 'SIC = nil');
      ClearHexResult;
      Exit;
    end;
    {$ENDIF}

    try
      UpdateVars;
      ClearStatus;
      ClearTime;
      P := CompileTest (S, CO);

      Imax := GetCycles (count2);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        {$IFDEF SIC_OCX}
        D := SIC.CoExec (@vsic, P, CO, E);
        {$ELSE}
        D := sic_cexec (@vsic, P, CO, E);
        {$ENDIF}
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        {$IFDEF SIC_OCX}
        D := SIC.CoExec (@vsic, P, CO, E);
        {$ELSE}
        D := sic_cexec (@vsic, P, CO, E);
        {$ENDIF}
        PerformanceLeave (VPData);

        if E <> 0 then Break;
        if Escape then Break;
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);

      PrintStatus (vsic);
      PrintError (CO, E);
      PrintVars;
    finally
      AssignCodeSize (0, 0);
      ClearRpnItems;
      PrintResult (D);
    end;

    finally
      Dec (FacSicCompileExecLock);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acSicCompileExecute(Sender: TObject);
var
  S    : AnsiString;
  P    : PAnsiChar;
  I    : Integer;
  Imax : Integer;
  CO   : DWORD;
  CU   : TCursor;
begin
  if FacSicCompileLock > 0 then Exit;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Inc (FacSicCompileLock);
    try

    if DefOptions then acDefaultOptions.Execute;

    Escape := false;

    {$IFDEF SIC_OCX}
    if SIC = nil then begin
      SetEditText (ED_Result, 'SIC = nil');
      ClearHexResult;
      Exit;
    end;
    {$ENDIF}

    try
      ClearStatus;
      ClearTime;
      P := CompileTest (S, CO);

      Imax := GetCycles (count2);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        {$IFDEF SIC_OCX}
        SIC.Compile (@vsic, P, CO);
        {$ELSE}
        sic_compile (@vsic, P, CO);
        {$ENDIF}
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        {$IFDEF SIC_OCX}
        SIC.Compile (@vsic, P, CO);
        {$ELSE}
        sic_compile (@vsic, P, CO);
        {$ENDIF}
        PerformanceLeave (VPData);

        if Escape then Break;
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);

      PrintStatus (vsic);
    finally
      AssignCodeSize (vsic.size, vsic.cspace);
      PrintRpnItems (vsic);
      SetEditText (ED_Result, '');
      ClearHexResult;
    end;

    finally
      Dec (FacSicCompileLock);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acMultiLinePreBuildExecute(Sender: TObject);
const
  S = 'z=1234.4321';
var
  CO : DWORD;
begin
  {$IFNDEF __MultiLinePreBuild}
  Exit;
  {$ENDIF}
  {$IFDEF DEBUG_int3}
  Exit;
  {$ENDIF}

  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    SetEditText (ED_Result, 'SIC = nil');
    ClearHexResult;
    Exit;
  end;
  {$ENDIF}

  CO := GetCompilerOptions;
  {$IFDEF SIC_OCX}
  SIC.Build (@vsic2, S, CO);
  {$ELSE}
  sic_build (@vsic2, S, CO);
  {$ENDIF}
  if vsic2.entry = 0 then ;
end;

{
}
procedure TmForm.acMultiLineBuildExecute(Sender: TObject);
var
  S    : AnsiString;
  P    : PAnsiChar;
  I    : Integer;
  Imax : Integer;
  CO   : DWORD;
  CU   : TCursor;
begin
  if FacMultiLineBuildLock > 0 then Exit;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Inc (FacMultiLineBuildLock);
    try

    if DefOptions then acDefaultOptions.Execute;

    {$IFDEF SIC_OCX}
    if SIC = nil then begin
      SetEditText (ED_Result, 'SIC = nil');
      ClearHexResult;
      Exit;
    end;
    {$ENDIF}

    acMultiLinePreBuild.Execute;

    Escape := false;

    try
      UpdateVars;
      ClearStatus;
      ClearTime;

      {$IFDEF __BuildTest}
      P := BuildTest (S, CO);
      {$ELSE}
      GetAnsiText (ED_MultiLine, S);
      P := PAnsiChar(S);
      CO := GetCompilerOptions;
      {$ENDIF}

      Imax := GetCycles (count2);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        {$IFDEF SIC_OCX}
        SIC.Build (@vsic, P, CO);
        {$ELSE}
        sic_build (@vsic, P, CO);
        {$ENDIF}
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        {$IFDEF SIC_OCX}
        SIC.Build (@vsic, P, CO);
        {$ELSE}
        sic_build (@vsic, P, CO);
        {$ENDIF}
        PerformanceLeave (VPData);

        if Escape then Break;
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);

      PrintStatus (vsic);
      PrintVars;
    finally
      AssignCodeSize (vsic.size, vsic.cspace);
      PrintRpnItems (vsic);
      SetEditText (ED_Result, '');
      ClearHexResult;
    end;

    finally
      Dec (FacMultiLineBuildLock);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acMultiLineBuildExecExecute (Sender: TObject);
var
  S    : AnsiString;
  P    : PAnsiChar;
  I    : Integer;
  Imax : Integer;
  E    : DWORD;
  D    : Double;
  CO   : DWORD;
  CU   : TCursor;
begin
  if FacMultiLineBuildExecLock > 0 then Exit;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Inc (FacMultiLineBuildExecLock);
    try

    if DefOptions then acDefaultOptions.Execute;

    {$IFDEF SIC_OCX}
    if SIC = nil then begin
      SetEditText (ED_Result, 'SIC = nil');
      ClearHexResult;
      Exit;
    end;
    {$ENDIF}

    acMultiLinePreBuild.Execute;

    D := 0;
    Escape := false;

    try
      UpdateVars;
      ClearStatus;
      ClearTime;
      P := BuildTest (S, CO);

      Imax := GetCycles (count2);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        {$IFDEF SIC_OCX}
        D := SIC.BuExec (@vsic, P, CO, E);
        {$ELSE}
        D := sic_bexec (@vsic, P, CO, E);
        {$ENDIF}
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        {$IFDEF SIC_OCX}
        D := SIC.BuExec (@vsic, P, CO, E);
        {$ELSE}
        D := sic_bexec (@vsic, P, CO, E);
        {$ENDIF}
        PerformanceLeave (VPData);

        if E <> 0 then Break;
        if Escape then Break;
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);

      PrintStatus (vsic);
      PrintError (CO, E);
      PrintVars;
    finally
      AssignCodeSize (vsic.size, vsic.cspace);
      PrintRpnItems (vsic);
      PrintResult (D);
    end;

    finally
      Dec (FacMultiLineBuildExecLock);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acMultiLineExecuteExecute(Sender: TObject);
var
  S    : AnsiString;
  I    : Integer;
  Imax : Integer;
  E    : DWORD;
  D    : Double;
  CO   : DWORD;
  CU   : TCursor;
begin
  if FacMultiLineExecuteLock > 0 then Exit;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Inc (FacMultiLineExecuteLock);
    try

    if DefOptions then acDefaultOptions.Execute;

    {$IFDEF SIC_OCX}
    if SIC = nil then begin
      SetEditText (ED_Result, 'SIC = nil');
      ClearHexResult;
      Exit;
    end;
    {$ENDIF}

    acMultiLinePreBuild.Execute;

    D := 0;
    Escape := false;

    try
      UpdateVars;
      ClearStatus;
      ClearTime;
      BuildTest (S, CO);

      Imax := GetCycles (count2);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        try
          {$IFDEF SIC_OCX}
          D := SIC.Exec (@vsic, E);
          {$ELSE}
          D := sic_exec (@vsic, E);
          {$ENDIF}
        except
        //
        end;
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        {$IFDEF SIC_OCX}
        D := SIC.Exec (@vsic, E);
        {$ELSE}
        D := sic_exec (@vsic, E);
        {$ENDIF}
        PerformanceLeave (VPData);

        if E <> 0 then Break;
        if Escape then Break;
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);

      PrintStatus (vsic);
      PrintError (CO, E);
      PrintVars;
    finally
      AssignCodeSize (vsic.size, vsic.cspace);
      PrintRpnItems (vsic);
      PrintResult (D);
    end;

    finally
      Dec (FacMultiLineExecuteLock);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acDelphiExecExecute(Sender: TObject);
var
  I    : Integer;
  Imax : Integer;
  D    : Double;
  CU   : TCursor;
begin
  D := 0;

  CU := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    try
      {$IFDEF CPUX64}
      vsic.entry := UInt64(@FUTEST);
      {$ELSE}
      vsic.entry := UInt32(@FUTEST);
      {$ENDIF}
      vsic.size := PAnsiChar(@FUTEST_Leave) - PAnsiChar(@FUTEST);
      vsic.cspace := 0;

      Inc (FacSicExecuteLock);
      try
        CB_Expression.ItemIndex := 0;
        ED_Expression.Text := FUGET_Default;
      finally
        Dec (FacSicExecuteLock);
      end;

      UpdateVars;
      ClearError;
      ClearStatus;
      ClearTime;

      Imax := GetCycles (count);
      PerformanceReset (VPData);
      Application.ProcessMessages;

      PerformanceEnter (VPData);
      for I := 1 to Imax do begin
        D := FUTEST;
      end;
      PerformanceLeave (VPData);
      (*
      for I := 1 to Imax do begin
        PerformanceEnter (VPData);
        D := FUTEST;
        PerformanceLeave (VPData);
        Application.ProcessMessages;
      end;
      // *)

      PerformanceDone (VPData, false);
      PrintTime (VPData, Imax);
    finally
      AssignCodeSize (vsic.size, vsic.cspace);
      ClearRpnItems;
      PrintResult (D);
    end;
  finally
    Screen.Cursor := CU;
  end;
end;

{
}
procedure TmForm.acGFunTableExecute(Sender: TObject);
const
  CFlags : array [Boolean] of Char = ('0', '1');
var
  S : string;
begin
  S := FunTable (nil);
  ShowSicTable (S, 'Functions - GLOBAL');
end;

{
}
procedure TmForm.acLFunTableExecute(Sender: TObject);
var
  S : string;
begin
  S := FunTable (@vsic);
  ShowSicTable (S, 'Functions - LOCAL');
end;

{
}
procedure TmForm.acGConTableExecute(Sender: TObject);
var
  S : string;
begin
  S := ConTable (nil);
  ShowSicTable (S, 'Constants - GLOBAL');
end;

{
}
procedure TmForm.acLConTableExecute(Sender: TObject);
var
  S : string;
begin
  S := ConTable (@vsic);
  ShowSicTable (S, 'Constants - LOCAL');
end;

{
}
procedure TmForm.acGRunTableExecute(Sender: TObject);
var
  S : string;
begin
  S := RunTable (nil);
  ShowSicTable (S, 'Runtimes - GLOBAL');
end;

{
}
procedure TmForm.acLRunTableExecute(Sender: TObject);
var
  S : string;
begin
  S := RunTable (@vsic);
  ShowSicTable (S, 'Runtimes - LOCAL');
end;

{
}
procedure TmForm.acGVarTableExecute(Sender: TObject);
var
  S : string;
begin
  UpdateVars;
  S := VarTable (nil);
  ShowSicTable (S, 'Variables - GLOBAL');
end;

{
}
procedure TmForm.acLVarTableExecute(Sender: TObject);
var
  S : string;
begin
  UpdateVars;
  S := VarTable (@vsic);
  ShowSicTable (S, 'Variables - LOCAL');
end;

{
}
procedure TmForm.edKeyPress(Sender: TObject; var Key: Char);
begin
  {$IFDEF VER_DXEH}
  if CharInSet (Key, [',', '.']) then Key := SIC_DS;
  {$ELSE}
  if Key in [',', '.'] then Key := SIC_DS;
  {$ENDIF}
end;

{
}
procedure TmForm.acEscapeExecute(Sender: TObject);
begin
  Escape := true;
end;

{
}
procedure TmForm.BT_BenchClick(Sender: TObject);
begin
  CB_Cycles.Text := '1';

  ED_MultiLine.Text :=
    '// Code benchmark '#13#10#13#10 +

    'int i0, imax = 1000000; // 1E-06 '#13#10 +
    'var x0, y0, r0; int p0, n0; str s0; '#13#10#13#10 +

    'i0 = 0; r0 = 0; '#13#10 +
    'x0 = x; y0 = y; '#13#10 +
    'p0 = x; n0 = y; '#13#10#13#10 +

    'bench: // code to bench '#13#10 +
    'r0 = '#13#10 +
    'sin(x0); '#13#10#13#10 +

    'i0 += 1; '#13#10 +
    'goto.if bench, i0 < imax; // goto bench if i0 < imax '#13#10#13#10 +

    'r0; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu01Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    'double aas;      // declare variable '#13#10 +
    ': aas = 1/32767; // evaluate at compile time '#13#10#13#10 +

    'u->3 = roundto (100000*aas, -6); '#13#10#13#10 +

    '// crt_rand returns integer result '#13#10 +
    '// use :double modifier to get double value '#13#10 +
    'x = crt_rand:double * aas; '#13#10#13#10 +

    'a = sin (x); '#13#10 +
    'b = cos (x); '#13#10 +
    'c = a^2 + b^2; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu02Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    'string aa; '#13#10 +
    'string ss = "123456.789"; '#13#10 +
    'string zz = "a\cZ\t\x30"; '#13#10 +
    'string uu = "\u0031\x32\063"; '#13#10#13#10 +

    'aa = ss; '#13#10 +
    'x = strtod (uu, null); '#13#10 +
    'strtod (aa, null) '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu03Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    'int n = 10; '#13#10 +
    'int m = 20; '#13#10 +
    'double nn = n; '#13#10 +
    'a + nn + m:double '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu04Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// sum(n), n=1..100 '#13#10#13#10 +

    'int n = 0; '#13#10 +
    'int m = 100; '#13#10 +
    'double su = 0; '#13#10#13#10 +

    'reset(n); '#13#10 +
    'reset(m); '#13#10 +
    '| SE: '#13#10 +
    '|   n += 1; '#13#10 +
    '|   su += n; '#13#10 +
    '| goto.if SE, n<m; // if n<m then goto SE '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'su // return result '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu05Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// goto label example '#13#10#13#10 +

    'x = 0; '#13#10 +
    'goto mars; '#13#10 +
    'x += 2; '#13#10#13#10 +

    'mars: '#13#10 +
    'x // return result '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu06Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// Procedure call example '#13#10#13#10 +

    'call procc; '#13#10 +
    'goto result; '#13#10#13#10 +

    '| procc: // procedure '#13#10 +
    '| proc.begin '#13#10 +
    '|   a = b*c; '#13#10 +
    '|   a = sin(a); '#13#10 +
    '| proc.end '#13#10 +

    '  '#13#10 +
    'a = 8888; '#13#10#13#10 +

    'result: '#13#10 +
    'a // return result '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu07Click(Sender: TObject);
begin
  CB_Cycles.Text := '1';

  ED_MultiLine.Text :=
    '// Create file example '#13#10#13#10 +

    'int file = 0; '#13#10 +
    'int p2 = 0xC0000000; // GENERIC_READ(0x80000000) or GENERIC_WRITE(0x40000000) '#13#10 +
    'int p3 = 0x00000001; // FILE_SHARE_READ(0x00000001) '#13#10 +
    'int p5 = 2;          // CREATE_ALWAYS(2) '#13#10 +
    'int p6 = 0x00000080; // FILE_ATTRIBUTE_NORMAL(0x00000080) '#13#10 +
    'int p7 = 0; '#13#10 +
    'int pp = 0; '#13#10#13#10 +

    (*
    'int file = 0; '#13#10 +
    'int p2 = 3221225472; // GENERIC_READ(0x80000000) or GENERIC_WRITE(0x40000000) '#13#10 +
    'int p3 = 1;          // FILE_SHARE_READ(0x00000001) '#13#10 +
    'int p5 = 2;          // CREATE_ALWAYS(2) '#13#10 +
    'int p6 = 128;        // FILE_ATTRIBUTE_NORMAL(0x00000080) '#13#10 +
    'int p7 = 0; '#13#10 +
    'int pp = 0; '#13#10#13#10 +
    // *)

    'string data = "http://flatassembler.net\r\n\x22\x95\x22\r\n"; '#13#10 +
    'int sz = lstrlen (data); '#13#10#13#10 +

    'file = CreateFile ( '#13#10 +
    '  "TEST.FILE", '#13#10 +
    '  p2, p3, null, '#13#10 +
    '  p5, p6, p7 '#13#10 +
    '); '#13#10#13#10 +

    'WriteFile (file, '#13#10 +
    '  data, sz, '#13#10 +
    '  &pp, null '#13#10 +
    '); '#13#10#13#10 +

    'CloseHandle (file); '#13#10 +
    'pp // return result '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu08Click(Sender: TObject);
begin
  CB_Cycles.Text := '1';

  ED_MultiLine.Text :=
    '// ¬ычисление элементарной сплайновой '#13#10 +
    '// кривой Catmull-Rom в трехмерном '#13#10 +
    '// пространстве '#13#10#13#10 +

    '// ќпорные точки '#13#10 +
    'double x1 = -1; '#13#10 +
    'double y1 = -1; '#13#10 +
    'double z1 =  0; '#13#10 +
    'double x2 = -1; '#13#10 +
    'double y2 =  1; '#13#10 +
    'double z2 =  0; '#13#10 +
    'double x3 =  1; '#13#10 +
    'double y3 = -1; '#13#10 +
    'double z3 =  0; '#13#10 +
    'double x4 =  1; '#13#10 +
    'double y4 =  1; '#13#10 +
    'double z4 =  0; '#13#10#13#10 +

    '// ѕромежуточные переменные '#13#10 +
    'double px1; '#13#10 +
    'double py1; '#13#10 +
    'double pz1; '#13#10 +
    'double px2; '#13#10 +
    'double py2; '#13#10 +
    'double pz2; '#13#10 +
    'double px3; '#13#10 +
    'double py3; '#13#10 +
    'double pz3; '#13#10 +
    'double px4; '#13#10 +
    'double py4; '#13#10 +
    'double pz4; '#13#10#13#10 +

    'double ansx; '#13#10 +
    'double ansy; '#13#10 +
    'double ansz; '#13#10#13#10 +

    'int iOptCnt = 50000000; // количество рассчитываемых точек '#13#10 +
    'double dt = 1.0 / iOptCnt:double; // инкремент параметра tt на каждой итерации '#13#10#13#10 +

    'double t1; '#13#10 +
    'double t2; '#13#10 +
    'double t3; '#13#10 +
    'double n0; '#13#10 +
    'double n1; '#13#10 +
    'double n2; '#13#10 +
    'double n3; //  оэффициент сплайна '#13#10#13#10 +

    'int i; '#13#10 +
    'double tt; '#13#10#13#10 +

    'i = 0; '#13#10 +
    'tt = 0; '#13#10#13#10 +

    '| SE: '#13#10 +
    '|   // n0 = (-tt * ((1 - tt) * (1 - tt))) / 2; '#13#10 +
    '|   // n1 = (2 - 5 * tt * tt + 3 * tt * tt * tt) / 2; '#13#10 +
    '|   // n2 = (tt / 2) * (1 + 4 * tt - 3 * tt * tt); '#13#10 +
    '|   // n3 = -((tt * tt) / 2) * (1 - tt); '#13#10 +
    '|   '#13#10 +
    '|   t1 = 1 - tt; '#13#10 +
    '|   t2 = tt * tt; '#13#10 +
    '|   t3 = tt * t2; '#13#10 +
    '|   '#13#10 +
    '|   n0 = (-tt * (t1 * t1)) * (1 / 2); '#13#10 +
    '|   n1 = (2 - 5 * t2 + 3 * t3) * (1 / 2); '#13#10 +
    '|   n2 = (tt * (1 / 2)) * (1 + 4 * tt - 3 * t2); '#13#10 +
    '|   n3 = -(t2 * (1 / 2)) * t1; '#13#10 +
    '|   '#13#10 +
    '|   px1 = x1 * n0; py1 = y1 * n0; pz1 = z1 * n0; '#13#10 +
    '|   px2 = x2 * n1; py2 = y2 * n1; pz2 = z2 * n1; '#13#10 +
    '|   px3 = x3 * n2; py3 = y3 * n2; pz3 = z3 * n2; '#13#10 +
    '|   px4 = x4 * n3; py4 = y4 * n3; pz4 = z4 * n3; '#13#10 +
    '|   '#13#10 +
    '|   ansx = px1 + px2 + px3 + px4; '#13#10 +
    '|   ansy = py1 + py2 + py3 + py4; '#13#10 +
    '|   ansz = pz1 + pz2 + pz3 + pz4; '#13#10 +
    '|   '#13#10 +
    '|   tt += dt; '#13#10 +
    '|   i += 1; '#13#10 +
    '| goto.if SE, i<iOptCnt; // if i<iOptCnt then goto SE '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'x = ansx; '#13#10 +
    'y = ansy; '#13#10 +
    'z = ansz; '#13#10 +
    't = tt; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu09Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 0; '#13#10 +
    '// for i := 1 to 100 do begin '#13#10 +
    '//   c := c + 2; '#13#10 +
    '// end; '#13#10#13#10 +

    'int i = 1; '#13#10 +
    'int imax = 100; '#13#10#13#10 +

    'c=0; '#13#10#13#10 +

    'reset(i); '#13#10 +
    'reset(imax); '#13#10 +
    '| for.enter: '#13#10 +
    '|   goto.if for.leave, i>imax; // goto for.leave if i>imax '#13#10 +
    '| for.body: '#13#10 +
    '|   '#13#10 +
    '|   c+=2; '#13#10 +
    '|   '#13#10 +
    '| for.next: '#13#10 +
    '|   i+=1; '#13#10 +
    '|   goto.if for.body, i<=imax; // goto for.body if i<=imax '#13#10 +
    '| for.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu10Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 0; '#13#10 +
    '// for i := 1 to 100 do begin '#13#10 +
    '//   for j := 1 to 100 do begin '#13#10 +
    '//     c := c + 2; '#13#10 +
    '//   end; '#13#10 +
    '// end; '#13#10#13#10 +

    'int i; '#13#10 +
    'int imax; '#13#10 +
    'int j; '#13#10 +
    'int jmax; '#13#10#13#10 +

    'c=0; '#13#10#13#10 +

    '| i=1; imax=100; '#13#10 +
    '| for.i.enter: '#13#10 +
    '|   goto.if for.i.leave, i>imax; // goto for.i.leave if i>imax '#13#10 +
    '| for.i.body: '#13#10 +
    '|   '#13#10 +
    '|   | j=1; jmax=100; '#13#10 +
    '|   | for.j.enter: '#13#10 +
    '|   |   goto.if for.j.leave, j>jmax; // goto for.j.leave if j>jmax '#13#10 +
    '|   | for.j.body: '#13#10 +
    '|   | '#13#10 +
    '|   |   c+=2; '#13#10 +
    '|   | '#13#10 +
    '|   | for.j.next: '#13#10 +
    '|   |   j+=1; '#13#10 +
    '|   |   goto.if for.j.body, j<=jmax; // goto for.j.body if j<=jmax '#13#10 +
    '|   | for.j.leave: '#13#10 +
    '|   '#13#10 +
    '| for.i.next: '#13#10 +
    '|   i+=1; '#13#10 +
    '|   goto.if for.i.body, i<=imax; // goto for.i.body if i<=imax '#13#10 +
    '| for.i.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu11Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 0; '#13#10 +
    '// a := 0; '#13#10 +
    '// b := 8; '#13#10 +
    '// '#13#10 +
    '// while a < b do begin '#13#10 +
    '//   c := c + 1; '#13#10 +
    '//   b := b - 1; '#13#10 +
    '// end; '#13#10#13#10 +

    'c=0; a=0; b=8; '#13#10#13#10 +

    '| while.enter: '#13#10 +
    '|   goto.if while.leave, a>=b; // goto while.leave if a>=b '#13#10 +
    '| while.body: '#13#10 +
    '|   '#13#10 +
    '|   c+=1; '#13#10 +
    '|   b-=1; '#13#10 +
    '|   '#13#10 +
    '| while.next: '#13#10 +
    '|   goto.if while.body, a<b; // goto while.body if a<b '#13#10 +
    '| while.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu12Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 0; '#13#10 +
    '// a := 0; '#13#10 +
    '// b := 8; '#13#10 +
    '// '#13#10 +
    '// repeat '#13#10 +
    '//   c := c + 1; '#13#10 +
    '//   b := b - 1; '#13#10 +
    '// until a > b; '#13#10#13#10 +

    'c=0; a=0; b=8; '#13#10#13#10 +

    '| repeat.enter: '#13#10 +
    '|   '#13#10 +
    '|   c+=1; '#13#10 +
    '|   b-=1; '#13#10 +
    '|   '#13#10 +
    '| repeat.next: '#13#10 +
    '|   goto.if repeat.enter, a<=b; // goto repeat.enter if a<=b '#13#10 +
    '| repeat.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu13Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// case a of '#13#10 +
    '//   x : b := 2; '#13#10 +
    '//   y : b := 4; '#13#10 +
    '//   z : b := 8; '#13#10 +
    '//   else b := 256; '#13#10 +
    '// end; '#13#10#13#10 +

    '| case.enter: '#13#10 +
    '|   goto.if case.x, a==x; // goto case.x if a=x '#13#10 +
    '|   goto.if case.y, a==y; // goto case.y if a=y '#13#10 +
    '|   goto.if case.z, a==z; // goto case.z if a=z '#13#10 +
    '| case.else: '#13#10 +
    '|   b = 256; '#13#10 +
    '|   goto case.leave; '#13#10 +
    '| case.x: '#13#10 +
    '|   b = 2; '#13#10 +
    '|   goto case.leave; '#13#10 +
    '| case.y: '#13#10 +
    '|   b = 4; '#13#10 +
    '|   goto case.leave; '#13#10 +
    '| case.z: '#13#10 +
    '|   b = 8; '#13#10 +
    '|   // goto case.leave; '#13#10 +
    '| case.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'b '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu14Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 1; '#13#10 +
    '// a := 2; '#13#10 +
    '// b := 8; '#13#10 +
    '// '#13#10 +
    '// if a > b then begin '#13#10 +
    '//   c := c + 1; '#13#10 +
    '// end else begin '#13#10 +
    '//   c := c - 1; '#13#10 +
    '// end; '#13#10#13#10 +

    'c=1; a=2; b=8; '#13#10#13#10 +

    '| if.enter: '#13#10 +
    '|   goto.if if.then, a>b; // goto if.then if a>b '#13#10 +
    '|   '#13#10 +
    '| if.else: '#13#10 +
    '|   c-=1; '#13#10 +
    '|   goto if.leave; '#13#10 +
    '|   '#13#10 +
    '| if.then: '#13#10 +
    '|   c+=1; '#13#10 +
    '|   '#13#10 +
    '| if.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu15Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 1; '#13#10 +
    '// a := 2; '#13#10 +
    '// b := 8; '#13#10 +
    '// x := 2.2; '#13#10 +
    '// y := 8.8; '#13#10 +
    '// '#13#10 +
    '// if (a > b) or (x > y) then begin '#13#10 +
    '//   c := c + 1; '#13#10 +
    '// end else begin '#13#10 +
    '//   c := c - 1; '#13#10 +
    '// end; '#13#10#13#10 +

    'c=1; a=2; b=8; x=2.2; y=8.8; '#13#10#13#10 +

    '| if.enter: '#13#10 +
    '|   goto.if if.then, a>b; // goto if.then if a>b '#13#10 +
    '|   goto.if if.then, x>y; // goto if.then if x>y '#13#10 +
    '|   '#13#10 +
    '| if.else: '#13#10 +
    '|   c-=1; '#13#10 +
    '|   goto if.leave; '#13#10 +
    '|   '#13#10 +
    '| if.then: '#13#10 +
    '|   c+=1; '#13#10 +
    '|   '#13#10 +
    '| if.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu16Click(Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 1; '#13#10 +
    '// a := 2; '#13#10 +
    '// b := 8; '#13#10 +
    '// x := 2.2; '#13#10 +
    '// y := 8.8; '#13#10 +
    '// '#13#10 +
    '// if (a > b) and (x > y) then begin '#13#10 +
    '//   c := c + 1; '#13#10 +
    '// end else begin '#13#10 +
    '//   c := c - 1; '#13#10 +
    '// end; '#13#10#13#10 +

    'c=1; a=2; b=8; x=2.2; y=8.8; '#13#10#13#10 +

    '| if.enter: '#13#10 +
    '|   goto.if if.else, a<=b; // goto if.else if a<=b '#13#10 +
    '|   goto.if if.else, x<=y; // goto if.else if x<=y '#13#10 +
    '|   '#13#10 +
    '| if.then: '#13#10 +
    '|   c+=1; '#13#10 +
    '|   goto if.leave; '#13#10 +
    '|   '#13#10 +
    '| if.else: '#13#10 +
    '|   c-=1; '#13#10 +
    '|   '#13#10 +
    '| if.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu17Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// c := 1; '#13#10 +
    '// a := 2; '#13#10 +
    '// b := 8; '#13#10 +
    '// d := 6; '#13#10 +
    '// x := 2.2; '#13#10 +
    '// y := 8.8; '#13#10 +
    '// z := 6.6; '#13#10 +
    '// '#13#10 +
    '// if ((a > b) and (x > y)) or ((a < d) and (x < z)) then begin '#13#10 +
    '//   c := c + 1; '#13#10 +
    '// end else begin '#13#10 +
    '//   c := c - 1; '#13#10 +
    '// end; '#13#10#13#10 +

    'c=1; '#13#10 +
    'a=2; b=8; d=6; '#13#10 +
    'x=2.2; y=8.8; z=6.6; '#13#10#13#10 +

    '| int if.cond; '#13#10 +
    '| if.cond=((a > b) and (x > y)) or ((a < d) and (x < z)); '#13#10 +
    '| if.enter: '#13#10 +
    '|   // goto if.then if (if.cond=true) '#13#10 +
    '|   goto.if if.then, if.cond; '#13#10 +
    '|   '#13#10 +
    '| if.else: '#13#10 +
    '|   c-=1; '#13#10 +
    '|   goto if.leave; '#13#10 +
    '|   '#13#10 +
    '| if.then: '#13#10 +
    '|   c+=1; '#13#10 +
    '|   '#13#10 +
    '| if.leave: '#13#10 +

    '  '#13#10 +
    'result: '#13#10 +
    'c '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu18Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '#+STACK_FRAME '#13#10 +
    '#+LOCALS '#13#10#13#10 +

    'int ps; '#13#10 +
    'int pchar; '#13#10#13#10 +

    '// allocate 20 bytes for string '#13#10 +
    'ps = malloc (0i20); '#13#10 +
    'return.if(-1,ps==0); // return -1 on error '#13#10#13#10 +

    '// convert base-10 integer to string '#13#10 +
    'pchar = ltoa (0i123456789, ps, 0i10); '#13#10#13#10 +

    '// get string length '#13#10 +
    'y = lstrlen (pchar); '#13#10#13#10 +

    '// convert string to double '#13#10 +
    'x = strtod (pchar, null); '#13#10#13#10 +

    '// free string '#13#10 +
    'free (ps); '#13#10#13#10 +

    'result: '#13#10 +
    'x; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu19Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// FPU Control '#13#10 +
    '// msvcrt.dll '#13#10#13#10 +

    'int RC_o = 0; '#13#10 +
    'int PC_o = 0; '#13#10 +
    'int RC_n = 0x00000300; // _RC_CHOP '#13#10 +
    'int PC_n = 0x00000000; // _PC_64 '#13#10#13#10 +

    'RC_o = controlfp (RC_n, 0x00000300); '#13#10 +
    'PC_o = controlfp (PC_n, 0x00030000); '#13#10#13#10 +

    '// Rounding Control '#13#10 +
    '// '#13#10 +
    '// _MCW_RC  = 0x00000300 '#13#10 +
    '// '#13#10 +
    '// _RC_NEAR = 0x00000000 '#13#10 +
    '// _RC_DOWN = 0x00000100 '#13#10 +
    '// _RC_UP   = 0x00000200 '#13#10 +
    '// _RC_CHOP = 0x00000300 '#13#10#13#10 +

    '// Precision Control '#13#10 +
    '// '#13#10 +
    '// _MCW_PC  = 0x00030000 '#13#10 +
    '// '#13#10 +
    '// _PC_64   = 0x00000000 '#13#10 +
    '// _PC_53   = 0x00010000 '#13#10 +
    '// _PC_24   = 0x00020000 '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu20Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// FPU status word test '#13#10#13#10 +

    '// f[n]stsw ax '#13#10 +
    '// ah                        al '#13#10 +
    '// 07 06 05 04 03 02 01 00   07 06 05 04 03 02 01 00 '#13#10 +
    '// ?? C3 ?? ?? ?? C2 C1 C0   ?? ?? PE UE OE ZE DE IE '#13#10#13#10 +

    '// f[n]stcw m2b '#13#10 +
    '// mh                        ml '#13#10 +
    '// 07 06 05 04 03 02 01 00   07 06 05 04 03 02 01 00 '#13#10 +
    '// ?? ?? ?? IC RC RC PC PC   ?? ?? PE UE OE ZE DE IE '#13#10#13#10 +

    'var bb; '#13#10 +
    'var cc; '#13#10 +
    'int cw_o; '#13#10 +
    'int ef_n; '#13#10#13#10 +

    '// clear FPU exception flags '#13#10 +
    'fnclex; '#13#10#13#10 +

    '// save FPU control word '#13#10 +
    'fnstcw cw_o; '#13#10#13#10 +

    '// mask all FPU exceptions '#13#10 +
    'fnmaske 0b00111111; '#13#10#13#10 +

    '// divide by zero '#13#10 +
    'cc = 0; '#13#10 +
    'bb = a / cc; '#13#10#13#10 +

    '// get exception flags '#13#10 +
    'fstef ef_n; '#13#10#13#10 +

    '// test OE, ZE and IE flags '#13#10 +
    'ef_n = ef_n & 0b00001101; '#13#10#13#10 +

    'goto.if.nz E_1, ef_n; // goto E_1 if some flags are set '#13#10#13#10 +

    'E_0: // all flags are clear '#13#10 +
    'b = 888; '#13#10 +
    'goto leave; '#13#10#13#10 +

    'E_1: // some flags are set '#13#10 +
    'b = -888; '#13#10#13#10 +

    'leave: '#13#10#13#10 +

    '// clear FPU exception flags '#13#10 +
    'fnclex; '#13#10#13#10 +

    '// restore FPU control word '#13#10 +
    'fldcw cw_o; '#13#10#13#10 +

    'result: '#13#10 +
    'bb; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu21Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// Bitwise expressions '#13#10#13#10 +

    'var cc = 16; '#13#10 +
    'int uu_1; '#13#10 +
    'int uu_2; '#13#10 +
    'int pp_1; '#13#10 +
    'int pp_2; '#13#10 +
    'int nn_1; '#13#10 +
    'int nn_2; '#13#10 +
    'int ee_1; '#13#10 +
    'int ee_2; '#13#10#13#10 +

    '// uu := 0x1 or 0x2 '#13#10 +
    'uu_1 = 0x1 | 0x2; '#13#10 +
    'uu_2 = 0x1 | (cc/8):int; '#13#10#13#10 +

    '// pp := 0x1 or 0x2 or 0x4 '#13#10 +
    'pp_1 = 0x1 | 0x2 | 0x4; '#13#10 +
    'pp_2 = 0x1 | 0x2 | (cc/4):int; '#13#10#13#10 +

    '// nn := 0x1 or 0x2 or 0x4 or 0x8 '#13#10 +
    'nn_1 = 0x1 | 0x2 | 0x4 | 0x8; '#13#10 +
    'nn_2 = 0x1 | 0x2 | 0x4 | (cc/2):int; '#13#10#13#10 +

    '// ee := 0x1 or 0x2 and 0x4 or 0x10 '#13#10 +
    'ee_1 = 0x1 | 0x2 & 0x4 | 0x10; '#13#10 +
    'ee_2 = 0x1 | 0x2 & 0x4 | cc:int; '#13#10#13#10 +

    'result: '#13#10 +
    'u->0 = uu_2:double; '#13#10 +
    'u->1 = pp_2:double; '#13#10 +
    'u->2 = nn_2:double; '#13#10 +
    'u->3 = ee_2:double; '#13#10 +
    'x = uu_1; '#13#10 +
    'y = pp_1; '#13#10 +
    'z = nn_1; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu22Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// return example '#13#10#13#10 +

    '#+STACK_FRAME '#13#10 +
    '#+LOCALS '#13#10#13#10 +

    'a = x; '#13#10#13#10 +

    '| case.enter: '#13#10 +
    '|   goto.if case.x, a==x; // goto case.x if a=x '#13#10 +
    '|   goto.if case.y, a==y; // goto case.y if a=y '#13#10 +
    '|   goto.if case.z, a==z; // goto case.z if a=z '#13#10 +
    '| case.else: '#13#10 +
    '|   // a=? '#13#10 +
    '|   return (b = 256); '#13#10 +
    '| case.x: '#13#10 +
    '|   // a=x '#13#10 +
    '|   return (b = 2); '#13#10 +
    '| case.y: '#13#10 +
    '|   // a=y '#13#10 +
    '|   return (b = 4); '#13#10 +
    '| case.z: '#13#10 +
    '|   // a=z '#13#10 +
    '|   return (b = 8); '#13#10 +
    '| case.leave: '#13#10#13#10 +

    'a = 888; '#13#10 ;
end;

{
}
procedure TmForm.BT_Bu23Click (Sender: TObject);
begin
  ED_MultiLine.Text :=
    '// Complex numbers '#13#10#13#10 +

    'complex a0 = 10,20; '#13#10 +
    'complex b0 = 30,40; '#13#10 +
    'complex c0 = 50,60; '#13#10 +
    'complex d0 = 70,80; '#13#10 +
    'complex z0 = 11,22; '#13#10 +
    'complex u0, v0, m0, n0; '#13#10#13#10 +

    '// u = (a*z + b)/(c*z + d) '#13#10#13#10 +

    'cmove(u0, '#13#10 +
    '  cdiv( '#13#10 +
    '    cadd(cmul(a0,z0), b0), '#13#10 +
    '    cadd(cmul(c0,z0), d0) '#13#10 +
    '  ) '#13#10 +
    '); '#13#10#13#10 +

    '// v = (1/2)*(z + 1/z) '#13#10#13#10 +

    'cmove(v0, '#13#10 +
    '  crmul(cadd(z0, cinv(z0)), 1/2) '#13#10 +
    '); '#13#10#13#10 +

    '// m = z^2 + c '#13#10#13#10 +

    'cmove(m0, '#13#10 +
    '  cadd(csqr(z0), c0) '#13#10 +
    '); '#13#10#13#10 +

    '// n = z^2.2 + c '#13#10#13#10 +

    'cmove(n0, '#13#10 +
    '  cadd(cpowx(z0, 2.2), c0) '#13#10 +
    '); '#13#10 ;

  (*
  ED_MultiLine.Text :=
    '// Complex numbers '#13#10#13#10 +

    'var a.re=10, a.im=20; '#13#10 +
    'var b.re=30, b.im=40; '#13#10 +
    'var c.re=50, c.im=60; '#13#10 +
    'var d.re=70, d.im=80; '#13#10 +
    'var z.re=11, z.im=22; '#13#10 +
    'var u.re, u.im; '#13#10 +
    'var v.re, v.im; '#13#10 +
    'var m.re, m.im; '#13#10 +
    'var n.re, n.im; '#13#10#13#10 +

    '// u = (a*z + b)/(c*z + d) '#13#10#13#10 +

    'cmove(u.re,u.im, '#13#10 +
    '  cdiv( '#13#10 +
    '    cadd(cmul(a.re,a.im, z.re,z.im), b.re,b.im), '#13#10 +
    '    cadd(cmul(c.re,c.im, z.re,z.im), d.re,d.im) '#13#10 +
    '  ) '#13#10 +
    '); '#13#10#13#10 +

    '// v = (1/2)*(z + 1/z) '#13#10#13#10 +

    'cmove(v.re,v.im, '#13#10 +
    '  crmul(cadd(z.re,z.im, cinv(z.re,z.im)), 1/2) '#13#10 +
    '); '#13#10#13#10 +

    '// m = z^2 + c '#13#10#13#10 +

    'cmove(m.re,m.im, '#13#10 +
    '  cadd(csqr(z.re,z.im), c.re,c.im) '#13#10 +
    '); '#13#10#13#10 +

    '// n = z^2.2 + c '#13#10#13#10 +

    'cmove(n.re,n.im, '#13#10 +
    '  cadd(cpowx(z.re,z.im, 2.2), c.re,c.im) '#13#10 +
    '); '#13#10 ;
  // *)
end;

{
}
procedure TmForm.BT_Bu24Click (Sender: TObject);
begin
//
end;

{
}
procedure TmForm.BT_Bu25Click (Sender: TObject);
begin
//
end;

{
}
procedure TmForm.WMAppMouseWheel (var AMessage: TMessage); // message WM_APP_MOUSE_WHEEL;
begin
  inherited;
end;

{
}
procedure TmForm.WMAppMouseWheelUp (var AMessage: TMessage); // message WM_APP_MOUSE_WHEEL_UP;
var
  OB : TObject;
begin
  inherited;

  try
    OB := TObject(AMessage.WParam);
    if IsClass (OB, TScrollBox) then begin
      VScrollExecute (TScrollBox(OB), true, AMessage.LParam);
    end;
  except
    // bypass exception
  end;
end;

{
}
procedure TmForm.WMAppMouseWheelDown (var AMessage: TMessage); // message WM_APP_MOUSE_WHEEL_DOWN;
var
  OB : TObject;
begin
  inherited;

  try
    OB := TObject(AMessage.WParam);
    if IsClass (OB, TScrollBox) then begin
      VScrollExecute (TScrollBox(OB), false, AMessage.LParam);
    end;
  except
    // bypass exception
  end;
end;

{$IFDEF VER_D7H} {$DEFINE __TColorBox} {$ENDIF}
{$IFDEF FPC} {$UNDEF __TColorBox} {$ENDIF}

{
}
function TmForm.BypassMouseWheel: Boolean;
begin
  Result := true;
  if IsClass (ActiveControl, TMemo) then Exit;
  {$IFDEF __TColorBox}
  if IsClass (ActiveControl, TColorBox) then Exit;
  {$ENDIF}
  if IsClass (ActiveControl, TComboBox) then Exit;

  Result := false;
end;

{
}
procedure TmForm.FormMouseWheel (Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  SB : TScrollBox;
begin
  inherited;
  if BypassMouseWheel then Exit;

  SB := FindScrollBox (SELF, MousePos);
  if SB <> nil then begin
    if WheelDelta > 0 then begin
      PostSingleMessage (Handle, WM_APP_MOUSE_WHEEL_UP, WPARAM(SB), 4);
    end else begin
      PostSingleMessage (Handle, WM_APP_MOUSE_WHEEL_DOWN, WPARAM(SB), 4);
    end;
  end;
end;

{
}
procedure TmForm.FormMouseWheelUp (Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  SB : TScrollBox;
begin
  inherited;
  if BypassMouseWheel then Exit;

  SB := FindScrollBox (SELF, MousePos);
  if SB <> nil then begin
    PostSingleMessage (Handle, WM_APP_MOUSE_WHEEL_UP, WPARAM(SB), 4);
  end;
end;

{
}
procedure TmForm.FormMouseWheelDown (Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  SB : TScrollBox;
begin
  inherited;
  if BypassMouseWheel then Exit;

  SB := FindScrollBox (SELF, MousePos);
  if SB <> nil then begin
    PostSingleMessage (Handle, WM_APP_MOUSE_WHEEL_DOWN, WPARAM(SB), 4);
  end;
end;

{
}
procedure TmForm.FormClick (Sender: TObject);
begin
  ActiveControl := nil;
end;

{
}
procedure SaveData_(const AFile: string; const AData: AnsiString);
var
  VFile  : THandle;
  VBytes : DWORD;
begin
  VFile := CreateFile (PChar(AFile), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0);

  if VFile <> INVALID_HANDLE_VALUE then try
    WriteFile (VFile, PAnsiChar(AData)^, Length(AData), VBytes, nil);
  finally
    CloseHandle (VFile);
  end;
end;

{
}
procedure TmForm.GetIDAStrings (ATXT, ARTF: TStringList);

  {$IFDEF CPUX64}
  function OffsetAsHex_(O: UInt64): string;
  begin
    Result := Result + Format ('%.16X', [O]);
  end;
  {$ELSE}
  function OffsetAsHex_(O: UInt32): string;
  begin
    Result := Result + Format ('%.8X', [O]);
  end;
  {$ENDIF}

  function ByteAsHex_(B: Byte): string;
  begin
    Result := Result + Format ('%.2X', [B]);
  end;

  {$IFDEF CPUX64}
  function BytesAsHex_(P: UInt64; L: Integer): string;
  {$ELSE}
  function BytesAsHex_(P: UInt32; L: Integer): string;
  {$ENDIF}
  var
    I : Integer;
    C : AnsiChar;
    B : Byte absolute C;
  begin
    Result := '';
    for I := 1 to L do begin
      C := PAnsiChar(P)^;
      Result := Result + Format ('%.2X', [B]);
      Inc (P);
    end;
  end;

  {$IFDEF CPUX64}
  function BytesAsSparseHex_(P: UInt64; L: Integer): string;
  {$ELSE}
  function BytesAsSparseHex_(P: UInt32; L: Integer): string;
  {$ENDIF}
  var
    I : Integer;
    C : AnsiChar;
    B : Byte absolute C;
  begin
    Result := '';
    if L <= 0 then Exit;

    C := PAnsiChar(P)^;
    Result := Format ('%.2X', [B]);

    for I := 2 to L do begin
      Inc (P);
      C := PAnsiChar(P)^;
      Result := Result + Format (' %.2X', [B]);
    end;
  end;

  // Instruction format:
  // | prefix | REX/VEX/EVEX | opcode | modR/M | SIB | disp8/16/32 | imm8/16/32/64 |

  {$IFDEF CPUX64}
  function LDAsHex_(P, O: UInt64; L: UInt32; ALD: PSIC_IDAData; var AText: string): string;
  {$ELSE}
  function LDAsHex_(P, O: UInt32; L: UInt32; ALD: PSIC_IDAData; var AText: string): string;
  {$ENDIF}
  var
    D : UInt32;
    S : string;
    B : Byte;
  begin
    S := OffsetAsHex_(O) + ': ';
    Result := '{\cf3 ' + OffsetAsHex_(O) + ': ';
    AText := S;

    if ALD = nil then begin
      S := BytesAsHex_(P, L);
      Result := Result + '{\cf8 ' + S + '} ';
      AText := AText + S + ' ';
    end else begin
      D := 0;

      // if (ALD.flags and IDA_PREFIX) <> 0 then
      if ALD.prefix_size <> 0 then begin
        S := BytesAsHex_(P, ALD.prefix_size);
        Result := Result + '{\cf1 ' + S + '} ';
        AText := AText + S + ' ';
        Inc (D, ALD.prefix_size);
      end;

      if ALD.prex_size <> 0 then begin
        // S := BytesAsSparseHex_(P + D, ALD.prex_size);
        S := BytesAsHex_(P + D, ALD.prex_size);
        Result := Result + '{\cf2 ' + S + '} ';
        AText := AText + S + ' ';
        Inc (D, ALD.prex_size);
      end else
      if (ALD.flags and IDA_REX) <> 0 then begin
        S := BytesAsHex_(P + D, 1);
        Result := Result + '{\cf2 ' + S + '} ';
        AText := AText + S + ' ';
        Inc (D);
      end;

      if ALD.opcode_size <> 0 then begin
        B := PByte(P + ALD.opcode_offset)^;
        S := BytesAsHex_(P + ALD.opcode_offset, ALD.opcode_size);
        if (ALD.opcode_size = 1) and ((B = $55) or (B = $C3) or (B = $C9)) then begin
          // 55 PUSH EBP(RBP)
          // C9 LEAVE
          // C3 RET
          Result := Result + '{\cf3\highlight10 ' + S + '}';
        end else begin
          Result := Result + '{\cf3 ' + S + '}';
        end;
        AText := AText + S;
        D := ALD.opcode_offset + ALD.opcode_size;
      end;

      if (ALD.flags and IDA_MODRM) <> 0 then begin
        S := BytesAsHex_(P + D, 1);
        Result := Result + ' {\cf4 ' + S + '}';
        AText := AText + ' ' + S;
        Inc (D);
      end;

      if (ALD.flags and IDA_SIB) <> 0 then begin
        S := BytesAsHex_(P + D, 1);
        Result := Result + ' {\cf5 ' + S + '}';
        AText := AText + ' ' + S;
        Inc (D);
      end;

      if (ALD.flags and IDA_DISP) <> 0 then
      if (ALD.disp_offset <> 0) and (ALD.disp_size <> 0) then begin
        S := BytesAsHex_(P + ALD.disp_offset, ALD.disp_size);
        if (ALD.flags and IDA_RELATIVE) <> 0 then begin
          Result := Result + ' {\cf6\highlight9 ' + S + '}';
        end else begin
          Result := Result + ' {\cf6 ' + S + '}';
        end;
        AText := AText + ' ' + S;
        D := ALD.disp_offset + ALD.disp_size;
      end;

      if (ALD.flags and IDA_IMM) <> 0 then
      if (ALD.imm_offset <> 0) and (ALD.imm_size <> 0) then begin
        S := BytesAsHex_(P + ALD.imm_offset, ALD.imm_size);
        if (ALD.flags and IDA_RELATIVE) <> 0 then begin
          Result := Result + ' {\cf7\highlight9 ' + S + '}';
        end else begin
          Result := Result + ' {\cf7 ' + S + '}';
        end;
        AText := AText + ' ' + S;
        D := ALD.imm_offset + ALD.imm_size;
      end;

      if D < L then begin
        S := BytesAsHex_(P + D, L - D);
        Result := Result + ' {\cf8 ' + S + '}';
        AText := AText + ' ' + S;
      end;
    end;

    Result := Result + '}';
  end;

{$UNDEF __INDA_STR}
{.$DEFINE __INDA_STR}

{$IFDEF __INDA_STR}
const
// c4 03 19 4a b4 bc 67 ff ff ff 80 	vblendvps xmm14,xmm12,XMMWORD PTR \[r12\+r15\*4-0x99\],xmm8
// CInstr : AnsiString = #$c4#$03#$19#$4a#$b4#$bc#$67#$ff#$ff#$ff#$80 + #$C3;

// C4 03 19 4A B4 BC 67 FF FF FF 80
// vblendvps xmm14,xmm12,dqword[r12+r15*4-0x99],xmm8

// x32
// C4 E3 71 4A 84 90 67 FF FF FF 30
// vblendvps xmm0,xmm1,dqword[eax+edx*4-0x99],xmm3

// 66 f3 44 0f bc 11    	tzcnt  r10w,WORD PTR \[rcx\]
// CInstr : AnsiString = #$66#$f3#$44#$0f#$bc#$11 + #$C3;

// 62 22 7d 48 c4 b4 f0 23 01 00 00 	vpconflictd zmm30,ZMMWORD PTR \[rax\+r14\*8\+0x123\]
// CInstr : AnsiString = #$62#$22#$7d#$48#$c4#$b4#$f0#$23#$01#$00#$00 + #$C3;

// 66 0f 3a 0d 01 00    	blendpd xmm0,XMMWORD PTR \[rcx\],0x0
// CInstr : AnsiString = #$66#$0f#$3a#$0d#$01#$00 + #$C3;

// 66 0f 3a 0b 01 00    	roundsd xmm0,QWORD PTR \[rcx\],0x0
// CInstr : AnsiString = #$66#$0f#$3a#$0b#$01#$00 + #$C3;

// c5 fd d7 cc          	vpmovmskb ecx,ymm4
// c5 ed 72 f6 07       	vpslld ymm2,ymm6,0x7
// CInstr : AnsiString = #$c5#$fd#$d7#$cc#$c5#$ed#$72#$f6#$07 + #$C3;
// c4 e2 cd 98 d4       	vfmadd132pd ymm2,ymm6,ymm4
// CInstr : AnsiString = #$c4#$e2#$cd#$98#$d4 + #$C3;
{$ENDIF}

var
  L      : UInt32;
  LD     : TSIC_IDAData;
  PLD    : PSIC_IDAData;
  x64    : Byte;

  {$IFDEF CPUX64}
  C, CO  : UInt64;
  {$ELSE}
  C, CO  : UInt32;
  {$ENDIF}
  Z      : UInt32;

  SText  : string;
begin
  if ATXT <> nil then ATXT.Clear;
  if ARTF <> nil then ARTF.Clear;

  {$IFDEF __INDA_STR}
  {$IFDEF CPUX64}
  C := UInt64(@CInstr[1]);
  {$ELSE}
  C := UInt32(@CInstr[1]);
  {$ENDIF}
  Z := Length(CInstr);
  {$ELSE}
  C := vsic.entry;
  Z := vsic.size;
  {$ENDIF}

  if C = 0 then Exit;
  if Z <= 0 then Exit;

  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    Exit;
  end;
  {$ENDIF}

  {$IFDEF CPUX64} x64 := 1; {$ELSE} x64 := 0; {$ENDIF}

  if ARTF <> nil then begin
    ARTF.ADD ('{\rtf1\ansi\deff0');
    ARTF.ADD ('{\fonttbl\f0\fmodern Courier New;}');
    ARTF.ADD ('{\colortbl;');
    ARTF.ADD ('\red192\green192\blue192;'); // cf1  // $FFC0C0C0 // clSilver
    ARTF.ADD ('\red128\green128\blue128;'); // cf2  // $FF808080 // clGrey
    ARTF.ADD ('\red0\green0\blue0;');       // cf3  // $FF000000 // clBlack
    ARTF.ADD ('\red128\green0\blue128;');   // cf4  // $FF800080 // clPurple
    ARTF.ADD ('\red0\green128\blue128;');   // cf5  // $FF008080 // clTeal
    ARTF.ADD ('\red0\green0\blue192;');     // cf6  // $FF0000C0 //
 // ARTF.ADD ('\red0\green0\blue128;');     // cf6  // $FF000080 // clNavy
    ARTF.ADD ('\red0\green0\blue255;');     // cf7  // $FF0000FF // clBlue
    ARTF.ADD ('\red255\green0\blue0;');     // cf8  // $FFFF0000 // clRed
    ARTF.ADD ('\red255\green255\blue0;');   // cf9  // $FFFFFF00 // clYellow
    ARTF.ADD ('\red0\green255\blue255;');   // cf10 // $FF00FFFF //
    ARTF.ADD ('}');
    ARTF.ADD ('{\b');
  end;

  CO := 0;
  while Z > 0 do begin
    {$IFDEF SIC_OCX}
    L := SIC.inda (Pointer(C), @LD, x64);
    {$ELSE}
    //L := sic_inda (Pointer(C), @LD, x64);
     L := inda (Pointer(C), LD, x64);
    {$ENDIF}

    if (LD.flags and IDA_INVALID) <> 0 then begin
      if ARTF <> nil then ARTF.ADD ('{\cf8 Invalid instruction}\par');
      if ATXT <> nil then ATXT.ADD ('Invalid instruction');
      Break;
    end;

    if L = 0 then begin
      L := 1;
      PLD := nil;
    end else begin
      PLD := @LD;
    end;
    if ARTF <> nil then ARTF.ADD (LDAsHex_(C, CO, L, PLD, SText) + '\par');
    if ATXT <> nil then ATXT.ADD (SText);

    if L > Z then Break;
    Inc (C, L);
    Inc (CO, L);
    Dec (Z, L);
  end;

  if ARTF <> nil then begin
    ARTF.ADD ('}');
    ARTF.ADD ('}');
  end;
end;

{
}
procedure TmForm.acIDAExecute (Sender: TObject);
var
  VTXT : TStringList;
  VRTF : TStringList;
begin
  VTXT := TStringList.Create;
  try
  VRTF := TStringList.Create;
  try
    GetIDAStrings (VTXT, VRTF);

    {$IFDEF UNICODE}
    SaveData_('CODE_IDA.rtf', AnsiString(VRTF.Text));
    {$ELSE}
    SaveData_('CODE_IDA.rtf', VRTF.Text);
    {$ENDIF}
    // VRTF.SaveToFile ('CODE_IDA.rtf');

    {$IFDEF UNICODE}
    SaveData_('CODE_IDA.txt', AnsiString(VTXT.Text));
    {$ELSE}
    SaveData_('CODE_IDA.txt', VTXT.Text);
    {$ENDIF}
    // VTXT.SaveToFile ('CODE_IDA.txt');
  finally
    VRTF.Free;
  end;
  finally
    VTXT.Free;
  end;
end;

{
}
procedure TmForm.CB_SIC_OPT_FLAG_Click(Sender: TObject);
begin
  if Screen.Cursor <> crHourGlass then begin
    DefOptions := false;
    BT_DefaultOptions.Down := DefOptions;
  end;

  ED_Expression.SelLength := 0;
  ED_MultiLine.SelLength := 0;
end;

{
}
procedure TmForm.BT_ExpressionClipboardClick(Sender: TObject);
begin
  ED_Expression.Text := ClipBrd.Clipboard.AsText;
end;

{
}
procedure TmForm.BT_ExpressionPasteFromClipboardClick(Sender: TObject);
begin
  ED_Expression.PasteFromClipboard;
end;

{
}
procedure TmForm.BT_ExpressionClearClick(Sender: TObject);
begin
  ED_Expression.Text := '';
end;

{
}
procedure TmForm.BT_MultiLineClipboardClick(Sender: TObject);
begin
  ED_MultiLine.Text := ClipBrd.Clipboard.AsText;
end;

{
}
procedure TmForm.BT_MultiLinePasteFromClipboardClick(Sender: TObject);
begin
  ED_MultiLine.PasteFromClipboard;
end;

{
}
procedure TmForm.BT_MultiLineClearClick(Sender: TObject);
begin
  ED_MultiLine.Text := '';
end;

{
}
procedure TmForm.ac_TESTExecute(Sender: TObject);
begin
//
end;

{
}
procedure TmForm.WMAppTestStatus (var AMessage: TMessage); // message WM_APP_TEST_STATUS;
begin
  inherited;
  SetStatusText (IntToStr (AMessage.WParam) + '/' + IntToStr (AMessage.LParam));
end;

{
}
procedure ClearExceptionFlags;
asm
  fnclex

  (*
  {$IFDEF CPUX64}
  stmxcsr dword [rsp - 4]
  and     dword [rsp - 4], $FFFFFFC0
  ldmxcsr dword [rsp - 4]
  {$ELSE}
  stmxcsr dword [esp - 4]
  and     dword [esp - 4], $FFFFFFC0
  ldmxcsr dword [esp - 4]
  {$ENDIF}
  // *)
end;

{
}
procedure TmForm.TEST_(const AHeader: string; const AExpr: string; AExecute: Boolean;
  var ARCount, AECount: Integer; var AROutput, AEOutput: string);
var
  S   : AnsiString;
  P   : PAnsiChar;
  E   : DWORD;
  CO  : DWORD;
  VCO : DWORD;
  D   : Double;
  RT  : string;
begin
  ClearExceptionFlags;

  Inc (ARCount);
  acDefaultVars.Execute;

  if AHeader = '' then begin
    AROutput :=
      CAst80 + #13#10 + AExpr +
      CAst80 + #13#10;
  end else begin
    AROutput :=
      CAst80 + #13#10 + AHeader + #13#10 +
      CAst80 + #13#10 + AExpr +
      CAst80 + #13#10;
  end;

  AEOutput := '';

  CO := GetCompilerOptions;
  S := AnsiString(AExpr);
  P := PAnsiChar(S);

  try
    {$IFDEF SIC_OCX}
    SIC.Build (@vsic, P, CO);
    {$ELSE}
    sic_build (@vsic, P, CO);
    {$ENDIF}
  except
    on E : Exception do begin
      AROutput := AROutput + '!!! EXCEPTION !!! build'#13#10 +
        SicErrorAsString (vsic.ecode) + #13#10#13#10#13#10#13#10;
      AEOutput := AROutput;
      Inc (AECount);
      Exit;
    end;
  end;

  if vsic.size <= 0 then begin
    AROutput := AROutput + '!!! ERROR !!! build'#13#10 +
      SicErrorAsString (vsic.ecode) + #13#10#13#10#13#10#13#10;
    AEOutput := AROutput;
    Inc (AECount);
    Exit;
  end;

  if AExecute then begin
    E := 0;

    try
      {$IFDEF SIC_OCX}
      D := SIC.Exec (@vsic, E);
      {$ELSE}
      D := sic_exec (@vsic, E);
      {$ENDIF}
    except
      on E : Exception do begin
        AROutput := AROutput + '!!! EXCEPTION !!! exec'#13#10 +
          SicErrorAsString (vsic.ecode) + #13#10#13#10#13#10#13#10;
        AEOutput := AROutput;
        Inc (AECount);
        Exit;
      end;
    end;

    VCO := CO and SIC_OPT_FLAG_FP_FRAME;
    if VCO = 0 then E := 0;

    if E <> 0 then begin
      Inc (AECount);
      AROutput := AROutput + '!!! ERROR !!! exec'#13#10 +
        SicErrorAsString (vsic.ecode) + #13#10#13#10#13#10#13#10;
      AEOutput := AROutput;
      Exit;
    end;

    RT := RunTable (@vsic);
    AROutput := AROutput + 'RUNTIMES'#13#10 + RT;
    AROutput := AROutput + 'RESULT = ' + FloatToStr (D) + #13#10;
  end else begin
    AROutput := AROutput + 'BUILD SUCCESS'#13#10;
  end;

  AROutput := AROutput + 'CODE SIZE: ' + IntToStr (vsic.size) +
    #13#10#13#10#13#10#13#10;
end;

{
  Test all expressions from TEST.LIST file

  Save results to TEST_LIST.OUTPUT file
  Save errors to TEST_LIST_ERRORS.OUTPUT file
}
procedure TmForm.ac_TEST_LISTExecute(Sender: TObject);
const
  COPState : array [Boolean] of string = ('[-] ', '[+] ');

var
  CO       : DWORD;

  function OptionString_(AOpFlag: DWORD; const SOpFlag: string): string;
  var
    COOn : Boolean;
  begin
    COOn := (CO and AOpFlag) <> 0;
    Result := COPState[COOn] + SOpFlag;
  end;

var
  T        : DWORD;

  I, L     : Integer;
  S, Smsg  : string;
  SLFile   : string;
  SCFile   : string;
  SOFile   : string;
  SEFile   : string;
  VLFile   : TStringList;
  VCOutput : TStringList;
  VROutput : TStringList;
  VEOutput : TStringList;
  SExpr    : string;
  VPExec   : Boolean;
  VCExec   : Boolean;
  VRCount  : Integer;
  VECount  : Integer;
  SOutput  : string;
  SEOutput : string;
  DType    : TMsgDlgType;
  VCursor  : TCursor;

  {$IFDEF __TEST_VERBOSE_TRUE}
  CText    : Integer;
  SText    : string;
  GVT      : string;
  LVT      : string;
  {$ENDIF}
begin
  ClearStatus;

  {$IFDEF SIC_SSE}
  SCFile := SAPPPath + 'TEST_LAST_S.OUTPUT';
  SOFile := SAPPPath + 'TEST_LIST_S.OUTPUT';
  SEFile := SAPPPath + 'TEST_LIST_S_ERRORS.OUTPUT';
  {$ELSE}
  SCFile := SAPPPath + 'TEST_LAST_X.OUTPUT';
  SOFile := SAPPPath + 'TEST_LIST_X.OUTPUT';
  SEFile := SAPPPath + 'TEST_LIST_X_ERRORS.OUTPUT';
  {$ENDIF}

  if FileExists (SCFile) then DeleteFile (SCFile);
  if FileExists (SEFile) then DeleteFile (SEFile);

  SLFile := SAPPPath + 'TEST.LIST';
  if not FileExists (SLFile) then begin
    S := 'File TEST.LIST not found';
    MessageDlg (S, mtWarning, [mbOK], 0);
    Exit;
  end;

  T := GetTickCount;

  Escape := false;
  VRCount := 0;
  VECount := 0;
  Smsg := '???';

  VCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    VLFile := TStringList.Create;
    try
      VLFile.LoadFromFile (SLFile);

      VCOutput := TStringList.Create;
      try
      VROutput := TStringList.Create;
      try
        VEOutput := TStringList.Create;
        try
          VPExec := true;
          VCExec := true;
          SExpr := '';

          {$IFDEF __TEST_VERBOSE_TRUE}
          CText := 0;
          {$ENDIF}

          Smsg := 'COMPILER OPTIONS:'#13#10;
          CO := GetCompilerOptions;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_OPTIMIZATION , 'SIC_OPT_FLAG_OPTIMIZATION') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_STACK_FRAME  , 'SIC_OPT_FLAG_STACK_FRAME') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_LOCALS       , 'SIC_OPT_FLAG_LOCALS') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_FP_FRAME     , 'SIC_OPT_FLAG_FP_FRAME') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_DEBUG        , 'SIC_OPT_FLAG_DEBUG') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_CPUX64       , 'SIC_OPT_FLAG_CPUX64') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_CPUX32       , 'SIC_OPT_FLAG_CPUX32') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_CPUX         , 'SIC_OPT_FLAG_CPUX') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_DALIGN       , 'SIC_OPT_FLAG_DALIGN') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_NO_CALIGN    , 'SIC_OPT_FLAG_NO_CALIGN') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_NO_ECALC     , 'SIC_OPT_FLAG_NO_ECALC') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_COMPLEX      , 'SIC_OPT_FLAG_COMPLEX') + #13#10;
          Smsg := Smsg + OptionString_(SIC_OPT_FLAG_COMPACT      , 'SIC_OPT_FLAG_COMPACT') + #13#10;
          VROutput.ADD (Smsg + #13#10#13#10#13#10);

          for I := 0 to VLFile.Count - 1 do begin
            try
              S := Trim (VLFile[I]);
              L := Length (S);
              if L <= 0 then Continue;

              if (S[1] = '[') and (S[L] = ']') then begin
                (*
                if S = '[-]' then begin
                  SExpr := '';
                  S := '';
                end else
                // *)
                begin
                  VCExec := S <> '[]';

                  if SExpr <> '' then begin
                    if VRCount = 0 then VPExec := VCExec;

                    {$IFDEF __TEST_VERBOSE_TRUE}
                    Inc (CText);
                    GVT := VarTable (nil);
                    LVT := VarTable (@vsic);
                    SText := '#' + IntToStr (CText) + #13#10 + SExpr;
                    SText := SText + #13#10 + GVT + #13#10 + LVT + #13#10;
                    VCOutput.Text := SText;
                    VCOutput.SaveToFile (SCFile);
                    {$ENDIF}

                    TEST_('', SExpr, VPExec, VRCount, VECount, SOutput, SEOutput);
                    Refresh_(T);

                    SExpr := '';
                    VPExec := VCExec;
                    VROutput.ADD (SOutput);
                    if SEOutput <> '' then VEOutput.ADD (SEOutput);
                  end;

                  S := '';
                end;
              end;

              if S <> '' then
              SExpr := SExpr + S + #13#10;
            except
              on E : Exception do begin
                SOutput := SOutput + '!!! EXCEPTION !!! L0'#13#10 +
                  SicErrorAsString (vsic.ecode) + #13#10#13#10#13#10#13#10;
                SEOutput := SOutput;
                Inc (VECount);
                
                Refresh_(T);

                SExpr := '';
                VPExec := VCExec;
                VROutput.ADD (SOutput);
                if SEOutput <> '' then VEOutput.ADD (SEOutput);
              end;
            end;
          end;

          if SExpr <> '' then begin
            try
              {$IFDEF __TEST_VERBOSE_TRUE}
              Inc (CText);
              GVT := VarTable (nil);
              LVT := VarTable (@vsic);
              SText := '#' + IntToStr (CText) + #13#10 + SExpr;
              SText := SText + #13#10 + GVT + #13#10 + LVT + #13#10;
              VCOutput.Text := SText;
              VCOutput.SaveToFile (SCFile);
              {$ENDIF}

              TEST_('', SExpr, VCExec, VRCount, VECount, SOutput, SEOutput);
              Refresh_(T);

              VROutput.ADD (SOutput);
              if SEOutput <> '' then VEOutput.ADD (SEOutput);
            except
              SOutput := SOutput + '!!! EXCEPTION !!! L2'#13#10 +
                SicErrorAsString (vsic.ecode) + #13#10#13#10#13#10#13#10;
              SEOutput := SOutput;
              Inc (VECount);

              Refresh_(T);

              // SExpr := '';
              // VPExec := VCExec;
              VROutput.ADD (SOutput);
              if SEOutput <> '' then VEOutput.ADD (SEOutput);
            end;
          end;

          Smsg := 'Expressions count: ' + IntToStr (VRCount) + #13#10 +
            'Errors count: ' + IntToStr (VECount);

          VROutput.ADD (Smsg);
          VROutput.SaveToFile (SOFile);

          if VEOutput.Count > 0 then begin
            VEOutput.ADD (Smsg);
            VEOutput.SaveToFile (SEFile);
          end;
        finally
          VEOutput.Free;
        end;
      finally
        VROutput.Free;
      end;
      finally
        VCOutput.Free;
      end;
    finally
      VLFile.Free;
    end;
  finally
    Screen.Cursor := VCursor;
  end;

  if VECount > 0 then begin
    DType := mtWarning;
  end else begin
    DType := mtInformation;
  end;

  Refresh_(T, true);
  MessageDlg (Smsg, DType, [mbOK], 0);
end;

{
  Test all formulas from Visions of Chaos files
  %APPDATA%\Visions of Chaos\Examples\Data\*.*
  %USERPROFILE%\Documents\Visions of Chaos\Data\*.*

  Save results to VOC.OUTPUT file
  Save errors to VOC_ERRORS.OUTPUT file
}
procedure TmForm.ac_TEST_VOCExecute(Sender: TObject);
var
  T         : DWORD;

  VRCount   : Integer;
  VECount   : Integer;
  VFormMask : TMask;
  VGeneMask : TMask;
  VSections : TStringList;
  VValues   : TStringList;
  SCFile    : string;
  SOFile    : string;
  SEFile    : string;
  VCOutput  : TStringList;
  VROutput  : TStringList;
  VEOutput  : TStringList;

  // matches_()
  function matches_(const S: string): Boolean;
  begin
    Result := true;
    if VFormMask.Matches (S) then Exit;
    if VGeneMask.Matches (S) then Exit;
    Result := false;
  end;

  // nameValid_()
  function nameValid_(const Aname: string): Boolean;
  begin
    Result := false;
    if Aname = '.' then Exit;
    if Aname = '..' then Exit;
    Result := true;
  end;

  { Enum_() }
  procedure Enum_(const ARootEnv: string; const ARoot, ADir: string);
  var
    I  : Integer;
    J  : Integer;
    P  : Integer;
    L  : Integer;
    S  : string;
    SE : string;
    SO : string;
    EO : string;
    SN : string;
    SV : string;
    SD : string;
    SF : string;
    FD : string;
    FA : TDateTime;
    SA : string;
    SH : string;
    SR : TSearchRec;
    FR : Integer;
    VF : TMemIniFile;
  begin
    if Escape then Exit;

    FR := FindFirst (ARoot + ADir + '\*.*', faAnyFile, SR);
    try
      while FR = 0 do begin
        if Escape then Break;
        Refresh_(T);

        if nameValid_(SR.name) then begin
          SD := ADir + '\' + SR.name;

          if (SR.Attr and faDirectory) = faDirectory then begin
            Enum_(ARootEnv, ARoot, SD);
          end else begin
            SF := ARoot + SD;
            VF := TMemIniFile.Create (SF);
            try
              {$IFDEF VER_LD2006}
              FA := FileDateToDateTime (FileAge (SF));
              {$ELSE}
              FileAge (SF, FA);
              {$ENDIF}
              SA := FormatDateTime ('yyyy"-"mm"-"dd', FA);
              FD := ARootEnv + '\' + SD + #13#10 + SA;

              VF.ReadSections (VSections);
              for I := 0 to VSections.Count - 1 do begin
                if Escape then Break;
                Refresh_(T);

                SE := VSections[I];
                VF.ReadSectionValues (SE, VValues);

                for J := 0 to VValues.Count - 1 do begin
                  if Escape then Break;
                  Refresh_(T);

                  S := VValues[J];
                  P := AnsiPos ('=', S);
                  if P > 0 then begin
                    SN := Copy (S, 1, P - 1);
                    if matches_(SN) then begin
                      L := Length (S);
                      SV := Copy (S, P + 1, L - P) + #13#10;
                      SH := FD + #13#10 + '[' + SE + '].' + SN;

                      {$IFDEF __TEST_VERBOSE_TRUE}
                      VCOutput.Text := SV;
                      VCOutput.SaveToFile (SCFile);
                      {$ENDIF}

                      TEST_(SH, SV, false, VRCount, VECount, SO, EO);
                      PostSingleMessage (Handle, WM_APP_TEST_STATUS, VRCount, VECount);
                      Refresh_(T);

                      VROutput.ADD (SO);
                      if EO <> '' then VEOutput.ADD (EO);
                    end;
                  end;
                end;
              end;
            finally
              VF.Free;
            end;
          end;
        end;

        FR := FindNext (SR);
      end;
    finally
      FindClose (SR);
    end;
  end;

var
  Smsg    : string;
  SADPath : string;
  SUPPath : string;
  DType   : TMsgDlgType;
  VCursor : TCursor;
begin
  ClearStatus;

  SOFile := SAPPPath + 'VOC.OUTPUT';
  SCFile := SAPPPath + 'VOC_LAST.OUTPUT';
  SEFile := SAPPPath + 'VOC_ERRORS.OUTPUT';
  if FileExists (SCFile) then DeleteFile (SCFile);
  if FileExists (SEFile) then DeleteFile (SEFile);

  SADPath := GetEnvironmentPath ('%APPDATA%');
  SUPPath := GetEnvironmentPath ('%USERPROFILE%');

  T := GetTickCount;

  Escape := false;
  VRCount := 0;
  VECount := 0;
  Smsg := '???';

  VCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    VCOutput := TStringList.Create;
    try
    VROutput := TStringList.Create;
    try
      VEOutput := TStringList.Create;
      try
        VFormMask := TMask.Create ('*Formula*');
        try
          VGeneMask := TMask.Create ('*Gene*');
          try

          VSections := TStringList.Create;
          try
            VValues := TStringList.Create;
            try
              Enum_('%APPDATA%', SADPath, 'Visions of Chaos\Examples\Data');
              Enum_('%USERPROFILE%', SUPPath, 'Documents\Visions of Chaos\Data');
            finally
              VValues.Free;
            end;
          finally
            VSections.Free;
          end;

          finally
            VGeneMask.Free;
          end;
        finally
          VFormMask.Free;
        end;

        Smsg := 'Expressions count: ' + IntToStr (VRCount) + #13#10 +
          'Errors count: ' + IntToStr (VECount);
        if Escape then Smsg := Smsg + #13#10#13#10 + 'Canceled by user';

        VROutput.ADD (Smsg);
        VROutput.SaveToFile (SOFile);

        if VEOutput.Count > 0 then begin
          VEOutput.ADD (Smsg);
          VEOutput.SaveToFile (SEFile);
        end;
      finally
        VEOutput.Free;
      end;
    finally
      VROutput.Free;
    end;
    finally
      VCOutput.Free;
    end;
  finally
    Screen.Cursor := VCursor;
  end;

  if VECount > 0 then begin
    DType := mtWarning;
  end else begin
    DType := mtInformation;
  end;

  Refresh_(T, true);
  MessageDlg (Smsg, DType, [mbOK], 0);
end;

{
}
procedure SICxProcs_mt19937_test (AOutput: TmForm);
const
  {$IFDEF CPUX64}
  seeds : array[0..3] of UIntX = ($12345, $23456, $34567, $45678);
  {$ELSE}
  seeds : array[0..3] of UIntX = ($123, $234, $345, $456);
  {$ENDIF}
var
  I : Integer;
  U : UIntX;
  D : Double;
begin
  AOutput.ClearTime;
  AOutput.ED_MultiLine.Lines.Clear;

  {$IFDEF SIC_OCX}
  SIC.mt19937_seeds (@seeds, 4);
  for I := 1 to 1000 do begin
    U := SIC.mt19937_igen;
    AOutput.ED_MultiLine.Lines.ADD (Format ('%u', [u]));
  end;
  for I := 1 to 1000 do begin
    D := SIC.mt19937_fgen;
    AOutput.ED_MultiLine.Lines.ADD (Format ('%g', [D]));
  end;
  {$ELSE}
  mt19937_seeds (@seeds, 4);
  for I := 1 to 1000 do begin
    U := mt19937_igen;
    AOutput.ED_MultiLine.Lines.ADD (Format ('%u', [u]));
  end;
  for I := 1 to 1000 do begin
    D := mt19937_fgen;
    AOutput.ED_MultiLine.Lines.ADD (Format ('%g', [D]));
  end;
  {$ENDIF}
end;

{
}
procedure TmForm.ac_TEST_mt19937_SICxExecute (Sender: TObject);
begin
  SICxProcs_mt19937_test (SELF);
end;

{
}
procedure mt19937_test (AOutput: TmForm);
const
  S32 = SizeOf(UInt32);
  {$IFDEF CPUX64}
  seeds : array[0..3] of UIntX = ($12345, $23456, $34567, $45678);
  {$ELSE}
  seeds : array[0..3] of UIntX = ($123, $234, $345, $456);
  {$ENDIF}
var
  I    : Integer;
  Imax : Integer;
  U    : UIntX;
  D    : Double;
  R    : PUInt32;
  P    : PUInt32;
begin
  AOutput.ClearTime;
  AOutput.ED_MultiLine.Lines.Clear;

  mt19937.mt19937_seeds (@seeds, 4);

  Imax := 1000;
  R := GetMemory (Imax * S32);
  try
    PerformanceReset (VPData);
    PerformanceEnter (VPData);
    P := R;
    for I := 0 to Imax - 1 do begin
      P^ := mt19937.mt19937_igen;
      P := PUInt32(PAnsiChar(P) + S32);
    end;
    PerformanceLeave (VPData);
    PerformanceDone (VPData, false);
    AOutput.PrintTime (VPData, Imax);
    Application.ProcessMessages;

    AOutput.ED_MultiLine.Lines.BeginUpdate;
    try
      P := R;
      for I := 0 to Imax - 1 do begin
        U := P^;
        P := PUInt32(PAnsiChar(P) + S32);
        AOutput.ED_MultiLine.Lines.ADD (Format ('%u', [U]));
      end;
    finally
      AOutput.ED_MultiLine.Lines.EndUpdate;
    end;
  finally
    FreeMemory (R);
  end;

  AOutput.ED_MultiLine.Lines.BeginUpdate;
  try
    for I := 1 to 1000 do begin
      {$IFDEF CPUX64}
      D := mt19937.mt19937_fgen;
      {$ELSE}
      D := mt19937.mt19937_gen0;
      {$ENDIF}
      AOutput.ED_MultiLine.Lines.ADD (Format ('%g', [D]));
    end;
  finally
    AOutput.ED_MultiLine.Lines.EndUpdate;
  end;
end;

{
}
procedure TmForm.ac_TEST_mt19937_DelphiExecute (Sender: TObject);
begin
  mt19937_test (SELF);
end;

{
}
procedure TmForm.ac_TEST_sfmtExecute(Sender: TObject);
{$IFDEF __SFMT}
const
  S32 = SizeOf(UInt32);
var
  I    : Integer;
  Imax : Integer;
  U    : UInt32;
  R    : PUInt32;
  P    : PUInt32;
begin
  sfmt_init;
  try

  SELF.ClearTime;
  SELF.ED_MultiLine.Lines.Clear;

  SELF.ED_MultiLine.Lines.ADD (sfmt_get_idstring);
  SELF.ED_MultiLine.Lines.ADD ('32 bit generated randoms');
  SELF.ED_MultiLine.Lines.ADD ('init_gen_rand__________');

  sfmt_init_gen_rand (1234);

  Imax := 1000;
  R := GetMemory (Imax * S32);
  try
    PerformanceReset (VPData);
    PerformanceEnter (VPData);
    P := R;
    for I := 0 to Imax - 1 do begin
      P^ := sfmt_genrand_uint32;
      P := PUInt32(PAnsiChar(P) + S32);
    end;
    PerformanceLeave (VPData);
    PerformanceDone (VPData, false);
    SELF.PrintTime (VPData, Imax);
    Application.ProcessMessages;

    SELF.ED_MultiLine.Lines.BeginUpdate;
    try
      P := R;
      for I := 0 to Imax - 1 do begin
        U := P^;
        P := PUInt32(PAnsiChar(P) + S32);
        SELF.ED_MultiLine.Lines.ADD (Format ('%u', [U]));
      end;
    finally
      SELF.ED_MultiLine.Lines.EndUpdate;
    end;
  finally
    FreeMemory (R);
  end;

  finally
    sfmt_done;
  end;
end;
{$ELSE}
begin
  SELF.ClearTime;
  SELF.ED_MultiLine.Lines.Clear;
  SELF.ED_MultiLine.Lines.ADD ('sfmt disabled');
end;
{$ENDIF}

{
}
procedure TmForm.ac_TEST_sfmt_aExecute(Sender: TObject);
{$IFDEF __SFMT}
const
  S32 = SizeOf(UInt32);
  C : array [0..3] of UInt32 = ($1234, $5678, $9abc, $def0);
var
  I    : Integer;
  Imax : Integer;
  U    : UInt32;
  R    : PUInt32;
  P    : PUInt32;
begin
  sfmt_init;
  try

  SELF.ClearTime;
  SELF.ED_MultiLine.Lines.Clear;

  SELF.ED_MultiLine.Lines.ADD (sfmt_get_idstring);
  SELF.ED_MultiLine.Lines.ADD ('32 bit generated randoms');
  SELF.ED_MultiLine.Lines.ADD ('init_by_array__________');

  sfmt_init_by_array (@C, 4);

  PerformanceReset (VPData);
  Imax := 1000;
  R := GetMemory (Imax * S32);
  try
    PerformanceEnter (VPData);
    P := R;
    for I := 0 to Imax - 1 do begin
      P^ := sfmt_genrand_uint32;
      P := PUInt32(PAnsiChar(P) + S32);
    end;
    PerformanceLeave (VPData);

    SELF.ED_MultiLine.Lines.BeginUpdate;
    try
      P := R;
      for I := 0 to Imax - 1 do begin
        U := P^;
        P := PUInt32(PAnsiChar(P) + S32);
        SELF.ED_MultiLine.Lines.ADD (Format ('%u', [U]));
      end;
    finally
      SELF.ED_MultiLine.Lines.EndUpdate;
    end;
  finally
    FreeMemory (R);
  end;

  PerformanceDone (VPData, false);
  SELF.PrintTime (VPData, Imax);

  finally
    sfmt_done;
  end;
end;
{$ELSE}
begin
  SELF.ClearTime;
  SELF.ED_MultiLine.Lines.Clear;
  SELF.ED_MultiLine.Lines.ADD ('sfmt disabled');
end;
{$ENDIF}

{
}
procedure Enter;
begin
  SAPPPath := ExtractFilePath (ParamStr(0));
end;

initialization
  uTest.Enter;

end.

