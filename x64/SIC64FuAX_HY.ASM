
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate hyperbolic functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; include '..\xCommon\SICFuCO_AX_hyp.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; hyperbolic sine
; sinh(x)

; sinh(x) = (exp(x) - exp(-x))/2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fsinh.sse
{
$asprocf @@fsinh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_fsinh_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 5*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 6*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 7*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 8*16]              ; xmm4 = P:Q
        ;
        movapd  xmm5, xmm4                      ; xmm5 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm5, xmm4                      ; xmm5 = P/Q
        mulsd   xmm0, xmm5                      ; xmm0 = x*P/Q

   .return:
        retn
$endp

; sinh = [exp(x)/2] - (1/[exp(x)/2])/4
$asprocf @@fsinh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sinh.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fsinh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5                      ; xmm0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; xmm0 = exp(x)/2
        ;
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 2/exp(-x)
        xmovsd  xmm4, SIC_AX.0.25
        mulsd   xmm5, xmm4                      ; xmm5 = exp(-x)/2
        subsd   xmm0, xmm5
        jmp    .return

   .L.PQ:
        mov     rbx, @@fsinh.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@fsinh.fpu
{
$asprocf @@fsinh.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2    | st1 = x

        mov     rdx, ??.SD_fsinh_Pn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmul    st0, st1
        fadd    qword [rdx + 8*8]               ; st0 = P      | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_fsinh_Qn
        fxch                                    ; st0 = x^2    | st1 = P   | st2 = x
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q      | st1 = P   | st2 = x
        ;
        fdivp                                   ; st0 = P/Q    | st1 = x
        fmulp                                   ; st0 = x*P/Q

   .return:
        retn
$endp

; sinh = [exp(x)/2] - (1/[exp(x)/2])/4
$asprocf @@fsinh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sinh.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fsinh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fmulq   SIC_AX.log2.e
        fld1
        fsubp                                   ; st0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; st0 = exp(x)/2
        ;
        fld1
        fdiv    st0, st1                        ; st0 = 2/exp(-x) | st1 = exp(x)/2
        fmulq   SIC_AX.0.25                     ; st0 = exp(-x)/2 | st1 = exp(x)/2
        fsubp
        jmp    .return

   .L.PQ:
        mov     rbx, @@fsinh.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsinh.sse
$else
  @@fsinh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine
; cosh(x)

; cosh(x) = (exp(x) + exp(-x))/2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fcosh.sse
{
$asprocf @@fcosh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_fcosh_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 5*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 6*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 7*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 8*16]              ; xmm4 = P:Q
        ;
        movapd  xmm0, xmm4                      ; xmm0 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm0, xmm4                      ; xmm0 = P/Q

   .return:
        retn
$endp

; cosh = [exp(x)/2] + (1/[exp(x)/2])/4
$asprocf @@fcosh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@cosh.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fcosh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5                      ; xmm0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; xmm0 = exp(x)/2
        ;
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 2/exp(-x)
        xmovsd  xmm4, SIC_AX.0.25
        mulsd   xmm5, xmm4                      ; xmm5 = exp(-x)/2
        addsd   xmm0, xmm5
        jmp    .return

   .L.PQ:
        mov     rbx, @@fcosh.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@fcosh.fpu
{
$asprocf @@fcosh.PQ

   .main:
        fmul    st0, st0                        ; st0 = x^2

        mov     rdx, ??.SD_fcosh_Pn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmul    st0, st1
        fadd    qword [rdx + 8*8]               ; st0 = P      | st1 = x^2
        ;
        mov     rdx, ??.SD_fcosh_Qn
        fxch                                    ; st0 = x^2    | st1 = P
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q      | st1 = P
        ;
        fdivp                                   ; st0 = P/Q

   .return:
        retn
$endp

; cosh = [exp(x)/2] + (1/[exp(x)/2])/4
$asprocf @@fcosh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@cosh.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fcosh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fmulq   SIC_AX.log2.e
        fld1
        fsubp                                   ; st0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; st0 = exp(x)/2
        ;
        fld1
        fdiv    st0, st1                        ; st0 = 2/exp(-x) | st1 = exp(x)/2
        fmulq   SIC_AX.0.25                     ; st0 = exp(-x)/2 | st1 = exp(x)/2
        faddp
        jmp    .return

   .L.PQ:
        mov     rbx, @@fcosh.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fcosh.sse
$else
  @@fcosh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic sine and cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fshch.sse
{
$asprocf @@fshch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sinhcosh.arg             ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fsinhcosh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5                      ; xmm0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; xmm0 = exp(x)/2
        xmovx   xmm1, xmm0                      ; xmm1 = exp(x)/2
        ;
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 2/exp(-x)
        xmovsd  xmm4, SIC_AX.0.25
        mulsd   xmm5, xmm4                      ; xmm5 = exp(-x)/2
        subsd   xmm0, xmm5                      ; xmm0 = sinh
        addsd   xmm1, xmm5                      ; xmm1 = cosh
        jmp    .return

   .L.PQ:
        xmovx   xmm1, xmm0
        mov     rbx, @@fcosh.PQ
        call    rbx                             ; xmm0 = cosh | xmm1 = x
        @@.xch  xmm0, xmm1                      ; xmm0 = x    | xmm1 = cosh
        mov     rbx, @@fsinh.PQ
        call    rbx                             ; xmm0 = sinh | xmm1 = cosh

   .return:
        retn
$endp

; hyperbolic sine & cosine
; double co.fshch ( double *sinh, double *cosh, double x )
;
; x = rsp
;
; rax = sinh offset
; rdx = cosh offset
;
; return_1 = st1 = sinh
; return_2 = st0 = cosh
;
; return   = st0 = sinh

$asprocf @@co.fshch

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    rax rdx
        ;
        mov     rbx, @@fshch.enter
        call    rbx
        ;
        pop     rdx rax
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
   .return:
        retn
$endp
}

macro @@fshch.fpu
{
$asprocf @@fshch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sinhcosh.arg             ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fsinhcosh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fmulq   SIC_AX.log2.e
        fld1
        fsubp                                   ; st0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; st0 = exp(x)/2
        ;
        fld1
        fdiv    st0, st1                        ; st0 = 2/exp(-x) | st1 = exp(x)/2
        fmulq   SIC_AX.0.25                     ; st0 = exp(-x)/2 | st1 = exp(x)/2
        fld     st1
        fxch                                    ; st0 = exp(-x)/2 | st1 = exp(x)/2 | st2 = exp(x)/2
        fsub    st2, st0
        faddp                                   ; st0 = cosh      | st1 = sinh
        jmp    .return

   .L.PQ:
        fld     st0
        mov     rbx, @@fsinh.PQ
        call    rbx                             ; st0 = sinh | st1 = x
        fxch                                    ; st0 = x    | st1 = sinh
        mov     rbx, @@fcosh.PQ
        call    rbx                             ; st0 = cosh | st1 = sinh

   .return:
        retn
$endp

; hyperbolic sine & cosine
; double co.fshch ( double *sinh, double *cosh, double x )
;
; x = rsp
;
; rax = sinh offset
; rdx = cosh offset
;
; return_1 = st1 = sinh
; return_2 = st0 = cosh
;
; return   = st0 = sinh

$asprocf @@co.fshch

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    rax rdx
        ;
        mov     rbx, @@fshch.enter
        call    rbx
        ;
        pop     rdx rax
        fstp    qword [rdx]
        fst     qword [rax]
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fshch.sse
$else
  @@fshch.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosine and sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fchsh.sse
{
$asprocf @@fchsh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@coshsinh.arg             ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fcoshsinh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5                      ; xmm0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; xmm0 = exp(x)/2
        xmovx   xmm1, xmm0                      ; xmm1 = exp(x)/2
        ;
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = 2/exp(-x)
        xmovsd  xmm4, SIC_AX.0.25
        mulsd   xmm5, xmm4                      ; xmm5 = exp(-x)/2
        addsd   xmm0, xmm5                      ; xmm0 = cosh
        subsd   xmm1, xmm5                      ; xmm1 = sinh
        jmp    .return

   .L.PQ:
        xmovx   xmm1, xmm0
        mov     rbx, @@fsinh.PQ
        call    rbx                             ; xmm0 = sinh | xmm1 = x
        @@.xch  xmm0, xmm1                      ; xmm0 = x    | xmm1 = sinh
        mov     rbx, @@fcosh.PQ
        call    rbx                             ; xmm0 = cosh | xmm1 = sinh

   .return:
        retn
$endp

; hyperbolic cosine & sine
; double co.fchsh ( double *cosh, double *sinh, double x )
;
; x = rsp
;
; rax = cosh offset
; rdx = sinh offset
;
; return_1 = st1 = cosh
; return_2 = st0 = sinh
;
; return   = st0 = cosh

$asprocf @@co.fchsh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    rax rdx
        ;
        mov     rbx, @@fchsh.enter
        call    rbx
        ;
        pop     rdx rax
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
   .return:
        retn
$endp
}

macro @@fchsh.fpu
{
$asprocf @@fchsh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@coshsinh.arg             ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fcoshsinh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fmulq   SIC_AX.log2.e
        fld1
        fsubp                                   ; st0 = x*log2(e)-1
        mov     rbx, @@fexp.core
        call    rbx                             ; st0 = exp(x)/2
        ;
        fld1
        fdiv    st0, st1                        ; st0 = 2/exp(-x) | st1 = exp(x)/2
        fmulq   SIC_AX.0.25                     ; st0 = exp(-x)/2 | st1 = exp(x)/2
        fld     st1
        fxch                                    ; st0 = exp(-x)/2 | st1 = exp(x)/2 | st2 = exp(x)/2
        fadd    st2, st0
        fsubp                                   ; st0 = sinh      | st1 = cosh
        jmp    .return

   .L.PQ:
        fld     st0
        mov     rbx, @@fcosh.PQ
        call    rbx                             ; st0 = cosh | st1 = x
        fxch                                    ; st0 = x    | st1 = cosh
        mov     rbx, @@fsinh.PQ
        call    rbx                             ; st0 = sinh | st1 = cosh

   .return:
        retn
$endp

; hyperbolic cosine & sine
; double co.fchsh ( double *cosh, double *sinh, double x )
;
; x = rsp
;
; rax = cosh offset
; rdx = sinh offset
;
; return_1 = st1 = cosh
; return_2 = st0 = sinh
;
; return   = st0 = cosh

$asprocf @@co.fchsh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    rax rdx
        ;
        mov     rbx, @@fchsh.enter
        call    rbx
        ;
        pop     rdx rax
        fstp    qword [rdx]
        fst     qword [rax]
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fchsh.sse
$else
  @@fchsh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic secant
; 1/cosh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fsech.sse
{
$asprocf @@fsech

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sech.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        mov     rbx, @@fcosh.core
        call    rbx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fsech.fpu
{
$asprocf @@fsech

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sech.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        mov     rbx, @@fcosh.core
        call    rbx
        fld1
        fdivrp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsech.sse
$else
  @@fsech.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cosecant
; 1/sinh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fcosech.sse
{
$asprocf @@fcosech

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@cosech.arg               ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        mov     rbx, @@fsinh.core
        call    rbx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fcosech.fpu
{
$asprocf @@fcosech

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@cosech.arg               ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        mov     rbx, @@fsinh.core
        call    rbx
        fld1
        fdivrp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fcosech.sse
$else
  @@fcosech.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic tangent
; tanh(x)

; tanh(x) = sinh(x)/cosh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ftanh.sse
{
$asprocf @@ftanh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_ftanh_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 5*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 6*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 7*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 8*16]              ; xmm4 = P:Q
        ;
        movapd  xmm5, xmm4                      ; xmm5 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm5, xmm4                      ; xmm5 = P/Q
        mulsd   xmm0, xmm5                      ; xmm0 = x*P/Q

   .return:
        retn
$endp

$asprocf @@ftanh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@tanh.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.ftanh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        mov     rbx, @@fexp.core
        call    rbx                             ; xmm0 = exp(x)
        ;
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = exp(-x)
        xmovx   xmm4, xmm0
        subsd   xmm0, xmm5
        addsd   xmm4, xmm5
        divsd   xmm0, xmm4
        jmp    .return

   .L.PQ:
        mov     rbx, @@ftanh.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@ftanh.fpu
{
$asprocf @@ftanh.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2    | st1 = x

        mov     rdx, ??.SD_ftanh_Pn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmul    st0, st1
        fadd    qword [rdx + 8*8]               ; st0 = P      | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_ftanh_Qn
        fxch                                    ; st0 = x^2    | st1 = P   | st2 = x
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q      | st1 = P   | st2 = x
        ;
        fdivp                                   ; st0 = P/Q    | st1 = x
        fmulp                                   ; st0 = x*P/Q

   .return:
        retn
$endp

$asprocf @@ftanh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@tanh.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.ftanh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fmulq   SIC_AX.log2.e
        mov     rbx, @@fexp.core
        call    rbx                             ; st0 = exp(x)
        ;
        fld1
        fdiv    st0, st1                        ; st0 = exp(-x)        | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = exp(-x)        | st1 = exp(x)  | st2 = exp(-x) | st3 = exp(x)
        fsubp                                   ; st0 = exp(x)-exp(-x) | st1 = exp(-x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)         | st1 = exp(-x) | st2 = exp(x)-exp(-x)
        faddp
        fdivp
        jmp    .return

   .L.PQ:
        mov     rbx, @@ftanh.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ftanh.sse
$else
  @@ftanh.fpu
$end

; ------------------------------------------------------------------------------

; hyperbolic cotangent
; cotanh(x)

; cotanh(x) = cosh(x)/sinh(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fcotanh.sse
{
$asprocf @@fcotanh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_fcoth_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 5*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 6*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 7*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 8*16]              ; xmm4 = P:Q
        ;
        movapd  xmm5, xmm4                      ; xmm5 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm5, xmm4                      ; xmm5 = P/Q
        mulsd   xmm0, xmm5                      ; xmm0 = x*P/Q

   .return:
        retn
$endp

$asprocf @@fcotanh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@cotanh.arg               ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fcoth_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        mov     rbx, @@fexp.core
        call    rbx                             ; xmm0 = exp(x)
        ;
        xmovsd  xmm5, SIC_AX.1.0
        divsd   xmm5, xmm0                      ; xmm5 = exp(-x)
        xmovx   xmm4, xmm0
        addsd   xmm0, xmm5
        subsd   xmm4, xmm5
        divsd   xmm0, xmm4
        jmp    .return

   .L.PQ:
        xmovsd  xmm3, SIC_AX.1.0
        divsd   xmm3, xmm0
        mov     rbx, @@fcotanh.PQ
        call    rbx
        addsd   xmm0, xmm3

   .return:
        retn
$endp
}

macro @@fcotanh.fpu
{
$asprocf @@fcotanh.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2    | st1 = x

        mov     rdx, ??.SD_fcoth_Pn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmul    st0, st1
        fadd    qword [rdx + 8*8]               ; st0 = P      | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_fcoth_Qn
        fxch                                    ; st0 = x^2    | st1 = P   | st2 = x
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q      | st1 = P   | st2 = x
        ;
        fdivp                                   ; st0 = P/Q    | st1 = x
        fmulp                                   ; st0 = x*P/Q

   .return:
        retn
$endp

$asprocf @@fcotanh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@cotanh.arg               ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fcoth_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fmulq   SIC_AX.log2.e
        mov     rbx, @@fexp.core
        call    rbx                             ; st0 = exp(x)
        ;
        fld1
        fdiv    st0, st1                        ; st0 = exp(-x)        | st1 = exp(x)
        fld     st1
        fld     st1                             ; st0 = exp(-x)        | st1 = exp(x)  | st2 = exp(-x) | st3 = exp(x)
        faddp                                   ; st0 = exp(x)+exp(-x) | st1 = exp(-x) | st2 = exp(x)
        fxch    st2                             ; st0 = exp(x)         | st1 = exp(-x) | st2 = exp(x)+exp(-x)
        fsubrp
        fdivp
        jmp    .return

   .L.PQ:
        fld     st0
        fld1
        fdivrp
        fxch
        mov     rbx, @@fcotanh.PQ
        call    rbx
        faddp

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fcotanh.sse
$else
  @@fcotanh.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; include '..\xCommon\SICFuCO_AX_ahyp.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; inverse hyperbolic sine
; asinh(x)

; asinh(x) = ln(x+sqrt(x^2+1))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fasinh.sse
{
$asprocf @@fasinh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_fasinh_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]              ; xmm4 = P:Q
        ;
        mulsd   xmm4, xmm5                      ; xmm4 = P'/Q = (x^2)*P/Q
        movapd  xmm5, xmm4                      ; xmm5 = P':Q
;       psrldq  xmm5, 8                         ; xmm5 = Q:0
        shufpd  xmm5, xmm5, 1                   ; xmm5 = Q:P'
        divsd   xmm4, xmm5                      ; xmm4 = P'/Q
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm4, xmm5
        mulsd   xmm0, xmm4
   .return:
        retn
$endp

$asprocf @@fasinh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@asinh.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fasinh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovx   xmm5, xmm0
        mulsd   xmm5, xmm5
        xmovsd  xmm4, SIC_AX.1.0
        addsd   xmm5, xmm4
        sqrtsd  xmm5, xmm5
        addsd   xmm0, xmm5
        ;
        mov     rbx, @@floge.enter
        call    rbx
        jmp    .return

   .L.PQ:
        mov     rbx, @@fasinh.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@fasinh.fpu
{
$asprocf @@fasinh.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2  | st1 = x

        mov     rdx, ??.SD_fasinh_Pn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]               ; st0 = P    | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_fasinh_Qn
        fxch                                    ; st0 = x^2  | st1 = P   | st2 = x
        fld     st0                             ; Q0 = 1.0
;       fld     qword [rdx + 0*8]
;       fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]               ; st0 = Q    | st1 = x^2 | st2 = P | st3 = x
        ;
        fdivp   st2, st0                        ; st0 = x^2  | st0 = P/Q | st1 = x
        fmulp
        fld1
        faddp
        fmulp
   .return:
        retn
$endp

$asprocf @@fasinh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@asinh.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fasinh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fld     st0
        fmul    st0, st0
        fld1
        faddp
        fsqrt
        faddp
        ;
        mov     rbx, @@floge.enter
        call    rbx
        jmp    .return

   .L.PQ:
        mov     rbx, @@fasinh.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fasinh.sse
$else
  @@fasinh.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cosine
; acosh(x)

; acosh(x) = ln(x+sqrt(x^2-1))
; x >= 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@facosh.sse
{
$asprocf @@facosh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x

        mov     rdx, ??.PD_facosh_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 5*16]              ; xmm4 = P:Q
        ;
        movapd  xmm5, xmm4                      ; xmm5 = P:Q
;       psrldq  xmm5, 8                         ; xmm5 = Q:0
        shufpd  xmm5, xmm5, 1                   ; xmm5 = Q:P
        divsd   xmm4, xmm5                      ; xmm4 = P/Q
        sqrtsd  xmm0, xmm0
        mulsd   xmm0, xmm4
   .return:
        retn
$endp

$asprocf @@facosh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@acosh.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovsd  xmm5, ??.facosh_range
        comisd  xmm0, xmm5                      ; compare x to ??.range
        jb     .L.PQ                            ; jump if x < ??.range

   .LF:
        xmovx   xmm5, xmm0
        mulsd   xmm5, xmm5
        xmovsd  xmm4, SIC_AX.1.0
        subsd   xmm5, xmm4
        sqrtsd  xmm5, xmm5
        addsd   xmm0, xmm5
        ;
        mov     rbx, @@floge.enter
        call    rbx
        jmp    .return

   .L.PQ:
        xmovsd  xmm5, SIC_AX.1.0
        subsd   xmm0, xmm5
        mov     rbx, @@facosh.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@facosh.fpu
{
$asprocf @@facosh.PQ

   .main:
        fld     st0                             ; st0 = x    | st1 = x

        mov     rdx, ??.SD_facosh_Pn
        fld     qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]               ; st0 = P    | st1 = x   | st2 = x
        ;
        mov     rdx, ??.SD_facosh_Qn
        fxch                                    ; st0 = x    | st1 = P   | st2 = x
        fld     st0                             ; Q0 = 1.0
;       fld     qword [rdx + 0*8]
;       fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmulp
        fadd    qword [rdx + 5*8]               ; st0 = Q    | st1 = P   | st2 = x
        ;
        fdivp                                   ; st0 = P/Q  | st1 = x
        fxch                                    ; st0 = x    | st1 = P/Q
        fsqrt
        fmulp
   .return:
        retn
$endp

$asprocf @@facosh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@acosh.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fldq    ??.facosh_range
        fcompp                                  ; compare ??.range to x
        fnjg   .L.PQ                            ; jump if x < ??.range (??.range > x)

   .LF:
        fld     st0
        fmul    st0, st0
        fld1
        fsubp
        fsqrt
        faddp
        ;
        mov     rbx, @@floge.enter
        call    rbx
        jmp    .return

   .L.PQ:
        fld1
        fsubp
        mov     rbx, @@facosh.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@facosh.sse
$else
  @@facosh.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic secant
; acosh(1/x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fasech.sse
{
$asprocf @@fasech

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@asech.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        mov     rbx, @@facosh.enter
;       mov     rbx, @@facosh.core
        call    rbx
   .return:
        retn
$endp
}

macro @@fasech.fpu
{
$asprocf @@fasech

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@asech.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld1
        fdivrp
        mov     rbx, @@facosh.core
        call    rbx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fasech.sse
$else
  @@fasech.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cosecant
; asinh(1/x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@facosech.sse
{
$asprocf @@facosech

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@acosech.arg              ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        mov     rbx, @@fasinh.enter
;       mov     rbx, @@fasinh.core
        call    rbx
   .return:
        retn
$endp
}

macro @@facosech.fpu
{
$asprocf @@facosech

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@acosech.arg              ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld1
        fdivrp
        mov     rbx, @@fasinh.core
        call    rbx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@facosech.sse
$else
  @@facosech.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic tangent
; atanh(x)

; atanh(x) = (1/2)*ln((1+x)/(1-x))
; |x| < 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fatanh.sse
{
$asprocf @@fatanh.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_fatanh_PQ
        movapd  xmm4, [rdx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 5*16]              ; xmm4 = P':Q
        ;
        movapd  xmm5, xmm4                      ; xmm5 = P':Q
;       psrldq  xmm5, 8                         ; xmm5 = Q:0
        shufpd  xmm5, xmm5, 1                   ; xmm5 = Q:P'
        divsd   xmm4, xmm5                      ; xmm4 = P'/Q
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm4, xmm5
        mulsd   xmm0, xmm4
   .return:
        retn
$endp

$asprocf @@fatanh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@atanh.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm4, xmm0
        @@.abs  xmm4
        xmovsd  xmm5, ??.fatanh_range
        comisd  xmm4, xmm5                      ; compare |x| to ??.range
        jb     .L.PQ                            ; jump if |x| < ??.range

   .LF:
        xmovsd  xmm4, SIC_AX.1.0
        xmovx   xmm5, xmm4
        subsd   xmm4, xmm0
        addsd   xmm0, xmm5
        divsd   xmm0, xmm4
        ;
        mov     rbx, @@floge.enter
        call    rbx
        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5
        jmp    .return

   .L.PQ:
        mov     rbx, @@fatanh.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@fatanh.fpu
{
$asprocf @@fatanh.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2  | st1 = x

        mov     rdx, ??.SD_fatanh_Pn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1                        ; st0 = P'   | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_fatanh_Qn
        fxch                                    ; st0 = x^2  | st1 = P'  | st2 = x
        fld     st0                             ; Q0 = 1.0
;       fld     qword [rdx + 0*8]
;       fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmulp
        fadd    qword [rdx + 5*8]               ; st0 = Q    | st1 = P'  | st2 = x
        ;
        fdivp                                   ; st0 = P'/Q | st1 = x
        fld1
        faddp
        fmulp
   .return:
        retn
$endp

$asprocf @@fatanh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@atanh.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.fatanh_range
        fcompp                                  ; compare ??.range to |x|
        fnjg   .L.PQ                            ; jump if |x| < ??.range (??.range > |x|)

   .LF:
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubrp
        fdivp
        ;
        mov     rbx, @@floge.enter
        call    rbx
        fmulq   SIC_AX.0.5
        jmp    .return

   .L.PQ:
        mov     rbx, @@fatanh.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fatanh.sse
$else
  @@fatanh.fpu
$end

; ------------------------------------------------------------------------------

; inverse hyperbolic cotangent
; acotanh(x)

; acotanh(x) = (1/2)*ln((x+1)/(x-1))
; |x| > 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@facotanh.sse
{
$asprocf @@facotanh

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@acotanh.arg              ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovsd  xmm4, SIC_AX.1.0
        xmovx   xmm5, xmm0
        subsd   xmm5, xmm4
        addsd   xmm0, xmm4
        divsd   xmm0, xmm5
        ;
        mov     rbx, @@floge.enter
        call    rbx
        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5

   .return:
        retn
$endp
}

macro @@facotanh.fpu
{
$asprocf @@facotanh

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@acotanh.arg              ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fld1
        faddp
        fxch
        fld1
        fsubp
        fdivp
        ;
        mov     rbx, @@floge.enter
        call    rbx
        fmulq   SIC_AX.0.5

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@facotanh.sse
$else
  @@facotanh.fpu
$end

; ------------------------------------------------------------------------------
