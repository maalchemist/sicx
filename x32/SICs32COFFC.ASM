
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; main project file (MS COFF format)
; Visual Studio

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

format MS   COFF

DEFINE  _COFF    TRUE
DEFINE   _X64   FALSE
DEFINE   _X32    TRUE
DEFINE   _VEX    TRUE
DEFINE  _EVEX    TRUE
DEFINE  _SSEX    TRUE
DEFINE  _SSE4.1  TRUE
DEFINE  _SSE3    TRUE
DEFINE  _SSE2    TRUE
DEFINE   _UDF    TRUE                           ; user-defined files

; ------------------------------------------------------------------------------

include 'SIC32I.INC'
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

        mov     eax, TRUE
        ret
endp

include 'SIC32E.ASM'
include '..\xCommon\SICEX.ASM'

include 'SIC32IDA.ASM'
include 'SIC32B.ASM'
include 'SIC32C.ASM'
include 'SIC32OP.ASM'
include 'SIC32U.ASM'
include 'SIC32UC.ASM'
include 'SIC32UD.ASM'
include 'SIC32UF.ASM'
include 'SIC32Fu.ASM'
include 'SIC32Rand.ASM'
include 'SICmt32.ASM'

SIC_EOF_section_code:

; ------------------------------------------------------------------------------

section '.data' data readable writeable align 16
SIC_BOF_section_data:

include 'SIC32V.ASM'
include 'SICmt32V.ASM'
include '..\xCommon\SICC.ASM'
include '..\xCommon\SICF.ASM'
include '..\xCommon\SICIDA.ASM'
include '..\xCommon\SICFuCOs.ASM' ; '..\xCommon\SICFuCO.ASM'

SIC_EOF_section_data:

; ------------------------------------------------------------------------------

SIC_BOF_section_idata:

; IMPORT
include '..\xCommon\SICCOFFesC32.INC'

SIC_EOF_section_idata:

; ------------------------------------------------------------------------------

SIC_BOF_section_edata:

; DLL entry point
publics zentry, 'sic_zentry'

; EXPORT
include '..\xCommon\SICCOFFpsC32.INC'

SIC_EOF_section_edata:

; ------------------------------------------------------------------------------
