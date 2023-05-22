
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (complex number exponential functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; complex exponential function
; z = a + i•b
; cexp(a,b) = e^(a + i•b)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = exp(a)*cos(b)
; return_2 = st0 = b' = exp(a)*sin(b)

macro @@cexp.sse.fpu
{
$usprocf @@cexp

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b      | st1 = a
        ;
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@exp.enter.fpu
        call    rdx                             ; st0 = exp(a) | st1 = sin(b) | st2 = cos(b)
        fmul    st2, st0                        ; st0 = exp(a) | st1 = sin(b) | st2 = a'
        fmulp                                   ; st0 = b'     | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp

$asprocf @@cexp.enter.fpu
                                                ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@exp.enter.fpu
        call    rdx                             ; st0 = exp(a) | st1 = sin(b) | st2 = cos(b)
        fmul    st2, st0                        ; st0 = exp(a) | st1 = sin(b) | st2 = a'
        fmulp                                   ; st0 = b'     | st1 = a'
   .return:
        retn
$endp
}

macro @@cexp.fpu
{
$usprocf @@cexp

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(b) | st1 = sin(b) | st2 = a
        fxch    st2                             ; st0 = a      | st1 = sin(b) | st2 = cos(b)
        mov     rdx, @@exp.enter
        call    rdx                             ; st0 = exp(a) | st1 = sin(b) | st2 = cos(b)
        fmul    st2, st0                        ; st0 = exp(a) | st1 = sin(b) | st2 = a'
        fmulp                                   ; st0 = b'     | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cexp.sse.fpu
$else
  @@cexp.fpu
$end

; ------------------------------------------------------------------------------

; 2 raised to a power of complex z
; z = a + i•b
; cexp2(a,b) = 2^(a + i•b)
;
; rsp + 0  = a
; rsp + 8  = b
;
; return_1 = st1 = a' = r'*cos(t')
; return_2 = st0 = b' = r'*sin(t')
; r' = (2^a)
; t' = b*ln(2)

macro @@cexp2.sse.fpu
{
$usprocf @@cexp2

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b       | st1 = a
        ;
        fldq    ??.ln.2                         ; st0 = ln(2)   | st1 = b        | st2 = a
        fmulp                                   ; st0 = t'      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t') | st1 = sin(t')  | st2 = a
        fxch    st2                             ; st0 = a       | st1 = sin(t')  | st2 = cos(t')
        fldq    ??.2.0                          ; st0 = 2       | st0 = a        | st1 = sin(t') | st2 = cos(t')
        mov     rdx, @@powr.enter.fpu           ; st0 = base    | st1 = exponent |
        call    rdx                             ; st0 = r'      | st1 = sin(t')  | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'      | st1 = sin(t')  | st2 = a'
        fmulp                                   ; st0 = b'      | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cexp2.fpu
{
$usprocf @@cexp2

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b       | st1 = a
        mov     rdx, ??.ln.2
        fld     qword [rdx]                     ; st0 = ln(2)   | st1 = b        | st2 = a
        fmulp                                   ; st0 = t'      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t') | st1 = sin(t')  | st2 = a
        fxch    st2                             ; st0 = a       | st1 = sin(t')  | st2 = cos(t')
        mov     rdx, ??.2.0
        fld     qword [rdx]                     ; st0 = 2       | st0 = a        | st1 = sin(t') | st2 = cos(t')
        mov     rdx, @@powr.enter               ; st0 = base    | st1 = exponent |
        call    rdx                             ; st0 = r'      | st1 = sin(t')  | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'      | st1 = sin(t')  | st2 = a'
        fmulp                                   ; st0 = b'      | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cexp2.sse.fpu
$else
  @@cexp2.fpu
$end

; ------------------------------------------------------------------------------

; 10 raised to a power of complex z
; z = a + i•b
; cexp10(a,b) = 10^(a + i•b)
;
; rsp + 0  = a
; rsp + 8  = b
;
; return_1 = st1 = a' = r'*cos(t')
; return_2 = st0 = b' = r'*sin(t')
; r' = (10^a)
; t' = b*ln(10)

macro @@cexp10.sse.fpu
{
$usprocf @@cexp10

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b       | st1 = a
        ;
        fldq    ??.ln.10                        ; st0 = ln(10)  | st1 = b        | st2 = a
        fmulp                                   ; st0 = t'      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t') | st1 = sin(t')  | st2 = a
        fxch    st2                             ; st0 = a       | st1 = sin(t')  | st2 = cos(t')
        fldq    ??.10.0                         ; st0 = 10      | st0 = a        | st1 = sin(t') | st2 = cos(t')
        mov     rdx, @@powr.enter.fpu           ; st0 = base    | st1 = exponent |
        call    rdx                             ; st0 = r'      | st1 = sin(t')  | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'      | st1 = sin(t')  | st2 = a'
        fmulp                                   ; st0 = b'      | st1 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@cexp10.fpu
{
$usprocf @@cexp10

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b       | st1 = a
        mov     rdx, ??.ln.10
        fld     qword [rdx]                     ; st0 = ln(10)  | st1 = b        | st2 = a
        fmulp                                   ; st0 = t'      | st1 = a
        @@st0.sin.cos.core.reduce
        fsincos                                 ; st0 = cos(t') | st1 = sin(t')  | st2 = a
        fxch    st2                             ; st0 = a       | st1 = sin(t')  | st2 = cos(t')
        mov     rdx, ??.10.0
        fld     qword [rdx]                     ; st0 = 10      | st0 = a        | st1 = sin(t') | st2 = cos(t')
        mov     rdx, @@powr.enter               ; st0 = base    | st1 = exponent |
        call    rdx                             ; st0 = r'      | st1 = sin(t')  | st2 = cos(t')
        fmul    st2, st0                        ; st0 = r'      | st1 = sin(t')  | st2 = a'
        fmulp                                   ; st0 = b'      | st1 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cexp10.sse.fpu
$else
  @@cexp10.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; complex natural logarithm
; z = a + i•b = r*exp(i•t)
; cln(a,b) = ln(r) + i•t
; cln(a,b) = ln(r) + i•(t + 2*pi*n)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = ln(r)
; return_2 = st0 = b' = t

macro @@cln.sse.fpu
{
$usprocf @@cln

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b     | st1 = a
        ;
        fld     st1                             ; st0 = a     | st1 = b     | st2 = a
        fld     st1                             ; st0 = b     | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r     | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r) | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a     | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t     | st1 = ln(r) |
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp

$asprocf @@cln.enter.fpu
                                                ; st0 = b     | st1 = a
        fld     st1                             ; st0 = a     | st1 = b     | st2 = a
        fld     st1                             ; st0 = b     | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r     | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r) | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a     | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t     | st1 = ln(r) |
   .return:
        retn
$endp
}

macro @@cln.fpu
{
$usprocf @@cln

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b     | st1 = a
        fld     st1                             ; st0 = a     | st1 = b     | st2 = a
        fld     st1                             ; st0 = b     | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r     | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r) | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a     | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t     | st1 = ln(r) |
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@cln.sse.fpu
$else
  @@cln.fpu
$end

; ------------------------------------------------------------------------------

; complex base-2 logarithm
; z = a + i•b = r*exp(i•t)
; clog2(a,b) = log2(e)*(ln(r) + i•t)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = log2(e)*ln(r)
; return_2 = st0 = b' = log2(e)*t

macro @@clog2.sse.fpu
{
$usprocf @@clog2

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b       | st1 = a
        ;
   .cln.enter:
        fld     st1                             ; st0 = a       | st1 = b     | st2 = a
        fld     st1                             ; st0 = b       | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r       | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)   | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t       | st1 = ln(r) |
   .cln.leave:
        fldl2e                                  ; st0 = log2(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = log2(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'      | st2 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@clog2.fpu
{
$usprocf @@clog2

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b       | st1 = a
   .cln.enter:
        fld     st1                             ; st0 = a       | st1 = b     | st2 = a
        fld     st1                             ; st0 = b       | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r       | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)   | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t       | st1 = ln(r) |
   .cln.leave:
        fldl2e                                  ; st0 = log2(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = log2(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'      | st2 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@clog2.sse.fpu
$else
  @@clog2.fpu
$end

; ------------------------------------------------------------------------------

; complex base-10 logarithm
; z = a + i•b = r*exp(i•t)
; clog10(a,b) = log10(e)*(ln(r) + i•t)
;
; rsp + 0 = a
; rsp + 8 = b
;
; return_1 = st1 = a' = log10(e)*ln(r)
; return_2 = st0 = b' = log10(e)*t

macro @@clog10.sse.fpu
{
$usprocf @@clog10

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b        | st1 = a
        ;
   .cln.enter:
        fld     st1                             ; st0 = a        | st1 = b     | st2 = a
        fld     st1                             ; st0 = b        | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r        | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)    | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a        | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t        | st1 = ln(r) |
   .cln.leave:
        fldq    ??.log10.e                      ; st0 = log10(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = log10(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'       | st2 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@clog10.fpu
{
$usprocf @@clog10

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = b        | st1 = a
   .cln.enter:
        fld     st1                             ; st0 = a        | st1 = b     | st2 = a
        fld     st1                             ; st0 = b        | st1 = a     | st2 = b | st3 = a
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r        | st1 = b     | st2 = a
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)    | st1 = b     | st2 = a
   .ln.r.leave:
        fxch    st2                             ; st0 = a        | st1 = b     | st2 = ln(r)
        fpatan                                  ; st0 = t        | st1 = ln(r) |
   .cln.leave:
        fldq    ??.log10.e                      ; st0 = log10(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = log10(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'       | st2 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@clog10.sse.fpu
$else
  @@clog10.fpu
$end

; ------------------------------------------------------------------------------

; complex base-n logarithm
; z = a + i•b = r*exp(i•t)
; clogn(n,a,b) = logn(e)*(ln(r) + i•t)
;
; rsp + 0  = n
; rsp + 8  = a
; rsp + 16 = b
;
; return_1 = st1 = a' = logn(e)*ln(r)
; return_2 = st0 = b' = logn(e)*t

macro @@clogn.sse.fpu
{
$usprocf @@clogn

        movsd   xmm0, qword [rsp]               ; xmm0 = n
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = a
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = b
   .enter:
        @@.fld.xmm0
        @@.fld.xmm1
        @@.fld.xmm2                             ; st0 = b       | st1 = a     | st2 = n
        ;
   .cln.enter:
        fld     st1                             ; st0 = a       | st1 = b     | st2 = a     | st3 = n
        fld     st1                             ; st0 = b       | st1 = a     | st2 = b     | st3 = a | st4 = n
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r       | st1 = b     | st2 = a     | st3 = n
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)   | st1 = b     | st2 = a     | st3 = n
   .ln.r.leave:
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = ln(r) | st3 = n
        fpatan                                  ; st0 = t       | st1 = ln(r) | st2 = n
   .cln.leave:
        fxch                                    ; st0 = ln(r)   | st1 = t     | st2 = n
        fxch    st2                             ; st0 = n       | st1 = t     | st2 = ln(r)
   .ln.n.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(n)   | st1 = t     | st2 = ln(r)
   .ln.n.leave:
        fld1
        fdivrp                                  ; st0 = logn(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = logn(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'      | st2 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@clogn.fpu
{
$usprocf @@clogn

        fld     qword [rsp]                     ; load n
        fld     qword [rsp + 8]                 ; load a
        fld     qword [rsp + 16]                ; load b
   .enter:                                      ; st0 = b       | st1 = a     | st2 = n
   .cln.enter:
        fld     st1                             ; st0 = a       | st1 = b     | st2 = a     | st3 = n
        fld     st1                             ; st0 = b       | st1 = a     | st2 = b     | st3 = a | st4 = n
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r       | st1 = b     | st2 = a     | st3 = n
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)   | st1 = b     | st2 = a     | st3 = n
   .ln.r.leave:
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = ln(r) | st3 = n
        fpatan                                  ; st0 = t       | st1 = ln(r) | st2 = n
   .cln.leave:
        fxch                                    ; st0 = ln(r)   | st1 = t     | st2 = n
        fxch    st2                             ; st0 = n       | st1 = t     | st2 = ln(r)
   .ln.n.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(n)   | st1 = t     | st2 = ln(r)
   .ln.n.leave:
        fld1
        fdivrp                                  ; st0 = logn(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = logn(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'      | st2 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@clogn.sse.fpu
$else
  @@clogn.fpu
$end

; ------------------------------------------------------------------------------

; reverse complex base-n logarithm
; z = a + i•b = r*exp(i•t)
; clognr(a,b,n) = logn(e)*(ln(r) + i•t)
;
; rsp + 0  = a
; rsp + 8  = b
; rsp + 16 = n
;
; return_1 = st1 = a' = logn(e)*ln(r)
; return_2 = st0 = b' = logn(e)*t

macro @@clognr.sse.fpu
{
$usprocf @@clognr

        movsd   xmm0, qword [rsp]               ; xmm0 = a
        movsd   xmm1, qword [rsp + 8]           ; xmm1 = b
        movsd   xmm2, qword [rsp + 16]          ; xmm2 = n
   .enter:                                      ; st0 = n       | st1 = b     | st2 = a
        @@.fld.xmm2
        @@.fld.xmm0
        @@.fld.xmm1                             ; st0 = b       | st1 = a     | st2 = n
        ;
   .clogn:
   .cln.enter:
        fld     st1                             ; st0 = a       | st1 = b     | st2 = a     | st3 = n
        fld     st1                             ; st0 = b       | st1 = a     | st2 = b     | st3 = a | st4 = n
        mov     rdx, @@cabs.enter.fpu
        call    rdx                             ; st0 = r       | st1 = b     | st2 = a     | st3 = n
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)   | st1 = b     | st2 = a     | st3 = n
   .ln.r.leave:
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = ln(r) | st3 = n
        fpatan                                  ; st0 = t       | st1 = ln(r) | st2 = n
   .cln.leave:
        fxch                                    ; st0 = ln(r)   | st1 = t     | st2 = n
        fxch    st2                             ; st0 = n       | st1 = t     | st2 = ln(r)
   .ln.n.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(n)   | st1 = t     | st2 = ln(r)
   .ln.n.leave:
        fld1
        fdivrp                                  ; st0 = logn(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = logn(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'      | st2 = a'
   .return:
        @@.fstp.xmm1
        @@.fstp.xmm0
        retn
$endp
}

macro @@clognr.fpu
{
$usprocf @@clognr

        fld     qword [rsp]                     ; load a
        fld     qword [rsp + 8]                 ; load b
        fld     qword [rsp + 16]                ; load n
   .enter:                                      ; st0 = n       | st1 = b     | st2 = a
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = n
        fxch                                    ; st0 = b       | st1 = a     | st2 = n
   .clogn:
   .cln.enter:
        fld     st1                             ; st0 = a       | st1 = b     | st2 = a     | st3 = n
        fld     st1                             ; st0 = b       | st1 = a     | st2 = b     | st3 = a | st4 = n
        mov     rdx, @@cabs.enter
        call    rdx                             ; st0 = r       | st1 = b     | st2 = a     | st3 = n
   .ln.r.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(r)   | st1 = b     | st2 = a     | st3 = n
   .ln.r.leave:
        fxch    st2                             ; st0 = a       | st1 = b     | st2 = ln(r) | st3 = n
        fpatan                                  ; st0 = t       | st1 = ln(r) | st2 = n
   .cln.leave:
        fxch                                    ; st0 = ln(r)   | st1 = t     | st2 = n
        fxch    st2                             ; st0 = n       | st1 = t     | st2 = ln(r)
   .ln.n.enter:
        fldln2
        fxch
        fyl2x                                   ; st0 = ln(n)   | st1 = t     | st2 = ln(r)
   .ln.n.leave:
        fld1
        fdivrp                                  ; st0 = logn(e) | st1 = t     | st2 = ln(r)
        fmul    st2, st0                        ; st0 = logn(e) | st1 = t     | st2 = a'
        fmulp                                   ; st0 = b'      | st2 = a'
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@clognr.sse.fpu
$else
  @@clognr.fpu
$end

; ------------------------------------------------------------------------------
