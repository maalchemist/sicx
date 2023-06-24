unit SICxDefs;

// SICx.DLL defs

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
  Windows;

type
  PINT_PTR = ^INT_PTR;
  {$IFDEF CPUX64}
  INT_PTR = Int64;
  {$ELSE}
  INT_PTR = Integer;
  {$ENDIF}

type
  PUINT_PTR = ^UINT_PTR;
  {$IFDEF CPUX64}
  UINT_PTR = UInt64;
  {$ELSE}
  UINT_PTR = Cardinal;
  {$ENDIF}

type
  PPointer = ^Pointer;
  PPAnsiChar = ^PAnsiChar;

type
  Int16  = SmallInt;
  Int32  = Integer;
  UInt16 = Word;
  PUInt32 = ^UInt32;
  UInt32 = Cardinal;
  {$IFDEF VER_D4L} // Delphi 4.0 or lower
  PUInt64 = ^UInt64;
  UInt64 = Int64;
  {$ENDIF}

type
  {$IFDEF CPUX64}
  PUIntX = ^UIntX;
  UIntX = UInt64;
  {$ELSE}
  PUIntX = ^UIntX;
  UIntX = Cardinal;
  {$ENDIF}

const
  // Compiler configuration flags

  // --------------------------------
  // Case sensitive compiler
  // --------------------------------
  SIC_CFG_FLAG_CASE_SENSITIVE   = $00000001; // 00000000 00000001

  // --------------------------------
  // Bypass user-defined functions
  // SICx*.UDF
  // --------------------------------
  SIC_CFG_FLAG_NO_UDF           = $00000002; // 00000000 00000010

  // --------------------------------
  // Bypass user-defined constants
  // SICx*.UDC
  // --------------------------------
  SIC_CFG_FLAG_NO_UDC           = $00000004; // 00000000 00000100

  // --------------------------------
  // Bypass user-defined variables
  // SICx*.UDV
  // --------------------------------
  SIC_CFG_FLAG_NO_UDV           = $00000008; // 00000000 00001000

const
  // Compiler default configuration flags

  SIC_CFG_DEFAULT_X32 = 0;
  SIC_CFG_DEFAULT_X64 = 0;

const
  // Compiler options flags

  // --------------------------------
  // Code optimization
  // --------------------------------
  SIC_OPT_FLAG_OPTIMIZATION     = $00000001; // 00000000 00000001

  // --------------------------------
  // Stack frame
  // --------------------------------
  SIC_OPT_FLAG_STACK_FRAME      = $00000002; // 00000000 00000010

  // --------------------------------
  // Build mode
  // Local variables
  // --------------------------------
  SIC_OPT_FLAG_LOCALS           = $00000004; // 00000000 00000100

  // --------------------------------
  // Mask all FP exceptions
  // Return FP exception flags in EAX
  // Use this option to avoid exception raising on FP errors
  // --------------------------------
  SIC_OPT_FLAG_FP_FRAME         = $00000008; // 00000000 00001000

  // --------------------------------
  // Debug mode
  // --------------------------------
  SIC_OPT_FLAG_DEBUG            = $00000010; // 00000000 00010000

  // --------------------------------
  // x64 CPU mode
  // --------------------------------
  SIC_OPT_FLAG_CPUX64           = $00000020; // 00000000 00100000

  // --------------------------------
  // x32 CPU mode
  // --------------------------------
  SIC_OPT_FLAG_CPUX32           = $00000040; // 00000000 01000000

  // --------------------------------
  // Any CPU mode
  // --------------------------------
  SIC_OPT_FLAG_CPUX             = $00000080; // 00000000 10000000

  // --------------------------------
  // Data alignment
  //
  // Default align values
  // x32: 8-byte data alignment
  // x64: 16-byte data alignment
  // --------------------------------
  SIC_OPT_FLAG_DALIGN           = $00000100; // 00000001 00000000

  // --------------------------------
  // Build mode
  // Disable code alignment
  //
  // Default align values
  // x32: 8-byte code alignment
  // x64: 16-byte code alignment
  // --------------------------------
  SIC_OPT_FLAG_NO_CALIGN        = $00000200; // 00000010 00000000

  // --------------------------------
  // Disable compile-time calculations
  // of external functions
  // --------------------------------
  SIC_OPT_FLAG_NO_ECALC         = $00000400; // 00000100 00000000

  // --------------------------------
  // Complex functions
  // --------------------------------
  SIC_OPT_FLAG_COMPLEX          = $00000800; // 00001000 00000000

  // --------------------------------
  // Compact mode
  // Line break as expression separator
  // --------------------------------
  SIC_OPT_FLAG_COMPACT          = $00001000; // 00010000 00000000

const
  // --------------------------------
  // Compiler default options x32
  // --------------------------------
  // Code optimization
  // Stack frame
  // Local variables
  // --------------------------------
  SIC_OPT_DEFAULT_X32 = SIC_OPT_FLAG_OPTIMIZATION or
                        SIC_OPT_FLAG_STACK_FRAME  or
                        SIC_OPT_FLAG_LOCALS        ;

  // --------------------------------
  // Compiler default options x64
  // --------------------------------
  // Code optimization
  // Stack frame
  // Local variables
  // --------------------------------
  SIC_OPT_DEFAULT_X64 = SIC_OPT_FLAG_OPTIMIZATION or
                        SIC_OPT_FLAG_STACK_FRAME  or
                        SIC_OPT_FLAG_LOCALS        ;

const
  // Compiler error codes

  SIC_ERROR_SUCCESS    = 0;
  SIC_ERROR_GENERAL    = 1;
  SIC_ERROR_CPU        = 2;
  SIC_ERROR_STRING     = 3;
  SIC_ERROR_MEMORY     = 4;
  SIC_ERROR_BRACKET    = 5;
  SIC_ERROR_TOKEN      = 6;
  SIC_ERROR_RT_TOKEN   = 7;
  SIC_ERROR_STACK      = 8;
  SIC_ERROR_RPN_BUILD  = 9;
  SIC_ERROR_CODE_BUILD = 10;
  SIC_ERROR_ARGUMENT   = 11;
  SIC_ERROR_EVALUATE   = 12;
  SIC_ERROR_EXECUTE    = 13;
  SIC_ERROR_RANGE      = 14;
  SIC_ERROR_NO_IMPL    = 15;
  SIC_ERROR_POINTER    = 16;

const
  // CPU flags

  SIC_CPU_FLAG_SSE      = $00000001;
  SIC_CPU_FLAG_SSE2     = $00000002;
  SIC_CPU_FLAG_SSE3     = $00000004;
  SIC_CPU_FLAG_SSSE3    = $00000008;
  SIC_CPU_FLAG_SSE4_1   = $00000010;
  SIC_CPU_FLAG_SSE4_2   = $00000020;
  SIC_CPU_FLAG_AVX      = $00000040;
  SIC_CPU_FLAG_AVX2     = $00000080;
  SIC_CPU_FLAG_AVX512   = $00000100;
  SIC_CPU_FLAG_BMI1     = $00000200;
  SIC_CPU_FLAG_BMI2     = $00000400;
  SIC_CPU_FLAG_POPCNT   = $00000800;
  SIC_CPU_FLAG_LZCNT    = $00001000;
  SIC_CPU_FLAG_FMA      = $00002000;
  SIC_CPU_FLAG_ADX      = $00004000;
  // SIC_CPU_FLAG_???   = $00008000;
  SIC_CPU_FLAG_AVX512F  = $00010000; // AVX-512 Foundation (F)
  SIC_CPU_FLAG_AVX512VL = $00020000; // AVX-512 Vector Length Extensions (VL)
  SIC_CPU_FLAG_RDRAND   = $10000000;
  SIC_CPU_FLAG_RDSEED   = $20000000;

const
  // Table item name size

  SIC_FunNameSize = 50;
  SIC_ConNameSize = 44;
  SIC_VarNameSize = 44;

implementation

end.



