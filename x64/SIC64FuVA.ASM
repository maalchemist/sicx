
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (variable number of arguments)

; Copyright � 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; vncycle
; variable number of arguments
; r13 -> argument count, min=6, even
; section count = (acount - 2) div 2
;
; double vncycle ( x, a, P1, P2, ... , Pn, V1, V2, ... , Vn )
; period = P = P[1]+P[2]+...+P[n] (take into account only positive P[i])
;
; returns V[n], ( x-a >= P[1]+P[2]+...+P[n-1] ) & ( x-a < P[1]+P[2]+...+P[n-1]+P[n] )
;            0, P = 0
;            0, argument count < 6 or odd
;
; double v2cycle ( x, a, P1, P2, V1, V2 )
; section count = 2
;   |
;   |
;   |--   --   --   --     V1
; --|--------------------> Z[ero]
;   |  ---  ---  ---  ---  V2
;   |
;   |
;
; double v3cycle ( x, a, P1, P2, P3, V1, V2, V3 )
; section count = 3
;   |
;   |     ----     ----  V3
;   |--       --         V1
; --|------------------> Z[ero]
;   |  ---      ---      V2
;   |
;   |
;
; double v4cycle ( x, a, P1, P2, P3, P4, V1, V2, V3, V4 )
; section count = 4
;   |
;   |     ----        ----      V3
;   |--          --             V1
; --|-------------------------> Z[ero]
;   |  ---         ---          V2
;   |         ---         ----  V4
;   |
;
; double v5cycle ( x, a, P1, P2, P3, P4, P5, V1, V2, V3, V4, V5 )
; section count = 5
;   |            --            --  V5
;   |     ----          ----       V3
;   |--            --              V1
; --|----------------------------> Z[ero]
;   |  ---           ---           V2
;   |         ---           ---    V4
;   |

macro @@vncycle.sse.fpu
{
$usprocf @@vncycle

        fldz
        test    r13, 1
        jnz    .return                          ; jump if arg count odd

        lea     rdx, [r13 - 2]
        shr     rdx, 1                          ; rdx = section count = (r13 - 2) div 2
        mov     rcx, rdx                        ; rcx = section count

        fldz
    .a: fld     qword [rsp + rdx * 8 + 8]
        ftst
        fnjge  .p
        fstp    st0                             ; convert negative P[i] to 0
        fldz
    .p: faddp
        dec     rdx
        jnz    .a                               ; st0 = P, st1 = 0
        fxch                                    ; st0 = 0, st1 = P
        fcomp                                   ; compare 0 to P
        fnje   .return

        fld     qword [rsp]
        fsub    qword [rsp + 8]                 ; st0 = x-a
        fld     st0
        fdiv    st0, st2
        @@.int.st0
        fmul    st0, st2
        fsubp                                   ; st0 = (x-a) mod P

        ftst
        fnjge  .0
        fadd    st0, st1
    .0: fstp    st1
        fldz
        mov     rdx, 1
        sub     rdx, rcx                        ; rdx = 1 - [section count]
    .1: lea     rax, [rsp + 8 + rcx * 8]        ; rax = rsp + 8 + [section count] * 8
        fadd    qword [rax + rdx * 8]
        fcom    st1
        fnjg   .2
        inc     rdx
        jnz    .1
    .2: shl     rcx, 4                          ; rcx = [section count] * 16
        lea     rcx, [rsp + 8 + rcx]            ; rcx = rsp + 8 + [section count] * 16
        fld     qword [rcx + rdx * 8]

        fstp    st1
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vncycle.fpu
{
$usprocf @@vncycle

        fldz
        test    r13, 1
        jnz    .return                          ; jump if arg count odd

        lea     rdx, [r13 - 2]
        shr     rdx, 1                          ; rdx = section count = (r13 - 2) div 2
        mov     rcx, rdx                        ; rcx = section count

        fldz
    .a: fld     qword [rsp + rdx * 8 + 8]
        ftst
        fnjge  .p
        fstp    st0                             ; convert negative P[i] to 0
        fldz
    .p: faddp
        dec     rdx
        jnz    .a                               ; st0 = P, st1 = 0
        fxch                                    ; st0 = 0, st1 = P
        fcomp                                   ; compare 0 to P
        fnje   .return

        fld     qword [rsp]
        fsub    qword [rsp + 8]                 ; st0 = x-a
        fld     st0
        fdiv    st0, st2
        @@.int.st0
        fmul    st0, st2
        fsubp                                   ; st0 = (x-a) mod P

        ftst
        fnjge  .0
        fadd    st0, st1
    .0: fstp    st1
        fldz
        mov     rdx, 1
        sub     rdx, rcx                        ; rdx = 1 - [section count]
    .1: lea     rax, [rsp + 8 + rcx * 8]        ; rax = rsp + 8 + [section count] * 8
        fadd    qword [rax + rdx * 8]
        fcom    st1
        fnjg   .2
        inc     rdx
        jnz    .1
    .2: shl     rcx, 4                          ; rcx = [section count] * 16
        lea     rcx, [rsp + 8 + rcx]            ; rcx = rsp + 8 + [section count] * 16
        fld     qword [rcx + rdx * 8]

        fstp    st1
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vncycle.sse.fpu
$else
  @@vncycle.fpu
$end

; ------------------------------------------------------------------------------

; vnstep
; variable number of arguments
; r13 -> argument count, min=4, even
; step count = (acount - 2) div 2
;
; double vnstep ( x, P1, P2, ... , Pn, V0, V1, V2, ... , Vn )
;
; returns V[n], x >= P[n]
;         V[0], x < P1
;            0, argument count < 4 or odd
;
; double v1step ( x, P1, V0, V1 )
; step count = 1
;   |
;   |
;   |-------               V0
; --|--------------------> Z[ero]
;   |       -------------  V1
;   |
;   |      P1
;
; double v2step ( x, P1, P2, V0, V1, V2 )
; step count = 2
;   |
;   |             -------  V2
;   |-------               V0
; --|--------------------> Z[ero]
;   |       ------         V1
;   |
;   |      P1    P2

macro @@vnstep.sse.fpu
{
$usprocf @@vnstep

        fldz
        test    r13, 1
        jnz    .return                          ; jump if arg count odd

        lea     rdx, [r13 - 2]
        shr     rdx, 1                          ; rdx = step count = (r13 - 2) div 2

    .continue:
        fld     qword [rsp + rdx * 8]           ; st0 = P[i]
        fcomp   qword [rsp]                     ; compare P[i] to x
        fnjle  .break                           ; break if P[i] <= x (x >= P[i])
        dec     rdx
        jnz    .continue
    .break:
        shr     r13, 1                          ; r13 = [arg count] div 2
        lea     rcx, [r13 + rdx]
        fld     qword [rsp + rcx * 8]           ; st0 = V[i]

        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vnstep.fpu
{
$usprocf @@vnstep

        fldz
        test    r13, 1
        jnz    .return                          ; jump if arg count odd

        lea     rdx, [r13 - 2]
        shr     rdx, 1                          ; rdx = step count = (r13 - 2) div 2

    .continue:
        fld     qword [rsp + rdx * 8]           ; st0 = P[i]
        fcomp   qword [rsp]                     ; compare P[i] to x
        fnjle  .break                           ; break if P[i] <= x (x >= P[i])
        dec     rdx
        jnz    .continue
    .break:
        shr     r13, 1                          ; r13 = [arg count] div 2
        lea     rcx, [r13 + rdx]
        fld     qword [rsp + rcx * 8]           ; st0 = V[i]

        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vnstep.sse.fpu
$else
  @@vnstep.fpu
$end

; ------------------------------------------------------------------------------

; sum of values
; variable number of arguments
; r13 -> argument count, min=1

macro @@vsum.sse
{
$usprocf @@vsum

        xorpd   xmm0, xmm0
        test    r13, r13
        jz     .return

    .next.arg:
        addsd   xmm0, qword [rsp + r13 * 8 - 8]
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

macro @@vsum.fpu
{
$usprocf @@vsum

        fldz
        test    r13, r13
        jz     .return

    .next.arg:
        fadd    qword [rsp + r13 * 8 - 8]
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vsum.sse
$else
  @@vsum.fpu
$end

; ------------------------------------------------------------------------------

; product of values
; variable number of arguments
; r13 -> argument count, min=1

macro @@vmul.sse
{
$usprocf @@vmul

        test    r13, r13
        jnz    .args
        xorpd   xmm0, xmm0
        jmp    .return

    .args:
        xmovsd  xmm0, ??.1.0
    .next.arg:
        mulsd   xmm0, qword [rsp + r13 * 8 - 8]
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

macro @@vmul.fpu
{
$usprocf @@vmul

        test    r13, r13
        jnz    .args
        fldz
        jmp    .return

    .args:
        fld1
    .next.arg:
        fmul    qword [rsp + r13 * 8 - 8]
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmul.sse
$else
  @@vmul.fpu
$end

; ------------------------------------------------------------------------------

; returns the smaller of values
; variable number of arguments
; r13 -> argument count, min=1

macro @@vmin.sse
{
$usprocf @@vmin

        test    r13, r13
        jnz    .args
        xorpd   xmm0, xmm0
        jmp    .return

    .args:
        movsd   xmm0, qword [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return

    .arg.test:
        minsd   xmm0, qword [rsp + r13 * 8 - 8]
    .arg.next:
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

macro @@vmin.fpu
{
$usprocf @@vmin

        test    r13, r13
        jnz    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return

    .arg.test:
        fcom    qword [rsp + r13 * 8 - 8]
        fnjle  .arg.next
        fstp    st0
        fld     qword [rsp + r13 * 8 - 8]
    .arg.next:
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmin.sse
$else
  @@vmin.fpu
$end

; ------------------------------------------------------------------------------

; returns the larger of values
; variable number of arguments
; r13 -> argument count, min=1

macro @@vmax.sse
{
$usprocf @@vmax

        test    r13, r13
        jnz    .args
        xorpd   xmm0, xmm0
        jmp    .return

    .args:
        movsd   xmm0, qword [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return

    .arg.test:
        maxsd   xmm0, qword [rsp + r13 * 8 - 8]
    .arg.next:
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

macro @@vmax.fpu
{
$usprocf @@vmax

        test    r13, r13
        jnz    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return

    .arg.test:
        fcom    qword [rsp + r13 * 8 - 8]
        fnjge  .arg.next
        fstp    st0
        fld     qword [rsp + r13 * 8 - 8]
    .arg.next:
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmax.sse
$else
  @@vmax.fpu
$end

; ------------------------------------------------------------------------------

; returns the smaller and the larger of values
; double double vminmax (...)
; variable number of arguments
; r13 -> argument count, min=1
;
; return_1 = st1 = x_min
; return_2 = st0 = x_max

macro @@vminmax.sse
{
$usprocf @@vminmax

        test    r13, r13
        jnz    .args
        xorpd   xmm0, xmm0
        xorpd   xmm1, xmm1
        jmp    .return

    .args:
        movsd   xmm0, qword [rsp + r13 * 8 - 8]
        movsd   xmm1, xmm0
        dec     r13
        jz     .return

    .arg.test:
        movsd   xmm2, qword [rsp + r13 * 8 - 8]
        minsd   xmm0, xmm2
        maxsd   xmm1, xmm2
    .arg.next:
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

macro @@vminmax.fpu
{
$usprocf @@vminmax

        test    r13, r13
        jnz    .args
        fldz
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]
        fld     st0
        dec     r13
        jz     .return

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x | st1 = x_max | st2 = x_min
        fcom    st2                             ; compare x to x_min
        fnjge   @F
        fxch    st2                             ; x < x_min
        jmp    .arg.next
    @@:
        fcom    st1                             ; compare x to x_max
        fnjle   @F
        fxch    st1                             ; x > x_max
;       jmp    .arg.next
    @@:
    .arg.next:
        fstp    st0
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vminmax.sse
$else
  @@vminmax.fpu
$end

; ------------------------------------------------------------------------------

; returns the smaller and the larger of values
; double co.vminmax ( double *x_min, double *x_max, ...)
; variable number of arguments
; r13 -> argument count, min=3
;
; rax = x_min offset
; rdx = x_max offset

macro @@co.vminmax.sse
{
$usprocf @@co.vminmax

;       mov     r10, rax                        ; save rax
        movsd   xmm0, qword [rsp + r13 * 8 - 8]
        movsd   xmm1, xmm0
        dec     r13
        jz     .assign

    .arg.test:
        movsd   xmm2, qword [rsp + r13 * 8 - 8]
        minsd   xmm0, xmm2
        maxsd   xmm1, xmm2
    .arg.next:
        dec     r13
        jnz    .arg.test
    .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
    .return:
        retn
$endp
}

macro @@co.vminmax.fpu
{
$usprocf @@co.vminmax

        mov     r10, rax                        ; save rax
        fld     qword [rsp + r13 * 8 - 8]
        fld     st0
        dec     r13
        jz     .assign

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x | st1 = x_max | st2 = x_min
        fcom    st2                             ; compare x to x_min
        fnjge   @F
        fxch    st2                             ; x < x_min
        jmp    .arg.next
    @@:
        fcom    st1                             ; compare x to x_max
        fnjle   @F
        fxch    st1                             ; x > x_max
;       jmp    .arg.next
    @@:
    .arg.next:
        fstp    st0
        dec     r13
        jnz    .arg.test
    .assign:
        fstp    qword [rdx]
        fst     qword [r10]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.vminmax.sse
$else
  @@co.vminmax.fpu
$end

; ------------------------------------------------------------------------------

; returns the larger and the smaller of values
; double double vmaxmin (...)
; variable number of arguments
; r13 -> argument count, min=1
;
; return_1 = st1 = x_max
; return_2 = st0 = x_min

macro @@vmaxmin.sse
{
$usprocf @@vmaxmin

        test    r13, r13
        jnz    .args
        xorpd   xmm0, xmm0
        xorpd   xmm1, xmm1
        jmp    .return

    .args:
        movsd   xmm0, qword [rsp + r13 * 8 - 8]
        movsd   xmm1, xmm0
        dec     r13
        jz     .return

    .arg.test:
        movsd   xmm2, qword [rsp + r13 * 8 - 8]
        maxsd   xmm0, xmm2
        minsd   xmm1, xmm2
    .arg.next:
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

macro @@vmaxmin.fpu
{
$usprocf @@vmaxmin

        test    r13, r13
        jnz    .args
        fldz
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]
        fld     st0
        dec     r13
        jz     .return

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x | st1 = x_min | st2 = x_max
        fcom    st2                             ; compare x to x_max
        fnjle   @F
        fxch    st2                             ; x > x_max
        jmp    .arg.next
    @@:
        fcom    st1                             ; compare x to x_min
        fnjge   @F
        fxch    st1                             ; x < x_min
;       jmp    .arg.next
    @@:
    .arg.next:
        fstp    st0
        dec     r13
        jnz    .arg.test
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmaxmin.sse
$else
  @@vmaxmin.fpu
$end

; ------------------------------------------------------------------------------

; returns the larger and the smaller of values
; double co.vmaxmin ( double *x_max, double *x_min, ...)
; variable number of arguments
; r13 -> argument count, min=3
;
; rax = x_max offset
; rdx = x_min offset

macro @@co.vmaxmin.sse
{
$usprocf @@co.vmaxmin

;       mov     r10, rax                        ; save rax
        movsd   xmm0, qword [rsp + r13 * 8 - 8]
        movsd   xmm1, xmm0
        dec     r13
        jz     .assign

    .arg.test:
        movsd   xmm2, qword [rsp + r13 * 8 - 8]
        maxsd   xmm0, xmm2
        minsd   xmm1, xmm2
    .arg.next:
        dec     r13
        jnz    .arg.test
    .assign:
        movsd   qword [rax], xmm0
        movsd   qword [rdx], xmm1
    .return:
        retn
$endp
}

macro @@co.vmaxmin.fpu
{
$usprocf @@co.vmaxmin

        mov     r10, rax                        ; save rax
        fld     qword [rsp + r13 * 8 - 8]
        fld     st0
        dec     r13
        jz     .assign

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x | st1 = x_min | st2 = x_max
        fcom    st2                             ; compare x to x_max
        fnjle   @F
        fxch    st2                             ; x > x_max
        jmp    .arg.next
    @@:
        fcom    st1                             ; compare x to x_min
        fnjge   @F
        fxch    st1                             ; x < x_min
;       jmp    .arg.next
    @@:
    .arg.next:
        fstp    st0
        dec     r13
        jnz    .arg.test
    .assign:
        fstp    qword [rdx]
        fst     qword [r10]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.vmaxmin.sse
$else
  @@co.vmaxmin.fpu
$end

; ------------------------------------------------------------------------------

; returns the value of the smaller absolute deviation
; double vmin.adev ( double x[1], double x[2], ..., double x[n], double a )
; deviation[i] = abs(a - x[i])
;
; variable number of arguments
; r13 -> argument count, min=2

macro @@vmin.adev.sse.fpu
{
$usprocf @@vmin.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a
        dec     r13
        jz     .return.L1

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjle  .xn1                             ; jump if abs(x[n-1] - a) <= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

    .return.L1:
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vmin.adev.fpu
{
$usprocf @@vmin.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a
        dec     r13
        jz     .return.L1

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjle  .xn1                             ; jump if abs(x[n-1] - a) <= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

    .return.L1:
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmin.adev.sse.fpu
$else
  @@vmin.adev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value with the smaller absolute deviation
; prefer argument with a lower index
; double vminl.adev ( double x[1], double x[2], ..., double x[n], double a )
; deviation[i] = abs(a - x[i])
;
; variable number of arguments
; r13 -> argument count, min=2

macro @@vminl.adev.sse.fpu
{
$usprocf @@vminl.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjle  .xn1                             ; jump if abs(x[n-1] - a) <= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vminl.adev.fpu
{
$usprocf @@vminl.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjle  .xn1                             ; jump if abs(x[n-1] - a) <= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vminl.adev.sse.fpu
$else
  @@vminl.adev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value with smaller the absolute deviation
; prefer argument with a higher index
; double vminh.adev ( double x[1], double x[2], ..., double x[n], double a )
; deviation[i] = abs(a - x[i])
;
; variable number of arguments
; r13 -> argument count, min=2

macro @@vminh.adev.sse.fpu
{
$usprocf @@vminh.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjl   .xn1                             ; jump if abs(x[n-1] - a) < abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vminh.adev.fpu
{
$usprocf @@vminh.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjl   .xn1                             ; jump if abs(x[n-1] - a) < abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vminh.adev.sse.fpu
$else
  @@vminh.adev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value of the larger absolute deviation
; double vmax.adev ( double x[1], double x[2], ..., double x[n], double a )
; deviation[i] = abs(a - x[i])
;
; variable number of arguments
; r13 -> argument count, min=2

macro @@vmax.adev.sse.fpu
{
$usprocf @@vmax.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a
        dec     r13
        jz     .return.L1

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjge  .xn1                             ; jump if abs(x[n-1] - a) >= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

    .return.L1:
        fstp    st1
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vmax.adev.fpu
{
$usprocf @@vmax.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a
        dec     r13
        jz     .return.L1

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjge  .xn1                             ; jump if abs(x[n-1] - a) >= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

    .return.L1:
        fstp    st1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmax.adev.sse.fpu
$else
  @@vmax.adev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value with the larger absolute deviation
; prefer argument with a lower index
; double vmaxl.adev ( double x[1], double x[2], ..., double x[n], double a )
; deviation[i] = abs(a - x[i])
;
; variable number of arguments
; r13 -> argument count, min=2

macro @@vmaxl.adev.sse.fpu
{
$usprocf @@vmaxl.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjge  .xn1                             ; jump if abs(x[n-1] - a) >= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vmaxl.adev.fpu
{
$usprocf @@vmaxl.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjge  .xn1                             ; jump if abs(x[n-1] - a) >= abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmaxl.adev.sse.fpu
$else
  @@vmaxl.adev.fpu
$end

; ------------------------------------------------------------------------------

; returns the value with larger the absolute deviation
; prefer argument with a higher index
; double vmaxh.adev ( double x[1], double x[2], ..., double x[n], double a )
; deviation[i] = abs(a - x[i])
;
; variable number of arguments
; r13 -> argument count, min=2

macro @@vmaxh.adev.sse.fpu
{
$usprocf @@vmaxh.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjg   .xn1                             ; jump if abs(x[n-1] - a) > abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@vmaxh.adev.fpu
{
$usprocf @@vmaxh.adev

        cmp     r13, 2
        jae    .args
        fldz
        jmp    .return

    .args:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = a
        dec     r13
        lea     rdx, [rsp + r13 * 8 - 8]
        dec     r13
        jz     .return.L1

        fld     qword [rdx]                     ; st0 = x[n], st1 = a
        fsub    st0, st1                        ; st0 = x[n] - a, st1 = a
        fabs                                    ; st0 = abs(x[n] - a), st1 = a

    .arg.test:
        fld     qword [rsp + r13 * 8 - 8]       ; st0 = x[n-1], st1 = abs(x[n] - a), st2 = a
        fsub    st0, st2                        ; st0 = x[n-1] - a, st1 = abs(x[n] - a), st2 = a
        fabs                                    ; st0 = abs(x[n-1] - a), st1 = abs(x[n] - a), st2 = a
        fcom
        fnjg   .xn1                             ; jump if abs(x[n-1] - a) > abs(x[n] - a)
    .xnn:
        fstp    st0
        jmp    .arg.next
    .xn1:
        lea     rdx, [rsp + r13 * 8 - 8]
        fstp    st1
    .arg.next:                                  ; st0 = abs(x[?] - a), st1 = a
        dec     r13
        jnz    .arg.test

        fstp    st0
    .return.L1:
        fstp    st0
        fld     qword [rdx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmaxh.adev.sse.fpu
$else
  @@vmaxh.adev.fpu
$end

; ------------------------------------------------------------------------------

; evaluates a uniform polynomial of one variable at value x (Horner`s method)
; the coefficients are ordered in increasing powers of x
; c[0] + c[1]*x + c[2]*(x^2) + ... + c[n]*(x^n)
; variable number of arguments
; r13 -> argument count, min=2
;
; double vpoly ( double x, double c[0], double c[1], ..., double c[n] )

macro @@vpoly.sse
{
$usprocf @@vpoly

        movsd   xmm0, qword [rsp + r13 * 8 - 8] ; xmm0 = c[n]
        sub     r13, 2
        jz     .return

        movsd   xmm1, qword [rsp]               ; xmm1 = x
    .next.arg:
        mulsd   xmm0, xmm1
        addsd   xmm0, qword [rsp + r13 * 8]     ; xmm0 = xmm0 * x + c[i]
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

macro @@vpoly.fpu
{
$usprocf @@vpoly

        fld     qword [rsp + r13 * 8 - 8]       ; st0 = c[n]
        sub     r13, 2
        jz     .return

    .next.arg:
        fmul    qword [rsp]
        fadd    qword [rsp + r13 * 8]           ; st0 = st0 * x + c[i]
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vpoly.sse
$else
  @@vpoly.fpu
$end

; ------------------------------------------------------------------------------

; arithmetic average of values (sum / n)
; variable number of arguments
; r13 -> argument count, min=1

macro @@vmean.sse
{
$usprocf @@vmean

        xorpd   xmm0, xmm0
        test    r13, r13
        jz     .return

        cvtsi2sd xmm1, r13                      ; xmm1 = argument count
    .next.arg:
        addsd   xmm0, qword [rsp + r13 * 8 - 8]
        dec     r13
        jnz    .next.arg
        divsd   xmm0, xmm1                      ; xmm0 = mean = sum / n
    .return:
        retn
$endp
}

macro @@vmean.fpu
{
$usprocf @@vmean

       .int64   EQU rsp - 16

        fldz
        test    r13, r13
        jz     .return

        mov     [.int64], r13                   ; save argument count
    .next.arg:
        fadd    qword [rsp + r13 * 8 - 8]
        dec     r13
        jnz    .next.arg
        fidiv   dword [.int64]                  ; st0 = mean = sum / n
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vmean.sse
$else
  @@vmean.fpu
$end

; ------------------------------------------------------------------------------

; sum of squares of values
; variable number of arguments
; r13 -> argument count, min=1

macro @@vsumsqr.sse
{
$usprocf @@vsumsqr

        xorpd   xmm0, xmm0
        test    r13, r13
        jz     .return

    .next.arg:
        movsd   xmm1, qword [rsp + r13 * 8 - 8]
        mulsd   xmm1, xmm1
        addsd   xmm0, xmm1
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

macro @@vsumsqr.fpu
{
$usprocf @@vsumsqr

        fldz
        test    r13, r13
        jz     .return

    .next.arg:
        fld     qword [rsp + r13 * 8 - 8]
        fld     st0
        fmulp
        faddp
        dec     r13
        jnz    .next.arg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vsumsqr.sse
$else
  @@vsumsqr.fpu
$end

; ------------------------------------------------------------------------------

; Euclidean L2-norm
; norm = sqrt(summsqr)
; variable number of arguments
; r13 -> argument count, min=1

macro @@vnorm.sse
{
$usprocf @@vnorm

        xorpd   xmm0, xmm0
        test    r13, r13
        jz     .return

    .next.arg:
        movsd   xmm1, qword [rsp + r13 * 8 - 8]
        mulsd   xmm1, xmm1
        addsd   xmm0, xmm1
        dec     r13
        jnz    .next.arg
        sqrtsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@vnorm.fpu
{
$usprocf @@vnorm

        fldz
        test    r13, r13
        jz     .return

    .next.arg:
        fld     qword [rsp + r13 * 8 - 8]
        fld     st0
        fmulp
        faddp
        dec     r13
        jnz    .next.arg
        fsqrt
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@vnorm.sse
$else
  @@vnorm.fpu
$end

; ------------------------------------------------------------------------------
