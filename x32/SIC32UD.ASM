
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; debug utils

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_UD:

; ------------------------------------------------------------------------------

macro pushh {
        push    eax ecx edx ebx esi edi
}

; ------------------------------------------------------------------------------

macro poppp {
        pop     edi esi ebx edx ecx eax
}

; ------------------------------------------------------------------------------

; display string
proc display.string, s

;       mov     [s], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        pushh
        invoke  MessageBox, 0, [s], .caption, 0
   .return:
        poppp
        ret

       .caption db 'Display',0
endp ; display.string

; ------------------------------------------------------------------------------

; display integer value
proc display.int, i

    locals
       .buffer  rb 32
    endl

;       mov     [i], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        pushh
        lea     ecx, [.buffer]
        lea     eax, [i]
        cinvoke vsprintf, ecx, .format, eax
        lea     edx, [.buffer]
        invoke  MessageBox, 0, edx, .caption, 0
   .return:
        poppp
        ret

       .caption db 'Display',0
       .format  db '%d',0
endp ; display.int

; ------------------------------------------------------------------------------

; display hex integer value
proc display.hex, i

    locals
       .buffer  rb 32
    endl

;       mov     [i], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        pushh
        lea     ecx, [.buffer]
        lea     eax, [i]
        cinvoke vsprintf, ecx, .format, eax
        lea     edx, [.buffer]
        invoke  MessageBox, 0, edx, .caption, 0
   .return:
        poppp
        ret

       .caption db 'Display',0
       .format  db '0x%.8X',0
endp ; display.hex

; ------------------------------------------------------------------------------

; display double value
proc display.double, d, d.HI

    locals
       .buffer  rb 32
    endl

;       movsd   qword [d], xmm0
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        pushh
        lea     ecx, [.buffer]
        lea     eax, [d]
        cinvoke vsprintf, ecx, .format, eax
        lea     edx, [.buffer]
        invoke  MessageBox, 0, edx, .caption, 0
   .return:
        poppp
        ret

       .caption db 'Display',0
       .format  db '%.8g',0
endp ; display.double

; ------------------------------------------------------------------------------
