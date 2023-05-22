
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

SIC32rand:

; ------------------------------------------------------------------------------

; generates a random integer 64-bit seed number

$align 16
proc cpuseed64

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .RDA:
        rdseed  eax
        jnc    .RDA
   .RDD:
        rdseed  edx
        jnc    .RDD

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
        and     eax, 0xFFFF

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

   .RDA:
        rdrand  eax
        jnc    .RDA
   .RDD:
        rdrand  edx
        jnc    .RDD

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
        and     eax, 0xFFFF

        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,1)-interval (53-bit resolution)
;
; unsigned long a=genrand_int32()>>5, b=genrand_int32()>>6;
; return(a*67108864.0+b)*(1.0/9007199254740992.0);
;
; (a*(2^26) + b)*(2^(-53))

$align 16
proc cpurandf

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        call    cpurand64
        shr     eax, 5                          ; a
        shr     edx, 6                          ; b
        mov     [esp - 8], eax
        mov     [esp - 4], edx

        fild    dword [esp - 8]                 ; a
        fmul    qword [??.2p26]                 ; a*(2^26)
        fild    dword [esp - 4]                 ; b
        faddp                                   ; a*(2^26) + b
        fmul    qword [??.2m53]                 ; (a*(2^26) + b)*(2^(-53))

        ret
endp

; ------------------------------------------------------------------------------

; generates a random float number on [0,2•pi)-interval (53-bit resolution)
;
; unsigned long a=genrand_int32()>>5, b=genrand_int32()>>6;
; return(a*67108864.0+b)*(2.0*pi/9007199254740992.0);
;
; (a*(2^26) + b)*(2^(-53))*2*pi

$align 16
proc cpurandf2pi

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

        call    cpurand64
        shr     eax, 5                          ; a
        shr     edx, 6                          ; b
        mov     [esp - 8], eax
        mov     [esp - 4], edx

        fild    dword [esp - 8]                 ; a
        fmul    qword [??.2p26]                 ; a*(2^26)
        fild    dword [esp - 4]                 ; b
        faddp                                   ; a*(2^26) + b
        fmul    qword [??.2m53_2pi]             ; (a*(2^26) + b)*(2^(-53))*2*pi

        ret
endp

; ------------------------------------------------------------------------------
