
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; Delphi

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC:

; ------------------------------------------------------------------------------

format MS64 COFF

DEFINE  _COFF    TRUE
DEFINE   _X64    TRUE
DEFINE   _X32   FALSE
DEFINE   _VEX   FALSE
DEFINE  _EVEX   FALSE
DEFINE  _SSEX   FALSE
DEFINE  _SSE4.1 FALSE
DEFINE  _SSE3    TRUE
DEFINE  _SSE2    TRUE
DEFINE   _UDF    TRUE                           ; user-defined files

; ------------------------------------------------------------------------------

include 'SIC64I.INC'
$.define DEBUG_CODE

; ------------------------------------------------------------------------------

section '.code' code readable executable align 16
SIC_BOF_section_code:

; DLL ENTRY POINT
; reason : DLL_PROCESS_ATTACH
;          DLL_PROCESS_DETACH
;          DLL_THREAD_ATTACH
;          DLL_THREAD_DETACH
proc zentry hinstance, reason, reserved

;       mov     [hinstance], rcx
;       mov     [reason], rdx
;       mov     [reserved], r8
;       mov     [], r9

        mov     rax, TRUE
        ret
endp

include 'SIC64E.ASM'
include '..\xCommon\SICEX.ASM'

include 'SIC64IDA.ASM'
include 'SIC64B.ASM'
include 'SIC64C.ASM'
include 'SIC64OP.ASM'
include 'SIC64U.ASM'
include 'SIC64UC.ASM'
include 'SIC64UD.ASM'
include 'SIC64UF.ASM'
include 'SIC64Fu.ASM'
include 'SIC64Rand.ASM'
include 'SICmt64.ASM'

SIC_EOF_section_code:

; ------------------------------------------------------------------------------

section '.data' data readable writeable align 16
SIC_BOF_section_data:

include 'SIC64V.ASM'
include 'SICmt64V.ASM'
include '..\xCommon\SICC.ASM'
include '..\xCommon\SICF.ASM'
include '..\xCommon\SICIDA.ASM'
include '..\xCommon\SICFuCOs.ASM' ; '..\xCommon\SICFuCO.ASM'

SIC_EOF_section_data:

; ------------------------------------------------------------------------------

SIC_BOF_section_idata:

; IMPORT
include '..\xCommon\SICCOFFesD64.INC'

SIC_EOF_section_idata:

; ------------------------------------------------------------------------------

SIC_BOF_section_edata:

; DLL entry point
publics zentry, 'sic_zentry'

; EXPORT
include '..\xCommon\SICCOFFpsD64.INC'

SIC_EOF_section_edata:

; ------------------------------------------------------------------------------
