
; FASM SOURCE FILE
; http://flatassembler.net

; external user defined functions for SICx32.DLL (EXAMPLE)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC.UDF:

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

; double zoom.. ( double value, double zoom )
; <- value*zoom

proc zoom32 c, value, value.HI, zoom, zoom.HI

        fld     qword [value]
        fmul    qword [zoom]
        ret
endp

proc zoom64, value, zoom

        mulsd   xmm0, xmm1
        ret
endp

; ------------------------------------------------------------------------------

; double izoom.. ( int z1, int z2, double value )
; <- value*z1*z2

proc izoom2x32 c, z1, z2, value, value.HI

        fld     qword [value]
        fimul   dword [z1]
        fimul   dword [z2]
        ret
endp

proc izoom2x64, z1, z2, value

        mov         [z1], rcx
        mov         [z2], rdx
        movsd       qword [value], xmm2

        cvtsi2sd    xmm0, qword [z1]
        mulsd       xmm0, qword [value]
        cvtsi2sd    xmm1, qword [z2]
        mulsd       xmm0, xmm1
        ret
endp

; ------------------------------------------------------------------------------

; double izoom.. ( int z1, double value1, int z2, double value1 )
; <- value1*z1 + value2*z2

proc izoom2x2x32 c, z1, value.1, value.1.HI, z2, value.2, value.2.HI

        fld     qword [value.1]
        fimul   dword [z1]
        fld     qword [value.2]
        fimul   dword [z2]
        faddp   st1, st0
        ret
endp

proc izoom2x2x64, z1, value.1, z2, value.2

        mov         [z1], rcx
        movsd       qword [value.1], xmm1
        mov         [z2], r8
        movsd       qword [value.2], xmm3

        cvtsi2sd    xmm0, qword [z1]
        mulsd       xmm0, qword [value.1]
        cvtsi2sd    xmm1, qword [z2]
        mulsd       xmm1, qword [value.2]
        addsd       xmm0, xmm1
        ret
endp

; ------------------------------------------------------------------------------

; double izoom.. ( int z1, int z2, int z3, double value )
; <- value*z1*z2*z3

proc izoom3x32 c, z1, z2, z3, value, value.HI

        fld     qword [value]
        fimul   dword [z1]
        fimul   dword [z2]
        fimul   dword [z3]
        ret
endp

proc izoom3x64, z1, z2, z3, value

        mov         [z1], rcx
        mov         [z2], rdx
        mov         [z3], r8
        movsd       qword [value], xmm3

        cvtsi2sd    xmm0, qword [z1]
        mulsd       xmm0, qword [value]
        cvtsi2sd    xmm1, qword [z2]
        mulsd       xmm0, xmm1
        cvtsi2sd    xmm1, qword [z3]
        mulsd       xmm0, xmm1
        ret
endp

; ------------------------------------------------------------------------------

; double izoom.. ( int z1, int z2, int z3, int z4, double value )
; <- value*z1*z2*z3*z4

proc izoom4x32 c, z1, z2, z3, z4, value, value.HI

        fld     qword [value]
        fimul   dword [z1]
        fimul   dword [z2]
        fimul   dword [z3]
        fimul   dword [z4]
        ret
endp

proc izoom4x64, z1, z2, z3, z4, value

        mov         [z1], rcx
        mov         [z2], rdx
        mov         [z3], r8
        mov         [z4], r9

        cvtsi2sd    xmm0, qword [z1]
        mulsd       xmm0, qword [value]
        cvtsi2sd    xmm1, qword [z2]
        mulsd       xmm0, xmm1
        cvtsi2sd    xmm1, qword [z3]
        mulsd       xmm0, xmm1
        cvtsi2sd    xmm1, qword [z4]
        mulsd       xmm0, xmm1
        ret
endp

; ------------------------------------------------------------------------------

section '.edata' export data readable

export  'SICx32F.DLL',\
        zoom32, 'zoom',\
        izoom2x32, 'izoom2x',\
        izoom2x2x32, 'izoom2x2x',\
        izoom3x32, 'izoom3x',\
        izoom4x32, 'izoom4x'

; ------------------------------------------------------------------------------

section '.reloc' fixups data readable discardable

if $=$$
  dd 0, 8 ; if there are no fixups, generate dummy entry
end if

; ------------------------------------------------------------------------------
