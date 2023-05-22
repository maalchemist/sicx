
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (approximate trigonometric functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; angle disposition
; 0 <= x < 2*pi
;
; 0 : 0*pi/4 <= x < 1*pi/4    x = x0
; 1 : 1*pi/4 <= x < 2*pi/4    x = pi/2 - x0
; 2 : 2*pi/4 <= x < 3*pi/4    x = pi/2 + x0
; 3 : 3*pi/4 <= x < 4*pi/4    x = pi - x0
; 4 : 4*pi/4 <= x < 5*pi/4    x = pi + x0
; 5 : 5*pi/4 <= x < 6*pi/4    x = 3*pi/2 - x0
; 6 : 6*pi/4 <= x < 7*pi/4    x = 3*pi/2 + x0
; 7 : 7*pi/4 <= x < 8*pi/4    x = 2*pi - x0
;
; 0 <= x0 < pi/4

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/sin.c
; Circular sine
; Circular cosine

; sin(x) = x + (x^3)*P(x^2)
;        = x*(1 + (x^2)*P(x^2))
; 0 <= x < pi/4
;
; sin(x) = x*(
;          1 +                                  // P6
;  (x^2)*(-1.66666666666666307295E-1 +          // P5
;  (x^2)*( 8.33333333332211858878E-3 +          // P4
;  (x^2)*(-1.98412698295895385996E-4 +          // P3
;  (x^2)*( 2.75573136213857245213E-6 +          // P2
;  (x^2)*(-2.50507477628578072866E-8 +          // P1
;  (x^2)*( 1.58962301576546568060E-10 )...)     // P0
;
; sin(x) = x*(
;          1 +                                  // P6
;  (x^2)*(
;  (
;         -1.66666666666666307295E-1 +          // P5
;  (x^2)*( 8.33333333332211858878E-3 +          // P4
;  (x^2)*(-1.98412698295895385996E-4 )...)      // P3
;  +
;  (x^6)*(
;          2.75573136213857245213E-6 +          // P2
;  (x^2)*(-2.50507477628578072866E-8 +          // P1
;  (x^2)*( 1.58962301576546568060E-10 )...)     // P0
;  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_sin.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fsin.sse
{
; 0 <= x < pi/4
$asprocf @@fsin.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2
        xmovx   xmm4, xmm5                      ; xmm4 = x^2:?
        mulsd   xmm4, xmm4                      ; xmm4 = x^4:?
        mulsd   xmm4, xmm5                      ; xmm4 = x^6:?

        mov     edx, ??.PD_fsin_Pn
        movapd  xmm3, [edx + 0*16]
        mulpd   xmm3, xmm5
        addpd   xmm3, [edx + 1*16]
        mulpd   xmm3, xmm5
        addpd   xmm3, [edx + 2*16]              ; xmm3 = sinA:sinB
        ;
        mulsd   xmm3, xmm4                      ; xmm3 = sinA*(x^6):sinB
    $ifdef _SSE3
        haddpd  xmm3, xmm3                      ; xmm3 = sinA*(x^6)+sinB
    $else
        oops haddpd
    $end
        mulsd   xmm3, xmm5
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm3, xmm5
        mulsd   xmm0, xmm3
   .return:
        retn
$endp

$asprocf @@fsin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sin.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.sin.cos.reduce                   ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 4
        jne    .main
   .x.PI:                                       ; sin(PI + 2*PI*n) = 0
   .x.0:                                        ; sin(0 + 2*PI*n) = 0
        xorpd   xmm0, xmm0
        jmp    .return

   .main:
        mov     eax, @@fsin.base.enter
        mov     edx, @@fcos.base.enter
        mov     ebx, @@sin.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fsinpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sinpi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xintsd  xmm4, xmm0                      ; xmm4 = int(x)
        ucomisd xmm0, xmm4                      ; compare x to int(x)
        jnz    .Not.Int
        jp     .Not.Int
   .Int:
        xorpd   xmm0, xmm0                      ; sin(PI*n) = 0
        jmp    .return
   .Not.Int:
        subsd   xmm0, xmm4                      ; xmm0 = frac(x)
        @@.xmm4.so.flags.edi                    ; edi = int(x) sign and odd flags
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5

   .reduce:
        @@xmm0.pi.sin.cos.reduce                ; ecx = angle disposition
   .main:
        mov     eax, @@fsin.base.enter
        mov     edx, @@fcos.base.enter
        mov     ebx, @@sin.pn
        call    ebx
   .return:
        retn
$endp
}

macro @@fsin.fpu
{
; 0 <= x < pi/4
$asprocf @@fsin.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2 | st1 = x

        mov     edx, ??.SD_fsin_Pn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1
        fadd    qword [edx + 5*8]
        fmulp
        fadd    qword [edx + 6*8]
        fmulp
   .return:
        retn
$endp

$asprocf @@fsin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sin.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.sin.cos.reduce                    ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 4
        jne    .main
   .x.PI:                                       ; sin(PI + 2*PI*n) = 0
   .x.0:                                        ; sin(0 + 2*PI*n) = 0
        fstp    st0
        fldz
        jmp    .return

   .main:
        mov     eax, @@fsin.base.enter
        mov     edx, @@fcos.base.enter
        mov     ebx, @@sin.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fsinpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sinpi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        fld     st0
        @@.int.st0                              ; st0 = int(x) | st1 = x
        fcom                                    ; compare int(x) to x
        fnjne  .Not.Int
   .Int:                                        ; st0 = int(x) | st1 = x
        fstp    st0
        fstp    st0
        fldz                                    ; sin(PI*n) = 0
        jmp    .return
   .Not.Int:                                    ; st0 = int(x) | st1 = x
        @@.st0.so.flags.edi                     ; edi = int(x) sign and odd flags
        fsubp                                   ; st0 = frac(x)
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        fld1
        faddp

   .reduce:
        @@st0.pi.sin.cos.reduce                 ; ecx = angle disposition
   .main:
        mov     eax, @@fsin.base.enter
        mov     edx, @@fcos.base.enter
        mov     ebx, @@sin.pn
        call    ebx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsin.sse
$else
  @@fsin.fpu
$end

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/sin.c
; Circular sine
; Circular cosine

; cos(x) = 1 - 0.5*(x^2) + (x^4)*Q(x^2)
; 0 <= x < pi/4
;
; cos(x) =
;          1 +                                  // Q7
;  (x^2)*(-0.5 +                                // Q6
;  (x^2)*( 4.16666666666665929218E-2 +          // Q5
;  (x^2)*(-1.38888888888730564116E-3 +          // Q4
;  (x^2)*( 2.48015872888517045348E-5 +          // Q3
;  (x^2)*(-2.75573141792967388112E-7 +          // Q2
;  (x^2)*( 2.08757008419747316778E-9 +          // Q1
;  (x^2)*(-1.13585365213876817300E-11 )...)     // Q0
;
; cos(x) =
;          1 +                                  // Q7
;  (x^2)*(-0.5 +                                // Q6
;  (x^2)*( 4.16666666666665929218E-2 +          // Q5
;  (x^2)*(-1.38888888888730564116E-3 )...)      // Q4
;  +
;  (x^8)*(
;          2.48015872888517045348E-5 +          // Q3
;  (x^2)*(-2.75573141792967388112E-7 +          // Q2
;  (x^2)*( 2.08757008419747316778E-9 +          // Q1
;  (x^2)*(-1.13585365213876817300E-11 )...)     // Q0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fcos.sse
{
; 0 <= x < pi/4
$asprocf @@fcos.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2
        xmovx   xmm4, xmm5                      ; xmm4 = x^2:?
        mulsd   xmm4, xmm4                      ; xmm4 = x^4:?
        mulsd   xmm4, xmm4                      ; xmm4 = x^8:?

        mov     edx, ??.PD_fcos_Qn
        movapd  xmm0, [edx + 0*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 1*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 2*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 3*16]              ; xmm0 = cosA:cosB
        ;
        mulsd   xmm0, xmm4                      ; xmm0 = cosA*(x^8):cosB
    $ifdef _SSE3
        haddpd  xmm0, xmm0                      ; xmm0 = cosA*(x^8)+cosB
    $else
        oops haddpd
    $end
   .return:
        retn
$endp

$asprocf @@fcos

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cos.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.sin.cos.reduce                   ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; cos(3*PI/2 + 2*PI*n) = 0
   .x.PI2:                                      ; cos(PI/2 + 2*PI*n) = 0
        xorpd   xmm0, xmm0
        jmp    .return

   .main:
        mov     eax, @@fcos.base.enter
        mov     edx, @@fsin.base.enter
        mov     ebx, @@cos.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fcospi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cospi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.xmm0.int.flags.edi                   ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        xmovsd  xmm0, SIC_AX.m1.0               ; cos(PI*odd) = -1
        jmp    .return
   .Int.Even:
        xmovsd  xmm0, SIC_AX.1.0                ; cos(PI*even) = 1
        jmp    .return
   .Not.Int:
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        xorpd   xmm0, xmm0                      ; cos(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.main:
        xintsd  xmm4, xmm0                      ; xmm4 = int(x)
        subsd   xmm0, xmm4                      ; xmm0 = frac(x)
        @@.xmm4.so.flags.edi                    ; edi = int(x) sign and odd flags
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5

   .reduce:
        @@xmm0.pi.sin.cos.reduce                ; ecx = angle disposition
   .main:
        mov     eax, @@fcos.base.enter
        mov     edx, @@fsin.base.enter
        mov     ebx, @@cos.pn
        call    ebx
   .return:
        retn
$endp
}

macro @@fcos.fpu
{
; 0 <= x < pi/4
$asprocf @@fcos.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fmul    st0, st0                        ; st0 = x^2

        mov     edx, ??.SD_fcos_Qn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1
        fadd    qword [edx + 5*8]
        fmul    st0, st1
        fadd    qword [edx + 6*8]
        fmulp
        fadd    qword [edx + 7*8]
   .return:
        retn
$endp

$asprocf @@fcos

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cos.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.sin.cos.reduce                    ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; cos(3*PI/2 + 2*PI*n) = 0
   .x.PI2:                                      ; cos(PI/2 + 2*PI*n) = 0
        fstp    st0
        fldz
        jmp    .return

   .main:
        mov     eax, @@fcos.base.enter
        mov     edx, @@fsin.base.enter
        mov     ebx, @@cos.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fcospi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cospi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.st0.int.flags.edi                    ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:                                        ; st0 = x
        fstp    st0
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        fld1
        fchs                                    ; cos(PI*odd) = -1
        jmp    .return
   .Int.Even:
        fld1                                    ; cos(PI*even) = 1
        jmp    .return
   .Not.Int:                                    ; st0 = x
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        fstp    st0
        fldz                                    ; cos(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.main:                               ; st0 = x
        fld     st0
        @@.int.st0                              ; st0 = int(x) | st1 = x
        @@.st0.so.flags.edi                     ; edi = int(x) sign and odd flags
        fsubp                                   ; st0 = frac(x)
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        fld1
        faddp

   .reduce:
        @@st0.pi.sin.cos.reduce                 ; ecx = angle disposition
   .main:
        mov     eax, @@fcos.base.enter
        mov     edx, @@fsin.base.enter
        mov     ebx, @@cos.pn
        call    ebx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fcos.sse
$else
  @@fcos.fpu
$end

; ------------------------------------------------------------------------------

; sine & cosine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fsincos.sse
{
; 0 <= x < pi/4
$asprocf @@fsincos.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xmovx   xmm5, xmm0                      ; xmm5 = x:?
        xddup   xmm4, xmm0                      ; xmm4 = x:x
        mulpd   xmm4, xmm4                      ; xmm4 = x^2:x^2

        mov     edx, ??.PD_fsico_PQ
        movapd  xmm0, [edx + 0*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 1*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 2*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 3*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 4*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 5*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 6*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 7*16]              ; xmm0 = sin':cos
        ;
        mulsd   xmm0, xmm5                      ; xmm0 = sin:cos
        movapd  xmm1, xmm0                      ; xmm1 = sin:cos
;       psrldq  xmm1, 8                         ; xmm1 = cos:0
        shufpd  xmm1, xmm1, 1                   ; xmm1 = cos:sin
   .return:
        retn
$endp

$asprocf @@fsincos

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sincos.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.sin.cos.reduce                   ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 4
        je     .x.PI
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; sin(3*PI/2 + 2*PI*n) = -1
        xmovsd  xmm0, SIC_AX.m1.0               ; cos(3*PI/2 + 2*PI*n) = 0
        xorpd   xmm1, xmm1
        jmp    .return
   .x.PI:                                       ; sin(PI + 2*PI*n) = 0
        xorpd   xmm0, xmm0                      ; cos(PI + 2*PI*n) = -1
        xmovsd  xmm1, SIC_AX.m1.0
        jmp    .return
   .x.PI2:                                      ; sin(PI/2 + 2*PI*n) = 1
        xmovsd  xmm0, SIC_AX.1.0                ; cos(PI/2 + 2*PI*n) = 0
        xorpd   xmm1, xmm1
        jmp    .return
   .x.0:                                        ; sin(0 + 2*PI*n) = 0
        xorpd   xmm0, xmm0                      ; cos(0 + 2*PI*n) = 1
        xmovsd  xmm1, SIC_AX.1.0
        jmp    .return

   .main:
        mov     eax, @@fsincos.base.enter
        mov     ebx, @@sincos.pn
        call    ebx
   .return:
        retn
$endp

; xmm4 = int(x)
$asprocf @@.fsincospi.N.5

   .Not.Int.N.5:                                ; x = N + 0.5
        @@.xmm4.int.flags.edi                   ; edi = int(x) flags
        test    edi, 0x0001                     ; test odd flag
        jz     .Not.Int.N.5.Even

   .Not.Int.N.5.Odd:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Odd.Pos
   .Not.Int.N.5.Odd.Neg:
        xmovsd  xmm0, SIC_AX.1.0                ; sin(-3*PI/2 + 2*PI*n) = 1
        xorpd   xmm1, xmm1                      ; cos(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.N.5.Odd.Pos:
        xmovsd  xmm0, SIC_AX.m1.0               ; sin(+3*PI/2 + 2*PI*n) = -1
        xorpd   xmm1, xmm1                      ; cos(PI/2 + PI*n) = 0
        jmp    .return

   .Not.Int.N.5.Even:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Even.Pos
   .Not.Int.N.5.Even.Neg:
        xmovsd  xmm0, SIC_AX.m1.0               ; sin(-PI/2 + 2*PI*n) = -1
        xorpd   xmm1, xmm1                      ; cos(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.N.5.Even.Pos:
        xmovsd  xmm0, SIC_AX.1.0                ; sin(+PI/2 + 2*PI*n) = 1
        xorpd   xmm1, xmm1                      ; cos(PI/2 + PI*n) = 0
;       jmp    .return

   .return:
        retn
$endp

$asprocf @@fsincospi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sincospi.arg             ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.xmm0.int.flags.edi                   ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        xorpd   xmm0, xmm0                      ; sin(PI*odd) = 0
        xmovsd  xmm1, SIC_AX.m1.0               ; cos(PI*odd) = -1
        jmp    .return
   .Int.Even:
        xorpd   xmm0, xmm0                      ; sin(PI*even) = 0
        xmovsd  xmm1, SIC_AX.1.0                ; cos(PI*even) = 1
        jmp    .return
   .Not.Int:
        xintsd  xmm4, xmm0                      ; xmm4 = int(x)
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        mov     ebx, @@.fsincospi.N.5
        call    ebx
        jmp    .return
   .Not.Int.main:
        subsd   xmm0, xmm4                      ; xmm0 = frac(x)
        @@.xmm4.so.flags.edi                    ; edi = int(x) sign and odd flags
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5

   .reduce:
        @@xmm0.pi.sin.cos.reduce                ; ecx = angle disposition
   .main:
        mov     eax, @@fsincos.base.enter
        mov     ebx, @@sincos.pn
        call    ebx
   .return:
        retn
$endp

; sine & cosine
; double co.sincos ( double *sin, double *cos, double x )
;
; x = esp
;
; eax = sin offset
; edx = cos offset
;
; return_1 = st1 = sin
; return_2 = st0 = cos
;
; return   = st0 = sin

$asprocf @@co.fsincos

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fsincos.enter
        call    ebx
        ;
        pop     edx eax
        movsd   qword [eax], xmm0
        movsd   qword [edx], xmm1
   .return:
        retn
$endp

$asprocf @@co.fsincospi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fsincospi.enter
        call    ebx
        ;
        pop     edx eax
        movsd   qword [eax], xmm0
        movsd   qword [edx], xmm1
   .return:
        retn
$endp
}

macro @@fsincos.fpu
{
; 0 <= x < pi/4
$asprocf @@fsincos.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0                             ; st0 = x   | st1 = x
        mov     ebx, @@fsin.base.enter
        call    ebx                             ; st0 = sin | st1 = x
        fxch                                    ; st0 = x   | st1 = sin
        mov     ebx, @@fcos.base.enter
        call    ebx                             ; st0 = cos | st1 = sin
   .return:
        retn
$endp

$asprocf @@fsincos

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sincos.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.sin.cos.reduce                    ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 4
        je     .x.PI
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; sin(3*PI/2 + 2*PI*n) = -1
        fstp    st0                             ; cos(3*PI/2 + 2*PI*n) = 0
        fld1
        fchs
        fldz
        jmp    .return
   .x.PI:                                       ; sin(PI + 2*PI*n) = 0
        fstp    st0                             ; cos(PI + 2*PI*n) = -1
        fldz
        fld1
        fchs
        jmp    .return
   .x.PI2:                                      ; sin(PI/2 + 2*PI*n) = 1
        fstp    st0                             ; cos(PI/2 + 2*PI*n) = 0
        fld1
        fldz
        jmp    .return
   .x.0:                                        ; sin(0 + 2*PI*n) = 0
        fstp    st0                             ; cos(0 + 2*PI*n) = 1
        fldz
        fld1
        jmp    .return

   .main:
        mov     eax, @@fsincos.base.enter
        mov     ebx, @@sincos.pn
        call    ebx
   .return:
        retn
$endp

; st0 = int(x) | st1 = x
$asprocf @@.fsincospi.N.5

   .Not.Int.N.5:                                ; x = N + 0.5
        @@.st0.int.flags.edi                    ; edi = int(x) flags
        fstp    st0
        fstp    st0
        test    edi, 0x0001                     ; test odd flag
        jz     .Not.Int.N.5.Even

   .Not.Int.N.5.Odd:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Odd.Pos
   .Not.Int.N.5.Odd.Neg:
        fld1                                    ; sin(-3*PI/2 + 2*PI*n) = 1
        fldz                                    ; cos(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.N.5.Odd.Pos:
        fld1
        fchs                                    ; sin(+3*PI/2 + 2*PI*n) = -1
        fldz                                    ; cos(PI/2 + PI*n) = 0
        jmp    .return

   .Not.Int.N.5.Even:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Even.Pos
   .Not.Int.N.5.Even.Neg:
        fld1
        fchs                                    ; sin(-PI/2 + 2*PI*n) = -1
        fldz                                    ; cos(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.N.5.Even.Pos:
        fld1                                    ; sin(+PI/2 + 2*PI*n) = 1
        fldz                                    ; cos(PI/2 + PI*n) = 0
;       jmp    .return

   .return:
        retn
$endp

$asprocf @@fsincospi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sincospi.arg             ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.st0.int.flags.edi                    ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:                                        ; st0 = x
        fstp    st0
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        fldz                                    ; sin(PI*odd) = 0
        fld1
        fchs                                    ; cos(PI*odd) = -1
        jmp    .return
   .Int.Even:
        fldz                                    ; sin(PI*even) = 0
        fld1                                    ; cos(PI*even) = 1
        jmp    .return
   .Not.Int:                                    ; st0 = x
        fld     st0
        @@.int.st0                              ; st0 = int(x) | st1 = x
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        mov     ebx, @@.fsincospi.N.5
        call    ebx
        jmp    .return
   .Not.Int.main:                               ; st0 = int(x) | st1 = x
        @@.st0.so.flags.edi                     ; edi = int(x) sign and odd flags
        fsubp                                   ; st0 = frac(x)
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        fld1
        faddp

   .reduce:
        @@st0.pi.sin.cos.reduce                 ; ecx = angle disposition
   .main:
        mov     eax, @@fsincos.base.enter
        mov     ebx, @@sincos.pn
        call    ebx
   .return:
        retn
$endp

; sine & cosine
; double co.sincos ( double *sin, double *cos, double x )
;
; x = esp
;
; eax = sin offset
; edx = cos offset
;
; return_1 = st1 = sin
; return_2 = st0 = cos
;
; return   = st0 = sin

$asprocf @@co.fsincos

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fsincos.enter
        call    ebx
        ;
        pop     edx eax
        fstp    qword [edx]
        fst     qword [eax]
   .return:
        retn
$endp

$asprocf @@co.fsincospi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fsincospi.enter
        call    ebx
        ;
        pop     edx eax
        fstp    qword [edx]
        fst     qword [eax]
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsincos.sse
$else
  @@fsincos.fpu
$end

; ------------------------------------------------------------------------------

; cosine & sine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fcossin.sse
{
; 0 <= x < pi/4
$asprocf @@fcossin.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xmovx   xmm5, xmm0                      ; xmm5 = x:?
        xddup   xmm4, xmm0                      ; xmm4 = x:x
        mulpd   xmm4, xmm4                      ; xmm4 = x^2:x^2

        mov     edx, ??.PD_fsico_PQ
        movapd  xmm0, [edx + 0*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 1*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 2*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 3*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 4*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 5*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 6*16]
        mulpd   xmm0, xmm4
        addpd   xmm0, [edx + 7*16]              ; xmm0 = sin':cos
        ;
        mulsd   xmm0, xmm5                      ; xmm0 = sin:cos
        xmovx   xmm1, xmm0                      ; xmm1 = sin
;       psrldq  xmm0, 8                         ; xmm0 = cos:0
        shufpd  xmm0, xmm0, 1                   ; xmm0 = cos:sin
   .return:
        retn
$endp

$asprocf @@fcossin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cossin.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.sin.cos.reduce                   ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 4
        je     .x.PI
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; cos(3*PI/2 + 2*PI*n) = 0
        xorpd   xmm0, xmm0                      ; sin(3*PI/2 + 2*PI*n) = -1
        xmovsd  xmm1, SIC_AX.m1.0
        jmp    .return
   .x.PI:                                       ; cos(PI + 2*PI*n) = -1
        xmovsd  xmm0, SIC_AX.m1.0               ; sin(PI + 2*PI*n) = 0
        xorpd   xmm1, xmm1
        jmp    .return
   .x.PI2:                                      ; cos(PI/2 + 2*PI*n) = 0
        xorpd   xmm0, xmm0                      ; sin(PI/2 + 2*PI*n) = 1
        xmovsd  xmm1, SIC_AX.1.0
        jmp    .return
   .x.0:                                        ; cos(0 + 2*PI*n) = 1
        xmovsd  xmm0, SIC_AX.1.0                ; sin(0 + 2*PI*n) = 0
        xorpd   xmm1, xmm1
        jmp    .return

   .main:
        mov     eax, @@fcossin.base.enter
        mov     ebx, @@cossin.pn
        call    ebx
   .return:
        retn
$endp

; xmm4 = int(x)
$asprocf @@.fcossinpi.N.5

   .Not.Int.N.5:                                ; x = N + 0.5
        @@.xmm4.int.flags.edi                   ; edi = int(x) flags
        test    edi, 0x0001                     ; test odd flag
        jz     .Not.Int.N.5.Even

   .Not.Int.N.5.Odd:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Odd.Pos
   .Not.Int.N.5.Odd.Neg:
        xorpd   xmm0, xmm0                      ; cos(PI/2 + PI*n) = 0
        xmovsd  xmm1, SIC_AX.1.0                ; sin(-3*PI/2 + 2*PI*n) = 1
        jmp    .return
   .Not.Int.N.5.Odd.Pos:
        xorpd   xmm0, xmm0                      ; cos(PI/2 + PI*n) = 0
        xmovsd  xmm1, SIC_AX.m1.0               ; sin(+3*PI/2 + 2*PI*n) = -1
        jmp    .return

   .Not.Int.N.5.Even:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Even.Pos
   .Not.Int.N.5.Even.Neg:
        xorpd   xmm0, xmm0                      ; cos(PI/2 + PI*n) = 0
        xmovsd  xmm1, SIC_AX.m1.0               ; sin(-PI/2 + 2*PI*n) = -1
        jmp    .return
   .Not.Int.N.5.Even.Pos:
        xorpd   xmm0, xmm0                      ; cos(PI/2 + PI*n) = 0
        xmovsd  xmm1, SIC_AX.1.0                ; sin(+PI/2 + 2*PI*n) = 1
;       jmp    .return

   .return:
        retn
$endp

$asprocf @@fcossinpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cossinpi.arg             ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.xmm0.int.flags.edi                   ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        xmovsd  xmm0, SIC_AX.m1.0               ; cos(PI*odd) = -1
        xorpd   xmm1, xmm1                      ; sin(PI*odd) = 0
        jmp    .return
   .Int.Even:
        xmovsd  xmm0, SIC_AX.1.0                ; cos(PI*even) = 1
        xorpd   xmm1, xmm1                      ; sin(PI*even) = 0
        jmp    .return
   .Not.Int:
        xintsd  xmm4, xmm0                      ; xmm4 = int(x)
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        mov     ebx, @@.fcossinpi.N.5
        call    ebx
        jmp    .return
   .Not.Int.main:
        subsd   xmm0, xmm4                      ; xmm0 = frac(x)
        @@.xmm4.so.flags.edi                    ; edi = int(x) sign and odd flags
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5

   .reduce:
        @@xmm0.pi.sin.cos.reduce                ; ecx = angle disposition
   .main:
        mov     eax, @@fcossin.base.enter
        mov     ebx, @@cossin.pn
        call    ebx
   .return:
        retn
$endp

; cosine & sine
; double co.cossin ( double *cos, double *sin, double x )
;
; x = esp
;
; eax = cos offset
; edx = sin offset
;
; return_1 = st1 = cos
; return_2 = st0 = sin
;
; return   = st0 = cos

$asprocf @@co.fcossin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fcossin.enter
        call    ebx
        ;
        pop     edx eax
        movsd   qword [eax], xmm0
        movsd   qword [edx], xmm1
   .return:
        retn
$endp

$asprocf @@co.fcossinpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fcossinpi.enter
        call    ebx
        ;
        pop     edx eax
        movsd   qword [eax], xmm0
        movsd   qword [edx], xmm1
   .return:
        retn
$endp
}

macro @@fcossin.fpu
{
; 0 <= x < pi/4
$asprocf @@fcossin.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0                             ; st0 = x   | st1 = x
        mov     ebx, @@fcos.base.enter
        call    ebx                             ; st0 = cos | st1 = x
        fxch                                    ; st0 = x   | st1 = cos
        mov     ebx, @@fsin.base.enter
        call    ebx                             ; st0 = sin | st1 = cos
   .return:
        retn
$endp

$asprocf @@fcossin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cossin.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.sin.cos.reduce                    ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 4
        je     .x.PI
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; cos(3*PI/2 + 2*PI*n) = 0
        fstp    st0                             ; sin(3*PI/2 + 2*PI*n) = -1
        fldz
        fld1
        fchs
        jmp    .return
   .x.PI:                                       ; cos(PI + 2*PI*n) = -1
        fstp    st0                             ; sin(PI + 2*PI*n) = 0
        fld1
        fchs
        fldz
        jmp    .return
   .x.PI2:                                      ; cos(PI/2 + 2*PI*n) = 0
        fstp    st0                             ; sin(PI/2 + 2*PI*n) = 1
        fldz
        fld1
        jmp    .return
   .x.0:                                        ; cos(0 + 2*PI*n) = 1
        fstp    st0                             ; sin(0 + 2*PI*n) = 0
        fld1
        fldz
        jmp    .return

   .main:
        mov     eax, @@fcossin.base.enter
        mov     ebx, @@cossin.pn
        call    ebx
   .return:
        retn
$endp

; st0 = int(x) | st1 = x
$asprocf @@.fcossinpi.N.5

   .Not.Int.N.5:                                ; x = N + 0.5
        @@.st0.int.flags.edi                    ; edi = int(x) flags
        fstp    st0
        fstp    st0
        test    edi, 0x0001                     ; test odd flag
        jz     .Not.Int.N.5.Even

   .Not.Int.N.5.Odd:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Odd.Pos
   .Not.Int.N.5.Odd.Neg:
        fldz                                    ; cos(PI/2 + PI*n) = 0
        fld1                                    ; sin(-3*PI/2 + 2*PI*n) = 1
        jmp    .return
   .Not.Int.N.5.Odd.Pos:
        fldz                                    ; cos(PI/2 + PI*n) = 0
        fld1
        fchs                                    ; sin(+3*PI/2 + 2*PI*n) = -1
        jmp    .return

   .Not.Int.N.5.Even:
        test    edi, 0x8000                     ; test sign flag
        jz     .Not.Int.N.5.Even.Pos
   .Not.Int.N.5.Even.Neg:
        fldz                                    ; cos(PI/2 + PI*n) = 0
        fld1
        fchs                                    ; sin(-PI/2 + 2*PI*n) = -1
        jmp    .return
   .Not.Int.N.5.Even.Pos:
        fldz                                    ; cos(PI/2 + PI*n) = 0
        fld1                                    ; sin(+PI/2 + 2*PI*n) = 1
;       jmp    .return

   .return:
        retn
$endp

$asprocf @@fcossinpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cossinpi.arg             ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.st0.int.flags.edi                    ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:                                        ; st0 = x
        fstp    st0
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        fld1
        fchs                                    ; cos(PI*odd) = -1
        fldz                                    ; sin(PI*odd) = 0
        jmp    .return
   .Int.Even:
        fld1                                    ; cos(PI*even) = 1
        fldz                                    ; sin(PI*even) = 0
        jmp    .return
   .Not.Int:                                    ; st0 = x
        fld     st0
        @@.int.st0                              ; st0 = int(x) | st1 = x
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        mov     ebx, @@.fcossinpi.N.5
        call    ebx
        jmp    .return
   .Not.Int.main:                               ; st0 = int(x) | st1 = x
        @@.st0.so.flags.edi                     ; edi = int(x) sign and odd flags
        fsubp                                   ; st0 = frac(x)
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        fld1
        faddp

   .reduce:
        @@st0.pi.sin.cos.reduce                 ; ecx = angle disposition
   .main:
        mov     eax, @@fcossin.base.enter
        mov     ebx, @@cossin.pn
        call    ebx
   .return:
        retn
$endp

; cosine & sine
; double co.cossin ( double *cos, double *sin, double x )
;
; x = esp
;
; eax = cos offset
; edx = sin offset
;
; return_1 = st1 = cos
; return_2 = st0 = sin
;
; return   = st0 = cos

$asprocf @@co.fcossin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fcossin.enter
        call    ebx
        ;
        pop     edx eax
        fstp    qword [edx]
        fst     qword [eax]
   .return:
        retn
$endp

$asprocf @@co.fcossinpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax edx
        ;
        mov     ebx, @@fcossinpi.enter
        call    ebx
        ;
        pop     edx eax
        fstp    qword [edx]
        fst     qword [eax]
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fcossin.sse
$else
  @@fcossin.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; secant
; 1/cos(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fsec.sse
{
$asprocf @@fsec

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sec.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.sec.cosec.reduce                 ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; sec(3*PI/2 + 2*PI*n) = NaN
   .x.PI2:                                      ; sec(PI/2 + 2*PI*n) = NaN
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .return

   .main:
        mov     ebx, @@fcos.main
        call    ebx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
   .return:
        retn
$endp

$asprocf @@fsecpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@secpi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.xmm0.int.flags.edi                   ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        xmovsd  xmm0, SIC_AX.m1.0               ; sec(PI*odd) = -1
        jmp    .return
   .Int.Even:
        xmovsd  xmm0, SIC_AX.1.0                ; sec(PI*even) = 1
        jmp    .return
   .Not.Int:
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        xmovsd  xmm0, SIC_AX.NaN                ; sec(PI/2 + PI*n) = NInf
        jmp    .return
   .Not.Int.main:
        xintsd  xmm4, xmm0                      ; xmm4 = int(x)
        subsd   xmm0, xmm4                      ; xmm0 = frac(x)
        @@.xmm4.so.flags.edi                    ; edi = int(x) sign and odd flags
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5

   .reduce:
        @@xmm0.pi.sec.cosec.reduce              ; ecx = angle disposition
   .main:
        mov     ebx, @@fcos.main
        call    ebx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fsec.fpu
{
$asprocf @@fsec

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@sec.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.sec.cosec.reduce                  ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 2
        je     .x.PI2
        cmp     ecx, 6
        jne    .main
   .x.3PI2:                                     ; sec(3*PI/2 + 2*PI*n) = NaN
   .x.PI2:                                      ; sec(PI/2 + 2*PI*n) = NaN
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .return

   .main:
        mov     ebx, @@fcos.main
        call    ebx
        fld1
        fdivrp
   .return:
        retn
$endp

$asprocf @@fsecpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@secpi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.st0.int.flags.edi                    ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:                                        ; st0 = x
        fstp    st0
        test    edi, 0x0001                     ; test odd flag
        jz     .Int.Even
   .Int.Odd:
        fld1
        fchs                                    ; sec(PI*odd) = -1
        jmp    .return
   .Int.Even:
        fld1                                    ; sec(PI*even) = 1
        jmp    .return
   .Not.Int:                                    ; st0 = x
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        fstp    st0
        fldq    SIC_AX.NaN                      ; sec(PI/2 + PI*n) = NaN
        jmp    .return
   .Not.Int.main:                               ; st0 = x
        fld     st0
        @@.int.st0                              ; st0 = int(x) | st1 = x
        @@.st0.so.flags.edi                     ; edi = int(x) sign and odd flags
        fsubp                                   ; st0 = frac(x)
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        fld1
        faddp

   .reduce:
        @@st0.pi.sec.cosec.reduce               ; ecx = angle disposition
   .main:
        mov     ebx, @@fcos.main
        call    ebx
        fld1
        fdivrp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fsec.sse
$else
  @@fsec.fpu
$end

; ------------------------------------------------------------------------------

; cosecant
; 1/sin(x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fcosec.sse
{
$asprocf @@fcosec

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cosec.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.sec.cosec.reduce                 ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 4
        jne    .main
   .x.PI:                                       ; cosec(PI + 2*PI*n) = NaN
   .x.0:                                        ; cosec(0 + 2*PI*n) = NaN
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .return

   .main:
        mov     ebx, @@fsin.main
        call    ebx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
   .return:
        retn
$endp

$asprocf @@fcosecpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cosecpi.arg              ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xintsd  xmm4, xmm0                      ; xmm4 = int(x)
        ucomisd xmm0, xmm4                      ; compare x to int(x)
        jnz    .Not.Int
        jp     .Not.Int
   .Int:
        xmovsd  xmm0, SIC_AX.NaN                ; fcosecpi(PI*n) = NaN
        jmp    .return
   .Not.Int:
        subsd   xmm0, xmm4                      ; xmm0 = frac(x)
        @@.xmm4.so.flags.edi                    ; edi = int(x) sign and odd flags
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        xmovsd  xmm5, SIC_AX.1.0
        addsd   xmm0, xmm5

   .reduce:
        @@xmm0.pi.sec.cosec.reduce              ; ecx = angle disposition
   .main:
        mov     ebx, @@fsin.main
        call    ebx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fcosec.fpu
{
$asprocf @@fcosec

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cosec.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.sec.cosec.reduce                  ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 0
        je     .x.0
        cmp     ecx, 4
        jne    .main
   .x.PI:                                       ; cosec(PI + 2*PI*n) = NaN
   .x.0:                                        ; cosec(0 + 2*PI*n) = NaN
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .return

   .main:
        mov     ebx, @@fsin.main
        call    ebx
        fld1
        fdivrp
   .return:
        retn
$endp

$asprocf @@fcosecpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cosecpi.arg              ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        fld     st0
        @@.int.st0                              ; st0 = int(x) | st1 = x
        fcom                                    ; compare int(x) to x
        fnjne  .Not.Int
   .Int:                                        ; st0 = int(x) | st1 = x
        fstp    st0
        fstp    st0
        fldq    SIC_AX.NaN                      ; cosec(PI*n) = NaN
        jmp    .return
   .Not.Int:                                    ; st0 = int(x) | st1 = x
        @@.st0.so.flags.edi                     ; edi = int(x) sign and odd flags
        fsubp                                   ; st0 = frac(x)
        test    edi, 0x0001                     ; test odd flag
        jz     .reduce
   .Not.Int.N.Odd:
        fld1
        faddp

   .reduce:
        @@st0.pi.sec.cosec.reduce               ; ecx = angle disposition
   .main:
        mov     ebx, @@fsin.main
        call    ebx
        fld1
        fdivrp
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fcosec.sse
$else
  @@fcosec.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/tan.c
; Circular tangent
; Circular cotangent

; tan(x) = x + (x^3)*P(x^2)/Q(x^2)
;        = x*(1 + (x^2)*P(x^2)/Q(x^2))
;        = x*(1 + P'(x^2)/Q(x^2))
; 0 <= x < pi/4
;
; P =      -1.79565251976484877988E+7 +
;   (x^2)*( 1.15351664838587416140E+6 +
;   (x^2)*(-1.30936939181383777646E+4 ))
;
; P' =      0.00000000000000000000E+0 +
;   (x^2)*(-1.79565251976484877988E+7 +
;   (x^2)*( 1.15351664838587416140E+6 +
;   (x^2)*(-1.30936939181383777646E+4 +
;   (x^2)*( 0.00000000000000000000E+0 ))))
;
; Q =      -5.38695755929454629881E+7 +
;   (x^2)*( 2.50083801823357915839E+7 +
;   (x^2)*(-1.32089234440210967447E+6 +
;   (x^2)*( 1.36812963470692954678E+4 +
;   (x^2)*( 1.00000000000000000000E+0 ))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_tan.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@ftan.cotan.sse
{
; 0 <= x < pi/4
$asprocf @@ftan.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_ftan_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 4*16]              ; xmm4 = P':Q
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

$asprocf @@ftan

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@tan.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.tan.cotan.reduce                 ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        cmp     ecx, 2
        jne    .main
   .x.PI2:                                      ; tan(PI/2 + PI*n) = NaN
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .return

   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@ftan.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@ftanpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@tanpi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.xmm0.int.flags.edi                   ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:
        xorpd   xmm0, xmm0                      ; tan(PI*n) = 0
        jmp    .return
   .Not.Int:
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        xmovsd  xmm0, SIC_AX.NaN                ; tan(PI/2 + PI*n) = NInf
        jmp    .return
   .Not.Int.main:
        xfracsd xmm0, xmm0                      ; xmm0 = frac(x)

   .reduce:
        @@xmm0.pi.tan.cotan.reduce              ; ecx = angle disposition
   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@ftan.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fcotan

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cotan.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@xmm0.tan.cotan.reduce                 ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        xorpd   xmm5, xmm5
        ucomisd xmm0, xmm5
        jnz    .main                            ; jump if x' <> 0.0
        jp     .main
        test    ecx, ecx
        jnz    .main
   .x.0:                                        ; cotan(0 + PI*n) = NaN
        xmovsd  xmm0, SIC_AX.NaN
        jmp    .return

   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@fcotan.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fcotanpi

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cotanpi.arg              ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.xmm0.int.flags.edi                   ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:
        xmovsd  xmm0, SIC_AX.NaN                ; cotan(PI*n) = NaN
        jmp    .return
   .Not.Int:
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        xorpd   xmm0, xmm0                      ; cotan(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.main:
        xfracsd xmm0, xmm0                      ; xmm0 = frac(x)

   .reduce:
        @@xmm0.pi.tan.cotan.reduce              ; ecx = angle disposition
   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@fcotan.pn
        call    ebx
   .return:
        retn
$endp
}

macro @@ftan.cotan.fpu
{
; 0 <= x < pi/4
$asprocf @@ftan.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2  | st1 = x

        mov     edx, ??.SD_ftan_Pn
        fld     qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1                        ; st0 = P'   | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_ftan_Qn
        fxch                                    ; st0 = x^2  | st1 = P'  | st2 = x
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmulp
        fadd    qword [edx + 4*8]               ; st0 = Q    | st1 = P'  | st2 = x
        ;
        fdivp                                   ; st0 = P'/Q | st1 = x
        fld1
        faddp
        fmulp
   .return:
        retn
$endp

$asprocf @@ftan

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@tan.arg                  ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.tan.cotan.reduce                  ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        cmp     ecx, 2
        jne    .main
   .x.PI2:                                      ; tan(PI/2 + PI*n) = NaN
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .return

   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@ftan.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@ftanpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@tanpi.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.st0.int.flags.edi                    ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:                                        ; st0 = x
        fstp    st0
        fldz                                    ; tan(PI*n) = 0
        jmp    .return
   .Not.Int:                                    ; st0 = x
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        fstp    st0
        fldq    SIC_AX.NaN                      ; tan(PI/2 + PI*n) = NaN
        jmp    .return
   .Not.Int.main:                               ; st0 = x
        @@.frac.st0                             ; st0 = frac(x)

   .reduce:
        @@st0.pi.tan.cotan.reduce               ; ecx = angle disposition
   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@ftan.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fcotan

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cotan.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@st0.tan.cotan.reduce                  ; ecx = angle disposition

   .re.arg:                                     ; reduced argument test
        ftst
        fnjnz  .main                            ; jump if x' <> 0.0
        test    ecx, ecx
        jnz    .main
   .x.0:                                        ; cotan(0 + PI*n) = NaN
        fstp    st0
        fldq    SIC_AX.NaN
        jmp    .return

   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@fcotan.pn
        call    ebx
   .return:
        retn
$endp

$asprocf @@fcotanpi

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@cotanpi.arg              ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        @@.st0.int.flags.edi                    ; edi = x flags
        test    edi, 0x0002                     ; test integer flag
        jz     .Not.Int
   .Int:                                        ; st0 = x
        fstp    st0
        fldq    SIC_AX.NaN                      ; cotan(PI*n) = NaN
        jmp    .return
   .Not.Int:                                    ; st0 = x
        test    edi, 0x0008                     ; test N.5 flag
        jz     .Not.Int.main
   .Not.Int.N.5:                                ; x = N + 0.5
        fstp    st0
        fldz                                    ; cotan(PI/2 + PI*n) = 0
        jmp    .return
   .Not.Int.main:                               ; st0 = x
        @@.frac.st0                             ; st0 = frac(x)

   .reduce:
        @@st0.pi.tan.cotan.reduce               ; ecx = angle disposition
   .main:
        mov     eax, @@ftan.base.enter
        mov     ebx, @@fcotan.pn
        call    ebx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@ftan.cotan.sse
$else
  @@ftan.cotan.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/asin.c
; Inverse circular sine
; Inverse circular cosine

; asin(x) = x + (x^3)*P(x^2)/Q(x^2)
;         = x*(1 + (x^2)*P(x^2)/Q(x^2))
;         = x*(1 + P'(x^2)/Q(x^2))
; |x| <= 0.5
;
; asin(x) = pi/2 - 2*asin(sqrt((1-x)/2))
; |x| > 0.5
;
; P =      -8.198089802484824371615E+0 +
;   (x^2)*( 1.956261983317594739197E+1 +
;   (x^2)*(-1.626247967210700244449E+1 +
;   (x^2)*( 5.444622390564711410273E+0 +
;   (x^2)*(-6.019598008014123785661E-1 +
;   (x^2)*( 4.253011369004428248960E-3 )...)
;
; Q =      -4.918853881490881290097E+1 +
;   (x^2)*( 1.395105614657485689735E+2 +
;   (x^2)*(-1.471791292232726029859E+2 +
;   (x^2)*( 7.049610280856842141659E+1 +
;   (x^2)*(-1.474091372988853791896E+1 +
;   (x^2)*( 1.000000000000000000000E+0 )...)

; asin(x) = pi/2 - sqrt(2*z)*(1 + z*R(z)/S(z))
;         = pi/2 - sqrt(2*z)*(1 + R'(z)/S(z))
; z = 1-x
; |x| > 0.625
;
; R =     2.853665548261061424989E+1 +
;   (x)*(-2.556901049652824852289E+1 +
;   (x)*( 6.968710824104713396794E+0 +
;   (x)*(-5.634242780008963776856E-1 +
;   (x)*( 2.967721961301243206100E-3 )...)
;
; S =     3.424398657913078477438E+2 +
;   (x)*(-3.838770957603691357202E+2 +
;   (x)*( 1.470656354026814941758E+2 +
;   (x)*(-2.194779531642920639778E+1 +
;   (x)*( 1.000000000000000000000E+0 )...)

; acos(x) = pi/2 - asin(x)
; |x| <= 0.5
;
; acos(x) = 2*asin(sqrt((1-x)/2))
; x > 0.5
;
; acos(x) = pi - 2*asin(sqrt((1+x)/2))
; x < -0.5

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_asin.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fasin.sse
{
; |x| <= 0.5
$asprocf @@fasin.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_fasin_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 5*16]              ; xmm4 = P:Q
        ;
        mulsd   xmm4, xmm5                      ; xmm4 = P':Q
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

; |x| <= 0.375
$asprocf @@fasin.RS.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x

        mov     edx, ??.PD_fasin_RS
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 4*16]              ; xmm4 = R:S
        ;
        mulsd   xmm4, xmm5                      ; xmm4 = R':S
        movapd  xmm3, xmm4                      ; xmm3 = R':S
;       psrldq  xmm3, 8                         ; xmm3 = S:0
        shufpd  xmm3, xmm3, 1                   ; xmm3 = S:R'
        divsd   xmm4, xmm3                      ; xmm4 = R'/S
        xmovsd  xmm3, SIC_AX.1.0
        addsd   xmm4, xmm3                      ; xmm4 = 1+R'/S
        addsd   xmm5, xmm5
        sqrtsd  xmm5, xmm5
        mulsd   xmm4, xmm5
        xmovsd  xmm0, SIC_AX.pi2
        subsd   xmm0, xmm4
;       xmovsd  xmm5, ??.SD_fasin_more.bits     ; + more bits
;       addsd   xmm0, xmm5
   .return:
        retn
$endp

$asprocf @@fasin

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@asin.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xor     ecx, ecx
        ;
        xmovsd  xmm4, SIC_AX.0.625              ; xmm4 = 0.625
        comisd  xmm0, xmm4
        ja     .L2                              ; x > 0.625
;       xmovsd  xmm4, SIC_AX.m0.625             ; xmm4 = -0.625
        @@.chs  xmm4
        comisd  xmm0, xmm4
        jae    .main
   .L0:                                         ; x < -0.625
        or      ecx, -1
   .L2:                                         ; x > 0.625
        xmovx   xmm3, xmm0
        @@.abs  xmm3                            ; xmm3 = |x|
        xmovsd  xmm0, SIC_AX.1.0                ; xmm0 = 1.0
        subsd   xmm0, xmm3                      ; xmm0 = 1.0-|x|
        mov     edx, @@fasin.RS.base.enter
        call    edx
        ;
        test    ecx, ecx
        jz     .return
        @@.chs  xmm0
        jmp    .return
   .main:                                       ; |x| <= 0.625
        mov     edx, @@fasin.base.enter
        call    edx
   .return:
        retn
$endp

$asprocf @@facos

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@acos.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     ebx, @@fasin.base.enter
        ;
        xmovsd  xmm5, SIC_AX.1.0                ; xmm5 = 1.0
        xmovsd  xmm4, SIC_AX.0.5                ; xmm4 = 0.5
        comisd  xmm0, xmm4
        ja     .L2                              ; x > 0.5
        xmovsd  xmm3, SIC_AX.m0.5
        comisd  xmm0, xmm3
        jae    .main
   .L0:                                         ; x < -0.5
        addsd   xmm0, xmm5                      ; xmm0 = 1.0+x
        mulsd   xmm0, xmm4                      ; xmm0 = (1.0+x)*0.5
        sqrtsd  xmm0, xmm0                      ; x' = sqrt((1+x)/2)
        call    ebx                             ; 0 <= x' < 0.5
        ;
        xmovx   xmm3, xmm0
        xmovsd  xmm0, SIC_AX.pi2
        subsd   xmm0, xmm3                      ; xmm0 = pi/2 - asin(x')
;       xmovsd  xmm5, ??.SD_fasin_more.bits     ; + more bits
;       addsd   xmm0, xmm5
        addsd   xmm0, xmm0                      ; xmm0 = pi - 2*asin(x')
        jmp    .return
   .L2:                                         ; x > 0.5
        xmovx   xmm3, xmm0
        xmovx   xmm0, xmm5                      ; xmm0 = 1.0
        subsd   xmm0, xmm3                      ; xmm0 = 1.0-x
        mulsd   xmm0, xmm4                      ; xmm0 = (1.0-x)*0.5
        sqrtsd  xmm0, xmm0                      ; x' = sqrt((1-x)/2)
        call    ebx                             ; 0 <= x' < 0.5
        ;
        addsd   xmm0, xmm0                      ; xmm0 = 2*asin(x')
        jmp    .return
   .main:                                       ; |x| <= 0.5
        call    ebx
        ;
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi2
        subsd   xmm0, xmm5
;       xmovsd  xmm5, ??.SD_fasin_more.bits     ; + more bits
;       addsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fasin.fpu
{
; |x| <= 0.5
$asprocf @@fasin.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2  | st1 = x

        mov     edx, ??.SD_fasin_Pn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1
        fadd    qword [edx + 5*8]
        fmul    st0, st1                        ; st0 = P'   | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_fasin_Qn
        fxch                                    ; st0 = x^2  | st1 = P'  | st2 = x
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmulp
        fadd    qword [edx + 5*8]               ; st0 = Q    | st1 = P'  | st2 = x
        ;
        fdivp                                   ; st0 = P'/Q | st1 = x
        fld1
        faddp
        fmulp
   .return:
        retn
$endp

; |x| <= 0.375
$asprocf @@fasin.RS.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0                             ; st0 = x    | st1 = x

        mov     edx, ??.SD_fasin_Rn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1                        ; st0 = R'   | st1 = x   | st2 = x
        ;
        mov     edx, ??.SD_fasin_Sn
        fxch                                    ; st0 = x    | st1 = R'  | st2 = x
        fld     st0                             ; S0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmulp
        fadd    qword [edx + 4*8]               ; st0 = S    | st1 = R'  | st2 = x
        ;
        fdivp                                   ; st0 = R'/S | st1 = x
        fld1
        faddp
        fxch                                    ; st0 = x    | st1 = 1+R'/S
        fadd    st0, st0                        ; st0 = 2*x  | st1 = 1+R'/S
        fsqrt
        fmulp
        fsubrq  SIC_AX.pi2
;       faddq   ??.SD_fasin_more.bits           ; + more bits
   .return:
        retn
$endp

$asprocf @@fasin

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@asin.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xor     ecx, ecx
        ;
        fldq    SIC_AX.0.625
        fcomp                                   ; compare 0.625 to x
        fnjl   .L2                              ; jump if x > 0.625 (0.625 < x)
        fldq    SIC_AX.m0.625
        fcomp                                   ; compare -0.625 to x
        fnjle  .main                            ; jump if x >= -0.625 (-0.625 <= x)
   .L0:                                         ; x < -0.625
        or      ecx, -1
   .L2:                                         ; x > 0.625
        fabs
        fld1
        fsubrp                                  ; st0 = 1.0-|x|
        mov     edx, @@fasin.RS.base.enter
        call    edx
        ;
        test    ecx, ecx
        jz     .return
        fchs
        jmp    .return
   .main:                                       ; |x| <= 0.625
        mov     edx, @@fasin.base.enter
        call    edx
   .return:
        retn
$endp

$asprocf @@facos

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@acos.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        mov     ebx, @@fasin.base.enter
        ;
        fldq    SIC_AX.0.5
        fcomp                                   ; compare 0.5 to x
        fnjl   .L2                              ; jump if x > 0.5 (0.5 < x)
        fldq    SIC_AX.m0.5
        fcomp                                   ; compare -0.5 to x
        fnjle  .main                            ; jump if x >= -0.5 (-0.5 <= x)
   .L0:                                         ; x < -0.5
        fld1
        faddp                                   ; st0 = 1+x
        fmulq   SIC_AX.0.5                      ; st0 = (1+x)/2
        fsqrt                                   ; x' = sqrt((1+x)/2)
        call    ebx                             ; 0 <= x' < 0.5
        ;
        fsubrq  SIC_AX.pi2                      ; st0 = pi/2 - asin(x')
;       faddq   ??.SD_fasin_more.bits           ; + more bits
        fadd    st0, st0                        ; st0 = pi - 2*asin(x')
        jmp    .return
   .L2:                                         ; x > 0.5
        fld1
        fsubrp                                  ; st0 = 1-x
        fmulq   SIC_AX.0.5                      ; st0 = (1-x)/2
        fsqrt                                   ; x' = sqrt((1-x)/2)
        call    ebx                             ; 0 <= x' < 0.5
        ;
        fadd    st0, st0                        ; st0 = 2*asin(x')
        jmp    .return
   .main:                                       ; |x| <= 0.5
        call    ebx
        fsubrq  SIC_AX.pi2
;       faddq   ??.SD_fasin_more.bits           ; + more bits
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fasin.sse
$else
  @@fasin.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; inverse secant
; acos(1/x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fasec.sse
{
$asprocf @@fasec

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@asec.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        mov     ebx, @@facos.enter
;       mov     ebx, @@facos.core
        call    ebx
   .return:
        retn
$endp
}

macro @@fasec.fpu
{
$asprocf @@fasec

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@asec.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        fld1
        fdivrp
        mov     ebx, @@facos.core
        call    ebx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fasec.sse
$else
  @@fasec.fpu
$end

; ------------------------------------------------------------------------------

; inverse cosecant
; asin(1/x)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@facosec.sse
{
$asprocf @@facosec

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@acosec.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5
        mov     ebx, @@fasin.enter
;       mov     ebx, @@fasin.core
        call    ebx
   .return:
        retn
$endp
}

macro @@facosec.fpu
{
$asprocf @@facosec

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@acosec.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        fld1
        fdivrp
        mov     ebx, @@fasin.core
        call    ebx
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@facosec.sse
$else
  @@facosec.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/atan.c
; Inverse circular tangent (arctangent)

; atan(x) = x + (x^3)*P(x^2)/Q(x^2)
;         = x*(1 + (x^2)*P(x^2)/Q(x^2))
;         = x*(1 + P'(x^2)/Q(x^2))
; |x| <= 0.66
;
; atan(x) = pi/2 - atan(z)
; z = 1/x
; |x| > tan(3*pi/8)
;
; atan(x) = pi/4 + atan(z)
; z = (x-1)/(x+1)
; 0.66 < |x| <= tan(3*pi/8)
;
; P =      -6.485021904942025371773E+1 +
;   (x^2)*(-1.228866684490136173410E+2 +
;   (x^2)*(-7.500855792314704667340E+1 +
;   (x^2)*(-1.615753718733365076637E+1 +
;   (x^2)*(-8.750608600031904122785E-1 )...)
;
; P' =      0.000000000000000000000E+0 +
;   (x^2)*(-6.485021904942025371773E+1 +
;   (x^2)*(-1.228866684490136173410E+2 +
;   (x^2)*(-7.500855792314704667340E+1 +
;   (x^2)*(-1.615753718733365076637E+1 +
;   (x^2)*(-8.750608600031904122785E-1 )...)
;
; Q =       1.945506571482613964425E+2 +
;   (x^2)*( 4.853903996359136964868E+2 +
;   (x^2)*( 4.328810604912902668951E+2 +
;   (x^2)*( 1.650270098316988542046E+2 +
;   (x^2)*( 2.485846490142306297962E+1 +
;   (x^2)*( 1.000000000000000000000E+0 )...)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; include '..\xCommon\SICFuCO_AX_atan.ASM'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fatan.sse
{
; |x| <= 0.66
$asprocf @@fatan.base

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        xddup   xmm5, xmm0                      ; xmm5 = x:x
        mulpd   xmm5, xmm5                      ; xmm5 = x^2:x^2

        mov     edx, ??.PD_fatan_PQ
        movapd  xmm4, [edx + 0*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 1*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 2*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 3*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 4*16]
        mulpd   xmm4, xmm5
        addpd   xmm4, [edx + 5*16]              ; xmm4 = P':Q
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

$asprocf @@fatan

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@atan.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        movmskpd ecx, xmm0                      ; ecx = sign bits
        @@.abs  xmm0
   .L0:
        mov     ebx, @@fatan.base.enter
        ;
        xmovsd  xmm5, ??.SD_fatan_T3P8
        comisd  xmm0, xmm5
        ja     .GT.T3P8
        xmovsd  xmm5, SIC_AX.0.66
        comisd  xmm0, xmm5
        jbe    .main
   .GT.0.66:                                    ; 0.66 < x <= tan(3*pi/8)
        xmovx   xmm5, xmm0
        xmovsd  xmm4, SIC_AX.1.0
        subsd   xmm0, xmm4
        addsd   xmm5, xmm4
        divsd   xmm0, xmm5                      ; z = (x-1)/(x+1)
        call    ebx
        xmovsd  xmm5, SIC_AX.pi4
        addsd   xmm0, xmm5
        jmp    .update
   .GT.T3P8:                                    ; x > tan(3*pi/8)
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.1.0
        divsd   xmm0, xmm5                      ; z = 1/x
        call    ebx
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi2
        subsd   xmm0, xmm5
        jmp    .update

   .main:
        call    ebx
   .update:
        test    ecx, 1
        jp     .return
        @@.chs  xmm0
   .return:
        retn
$endp

; |x| >= 2^53
$asprocf @@facotan.2P53.PD

        xmovsd  xmm4, SIC_AX.1.0
        divsd   xmm4, xmm0                      ; xmm4 = 1/x = u
        xddup   xmm5, xmm4                      ; xmm5 = u:u
        mulpd   xmm5, xmm5                      ; xmm5 = u^2:u^2

        mov     edx, ??.PD_facot_Pn
        movapd  xmm0, [edx + 0*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 1*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 2*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 3*16]
        mulpd   xmm0, xmm5
        addpd   xmm0, [edx + 4*16]              ; xmm0 = PB':PA
        ;
        xmovx   xmm3, xmm5                      ; xmm3 = u^2
        mulsd   xmm5, xmm5                      ; xmm5 = u^4
        mulsd   xmm5, xmm5                      ; xmm5 = u^8
        mulsd   xmm5, xmm3                      ; xmm5 = u^10
        mulsd   xmm0, xmm5                      ; xmm0 = PB:PA
    $ifdef _SSE3
        haddpd  xmm0, xmm0                      ; xmm0 = PB+PA
    $else
        oops hsubpd
    $end
        mulsd   xmm0, xmm4
   .return:
        retn
$endp

; |x| >= 2^53
$asprocf @@facotan.2P53.SD

        xmovsd  xmm4, SIC_AX.1.0
        divsd   xmm4, xmm0                      ; xmm4 = 1/x = u
        xmovx   xmm5, xmm4
        mulsd   xmm5, xmm5                      ; xmm5 = u^2

        mov     edx, ??.SD_facot_Pn
        movsd   xmm0, [edx + 0*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 1*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 2*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 3*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 4*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 5*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 6*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 7*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 8*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 9*8]
        mulsd   xmm0, xmm4
   .return:
        retn
$endp

; |x| >= 2^101
$asprocf @@facotan.2P101.SD

        xmovsd  xmm4, SIC_AX.1.0
        divsd   xmm4, xmm0                      ; xmm4 = 1/x = u
        xmovx   xmm5, xmm4
        mulsd   xmm5, xmm5                      ; xmm5 = u^2

        mov     edx, ??.SD_facot_Pn
        movsd   xmm0, [edx + 5*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 6*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 7*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 8*8]
        mulsd   xmm0, xmm5
        addsd   xmm0, [edx + 9*8]
        mulsd   xmm0, xmm4
   .return:
        retn
$endp

$asprocf @@facotan

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@acotan.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
        cmp     ebx, 1
        je     .x.2P53
        cmp     ebx, 2
        jne    .core
   .x.2P101:                                    ; |x| >= 2^101
        mov     edx, @@facotan.2P101.SD
        call    edx
        jmp    .return
   .x.2P53:                                     ; |x| >= 2^53
        mov     edx, @@facotan.2P53.PD
        call    edx
        jmp    .return
   .core:
        mov     ebx, @@fatan.core
        call    ebx
        ;
        xmovx   xmm5, xmm0
        xmovsd  xmm0, SIC_AX.pi2
        subsd   xmm0, xmm5                      ; pi/2 - atan
   .return:
        retn
$endp
}

macro @@fatan.fpu
{
; |x| <= 0.66
$asprocf @@fatan.base

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
        fld     st0
        fmul    st0, st0                        ; st0 = x^2  | st1 = x

        mov     edx, ??.SD_fatan_Pn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1                        ; st0 = P'   | st1 = x^2 | st2 = x
        ;
        mov     edx, ??.SD_fatan_Qn
        fxch                                    ; st0 = x^2  | st1 = P'  | st2 = x
        fld     st0                             ; Q0 = 1.0
;       fld     qword [edx + 0*8]
;       fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmulp
        fadd    qword [edx + 5*8]               ; st0 = Q    | st1 = P'  | st2 = x
        ;
        fdivp                                   ; st0 = P'/Q | st1 = x
        fld1
        faddp
        fmulp
   .return:
        retn
$endp

$asprocf @@fatan

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    $align
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@atan.arg                 ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .core:
        xor     ecx, ecx                        ; ecx = sign bit
        ftst
        fnjge  .L0
        inc     ecx
        fchs
   .L0:
        mov     ebx, @@fatan.base.enter
        ;
        fldq    ??.SD_fatan_T3P8
        fcomp                                   ; compare T3P8 to x
        fnjl   .GT.T3P8                         ; jump if x > T3P8 (T3P8 < x)
        fldq    SIC_AX.0.66
        fcomp                                   ; compare 0.66 to x
        fnjge  .main                            ; jump if x <= 0.66 (0.66 >= x)
   .GT.0.66:                                    ; 0.66 < x <= tan(3*pi/8)
        fld     st0
        fld1
        fsubp
        fxch
        fld1
        faddp
        fdivp                                   ; z = (x-1)/(x+1)
        call    ebx
        faddq   SIC_AX.pi4
        jmp    .update
   .GT.T3P8:                                    ; x > tan(3*pi/8)
        fld1
        fdivrp                                  ; z = 1/x
        call    ebx
        fsubrq  SIC_AX.pi2
        jmp    .update

   .main:
        call    ebx
   .update:
        test    ecx, 1
        jp     .return
        fchs
   .return:
        retn
$endp

; |x| >= 2^53
$asprocf @@facotan.2P53.SD

        fld1
        fdivrp                                  ; st0 = 1/x = u
        fld     st0
        fmul    st0, st0                        ; st0 = u^2 | st1 = u

        mov     edx, ??.SD_facot_Pn
        fld     qword [edx + 0*8]
        fmul    st0, st1
        fadd    qword [edx + 1*8]
        fmul    st0, st1
        fadd    qword [edx + 2*8]
        fmul    st0, st1
        fadd    qword [edx + 3*8]
        fmul    st0, st1
        fadd    qword [edx + 4*8]
        fmul    st0, st1
        fadd    qword [edx + 5*8]
        fmul    st0, st1
        fadd    qword [edx + 6*8]
        fmul    st0, st1
        fadd    qword [edx + 7*8]
        fmul    st0, st1
        fadd    qword [edx + 8*8]
        fmulp
        fadd    qword [edx + 9*8]
        fmulp
   .return:
        retn
$endp

; |x| >= 2^101
$asprocf @@facotan.2P101.SD

        fld1
        fdivrp                                  ; st0 = 1/x = u
        fld     st0
        fmul    st0, st0                        ; st0 = u^2 | st1 = u

        mov     edx, ??.SD_facot_Pn
        fld     qword [edx + 5*8]
        fmul    st0, st1
        fadd    qword [edx + 6*8]
        fmul    st0, st1
        fadd    qword [edx + 7*8]
        fmul    st0, st1
        fadd    qword [edx + 8*8]
        fmulp
        fadd    qword [edx + 9*8]
        fmulp
   .return:
        retn
$endp

$asprocf @@facotan

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        mov     ebx, @@acotan.arg               ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
        cmp     ebx, 1
        je     .x.2P53
        cmp     ebx, 2
        jne    .core
   .x.2P101:                                    ; |x| >= 2^101
        mov     edx, @@facotan.2P101.SD
        call    edx
        jmp    .return
   .x.2P53:                                     ; |x| >= 2^53
        mov     edx, @@facotan.2P53.SD
        call    edx
        jmp    .return
   .core:
        mov     ebx, @@fatan.core
        call    ebx
        ;
        fsubrq  SIC_AX.pi2                      ; acotan = pi/2 - atan
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fatan.sse
$else
  @@fatan.fpu
$end

; ------------------------------------------------------------------------------

; http://www.moshier.net/#Cephes
; http://www.moshier.net/double.zip/atan.c
; Quadrant correct inverse circular tangent

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

macro @@fatan2.sse
{
; atan2(y,x) = atan(y/x)
; y = esp
; x = esp + 8

$asprocf @@fatan2

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; xmm0 = y | xmm1 = x
   .arg:                                        ; argument test
        mov     ebx, @@atan2.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .main:
        divsd   xmm0, xmm1
        mov     ebx, @@fatan.core
        call    ebx
        ;
        movsd   xmm5, [edi]
        addsd   xmm0, xmm5
   .return:
        retn
$endp

; atan2r(x,y) = atan(y/x)
; y = esp
; x = esp + 8

$asprocf @@fatan2r

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; xmm0 = x | xmm1 = y
        @@.xch  xmm0, xmm1                      ; xmm0 = y | xmm1 = x
   .arg:                                        ; argument test
        mov     ebx, @@atan2.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .main:
        divsd   xmm0, xmm1
        mov     ebx, @@fatan.core
        call    ebx
        ;
        movsd   xmm5, [edi]
        addsd   xmm0, xmm5
   .return:
        retn
$endp
}

macro @@fatan2.fpu
{
; atan2(y,x) = atan(y/x)
; y = esp
; x = esp + 8

$asprocf @@fatan2

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = x | st1 = y
   .arg:                                        ; argument test
        mov     ebx, @@atan2.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .main:
        fdivp
        mov     ebx, @@fatan.core
        call    ebx
        ;
        fadd    qword [edi]
   .return:
        retn
$endp

; atan2r(x,y) = atan(y/x)
; y = esp
; x = esp + 8

$asprocf @@fatan2r

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:                                      ; st0 = y | st1 = x
        fxch                                    ; st0 = x | st1 = y
   .arg:                                        ; argument test
        mov     ebx, @@atan2.arg                ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
   .main:
        fdivp
        mov     ebx, @@fatan.core
        call    ebx
        ;
        fadd    qword [edi]
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@fatan2.sse
$else
  @@fatan2.fpu
$end

; ------------------------------------------------------------------------------
