
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (byte functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; byte swap
; integer bswap ( integer x )
; return 32-bit result in eax
; x = esp

$usprocf @@bswap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        bswap   eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; byte swap
; integer b4swap ( integer x )
; return 32-bit result in eax
; x = esp

$usprocf @@b4swap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
;       xor     edx, edx                        ; rdx = 0
;       dec     edx                             ; rdx = 00000000FFFFFFFF
;       and     rax, rdx                        ; rax = 00000000********
        bswap   eax
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; byte swap
; integer b2swap ( integer x )
; return 16-bit result in eax
; x = esp

$usprocf @@b2swap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        and     eax, 0x0000FFFF
        ror     ax, 8
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; bit swap
; integer bitswap ( integer x )
; return 32-bit result in eax
; x = esp

$usprocf @@bitswap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        mov     ecx, eax                        ; ecx = x
        xor     eax, eax
        xor     edx, edx
        inc     edx                             ; edx = .... 0001
        ror     edx, 1                          ; edx = 1000 ....
   .LOOP:
        shr     ecx, 1
        jnc     @F
        or      eax, edx
    @@:
        shr     edx, 1
        jnc    .LOOP
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit swap
; integer bit32swap ( integer x )
; return 32-bit result in eax
; x = esp

$usprocf @@bit32swap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        mov     ecx, eax                        ; ecx = x
        xor     eax, eax
        xor     edx, edx
        inc     edx                             ; edx = .... 0001
        ror     edx, 1                          ; edx = 1000 ....
   .LOOP:
        shr     ecx, 1
        jnc     @F
        or      eax, edx
    @@:
        shr     edx, 1
        jnc    .LOOP
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit swap
; integer bit16swap ( integer x )
; return 16-bit result in eax
; x = esp

$usprocf @@bit16swap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        mov     ecx, eax                        ; ecx = x
        xor     eax, eax
        xor     edx, edx
        inc     edx                             ; dx = .... 0001
        ror     dx, 1                           ; dx = 1000 ....
   .LOOP:
        shr     cx, 1
        jnc     @F
        or      ax, dx
    @@:
        shr     dx, 1
        jnc    .LOOP
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; bit swap
; integer bit8swap ( integer x )
; return 8-bit result in eax
; x = esp

$usprocf @@bit8swap

        mov     eax, dword [esp]                ; eax = x integer value
   .enter:
        mov     ecx, eax                        ; ecx = x
        xor     eax, eax
        xor     edx, edx
        inc     edx                             ; dl = .... 0001
        ror     dl, 1                           ; dl = 1000 ....
   .LOOP:
        shr     cl, 1
        jnc     @F
        or      al, dl
    @@:
        shr     dl, 1
        jnc    .LOOP
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
