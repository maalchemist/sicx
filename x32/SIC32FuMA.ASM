
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
; return result in eax
;
; i - item index | constant or integer variable
;
; f(x) = i[1]
;
; i = esp

; no range check
$usprocf @@.1D.1P.matrip

        mov     eax, dword [esp]                ; eax = i
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; 1-dimensional matrix item position
; integer 1D.2P.matrip (n[1], i[1])
; return result in eax
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; f(x) = i[1]
;
; n[1] = esp + 00
; i[1] = esp + 04

; no range check
$usprocf @@.1D.2P.matrip

        mov     eax, dword [esp + 04]           ; eax = i[1]
    .return:
        retn
$endp

; range check
; 0 <= i[i] < n[i]
; returns -1 on error
$usprocf @@.1D.matrip.rc

        mov     eax, dword [esp + 04]           ; eax = i[1]
        cmp     eax, 0                          ; compare i[1] to 0
        jl     .error                           ; error if i[1] < 0
        ;
        mov     ebx, dword [esp + 00]           ; ebx = n[1]
        cmp     ebx, eax                        ; compare n[1] to i[1]
        jg     .return                          ; success if n[1] > i[1]
    .error:
        mov     eax, -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; 2-dimensional matrix item position
; integer 2D.3P.matrip (n[1], i[1], i[2])
; return result in eax
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; f(x) = i[1] + i[2] * n[1]
;
; n[1] = esp + 00
; i[1] = esp + 04
; i[2] = esp + 08

; no range check
$usprocf @@.2D.3P.matrip

        mov     eax, dword [esp + 08]           ; eax = i[2]
        mov     ebx, dword [esp + 04]           ; ebx = i[1]
        mov     edx, dword [esp + 00]           ; edx = n[1]
        ;
        imul    edx                             ; eax = i[2] * n[1]
        add     eax, ebx                        ; eax = i[1] + i[2] * n[1]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; 2-dimensional matrix item position
; integer 2D.4P.matrip (n[1], n[2], i[1], i[2])
; return result in eax
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; f(x) = i[1] + i[2] * n[1]
;
; n[1] = esp + 00
; n[2] = esp + 04
; i[1] = esp + 08
; i[2] = esp + 12

; no range check
$usprocf @@.2D.4P.matrip

        mov     eax, dword [esp + 12]           ; eax = i[2]
        mov     ebx, dword [esp + 08]           ; ebx = i[1]
        mov     edx, dword [esp + 00]           ; edx = n[1]
        ;
        imul    edx                             ; eax = i[2] * n[1]
        add     eax, ebx                        ; eax = i[1] + i[2] * n[1]
    .return:
        retn
$endp

; range check
; 0 <= i[i] < n[i]
; returns -1 on error
$usprocf @@.2D.matrip.rc

        mov     eax, dword [esp + 12]           ; eax = i[2]
        cmp     eax, 0                          ; compare i[2] to 0
        jl     .error                           ; error if i[2] < 0
        mov     ebx, dword [esp + 04]           ; ebx = n[2]
        cmp     ebx, eax                        ; compare n[2] to i[2]
        jle    .error                           ; error if n[2] <= i[2]
        ;
        mov     ebx, dword [esp + 08]           ; ebx = i[1]
        cmp     ebx, 0                          ; compare i[1] to 0
        jl     .error                           ; error if i[1] < 0
        mov     edx, dword [esp + 00]           ; edx = n[1]
        cmp     edx, ebx                        ; compare n[1] to i[1]
        jle    .error                           ; error if n[1] <= i[1]
        ;
        imul    edx                             ; eax = i[2] * n[1]
        add     eax, ebx                        ; eax = i[1] + i[2] * n[1]
        jmp    .return

    .error:
        mov     eax, -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; n-dimensional matrix item position
; integer matrip (n[1], n[2], ..., n[n], i[1], i[2], ..., i[n])
; return result in eax
; variable number of arguments
; ecx -> argument count, min=1
;
; n[i] - dimension value | constant or integer variable
; i[i] - item index      | constant or integer variable
;
; n[1] = esp + 00
; n[2] = esp + 04
; ...

; no range check
$usprocf @@matrip

        mov     edi, ecx                        ; edi = i[i] pointer
        shr     ecx, 1                          ; ecx = n[i] pointer
        test    edi, 1
        jz      @F
        inc     ecx                             ; argument count is odd
    @@:

        mov     eax, dword [esp + 4*edi - 4]    ; eax = i[n]
        dec     ecx
        jz     .return
    .arg:
        dec     edi
        mov     ebx, dword [esp + 4*edi - 4]    ; ebx = i[n-1]
        mov     edx, dword [esp + 4*ecx - 4]    ; edx = n[n-1]
        ;
        imul    edx                             ; eax = i[n] * n[n-1]
        add     eax, ebx                        ; eax = i[n-1] + i[n] * n[n-1]
        ;
        dec     ecx
        jnz    .arg
    .return:
        retn
$endp

; range check
; 0 <= i[i] < n[i]
; returns -1 on error
$usprocf @@matrip.rc

        test    ecx, 1
        jnz    .error                           ; error if argument count is odd

        mov     edi, ecx                        ; edi = i[i] pointer
        shr     ecx, 1                          ; ecx = n[i] pointer

        mov     eax, dword [esp + 4*edi - 4]    ; eax = i[n]
        cmp     eax, 0                          ; compare i[n] to 0
        jl     .error                           ; error if i[n] < 0
        mov     ebx, dword [esp + 4*ecx - 4]    ; ebx = n[n]
        cmp     ebx, eax                        ; compare n[n] to i[n]
        jle    .error                           ; error if n[n] <= i[n]
        dec     ecx
        jz     .return
    .arg:
        dec     edi
        mov     ebx, dword [esp + 4*edi - 4]    ; ebx = i[n-1]
        cmp     ebx, 0                          ; compare i[n-1] to 0
        jl     .error                           ; error if i[n-1] < 0
        mov     edx, dword [esp + 4*ecx - 4]    ; edx = n[n-1]
        cmp     edx, ebx                        ; compare n[n-1] to i[n-1]
        jle    .error                           ; error if n[n-1] <= i[n-1]
        ;
        imul    edx                             ; eax = i[n] * n[n-1]
        add     eax, ebx                        ; eax = i[n-1] + i[n] * n[n-1]
        ;
        dec     ecx
        jnz    .arg
        jmp    .return

    .error:
        mov     eax, -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; read double array item, forward search
; ecx = array offset
; eax = item index

macro @@farr.sse
{
$usprocf @@farr

        movsd   xmm0, qword [ecx + eax * 8]
    .return:
        retn
$endp
}

macro @@farr.fpu
{
$usprocf @@farr

        fld     qword [ecx + eax * 8]
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
; ecx = array offset offset
; eax = item index

macro @@pfarr.sse
{
$usprocf @@pfarr

        mov     ecx, [ecx]
        movsd   xmm0, qword [ecx + eax * 8]
    .return:
        retn
$endp
}

macro @@pfarr.fpu
{
$usprocf @@pfarr

        mov     ecx, [ecx]
        fld     qword [ecx + eax * 8]
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
; ecx = array offset
; eax = item index

macro @@barr.sse
{
$usprocf @@barr

        neg     eax
        movsd   xmm0, qword [ecx + eax * 8]
    .return:
        retn
$endp
}

macro @@barr.fpu
{
$usprocf @@barr

        neg     eax
        fld     qword [ecx + eax * 8]
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
; ecx = array offset offset
; eax = item index

macro @@pbarr.sse
{
$usprocf @@pbarr

        mov     ecx, [ecx]
        neg     eax
        movsd   xmm0, qword [ecx + eax * 8]
    .return:
        retn
$endp
}

macro @@pbarr.fpu
{
$usprocf @@pbarr

        mov     ecx, [ecx]
        neg     eax
        fld     qword [ecx + eax * 8]
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
; ecx = array offset
; eax = item index
; esp = value

macro @@farw.sse
{
$usprocf @@farw

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   qword [ecx + eax * 8], xmm0
    .return:
        retn
$endp
}

macro @@farw.fpu
{
$usprocf @@farw

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fst     qword [ecx + eax * 8]
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
; ecx = array offset offset
; eax = item index
; esp = value

macro @@pfarw.sse
{
$usprocf @@pfarw

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     ecx, [ecx]
        movsd   qword [ecx + eax * 8], xmm0
    .return:
        retn
$endp
}

macro @@pfarw.fpu
{
$usprocf @@pfarw

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     ecx, [ecx]
        fst     qword [ecx + eax * 8]
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
; ecx = array offset
; eax = item index
; esp = value

macro @@barw.sse
{
$usprocf @@barw

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        neg     eax
        movsd   qword [ecx + eax * 8], xmm0
    .return:
        retn
$endp
}

macro @@barw.fpu
{
$usprocf @@barw

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        neg     eax
        fst     qword [ecx + eax * 8]
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
; ecx = array offset offset
; eax = item index
; esp = value

macro @@pbarw.sse
{
$usprocf @@pbarw

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     ecx, [ecx]
        neg     eax
        movsd   qword [ecx + eax * 8], xmm0
    .return:
        retn
$endp
}

macro @@pbarw.fpu
{
$usprocf @@pbarw

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     ecx, [ecx]
        neg     eax
        fst     qword [ecx + eax * 8]
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
; ecx = array offset
; eax = item index
; return result in eax

$usprocf @@fara

        lea     eax, [ecx + eax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; double array item address, forward search, indirect
; ecx = array offset offset
; eax = item index
; return result in eax

$usprocf @@pfara

        mov     ecx, [ecx]
        lea     eax, [ecx + eax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; double array item address, backward search
; ecx = array offset
; eax = item index
; return result in eax

$usprocf @@bara

        neg     eax
        lea     eax, [ecx + eax * 8]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; double array item address, backward search, indirect
; ecx = array offset offset
; eax = item index
; return result in eax

$usprocf @@pbara

        mov     ecx, [ecx]
        neg     eax
        lea     eax, [ecx + eax * 8]
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
