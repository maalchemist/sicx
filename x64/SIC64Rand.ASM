
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; random numbers functions

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC64rand:

; ------------------------------------------------------------------------------

; generates a random integer 64-bit seed number

$align 16
proc cpuseed64

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RD:
        rdseed  rax
        jnc    .RD

        ret
endp

; ------------------------------------------------------------------------------

; generates a random integer 32-bit seed number

$align 16
proc cpuseed32

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RD:
        rdseed  eax
        jnc    .RD
;       and     rax, 0xFFFFFFFF
        mov     rdx, 0xFFFFFFFF
        and     rax, rdx

        ret
endp

; ------------------------------------------------------------------------------

; generates a random integer 16-bit seed number

$align 16
proc cpuseed16

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RD:
        rdseed  ax
        jnc    .RD
        and     rax, 0xFFFF

        ret
endp

; ------------------------------------------------------------------------------

; generates a random integer 64-bit number

$align 16
proc cpurand64

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RD:
        rdrand  rax
        jnc    .RD

        ret
endp

; ------------------------------------------------------------------------------

; generates a random integer 32-bit number

$align 16
proc cpurand32

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RD:
        rdrand  eax
        jnc    .RD
;       and     rax, 0xFFFFFFFF
        mov     rdx, 0xFFFFFFFF
        and     rax, rdx

        ret
endp

; ------------------------------------------------------------------------------

; generates a random integer 16-bit number

$align 16
proc cpurand16

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RD:
        rdrand  ax
        jnc    .RD
        and     rax, 0xFFFF

        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,1)-interval (53-bit resolution)
;
; return (genrand64_int64() >> 11) * (1.0/9007199254740992.0);
;
; a*(2^(-53))

$align 16
proc cpurandf

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        call    cpurand64
        shr     rax, 11                         ; a
       cvtsi2sd xmm0, rax
        mulsd   xmm0, [??.2m53]                 ; a*(2^(-53))

        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,2•pi)-interval (53-bit resolution)
;
; return (genrand64_int64() >> 11) * (2.0*pi/9007199254740992.0);
;
; a*(2^(-53))*2*pi

$align 16
proc cpurandf2pi

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        call    cpurand64
        shr     rax, 11                         ; a
       cvtsi2sd xmm0, rax
        mulsd   xmm0, [??.2m53_2pi]             ; a*(2^(-53))*2*pi

        ret
endp

; ------------------------------------------------------------------------------
