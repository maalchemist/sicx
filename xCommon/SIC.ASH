
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; header file

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; !!! This code doesn't work
;
; $ifdef _X64
;   r8q EQU r8
;   r9q EQU r9
;
;   xax EQU rax
;   xbx EQU rbx
;   xcx EQU rcx
;   xdx EQU rdx
;   xdi EQU rdi
;   xsi EQU rsi
;   xsp EQU rsp
;   xbp EQU rbp
; $else
;   xax EQU eax
;   xbx EQU ebx
;   xcx EQU ecx
;   xdx EQU edx
;   xdi EQU edi
;   xsi EQU esi
;   xsp EQU esp
;   xbp EQU ebp
; $end

; something equ 1
; if something eq 1
; else
; end if
; xdi
; ; xdi EQ xdi
; ; OK
;
; something equ 1
; if something eq 1
;  xdi equ rdi
; else
; end if
; xdi
; ; xdi EQ rdi
; ; OK
;
; something equ 1
; if something eq 1
;  xdi equ rdi
; else
;  xdi equ edi
; end if
; xdi
; ; xdi EQ edi
; ; ??? xdi NOT EQ rdi
;
; something equ 1
; if something eq 1
; else
;  xdi equ edi
; end if
; xdi
; ; xdi EQ edi
; ; ??? xdi NOT EQ xdi

; define something TRUE
; match =TRUE, something {xdi equ rdi}
; match =FALSE, something {xdi equ edi}
; xdi
; ; xdi EQ rdi
; ; OK
;
; define something TRUE
; match =FALSE, something {xdi equ edi}
; match =TRUE, something {xdi equ rdi}
; xdi
; ; xdi EQ rdi
; ; OK
;
; define something FALSE
; match =TRUE, something {xdi equ rdi}
; match =FALSE, something {xdi equ edi}
; xdi
; ; xdi EQ edi
; ; OK
;
; define something FALSE
; match =FALSE, something {xdi equ edi}
; match =TRUE, something {xdi equ rdi}
; xdi
; ; xdi EQ edi
; ; OK

; ------------------------------------------------------------------------------

sys_mem_dsize   = 0x00000100                    ; 256B : reserved bytes in T_sic_data.data segment for system use

mem_block_size  = 0x00010000                    ; 64K

fdata_size      = 2 * mem_block_size            ; 128K : function data segment size
fdata_count     = (fdata_size - sizeof.table.header) / sizeof.fitem
                                                ; maximum function count = 2047

cdata_size      = mem_block_size                ; 64K : constant data segment size
cdata_count     = (cdata_size - sizeof.table.header) / sizeof.citem
                                                ; maximum constant count = 1023

vdata_size      = mem_block_size                ; 64K : variable data segment size
vdata_count     = (vdata_size - sizeof.table.header) / sizeof.vitem
                                                ; maximum variable count = 1023

rdata_size      = mem_block_size                ; 64K : runtime data segment size
rdata_count     = (rdata_size - sizeof.table.header) / sizeof.citem
                                                ; maximum runtime count = 1023

; --------------------------------------

stack_size      = 5 * mem_block_size            ; 320K : stack array size
stack_count     = stack_size / sizeof.sitem     ; maximum token count = 20480

rpn_size        = 3 * mem_block_size            ; 192K : rpn array size
rpn_count       = rpn_size / sizeof.sitem - 1   ; maximum rpn item count = 12287

code_size       = 4 * mem_block_size            ; 256K : code segment size

; memory usage while building code
; rpn array build  [ stack (320K) ][ rpn (192K) ]
; code build       [ code   (??K) ][ rpn  (??K) ]
; realloc memory   [ code   (??K) ]

; ------------------------------------------------------------------------------

; SIC_OPT_FLAG_OPTIMIZATION
$ifdef _SSEX
CODE_MIN_SIZE_X32 = 7   ; minimum code size (x32)
                        ;  7 bytes - single built-in function with no arguments (zero)
                        ; 14 bytes - single constant (0)
                        ; 20 bytes - single user defined function with no arguments (random_s)
                        ; 21 bytes - single variable
$else
CODE_MIN_SIZE_X32 = 5   ; minimum code size (x32)
                        ;  5 bytes - single built-in function with no arguments (zero)
                        ;  9 bytes - single variable
                        ; 10 bytes - single user defined function with no arguments (random_s)
                        ; 13 bytes - single constant (0)
$end

; SIC_OPT_FLAG_OPTIMIZATION
$ifdef _SSEX
CODE_MIN_SIZE_X64 = 13  ; minimum code size (x64)
                        ; 13 bytes - single built-in function with no arguments (zero)
                        ; 18 bytes - single constant (0)
                        ; 25 bytes - single user defined function with no arguments (random_s)
                        ; 26 bytes - single variable
$else
CODE_MIN_SIZE_X64 = 11  ; minimum code size (x64)
                        ; 11 bytes - single built-in function with no arguments (zero)
                        ; 16 bytes - single constant (0)
                        ; 24 bytes - single variable
                        ; 35 bytes - single user defined function with no arguments (random_s)
$end

; ------------------------------------------------------------------------------

; compiler configuration flags (user-avalable)

; ------------------------------
; case sensitive compiler
; ------------------------------
SIC_CFG_FLAG_CASE_SENSITIVE     = 0x00000001 ; 00000000 00000000 00000000 00000001

; ------------------------------
; bypass user-defined functions
; SICx*.UDF
; ------------------------------
SIC_CFG_FLAG_NO_UDF             = 0x00000002 ; 00000000 00000000 00000000 00000010

; ------------------------------
; bypass user-defined constants
; SICx*.UDC
; ------------------------------
SIC_CFG_FLAG_NO_UDC             = 0x00000004 ; 00000000 00000000 00000000 00000100

; ------------------------------
; bypass user-defined variables
; SICx*.UDV
; ------------------------------
SIC_CFG_FLAG_NO_UDV             = 0x00000008 ; 00000000 00000000 00000000 00001000

; ------------------------------------------------------------------------------

; compiler default configuration flags

SIC_CFG_DEFAULT_X32 = 0
SIC_CFG_DEFAULT_X64 = 0

; ------------------------------------------------------------------------------

; compiler options flags (internal use)

; ------------------------------
; ...
; ------------------------------
SIC_OPT_FLAG_EXTERNAL_CALL      = 0x00800000 ; 00000000 10000000 00000000 00000000

; ------------------------------
; ...
; ------------------------------
SIC_OPT_FLAG_EXECUTE            = 0x00400000 ; 00000000 01000000 00000000 00000000
SIC_OPT_FLAG_NOT_EXECUTE        = not SIC_OPT_FLAG_EXECUTE

; ------------------------------
; ...
; ------------------------------
SIC_OPT_FLAG_SYSTEM_MEMORY      = 0x00200000 ; 00000000 00100000 00000000 00000000

; ------------------------------------------------------------------------------

; compiler options flags (user-avalable)

; ------------------------------
; code optimization
; ------------------------------
SIC_OPT_FLAG_OPTIMIZATION       = 0x00000001 ; 00000000 00000000 00000000 00000001

; ------------------------------
; stack frame
; ------------------------------
SIC_OPT_FLAG_STACK_FRAME        = 0x00000002 ; 00000000 00000000 00000000 00000010
SIC_OPT_FLAG_STACK.FRAME        = SIC_OPT_FLAG_STACK_FRAME

; ------------------------------
; build mode
; local variables
; ------------------------------
SIC_OPT_FLAG_LOCALS             = 0x00000004 ; 00000000 00000000 00000000 00000100

; ------------------------------
; mask all FP exceptions
; return FP exception flags in EAX
; use this option to avoid exception raising on FP errors
; ------------------------------
SIC_OPT_FLAG_FP_FRAME           = 0x00000008 ; 00000000 00000000 00000000 00001000
SIC_OPT_FLAG_FP.FRAME           = SIC_OPT_FLAG_FP_FRAME

; ------------------------------
; debug mode
; ------------------------------
SIC_OPT_FLAG_DEBUG              = 0x00000010 ; 00000000 00000000 00000000 00010000

; ------------------------------
; x64 CPU mode
; ------------------------------
SIC_OPT_FLAG_CPUX64             = 0x00000020 ; 00000000 00000000 00000000 00100000

; ------------------------------
; x32 CPU mode
; ------------------------------
SIC_OPT_FLAG_CPUX32             = 0x00000040 ; 00000000 00000000 00000000 01000000

; ------------------------------
; any CPU mode
; ------------------------------
SIC_OPT_FLAG_CPUX               = 0x00000080 ; 00000000 00000000 00000000 10000000

; ------------------------------
; data alignment
;
; default align values
; x32: 8-byte data alignment
; x64: 16-byte data alignment
; ------------------------------
SIC_OPT_FLAG_DALIGN             = 0x00000100 ; 00000000 00000000 00000001 00000000

; ------------------------------
; build mode
; disable code alignment
;
; default align values
; x32: 8-byte code alignment
; x64: 16-byte code alignment
; ------------------------------
SIC_OPT_FLAG_NO_CALIGN          = 0x00000200 ; 00000000 00000000 00000010 00000000
SIC_OPT_FLAG_NO.CALIGN          = SIC_OPT_FLAG_NO_CALIGN

; ------------------------------
; disable compile-time calculations
; of external functions
; ------------------------------
SIC_OPT_FLAG_NO_ECALC           = 0x00000400 ; 00000000 00000000 00000100 00000000
SIC_OPT_FLAG_NO.ECALC           = SIC_OPT_FLAG_NO_ECALC

; ------------------------------
; complex functions
; ------------------------------
SIC_OPT_FLAG_COMPLEX            = 0x00000800 ; 00000000 00000000 00001000 00000000

; ------------------------------
; compact mode
; line break as expression separator
; ------------------------------
SIC_OPT_FLAG_COMPACT            = 0x00001000 ; 00000000 00000000 00010000 00000000

; ------------------------------
; user-available flags mask
; ------------------------------
SIC_OPT_USER_FLAGS = SIC_OPT_FLAG_OPTIMIZATION or \
                     SIC_OPT_FLAG_STACK_FRAME  or \
                     SIC_OPT_FLAG_LOCALS       or \
                     SIC_OPT_FLAG_FP_FRAME     or \
                     SIC_OPT_FLAG_DEBUG        or \
                     SIC_OPT_FLAG_CPUX64       or \
                     SIC_OPT_FLAG_CPUX32       or \
                     SIC_OPT_FLAG_CPUX         or \
                     SIC_OPT_FLAG_DALIGN       or \
                     SIC_OPT_FLAG_NO_CALIGN    or \
                     SIC_OPT_FLAG_NO_ECALC     or \
                     SIC_OPT_FLAG_COMPLEX      or \
                     SIC_OPT_FLAG_COMPACT

; ------------------------------------------------------------------------------

; ------------------------------
; compiler default options x32
; ------------------------------
; code optimization
; stack frame
; local variables
; ------------------------------
SIC_OPT_DEFAULT_X32 = SIC_OPT_FLAG_OPTIMIZATION or \
                      SIC_OPT_FLAG_STACK_FRAME  or \
                      SIC_OPT_FLAG_LOCALS

; ------------------------------
; compiler default options x64
; ------------------------------
; code optimization
; stack frame
; local variables
; ------------------------------
SIC_OPT_DEFAULT_X64 = SIC_OPT_FLAG_OPTIMIZATION or \
                      SIC_OPT_FLAG_STACK_FRAME  or \
                      SIC_OPT_FLAG_LOCALS

; ------------------------------------------------------------------------------

; compiler error codes

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

; ------------------------------------------------------------------------------

; OBJ_PROCEDURE        = 01 ; - 0x01
  OBJ_ARG_COUNT        = 02 ; + 0x02

  OBJ_DOUBLE_ST0       = 11 ; + 0x0B
  OBJ_DOUBLE_SSE       = 12 ; + 0x0C
  OBJ_DOUBLE_CON       = 13 ; + 0x0D
  OBJ_DOUBLE_VAR       = 14 ; + 0x0E
; OBJ_DOUBLE_REF       = 15 ; - 0x0F
; OBJ_DOUBLE_IND       = 16 ; - 0x10
; OBJ_DOUBLE_OFF       = 17 ; - 0x11

  OBJ_INT_CON          = 21 ; + 0x15
  OBJ_INT_VAR          = 22 ; + 0x16
; OBJ_INT_REF          = 23 ; - 0x17
; OBJ_INT_IND          = 24 ; - 0x18
; OBJ_INT_OFF          = 25 ; - 0x19
; OBJ_INT_RAX_RSP      = 26 ; - 0x1A
  OBJ_INT_RSP_RAX      = 27 ; + 0x1B
; OBJ_INT_ESP_EAX_EDX  = 28 ; - 0x1C
; OBJ_INT_EAX_EDX_ESP  = 29 ; - 0x1D
; OBJ_INT_RAX_ST0      = 30 ; - 0x1E
; OBJ_INT_EAX_EDX_ST0  = 31 ; - 0x1F

  OBJ_STRING_CON       = 41 ; + 0x29
  OBJ_STRING_VAR       = 42 ; + 0x2A
; OBJ_STRING_REF       = 43 ; - 0x2B
; OBJ_STRING_IND       = 44 ; - 0x2C
; OBJ_STRING_OFF       = 45 ; - 0x2D

  OBJ_POINTER          = 51 ; + 0x33
  OBJ_PTR_CON          = 51 ; + 0x33
; OBJ_PTR_VAR          = 52 ; - 0x34
; OBJ_PTR_OFF          = 53 ; - 0x35

  OBJ_LOFFSET          = 54 ; + 0x36

; ------------------------------------------------------------------------------

RCODE_FLAG_JUMP      = 0x00000001 ; 00000000 00000000 00000000 00000001
RCODE_FLAG_RETN      = 0x00000002 ; 00000000 00000000 00000000 00000010
RCODE_FLAG_EXIT      = 0x00000004 ; 00000000 00000000 00000000 00000100
RCODE_FLAG_BOOL      = 0x00000008 ; 00000000 00000000 00000000 00001000
RCODE_FLAG_DECLARE   = 0x00000010 ; 00000000 00000000 00000000 00010000
RCODE_FLAG_ASSIGN    = 0x00000020 ; 00000000 00000000 00000000 00100000
RCODE_FLAG_ZERO_SIZE = 0x00000040 ; 00000000 00000000 00000000 01000000

; ------------------------------------------------------------------------------

; CPU flags

SIC_CPU_FLAG_SSE     = 0x00000001
SIC_CPU_FLAG_SSE2    = 0x00000002
SIC_CPU_FLAG_SSE3    = 0x00000004
SIC_CPU_FLAG_SSSE3   = 0x00000008
SIC_CPU_FLAG_SSE4.1  = 0x00000010
SIC_CPU_FLAG_SSE4.2  = 0x00000020
SIC_CPU_FLAG_AVX     = 0x00000040
SIC_CPU_FLAG_AVX2    = 0x00000080
SIC_CPU_FLAG_AVX512  = 0x00000100
SIC_CPU_FLAG_BMI1    = 0x00000200
SIC_CPU_FLAG_BMI2    = 0x00000400
SIC_CPU_FLAG_POPCNT  = 0x00000800
SIC_CPU_FLAG_LZCNT   = 0x00001000
SIC_CPU_FLAG_FMA     = 0x00002000
SIC_CPU_FLAG_ADX     = 0x00004000
SIC_CPU_FLAG_RDRAND  = 0x10000000
SIC_CPU_FLAG_RDSEED  = 0x20000000

; ------------------------------------------------------------------------------

; SIC config structure
macro struct_T_sic64_config
{
struct T_sic64_config
  cflags        dd ?            ; compiler flags
  memory        dq ?            ; memory block size

  cpu_flags     dd ?            ; CPU flags

  section_code  dd ?            ; size of .code section
  section_data  dd ?            ; size of .data section
  section_idata dd ?            ; size of .idata section
  section_edata dd ?            ; size of .edata section
  section_rsrc  dd ?            ; size of .rsrc section
  section_reloc dd ?            ; size of .reloc section

  fcode_size    dd ?            ; size of built-in functions

  fdata_size    dq ?            ; function data segment size
  fdata_count   dd ?            ; maximum function count
  cdata_size    dq ?            ; constant data segment size
  cdata_count   dd ?            ; maximum constant count
  vdata_size    dq ?            ; variable data segment size
  vdata_count   dd ?            ; maximum variable count
  rdata_size    dq ?            ; runtime data segment size
  rdata_count   dd ?            ; maximum runtime count
  stack_size    dq ?            ; stack array size
  stack_count   dd ?            ; maximum token count
  rpn_size      dq ?            ; rpn array size
  rpn_count     dd ?            ; maximum rpn item count
  code_size     dq ?            ; code segment size

  fitem_nsize   dd ?            ; maximum length of function name
  citem_nsize   dd ?            ; maximum length of constant name
  vitem_nsize   dd ?            ; maximum length of variable name

  uddata_scount dd ?            ; maximum section count in user-defined data files (SIC.UDF, SIC.UDV)
ends

struct T_sic_config T_sic64_config
ends
}

; SIC config structure
macro struct_T_sic32_config
{
struct T_sic32_config
  cflags        dd ?            ; compiler flags
  memory        dd ?            ; memory block size

  cpu_flags     dd ?            ; CPU flags

  section_code  dd ?            ; size of .code section
  section_data  dd ?            ; size of .data section
  section_idata dd ?            ; size of .idata section
  section_edata dd ?            ; size of .edata section
  section_rsrc  dd ?            ; size of .rsrc section
  section_reloc dd ?            ; size of .reloc section

  fcode_size    dd ?            ; size of built-in functions

  fdata_size    dd ?            ; function data segment size
  fdata_count   dd ?            ; maximum function count
  cdata_size    dd ?            ; constant data segment size
  cdata_count   dd ?            ; maximum constant count
  vdata_size    dd ?            ; variable data segment size
  vdata_count   dd ?            ; maximum variable count
  rdata_size    dd ?            ; runtime data segment size
  rdata_count   dd ?            ; maximum runtime count
  stack_size    dd ?            ; stack array size
  stack_count   dd ?            ; maximum token count
  rpn_size      dd ?            ; rpn array size
  rpn_count     dd ?            ; maximum rpn item count
  code_size     dd ?            ; code segment size

  fitem_nsize   dd ?            ; maximum length of function name
  citem_nsize   dd ?            ; maximum length of constant name
  vitem_nsize   dd ?            ; maximum length of variable name

  uddata_scount dd ?            ; maximum section count in user-defined data files (SIC.UDF, SIC.UDV)
ends

struct T_sic_config T_sic32_config
ends
}

$ifdef _X64
  struct_T_sic64_config
$else
  struct_T_sic32_config
$end

; ------------------------------------------------------------------------------

; SIC data structure
macro struct_T_sic64_data
{
struct T_sic64_data
  fdata   dq ?                  ; function data segment offset
  cdata   dq ?                  ; constant data segment offset
  vdata   dq ?                  ; variable data segment offset
  rdata   dq ?                  ; runtime data segment offset
  code    dq ?                  ; code segment offset
  data    dq ?                  ; data segment offset
  heap    dq ?                  ; heap segment offset
  entry   dq ?                  ; entry point
  param   dq ?                  ; parameter
  size    dd ?                  ; code size
  cspace  dd ?                  ; code space
  calign  dd ?                  ; code align
  dsize   dd ?                  ; data size
  dspace  dd ?                  ; data space
  dalign  dd ?                  ; data align
  hsize   dd ?                  ; heap size
  hspace  dd ?                  ; heap space
  halign  dd ?                  ; heap align
  coops   dd ?                  ; compiler options
  tokens  dd ?                  ; scanned tokens count
  rpn     dd ?                  ; rpn array item count
  fcount  dd ?                  ; functions count
  ccount  dd ?                  ; constants count
  vcount  dd ?                  ; variables count
  rcount  dd ?                  ; runtimes count
  ccurs   dd ?                  ; current string cursor
  pcurs   dd ?                  ; previous string cursor
  gdata   dq ?                  ; global data
  gcode   dd ?                  ; global code
  ecode   dd ?                  ; error code
  rcode   dd ?                  ; return code
  value   dq ?                  ; return value
ends

struct T_sic_data T_sic64_data
ends
}

; SIC data structure
macro struct_T_sic32_data
{
struct T_sic32_data
  fdata   dd ?                  ; function data segment offset
  cdata   dd ?                  ; constant data segment offset
  vdata   dd ?                  ; variable data segment offset
  rdata   dd ?                  ; runtime data segment offset
  code    dd ?                  ; code segment offset
  data    dd ?                  ; data segment offset
  heap    dd ?                  ; heap segment offset
  entry   dd ?                  ; entry point
  param   dd ?                  ; parameter
  size    dd ?                  ; code size
  cspace  dd ?                  ; code space
  calign  dd ?                  ; code align
  dsize   dd ?                  ; data size
  dspace  dd ?                  ; data space
  dalign  dd ?                  ; data align
  hsize   dd ?                  ; heap size
  hspace  dd ?                  ; heap space
  halign  dd ?                  ; heap align
  coops   dd ?                  ; compiler options
  tokens  dd ?                  ; scanned tokens count
  rpn     dd ?                  ; rpn array item count
  fcount  dd ?                  ; functions count
  ccount  dd ?                  ; constants count
  vcount  dd ?                  ; variables count
  rcount  dd ?                  ; runtimes count
  ccurs   dd ?                  ; current string cursor
  pcurs   dd ?                  ; previous string cursor
  gdata   dd ?                  ; global data
  gcode   dd ?                  ; global code
  ecode   dd ?                  ; error code
  rcode   dd ?                  ; return code
  value   dq ?                  ; return value
ends

struct T_sic_data T_sic32_data
ends
}

$ifdef _X64
  struct_T_sic64_data
$else
  struct_T_sic32_data
$end

; ------------------------------------------------------------------------------

; SIC compiler data structure
struct T_sic_codata
  csse3   dd ?                  ; SSE3 instructions count
  csse4.1 dd ?                  ; SSE4.1 instructions count
ends

; ------------------------------------------------------------------------------

; complex number

struct T_complex
  re dq ?                       ; real part
  im dq ?                       ; imaginary part
ends

; ------------------------------------------------------------------------------

; common table header
struct table.header
  icount dd ?                   ; item count
  mcount dd ?                   ; item max count
  tisize dd ?                   ; table item size
  tnsize dd ?                   ; table item name size
  titype dd ?                   ; table item type
                                ; = 1 - functions
                                ; = 2 - constants
                                ; = 3 - variables
  oooooo dd ?                   ; padding
ends

; ------------------------------------------------------------------------------

; function table item
sizeof.fitem = 64
fitem.nsize  = 50               ; maximum length of function name buffer

macro struct_fitem64
{
struct fitem64
  name   rb fitem.nsize         ; function name (zero terminated)
  retype dw ?                   ; function return type (INT16)
  acount dw ?                   ; function argument count (INT16)
  cosize dw ?                   ; function code size or flags (INT16)
  offset dq ?                   ; function offset
ends

fitem64.retype.base = 0
fitem64.acount.base = 2
fitem64.cosize.base = 4
fitem64.offset.base = 6

assert ~ sizeof.fitem64 <> sizeof.fitem
}

macro struct_fitem32
{
struct fitem32
  name   rb fitem.nsize         ; function name (zero terminated)
  retype dw ?                   ; function return type (INT16)
  acount dw ?                   ; function argument count (INT16)
  cosize dw ?                   ; function code size or flags (INT16)
  offset dd ?                   ; function offset
         dd ?
ends

fitem32.retype.base = 0
fitem32.acount.base = 2
fitem32.cosize.base = 4
fitem32.offset.base = 6

assert ~ sizeof.fitem32 <> sizeof.fitem
}

$ifdef _X64
  struct_fitem64
$else
  struct_fitem32
$end

; ------------------------------------------------------------------------------

; constant table item
sizeof.citem = 64
citem.nsize  = 44               ; maximum length of constant name buffer

macro struct_citem64
{
struct citem64
  name   rb citem.nsize         ; constant name (zero terminated)
  codata dq ?                   ; constant data
  cotype dw ?                   ; constant type
  datype dw ?                   ; constant data type
 union
  value  dq ?                   ; constant value
  offset dq ?
 ends
ends

citem64.codata.base    = 0
citem64.codata.LO.base = 0
citem64.codata.HI.base = 4
citem64.cotype.base    = 8
citem64.datype.base    = 10
citem64.value.base     = 12
citem64.value.LO.base  = 12
citem64.value.HI.base  = 16
citem64.offset.base    = 12
citem64.offset.LO.base = 12
citem64.offset.HI.base = 16

assert ~ sizeof.citem64 <> sizeof.citem
}

macro struct_citem32
{
struct citem32
  name   rb citem.nsize         ; constant name (zero terminated)
  codata dq ?                   ; constant data
  cotype dw ?                   ; constant type
  datype dw ?                   ; constant data type
 union
  value  dq ?                   ; constant value
  offset dd ?
 ends
ends

citem32.codata.base    = 0
citem32.codata.LO.base = 0
citem32.codata.HI.base = 4
citem32.cotype.base    = 8
citem32.datype.base    = 10
citem32.value.base     = 12
citem32.value.LO.base  = 12
citem32.value.HI.base  = 16
citem32.offset.base    = 12
citem32.offset.LO.base = 12
citem32.offset.HI.base = 16

assert ~ sizeof.citem32 <> sizeof.citem
}

$ifdef _X64
  struct_citem64
$else
  struct_citem32
$end

; ------------------------------------------------------------------------------

; variable table item
sizeof.vitem = 64
vitem.nsize  = 44               ; maximum length of variable name buffer

macro struct_vitem64
{
struct vitem64
  name   rb vitem.nsize         ; variable name (zero terminated)
  vadata dq ?                   ; variable data
  vatype dw ?                   ; variable type
  datype dw ?                   ; variable data type
  offset dq ?                   ; variable offset
ends

vitem64.vadata.base    = 0
vitem64.vadata.LO.base = 0
vitem64.vadata.HI.base = 4
vitem64.vatype.base    = 8
vitem64.datype.base    = 10
vitem64.offset.base    = 12
vitem64.offset.LO.base = 12
vitem64.offset.HI.base = 16

assert ~ sizeof.vitem64 <> sizeof.vitem
}

macro struct_vitem32
{
struct vitem32
  name   rb vitem.nsize         ; variable name (zero terminated)
  vadata dq ?                   ; variable data
  vatype dw ?                   ; variable type
  datype dw ?                   ; variable data type
  offset dd ?                   ; variable offset
         dd ?
ends

vitem32.vadata.base    = 0
vitem32.vadata.LO.base = 0
vitem32.vadata.HI.base = 4
vitem32.vatype.base    = 8
vitem32.datype.base    = 10
vitem32.offset.base    = 12
vitem32.offset.LO.base = 12
vitem32.offset.HI.base = 16

assert ~ sizeof.vitem32 <> sizeof.vitem
}

$ifdef _X64
  struct_vitem64
$else
  struct_vitem32
$end

; ------------------------------------------------------------------------------

; common table item
sizeof.xitem = 64
xitem.nsize  = 44               ; maximum length of name buffer

macro struct_xitem64
{
struct xitem64
  name  rb xitem.nsize          ; item name (zero terminated)
  idata dq ?                    ; item data
  itype dw ?                    ; item type
  dtype dw ?                    ; item data type
 union
  value dq ?                    ; item value
 struct
  va.lo dd ?                    ; item value LO
  va.hi dd ?                    ; item value HI
 ends
 ends
ends

assert ~ sizeof.xitem64 <> sizeof.xitem
assert ~ xitem64.idata <> citem64.codata
assert ~ xitem64.idata <> vitem64.vadata
assert ~ xitem64.itype <> citem64.cotype
assert ~ xitem64.itype <> vitem64.vatype
assert ~ xitem64.dtype <> citem64.datype
assert ~ xitem64.dtype <> vitem64.datype
assert ~ xitem64.value <> citem64.offset
assert ~ xitem64.value <> vitem64.offset
}

macro struct_xitem32
{
struct xitem32
  name  rb xitem.nsize          ; item name (zero terminated)
  idata dq ?                    ; item data
  itype dw ?                    ; item type
  dtype dw ?                    ; item data type
 union
  value dq ?                    ; item value
 struct
  va.lo dd ?                    ; item value LO
  va.hi dd ?                    ; item value HI
 ends
 ends
ends

assert ~ sizeof.xitem32 <> sizeof.xitem
assert ~ xitem32.idata <> citem32.codata
assert ~ xitem32.idata <> vitem32.vadata
assert ~ xitem32.itype <> citem32.cotype
assert ~ xitem32.itype <> vitem32.vatype
assert ~ xitem32.dtype <> citem32.datype
assert ~ xitem32.dtype <> vitem32.datype
assert ~ xitem32.value <> citem32.offset
assert ~ xitem32.value <> vitem32.offset
}

$ifdef _X64
  struct_xitem64
$else
  struct_xitem32
$end

; ------------------------------------------------------------------------------

sizeof.sitem = 16

; stack item
macro struct_sitem64
{
struct sitem64
  ItemType  dw ?                ;  item type
                                ;  0  - empty item
                                ; '!' - invalid item
                                ; '?' - invalid item
                                ; '(' - bra
                                ; ')' - ket
                                ; ',' - separator
                                ; 'c' - constant
                                ; 'v' - variable
                                ; 'r' - run-time variable
                                ; 'f' - function
                                ; 'F' - function
                                ; 'A' - function (argument filter)
 union
  DataSize  dd ?                ; data size
 struct
  ArgCount  dw ?                ; function : argument count
  ReType    dw ?                ; function : return type
 ends
 ends
 union
 union
  Priority  dw ?                ; function : operation priority
  OPriority db ?
 ends
  DataType  dw ?                ; variable : 'f'  - double float
                                ;            'i'  - integer
                                ;            's'  - string
                                ;            'p'  - pointer
                                ;            'o'  - offset
                                ;            'a'  - address
                                ; constant : 'f'  - double float
                                ;            'i'  - integer
                                ;            's'  - string
                                ;            'p'  - pointer
                                ;            'o'  - offset
                                ;            'f1' - offset of 1 double float
                                ;            'f2' - offset of 2 double floats
                                ;            'f3' - offset of 3 double floats
                                ;            'f4' - offset of 4 double floats
                                ;            'i1' - offset of 1 integer
                                ;            'i2' - offset of 2 integers
                                ;            'i3' - offset of 3 integers
                                ;            'i4' - offset of 4 integers
                                ;            's1' - offset of 1 string
 ends
 union
  Data64    dq ?                ; 64-bit data
  Data32    dd ?                ; 32-bit data
  Offset    dq ?                ; offset
  Param     dq ?                ; function : table item offset
                                ; variable : offset
                                ; constant : value
                                ; string   : offset
 ends
ends

assert ~ sizeof.sitem64 <> sizeof.sitem
}

; stack item
macro struct_sitem32
{
struct sitem32
  ItemType  dw ?                ;  item type
                                ;  0  - empty item
                                ; '!' - invalid item
                                ; '?' - invalid item
                                ; '(' - bra
                                ; ')' - ket
                                ; ',' - separator
                                ; 'c' - constant
                                ; 'v' - variable
                                ; 'r' - run-time variable
                                ; 'f' - function
                                ; 'F' - function
                                ; 'A' - function (argument filter)
 union
  DataSize  dd ?                ; data size
 struct
  ArgCount  dw ?                ; function : argument count
  ReType    dw ?                ; function : return type
 ends
 ends
 union
 union
  Priority  dw ?                ; function : operation priority
  OPriority db ?
 ends
  DataType  dw ?                ; variable : 'f'  - double float
                                ;            'i'  - integer
                                ;            's'  - string
                                ;            'p'  - pointer
                                ;            'o'  - offset
                                ;            'a'  - address
                                ; constant : 'f'  - double float
                                ;            'i'  - integer
                                ;            's'  - string
                                ;            'p'  - pointer
                                ;            'o'  - offset
                                ;            'f1' - offset of 1 double float
                                ;            'f2' - offset of 2 double floats
                                ;            'f3' - offset of 3 double floats
                                ;            'f4' - offset of 4 double floats
                                ;            'i1' - offset of 1 integer
                                ;            'i2' - offset of 2 integers
                                ;            'i3' - offset of 3 integers
                                ;            'i4' - offset of 4 integers
                                ;            's1' - offset of 1 string
 ends
 union
  Data64    dq ?                ; 64-bit data
  Data32    dd ?                ; 32-bit data
  Offset    dd ?                ; offset
 struct
  Param     dd ?                ; function : table item offset
  Param.HI  dd ?                ; variable : offset
                                ; constant : value
                                ; string   : offset
 ends
 ends
ends

assert ~ sizeof.sitem32 <> sizeof.sitem
}

$ifdef _X64
  struct_sitem64
$else
  struct_sitem32
$end

; ------------------------------------------------------------------------------
