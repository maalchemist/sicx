
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (arithmetic functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; nop

$usprocf @@nop

    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; prefix +
; unary +

macro @@uplus.sse
{
$usprocf @@uplus

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

macro @@uplus.fpu
{
$usprocf @@uplus

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@uplus.sse
$else
  @@uplus.fpu
$end

; ------------------------------------------------------------------------------

; reverse sign

macro @@chs.sse
{
$usprocf @@chs

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, ??.0x8000000000000000
        pxor    xmm0, [eax]                     ; xmm0 = chs(x)
    .return:
        retn
$endp
}

macro @@chs.fpu
{
$usprocf @@chs

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fchs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@chs.sse
$else
  @@chs.fpu
$end

; ------------------------------------------------------------------------------

; reverse sign

macro @@_chs_int.sse
{
$usprocf @@_chs_int

        mov     eax, [esp]
    .enter:
        neg     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_chs_int.fpu
{
$usprocf @@_chs_int

        mov     eax, [esp]
    .enter:
        neg     eax
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_chs_int.sse
$else
; @@_chs_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse sign
; x = eax

macro @@_chs_reg.sse
{
$usprocf @@_chs_reg

    .enter:
        neg     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_chs_reg.fpu
{
$usprocf @@_chs_reg

    .enter:
        neg     eax
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_chs_reg.sse
$else
  @@_chs_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy chs(dst) to dst
; co.chs ( pdouble dst )
; dst offset = ecx

macro @@co.chs.sse
{
$usprocf @@co.chs

        movsd   xmm0, qword [ecx]               ; xmm0 = x
    .enter:
        mov     eax, ??.0x8000000000000000
        pxor    xmm0, [eax]                     ; xmm0 = chs(x)
    .copy:
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@co.chs.fpu
{
$usprocf @@co.chs

        fld     qword [ecx]
    .enter:
        fchs
    .copy:
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.chs.sse
$else
  @@co.chs.fpu
$end

; ------------------------------------------------------------------------------

; copy chs(dst) to dst
; co.chs ( pinteger dst )
; dst offset = ecx

macro @@_co.int.chs.sse
{
$usprocf @@_co.int.chs

        neg     dword [ecx]
    .load:
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.chs.fpu
{
$usprocf @@_co.int.chs

        neg     dword [ecx]
    .load:
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.chs.sse
$else
  @@_co.int.chs.fpu
$end

; ------------------------------------------------------------------------------

; absolute value

macro @@abs.sse
{
$usprocf @@abs

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, ??.0x7FFFFFFFFFFFFFFF
        pand    xmm0, [eax]                     ; xmm0 = abs(x)
    .return:
        retn
$endp
}

macro @@abs.fpu
{
$usprocf @@abs

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fabs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@abs.sse
$else
  @@abs.fpu
$end

; ------------------------------------------------------------------------------

; absolute value

macro @@_abs_int.sse
{
$usprocf @@_abs_int

        mov     eax, [esp]
    .enter:
        cdq
        xor     eax, edx
        sub     eax, edx                        ; eax = abs(x)
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_abs_int.fpu
{
$usprocf @@_abs_int

        mov     eax, [esp]
    .enter:
        cdq
        xor     eax, edx
        sub     eax, edx                        ; eax = abs(x)
    .save:
        mov     [esp], eax
    .load:
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_abs_int.sse
$else
; @@_abs_int.fpu
$end

; ------------------------------------------------------------------------------

; absolute value
; x = eax

macro @@_abs_reg.sse
{
$usprocf @@_abs_reg

    .enter:
        cdq
        xor     eax, edx
        sub     eax, edx                        ; eax = abs(x)
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_abs_reg.fpu
{
$usprocf @@_abs_reg

    .enter:
        cdq
        xor     eax, edx
        sub     eax, edx                        ; eax = abs(x)
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_abs_reg.sse
$else
  @@_abs_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy abs(dst) to dst
; co.abs ( pdouble dst )
; dst offset = ecx

macro @@co.abs.sse
{
$usprocf @@co.abs

        movsd   xmm0, qword [ecx]               ; xmm0 = x
    .enter:
        mov     eax, ??.0x7FFFFFFFFFFFFFFF
        pand    xmm0, [eax]                     ; xmm0 = abs(x)
    .copy:
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@co.abs.fpu
{
$usprocf @@co.abs

        fld     qword [ecx]
    .enter:
        fabs
    .copy:
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.abs.sse
$else
  @@co.abs.fpu
$end

; ------------------------------------------------------------------------------

; copy abs(dst) to dst
; co.abs ( pinteger dst )
; dst offset = ecx

macro @@_co.int.abs.sse
{
$usprocf @@_co.int.abs

        cmp     dword [ecx], 0
        jge    .load
        neg     dword [ecx]
    .load:
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.abs.fpu
{
$usprocf @@_co.int.abs

        cmp     dword [ecx], 0
        jge    .load
        neg     dword [ecx]
    .load:
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.abs.sse
$else
  @@_co.int.abs.fpu
$end

; ------------------------------------------------------------------------------

; negative absolute value
; nabs(x) = -abs(x)

macro @@nabs.sse
{
$usprocf @@nabs

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, ??.0x8000000000000000
        por     xmm0, [eax]                     ; xmm0 = -abs(x)
    .return:
        retn
$endp
}

macro @@nabs.fpu
{
$usprocf @@nabs

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fabs
        fchs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@nabs.sse
$else
  @@nabs.fpu
$end

; ------------------------------------------------------------------------------

; negative absolute value
; nabs(x) = -abs(x)

macro @@_nabs_int.sse
{
$usprocf @@_nabs_int

        mov     eax, [esp]
    .enter:
        cmp     eax, 0
        jle    .load
        neg     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_nabs_int.fpu
{
$usprocf @@_nabs_int

        mov     eax, [esp]
    .enter:
        cmp     eax, 0
        jle    .load
        neg     eax
    .save:
        mov     [esp], eax
    .load:
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_nabs_int.sse
$else
; @@_nabs_int.fpu
$end

; ------------------------------------------------------------------------------

; negative absolute value
; nabs(x) = -abs(x)
; x = eax

macro @@_nabs_reg.sse
{
$usprocf @@_nabs_reg

    .enter:
        cmp     eax, 0
        jle    .load
        neg     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_nabs_reg.fpu
{
$usprocf @@_nabs_reg

    .enter:
        cmp     eax, 0
        jle    .load
        neg     eax
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nabs_reg.sse
$else
  @@_nabs_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy nabs(dst) to dst
; co.nabs ( pdouble dst )
; dst offset = ecx

macro @@co.nabs.sse
{
$usprocf @@co.nabs

        movsd   xmm0, qword [ecx]               ; xmm0 = x
    .enter:
        mov     eax, ??.0x8000000000000000
        por     xmm0, [eax]                     ; xmm0 = -abs(x)
    .copy:
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@co.nabs.fpu
{
$usprocf @@co.nabs

        fld     qword [ecx]
    .enter:
        fabs
        fchs
    .copy:
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.nabs.sse
$else
  @@co.nabs.fpu
$end

; ------------------------------------------------------------------------------

; copy nabs(dst) to dst
; co.nabs ( pinteger dst )
; dst offset = ecx

macro @@_co.int.nabs.sse
{
$usprocf @@_co.int.nabs

        cmp     dword [ecx], 0
        jle    .load
        neg     dword [ecx]
    .load:
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.nabs.fpu
{
$usprocf @@_co.int.nabs

        cmp     dword [ecx], 0
        jle    .load
        neg     dword [ecx]
    .load:
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.nabs.sse
$else
  @@_co.int.nabs.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; sign of a number (-1, 0, 1)

macro @@sign.sse
{
$usprocf @@sign

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        comisd  xmm0, xmm1                      ; compare x to 0
        ja     .p1                              ; jump if x > 0
        jb     .m1                              ; jump if x < 0
   .zero:
        xorpd   xmm0, xmm0                      ; return 0
        jmp    .return
   .m1:
        mov     eax, ??.m1.0                    ; return -1
        jmp    .load
   .p1:
        mov     eax, ??.1.0                     ; return +1
   .load:
        movsd   xmm0, qword [eax]
   .return:
        retn
$endp
}

macro @@sign.fpu
{
$usprocf @@sign

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnstsw  ax
        sahf
        jne    .nonzero                         ; jump if x != 0
   .zero:
        fldz                                    ; return 0
        jmp    .return
   .nonzero:
        fld1
        ja     .return                          ; return +1
        fchs                                    ; return -1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@sign.sse
$else
  @@sign.fpu
$end

; ------------------------------------------------------------------------------

; sign of a number (-1, 0, 1)

macro @@_sign_int.sse
{
$usprocf @@_sign_int

        mov     eax, [esp]
   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        xorpd   xmm0, xmm0                      ; return 0
        jmp    .return
   .nonzero:
        jg     .p1
   .m1:
        mov     eax, ??.m1.0                    ; return -1
        jmp    .load
   .p1:
        mov     eax, ??.1.0                     ; return +1
   .load:
        movsd   xmm0, qword [eax]
   .return:
        retn
$endp
}

macro @@_sign_int.fpu
{
$usprocf @@_sign_int

        mov     eax, [esp]
   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        fldz
        jmp    .return
   .nonzero:
        fld1
        jg     .return
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sign_int.sse
$else
  @@_sign_int.fpu
$end

; ------------------------------------------------------------------------------

; sign of a number (-1, 0, 1)
; x = eax

macro @@_sign_reg.sse
{
$usprocf @@_sign_reg

   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        xorpd   xmm0, xmm0                      ; return 0
        jmp    .return
   .nonzero:
        jg     .p1
   .m1:
        mov     eax, ??.m1.0                    ; return -1
        jmp    .load
   .p1:
        mov     eax, ??.1.0                     ; return +1
   .load:
        movsd   xmm0, qword [eax]
   .return:
        retn
$endp
}

macro @@_sign_reg.fpu
{
$usprocf @@_sign_reg

   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        fldz
        jmp    .return
   .nonzero:
        fld1
        jg     .return
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sign_reg.sse
$else
  @@_sign_reg.fpu
$end

; ------------------------------------------------------------------------------

; reversed sign of a number (-1, 0, 1)

macro @@rsign.sse
{
$usprocf @@rsign

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        comisd  xmm0, xmm1                      ; compare x to 0
        jb     .p1                              ; jump if x < 0
        ja     .m1                              ; jump if x > 0
   .zero:
        xorpd   xmm0, xmm0                      ; return 0
        jmp    .return
   .m1:
        mov     eax, ??.m1.0                    ; return -1
        jmp    .load
   .p1:
        mov     eax, ??.1.0                     ; return +1
   .load:
        movsd   xmm0, qword [eax]
   .return:
        retn
$endp
}

macro @@rsign.fpu
{
$usprocf @@rsign

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnstsw  ax
        sahf
        jne    .nonzero                         ; jump if x != 0
   .zero:
        fldz                                    ; return 0
        jmp    .return
   .nonzero:
        fld1
        jb     .return                          ; return +1
        fchs                                    ; return -1
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@rsign.sse
$else
  @@rsign.fpu
$end

; ------------------------------------------------------------------------------

; reversed sign of a number (-1, 0, 1)

macro @@_rsign_int.sse
{
$usprocf @@_rsign_int

        mov     eax, [esp]
   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        xorpd   xmm0, xmm0                      ; return 0
        jmp    .return
   .nonzero:
        jl     .p1
   .m1:
        mov     eax, ??.m1.0                    ; return -1
        jmp    .load
   .p1:
        mov     eax, ??.1.0                     ; return +1
   .load:
        movsd   xmm0, qword [eax]
   .return:
        retn
$endp
}

macro @@_rsign_int.fpu
{
$usprocf @@_rsign_int

        mov     eax, [esp]
   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        fldz
        jmp    .return
   .nonzero:
        fld1
        jl     .return
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_rsign_int.sse
$else
  @@_rsign_int.fpu
$end

; ------------------------------------------------------------------------------

; reversed sign of a number (-1, 0, 1)
; x = eax

macro @@_rsign_reg.sse
{
$usprocf @@_rsign_reg

   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        xorpd   xmm0, xmm0                      ; return 0
        jmp    .return
   .nonzero:
        jl     .p1
   .m1:
        mov     eax, ??.m1.0                    ; return -1
        jmp    .load
   .p1:
        mov     eax, ??.1.0                     ; return +1
   .load:
        movsd   xmm0, qword [eax]
   .return:
        retn
$endp
}

macro @@_rsign_reg.fpu
{
$usprocf @@_rsign_reg

   .enter:
        cmp     eax, 0
        jnz    .nonzero
   .zero:
        fldz
        jmp    .return
   .nonzero:
        fld1
        jl     .return
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_rsign_reg.sse
$else
  @@_rsign_reg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; sign of a number (-1, 0, 1)
; return result in eax

macro @@isign.sse
{
$usprocf @@isign

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        comisd  xmm0, xmm1                      ; compare x to 0
        ja     .p1                              ; jump if x > 0
        jb     .m1                              ; jump if x < 0
   .zero:
        jmp    .load
   .m1:
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp
}

macro @@isign.fpu
{
$usprocf @@isign

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnstsw  ax
        sahf
        ja     .p1                              ; jump if x > 0
        jb     .m1                              ; jump if x < 0
   .zero:
        xor     eax, eax                        ; return 0
        jmp    .load
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@isign.sse
$else
  @@isign.fpu
$end

; ------------------------------------------------------------------------------

$usprocf @@_isign_reg

   .enter:
        cmp     eax, 0
        jz     .load
   .nonzero:
        jg     .p1                              ; jump if x > 0
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; reversed sign of a number (-1, 0, 1)
; return result in eax

macro @@risign.sse
{
$usprocf @@risign

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        comisd  xmm0, xmm1                      ; compare x to 0
        jb     .p1                              ; jump if x < 0
        ja     .m1                              ; jump if x > 0
   .zero:
        jmp    .load
   .m1:
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp
}

macro @@risign.fpu
{
$usprocf @@risign

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        ftst                                    ; compare x to 0
        fstp    st0
        fnstsw  ax
        sahf
        jb     .p1                              ; jump if x < 0
        ja     .m1                              ; jump if x > 0
   .zero:
        xor     eax, eax                        ; return 0
        jmp    .load
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@risign.sse
$else
  @@risign.fpu
$end

; ------------------------------------------------------------------------------

$usprocf @@_risign_reg

   .enter:
        cmp     eax, 0
        jz     .load
   .nonzero:
        jl     .p1                              ; jump if x < 0
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; non-zero sign of a number (-1, 1)
; return result in eax

macro @@nzisign.sse
{
$usprocf @@nzisign

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax
       movmskpd ecx, xmm0                       ; ecx = sign bits
        test    ecx, 1                          ; test sign bit
        jnz    .m1                              ; jump if x < 0
   .p1:
        inc     eax                             ; return +1
        jmp    .load
   .m1:
        dec     eax                             ; return -1
   .load:
   .return:
        retn
$endp
}

macro @@nzisign.fpu
{
$usprocf @@nzisign

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fstp    qword [esp - 8]
        test    dword [esp - 4], 0x80000000     ; test sign bit
        jnz    .m1                              ; jump if x < 0
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
        jmp    .load
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
   .load:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@nzisign.sse
$else
  @@nzisign.fpu
$end

; ------------------------------------------------------------------------------

$usprocf @@_nzisign_reg

   .enter:
        cmp     eax, 0
        jl     .m1                              ; jump if x < 0
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
        jmp    .load
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
   .load:
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; reversed non-zero sign of a number (-1, 1)
; return result in eax

macro @@rnzisign.sse
{
$usprocf @@rnzisign

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xor     eax, eax
       movmskpd ecx, xmm0                       ; ecx = sign bits
        test    ecx, 1                          ; test sign bit
        jnz    .p1                              ; jump if x < 0
   .m1:
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp
}

macro @@rnzisign.fpu
{
$usprocf @@rnzisign

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fstp    qword [esp - 8]
        test    dword [esp - 4], 0x80000000     ; test sign bit
        jnz    .p1                              ; jump if x < 0
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@rnzisign.sse
$else
  @@rnzisign.fpu
$end

; ------------------------------------------------------------------------------

$usprocf @@_rnzisign_reg

   .enter:
        cmp     eax, 0
        jl     .p1                              ; jump if x < 0
   .m1:
        xor     eax, eax
        dec     eax                             ; return -1
        jmp    .load
   .p1:
        xor     eax, eax
        inc     eax                             ; return +1
   .load:
   .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; non-zero value
; double nzero ( double x )
;
; returns:    x, x <> 0
;          +eps, x = +0
;          -eps, x = -0

macro @@nzero.sse
{
$usprocf @@nzero

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        ucomisd xmm0, xmm1                      ; compare x to 0
        jnz    .nonzero
        jp     .nonzero
   .zero:
       movmskpd ecx, xmm0                       ; ecx = sign bits
        test    ecx, 1                          ; test sign bit
        jz     .zerop                           ; jump if no sign bit
   .zerom:                                      ; -0
        xmovsd  xmm0, ??.NEpsilon               ; return negative epsilon
        jmp    .return
   .zerop:                                      ; +0
        xmovsd  xmm0, ??.PEpsilon               ; return positive epsilon
;       jmp    .return
   .nonzero:
   .return:
        retn
$endp
}

macro @@nzero.fpu
{
$usprocf @@nzero

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        ftst                                    ; compare x to 0
        fnstsw  ax
        sahf
        jne    .nonzero                         ; jump if x != 0
   .zero:
        fstp    qword [esp - 8]
        test    dword [esp - 4], 0x80000000     ; test sign bit
        jz     .zerop                           ; jump if no sign bit
   .zerom:                                      ; -0
        fldq    ??.NEpsilon                     ; return negative epsilon
        jmp    .return
   .zerop:                                      ; +0
        fldq    ??.PEpsilon                     ; return positive epsilon
;       jmp    .return
   .nonzero:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@nzero.sse
$else
  @@nzero.fpu
$end

; ------------------------------------------------------------------------------

; non-zero value
; double nzero ( integer x )
;
; returns:    x, x <> 0
;          +eps, x = 0

macro @@_nzero_int.sse
{
$usprocf @@_nzero_int

        mov     eax, [esp]
   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        xmovsd  xmm0, ??.PEpsilon               ; return positive epsilon
        jmp    .return
   .load:
       cvtsi2sd xmm0, eax
   .return:
        retn
$endp
}

macro @@_nzero_int.fpu
{
$usprocf @@_nzero_int

        mov     eax, [esp]
   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        fldq    ??.PEpsilon                     ; return positive epsilon
        jmp    .return
   .load:
        mov     [esp], eax
        fild    dword [esp]
   .return:
        retn
$endp
}

$ifdef _SSEX
; @@_nzero_int.sse
$else
; @@_nzero_int.fpu
$end

; ------------------------------------------------------------------------------

; non-zero value
; double nzero ( integer x )
; x = eax
;
; returns:    x, x <> 0
;          +eps, x = 0

macro @@_nzero_reg.sse
{
$usprocf @@_nzero_reg

   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        xmovsd  xmm0, ??.PEpsilon               ; return positive epsilon
        jmp    .return
   .load:
       cvtsi2sd xmm0, eax
   .return:
        retn
$endp
}

macro @@_nzero_reg.fpu
{
$usprocf @@_nzero_reg

   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        fldq    ??.PEpsilon                     ; return positive epsilon
        jmp    .return
   .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_nzero_reg.sse
$else
  @@_nzero_reg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reversed non-zero value
; double rnzero ( double x )
;
; returns:   -x, x <> 0
;          -eps, x = +0
;          +eps, x = -0

macro @@rnzero.sse
{
$usprocf @@rnzero

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        ucomisd xmm0, xmm1                      ; compare x to 0
        jnz    .nonzero
        jp     .nonzero
   .zero:
       movmskpd ecx, xmm0                       ; ecx = sign bits
        test    ecx, 1                          ; test sign bit
        jz     .zerop                           ; jump if no sign bit
   .zerom:                                      ; -0
        xmovsd  xmm0, ??.PEpsilon               ; return positive epsilon
        jmp    .return
   .zerop:                                      ; +0
        xmovsd  xmm0, ??.NEpsilon               ; return negative epsilon
        jmp    .return
   .nonzero:
        @@.chs  xmm0
   .return:
        retn
$endp
}

macro @@rnzero.fpu
{
$usprocf @@rnzero

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        ftst                                    ; compare x to 0
        fnstsw  ax
        sahf
        jne    .nonzero                         ; jump if x != 0
   .zero:
        fstp    qword [esp - 8]
        test    dword [esp - 4], 0x80000000     ; test sign bit
        jz     .zerop                           ; jump if no sign bit
   .zerom:                                      ; -0
        fldq    ??.PEpsilon                     ; return positive epsilon
        jmp    .return
   .zerop:                                      ; +0
        fldq    ??.NEpsilon                     ; return negative epsilon
        jmp    .return
   .nonzero:
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@rnzero.sse
$else
  @@rnzero.fpu
$end

; ------------------------------------------------------------------------------

; reversed non-zero value
; double rnzero ( integer x )
;
; returns:   -x, x <> 0
;          -eps, x = 0

macro @@_rnzero_int.sse
{
$usprocf @@_rnzero_int

        mov     eax, [esp]
   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        xmovsd  xmm0, ??.NEpsilon               ; return negative epsilon
        jmp    .return
   .load:
       cvtsi2sd xmm0, eax
        @@.chs  xmm0
   .return:
        retn
$endp
}

macro @@_rnzero_int.fpu
{
$usprocf @@_rnzero_int

        mov     eax, [esp]
   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        fldq    ??.NEpsilon                     ; return negative epsilon
        jmp    .return
   .load:
        mov     [esp], eax
        fild    dword [esp]
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
; @@_rnzero_int.sse
$else
; @@_rnzero_int.fpu
$end

; ------------------------------------------------------------------------------

; reversed non-zero value
; double rnzero ( integer x )
; x = eax
;
; returns:   -x, x <> 0
;          -eps, x = 0

macro @@_rnzero_reg.sse
{
$usprocf @@_rnzero_reg

   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        xmovsd  xmm0, ??.NEpsilon               ; return negative epsilon
        jmp    .return
   .load:
       cvtsi2sd xmm0, eax
        @@.chs  xmm0
   .return:
        retn
$endp
}

macro @@_rnzero_reg.fpu
{
$usprocf @@_rnzero_reg

   .enter:
        test    eax, eax
        jnz    .load
   .zero:
        fldq    ??.NEpsilon                     ; return negative epsilon
        jmp    .return
   .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
        fchs
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@_rnzero_reg.sse
$else
  @@_rnzero_reg.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; positive value or zero
; double pos ( double x )
;
; returns: x, x > 0
;          0, otherwise

macro @@pos.sse
{
$usprocf @@pos

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@pos.fpu
{
$usprocf @@pos

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@pos.sse
$else
  @@pos.fpu
$end

; ------------------------------------------------------------------------------

; positive value or zero
; double pos ( integer x )
;
; returns: x, x > 0
;          0, otherwise

macro @@_pos_int.sse
{
$usprocf @@_pos_int

        mov     eax, [esp]
    .enter:
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_pos_int.fpu
{
$usprocf @@_pos_int

        mov     eax, [esp]
    .enter:
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_pos_int.sse
$else
; @@_pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive value or zero
; double pos ( integer x )
; x = eax
;
; returns: x, x > 0
;          0, otherwise

macro @@_pos_reg.sse
{
$usprocf @@_pos_reg

    .enter:
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_pos_reg.fpu
{
$usprocf @@_pos_reg

    .enter:
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_pos_reg.sse
$else
  @@_pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative value or zero
; double neg ( double x )
;
; returns: x, x < 0
;          0, otherwise

macro @@neg.sse
{
$usprocf @@neg

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@neg.fpu
{
$usprocf @@neg

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@neg.sse
$else
  @@neg.fpu
$end

; ------------------------------------------------------------------------------

; negative value or zero
; double neg ( integer x )
;
; returns: x, x < 0
;          0, otherwise

macro @@_neg_int.sse
{
$usprocf @@_neg_int

        mov     eax, [esp]
    .enter:
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_neg_int.fpu
{
$usprocf @@_neg_int

        mov     eax, [esp]
    .enter:
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_neg_int.sse
$else
; @@_neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative value or zero
; double neg ( integer x )
; x = eax
;
; returns: x, x < 0
;          0, otherwise

macro @@_neg_reg.sse
{
$usprocf @@_neg_reg

    .enter:
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_neg_reg.fpu
{
$usprocf @@_neg_reg

    .enter:
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_neg_reg.sse
$else
  @@_neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; inversion
; /x = 1/x

macro @@inv.sse
{
$usprocf @@inv

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmovsd  xmm1, ??.1.0                    ; xmm1 = 1
        divsd   xmm1, xmm0                      ; xmm1 = 1/x
        movsd   xmm0, xmm1                      ; xmm0 = 1/x
    .return:
        retn
$endp
}

macro @@inv.fpu
{
$usprocf @@inv

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@inv.sse
$else
  @@inv.fpu
$end

; ------------------------------------------------------------------------------

; inversion
; /x = 1/x

macro @@_inv_int.sse
{
$usprocf @@_inv_int

        mov     eax, 1
        cdq
        idiv    dword [esp]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_inv_int.fpu
{
$usprocf @@_inv_int

        mov     eax, 1
        cdq
        idiv    dword [esp]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_inv_int.sse
$else
; @@_inv_int.fpu
$end

; ------------------------------------------------------------------------------

; inversion
; /x = 1/x
; x = eax

macro @@_inv_reg.sse
{
$usprocf @@_inv_reg

        mov     ecx, 1
        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_inv_reg.fpu
{
$usprocf @@_inv_reg

        mov     ecx, 1
        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_inv_reg.sse
$else
  @@_inv_reg.fpu
$end

; ------------------------------------------------------------------------------

; quo inversion
; \x = 1\x = int(1/x)

macro @@inv.quo.sse
{
$usprocf @@inv.quo

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xmovsd  xmm1, ??.1.0                    ; xmm1 = 1
        divsd   xmm1, xmm0                      ; xmm1 = 1/x
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .return:
        retn
$endp
}

macro @@inv.quo.fpu
{
$usprocf @@inv.quo

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        fdivrp
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@inv.quo.sse
$else
; @@inv.quo.fpu
$end

; ------------------------------------------------------------------------------

; quo inversion
; \x = 1\x

macro @@_inv.quo_int.sse
{
$usprocf @@_inv.quo_int

        mov     eax, 1
        cdq
        idiv    dword [esp]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_inv.quo_int.fpu
{
$usprocf @@_inv.quo_int

        mov     eax, 1
        cdq
        idiv    dword [esp]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_inv.quo_int.sse
$else
; @@_inv.quo_int.fpu
$end

; ------------------------------------------------------------------------------

; mod inversion
; %x = 1%x = 1 - x * int(1/x)

macro @@inv.mod.sse
{
$usprocf @@inv.mod

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        xmovsd  xmm1, ??.1.0
        divsd   xmm1, xmm0
        xintsd  xmm1, xmm1                      ; xmm1 = int(1/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(1/x)
        xmovsd  xmm0, ??.1.0
        subsd   xmm0, xmm1                      ; xmm0 = 1 - x*int(1/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@inv.mod.fpu
{
$usprocf @@inv.mod

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld1                                    ; st0 = 1       | st1 = x
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
; @@inv.mod.sse
$else
; @@inv.mod.fpu
$end

; ------------------------------------------------------------------------------

; mod inversion
; %x = 1%x

macro @@_inv.mod_int.sse
{
$usprocf @@_inv.mod_int

        mov     eax, 1
        cdq
        idiv    dword [esp]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_inv.mod_int.fpu
{
$usprocf @@_inv.mod_int

        mov     eax, 1
        cdq
        idiv    dword [esp]
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_inv.mod_int.sse
$else
; @@_inv.mod_int.fpu
$end

; ------------------------------------------------------------------------------

; increment by 1

macro @@inc.sse
{
$usprocf @@inc

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xaddsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@inc.fpu
{
$usprocf @@inc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@inc.sse
$else
  @@inc.fpu
$end

; ------------------------------------------------------------------------------

; increment by 1

macro @@_inc_int.sse
{
$usprocf @@_inc_int

        mov     eax, [esp]
    .enter:
        inc     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_inc_int.fpu
{
$usprocf @@_inc_int

        mov     eax, [esp]
    .enter:
        inc     eax
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_inc_int.sse
$else
; @@_inc_int.fpu
$end

; ------------------------------------------------------------------------------

; increment by 1
; x = eax

macro @@_inc_reg.sse
{
$usprocf @@_inc_reg

    .enter:
        inc     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_inc_reg.fpu
{
$usprocf @@_inc_reg

    .enter:
        inc     eax
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_inc_reg.sse
$else
  @@_inc_reg.fpu
$end

; ------------------------------------------------------------------------------

; ++x
; prefix increment by 1
; copy inc(dst) to dst
; return new value of dst
;
; ecx = dst offset

macro @@inc.pre.sse
{
$usprocf @@inc.pre

        movsd   xmm0, qword [ecx]
    .enter:
        xaddsd  xmm0, ??.1.0
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro @@inc.pre.fpu
{
$usprocf @@inc.pre

        fld     qword [ecx]
    .enter:
        fld1
        faddp
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@inc.pre.sse
$else
  @@inc.pre.fpu
$end

; ------------------------------------------------------------------------------

; ++x
; prefix increment by 1
; copy inc(dst) to dst
; return new value of dst
;
; ecx = dst offset

macro @@_inc.pre_int.sse
{
$usprocf @@_inc.pre_int

        inc     dword [ecx]
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_inc.pre_int.fpu
{
$usprocf @@_inc.pre_int

        inc     dword [ecx]
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_inc.pre_int.sse
$else
  @@_inc.pre_int.fpu
$end

; ------------------------------------------------------------------------------

; x++
; postfix increment by 1
; copy inc(dst) to dst
; return old value of dst
;
; ecx = dst offset

macro @@inc.post.sse
{
$usprocf @@inc.post

        movsd   xmm0, qword [ecx]
    .enter:
        xmovsd  xmm1, ??.1.0
        addsd   xmm1, xmm0
        movsd   qword [ecx], xmm1
    .return:
        retn
$endp
}

macro @@inc.post.fpu
{
$usprocf @@inc.post

        fld     qword [ecx]
    .enter:
        fld     st0
        fld1
        faddp
        fstp    qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@inc.post.sse
$else
  @@inc.post.fpu
$end

; ------------------------------------------------------------------------------

; x++
; postfix increment by 1
; copy inc(dst) to dst
; return old value of dst
;
; ecx = dst offset

macro @@_inc.post_int.sse
{
$usprocf @@_inc.post_int

       cvtsi2sd xmm0, dword [ecx]
        inc     dword [ecx]
    .return:
        retn
$endp
}

macro @@_inc.post_int.fpu
{
$usprocf @@_inc.post_int

        fild    dword [ecx]
        inc     dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_inc.post_int.sse
$else
  @@_inc.post_int.fpu
$end

; ------------------------------------------------------------------------------

; decrement by 1

macro @@dec.sse
{
$usprocf @@dec

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xsubsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@dec.fpu
{
$usprocf @@dec

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld1
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@dec.sse
$else
  @@dec.fpu
$end

; ------------------------------------------------------------------------------

; decrement by 1

macro @@_dec_int.sse
{
$usprocf @@_dec_int

        mov     eax, [esp]
    .enter:
        dec     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_dec_int.fpu
{
$usprocf @@_dec_int

        mov     eax, [esp]
    .enter:
        dec     eax
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
; @@_dec_int.sse
$else
; @@_dec_int.fpu
$end

; ------------------------------------------------------------------------------

; decrement by 1
; x = eax

macro @@_dec_reg.sse
{
$usprocf @@_dec_reg

    .enter:
        dec     eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_dec_reg.fpu
{
$usprocf @@_dec_reg

    .enter:
        dec     eax
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dec_reg.sse
$else
  @@_dec_reg.fpu
$end

; ------------------------------------------------------------------------------

; --x
; prefix decrement by 1
; copy dec(dst) to dst
; return new value of dst
;
; ecx = dst offset

macro  @@dec.pre.sse
{
$usprocf @@dec.pre

        movsd   xmm0, qword [ecx]
    .enter:
        xsubsd  xmm0, ??.1.0
        movsd   qword [ecx], xmm0
    .return:
        retn
$endp
}

macro  @@dec.pre.fpu
{
$usprocf @@dec.pre

        fld     qword [ecx]
    .enter:
        fld1
        fsubp
        fst     qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@dec.pre.sse
$else
  @@dec.pre.fpu
$end

; ------------------------------------------------------------------------------

; --x
; prefix decrement by 1
; copy dec(dst) to dst
; return new value of dst
;
; ecx = dst offset

macro @@_dec.pre_int.sse
{
$usprocf @@_dec.pre_int

        dec     dword [ecx]
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_dec.pre_int.fpu
{
$usprocf @@_dec.pre_int

        dec     dword [ecx]
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dec.pre_int.sse
$else
  @@_dec.pre_int.fpu
$end

; ------------------------------------------------------------------------------

; x--
; postfix decrement by 1
; copy dec(dst) to dst
; return old value of dst
;
; ecx = dst offset

macro @@dec.post.sse
{
$usprocf @@dec.post

        movsd   xmm0, qword [ecx]
    .enter:
        movsd   xmm1, xmm0
        xsubsd  xmm1, ??.1.0
        movsd   qword [ecx], xmm1
    .return:
        retn
$endp
}

macro @@dec.post.fpu
{
$usprocf @@dec.post

        fld     qword [ecx]
    .enter:
        fld     st0
        fld1
        fsubp
        fstp    qword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@dec.post.sse
$else
  @@dec.post.fpu
$end

; ------------------------------------------------------------------------------

; x--
; postfix decrement by 1
; copy dec(dst) to dst
; return old value of dst
;
; ecx = dst offset

macro @@_dec.post_int.sse
{
$usprocf @@_dec.post_int

       cvtsi2sd xmm0, dword [ecx]
        dec     dword [ecx]
    .return:
        retn
$endp
}

macro @@_dec.post_int.fpu
{
$usprocf @@_dec.post_int

        fild    dword [ecx]
        dec     dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_dec.post_int.sse
$else
  @@_dec.post_int.fpu
$end

; ------------------------------------------------------------------------------

; addition

macro @@add.sse
{
$usprocf @@add

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        addsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .return:
        retn
$endp
}

macro @@add.fpu
{
$usprocf @@add

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.sse
$else
  @@add.fpu
$end

; ------------------------------------------------------------------------------

; addition

macro @@_add_int.sse
{
$usprocf @@_add_int

        mov     eax, [esp]
        add     eax, [esp + 4]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_add_int.fpu
{
$usprocf @@_add_int

        mov     eax, [esp]
        add     eax, [esp + 4]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_add_int.sse
$else
  @@_add_int.fpu
$end

; ------------------------------------------------------------------------------

; addition
; x = eax
; y = ecx

macro @@_add_reg.sse
{
$usprocf @@_add_reg

        add     eax, ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_add_reg.fpu
{
$usprocf @@_add_reg

        add     eax, ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_add_reg.sse
$else
  @@_add_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst + src) to dst
; co.add ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.add.sse
{
$usprocf @@co.add

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        addsd   xmm0, qword [ecx]               ; xmm0 = dst + src
    .copy:
        movsd   qword [ecx], xmm0               ; dst = dst + src
    .return:
        retn
$endp
}

macro @@co.add.fpu
{
$usprocf @@co.add

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fadd    qword [ecx]                     ; st0 = dst + src
    .copy:
        fst     qword [ecx]                     ; dst = dst + src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.add.sse
$else
  @@co.add.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst + src) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.add.sse
{
$usprocf @@_co.int.add

        add     [ecx], eax                      ; dst = dst + src
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.add.fpu
{
$usprocf @@_co.int.add

        add     [ecx], eax                      ; dst = dst + src
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.add.sse
$else
  @@_co.int.add.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst + 1) to dst
; dst offset = ecx

macro @@_co.int.add.1.sse
{
$usprocf @@_co.int.add.1

        inc     dword [ecx]                     ; dst = dst + 1
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.add.1.fpu
{
$usprocf @@_co.int.add.1

        inc     dword [ecx]                     ; dst = dst + 1
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.add.1.sse
$else
  @@_co.int.add.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst + -1) to dst
; dst offset = ecx

macro @@_co.int.add.m1.sse
{
$usprocf @@_co.int.add.m1

        dec     dword [ecx]                     ; dst = dst - 1
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.add.m1.fpu
{
$usprocf @@_co.int.add.m1

        dec     dword [ecx]                     ; dst = dst - 1
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.add.m1.sse
$else
  @@_co.int.add.m1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst + src) to dst
; co.add ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

$usprocf @@co.str.add

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy (dst + src) to dst
; dst offset = rcx
; src value  = rax

$usprocf @@_co.int.str.add

        add     [ecx], eax                      ; dst = dst + src
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy (dst + 1) to dst
; dst offset = rcx

$usprocf @@_co.int.str.add.1

        inc     dword [ecx]                     ; dst = dst + 1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy (dst + -1) to dst
; dst offset = rcx

$usprocf @@_co.int.str.add.m1

        dec     dword [ecx]                     ; dst = dst - 1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; positive addition
; double add.pos ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x+y, x+y > 0
;            0, otherwise

macro @@add.pos.sse
{
$usprocf @@add.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        addsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@add.pos.fpu
{
$usprocf @@add.pos

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        faddp
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.pos.sse
$else
  @@add.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive addition
; double add.pos ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x+y, x+y > 0
;            0, otherwise

macro @@_add.pos_int.sse
{
$usprocf @@_add.pos_int

        mov     eax, [esp]
        add     eax, [esp + 4]
;       cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_add.pos_int.fpu
{
$usprocf @@_add.pos_int

        mov     eax, [esp]
        add     eax, [esp + 4]
;       cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_add.pos_int.sse
$else
  @@_add.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive addition
; double add.pos ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x+y, x+y > 0
;            0, otherwise

macro @@_add.pos_reg.sse
{
$usprocf @@_add.pos_reg

        add     eax, ecx
;       cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_add.pos_reg.fpu
{
$usprocf @@_add.pos_reg

        add     eax, ecx
;       cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_add.pos_reg.sse
$else
  @@_add.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative addition
; double add.neg ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x+y, x+y < 0
;            0, otherwise

macro @@add.neg.sse
{
$usprocf @@add.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        addsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@add.neg.fpu
{
$usprocf @@add.neg

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        faddp
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.neg.sse
$else
  @@add.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative addition
; double add.neg ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x+y, x+y < 0
;            0, otherwise

macro @@_add.neg_int.sse
{
$usprocf @@_add.neg_int

        mov     eax, [esp]
        add     eax, [esp + 4]
;       cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_add.neg_int.fpu
{
$usprocf @@_add.neg_int

        mov     eax, [esp]
        add     eax, [esp + 4]
;       cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_add.neg_int.sse
$else
  @@_add.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative addition
; double add.neg ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x+y, x+y < 0
;            0, otherwise

macro @@_add.neg_reg.sse
{
$usprocf @@_add.neg_reg

        add     eax, ecx
;       cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_add.neg_reg.fpu
{
$usprocf @@_add.neg_reg

        add     eax, ecx
;       cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_add.neg_reg.sse
$else
  @@_add.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; int addition
; double add.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(x) + int(y)

macro @@add.int.sse
{
$usprocf @@add.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        addsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@add.int.fpu
{
$usprocf @@add.int

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.int.sse
$else
  @@add.int.fpu
$end

; ------------------------------------------------------------------------------

; frac addition
; double add.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(x) + frac(y)

macro @@add.frac.sse
{
$usprocf @@add.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        addsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@add.frac.fpu
{
$usprocf @@add.frac

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.frac.sse
$else
  @@add.frac.fpu
$end

; ------------------------------------------------------------------------------

; round addition
; double add.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(x) + round(y)

macro @@add.round.sse
{
$usprocf @@add.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        addsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@add.round.fpu
{
$usprocf @@add.round

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        faddp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@add.round.sse
$else
  @@add.round.fpu
$end

; ------------------------------------------------------------------------------

; subtraction

macro @@sub.sse
{
$usprocf @@sub

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .return:
        retn
$endp
}

macro @@sub.fpu
{
$usprocf @@sub

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.sse
$else
  @@sub.fpu
$end

; ------------------------------------------------------------------------------

; subtraction

macro @@_sub_int.sse
{
$usprocf @@_sub_int

        mov     eax, [esp]
        sub     eax, [esp + 4]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_sub_int.fpu
{
$usprocf @@_sub_int

        mov     eax, [esp]
        sub     eax, [esp + 4]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sub_int.sse
$else
  @@_sub_int.fpu
$end

; ------------------------------------------------------------------------------

; subtraction
; x = eax
; y = ecx

macro @@_sub_reg.sse
{
$usprocf @@_sub_reg

        sub     eax, ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_sub_reg.fpu
{
$usprocf @@_sub_reg

        sub     eax, ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sub_reg.sse
$else
  @@_sub_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst - src) to dst
; co.sub ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.sub.sse
{
$usprocf @@co.sub

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst
        subsd   xmm1, xmm0                      ; xmm1 = dst - src
        movsd   xmm0, xmm1                      ; xmm0 = dst - src
    .copy:
        movsd   qword [ecx], xmm0               ; dst = dst - src
    .return:
        retn
$endp
}

macro @@co.sub.fpu
{
$usprocf @@co.sub

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsubr   qword [ecx]                     ; st0 = dst - src
    .copy:
        fst     qword [ecx]                     ; dst = dst - src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.sub.sse
$else
  @@co.sub.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst - src) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.sub.sse
{
$usprocf @@_co.int.sub

        sub     [ecx], eax                      ; dst = dst - src
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.sub.fpu
{
$usprocf @@_co.int.sub

        sub     [ecx], eax                      ; dst = dst - src
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.sub.sse
$else
  @@_co.int.sub.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst - 1) to dst
; dst offset = ecx

macro @@_co.int.sub.1.sse
{
$usprocf @@_co.int.sub.1

        dec     dword [ecx]                     ; dst = dst - 1
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.sub.1.fpu
{
$usprocf @@_co.int.sub.1

        dec     dword [ecx]                     ; dst = dst - 1
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.sub.1.sse
$else
  @@_co.int.sub.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst - -1) to dst
; dst offset = ecx

macro @@_co.int.sub.m1.sse
{
$usprocf @@_co.int.sub.m1

        inc     dword [ecx]                     ; dst = dst + 1
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.sub.m1.fpu
{
$usprocf @@_co.int.sub.m1

        inc     dword [ecx]                     ; dst = dst + 1
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.sub.m1.sse
$else
  @@_co.int.sub.m1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst - src) to dst
; co.sub ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

$usprocf @@co.str.sub

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy (dst - src) to dst
; dst offset = ecx
; src value  = eax

$usprocf @@_co.int.str.sub

        sub     [ecx], eax                      ; dst = dst - src
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy (dst - 1) to dst
; dst offset = ecx

$usprocf @@_co.int.str.sub.1

        dec     dword [ecx]                     ; dst = dst - 1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy (dst - -1) to dst
; dst offset = ecx

$usprocf @@_co.int.str.sub.m1

        inc     dword [ecx]                     ; dst = dst + 1
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; positive subtraction
; double sub.pos ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x-y, x-y > 0
;            0, otherwise

macro @@sub.pos.sse
{
$usprocf @@sub.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@sub.pos.fpu
{
$usprocf @@sub.pos

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fsubp
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.pos.sse
$else
  @@sub.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive subtraction
; double sub.pos ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x-y, x-y > 0
;            0, otherwise

macro @@_sub.pos_int.sse
{
$usprocf @@_sub.pos_int

        mov     eax, [esp]
        sub     eax, [esp + 4]
;       cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_sub.pos_int.fpu
{
$usprocf @@_sub.pos_int

        mov     eax, [esp]
        sub     eax, [esp + 4]
;       cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sub.pos_int.sse
$else
  @@_sub.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive subtraction
; double sub.pos ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x-y, x-y > 0
;            0, otherwise

macro @@_sub.pos_reg.sse
{
$usprocf @@_sub.pos_reg

        sub     eax, ecx
;       cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_sub.pos_reg.fpu
{
$usprocf @@_sub.pos_reg

        sub     eax, ecx
;       cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sub.pos_reg.sse
$else
  @@_sub.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative subtraction
; double sub.neg ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x-y, x-y < 0
;            0, otherwise

macro @@sub.neg.sse
{
$usprocf @@sub.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@sub.neg.fpu
{
$usprocf @@sub.neg

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fsubp
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.neg.sse
$else
  @@sub.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative subtraction
; double sub.neg ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x-y, x-y < 0
;            0, otherwise

macro @@_sub.neg_int.sse
{
$usprocf @@_sub.neg_int

        mov     eax, [esp]
        sub     eax, [esp + 4]
;       cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_sub.neg_int.fpu
{
$usprocf @@_sub.neg_int

        mov     eax, [esp]
        sub     eax, [esp + 4]
;       cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sub.neg_int.sse
$else
  @@_sub.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative subtraction
; double sub.neg ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x-y, x-y < 0
;            0, otherwise

macro @@_sub.neg_reg.sse
{
$usprocf @@_sub.neg_reg

        sub     eax, ecx
;       cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_sub.neg_reg.fpu
{
$usprocf @@_sub.neg_reg

        sub     eax, ecx
;       cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_sub.neg_reg.sse
$else
  @@_sub.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; int subtraction
; double sub.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(x) - int(y)

macro @@sub.int.sse
{
$usprocf @@sub.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@sub.int.fpu
{
$usprocf @@sub.int

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        fsubrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.int.sse
$else
  @@sub.int.fpu
$end

; ------------------------------------------------------------------------------

; frac subtraction
; double sub.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(x) - frac(y)

macro @@sub.frac.sse
{
$usprocf @@sub.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@sub.frac.fpu
{
$usprocf @@sub.frac

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        fsubrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.frac.sse
$else
  @@sub.frac.fpu
$end

; ------------------------------------------------------------------------------

; round subtraction
; double sub.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(x) - round(y)

macro @@sub.round.sse
{
$usprocf @@sub.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@sub.round.fpu
{
$usprocf @@sub.round

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        fsubrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@sub.round.sse
$else
  @@sub.round.fpu
$end

; ------------------------------------------------------------------------------

; reverse subtraction

macro @@subr.sse
{
$usprocf @@subr

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@subr.fpu
{
$usprocf @@subr

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fsubrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.sse
$else
  @@subr.fpu
$end

; ------------------------------------------------------------------------------

; reverse subtraction

macro @@_subr_int.sse
{
$usprocf @@_subr_int

        mov     eax, [esp + 4]
        sub     eax, [esp]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_subr_int.fpu
{
$usprocf @@_subr_int

        mov     eax, [esp + 4]
        sub     eax, [esp]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_subr_int.sse
$else
  @@_subr_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse subtraction
; x = eax
; y = ecx

macro @@_subr_reg.sse
{
$usprocf @@_subr_reg

        sub     ecx, eax
    .load:
       cvtsi2sd xmm0, ecx
    .return:
        retn
$endp
}

macro @@_subr_reg.fpu
{
$usprocf @@_subr_reg

        sub     ecx, eax
    .load:
        mov     [esp - 4], ecx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_subr_reg.sse
$else
  @@_subr_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (src - dst) to dst
; co.subr ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.subr.sse
{
$usprocf @@co.subr

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm0, qword [ecx]               ; xmm0 = src - dst
    .copy:
        movsd   qword [ecx], xmm0               ; dst = src - dst
    .return:
        retn
$endp
}

macro @@co.subr.fpu
{
$usprocf @@co.subr

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fsub    qword [ecx]                     ; st0 = src - dst
    .copy:
        fst     qword [ecx]                     ; dst = src - dst
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.subr.sse
$else
  @@co.subr.fpu
$end

; ------------------------------------------------------------------------------

; copy (src - dst) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.subr.sse
{
$usprocf @@_co.int.subr

        sub     [ecx], eax                      ; dst = dst - src
        neg     dword [ecx]                     ; dst = src - dst
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.subr.fpu
{
$usprocf @@_co.int.subr

        sub     [ecx], eax                      ; dst = dst - src
        neg     dword [ecx]                     ; dst = src - dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.subr.sse
$else
  @@_co.int.subr.fpu
$end

; ------------------------------------------------------------------------------

; copy (1 - dst) to dst
; dst offset = ecx

macro @@_co.int.subr.1.sse
{
$usprocf @@_co.int.subr.1

        dec     dword [ecx]                     ; dst = dst - 1
        neg     dword [ecx]                     ; dst = 1 - dst
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.subr.1.fpu
{
$usprocf @@_co.int.subr.1

        dec     dword [ecx]                     ; dst = dst - 1
        neg     dword [ecx]                     ; dst = 1 - dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.subr.1.sse
$else
  @@_co.int.subr.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (-1 - dst) to dst
; dst offset = ecx

macro @@_co.int.subr.m1.sse
{
$usprocf @@_co.int.subr.m1

        inc     dword [ecx]                     ; dst = 1 + dst
        neg     dword [ecx]                     ; dst = -(1 + dst)
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.subr.m1.fpu
{
$usprocf @@_co.int.subr.m1

        inc     dword [ecx]                     ; dst = 1 + dst
        neg     dword [ecx]                     ; dst = -(1 + dst)
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.subr.m1.sse
$else
  @@_co.int.subr.m1.fpu
$end

; ------------------------------------------------------------------------------

; copy (src - dst) to dst
; co.subr ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

$usprocf @@co.str.subr

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; copy (src - dst) to dst
; dst offset = ecx
; src value  = eax

$usprocf @@_co.int.str.subr

        sub     [ecx], eax                      ; dst = dst - src
        neg     dword [ecx]                     ; dst = src - dst
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy (1 - dst) to dst
; dst offset = ecx

$usprocf @@_co.int.str.subr.1

        dec     dword [ecx]                     ; dst = dst - 1
        neg     dword [ecx]                     ; dst = 1 - dst
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; copy (-1 - dst) to dst
; dst offset = ecx

$usprocf @@_co.int.str.subr.m1

        inc     dword [ecx]                     ; dst = 1 + dst
        neg     dword [ecx]                     ; dst = -(1 + dst)
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; reverse positive subtraction
; double subr.pos ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y-x, y-x > 0
;            0, otherwise

macro @@subr.pos.sse
{
$usprocf @@subr.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@subr.pos.fpu
{
$usprocf @@subr.pos

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fsubrp
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.pos.sse
$else
  @@subr.pos.fpu
$end

; ------------------------------------------------------------------------------

; reverse positive subtraction
; double subr.pos ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y-x, y-x > 0
;            0, otherwise

macro @@_subr.pos_int.sse
{
$usprocf @@_subr.pos_int

        mov     eax, [esp + 4]
        sub     eax, [esp]
;       cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_subr.pos_int.fpu
{
$usprocf @@_subr.pos_int

        mov     eax, [esp + 4]
        sub     eax, [esp]
;       cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_subr.pos_int.sse
$else
  @@_subr.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse positive subtraction
; double subr.pos ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y-x, y-x > 0
;            0, otherwise

macro @@_subr.pos_reg.sse
{
$usprocf @@_subr.pos_reg

        sub     ecx, eax
;       cmp     ecx, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, ecx
    .return:
        retn
$endp
}

macro @@_subr.pos_reg.fpu
{
$usprocf @@_subr.pos_reg

        sub     ecx, eax
;       cmp     ecx, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], ecx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_subr.pos_reg.sse
$else
  @@_subr.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; reverse negative subtraction
; double subr.neg ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y-x, y-x < 0
;            0, otherwise

macro @@subr.neg.sse
{
$usprocf @@subr.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@subr.neg.fpu
{
$usprocf @@subr.neg

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fsubrp
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.neg.sse
$else
  @@subr.neg.fpu
$end

; ------------------------------------------------------------------------------

; reverse negative subtraction
; double subr.neg ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y-x, y-x < 0
;            0, otherwise

macro @@_subr.neg_int.sse
{
$usprocf @@_subr.neg_int

        mov     eax, [esp + 4]
        sub     eax, [esp]
;       cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_subr.neg_int.fpu
{
$usprocf @@_subr.neg_int

        mov     eax, [esp + 4]
        sub     eax, [esp]
;       cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_subr.neg_int.sse
$else
  @@_subr.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse negative subtraction
; double subr.neg ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y-x, y-x < 0
;            0, otherwise

macro @@_subr.neg_reg.sse
{
$usprocf @@_subr.neg_reg

        sub     ecx, eax
;       cmp     ecx, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, ecx
    .return:
        retn
$endp
}

macro @@_subr.neg_reg.fpu
{
$usprocf @@_subr.neg_reg

        sub     ecx, eax
;       cmp     ecx, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], ecx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_subr.neg_reg.sse
$else
  @@_subr.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; reverse int subtraction
; double subr.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(y) - int(x)

macro @@subr.int.sse
{
$usprocf @@subr.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@subr.int.fpu
{
$usprocf @@subr.int

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.int.sse
$else
  @@subr.int.fpu
$end

; ------------------------------------------------------------------------------

; reverse frac subtraction
; double subr.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(y) - frac(x)

macro @@subr.frac.sse
{
$usprocf @@subr.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@subr.frac.fpu
{
$usprocf @@subr.frac

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.frac.sse
$else
  @@subr.frac.fpu
$end

; ------------------------------------------------------------------------------

; reverse round subtraction
; double subr.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(y) - round(x)

macro @@subr.round.sse
{
$usprocf @@subr.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        subsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@subr.round.fpu
{
$usprocf @@subr.round

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@subr.round.sse
$else
  @@subr.round.fpu
$end

; ------------------------------------------------------------------------------

; multiplication

macro @@mul.sse
{
$usprocf @@mul

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mulsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .return:
        retn
$endp
}

macro @@mul.fpu
{
$usprocf @@mul

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.sse
$else
  @@mul.fpu
$end

; ------------------------------------------------------------------------------

; multiplication

macro @@_mul_int.sse
{
$usprocf @@_mul_int

        mov     eax, [esp]
        imul    dword [esp + 4]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_mul_int.fpu
{
$usprocf @@_mul_int

        mov     eax, [esp]
        imul    dword [esp + 4]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul_int.sse
$else
  @@_mul_int.fpu
$end

; ------------------------------------------------------------------------------

; multiplication
; x = eax
; y = ecx

macro @@_mul_reg.sse
{
$usprocf @@_mul_reg

        imul    eax
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_mul_reg.fpu
{
$usprocf @@_mul_reg

        imul    eax
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul_reg.sse
$else
  @@_mul_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst * src) to dst
; co.mul ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.mul.sse
{
$usprocf @@co.mul

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mulsd   xmm0, qword [ecx]               ; xmm0 = dst * src
    .copy:
        movsd   qword [ecx], xmm0               ; dst = dst * src
    .return:
        retn
$endp
}

macro @@co.mul.fpu
{
$usprocf @@co.mul

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fmul    qword [ecx]                     ; st0 = dst * src
    .copy:
        fst     qword [ecx]                     ; dst = dst * src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.mul.sse
$else
  @@co.mul.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst * src) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.mul.sse
{
$usprocf @@_co.int.mul

        imul    dword [ecx]                     ; eax = dst * src
        mov     [ecx], eax                      ; dst = dst * src
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.mul.fpu
{
$usprocf @@_co.int.mul

        imul    dword [ecx]                     ; eax = dst * src
        mov     [ecx], eax                      ; dst = dst * src
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.mul.sse
$else
  @@_co.int.mul.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst * 1) to dst
; dst offset = ecx

macro @@_co.int.mul.1.sse
{
$usprocf @@_co.int.mul.1

       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.mul.1.fpu
{
$usprocf @@_co.int.mul.1

        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.mul.1.sse
$else
  @@_co.int.mul.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst * -1) to dst
; dst offset = ecx

macro @@_co.int.mul.m1.sse
{
$usprocf @@_co.int.mul.m1

        neg     dword [ecx]                     ; dst = -dst
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.mul.m1.fpu
{
$usprocf @@_co.int.mul.m1

        neg     dword [ecx]                     ; dst = -dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.mul.m1.sse
$else
  @@_co.int.mul.m1.fpu
$end

; ------------------------------------------------------------------------------

; positive multiplication
; double mul.pos ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x*y, x*y > 0
;            0, otherwise

macro @@mul.pos.sse
{
$usprocf @@mul.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mulsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@mul.pos.fpu
{
$usprocf @@mul.pos

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fmulp
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.pos.sse
$else
  @@mul.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive multiplication
; double mul.pos ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x*y, x*y > 0
;            0, otherwise

macro @@_mul.pos_int.sse
{
$usprocf @@_mul.pos_int

        mov     eax, [esp]
        imul    dword [esp + 4]
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_mul.pos_int.fpu
{
$usprocf @@_mul.pos_int

        mov     eax, [esp]
        imul    dword [esp + 4]
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.pos_int.sse
$else
  @@_mul.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive multiplication
; double mul.pos ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x*y, x*y > 0
;            0, otherwise

macro @@_mul.pos_reg.sse
{
$usprocf @@_mul.pos_reg

        imul    ecx
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_mul.pos_reg.fpu
{
$usprocf @@_mul.pos_reg

        imul    ecx
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.pos_reg.sse
$else
  @@_mul.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative multiplication
; double mul.neg ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x*y, x*y < 0
;            0, otherwise

macro @@mul.neg.sse
{
$usprocf @@mul.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mulsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@mul.neg.fpu
{
$usprocf @@mul.neg

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fmulp
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.neg.sse
$else
  @@mul.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative multiplication
; double mul.neg ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x*y, x*y < 0
;            0, otherwise

macro @@_mul.neg_int.sse
{
$usprocf @@_mul.neg_int

        mov     eax, [esp]
        imul    dword [esp + 4]
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_mul.neg_int.fpu
{
$usprocf @@_mul.neg_int

        mov     eax, [esp]
        imul    dword [esp + 4]
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.neg_int.sse
$else
  @@_mul.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative multiplication
; double mul.neg ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x*y, x*y < 0
;            0, otherwise

macro @@_mul.neg_reg.sse
{
$usprocf @@_mul.neg_reg

        imul    ecx
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_mul.neg_reg.fpu
{
$usprocf @@_mul.neg_reg

        imul    ecx
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mul.neg_reg.sse
$else
  @@_mul.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; int multiplication
; double mul.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(x) * int(y)

macro @@mul.int.sse
{
$usprocf @@mul.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        mulsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@mul.int.fpu
{
$usprocf @@mul.int

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.int.sse
$else
  @@mul.int.fpu
$end

; ------------------------------------------------------------------------------

; frac multiplication
; double mul.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(x) * frac(y)

macro @@mul.frac.sse
{
$usprocf @@mul.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        mulsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@mul.frac.fpu
{
$usprocf @@mul.frac

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.frac.sse
$else
  @@mul.frac.fpu
$end

; ------------------------------------------------------------------------------

; round multiplication
; double mul.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(x) * round(y)

macro @@mul.round.sse
{
$usprocf @@mul.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        mulsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@mul.round.fpu
{
$usprocf @@mul.round

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        fmulp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@mul.round.sse
$else
  @@mul.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; division

macro @@div.sse
{
$usprocf @@div

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .return:
        retn
$endp
}

macro @@div.fpu
{
$usprocf @@div

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.sse
$else
  @@div.fpu
$end

; ------------------------------------------------------------------------------

; division

macro @@_div_int.sse
{
$usprocf @@_div_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_div_int.fpu
{
$usprocf @@_div_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div_int.sse
$else
  @@_div_int.fpu
$end

; ------------------------------------------------------------------------------

; division
; x = eax
; y = ecx

macro @@_div_reg.sse
{
$usprocf @@_div_reg

        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_div_reg.fpu
{
$usprocf @@_div_reg

        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div_reg.sse
$else
  @@_div_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst / src) to dst
; co.div ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.div.sse
{
$usprocf @@co.div

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; dst / +0
        xmovsd  xmm0, ??.PInf
        jmp    .copy
    .NZero:                                     ; dst / -0
        xmovsd  xmm0, ??.NInf
        jmp    .copy

    .main:
        divsd   xmm1, xmm0                      ; xmm1 = dst / src
        movsd   xmm0, xmm1                      ; xmm0 = dst / src
    .copy:
        movsd   qword [ecx], xmm0               ; dst = dst / src
    .return:
        retn
$endp
}

macro @@co.div.fpu
{
$usprocf @@co.div

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fdivr   qword [ecx]                     ; st0 = dst / src
    .copy:
        fst     qword [ecx]                     ; dst = dst / src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.div.sse
$else
  @@co.div.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst / src) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.div.sse
{
$usprocf @@_co.int.div

        mov     edx, eax
        mov     eax, [ecx]                      ; eax = dst
        mov     [ecx], edx                      ; [ecx] = src
        cdq
        idiv    dword [ecx]                     ; eax = dst / src
        mov     [ecx], eax                      ; dst = dst / src
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.div.fpu
{
$usprocf @@_co.int.div

        mov     edx, eax
        mov     eax, [ecx]                      ; eax = dst
        mov     [ecx], edx                      ; [ecx] = src
        cdq
        idiv    dword [ecx]                     ; eax = dst / src
        mov     [ecx], eax                      ; dst = dst / src
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.div.sse
$else
  @@_co.int.div.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst / 1) to dst
; dst offset = ecx

macro @@_co.int.div.1.sse
{
$usprocf @@_co.int.div.1

       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.div.1.fpu
{
$usprocf @@_co.int.div.1

        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.div.1.sse
$else
  @@_co.int.div.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst / -1) to dst
; dst offset = ecx

macro @@_co.int.div.m1.sse
{
$usprocf @@_co.int.div.m1

        neg     dword [ecx]                     ; dst = -dst
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.div.m1.fpu
{
$usprocf @@_co.int.div.m1

        neg     dword [ecx]                     ; dst = -dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.div.m1.sse
$else
  @@_co.int.div.m1.fpu
$end

; ------------------------------------------------------------------------------

; positive division
; double div.pos ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x/y, x/y > 0
;            0, otherwise

macro @@div.pos.sse
{
$usprocf @@div.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xorpd   xmm0, xmm0
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@div.pos.fpu
{
$usprocf @@div.pos

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fdivp
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.pos.sse
$else
  @@div.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive division
; double div.pos ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x/y, x/y > 0
;            0, otherwise

macro @@_div.pos_int.sse
{
$usprocf @@_div.pos_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_div.pos_int.fpu
{
$usprocf @@_div.pos_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.pos_int.sse
$else
  @@_div.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive division
; double div.pos ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x/y, x/y > 0
;            0, otherwise

macro @@_div.pos_reg.sse
{
$usprocf @@_div.pos_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_div.pos_reg.fpu
{
$usprocf @@_div.pos_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.pos_reg.sse
$else
  @@_div.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative division
; double div.neg ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x/y, x/y < 0
;            0, otherwise

macro @@div.neg.sse
{
$usprocf @@div.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xorpd   xmm0, xmm0
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@div.neg.fpu
{
$usprocf @@div.neg

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fdivp
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.neg.sse
$else
  @@div.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative division
; double div.neg ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x/y, x/y < 0
;            0, otherwise

macro @@_div.neg_int.sse
{
$usprocf @@_div.neg_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_div.neg_int.fpu
{
$usprocf @@_div.neg_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.neg_int.sse
$else
  @@_div.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative division
; double div.neg ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x/y, x/y < 0
;            0, otherwise

macro @@_div.neg_reg.sse
{
$usprocf @@_div.neg_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_div.neg_reg.fpu
{
$usprocf @@_div.neg_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_div.neg_reg.sse
$else
  @@_div.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; int division
; double div.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(x) / int(y)

macro @@div.int.sse
{
$usprocf @@div.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@div.int.fpu
{
$usprocf @@div.int

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.int.sse
$else
  @@div.int.fpu
$end

; ------------------------------------------------------------------------------

; frac division
; double div.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(x) / frac(y)

macro @@div.frac.sse
{
$usprocf @@div.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@div.frac.fpu
{
$usprocf @@div.frac

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.frac.sse
$else
  @@div.frac.fpu
$end

; ------------------------------------------------------------------------------

; round division
; double div.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(x) / round(y)

macro @@div.round.sse
{
$usprocf @@div.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@div.round.fpu
{
$usprocf @@div.round

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@div.round.sse
$else
  @@div.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reverse division

macro @@divr.sse
{
$usprocf @@divr

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@divr.fpu
{
$usprocf @@divr

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fdivrp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.sse
$else
  @@divr.fpu
$end

; ------------------------------------------------------------------------------

; reverse division

macro @@_divr_int.sse
{
$usprocf @@_divr_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_divr_int.fpu
{
$usprocf @@_divr_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_divr_int.sse
$else
  @@_divr_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse division
; x = eax
; y = ecx

macro @@_divr_reg.sse
{
$usprocf @@_divr_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_divr_reg.fpu
{
$usprocf @@_divr_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_divr_reg.sse
$else
  @@_divr_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (src / dst) to dst
; co.divr ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.divr.sse
{
$usprocf @@co.divr

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; src / +0
        xmovsd  xmm0, ??.PInf
        jmp    .copy
    .NZero:                                     ; src / -0
        xmovsd  xmm0, ??.NInf
        jmp    .copy

    .main:
        divsd   xmm0, xmm1                      ; xmm0 = src / dst
    .copy:
        movsd   qword [ecx], xmm0               ; dst = src / dst
    .return:
        retn
$endp
}

macro @@co.divr.fpu
{
$usprocf @@co.divr

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fdiv    qword [ecx]                     ; st0 = src / dst
    .copy:
        fst     qword [ecx]                     ; dst = src / dst
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.divr.sse
$else
  @@co.divr.fpu
$end

; ------------------------------------------------------------------------------

; copy (src / dst) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.divr.sse
{
$usprocf @@_co.int.divr

        cdq
        idiv    dword [ecx]                     ; eax = src / dst
        mov     [ecx], eax                      ; dst = src / dst
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.divr.fpu
{
$usprocf @@_co.int.divr

        cdq
        idiv    dword [ecx]                     ; eax = src / dst
        mov     [ecx], eax                      ; dst = src / dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.divr.sse
$else
  @@_co.int.divr.fpu
$end

; ------------------------------------------------------------------------------

; copy (1 / dst) to dst
; dst offset = ecx

macro @@_co.int.divr.1.sse
{
$usprocf @@_co.int.divr.1

        mov     eax, 1
        cdq
        idiv    dword [ecx]                     ; eax = 1 / dst
        mov     [ecx], eax                      ; dst = 1 / dst
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.divr.1.fpu
{
$usprocf @@_co.int.divr.1

        mov     eax, 1
        cdq
        idiv    dword [ecx]                     ; eax = 1 / dst
        mov     [ecx], eax                      ; dst = 1 / dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.divr.1.sse
$else
  @@_co.int.divr.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (-1 / dst) to dst
; dst offset = ecx

macro @@_co.int.divr.m1.sse
{
$usprocf @@_co.int.divr.m1

        mov     eax, -1
        cdq
        idiv    dword [ecx]                     ; eax = -1 / dst
        mov     [ecx], eax                      ; dst = -1 / dst
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.divr.m1.fpu
{
$usprocf @@_co.int.divr.m1

        mov     eax, -1
        cdq
        idiv    dword [ecx]                     ; eax = -1 / dst
        mov     [ecx], eax                      ; dst = -1 / dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.divr.m1.sse
$else
  @@_co.int.divr.m1.fpu
$end

; ------------------------------------------------------------------------------

; reverse positive division
; double divr.pos ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y/x, y/x > 0
;            0, otherwise

macro @@divr.pos.sse
{
$usprocf @@divr.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xorpd   xmm0, xmm0
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@divr.pos.fpu
{
$usprocf @@divr.pos

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fdivrp
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.pos.sse
$else
  @@divr.pos.fpu
$end

; ------------------------------------------------------------------------------

; reverse positive division
; double divr.pos ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y/x, y/x > 0
;            0, otherwise

macro @@_divr.pos_int.sse
{
$usprocf @@_divr.pos_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_divr.pos_int.fpu
{
$usprocf @@_divr.pos_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_divr.pos_int.sse
$else
  @@_divr.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse positive division
; double divr.pos ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y/x, y/x > 0
;            0, otherwise

macro @@_divr.pos_reg.sse
{
$usprocf @@_divr.pos_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_divr.pos_reg.fpu
{
$usprocf @@_divr.pos_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_divr.pos_reg.sse
$else
  @@_divr.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; reverse negative division
; double divr.neg ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y/x, y/x < 0
;            0, otherwise

macro @@divr.neg.sse
{
$usprocf @@divr.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xorpd   xmm0, xmm0
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@divr.neg.fpu
{
$usprocf @@divr.neg

        fld     qword [esp]
        fld     qword [esp + 8]
    .enter:
        fdivrp
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.neg.sse
$else
  @@divr.neg.fpu
$end

; ------------------------------------------------------------------------------

; reverse negative division
; double divr.neg ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y/x, y/x < 0
;            0, otherwise

macro @@_divr.neg_int.sse
{
$usprocf @@_divr.neg_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_divr.neg_int.fpu
{
$usprocf @@_divr.neg_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_divr.neg_int.sse
$else
  @@_divr.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse negative division
; double divr.neg ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y/x, y/x < 0
;            0, otherwise

macro @@_divr.neg_reg.sse
{
$usprocf @@_divr.neg_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_divr.neg_reg.fpu
{
$usprocf @@_divr.neg_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_divr.neg_reg.sse
$else
  @@_divr.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; reverse int division
; double divr.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(y) / int(x)

macro @@divr.int.sse
{
$usprocf @@divr.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@divr.int.fpu
{
$usprocf @@divr.int

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.int.sse
$else
  @@divr.int.fpu
$end

; ------------------------------------------------------------------------------

; reverse frac division
; double divr.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(y) / frac(x)

macro @@divr.frac.sse
{
$usprocf @@divr.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@divr.frac.fpu
{
$usprocf @@divr.frac

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.frac.sse
$else
  @@divr.frac.fpu
$end

; ------------------------------------------------------------------------------

; reverse round division
; double divr.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(y) / round(x)

macro @@divr.round.sse
{
$usprocf @@divr.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        movsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@divr.round.fpu
{
$usprocf @@divr.round

        fld     qword [esp]
        fld     qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax
        fdivp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@divr.round.sse
$else
  @@divr.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; quotient
; double quo ( double x, double y )
; x = esp
; y = esp + 8
;
; quo = x \ y = int (x / y)

macro @@quo.sse
{
$usprocf @@quo

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@quo.fpu
{
$usprocf @@quo

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivp                                   ; st0 = x/y
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.sse
$else
  @@quo.fpu
$end

; ------------------------------------------------------------------------------

; quotient

macro @@_quo_int.sse
{
$usprocf @@_quo_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quo_int.fpu
{
$usprocf @@_quo_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo_int.sse
$else
  @@_quo_int.fpu
$end

; ------------------------------------------------------------------------------

; quotient
; x = eax
; y = ecx

macro @@_quo_reg.sse
{
$usprocf @@_quo_reg

        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quo_reg.fpu
{
$usprocf @@_quo_reg

        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo_reg.sse
$else
  @@_quo_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst quo src) to dst
; co.quo ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.quo.sse
{
$usprocf @@co.quo

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; dst / +0
        xmovsd  xmm0, ??.PInf
        jmp    .copy
    .NZero:                                     ; dst / -0
        xmovsd  xmm0, ??.NInf
        jmp    .copy

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .copy:
        movsd   qword [ecx], xmm0               ; dst = dst quo src
    .return:
        retn
$endp
}

macro @@co.quo.fpu
{
$usprocf @@co.quo

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [ecx]                     ; st0 = dst | st1 = src
    .enter:
        fdivrp                                  ; st0 = dst/src
        @@.int.st0
    .copy:
        fst     qword [ecx]                     ; dst = dst quo src
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.quo.sse
$else
  @@co.quo.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst \ src) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.quo.sse
{
$usprocf @@_co.int.quo

        mov     edx, eax
        mov     eax, [ecx]                      ; eax = dst
        mov     [ecx], edx                      ; [ecx] = src
        cdq
        idiv    dword [ecx]                     ; eax = dst \ src
        mov     [ecx], eax                      ; dst = dst \ src
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.quo.fpu
{
$usprocf @@_co.int.quo

        mov     edx, eax
        mov     eax, [ecx]                      ; eax = dst
        mov     [ecx], edx                      ; [ecx] = src
        cdq
        idiv    dword [ecx]                     ; eax = dst \ src
        mov     [ecx], eax                      ; dst = dst \ src
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.quo.sse
$else
  @@_co.int.quo.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst \ 1) to dst
; dst offset = ecx

macro @@_co.int.quo.1.sse
{
$usprocf @@_co.int.quo.1

       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.quo.1.fpu
{
$usprocf @@_co.int.quo.1

        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.quo.1.sse
$else
  @@_co.int.quo.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst \ -1) to dst
; dst offset = ecx

macro @@_co.int.quo.m1.sse
{
$usprocf @@_co.int.quo.m1

        neg     dword [ecx]                     ; dst = -dst
       cvtsi2sd xmm0, dword [ecx]
    .return:
        retn
$endp
}

macro @@_co.int.quo.m1.fpu
{
$usprocf @@_co.int.quo.m1

        neg     dword [ecx]                     ; dst = -dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.quo.m1.sse
$else
  @@_co.int.quo.m1.fpu
$end

; ------------------------------------------------------------------------------

; positive quotient
; double quo ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x\y, x\y > 0
;            0, otherwise

macro @@quo.pos.sse
{
$usprocf @@quo.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xorpd   xmm0, xmm0
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
        xintsd  xmm0, xmm0
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@quo.pos.fpu
{
$usprocf @@quo.pos

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivp                                   ; st0 = x/y
        @@.int.st0
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.pos.sse
$else
  @@quo.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive quotient
; double quo ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x\y, x\y > 0
;            0, otherwise

macro @@_quo.pos_int.sse
{
$usprocf @@_quo.pos_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quo.pos_int.fpu
{
$usprocf @@_quo.pos_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.pos_int.sse
$else
  @@_quo.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive quotient
; double quo ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x\y, x\y > 0
;            0, otherwise

macro @@_quo.pos_reg.sse
{
$usprocf @@_quo.pos_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quo.pos_reg.fpu
{
$usprocf @@_quo.pos_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.pos_reg.sse
$else
  @@_quo.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative quotient
; double quo ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x\y, x\y < 0
;            0, otherwise

macro @@quo.neg.sse
{
$usprocf @@quo.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xorpd   xmm0, xmm0
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        @@discard                               ; optimizer directive - initial [xmm] values can be discarded
        xintsd  xmm0, xmm0
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@quo.neg.fpu
{
$usprocf @@quo.neg

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivp                                   ; st0 = x/y
        @@.int.st0
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.neg.sse
$else
  @@quo.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative quotient
; double quo ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x\y, x\y < 0
;            0, otherwise

macro @@_quo.neg_int.sse
{
$usprocf @@_quo.neg_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quo.neg_int.fpu
{
$usprocf @@_quo.neg_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.neg_int.sse
$else
  @@_quo.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative quotient
; double quo ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x\y, x\y < 0
;            0, otherwise

macro @@_quo.neg_reg.sse
{
$usprocf @@_quo.neg_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quo.neg_reg.fpu
{
$usprocf @@_quo.neg_reg

        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quo.neg_reg.sse
$else
  @@_quo.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; int quotient
; double quo.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(x) \ int(y)

macro @@quo.int.sse
{
$usprocf @@quo.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@quo.int.fpu
{
$usprocf @@quo.int

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax                             ; st0 = int(x), st1 = int(y)
        fdivrp                                  ; st0 = int(x) / int(y)
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.int.sse
$else
  @@quo.int.fpu
$end

; ------------------------------------------------------------------------------

; frac quotient
; double quo.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(x) \ frac(y)

macro @@quo.frac.sse
{
$usprocf @@quo.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@quo.frac.fpu
{
$usprocf @@quo.frac

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax                             ; st0 = frac(x), st1 = frac(y)
        fdivrp                                  ; st0 = frac(x) / frac(y)
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.frac.sse
$else
  @@quo.frac.fpu
$end

; ------------------------------------------------------------------------------

; round quotient
; double quo.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(x) \ round(y)

macro @@quo.round.sse
{
$usprocf @@quo.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; x / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; x / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm0, xmm1
        xintsd  xmm0, xmm0
    .return:
        retn
$endp
}

macro @@quo.round.fpu
{
$usprocf @@quo.round

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax                             ; st0 = round(x), st1 = round(y)
        fdivrp                                  ; st0 = round(x) / round(y)
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.round.sse
$else
  @@quo.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reverse quotient
; double quor ( double x, double y )
; x = esp
; y = esp + 8
;
; quor = x ~\ y = int (y / x)

macro @@quor.sse
{
$usprocf @@quor

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .return:
        retn
$endp
}

macro @@quor.fpu
{
$usprocf @@quor

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivrp                                  ; st0 = y/x
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quor.sse
$else
  @@quor.fpu
$end

; ------------------------------------------------------------------------------

; reverse quotient

macro @@_quor_int.sse
{
$usprocf @@_quor_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quor_int.fpu
{
$usprocf @@_quor_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quor_int.sse
$else
  @@_quor_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse quotient
; x = eax
; y = ecx

macro @@_quor_reg.sse
{
$usprocf @@_quor_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quor_reg.fpu
{
$usprocf @@_quor_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quor_reg.sse
$else
  @@_quor_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (src quo dst) to dst
; co.quor ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.quor.sse
{
$usprocf @@co.quor

        movsd   xmm0, qword [esp]               ; xmm0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; src / +0
        xmovsd  xmm0, ??.PInf
        jmp    .copy
    .NZero:                                     ; src / -0
        xmovsd  xmm0, ??.NInf
        jmp    .copy

    .main:
        divsd   xmm0, xmm1
        xintsd  xmm0, xmm0
    .copy:
        movsd   qword [ecx], xmm0               ; dst = src quo dst
    .return:
        retn
$endp
}

macro @@co.quor.fpu
{
$usprocf @@co.quor

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [ecx]                     ; st0 = dst | st1 = src
    .enter:
        fdivp                                   ; st0 = src/dst
        @@.int.st0
    .copy:
        fst     qword [ecx]                     ; dst = src quo dst
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.quor.sse
$else
  @@co.quor.fpu
$end

; ------------------------------------------------------------------------------

; copy (src \ dst) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.quor.sse
{
$usprocf @@_co.int.quor

        cdq
        idiv    dword [ecx]                     ; eax = src \ dst
        mov     [ecx], eax                      ; dst = src \ dst
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.quor.fpu
{
$usprocf @@_co.int.quor

        cdq
        idiv    dword [ecx]                     ; eax = src \ dst
        mov     [ecx], eax                      ; dst = src \ dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.quor.sse
$else
  @@_co.int.quor.fpu
$end

; ------------------------------------------------------------------------------

; copy (1 \ dst) to dst
; dst offset = ecx

macro @@_co.int.quor.1.sse
{
$usprocf @@_co.int.quor.1

        mov     eax, 1
        cdq
        idiv    dword [ecx]                     ; eax = 1 \ dst
        mov     [ecx], eax                      ; dst = 1 \ dst
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.quor.1.fpu
{
$usprocf @@_co.int.quor.1

        mov     eax, 1
        cdq
        idiv    dword [ecx]                     ; eax = 1 \ dst
        mov     [ecx], eax                      ; dst = 1 \ dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.quor.1.sse
$else
  @@_co.int.quor.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (-1 \ dst) to dst
; dst offset = ecx

macro @@_co.int.quor.m1.sse
{
$usprocf @@_co.int.quor.m1

        mov     eax, -1
        cdq
        idiv    dword [ecx]                     ; eax = -1 \ dst
        mov     [ecx], eax                      ; dst = -1 \ dst
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_co.int.quor.m1.fpu
{
$usprocf @@_co.int.quor.m1

        mov     eax, -1
        cdq
        idiv    dword [ecx]                     ; eax = -1 \ dst
        mov     [ecx], eax                      ; dst = -1 \ dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.quor.m1.sse
$else
  @@_co.int.quor.m1.fpu
$end

; ------------------------------------------------------------------------------

; positive reverse quotient
; double quor ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y\x, y\x > 0
;            0, otherwise

macro @@quor.pos.sse
{
$usprocf @@quor.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xorpd   xmm0, xmm0
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .test:
        @@.xmm0.pos
    .return:
        retn
$endp
}

macro @@quor.pos.fpu
{
$usprocf @@quor.pos

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivrp                                  ; st0 = y/x
        @@.int.st0
    .test:
        @@.st0.pos
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quor.pos.sse
$else
  @@quor.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive reverse quotient
; double quor ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y\x, y\x > 0
;            0, otherwise

macro @@_quor.pos_int.sse
{
$usprocf @@_quor.pos_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quor.pos_int.fpu
{
$usprocf @@_quor.pos_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quor.pos_int.sse
$else
  @@_quor.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive reverse quotient
; double quor ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y\x, y\x > 0
;            0, otherwise

macro @@_quor.pos_reg.sse
{
$usprocf @@_quor.pos_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quor.pos_reg.fpu
{
$usprocf @@_quor.pos_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jge    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quor.pos_reg.sse
$else
  @@_quor.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative reverse quotient
; double quor ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y\x, y\x < 0
;            0, otherwise

macro @@quor.neg.sse
{
$usprocf @@quor.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xorpd   xmm0, xmm0
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .test:
        @@.xmm0.neg
    .return:
        retn
$endp
}

macro @@quor.neg.fpu
{
$usprocf @@quor.neg

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
    .enter:
        fdivrp                                  ; st0 = y/x
        @@.int.st0
    .test:
        @@.st0.neg
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quor.neg.sse
$else
  @@quor.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative reverse quotient
; double quor ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y\x, y\x < 0
;            0, otherwise

macro @@_quor.neg_int.sse
{
$usprocf @@_quor.neg_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quor.neg_int.fpu
{
$usprocf @@_quor.neg_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp], eax
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quor.neg_int.sse
$else
  @@_quor.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative reverse quotient
; double quor ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y\x, y\x < 0
;            0, otherwise

macro @@_quor.neg_reg.sse
{
$usprocf @@_quor.neg_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        xorpd   xmm0, xmm0                      ; xmm0 = 0
        jmp    .return
    .load:
       cvtsi2sd xmm0, eax
    .return:
        retn
$endp
}

macro @@_quor.neg_reg.fpu
{
$usprocf @@_quor.neg_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     eax, 0
        jle    .load
        fldz
        jmp    .return
    .load:
        mov     [esp - 4], eax
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_quor.neg_reg.sse
$else
  @@_quor.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; reverse int quotient
; double quor.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(y) \ int(x)

macro @@quor.int.sse
{
$usprocf @@quor.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .return:
        retn
$endp
}

macro @@quor.int.fpu
{
$usprocf @@quor.int

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__int2p
        call    eax                             ; st0 = int(x), st1 = int(y)
        fdivp                                   ; st0 = int(y) / int(x)
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quor.int.sse
$else
  @@quor.int.fpu
$end

; ------------------------------------------------------------------------------

; reverse frac quotient
; double quor.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(y) \ frac(x)

macro @@quor.frac.sse
{
$usprocf @@quor.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .return:
        retn
$endp
}

macro @@quor.frac.fpu
{
$usprocf @@quor.frac

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__frac2p
        call    eax                             ; st0 = frac(x), st1 = frac(y)
        fdivp                                   ; st0 = frac(y) / frac(x)
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quor.frac.sse
$else
  @@quor.frac.fpu
$end

; ------------------------------------------------------------------------------

; reverse round quotient
; double quor.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(y) \ round(x)

macro @@quor.round.sse
{
$usprocf @@quor.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
    .Zero:
        test    dx, 0x8000                      ; test sign flag
        jnz    .NZero
    .PZero:                                     ; y / +0
        xmovsd  xmm0, ??.PInf
        jmp    .return
    .NZero:                                     ; y / -0
        xmovsd  xmm0, ??.NInf
        jmp    .return

    .main:
        divsd   xmm1, xmm0
        xintsd  xmm0, xmm1                      ; xmm0 = int(xmm1)
    .return:
        retn
$endp
}

macro @@quor.round.fpu
{
$usprocf @@quor.round

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y, st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     eax, @@__round2p
        call    eax                             ; st0 = round(x), st1 = round(y)
        fdivp                                   ; st0 = round(y) / round(x)
        @@.int.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@quor.round.sse
$else
  @@quor.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; remainder
; double mod ( double x, double y )
; x = esp
; y = esp + 8
;
; mod = x % y = x - y * int (x / y)

macro @@mod.sse
{
$usprocf @@mod

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; x / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        jmp    .return                          ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm1                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@mod.sse.fpu
{
$usprocf @@mod

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fld.xmm1
        @@.fld.xmm0                             ; st0 = x       | st1 = y
        ;
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@mod.fpu
{
$usprocf @@mod

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch                                    ; st0 = x       | st1 = y
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.sse
$else
  @@mod.fpu
$end

; ------------------------------------------------------------------------------

; remainder

macro @@_mod_int.sse
{
$usprocf @@_mod_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_mod_int.fpu
{
$usprocf @@_mod_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod_int.sse
$else
  @@_mod_int.fpu
$end

; ------------------------------------------------------------------------------

; remainder
; x = eax
; y = ecx

macro @@_mod_reg.sse
{
$usprocf @@_mod_reg

        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_mod_reg.fpu
{
$usprocf @@_mod_reg

        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], edx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod_reg.sse
$else
  @@_mod_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst mod src) to dst
; co.mod ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.mod.sse
{
$usprocf @@co.mod

        movsd   xmm0, qword [esp]               ; xmm0 = src = y
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst = x

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; dst / 0
        xmovsd  xmm0, ??.NaN
        jmp    .copy

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = y = D
        movsd   xmm2, xmm1                      ; xmm2 = x
        divsd   xmm2, xmm0                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        movsd   xmm0, xmm1                      ; xmm0 = x
        jmp    .return
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm0                      ; xmm2 = y*int(x/y)
        movsd   xmm0, xmm1                      ; xmm0 = x
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .copy:
        movsd   qword [ecx], xmm0               ; dst = dst mod src
   .return:
        retn
$endp
}

macro @@co.mod.fpu
{
$usprocf @@co.mod

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [ecx]                     ; st0 = dst     | st1 = src
   .enter:
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .copy:
        fst     qword [ecx]                     ; dst = dst mod src
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.mod.sse
$else
  @@co.mod.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst % src) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.mod.sse
{
$usprocf @@_co.int.mod

        mov     edx, eax
        mov     eax, [ecx]                      ; eax = dst
        mov     [ecx], edx                      ; [ecx] = src
        cdq
        idiv    dword [ecx]                     ; eax = dst % src
        mov     [ecx], edx                      ; dst = dst % src
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_co.int.mod.fpu
{
$usprocf @@_co.int.mod

        mov     edx, eax
        mov     eax, [ecx]                      ; eax = dst
        mov     [ecx], edx                      ; [ecx] = src
        cdq
        idiv    dword [ecx]                     ; eax = dst % src
        mov     [ecx], edx                      ; dst = dst % src
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.mod.sse
$else
  @@_co.int.mod.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst % 1) to dst
; dst offset = ecx

macro @@_co.int.mod.1.sse
{
$usprocf @@_co.int.mod.1

        mov     dword [ecx], 0                  ; dst = dst % 1
        xorpd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_co.int.mod.1.fpu
{
$usprocf @@_co.int.mod.1

        mov     dword [ecx], 0                  ; dst = dst % 1
        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.mod.1.sse
$else
  @@_co.int.mod.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (dst % -1) to dst
; dst offset = ecx

macro @@_co.int.mod.m1.sse
{
$usprocf @@_co.int.mod.m1

        mov     dword [ecx], 0                  ; dst = dst % -1
        xorpd   xmm0, xmm0
    .return:
        retn
$endp
}

macro @@_co.int.mod.m1.fpu
{
$usprocf @@_co.int.mod.m1

        mov     dword [ecx], 0                  ; dst = dst % -1
        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.mod.m1.sse
$else
  @@_co.int.mod.m1.fpu
$end

; ------------------------------------------------------------------------------

; positive remainder
; double mod ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x%y, x%y > 0
;            0, otherwise

macro @@mod.pos.sse
{
$usprocf @@mod.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; x / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        jmp    .test                            ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm1                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .test:
        @@.xmm0.pos
   .return:
        retn
$endp
}

macro @@mod.pos.fpu
{
$usprocf @@mod.pos

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch                                    ; st0 = x       | st1 = y
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .test:
        @@.st0.pos
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.pos.sse
$else
  @@mod.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive remainder
; double mod ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x%y, x%y > 0
;            0, otherwise

macro @@_mod.pos_int.sse
{
$usprocf @@_mod.pos_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_mod.pos_int.fpu
{
$usprocf @@_mod.pos_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.pos_int.sse
$else
  @@_mod.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive remainder
; double mod ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x%y, x%y > 0
;            0, otherwise

macro @@_mod.pos_reg.sse
{
$usprocf @@_mod.pos_reg

        cdq
        idiv    ecx
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_mod.pos_reg.fpu
{
$usprocf @@_mod.pos_reg

        cdq
        idiv    ecx
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
        mov     [esp - 4], edx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.pos_reg.sse
$else
  @@_mod.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative remainder
; double mod ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: x%y, x%y < 0
;            0, otherwise

macro @@mod.neg.sse
{
$usprocf @@mod.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; x / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        jmp    .test                            ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm1                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .test:
        @@.xmm0.neg
   .return:
        retn
$endp
}

macro @@mod.neg.fpu
{
$usprocf @@mod.neg

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fxch                                    ; st0 = x       | st1 = y
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .test:
        @@.st0.neg
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.neg.sse
$else
  @@mod.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative remainder
; double mod ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: x%y, x%y < 0
;            0, otherwise

macro @@_mod.neg_int.sse
{
$usprocf @@_mod.neg_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_mod.neg_int.fpu
{
$usprocf @@_mod.neg_int

        mov     eax, [esp]
        cdq
        idiv    dword [esp + 4]
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.neg_int.sse
$else
  @@_mod.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative remainder
; double mod ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: x%y, x%y < 0
;            0, otherwise

macro @@_mod.neg_reg.sse
{
$usprocf @@_mod.neg_reg

        cdq
        idiv    ecx
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_mod.neg_reg.fpu
{
$usprocf @@_mod.neg_reg

        cdq
        idiv    ecx
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
        mov     [esp - 4], edx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_mod.neg_reg.sse
$else
  @@_mod.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; int remainder
; double mod.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(x) % int(y)

macro @@mod.int.sse
{
$usprocf @@mod.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__int2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; x / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        jmp    .return                          ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm1                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@mod.int.fpu
{
$usprocf @@mod.int

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__int2p
        call    eax                             ; st0 = int(x)  | st1 = int(y)

   .main:
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.int.sse
$else
  @@mod.int.fpu
$end

; ------------------------------------------------------------------------------

; frac remainder
; double mod.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(x) % frac(y)

macro @@mod.frac.sse
{
$usprocf @@mod.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__frac2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; x / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        jmp    .return                          ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm1                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@mod.frac.fpu
{
$usprocf @@mod.frac

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__frac2p
        call    eax                             ; st0 = frac(x) | st1 = frac(y)

   .main:
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.frac.sse
$else
  @@mod.frac.fpu
$end

; ------------------------------------------------------------------------------

; round remainder
; double mod.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(x) % round(y)

macro @@mod.round.sse
{
$usprocf @@mod.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__round2p
        call    eax

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; x / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        jmp    .return                          ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm1                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@mod.round.fpu
{
$usprocf @@mod.round

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__round2p
        call    eax                             ; st0 = round(x) | st1 = round(y)

   .main:
        fprem                                   ; st0 = U mod D  | st1 = D
   .mod.range:
        fxch                                    ; st0 = D        | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.round.sse
$else
  @@mod.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; reverse remainder
; double modr ( double x, double y )
; x = esp
; y = esp + 8
;
; modr = x ~% y = y - x * int (y / x)

macro @@modr.sse
{
$usprocf @@modr

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; y / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm1                      ; xmm2 = y
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm1, xmm3                      ; compare xmm1 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        movsd   xmm0, xmm2                      ; xmm0 = y
        jmp    .return
   .nonzero:
        xintsd  xmm1, xmm1                      ; xmm1 = int(y/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(y/x)
        movsd   xmm0, xmm2                      ; xmm0 = y
        subsd   xmm0, xmm1                      ; xmm0 = y - x*int(y/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@modr.fpu
{
$usprocf @@modr

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@modr.sse
$else
  @@modr.fpu
$end

; ------------------------------------------------------------------------------

; reverse remainder

macro @@_modr_int.sse
{
$usprocf @@_modr_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_modr_int.fpu
{
$usprocf @@_modr_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_modr_int.sse
$else
  @@_modr_int.fpu
$end

; ------------------------------------------------------------------------------

; reverse remainder
; x = eax
; y = ecx

macro @@_modr_reg.sse
{
$usprocf @@_modr_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_modr_reg.fpu
{
$usprocf @@_modr_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
    .load:
        mov     [esp - 4], edx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_modr_reg.sse
$else
  @@_modr_reg.fpu
$end

; ------------------------------------------------------------------------------

; copy (src mod dst) to dst
; co.modr ( pdouble dst, double src )
; dst offset = ecx
; src value  = esp

macro @@co.modr.sse
{
$usprocf @@co.modr

        movsd   xmm0, qword [esp]               ; xmm0 = src = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        movsd   xmm1, qword [ecx]               ; xmm1 = dst = y

        @@.xmm1.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; src / 0
        xmovsd  xmm0, ??.NaN
        jmp    .copy

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        jmp    .copy                            ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm2, xmm1                      ; xmm2 = y*int(x/y)
        subsd   xmm0, xmm2                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .copy:
        movsd   qword [ecx], xmm0               ; dst = src mod dst
   .return:
        retn
$endp
}

macro @@co.modr.fpu
{
$usprocf @@co.modr

        fld     qword [esp]                     ; st0 = src
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
        fld     qword [ecx]                     ; st0 = dst     | st1 = src
   .enter:
        fxch                                    ; st0 = src     | st1 = dst
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .copy:
        fst     qword [ecx]                     ; dst = src mod dst
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@co.modr.sse
$else
  @@co.modr.fpu
$end

; ------------------------------------------------------------------------------

; copy (src % dst) to dst
; dst offset = ecx
; src value  = eax

macro @@_co.int.modr.sse
{
$usprocf @@_co.int.modr

        cdq
        idiv    dword [ecx]                     ; eax = src % dst
        mov     [ecx], edx                      ; dst = src % dst
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_co.int.modr.fpu
{
$usprocf @@_co.int.modr

        cdq
        idiv    dword [ecx]                     ; eax = src % dst
        mov     [ecx], edx                      ; dst = src % dst
        fild    dword [ecx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.modr.sse
$else
  @@_co.int.modr.fpu
$end

; ------------------------------------------------------------------------------

; copy (1 % dst) to dst
; dst offset = ecx

macro @@_co.int.modr.1.sse
{
$usprocf @@_co.int.modr.1

        mov     dword [ecx], 1                  ; dst = 1 % dst
        xmovsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@_co.int.modr.1.fpu
{
$usprocf @@_co.int.modr.1

        mov     dword [ecx], 1                  ; dst = 1 % dst
        fld1
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.modr.1.sse
$else
  @@_co.int.modr.1.fpu
$end

; ------------------------------------------------------------------------------

; copy (-1 % dst) to dst
; dst offset = ecx

macro @@_co.int.modr.m1.sse
{
$usprocf @@_co.int.modr.m1

        mov     dword [ecx], -1                 ; dst = -1 % dst
        xmovsd  xmm0, ??.m1.0
    .return:
        retn
$endp
}

macro @@_co.int.modr.m1.fpu
{
$usprocf @@_co.int.modr.m1

        mov     dword [ecx], -1                 ; dst = -1 % dst
        fld1
        fchs
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_co.int.modr.m1.sse
$else
  @@_co.int.modr.m1.fpu
$end

; ------------------------------------------------------------------------------

; positive reverse remainder
; double modr ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y%x, y%x > 0
;            0, otherwise

macro @@modr.pos.sse
{
$usprocf @@modr.pos

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; y / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm1                      ; xmm2 = y
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm1, xmm3                      ; compare xmm1 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        movsd   xmm0, xmm2                      ; xmm0 = y
        jmp    .test
   .nonzero:
        xintsd  xmm1, xmm1                      ; xmm1 = int(y/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(y/x)
        movsd   xmm0, xmm2                      ; xmm0 = y
        subsd   xmm0, xmm1                      ; xmm0 = y - x*int(y/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .test:
        @@.xmm0.pos
   .return:
        retn
$endp
}

macro @@modr.pos.fpu
{
$usprocf @@modr.pos

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .test:
        @@.st0.pos
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@modr.pos.sse
$else
  @@modr.pos.fpu
$end

; ------------------------------------------------------------------------------

; positive reverse remainder
; double modr ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y%x, y%x > 0
;            0, otherwise

macro @@_modr.pos_int.sse
{
$usprocf @@_modr.pos_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_modr.pos_int.fpu
{
$usprocf @@_modr.pos_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_modr.pos_int.sse
$else
  @@_modr.pos_int.fpu
$end

; ------------------------------------------------------------------------------

; positive reverse remainder
; double modr ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y%x, y%x > 0
;            0, otherwise

macro @@_modr.pos_reg.sse
{
$usprocf @@_modr.pos_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_modr.pos_reg.fpu
{
$usprocf @@_modr.pos_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     edx, 0
        jge    .load
        xor     edx, edx
    .load:
        mov     [esp - 4], edx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_modr.pos_reg.sse
$else
  @@_modr.pos_reg.fpu
$end

; ------------------------------------------------------------------------------

; negative reverse remainder
; double modr ( double x, double y )
; x = esp
; y = esp + 8
;
; returns: y%x, y%x < 0
;            0, otherwise

macro @@modr.neg.sse
{
$usprocf @@modr.neg

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; y / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm1                      ; xmm2 = y
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm1, xmm3                      ; compare xmm1 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        movsd   xmm0, xmm2                      ; xmm0 = y
        jmp    .test
   .nonzero:
        xintsd  xmm1, xmm1                      ; xmm1 = int(y/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(y/x)
        movsd   xmm0, xmm2                      ; xmm0 = y
        subsd   xmm0, xmm1                      ; xmm0 = y - x*int(y/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .test:
        @@.xmm0.neg
   .return:
        retn
$endp
}

macro @@modr.neg.fpu
{
$usprocf @@modr.neg

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .test:
        @@.st0.neg
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@modr.neg.sse
$else
  @@modr.neg.fpu
$end

; ------------------------------------------------------------------------------

; negative reverse remainder
; double modr ( integer x, integer y )
; x = esp
; y = esp + 4
;
; returns: y%x, y%x < 0
;            0, otherwise

macro @@_modr.neg_int.sse
{
$usprocf @@_modr.neg_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_modr.neg_int.fpu
{
$usprocf @@_modr.neg_int

        mov     eax, [esp + 4]
        cdq
        idiv    dword [esp]
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
        mov     [esp], edx
        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_modr.neg_int.sse
$else
  @@_modr.neg_int.fpu
$end

; ------------------------------------------------------------------------------

; negative reverse remainder
; double modr ( integer x, integer y )
; x = eax
; y = ecx
;
; returns: y%x, y%x < 0
;            0, otherwise

macro @@_modr.neg_reg.sse
{
$usprocf @@_modr.neg_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
       cvtsi2sd xmm0, edx
    .return:
        retn
$endp
}

macro @@_modr.neg_reg.fpu
{
$usprocf @@_modr.neg_reg

        xchg    eax, ecx
        cdq
        idiv    ecx
        cmp     edx, 0
        jle    .load
        xor     edx, edx
    .load:
        mov     [esp - 4], edx
        fild    dword [esp - 4]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_modr.neg_reg.sse
$else
  @@_modr.neg_reg.fpu
$end

; ------------------------------------------------------------------------------

; reverse int remainder
; double modr.int ( double x, double y )
; x = esp
; y = esp + 8
;
; result = int(y) % int(x)

macro @@modr.int.sse
{
$usprocf @@modr.int

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__int2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; y / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm1                      ; xmm2 = y
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm1, xmm3                      ; compare xmm1 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        movsd   xmm0, xmm2                      ; xmm0 = y
        jmp    .return
   .nonzero:
        xintsd  xmm1, xmm1                      ; xmm1 = int(y/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(y/x)
        movsd   xmm0, xmm2                      ; xmm0 = y
        subsd   xmm0, xmm1                      ; xmm0 = y - x*int(y/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@modr.int.fpu
{
$usprocf @@modr.int

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__int2p
        call    eax                             ; st0 = int(x)  | st1 = int(y)

   .main:
        fxch                                    ; st0 = int(y)  | st1 = int(x)
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@modr.int.sse
$else
  @@modr.int.fpu
$end

; ------------------------------------------------------------------------------

; reverse frac remainder
; double modr.frac ( double x, double y )
; x = esp
; y = esp + 8
;
; result = frac(y) % frac(x)

macro @@modr.frac.sse
{
$usprocf @@modr.frac

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__frac2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; y / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm1                      ; xmm2 = y
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm1, xmm3                      ; compare xmm1 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        movsd   xmm0, xmm2                      ; xmm0 = y
        jmp    .return
   .nonzero:
        xintsd  xmm1, xmm1                      ; xmm1 = int(y/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(y/x)
        movsd   xmm0, xmm2                      ; xmm0 = y
        subsd   xmm0, xmm1                      ; xmm0 = y - x*int(y/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@modr.frac.fpu
{
$usprocf @@modr.frac

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__frac2p
        call    eax                             ; st0 = frac(x) | st1 = frac(y)

   .main:
        fxch                                    ; st0 = frac(y) | st1 = frac(x)
        fprem                                   ; st0 = U mod D | st1 = D
   .mod.range:
        fxch                                    ; st0 = D       | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@modr.frac.sse
$else
  @@modr.frac.fpu
$end

; ------------------------------------------------------------------------------

; reverse round remainder
; double modr.round ( double x, double y )
; x = esp
; y = esp + 8
;
; result = round(y) % round(x)

macro @@modr.round.sse
{
$usprocf @@modr.round

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__round2p
        call    eax

        @@.xmm0.sz.flags.edx
        test    dx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:                                       ; y / 0
        xmovsd  xmm0, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm0                      ; xmm4 = x = D
        movsd   xmm2, xmm1                      ; xmm2 = y
        divsd   xmm1, xmm0                      ; xmm1 = y/x
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm1, xmm3                      ; compare xmm1 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; y/x = 0
        movsd   xmm0, xmm2                      ; xmm0 = y
        jmp    .return
   .nonzero:
        xintsd  xmm1, xmm1                      ; xmm1 = int(y/x)
        mulsd   xmm1, xmm0                      ; xmm1 = x*int(y/x)
        movsd   xmm0, xmm2                      ; xmm0 = y
        subsd   xmm0, xmm1                      ; xmm0 = y - x*int(y/x) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@modr.round.fpu
{
$usprocf @@modr.round

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        mov     eax, @@__round2p
        call    eax                             ; st0 = round(x) | st1 = round(y)

   .main:
        fxch                                    ; st0 = round(y) | st1 = round(x)
        fprem                                   ; st0 = U mod D  | st1 = D
   .mod.range:
        fxch                                    ; st0 = D        | st1 = U mod D
        fld     st1
        fabs
        fcompp                                  ; compare |U mod D| to D
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@modr.round.sse
$else
  @@modr.round.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; quotient and remainder
; double double quo.mod ( double x, double y )
; x = esp
; y = esp + 8
;
; return_1 = st1 = quo
; return_2 = st0 = mod
;
; quo = int (x / y)
; mod = x % y = x - y * int (x / y)

macro @@quo.mod.sse
{
$usprocf @@quo.mod

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.ecx
        test    cx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:
        test    cx, 0x8000                      ; test sign flag
        jnz    .NZero
   .PZero:                                      ; x / +0
        xmovsd  xmm0, ??.PInf
        xmovsd  xmm1, ??.NaN
        jmp    .return
   .NZero:                                      ; x / -0
        xmovsd  xmm0, ??.NInf
        xmovsd  xmm1, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm1                      ; xmm4 = y = D
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm0, xmm1                      ; xmm0 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm0, xmm3                      ; compare xmm0 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; xmm0 = x/y = 0
        movsd   xmm1, xmm2                      ; xmm1 = x
        jmp    .return
   .nonzero:
        xintsd  xmm0, xmm0                      ; xmm0 = int(x/y)
        mulsd   xmm1, xmm0                      ; xmm1 = y*int(x/y)
        subsd   xmm2, xmm1                      ; xmm2 = x - y*int(x/y)
        movsd   xmm1, xmm2                      ; xmm1 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm2, xmm1
        @@.abs  xmm2
        comisd  xmm2, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm1, xmm1
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@quo.mod.fpu
{
$usprocf @@quo.mod

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x        | st1 = y       | st2 = x        |
        fld     st1                             ; st0 = y        | st1 = x       | st2 = y        | st3 = x
        fdivp                                   ; st0 = x/y      | st1 = y       | st2 = x        |
        ;
        ftst                                    ; compare x/y to 0
        fnjnz  .nonzero
   .iszero:                                     ; st0 = x/y = 0
        fstp    st1                             ; st0 = 0        | st1 = x       |
        fxch                                    ; st0 = x        | st1 = 0       |
        jmp    .return
   .nonzero:
        @@.int.st0                              ; st0 = int(x/y) | st1 = y       | st2 = x        |
        fxch    st2                             ; st0 = x        | st1 = y       | st2 = int(x/y) |
        fprem                                   ; st0 = x mod y  | st1 = y       | st2 = int(x/y) |
   .mod.range:
        fxch                                    ; st0 = y        | st1 = x mod y | st2 = int(x/y) |
        fld     st1
        fabs
        fcompp                                  ; compare |x mod y| to y
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:                              ; st0 = x mod y  | st1 = int(x/y)
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@quo.mod.sse
$else
  @@quo.mod.fpu
$end

; ------------------------------------------------------------------------------

; quotient and remainder
; double co.quo.mod ( double *quo, double *mod, double x, double y )
;
; eax = quo offset
; edx = mod offset
;
; return_1 = st1 = quo
; return_2 = st0 = mod
;
; return   = st0 = quo
;
; quo = int (x / y)
; mod = x % y = x - y * int (x / y)

macro @@co.quo.mod.sse
{
$usprocf @@co.quo.mod

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.ecx
        test    cx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:
        test    cx, 0x8000                      ; test sign flag
        jnz    .NZero
   .PZero:                                      ; x / +0
        xmovsd  xmm0, ??.PInf
        xmovsd  xmm2, ??.NaN
        jmp    .return
   .NZero:                                      ; x / -0
        xmovsd  xmm0, ??.NInf
        xmovsd  xmm2, ??.NaN
        jmp    .return

   .main:
        movsd   xmm4, xmm1                      ; xmm4 = y = D
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm0, xmm1                      ; xmm0 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm0, xmm3                      ; compare xmm0 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; xmm0 = x/y = 0
        jmp    .return                          ; xmm2 = x
   .nonzero:
        xintsd  xmm0, xmm0                      ; xmm0 = int(x/y)
        mulsd   xmm1, xmm0                      ; xmm1 = y*int(x/y)
        subsd   xmm2, xmm1                      ; xmm2 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm1, xmm2
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm2, xmm2
   .mod.range.out:
   .return:
        movsd   qword [eax], xmm0               ; xmm0 = int(x/y)
        movsd   qword [edx], xmm2               ; xmm2 = x - y*int(x/y)
        retn
$endp
}

macro @@co.quo.mod.fpu
{
$usprocf @@co.quo.mod

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax                             ; fnj... macros modify eax register
        fld     st1                             ; st0 = x        | st1 = y       | st2 = x        |
        fld     st1                             ; st0 = y        | st1 = x       | st2 = y        | st3 = x
        fdivp                                   ; st0 = x/y      | st1 = y       | st2 = x        |
        ;
        ftst                                    ; compare x/y to 0
        fnjnz  .nonzero
   .iszero:                                     ; st0 = x/y = 0
        fstp    st1                             ; st0 = 0        | st1 = x       |
        fxch                                    ; st0 = x        | st1 = 0       |
        jmp    .return
   .nonzero:
        @@.int.st0                              ; st0 = int(x/y) | st1 = y       | st2 = x        |
        fxch    st2                             ; st0 = x        | st1 = y       | st2 = int(x/y) |
        fprem                                   ; st0 = x mod y  | st1 = y       | st2 = int(x/y) |
   .mod.range:
        fxch                                    ; st0 = y        | st1 = x mod y | st2 = int(x/y) |
        fld     st1
        fabs
        fcompp                                  ; compare |x mod y| to y
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:                              ; st0 = x mod y  | st1 = int(x/y)
   .return:
        pop     eax
        fstp    qword [edx]
        fst     qword [eax]
        retn
$endp
}

$ifdef _SSEX
  @@co.quo.mod.sse
$else
  @@co.quo.mod.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; remainder and quotient
; double double mod.quo ( double x, double y )
; x = esp
; y = esp + 8
;
; return_1 = st1 = mod
; return_2 = st0 = quo
;
; mod = x % y = x - y * int (x / y)
; quo = int (x / y)

macro @@mod.quo.sse
{
$usprocf @@mod.quo

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.ecx
        test    cx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:
        test    cx, 0x8000                      ; test sign flag
        jnz    .NZero
   .PZero:                                      ; x / +0
        xmovsd  xmm0, ??.NaN
        xmovsd  xmm1, ??.PInf
        jmp    .return
   .NZero:                                      ; x / -0
        xmovsd  xmm0, ??.NaN
        xmovsd  xmm1, ??.NInf
        jmp    .return

   .main:
        movsd   xmm4, xmm1                      ; xmm4 = y = D
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; x/y = 0
        xorpd   xmm1, xmm1                      ; xmm1 = 0
        jmp    .return                          ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm1, xmm2                      ; xmm1 = y*int(x/y)
        subsd   xmm0, xmm1                      ; xmm0 = x - y*int(x/y) = U mod D
        movsd   xmm1, xmm2                      ; xmm1 = int(x/y)
   .mod.range:
        movsd   xmm2, xmm0
        @@.abs  xmm2
        comisd  xmm2, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        retn
$endp
}

macro @@mod.quo.fpu
{
$usprocf @@mod.quo

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        fld     st1                             ; st0 = x        | st1 = y       | st2 = x        |
        fld     st1                             ; st0 = y        | st1 = x       | st2 = y        | st3 = x
        fdivp                                   ; st0 = x/y      | st1 = y       | st2 = x        |
        ;
        ftst                                    ; compare x/y to 0
        fnjnz  .nonzero
   .iszero:                                     ; st0 = x/y = 0
        fstp    st1                             ; st0 = 0        | st1 = x       |
        jmp    .return
   .nonzero:
        @@.int.st0                              ; st0 = int(x/y) | st1 = y       | st2 = x        |
        fxch    st2                             ; st0 = x        | st1 = y       | st2 = int(x/y) |
        fprem                                   ; st0 = x mod y  | st1 = y       | st2 = int(x/y) |
   .mod.range:
        fxch                                    ; st0 = y        | st1 = x mod y | st2 = int(x/y) |
        fld     st1
        fabs
        fcompp                                  ; compare |x mod y| to y
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:                              ; st0 = x mod y  | st1 = int(x/y)
        fxch                                    ; st0 = int(x/y) | x mod y
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@mod.quo.sse
$else
  @@mod.quo.fpu
$end

; ------------------------------------------------------------------------------

; remainder and quotient
; double co.mod.quo ( double *mod, double *quo, double x, double y )
;
; eax = mod offset
; edx = quo offset
;
; return_1 = st1 = mod
; return_2 = st0 = quo
;
; return   = st0 = mod
;
; mod = x % y = x - y * int (x / y)
; quo = int (x / y)

macro @@co.mod.quo.sse
{
$usprocf @@co.mod.quo

        movsd   xmm0, qword [esp]
        movsd   xmm1, qword [esp + 8]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.xmm1.sz.flags.ecx
        test    cx, 0x0001                      ; test zero flag
        jz     .main
   .Zero:
        test    cx, 0x8000                      ; test sign flag
        jnz    .NZero
   .PZero:                                      ; x / +0
        xmovsd  xmm0, ??.NaN
        xmovsd  xmm2, ??.PInf
        jmp    .return
   .NZero:                                      ; x / -0
        xmovsd  xmm0, ??.NaN
        xmovsd  xmm2, ??.NInf
        jmp    .return

   .main:
        movsd   xmm4, xmm1                      ; xmm4 = y = D
        movsd   xmm2, xmm0                      ; xmm2 = x
        divsd   xmm2, xmm1                      ; xmm2 = x/y
        ;
        xorpd   xmm3, xmm3                      ; xmm3 = 0
        ucomisd xmm2, xmm3                      ; compare xmm2 to 0
        jnz    .nonzero
        jp     .nonzero
   .iszero:                                     ; xmm2 = x/y = 0
        jmp    .return                          ; xmm0 = x
   .nonzero:
        xintsd  xmm2, xmm2                      ; xmm2 = int(x/y)
        mulsd   xmm1, xmm2                      ; xmm1 = y*int(x/y)
        subsd   xmm0, xmm1                      ; xmm0 = x - y*int(x/y) = U mod D
   .mod.range:
        movsd   xmm1, xmm0
        @@.abs  xmm1
        comisd  xmm1, xmm4                      ; compare |U mod D| to D
        jb     .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        xorpd   xmm0, xmm0
   .mod.range.out:
   .return:
        movsd   qword [eax], xmm0               ; xmm0 = x - y*int(x/y)
        movsd   qword [edx], xmm2               ; xmm2 = int(x/y)
        retn
$endp
}

macro @@co.mod.quo.fpu
{
$usprocf @@co.mod.quo

        fld     qword [esp]
        fld     qword [esp + 8]                 ; st0 = y | st1 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        push    eax                             ; fnj... macros modify eax register
        fld     st1                             ; st0 = x        | st1 = y       | st2 = x        |
        fld     st1                             ; st0 = y        | st1 = x       | st2 = y        | st3 = x
        fdivp                                   ; st0 = x/y      | st1 = y       | st2 = x        |
        ;
        ftst                                    ; compare x/y to 0
        fnjnz  .nonzero
   .iszero:                                     ; st0 = x/y = 0
        fstp    st1                             ; st0 = 0        | st1 = x       |
        jmp    .return
   .nonzero:
        @@.int.st0                              ; st0 = int(x/y) | st1 = y       | st2 = x        |
        fxch    st2                             ; st0 = x        | st1 = y       | st2 = int(x/y) |
        fprem                                   ; st0 = x mod y  | st1 = y       | st2 = int(x/y) |
   .mod.range:
        fxch                                    ; st0 = y        | st1 = x mod y | st2 = int(x/y) |
        fld     st1
        fabs
        fcompp                                  ; compare |x mod y| to y
        fnjl   .mod.range.out
   .mod.zero:                                   ; mod() = 0 if |U mod D| >= D
        fldz
        fstp    st1
   .mod.range.out:                              ; st0 = x mod y  | st1 = int(x/y)
        fxch                                    ; st0 = int(x/y) | st1 = x mod y
   .return:
        pop     eax
        fstp    qword [edx]
        fst     qword [eax]
        retn
$endp
}

$ifdef _SSEX
  @@co.mod.quo.sse
$else
  @@co.mod.quo.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; integer part of x
; integer trunc ( double x )
; return result in eax
;
; trunc ( 2.1) =  2
; trunc ( 2.5) =  2
; trunc ( 3.5) =  3
; trunc (-2.1) = -2
; trunc (-2.5) = -2
; trunc (-3.5) = -3

macro @@trunc.sse
{
$usprocf @@trunc

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
      cvttsd2si eax, xmm0                       ; eax = truncated xmm0 = trunc(x)
   .return:
        retn
$endp
}

macro @@trunc.fpu
{
$usprocf @@trunc

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        fistp   dword [esp - 4]
        mov     eax, dword [esp - 4]
        @@.fpu.cw.restore                       ; restore control word
   .return:
        retn
$endp
}

$ifdef _SSEX
  @@trunc.sse
$else
  @@trunc.fpu
$end

; ------------------------------------------------------------------------------

; integer part of x
; integer trunc ( integer x )
; return result in eax
; eax = x

$usprocf @@_trunc_reg

   .enter:
   .return:
        retn
$endp

; ------------------------------------------------------------------------------

; integer part of x
; integer trunc ( integer x )
; return result in eax
; eax = x

macro @@.trunc_int
{
$usprocf @@_trunc_int

        nop
;       retn
$endp
}

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; integer part of x
$usprocf @@.vint

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; integer part of x
;
; int ( 2.1) =  2
; int ( 2.5) =  2
; int ( 3.5) =  3
; int (-2.1) = -2
; int (-2.5) = -2
; int (-3.5) = -3

; <- st0

macro @@int.sse
{
$usprocf @@int

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xintsd  xmm0, xmm0                      ; xmm0 = int(x)
    .return:
        retn
$endp
}

macro @@int.fpu
{
$usprocf @@int

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@int.sse
$else
  @@int.fpu
$end

; ------------------------------------------------------------------------------

; integer part of x
; double int ( integer x )

macro @@_int_int.sse
{
$usprocf @@_int_int

       cvtsi2sd xmm0, dword [esp]
    .return:
        retn
$endp
}

macro @@_int_int.fpu
{
$usprocf @@_int_int

        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_int_int.sse
$else
  @@_int_int.fpu
$end

; ------------------------------------------------------------------------------

; integer part of x & y
; x = esp
; y = esp + 8

macro @@__int2p.sse
{
$asprocf @@__int2p

    .enter:
        xintsd  xmm0, xmm0                      ; xmm0 = int(x)
        xintsd  xmm1, xmm1                      ; xmm1 = int(y)
    .return:
        retn
$endp
}

macro @@__int2p.fpu
{
$asprocf @@__int2p
                                                ; --------------------
                                                ; ST(0)              |
                                                ; --------------------
    .enter:                                     ; y                  |
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        frndint                                 ; Y = int(y)         |
        fxch                                    ; x                  |
        frndint                                 ; X = int(x)         |

        @@.fpu.cw.restore                       ; restore control word
    .return:                                    ; --------------------
        retn
$endp
}

$ifdef _SSEX
  @@__int2p.sse
$else
  @@__int2p.fpu
$end

; ------------------------------------------------------------------------------

; trunc x to a specified power of ten
; double intto ( double x, double n )
; x = esp
; n = esp + 8
;
; intto (123456, 4) = 120000
; intto (123456, 3) = 123000
; intto (123456, 2) = 123400
; intto (1.234, -2) = 1.23
; intto (1.235, -2) = 1.23
; intto (1.245, -2) = 1.24

macro @@intto.sse
{
$usprocf @@intto

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm2, xmm0                      ; xmm2 = x
        cvttsd2si eax, xmm1                     ; eax = trunc(n)
        xmovsd  xmm0, ??.10.0
        mov     edx, @@ipow.enter
        call    edx                             ; xmm0 = 10^n
        divsd   xmm2, xmm0
        xintsd  xmm2, xmm2
        mulsd   xmm0, xmm2
    .return:
        retn
$endp
}

macro @@intto.fpu
{
$usprocf @@intto

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions

        frndint                                 ; st0 = int(n)
        mov     eax, @@exp10.enter
        call    eax
        fxch
        fld     st1
        fdivp
        frndint
        fmulp

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@intto.sse
$else
  @@intto.fpu
$end

; ------------------------------------------------------------------------------

; intto delta
; double deintto ( double x, double n )
; deintto(x,n) = x - intto(x,n)

macro @@deintto.sse
{
$usprocf @@deintto

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm3, xmm0                      ; xmm3 = x
        mov     edx, @@intto.enter
        call    edx                             ; xmm0 = intto(x,n)
        subsd   xmm3, xmm0
        movsd   xmm0, xmm3
    .return:
        retn
$endp
}

macro @@deintto.fpu
{
$usprocf @@deintto

        fld     qword [esp]                     ; st0 = x |
        fld     qword [esp + 8]                 ; st0 = n | st1 = x |
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st1                             ; st0 = x | st1 = n | st2 = x
        fxch                                    ; st0 = n | st1 = x | st2 = x
        mov     eax, @@intto.enter
        call    eax                             ; st0 = intto(x,n)  | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deintto.sse
$else
  @@deintto.fpu
$end

; ------------------------------------------------------------------------------

; fractional part of x
$usprocf @@.vfrac

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; fractional part of x
;
; frac ( 2.1) =  0.1
; frac ( 2.5) =  0.5
; frac ( 3.5) =  0.5
; frac (-2.1) = -0.1
; frac (-2.5) = -0.5
; frac (-3.5) = -0.5

macro @@frac.sse
{
$usprocf @@frac

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xfracsd xmm0, xmm0                      ; xmm0 = frac(x)
    .return:
        retn
$endp
}

macro @@frac.fpu
{
$usprocf @@frac

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.frac.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@frac.sse
$else
  @@frac.fpu
$end

; ------------------------------------------------------------------------------

; fractional part of x
; double frac ( integer x )

macro @@_frac_int.sse
{
$usprocf @@_frac_int

    .enter:
        xorpd   xmm0, xmm0                      ; xmm0 = 0
    .return:
        retn
$endp
}

macro @@_frac_int.fpu
{
$usprocf @@_frac_int

    .enter:
        fldz
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_frac_int.sse
$else
  @@_frac_int.fpu
$end

; ------------------------------------------------------------------------------

; fractional part of x & y
; x = esp
; y = esp + 8

macro @@__frac2p.sse
{
$asprocf @@__frac2p

    .enter:
        xfracsd xmm0, xmm0                      ; xmm0 = frac(x)
        xfracsd xmm1, xmm1                      ; xmm1 = frac(y)
    .return:
        retn
$endp
}

macro @@__frac2p.fpu
{                                               ; --------------------
$asprocf @@__frac2p                             ; ST(0)              |
                                                ; --------------------
    .enter:                                     ; y                  |
        @@.frac.st0                             ; Y = frac(y)        |
        fxch                                    ; x                  |
        @@.frac.st0                             ; X = frac(x)        |
    .return:                                    ; --------------------
        retn
$endp
}

$ifdef _SSEX
  @@__frac2p.sse
$else
  @@__frac2p.fpu
$end

; ------------------------------------------------------------------------------

; frac x to a specified power of ten
; double fracto ( double x, double n )
; x = esp
; n = esp + 8
;
; fracto (12345.6789,  4) = 0.23456789
; fracto (12345.6789,  3) = 0.3456789
; fracto (12345.6789,  2) = 0.456789
; fracto (12345.6789, -1) = 0.789
; fracto (12345.6789, -2) = 0.89
; fracto (12345.6789, -3) = 0.9

macro @@fracto.sse
{
$usprocf @@fracto

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm2, xmm0                      ; xmm2 = x
        cvttsd2si eax, xmm1                     ; eax = trunc(n)
        neg     eax                             ; eax = -n
        xmovsd  xmm0, ??.10.0
        mov     edx, @@ipow.enter
        call    edx                             ; xmm0 = 10^(-n)
        mulsd   xmm0, xmm2
        xfracsd xmm0, xmm0
    .return:
        retn
$endp
}

macro @@fracto.fpu
{
$usprocf @@fracto

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.int.st0                              ; st0 = int(n)
        mov     eax, @@exp10.enter
        call    eax
        fdivp
        @@.frac.st0
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@fracto.sse
$else
  @@fracto.fpu
$end

; ------------------------------------------------------------------------------

; fracto delta
; double defracto ( double x, double n )
; defracto(x,n) = x - fracto(x,n)

macro @@defracto.sse
{
$usprocf @@defracto

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm3, xmm0                      ; xmm3 = x
        mov     edx, @@fracto.enter
        call    edx                             ; xmm0 = fracto(x,n)
        subsd   xmm3, xmm0
        movsd   xmm0, xmm3
    .return:
        retn
$endp
}

macro @@defracto.fpu
{
$usprocf @@defracto

        fld     qword [esp]                     ; st0 = x |
        fld     qword [esp + 8]                 ; st0 = n | st1 = x |
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st1                             ; st0 = x | st1 = n | st2 = x
        fxch                                    ; st0 = n | st1 = x | st2 = x
        mov     eax, @@fracto.enter
        call    eax                             ; st0 = fracto(x,n) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@defracto.sse
$else
  @@defracto.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; round x
$usprocf @@.vround

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; round x to the nearest integer number
; round half away from zero
; int(x) + int(2*frac(x));
;
; round ( 2.1) =  2
; round ( 2.5) =  3
; round ( 2.9) =  3
; round ( 5.1) =  5
; round ( 5.5) =  6
; round ( 5.9) =  6
; round (-2.1) = -2
; round (-2.5) = -3
; round (-2.9) = -3
; round (-5.1) = -5
; round (-5.5) = -6
; round (-5.9) = -6

macro @@round.sse
{
$usprocf @@round

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xrndsd  xmm0, xmm0                      ; xmm0 = round(x)
    .return:
        retn
$endp

$asprocf @@round.enter.fpu

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
                                                ; -------------------------------------
                                                ; ST(0)        | ST(1)        | ST(2) |
                                                ; -------------------------------------
                                                ; x.y          | ?            | ?     |
        fld     st0                             ; x.y          | x.y          | ?     |
        fld     st0                             ; x.y          | x.y          | x.y   |
        frndint                                 ; x            | x.y          | x.y   |
        fsubp                                   ; 0.y          | x.y          | ?     |
        fld     st0                             ; 0.y          | 0.y          | x.y   |
        faddp                                   ; 2 * 0.y      | x.y          | ?     |
        frndint                                 ; int(2 * 0.y) | x.y          | ?     |
        fxch                                    ; x.y          | int(2 * 0.y) | ?     |
        frndint                                 ; int(x.y)     | int(2 * 0.y) | ?     |
        faddp                                   ; round(x.y)   | ?            | ?     |
                                                ; -------------------------------------
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@round.fpu
{
$usprocf @@round

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
                                                ; -------------------------------------
                                                ; ST(0)        | ST(1)        | ST(2) |
                                                ; -------------------------------------
                                                ; x.y          | ?            | ?     |
        fld     st0                             ; x.y          | x.y          | ?     |
        fld     st0                             ; x.y          | x.y          | x.y   |
        frndint                                 ; x            | x.y          | x.y   |
        fsubp                                   ; 0.y          | x.y          | ?     |
        fld     st0                             ; 0.y          | 0.y          | x.y   |
        faddp                                   ; 2 * 0.y      | x.y          | ?     |
        frndint                                 ; int(2 * 0.y) | x.y          | ?     |
        fxch                                    ; x.y          | int(2 * 0.y) | ?     |
        frndint                                 ; int(x.y)     | int(2 * 0.y) | ?     |
        faddp                                   ; round(x.y)   | ?            | ?     |
                                                ; -------------------------------------
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@round.sse
$else
  @@round.fpu
$end

; ------------------------------------------------------------------------------

; round x to the nearest integer number
; double round ( integer x )

macro @@_round_int.sse
{
$usprocf @@_round_int

       cvtsi2sd xmm0, dword [esp]
    .return:
        retn
$endp
}

macro @@_round_int.fpu
{
$usprocf @@_round_int

        fild    dword [esp]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@_round_int.sse
$else
  @@_round_int.fpu
$end

; ------------------------------------------------------------------------------

; round x & y
; x = esp
; y = esp + 8

macro @@__round2p.sse
{
$asprocf @@__round2p

    .enter:
        xrndsd  xmm0, xmm0                      ; xmm0 = round(x)
        xrndsd  xmm1, xmm1                      ; xmm1 = round(y)
    .return:
        retn
$endp
}

macro @@__round2p.fpu
{                                               ; --------------------
$asprocf @@__round2p                            ; ST(0)              |
                                                ; --------------------
    .enter:                                     ; y                  |
        mov     eax, @@round.enter              ;                    |
        call    eax                             ; Y = round(y)       |
        fxch                                    ; x                  |
        mov     eax, @@round.enter              ;                    |
        call    eax                             ; X = round(x)       |
    .return:                                    ; --------------------
        retn
$endp
}

$ifdef _SSEX
  @@__round2p.sse
$else
  @@__round2p.fpu
$end

; ------------------------------------------------------------------------------

; round delta
; double deround ( double x )
; deround(x) = x - round(x)

macro @@deround.sse
{
$usprocf @@deround

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, xmm0                      ; xmm1 = x
        xrndsd  xmm1, xmm1                      ; xmm1 = round(x)
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@deround.fpu
{
$usprocf @@deround

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@round.enter
        call    eax                             ; st0 = round(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deround.sse
$else
  @@deround.fpu
$end

; ------------------------------------------------------------------------------

; round x to a specified power of ten
; double roundto ( double x, double n )
; x = esp
; n = esp + 8
;
; roundto (123456, 4) = 120000
; roundto (123456, 3) = 123000
; roundto (123456, 2) = 123500
; roundto (1.234, -2) = 1.23
; roundto (1.235, -2) = 1.24
; roundto (1.245, -2) = 1.25

macro @@roundto.sse
{
$usprocf @@roundto

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
    $ifdef _SSE4.1
        xmovsd  xmm2, ??.m16.0                  ; xmm2 = -16.0
        comisd  xmm1, xmm2                      ; compare n to -16.0
        jb     .return                          ; return x if n < -16.0
        xmovsd  xmm2, ??.16.0                   ; xmm2 = 16.0
        comisd  xmm1, xmm2                      ; compare n to 16.0
        jbe    .main                            ; jump if n <= 16.0
   .n.GT.16.0:                                  ; n > 16.0
        xorpd   xmm0, xmm0
        jmp    .return                          ; return 0.0
    $else
        mov     ebx, @@.roundto.arg             ; !!! use ebx
        call    ebx
        test    ebx, ebx
        jz     .return
    $end
   .main:                                       ; -16.0 <= n <= 16.0
        movsd   xmm2, xmm0                      ; xmm2 = x
        cvttsd2si eax, xmm1                     ; eax = trunc(n)
        xmovsd  xmm0, ??.10.0
        mov     edx, @@ipow.enter
        call    edx                             ; xmm0 = 10^n
        divsd   xmm2, xmm0
        xrndsd  xmm2, xmm2
        mulsd   xmm0, xmm2

   .return:
        retn
$endp

$asprocf @@.roundto.arg

        xmovsd  xmm2, ??.m16.0                  ; xmm2 = -16.0
        comisd  xmm1, xmm2                      ; compare n to -16.0
        jb     .assign                          ; assign x if n < -16.0
        xmovsd  xmm2, ??.16.0                   ; xmm2 = 16.0
        comisd  xmm1, xmm2                      ; compare n to 16.0
        jbe    .return                          ; jump if n <= 16.0
   .n.GT.16.0:                                  ; n > 16.0
        xorpd   xmm0, xmm0
;       jmp    .assign                          ; assign 0.0

   .assign:
        xor     ebx, ebx

   .return:
        retn
$endp
}

macro @@roundto.fpu
{
$usprocf @@roundto

        fld     qword [esp]                     ; st0 = x
        fld     qword [esp + 8]                 ; st0 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
   .enter:
   .arg:                                        ; argument test
        fldq    ??.m16.0                        ; st0 = -16.0 | st1 = n | st2 = x
        fcomp                                   ; compare -16.0 to n
        fnjg   .n.LT.m16.0                      ; jump if n < -16.0 (-16.0 > n)
        fldq    ??.16.0                         ; st0 = 16.0  | st1 = n | st2 = x
        fcomp                                   ; compare 16.0 to n
        fnjge  .main                            ; jump if n <= 16.0 (16.0 >= n)
   .n.GT.16.0:                                  ; n > 16.0
        fstp    st0
        fstp    st0
        fldz
        jmp    .return                          ; return 0.0
   .n.LT.m16.0:                                 ; n < -16.0
        fstp    st0
        jmp    .return                          ; return x
   .main:                                       ; -16.0 <= n <= 16.0
        @@.int.st0                              ; st0 = int(n)
        mov     eax, @@exp10.enter
        call    eax
        fxch
        fld     st1
        fdivp
        mov     eax, @@round.enter
        call    eax
        fmulp

   .return:
        retn
$endp
}

$ifdef _SSEX
  @@roundto.sse
$else
  @@roundto.fpu
$end

; ------------------------------------------------------------------------------

; roundto delta
; double deroundto ( double x, double n )
; deroundto(x,n) = x - roundto(x,n)

macro @@deroundto.sse
{
$usprocf @@deroundto

        movsd   xmm0, qword [esp]               ; xmm0 = x
        movsd   xmm1, qword [esp + 8]           ; xmm1 = n
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm3, xmm0                      ; xmm3 = x
        mov     edx, @@roundto.enter
        call    edx                             ; xmm0 = roundto(x,n)
        subsd   xmm3, xmm0
        movsd   xmm0, xmm3
    .return:
        retn
$endp
}

macro @@deroundto.fpu
{
$usprocf @@deroundto

        fld     qword [esp]                     ; st0 = x |
        fld     qword [esp + 8]                 ; st0 = n | st1 = x |
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st1                             ; st0 = x | st1 = n | st2 = x
        fxch                                    ; st0 = n | st1 = x | st2 = x
        mov     eax, @@roundto.enter
        call    eax                             ; st0 = roundto(x,n)| st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@deroundto.sse
$else
  @@deroundto.fpu
$end

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; round x to integer
; depends on the current FPU(MXCSR) rounding mode
; x = esp

macro @@rint.sse4
{
$usprocf @@rint

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm0, xmm0, 0x4                 ; use current MXCSR setting (_MM_FROUND_CUR_DIRECTION = 0x4)
    .return:
        retn
$endp
}

macro @@rint.sse.fpu
{
$usprocf @@rint

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        frndint
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@rint.fpu
{
$usprocf @@rint

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        frndint
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rint.sse4
$else
  @@rint.sse.fpu
$end
$else
  @@rint.fpu
$end

; ------------------------------------------------------------------------------

; round x to the nearest integer number
; round half to even
;
; rheven ( 2.1) =  2
; rheven ( 2.5) =  2
; rheven ( 2.9) =  3
; rheven ( 5.1) =  5
; rheven ( 5.5) =  6
; rheven ( 5.9) =  6
; rheven (-2.1) = -2
; rheven (-2.5) = -2
; rheven (-2.9) = -3
; rheven (-5.1) = -5
; rheven (-5.5) = -6
; rheven (-5.9) = -6

macro @@rheven.sse4
{
$usprocf @@rheven

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm0, xmm0, 0x0                 ; round to nearest (even) (_MM_FROUND_TO_NEAREST_INT = 0x0)
    .return:
        retn
$endp
}

macro @@rheven.sse.fpu
{
$usprocf @@rheven

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x033F                 ; 00000011 00111111 ; round toward nearest (even), full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@rheven.enter.fpu

        @@.fpu.cw.assign 0x033F                 ; 00000011 00111111 ; round toward nearest (even), full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@rheven.fpu
{
$usprocf @@rheven

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x033F                 ; 00000011 00111111 ; round toward nearest (even), full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rheven.sse4
$else
  @@rheven.sse.fpu
$end
$else
  @@rheven.fpu
$end

; ------------------------------------------------------------------------------

; rheven delta
; double derheven ( double x )
; derheven(x) = x - rheven(x)

macro @@derheven.sse4
{
$usprocf @@derheven

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm1, xmm0, 0x0                 ; round to nearest (even) (_MM_FROUND_TO_NEAREST_INT = 0x0)
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@derheven.sse.fpu
{
$usprocf @@derheven

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rheven.enter.fpu
        call    eax                             ; st0 = rheven(x) | st1 = x
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@derheven.fpu
{
$usprocf @@derheven

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rheven.enter
        call    eax                             ; st0 = rheven(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@derheven.sse4
$else
  @@derheven.sse.fpu
$end
$else
  @@derheven.fpu
$end

; ------------------------------------------------------------------------------

; round x to the nearest integer number
; round half to odd
; rhodd(x) = rheven(x+1)-1
;
; rhodd ( 2.1) =  2
; rhodd ( 2.5) =  3
; rhodd ( 2.9) =  3
; rhodd ( 5.1) =  5
; rhodd ( 5.5) =  5
; rhodd ( 5.9) =  6
; rhodd (-2.1) = -2
; rhodd (-2.5) = -3
; rhodd (-2.9) = -3
; rhodd (-5.1) = -5
; rhodd (-5.5) = -5
; rhodd (-5.9) = -6

macro @@rhodd.sse4
{
$usprocf @@rhodd

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xaddsd  xmm0, ??.1.0
        roundsd xmm0, xmm0, 0x0                 ; round to nearest (even) (_MM_FROUND_TO_NEAREST_INT = 0x0)
        xsubsd  xmm0, ??.1.0
    .return:
        retn
$endp
}

macro @@rhodd.sse.fpu
{
$usprocf @@rhodd

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x033F                 ; 00000011 00111111 ; round toward nearest (even), full precision, mask all exceptions

        fld1
        faddp
        frndint
        fld1
        fsubp

        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@rhodd.enter.fpu

        @@.fpu.cw.assign 0x033F                 ; 00000011 00111111 ; round toward nearest (even), full precision, mask all exceptions

        fld1
        faddp
        frndint
        fld1
        fsubp

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@rhodd.fpu
{
$usprocf @@rhodd

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x033F                 ; 00000011 00111111 ; round toward nearest (even), full precision, mask all exceptions

        fld1
        faddp
        frndint
        fld1
        fsubp

        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rhodd.sse4
$else
  @@rhodd.sse.fpu
$end
$else
  @@rhodd.fpu
$end

; ------------------------------------------------------------------------------

; rhodd delta
; double derhodd ( double x )
; derhodd(x) = x - rhodd(x)

macro @@derhodd.sse4
{
$usprocf @@derhodd

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        movsd   xmm1, xmm0
        xaddsd  xmm1, ??.1.0
        roundsd xmm1, xmm1, 0x0                 ; round to nearest (even) (_MM_FROUND_TO_NEAREST_INT = 0x0)
        xsubsd  xmm1, ??.1.0
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@derhodd.sse.fpu
{
$usprocf @@derhodd

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rhodd.enter.fpu
        call    eax                             ; st0 = rhodd(x) | st1 = x
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@derhodd.fpu
{
$usprocf @@derhodd

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rhodd.enter
        call    eax                             ; st0 = rhodd(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@derhodd.sse4
$else
  @@derhodd.sse.fpu
$end
$else
  @@derhodd.fpu
$end

; ------------------------------------------------------------------------------

; round x toward zero
;
; rzero ( 2.1) =  2
; rzero ( 2.5) =  2
; rzero ( 2.9) =  2
; rzero ( 5.1) =  5
; rzero (-2.1) = -2
; rzero (-2.5) = -2
; rzero (-2.9) = -2
; rzero (-5.1) = -5

macro @@rzero.sse4
{
$usprocf @@rzero

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm0, xmm0, 0x3                 ; round toward zero (truncate) (_MM_FROUND_TO_ZERO = 0x3)
    .return:
        retn
$endp
}

macro @@rzero.sse.fpu
{
$usprocf @@rzero

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@rzero.enter.fpu

        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@rzero.fpu
{
$usprocf @@rzero

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0F3F                 ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rzero.sse4
$else
  @@rzero.sse.fpu
$end
$else
  @@rzero.fpu
$end

; ------------------------------------------------------------------------------

; rzero delta
; double derzero ( double x )
; derzero(x) = x - rzero(x)

macro @@derzero.sse4
{
$usprocf @@derzero

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm1, xmm0, 0x3                 ; round toward zero (truncate) (_MM_FROUND_TO_ZERO = 0x3)
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@derzero.sse.fpu
{
$usprocf @@derzero

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rzero.enter.fpu
        call    eax                             ; st0 = rzero(x) | st1 = x
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@derzero.fpu
{
$usprocf @@derzero

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rzero.enter
        call    eax                             ; st0 = rzero(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@derzero.sse4
$else
  @@derzero.sse.fpu
$end
$else
  @@derzero.fpu
$end

; ------------------------------------------------------------------------------

; round x toward infinity
;
; rinf ( 2.1) =  3
; rinf ( 2.5) =  3
; rinf ( 2.9) =  3
; rinf ( 5.1) =  6
; rinf (-2.1) = -3
; rinf (-2.5) = -3
; rinf (-2.9) = -3
; rinf (-5.1) = -6

macro @@rinf.sse4
{
$usprocf @@rinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm1, xmm1
        comisd  xmm0, xmm1                      ; compare x to 0
        jae    .x.ge.0
    .x.lt.0:
        roundsd xmm0, xmm0, 0x1                 ; round down (toward -inf) (_MM_FROUND_TO_NEG_INF = 0x1)
        jmp    .return
    .x.ge.0:
        roundsd xmm0, xmm0, 0x2                 ; round up (toward +inf) (_MM_FROUND_TO_POS_INF = 0x2)
    .return:
        retn
$endp
}

macro @@rinf.sse.fpu
{
$usprocf @@rinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        ftst
        fnjge  .x.ge.0
    .x.lt.0:
        @@.fpu.cw.assign 0x073F                 ; 00000111 00111111 ; round toward -infinity, full precision, mask all exceptions
        jmp    .round
    .x.ge.0:
        @@.fpu.cw.assign 0x0B3F                 ; 00001011 00111111 ; round toward +infinity, full precision, mask all exceptions
    .round:
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@rinf.enter.fpu

        ftst
        fnjge  .x.ge.0
    .x.lt.0:
        @@.fpu.cw.assign 0x073F                 ; 00000111 00111111 ; round toward -infinity, full precision, mask all exceptions
        jmp    .round
    .x.ge.0:
        @@.fpu.cw.assign 0x0B3F                 ; 00001011 00111111 ; round toward +infinity, full precision, mask all exceptions
    .round:
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@rinf.fpu
{
$usprocf @@rinf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        ftst
        fnjge  .x.ge.0
    .x.lt.0:
        @@.fpu.cw.assign 0x073F                 ; 00000111 00111111 ; round toward -infinity, full precision, mask all exceptions
        jmp    .round
    .x.ge.0:
        @@.fpu.cw.assign 0x0B3F                 ; 00001011 00111111 ; round toward +infinity, full precision, mask all exceptions
    .round:
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rinf.sse4
$else
  @@rinf.sse.fpu
$end
$else
  @@rinf.fpu
$end

; ------------------------------------------------------------------------------

; rinf delta
; double derinf ( double x )
; derinf(x) = x - rinf(x)

macro @@derinf.sse4
{
$usprocf @@derinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        xorpd   xmm1, xmm1
        comisd  xmm0, xmm1                      ; compare x to 0
        jae    .x.ge.0
    .x.lt.0:
        roundsd xmm1, xmm0, 0x1                 ; round down (toward -inf) (_MM_FROUND_TO_NEG_INF = 0x1)
        jmp    .leave
    .x.ge.0:
        roundsd xmm1, xmm0, 0x2                 ; round up (toward +inf) (_MM_FROUND_TO_POS_INF = 0x2)
    .leave:
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@derinf.sse.fpu
{
$usprocf @@derinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rinf.enter.fpu
        call    eax                             ; st0 = rinf(x) | st1 = x
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@derinf.fpu
{
$usprocf @@derinf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rinf.enter
        call    eax                             ; st0 = rinf(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@derinf.sse4
$else
  @@derinf.sse.fpu
$end
$else
  @@derinf.fpu
$end

; ------------------------------------------------------------------------------

; round x toward +infinity
; ceil
;
; rpinf ( 2.1) =  3
; rpinf ( 2.5) =  3
; rpinf ( 2.9) =  3
; rpinf ( 5.1) =  6
; rpinf (-2.1) = -2
; rpinf (-2.5) = -2
; rpinf (-2.9) = -2
; rpinf (-5.1) = -5

macro @@rpinf.sse4
{
$usprocf @@rpinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm0, xmm0, 0x2                 ; round up (toward +inf) (_MM_FROUND_TO_POS_INF = 0x2)
    .return:
        retn
$endp
}

macro @@rpinf.sse.fpu
{
$usprocf @@rpinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x0B3F                 ; 00001011 00111111 ; round toward +infinity, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@rpinf.enter.fpu

        @@.fpu.cw.assign 0x0B3F                 ; 00001011 00111111 ; round toward +infinity, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@rpinf.fpu
{
$usprocf @@rpinf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x0B3F                 ; 00001011 00111111 ; round toward +infinity, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rpinf.sse4
$else
  @@rpinf.sse.fpu
$end
$else
  @@rpinf.fpu
$end

; ------------------------------------------------------------------------------

; rpinf delta
; double derpinf ( double x )
; derpinf(x) = x - rpinf(x)

macro @@derpinf.sse4
{
$usprocf @@derpinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm1, xmm0, 0x2                 ; round up (toward +inf) (_MM_FROUND_TO_POS_INF = 0x2)
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@derpinf.sse.fpu
{
$usprocf @@derpinf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rpinf.enter.fpu
        call    eax                             ; st0 = rpinf(x) | st1 = x
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@derpinf.fpu
{
$usprocf @@derpinf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rpinf.enter
        call    eax                             ; st0 = rpinf(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@derpinf.sse4
$else
  @@derpinf.sse.fpu
$end
$else
  @@derpinf.fpu
$end

; ------------------------------------------------------------------------------

; round x toward -infinity
; floor
;
; rninf ( 2.1) =  2
; rninf ( 2.5) =  2
; rninf ( 2.9) =  2
; rninf ( 5.1) =  5
; rninf (-2.1) = -3
; rninf (-2.5) = -3
; rninf (-2.9) = -3
; rninf (-5.1) = -6

macro @@rninf.sse4
{
$usprocf @@rninf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm0, xmm0, 0x1                 ; round down (toward -inf) (_MM_FROUND_TO_NEG_INF = 0x1)
    .return:
        retn
$endp
}

macro @@rninf.sse.fpu
{
$usprocf @@rninf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        @@.fpu.cw.assign 0x073F                 ; 00000111 00111111 ; round toward -infinity, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        @@.fstp.xmm0
        retn
$endp

$asprocf @@rninf.enter.fpu

        @@.fpu.cw.assign 0x073F                 ; 00000111 00111111 ; round toward -infinity, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

macro @@rninf.fpu
{
$usprocf @@rninf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fpu.cw.assign 0x073F                 ; 00000111 00111111 ; round toward -infinity, full precision, mask all exceptions
        frndint
        @@.fpu.cw.restore                       ; restore control word
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@rninf.sse4
$else
  @@rninf.sse.fpu
$end
$else
  @@rninf.fpu
$end

; ------------------------------------------------------------------------------

; rninf delta
; double derninf ( double x )
; derninf(x) = x - rninf(x)

macro @@derninf.sse4
{
$usprocf @@derninf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        roundsd xmm1, xmm0, 0x1                 ; round down (toward -inf) (_MM_FROUND_TO_NEG_INF = 0x1)
        subsd   xmm0, xmm1
    .return:
        retn
$endp
}

macro @@derninf.sse.fpu
{
$usprocf @@derninf

        movsd   xmm0, qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        @@.fld.xmm0
        ;
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rninf.enter.fpu
        call    eax                             ; st0 = rninf(x) | st1 = x
        fsubp
    .return:
        @@.fstp.xmm0
        retn
$endp
}

macro @@derninf.fpu
{
$usprocf @@derninf

        fld     qword [esp]
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        fld     st0                             ; st0 = x | st1 = x
        mov     eax, @@rninf.enter
        call    eax                             ; st0 = rninf(x) | st1 = x
        fsubp
    .return:
        retn
$endp
}

$ifdef _SSEX
$ifdef _SSE4.1
  @@derninf.sse4
$else
  @@derninf.sse.fpu
$end
$else
  @@derninf.fpu
$end

; ------------------------------------------------------------------------------
