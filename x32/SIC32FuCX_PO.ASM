
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number power functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex power function
; z1 = a + i•b
; z2 = c + i•d
; cpow(a,b,c,d) = exp(ln(a,b)*(c,d))
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cpow.sse.fpu
{
$usprocf @@cpow

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm2
        @@.fld.xmm3
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b  | st1 = a | st2 = d | st3 = c
        ;
        mov     edx, @@cln.enter.fpu
        call    edx
        mov     edx, @@cmul.enter.fpu
        call    edx
        mov     edx, @@cexp.enter.fpu
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cpow.fpu
{
$usprocf @@cpow

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d  | st1 = c | st2 = b | st3 = a
        fxch    st2                             ; st0 = b  | st1 = c | st2 = d | st3 = a
        fxch                                    ; st0 = c  | st1 = b | st2 = d | st3 = a
        fxch    st3                             ; st0 = a  | st1 = b | st2 = d | st3 = c
        fxch                                    ; st0 = b  | st1 = a | st2 = d | st3 = c
        mov     edx, @@cln.enter
        call    edx
        mov     edx, @@cmul.enter
        call    edx
        mov     edx, @@cexp.enter
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpow.sse.fpu
$else
  @@cpow.fpu
$end

; ------------------------------------------------------------------------------

; complex reverse power function
; z1 = a + i•b
; z2 = c + i•d
; cpowr(a,b,c,d) = exp(ln(c,d)*(a,b))
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cpowr.sse.fpu
{
$usprocf @@cpowr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2
        @@.fld.xmm3                             ; st0 = d  | st1 = c | st2 = b | st3 = a
        ;
        mov     edx, @@cln.enter.fpu
        call    edx
        mov     edx, @@cmul.enter.fpu
        call    edx
        mov     edx, @@cexp.enter.fpu
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cpowr.fpu
{
$usprocf @@cpowr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d  | st1 = c | st2 = b | st3 = a
        mov     edx, @@cln.enter
        call    edx
        mov     edx, @@cmul.enter
        call    edx
        mov     edx, @@cexp.enter
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpowr.sse.fpu
$else
  @@cpowr.fpu
$end

; ------------------------------------------------------------------------------

; complex power function
; z = a + i•b
; cxpow(x,a,b) = x^(a + i•b)
;
; esp + 0  = x
; esp + 8  = a
; esp + 16 = b
;
; return_1 = st1 = a' = r'*cos(t')
; return_2 = st0 = b' = r'*sin(t')
; r' = (x^a)
; t' = b*ln(x)

macro @@cxpow.sse.fpu
{
$usprocf @@cxpow

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = a
        movsd   xmm2, qword [esp + 16]          ; xmm2 = b
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2                             ; st0 = b        | st1 = a       | st2 = x
        ;
        fld     st2                             ; st0 = x        | st1 = b       | st2 = a       | st3 = x
   .ln.x.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)    | st1 = b       | st2 = a       | st3 = x
   .ln.x.leave:
        fmulp                                   ; st0 = t'       | st1 = a       | st2 = x
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t')  | st1 = sin(t') | st2 = a       | st3 = x
        fxch    st3                             ; st0 = x        | st1 = sin(t') | st2 = a       | st3 = cos(t')
        fxch                                    ; st0 = sin(t')  | st1 = x       | st2 = a       | st3 = cos(t')
        fxch    st2                             ; st0 = a        | st1 = x       | st2 = sin(t') | st3 = cos(t')
        mov     edx, @@pow.enter.fpu            ; st0 = exponent | st1 = base
        call    edx                             ; st0 = r'       | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'       | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'       | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cxpow.fpu
{
$usprocf @@cxpow

        fld     qword [esp]                     ; load x
        fld     qword [esp + 8]                 ; load a
        fld     qword [esp + 16]                ; load b
   .enter:                                      ; st0 = b        | st1 = a       | st2 = x
        fld     st2                             ; st0 = x        | st1 = b       | st2 = a       | st3 = x
   .ln.x.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(x)    | st1 = b       | st2 = a       | st3 = x
   .ln.x.leave:
        fmulp                                   ; st0 = t'       | st1 = a       | st2 = x
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t')  | st1 = sin(t') | st2 = a       | st3 = x
        fxch    st3                             ; st0 = x        | st1 = sin(t') | st2 = a       | st3 = cos(t')
        fxch                                    ; st0 = sin(t')  | st1 = x       | st2 = a       | st3 = cos(t')
        fxch    st2                             ; st0 = a        | st1 = x       | st2 = sin(t') | st3 = cos(t')
        mov     edx, @@pow.enter                ; st0 = exponent | st1 = base
        call    edx                             ; st0 = r'       | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'       | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'       | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cxpow.sse.fpu
$else
  @@cxpow.fpu
$end

; ------------------------------------------------------------------------------

; complex power function
; z = a + i•b
; cpowx(a,b,x) = exp(ln(a,b)*x)
; x - double value
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = x
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cpowx.sse.fpu
{
$usprocf @@cpowx

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = x
   .enter:                                      ; st0 = x      | st1 = b      | st2 = a
        @@.fld.xmm2
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a      | st2 = x
        ;
        mov     edx, @@cln.enter.fpu
        call    edx                             ; st0 = ln.b   | st1 = ln.a   | st2 = x
        fxch    st2                             ; st0 = x      | st0 = ln.a   | st1 = ln.b
        fmul    st2, st0                        ; st0 = x      | st0 = ln.a   | st1 = x*ln.b
        fmulp                                   ; st0 = x*ln.a | st1 = x*ln.b
        fxch                                    ; st0 = x*ln.b | st1 = x*ln.a
        mov     edx, @@cexp.enter.fpu
        call    edx                             ; st0 = b'     | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cpowx.fpu
{
$usprocf @@cpowx

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load x
   .enter:                                      ; st0 = x      | st1 = b      | st2 = a
        fxch    st2                             ; st0 = a      | st1 = b      | st2 = x
        fxch                                    ; st0 = b      | st1 = a      | st2 = x
        mov     edx, @@cln.enter
        call    edx                             ; st0 = ln.b   | st1 = ln.a   | st2 = x
        fxch    st2                             ; st0 = x      | st0 = ln.a   | st1 = ln.b
        fmul    st2, st0                        ; st0 = x      | st0 = ln.a   | st1 = x*ln.b
        fmulp                                   ; st0 = x*ln.a | st1 = x*ln.b
        fxch                                    ; st0 = x*ln.b | st1 = x*ln.a
        mov     edx, @@cexp.enter
        call    edx                             ; st0 = b'     | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpowx.sse.fpu
$else
  @@cpowx.fpu
$end

; ------------------------------------------------------------------------------

; complex power function
; z = a + i•b
; cpown(a,b,n)
; n - integer value
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = n
;
; return_1 = st1 = a' = r'*cos(t')
; return_2 = st0 = b' = r'*sin(t')
; r' = r^n
; t' = t*n
; r  = (a^2 + b^2)^(1/2)
; t  = atan(b/a)

macro @@cpown.sse.fpu
{
$usprocf @@cpown

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        mov     eax, dword [esp + 16]           ; eax = n
        cvtsi2sd xmm2, eax                      ; xmm2 = n
   .enter:
        @@.fld.xmm2
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b       | st1 = a       | st2 = n
        ;
        mov     edx, @@cpolar.enter.fpu
        call    edx                             ; st0 = t       | st1 = r       | st2 = n
        fmulp   st2, st0                        ; st0 = r       | st1 = t'
        mov     edx, @@ipow.enter.fpu           ; st0 = base    | rax = exponent
        call    edx                             ; st0 = r'      | st1 = t'
        fxch                                    ; st0 = t'      | st1 = r'
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t') | st1 = sin(t') | st2 = r'
        fxch    st2                             ; st0 = r'      | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'      | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'      | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cpown.fpu
{
$usprocf @@cpown

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fild    dword [esp + 16]                ; load n
        mov     eax, dword [esp + 16]           ; eax = n
   .enter:                                      ; st0 = n       | st1 = b       | st2 = a
        fxch    st2                             ; st0 = a       | st1 = b       | st2 = n
        fxch                                    ; st0 = b       | st1 = a       | st2 = n
        mov     edx, @@cpolar.enter
        call    edx                             ; st0 = t       | st1 = r       | st2 = n
        fmulp   st2, st0                        ; st0 = r       | st1 = t'
        mov     edx, @@ipow.enter               ; st0 = base    | eax = exponent
        call    edx                             ; st0 = r'      | st1 = t'
        fxch                                    ; st0 = t'      | st1 = r'
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t') | st1 = sin(t') | st2 = r'
        fxch    st2                             ; st0 = r'      | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'      | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'      | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpown.sse.fpu
$else
  @@cpown.fpu
$end

; ------------------------------------------------------------------------------

; complex value raised to a power of 2
; z = a + i•b
; cpow2(a,b) = (a^2 - b^2) + i•(2*a*b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a' = a^2 - b^2
; return_2 = st0 = b' = 2*a*b

macro @@cpow2.sse
{
$usprocf @@cpow2

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm4, xmm1                      ; xmm4 = b
        mulsd   xmm1, xmm0
        addsd   xmm1, xmm1                      ; xmm1 = 2*a*b
        mulsd   xmm0, xmm0                      ; xmm0 = a^2
        mulsd   xmm4, xmm4                      ; xmm4 = b^2
        subsd   xmm0, xmm4                      ; xmm0 = a^2-b^2
   .return:
        retn
$endp

$asprocf @@cpow2.enter.fpu
                                                ; st0 = b   | st1 = a
        fld     st1
        fmul    st0, st0                        ; st0 = a^2 | st1 = b   | st2 = a
        fld     st1
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = b   | st3 = a
        fsubp                                   ; st0 = a'  | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = a'
        fmulp                                   ; st0 = a*b | st1 = a'
        fadd    st0, st0
   .return:
        retn
$endp
}

macro @@cpow2.fpu
{
$usprocf @@cpow2

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld     st1
        fmul    st0, st0                        ; st0 = a^2 | st1 = b   | st2 = a
        fld     st1
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = b   | st3 = a
        fsubp                                   ; st0 = a'  | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = a'
        fmulp                                   ; st0 = a*b | st1 = a'
        fadd    st0, st0
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpow2.sse
$else
  @@cpow2.fpu
$end

; ------------------------------------------------------------------------------

; complex value raised to a power of 3
; z = a + i•b
; cpow3(a,b) = cpow2(a,b)*(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cpow3.sse
{
$usprocf @@cpow3

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm2, xmm0                      ; xmm2 = a
        movsd   xmm3, xmm1                      ; xmm3 = b
   .cpow2.enter:
        movsd   xmm4, xmm1                      ; xmm4 = b
        mulsd   xmm1, xmm0
        addsd   xmm1, xmm1                      ; xmm1 = 2*a*b
        mulsd   xmm0, xmm0                      ; xmm0 = a^2
        mulsd   xmm4, xmm4                      ; xmm4 = b^2
        subsd   xmm0, xmm4                      ; xmm0 = a^2-b^2
   .cpow2.leave:
        mov     edx, @@cmul.enter
        call    edx
   .return:
        retn
$endp
}

macro @@cpow3.fpu
{
$usprocf @@cpow3

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        fld     st1
        fld     st1                             ; st0 = b   | st1 = a   | st2 = b   | st3 = a
   .cpow2.enter:
        fld     st1
        fmul    st0, st0                        ; st0 = a^2 | st1 = b   | st2 = a
        fld     st1
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = b   | st3 = a
        fsubp                                   ; st0 = a'  | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = a'
        fmulp                                   ; st0 = a*b | st1 = a'
        fadd    st0, st0                        ; st0:st1 = cpow2(a,b)
   .cpow2.leave:
        mov     edx, @@cmul.enter
        call    edx                             ; st0:st1 = cpow3(a,b)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpow3.sse
$else
  @@cpow3.fpu
$end

; ------------------------------------------------------------------------------

; complex value raised to a power of 4
; z = a + i•b
; cpow4(a,b) = cpow2(a,b)*cpow2(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@cpow4.sse
{
$usprocf @@cpow4

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .cpow2a.enter:
        movsd   xmm4, xmm1                      ; xmm4 = b
        mulsd   xmm1, xmm0
        addsd   xmm1, xmm1                      ; xmm1 = 2*a*b
        mulsd   xmm0, xmm0                      ; xmm0 = a^2
        mulsd   xmm4, xmm4                      ; xmm4 = b^2
        subsd   xmm0, xmm4                      ; xmm0 = a^2-b^2
   .cpow2a.leave:
   .cpow2b.enter:
        movsd   xmm4, xmm1                      ; xmm4 = b
        mulsd   xmm1, xmm0
        addsd   xmm1, xmm1                      ; xmm1 = 2*a*b
        mulsd   xmm0, xmm0                      ; xmm0 = a^2
        mulsd   xmm4, xmm4                      ; xmm4 = b^2
        subsd   xmm0, xmm4                      ; xmm0 = a^2-b^2
   .cpow2b.leave:
   .return:
        retn
$endp
}

macro @@cpow4.fpu
{
$usprocf @@cpow4

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
   .cpow2a.enter:
        fld     st1
        fmul    st0, st0                        ; st0 = a^2 | st1 = b   | st2 = a
        fld     st1
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = b   | st3 = a
        fsubp                                   ; st0 = a'  | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = a'
        fmulp                                   ; st0 = a*b | st1 = a'
        fadd    st0, st0                        ; st0:st1 = cpow2(a,b)
   .cpow2a.leave:
   .cpow2b.enter:
        fld     st1
        fmul    st0, st0                        ; st0 = a^2 | st1 = b   | st2 = a
        fld     st1
        fmul    st0, st0                        ; st0 = b^2 | st1 = a^2 | st2 = b   | st3 = a
        fsubp                                   ; st0 = a'  | st1 = b   | st2 = a
        fxch    st2                             ; st0 = a   | st1 = b   | st2 = a'
        fmulp                                   ; st0 = a*b | st1 = a'
        fadd    st0, st0                        ; st0:st1 = cpow2(cpow2(a,b))
   .cpow2b.leave:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cpow4.sse
$else
  @@cpow4.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex root function
; z1 = a + i•b
; z2 = c + i•d
; croot(a,b,c,d) = exp(ln(a,b)/(c,d))
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@croot.sse.fpu
{
$usprocf @@croot

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm2
        @@.fld.xmm3
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b  | st1 = a | st2 = d | st3 = c
        ;
        mov     edx, @@cln.enter.fpu
        call    edx
        mov     edx, @@cdivr.enter.fpu
        call    edx
        mov     edx, @@cexp.enter.fpu
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@croot.fpu
{
$usprocf @@croot

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d  | st1 = c | st2 = b | st3 = a
        fxch    st2                             ; st0 = b  | st1 = c | st2 = d | st3 = a
        fxch                                    ; st0 = c  | st1 = b | st2 = d | st3 = a
        fxch    st3                             ; st0 = a  | st1 = b | st2 = d | st3 = c
        fxch                                    ; st0 = b  | st1 = a | st2 = d | st3 = c
        mov     edx, @@cln.enter
        call    edx
        mov     edx, @@cdivr.enter
        call    edx
        mov     edx, @@cexp.enter
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@croot.sse.fpu
$else
  @@croot.fpu
$end

; ------------------------------------------------------------------------------

; complex reverse root function
; z1 = a + i•b
; z2 = c + i•d
; crootr(a,b,c,d) = exp(ln(c,d)/(a,b))
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = c
; esp + 24 = d
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@crootr.sse.fpu
{
$usprocf @@crootr

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = c
        movsd   xmm3, qword [esp + 24]          ; xmm3 = d
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2
        @@.fld.xmm3                             ; st0 = d  | st1 = c | st2 = b | st3 = a
        ;
        mov     edx, @@cln.enter.fpu
        call    edx
        mov     edx, @@cdivr.enter.fpu
        call    edx
        mov     edx, @@cexp.enter.fpu
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@crootr.fpu
{
$usprocf @@crootr

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load c
        fld     qword [esp + 24]                ; load d
   .enter:                                      ; st0 = d  | st1 = c | st2 = b | st3 = a
        mov     edx, @@cln.enter
        call    edx
        mov     edx, @@cdivr.enter
        call    edx
        mov     edx, @@cexp.enter
        call    edx                             ; st0 = b' | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crootr.sse.fpu
$else
  @@crootr.fpu
$end

; ------------------------------------------------------------------------------

; complex root function
; z = a + i•b
; crootx(a,b,x) = exp(ln(a,b)/x)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = x
;
; return_1 = st1 = a'
; return_2 = st0 = b'

macro @@crootx.sse.fpu
{
$usprocf @@crootx

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        movsd   xmm2, qword [esp + 16]          ; xmm2 = x
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2                             ; st0 = x      | st1 = b    | st2 = a
        ;
        fld1
        fdivrp                                  ; st0 = 1/x    | st1 = b    | st2 = a
        fxch    st2                             ; st0 = a      | st1 = b    | st2 = 1/x
        fxch                                    ; st0 = b      | st1 = a    | st2 = 1/x
        mov     edx, @@cln.enter.fpu
        call    edx                             ; st0 = ln.b   | st1 = ln.a | st2 = 1/x
        fxch    st2                             ; st0 = 1/x    | st1 = ln.a | st2 = ln.b
        fmul    st2, st0                        ; st0 = 1/x    | st1 = ln.a | st2 = ln.b/x
        fmulp                                   ; st0 = ln.a/x | st1 = ln.b/x
        fxch                                    ; st0 = ln.b/x | st1 = ln.a/x
        mov     edx, @@cexp.enter.fpu
        call    edx                             ; st0 = b'     | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@crootx.fpu
{
$usprocf @@crootx

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fld     qword [esp + 16]                ; load x
   .enter:                                      ; st0 = x      | st1 = b    | st2 = a
        fld1
        fdivrp                                  ; st0 = 1/x    | st1 = b    | st2 = a
        fxch    st2                             ; st0 = a      | st1 = b    | st2 = 1/x
        fxch                                    ; st0 = b      | st1 = a    | st2 = 1/x
        mov     edx, @@cln.enter
        call    edx                             ; st0 = ln.b   | st1 = ln.a | st2 = 1/x
        fxch    st2                             ; st0 = 1/x    | st1 = ln.a | st2 = ln.b
        fmul    st2, st0                        ; st0 = 1/x    | st1 = ln.a | st2 = ln.b/x
        fmulp                                   ; st0 = ln.a/x | st1 = ln.b/x
        fxch                                    ; st0 = ln.b/x | st1 = ln.a/x
        mov     edx, @@cexp.enter
        call    edx                             ; st0 = b'     | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crootx.sse.fpu
$else
  @@crootx.fpu
$end

; ------------------------------------------------------------------------------

; complex root function
; z = a + i•b
; crootn(a,b,n)
; n - integer value
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = n
;
; return_1 = st1 = a' = r'*cos(t')
; return_2 = st0 = b' = r'*sin(t')
; r' = r^(1/n)
; t' = t/n
; r  = (a^2 + b^2)^(1/2)
; t  = atan(b/a)

macro @@crootn.sse.fpu
{
$usprocf @@crootn

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        cvtsi2sd xmm2, dword [esp + 16]         ; xmm2 = n
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2                             ; st0 = n        | st1 = b  | st2 = a
        ;
        fld1
        fdivrp                                  ; st0 = 1/n      | st1 = b  | st2 = a
        fxch    st2                             ; st0 = a        | st1 = b  | st2 = 1/n
        fxch                                    ; st0 = b        | st1 = a  | st2 = 1/n
        mov     edx, @@cpolar.enter.fpu
        call    edx                             ; st0 = t        | st1 = r  | st2 = 1/n
        fmul    st0, st2                        ; st0 = t'       | st1 = r  | st2 = 1/n
        fxch    st2                             ; st0 = 1/n      | st1 = r  | st2 = t'
        mov     edx, @@dpow.enter.fpu           ; st0 = exponent | st1 = base
        call    edx                             ; st0 = r'       | st1 = t'
        fxch                                    ; st0 = t'       | st1 = r'
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t')  | st1 = sin(t') | st2 = r'
        fxch    st2                             ; st0 = r'       | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'       | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'       | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@crootn.fpu
{
$usprocf @@crootn

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fild    dword [esp + 16]                ; load n
   .enter:                                      ; st0 = n        | st1 = b  | st2 = a
        fld1
        fdivrp                                  ; st0 = 1/n      | st1 = b  | st2 = a
        fxch    st2                             ; st0 = a        | st1 = b  | st2 = 1/n
        fxch                                    ; st0 = b        | st1 = a  | st2 = 1/n
        mov     edx, @@cpolar.enter
        call    edx                             ; st0 = t        | st1 = r  | st2 = 1/n
        fmul    st0, st2                        ; st0 = t'       | st1 = r  | st2 = 1/n
        fxch    st2                             ; st0 = 1/n      | st1 = r  | st2 = t'
        mov     edx, @@dpow.enter               ; st0 = exponent | st1 = base
        call    edx                             ; st0 = r'       | st1 = t'
        fxch                                    ; st0 = t'       | st1 = r'
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t')  | st1 = sin(t') | st2 = r'
        fxch    st2                             ; st0 = r'       | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'       | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'       | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crootn.sse.fpu
$else
  @@crootn.fpu
$end

; ------------------------------------------------------------------------------

; complex root function
; z = a + i•b
; crootsn(a,b,n,p)
; n - integer value
; p - integer value
; p = root number (0 <= p <= n-1)
;
; esp + 0  = a
; esp + 8  = b
; esp + 16 = n
; esp + 20 = p
;
; return_1 = st1 = a' = r'*cos(t')
; return_2 = st0 = b' = r'*sin(t')
; r' = r^(1/n)
; t' = (t + p')/n
; p' = 2*pi*p
; r  = (a^2 + b^2)^(1/2)
; t  = atan(b/a)

macro @@crootsn.sse.fpu
{
$usprocf @@crootsn

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        cvtsi2sd xmm2, dword [esp + 16]         ; xmm2 = n
        cvtsi2sd xmm3, dword [esp + 20]         ; xmm3 = p
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2
        @@.fld.xmm3                             ; st0 = p        | st1 = n       | st2 = b   | st3 = a
        ;
        fldpi
        fmulp
        fadd    st0, st0                        ; st0 = p'       | st1 = n       | st2 = b   | st3 = a
        fxch    st3                             ; st0 = a        | st1 = n       | st2 = b   | st3 = p'
        fxch                                    ; st0 = n        | st1 = a       | st2 = b   | st3 = p'
        fld1
        fdivrp                                  ; st0 = 1/n      | st1 = a       | st2 = b   | st3 = p'
        fxch    st2                             ; st0 = b        | st1 = a       | st2 = 1/n | st3 = p'
        mov     edx, @@cpolar.enter.fpu
        call    edx                             ; st0 = t        | st1 = r       | st2 = 1/n | st3 = p'
        faddp   st3, st0                        ; st0 = r        | st1 = 1/n     | st2 = t+p'
        fxch                                    ; st0 = 1/n      | st1 = r       | st2 = t+p'
        fmul    st2, st0                        ; st0 = 1/n      | st1 = r       | st2 = t'
        mov     edx, @@dpow.enter.fpu           ; st0 = exponent | st1 = base
        call    edx                             ; st0 = r'       | st1 = t'
        fxch                                    ; st0 = t'       | st1 = r'
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t')  | st1 = sin(t') | st2 = r'
        fxch    st2                             ; st0 = r'       | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'       | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'       | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@crootsn.fpu
{
$usprocf @@crootsn

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        fild    dword [esp + 16]                ; load n
        fild    dword [esp + 20]                ; load p
   .enter:                                      ; st0 = p        | st1 = n       | st2 = b   | st3 = a
        fldpi
        fmulp
        fadd    st0, st0                        ; st0 = p'       | st1 = n       | st2 = b   | st3 = a
        fxch    st3                             ; st0 = a        | st1 = n       | st2 = b   | st3 = p'
        fxch                                    ; st0 = n        | st1 = a       | st2 = b   | st3 = p'
        fld1
        fdivrp                                  ; st0 = 1/n      | st1 = a       | st2 = b   | st3 = p'
        fxch    st2                             ; st0 = b        | st1 = a       | st2 = 1/n | st3 = p'
        mov     edx, @@cpolar.enter
        call    edx                             ; st0 = t        | st1 = r       | st2 = 1/n | st3 = p'
        faddp   st3, st0                        ; st0 = r        | st1 = 1/n     | st2 = t+p'
        fxch                                    ; st0 = 1/n      | st1 = r       | st2 = t+p'
        fmul    st2, st0                        ; st0 = 1/n      | st1 = r       | st2 = t'
        mov     edx, @@dpow.enter               ; st0 = exponent | st1 = base
        call    edx                             ; st0 = r'       | st1 = t'
        fxch                                    ; st0 = t'       | st1 = r'
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t')  | st1 = sin(t') | st2 = r'
        fxch    st2                             ; st0 = r'       | st1 = sin(t') | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'       | st1 = sin(t') | st2 = a'
        fmulp                                   ; st0 = b'       | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@crootsn.sse.fpu
$else
  @@crootsn.fpu
$end

; ------------------------------------------------------------------------------

; complex square root
; z = a + i•b
; croot2(a,b)
;
; esp + 0 = a
; esp + 8 = b
;
; return_1 = st1 = a'
; return_2 = st0 = b'
;
; a' = ((r + a)/2)^(1/2)
; b' = ((r - a)/2)^(1/2)*sign(b)
; r = (a^2 + b^2)^(1/2)

macro @@croot2.sse.fpu
{
$usprocf @@croot2

        movsd   xmm0, qword [esp]               ; xmm0 = a
        movsd   xmm1, qword [esp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b   | st1 = a
        ;
        ftst                                    ; compare b to 0
        fnstsw  ax                              ; save compare result
        ;
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a
        fxch                                    ; st0 = b   | st1 = a   | st2 = a
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a   | st3 = a
        mov     edx, @@cabs.enter.fpu
        call    edx                             ; st0 = r   | st1 = a   | st2 = a
        fsubr   st2, st0                        ; st0 = r   | st1 = a   | st2 = r-a
        faddp                                   ; st0 = r+a | st1 = r-a
        mov     edx, ??.0.5
        fmul    qword [edx]                     ; *0.5 = /2
        fsqrt                                   ; st0 = a'  | st1 = r-a
        fxch                                    ; st0 = r-a | st1 = a'
        fmul    qword [edx]                     ; *0.5 = /2
        fsqrt                                   ; st0 = b'  | st1 = a'
        sahf
        jae    .return
   .b.lt.0:                                     ; b < 0
        fchs
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp

$asprocf @@croot2.enter.fpu
                                                ; st0 = b   | st1 = a
        ftst                                    ; compare b to 0
        fnstsw  ax                              ; save compare result
        ;
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a
        fxch                                    ; st0 = b   | st1 = a   | st2 = a
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a   | st3 = a
        mov     edx, @@cabs.enter.fpu
        call    edx                             ; st0 = r   | st1 = a   | st2 = a
        fsubr   st2, st0                        ; st0 = r   | st1 = a   | st2 = r-a
        faddp                                   ; st0 = r+a | st1 = r-a
        mov     edx, ??.0.5
        fmul    qword [edx]                     ; *0.5 = /2
        fsqrt                                   ; st0 = a'  | st1 = r-a
        fxch                                    ; st0 = r-a | st1 = a'
        fmul    qword [edx]                     ; *0.5 = /2
        fsqrt                                   ; st0 = b'  | st1 = a'
        sahf
        jae    .return
   .b.lt.0:                                     ; b < 0
        fchs
   .return:
        retn
$endp
}

macro @@croot2.fpu
{
$usprocf @@croot2

        fld     qword [esp]                     ; load a
        fld     qword [esp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b   | st1 = a
        ftst                                    ; compare b to 0
        fnstsw  ax                              ; save compare result
        ;
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a
        fxch                                    ; st0 = b   | st1 = a   | st2 = a
        fld     st1                             ; st0 = a   | st1 = b   | st2 = a   | st3 = a
        mov     edx, @@cabs.enter
        call    edx                             ; st0 = r   | st1 = a   | st2 = a
        fsubr   st2, st0                        ; st0 = r   | st1 = a   | st2 = r-a
        faddp                                   ; st0 = r+a | st1 = r-a
        mov     edx, ??.0.5
        fmul    qword [edx]                     ; *0.5 = /2
        fsqrt                                   ; st0 = a'  | st1 = r-a
        fxch                                    ; st0 = r-a | st1 = a'
        fmul    qword [edx]                     ; *0.5 = /2
        fsqrt                                   ; st0 = b'  | st1 = a'
        sahf
        jae    .return
   .b.lt.0:                                     ; b < 0
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@croot2.sse.fpu
$else
  @@croot2.fpu
$end

; ------------------------------------------------------------------------------
