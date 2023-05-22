unit SICxTypes;

// SICx.DLL types

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
  Windows, SICxDefs;

type
  // SIC config structure

  {$EXTERNALSYM PSIC_Config64}
  PSIC_Config64 = ^TSIC_Config64;
  {$EXTERNALSYM TSIC_Config64}
  TSIC_Config64 = packed record
    cflags        : UInt32;         // Compiler flags
    memory        : UInt64;         // Memory block size

    cpu_flags     : UInt32;         // CPU flags

    section_code  : UInt32;         // Size of .code section
    section_data  : UInt32;         // Size of .data section
    section_idata : UInt32;         // Size of .idata section
    section_edata : UInt32;         // Size of .edata section
    section_rsrc  : UInt32;         // Size of .rsrc section
    section_reloc : UInt32;         // Size of .reloc section

    fcode_size    : UInt32;         // Size of built-in functions

    fdata_size    : UInt64;         // Function data segment size
    fdata_count   : UInt32;         // Maximum function count
    cdata_size    : UInt64;         // Constant data segment size
    cdata_count   : UInt32;         // Maximum constant count
    vdata_size    : UInt64;         // Variable data segment size
    vdata_count   : UInt32;         // Maximum variable count
    rdata_size    : UInt64;         // Runtime data segment size
    rdata_count   : UInt32;         // Maximum runtime count
    stack_size    : UInt64;         // Stack array size
    stack_count   : UInt32;         // Maximum token count
    rpn_size      : UInt64;         // Rpn array size
    rpn_count     : UInt32;         // Maximum rpn item count
    code_size     : UInt64;         // Code segment size

    fitem_nsize   : UInt32;         // Maximum length of function name
    citem_nsize   : UInt32;         // Maximum length of constant name
    vitem_nsize   : UInt32;         // Maximum length of variable name

    uddata_scount : UInt32;         // Maximum section count in user-defined data files (SIC.UDF, SIC.UDV)
  end;

  {$EXTERNALSYM PSIC_Config32}
  PSIC_Config32 = ^TSIC_Config32;
  {$EXTERNALSYM TSIC_Config32}
  TSIC_Config32 = packed record
    cflags        : UInt32;         // Compiler flags
    memory        : UInt32;         // Memory block size

    cpu_flags     : UInt32;         // CPU flags

    section_code  : UInt32;         // Size of .code section
    section_data  : UInt32;         // Size of .data section
    section_idata : UInt32;         // Size of .idata section
    section_edata : UInt32;         // Size of .edata section
    section_rsrc  : UInt32;         // Size of .rsrc section
    section_reloc : UInt32;         // Size of .reloc section

    fcode_size    : UInt32;         // Size of built-in functions

    fdata_size    : UInt32;         // Function data segment size
    fdata_count   : UInt32;         // Maximum function count
    cdata_size    : UInt32;         // Constant data segment size
    cdata_count   : UInt32;         // Maximum constant count
    vdata_size    : UInt32;         // Variable data segment size
    vdata_count   : UInt32;         // Maximum variable count
    rdata_size    : UInt32;         // Runtime data segment size
    rdata_count   : UInt32;         // Maximum runtime count
    stack_size    : UInt32;         // Stack array size
    stack_count   : UInt32;         // Maximum token count
    rpn_size      : UInt32;         // Rpn array size
    rpn_count     : UInt32;         // Maximum rpn item count
    code_size     : UInt32;         // Code segment size

    fitem_nsize   : UInt32;         // Maximum length of function name
    citem_nsize   : UInt32;         // Maximum length of constant name
    vitem_nsize   : UInt32;         // Maximum length of variable name

    uddata_scount : UInt32;         // Maximum section count in user-defined data files (SIC.UDF, SIC.UDV)
  end;

  {$EXTERNALSYM PSIC_Config}
  PSIC_Config = ^TSIC_Config;
  {$IFDEF CPUX64}
  {$EXTERNALSYM TSIC_Config}
  TSIC_Config = TSIC_Config64;
  {$ELSE}
  {$EXTERNALSYM TSIC_Config}
  TSIC_Config = TSIC_Config32;
  {$ENDIF}

type
  // SIC data structure

  {$EXTERNALSYM PSIC_Data64}
  PSIC_Data64 = ^TSIC_Data64;
  {$EXTERNALSYM TSIC_Data64}
  TSIC_Data64 = packed record
    fdata   : UInt64;               // Function data segment offset
    cdata   : UInt64;               // Constant data segment offset
    vdata   : UInt64;               // Variable data segment offset
    rdata   : UInt64;               // Runtime data segment offset
    code    : UInt64;               // Code segment offset
    data    : UInt64;               // Data segment offset
    heap    : UInt64;               // Heap segment offset
    entry   : UInt64;               // Entry point
    param   : UInt64;               // Parameter
    size    : UInt32;               // Code size
    cspace  : UInt32;               // Code space
    calign  : UInt32;               // Code align
    dsize   : UInt32;               // Data size
    dspace  : UInt32;               // Data space
    dalign  : UInt32;               // Data align
    hsize   : UInt32;               // Heap size
    hspace  : UInt32;               // Heap space
    halign  : UInt32;               // Heap align
    coops   : UInt32;               // Compiler options
    tokens  : UInt32;               // Scanned tokens count
    rpn     : UInt32;               // Rpn array item count
    fcount  : UInt32;               // Functions count
    ccount  : UInt32;               // Constants count
    vcount  : UInt32;               // Variables count
    rcount  : UInt32;               // Runtimes count
    ccurs   : UInt32;               // Current string cursor
    pcurs   : UInt32;               // Previous string cursor
    gdata   : UInt64;               // Global data
    gcode   : UInt32;               // Global code
    ecode   : UInt32;               // Error code
    rcode   : UInt32;               // Return code
    value   : Double;               // Return value
  end;

  {$EXTERNALSYM PSIC_Data32}
  PSIC_Data32 = ^TSIC_Data32;
  {$EXTERNALSYM TSIC_Data32}
  TSIC_Data32 = packed record
    fdata   : UInt32;               // Function data segment offset
    cdata   : UInt32;               // Constant data segment offset
    vdata   : UInt32;               // Variable data segment offset
    rdata   : UInt32;               // Runtime data segment offset
    code    : UInt32;               // Code segment offset
    data    : UInt32;               // Data segment offset
    heap    : UInt32;               // Heap segment offset
    entry   : UInt32;               // Entry point
    param   : UInt32;               // Parameter
    size    : UInt32;               // Code size
    cspace  : UInt32;               // Code space
    calign  : UInt32;               // Code align
    dsize   : UInt32;               // Data size
    dspace  : UInt32;               // Data space
    dalign  : UInt32;               // Data align
    hsize   : UInt32;               // Heap size
    hspace  : UInt32;               // Heap space
    halign  : UInt32;               // Heap align
    coops   : UInt32;               // Compiler options
    tokens  : UInt32;               // Scanned tokens count
    rpn     : UInt32;               // Rpn array item count
    fcount  : UInt32;               // Functions count
    ccount  : UInt32;               // Constants count
    vcount  : UInt32;               // Variables count
    rcount  : UInt32;               // Runtimes count
    ccurs   : UInt32;               // Current string cursor
    pcurs   : UInt32;               // Previous string cursor
    gdata   : UInt32;               // Global data
    gcode   : UInt32;               // Global code
    ecode   : UInt32;               // Error code
    rcode   : UInt32;               // Return code
    value   : Double;               // Return value
  end;

  {$IFDEF CPUX64}
  {$EXTERNALSYM PSIC_Data}
  PSIC_Data = PSIC_Data64;
  {$EXTERNALSYM TSIC_Data}
  TSIC_Data = TSIC_Data64;
  {$ELSE}
  {$EXTERNALSYM PSIC_Data}
  PSIC_Data = PSIC_Data32;
  {$EXTERNALSYM TSIC_Data}
  TSIC_Data = TSIC_Data32;
  {$ENDIF}

type
  // Common table header
  {$EXTERNALSYM PSIC_TableHeader}
  PSIC_TableHeader = ^TSIC_TableHeader;
  {$EXTERNALSYM TSIC_TableHeader}
  TSIC_TableHeader = packed record
    icount : Int32;                 // Item count
    mcount : Int32;                 // Item max count
    tisize : Int32;                 // Table item size
    tnsize : Int32;                 // Table item name size
    titype : Int32;                 // Table item type
                                    // = 1 - functions
                                    // = 2 - constants
                                    // = 3 - variables
    oooooo : Int32;                 // Padding
  end;

type
  // Function name
  {$EXTERNALSYM PSIC_FunName}
  PSIC_FunName = ^TSIC_FunName;
  {$EXTERNALSYM TSIC_FunName}
  TSIC_FunName = array [0..SIC_FunNameSize-1] of AnsiChar;

  // Constant name
  {$EXTERNALSYM PSIC_ConName}
  PSIC_ConName = ^TSIC_ConName;
  {$EXTERNALSYM TSIC_ConName}
  TSIC_ConName = array [0..SIC_ConNameSize-1] of AnsiChar;

  // Variable name
  {$EXTERNALSYM PSIC_VarName}
  PSIC_VarName = ^TSIC_VarName;
  {$EXTERNALSYM TSIC_VarName}
  TSIC_VarName = array [0..SIC_VarNameSize-1] of AnsiChar;

type
  // Function table item
  {$EXTERNALSYM PSIC_FunItem}
  PSIC_FunItem = ^TSIC_FunItem;
  {$EXTERNALSYM TSIC_FunItem}
  TSIC_FunItem = packed record
    name   : TSIC_FunName;          // Function name (zero terminated)
    retype : Int16;                 // Function return type
    acount : Int16;                 // Function argument count
    cosize : Int16;                 // Function code size or flags
    offset : UInt64;                // Function offset
  end;

  // Function table items
  {$EXTERNALSYM PSIC_FunItems}
  PSIC_FunItems = ^TSIC_FunItems;
  {$EXTERNALSYM TSIC_FunItems}
  TSIC_FunItems = array [0..0] of TSIC_FunItem;

  // Function table
  {$EXTERNALSYM PSIC_FunTable}
  PSIC_FunTable = ^TSIC_FunTable;
  {$EXTERNALSYM TSIC_FunTable}
  TSIC_FunTable = packed record
    header : TSIC_TableHeader;      // Function table header
    items  : TSIC_FunItems;         // Function item list
  end;

type
  // Constant table item
  {$EXTERNALSYM PSIC_ConItem}
  PSIC_ConItem = ^TSIC_ConItem;
  {$EXTERNALSYM TSIC_ConItem}
  TSIC_ConItem = packed record
    name   : TSIC_ConName;          // Constant name (zero terminated)
    codata : UInt64;                // Constant data
    cotype : Int16;                 // Constant type
    datype : Int16;                 // Constant data type
    value  : Double;                // Constant value
  end;

  // Constant table items
  {$EXTERNALSYM PSIC_ConItems}
  PSIC_ConItems = ^TSIC_ConItems;
  {$EXTERNALSYM TSIC_ConItems}
  TSIC_ConItems = array [0..0] of TSIC_ConItem;

  // Constant table
  {$EXTERNALSYM PSIC_ConTable}
  PSIC_ConTable = ^TSIC_ConTable;
  {$EXTERNALSYM TSIC_ConTable}
  TSIC_ConTable = packed record
    header : TSIC_TableHeader;      // Constant table header
    items  : TSIC_ConItems;         // Constant item list
  end;

type
  // Variable table item
  {$EXTERNALSYM PSIC_VarItem}
  PSIC_VarItem = ^TSIC_VarItem;
  {$EXTERNALSYM TSIC_VarItem}
  TSIC_VarItem = packed record
    name   : TSIC_VarName;          // Variable name (zero terminated)
    vadata : UInt64;                // Variable data
    vatype : Int16;                 // Variable type
    datype : Int16;                 // Variable data type
    offset : UInt64;                // Variable offset
  end;

  // Variable table items
  {$EXTERNALSYM PSIC_VarItems}
  PSIC_VarItems = ^TSIC_VarItems;
  {$EXTERNALSYM TSIC_VarItems}
  TSIC_VarItems = array [0..0] of TSIC_VarItem;

  // Variable table
  {$EXTERNALSYM PSIC_VarTable}
  PSIC_VarTable = ^TSIC_VarTable;
  {$EXTERNALSYM TSIC_VarTable}
  TSIC_VarTable = packed record
    header : TSIC_TableHeader;      // Variable table header
    items  : TSIC_VarItems;         // Variable item list
  end;

type
  // Complex number
  {$EXTERNALSYM PSIC_IDAData}
  PSIC_Complex = ^TSIC_Complex;
  {$EXTERNALSYM TSIC_IDAData}
  TSIC_Complex = packed record
    re : Double;                    // Real part
    im : Double;                    // Imaginary part
  end;

type
  // IDA data
  {$EXTERNALSYM PSIC_IDAData}
  PSIC_IDAData = ^TSIC_IDAData;
  {$EXTERNALSYM TSIC_IDAData}
  TSIC_IDAData = packed record
    instr_size    : Byte;
    flags         : DWORD;
    prefix_size   : Byte;
    rex           : Byte;
    prex_size     : Byte;           // VEX/EVEX prefix size
    prex_0        : Byte;           // VEX.2:C5H VEX.3:C4H EVEX:62H
    prex_1        : Byte;
    prex_2        : Byte;
    prex_3        : Byte;
    modrm         : Byte;
    sib           : Byte;
    opcode_offset : Byte;
    opcode_size   : Byte;
    disp_offset   : Byte;
    disp_size     : Byte;
    imm_offset    : Byte;
    imm_size      : Byte;
  end;

implementation

end.

