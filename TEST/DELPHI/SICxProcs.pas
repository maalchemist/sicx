unit SICxProcs;

// SICx.DLL procs
// Static

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

{$I version.inc}

{$UNDEF __msvcrt}         // -
{$UNDEF __imp_procs}      // -
{$IFNDEF FPC}
{$IFDEF SIC_STATIC}
  {$DEFINE __msvcrt}      // +
  {$IFDEF CPUX64}
    {$DEFINE __imp_procs} // +
  {$ENDIF}
{$ENDIF}
{$ENDIF}

    
interface

uses
  Windows,
  {$IFDEF __msvcrt} msvcrt, {$ENDIF}
  SICxDefs, SICxTypes;

{$IFDEF FPC}
{$IFDEF CPUX64}
  {$LINKLIB libmsvcrt.x64.a}
  {$LINKLIB libkernel32.x64.a}
  {.$LINKLIB libuser32.x64.a}
{$ELSE}
  {$LINKLIB libmsvcrt.x32.a}
  {$LINKLIB libkernel32.x32.a}
  {.$LINKLIB libuser32.x32.a}
{$ENDIF}
{$ENDIF}

{$IFDEF SIC_STATIC}
{$IFDEF SIC_SSE}
  {$IFDEF CPUX64}
    {$L SICs64COFFD.OBJ}
  {$ELSE}
    {$IFDEF FPC}
      {$L SICs32COFFD.OBJ}
    {$ELSE}
      {$L SICs32D.OBJ}
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$IFDEF CPUX64}
    {$L SICx64COFFD.OBJ}
  {$ELSE}
    {$IFDEF FPC}
      {$L SICx32COFFD.OBJ}
    {$ELSE}
      {$L SICx32D.OBJ}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
{$ENDIF}

{$EXTERNALSYM sic_version}
function sic_version: DWORD; stdcall;
//
// Compiler version
// F0V2V1V0
// V0 - version L0
// V1 - version L1
// V2 - version L2
// F0 - flags
//      0 : SICx*
//      1 : SICs*
//

{$EXTERNALSYM sic_cpu_support}
function sic_cpu_support: BOOL; stdcall;
//
// Compiler support for the CPU
//
// <- Result : 1 - CPU supported
//             0 - CPU not supported
//

{$EXTERNALSYM sic_setup}
procedure sic_setup (AConfig: PSIC_Config); stdcall;
//
// Setup compiler
//
// <-> AConfig : T_sic_config structure offset
//
// --> AConfig.cflags : compiler configuration flags
//                      SIC_CFG_FLAG_CASE_SENSITIVE
//                      SIC_CFG_FLAG_NO_UDF
//                      SIC_CFG_FLAG_NO_UDC
//                      SIC_CFG_FLAG_NO_UDV
// --> AConfig.memory : memory block size in bytes
//                      default = 64K
//                      maximum = 0x00100000 (1024K)
//                      code space = 4 * memory block size
//
// AConfig.cflags = 0
// AConfig.memory = 0
//   case insensitive compiler
//   memory block size = 64K (default)
//
// AConfig.cflags = 0
// AConfig.memory = 0x00100000
//   case insensitive compiler
//   memory block size = 1024K
//
// AConfig.cflags = SIC_CFG_FLAG_CASE_SENSITIVE
// AConfig.memory = 0
//   case sensitive compiler
//   memory block size = 64K (default)
//

{$EXTERNALSYM sic_cretab}
procedure sic_cretab; stdcall;
//
// Create global tables
//

{$EXTERNALSYM sic_fretab}
procedure sic_fretab; stdcall;
//
// Destroy global tables
//

{$EXTERNALSYM sic_funtac}
function sic_funtac: DWORD; stdcall;
//
// Create global function table
// Assign table header and add built-in functions
//
// <- Result : function table item count or zero on error
//

{$EXTERNALSYM sic_funtaf}
procedure sic_funtaf; stdcall;
//
// Destroy global function table
//

{$EXTERNALSYM sic_funloa}
function sic_funloa: DWORD; stdcall;
//
// Load external user defined functions
//
// <- Result : external function item count
//

{$EXTERNALSYM sic_funulo}
procedure sic_funulo; stdcall;
//
// Unload external user defined functions
//

{$EXTERNALSYM sic_contac}
function sic_contac: DWORD; stdcall;
//
// Create global constant table
// Assign table header and add predefined constants
//
// <- Result : constant table item count or zero on error
//

{$EXTERNALSYM sic_contaf}
procedure sic_contaf; stdcall;
//
// Destroy global constant table
//

{$EXTERNALSYM sic_conloa}
function sic_conloa: DWORD; stdcall;
//
// Load external user defined constants
//
// <- Result : external constant item count
//

{$EXTERNALSYM sic_conulo}
procedure sic_conulo; stdcall;
//
// Unload external user defined constants
//

{$EXTERNALSYM sic_vartac}
function sic_vartac: DWORD; stdcall;
//
// Create global variable table
// Assign table header and add predefined variables
//
// <- Result : variable table item count or zero on error
//

{$EXTERNALSYM sic_vartaf}
procedure sic_vartaf; stdcall;
//
// Destroy global variable table
//

{$EXTERNALSYM sic_varloa}
function sic_varloa: DWORD; stdcall;
//
// Load external user defined variables
//
// <- Result : external variable item count
//

{$EXTERNALSYM sic_varulo}
procedure sic_varulo; stdcall;
//
// Unload external user defined variables
//

{$EXTERNALSYM sic_runtac}
function sic_runtac: DWORD; stdcall;
//
// Create global runtime table
//
// <- Result : runtime table item count
//

{$EXTERNALSYM sic_runtaf}
procedure sic_runtaf; stdcall;
//
// Destroy global runtime table
//

{$EXTERNALSYM sic_init}
procedure sic_init (ASic: PSIC_Data); stdcall;
//
// Allocate memory for ASic data segments
// Assign table headers
//
// -> ASic : TSIC_Data structure offset
//

{$EXTERNALSYM sic_done}
procedure sic_done (ASic: PSIC_Data); stdcall;
//
// Free memory previously allocated for ASic data and code segments
//
// -> ASic : TSIC_Data structure offset
//

{$EXTERNALSYM sic_afun}
function sic_afun (ASic: PSIC_Data; AFuname: PAnsiChar; AOffset: Pointer; AACount: Int16; AFlags: UInt16): Integer; stdcall;
//
// Add|set user defined global or local function ( AFuname ) and assign data ( AOffset, AACount, AFlags )
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// -> AOffset : function offset
// -> AACount : function argument count
//              AACount < 0 - variable number of arguments
//                            ABS(AACount) = minimum argument count
//              AACount = 0x8000 - any variable number of arguments
// -> AFlags  : function flags
//              LO.BYTE = AFlags AND 0x00FF
//              HI.BYTE = AFlags SHR 8
//              x32 : LO.BYTE
//                    cdecl   : count of 4-byte arguments
//                    stdcall : 0xFF
//              x64 : LO.BYTE
//                    4-bit mask for integer and pointer arguments
//                    ex.: 0010 - second argument is integer or pointer
//                         0101 - first and third arguments are integer or pointer
//              x** : HI.BYTE AND (00001111B) - function return type
//                    0x01 (00000001B) - 1-byte integer
//                    0x02 (00000010B) - 2-byte integer
//                    0x04 (00000100B) - 4-byte integer
//                    0x08 (00001000B) - 8-byte integer
//                    0x09 (00001001B) - 2 double values (*)
//                    0x0A (00001010B) - 3 double values (*)
//                    0x0C (00001100B) - 4 double values (*)
//                    0x0F (00001111B) - void, no result
//                    double otherwise
//              x** : HI.BYTE AND (00100000B) - dynamic function flag
//                    dynamic functions are not calculated at compile time
// (*) multiple-result functions must return double values
//     on the FPU register stack (SICx*) or in SSE registers (SICs*)
//     both on x32 and x64 systems
// <- Result  : function index or negative value on error
//

{$EXTERNALSYM sic_refun}
function sic_refun (ASic: PSIC_Data; AFuname, AOrgname: PAnsiChar; AInvalidate: BOOL): Integer; stdcall;
//
// Rename global or local function
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic        : TSIC_Data structure offset
// -> AFuname     : function new name
// -> AOrgname    : function original name
// -> AInvalidate : invalidate original function if TRUE
// <- Result      : function index or negative value on error
//

{$EXTERNALSYM sic_dufun}
function sic_dufun (ASic: PSIC_Data; AFuname, AOrgname: PAnsiChar): Integer; stdcall;
//
// Duplicate global or local function
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic     : TSIC_Data structure offset
// -> AFuname  : function dup name
// -> AOrgname : function original name
// <- Result   : function index or negative value on error
//

{$EXTERNALSYM sic_exfun}
function sic_exfun (ASic: PSIC_Data; AFuname, AFunami: PAnsiChar): Integer; stdcall;
//
// Exchange global or local functions
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// -> AFunami : function name
// <- Result  : function index or negative value on error
//

{$EXTERNALSYM sic_aconf}
function sic_aconf (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Double): Integer; stdcall;
//
// Add|set user defined global or local float constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_aconi}
function sic_aconi (ASic: PSIC_Data; AConame: PAnsiChar; AValue: INT_PTR): Integer; stdcall;
//
// Add|set user defined global or local integer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_acons}
function sic_acons (ASic: PSIC_Data; AConame: PAnsiChar; AValue: PAnsiChar): Integer; stdcall;
//
// Add|set user defined global or local string constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_acono}
function sic_acono (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
//
// Add|set user defined global or local offset constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_aconp}
function sic_aconp (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
//
// Add|set user defined global or local pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_aconpf}
function sic_aconpf (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
//
// Add|set user defined global or local float pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_aconpi}
function sic_aconpi (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
//
// Add|set user defined global or local integer pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_aconps}
function sic_aconps (ASic: PSIC_Data; AConame: PAnsiChar; AValue: Pointer): Integer; stdcall;
//
// Add|set user defined global or local string pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_recon}
function sic_recon (ASic: PSIC_Data; AConame, AOrgname: PAnsiChar; AInvalidate: BOOL): Integer; stdcall;
//
// Rename global or local constant
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic        : TSIC_Data structure offset
// -> AConame     : constant new name
// -> AOrgname    : constant original name
// -> AInvalidate : invalidate original constant if TRUE
// <- Result      : constant index or negative value on error
//

{$EXTERNALSYM sic_ducon}
function sic_ducon (ASic: PSIC_Data; AConame, AOrgname: PAnsiChar): Integer; stdcall;
//
// Duplicate global or local constant
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic     : TSIC_Data structure offset
// -> AConame  : constant dup name
// -> AOrgname : constant original name
// <- Result   : constant index or negative value on error
//

{$EXTERNALSYM sic_excon}
function sic_excon (ASic: PSIC_Data; AConame, AConami: PAnsiChar): Integer; stdcall;
//
// Exchange global or local constants
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AConami : constant name
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_avarf}
function sic_avarf (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local float variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avari}
function sic_avari (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local integer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avars}
function sic_avars (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local string variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avaro}
function sic_avaro (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local offset variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avarp}
function sic_avarp (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avarpf}
function sic_avarpf (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local float pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avarpi}
function sic_avarpi (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local integer pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_avarps}
function sic_avarps (ASic: PSIC_Data; AVaname: PAnsiChar; AOffset: Pointer): Integer; stdcall;
//
// Add|set user defined global or local string pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_revar}
function sic_revar (ASic: PSIC_Data; AVaname, AOrgname: PAnsiChar; AInvalidate: BOOL): Integer; stdcall;
//
// Rename global or local variable
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic        : TSIC_Data structure offset
// -> AVaname     : variable new name
// -> AOrgname    : variable original name
// -> AInvalidate : invalidate original variable if TRUE
// <- Result      : variable index or negative value on error
//

{$EXTERNALSYM sic_duvar}
function sic_duvar (ASic: PSIC_Data; AVaname, AOrgname: PAnsiChar): Integer; stdcall;
//
// Duplicate global or local variable
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic     : TSIC_Data structure offset
// -> AVaname  : variable dup name
// -> AOrgname : variable original name
// <- Result   : variable index or negative value on error
//

{$EXTERNALSYM sic_exvar}
function sic_exvar (ASic: PSIC_Data; AVaname, AVanami: PAnsiChar): Integer; stdcall;
//
// Exchange global or local variables
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AVanami : variable name
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_invaf}
function sic_invaf (ASic: PSIC_Data; AFuname: PAnsiChar): Integer; stdcall;
//
// Invalidate global or local function ( AFuname )
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// <- Result  : function index or negative value on error
//

{$EXTERNALSYM sic_invac}
function sic_invac (ASic: PSIC_Data; AConame: PAnsiChar): Integer; stdcall;
//
// Invalidate global or local constant ( AConame )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_invav}
function sic_invav (ASic: PSIC_Data; AVaname: PAnsiChar): Integer; stdcall;
//
// Invalidate global or local variable ( AVaname )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_patab}
procedure sic_patab (ASic: PSIC_Data); stdcall;
//
// Pack global or local tables ( remove deleted items, decrease and fix table size )
// Deal with global tables if ASic = null or ASic.?data = null
// !!! You can`t add any item to the packed table
//
// -> ASic : TSIC_Data structure offset
//

{$EXTERNALSYM sic_pafut}
function sic_pafut (ASic: PSIC_Data): DWORD; stdcall;
//
// Pack global or local function table ( remove deleted items, decrease and fix table size )
// Deal with global table if ASic = null or ASic.fdata = null
// !!! You can`t add any item to the packed table
//
// -> ASic   : TSIC_Data structure offset
// <- Result : table item count or zero on error
//

{$EXTERNALSYM sic_pacot}
function sic_pacot (ASic: PSIC_Data): DWORD; stdcall;
//
// Pack global or local constant table ( remove deleted items, decrease and fix table size )
// Deal with global table if ASic = null or ASic.cdata = null
// !!! You can`t add any item to the packed table
//
// -> ASic   : TSIC_Data structure offset
// <- Result : table item count or zero on error
//

{$EXTERNALSYM sic_pavat}
function sic_pavat (ASic: PSIC_Data): DWORD; stdcall;
//
// Pack global or local variable table ( remove deleted items, decrease and fix table size )
// Deal with global table if ASic = null or ASic.vdata = null
// !!! You can`t add any item to the packed table
//
// -> ASic   : TSIC_Data structure offset
// <- Result : table item count or zero on error
//

{$EXTERNALSYM sic_gefut}
function sic_gefut (ASic: PSIC_Data): Pointer; stdcall;
//
// Get global or local function table offset
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : function table offset
//

{$EXTERNALSYM sic_gefuc}
function sic_gefuc (ASic: PSIC_Data): DWORD; stdcall;
//
// Get global or local function item count
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : function item count
//

{$EXTERNALSYM sic_gefui}
function sic_gefui (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_FunItem): Integer; stdcall;
//
// Get global or local function item
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : function index
// <- AItem  : function item
// <- Result : function index or negative value on error
//

{$EXTERNALSYM sic_gefun}
function sic_gefun (ASic: PSIC_Data; AFuname: PAnsiChar): Integer; stdcall;
//
// Get global or local item ( AFuname ) index in function table
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// <- Result  : function index or negative value on error
//

{$EXTERNALSYM sic_gecot}
function sic_gecot (ASic: PSIC_Data): Pointer; stdcall;
//
// Get global or local constant table offset
// Deal with global table if ASic = null or ASic.cdata = nil
//
// -> ASic   : TSIC_Data structure offset
// <- Result : constant table offset
//

{$EXTERNALSYM sic_gecoc}
function sic_gecoc (ASic: PSIC_Data): DWORD; stdcall;
//
// Get global or local constant item count
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : constant item count
//

{$EXTERNALSYM sic_gecoi}
function sic_gecoi (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_ConItem): Integer; stdcall;
//
// Get global or local constant item
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : constant index
// <- AItem  : constant item
// <- Result : constant index or negative value on error
//

{$EXTERNALSYM sic_gecon}
function sic_gecon (ASic: PSIC_Data; AConame: PAnsiChar): Integer; stdcall;
//
// Get global or local item ( AConame ) index in constant table
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// <- Result  : constant index or negative value on error
//

{$EXTERNALSYM sic_gevat}
function sic_gevat (ASic: PSIC_Data): Pointer; stdcall;
//
// Get global or local variable table offset
// Deal with global table if ASic = null or ASic.vdata = nil
//
// -> ASic   : TSIC_Data structure offset
// <- Result : variable table offset
//

{$EXTERNALSYM sic_gevac}
function sic_gevac (ASic: PSIC_Data): DWORD; stdcall;
//
// Get global or local variable item count
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : variable item count
//

{$EXTERNALSYM sic_gevai}
function sic_gevai (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_VarItem): Integer; stdcall;
//
// Get global or local variable item
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : variable index
// <- AItem  : variable item
// <- Result : variable index or negative value on error
//

{$EXTERNALSYM sic_gevar}
function sic_gevar (ASic: PSIC_Data; AVaname: PAnsiChar): Integer; stdcall;
//
// Get global or local item ( AVaname ) index in variable table
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// <- Result  : variable index or negative value on error
//

{$EXTERNALSYM sic_gerut}
function sic_gerut (ASic: PSIC_Data): Pointer; stdcall;
//
// Get global or local runtime table offset
// Deal with global table if ASic = null or ASic.rdata = nil
//
// -> ASic   : TSIC_Data structure offset
// <- Result : runtime table offset
//

{$EXTERNALSYM sic_geruc}
function sic_geruc (ASic: PSIC_Data): DWORD; stdcall;
//
// Get global or local runtime item count
// Deal with global table if ASic = null or ASic.rdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : runtime item count
//

{$EXTERNALSYM sic_gerui}
function sic_gerui (ASic: PSIC_Data; AIndex: Integer; AItem: PSIC_ConItem): Integer; stdcall;
//
// Get global or local runtime item
// Deal with global table if ASic = null or ASic.rdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : runtime index
// <- AItem  : runtime item
// <- Result : runtime index or negative value on error
//

{$EXTERNALSYM sic_gerun}
function sic_gerun (ASic: PSIC_Data; ARuname: PAnsiChar): Integer; stdcall;
//
// Get global or local item ( ARuname ) index in runtime table
// Deal with global table if ASic = null or ASic.rdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> ARuname : runtime name
// <- Result  : runtime index or negative value on error
//

{$EXTERNALSYM sic_compile}
function sic_compile (ASic: PSIC_Data; S: PAnsiChar; ASop: DWORD): DWORD; stdcall;
//
// Allocate memory for ASic code segment and compile string ( S )
//
// -> ASic : TSIC_Data structure offset
// -> S    : string to compile
// -> ASop : sic compiler options
//
// <- Result      : generated code size or zero on error
// <- ASic.coops  : actual compiler options
// <- ASic.tokens : scanned tokens count
// <- ASic.ccurs  : current string cursor
// <- ASic.pcurs  : previous string cursor
//

{$EXTERNALSYM sic_build}
function sic_build (ASic: PSIC_Data; S: PAnsiChar; ASop: DWORD): DWORD; stdcall;
//
// Allocate memory for ASic code segment and compile string ( S )
// <S> can be multi-line expression with ';' as delimiter
//
// -> ASic : TSIC_Data structure offset
// -> S    : string to compile
// -> ASop : sic compiler options
//
// <- Result      : generated code size or zero on error
// <- ASic.coops  : actual compiler options
// <- ASic.tokens : scanned tokens count
// <- ASic.ccurs  : current string cursor
// <- ASic.pcurs  : previous string cursor
//

{$EXTERNALSYM sic_exec}
function sic_exec (ASic: PSIC_Data; var AError: DWORD): Double; stdcall;
//
// Execute code
//
// -> ASic   : TSIC_Data structure offset
//
// <- Result : result or zero on error
// <- AError : error code or zero on success
//             AError = 0x00010000 -> null TSIC_Data structure offset
//             AError = 0x00020000 -> null code segment offset
//             AError = 0x00040000 -> invalid code size
//
//             if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
//             AError and 0x00000008 = OE flag
//             AError and 0x00000004 = ZE flag
//             AError and 0x00000001 = IE flag
//

{$EXTERNALSYM sic_call}
procedure sic_call (ASic: PSIC_Data); stdcall;
//
// Execute code
//
// -> ASic       : TSIC_Data structure offset
// <- ASic.value : result
//

{$EXTERNALSYM sic_cexec}
function sic_cexec (ASic: PSIC_Data; S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
//
// Compile & execute string
//
// -> ASic   : TSIC_Data structure offset
// -> S      : string to compile
// -> ASop   : sic compiler options offset
//
// <- Result : result or zero on error
// <- ASop   : actual compiler options
// <- AError : error code or zero on success
//             AError = 0x00000100 -> compiler error
//
//             if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
//             AError and 0x00000008 = OE flag
//             AError and 0x00000004 = ZE flag
//             AError and 0x00000001 = IE flag
//

{$EXTERNALSYM sic_bexec}
function sic_bexec (ASic: PSIC_Data; S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
//
// Compile & execute string
// <S> can be multi-line expression with ';' as delimiter
//
// -> ASic   : TSIC_Data structure offset
// -> S      : string to compile
// -> ASop   : sic compiler options offset
//
// <- Result : result or zero on error
// <- ASop   : actual compiler options
// <- AError : error code or zero on success
//             AError = 0x00000100 -> compiler error
//
//             if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
//             AError and 0x00000008 = OE flag
//             AError and 0x00000004 = ZE flag
//             AError and 0x00000001 = IE flag
//

{$EXTERNALSYM sic_scexec}
function sic_scexec (S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
//
// Compile & execute string
//
// -> S      : string to compile
// -> ASop   : sic compiler options offset
//
// <- Result : result or zero on error
// <- ASop   : actual compiler options
// <- AError : error code or zero on success
//             AError = 0x00000100 -> compiler error
//
//             if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
//             AError and 0x00000008 = OE flag
//             AError and 0x00000004 = ZE flag
//             AError and 0x00000001 = IE flag
//

{$EXTERNALSYM sic_sbexec}
function sic_sbexec (S: PAnsiChar; var ASop: DWORD; var AError: DWORD): Double; stdcall;
//
// Compile & execute string
// <S> can be multi-line expression with ';' as delimiter
//
// -> S      : string to compile
// -> ASop   : sic compiler options offset
//
// <- Result : result or zero on error
// <- ASop   : actual compiler options
// <- AError : error code or zero on success
//             AError = 0x00000100 -> compiler error
//
//             if compiler option SIC_OPT_FLAG_FP_FRAME is enabled
//             AError and 0x00000008 = OE flag
//             AError and 0x00000004 = ZE flag
//             AError and 0x00000001 = IE flag
//

{$EXTERNALSYM sic_va_count}
function sic_va_count: Integer; stdcall;
//
// Variable argument count
//
// <- Result : variable argument count
//

{$EXTERNALSYM sic_inda}
function sic_inda (code: Pointer; data: Pointer; x64: Byte): Integer; stdcall;
//
// Instruction disassembler
//
// -> code - pointer to the code
// -> data - pointer to TSIC_IDAData structure
// -> x64  - x64=0 for 32-bit, x64!=0 for 64-bit code
//
// <- Result : instruction size
// <- edx    : instruction flags
//

{$EXTERNALSYM cpuseed}
function cpuseed: UIntX; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    x64 : <- rax [0, 2^64-1]-interval
//    x32 : <- eax [0, 2^32-1]-interval
//

{$EXTERNALSYM cpuseed64}
function cpuseed64: UInt64; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^64-1]-interval
//    x64 : <- rax
//    x32 : <- eax:edx
//

{$EXTERNALSYM cpuseed32}
function cpuseed32: UInt32; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^32-1]-interval
//    <- eax
//

{$EXTERNALSYM cpuseed16}
function cpuseed16: UInt16; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^16-1]-interval
//    <- ax
//

{$EXTERNALSYM cpurand}
function cpurand: UIntX; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    x64 : <- rax [0, 2^64-1]-interval
//    x32 : <- eax [0, 2^32-1]-interval
//

{$EXTERNALSYM cpurand64}
function cpurand64: UInt64; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^64-1]-interval
//    x64 : <- rax
//    x32 : <- eax:edx
//

{$EXTERNALSYM cpurand32}
function cpurand32: UInt32; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^32-1]-interval
//    <- eax
//

{$EXTERNALSYM cpurand16}
function cpurand16: UInt16; stdcall;
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^16-1]-interval
//    <- ax
//

{$EXTERNALSYM cpurandf}
function cpurandf: Double; stdcall;
//
// CPU random generator
//
// <- Result : random float number
//    [0,1)-interval (53-bit resolution)
//

{$EXTERNALSYM cpurandf2pi}
function cpurandf2pi: Double; stdcall;
//
// CPU random generator
//
// <- Result : random float number
//    [0,2•pi)-interval (53-bit resolution)
//

{$EXTERNALSYM mt19937_igen}
function mt19937_igen: UIntX; stdcall;
//
// Mersenne Twister random generator
//
// <- Result : random uint number
//    x64 : <- rax [0, 2^64-1]-interval
//    x32 : <- eax [0, 2^32-1]-interval
//

{$EXTERNALSYM mt19937_fgen}
function mt19937_fgen: Double; stdcall;
//
// Mersenne Twister random generator
//
// <- Result : random float number
//    [0,1)-interval (53-bit resolution)
//

{$EXTERNALSYM mt19937_fgen2pi}
function mt19937_fgen2pi: Double; stdcall;
//
// Mersenne Twister random generator
//
// <- Result : random float number
//    [0,2•pi)-interval (53-bit resolution)
//

{$EXTERNALSYM mt19937_seed}
procedure mt19937_seed (ASeed: UIntX); stdcall;
//
// Mersenne Twister seed by value
//
// -> ASeed : seed value
//

{$EXTERNALSYM mt19937_seeds}
procedure mt19937_seeds (ASeeds: PUIntX; ACount: UIntX); stdcall;
//
// Mersenne Twister seed by array
//
// -> ASeeds : pointer to seed values array
// -> ACount : seeds count
//

{$EXTERNALSYM sic_erf}
function sic_erf (A: Double): Double; stdcall;
//
// Error function
//

{$EXTERNALSYM sic_erfc}
function sic_erfc (A: Double): Double; stdcall;
//
// Complementary error function
//

{$EXTERNALSYM sic_cdfnorm}
function sic_cdfnorm (A: Double): Double; stdcall;
//
// Normal distribution function
//

{$EXTERNALSYM sic_erfinv}
function sic_erfinv (A: Double): Double; stdcall;
//
// Inverse error function
//

{$EXTERNALSYM sic_erfcinv}
function sic_erfcinv (A: Double): Double; stdcall;
//
// Inverse complementary error function
//

{$EXTERNALSYM sic_cdfnorminv}
function sic_cdfnorminv (A: Double): Double; stdcall;
//
// Inverse of normal distribution function
//

{$EXTERNALSYM sic_lgamma}
function sic_lgamma (A: Double): Double; stdcall;
//
// Natural logarithm of the absolute value of gamma function
//

{$EXTERNALSYM sic_lgammas}
function sic_lgammas (A: Double; var S: DWORD): Double; stdcall;
//
// Natural logarithm of the absolute value and the sign of gamma function
// <- S - gamma function sign flag
//    0 : positive
//    1 : negative
//

{$EXTERNALSYM sic_tgamma}
function sic_tgamma (A: Double): Double; stdcall;
//
// Gamma function
//

{$EXTERNALSYM sic_rgamma}
function sic_rgamma (A: Double): Double; stdcall;
//
// Reciprocal gamma function
//

{$EXTERNALSYM sic_rtgamma}
function sic_rtgamma (A: Double): Double; stdcall;
//
// Reciprocal gamma function
//

{$EXTERNALSYM sic_beta}
function sic_beta (A, B: Double): Double; stdcall;
//
// Beta function
//

implementation

{$IFDEF SIC_STATIC}

{$IFDEF __imp_procs}
var
  // IMPORT KERNEL32.DLL
  __imp_GetCurrentDirectoryA : Pointer = nil;
  __imp_SetCurrentDirectoryA : Pointer = nil;
  __imp_GetModuleFileNameA : Pointer = nil;
  __imp_GetFullPathNameA : Pointer = nil;
  __imp_GetPrivateProfileSectionNamesA : Pointer = nil;
  __imp_GetPrivateProfileSectionA : Pointer = nil;
  __imp_SetDllDirectoryA : Pointer = nil;
  __imp_LoadLibraryA : Pointer = nil;
  __imp_LoadLibraryExA : Pointer = nil;
  __imp_FreeLibrary : Pointer = nil;
  __imp_GetProcAddress : Pointer = nil;
  __imp_CreateFileA : Pointer = nil;
  __imp_GetFileSize : Pointer = nil;
  __imp_CompareStringA : Pointer = nil;
  __imp_lstrlenA : Pointer = nil;
  __imp_lstrcpyA : Pointer = nil;
  __imp_lstrcpynA : Pointer = nil;
  __imp_VirtualAlloc : Pointer = nil;
  __imp_VirtualFree : Pointer = nil;
  __imp_VirtualProtect : Pointer = nil;
  __imp_GetProcessHeap : Pointer = nil;
  __imp_HeapAlloc : Pointer = nil;
  __imp_HeapReAlloc : Pointer = nil;
  __imp_HeapFree : Pointer = nil;
  __imp_GetCurrentProcess : Pointer = nil;
  __imp_FlushInstructionCache : Pointer = nil;
  __imp_CloseHandle : Pointer = nil;
  __imp_GetLastError : Pointer = nil;

  // IMPORT MSVCRT.DLL
  __imp_setlocale : Pointer = nil;
  __imp_strtol : Pointer = nil;
  __imp_strtod : Pointer = nil;
  __imp__strtoi64 : Pointer = nil;
  __imp__strtoui64 : Pointer = nil;
  __imp_strlen : Pointer = nil;
  __imp_strcpy : Pointer = nil;
  __imp_strncpy : Pointer = nil;
  __imp_strcmp : Pointer = nil;
  __imp__stricmp : Pointer = nil;
  __imp_strncmp : Pointer = nil;
  __imp__strnicmp : Pointer = nil;
  __imp_wctomb : Pointer = nil;
{$ENDIF}

function  sic_version;     external;
function  sic_cpu_support; external;
procedure sic_setup;       external;
procedure sic_cretab;      external;
procedure sic_fretab;      external;
function  sic_funtac;      external;
procedure sic_funtaf;      external;
function  sic_funloa;      external;
procedure sic_funulo;      external;
function  sic_contac;      external;
procedure sic_contaf;      external;
function  sic_conloa;      external;
procedure sic_conulo;      external;
function  sic_vartac;      external;
procedure sic_vartaf;      external;
function  sic_varloa;      external;
procedure sic_varulo;      external;
function  sic_runtac;      external;
procedure sic_runtaf;      external;
procedure sic_init;        external;
procedure sic_done;        external;
function  sic_afun;        external;
function  sic_refun;       external;
function  sic_dufun;       external;
function  sic_exfun;       external;
function  sic_aconf;       external;
function  sic_aconi;       external;
function  sic_acons;       external;
function  sic_acono;       external;
function  sic_aconp;       external;
function  sic_aconpf;      external;
function  sic_aconpi;      external;
function  sic_aconps;      external;
function  sic_recon;       external;
function  sic_ducon;       external;
function  sic_excon;       external;
function  sic_avarf;       external;
function  sic_avari;       external;
function  sic_avars;       external;
function  sic_avaro;       external;
function  sic_avarp;       external;
function  sic_avarpf;      external;
function  sic_avarpi;      external;
function  sic_avarps;      external;
function  sic_revar;       external;
function  sic_duvar;       external;
function  sic_exvar;       external;
function  sic_invaf;       external;
function  sic_invac;       external;
function  sic_invav;       external;
procedure sic_patab;       external;
function  sic_pafut;       external;
function  sic_pacot;       external;
function  sic_pavat;       external;
function  sic_gefut;       external;
function  sic_gefuc;       external;
function  sic_gefui;       external;
function  sic_gefun;       external;
function  sic_gecot;       external;
function  sic_gecoc;       external;
function  sic_gecoi;       external;
function  sic_gecon;       external;
function  sic_gevat;       external;
function  sic_gevac;       external;
function  sic_gevai;       external;
function  sic_gevar;       external;
function  sic_gerut;       external;
function  sic_geruc;       external;
function  sic_gerui;       external;
function  sic_gerun;       external;
function  sic_compile;     external;
function  sic_build;       external;
function  sic_exec;        external;
procedure sic_call;        external;
function  sic_cexec;       external;
function  sic_bexec;       external;
function  sic_scexec;      external;
function  sic_sbexec;      external;
function  sic_va_count;    external;
function  sic_inda;        external;

function  cpuseed;         external;
function  cpuseed64;       external;
function  cpuseed32;       external;
function  cpuseed16;       external;
function  cpurand;         external;
function  cpurand64;       external;
function  cpurand32;       external;
function  cpurand16;       external;
function  cpurandf;        external;
function  cpurandf2pi;     external;

function  mt19937_igen;    external;
function  mt19937_fgen;    external;
function  mt19937_fgen2pi; external;
procedure mt19937_seed;    external;
procedure mt19937_seeds;   external;

function  sic_erf;         external;
function  sic_erfc;        external;
function  sic_cdfnorm;     external;
function  sic_erfinv;      external;
function  sic_erfcinv;     external;
function  sic_cdfnorminv;  external;
function  sic_lgamma;      external;
function  sic_lgammas;     external;
function  sic_tgamma;      external;
function  sic_rgamma;      external;
function  sic_rtgamma;     external;
function  sic_beta;        external;

{$ELSE}

const
  {$IFDEF SIC_SSE}
  {$IFDEF CPUX64}
  sicxn = 'SICs64.DLL';
  {$ELSE}
  sicxn = 'SICs32.DLL';
  {$ENDIF}
  {$ELSE}
  {$IFDEF CPUX64}
  sicxn = 'SICx64.DLL';
  {$ELSE}
  sicxn = 'SICx32.DLL';
  {$ENDIF}
  {$ENDIF}

function  sic_version;     external sicxn name 'sic_version';
function  sic_cpu_support; external sicxn name 'sic_cpu_support';
procedure sic_setup;       external sicxn name 'sic_setup';
procedure sic_cretab;      external sicxn name 'sic_cretab';
procedure sic_fretab;      external sicxn name 'sic_fretab';
function  sic_funtac;      external sicxn name 'sic_funtac';
procedure sic_funtaf;      external sicxn name 'sic_funtaf';
function  sic_funloa;      external sicxn name 'sic_funloa';
procedure sic_funulo;      external sicxn name 'sic_funulo';
function  sic_contac;      external sicxn name 'sic_contac';
procedure sic_contaf;      external sicxn name 'sic_contaf';
function  sic_conloa;      external sicxn name 'sic_conloa';
procedure sic_conulo;      external sicxn name 'sic_conulo';
function  sic_vartac;      external sicxn name 'sic_vartac';
procedure sic_vartaf;      external sicxn name 'sic_vartaf';
function  sic_varloa;      external sicxn name 'sic_varloa';
procedure sic_varulo;      external sicxn name 'sic_varulo';
function  sic_runtac;      external sicxn name 'sic_runtac';
procedure sic_runtaf;      external sicxn name 'sic_runtaf';
procedure sic_init;        external sicxn name 'sic_init';
procedure sic_done;        external sicxn name 'sic_done';
function  sic_afun;        external sicxn name 'sic_afun';
function  sic_refun;       external sicxn name 'sic_refun';
function  sic_dufun;       external sicxn name 'sic_dufun';
function  sic_exfun;       external sicxn name 'sic_exfun';
function  sic_aconf;       external sicxn name 'sic_aconf';
function  sic_aconi;       external sicxn name 'sic_aconi';
function  sic_acons;       external sicxn name 'sic_acons';
function  sic_acono;       external sicxn name 'sic_acono';
function  sic_aconp;       external sicxn name 'sic_aconp';
function  sic_aconpf;      external sicxn name 'sic_aconpf';
function  sic_aconpi;      external sicxn name 'sic_aconpi';
function  sic_aconps;      external sicxn name 'sic_aconps';
function  sic_recon;       external sicxn name 'sic_recon';
function  sic_ducon;       external sicxn name 'sic_ducon';
function  sic_excon;       external sicxn name 'sic_excon';
function  sic_avarf;       external sicxn name 'sic_avarf';
function  sic_avari;       external sicxn name 'sic_avari';
function  sic_avars;       external sicxn name 'sic_avars';
function  sic_avaro;       external sicxn name 'sic_avaro';
function  sic_avarp;       external sicxn name 'sic_avarp';
function  sic_avarpf;      external sicxn name 'sic_avarpf';
function  sic_avarpi;      external sicxn name 'sic_avarpi';
function  sic_avarps;      external sicxn name 'sic_avarps';
function  sic_revar;       external sicxn name 'sic_revar';
function  sic_duvar;       external sicxn name 'sic_duvar';
function  sic_exvar;       external sicxn name 'sic_exvar';
function  sic_invaf;       external sicxn name 'sic_invaf';
function  sic_invac;       external sicxn name 'sic_invac';
function  sic_invav;       external sicxn name 'sic_invav';
procedure sic_patab;       external sicxn name 'sic_patab';
function  sic_pafut;       external sicxn name 'sic_pafut';
function  sic_pacot;       external sicxn name 'sic_pacot';
function  sic_pavat;       external sicxn name 'sic_pavat';
function  sic_gefut;       external sicxn name 'sic_gefut';
function  sic_gefuc;       external sicxn name 'sic_gefuc';
function  sic_gefui;       external sicxn name 'sic_gefui';
function  sic_gefun;       external sicxn name 'sic_gefun';
function  sic_gecot;       external sicxn name 'sic_gecot';
function  sic_gecoc;       external sicxn name 'sic_gecoc';
function  sic_gecoi;       external sicxn name 'sic_gecoi';
function  sic_gecon;       external sicxn name 'sic_gecon';
function  sic_gevat;       external sicxn name 'sic_gevat';
function  sic_gevac;       external sicxn name 'sic_gevac';
function  sic_gevai;       external sicxn name 'sic_gevai';
function  sic_gevar;       external sicxn name 'sic_gevar';
function  sic_gerut;       external sicxn name 'sic_gerut';
function  sic_geruc;       external sicxn name 'sic_geruc';
function  sic_gerui;       external sicxn name 'sic_gerui';
function  sic_gerun;       external sicxn name 'sic_gerun';
function  sic_compile;     external sicxn name 'sic_compile';
function  sic_build;       external sicxn name 'sic_build';
function  sic_exec;        external sicxn name 'sic_exec';
procedure sic_call;        external sicxn name 'sic_call';
function  sic_cexec;       external sicxn name 'sic_cexec';
function  sic_bexec;       external sicxn name 'sic_bexec';
function  sic_scexec;      external sicxn name 'sic_scexec';
function  sic_sbexec;      external sicxn name 'sic_sbexec';
function  sic_va_count;    external sicxn name 'sic_va_count';
function  sic_inda;        external sicxn name 'sic_inda';

function  cpuseed;         external sicxn name 'cpuseed';
function  cpuseed64;       external sicxn name 'cpuseed64';
function  cpuseed32;       external sicxn name 'cpuseed32';
function  cpuseed16;       external sicxn name 'cpuseed16';
function  cpurand;         external sicxn name 'cpurand';
function  cpurand64;       external sicxn name 'cpurand64';
function  cpurand32;       external sicxn name 'cpurand32';
function  cpurand16;       external sicxn name 'cpurand16';
function  cpurandf;        external sicxn name 'cpurandf';
function  cpurandf2pi;     external sicxn name 'cpurandf2pi';

function  mt19937_igen;    external sicxn name 'mt19937_igen';
function  mt19937_fgen;    external sicxn name 'mt19937_fgen';
function  mt19937_fgen2pi; external sicxn name 'mt19937_fgen2pi';
procedure mt19937_seed;    external sicxn name 'mt19937_seed';
procedure mt19937_seeds;   external sicxn name 'mt19937_seeds';

function  sic_erf;         external sicxn name 'sic_erf';
function  sic_erfc;        external sicxn name 'sic_erfc';
function  sic_cdfnorm;     external sicxn name 'sic_cdfnorm';
function  sic_erfinv;      external sicxn name 'sic_erfinv';
function  sic_erfcinv;     external sicxn name 'sic_erfcinv';
function  sic_cdfnorminv;  external sicxn name 'sic_cdfnorminv';
function  sic_lgamma;      external sicxn name 'sic_lgamma';
function  sic_lgammas;     external sicxn name 'sic_lgammas';
function  sic_tgamma;      external sicxn name 'sic_tgamma';
function  sic_rgamma;      external sicxn name 'sic_rgamma';
function  sic_rtgamma;     external sicxn name 'sic_rtgamma';
function  sic_beta;        external sicxn name 'sic_beta';

{$ENDIF}

{
}
procedure Enter;
begin
  {$IFDEF __imp_procs}
  __imp_GetCurrentDirectoryA := @GetCurrentDirectoryA;
  __imp_SetCurrentDirectoryA := @SetCurrentDirectoryA;
  __imp_GetModuleFileNameA := @GetModuleFileNameA;
  __imp_GetFullPathNameA := @GetFullPathNameA;
  __imp_GetPrivateProfileSectionNamesA := @GetPrivateProfileSectionNamesA;
  __imp_GetPrivateProfileSectionA := @GetPrivateProfileSectionA;
  __imp_SetDllDirectoryA := @SetDllDirectoryA;
  __imp_LoadLibraryA := @LoadLibraryA;
  __imp_LoadLibraryExA := @LoadLibraryExA;
  __imp_FreeLibrary := @FreeLibrary;
  __imp_GetProcAddress := @GetProcAddress;
  __imp_CreateFileA := @CreateFileA;
  __imp_GetFileSize := @GetFileSize;
  __imp_CompareStringA := @CompareStringA;
  __imp_lstrlenA := @lstrlenA;
  __imp_lstrcpyA := @lstrcpyA;
  __imp_lstrcpynA := @lstrcpynA;
  __imp_VirtualAlloc := @VirtualAlloc;
  __imp_VirtualFree := @VirtualFree;
  __imp_VirtualProtect := @VirtualProtect;
  __imp_GetProcessHeap := @GetProcessHeap;
  __imp_HeapAlloc := @HeapAlloc;
  __imp_HeapReAlloc := @HeapReAlloc;
  __imp_HeapFree := @HeapFree;
  __imp_GetCurrentProcess := @GetCurrentProcess;
  __imp_FlushInstructionCache := @FlushInstructionCache;
  __imp_CloseHandle := @CloseHandle;
  __imp_GetLastError := @GetLastError;

  __imp_setlocale := @setlocale;
  __imp_strtol := @strtol;
  __imp_strtod := @strtod;
  __imp__strtoi64 := @_strtoi64;
  __imp__strtoui64 := @_strtoui64;
  __imp_strlen := @strlen;
  __imp_strcpy := @strcpy;
  __imp_strncpy := @strncpy;
  __imp_strcmp := @strcmp;
  __imp__stricmp := @_stricmp;
  __imp_strncmp := @strncmp;
  __imp__strnicmp := @_strnicmp;
  __imp_wctomb := @wctomb;
  {$ENDIF}
end;

initialization
  SICxProcs.Enter;

end.

