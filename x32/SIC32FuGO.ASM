
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; native functions (goto functions)

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; goto (label)
; unconditional jump
; edx = offset of address to jump
$usprocf @@goto

        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; xgoto (label_0, label_1, ..., label_n, index)
; jump by index

$usprocf @@xgoto

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; rxgoto (label_n, ..., label_1, label_0, index)
; jump by reverse index

$usprocf @@rxgoto

        nop
;       retn
$endp

; ------------------------------------------------------------------------------

; goto.if.x32 (label)
; conditional jump
;
; jump to label if DLL is x32
;
; edx = offset of address to jump
$usprocf @@goto.if.x32

        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.n32 (label)
; conditional jump
;
; jump to label if DLL is not x32
;
; edx = offset of address to jump
$usprocf @@goto.if.n32

;       jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.x64 (label)
; conditional jump
;
; jump to label if DLL is x64
;
; edx = offset of address to jump
$usprocf @@goto.if.x64

;       jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.n64 (label)
; conditional jump
;
; jump to label if DLL is not x64
;
; edx = offset of address to jump
$usprocf @@goto.if.n64

        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; goto.if.true (label, x)
; conditional jump
;
; jump to label if x <> 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.true.sse
{
$usprocf @@goto.if.true

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .jump                            ; jump if x <> 0
        jp     .jump                            ; jump if x <> 0
        jmp    .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.true.fpu
{
$usprocf @@goto.if.true

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjz   .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.true.sse
$else
  @@goto.if.true.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.true (label, x)
; conditional jump
;
; jump to label if x <> 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.true

        cmp     dword [eax], 0                  ; compare x to 0
        jz     .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.true (label, x)
; conditional jump
;
; jump to label if x <> 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.true

        test    eax, eax                        ; compare x to 0
        jz     .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.false (label, x)
; conditional jump
;
; jump to label if x = 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.false.sse
{
$usprocf @@goto.if.false

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .return                          ; return if x <> 0
        jp     .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.false.fpu
{
$usprocf @@goto.if.false

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjnz  .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.false.sse
$else
  @@goto.if.false.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.false (label, x)
; conditional jump
;
; jump to label if x = 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.false

        cmp     dword [eax], 0                  ; compare x to 0
        jnz    .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.false (label, x)
; conditional jump
;
; jump to label if x = 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.false

        test    eax, eax                        ; compare x to 0
        jnz    .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.z (label, x)
; conditional jump
;
; jump to label if x = 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.z.sse
{
$usprocf @@goto.if.z

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .return                          ; return if x <> 0
        jp     .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.z.fpu
{
$usprocf @@goto.if.z

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjne  .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.z.sse
$else
  @@goto.if.z.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.z (label, x)
; conditional jump
;
; jump to label if x = 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.z

        cmp     dword [eax], 0                  ; compare x to 0
        jne    .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.z (label, x)
; conditional jump
;
; jump to label if x = 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.z

        test    eax, eax                        ; compare x to 0
        jnz    .return                          ; return if x <> 0

    .jump:                                      ; x = 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.nz (label, x)
; conditional jump
;
; jump to label if x <> 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.nz.sse
{
$usprocf @@goto.if.nz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        ucomisd xmm0, xmm5                      ; compare x to 0
        jnz    .jump                            ; jump if x <> 0
        jp     .jump                            ; jump if x <> 0
        jmp    .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.nz.fpu
{
$usprocf @@goto.if.nz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnje   .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.nz.sse
$else
  @@goto.if.nz.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.nz (label, x)
; conditional jump
;
; jump to label if x <> 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.nz

        cmp     dword [eax], 0                  ; compare x to 0
        je     .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.nz (label, x)
; conditional jump
;
; jump to label if x <> 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.nz

        test    eax, eax                        ; compare x to 0
        jz     .return                          ; return if x = 0

    .jump:                                      ; x <> 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.az (label, x)
; conditional jump
;
; jump to label if x > 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.az.sse
{
$usprocf @@goto.if.az

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jbe    .return                          ; return if x <= 0

    .jump:                                      ; x > 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.az.fpu
{
$usprocf @@goto.if.az

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjle  .return                          ; return if x <= 0

    .jump:                                      ; x > 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.az.sse
$else
  @@goto.if.az.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.az (label, x)
; conditional jump
;
; jump to label if x > 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.az

        cmp     dword [eax], 0                  ; compare x to 0
        jle    .return                          ; return if x <= 0

    .jump:                                      ; x > 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.az (label, x)
; conditional jump
;
; jump to label if x > 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.az

        cmp     eax, 0                          ; compare x to 0
        jle    .return                          ; return if x <= 0

    .jump:                                      ; x > 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.aez (label, x)
; conditional jump
;
; jump to label if x >= 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.aez.sse
{
$usprocf @@goto.if.aez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jb     .return                          ; return if x < 0

    .jump:                                      ; x >= 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.aez.fpu
{
$usprocf @@goto.if.aez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjl   .return                          ; return if x < 0

    .jump:                                      ; x >= 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.aez.sse
$else
  @@goto.if.aez.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.aez (label, x)
; conditional jump
;
; jump to label if x >= 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.aez

        cmp     dword [eax], 0                  ; compare x to 0
        jl     .return                          ; return if x < 0

    .jump:                                      ; x >= 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.aez (label, x)
; conditional jump
;
; jump to label if x >= 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.aez

        cmp     eax, 0                          ; compare x to 0
        jl     .return                          ; return if x < 0

    .jump:                                      ; x >= 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.bz (label, x)
; conditional jump
;
; jump to label if x < 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.bz.sse
{
$usprocf @@goto.if.bz

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        jae    .return                          ; return if x >= 0

    .jump:                                      ; x < 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.bz.fpu
{
$usprocf @@goto.if.bz

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjge  .return                          ; return if x >= 0

    .jump:                                      ; x < 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.bz.sse
$else
  @@goto.if.bz.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.bz (label, x)
; conditional jump
;
; jump to label if x < 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.bz

        cmp     dword [eax], 0                  ; compare x to 0
        jge    .return                          ; return if x >= 0

    .jump:                                      ; x < 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.bz (label, x)
; conditional jump
;
; jump to label if x < 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.bz

        cmp     eax, 0                          ; compare x to 0
        jge    .return                          ; return if x >= 0

    .jump:                                      ; x < 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.if.bez (label, x)
; conditional jump
;
; jump to label if x <= 0
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.bez.sse
{
$usprocf @@goto.if.bez

        movsd   xmm0, qword [esp]               ; xmm0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        xorpd   xmm5, xmm5                      ; xmm5 = 0
        comisd  xmm0, xmm5                      ; compare x to 0
        ja     .return                          ; return if x > 0

    .jump:                                      ; x <= 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

macro @@goto.if.bez.fpu
{
$usprocf @@goto.if.bez

        fld     qword [esp]                     ; st0 = x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        add     esp, 8

        ftst                                    ; compare x to 0
        fstp    st0
        fnjg   .return                          ; return if x > 0

    .jump:                                      ; x <= 0
        jmp     dword [edx]
    .return:
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.bez.sse
$else
  @@goto.if.bez.fpu
$end

; ------------------------------------------------------------------------------

; goto.int.if.bez (label, x)
; conditional jump
;
; jump to label if x <= 0
;
; edx = offset of address to jump
; eax = offset of x

$usprocf @@goto.int.if.bez

        cmp     dword [eax], 0                  ; compare x to 0
        jg     .return                          ; return if x > 0

    .jump:                                      ; x <= 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------

; goto.reg.if.bez (label, x)
; conditional jump
;
; jump to label if x <= 0
;
; edx = offset of address to jump
; eax = x

$usprocf @@goto.reg.if.bez

        cmp     eax, 0                          ; compare x to 0
        jg     .return                          ; return if x > 0

    .jump:                                      ; x <= 0
        jmp     dword [edx]
    .return:
        retn
$endp

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------

; goto.if.or (label, x, Y1, Y2, ..., Yn)
; conditional jump
; variable number of arguments
; ecx -> argument count, min=3
;
; jump to label if (x = Y1) or (x = Y2) or ... or (x = Yn)
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.or.sse
{
$usprocf @@goto.if.or

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .return                          ; return if no matches
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]

    .jump:                                      ; some x = Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        jmp     dword [edx]

    .return:
        add     esp, ecx
        retn
$endp
}

macro @@goto.if.or.fpu
{
$usprocf @@goto.if.or

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .return                          ; return if no matches
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnjne  .next.arg                        ; test next argument if x <> Y[i]

    .jump:                                      ; some x = Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        fstp    st0                             ; pop x
        jmp     dword [edx]

    .return:
        add     esp, ecx
        fstp    st0                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.or.sse
$else
  @@goto.if.or.fpu
$end

; ------------------------------------------------------------------------------

; goto.if.nor (label, x, Y1, Y2, ..., Yn)
; conditional jump
; variable number of arguments
; ecx -> argument count, min=3
;
; jump to label if (x <> Y1) and (x <> Y2) and ... and (x <> Yn)
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.nor.sse
{
$usprocf @@goto.if.nor

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .jump                            ; jump on complete match
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .next.arg                        ; test next argument if x <> Y[i]
        jp     .next.arg                        ; test next argument if x <> Y[i]
        jmp    .return                          ; return if x = Y[i]

    .jump:                                      ; all x <> Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        jmp     dword [edx]

    .return:
        add     esp, ecx
        retn
$endp
}

macro @@goto.if.nor.fpu
{
$usprocf @@goto.if.nor

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .jump                            ; jump on complete match
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnje   .return                          ; return if x = Y[i]
        jmp    .next.arg                        ; test next argument if x <> Y[i]

    .jump:                                      ; all x <> Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        fstp    st0                             ; pop x
        jmp     dword [edx]

    .return:
        add     esp, ecx
        fstp    st0                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.nor.sse
$else
  @@goto.if.nor.fpu
$end

; ------------------------------------------------------------------------------

; goto.if.and (label, x, Y1, Y2, ..., Yn)
; conditional jump
; variable number of arguments
; ecx -> argument count, min=3
;
; jump to label if (x = Y1) and (x = Y2) and ... and (x = Yn)
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.and.sse
{
$usprocf @@goto.if.and

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .jump                            ; jump on complete match
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .return                          ; return if x <> Y[i]
        jp     .return                          ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .jump:                                      ; all x = Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        jmp     dword [edx]

    .return:
        add     esp, ecx
        retn
$endp
}

macro @@goto.if.and.fpu
{
$usprocf @@goto.if.and

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .jump                            ; jump on complete match
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnjne  .return                          ; return if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .jump:                                      ; all x = Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        fstp    st0                             ; pop x
        jmp     dword [edx]

    .return:
        add     esp, ecx
        fstp    st0                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.and.sse
$else
  @@goto.if.and.fpu
$end

; ------------------------------------------------------------------------------

; goto.if.nand (label, x, Y1, Y2, ..., Yn)
; conditional jump
; variable number of arguments
; ecx -> argument count, min=3
;
; jump to label if (x <> Y1) or (x <> Y2) or ... or (x <> Yn)
;
; edx = offset of address to jump
; esp = x

macro @@goto.if.nand.sse
{
$usprocf @@goto.if.nand

        movsd   xmm0, qword [esp]               ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .return                          ; return if no matches
        ucomisd xmm0, qword [esp + edx]         ; compare x to Y[i]
        jnz    .jump                            ; jump if x <> Y[i]
        jp     .jump                            ; jump if x <> Y[i]
        jmp    .next.arg                        ; test next argument if x = Y[i]

    .jump:                                      ; some x <> Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        jmp     dword [edx]

    .return:
        add     esp, ecx
        retn
$endp
}

macro @@goto.if.nand.fpu
{
$usprocf @@goto.if.nand

        fld     qword [esp]                     ; load x
        @@discard                               ; optimizer directive - initial [xsp] values can be discarded
    .enter:
        mov     [esp], edx                      ; save label
        lea     ecx, [ecx * 8 - 8]
        xor     edx, edx
    .next.arg:
        add     edx, 8
        cmp     edx, ecx
        je     .return                          ; return if no matches
        fcom    qword [esp + edx]               ; compare x to Y[i]
        fnje   .next.arg                        ; test next argument if x = Y[i]

    .jump:                                      ; some x <> Y[i]
        mov     edx, [esp]                      ; restore label
        add     esp, ecx
        fstp    st0                             ; pop x
        jmp     dword [edx]

    .return:
        add     esp, ecx
        fstp    st0                             ; pop x
        retn
$endp
}

$ifdef _SSEX
  @@goto.if.nand.sse
$else
  @@goto.if.nand.fpu
$end

; ------------------------------------------------------------------------------
