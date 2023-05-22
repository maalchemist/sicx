
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (matrix and array functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; 1-dimensional matrix item position
; integer 1D.1P.matrip (i)
; return result in rax
;
; i - item index | constant or integer variable
;
; f(x) = i[1]
;
; i = rsp

; no range check
$usprocf @@.1D.1P.matrip

        mov     rax, qword [rsp]                ; rax = i
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; 1-dimensional matrix item position
; integer 1D.2P.matrip (n[1], i[1])
; return result in rax
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; f(x) = i[1]
;
; n[1] = rsp + 00
; i[1] = rsp + 08

; no range check
$usprocf @@.1D.2P.matrip

        mov     rax, qword [rsp + 08]           ; rax = i[1]
    .return:
        retn
$endp

; range check
; 0 <= i[i] < n[i]
; returns -1 on error
$usprocf @@.1D.matrip.rc

        mov     rax, qword [rsp + 08]           ; rax = i[1]
        cmp     rax, 0                          ; compare i[1] to 0
        jl     .error                           ; error if i[1] < 0
        ;
        mov     rbx, qword [rsp + 00]           ; rbx = n[1]
        cmp     rbx, rax                        ; compare n[1] to i[1]
        jg     .return                          ; success if n[1] > i[1]
    .error:
        mov     rax, -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; 2-dimensional matrix item position
; integer 2D.3P.matrip (n[1], i[1], i[2])
; return result in rax
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; f(x) = i[1] + i[2] * n[1]
;
; n[1] = rsp + 00
; i[1] = rsp + 08
; i[2] = rsp + 16

; no range check
$usprocf @@.2D.3P.matrip

        mov     rax, qword [rsp + 16]           ; rax = i[2]
        mov     rbx, qword [rsp + 08]           ; rbx = i[1]
        mov     rdx, qword [rsp + 00]           ; rdx = n[1]
        ;
        imul    rdx                             ; rax = i[2] * n[1]
        add     rax, rbx                        ; rax = i[1] + i[2] * n[1]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; 2-dimensional matrix item position
; integer 2D.4P.matrip (n[1], n[2], i[1], i[2])
; return result in rax
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; f(x) = i[1] + i[2] * n[1]
;
; n[1] = rsp + 00
; n[2] = rsp + 08
; i[1] = rsp + 16
; i[2] = rsp + 24

; no range check
$usprocf @@.2D.4P.matrip

        mov     rax, qword [rsp + 24]           ; rax = i[2]
        mov     rbx, qword [rsp + 16]           ; rbx = i[1]
        mov     rdx, qword [rsp + 00]           ; rdx = n[1]
        ;
        imul    rdx                             ; rax = i[2] * n[1]
        add     rax, rbx                        ; rax = i[1] + i[2] * n[1]
    .return:
        retn
$endp

; range check
; 0 <= i[i] < n[i]
; returns -1 on error
$usprocf @@.2D.matrip.rc

        mov     rax, qword [rsp + 24]           ; rax = i[2]
        cmp     rax, 0                          ; compare i[2] to 0
        jl     .error                           ; error if i[2] < 0
        mov     rbx, qword [rsp + 08]           ; rbx = n[2]
        cmp     rbx, rax                        ; compare n[2] to i[2]
        jle    .error                           ; error if n[2] <= i[2]
        ;
        mov     rbx, qword [rsp + 16]           ; rbx = i[1]
        cmp     rbx, 0                          ; compare i[1] to 0
        jl     .error                           ; error if i[1] < 0
        mov     rdx, qword [rsp + 00]           ; rdx = n[1]
        cmp     rdx, rbx                        ; compare n[1] to i[1]
        jle    .error                           ; error if n[1] <= i[1]
        ;
        imul    rdx                             ; rax = i[2] * n[1]
        add     rax, rbx                        ; rax = i[1] + i[2] * n[1]
        jmp    .return

    .error:
        mov     rax, -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; n-dimensional matrix item position
; integer matrip (n[1], n[2], ..., n[n], i[1], i[2], ..., i[n])
; return result in rax
; variable number of arguments
; r13 -> argument count, min=1
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; n[1] = rsp + 00
; n[2] = rsp + 08
; ...

; no range check
$usprocf @@matrip

        mov     r10, r13                        ; r10 = i[i] pointer
        shr     r13, 1                          ; r13 = n[i] pointer
        test    r10, 1
        jz      @F
        inc     r13                             ; argument count is odd
    @@:

        mov     rax, qword [rsp + 8*r10 - 8]    ; rax = i[n]
        dec     r13
        jz     .return
    .arg:
        dec     r10
        mov     rbx, qword [rsp + 8*r10 - 8]    ; rbx = i[n-1]
        mov     rdx, qword [rsp + 8*r13 - 8]    ; rdx = n[n-1]
        ;
        imul    rdx                             ; rax = i[n] * n[n-1]
        add     rax, rbx                        ; rax = i[n-1] + i[n] * n[n-1]
        ;
        dec     r13
        jnz    .arg
    .return:
        retn
$endp

; range check
; 0 <= i[i] < n[i]
; returns -1 on error
$usprocf @@matrip.rc

        test    r13, 1
        jnz    .error                           ; error if argument count is odd

        mov     r10, r13                        ; r10 = i[i] pointer
        shr     r13, 1                          ; r13 = n[i] pointer

        mov     rax, qword [rsp + 8*r10 - 8]    ; rax = i[n]
        cmp     rax, 0                          ; compare i[n] to 0
        jl     .error                           ; error if i[n] < 0
        mov     rbx, qword [rsp + 8*r13 - 8]    ; rbx = n[n]
        cmp     rbx, rax                        ; compare n[n] to i[n]
        jle    .error                           ; error if n[n] <= i[n]
        dec     r13
        jz     .return
    .arg:
        dec     r10
        mov     rbx, qword [rsp + 8*r10 - 8]    ; rbx = i[n-1]
        cmp     rbx, 0                          ; compare i[n-1] to 0
        jl     .error                           ; error if i[n-1] < 0
        mov     rdx, qword [rsp + 8*r13 - 8]    ; rdx = n[n-1]
        cmp     rdx, rbx                        ; compare n[n-1] to i[n-1]
        jle    .error                           ; error if n[n-1] <= i[n-1]
        ;
        imul    rdx                             ; rax = i[n] * n[n-1]
        add     rax, rbx                        ; rax = i[n-1] + i[n] * n[n-1]
        ;
        dec     r13
        jnz    .arg
        jmp    .return

    .error:
        mov     rax, -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; read double array item, forward search
; rcx = array offset
; rax = item index

macro @@farr.sse
{
$usprocf @@farr

        movsd   xmm0, qword [rcx + rax * 8]
    .return:
        retn
$endp
}

macro @@farr.fpu
{
$usprocf @@farr

        fld     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@farr.sse
$else
  @@farr.fpu
$end

; ------------------------------------------------------------------------------

; read double array item, forward search, indirect
; rcx = array offset offset
; rax = item index

macro @@pfarr.sse
{
$usprocf @@pfarr

        mov     rcx, [rcx]
        movsd   xmm0, qword [rcx + rax * 8]
    .return:
        retn
$endp
}

macro @@pfarr.fpu
{
$usprocf @@pfarr

        mov     rcx, [rcx]
        fld     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pfarr.sse
$else
  @@pfarr.fpu
$end

; ------------------------------------------------------------------------------

; read double array item, backward search
; rcx = array offset
; rax = item index

macro @@barr.sse
{
$usprocf @@barr

        neg     rax
        movsd   xmm0, qword [rcx + rax * 8]
    .return:
        retn
$endp
}

macro @@barr.fpu
{
$usprocf @@barr

        neg     rax
        fld     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@barr.sse
$else
  @@barr.fpu
$end

; ------------------------------------------------------------------------------

; read double array item, backward search, indirect
; rcx = array offset offset
; rax = item index

macro @@pbarr.sse
{
$usprocf @@pbarr

        mov     rcx, [rcx]
        neg     rax
        movsd   xmm0, qword [rcx + rax * 8]
    .return:
        retn
$endp
}

macro @@pbarr.fpu
{
$usprocf @@pbarr

        mov     rcx, [rcx]
        neg     rax
        fld     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pbarr.sse
$else
  @@pbarr.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; write double array item, forward search
; rcx = array offset
; rax = item index
; rsp = value

macro @@farw.sse
{
$usprocf @@farw

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   qword [rcx + rax * 8], xmm0
    .return:
        retn
$endp
}

macro @@farw.fpu
{
$usprocf @@farw

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fst     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@farw.sse
$else
  @@farw.fpu
$end

; ------------------------------------------------------------------------------

; write double array item, forward search, indirect
; rcx = array offset offset
; rax = item index
; rsp = value

macro @@pfarw.sse
{
$usprocf @@pfarw

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rcx, [rcx]
        movsd   qword [rcx + rax * 8], xmm0
    .return:
        retn
$endp
}

macro @@pfarw.fpu
{
$usprocf @@pfarw

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rcx, [rcx]
        fst     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pfarw.sse
$else
  @@pfarw.fpu
$end

; ------------------------------------------------------------------------------

; write double array item, backward search
; rcx = array offset
; rax = item index
; rsp = value

macro @@barw.sse
{
$usprocf @@barw

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        neg     rax
        movsd   qword [rcx + rax * 8], xmm0
    .return:
        retn
$endp
}

macro @@barw.fpu
{
$usprocf @@barw

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        neg     rax
        fst     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@barw.sse
$else
  @@barw.fpu
$end

; ------------------------------------------------------------------------------

; write double array item, backward search, indirect
; rcx = array offset offset
; rax = item index
; rsp = value

macro @@pbarw.sse
{
$usprocf @@pbarw

        movsd   xmm0, qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rcx, [rcx]
        neg     rax
        movsd   qword [rcx + rax * 8], xmm0
    .return:
        retn
$endp
}

macro @@pbarw.fpu
{
$usprocf @@pbarw

        fld     qword [rsp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     rcx, [rcx]
        neg     rax
        fst     qword [rcx + rax * 8]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pbarw.sse
$else
  @@pbarw.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double array item address, forward search
; rcx = array offset
; rax = item index
; return result in rax

$usprocf @@fara

        lea     rax, [rcx + rax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; double array item address, forward search, indirect
; rcx = array offset offset
; rax = item index
; return result in rax

$usprocf @@pfara

        mov     rcx, [rcx]
        lea     rax, [rcx + rax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; double array item address, backward search
; rcx = array offset
; rax = item index
; return result in rax

$usprocf @@bara

        neg     rax
        lea     rax, [rcx + rax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; double array item address, backward search, indirect
; rcx = array offset offset
; rax = item index
; return result in rax

$usprocf @@pbara

        mov     rcx, [rcx]
        neg     rax
        lea     rax, [rcx + rax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; double array item as variable, forward search
$usprocf @@farv

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; double array item as variable, backward search
$usprocf @@barv

        nop
;       retn
$endp

; ------------------------------------------------------------------------------
