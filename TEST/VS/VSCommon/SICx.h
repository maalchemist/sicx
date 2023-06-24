// SICx.h

// Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
// All rights reserved
//
// http://maalchemist.ru
// http://maalchemist.narod.ru
// maa@maalchemist.ru
// maalchemist@yandex.ru
// maalchemist@gmail.com

#ifndef _SICX_H_
#define _SICX_H_

#pragma once

#define SICXAPI __stdcall

//===========================================================================
//
//  SICx Defs
//
//===========================================================================

// Compiler configuration flags

// --------------------------------
// Case sensitive compiler
// --------------------------------
#define SIC_CFG_FLAG_CASE_SENSITIVE     0x00000001 // 00000000 00000001

// --------------------------------
// Bypass user-defined functions
// SICx*.UDF
// --------------------------------
#define SIC_CFG_FLAG_NO_UDF             0x00000002 // 00000000 00000010

// --------------------------------
// Bypass user-defined constants
// SICx*.UDC
// --------------------------------
#define SIC_CFG_FLAG_NO_UDC             0x00000004 // 00000000 00000100

// --------------------------------
// Bypass user-defined variables
// SICx*.UDV
// --------------------------------
#define SIC_CFG_FLAG_NO_UDV             0x00000008 // 00000000 00001000

// Compiler default configuration flags

#define SIC_CFG_DEFAULT_X32 0
#define SIC_CFG_DEFAULT_X64 0

// Compiler options flags

// --------------------------------
// Code optimization
// --------------------------------
#define SIC_OPT_FLAG_OPTIMIZATION       0x00000001 // 00000000 00000001

// --------------------------------
// Stack frame
// --------------------------------
#define SIC_OPT_FLAG_STACK_FRAME        0x00000002 // 00000000 00000010

// --------------------------------
// Build mode
// Local variables
// --------------------------------
#define SIC_OPT_FLAG_LOCALS             0x00000004 // 00000000 00000100

// --------------------------------
// Mask all FP exceptions
// Return FP exception flags in EAX
// Use this option to avoid exception raising on FP errors
// --------------------------------
#define SIC_OPT_FLAG_FP_FRAME           0x00000008 // 00000000 00001000

// --------------------------------
// Debug mode
// --------------------------------
#define SIC_OPT_FLAG_DEBUG              0x00000010 // 00000000 00010000

// --------------------------------
// x64 CPU mode
// --------------------------------
#define SIC_OPT_FLAG_CPUX64             0x00000020 // 00000000 00100000

// --------------------------------
// x32 CPU mode
// --------------------------------
#define SIC_OPT_FLAG_CPUX32             0x00000040 // 00000000 01000000

// --------------------------------
// Any CPU mode
// --------------------------------
#define SIC_OPT_FLAG_CPUX               0x00000080 // 00000000 10000000

// --------------------------------
// Data alignment
//
// Default align values
// x32: 8-byte data alignment
// x64: 16-byte data alignment
// --------------------------------
#define SIC_OPT_FLAG_DALIGN             0x00000100 // 00000001 00000000

// --------------------------------
// Build mode
// Disable code alignment
//
// Default align values
// x32: 8-byte code alignment
// x64: 16-byte code alignment
// --------------------------------
#define SIC_OPT_FLAG_NO_CALIGN          0x00000200 // 00000010 00000000

// --------------------------------
// Disable compile-time calculations
// of external functions
// --------------------------------
#define SIC_OPT_FLAG_NO_ECALC           0x00000400 // 00000100 00000000

// --------------------------------
// Complex functions
// --------------------------------
#define SIC_OPT_FLAG_COMPLEX            0x00000800 // 00001000 00000000

// --------------------------------
// Compact mode
// Line beak as expression separator
// --------------------------------
#define SIC_OPT_FLAG_COMPACT            0x00001000 // 00010000 00000000

// --------------------------------
// Compiler default options x32
// --------------------------------
// Code optimization
// Stack frame
// Local variables
// --------------------------------
#define SIC_OPT_DEFAULT_X32   ( SIC_OPT_FLAG_OPTIMIZATION | \
                                SIC_OPT_FLAG_STACK_FRAME  | \
                                SIC_OPT_FLAG_LOCALS       )

// --------------------------------
// Compiler default options x64
// --------------------------------
// Code optimization
// Stack frame
// Local variables
// --------------------------------
#define SIC_OPT_DEFAULT_X64   ( SIC_OPT_FLAG_OPTIMIZATION | \
                                SIC_OPT_FLAG_STACK_FRAME  | \
                                SIC_OPT_FLAG_LOCALS       )

// Compiler error codes

#define SIC_ERROR_SUCCESS    0
#define SIC_ERROR_GENERAL    1
#define SIC_ERROR_CPU        2
#define SIC_ERROR_STRING     3
#define SIC_ERROR_MEMORY     4
#define SIC_ERROR_BRACKET    5
#define SIC_ERROR_TOKEN      6
#define SIC_ERROR_RT_TOKEN   7
#define SIC_ERROR_STACK      8
#define SIC_ERROR_RPN_BUILD  9
#define SIC_ERROR_CODE_BUILD 10
#define SIC_ERROR_ARGUMENT   11
#define SIC_ERROR_EVALUATE   12
#define SIC_ERROR_EXECUTE    13
#define SIC_ERROR_RANGE      14
#define SIC_ERROR_NO_IMPL    15
#define SIC_ERROR_POINTER    16

// CPU flags

#define SIC_CPU_FLAG_SSE      0x00000001
#define SIC_CPU_FLAG_SSE2     0x00000002
#define SIC_CPU_FLAG_SSE3     0x00000004
#define SIC_CPU_FLAG_SSSE3    0x00000008
#define SIC_CPU_FLAG_SSE4_1   0x00000010
#define SIC_CPU_FLAG_SSE4_2   0x00000020
#define SIC_CPU_FLAG_AVX      0x00000040
#define SIC_CPU_FLAG_AVX2     0x00000080
#define SIC_CPU_FLAG_AVX512   0x00000100
#define SIC_CPU_FLAG_BMI1     0x00000200
#define SIC_CPU_FLAG_BMI2     0x00000400
#define SIC_CPU_FLAG_POPCNT   0x00000800
#define SIC_CPU_FLAG_LZCNT    0x00001000
#define SIC_CPU_FLAG_FMA      0x00002000
#define SIC_CPU_FLAG_ADX      0x00004000
// #define SIC_CPU_FLAG_???   0x00008000
#define SIC_CPU_FLAG_AVX512F  0x00010000 // AVX-512 Foundation (F)
#define SIC_CPU_FLAG_AVX512VL 0x00020000 // AVX-512 Vector Length Extensions (VL)
#define SIC_CPU_FLAG_RDRAND   0x10000000
#define SIC_CPU_FLAG_RDSEED   0x20000000

// Table item name size

#define SIC_FunNameSize 50
#define SIC_ConNameSize 44
#define SIC_VarNameSize 44

// IDA opcode flags

#define IDA_INVALID  0x00000001
#define IDA_PREFIX   0x00000002
#define IDA_REX      0x00000004
#define IDA_MODRM    0x00000008
#define IDA_SIB      0x00000010
#define IDA_DISP     0x00000020
#define IDA_IMM      0x00000040
#define IDA_RELATIVE 0x00000080
#define IDA_VEX2     0x00000100
#define IDA_VEX3     0x00000200
#define IDA_EVEX     0x00000400

//===========================================================================
//
//  SICx Structures
//
//===========================================================================

//
// use 1 byte packing for the data structures
//
#include "pshpack1.h"

//
// SIC config structure (x64)
//
typedef struct SIC_Config64 {
    UINT32 cflags;                  // Compiler flags
    UINT64 memory;                  // Memory block size

    UINT32 cpu_flags;               // CPU flags

    UINT32 section_code;            // Size of .code section
    UINT32 section_data;            // Size of .data section
    UINT32 section_idata;           // Size of .idata section
    UINT32 section_edata;           // Size of .edata section
    UINT32 section_rsrc;            // Size of .rsrc section
    UINT32 section_reloc;           // Size of .reloc section

    UINT32 fcode_size;              // Size of built-in functions

    UINT64 fdata_size;              // Function data segment size
    UINT32 fdata_count;             // Maximum function count
    UINT64 cdata_size;              // Constant data segment size
    UINT32 cdata_count;             // Maximum constant count
    UINT64 vdata_size;              // Variable data segment size
    UINT32 vdata_count;             // Maximum variable count
    UINT64 rdata_size;              // Runtime data segment size
    UINT32 rdata_count;             // Maximum runtime count
    UINT64 stack_size;              // Stack array size
    UINT32 stack_count;             // Maximum token count
    UINT64 rpn_size;                // Rpn array size
    UINT32 rpn_count;               // Maximum rpn item count
    UINT64 code_size;               // Code segment size

    UINT32 fitem_nsize;             // Maximum length of function name
    UINT32 citem_nsize;             // Maximum length of constant name
    UINT32 vitem_nsize;             // Maximum length of variable name

    UINT32 uddata_scount;           // Maximum section count in user-defined data files (SIC.UDF, SIC.UDV)
} TSIC_Config64, *PSIC_Config64;

//
// SIC config structure (x86)
//
typedef struct SIC_Config32 {
    UINT32 cflags;                  // Compiler flags
    UINT32 memory;                  // Memory block size

    UINT32 cpu_flags;               // CPU flags

    UINT32 section_code;            // Size of .code section
    UINT32 section_data;            // Size of .data section
    UINT32 section_idata;           // Size of .idata section
    UINT32 section_edata;           // Size of .edata section
    UINT32 section_rsrc;            // Size of .rsrc section
    UINT32 section_reloc;           // Size of .reloc section

    UINT32 fcode_size;              // Size of built-in functions

    UINT32 fdata_size;              // Function data segment size
    UINT32 fdata_count;             // Maximum function count
    UINT32 cdata_size;              // Constant data segment size
    UINT32 cdata_count;             // Maximum constant count
    UINT32 vdata_size;              // Variable data segment size
    UINT32 vdata_count;             // Maximum variable count
    UINT32 rdata_size;              // Runtime data segment size
    UINT32 rdata_count;             // Maximum runtime count
    UINT32 stack_size;              // Stack array size
    UINT32 stack_count;             // Maximum token count
    UINT32 rpn_size;                // Rpn array size
    UINT32 rpn_count;               // Maximum rpn item count
    UINT32 code_size;               // Code segment size

    UINT32 fitem_nsize;             // Maximum length of function name
    UINT32 citem_nsize;             // Maximum length of constant name
    UINT32 vitem_nsize;             // Maximum length of variable name

    UINT32 uddata_scount;           // Maximum section count in user-defined data files (SIC.UDF, SIC.UDV)
} TSIC_Config32, *PSIC_Config32;

#ifdef _WIN64
#define TSIC_Config TSIC_Config64
#else
#define TSIC_Config TSIC_Config32
#endif
  
//
// SIC data structure (x64)
//
typedef struct SIC_Data64 {
    UINT64 fdata;                   // Function data segment offset
    UINT64 cdata;                   // Constant data segment offset
    UINT64 vdata;                   // Variable data segment offset
    UINT64 rdata;                   // Runtime data segment offset
    UINT64 code;                    // Code segment offset
    UINT64 data;                    // Data segment offset
    UINT64 heap;                    // Heap segment offset
    UINT64 entry;                   // Entry point
    UINT64 param;                   // Parameter
    UINT32 size;                    // Code size
    UINT32 cspace;                  // Code space
    UINT32 calign;                  // Code align
    UINT32 dsize;                   // Data size
    UINT32 dspace;                  // Data space
    UINT32 dalign;                  // Data align
    UINT32 hsize;                   // Heap size
    UINT32 hspace;                  // Heap space
    UINT32 halign;                  // Heap align
    UINT32 coops;                   // Compiler options
    UINT32 tokens;                  // Scanned tokens count
    UINT32 rpn;                     // Rpn array item count
    UINT32 fcount;                  // Functions count
    UINT32 ccount;                  // Constants count
    UINT32 vcount;                  // Variables count
    UINT32 rcount;                  // Runtimes count
    UINT32 ccurs;                   // Current string cursor
    UINT32 pcurs;                   // Previous string cursor
    UINT64 gdata;                   // Global data
    UINT32 gcode;                   // Global code
    UINT32 ecode;                   // Error code
    UINT32 rcode;                   // Return code
    double value;                   // Return value
} TSIC_Data64, *PSIC_Data64;

//
// SIC data structure (x86)
//
typedef struct SIC_Data32 {
    UINT32 fdata;                   // Function data segment offset
    UINT32 cdata;                   // Constant data segment offset
    UINT32 vdata;                   // Variable data segment offset
    UINT32 rdata;                   // Runtime data segment offset
    UINT32 code;                    // Code segment offset
    UINT32 data;                    // Data segment offset
    UINT32 heap;                    // Heap segment offset
    UINT32 entry;                   // Entry point
    UINT32 param;                   // Parameter
    UINT32 size;                    // Code size
    UINT32 cspace;                  // Code space
    UINT32 calign;                  // Code align
    UINT32 dsize;                   // Data size
    UINT32 dspace;                  // Data space
    UINT32 dalign;                  // Data align
    UINT32 hsize;                   // Heap size
    UINT32 hspace;                  // Heap space
    UINT32 halign;                  // Heap align
    UINT32 coops;                   // Compiler options
    UINT32 tokens;                  // Scanned tokens count
    UINT32 rpn;                     // Rpn array item count
    UINT32 fcount;                  // Functions count
    UINT32 ccount;                  // Constants count
    UINT32 vcount;                  // Variables count
    UINT32 rcount;                  // Runtimes count
    UINT32 ccurs;                   // Current string cursor
    UINT32 pcurs;                   // Previous string cursor
    UINT32 gdata;                   // Global data
    UINT32 gcode;                   // Global code
    UINT32 ecode;                   // Error code
    UINT32 rcode;                   // Return code
    double value;                   // Return value
} TSIC_Data32, *PSIC_Data32;

#ifdef _WIN64
#define TSIC_Data TSIC_Data64
#else
#define TSIC_Data TSIC_Data32
#endif

//
// Common table header
//
typedef struct SIC_TableHeader {
    INT32 icount;                   // Item count
    INT32 mcount;                   // Item max count
    INT32 tisize;                   // Table item size
    INT32 tnsize;                   // Table item name size
    INT32 titype;                   // Table item type
                                    // = 1 - functions
                                    // = 2 - constants
                                    // = 3 - variables
    INT32 oooooo;                   // Padding
} TSIC_TableHeader, *PSIC_TableHeader;

//
// Function table item
//
typedef struct SIC_FunItem {
    CHAR   name[SIC_FunNameSize];   // Function name (zero terminated)
    INT16  retype;                  // Function return type
    INT16  acount;                  // Function argument count
    INT16  cosize;                  // Function code size or flags
    UINT64 offset;                  // Function offset
} TSIC_FunItem, *PSIC_FunItem;

//
// Function table
//
typedef struct SIC_FunTable {
    TSIC_TableHeader header;        // Function table header
    TSIC_FunItem     items[1];      // Function item list
} TSIC_FunTable, *PSIC_FunTable;

//
// Constant table item
//
typedef struct SIC_ConItem {
    CHAR   name[SIC_ConNameSize];   // Constant name (zero terminated)
    UINT64 codata;                  // Constant data
    INT16  cotype;                  // Constant type
    INT16  datype;                  // Constant data type
    double value;                   // Constant value
} TSIC_ConItem, *PSIC_ConItem;

//
// Constant table
//
typedef struct SIC_ConTable {
    TSIC_TableHeader header;        // Constant table header
    TSIC_ConItem     items[1];      // Constant item list
} TSIC_ConTable, *PSIC_ConTable;

//
// Variable table item
//
typedef struct SIC_VarItem {
    CHAR   name[SIC_VarNameSize];   // Variable name (zero terminated)
    UINT64 vadata;                  // Variable data
    INT16  vatype;                  // Variable type
    INT16  datype;                  // Variable data type
    UINT64 offset;                  // Variable offset
} TSIC_VarItem, *PSIC_VarItem;

//
// Variable table
//
typedef struct SIC_VarTable {
    TSIC_TableHeader header;        // Variable table header
    TSIC_VarItem     items[1];      // Variable item list
} TSIC_VarTable, *PSIC_VarTable;

//
// Complex number
//
typedef struct SIC_Complex {
    double re;                      // Real part
    double im;                      // Imaginary part
} TSIC_Complex, *PSIC_Complex;

//
// IDA data
//
typedef struct SIC_IDAData {
    UINT8  instr_size;
    UINT32 flags;
    UINT8  prefix_size;
    UINT8  rex;
    UINT8  prex_size;               // VEX/EVEX prefix size
    UINT8  prex_0;                  // VEX.2:C5H VEX.3:C4H EVEX:62H
    UINT8  prex_1;
    UINT8  prex_2;
    UINT8  prex_3;
    UINT8  modrm;
    UINT8  sib;
    UINT8  opcode_offset;
    UINT8  opcode_size;
    UINT8  disp_offset;
    UINT8  disp_size;
    UINT8  imm_offset;
    UINT8  imm_size;
} TSIC_IDAData, *PSIC_IDAData;

//
// revert back to normal default packing
//
#include "poppack.h"

//===========================================================================
//
//  SICx Functions
//
//===========================================================================

DWORD
SICXAPI
sic_version (VOID);
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

BOOL
SICXAPI
sic_cpu_support (VOID);
//
// Compiler support for the CPU
//
// <- Result : 1 - CPU supported
//             0 - CPU not supported
//

VOID
SICXAPI
sic_setup (LPVOID AConfig);
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

VOID
SICXAPI
sic_cretab (VOID);
//
// Create global tables
//

VOID
SICXAPI
sic_fretab (VOID);
//
// Destroy global tables
//

DWORD
SICXAPI
sic_funtac (VOID);
//
// Create global function table
// Assign table header and add built-in functions
//
// <- Result : function table item count or zero on error
//

VOID
SICXAPI
sic_funtaf (VOID);
//
// Destroy global function table
//

DWORD
SICXAPI
sic_funloa (VOID);
//
// Load external user defined functions
//
// <- Result : external function item count
//

VOID
SICXAPI
sic_funulo (VOID);
//
// Unload external user defined functions
//

DWORD
SICXAPI
sic_contac (VOID);
//
// Create global constant table
// Assign table header and add predefined constants
//
// <- Result : constant table item count or zero on error
//

VOID
SICXAPI
sic_contaf (VOID);
//
// Destroy global constant table
//

DWORD
SICXAPI
sic_conloa (VOID);
//
// Load external user defined constants
//
// <- Result : external constant item count
//

VOID
SICXAPI
sic_conulo (VOID);
//
// Unload external user defined constants
//

DWORD
SICXAPI
sic_vartac (VOID);
//
// Create global variable table
// Assign table header and add predefined variables
//
// <- Result : variable table item count or zero on error
//

VOID
SICXAPI
sic_vartaf (VOID);
//
// Destroy global variable table
//

DWORD
SICXAPI
sic_varloa (VOID);
//
// Load external user defined variables
//
// <- Result : external variable item count
//

VOID
SICXAPI
sic_varulo (VOID);
//
// Unload external user defined variables
//

DWORD
SICXAPI
sic_runtac (VOID);
//
// Create global runtime table
//
// <- Result : function table item count
//

VOID
SICXAPI
sic_runtaf (VOID);
//
// Destroy global runtime table
//

VOID
SICXAPI
sic_init (LPVOID ASic);
//
// Allocate memory for ASic data segments
// Assign table headers
//
// -> ASic : TSIC_Data structure offset
//

VOID
SICXAPI
sic_done (LPVOID ASic);
//
// Free memory previously allocated for ASic data and code segments
//
// -> ASic : TSIC_Data structure offset
//

INT
SICXAPI
sic_afun (LPVOID ASic, LPCSTR AFuname, LPVOID AOffset, INT16 AACount, UINT16 AFlags);
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
// <- Result : function index or negative value on error
//

INT
SICXAPI
sic_refun (LPVOID ASic, LPCSTR AFuname, LPCSTR AOrgname, BOOL AInvalidate);
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

INT
SICXAPI
sic_dufun (LPVOID ASic, LPCSTR AFuname, LPCSTR AOrgname);
//
// Duplicate global or local function
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic     : TSIC_Data structure offset
// -> AFuname  : function dup name
// -> AOrgname : function original name
// <- Result   : function index or negative value on error
//

INT
SICXAPI
sic_exfun (LPVOID ASic, LPCSTR AFuname, LPCSTR AFunami);
//
// Exchange global or local functions
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// -> AFunami : function name
// <- Result  : function index or negative value on error
//

INT
SICXAPI
sic_aconf (LPVOID ASic, LPCSTR AConame, double AValue);
//
// Add|set user defined global or local float constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_aconi (LPVOID ASic, LPCSTR AConame, INT_PTR AValue);
//
// Add|set user defined global or local integer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_acons (LPVOID ASic, LPCSTR AConame, LPCSTR AValue);
//
// Add|set user defined global or local string constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_acono (LPVOID ASic, LPCSTR AConame, LPVOID AValue);
//
// Add|set user defined global or local offset constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_aconp (LPVOID ASic, LPCSTR AConame, LPVOID AValue);
//
// Add|set user defined global or local pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_aconpf (LPVOID ASic, LPCSTR AConame, LPVOID AValue);
//
// Add|set user defined global or local float pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_aconpi (LPVOID ASic, LPCSTR AConame, LPVOID AValue);
//
// Add|set user defined global or local integer pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_aconps (LPVOID ASic, LPCSTR AConame, LPVOID AValue);
//
// Add|set user defined global or local string pointer constant ( AConame ) and assign data ( AValue )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AValue  : constant value
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_recon (LPVOID ASic, LPCSTR AConame, LPCSTR AOrgname, BOOL AInvalidate);
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

INT
SICXAPI
sic_ducon (LPVOID ASic, LPCSTR AConame, LPCSTR AOrgname);
//
// Duplicate global or local constant
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic     : TSIC_Data structure offset
// -> AConame  : constant dup name
// -> AOrgname : constant original name
// <- Result   : constant index or negative value on error
//

INT
SICXAPI
sic_excon (LPVOID ASic, LPCSTR AConame, LPCSTR AConami);
//
// Exchange global or local constants
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// -> AConami : constant name
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_avarf (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local float variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avari (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local integer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avars (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local string variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avaro (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local offset variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avarp (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avarpf (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local float pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avarpi (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local integer pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_avarps (LPVOID ASic, LPCSTR AVaname, LPVOID AOffset);
//
// Add|set user defined global or local string pointer variable ( AVaname ) and assign data ( AOffset )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AOffset : variable offset
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_revar (LPVOID ASic, LPCSTR AVaname, LPCSTR AOrgname, BOOL AInvalidate);
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

INT
SICXAPI
sic_duvar (LPVOID ASic, LPCSTR AVaname, LPCSTR AOrgname);
//
// Duplicate global or local variable
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic     : TSIC_Data structure offset
// -> AVaname  : variable dup name
// -> AOrgname : variable original name
// <- Result   : variable index or negative value on error
//

INT
SICXAPI
sic_exvar (LPVOID ASic, LPCSTR AVaname, LPCSTR AVanami);
//
// Exchange global or local variables
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// -> AVanami : variable name
// <- Result  : variable index or negative value on error
//

INT
SICXAPI
sic_invaf (LPVOID ASic, LPCSTR AFuname);
//
// Invalidate global or local function ( AFuname )
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// <- Result  : function index or negative value on error
//

INT
SICXAPI
sic_invac (LPVOID ASic, LPCSTR AConame);
//
// Invalidate global or local constant ( AConame )
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// <- Result  : constant index or negative value on error
//

INT
SICXAPI
sic_invav (LPVOID ASic, LPCSTR AVaname);
//
// Invalidate global or local variable ( AVaname )
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// <- Result  : variable index or negative value on error
//

VOID
SICXAPI
sic_patab (LPVOID ASic);
//
// Pack global or local tables ( remove deleted items, decrease and fix table size )
// Deal with global tables if ASic = null or ASic.?data = null
// !!! You can`t add any item to the packed table
//
// -> ASic : TSIC_Data structure offset
//

DWORD
SICXAPI
sic_pafut (LPVOID ASic);
//
// Pack global or local function table ( remove deleted items, decrease and fix table size )
// Deal with global table if ASic = null or ASic.fdata = null
// !!! You can`t add any item to the packed table
//
// -> ASic   : TSIC_Data structure offset
// <- Result : table item count or zero on error
//

DWORD
SICXAPI
sic_pacot (LPVOID ASic);
//
// Pack global or local constant table ( remove deleted items, decrease and fix table size )
// Deal with global table if ASic = null or ASic.cdata = null
// !!! You can`t add any item to the packed table
//
// -> ASic   : TSIC_Data structure offset
// <- Result : table item count or zero on error
//

DWORD
SICXAPI
sic_pavat (LPVOID ASic);
//
// Pack global or local variable table ( remove deleted items, decrease and fix table size )
// Deal with global table if ASic = null or ASic.vdata = null
// !!! You can`t add any item to the packed table
//
// -> ASic   : TSIC_Data structure offset
// <- Result : table item count or zero on error
//

LPVOID
SICXAPI
sic_gefut (LPVOID ASic);
//
// Get global or local function table offset
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : function table offset
//

DWORD
SICXAPI
sic_gefuc (LPVOID ASic);
//
// Get global or local function item count
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : function item count
//

INT
SICXAPI
sic_gefui (LPVOID ASic, INT AIndex, LPVOID AItem);
//
// Get global or local function item
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : function index
// <- AItem  : function item
// <- Result : function index or negative value on error
//

INT
SICXAPI
sic_gefun (LPVOID ASic, LPCSTR AFuname);
//
// Get global or local item ( AFuname ) index in function table
// Deal with global table if ASic = null or ASic.fdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AFuname : function name
// <- Result  : function index or negative value on error
//

LPVOID
SICXAPI
sic_gecot (LPVOID ASic);
//
// Get global or local constant table offset
// Deal with global table if ASic = null or ASic.cdata = nil
//
// -> ASic   : TSIC_Data structure offset
// <- Result : constant table offset
//

DWORD
SICXAPI
sic_gecoc (LPVOID ASic);
//
// Get global or local constant item count
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : constant item count
//

INT
SICXAPI
sic_gecoi (LPVOID ASic, INT AIndex, LPVOID AItem);
//
// Get global or local constant item
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : constant index
// <- AItem  : constant item
// <- Result : constant index or negative value on error
//

INT
SICXAPI
sic_gecon (LPVOID ASic, LPCSTR AConame);
//
// Get global or local item ( AConame ) index in constant table
// Deal with global table if ASic = null or ASic.cdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AConame : constant name
// <- Result  : constant index or negative value on error
//

LPVOID
SICXAPI
sic_gevat (LPVOID ASic);
//
// Get global or local variable table offset
// Deal with global table if ASic = null or ASic.vdata = nil
//
// -> ASic   : TSIC_Data structure offset
// <- Result : variable table offset
//

DWORD
SICXAPI
sic_gevac (LPVOID ASic);
//
// Get global or local variable item count
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : variable item count
//

INT
SICXAPI
sic_gevai (LPVOID ASic, INT AIndex, LPVOID AItem);
//
// Get global or local variable item
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : variable index
// <- AItem  : variable item
// <- Result : variable index or negative value on error
//

INT
SICXAPI
sic_gevar (LPVOID ASic, LPCSTR AVaname);
//
// Get global or local item ( AVaname ) index in variable table
// Deal with global table if ASic = null or ASic.vdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> AVaname : variable name
// <- Result  : variable index or negative value on error
//

LPVOID
SICXAPI
sic_gerut (LPVOID ASic);
//
// Get global or local runtime table offset
// Deal with global table if ASic = null or ASic.rdata = nil
//
// -> ASic   : TSIC_Data structure offset
// <- Result : runtime table offset
//

DWORD
SICXAPI
sic_geruc (LPVOID ASic);
//
// Get global or local runtime item count
// Deal with global table if ASic = null or ASic.rdata = null
//
// -> ASic   : TSIC_Data structure offset
// <- Result : runtime item count
//

INT
SICXAPI
sic_gerui (LPVOID ASic, INT AIndex, LPVOID AItem);
//
// Get global or local runtime item
// Deal with global table if ASic = null or ASic.rdata = null
//
// -> ASic   : TSIC_Data structure offset
// -> AIndex : runtime index
// <- AItem  : runtime item
// <- Result : runtime index or negative value on error
//

INT
SICXAPI
sic_gerun (LPVOID ASic, LPCSTR ARuname);
//
// Get global or local item ( ARuname ) index in runtime table
// Deal with global table if ASic = null or ASic.rdata = null
//
// -> ASic    : TSIC_Data structure offset
// -> ARuname : runtime name
// <- Result  : runtime index or negative value on error
//

DWORD
SICXAPI
sic_compile (LPVOID ASic, LPCSTR S, DWORD ASop);
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

DWORD
SICXAPI
sic_build (LPVOID ASic, LPCSTR S, DWORD ASop);
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

double
SICXAPI
sic_exec (LPVOID ASic, LPDWORD AError);
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

VOID
SICXAPI
sic_call (LPVOID ASic);
//
// Execute code
//
// -> ASic       : TSIC_Data structure offset
// <- ASic.value : result
//

double
SICXAPI
sic_cexec (LPVOID ASic, LPCSTR S, LPDWORD ASop, LPDWORD AError);
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

double
SICXAPI
sic_bexec (LPVOID ASic, LPCSTR S, LPDWORD ASop, LPDWORD AError);
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

double
SICXAPI
sic_scexec (LPCSTR S, LPDWORD ASop, LPDWORD AError);
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

double
SICXAPI
sic_sbexec (LPCSTR S, LPDWORD ASop, LPDWORD AError);
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

INT
SICXAPI
sic_va_count (VOID);
//
// Variable argument count
//
// <- Result : variable argument count
//

INT
SICXAPI
sic_inda (LPVOID code, LPVOID data, UINT8 x64);
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

UINT_PTR
SICXAPI
cpuseed(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    x64 : <- rax [0, 2^64-1]-interval
//    x32 : <- eax [0, 2^32-1]-interval
//

UINT64
SICXAPI
cpuseed64(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^64-1]-interval
//    x64 : <- rax
//    x32 : <- eax:edx
//

UINT32
SICXAPI
cpuseed32(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^32-1]-interval
//    <- eax
//

UINT16
SICXAPI
cpuseed16(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^16-1]-interval
//    <- ax
//

UINT_PTR
SICXAPI
cpurand(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    x64 : <- rax [0, 2^64-1]-interval
//    x32 : <- eax [0, 2^32-1]-interval
//

UINT64
SICXAPI
cpurand64(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^64-1]-interval
//    x64 : <- rax
//    x32 : <- eax:edx
//

UINT32
SICXAPI
cpurand32(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^32-1]-interval
//    <- eax
//

UINT16
SICXAPI
cpurand16(VOID);
//
// CPU random generator
//
// <- Result : random uint number
//    [0, 2^16-1]-interval
//    <- ax
//

double
SICXAPI
cpurandf(VOID);
//
// CPU random generator
//
// <- Result : random float number
//    [0,1)-interval (53-bit resolution)
//

double
SICXAPI
cpurandf2pi(VOID);
//
// CPU random generator
//
// <- Result : random float number
//    [0,2•pi)-interval (53-bit resolution)
//

UINT_PTR
SICXAPI
mt19937_igen (VOID);
//
// Mersenne Twister random generator
//
// <- Result : random uint number
//    x64 : <- rax [0, 2^64-1]-interval
//    x32 : <- eax [0, 2^32-1]-interval
//

double
SICXAPI
mt19937_fgen (VOID);
//
// Mersenne Twister random generator
//
// <- Result : random float number
//    [0,1)-interval (53-bit resolution)
//

double
SICXAPI
mt19937_fgen2pi (VOID);
//
// Mersenne Twister random generator
//
// <- Result : random float number 
//    [0,2•pi)-interval (53-bit resolution)
//

VOID
SICXAPI
mt19937_seed (UINT_PTR ASeed);
//
// Mersenne Twister seed by value
//
// -> ASeed : seed value
//

VOID
SICXAPI
mt19937_seeds (PUINT_PTR ASeeds, UINT_PTR ACount);
//
// Mersenne Twister seed by array
//
// -> ASeeds : pointer to seed values array
// -> ACount : seeds count
//

double
SICXAPI
sic_erf (double A);
//
// Error function
//

double
SICXAPI
sic_erfc (double A);
//
// Complementary error function
//

double
SICXAPI
sic_cdfnorm (double A);
//
// Normal distribution function
//

double
SICXAPI
sic_erfinv (double A);
//
// Inverse error function
//

double
SICXAPI
sic_erfcinv (double A);
//
// Inverse complementary error function
//

double
SICXAPI
sic_cdfnorminv (double A);
//
// Inverse of normal distribution function
//

double
SICXAPI
sic_lgamma (double A);
//
// Natural logarithm of the absolute value of gamma function
//

double
SICXAPI
sic_lgammas (double A, LPDWORD S);
//
// Natural logarithm of the absolute value and the sign of gamma function
// <- S - gamma function sign flag
//    0 : positive
//    1 : negative
//

double
SICXAPI
sic_tgamma (double A);
//
// Gamma function
//

double
SICXAPI
sic_rgamma (double A);
//
// Reciprocal gamma function
//

double
SICXAPI
sic_rtgamma (double A);
//
// Reciprocal gamma function
//

double
SICXAPI
sic_beta (double A, double B);
//
// Beta function
//

#endif // _SICX_H_
