
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (boolean functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; double value as boolean
; integer ot ( double x )
; return result in eax
; x = esp
;
; returns: 1, x <> 0
;          0, x = 0

macro @@ot.sse
{
$usprocf @@ot

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .1                               ; x <> 0
        jp     .1                               ; x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@ot.fpu
{
$usprocf @@ot

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@ot.sse
$else
  @@ot.fpu
$end

; ------------------------------------------------------------------------------

; integer value as boolean
; integer ot ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x <> 0
;          0, x = 0

macro c
{
$usprocf @@_ot_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        test    eax, eax                        ; compare x to 0
        jz     .return                          ; jump if x = 0
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; integer value as boolean
; integer ot ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x <> 0
;          0, x = 0

$usprocf @@_ot_reg

    .enter:
        test    eax, eax                        ; compare x to 0
        jz     .return                          ; jump if x = 0
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negation
; integer not ( double x )
; return result in eax
; x = esp
;
; returns: 1, x = 0
;          0, x <> 0

macro @@not.sse
{
$usprocf @@not

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .0                               ; x <> 0
        jp     .0                               ; x <> 0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@not.fpu
{
$usprocf @@not

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@not.sse
$else
  @@not.fpu
$end

; ------------------------------------------------------------------------------

; negation
; integer not ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x = 0
;          0, x <> 0

macro c
{
$usprocf @@_not_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        test    eax, eax                        ; compare x to 0
        jz     .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: inc     eax                             ; return 1

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; negation
; integer not ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x = 0
;          0, x <> 0

$usprocf @@_not_reg

    .enter:
        test    eax, eax                        ; compare x to 0
        jz     .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: inc     eax                             ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; disjunction
; integer or ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x <> 0 or y <> 0
;          0, otherwise

macro @@or.sse
{
$usprocf @@or

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .1                               ; x <> 0
        jp     .1                               ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .1                               ; y <> 0
        jp     .1                               ; y <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@or.fpu
{
$usprocf @@or

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fstp    st0
        fnjnz  .1.st0                           ; jump if y <> 0

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1.st0:
        fstp    st0
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@or.sse
$else
  @@or.fpu
$end

; ------------------------------------------------------------------------------

; disjunction
; integer or ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x <> 0 or y <> 0
;          0, otherwise

$usprocf @@_or_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        test    eax, eax
        jnz    .1
        test    edx, edx
        jnz    .1

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; disjunction
; integer or ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x <> 0 or y <> 0
;          0, otherwise

$usprocf @@_or_reg

    .enter:
        test    eax, eax
        jnz    .1
        test    ecx, ecx
        jnz    .1

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negative disjunction
; integer nor ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x = 0 and y = 0, not (x <> 0 or y <> 0)
;          0, otherwise

macro @@nor.sse
{
$usprocf @@nor

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .0                               ; x <> 0
        jp     .0                               ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .0                               ; y <> 0
        jp     .0                               ; y <> 0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@nor.fpu
{
$usprocf @@nor

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fstp    st0
        fnjnz  .0.st0                           ; jump if y <> 0

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .0                               ; jump if x <> 0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0.st0:
        fstp    st0
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nor.sse
$else
  @@nor.fpu
$end

; ------------------------------------------------------------------------------

; negative disjunction
; integer nor ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x = 0 and y = 0, not (x <> 0 or y <> 0)
;          0, otherwise

$usprocf @@_nor_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        test    eax, eax
        jnz    .0
        test    edx, edx
        jnz    .0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negative disjunction
; integer nor ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x = 0 and y = 0, not (x <> 0 or y <> 0)
;          0, otherwise

$usprocf @@_nor_reg

    .enter:
        test    eax, eax
        jnz    .0
        test    ecx, ecx
        jnz    .0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; exclusive disjunction
; integer xor ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, ( x <> 0 and y = 0 ) or ( x = 0 and y <> 0 )
;          0, otherwise

macro @@xor.sse
{
$usprocf @@xor

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .x.nz                            ; x <> 0
        jp     .x.nz                            ; x <> 0

    .x.z:                                       ; x = 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .1                               ; return 1 (x = 0 and y <> 0)
        jp     .1                               ; return 1 (x = 0 and y <> 0)
        xor     eax, eax                        ; return 0 (x = 0 and y = 0)
        jmp    .return

    .x.nz:                                      ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .0                               ; return 0 (x <> 0 and y <> 0)
        jp     .0                               ; return 0 (x <> 0 and y <> 0)
        jmp    .1                               ; return 1 (x <> 0 and y = 0)

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@xor.fpu
{
$usprocf @@xor

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fstp    st0
        fnstsw  ax
        mov     dx, ax

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .x.nz                            ; jump if x <> 0

    .x.z:                                       ; x = 0
        test    dh, $40
        jz     .1                               ; return 1 (x = 0 and y <> 0)
        xor     eax, eax                        ; return 0 (x = 0 and y = 0)
        jmp    .return
    .x.nz:                                      ; x <> 0
        test    dh, $40
        jnz    .1                               ; return 1 (x <> 0 and y = 0)
        xor     eax, eax                        ; return 0 (x <> 0 and y <> 0)
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@xor.sse
$else
  @@xor.fpu
$end

; ------------------------------------------------------------------------------

; exclusive disjunction
; integer xor ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, ( x <> 0 and y = 0 ) or ( x = 0 and y <> 0 )
;          0, otherwise

$usprocf @@_xor_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        test    eax, eax
        jnz    .x.nz

    .x.z:                                       ; x = 0
        test    edx, edx
        jnz    .1                               ; return 1 (x = 0 and y <> 0)
        xor     eax, eax                        ; return 0 (x = 0 and y = 0)
        jmp    .return
    .x.nz:                                      ; x <> 0
        test    edx, edx
        jz     .1                               ; return 1 (x <> 0 and y = 0)
        xor     eax, eax                        ; return 0 (x <> 0 and y <> 0)
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; exclusive disjunction
; integer xor ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, ( x <> 0 and y = 0 ) or ( x = 0 and y <> 0 )
;          0, otherwise

$usprocf @@_xor_reg

    .enter:
        test    eax, eax
        jnz    .x.nz

    .x.z:                                       ; x = 0
        test    ecx, ecx
        jnz    .1                               ; return 1 (x = 0 and y <> 0)
        xor     eax, eax                        ; return 0 (x = 0 and y = 0)
        jmp    .return
    .x.nz:                                      ; x <> 0
        test    ecx, ecx
        jz     .1                               ; return 1 (x <> 0 and y = 0)
        xor     eax, eax                        ; return 0 (x <> 0 and y <> 0)
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negative exclusive disjunction
; integer xnor ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, ( x = 0 or y <> 0 ) and ( x <> 0 or y = 0 ), not (( x <> 0 and y = 0 ) or ( x = 0 and y <> 0 ))
;          0, otherwise

macro @@xnor.sse
{
$usprocf @@xnor

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .x.nz                            ; x <> 0
        jp     .x.nz                            ; x <> 0

    .x.z:                                       ; x = 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .0                               ; return 0 (x = 0 and y <> 0)
        jp     .0                               ; return 0 (x = 0 and y <> 0)
        jmp    .1                               ; return 1 (x = 0 and y = 0)

    .x.nz:                                      ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .1                               ; return 1 (x <> 0 and y <> 0)
        jp     .1                               ; return 1 (x <> 0 and y <> 0)
;       jmp    .0                               ; return 0 (x <> 0 and y = 0)

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@xnor.fpu
{
$usprocf @@xnor

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fstp    st0
        fnstsw  ax
        mov     dx, ax

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .x.nz                            ; jump if x <> 0

    .x.z:                                       ; x = 0
        test    dh, $40
        jz     .0                               ; return 0 (x = 0 and y <> 0)
        mov     eax, 1                          ; return 1 (x = 0 and y = 0)
        jmp    .return
    .x.nz:                                      ; x <> 0
        test    dh, $40
        jnz    .0                               ; return 0 (x <> 0 and y = 0)
        mov     eax, 1                          ; return 1 (x <> 0 and y <> 0)
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@xnor.sse
$else
  @@xnor.fpu
$end

; ------------------------------------------------------------------------------

; negative exclusive disjunction
; integer xnor ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, ( x = 0 or y <> 0 ) and ( x <> 0 or y = 0 ), not (( x <> 0 and y = 0 ) or ( x = 0 and y <> 0 ))
;          0, otherwise

$usprocf @@_xnor_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        test    eax, eax
        jnz    .x.nz

    .x.z:                                       ; x = 0
        test    edx, edx
        jnz    .0                               ; return 0 (x = 0 and y <> 0)
        mov     eax, 1                          ; return 1 (x = 0 and y = 0)
        jmp    .return
    .x.nz:                                      ; x <> 0
        test    edx, edx
        jz     .0                               ; return 0 (x <> 0 and y = 0)
        mov     eax, 1                          ; return 1 (x <> 0 and y <> 0)
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negative exclusive disjunction
; integer xnor ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, ( x = 0 or y <> 0 ) and ( x <> 0 or y = 0 ), not (( x <> 0 and y = 0 ) or ( x = 0 and y <> 0 ))
;          0, otherwise

$usprocf @@_xnor_reg

    .enter:
        test    eax, eax
        jnz    .x.nz

    .x.z:                                       ; x = 0
        test    ecx, ecx
        jnz    .0                               ; return 0 (x = 0 and y <> 0)
        mov     eax, 1                          ; return 1 (x = 0 and y = 0)
        jmp    .return
    .x.nz:                                      ; x <> 0
        test    ecx, ecx
        jz     .0                               ; return 0 (x <> 0 and y = 0)
        mov     eax, 1                          ; return 1 (x <> 0 and y <> 0)
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; conjunction
; integer and ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x <> 0 and y <> 0
;          0, otherwise

macro @@and.sse
{
$usprocf @@and

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .x.nz                            ; x <> 0
        jp     .x.nz                            ; x <> 0

    .x.z:                                       ; x = 0
        jmp    .0
    .x.nz:                                      ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .1                               ; y <> 0
        jp     .1                               ; y <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@and.fpu
{
$usprocf @@and

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fstp    st0
        fnjz   .0.st0                           ; jump if y = 0

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .0                               ; jump if x = 0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0.st0:
        fstp    st0
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@and.sse
$else
  @@and.fpu
$end

; ------------------------------------------------------------------------------

; conjunction
; integer and ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x <> 0 and y <> 0
;          0, otherwise

$usprocf @@_and_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        test    eax, eax
        jz     .0
        test    edx, edx
        jz     .0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; conjunction
; integer and ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x <> 0 and y <> 0
;          0, otherwise

$usprocf @@_and_reg

    .enter:
        test    eax, eax
        jz     .0
        test    ecx, ecx
        jz     .0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negative conjunction
; integer nand ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x = 0 or y = 0, not (x <> 0 and y <> 0)
;          0, otherwise

macro @@nand.sse
{
$usprocf @@nand

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .x.nz                            ; x <> 0
        jp     .x.nz                            ; x <> 0

    .x.z:                                       ; x = 0
        jmp    .1
    .x.nz:                                      ; x <> 0
        ucomisd xmm1, xmm5                      ; compare y to 0
        jnz    .0                               ; y <> 0
        jp     .0                               ; y <> 0
        jmp    .1

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@nand.fpu
{
$usprocf @@nand

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare y to 0
        fstp    st0
        fnjz   .1.st0                           ; jump if y = 0

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1.st0:
        fstp    st0
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nand.sse
$else
  @@nand.fpu
$end

; ------------------------------------------------------------------------------

; negative conjunction
; integer nand ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x = 0 or y = 0, not (x <> 0 and y <> 0)
;          0, otherwise

$usprocf @@_nand_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        test    eax, eax
        jz     .1
        test    edx, edx
        jz     .1

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; negative conjunction
; integer nand ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x = 0 or y = 0, not (x <> 0 and y <> 0)
;          0, otherwise

$usprocf @@_nand_reg

    .enter:
        test    eax, eax
        jz     .1
        test    ecx, ecx
        jz     .1

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; true
; integer if.true ( double x )
; return result in eax
; x = esp
;
; returns: 1, x <> 0
;          0, x = 0

macro @@if.true.sse
{
$usprocf @@if.true

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .1                               ; x <> 0
        jp     .1                               ; x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.true.fpu
{
$usprocf @@if.true

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.true.sse
$else
  @@if.true.fpu
$end

; ------------------------------------------------------------------------------

; true
; integer if.true ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x <> 0
;          0, x = 0

macro c
{
$usprocf @@_if.true_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        test    eax, eax                        ; compare x to 0
        jnz    .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; true
; integer if.true ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x <> 0
;          0, x = 0

$usprocf @@_if.true_reg

    .enter:
        test    eax, eax                        ; compare x to 0
        jnz    .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; false
; integer if.false ( double x )
; return result in eax
; x = esp
;
; returns: 1, x = 0
;          0, x <> 0

macro @@if.false.sse
{
$usprocf @@if.false

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .0                               ; x <> 0
        jp     .0                               ; x <> 0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@if.false.fpu
{
$usprocf @@if.false

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.false.sse
$else
  @@if.false.fpu
$end

; ------------------------------------------------------------------------------

; false
; integer if.false ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x = 0
;          0, x <> 0

macro c
{
$usprocf @@_if.false_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        test    eax, eax                        ; compare x to 0
        jz     .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; false
; integer if.false ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x = 0
;          0, x <> 0

$usprocf @@_if.false_reg

    .enter:
        test    eax, eax                        ; compare x to 0
        jz     .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; zero
;
; integer if.z ( double x )
; return result in eax
; x = esp
;
; returns: 1, x = 0
;          0, x <> 0

macro @@if.z.sse
{
$usprocf @@if.z

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .0                               ; x <> 0
        jp     .0                               ; x <> 0

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@if.z.fpu
{
$usprocf @@if.z

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0, x <> 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x = 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.z.sse
$else
  @@if.z.fpu
$end

; ------------------------------------------------------------------------------

; zero
;
; integer if.z ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x = 0
;          0, x <> 0

macro c
{
$usprocf @@_if.z_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        test    eax, eax
        jz     .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0, x <> 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x = 0

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; zero
;
; integer if.z ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x = 0
;          0, x <> 0

$usprocf @@_if.z_reg

    .enter:
        test    eax, eax
        jz     .1                               ; jump if x = 0

    .0: xor     eax, eax                        ; return 0, x <> 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x = 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; not zero
;
; integer if.nz ( double x )
; return result in eax
; x = esp
;
; returns: 1, x <> 0
;          0, x = 0

macro @@if.nz.sse
{
$usprocf @@if.nz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .1                               ; x <> 0
        jp     .1                               ; x <> 0

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.nz.fpu
{
$usprocf @@if.nz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0, x = 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <> 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.nz.sse
$else
  @@if.nz.fpu
$end

; ------------------------------------------------------------------------------

; not zero
;
; integer if.nz ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x <> 0
;          0, x = 0

macro c
{
$usprocf @@_if.nz_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        test    eax, eax
        jnz    .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0, x = 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <> 0

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; not zero
;
; integer if.nz ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x <> 0
;          0, x = 0

$usprocf @@_if.nz_reg

    .enter:
        test    eax, eax
        jnz    .1                               ; jump if x <> 0

    .0: xor     eax, eax                        ; return 0, x = 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <> 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; above zero
;
; integer if.az ( double x )
; return result in eax
; x = esp
;
; returns: 1, x > 0
;          0, x <= 0

macro @@if.az.sse
{
$usprocf @@if.az

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .1

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp
}

macro @@if.az.fpu
{
$usprocf @@if.az

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .1                               ; jump if x > 0

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.az.sse
$else
  @@if.az.fpu
$end

; ------------------------------------------------------------------------------

; above zero
;
; integer if.az ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x > 0
;          0, x <= 0

macro c
{
$usprocf @@_if.az_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        cmp     eax, 0
        jg     .1                               ; jump if x > 0

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; above zero
;
; integer if.az ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x > 0
;          0, x <= 0

$usprocf @@_if.az_reg

    .enter:
        cmp     eax, 0
        jg     .1                               ; jump if x > 0

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; above or equal zero
;
; integer if.aez ( double x )
; return result in eax
; x = esp
;
; returns: 1, x >= 0
;          0, x < 0

macro @@if.aez.sse
{
$usprocf @@if.aez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .1

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp
}

macro @@if.aez.fpu
{
$usprocf @@if.aez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .1                               ; jump if x >= 0

    .0: xor     eax, eax                        ; return 0, x < 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x >= 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.aez.sse
$else
  @@if.aez.fpu
$end

; ------------------------------------------------------------------------------

; above or equal zero
;
; integer if.aez ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x >= 0
;          0, x < 0

macro c
{
$usprocf @@_if.aez_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        cmp     eax, 0
        jge    .1                               ; jump if x >= 0

    .0: xor     eax, eax                        ; return 0, x < 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x >= 0

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; above or equal zero
;
; integer if.aez ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x >= 0
;          0, x < 0

$usprocf @@_if.aez_reg

    .enter:
        cmp     eax, 0
        jge    .1                               ; jump if x >= 0

    .0: xor     eax, eax                        ; return 0, x < 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x >= 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; below zero
;
; integer if.bz ( double x )
; return result in eax
; x = esp
;
; returns: 1, x < 0
;          0, x >= 0

macro @@if.bz.sse
{
$usprocf @@if.bz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .1

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp
}

macro @@if.bz.fpu
{
$usprocf @@if.bz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .1                               ; jump if x < 0

    .0: xor     eax, eax                        ; return 0, x >= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x < 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.bz.sse
$else
  @@if.bz.fpu
$end

; ------------------------------------------------------------------------------

; below zero
;
; integer if.bz ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x < 0
;          0, x >= 0

macro c
{
$usprocf @@_if.bz_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        cmp     eax, 0
        jl     .1                               ; jump if x < 0

    .0: xor     eax, eax                        ; return 0, x >= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x < 0

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; below zero
;
; integer if.bz ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x < 0
;          0, x >= 0

$usprocf @@_if.bz_reg

    .enter:
        cmp     eax, 0
        jl     .1                               ; jump if x < 0

    .0: xor     eax, eax                        ; return 0, x >= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x < 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; below or equal zero
;
; integer if.bez ( double x )
; return result in eax
; x = esp
;
; returns: 1, x <= 0
;          0, x > 0

macro @@if.bez.sse
{
$usprocf @@if.bez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .1

    .0: xor     eax, eax                        ; return 0, x <= 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > 0

    .return:
        retn
$endp
}

macro @@if.bez.fpu
{
$usprocf @@if.bez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .1                               ; jump if x <= 0

    .0: xor     eax, eax                        ; return 0, x > 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <= 0

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.bez.sse
$else
  @@if.bez.fpu
$end

; ------------------------------------------------------------------------------

; below or equal zero
;
; integer if.bez ( integer x )
; return result in eax
; x = esp
;
; returns: 1, x <= 0
;          0, x > 0

macro c
{
$usprocf @@_if.bez_int

        mov     eax, dword [esp]                ; eax = x
    .enter:
        cmp     eax, 0
        jle    .1                               ; jump if x <= 0

    .0: xor     eax, eax                        ; return 0, x > 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <= 0

    .return:
        retn
$endp
}

; ------------------------------------------------------------------------------

; below or equal zero
;
; integer if.bez ( integer x )
; return result in eax
; x = eax
;
; returns: 1, x <= 0
;          0, x > 0

$usprocf @@_if.bez_reg

    .enter:
        cmp     eax, 0
        jle    .1                               ; jump if x <= 0

    .0: xor     eax, eax                        ; return 0, x > 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <= 0

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; equal
;
; integer if.e ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x = y
;          0, x <> y

macro @@if.e.sse
{
$usprocf @@if.e

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .0                               ; x <> y
        jp     .0                               ; x <> y

    .1: mov     eax, 1                          ; return 1
        jmp    .return
    .0: xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@if.e.fpu
{
$usprocf @@if.e

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnje   .1                               ; jump if x = y

    .0: xor     eax, eax                        ; return 0, x <> y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x = y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.e.sse
$else
  @@if.e.fpu
$end

; ------------------------------------------------------------------------------

; equal
;
; integer if.e ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x = y
;          0, x <> y

$usprocf @@_if.e_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx
        je     .1                               ; jump if x = y

    .0: xor     eax, eax                        ; return 0, x <> y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x = y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; equal
;
; integer if.e ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x = y
;          0, x <> y

$usprocf @@_if.e_reg

    .enter:
        cmp     eax, ecx
        je     .1                               ; jump if x = y

    .0: xor     eax, eax                        ; return 0, x <> y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x = y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; not equal
;
; integer if.ne ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x <> y
;          0, x = y

macro @@if.ne.sse
{
$usprocf @@if.ne

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ucomisd xmm0, xmm1                      ; compare x to y
        jnz    .1                               ; x <> y
        jp     .1                               ; x <> y

    .0: xor     eax, eax                        ; return 0
        jmp    .return
    .1: mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.ne.fpu
{
$usprocf @@if.ne

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnjne  .1                               ; jump if x <> y

    .0: xor     eax, eax                        ; return 0, x = y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <> y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.ne.sse
$else
  @@if.ne.fpu
$end

; ------------------------------------------------------------------------------

; not equal
;
; integer if.ne ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x <> y
;          0, x = y

$usprocf @@_if.ne_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx
        jne    .1                               ; jump if x <> y

    .0: xor     eax, eax                        ; return 0, x = y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <> y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; not equal
;
; integer if.ne ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x <> y
;          0, x = y

$usprocf @@_if.ne_reg

    .enter:
        cmp     eax, ecx
        jne    .1                               ; jump if x <> y

    .0: xor     eax, eax                        ; return 0, x = y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <> y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; above (greater)
;
; integer if.a ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x > y
;          0, x <= y

macro @@if.a.sse
{
$usprocf @@if.a

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        ja     .1

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp
}

macro @@if.a.fpu
{
$usprocf @@if.a

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnjl   .1                               ; jump if x > y (y < x)

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.a.sse
$else
  @@if.a.fpu
$end

; ------------------------------------------------------------------------------

; above (greater)
;
; integer if.a ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x > y
;          0, x <= y

$usprocf @@_if.a_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx
        jg     .1                               ; jump if x > y

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; above (greater)
;
; integer if.a ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x > y
;          0, x <= y

$usprocf @@_if.a_reg

    .enter:
        cmp     eax, ecx
        jg     .1                               ; jump if x > y

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; above or equal (greater or equal)
;
; integer if.ae ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x >= y
;          0, x < y

macro @@if.ae.sse
{
$usprocf @@if.ae

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jae    .1

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp
}

macro @@if.ae.fpu
{
$usprocf @@if.ae

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnjle  .1                               ; jump if x >= y (y <= x)

    .0: xor     eax, eax                        ; return 0, x < y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x >= y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.ae.sse
$else
  @@if.ae.fpu
$end

; ------------------------------------------------------------------------------

; above or equal (greater or equal)
;
; integer if.ae ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x >= y
;          0, x < y

$usprocf @@_if.ae_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx
        jge    .1                               ; jump if x >= y

    .0: xor     eax, eax                        ; return 0, x < y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x >= y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; above or equal (greater or equal)
;
; integer if.ae ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x >= y
;          0, x < y

$usprocf @@_if.ae_reg

    .enter:
        cmp     eax, ecx
        jge    .1                               ; jump if x >= y

    .0: xor     eax, eax                        ; return 0, x < y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x >= y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; below (less)
;
; integer if.b ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x < y
;          0, x >= y

macro @@if.b.sse
{
$usprocf @@if.b

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jb     .1

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp
}

macro @@if.b.fpu
{
$usprocf @@if.b

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnjg   .1                               ; jump if x < y (y > x)

    .0: xor     eax, eax                        ; return 0, x >= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x < y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.b.sse
$else
  @@if.b.fpu
$end

; ------------------------------------------------------------------------------

; below (less)
;
; integer if.b ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x < y
;          0, x >= y

$usprocf @@_if.b_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx
        jl     .1                               ; jump if x < y

    .0: xor     eax, eax                        ; return 0, x >= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x < y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; below (less)
;
; integer if.b ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x < y
;          0, x >= y

$usprocf @@_if.b_reg

    .enter:
        cmp     eax, ecx
        jl     .1                               ; jump if x < y

    .0: xor     eax, eax                        ; return 0, x >= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x < y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; below or equal (less or equal)
;
; integer if.be ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns: 1, x <= y
;          0, x > y

macro @@if.be.sse
{
$usprocf @@if.be

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jbe    .1

    .0: xor     eax, eax                        ; return 0, x <= y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x > y

    .return:
        retn
$endp
}

macro @@if.be.fpu
{
$usprocf @@if.be

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnjge  .1                               ; jump if x <= y (y >= x)

    .0: xor     eax, eax                        ; return 0, x > y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <= y

    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.be.sse
$else
  @@if.be.fpu
$end

; ------------------------------------------------------------------------------

; below or equal (less or equal)
;
; integer if.be ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns: 1, x <= y
;          0, x > y

$usprocf @@_if.be_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx
        jle    .1                               ; jump if x <= y

    .0: xor     eax, eax                        ; return 0, x > y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <= y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; below or equal (less or equal)
;
; integer if.be ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns: 1, x <= y
;          0, x > y

$usprocf @@_if.be_reg

    .enter:
        cmp     eax, ecx
        jle    .1                               ; jump if x <= y

    .0: xor     eax, eax                        ; return 0, x > y
        jmp    .return
    .1: mov     eax, 1                          ; return 1, x <= y

    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; three-way comparison
;
; integer if.bea ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns -1 if x < y
;          0 if x = y
;         +1 if x > y

macro @@if.bea.sse
{
$usprocf @@if.bea

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        ja     .p1
        jb     .m1

        xor     eax, eax                        ; return 0
        jmp    .return
    .m1:
        or      eax, -1                         ; return -1
        jmp    .return
    .p1:
        mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.bea.fpu
{
$usprocf @@if.bea

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnstsw  ax
        sahf
        jne    .ne
    .e:
        xor     eax, eax                        ; return 0
        jmp    .return
    .ne:
        mov     eax, 1                          ; return 1
        jb     .return                          ; jump if x > y (y < x)
        neg     eax                             ; return -1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.bea.sse
$else
  @@if.bea.fpu
$end

; ------------------------------------------------------------------------------

; three-way comparison
;
; integer if.bea ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns -1 if x < y
;          0 if x = y
;         +1 if x > y

$usprocf @@_if.bea_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx                        ; compare x to y
        jne    .ne
    .e:
        xor     eax, eax                        ; return 0
        jmp    .return
    .ne:
        mov     eax, 1                          ; return 1
        ja     .return                          ; jump if x > y
        neg     eax                             ; return -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; three-way comparison
;
; integer if.bea ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns -1 if x < y
;          0 if x = y
;         +1 if x > y

$usprocf @@_if.bea_reg

    .enter:
        cmp     eax, ecx                        ; compare x to y
        jne    .ne
    .e:
        xor     eax, eax                        ; return 0
        jmp    .return
    .ne:
        mov     eax, 1                          ; return 1
        ja     .return                          ; jump if x > y
        neg     eax                             ; return -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; three-way comparison
;
; integer if.aeb ( double x, double y )
; return result in eax
; x = esp
; y = esp + 8
;
; returns -1 if x > y
;          0 if x = y
;         +1 if x < y

macro @@if.aeb.sse
{
$usprocf @@if.aeb

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        comisd  xmm0, xmm1                      ; compare x to y
        jb     .p1
        ja     .m1

        xor     eax, eax                        ; return 0
        jmp    .return
    .m1:
        or      eax, -1                         ; return -1
        jmp    .return
    .p1:
        mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.aeb.fpu
{
$usprocf @@if.aeb

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fcompp                                  ; compare y to x
        fnstsw  ax
        sahf
        jne    .ne
    .e:
        xor     eax, eax                        ; return 0
        jmp    .return
    .ne:
        mov     eax, 1                          ; return 1
        ja     .return                          ; jump if x < y (y > x)
        neg     eax                             ; return -1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@if.aeb.sse
$else
  @@if.aeb.fpu
$end

; ------------------------------------------------------------------------------

; three-way comparison
;
; integer if.aeb ( integer x, integer y )
; return result in eax
; x = esp
; y = esp + 4
;
; returns -1 if x > y
;          0 if x = y
;         +1 if x < y

$usprocf @@_if.aeb_int

        mov     eax, dword [esp]                ; eax = x
        mov     edx, dword [esp + 4]            ; edx = y
    .enter:
        cmp     eax, edx                        ; compare x to y
        jne    .ne
    .e:
        xor     eax, eax                        ; return 0
        jmp    .return
    .ne:
        mov     eax, 1                          ; return 1
        jb     .return                          ; jump if x < y
        neg     eax                             ; return -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; three-way comparison
;
; integer if.aeb ( integer x, integer y )
; return result in eax
; x = eax
; y = ecx
;
; returns -1 if x > y
;          0 if x = y
;         +1 if x < y

$usprocf @@_if.aeb_reg

    .enter:
        cmp     eax, ecx                        ; compare x to y
        jne    .ne
    .e:
        xor     eax, eax                        ; return 0
        jmp    .return
    .ne:
        mov     eax, 1                          ; return 1
        jb     .return                          ; jump if x < y
        neg     eax                             ; return -1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; multi-or
;
; integer if.or ( x, Y1, Y2, ..., Yn )
; return result in eax
; variable number of arguments
; ecx -> argument count, min=2
;
; returns: 1, (x = Y1) or (x = Y2) or ... or (x = Yn)
;          0, othewise

macro @@if.or.sse
{
$usprocf @@if.or

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .0:
        xor     eax, eax                        ; return 0
        jmp    .return                          ; no matches
    .compare:
        ucomisd xmm0, qword [esp + edx * 8]     ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
    .1:
        mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.or.fpu
{
$usprocf @@if.or

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .0:
        xor     eax, eax                        ; return 0
        jmp    .return                          ; no matches
    .compare:
        fcom    qword [esp + edx * 8]           ; compare x to Y[i]
        fnjne  .next.arg                        ; test next argument if x <> Y[i]
    .1:
        mov     eax, 1                          ; return 1

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@if.or.sse
$else
  @@if.or.fpu
$end

; ------------------------------------------------------------------------------

; multi-nor
;
; integer if.nor ( x, Y1, Y2, ..., Yn )
; return result in eax
; variable number of arguments
; ecx -> argument count, min=2
;
; returns: 1, (x <> Y1) and (x <> Y2) and ... and (x <> Yn)
;          0, othewise

macro @@if.nor.sse
{
$usprocf @@if.nor

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .1:
        mov     eax, 1                          ; return 1
        jmp    .return                          ; complete match
    .compare:
        ucomisd xmm0, qword [esp + edx * 8]     ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
    .0:
        xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@if.nor.fpu
{
$usprocf @@if.nor

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .1:
        mov     eax, 1                          ; return 1
        jmp    .return                          ; complete match
    .compare:
        fcom    qword [esp + edx * 8]           ; compare x to Y[i]
        fnjne  .next.arg                        ; test next argument if x <> Y[i]
    .0:
        xor     eax, eax                        ; return 0

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@if.nor.sse
$else
  @@if.nor.fpu
$end

; ------------------------------------------------------------------------------

; multi-and
;
; integer if.and ( x, Y1, Y2, ..., Yn )
; return result in eax
; variable number of arguments
; ecx -> argument count, min=2
;
; returns: 1, (x = Y1) and (x = Y2) and ... and (x = Yn)
;          0, othewise

macro @@if.and.sse
{
$usprocf @@if.and

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .1:
        mov     eax, 1                          ; return 1
        jmp    .return                          ; complete match
    .compare:
        ucomisd xmm0, qword [esp + edx * 8]     ; compare x to Y[i]
        jnz    .0
        jp     .0
        jmp    .next.arg                        ; test next argument if x = Y[i]
    .0:
        xor     eax, eax                        ; return 0

    .return:
        retn
$endp
}

macro @@if.and.fpu
{
$usprocf @@if.and

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .1:
        mov     eax, 1                          ; return 1
        jmp    .return                          ; complete match
    .compare:
        fcom    qword [esp + edx * 8]           ; compare x to Y[i]
        fnje   .next.arg                        ; test next argument if x = Y[i]
    .0:
        xor     eax, eax                        ; return 0

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@if.and.sse
$else
  @@if.and.fpu
$end

; ------------------------------------------------------------------------------

; multi-nand
;
; integer if.nand ( x, Y1, Y2, ..., Yn )
; return result in eax
; variable number of arguments
; ecx -> argument count, min=2
;
; returns: 1, (x <> Y1) or (x <> Y2) or ... or (x <> Yn)
;          0, othewise

macro @@if.nand.sse
{
$usprocf @@if.nand

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .0:
        xor     eax, eax                        ; return 0
        jmp    .return                          ; complete match
    .compare:
        ucomisd xmm0, qword [esp + edx * 8]     ; compare x to Y[i]
        jnz    .1
        jp     .1
        jmp    .next.arg                        ; test next argument if x = Y[i]
    .1:
        mov     eax, 1                          ; return 1

    .return:
        retn
$endp
}

macro @@if.nand.fpu
{
$usprocf @@if.nand

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .inter:
        xor     edx, edx
    .next.arg:
        inc     edx
        cmp     edx, ecx
        jne    .compare
    .0:
        xor     eax, eax                        ; return 0
        jmp    .return                          ; no matches
    .compare:
        fcom    qword [esp + edx * 8]           ; compare x to Y[i]
        fnje   .next.arg                        ; test next argument if x = Y[i]
    .1:
        mov     eax, 1                          ; return 1

    .return:
        fstp    st1                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@if.nand.sse
$else
  @@if.nand.fpu
$end

; ------------------------------------------------------------------------------
