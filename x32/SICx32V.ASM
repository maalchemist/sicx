
; FASM SOURCE FILE
; http://flatassembler.net

; external user defined variables for SICx32.DLL (EXAMPLE)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC.UDV:

; ------------------------------------------------------------------------------

format PE   DLL
entry zentry

include '%INCLUDE%\WIN32A.INC'

; ------------------------------------------------------------------------------

section '.code' code readable executable

proc zentry hinstance, reason, reserved

;       mov     [hinstance], rcx
;       mov     [reason], rdx
;       mov     [reserved], r8
;       mov     [], r9

        mov     eax, TRUE
        ret
endp

; ------------------------------------------------------------------------------

section '.data' data readable writeable

_02 dq 02.0
_10 dq 10.0

; ------------------------------------------------------------------------------

section '.edata' export data readable

export  'SICx32V.DLL',\
        _02, '_02',\
        _10, '_10'

; ------------------------------------------------------------------------------

section '.reloc' fixups data readable discardable

if $=$$
  dd 0, 8 ; if there are no fixups, generate dummy entry
end if

; ------------------------------------------------------------------------------
