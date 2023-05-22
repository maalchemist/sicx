
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number boolean functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; equal
; z1 = a + i•b
; z2 = c + i•d
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : (a=c) and (b=d)
; 0 : otherwise

macro @@cequ.sse
{
$usprocf @@cequ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        ucomisd xmm0, xmm2                      ; compare a to c
        jnz    .0                               ; a <> c
        jp     .0                               ; a <> c
        ucomisd xmm1, xmm3                      ; compare b to d
        jnz    .0                               ; b <> d
        jp     .0                               ; b <> d

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@cequ.fpu
{
$usprocf @@cequ

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d | st1 = c | st2 = b | st3 = a
        fcomp   st2                             ; compare d to b
                                                ; st0 = c | st1 = b | st2 = a
        fnjne  .d.ne.b                          ; jump if d<>b
   .d.eq.b:                                     ; d=b
        fcomp   st2                             ; compare c to a
                                                ; st0 = b | st1 = a
        fnjne  .c.ne.a                          ; jump if c<>a
   .c.eq.a:                                     ; c=a and d=b
        fstp    st0
        fstp    st0
        mov     eax, 1
        jmp    .return
   .d.ne.b:                                     ; d<>b
        fstp    st0
   .c.ne.a:                                     ; d<>b
        fstp    st0
        fstp    st0
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cequ.sse
$else
  @@cequ.fpu
$end

; ------------------------------------------------------------------------------

; not equal
; z1 = a + i•b
; z2 = c + i•d
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : (a<>c) or (b<>d)
; 0 : otherwise

macro @@cnequ.sse
{
$usprocf @@cnequ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        ucomisd xmm0, xmm2                      ; compare a to c
        jnz    .1                               ; a <> c
        jp     .1                               ; a <> c
        ucomisd xmm1, xmm3                      ; compare b to d
        jnz    .1                               ; b <> d
        jp     .1                               ; b <> d

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@cnequ.fpu
{
$usprocf @@cnequ

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d | st1 = c | st2 = b | st3 = a
        fcomp   st2                             ; compare d to b
                                                ; st0 = c | st1 = b | st2 = a
        fnjne  .d.ne.b                          ; jump if d<>b
   .d.eq.b:                                     ; d=b
        fcomp   st2                             ; compare c to a
                                                ; st0 = b | st1 = a
        fnjne  .c.ne.a                          ; jump if c<>a
   .c.eq.a:                                     ; c=a and d=b
        fstp    st0
        fstp    st0
        xor     eax, eax
        jmp    .return
   .d.ne.b:                                     ; d<>b
        fstp    st0
   .c.ne.a:                                     ; d<>b
        fstp    st0
        fstp    st0
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cnequ.sse
$else
  @@cnequ.fpu
$end

; ------------------------------------------------------------------------------

; real equal
; z1 = a + i•b
; z2 = c + i•d
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : a=c
; 0 : otherwise

macro @@creal.equ.sse
{
$usprocf @@creal.equ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        ucomisd xmm0, xmm2                      ; compare a to c
        jnz    .0                               ; a <> c
        jp     .0                               ; a <> c

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@creal.equ.fpu
{
$usprocf @@creal.equ

        fld     qword [esp]                     ; load a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c | st1 = a
        fcompp                                  ; compare c to a
        fnjne  .ne                              ; jump if c<>a
   .eq:
        mov     eax, 1
        jmp    .return
   .ne:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@creal.equ.sse
$else
  @@creal.equ.fpu
$end

; ------------------------------------------------------------------------------

; real not equal
; z1 = a + i•b
; z2 = c + i•d
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : a<>c
; 0 : otherwise

macro @@creal.nequ.sse
{
$usprocf @@creal.nequ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
   .enter:
        ucomisd xmm0, xmm2                      ; compare a to c
        jnz    .1                               ; a <> c
        jp     .1                               ; a <> c

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@creal.nequ.fpu
{
$usprocf @@creal.nequ

        fld     qword [esp]                     ; load a
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [esp + 16]                ; load c
   .enter:                                      ; st0 = c | st1 = a
        fcompp                                  ; compare c to a
        fnjne  .ne                              ; jump if c<>a
   .eq:
        xor     eax, eax
        jmp    .return
   .ne:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@creal.nequ.sse
$else
  @@creal.nequ.fpu
$end

; ------------------------------------------------------------------------------

; imaginary equal
; z1 = a + i•b
; z2 = c + i•d
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : b=d
; 0 : otherwise

macro @@cimag.equ.sse
{
$usprocf @@cimag.equ

        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        ucomisd xmm1, xmm3                      ; compare b to d
        jnz    .0                               ; b <> d
        jp     .0                               ; b <> d

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@cimag.equ.fpu
{
$usprocf @@cimag.equ

        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d | st1 = b
        fcompp                                  ; compare d to b
        fnjne  .ne                              ; jump if d<>b
   .eq:
        mov     eax, 1
        jmp    .return
   .ne:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cimag.equ.sse
$else
  @@cimag.equ.fpu
$end

; ------------------------------------------------------------------------------

; imaginary not equal
; z1 = a + i•b
; z2 = c + i•d
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : b<>d
; 0 : otherwise

macro @@cimag.nequ.sse
{
$usprocf @@cimag.nequ

        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        ucomisd xmm1, xmm3                      ; compare b to d
        jnz    .1                               ; b <> d
        jp     .1                               ; b <> d

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@cimag.nequ.fpu
{
$usprocf @@cimag.nequ

        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d | st1 = b
        fcompp                                  ; compare d to b
        fnjne  .ne                              ; jump if d<>b
   .eq:
        xor     eax, eax
        jmp    .return
   .ne:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cimag.nequ.sse
$else
  @@cimag.nequ.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; abs equal
; z1 = a + i•b
; z2 = c + i•d
;
; abs_1 = (a^2 + b^2)^(1/2)
; abs_2 = (c^2 + d^2)^(1/2)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : abs_1 = abs_2
; 0 : otherwise

macro @@cabs.equ.sse
{
$usprocf @@cabs.equ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        mov     edx, @@cabs.enter
        call    edx                             ; xmm0 = abs_1
        movsd   xmm4, xmm0                      ; xmm4 = abs_1
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
        mov     edx, @@cabs.enter
        call    edx                             ; xmm0 = abs_s
        ;
        ucomisd xmm4, xmm0                      ; compare abs_1 to abs_2
        jnz    .0                               ; abs_1 <> abs_2
        jp     .0                               ; abs_1 <> abs_2

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@cabs.equ.fpu
{
$usprocf @@cabs.equ

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d     | st1 = c | st2 = b | st3 = a
        mov     edx, @@cabs.enter
        call    edx                             ; st0 = abs_2 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a     | st1 = b | st2 = abs_2
        mov     edx, @@cabs.enter
        call    edx                             ; st0 = abs_1 | st1 = abs_2
        ;
        fcompp                                  ; compare abs_1 to abs_2
        fnjne  .ne
   .eq:
        mov     eax, 1
        jmp    .return
   .ne:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cabs.equ.sse
$else
  @@cabs.equ.fpu
$end

; ------------------------------------------------------------------------------

; abs not equal
; z1 = a + i•b
; z2 = c + i•d
;
; abs_1 = (a^2 + b^2)^(1/2)
; abs_2 = (c^2 + d^2)^(1/2)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : abs_1 <> abs_2
; 0 : otherwise

macro @@cabs.nequ.sse
{
$usprocf @@cabs.nequ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        mov     edx, @@cabs.enter
        call    edx                             ; xmm0 = abs_1
        movsd   xmm4, xmm0                      ; xmm4 = abs_1
        movsd   xmm0, xmm2
        movsd   xmm1, xmm3
        mov     edx, @@cabs.enter
        call    edx                             ; xmm0 = abs_s
        ;
        ucomisd xmm4, xmm0                      ; compare abs_1 to abs_2
        jnz    .1                               ; abs_1 <> abs_2
        jp     .1                               ; abs_1 <> abs_2

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@cabs.nequ.fpu
{
$usprocf @@cabs.nequ

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d     | st1 = c | st2 = b | st3 = a
        mov     edx, @@cabs.enter
        call    edx                             ; st0 = abs_2 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a     | st1 = b | st2 = abs_2
        mov     edx, @@cabs.enter
        call    edx                             ; st0 = abs_1 | st1 = abs_2
        ;
        fcompp                                  ; compare abs_1 to abs_2
        fnjne  .ne
   .eq:
        xor     eax, eax
        jmp    .return
   .ne:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cabs.nequ.sse
$else
  @@cabs.nequ.fpu
$end

; ------------------------------------------------------------------------------

; arg equal
; z1 = a + i•b
; z2 = c + i•d
;
; arg_1 = atan(b/a)
; arg_2 = atan(d/c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : arg_1 = arg_2
; 0 : otherwise

macro @@carg.equ.sse
{
$usprocf @@carg.equ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.xch  xmm0, xmm2
        @@.xch  xmm1, xmm3
        mov     edx, @@fatan2r.enter
        call    edx
        @@.xch  xmm0, xmm2                      ; xmm2 = arg_2
        @@.xch  xmm1, xmm3
        mov     edx, @@fatan2r.enter
        call    edx                             ; xmm0 = arg_1
        ;
        ucomisd xmm0, xmm2                      ; compare arg_1 to arg_2
        jnz    .0                               ; arg_1 <> arg_2
        jp     .0                               ; arg_1 <> arg_2

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp

macro @@.carg.equ.fpu
\{
$usprocf @@carg.equ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm1                             ; st0 = b
        @@.fld.xmm0                             ; st0 = a | st1 = b
        @@.fld.xmm3                             ; st0 = d
        @@.fld.xmm2                             ; st0 = c | st1 = d | st2 = a | st3 = b
        fpatan
        @@.fstp.xmm1                            ; xmm1 = arg_2
        fpatan
        @@.fstp.xmm0                            ; xmm0 = arg_1
        ;
        ucomisd xmm0, xmm1                      ; compare arg_1 to arg_2
        jnz    .0                               ; arg_1 <> arg_2
        jp     .0                               ; arg_1 <> arg_2

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
\}
}

macro @@carg.equ.fpu
{
$usprocf @@carg.equ

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d     | st1 = c | st2 = b | st3 = a
        fxch                                    ; st0 = c     | st1 = d | st2 = b | st3 = a
        fpatan                                  ; st0 = arg_2 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a     | st1 = b | st2 = arg_2
        fpatan                                  ; st0 = arg_1 | st1 = arg_2
        ;
        fcompp
        fnjne  .ne
   .eq:
        mov     eax, 1
        jmp    .return
   .ne:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@carg.equ.sse
$else
  @@carg.equ.fpu
$end

; ------------------------------------------------------------------------------

; arg not equal
; z1 = a + i•b
; z2 = c + i•d
;
; arg_1 = atan(b/a)
; arg_2 = atan(d/c)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return result in eax
; 1 : arg_1 <> arg_2
; 0 : otherwise

macro @@carg.nequ.sse
{
$usprocf @@carg.nequ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.xch  xmm0, xmm2
        @@.xch  xmm1, xmm3
        mov     edx, @@fatan2r.enter
        call    edx
        @@.xch  xmm0, xmm2                      ; xmm2 = arg_2
        @@.xch  xmm1, xmm3
        mov     edx, @@fatan2r.enter
        call    edx                             ; xmm0 = arg_1
        ;
        ucomisd xmm0, xmm2                      ; compare arg_1 to arg_2
        jnz    .1                               ; arg_1 <> arg_2
        jp     .1                               ; arg_1 <> arg_2

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp

macro @@.carg.nequ.fpu
\{
$usprocf @@carg.nequ

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm1                             ; st0 = b
        @@.fld.xmm0                             ; st0 = a | st1 = b
        @@.fld.xmm3                             ; st0 = d
        @@.fld.xmm2                             ; st0 = c | st1 = d | st2 = a | st3 = b
        fpatan
        @@.fstp.xmm1                            ; xmm1 = arg_2
        fpatan
        @@.fstp.xmm0                            ; xmm0 = arg_1
        ;
        ucomisd xmm0, xmm1                      ; compare arg_1 to arg_2
        jnz    .1                               ; arg_1 <> arg_2
        jp     .1                               ; arg_1 <> arg_2

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
\}
}

macro @@carg.nequ.fpu
{
$usprocf @@carg.nequ

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d     | st1 = c | st2 = b | st3 = a
        fxch                                    ; st0 = c     | st1 = d | st2 = b | st3 = a
        fpatan                                  ; st0 = arg_2 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a     | st1 = b | st2 = arg_2
        fpatan                                  ; st0 = arg_1 | st1 = arg_2
        ;
        fcompp
        fnjne  .ne
   .eq:
        xor     eax, eax
        jmp    .return
   .ne:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@carg.nequ.sse
$else
  @@carg.nequ.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; is zero
; z = a + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return result in eax
; 1 : (a=0) and (b=0)
; 0 : otherwise

macro @@cis.zero.sse
{
$usprocf @@cis.zero

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .0                               ; x <> 0
        jp     .0                               ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .0                               ; y <> 0
        jp     .0                               ; y <> 0

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@cis.zero.fpu
{
$usprocf @@cis.zero

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fldz                                    ; st0 = 0 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a | st1 = b | st2 = 0
        fcomp   st2                             ; compare a to 0
                                                ; st0 = b | st1 = 0
        fnjnz  .a.nz                            ; jump if a<>0
   .a.z:                                        ; st0 = b | st1 = 0
        fcompp                                  ; compare b to 0
        fnjnz  .b.nz                            ; jump if b<>0
   .b.z:                                        ; (a=0) and (b=0)
        mov     eax, 1
        jmp    .return
   .a.nz:
        fstp    st0
        fstp    st0
   .b.nz:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cis.zero.sse
$else
  @@cis.zero.fpu
$end

; ------------------------------------------------------------------------------

; is not zero
; z = a + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return result in eax
; 1 : (a<>0) or (b<>0)
; 0 : otherwise

macro @@cisn.zero.sse
{
$usprocf @@cisn.zero

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .1                               ; x <> 0
        jp     .1                               ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .1                               ; y <> 0
        jp     .1                               ; y <> 0

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@cisn.zero.fpu
{
$usprocf @@cisn.zero

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fldz                                    ; st0 = 0 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a | st1 = b | st2 = 0
        fcomp   st2                             ; compare a to 0
                                                ; st0 = b | st1 = 0
        fnjnz  .a.nz                            ; jump if a<>0
   .a.z:                                        ; st0 = b | st1 = 0
        fcompp                                  ; compare b to 0
        fnjnz  .b.nz                            ; jump if b<>0
   .b.z:                                        ; (a=0) and (b=0)
        xor     eax, eax
        jmp    .return
   .a.nz:
        fstp    st0
        fstp    st0
   .b.nz:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cisn.zero.sse
$else
  @@cisn.zero.fpu
$end

; ------------------------------------------------------------------------------

; is purely real
; z = a + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return result in eax
; 1 : b=0
; 0 : otherwise

macro @@cis.real.sse
{
$usprocf @@cis.real

        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
   .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm1, xmm5                      ; compare b to 0
        jnz    .0                               ; b <> 0
        jp     .0                               ; b <> 0

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@cis.real.fpu
{
$usprocf @@cis.real

        fld     qword [esp + 8]                 ; load b
   .inter:                                      ; st0 = b
        fldz                                    ; st0 = 0 | st1 = b
        fcompp                                  ; compare 0 to b
        fnjnz  .b.nz                            ; jump if b<>0
   .b.z:
        mov     eax, 1
        jmp    .return
   .b.nz:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cis.real.sse
$else
  @@cis.real.fpu
$end

; ------------------------------------------------------------------------------

; is not purely real
; z = a + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return result in eax
; 1 : b<>0
; 0 : otherwise

macro @@cisn.real.sse
{
$usprocf @@cisn.real

        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
   .inter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm1, xmm5                      ; compare b to 0
        jnz    .1                               ; b <> 0
        jp     .1                               ; b <> 0

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@cisn.real.fpu
{
$usprocf @@cisn.real

        fld     qword [esp + 8]                 ; load b
   .inter:                                      ; st0 = b
        fldz                                    ; st0 = 0 | st1 = b
        fcompp                                  ; compare 0 to b
        fnjnz  .b.nz                            ; jump if b<>0
   .b.z:
        xor     eax, eax
        jmp    .return
   .b.nz:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cisn.real.sse
$else
  @@cisn.real.fpu
$end

; ------------------------------------------------------------------------------

; is purely imaginary
; z = a + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return result in eax
; 1 : (a=0) and (b<>0)
; 0 : otherwise

macro @@cis.imag.sse
{
$usprocf @@cis.imag

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare a to 0
        jnz    .0                               ; a <> 0
        jp     .0                               ; a <> 0
        ucomisd xmm1, xmm5                      ; compare b to 0
        jnz    .1                               ; b <> 0
        jp     .1                               ; b <> 0
        jmp    .0

   .1:  mov     eax, 1
        jmp    .return
   .0:  xor     eax, eax
   .return:
        retn
$endp
}

macro @@cis.imag.fpu
{
$usprocf @@cis.imag

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fldz                                    ; st0 = 0 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a | st1 = b | st2 = 0
        fcomp   st2                             ; compare a to 0
                                                ; st0 = b | st1 = 0
        fnjnz  .a.nz                            ; jump if a<>0
   .a.z:
        fcompp                                  ; compare b to 0
        fnjz   .b.z                             ; jump if b=0
   .b.nz:                                       ; (a=0) and (b<>0)
        mov     eax, 1
        jmp    .return
   .a.nz:
        fstp    st0
        fstp    st0
   .b.z:
        xor     eax, eax
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cis.imag.sse
$else
  @@cis.imag.fpu
$end

; ------------------------------------------------------------------------------

; is not purely imaginary
; z = a + i•b
;
; esp + 0 = a
; esp + 8 = b
;
; return result in eax
; 1 : (a<>0) or (b=0)
; 0 : otherwise

macro @@cisn.imag.sse
{
$usprocf @@cisn.imag

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare a to 0
        jnz    .1                               ; a <> 0
        jp     .1                               ; a <> 0
        ucomisd xmm1, xmm5                      ; compare b to 0
        jnz    .0                               ; b <> 0
        jp     .0                               ; b <> 0
        jmp    .1

   .0:  xor     eax, eax
        jmp    .return
   .1:  mov     eax, 1
   .return:
        retn
$endp
}

macro @@cisn.imag.fpu
{
$usprocf @@cisn.imag

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b | st1 = a
        fldz                                    ; st0 = 0 | st1 = b | st2 = a
        fxch    st2                             ; st0 = a | st1 = b | st2 = 0
        fcomp   st2                             ; compare a to 0
                                                ; st0 = b | st1 = 0
        fnjnz  .a.nz                            ; jump if a<>0
   .a.z:
        fcompp                                  ; compare b to 0
        fnjz   .b.z                             ; jump if b=0
   .b.nz:                                       ; (a=0) and (b<>0)
        xor     eax, eax
        jmp    .return
   .a.nz:
        fstp    st0
        fstp    st0
   .b.z:
        mov     eax, 1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cisn.imag.sse
$else
  @@cisn.imag.fpu
$end

; ------------------------------------------------------------------------------
