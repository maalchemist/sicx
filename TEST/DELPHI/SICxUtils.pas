unit SICxUtils;

// SICx utils

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
  Windows, Messages, Forms, Controls,
  {$IFDEF SIC_OCX}
  {$IFDEF CPUX64} SICx64_TLB, {$ELSE} SICx32_TLB, {$ENDIF}
  {$ELSE}
  SICxTypes,
  {$IFDEF SIC_DYNAMIC} SICxDProcs, {$ELSE} SICxProcs, {$ENDIF}
  {$ENDIF}
  SICxDefs;

const
  WM_APP_UPDATE_CAPTION   = WM_APP + 1001; // перерисовка заголовка
  WM_APP_MOUSE_WHEEL      = WM_APP + 1002;
  WM_APP_MOUSE_WHEEL_UP   = WM_APP + 1003;
  WM_APP_MOUSE_WHEEL_DOWN = WM_APP + 1004;
  WM_APP_TEST_STATUS      = WM_APP + 1005;

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

type
  PPerformanceData = ^TPerformanceData;
  TPerformanceData = record
    CType      : Integer; // 0 - GetTickCount
                          // 1 - QueryPerformanceCounter
    Frequency  : Int64;

    Count      : Int64;
    EnterCount : Int64;
    LeaveCount : Int64;

    Seconds    : Double;  // секунды
    mSeconds   : Double;  // миллисекунды
    mcSeconds  : Double;  // микросекунды
  end;

function  FloatToStr_(A: Double): string;

function  SicErrorAsString (AError: DWORD): string;

procedure PerformanceInit (var AData: TPerformanceData; AEnter: Boolean);
procedure PerformanceReset (var AData: TPerformanceData);
procedure PerformanceEnter (var AData: TPerformanceData);
procedure PerformanceLeave (var AData: TPerformanceData);
procedure PerformanceDone (var AData: TPerformanceData; ALeave: Boolean);

function  IsClass (AObject: TObject; AClass: TClass): Boolean;
function  PostSingleMessage (AWnd: HWND; AMsg: UINT; AWParam: WPARAM; ALParam: LPARAM; AMsgPeekCount: Integer = 1024): Integer;
function  HandleAsWinControl (AParent: TObject; AHandle: THandle): TWinControl;
function  FindScrollBox (AParent: TObject; const AMousePos: TPoint): TScrollBox;
function  FindParentScrollBox (AControl: TObject): TScrollBox;
procedure VScrollExecute (AScrollBox: TScrollBox; AUP: Boolean; AIncrementFactor: Integer);

function  Evaluate (const S: string; var AError: DWORD): Double;

procedure GetFPUExceptionFlags (const AError: DWORD; var A_OE, A_ZE, A_IE: Boolean); overload;
procedure GetFPUExceptionFlags (const AError: DWORD; var A_ES, A_SF, A_PE, A_UE, A_OE, A_ZE, A_DE, A_IE: Boolean); overload;

function  GetItemName (var AItem: TSIC_FunItem): string; overload;
function  GetItemName (var AItem: TSIC_ConItem): string; overload;
function  GetItemName (var AItem: TSIC_VarItem): string; overload;

function  GetString_(PS: PAnsiChar): string;

function  TrimALL (const S: string): string;

function  FunTable (Asic: Pointer): string;
function  FunItem (var AItem: TSIC_FunItem; AIndex: Integer): string;
function  ConTable (Asic: Pointer): string;
function  ConItem (var AItem: TSIC_ConItem; AIndex: Integer): string;
function  VarTable (Asic: Pointer): string;
function  VarItem (var AItem: TSIC_VarItem; AIndex: Integer): string;
function  RunTable (Asic: Pointer): string;

function  AsHex_(V: INT_PTR): string;
function  ExpandSicString (const S: string): string;
function  CollapseSicString (const S: string): string;

function  Round_D (AValue: Double): Double;
function  IRound_D (AValue: Double): INT_PTR;

function  GetEnvironmentPath (const AEnvString: string): string;

function  sic_afuns (ASic: Pointer): Integer;

(*
function smf_sph_bessel (n: Integer; x: Double): Double; stdcall;
// *)

{$IFDEF SIC_OCX}
var
  {$IFDEF CPUX64}
  SIC : ISICx64 = nil;
  {$ELSE}
  SIC : ISICx32 = nil;
  {$ENDIF}
{$ENDIF}

implementation

uses
  SysUtils, Classes, Math;

(*
function smf_sph_bessel; external 'msvcp140_2.dll' name '___std_smf_sph_bessel@12';
// *)

{
}
function IsNZero_(A: Double): Boolean;
var
  E  : Int64 absolute A;
  EL : Integer absolute A;
begin
  Result := false;
  if EL <> 0 then Exit;
  E := E shr 32;
  Result := E = $80000000;
end;

{
}
function FloatToStr_(A: Double): string;
var
  E : Int64 absolute A;
begin
  if IsNZero_(A) then begin
    Result := '-0';
    Exit;
  end;

  Result := FloatToStrF (A, ffGeneral, 15, 30);
end;

{
}
function SicErrorAsString (AError: DWORD): string;
begin
  Result := '???';
  case AError of
    SIC_ERROR_SUCCESS    : Result := 'SIC_ERROR_SUCCESS';
    SIC_ERROR_GENERAL    : Result := 'SIC_ERROR_GENERAL';
    SIC_ERROR_CPU        : Result := 'SIC_ERROR_CPU';
    SIC_ERROR_STRING     : Result := 'SIC_ERROR_STRING';
    SIC_ERROR_MEMORY     : Result := 'SIC_ERROR_MEMORY';
    SIC_ERROR_BRACKET    : Result := 'SIC_ERROR_BRACKET';
    SIC_ERROR_TOKEN      : Result := 'SIC_ERROR_TOKEN';
    SIC_ERROR_RT_TOKEN   : Result := 'SIC_ERROR_RT_TOKEN';
    SIC_ERROR_STACK      : Result := 'SIC_ERROR_STACK';
    SIC_ERROR_RPN_BUILD  : Result := 'SIC_ERROR_RPN_BUILD';
    SIC_ERROR_CODE_BUILD : Result := 'SIC_ERROR_CODE_BUILD';
    SIC_ERROR_ARGUMENT   : Result := 'SIC_ERROR_ARGUMENT';
    SIC_ERROR_EVALUATE   : Result := 'SIC_ERROR_EVALUATE';
    SIC_ERROR_EXECUTE    : Result := 'SIC_ERROR_EXECUTE';
    SIC_ERROR_RANGE      : Result := 'SIC_ERROR_RANGE';
    SIC_ERROR_NO_IMPL    : Result := 'SIC_ERROR_NO_IMPL';
    SIC_ERROR_POINTER    : Result := 'SIC_ERROR_POINTER';
  end;
end;

{
}
procedure PerformanceInit (var AData: TPerformanceData; AEnter: Boolean);
var
  C : Int64;
begin
  AData.CType := 0;
  AData.Frequency := 1000;

  PerformanceReset (AData);

  if QueryPerformanceFrequency (AData.Frequency) then begin
    if QueryPerformanceCounter (C) then begin
      AData.CType := 1;
    end;
  end;

  if AEnter then PerformanceEnter (AData);
end;

{
}
procedure PerformanceReset (var AData: TPerformanceData);
begin
  AData.Count := 0;
  AData.EnterCount := 0;
  AData.LeaveCount := 0;
  AData.Seconds := 0;
  AData.mSeconds := 0;
  AData.mcSeconds := 0;
end;

{
}
procedure PerformanceEnter (var AData: TPerformanceData);
begin
  if AData.CType = 1 then begin
    QueryPerformanceCounter (AData.EnterCount);
  end else begin
    AData.EnterCount := GetTickCount;
  end;
end;

{
}
procedure PerformanceLeave (var AData: TPerformanceData);
begin
  if AData.CType = 1 then begin
    QueryPerformanceCounter (AData.LeaveCount);
  end else begin
    AData.LeaveCount := GetTickCount;
  end;

  AData.Count := AData.Count + AData.LeaveCount - AData.EnterCount;
end;

{
}
procedure PerformanceDone (var AData: TPerformanceData; ALeave: Boolean);
begin
  if ALeave then PerformanceLeave (AData);

  if AData.CType = 1 then begin
    AData.Seconds := AData.Count / AData.Frequency;
    AData.mSeconds := AData.Seconds * 1000;
    AData.mcSeconds := AData.Seconds * 1000000;
  end else begin
    AData.Seconds := AData.Count / AData.Frequency;
    AData.mSeconds := AData.Count;
    AData.mcSeconds := AData.Count * 1000;
  end;
end;

{
}
function IsClass (AObject: TObject; AClass: TClass): Boolean;
begin
  Result := false;
  if (AObject = nil) or (AClass = nil) then Exit;

  try
    Result := AObject is AClass;
  except
    // bypass exception
  end;
end;

{
  удал€ет из очереди сообщений предыдущие сообщениz <AMsg> и вызывает <PostMessage()>
}
function PostSingleMessage (AWnd: HWND; AMsg: UINT; AWParam: WPARAM; ALParam: LPARAM;
  AMsgPeekCount: Integer = 1024): Integer;
var
  VMsg : TMsg;
begin
  Result := 0;

  FillChar (VMsg, SizeOf(VMsg), 0);
  VMsg.hwnd := AWnd;
  VMsg.message := AMsg;

  if AMsgPeekCount <> 0 then begin
    if AMsgPeekCount > 0 then begin
      while (Result < AMsgPeekCount) and PeekMessage (VMsg, AWnd, AMsg, AMsg, PM_REMOVE) do Inc (Result);
    end else begin
      while PeekMessage (VMsg, AWnd, AMsg, AMsg, PM_REMOVE) do Inc (Result);
    end;
  end;
  PostMessage (AWnd, AMsg, AWParam, ALParam);
end;

{
}
function HandleAsWinControl (AParent: TObject; AHandle: THandle): TWinControl;
var
  VList : TList;

  function Find__(A_Control: TObject; A_Handle: THandle): TWinControl;
  var
    I : Integer;
    C : TWinControl;
  begin
    Result := nil;

    if IsClass (A_Control, TWinControl) then begin
      C := TWinControl(A_Control);
      if C.Handle = A_Handle then begin
        Result := C;
        Exit;
      end;

      VList.ADD (C);
      for I := 0 to C.ControlCount - 1 do begin
        Result := Find__(C.Controls[I], A_Handle);
        if Result <> nil then Exit;
      end;
    end;
  end;

  function Find_(A_Control: TObject; A_Handle: THandle): TWinControl;
  var
    I : Integer;
    C : TWinControl;
  begin
    Result := nil;

    if VList.Count > 0 then begin
      for I := 0 to VList.Count - 1 do begin
        C := TWinControl(VList[I]);
        if C.Handle = A_Handle then begin
          Result := C;
          Exit;
        end;
      end;
    end else begin
      Result := Find__(A_Control, A_Handle);
    end;
  end;

var
  C : TWinControl;
begin
  Result := nil;

  VList := TList.Create;
  try
    while IsWindow (AHandle) do begin
      C := Find_(AParent, AHandle);
      if C <> nil then begin
        Result := C;
        Exit;
      end;
      AHandle := GetParent (AHandle);
    end;
  finally
    VList.Free;
  end;
end;

{
}
function FindScrollBox (AParent: TObject; const AMousePos: TPoint): TScrollBox;
var
  H : THandle;
  C : TWinControl;
begin
  Result := nil;
  if not IsClass (AParent, TWinControl) then Exit;

  H := WindowFromPoint (AMousePos);
  C := HandleAsWinControl (AParent, H);
  Result := FindParentScrollBox (C);
end;

{
}
function FindParentScrollBox (AControl: TObject): TScrollBox;
var
  VParent : TWinControl;
begin
  Result := nil;
  if not IsClass (AControl, TControl) then Exit;

  VParent := TControl(AControl).Parent;
  while VParent <> nil do begin
    if IsClass (VParent, TScrollBox) then begin
      Result := TScrollBox(VParent);
      Exit;
    end;
    VParent := VParent.Parent;
  end;
end;

{
}
procedure VScrollExecute (AScrollBox: TScrollBox; AUP: Boolean;
  AIncrementFactor: Integer);
var
  VDelta : Integer;
  VPos   : Integer;
begin
  VDelta := AScrollBox.VertScrollBar.Increment * AIncrementFactor;
  if VDelta < 1 then VDelta := AScrollBox.VertScrollBar.Increment;
  if AUP then VDelta := -VDelta;
  VPos := AScrollBox.VertScrollBar.Position + VDelta;
  AScrollBox.VertScrollBar.Position := VPos;
end;

{
}
function Evaluate (const S: string; var AError: DWORD): Double;
var
  {$IFDEF UNICODE}
  Sa    : AnsiString;
  {$ENDIF}
  V_sic : TSIC_Data;
  V_cop : DWORD;
begin
  AError := 0;

  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    Result := 0;
    Exit;
  end;
  {$ENDIF}

  {$IFDEF SIC_OCX}
  SIC.CreateTables;
  try
    SIC.Init (@V_sic);
    try
      V_cop := SIC_OPT_FLAG_STACK_FRAME or SIC_OPT_FLAG_LOCALS;
      {$IFDEF UNICODE}
      Sa := AnsiString(S);
      Result := SIC.SBuExec (PAnsiChar(Sa), V_cop, AError);
      {$ELSE}
      Result := SIC.SBuExec (PAnsiChar(S), V_cop, AError);
      {$ENDIF}
    finally
      SIC.Done (@V_sic);
    end;
  finally
    SIC.FreeTables;
  end;
  {$ELSE}
  sic_cretab;
  try
    sic_init (@V_sic);
    try
      V_cop := SIC_OPT_FLAG_STACK_FRAME or SIC_OPT_FLAG_LOCALS;
      {$IFDEF UNICODE}
      Sa := AnsiString(S);
      Result := sic_sbexec (PAnsiChar(Sa), V_cop, AError);
      {$ELSE}
      Result := sic_sbexec (PAnsiChar(S), V_cop, AError);
      {$ENDIF}
    finally
      sic_done (@V_sic);
    end;
  finally
    sic_fretab;
  end;
  {$ENDIF}
end;

// FPU Exception Flags
//
// 7 - ES - Exception Flag
// 6 - SF - Stack Fault
// 5 - PE - Precision
// 4 - UE - Underflow
// 3 - OE - Overflow
// 2 - ZE - Zero Divide
// 1 - DE - Denormalized
// 0 - IE - Invalid Operation

{
}
procedure GetFPUExceptionFlags (const AError: DWORD;
  var A_OE, A_ZE, A_IE: Boolean);
begin
  A_IE := (AError and $01) <> 0;
  A_ZE := (AError and $04) <> 0;
  A_OE := (AError and $08) <> 0;
end;

{
}
procedure GetFPUExceptionFlags (const AError: DWORD;
  var A_ES, A_SF, A_PE, A_UE, A_OE, A_ZE, A_DE, A_IE: Boolean);
begin
  A_IE := (AError and $01) <> 0;
  A_DE := (AError and $02) <> 0;
  A_ZE := (AError and $04) <> 0;
  A_OE := (AError and $08) <> 0;
  A_UE := (AError and $10) <> 0;
  A_PE := (AError and $20) <> 0;
  A_SF := (AError and $40) <> 0;
  A_ES := (AError and $80) <> 0;
end;

{
}
function GetItemName (var AItem: TSIC_FunItem): string;
{$IFDEF UNICODE}
var
  S : AnsiString;
begin
  // S := StrPas (PAnsiChar(@AItem.name));
  S := PAnsiChar(@AItem.name);
  Result := string(S);
end;
{$ELSE}
begin
  Result := StrPas (PAnsiChar(@AItem.name));
end;
{$ENDIF}

{
}
function GetItemName (var AItem: TSIC_ConItem): string;
{$IFDEF UNICODE}
var
  S : AnsiString;
begin
  // S := StrPas (PAnsiChar(@AItem.name));
  S := PAnsiChar(@AItem.name);
  Result := string(S);
end;
{$ELSE}
begin
  Result := StrPas (PAnsiChar(@AItem.name));
end;
{$ENDIF}

{
}
function GetItemName (var AItem: TSIC_VarItem): string;
{$IFDEF UNICODE}
var
  S : AnsiString;
begin
  // S := StrPas (PAnsiChar(@AItem.name));
  S := PAnsiChar(@AItem.name);
  Result := string(S);
end;
{$ELSE}
begin
  Result := StrPas (PAnsiChar(@AItem.name));
end;
{$ENDIF}

{
}
function GetString_(PS: PAnsiChar): string;
begin
  try
    {$IFDEF UNICODE}
    Result := string (PS);
    {$ELSE}
    Result := string (StrPas (PS));
    {$ENDIF}
  except
    on E : Exception do Result := E.message;
  end;
end;

{
}
function TrimALL (const S: string): string;
var
  I, L : Integer;
begin
  L := Length (S);
  I := 1;
  while (I <= L) and ((S[I] <= ' ') or (S[I] = #160)) do Inc(I);
  if I > L then Result := '' else begin
    while (S[L] <= ' ') or (S[I] = #160) do Dec(L);
    Result := Copy (S, I, L - I + 1);
  end;
end;

{
}
function FunItem (var AItem: TSIC_FunItem; AIndex: Integer): string;
const
  CFlags : array [Boolean] of Char = ('0', '1');
var
  FF : Integer;
  SS : string;
  ST : string;
  ZT : string;
  AC : string;
  AF : string;
  RT : string;
  DF : string;
  CS : string;
  KF : string; // keyword flag
begin
  SS := GetItemName (AItem);

  {$IFDEF SIC_OCX}
  if AItem.name[SIC_FunNameSize-1] = $08 then KF := 'Х' else KF := '';
  {$ELSE}
  if AItem.name[SIC_FunNameSize-1] = #$08 then KF := 'Х' else KF := '';
  {$ENDIF}

  ST := #09#09#09;
  if Length (SS) >= 16 then ST := #09 else
  if Length (SS) >= 8 then ST := #09#09;

  if WORD(AItem.acount) = $8000 then begin
    AC := 'any';
  end else begin
    AC := IntToStr (AItem.acount);
  end;

  AF := '';
  RT := '';
  DF := '';

  if AItem.cosize < 0 then begin
    {$IFDEF CPUX64}
    if (AItem.cosize and $0F) <> 0 then begin
      SetLength (AF, 4);
      AF[1] := CFlags[(AItem.cosize and 8) <> 0]; // 1000
      AF[2] := CFlags[(AItem.cosize and 4) <> 0]; // 0100
      AF[3] := CFlags[(AItem.cosize and 2) <> 0]; // 0010
      AF[4] := CFlags[(AItem.cosize and 1) <> 0]; // 0001
    end;
    {$ELSE}
    if (AItem.cosize and $4000) <> 0 then begin
      AF := 'STD';
    end else
    if (AItem.cosize and $FF) <> 0 then begin
      AF := IntToStr (AItem.cosize and $FF);
    end;
    {$ENDIF}

    FF := ShortInt((AItem.cosize shr 8) and $0F);
    if FF <> 0 then begin
      // if FF = $0F then RT := 'n' else
      if FF = B_1111 then RT := 'void' else
      if FF = B_1001 then RT := 'D2' else
      if FF = B_1010 then RT := 'D3' else
      if FF = B_1100 then RT := 'D4' else
      if FF = B_1000 then RT := 'I8' else
      if FF = B_0100 then RT := 'I4' else
      if FF = B_0010 then RT := 'I2' else
      if FF = B_0001 then RT := 'I1' else ;
    end;
    // RT := RT + '[' + IntToStr (AItem.retype) + ']';

    if (AItem.cosize and $2000) <> 0 then begin
      DF := 'D';
    end;
  end else begin
    if AItem.retype = Int16(ORD('i')) then begin
      RT := '[i]';
    end else begin
      RT := '[' + IntToStr (AItem.retype) + ']';
    end;
  end;
  if AItem.acount >= 0 then AC := ' ' + AC;
  if AF <> '' then AC := AC + '(' + AF + ')';
  if RT <> '' then AC := AC + ':' + RT;
  if DF <> '' then AC := AC + ':' + DF;

  ZT := #09#09#09;
  if Length (AC) >= 8 then ZT := #09#09;

  if AItem.offset <> 0 then begin
    if AItem.cosize > 0 then begin
      CS := IntToStr (AItem.cosize);
    end else begin
      CS := '0';
    end;
  end else begin
    CS := '????????';
  end;

  Result := Format ('%.4d%s'#09'%s%s%s%s%s', [AIndex, KF, SS, ST, AC, ZT, CS]);
end;

{
}
function FunTable (Asic: Pointer): string;
var
  I  : Integer;
  IC : Integer;
  S  : string;
  VI : TSIC_FunItem;
begin
  // get item count
  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    IC := 0;
  end else begin
    IC := SIC.GetFunCount (Asic);
  end;
  {$ELSE}
  IC := sic_gefuc (Asic);
  {$ENDIF}

  S := 'COUNT = ' + IntToStr (IC) + #13#10;
  S := S + '------------------------------------------------------------------'#13#10;
  S := S + '#'#09'name'#09#09#09'arg count'#09#09'code size'#13#10;
  S := S + '------------------------------------------------------------------'#13#10;

  for I := 0 to IC - 1 do begin
    // get item
    {$IFDEF SIC_OCX}
    if SIC.GetFunItem (Asic, I, VI) >= 0 then begin
    {$ELSE}
    if sic_gefui (Asic, I, @VI) >= 0 then begin
    {$ENDIF}
      S := S + FunItem (VI, I) + #13#10;
    end;
  end;

  Result := S + '------------------------------------------------------------------'#13#10;
end;

{
}
function ConItem (var AItem: TSIC_ConItem; AIndex: Integer): string;
var
  C  : AnsiChar;
  S  : string;
  SS : string;
  ST : string;
  SI : string;
  SU : string;
  V  : Double;
  II : INT_PTR;
  PP : Int64 absolute V;
  PS : PAnsiChar absolute V;
  I  : Integer;
  SC : Integer;
  SL : TStringList;
  P1 : PAnsiChar;
  P2 : PAnsiChar;
  V1 : Double;
  V2 : Double;
begin
  SL := TStringList.Create;
  try

  SS := GetItemName (AItem);

  ST := #09#09#09;
  if Length (SS) >= 16 then ST := #09 else
  if Length (SS) >= 8 then ST := #09#09;

  S := Format ('%.4d'#09'%s%s', [AIndex, SS, ST]);
  V := AItem.value;
  C := AnsiChar (AItem.datype);

  if AItem.datype = $3166{'f1'} then begin
    P1 := Pointer(PP);
    if P1 <> nil then begin
      V1 := PDouble(P1)^;
      S := S + FloatToStr_(V1);
    end else begin
      S := S + 'null data';
    end;
  end else

  if AItem.datype = $3169{'i1'} then begin
    P1 := Pointer(PP);
    if P1 <> nil then begin
      II := PINT_PTR(P1)^;
      S := S + IntToStr (II) + ':I';
    end else begin
      S := S + 'null:I';
    end;
  end else

  if AItem.datype = $3266{'f2'} then begin
    P1 := Pointer(PP);
    if P1 <> nil then begin
      P2 := P1 + 8;
      V1 := PDouble(P1)^;
      V2 := PDouble(P2)^;
      S := S + '(' + FloatToStr_(V1) + ',' + FloatToStr_(V2) + ')';
    end else begin
      S := S + 'null data';
    end;
  end else

  if C = 'i' then begin
    II := PINT_PTR(@AItem.value)^;
    SI := Format ('%d', [II]);
    SU := Format ('%u', [II]);
    if SI = SU then begin
      S := S + SI + ':' + AsHex_(II) + ':I';
    end else begin
      S := S + SI + '(' + SU + ')' + ':' + AsHex_(II) + ':I';
    end;
  end else

  if C = 'p' then begin
    S := S + AsHex_(PP) + ':P';
  end else

  if C = 'o' then begin
    S := S + AsHex_(PP) + ':O';
  end else

  if C = 's' then begin
    SS := GetString_(PS);
    SL.Text := SS;

    SC := SL.Count;
    if SC > 0 then begin
      if SC = 1 then begin
        S := S + '"' + SS + '"';
      end else begin
        S := S + SL[0];
        for I := 1 to SL.Count - 1 do begin
          S := S + #13#10 + #9#9#9#9'' + SL[I];
        end;
      end;
    end;
    // S := S + '"' + SS + '"';
  end else

  if C = '?' then begin
    S := S + 'undefined';
  end else

  begin
    S := S + FloatToStr_(V);
  end;

  Result := S;

  finally
    SL.Free;
  end;
end;

{
}
function ConTable (Asic: Pointer): string;
var
  I  : Integer;
  IC : Integer;
  S  : string;
  VI : TSIC_ConItem;
begin
  // get item count
  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    IC := 0;
  end else begin
    IC := SIC.GetConCount (Asic);
  end;
  {$ELSE}
  IC := sic_gecoc (Asic);
  {$ENDIF}

  S := 'COUNT = ' + IntToStr (IC) + #13#10;
  S := S + '------------------------------------------------------------------'#13#10;
  S := S + '#'#09'name'#09#09#09'value'#13#10;
  S := S + '------------------------------------------------------------------'#13#10;

  for I := 0 to IC - 1 do begin
    // get item
    {$IFDEF SIC_OCX}
    if SIC.GetConItem (Asic, I, VI) >= 0 then begin
    {$ELSE}
    if sic_gecoi (Asic, I, @VI) >= 0 then begin
    {$ENDIF}
      S := S + ConItem (VI, I) + #13#10;
    end;
  end;

  Result := S + '------------------------------------------------------------------'#13#10;
end;

{
}
function VarItem (var AItem: TSIC_VarItem; AIndex: Integer): string;
var
  C  : AnsiChar;
  S  : string;
  SS : string;
  ST : string;
  SI : string;
  SU : string;
  V  : Double;
  II : INT_PTR;
  PP : Pointer;
  PS : PAnsiChar;
  I  : Integer;
  SC : Integer;
  SL : TStringList;
begin
  SL := TStringList.Create;
  try

  SS := GetItemName (AItem);

  ST := #09#09#09;
  if Length (SS) >= 16 then ST := #09 else
  if Length (SS) >= 8 then ST := #09#09;

  S := Format ('%.4d'#09'%s%s', [AIndex, SS, ST]);
  if AItem.offset <> 0 then begin
    try
      C := AnsiChar (AItem.datype);
      if C = 'i' then begin
        II := PINT_PTR(AItem.offset)^;
        SI := Format ('%d', [II]);
        SU := Format ('%u', [II]);
        if SI = SU then begin
          S := S + SI + ':' + AsHex_(II) + ':I';
        end else begin
          S := S + SI + '(' + SU + ')' + ':' + AsHex_(II) + ':I';
        end;
      end else
      if C = 'p' then begin
        PP := PPointer(AItem.offset)^;
        S := S + AsHex_(INT_PTR(PP)) + ':P';
      end else
      if C = 'o' then begin
        PP := PPointer(AItem.offset)^;
        S := S + AsHex_(INT_PTR(PP)) + ':O';
      end else
      if C = 's' then begin
        PS := PPAnsiChar(AItem.offset)^;
        SS := GetString_(PS);
        SL.Text := SS;

        SC := SL.Count;
        if SC > 0 then begin
          if SC = 1 then begin
            S := S + '"' + SS + '"';
          end else begin
            S := S + SL[0];
            for I := 1 to SL.Count - 1 do begin
              S := S + #13#10 + #9#9#9#9'' + SL[I];
            end;
          end;
        end;
        // S := S + '"' + SS + '"';
      end else begin
        V := PDouble(AItem.offset)^;
        S := S + FloatToStr_(V);
      end;
    except
      S := S + 'ERROR';
    end;
  end else begin
    S := S + '????????';
  end;

  Result := S;

  finally
    SL.Free;
  end;
end;

{
}
function VarTable (Asic: Pointer): string;
var
  I  : Integer;
  IC : Integer;
  S  : string;
  VI : TSIC_VarItem;
begin
  // get item count
  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    IC := 0;
  end else begin
    IC := SIC.GetVarCount (Asic);
  end;
  {$ELSE}
  IC := sic_gevac (Asic);
  {$ENDIF}

  S := 'COUNT = ' + IntToStr (IC) + #13#10;
  S := S + '------------------------------------------------------------------'#13#10;
  S := S + '#'#09'name'#09#09#09'value'#13#10;
  S := S + '------------------------------------------------------------------'#13#10;

  for I := 0 to IC - 1 do begin
    // get item
    {$IFDEF SIC_OCX}
    if SIC.GetVarItem (Asic, I, VI) >= 0 then begin
    {$ELSE}
    if sic_gevai (Asic, I, @VI) >= 0 then begin
    {$ENDIF}
      S := S + VarItem (VI, I) + #13#10;
    end;
  end;

  Result := S + '------------------------------------------------------------------'#13#10;
end;

{
}
function RunTable (Asic: Pointer): string;
var
  I  : Integer;
  IC : Integer;
  S  : string;
  VI : TSIC_ConItem;
begin
  // get item count
  {$IFDEF SIC_OCX}
  if SIC = nil then begin
    IC := 0;
  end else begin
    IC := SIC.GetRunCount (Asic);
  end;
  {$ELSE}
  IC := sic_geruc (Asic);
  {$ENDIF}

  S := 'COUNT = ' + IntToStr (IC) + #13#10;
  S := S + '------------------------------------------------------------------'#13#10;
  S := S + '#'#09'name'#09#09#09'value'#13#10;
  S := S + '------------------------------------------------------------------'#13#10;

  for I := 0 to IC - 1 do begin
    // get item
    {$IFDEF SIC_OCX}
    if SIC.GetRunItem (Asic, I, VI) >= 0 then begin
    {$ELSE}
    if sic_gerui (Asic, I, @VI) >= 0 then begin
    {$ENDIF}
      S := S + ConItem (VI, I) + #13#10;
    end;
  end;

  Result := S + '------------------------------------------------------------------'#13#10;
end;

{
}
function AsHex_(V: INT_PTR): string;
const
  CHex08Format = '0x%.8X';
  CHex16Format = '0x%.16X';
begin
  {$IFDEF CPUX64}
  if (V and $FFFFFFFF00000000) <> 0 then begin
    Result := Format (CHex16Format, [V]);
  end else begin
    Result := Format (CHex08Format, [V]);
  end;
  {$ELSE}
  Result := Format (CHex08Format, [V]);
  {$ENDIF}
end;

{
  -> single-line string
  <- multi-line string
}
function ExpandSicString (const S: string): string;
var
  I : Integer;
begin
  Result := S;
  for I := 1 to Length (S) do begin
    if Result[I] = 'ґ' then Result[I] := #13;
  end;
end;

{
  -> multi-line string
  <- single-line string
}
function CollapseSicString (const S: string): string;
var
  I : Integer;
  L : TStringList;
begin
  Result := '';

  L := TStringList.Create;
  try
    L.Text := S;
    if L.Count > 0 then begin
      Result := L[0];
      for I := 1 to L.Count - 1 do begin
        // Result := Result + ';' + L[I];
        Result := Result + ' ґ' + L[I];
      end;
    end;
  finally
    L.Free;
  end;
end;

{
}
function Round_D (AValue: Double): Double;
var
  F : Double;
begin
  F := Frac (AValue);
  if F = 0 then begin
    Result := AValue;
    Exit;
  end;
  Result := Int (AValue) + Int (F * 2);
end;

{
}
function IRound_D (AValue: Double): INT_PTR;
var
  F : Double;
begin
  F := Frac (AValue);
  if F = 0 then begin
    Result := Trunc (AValue);
    Exit;
  end;
  Result := Trunc (AValue) + Trunc (F * 2);
end;

{
  AEnvString = %...%
}
function GetEnvironmentPath (const AEnvString: string): string;
var
  S, E : string;
  Z, L : Integer;
begin
  Result := '.\';

  Z := ExpandEnvironmentStrings (PChar(AEnvString), nil, 0);
  if Z <= 0 then Exit;

  SetLength (S, Z + 2);
  ExpandEnvironmentStrings (PChar(AEnvString), PChar(S), Z + 2);
  E := PChar(S);

  L := Length(E);
  if L <= 0 then Exit;

  {$IFDEF VER120} // Delphi 4.0
  if (E[L] <> '\') and (E[L] <> '/') then E := E + '\';
  Result := E;
  {$ELSE}
  Result := SysUtils.IncludeTrailingPathDelimiter (E);
  {$ENDIF}
end;

{
  Add internal SIC functions
}
function sic_afuns (ASic: Pointer): Integer;
const
  C_STDCALL_FF = $00FF;       // STDCALL function flag
  C_Dynamic_FF = ($20 shl 8); // Dynamic function flag
  C_VOID_RF    = ($0F shl 8); // VOID result flag
  C_Int64_RF   = ($08 shl 8); // Int64 result flag
  C_Int32_RF   = ($04 shl 8); // Int32 result flag
  C_Int16_RF   = ($02 shl 8); // Int16 result flag
begin
  Result := 0;

  {$IFDEF SIC_STATIC}
  {$IFDEF CPUX64}

  (*
  [==] ; SIC64.DLL
  cpuseed=cpuseed:::8:D                                   ; dynamic function
  cpuseed64=cpuseed64:::8:D                               ; dynamic function
  cpuseed32=cpuseed32:::4:D                               ; dynamic function
  cpuseed16=cpuseed16:::2:D                               ; dynamic function
  cpurand=cpurand:::8:D                                   ; dynamic function
  cpurand64=cpurand64:::8:D                               ; dynamic function
  cpurand32=cpurand32:::4:D                               ; dynamic function
  cpurand16=cpurand16:::2:D                               ; dynamic function
  cpurandf=cpurandf::::D                                  ; dynamic function
  cpurandf2pi=cpurandf2pi::::D                            ; dynamic function
  mt19937_seed=mt19937_seed:1:0001:-1:D                   ; dynamic function
  mt19937_igen=mt19937_igen:::8:D                         ; dynamic function
  mt19937_fgen=mt19937_fgen::::D                          ; dynamic function
  mt19937_fgen2pi=mt19937_fgen2pi::::D                    ; dynamic function
  sic_erf=sic_erf:1
  sic_erfc=sic_erfc:1
  sic_cdfnorm=sic_cdfnorm:1
  sic_erfinv=sic_erfinv:1
  sic_erfcinv=sic_erfcinv:1
  sic_cdfnorminv=sic_cdfnorminv:1
  sic_lgamma=sic_lgamma:1
  sic_lgammas=sic_lgammas:2:0010
  sic_tgamma=sic_tgamma:1
  sic_rgamma=sic_rgamma:1
  sic_rtgamma=sic_rtgamma:1
  sic_beta=sic_beta:2
  // *)
  sic_afun (ASic, 'cpuseed', @cpuseed, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed64', @cpuseed64, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed32', @cpuseed32, 0, ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed16', @cpuseed16, 0, ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand', @cpurand, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand64', @cpurand64, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand32', @cpurand32, 0, ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand16', @cpurand16, 0, ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurandf', @cpurandf, 0, ($20 shl 8));
  sic_afun (ASic, 'cpurandf2pi', @cpurandf2pi, 0, ($20 shl 8));
  sic_afun (ASic, 'mt19937_seed', @mt19937_seed, 1, B_0001 or ($0F shl 8) or ($20 shl 8));
  sic_afun (ASic, 'mt19937_igen', @mt19937_igen, 0, ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen', @mt19937_fgen, 0, ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen2pi', @mt19937_fgen2pi, 0, ($20 shl 8));
  sic_afun (ASic, 'sic_erf', @sic_erf, 1, 0);
  sic_afun (ASic, 'sic_erfc', @sic_erfc, 1, 0);
  sic_afun (ASic, 'sic_cdfnorm', @sic_cdfnorm, 1, 0);
  sic_afun (ASic, 'sic_erfinv', @sic_erfinv, 1, 0);
  sic_afun (ASic, 'sic_erfcinv', @sic_erfcinv, 1, 0);
  sic_afun (ASic, 'sic_cdfnorminv', @sic_cdfnorminv, 1, 0);
  sic_afun (ASic, 'sic_lgamma', @sic_lgamma, 1, 0);
  sic_afun (ASic, 'sic_lgammas', @sic_lgammas, 2, B_0010);
  sic_afun (ASic, 'sic_tgamma', @sic_tgamma, 1, 0);
  sic_afun (ASic, 'sic_rgamma', @sic_rgamma, 1, 0);
  sic_afun (ASic, 'sic_rtgamma', @sic_rtgamma, 1, 0);
  sic_afun (ASic, 'sic_beta', @sic_beta, 2, 0);

  {$ELSE}

  (*
  [==] ; SIC32.DLL
  cpuseed=cpuseed::-1:4:D                                 ; dynamic function
  cpuseed64=cpuseed64::-1:8:D                             ; dynamic function
  cpuseed32=cpuseed32::-1:4:D                             ; dynamic function
  cpuseed16=cpuseed16::-1:2:D                             ; dynamic function
  cpurand=cpurand::-1:4:D                                 ; dynamic function
  cpurand64=cpurand64::-1:8:D                             ; dynamic function
  cpurand32=cpurand32::-1:4:D                             ; dynamic function
  cpurand16=cpurand16::-1:2:D                             ; dynamic function
  cpurandf=cpurandf::-1::D                                ; dynamic function
  cpurandf2pi=cpurandf2pi::-1::D                          ; dynamic function
  mt19937_seed=mt19937_seed:1:-1:-1:D                     ; dynamic function
  mt19937_igen=mt19937_igen::-1:4:D                       ; dynamic function
  mt19937_fgen=mt19937_fgen::-1::D                        ; dynamic function
  mt19937_fgen2pi=mt19937_fgen2pi::-1::D                  ; dynamic function
  sic_erf=sic_erf:1:-1
  sic_erfc=sic_erfc:1:-1
  sic_cdfnorm=sic_cdfnorm:1:-1
  sic_erfinv=sic_erfinv:1:-1
  sic_erfcinv=sic_erfcinv:1:-1
  sic_cdfnorminv=sic_cdfnorminv:1:-1
  sic_lgamma=sic_lgamma:1:-1
  sic_lgammas=sic_lgammas:2:-1
  sic_tgamma=sic_tgamma:1:-1
  sic_rgamma=sic_rgamma:1:-1
  sic_rtgamma=sic_rtgamma:1:-1
  sic_beta=sic_beta:2:-1
  // *)
  sic_afun (ASic, 'cpuseed', @cpuseed, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed64', @cpuseed64, 0, $00FF or ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed32', @cpuseed32, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpuseed16', @cpuseed16, 0, $00FF or ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand', @cpurand, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand64', @cpurand64, 0, $00FF or ($08 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand32', @cpurand32, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurand16', @cpurand16, 0, $00FF or ($02 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'cpurandf', @cpurandf, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'cpurandf2pi', @cpurandf2pi, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'mt19937_seed', @mt19937_seed, 1, $00FF or ($20 shl 8));
  sic_afun (ASic, 'mt19937_igen', @mt19937_igen, 0, $00FF or ($04 shl 8) or ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen', @mt19937_fgen, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'mt19937_fgen2pi', @mt19937_fgen2pi, 0, $00FF or ($20 shl 8));
  sic_afun (ASic, 'sic_erf', @sic_erf, 1, $00FF);
  sic_afun (ASic, 'sic_erfc', @sic_erfc, 1, $00FF);
  sic_afun (ASic, 'sic_cdfnorm', @sic_cdfnorm, 1, $00FF);
  sic_afun (ASic, 'sic_erfinv', @sic_erfinv, 1, $00FF);
  sic_afun (ASic, 'sic_erfcinv', @sic_erfcinv, 1, $00FF);
  sic_afun (ASic, 'sic_cdfnorminv', @sic_cdfnorminv, 1, $00FF);
  sic_afun (ASic, 'sic_lgamma', @sic_lgamma, 1, $00FF);
  sic_afun (ASic, 'sic_lgammas', @sic_lgammas, 2, $00FF);
  sic_afun (ASic, 'sic_tgamma', @sic_tgamma, 1, $00FF);
  sic_afun (ASic, 'sic_rgamma', @sic_rgamma, 1, $00FF);
  sic_afun (ASic, 'sic_rtgamma', @sic_rtgamma, 1, $00FF);
  sic_afun (ASic, 'sic_beta', @sic_beta, 2, $00FF);

  {$ENDIF}
  {$ENDIF}
end;

end.

