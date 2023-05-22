
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate special functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/ndtr.c
; Error function

; erf(x) = x * T(x^2)/U(x^2), |x| < 1
; erf(x) = 1 - erfc(x), |x| >= 1
;
; T =      5.55923013010394962768E+4 +  // T5
;   (x^2)*(7.00332514112805075473E+3 +  // T4
;   (x^2)*(2.23200534594684319226E+3 +  // T3
;   (x^2)*(9.00260197203842689217E+1 +  // T2
;   (x^2)*(9.60497373987051638749E+0 +  // T1
;   (x^2)*(0.00000000000000000000E+0 )) // T0
;
; U =      4.92673942608635921086E+4 +  // U5
;   (x^2)*(2.26290000613890934246E+4 +  // U4
;   (x^2)*(4.59432382970980127987E+3 +  // U3
;   (x^2)*(5.21357949780152679795E+2 +  // U2
;   (x^2)*(3.35617141647503099647E+1 +  // U1
;   (x^2)*(1.00000000000000000000E+0 )) // U0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_ndtr.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ferf.sse
{
$asprocf @@ferf

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erf.arg                  ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm5, xmm0
        @@.abs  xmm5                            ; xmm5 = |x|
        xmovsd  xmm4, SIC_AX.1.0
        comisd  xmm5, xmm4                      ; compare |x| to 1.0
        jb     .L.TU

   .LF:                                         ; |x| >= 1.0
        mov     rbx, @@ferfc.core               ; erf(x) = 1 - erfc(x)
        call    rbx
        xmovx   xmm1, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm1
        jmp    .return

   .L.TU:                                       ; |x| < 1.0
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_ferf_TU
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
        addpd   xmm4, [rdx + 5*16]              ; xmm4 = T:U
        ;
        movapd  xmm5, xmm4                      ; xmm5 = T:U
;       psrldq  xmm5, 8                         ; xmm5 = U:0
        shufpd  xmm5, xmm5, 1                   ; xmm5 = U*T
        mulsd   xmm0, xmm4                      ; xmm0 = x*T
        divsd   xmm0, xmm5                      ; xmm0 = x*T/U

   .return:
        retn
$endp
}

macro @@ferf.fpu
{
$asprocf @@ferf

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erf.arg                  ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fld1                                    ; st0 = 1 | st1 = |x| | st2 = x
        fcompp                                  ; compare 1.0 to |x|
        fnjg   .L.TU                            ; jump if |x| < 1.0 (1.0 > |x|)

   .LF:                                         ; |x| >= 1.0
        mov     rbx, @@ferfc.core               ; erf(x) = 1 - erfc(x)
        call    rbx
        fld1
        fsubrp
        jmp    .return

   .L.TU:                                       ; |x| < 1.0
        fld     st0
        fmul    st0, st0                        ; st0 = x^2   | st1 = x

        mov     rdx, ??.SD_ferf_Tn
        fld     qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]               ; st0 = T     | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_ferf_Un
        fxch                                    ; st0 = x^2   | st1 = T   | st2 = x
        fld     st0                             ; U0 = 1.0
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
        fadd    qword [rdx + 5*8]               ; st0 = U     | st1 = T   | st2 = x
        ;
        fdivp                                   ; st0 = T/U   | st1 = x
        fmulp                                   ; st0 = x*T/U

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ferf.sse
$else
  @@ferf.fpu
$end

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/ndtr.c
; Complementary error function

; erfc(x) = exp(-x^2) * P(x)/Q(x), 1 <= |x| < 8
; erfc(x) = exp(-x^2) * R(x)/S(x), |x| >= 8
; erfc(x) = 1 - erf(x), |x| < 1
;
; P =    5.57535335369399327526E+2 +    // P8
;   (x)*(1.02755188689515710272E+3 +    // P7
;   (x)*(9.34528527171957607540E+2 +    // P6
;   (x)*(5.26445194995477358631E+2 +    // P5
;   (x)*(1.96520832956077098242E+2 +    // P4
;   (x)*(4.86371970985681366614E+1 +    // P3
;   (x)*(7.46321056442269912687E+0 +    // P2
;   (x)*(5.64189564831068821977E-1 +    // P1
;   (x)*(2.46196981473530512524E-10))   // P0
;
; Q =    5.57535340817727675546E+2 +    // Q8
;   (x)*(1.65666309194161350182E+3 +    // Q7
;   (x)*(2.24633760818710981792E+3 +    // Q6
;   (x)*(1.82390916687909736289E+3 +    // Q5
;   (x)*(9.75708501743205489753E+2 +    // Q4
;   (x)*(3.54937778887819891062E+2 +    // Q3
;   (x)*(8.67072140885989742329E+1 +    // Q2
;   (x)*(1.32281951154744992508E+1 +    // Q1
;   (x)*(1.00000000000000000000E+0 ))   // Q0
;
; R =    2.97886665372100240670E+0 +    // R6
;   (x)*(7.40974269950448939160E+0 +    // R5
;   (x)*(6.16021097993053585195E+0 +    // R4
;   (x)*(5.01905042251180477414E+0 +    // R3
;   (x)*(1.27536670759978104416E+0 +    // R2
;   (x)*(5.64189583547755073984E-1 +    // R1
;   (x)*(0.00000000000000000000E+0 ))   // R0
;
; S =    3.36907645100081516050E+0 +    // S6
;   (x)*(9.60896809063285878198E+0 +    // S5
;   (x)*(1.70814450747565897222E+1 +    // S4
;   (x)*(1.20489539808096656605E+1 +    // S3
;   (x)*(9.39603524938001434673E+0 +    // S2
;   (x)*(2.26052863220117276590E+0 +    // S1
;   (x)*(1.00000000000000000000E+0 ))   // S0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ferfc.sse
{
$asprocf @@ferfc.PQ

   .sign.bits:
        movmskpd ecx, xmm0                      ; ecx = sign bits
        @@.abs  xmm0

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x

        mov     rdx, ??.PD_ferfc_PQ
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
        movapd  xmm1, xmm4                      ; xmm1 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm1, xmm4                      ; xmm1 = P/Q
        ;
        mulsd   xmm0, xmm0
        @@.chs  xmm0
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        mov     rbx, @@fexp.core
        call    rbx
        mulsd   xmm0, xmm1

        test    ecx, 1                          ; if x < 0 { y = 2.0 - y }
        jp     .return
        xmovx   xmm1, xmm0
        xmovsd  xmm0, SIC_AX.2.0
        subsd   xmm0, xmm1

   .return:
        retn
$endp

$asprocf @@ferfc.RS

   .sign.bits:
        movmskpd ecx, xmm0                      ; ecx = sign bits
        @@.abs  xmm0

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x

        mov     rdx, ??.PD_ferfc_RS
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
        addpd   xmm4, [rdx + 6*16]              ; xmm4 = R:S
        ;
        movapd  xmm1, xmm4                      ; xmm1 = R:S
;       psrldq  xmm4, 8                         ; xmm4 = S:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = S*R
        divsd   xmm1, xmm4                      ; xmm1 = R/S
        ;
        mulsd   xmm0, xmm0
        @@.chs  xmm0
        xmovsd  xmm5, SIC_AX.log2.e
        mulsd   xmm0, xmm5
        mov     rbx, @@fexp.core
        call    rbx
        mulsd   xmm0, xmm1

        test    ecx, 1                          ; if x < 0 { y = 2.0 - y }
        jp     .return
        xmovx   xmm1, xmm0
        xmovsd  xmm0, SIC_AX.2.0
        subsd   xmm0, xmm1

   .return:
        retn
$endp

$asprocf @@ferfc

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfc.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm3, xmm0
        @@.abs  xmm3                            ; xmm3 = |x|
        xmovsd  xmm4, SIC_AX.1.0
        comisd  xmm3, xmm4                      ; compare |x| to 1.0
        jae    .L0

   .LL:                                         ; |x| < 1.0
        mov     rbx, @@ferf.core                ; erfc(x) = 1 - erf(x)
        call    rbx
        xmovx   xmm1, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm1
        jmp    .return

   .L0:                                         ; |x| >= 1.0
        xmovsd  xmm4, SIC_AX.8.0
        comisd  xmm3, xmm4                      ; compare |x| to 8.0
        jb     .L0.PQ                           ; jump if |x| < 8.0

   .L0.RS:                                      ; |x| >= 8.0
        mov     rbx, @@ferfc.RS
        call    rbx
        jmp    .return
   .L0.PQ:                                      ; |x| < 8.0
        mov     rbx, @@ferfc.PQ
        call    rbx

   .return:
        retn
$endp
}

macro @@ferfc.fpu
{
$asprocf @@ferfc.PQ

   .sign.bits:
        xor     ecx, ecx                        ; ecx = sign bit
        ftst
        fnjge  .main
        inc     ecx
        fchs

   .main:
        fld     st0                             ; st0 = x    | st1 = x

        mov     rdx, ??.SD_ferfc_Pn
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
        fadd    qword [rdx + 8*8]               ; st0 = P    | st1 = x   | st2 = x
        ;
        mov     rdx, ??.SD_ferfc_Qn
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
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q    | st1 = P   | st2 = x
        ;
        fdivp                                   ; st0 = P/Q  | st1 = x
        ;
        fxch                                    ; st0 = x    | st1 = P/Q
        fmul    st0, st0
        fchs                                    ; st0 = -x^2 | st1 = P/Q
        fmulq   SIC_AX.log2.e
        mov     rbx, @@fexp.core
        call    rbx
        fmulp

        test    ecx, 1                          ; if x < 0 { y = 2.0 - y }
        jp     .return
        fsubrq  SIC_AX.2.0

   .return:
        retn
$endp

$asprocf @@ferfc.RS

   .sign.bits:
        xor     ecx, ecx                        ; ecx = sign bit
        ftst
        fnjge  .main
        inc     ecx
        fchs

   .main:
        fld     st0                             ; st0 = x    | st1 = x

        mov     rdx, ??.SD_ferfc_Rn
        fld     qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]               ; st0 = R    | st1 = x   | st2 = x
        ;
        mov     rdx, ??.SD_ferfc_Sn
        fxch                                    ; st0 = x    | st1 = R   | st2 = x
        fld     st0                             ; S0 = 1.0
;       fld     qword [rdx + 0*8]
;       fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmulp
        fadd    qword [rdx + 6*8]               ; st0 = S    | st1 = R   | st2 = x
        ;
        fdivp                                   ; st0 = R/S  | st1 = x
        ;
        fxch                                    ; st0 = x    | st1 = R/S
        fmul    st0, st0
        fchs                                    ; st0 = -x^2 | st1 = R/S
        fmulq   SIC_AX.log2.e
        mov     rbx, @@fexp.core
        call    rbx
        fmulp

        test    ecx, 1                          ; if x < 0 { y = 2.0 - y }
        jp     .return
        fsubrq  SIC_AX.2.0

   .return:
        retn
$endp

$asprocf @@ferfc

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfc.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fld1                                    ; st0 = 1 | st1 = |x| | st2 = x
        fcompp                                  ; compare 1.0 to |x|
        fnjle  .L0                              ; jump if |x| >= 1.0 (1.0 <= |x|)

   .LL:                                         ; |x| < 1.0
        mov     rbx, @@ferf.core                ; erfc(x) = 1 - erf(x)
        call    rbx
        fld1
        fsubrp
        jmp    .return

   .L0:                                         ; |x| >= 1.0
        fld     st0
        fabs
        fldq    SIC_AX.8.0
        fcompp                                  ; compare 8.0 to |x|
        fnjg   .L0.PQ                           ; jump if |x| < 8.0 (8.0 > |x|)

   .L0.RS:                                      ; |x| >= 8.0
        mov     rbx, @@ferfc.RS
        call    rbx
        jmp    .return
   .L0.PQ:                                      ; |x| < 8.0
        mov     rbx, @@ferfc.PQ
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ferfc.sse
$else
  @@ferfc.fpu
$end

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/ndtr.c
; Normal distribution function

; ndtr(x) = (1 + erf(z))/2, |z| < 1
; ndtr(x) = erfc(z)/2, |z| >= 1
; z = x/sqrt(2)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fndtr.sse
{
$asprocf @@fndtr

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@ndtr.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
   .sign.bits:
        movmskpd ecx, xmm0                      ; ecx = sign bits

   .main:
        xmovsd  xmm5, SIC_AX.1D.SQRT2
        mulsd   xmm0, xmm5                      ; xmm0 = x' = x/sqrt(2)
        xmovx   xmm3, xmm0
        @@.abs  xmm3                            ; xmm3 = z = |x'|
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm3, xmm5
        jb     .erf                             ; jump if z < 1.0

   .erfc:
        xmovx   xmm0, xmm3                      ; xmm0 = z
        push    rcx
        mov     rax, @@ferfc.core
        call    rax                             ; xmm0 = erfc(z)
        pop     rcx
        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5                      ; xmm0 = erfc(z)/2
        ;
        test    ecx, 1                          ; if ( x > 0 ) { y = 1.0 - y }
        jnp    .return
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm5
        jmp    .return

   .erf:
        mov     rax, @@ferf.core
        call    rax                             ; xmm0 = erf(x')
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5                      ; xmm0 = (1+erf(x'))/2

   .return:
        retn
$endp
}

macro @@fndtr.fpu
{
$asprocf @@fndtr

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@ndtr.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
   .sign.bits:
        xor     ecx, ecx                        ; ecx = sign bit
        ftst
        fnjge  .main
        inc     ecx

   .main:
        fmulq   SIC_AX.1D.SQRT2                 ; st0 = x' = x/sqrt(2)
        fld     st0
        fabs                                    ; st0 = z = |x'| | st1 = x'
        fld1
        fcomp                                   ; compare 1.0 to z
        fnjg   .erf                             ; jump if z < 1.0 (1.0 > z)

   .erfc:
        fstp    st1                             ; st0 = z
        push    rcx
        mov     rax, @@ferfc.core
        call    rax                             ; st0 = erfc(z)
        pop     rcx
        fmulq   SIC_AX.0.5                      ; st0 = erfc(z)/2
        ;
        test    ecx, 1                          ; if ( x > 0 ) { y = 1.0 - y }
        jnp    .return
        fld1
        fsubrp
        jmp    .return

   .erf:
        fstp    st0                             ; st0 = x'
        mov     rax, @@ferf.core
        call    rax                             ; st0 = erf(x')
        fld1
        faddp
        fmulq   SIC_AX.0.5                      ; st0 = (1+erf(x'))/2

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fndtr.sse
$else
  @@fndtr.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/ndtri.c
; Inverse of normal distribution function

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_ndtri.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fndtri.sse
{
$asprocf @@fndtri.PQ0

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_fndtri_PQ0
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
        addpd   xmm4, [rdx + 8*16]              ; xmm4 = P':Q
        ;
        movapd  xmm3, xmm4                      ; xmm3 = P':Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P'
        divsd   xmm3, xmm4                      ; xmm3 = P'/Q
        xmovsd  xmm4, SIC_AX.1.0
        addsd   xmm4, xmm3                      ; xmm4 = 1+P'/Q
        mulsd   xmm0, xmm4                      ; xmm0 = x*(1+P'/Q)
        xmovsd  xmm4, SIC_AX.SQRT.2PI
        mulsd   xmm0, xmm4

   .return:
        retn
$endp

$asprocf @@fndtri.PQ1

   .main:                                       ; xmm1 = u
        xmovx   xmm7, xmm0                      ; xmm7 = z = 1/u
        xddup   xmm5, xmm0                      ; xmm5 = z:z

        mov     rdx, ??.PD_fndtri_PQ1
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
        movapd  xmm3, xmm4                      ; xmm3 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm3, xmm4                      ; xmm3 = P/Q
        mulsd   xmm0, xmm3                      ; xmm0 = z*P/Q

        xmovx   xmm6, xmm0
        xmovx   xmm0, xmm1
        mov     rbx, @@floge.core
        call    rbx
        mulsd   xmm7, xmm0
        xmovx   xmm0, xmm1
        subsd   xmm0, xmm7
        subsd   xmm0, xmm6

   .return:
        retn
$endp

$asprocf @@fndtri.PQ2

   .main:                                       ; xmm1 = u
        xmovx   xmm7, xmm0                      ; xmm7 = z = 1/u
        xddup   xmm5, xmm0                      ; xmm5 = z:z

        mov     rdx, ??.PD_fndtri_PQ2
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
        movapd  xmm3, xmm4                      ; xmm3 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm3, xmm4                      ; xmm3 = P/Q
        mulsd   xmm0, xmm3                      ; xmm0 = z*P/Q

        xmovx   xmm6, xmm0
        xmovx   xmm0, xmm1
        mov     rbx, @@floge.core
        call    rbx
        mulsd   xmm7, xmm0
        xmovx   xmm0, xmm1
        subsd   xmm0, xmm7
        subsd   xmm0, xmm6

   .return:
        retn
$endp

$asprocf @@fndtri.PQX

   .main:
        push    rcx
        mov     rbx, @@floge.core
        call    rbx
        xmovsd  xmm5, SIC_AX.m2.0
        mulsd   xmm0, xmm5
        sqrtsd  xmm0, xmm0                      ; xmm0 = u = sqrt(-2*loge(x))
        xmovx   xmm1, xmm0                      ; xmm1 = u
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm1                      ; xmm0 = z = 1/u
        xmovsd  xmm5, SIC_AX.8.0
        comisd  xmm1, xmm5                      ; compare u to 8
        jb     .LL.PQ1                          ; jump if u < 8

   .LL.PQ2:
        mov     rbx, @@fndtri.PQ2
        call    rbx
        jmp    .LL.update

   .LL.PQ1:
        mov     rbx, @@fndtri.PQ1
        call    rbx

   .LL.update:
        pop     rcx
        test    rcx, rcx
        jz     .return
        @@.chs  xmm0

   .return:
        retn
$endp

$asprocf @@fndtri

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@ndtri.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        mov     rcx, rsp                        ; rcx <> 0
        xmovsd  xmm5, SIC_AX.1m.exp.m2
        comisd  xmm0, xmm5                      ; compare x to 1-exp(-2)
        jbe    .L.PQ                            ; jump if x <= 1-exp(-2)
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        subsd   xmm0, xmm5                      ; x = 1-x
        xor     rcx, rcx                        ; rcx = 0

   .L.PQ:
        xmovsd  xmm5, SIC_AX.exp.m2
        comisd  xmm0, xmm5                      ; compare x to exp(-2)
        ja     .L.PQ0                           ; jump if x > exp(-2)

   .L.PQX:
        mov     rbx, @@fndtri.PQX
        call    rbx
        jmp    .return

   .L.PQ0:
        xmovsd  xmm5, SIC_AX.0.5
        subsd   xmm0, xmm5
        mov     rbx, @@fndtri.PQ0
        call    rbx

   .return:
        retn
$endp
}

macro @@fndtri.fpu
{
$asprocf @@fndtri.PQ0

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2    | st1 = x

        mov     rdx, ??.SD_fndtri_P0n
        fld     qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]               ; st0 = P      | st1 = x^2 | st2 = x
        fmul    st0, st1                        ; st0 = P'     | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_fndtri_Q0n
        fxch                                    ; st0 = x^2    | st1 = P'  | st2 = x
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
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q      | st1 = P'  | st2 = x
        ;
        fdivp                                   ; st0 = P'/Q   | st1 = x
        fld1
        faddp                                   ; st0 = 1+P'/Q | st1 = x
        fmulp                                   ; st0 = x*(1+P'/Q)
        fmulq   SIC_AX.SQRT.2PI

   .return:
        retn
$endp

$asprocf @@fndtri.PQ1

   .main:
        fld     st0                             ; st0 = z     | st1 = z   | st2 = u

        mov     rdx, ??.SD_fndtri_P1n
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
        fadd    qword [rdx + 8*8]               ; st0 = P     | st1 = z   | st2 = z | st3 = u
        ;
        mov     rdx, ??.SD_fndtri_Q1n
        fxch                                    ; st0 = z     | st1 = P   | st2 = z | st3 = u
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
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q     | st1 = P   | st2 = z | st3 = u
        ;
        fdivp                                   ; st0 = P/Q   | st1 = z   | st2 = u
        fmul    st0, st1                        ; st0 = z*P/Q | st1 = z   | st2 = u
        fxch    st2                             ; st0 = u     | st1 = z   | st2 = z*P/Q
        fld     st0                             ; st0 = u     | st1 = u   | st2 = z | st3 = z*P/Q
        mov     rbx, @@floge.core
        call    rbx                             ; st0 = ln(u) | st1 = u   | st2 = z | st3 = z*P/Q
        fmulp   st2, st0                        ; st0 = u     | st1 = z*ln(u) | st2 = z*P/Q
        fsubrp
        fsubrp                                  ; st0 = u - z*ln(u) - z*P/Q

   .return:
        retn
$endp

$asprocf @@fndtri.PQ2

   .main:
        fld     st0                             ; st0 = z     | st1 = z   | st2 = u

        mov     rdx, ??.SD_fndtri_P2n
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
        fadd    qword [rdx + 8*8]               ; st0 = P     | st1 = z   | st2 = z | st3 = u
        ;
        mov     rdx, ??.SD_fndtri_Q2n
        fxch                                    ; st0 = z     | st1 = P   | st2 = z | st3 = u
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
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmul    st0, st1
        fadd    qword [rdx + 6*8]
        fmul    st0, st1
        fadd    qword [rdx + 7*8]
        fmulp
        fadd    qword [rdx + 8*8]               ; st0 = Q     | st1 = P   | st2 = z | st3 = u
        ;
        fdivp                                   ; st0 = P/Q   | st1 = z   | st2 = u
        fmul    st0, st1                        ; st0 = z*P/Q | st1 = z   | st2 = u
        fxch    st2                             ; st0 = u     | st1 = z   | st2 = z*P/Q
        fld     st0                             ; st0 = u     | st1 = u   | st2 = z | st3 = z*P/Q
        mov     rbx, @@floge.core
        call    rbx                             ; st0 = ln(u) | st1 = u   | st2 = z | st3 = z*P/Q
        fmulp   st2, st0                        ; st0 = u     | st1 = z*ln(u) | st2 = z*P/Q
        fsubrp
        fsubrp                                  ; st0 = u - z*ln(u) - z*P/Q

   .return:
        retn
$endp

$asprocf @@fndtri.PQX

   .main:
        push    rcx
        mov     rbx, @@floge.core
        call    rbx
        fmulq   SIC_AX.m2.0
        fsqrt                                   ; st0 = u = sqrt(-2*loge(x))
        fldq    SIC_AX.8.0
        fcomp                                   ; compare 8 to u
        fnjg   .LL.PQ1                          ; jump if u < 8 (8 > u)

   .LL.PQ2:
        fld     st0                             ; st0 = u       | st1 = u
        fld1
        fdivrp                                  ; st0 = z = 1/u | st1 = u
        mov     rbx, @@fndtri.PQ2
        call    rbx
        jmp    .LL.update

   .LL.PQ1:
        fld     st0                             ; st0 = u       | st1 = u
        fld1
        fdivrp                                  ; st0 = z = 1/u | st1 = u
        mov     rbx, @@fndtri.PQ1
        call    rbx

   .LL.update:
        pop     rcx
        test    rcx, rcx
        jz     .return
        fchs

   .return:
        retn
$endp

$asprocf @@fndtri

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@ndtri.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        mov     rcx, rsp                        ; rcx <> 0
        fldq    SIC_AX.1m.exp.m2
        fcomp                                   ; compare 1-exp(-2) to x
        fnjge  .L.PQ                            ; jump if x <= 1-exp(-2) (1-exp(-2) >= x)
        fld1
        fsubrp                                  ; x = 1-x
        xor     rcx, rcx                        ; rcx = 0

   .L.PQ:
        fldq    SIC_AX.exp.m2
        fcomp                                   ; compare exp(-2) to x
        fnjl   .L.PQ0                           ; jump if x > exp(-2) (exp(-2) < x)

   .L.PQX:
        mov     rbx, @@fndtri.PQX
        call    rbx
        jmp    .return

   .L.PQ0:
        fsubq   SIC_AX.0.5
        mov     rbx, @@fndtri.PQ0
        call    rbx

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fndtri.sse
$else
  @@fndtri.fpu
$end

; ------------------------------------------------------------------------------

; inverse error function
; erfi(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ferfi.sse
{
$asprocf @@ferfi.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_ferfi_PQ
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
        movapd  xmm3, xmm4                      ; xmm3 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm3, xmm4                      ; xmm3 = P/Q
        mulsd   xmm0, xmm3                      ; xmm0 = x*P/Q
        xmovsd  xmm5, SIC_AX.SQRT.PI.D2
        mulsd   xmm0, xmm5

   .return:
        retn
$endp

$asprocf @@ferfi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfi.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovx   xmm3, xmm0
        @@.abs  xmm3
        xmovsd  xmm5, ??.ferfi_range
        comisd  xmm3, xmm5                      ; compare |x| to ??.range
        ja     .LF                              ; jump if |x| > ??.range

   .L.PQ:                                       ; |x| <= ??.range
        mov     rbx, @@ferfi.PQ
        call    rbx
        jmp    .return

   .LF:                                         ; |x| > ??.range
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5
        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5
        mov     rbx, @@fndtri.core
        call    rbx
        xmovsd  xmm5, SIC_AX.1D.SQRT2
        mulsd   xmm0, xmm5

   .return:
        retn
$endp
}

macro @@ferfi.fpu
{
$asprocf @@ferfi.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2    | st1 = x

        mov     rdx, ??.SD_ferfi_Pn
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
        mov     rdx, ??.SD_ferfi_Qn
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
        fmulq   SIC_AX.SQRT.PI.D2

   .return:
        retn
$endp

$asprocf @@ferfi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfi.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fabs
        fldq    ??.ferfi_range
        fcompp                                  ; compare ??.range to |x|
        fnjl   .LF                              ; jump if |x| > ??.range (??.range < |x|)

   .L.PQ:                                       ; |x| <= ??.range
        mov     rbx, @@ferfi.PQ
        call    rbx
        jmp    .return

   .LF:                                         ; |x| > ??.range
        fld1
        faddp
        fmulq   SIC_AX.0.5
        mov     rbx, @@fndtri.core
        call    rbx
        fmulq   SIC_AX.1D.SQRT2

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ferfi.sse
$else
  @@ferfi.fpu
$end

; ------------------------------------------------------------------------------

; inverse complementary error function
; erfci(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ferfci.sse
{
$asprocf @@ferfci

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfci.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
;       xmovx   xmm5, xmm0
;       xmovsd  xmm0, SIC_AX.1.0
;       subsd   xmm0, xmm5                      ; xmm0 = 1-x
;       mov     rbx, @@ferfi.core               ; erfci(x) = erfi(1-x)
;       call    rbx

        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5
        mov     rbx, @@fndtri.core
        call    rbx
        xmovsd  xmm5, SIC_AX.m1D.SQRT2
        mulsd   xmm0, xmm5

   .return:
        retn
$endp
}

macro @@ferfci.sse.V0
{
$asprocf @@ferfci.PQ

   .main:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     rdx, ??.PD_ferfci_PQ
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
        addpd   xmm4, [rdx + 8*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [rdx + 9*16]              ; xmm4 = P:Q
        ;
        movapd  xmm3, xmm4                      ; xmm3 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm3, xmm4                      ; xmm3 = P/Q
        mulsd   xmm0, xmm3                      ; xmm0 = x*P/Q
        xmovsd  xmm5, SIC_AX.SQRT.PI.D2
        mulsd   xmm0, xmm5

   .return:
        retn
$endp

$asprocf @@ferfci

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfci.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        xmovsd  xmm5, SIC_AX.1.0
        xmovx   xmm3, xmm0
        subsd   xmm3, xmm5
        xmovx   xmm4, xmm3                      ; xmm4 = x-1
        @@.abs  xmm3                            ; xmm3 = |x-1|
        xmovsd  xmm5, ??.ferfci_range
        comisd  xmm3, xmm5                      ; compare |x-1| to ??.range
        ja     .LF                              ; jump if |x-1| > ??.range

   .L.PQ:                                       ; |x-1| <= ??.range
        xmovx   xmm0, xmm4                      ; xmm0 = x-1
        mov     rbx, @@ferfci.PQ
        call    rbx
        jmp    .return

   .LF:                                         ; |x-1| > ??.range
        xmovsd  xmm5, SIC_AX.0.5
        mulsd   xmm0, xmm5
        mov     rbx, @@fndtri.core
        call    rbx
        xmovsd  xmm5, SIC_AX.m1D.SQRT2
        mulsd   xmm0, xmm5

   .return:
        retn
$endp
}

macro @@ferfci.fpu
{
$asprocf @@ferfci

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfci.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
;       fld1
;       fsubrp                                  ; st0 = 1-x
;       mov     rbx, @@ferfi.core               ; erfci(x) = erfi(1-x)
;       call    rbx

        fmulq   SIC_AX.0.5
        mov     rbx, @@fndtri.core
        call    rbx
        fmulq   SIC_AX.m1D.SQRT2

   .return:
        retn
$endp
}

macro @@ferfci.fpu.V0
{
$asprocf @@ferfci.PQ

   .main:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2    | st1 = x

        mov     rdx, ??.SD_ferfci_Pn
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
        fadd    qword [rdx + 8*8]
        fmul    st0, st1
        fadd    qword [rdx + 9*8]               ; st0 = P      | st1 = x^2 | st2 = x
        ;
        mov     rdx, ??.SD_ferfci_Qn
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
        fmul    st0, st1
        fadd    qword [rdx + 8*8]
        fmulp
        fadd    qword [rdx + 9*8]               ; st0 = Q      | st1 = P   | st2 = x
        ;
        fdivp                                   ; st0 = P/Q    | st1 = x
        fmulp                                   ; st0 = x*P/Q
        fmulq   SIC_AX.SQRT.PI.D2

   .return:
        retn
$endp

$asprocf @@ferfci

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@erfci.arg                ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:
        fld     st0
        fld1
        fsubp
        fabs                                    ; st0 = |x-1|
        fldq    ??.ferfci_range
        fcompp                                  ; compare ??.range to |x-1|
        fnjl   .LF                              ; jump if |x-1| > ??.range (??.range < |x-1|)

   .L.PQ:                                       ; |x-1| <= ??.range
        fld1
        fsubp                                   ; st0 = x-1
        mov     rbx, @@ferfci.PQ
        call    rbx
        jmp    .return

   .LF:                                         ; |x-1| > ??.range
        fmulq   SIC_AX.0.5
        mov     rbx, @@fndtri.core
        call    rbx
        fmulq   SIC_AX.m1D.SQRT2

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ferfci.sse
$else
  @@ferfci.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/gamma.c
; Gamma function

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_gamma.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Stirling's formula for the gamma function
;
; gamma(x) = sqrt(2*pi) * (x)^(x-0.5) * exp(-x) * (1 + 1/x * P(1/x))
;          = sqrt(2*pi/e) * (x/e)^(x-0.5) * (1 + 1/x * P(1/x))

macro @@fsgamma.sse
{
macro @@.fsgamma.PD.STIRn
\{
        xmovsd  xmm4, SIC_AX.1.0                ; xmm0 = x
        divsd   xmm4, xmm0                      ; xmm4 = w = 1/x
        xddup   xmm5, xmm4                      ; xmm5 = w:w
        mulsd   xmm4, xmm5
        mulsd   xmm4, xmm5                      ; xmm4 = w^3

        mov     rdx, ??.PD_fsgamma_ESTIRn
        movapd  xmm7, [rdx + 0*16]
        mulpd   xmm7, xmm5
        addpd   xmm7, [rdx + 1*16]
        mulpd   xmm7, xmm5
        addpd   xmm7, [rdx + 2*16]
        ;
        mulsd   xmm7, xmm4
    $ifdef _SSE3
        haddpd  xmm7, xmm7                      ; xmm7 = w
    $else
        oops haddpd
    $end
\}

macro @@.fsgamma.SD.STIRn
\{
        xmovsd  xmm4, SIC_AX.1.0                ; xmm0 = x
        divsd   xmm4, xmm0                      ; xmm4 = w = 1/x
        xddup   xmm5, xmm4                      ; xmm5 = w:w

        mov     rdx, ??.SD_fsgamma_ESTIRn
        movsd   xmm7, [rdx + 0*8]
        mulsd   xmm7, xmm5
        addsd   xmm7, [rdx + 1*8]
        mulsd   xmm7, xmm5
        addsd   xmm7, [rdx + 2*8]
        mulsd   xmm7, xmm5
        addsd   xmm7, [rdx + 3*8]
        mulsd   xmm7, xmm5
        addsd   xmm7, [rdx + 4*8]
        mulsd   xmm7, xmm5
        addsd   xmm7, [rdx + 5*8]               ; xmm7 = w
\}

$asprocf @@fsgamma

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        xmovsd  xmm5, ??.SD_fsgamma_max_arg
        comisd  xmm0, xmm5                      ; compare x to max_arg
        jb     .core                            ; jump if x < max_arg
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .return
   .core:
        xmovsd  xmm4, SIC_AX.1.0                ; xmm0 = x
        divsd   xmm4, xmm0                      ; xmm4 = w = 1/x
        xddup   xmm5, xmm4                      ; xmm5 = w:w
        mulsd   xmm4, xmm4
        mulsd   xmm4, xmm5                      ; xmm4 = w^3

        mov     rdx, ??.PD_fsgamma_ESTIRn
        movapd  xmm7, [rdx + 0*16]
        mulpd   xmm7, xmm5
        addpd   xmm7, [rdx + 1*16]
        mulpd   xmm7, xmm5
        addpd   xmm7, [rdx + 2*16]
        ;
        mulsd   xmm7, xmm4
    $ifdef _SSE3
        haddpd  xmm7, xmm7                      ; xmm7 = w
    $else
        oops haddpd
    $end

        xmovx   xmm1, xmm0                      ; xmm1 = x
        xmovsd  xmm5, ??.1D.E
        mulsd   xmm0, xmm5                      ; xmm0 = x/E
        xmovsd  xmm5, SIC_AX.0.5
        subsd   xmm1, xmm5                      ; xmm1 = x-0.5
        mov     rbx, @@fpow.core
        call    rbx                             ; xmm0 = (x/E)^(x-0.5)
        ;
        mulsd   xmm0, xmm7

   .return:
        retn
$endp
}

macro @@fsgamma.fpu
{
macro @@.fsgamma.STIRn
\{
        fld     st0
        fld1
        fdivrp                                  ; st0 = w = 1/x | st1 = x

        mov     rdx, ??.SD_fsgamma_ESTIRn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmulp
        fadd    qword [rdx + 5*8]               ; st0 = w | st1 = x
\}

$asprocf @@fsgamma

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        fldq    ??.SD_fsgamma_max_arg
        fcomp                                   ; compare max_arg to x
        fnjg   .core                            ; jump if x < max_arg (max_arg > x)
        fldq    SIC_AX.PInf
        jmp    .return
   .core:
        fld     st0
        fld1
        fdivrp                                  ; st0 = w = 1/x | st1 = x

        mov     rdx, ??.SD_fsgamma_ESTIRn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmul    st0, st1
        fadd    qword [rdx + 4*8]
        fmulp
        fadd    qword [rdx + 5*8]               ; st0 = w   | st1 = x

        fxch                                    ; st0 = x   | st1 = w
        fld     st0                             ; st0 = x   | st1 = x     | st2 = w
        fmulq   ??.1D.E                         ; st0 = x/E | st1 = x     | st2 = w
        fldq    SIC_AX.0.5                      ; st0 = 0.5 | st1 = x/E   | st2 = x | st3 = w
        fsubp   st2, st0                        ; st0 = x/E | st1 = x-0.5 | st2 = w
        mov     rbx, @@fpowr.core
        call    rbx                             ; st0 = (x/E)^(x-0.5)     | st1 = w
        fmulp

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsgamma.sse
$else
  @@fsgamma.fpu
$end

; ------------------------------------------------------------------------------

; gamma function

macro @@ftgamma.sse
{
; -33 <= x <= 33
$asprocf @@.ftgamma.PQ

        xmovsd  xmm4, SIC_AX.1.0                ; xmm4 = 1

        xmovx   xmm3, xmm4                      ; xmm3 = z = 1
        xmovsd  xmm5, SIC_AX.3.0                ; xmm5 = 3.0
   .x.GE.3.0:
        ; while ( x >= 3.0 )
        comisd  xmm0, xmm5                      ; compare x to 3.0
        jb     .x.LT.3.0                        ; jump if x < 3.0
        subsd   xmm0, xmm4                      ; x = x - 1
        mulsd   xmm3, xmm0                      ; z = z * x
        jmp    .x.GE.3.0
   .x.LT.3.0:

        xmovx   xmm1, xmm4                      ; xmm1 = w = 1
        xorpd   xmm5, xmm5                      ; xmm5 = 0.0
        xmovsd  xmm2, SIC_AX.m1.0Em9            ; xmm2 = -1.0E-9
   .x.LT.0.0:
        ; while ( x < 0.0 )
        comisd  xmm0, xmm5                      ; compare x to 0.0
        jae    .x.GE.0.0                        ; jump if x >= 0.0
        ; if ( x > -1.0E-9 )
        comisd  xmm0, xmm2                      ; compare x to -1.0E-9
        ja     .x.small                         ; jump if x > -1.0E-9
        mulsd   xmm1, xmm0                      ; w = w * x
        addsd   xmm0, xmm4                      ; x = x + 1
        jmp    .x.LT.0.0
   .x.GE.0.0:
        divsd   xmm3, xmm1                      ; z = z / w

        xmovx   xmm1, xmm4                      ; xmm1 = w = 1
        xmovsd  xmm5, SIC_AX.2.0                ; xmm5 = 2.0
        xmovsd  xmm2, SIC_AX.1.0Em9             ; xmm2 = 1.0E-9
   .x.LT.2.0:
        ; while ( x < 2.0 )
        comisd  xmm0, xmm5                      ; compare x to 2.0
        jae    .x.GE.2.0                        ; jump if x >= 2.0
        ; if ( x < 1.0E-9 )
        comisd  xmm0, xmm2                      ; compare x to 1.0E-9
        jb     .x.small                         ; jump if x < 1.0E-9
        mulsd   xmm1, xmm0                      ; w = w * x
        addsd   xmm0, xmm4                      ; x = x + 1
        jmp    .x.LT.2.0
   .x.GE.2.0:
        divsd   xmm3, xmm1                      ; z = z / w

        ; if ( x == 2.0 )
        ucomisd xmm0, xmm5                      ; compare x to 2.0
        jnz    .x.PQ                            ; jump if x <> 2.0
        jp     .x.PQ

   .x.EQ.2.0:
        xmovx   xmm0, xmm3
        jmp    .return

   .x.small:
        ; if ( x == 0.0 )
        xorpd   xmm5, xmm5                      ; xmm5 = 0.0
        ucomisd xmm0, xmm5                      ; compare x to 0.0
        jnz    .x.small.NE.0.0                  ; jump if x <> 0.0
        jp     .x.small.NE.0.0
   .x.small.EQ.0.0:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .return
   .x.small.NE.0.0:
        divsd   xmm3, xmm1                      ; z = z / w
        xmovsd  xmm5, SIC_AX.euler
        mulsd   xmm5, xmm0
        xmovsd  xmm4, SIC_AX.1.0
        addsd   xmm5, xmm4
        mulsd   xmm5, xmm0
        xmovx   xmm0, xmm3
        divsd   xmm0, xmm5
        jmp    .return

   .x.PQ:
        xmovsd  xmm5, SIC_AX.2.0
        subsd   xmm0, xmm5
        xddup   xmm5, xmm0                      ; xmm5 = x:x

        mov     rdx, ??.PD_ftgamma_PQ
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
        addpd   xmm4, [rdx + 7*16]              ; xmm4 = P:Q
        ;
        movapd  xmm0, xmm4                      ; xmm0 = P:Q
;       psrldq  xmm4, 8                         ; xmm4 = Q:0
        shufpd  xmm4, xmm4, 1                   ; xmm4 = Q:P
        divsd   xmm0, xmm4                      ; xmm0 = P/Q
        mulsd   xmm0, xmm3

   .return:
        retn
$endp

; x < -33
; x - not integer
$asprocf @@.ftgamma.LT.m33

        xmovsd  xmm5, SIC_AX.pi
        mulsd   xmm0, xmm5
        mov     rax, @@fsin.core
        call    rax

        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare sin() to 0
        jnz    .nonzero
        jp     .nonzero

   .zero:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .return

   .nonzero:
        xmovx   xmm5, xmm6
        mulsd   xmm6, xmm0                      ; xmm6 = q * sin( PI * z )
        xmovx   xmm0, xmm5
        mov     rax, @@fsgamma.core
        call    rax
        mulsd   xmm6, xmm0
        xmovsd  xmm0, SIC_AX.pi
        divsd   xmm0, xmm6

        @@.abs  xmm0
        test    rdi, 1
        jz     .return
        @@.chs  xmm0

   .return:
        retn
$endp

$asprocf @@ftgamma

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@tgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : xmm0 = x | xmm3 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        xmovsd  xmm5, SIC_AX.33.0
        comisd  xmm0, xmm5                      ; compare x to +33.0
        ja     .GT.33                           ; jump if x > +33.0
        xmovsd  xmm5, SIC_AX.m33.0
        comisd  xmm0, xmm5                      ; compare x to -33.0
        jb     .LT.m33                          ; jump if x < -33.0

   .L0:
        mov     rax, @@.ftgamma.PQ
        call    rax
        jmp    .return

   .LT.m33:
        xmovx   xmm6, xmm0
        @@.abs  xmm6                            ; xmm6 = abs(x)
        xmovx   xmm0, xmm3                      ; xmm0 = frac(x)
        mov     rax, @@.ftgamma.LT.m33
        call    rax
        jmp    .return

   .GT.33:
        mov     rax, @@fsgamma.core
        call    rax

   .return:
        retn
$endp
}

macro @@ftgamma.fpu
{
; -33 <= x <= 33
$asprocf @@.ftgamma.PQ

        mov     rbx, SIC_AX.1.0                 ; rbx = 1.0

        fld1
        fxch                                    ; st0 = x | st1 = z = 1

        mov     rdx, SIC_AX.3.0                 ; rdx = 3.0
   .x.GE.3.0:
        ; while ( x >= 3.0 )
        fcom    qword [rdx]                     ; compare x to 3.0
        fnjl   .x.LT.3.0                        ; jump if x < 3.0
        fsub    qword [rbx]                     ; x = x - 1
        fmul    st1, st0                        ; z = z * x
        jmp    .x.GE.3.0
   .x.LT.3.0:

        fld1                                    ; w = 1
        fxch                                    ; st0 = x | st1 = w | st2 = z
        mov     rcx, SIC_AX.m1.0Em9             ; rcx = -1.0E-9
   .x.LT.0.0:
        ; while ( x < 0.0 )
        ftst                                    ; compare x to 0.0
        fnjge  .x.GE.0.0                        ; jump if x >= 0.0
        ; if ( x > -1.0E-9 )
        fcom    qword [rcx]                     ; compare x to -1.0E-9
        fnjg   .x.small                         ; jump if x > -1.0E-9
        fmul    st1, st0                        ; w = w * x
        fadd    qword [rbx]                     ; x = x + 1
        jmp    .x.LT.0.0
   .x.GE.0.0:
        fxch    st2                             ; st0 = z     | st1 = w | st2 = x
        fdivrp                                  ; st0 = z / w | st1 = x
        fxch                                    ; st0 = x     | st1 = z

        fld1                                    ; w = 1
        fxch                                    ; st0 = x | st1 = w | st2 = z
        mov     rdx, SIC_AX.2.0                 ; rdx = 2.0
        mov     rcx, SIC_AX.1.0Em9              ; rcx = 1.0E-9
   .x.LT.2.0:
        ; while ( x < 2.0 )
        fcom    qword [rdx]                     ; compare x to 2.0
        fnjge  .x.GE.2.0                        ; jump if x >= 2.0
        ; if ( x < 1.0E-9 )
        fcom    qword [rcx]                     ; compare x to 1.0E-9
        fnjl   .x.small                         ; jump if x < 1.0E-9
        fmul    st1, st0                        ; w = w * x
        fadd    qword [rbx]                     ; x = x + 1
        jmp    .x.LT.2.0
   .x.GE.2.0:
        fxch    st2                             ; st0 = z     | st1 = w | st2 = x
        fdivrp                                  ; st0 = z / w | st1 = x
        fxch                                    ; st0 = x     | st1 = z

        ; if ( x == 2.0 )
        fcom    qword [rdx]                     ; compare x to 2.0
        fnjne  .x.PQ                            ; jump if x <> 2.0

   .x.EQ.2.0:
        fstp    st0                             ; st0 = z
        jmp    .return

   .x.small:                                    ; st0 = x | st1 = w | st2 = z
        ; if ( x == 0.0 )
        ftst                                    ; compare x to 0.0
        fnjnz  .x.small.NE.0.0                  ; jump if x <> 0.0
   .x.small.EQ.0.0:
        fstp    st0
        fstp    st0
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .return
   .x.small.NE.0.0:
        fxch    st2                             ; st0 = z     | st1 = w | st2 = x
        fdivrp                                  ; st0 = z / w | st1 = x
        fxch                                    ; st0 = x     | st1 = z

        fldq    SIC_AX.euler
        fmul    st0, st1
        fadd    qword [rbx]
        fmulp                                   ; st0 = x'    | st1 = z
        fdivp
        jmp    .return

   .x.PQ:
        fsubq   SIC_AX.2.0                      ; st0 = x     | st1 = z

        mov     rdx, ??.SD_ftgamma_Pn
        fld     qword [rdx + 1*8]
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
        fadd    qword [rdx + 7*8]               ; st0 = P  | st1 = x | st2 = z
        ;
        mov     rdx, ??.SD_ftgamma_Qn
        fxch                                    ; st0 = x  | st1 = P | st2 = z
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
        fmulp
        fadd    qword [rdx + 7*8]               ; st0 = Q    | st1 = P | st2 = z
        ;
        fdivp                                   ; st0 = P/Q  | st1 = z
        fmulp                                   ; st0 = z*P/Q

   .return:
        retn
$endp

; x < -33
; x - not integer
$asprocf @@.ftgamma.LT.m33

        fldpi
        fmulp
        mov     rax, @@fsin.core
        call    rax

        ftst                                    ; compare sin() to 0
        fnjnz  .nonzero

   .zero:
        fstp    st0
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .return

   .nonzero:
        fxch
        fabs                                    ; st0 = abs(x) | st1 = sin()
        fmul    st1, st0                        ; st0 = abs(x) | st1 = q * sin( PI * z )
        mov     rax, @@fsgamma.core
        call    rax
        fmulp
        fldpi
        fdivrp

        fabs
        test    rdi, 1
        jz     .return
        fchs

   .return:
        retn
$endp

$asprocf @@ftgamma

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@tgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : st0 = x | st1 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        fldq    SIC_AX.33.0
        fcomp                                   ; compare +33.0 to x
        fnjl   .GT.33                           ; jump if x > +33.0 (+33.0 < x)
        fldq    SIC_AX.m33.0
        fcomp                                   ; compare -33.0 to x
        fnjg   .LT.m33                          ; jump if x < -33.0 (-33.0 > x)

   .L0:
        ftst                                    ; compare x to 0.0
        fnjge  .L0.GE.0.0                       ; jump if x >= 0.0
   .L0.LT.0.0:                                  ; st0 = x | st1 = frac(x)
        fstp    st1                             ; st0 = x
   .L0.GE.0.0:
        mov     rax, @@.ftgamma.PQ
        call    rax
        jmp    .return

   .LT.m33:
        fxch                                    ; st0 = frac(x) | st1 = x
        mov     rax, @@.ftgamma.LT.m33
        call    rax
        jmp    .return

   .GT.33:
        mov     rax, @@fsgamma.core
        call    rax

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ftgamma.sse
$else
  @@ftgamma.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; trgamma(x) = 1/rgamma(x)

macro @@ftrgamma.sse
{
$asprocf @@ftrgamma

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@tgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : xmm0 = x | xmm3 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        mov     rax, @@frgamma.core
        call    rax

        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5

   .return:
        retn
$endp
}

macro @@ftrgamma.fpu
{
$asprocf @@ftrgamma

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@tgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : st0 = x | st1 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        mov     rax, @@frgamma.core
        call    rax

        fld1
        fdivrp

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ftrgamma.sse
$else
  @@ftrgamma.fpu
$end

; ------------------------------------------------------------------------------

; natural logarithm of the absolute value of gamma function

macro @@flgamma.sse
{
; x >= 13
$asprocf @@.flgamma.GE.13.0

        xmovx   xmm1, xmm0                      ; xmm1 = x
        mov     rax, @@floge.core
        call    rax                             ; xmm0 = ln(x)
        xmovx   xmm4, xmm1                      ; xmm4 = x
        xmovsd  xmm5, SIC_AX.0.5
        subsd   xmm4, xmm5
        mulsd   xmm0, xmm4
        subsd   xmm0, xmm1
        xmovsd  xmm5, SIC_AX.ln.SQRT2PI
        addsd   xmm0, xmm5                      ; xmm0 = q

        xmovsd  xmm5, SIC_AX.1.0E8              ; xmm5 = 1.0E8
        ; if ( x > 1.0E8 )
        comisd  xmm1, xmm5                      ; compare x to 1.0E8
        ja     .return                          ; jump if x > 1.0E8

   .LE.1.0E8:
        xmovsd  xmm3, SIC_AX.1.0
        divsd   xmm3, xmm1                      ; xmm3 = 1/x
        xmovx   xmm4, xmm3
        mulsd   xmm4, xmm4                      ; xmm4 = 1/x^2

        xmovsd  xmm5, SIC_AX.1000.0             ; xmm5 = 1000.0
        ; if ( x >= 1000.0 )
        comisd  xmm1, xmm5                      ; compare x to 1000.0
        jb     .LT.1000.0                       ; jump if x < 1000.0

   .GE.1000.0:
        mov     rdx, ??.SD_flgamma_Tn
        movsd   xmm2, qword [rdx + 0*8]
        mulsd   xmm2, xmm4
        addsd   xmm2, qword [rdx + 1*8]
        mulsd   xmm2, xmm4
        addsd   xmm2, qword [rdx + 2*8]
        mulsd   xmm2, xmm3
        addsd   xmm0, xmm2
        jmp    .return

   .LT.1000.0:
        mov     rdx, ??.SD_flgamma_An
        movsd   xmm2, qword [rdx + 0*8]
        mulsd   xmm2, xmm4
        addsd   xmm2, qword [rdx + 1*8]
        mulsd   xmm2, xmm4
        addsd   xmm2, qword [rdx + 2*8]
        mulsd   xmm2, xmm4
        addsd   xmm2, qword [rdx + 3*8]
        mulsd   xmm2, xmm4
        addsd   xmm2, qword [rdx + 4*8]
        mulsd   xmm2, xmm3
        addsd   xmm0, xmm2

   .return:
        retn
$endp

; x < 13
$asprocf @@.flgamma.LT.13.0

        xmovsd  xmm4, SIC_AX.1.0                ; xmm4 = 1

        xmovx   xmm3, xmm4                      ; xmm3 = z = 1
        xmovsd  xmm5, SIC_AX.3.0                ; xmm5 = 3.0
   .u.GE.3.0:
        ; while ( u >= 3.0 )
        comisd  xmm0, xmm5                      ; compare u to 3.0
        jb     .u.LT.3.0                        ; jump if u < 3.0
        subsd   xmm0, xmm4                      ; u = u - 1
        mulsd   xmm3, xmm0                      ; z = z * u
        jmp    .u.GE.3.0
   .u.LT.3.0:

        xmovx   xmm1, xmm4                      ; xmm1 = w = 1
        xmovsd  xmm5, SIC_AX.2.0                ; xmm5 = 2.0
        xorpd   xmm2, xmm2                      ; xmm2 = 0.0
   .u.LT.2.0:
        ; while ( u < 2.0 )
        comisd  xmm0, xmm5                      ; compare u to 2.0
        jae    .u.GE.2.0                        ; jump if u >= 2.0
        ; if ( u == 0.0 )
        ucomisd xmm0, xmm2                      ; compare u to 0.0
        jnz    .u.LT.2.0.NE.0.0                 ; jump if u <> 0.0
        jp     .u.LT.2.0.NE.0.0
   .u.LT.2.0.EQ.0.0:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .return
   .u.LT.2.0.NE.0.0:
        mulsd   xmm1, xmm0                      ; w = w * u
        addsd   xmm0, xmm4                      ; u = u + 1
        jmp    .u.LT.2.0
   .u.GE.2.0:
        divsd   xmm3, xmm1                      ; z = z / w
        @@.abs  xmm3                            ; xmm3 = |z|

        ; if ( u == 2.0 )
        ucomisd xmm0, xmm5                      ; compare u to 2.0
        jnz    .u.NE.2.0                        ; jump if u <> 2.0
        jp     .u.NE.2.0
   .u.EQ.2.0:
        xmovx   xmm0, xmm3                      ; xmm0 = z
        mov     rax, @@floge.core
        call    rax
        jmp    .return
   .u.NE.2.0:

        subsd   xmm0, xmm5                      ; xmm0 = u-2
        xddup   xmm5, xmm0                      ; xmm5 = x:x

        mov     rdx, ??.PD_flgamma_BC
        movapd  xmm1, [rdx + 0*16]
        mulpd   xmm1, xmm5
        addpd   xmm1, [rdx + 1*16]
        mulpd   xmm1, xmm5
        addpd   xmm1, [rdx + 2*16]
        mulpd   xmm1, xmm5
        addpd   xmm1, [rdx + 3*16]
        mulpd   xmm1, xmm5
        addpd   xmm1, [rdx + 4*16]
        mulpd   xmm1, xmm5
        addpd   xmm1, [rdx + 5*16]
        mulpd   xmm1, xmm5
        addpd   xmm1, [rdx + 6*16]              ; xmm1 = B:C
        ;
        movapd  xmm5, xmm1                      ; xmm5 = B:C
;       psrldq  xmm5, 8                         ; xmm5 = C:0
        shufpd  xmm5, xmm5, 1                   ; xmm5 = C:B
        divsd   xmm1, xmm5                      ; xmm1 = B/C
        ;
        xmovx   xmm0, xmm3                      ; xmm0 = z
        mov     rax, @@floge.core
        call    rax
        addsd   xmm0, xmm1

   .return:
        retn
$endp

; x < -34
$asprocf @@.flgamma.LT.m34.0

        @@.abs  xmm0
        xmovx   xmm6, xmm0                      ; xmm6 = q
        xmovx   xmm7, xmm3                      ; xmm7 = z = frac(x)

        mov     rax, @@flgamma.core
        call    rax
        @@.xch  xmm0, xmm7                      ; xmm0 = z | xmm7 = LG

        xmovsd  xmm5, SIC_AX.pi
        mulsd   xmm0, xmm5
        mov     rax, @@fsin.core
        call    rax

        mulsd   xmm0, xmm6
        @@.abs  xmm0
        mov     rax, @@floge.core
        call    rax

        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.Ln.PI
        subsd   xmm0, xmm5
        subsd   xmm0, xmm7

   .return:
        retn
$endp

$asprocf @@flgamma

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@lgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : xmm0 = x | xmm3 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        xmovsd  xmm5, SIC_AX.m34.0              ; xmm5 = -34.0
        ; if ( x < -34.0 )
        comisd  xmm0, xmm5                      ; compare x to -34.0
        jae    .GE.m34.0                        ; jump if x >= -34.0

   .LT.m34.0:
        mov     rax, @@.flgamma.LT.m34.0
        call    rax
        jmp    .return

   .GE.m34.0:
        xmovsd  xmm5, SIC_AX.13.0               ; xmm5 = 13.0
        ; if ( x < 13.0 )
        comisd  xmm0, xmm5                      ; compare x to 13.0
        jae    .GE.13.0                         ; jump if x >= 13.0

   .LT.13.0:
        mov     rax, @@.flgamma.LT.13.0
        call    rax
        jmp    .return

   .GE.13.0:
        mov     rax, @@.flgamma.GE.13.0
        call    rax

   .return:
        retn
$endp
}

macro @@flgamma.fpu
{
; x >= 13
$asprocf @@.flgamma.GE.13.0

        fld     st0                             ; st0 = x     | st1 = x
        mov     rax, @@floge.core
        call    rax                             ; st0 = ln(x) | st1 = x
        fld     st1                             ; st0 = x     | st1 = ln(x) | st2 = x
        fsubq   SIC_AX.0.5
        fmulp
        fsub    st0, st1
        faddq   SIC_AX.ln.SQRT2PI               ; st0 = q | st1 = x
        fxch                                    ; st0 = x | st1 = q

        mov     rdx, SIC_AX.1.0E8               ; rdx = 1.0E8
        ; if ( x > 1.0E8 )
        fcom    qword [rdx]                     ; compare x to 1.0E8
        fnjle  .LE.1.0E8                        ; jump if x <= 1.0E8

   .GT.1.0E8:
        fstp    st0
        jmp    .return

   .LE.1.0E8:
        mov     rdx, SIC_AX.1000.0              ; rdx = 1000.0
        ; if ( x >= 1000.0 )
        fcom    qword [rdx]                     ; compare x to 1000.0
        fnjl   .LT.1000.0                       ; jump if x < 1000.0

   .GE.1000.0:
        fld1
        fdivrp                                  ; st0 = 1/x   | st1 = q
        fld     st0
        fmul    st0, st0                        ; st0 = 1/x^2 | st1 = 1/x | st2 = q

        mov     rdx, ??.SD_flgamma_Tn
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmulp
        fadd    qword [rdx + 2*8]
        fmulp
        faddp
        jmp    .return

   .LT.1000.0:
        fld1
        fdivrp                                  ; st0 = 1/x   | st1 = q
        fld     st0
        fmul    st0, st0                        ; st0 = 1/x^2 | st1 = 1/x | st2 = q

        mov     rdx, ??.SD_flgamma_An
        fld     qword [rdx + 0*8]
        fmul    st0, st1
        fadd    qword [rdx + 1*8]
        fmul    st0, st1
        fadd    qword [rdx + 2*8]
        fmul    st0, st1
        fadd    qword [rdx + 3*8]
        fmulp
        fadd    qword [rdx + 4*8]
        fmulp
        faddp

   .return:
        retn
$endp

; x < 13
$asprocf @@.flgamma.LT.13.0

        mov     rbx, SIC_AX.1.0                 ; rbx = 1.0

        fld1                                    ; st0 = z = 1 | st1 = u = x
        fxch                                    ; st0 = u     | st1 = z

        mov     rdx, SIC_AX.3.0                 ; rdx = 3.0
   .u.GE.3.0:
        ; while ( u >= 3.0 )
        fcom    qword [rdx]                     ; compare u to 3.0
        fnjl   .u.LT.3.0                        ; jump if u < 3.0
        fsub    qword [rbx]                     ; u = u - 1
        fmul    st1, st0                        ; z = z * u
        jmp    .u.GE.3.0
   .u.LT.3.0:

        fld1                                    ; w = 1
        fxch                                    ; st0 = u | st1 = w | st2 = z
        mov     rdx, SIC_AX.2.0                 ; rdx = 2.0
   .u.LT.2.0:
        ; while ( u < 2.0 )
        fcom    qword [rdx]                     ; compare u to 2.0
        fnjge  .u.GE.2.0                        ; jump if u >= 2.0
        ; if ( u == 0.0 )
        ftst                                    ; compare u to 0.0
        fnjnz  .u.LT.2.0.NE.0.0                 ; jump if u <> 0.0
   .u.LT.2.0.EQ.0.0:
        fstp    st0
        fstp    st0
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .return
   .u.LT.2.0.NE.0.0:
        fmul    st1, st0                        ; w = w * u
        fadd    qword [rbx]                     ; u = u + 1
        jmp    .u.LT.2.0
   .u.GE.2.0:
        fxch    st2                             ; st0 = z     | st1 = w | st2 = u
        fdivrp                                  ; st0 = z / w | st1 = u
        fabs
        fxch                                    ; st0 = u     | st1 = |z|

        ; if ( u == 2.0 )
        fcom    qword [rdx]                     ; compare u to 2.0
        fnjne  .u.NE.2.0                        ; jump if u <> 2.0
   .u.EQ.2.0:
        fstp    st0                             ; st0 = z
        mov     rax, @@floge.core
        call    rax
        jmp    .return
   .u.NE.2.0:

        fsub    qword [rdx]                     ; st0 = u - 2 | st1 = z

        mov     rdx, ??.SD_flgamma_Bn
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
        fmul    st0, st1                        ; st0 = P   | st1 = u | st2 = z
        ;
        mov     rdx, ??.SD_flgamma_Cn
        fxch                                    ; st0 = u   | st1 = P | st2 = z
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
        fmul    st0, st1
        fadd    qword [rdx + 5*8]
        fmulp
        fadd    qword [rdx + 6*8]               ; st0 = Q   | st1 = P   | st2 = z
        ;
        fdivp                                   ; st0 = P/Q | st1 = z
        fxch                                    ; st0 = z   | st1 = P/Q
        mov     rax, @@floge.core
        call    rax
        faddp

   .return:
        retn
$endp

; x < -34
$asprocf @@.flgamma.LT.m34.0

        fabs                                    ; st0 = q  | st1 = z = frac(x)

        fld     st0
        mov     rax, @@flgamma.core
        call    rax                             ; st0 = LG | st1 = q | st2 = z

        fxch    st2                             ; st0 = z  | st1 = q | st2 = LG
        fldpi
        fmulp
        mov     rax, @@fsin.core
        call    rax

        fmulp
        fabs
        mov     rax, @@floge.core
        call    rax

        fldq    SIC_AX.Ln.PI
        fsubrp
        fsubrp

   .return:
        retn
$endp

$asprocf @@flgamma

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@lgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : st0 = x | st1 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        mov     rdx, SIC_AX.m34.0               ; rdx = -34.0
        ; if ( x < -34.0 )
        fcom    qword [rdx]                     ; compare x to -34.0
        fnjge  .GE.m34.0                        ; jump if x >= -34.0

   .LT.m34.0:
        mov     rax, @@.flgamma.LT.m34.0
        call    rax
        jmp    .return

   .GE.m34.0:
        ftst                                    ; compare x to 0.0
        fnjge  .GE.m34.0.GE.0.0                 ; jump if x >= 0.0
   .GE.m34.0.LT.0.0:                            ; st0 = x | st1 = frac(x)
        fstp    st1                             ; st0 = x
   .GE.m34.0.GE.0.0:
        mov     rdx, SIC_AX.13.0                ; rdx = 13.0
        ; if ( x < 13.0 )
        fcom    qword [rdx]                     ; compare x to 13.0
        fnjge  .GE.13.0                         ; jump if x >= 13.0

   .LT.13.0:
        mov     rax, @@.flgamma.LT.13.0
        call    rax
        jmp    .return

   .GE.13.0:
        mov     rax, @@.flgamma.GE.13.0
        call    rax

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@flgamma.sse
$else
  @@flgamma.fpu
$end

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/rgamma.c
; Reciprocal gamma function

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_rgamma.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@frgamma.sse
{
; x < -34.034
$asprocf @@.frgamma.LT.m34.0

        push    rdi                             ; rdi = sign bit (0 - positive, 1 - negative)

        @@.abs  xmm0                            ; xmm0 = w = |x|
        xmovx   xmm7, xmm0                      ; xmm7 = w

        xmovsd  xmm5, SIC_AX.pi
        mulsd   xmm0, xmm5
        mov     rax, @@fsin.core
        call    rax
        mulsd   xmm0, xmm7
        @@.abs  xmm0      
        mov     rax, @@floge.core
        call    rax
        @@.xch  xmm0, xmm7
        mov     rax, @@flgamma.core
        call    rax
        addsd   xmm0, xmm7
        xmovsd  xmm5, SIC_AX.Ln.PI
        subsd   xmm0, xmm5
        mov     rax, @@fexp.enter
        call    rax

        pop     rdi
        test    rdi, 1
        jz     .return
        @@.chs  xmm0

   .return:
        retn
$endp

; x >= -34.034
$asprocf @@.frgamma.GE.m34.0

        xmovsd  xmm5, SIC_AX.1.0                ; xmm5 = 1.0
        xmovx   xmm3, xmm5                      ; xmm3 = z = 1.0

   .w.GT.1.0:
        ; while ( w > 1.0 )
        comisd  xmm0, xmm5                      ; compare w to 1.0
        jbe    .w.LE.1.0                        ; jump if w <= 1.0
        subsd   xmm0, xmm5                      ; w = w - 1
        mulsd   xmm3, xmm0                      ; z = z * w
        jmp    .w.GT.1.0
   .w.LE.1.0:

        xmovx   xmm2, xmm5                      ; xmm2 = u = 1.0
        xorpd   xmm4, xmm4                      ; xmm4 = 0.0
   .w.LT.0.0:
        ; while ( w < 0.0 )
        comisd  xmm0, xmm4                      ; compare w to 0.0
        jae    .w.GE.0.0                        ; jump if w >= 0.0
        mulsd   xmm2, xmm0                      ; u = u * w
        addsd   xmm0, xmm5                      ; w = w + 1
        jmp    .w.LT.0.0
   .w.GE.0.0:
        divsd   xmm3, xmm2                      ; z = z/u

        ; if ( w == 1.0 )
        ucomisd xmm0, xmm5                      ; compare w to 1.0
        jnz    .w.NE.1.0                        ; jump if w <> 1.0
        jp     .w.NE.1.0
   .w.EQ.1.0:
        xmovx   xmm0, xmm5
        divsd   xmm0, xmm3                      ; return 1.0/z
        jmp    .return

   .w.NE.1.0:
        xmovx   xmm4, xmm0                      ; xmm4 = w
        divsd   xmm0, xmm3                      ; xmm0 = w/z
        xmovsd  xmm5, SIC_AX.4.0
        mulsd   xmm4, xmm5
        xmovsd  xmm5, SIC_AX.2.0
        subsd   xmm4, xmm5                      ; xmm4 = x = 4.0*w-2.0

        ; Evaluate Chebyshev series

        xor     rcx, rcx
        mov     rdx, ??.SD_frgamma_Rn
        movsd   xmm1, qword [rdx + rcx*8]       ; xmm1 = b0 = *p++
        xorpd   xmm2, xmm2                      ; xmm2 = b1 = 0.0

        inc     rcx
   .CHE:
        xmovx   xmm3, xmm2                      ; xmm3 = b2 = b1
        xmovx   xmm2, xmm1                      ; b1 = b0
        mulsd   xmm1, xmm4
        subsd   xmm1, xmm3
        addsd   xmm1, qword [rdx + rcx*8]       ; b0 = x * b1 - b2 + *p++
        inc     rcx
        cmp     rcx, 16
        jb     .CHE

        subsd   xmm1, xmm3
        xmovsd  xmm4, SIC_AX.0.5
        mulsd   xmm1, xmm4                      ; xmm1 = 0.5*(b0-b2)

        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm1, xmm5
        mulsd   xmm0, xmm1

   .return:
        retn
$endp

$asprocf @@frgamma

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@rgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : xmm0 = x | xmm3 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        xmovsd  xmm5, ??.SD_frgamma_m34.0
        ; if ( x < -34.034 )
        comisd  xmm0, xmm5                      ; compare x to -34.034
        jae    .GE.m34.0                        ; jump if x >= -34.034

   .LT.m34.0:
        mov     rax, @@.frgamma.LT.m34.0
        call    rax
        jmp    .return

   .GE.m34.0:
        mov     rax, @@.frgamma.GE.m34.0
        call    rax

   .return:
        retn
$endp
}

macro @@frgamma.fpu
{
; x < -34.034
$asprocf @@.frgamma.LT.m34.0

        push    rdi                             ; rdi = sign bit (0 - positive, 1 - negative)

        fabs                                    ; st0 = w = |x|
        fld     st0                             ; st0 = w | st1 = w

        fldpi
        fmulp
        mov     rax, @@fsin.core
        call    rax
        fmul    st0, st1
        fabs
        mov     rax, @@floge.core
        call    rax
        fxch
        mov     rax, @@flgamma.core
        call    rax
        faddp
        fsubq   SIC_AX.Ln.PI
        mov     rax, @@fexp.enter
        call    rax

        pop     rdi
        test    rdi, 1
        jz     .return
        fchs

   .return:
        retn
$endp

; x >= -34.034
$asprocf @@.frgamma.GE.m34.0

        mov     rbx, SIC_AX.1.0                 ; rbx = 1.0

        fld1
        fxch                                    ; st0 = w | st1 = z = 1

   .w.GT.1.0:
        ; while ( w > 1.0 )
        fcom    qword [rbx]                     ; compare w to 1.0
        fnjle  .w.LE.1.0                        ; jump if w <= 1.0
        fsub    qword [rbx]                     ; w = w - 1
        fmul    st1, st0                        ; z = z * w
        jmp    .w.GT.1.0
   .w.LE.1.0:

        fld1                                    ; st0 = u = 1 | st1 = w | st2 = z
        fxch                                    ; st0 = w     | st1 = u | st2 = z
   .w.LT.0.0:
        ; while ( w < 0.0 )
        ftst                                    ; compare w to 0.0
        fnjge  .w.GE.0.0                        ; jump if w >= 0.0
        fmul    st1, st0                        ; u = u * w
        fadd    qword [rbx]                     ; w = w + 1
        jmp    .w.LT.0.0
   .w.GE.0.0:
        fxch                                    ; st0 = u     | st1 = w | st2 = z
        fdivp   st2, st0                        ; st0 = w     | st1 = z/u

        ; if ( w == 1.0 )
        fcom    qword [rbx]                     ; compare w to 1.0
        fnjne  .w.NE.1.0                        ; jump if w <> 1.0
   .w.EQ.1.0:
        fstp    st0                             ; st0 = z
        fld1
        fdivrp                                  ; return 1.0/z
        jmp    .return

   .w.NE.1.0:
        fld     st0                             ; st0 = w     | st1 = w | st2 = z
        fdivrp  st2, st0                        ; st0 = w     | st1 = w/z
        fmulq   SIC_AX.4.0
        fsubq   SIC_AX.2.0                      ; st0 = x = 4.0*w-2.0   | st1 = w/z

        ; Evaluate Chebyshev series

        xor     rcx, rcx
        mov     rdx, ??.SD_frgamma_Rn
        fldz
        fldz
        fld     qword [rdx + rcx*8]             ; st0 = b0 = *p++ | st1 = b1 = 0  | st2 = b2 = 0  | st3 = x | st4 = w/z

        inc     rcx
   .CHE:
        fstp    st2                             ; st0 = b1        | st1 = b0      | st2 = x       | st3 = w/z
        fxch                                    ; st0 = b0        | st1 = b1      | st2 = x       | st3 = w/z
        fld     st0                             ; st0 = b1        | st1 = b1 = b0 | st2 = b2 = b1 | st3 = x | st4 = w/z
        fmul    st0, st3
        fsub    st0, st2
        fadd    qword [rdx + rcx*8]             ; st0 = b0 = x * b1 - b2 + *p++
        inc     rcx
        cmp     rcx, 16
        jb     .CHE

        fstp    st1
        fsubrp
        fmulq   SIC_AX.0.5                      ; st0 = 0.5*(b0-b2) | st1 = x   | st2 = w/z
        fstp    st1                             ; st0 = 0.5*(b0-b2) | st1 = w/z

        fadd    qword [rbx]
        fmulp

   .return:
        retn
$endp

$asprocf @@frgamma

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@rgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : st0 = x | st1 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        fstp    st1                             ; st0 = x

        mov     rdx, ??.SD_frgamma_m34.0
        ; if ( x < -34.034 )
        fcom    qword [rdx]                     ; compare x to -34.034
        fnjge  .GE.m34.0                        ; jump if x >= -34.034

   .LT.m34.0:
        mov     rax, @@.frgamma.LT.m34.0
        call    rax
        jmp    .return

   .GE.m34.0:
        mov     rax, @@.frgamma.GE.m34.0
        call    rax

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@frgamma.sse
$else
  @@frgamma.fpu
$end

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; rtgamma(x) = 1/tgamma(x)

macro @@frtgamma.sse
{
$asprocf @@frtgamma

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@rgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : xmm0 = x | xmm3 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        mov     rax, @@ftgamma.core
        call    rax

        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5

   .return:
        retn
$endp
}

macro @@frtgamma.fpu
{
$asprocf @@frtgamma

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@rgamma.arg               ; !!! use rbx
        call    rbx                             ; x < 0 : st0 = x | st1 = frac(x) | rdi = sign bit (0 - positive, 1 - negative)
        test    rbx, rbx
        jz     .return
   .core:
        mov     rax, @@ftgamma.core
        call    rax

        fld1
        fdivrp

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@frtgamma.sse
$else
  @@frtgamma.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; beta function
; beta(a,b) = tgamma(a)*tgamma(b)/tgamma(a+b)

macro @@fbeta.sse
{
        local   @space, @a, @b, @ab, @ga, @gb, @gab

        @space  = 6*16                          ; 6 local variables

        @a      EQU rsp + 0*16
        @b      EQU rsp + 1*16
        @ab     EQU rsp + 2*16
        @ga     EQU rsp + 3*16
        @gb     EQU rsp + 4*16
        @gab    EQU rsp + 5*16

$asprocf @@fbeta.tgamma

   .enter:
        @@.stack.align16.enter
        sub     rsp, @space

   .core:
        movsd   [@a], xmm0                      ; save a
        movsd   [@b], xmm1                      ; save b
        addsd   xmm0, xmm1                      ; xmm0 = a+b
        movsd   [@ab], xmm0                     ; save a+b

   .gab:
;       movsd   xmm0, [@ab]
        mov     rbx, @@ftgamma.enter            ; !!! use rbx
        call    rbx                             ; xmm0 = tgamma(a+b)
        test    rbx, rbx
        jnz    .gab.norm
   .gab.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .Zero
        test    cx, 0x0001                      ; test zero flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Zero
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gab.norm:
        movsd   [@gab], xmm0

   .ga:
        movsd   xmm0, [@a]
        mov     rbx, @@ftgamma.enter            ; !!! use rbx
        call    rbx                             ; xmm0 = tgamma(a)
        test    rbx, rbx
        jnz    .ga.norm
   .ga.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .ga.norm:
        movsd   [@ga], xmm0

   .gb:
        movsd   xmm0, [@b]
        mov     rbx, @@ftgamma.enter            ; !!! use rbx
        call    rbx                             ; xmm0 = tgamma(b)
        test    rbx, rbx
        jnz    .gb.norm
   .gb.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gb.norm:
        movsd   [@gb], xmm0

        movsd   xmm0, [@gab]
        xmovx   xmm4, xmm0
        @@.abs  xmm4                            ; xmm4 = |gab|
        xmovsd  xmm5, SIC_AX.1.0
        comisd  xmm4, xmm5                      ; compare |gab| to 1.0
        jae    .gab.GE.1.0                      ; jump if |gab| >= 1.0

   .gab.LT.1.0.or.EQ.0.0:
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5                      ; compare gab to 0.0
        jnz    .gab.LT.1.0                      ; jump if gab <> 0.0
        jp     .gab.LT.1.0

   .gab.EQ.0.0:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .leave

   .gab.LT.1.0:
        movsd   xmm0, [@ga]
        xmovx   xmm4, xmm0
        movsd   xmm5, [@gb]
        @@.abss xmm4, xmm5
        comisd  xmm4, xmm5                      ; compare |ga| to |gb|
        ja     .gab.LT.1.0..ga.GT.gb            ; jump if |ga| > |gb|
   .gab.LT.1.0..ga.LE.gb:
        divsd   xmm0, [@gab]                    ; (ga/gab)
        mulsd   xmm0, [@gb]                     ; (ga/gab)*gb
        jmp    .leave
   .gab.LT.1.0..ga.GT.gb:
        movsd   xmm5, [@gb]
        divsd   xmm5, [@gab]                    ; (gb/gab)
        mulsd   xmm0, xmm5                      ; (gb/gab)*ga
        jmp    .leave

   .gab.GE.1.0:
        movsd   xmm0, [@ga]
        xmovx   xmm4, xmm0
        movsd   xmm5, [@gb]
        @@.abss xmm4, xmm5
        comisd  xmm4, xmm5                      ; compare |ga| to |gb|
        ja     .gab.GE.1.0..ga.GT.gb            ; jump if |ga| > |gb|
   .gab.GE.1.0..ga.LE.gb:
        movsd   xmm5, [@gb]
        divsd   xmm5, [@gab]                    ; (gb/gab)
        mulsd   xmm0, xmm5                      ; (gb/gab)*ga
        jmp    .leave
   .gab.GE.1.0..ga.GT.gb:
        divsd   xmm0, [@gab]                    ; (ga/gab)
        mulsd   xmm0, [@gb]                     ; (ga/gab)*gb
        jmp    .leave

   .NaN:
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .leave

   .PInf:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .leave

   .Zero:
        xorpd   xmm0, xmm0
;       jmp    .leave

   .leave:
        add     rsp, @space
        @@.stack.align16.leave
   .return:
        retn
$endp

$asprocf @@fbeta.lgamma

   .enter:
        push    rsi
        @@.stack.align16.enter
        sub     rsp, @space

   .core:
        xor     rsi, rsi

        movsd   [@a], xmm0                      ; save a
        movsd   [@b], xmm1                      ; save b
        addsd   xmm0, xmm1                      ; xmm0 = a+b
        movsd   [@ab], xmm0                     ; save a+b

   .gab:
;       movsd   xmm0, [@ab]
        mov     rbx, @@flgamma.enter            ; !!! use rbx
        call    rbx                             ; xmm0 = lgamma(a+b)
        xor     rsi, rdi
        test    rbx, rbx
        jnz    .gab.norm
   .gab.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .Zero
        test    cx, 0x0001                      ; test zero flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Zero
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gab.norm:
        movsd   [@gab], xmm0

   .ga:
        movsd   xmm0, [@a]
        mov     rbx, @@flgamma.enter            ; !!! use rbx
        call    rbx                             ; xmm0 = lgamma(a)
        xor     rsi, rdi
        test    rbx, rbx
        jnz    .ga.norm
   .ga.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .ga.norm:
        movsd   [@ga], xmm0

   .gb:
        movsd   xmm0, [@b]
        mov     rbx, @@flgamma.enter            ; !!! use rbx
        call    rbx                             ; xmm0 = lgamma(b)
        xor     rsi, rdi
        test    rbx, rbx
        jnz    .gb.norm
   .gb.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gb.norm:
;       movsd   [@gb], xmm0

;       movsd   xmm0, [@gb]
        addsd   xmm0, [@ga]
        subsd   xmm0, [@gab]

        mov     rax, @@fexp.enter
        call    rax
        jmp    .leave.sign.main

   .NaN:
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .leave

   .PInf:
        xmovsd  xmm0, SIC_AX.PInf
        jmp    .leave.sign

   .Zero:
        xorpd   xmm0, xmm0
;       jmp    .leave.sign

   .leave.sign:
        @@.abs  xmm0
   .leave.sign.main:
        test    rsi, 1
        jz     .leave
        @@.chs  xmm0

   .leave:
        add     rsp, @space
        @@.stack.align16.leave
        pop     rsi
   .return:
        retn
$endp

$asprocf @@fbeta

        movsd   xmm0, qword [rsp]
        movsd   xmm1, qword [rsp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
   .core:
        xmovx   xmm4, xmm0
        addsd   xmm4, xmm1
        @@.abs  xmm4                            ; xmm4 = |a+b|
        xmovsd  xmm5, ??.SD_fbeta_maxgam        ; xmm5 = maxgam = 34.84...
        comisd  xmm4, xmm5                      ; compare |a+b| to maxgam
        jbe    .core.tgamma                     ; jump if |a+b| <= maxgam

   .core.lgamma:
        mov     rax, @@fbeta.lgamma
        call    rax
        jmp    .return

   .core.tgamma:
        mov     rax, @@fbeta.tgamma
        call    rax

   .return:
        retn
$endp
}

macro @@fbeta.fpu
{
        local   @space, @a, @b, @ab, @ga, @gb, @gab

        @space  = 6*16                          ; 6 local variables

        @a      EQU rsp + 0*16
        @b      EQU rsp + 1*16
        @ab     EQU rsp + 2*16
        @ga     EQU rsp + 3*16
        @gb     EQU rsp + 4*16
        @gab    EQU rsp + 5*16

$asprocf @@fbeta.tgamma

   .enter:
        sub     rsp, @space

   .core:
        fst     qword [@b]                      ; st0 = b | st1 = a
        fxch                                    ; st0 = a | st1 = b
        fst     qword [@a]
        faddp                                   ; st0 = a+b
;       fst     qword [@ab]

   .gab:
;       fld     qword [@ab]
        mov     rbx, @@ftgamma.enter            ; !!! use rbx
        call    rbx                             ; st0 = tgamma(a+b)
        test    rbx, rbx
        jnz    .gab.norm
   .gab.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .Zero
        test    cx, 0x0001                      ; test zero flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Zero
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gab.norm:
        fstp    qword [@gab]

   .ga:
        fld     qword [@a]
        mov     rbx, @@ftgamma.enter            ; !!! use rbx
        call    rbx                             ; st0 = tgamma(a)
        test    rbx, rbx
        jnz    .ga.norm
   .ga.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .ga.norm:
        fstp    qword [@ga]

   .gb:
        fld     qword [@b]
        mov     rbx, @@ftgamma.enter            ; !!! use rbx
        call    rbx                             ; st0 = tgamma(b)
        test    rbx, rbx
        jnz    .gb.norm
   .gb.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gb.norm:
        fstp    qword [@gb]

        fld     qword [@gab]                    ; st0 = gab
        fld1                                    ; st0 = 1.0   | st1 = gab
        fld     st1                             ; st0 = gab   | st1 = 1.0 | st2 = gab
        fabs                                    ; st0 = |gab| | st1 = 1.0 | st2 = gab
        fcompp                                  ; compare |gab| to 1.0
        fnjge  .gab.GE.1.0                      ; jump if |gab| >= 1.0

   .gab.LT.1.0.or.EQ.0.0:
        ftst                                    ; compare gab to 0.0
        fnjnz  .gab.LT.1.0                      ; jump if gab <> 0.0

   .gab.EQ.0.0:
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .leave

   .gab.LT.1.0:
        fld     qword [@gb]
        fld     qword [@ga]                     ; st0 = ga | st1 = gb | st2 = gab

        fld     st1
        fabs
        fld     st1
        fabs
        fcompp                                  ; compare |ga| to |gb|
        fnjg   .gab.LT.1.0..ga.GT.gb            ; jump if |ga| > |gb|
   .gab.LT.1.0..ga.LE.gb:
        fdivrp  st2, st0                        ; st0 = gb | st1 = (ga/gab)
        fmulp                                   ; st0 = (ga/gab)*gb
        jmp    .leave
   .gab.LT.1.0..ga.GT.gb:
        fxch                                    ; st0 = gb | st1 = ga | st2 = gab
        fdivrp  st2, st0                        ; st0 = ga | st1 = (gb/gab)
        fmulp                                   ; st0 = (gb/gab)*ga
        jmp    .leave

   .gab.GE.1.0:
        fld     qword [@gb]
        fld     qword [@ga]                     ; st0 = ga | st1 = gb

        fld     st1
        fabs
        fld     st1
        fabs
        fcompp                                  ; compare |ga| to |gb|
        fnjg   .gab.GE.1.0..ga.GT.gb            ; jump if |ga| > |gb|
   .gab.GE.1.0..ga.LE.gb:
        fxch                                    ; st0 = gb | st1 = ga | st2 = gab
        fdivrp  st2, st0                        ; st0 = ga | st1 = (gb/gab)
        fmulp                                   ; st0 = (gb/gab)*ga
        jmp    .leave
   .gab.GE.1.0..ga.GT.gb:
        fdivrp  st2, st0                        ; st0 = gb | st1 = (ga/gab)
        fmulp                                   ; st0 = (ga/gab)*gb
        jmp    .leave

   .NaN:
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .leave

   .PInf:
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .leave

   .Zero:
        fstp    st0
        fldz
;       jmp    .leave

   .leave:
        add     rsp, @space
   .return:
        retn
$endp

$asprocf @@fbeta.lgamma

   .enter:
        push    rsi
        sub     rsp, @space

   .core:
        xor     rsi, rsi

        fst     qword [@b]                      ; st0 = b | st1 = a
        fxch                                    ; st0 = a | st1 = b
        fst     qword [@a]
        faddp                                   ; st0 = a+b
;       fst     qword [@ab]

   .gab:
;       fld     qword [@ab]
        mov     rbx, @@flgamma.enter            ; !!! use rbx
        call    rbx                             ; st0 = lgamma(a+b)
        xor     rsi, rdi
        test    rbx, rbx
        jnz    .gab.norm
   .gab.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .Zero
        test    cx, 0x0001                      ; test zero flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .Zero
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gab.norm:
        fstp    qword [@gab]

   .ga:
        fld     qword [@a]
        mov     rbx, @@flgamma.enter            ; !!! use rbx
        call    rbx                             ; st0 = lgamma(a)
        xor     rsi, rdi
        test    rbx, rbx
        jnz    .ga.norm
   .ga.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .ga.norm:
        fstp    qword [@ga]

   .gb:
        fld     qword [@b]
        mov     rbx, @@flgamma.enter            ; !!! use rbx
        call    rbx                             ; st0 = lgamma(b)
        xor     rsi, rdi
        test    rbx, rbx
        jnz    .gb.norm
   .gb.spec:
        test    cx, 0x0020                      ; test negative integer flag
        jnz    .PInf
        test    cx, 0x0002                      ; test infinity flag
        jnz    .PInf
        test    cx, 0x0004                      ; test nan flag
        jnz    .NaN
   .gb.norm:
;       fstp    qword [@gb]

;       fld     qword [@gb]
        fadd    qword [@ga]
        fsub    qword [@gab]

        mov     rax, @@fexp.enter
        call    rax
        jmp    .leave.sign.main

   .NaN:
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .leave

   .PInf:
        fstp    st0
        fldq    SIC_AX.PInf
        jmp    .leave.sign

   .Zero:
        fstp    st0
        fldz
;       jmp    .leave.sign

   .leave.sign:
        fabs
   .leave.sign.main:
        test    rsi, 1
        jz     .leave
        fchs

   .leave:
        add     rsp, @space
        pop     rsi
   .return:
        retn
$endp

$asprocf @@fbeta

        fld     qword [rsp]
        fld     qword [rsp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
   .core:
        fld     st1                             ; st0 = a     | st1 = b | st2 = a
        fadd    st0, st1                        ; st0 = a+b   | st1 = b | st2 = a
        fabs                                    ; st0 = |a+b| | st1 = b | st2 = a
        fldq    ??.SD_fbeta_maxgam              ; st0 = maxgam = 34.84...
        fcompp                                  ; compare maxgam to |a+b|
        fnjge  .core.tgamma                     ; jump if |a+b| <= maxgam (maxgam >= |a+b|)

   .core.lgamma:
        mov     rax, @@fbeta.lgamma
        call    rax
        jmp    .return

   .core.tgamma:
        mov     rax, @@fbeta.tgamma
        call    rax

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fbeta.sse
$else
  @@fbeta.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/fresnl.c
; Fresnel integrals

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_fresnel.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ffresnel.sse
{
$asprocf @@ffresnel

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@fresnel.arg              ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@ffresnels

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@fresnels.arg             ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@ffresnelc

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@fresnelc.arg             ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp
}

macro @@ffresnel.fpu
{
$asprocf @@ffresnel

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@fresnel.arg              ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@ffresnels

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@fresnels.arg             ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@ffresnelc

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@fresnelc.arg             ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ffresnel.sse
$else
  @@ffresnel.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/sici.c
; Sine and cosine integrals

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_sici.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fsici.sse
{
$asprocf @@fsici

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sici.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fsi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@si.arg                   ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fci

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@fci.arg                  ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp
}

macro @@fsici.fpu
{
$asprocf @@fsici

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@sici.arg                 ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fsi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@si.arg                   ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fci

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@ci.arg                   ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsici.sse
$else
  @@fsici.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/shichi.c
; Hyperbolic sine and cosine integrals

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_shichi.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fshichi.sse
{
$asprocf @@fshichi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@shichi.arg               ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fshi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@shi.arg                  ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fchi

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@fchi.arg                 ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp
}

macro @@fshichi.fpu
{
$asprocf @@fshichi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     rbx, @@shichi.arg               ; !!! use rbx
        call    rbx
        test    rbx, rbx
        jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fshi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@shi.arg                  ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp

$asprocf @@fchi

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
;       mov     rbx, @@chi.arg                  ; !!! use rbx
;       call    rbx
;       test    rbx, rbx
;       jz     .return
   .core:

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fshichi.sse
$else
  @@fshichi.fpu
$end

; ------------------------------------------------------------------------------
