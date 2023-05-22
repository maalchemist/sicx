
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; common compiler macros

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

; optimizer directive
; initial [xsp] values can be discarded
macro @@discard
{
        nop                                     ; 0x90
}

; ------------------------------------------------------------------------------

; bound check of memory buffer allocated for code segment
; -> [.cspace] : free bytes available for code
; -> binc      : byte count to add to code
; -> exit      : jump to <exit> on out of bounds
; <- [.cspace] : free bytes available for code

macro @@bound binc, exit
{
        sub     [.cspace], binc
        js      exit
}

; @@bound n
; ...
; add rdi, n

; ------------------------------------------------------------------------------

; range check of memory buffer allocated for code segment
; -> [.cspace] : free bytes available for code
; -> binc      : byte count to add to code
; -> exit      : jump to <exit> on out of bounds

macro @@range binc, exit
{
        cmp     [.cspace], binc
        jl      exit
}

; @@range n
; @@xshl rdi, n
; ...
; @@xshr rdi, n

; ------------------------------------------------------------------------------

; -> [.cspace] : free bytes available for code
; <- [.cspace] : free bytes available for code

macro @@xshl xreg, value, reg
{
    if (reg eq)
        sub     xreg, value
        add     [.cspace], value
    else
        mov     reg, value
        sub     xreg, reg
        add     [.cspace], reg
    end if
}

; ------------------------------------------------------------------------------

; -> [.cspace] : free bytes available for code
; <- [.cspace] : free bytes available for code

macro @@xshr xreg, value, exit
{
        add     xreg, value
        sub     [.cspace], value
      if ~ (exit eq)
        js      exit
      end if
}

; ------------------------------------------------------------------------------

; d - destination (edi or rdi)
; v - value
; b - bytes to copy

macro @copy.q d, v, b
{
        mov     [d], qword v
      if b eq
        add     d, 8
      else
        add     d, b
      end if
}

macro @copy.d d, v, b
{
        mov     [d], dword v
      if b eq
        add     d, 4
      else
        add     d, b
      end if
}

macro @copy.w d, v, b
{
        mov     [d], word v
      if b eq
        add     d, 2
      else
        add     d, b
      end if
}

macro @copy.b d, v
{
        mov     [d], byte v
        inc     d
}

; ------------------------------------------------------------------------------

macro @@_MOV_EDX V
; ----------------------
; MOV EDX, FF+ | BA FF+
; ----------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [xdi + 0], byte 0xBA
    $ifdef _X64
        push    rax
        mov     rax, qword V
        mov     dword [xdi + 1], eax
        pop     rax
    $else
        push    dword V
        pop     dword [xdi + 1]
    $end
        add     xdi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_RDX V
; ------------------------
; MOV RDX, FF+ | 48BA FF+
; ------------------------
{
        local  .exit

        @@bound 10, .exit
        mov     [xdi + 0], word 0xBA48
        push    qword V
        pop     qword [xdi + 2]
        add     xdi, 10
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_EBX V
; ----------------------
; MOV EBX, FF+ | BB FF+
; ----------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [xdi + 0], byte 0xBB
    $ifdef _X64
        push    rax
        mov     rax, qword V
        mov     dword [xdi + 1], eax
        pop     rax
    $else
        push    dword V
        pop     dword [xdi + 1]
    $end
        add     xdi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_RBX V
; ------------------------
; MOV RBX, FF+ | 48BB FF+
; ------------------------
{
        local  .exit

        @@bound 10, .exit
        mov     [xdi + 0], word 0xBB48
        push    qword V
        pop     qword [xdi + 2]
        add     xdi, 10
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_XOR_EAX_EAX
; --------------------
; XOR EAX, EAX | 31C0
; --------------------
{
        local  .exit

        @@bound 2, .exit
        mov     [edi], word 0xC031
        add     edi, 2
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_XOR_RAX_RAX
; ----------------------
; XOR RAX, RAX | 4831C0
; ----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [rdi + 0], byte 0x48
        mov     [rdi + 1], word 0xC031
        add     rdi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_POP_ECX
; --------------------
; POP  ECX      | 59
; --------------------
{
        local  .exit

        @@bound 1, .exit
        mov     [edi], byte 0x59
        add     edi, 1
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_POP_RCX
; ----------------------
; POP  RCX      | 59
; ----------------------
{
        local  .exit

        @@bound 1, .exit
        mov     [edi], byte 0x59
        add     edi, 1
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_XORPD_XMM0_XMM0
; ----------------------------
; XORPD XMM0, XMM0 | 660F57C0
; ----------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [xdi], dword 0xC0570F66
        add     xdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_XMM0_QW_ESP
; --------------------------------------
; MOVSD XMM0, QWORD [ESP] | F20F1004 24
; --------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [edi + 0], dword 0x04100FF2
        mov     [edi + 4], byte 0x24
        add     edi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_XMM0_QW_RSP
; --------------------------------------
; MOVSD XMM0, QWORD [RSP] | F20F1004 24
; --------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [rdi + 0], dword 0x04100FF2
        mov     [rdi + 4], byte 0x24
        add     rdi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_CVTSI2SD_XMM0_DW_ESP
; -----------------------------------------
; CVTSI2SD XMM0, DWORD [ESP] | F20F2A04 24
; -----------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [edi + 0], dword 0x042A0FF2
        mov     [edi + 4], byte 0x24
        add     edi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_CVTSI2SD_XMM0_QW_RSP
; -------------------------------------------
; CVTSI2SD XMM0, QWORD [RSP] | F2480F2A 0424
; -------------------------------------------
{
        local  .exit

        @@bound 6, .exit
        mov     [rdi + 0], dword 0x2A0F48F2
        mov     [rdi + 4], word 0x2404
        add     rdi, 6
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_ESP_XMM0
; --------------------------------------
; MOVSD QWORD [ESP], XMM0 | F20F1104 24
; --------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [edi + 0], dword 0x04110FF2
        mov     [edi + 4], byte 0x24
        add     edi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_RSP_XMM0
; --------------------------------------
; MOVSD QWORD [RSP], XMM0 | F20F1104 24
; --------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [rdi + 0], dword 0x04110FF2
        mov     [rdi + 4], byte 0x24
        add     rdi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_ESP_RT1
; --------------------------------------
; MOVSD QWORD [ESP], XMM0 | F20F1104 24
; --------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [edi + 0], dword 0x04110FF2
        mov     [edi + 4], byte 0x24
        add     edi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_RSP_RT1
; --------------------------------------
; MOVSD QWORD [RSP], XMM0 | F20F1104 24
; --------------------------------------
{
        local  .exit

        @@bound 5, .exit
        mov     [rdi + 0], dword 0x04110FF2
        mov     [rdi + 4], byte 0x24
        add     rdi, 5
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_ESP_RT2
; ------------------------------------------
; MOVSD QWORD [ESP+8], XMM1 | F20F114C 2408
; MOVSD QWORD [ESP+0], XMM0 | F20F1104 24
; ------------------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [edi + 00], dword 0x4C110FF2
        mov     [edi + 04], word 0x0824
        mov     [edi + 06], dword 0x04110FF2
        mov     [edi + 10], byte 0x24
        add     edi, 11
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_RSP_RT2
; ------------------------------------------
; MOVSD QWORD [RSP+8], XMM1 | F20F114C 2408
; MOVSD QWORD [RSP+0], XMM0 | F20F1104 24
; ------------------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [rdi + 00], dword 0x4C110FF2
        mov     [rdi + 04], word 0x0824
        mov     [rdi + 06], dword 0x04110FF2
        mov     [rdi + 10], byte 0x24
        add     rdi, 11
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_ESP_RT3
; -------------------------------------------
; MOVSD QWORD [ESP+16], XMM2 | F20F1154 2410
; MOVSD QWORD [ESP+08], XMM1 | F20F114C 2408
; MOVSD QWORD [ESP+00], XMM0 | F20F1104 24
; -------------------------------------------
{
        local  .exit

        @@bound 17, .exit
        mov     [edi + 00], dword 0x54110FF2
        mov     [edi + 04], word 0x1024
        mov     [edi + 06], dword 0x4C110FF2
        mov     [edi + 10], word 0x0824
        mov     [edi + 12], dword 0x04110FF2
        mov     [edi + 16], byte 0x24
        add     edi, 17
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_RSP_RT3
; -------------------------------------------
; MOVSD QWORD [RSP+16], XMM2 | F20F1154 2410
; MOVSD QWORD [RSP+08], XMM1 | F20F114C 2408
; MOVSD QWORD [RSP+00], XMM0 | F20F1104 24
; -------------------------------------------
{
        local  .exit

        @@bound 17, .exit
        mov     [rdi + 00], dword 0x54110FF2
        mov     [rdi + 04], word 0x1024
        mov     [rdi + 06], dword 0x4C110FF2
        mov     [rdi + 10], word 0x0824
        mov     [rdi + 12], dword 0x04110FF2
        mov     [rdi + 16], byte 0x24
        add     rdi, 17
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_ESP_RT4
; -------------------------------------------
; MOVSD QWORD [ESP+24], XMM3 | F20F115C 2418
; MOVSD QWORD [ESP+16], XMM2 | F20F1154 2410
; MOVSD QWORD [ESP+08], XMM1 | F20F114C 2408
; MOVSD QWORD [ESP+00], XMM0 | F20F1104 24
; -------------------------------------------
{
        local  .exit

        @@bound 23, .exit
        mov     [edi + 00], dword 0x5C110FF2
        mov     [edi + 04], word 0x1824
        mov     [edi + 06], dword 0x54110FF2
        mov     [edi + 10], word 0x1024
        mov     [edi + 12], dword 0x4C110FF2
        mov     [edi + 16], word 0x0824
        mov     [edi + 18], dword 0x04110FF2
        mov     [edi + 22], byte 0x24
        add     edi, 23
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOVSD_QW_RSP_RT4
; -------------------------------------------
; MOVSD QWORD [RSP+24], XMM3 | F20F115C 2418
; MOVSD QWORD [RSP+16], XMM2 | F20F1154 2410
; MOVSD QWORD [RSP+08], XMM1 | F20F114C 2408
; MOVSD QWORD [RSP+00], XMM0 | F20F1104 24
; -------------------------------------------
{
        local  .exit

        @@bound 23, .exit
        mov     [rdi + 00], dword 0x5C110FF2
        mov     [rdi + 04], word 0x1824
        mov     [rdi + 06], dword 0x54110FF2
        mov     [rdi + 10], word 0x1024
        mov     [rdi + 12], dword 0x4C110FF2
        mov     [rdi + 16], word 0x0824
        mov     [rdi + 18], dword 0x04110FF2
        mov     [rdi + 22], byte 0x24
        add     rdi, 23
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_XORPD_XMM0_XMM0
; -------------------------------
; XORPD XMM0, XMM0 | 66 0F 57 C0
; -------------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [xdi], dword 0xC0570F66
        add     xdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FLDZ
; ---------------
; FLDZ | D9EE
; ---------------
{
        local  .exit

        @@bound 2, .exit
        mov     [xdi], word 0xEED9
        add     xdi, 2
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FLD_QW_ESP
; -------------------------
; FLD QWORD [ESP] | DD0424
; -------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x04DD
        mov     [edi + 2], byte 0x24
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FLD_QW_RSP
; -------------------------
; FLD QWORD [RSP] | DD0424
; -------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [rdi + 0], word 0x04DD
        mov     [rdi + 2], byte 0x24
        add     rdi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FLD_QW_ESP_p8
; ------------------------------
; FLD QWORD [ESP+8] | DD4424 08
; ------------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [edi], dword 0x082444DD
        add     edi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FLD_QW_RSP_p8
; ------------------------------
; FLD QWORD [RSP+8] | DD4424 08
; ------------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x082444DD
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FILD_DW_ESP
; --------------------------
; FILD DWORD [ESP] | DB0424
; --------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x04DB
        mov     [edi + 2], byte 0x24
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FILD_QW_RSP
; --------------------------
; FILD QWORD [RSP] | DF2C24
; --------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [rdi + 0], word 0x2CDF
        mov     [rdi + 2], byte 0x24
        add     rdi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_ST0
; --------------------------
; FSTP ST0 | DD D8
; --------------------------
{
        local  .exit

        @@bound 2, .exit
        mov     [xdi], word 0xD8DD
        add     xdi, 2
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FFREE_ST0
; --------------------------
; FFREE ST0 | DD C0
; --------------------------
{
        local  .exit

        @@bound 2, .exit
        mov     [xdi], word 0xC0DD
        add     xdi, 2
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_ESP
; --------------------------
; FSTP QWORD [ESP] | DD1C24
; --------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x1CDD
        mov     [edi + 2], byte 0x24
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_RSP
; --------------------------
; FSTP QWORD [RSP] | DD1C24
; --------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [rdi + 0], word 0x1CDD
        mov     [rdi + 2], byte 0x24
        add     rdi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_ESP_RT1
; --------------------------
; FSTP QWORD [ESP] | DD1C24
; --------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x1CDD
        mov     [edi + 2], byte 0x24
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_RSP_RT1
; --------------------------
; FSTP QWORD [RSP] | DD1C24
; --------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [rdi + 0], word 0x1CDD
        mov     [rdi + 2], byte 0x24
        add     rdi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_ESP_RT2
; -------------------------------
; FSTP QWORD [ESP+8] | DD5C24 08
; FSTP QWORD [ESP+0] | DD1C24
; -------------------------------
{
        local  .exit

        @@bound 7, .exit
        mov     [edi + 0], dword 0x08245CDD
        mov     [edi + 4], word 0x1CDD
        mov     [edi + 6], byte 0x24
        add     edi, 7
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_RSP_RT2
; -------------------------------
; FSTP QWORD [RSP+8] | DD5C24 08
; FSTP QWORD [RSP+0] | DD1C24
; -------------------------------
{
        local  .exit

        @@bound 7, .exit
        mov     [rdi + 0], dword 0x08245CDD
        mov     [rdi + 4], word 0x1CDD
        mov     [rdi + 6], byte 0x24
        add     rdi, 7
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_ESP_RT3
; --------------------------------
; FSTP QWORD [ESP+16] | DD5C24 10
; FSTP QWORD [ESP+08] | DD5C24 08
; FSTP QWORD [ESP+00] | DD1C24
; --------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [edi + 00], dword 0x10245CDD
        mov     [edi + 04], dword 0x08245CDD
        mov     [edi + 08], word 0x1CDD
        mov     [edi + 10], byte 0x24
        add     edi, 11
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_RSP_RT3
; --------------------------------
; FSTP QWORD [RSP+16] | DD5C24 10
; FSTP QWORD [RSP+08] | DD5C24 08
; FSTP QWORD [RSP+00] | DD1C24
; --------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [rdi + 00], dword 0x10245CDD
        mov     [rdi + 04], dword 0x08245CDD
        mov     [rdi + 08], word 0x1CDD
        mov     [rdi + 10], byte 0x24
        add     rdi, 11
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_ESP_RT4
; --------------------------------
; FSTP QWORD [ESP+24] | DD5C24 18
; FSTP QWORD [ESP+16] | DD5C24 10
; FSTP QWORD [ESP+08] | DD5C24 08
; FSTP QWORD [ESP+00] | DD1C24
; --------------------------------
{
        local  .exit

        @@bound 15, .exit
        mov     [edi + 00], dword 0x18245CDD
        mov     [edi + 04], dword 0x10245CDD
        mov     [edi + 08], dword 0x08245CDD
        mov     [edi + 12], word 0x1CDD
        mov     [edi + 14], byte 0x24
        add     edi, 15
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FSTP_QW_RSP_RT4
; --------------------------------
; FSTP QWORD [RSP+24] | DD5C24 18
; FSTP QWORD [RSP+16] | DD5C24 10
; FSTP QWORD [RSP+08] | DD5C24 08
; FSTP QWORD [RSP+00] | DD1C24
; --------------------------------
{
        local  .exit

        @@bound 15, .exit
        mov     [rdi + 00], dword 0x18245CDD
        mov     [rdi + 04], dword 0x10245CDD
        mov     [rdi + 08], dword 0x08245CDD
        mov     [rdi + 12], word 0x1CDD
        mov     [rdi + 14], byte 0x24
        add     rdi, 15
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FST_QW_ESP
; -------------------------
; FST QWORD [ESP] | DD1424
; -------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x14DD
        mov     [edi + 2], byte 0x24
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FST_QW_RSP
; -------------------------
; FST QWORD [RSP] | DD1424
; -------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [rdi + 0], word 0x14DD
        mov     [rdi + 2], byte 0x24
        add     rdi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FST_QW_ESP_p8
; ------------------------------
; FST QWORD [ESP+8] | DD5424 08
; ------------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [edi], dword 0x082454DD
        add     edi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_FST_QW_RSP_p8
; ------------------------------
; FST QWORD [RSP+8] | DD5424 08
; ------------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x082454DD
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_DW_ESP_EAX
; ------------------------------
; MOV DWORD [ESP], EAX | 890424
; ------------------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x0489
        mov     [edi + 2], byte 0x24
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_QW_RSP_RAX
; --------------------------------
; MOV QWORD [RSP], RAX | 48890424
; --------------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [edi], dword 0x24048948
        add     edi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_ESP_EDX
; ----------------------------------
; ADD ESP, FF       | 83C4 FF
; ADD ESP, FFFFFFFF | 81C4 FFFFFFFF
; ----------------------------------
{
        local  .exit, .stack.byte, .stack.dword

        cmp     edx, +127
        jg     .stack.dword
        cmp     edx, -128
        jl     .stack.dword
   .stack.byte:                                ; -128 <= EDX <= 127
        ; --------------------------------------
        ; ADD ESP, FF |   83C4 FF
        ; --------------------------------------
        @@bound 3, .exit
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], dl
        add     edi, 3
        jmp    .exit
   .stack.dword:                               ; (EDX < -128) or (EDX > 127)
        ; --------------------------------------
        ; ADD ESP, FFFFFFFF |   81C4 FFFFFFFF
        ; --------------------------------------
        @@bound 6, .exit
        mov     [edi + 0], word 0xC481
        mov     [edi + 2], edx
        add     edi, 6
;       jmp    .exit

   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_RSP_RDX
; ------------------------------------
; ADD RSP, FF       | 4883C4 FF
; ADD RSP, FFFFFFFF | 4881C4 FFFFFFFF
; ------------------------------------
{
        local  .exit, .stack.byte, .stack.dword

        cmp     rdx, +127
        jg     .stack.dword
        cmp     rdx, -128
        jl     .stack.dword
   .stack.byte:                                ; -128 <= RDX <= 127
        ; --------------------------------------
        ; ADD RSP, FF | 4883C4 FF
        ; --------------------------------------
        @@bound 4, .exit
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], dl
        add     rdi, 4
        jmp    .exit
   .stack.dword:                               ; (RDX < -128) or (RDX > 127)
        ; --------------------------------------
        ; ADD RSP, FFFFFFFF | 4881C4 FFFFFFFF
        ; --------------------------------------
        @@bound 7, .exit
        mov     [rdi + 0], dword 0x00C48148
        mov     [rdi + 3], edx
        add     rdi, 7
;       jmp    .exit

   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_ESP_4
; ----------------------
; ADD ESP, 04 | 83C4 04
; ----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], byte 0x04
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_RSP_4
; ------------------------
; ADD RSP, 04 | 4883C4 04
; ------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x04C48348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_ESP_8
; ----------------------
; ADD ESP, 08 | 83C4 08
; ----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], byte 0x08
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_RSP_8
; ------------------------
; ADD RSP, 08 | 4883C4 08
; ------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x08C48348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_ESP_m8
; -----------------------
; ADD ESP, -08 | 83C4 F8
; -----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], byte 0xF8
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_SUB_ESP_8
; ----------------------
; SUB ESP, 08 | 83EC 08
; ----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xEC83
        mov     [edi + 2], byte 0x08
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_RSP_m8
; -------------------------
; ADD RSP, -08 | 4883C4 F8
; -------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0xF8C48348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_SUB_RSP_8
; ------------------------
; SUB RSP, 08 | 4883EC 08
; ------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x08EC8348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_ESP_16
; ----------------------
; ADD ESP, 16 | 83C4 10
; ----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], byte 0x10
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_RSP_16
; ------------------------
; ADD RSP, 16 | 4883C4 10
; ------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x10C48348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_ESP_m16
; -----------------------
; ADD ESP, -16 | 83C4 F0
; -----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], byte 0xF0
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_SUB_ESP_16
; ----------------------
; SUB ESP, 16 | 83EC 10
; ----------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xEC83
        mov     [edi + 2], byte 0x10
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ADD_RSP_m16
; -------------------------
; ADD RSP, -16 | 4883C4 F0
; -------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0xF0C48348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_SUB_RSP_16
; ------------------------
; SUB RSP, 16 | 4883EC 10
; ------------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x10EC8348
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_PUSH_EAX
; ------------------------------
; PUSH EAX | 50
; ------------------------------
{
        local  .exit

        @@bound 1, .exit
        mov     [edi], byte 0x50
        add     edi, 1
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_PUSH_RAX
; ------------------------------
; PUSH RAX | 50
; ------------------------------
{
        local  .exit

        @@bound 1, .exit
        mov     [rdi], byte 0x50
        add     rdi, 1
   .exit:
}

; ------------------------------------------------------------------------------

; push double variable
; -> vo : variable offset
macro @@_PUSH_VF_32 vo
; ----------------------------------------------
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 10, .exit
    if ~ vo in <ecx, rcx>
        mov     ecx, dword vo                   ; ecx = variable offset
    end if
        mov     [edi + 0], byte 0xB9
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0xFF0471FF
        mov     [edi + 9], byte 0x31
        add     edi, 10
   .exit:
}

; ------------------------------------------------------------------------------

; push 2 double variables
; -> vo : variable offset
macro @@_PUSH_VF2_32 vo
; ----------------------------------------------
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 20, .exit
    if ~ vo in <ecx, rcx>
        mov     ecx, dword vo                   ; ecx = variable offset
    end if
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     [edi + 15], dword 0xFF0471FF
        mov     [edi + 19], byte 0x31
        add     ecx, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        add     edi, 20
   .exit:
}

; ------------------------------------------------------------------------------

; push 3 double variables
; -> vo : variable offset
macro @@_PUSH_VF3_32 vo
; ----------------------------------------------
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 30, .exit
    if ~ vo in <ecx, rcx>
        mov     ecx, dword vo                   ; ecx = variable offset
    end if
        mov     [edi + 20], byte 0xB9
        mov     [edi + 21], ecx
        mov     [edi + 25], dword 0xFF0471FF
        mov     [edi + 29], byte 0x31
        add     ecx, 8
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     [edi + 15], dword 0xFF0471FF
        mov     [edi + 19], byte 0x31
        add     ecx, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        add     edi, 30
   .exit:
}

; ------------------------------------------------------------------------------

; push 4 double variables
; -> vo : variable offset
macro @@_PUSH_VF4_32 vo
; ----------------------------------------------
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; MOV  ECX, OFFSET     | B9 AAAAAAAA
; PUSH DWORD [ECX + 4] | FF71 04
; PUSH DWORD [ECX + 0] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 40, .exit
    if ~ vo in <ecx, rcx>
        mov     ecx, dword vo                   ; ecx = variable offset
    end if
        mov     [edi + 30], byte 0xB9
        mov     [edi + 31], ecx
        mov     [edi + 35], dword 0xFF0471FF
        mov     [edi + 39], byte 0x31
        add     ecx, 8
        mov     [edi + 20], byte 0xB9
        mov     [edi + 21], ecx
        mov     [edi + 25], dword 0xFF0471FF
        mov     [edi + 29], byte 0x31
        add     ecx, 8
        mov     [edi + 10], byte 0xB9
        mov     [edi + 11], ecx
        mov     [edi + 15], dword 0xFF0471FF
        mov     [edi + 19], byte 0x31
        add     ecx, 8
        mov     [edi + 00], byte 0xB9
        mov     [edi + 01], ecx
        mov     [edi + 05], dword 0xFF0471FF
        mov     [edi + 09], byte 0x31
        add     edi, 40
   .exit:
}

; ------------------------------------------------------------------------------

; push double variable
; -> vo : variable offset
macro @@_PUSH_VF_64 vo
; ----------------------------------------------
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 12, .exit
    if ~ vo in <ecx, rcx>
        mov     rcx, qword vo                   ; rcx = variable offset
    end if
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x31FF
        add     rdi, 12
   .exit:
}

; ------------------------------------------------------------------------------

; push 2 double variables
; -> vo : variable offset
macro @@_PUSH_VF2_64 vo
; ----------------------------------------------
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 24, .exit
    if ~ vo in <ecx, rcx>
        mov     rcx, qword vo                   ; rcx = variable offset
    end if
        mov     [rdi + 12], word 0xB948
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x31FF
        add     rcx, 8
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x31FF
        add     rdi, 24
   .exit:
}

; ------------------------------------------------------------------------------

; push 3 double variables
; -> vo : variable offset
macro @@_PUSH_VF3_64 vo
; ----------------------------------------------
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 36, .exit
    if ~ vo in <ecx, rcx>
        mov     rcx, qword vo                   ; rcx = variable offset
    end if
        mov     [rdi + 24], word 0xB948
        mov     [rdi + 26], rcx
        mov     [rdi + 34], word 0x31FF
        add     rcx, 8
        mov     [rdi + 12], word 0xB948
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x31FF
        add     rcx, 8
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x31FF
        add     rdi, 36
   .exit:
}

; ------------------------------------------------------------------------------

; push 4 double variables
; -> vo : variable offset
macro @@_PUSH_VF4_64 vo
; ----------------------------------------------
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 48, .exit
    if ~ vo in <ecx, rcx>
        mov     rcx, qword vo                   ; rcx = variable offset
    end if
        mov     [rdi + 36], word 0xB948
        mov     [rdi + 38], rcx
        mov     [rdi + 46], word 0x31FF
        add     rcx, 8
        mov     [rdi + 24], word 0xB948
        mov     [rdi + 26], rcx
        mov     [rdi + 34], word 0x31FF
        add     rcx, 8
        mov     [rdi + 12], word 0xB948
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x31FF
        add     rcx, 8
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x31FF
        add     rdi, 48
   .exit:
}

; ------------------------------------------------------------------------------

; push double reference
; -> vo : variable offset
macro @@_PUSH_RF_32 vo
; ----------------------------------------------
; MOV  ECX, OFFSET      | B9 AAAAAAAA
; MOV  ECX, DWORD [ECX] | 8B09
; PUSH DWORD [ECX + 4]  | FF71 04
; PUSH DWORD [ECX + 0]  | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 12, .exit
    if ~ vo in <ecx, rcx>
        mov     ecx, dword vo                   ; ecx = variable offset
    end if
        mov     [edi + 0], byte 0xB9
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0x71FF098B
        mov     [edi + 8], dword 0x31FF0471
        add     edi, 12
   .exit:
}

; ------------------------------------------------------------------------------

; push double reference
; -> vo : variable offset
macro @@_PUSH_RF_64 vo
; ----------------------------------------------
; MOV  RCX, OFFSET      | 48B9 FFFFFFFFFFFFFFFF
; MOV  RCX, QWORD [RCX] | 488B09
; PUSH QWORD [RCX]      | FF31
; ----------------------------------------------
{
        local  .exit

        @@bound 15, .exit
    if ~ vo in <ecx, rcx>
        mov     rcx, qword vo                   ; rcx = variable offset
    end if
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0xFF098B48
        mov     [rdi + 14], byte 0x31
        add     rdi, 15
   .exit:
}

; ------------------------------------------------------------------------------

; push double constant
; -> c : constant
macro @@_PUSH_CF_32 c
; ----------------------------------------------
; MOV  EDX, QWORD.HI | BA FFFFFFFF
; MOV  ECX, QWORD.LO | B9 FFFFFFFF
; PUSH EDX           | 52
; PUSH ECX           | 51
; ----------------------------------------------
{
        local  .exit

        @@bound 12, .exit
        mov     ecx, [c + 4]
        mov     [edi + 00], byte 0xBA
        mov     [edi + 01], ecx
        mov     ecx, [c + 0]
        mov     [edi + 05], byte 0xB9
        mov     [edi + 06], ecx
        mov     [edi + 10], word 0x5152
        add     edi, 12
   .exit:
}

; ------------------------------------------------------------------------------

; push double constant
; -> c : constant
macro @@_PUSH_CF_64 c
; ----------------------------------------------
; MOV  RCX, QWORD | 48B9 FFFFFFFFFFFFFFFF
; PUSH RCX        | 51
; ----------------------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     rcx, [c]
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x51
        add     rdi, 11
   .exit:
}

; ------------------------------------------------------------------------------

; push integer variable
; -> io : integer offset
macro @@_PUSH_VI_32 io
; ----------------------------------------------
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 7, .exit
    if ~ io in <ecx, rcx>
        mov     ecx, dword io                   ; ecx = integer offset
    end if
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], ecx
        mov     [edi + 05], word 0x30FF
        add     edi, 7
   .exit:
}

; ------------------------------------------------------------------------------

; push 2 integer variables
; -> io : integer offset
macro @@_PUSH_VI2_32 io
; ----------------------------------------------
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 14, .exit
    if ~ io in <ecx, rcx>
        mov     ecx, dword io                   ; ecx = integer offset
    end if
        mov     [edi + 07], byte 0xB8
        mov     [edi + 08], ecx
        mov     [edi + 12], word 0x30FF
        add     ecx, 4
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], ecx
        mov     [edi + 05], word 0x30FF
        add     edi, 14
   .exit:
}

; ------------------------------------------------------------------------------

; push 3 integer variables
; -> io : integer offset
macro @@_PUSH_VI3_32 io
; ----------------------------------------------
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 21, .exit
    if ~ io in <ecx, rcx>
        mov     ecx, dword io                   ; ecx = integer offset
    end if
        mov     [edi + 14], byte 0xB8
        mov     [edi + 15], ecx
        mov     [edi + 19], word 0x30FF
        add     ecx, 4
        mov     [edi + 07], byte 0xB8
        mov     [edi + 08], ecx
        mov     [edi + 12], word 0x30FF
        add     ecx, 4
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], ecx
        mov     [edi + 05], word 0x30FF
        add     edi, 21
   .exit:
}

; ------------------------------------------------------------------------------

; push 4 integer variables
; -> io : integer offset
macro @@_PUSH_VI4_32 io
; ----------------------------------------------
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; MOV  EAX, OFFSET | B8 AAAAAAAA
; PUSH DWORD [EAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 28, .exit
    if ~ io in <ecx, rcx>
        mov     ecx, dword io                   ; ecx = integer offset
    end if
        mov     [edi + 21], byte 0xB8
        mov     [edi + 22], ecx
        mov     [edi + 26], word 0x30FF
        add     ecx, 4
        mov     [edi + 14], byte 0xB8
        mov     [edi + 15], ecx
        mov     [edi + 19], word 0x30FF
        add     ecx, 4
        mov     [edi + 07], byte 0xB8
        mov     [edi + 08], ecx
        mov     [edi + 12], word 0x30FF
        add     ecx, 4
        mov     [edi + 00], byte 0xB8
        mov     [edi + 01], ecx
        mov     [edi + 05], word 0x30FF
        add     edi, 28
   .exit:
}

; ------------------------------------------------------------------------------

; push integer variable
; -> io : integer offset
macro @@_PUSH_VI_64 io
; ----------------------------------------------
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 12, .exit
    if ~ io in <ecx, rcx>
        mov     rcx, qword io                   ; rcx = integer offset
    end if
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x30FF
        add     rdi, 12
   .exit:
}

; ------------------------------------------------------------------------------

; push 2 integer variables
; -> io : integer offset
macro @@_PUSH_VI2_64 io
; ----------------------------------------------
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 24, .exit
    if ~ io in <ecx, rcx>
        mov     rcx, qword io                   ; rcx = integer offset
    end if
        mov     [rdi + 12], word 0xB848
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x30FF
        add     rcx, 8
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x30FF
        add     rdi, 24
   .exit:
}

; ------------------------------------------------------------------------------

; push 3 integer variables
; -> io : integer offset
macro @@_PUSH_VI3_64 io
; ----------------------------------------------
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 36, .exit
    if ~ io in <ecx, rcx>
        mov     rcx, qword io                   ; rcx = integer offset
    end if
        mov     [rdi + 24], word 0xB848
        mov     [rdi + 26], rcx
        mov     [rdi + 34], word 0x30FF
        add     rcx, 8
        mov     [rdi + 12], word 0xB848
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x30FF
        add     rcx, 8
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x30FF
        add     rdi, 36
   .exit:
}

; ------------------------------------------------------------------------------

; push 4 integer variables
; -> io : integer offset
macro @@_PUSH_VI4_64 io
; ----------------------------------------------
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; MOV  RAX, OFFSET | 48B8 FFFFFFFFFFFFFFFF
; PUSH QWORD [RAX] | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 48, .exit
    if ~ io in <ecx, rcx>
        mov     rcx, qword io                   ; rcx = integer offset
    end if
        mov     [rdi + 36], word 0xB848
        mov     [rdi + 38], rcx
        mov     [rdi + 46], word 0x30FF
        add     rcx, 8
        mov     [rdi + 24], word 0xB848
        mov     [rdi + 26], rcx
        mov     [rdi + 34], word 0x30FF
        add     rcx, 8
        mov     [rdi + 12], word 0xB848
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x30FF
        add     rcx, 8
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x30FF
        add     rdi, 48
   .exit:
}

; ------------------------------------------------------------------------------

; push integer reference
; -> io : integer offset
macro @@_PUSH_RI_32 io
; ----------------------------------------------
; MOV  EAX, OFFSET      | B8 AAAAAAAA
; MOV  EAX, DWORD [EAX] | 8B00
; PUSH DWORD [EAX]      | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 9, .exit
    if ~ io in <ecx, rcx>
        mov     ecx, dword io                   ; ecx = integer offset
    end if
        mov     [edi + 0], byte 0xB8
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0x30FF008B
        add     edi, 9
   .exit:
}

; ------------------------------------------------------------------------------

; push integer reference
; -> io : integer offset
macro @@_PUSH_RI_64 io
; ----------------------------------------------
; MOV  RAX, OFFSET      | 48B8 FFFFFFFFFFFFFFFF
; MOV  RAX, QWORD [RAX] | 488B00
; PUSH QWORD [RAX]      | FF30
; ----------------------------------------------
{
        local  .exit

        @@bound 15, .exit
    if ~ io in <ecx, rcx>
        mov     rcx, qword io                   ; rcx = integer offset
    end if
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], dword 0x30FF008B
        add     rdi, 15
   .exit:
}

; ------------------------------------------------------------------------------

; push integer constant
; -> iv : integer value
macro @@_PUSH_CI_32 iv
; ----------------------------------------------
; MOV  EAX, VALUE | B8 AAAAAAAA
; PUSH EAX        | 50
; ----------------------------------------------
{
        local  .exit

        @@bound 6, .exit
    if ~ iv in <ecx, rcx>
        mov     ecx, dword iv                   ; ecx = integer value
    end if
        mov     [edi + 0], byte 0xB8
        mov     [edi + 1], ecx
        mov     [edi + 5], byte 0x50
        add     edi, 6
   .exit:
}

; ------------------------------------------------------------------------------

; push integer constant
; -> iv : integer value
macro @@_PUSH_CI_64 iv
; ----------------------------------------------
; MOV  RAX, VALUE | 48B8 FFFFFFFFFFFFFFFF
; PUSH RAX        | 50
; ----------------------------------------------
{
        local  .exit

        @@bound 11, .exit
    if ~ iv in <ecx, rcx>
        mov     rcx, qword iv                   ; rcx = integer value
    end if
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x50
        add     rdi, 11
   .exit:
}

; ------------------------------------------------------------------------------

; push string variable
; -> so : string offset
macro @@_PUSH_VS_32 so
; ----------------------------------------------
; MOV  EDX, OFFSET | BA FFFFFFFF
; PUSH DWORD [EDX] | FF32
; ----------------------------------------------
{
        local  .exit

        @@bound 7, .exit
    if ~ so in <ecx, rcx>
        mov     ecx, dword so                   ; ecx = string offset
    end if
        mov     [edi + 0], byte 0xBA
        mov     [edi + 1], ecx
        mov     [edi + 5], word 0x32FF
        add     edi, 7
   .exit:
}

; ------------------------------------------------------------------------------

; push string variable
; -> so : string offset
macro @@_PUSH_VS_64 so
; ----------------------------------------------
; MOV  RDX, OFFSET | 48BA FFFFFFFFFFFFFFFF
; PUSH QWORD [RDX] | FF32
; ----------------------------------------------
{
        local  .exit

        @@bound 12, .exit
    if ~ so in <ecx, rcx>
        mov     rcx, qword so                   ; rcx = string offset
    end if
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x32FF
        add     rdi, 12
   .exit:
}

; ------------------------------------------------------------------------------

; push string reference
; -> so : string offset
macro @@_PUSH_RS_32 so
; ----------------------------------------------
; MOV  EDX, OFFSET      | BA FFFFFFFF
; MOV  EDX, DWORD [EDX] | 8B12
; PUSH DWORD [EDX]      | FF32
; ----------------------------------------------
{
        local  .exit

        @@bound 9, .exit
    if ~ so in <ecx, rcx>
        mov     ecx, dword so                   ; ecx = string offset
    end if
        mov     [edi + 0], byte 0xBA
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0x32FF128B
        add     edi, 9
   .exit:
}

; ------------------------------------------------------------------------------

; push string reference
; -> so : string offset
macro @@_PUSH_RS_64 so
; ----------------------------------------------
; MOV  RDX, OFFSET      | 48BA FFFFFFFFFFFFFFFF
; MOV  RDX, QWORD [RDX] | 488B12
; PUSH QWORD [RDX]      | FF32
; ----------------------------------------------
{
        local  .exit

        @@bound 15, .exit
    if ~ so in <ecx, rcx>
        mov     rcx, qword so                   ; rcx = string offset
    end if
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], dword 0x32FF128B
        add     rdi, 15
   .exit:
}

; ------------------------------------------------------------------------------

; push string constant
; -> so : string offset
macro @@_PUSH_CS_32 so
; ----------------------------------------------
; MOV  EDX, VALUE | BA FFFFFFFF
; PUSH EDX        | 52
; ----------------------------------------------
{
        local  .exit

        @@bound 6, .exit
    if ~ so in <ecx, rcx>
        mov     ecx, dword so                   ; ecx = string offset
    end if
        mov     [edi + 0], byte 0xBA
        mov     [edi + 1], ecx
        mov     [edi + 5], byte 0x52
        add     edi, 6
   .exit:
}

; ------------------------------------------------------------------------------

; push string constant
; -> so : string offset
macro @@_PUSH_CS_64 so
; ----------------------------------------------
; MOV  RDX, VALUE | 48BA FFFFFFFFFFFFFFFF
; PUSH RDX        | 52
; ----------------------------------------------
{
        local  .exit

        @@bound 11, .exit
    if ~ so in <ecx, rcx>
        mov     rcx, qword so                   ; rcx = string offset
    end if
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x52
        add     rdi, 11
   .exit:
}

; ------------------------------------------------------------------------------

; push pointer variable
; -> po : pointer offset
macro @@_PUSH_VP_32 po
; ----------------------------------------------
; MOV  ECX, OFFSET | B9 FFFFFFFF
; PUSH DWORD [ECX] | FF31
; NOP2             | 9090
; ----------------------------------------------
{
        local  .exit

        @@bound 9, .exit
    if ~ po in <ecx, rcx>
        mov     ecx, dword po                   ; ecx = pointer offset
    end if
        mov     [edi + 0], byte 0xB9
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0x909031FF
        add     edi, 9
   .exit:
}

; ------------------------------------------------------------------------------

; push pointer variable
; -> po : pointer offset
macro @@_PUSH_VP_64 po
; ----------------------------------------------
; MOV  RCX, OFFSET | 48B9 FFFFFFFFFFFFFFFF
; PUSH QWORD [RCX] | FF31
; NOP2             | 9090
; ----------------------------------------------
{
        local  .exit

        @@bound 14, .exit
    if ~ po in <ecx, rcx>
        mov     rcx, qword po                   ; rcx = pointer offset
    end if
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x909031FF
        add     rdi, 14
        jmp    .exit
   .exit:
}

; ------------------------------------------------------------------------------

; push pointer constant
; -> pv : pointer value
macro @@_PUSH_CP_32 pv
; ----------------------------------------------
; MOV  ECX, VALUE | B9 FFFFFFFF
; PUSH ECX        | 51
; NOP3            | 909090
; ----------------------------------------------
{
        local  .exit

        @@bound 9, .exit
    if ~ pv in <ecx, rcx>
        mov     ecx, dword pv                   ; ecx = pointer value
    end if
        mov     [edi + 0], byte 0xB9
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0x90909051
        add     edi, 9
   .exit:
}

; ------------------------------------------------------------------------------

; push pointer constant
; -> pv : pointer value
macro @@_PUSH_CP_64 pv
; ----------------------------------------------
; MOV  RCX, VALUE | 48B9 FFFFFFFFFFFFFFFF
; PUSH RCX        | 51
; NOP3            | 909090
; ----------------------------------------------
{
        local  .exit

        @@bound 14, .exit
    if ~ pv in <ecx, rcx>
        mov     rcx, qword pv                   ; rcx = pointer value
    end if
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x90909051
        add     rdi, 14
        jmp    .exit
   .exit:
}

; ------------------------------------------------------------------------------

; push offset
; -> io : item offset
macro @@_PUSH_O_32 io
; ----------------------------------------------
; MOV  EDX, VALUE | BA AAAAAAAA
; ----------------------------------------------
{
        local  .exit

        @@bound 5, .exit
    if ~ io in <ecx, rcx>
        mov     ecx, dword io                   ; ecx = item offset
    end if
        mov     [edi + 0], byte 0xBA
        mov     [edi + 1], ecx
        add     edi, 5
   .exit:
}

; ------------------------------------------------------------------------------

; push offset
; -> io : item offset
macro @@_PUSH_O_64 io
; ----------------------------------------------
; MOV  RDX, VALUE | 48BA FFFFFFFFFFFFFFFF
; ----------------------------------------------
{
        local  .exit

        @@bound 10, .exit
    if ~ io in <ecx, rcx>
        mov     rcx, qword io                   ; rcx = item offset
    end if
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rcx
        add     rdi, 10
   .exit:
}

; ------------------------------------------------------------------------------

; push address
; -> ia : item address
macro @@_PUSH_A_32 ia
; ----------------------------------------------
; MOV  ECX, VALUE | B9 FFFFFFFF
; PUSH ECX        | 51
; NOP3            | 909090
; ----------------------------------------------
{
        local  .exit

        @@bound 9, .exit
    if ~ ia in <ecx, rcx>
        mov     ecx, dword ia                   ; ecx = address value
    end if
        mov     [edi + 0], byte 0xB9
        mov     [edi + 1], ecx
        mov     [edi + 5], dword 0x90909051
        add     edi, 9
   .exit:
}

; ------------------------------------------------------------------------------

; push address
; -> ia : item address
macro @@_PUSH_A_64 ia
; ----------------------------------------------
; MOV  RCX, VALUE | 48B9 FFFFFFFFFFFFFFFF
; PUSH RCX        | 51
; NOP3            | 909090
; ----------------------------------------------
{
        local  .exit

        @@bound 14, .exit
    if ~ ia in <ecx, rcx>
        mov     rcx, qword ia                   ; rcx = address value
    end if
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x90909051
        add     rdi, 14
        jmp    .exit
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ENTER_32
; ---------------------
; PUSH EBP      | 55
; MOV  EBP, ESP | 89E5
; ---------------------
; 55 89 E5
; ---------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0x8955
        mov     [edi + 2], byte 0xE5
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ENTER__32
; -----------------------
; ENTER 0, 0 | C8 000000
; -----------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [edi], dword 0x000000C8
        add     edi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ENTER_64
; -----------------------
; PUSH RBP      | 55
; MOV  RBP, RSP | 4889E5
; -----------------------
; 55 48 89 E5
; -----------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0xE5894855
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_ENTER__64
; -----------------------
; ENTER 0, 0 | C8 000000
; -----------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x000000C8
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_LEAVE_32
; -----------
; LEAVE | C9
; -----------
{
        local  .exit

        @@bound 1, .exit
        mov     [edi], byte 0xC9
        add     edi, 1
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_LEAVE__32
; --------------------
; MOV ESP, EBP | 89EC
; POP EBP      | 5D
; --------------------
; 89 EC 5D
; --------------------
{
        local  .exit

        @@bound 3, .exit
        mov     [edi + 0], word 0xEC89
        mov     [edi + 2], byte 0x5D
        add     edi, 3
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_LEAVE_64
; -----------
; LEAVE | C9
; -----------
{
        local  .exit

        @@bound 1, .exit
        mov     [rdi], byte 0xC9
        add     rdi, 1
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_LEAVE__64
; ----------------------
; MOV RSP, RBP | 4889EC
; POP RBP      | 5D
; ----------------------
; 48 89 EC 5D
; ----------------------
{
        local  .exit

        @@bound 4, .exit
        mov     [rdi], dword 0x5DEC8948
        add     rdi, 4
   .exit:
}

; ------------------------------------------------------------------------------

; allocate local variables
; [EBP - 08] - exit label offset (4 bytes) clear
; [EBP - 16] - result (double)   (8 bytes) clear
; [EBP - 22] - FPU control word  (2 bytes)
; [EBP - 24] - FPU control word  (2 bytes)
; [EBP - 28] - MXCSR             (4 bytes)
; [EBP - 32] - MXCSR             (4 bytes)

@@_LOCALS_32_SPACE        EQU 32 ; !!! must be a multiple of 16
@@_LOCALS_32_EXIT_LABEL   EQU EBP - 08
@@_LOCALS_32_RESULT       EQU EBP - 16
@@_LOCALS_32_FPU_CW_0     EQU EBP - 22
@@_LOCALS_32_FPU_CW       EQU EBP - 24
@@_LOCALS_32_FPU_MXCSR_0  EQU EBP - 28
@@_LOCALS_32_FPU_MXCSR    EQU EBP - 32

macro @@_LOCALS_ALLOC_32
; ------------------------
; SUB ESP, FF  | 83EC FF
; SUB ESP, FF+ | 81EC FF+
; ------------------------
{
        local  .exit

    if (@@_LOCALS_32_SPACE < -128) | (@@_LOCALS_32_SPACE > 127)
        @@bound 6, .exit
        push    eax
        mov     eax, @@_LOCALS_32_SPACE
        mov     [edi + 00], word 0xEC81
        mov     [edi + 02], eax
        pop     eax
        add     edi, 6
    else
        @@bound 3, .exit
        push    eax
        mov     eax, @@_LOCALS_32_SPACE
        mov     [edi + 00], word 0xEC83
        mov     [edi + 02], al
        pop     eax
        add     edi, 3
    end if
   .exit:
}

macro @@_LOCALS_RELEASE_32
; ------------------------
; ADD ESP, FF  | 83C4 FF
; ADD ESP, FF+ | 81C4 FF+
; ------------------------
{
        local  .exit

    if (@@_LOCALS_32_SPACE < -128) | (@@_LOCALS_32_SPACE > 127)
        @@bound 6, .exit
        push    eax
        mov     eax, @@_32_LOCALS_SPACE
        mov     [edi + 00], word 0xC481
        mov     [edi + 02], eax
        pop     eax
        add     edi, 6
    else
        @@bound 3, .exit
        push    eax
        mov     eax, @@_32_LOCALS_SPACE
        mov     [edi + 00], word 0xC483
        mov     [edi + 02], al
        pop     eax
        add     edi, 3
    end if
   .exit:
}

; clear local variables
macro @@_LOCALS_CLEAR_32
; -----------------------------------
; XOR EAX, EAX            | 31 C0
; MOV DWORD [EBP-08], EAX | 89 45 F8
; MOV DWORD [EBP-12], EAX | 89 45 F4
; MOV DWORD [EBP-16], EAX | 89 45 F0
; -----------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [edi + 00], dword 0x4589C031
        mov     [edi + 04], dword 0xF44589F8
        mov     [edi + 07], dword 0xF04589F4
        add     edi, 11
   .exit:
}

; ------------------------------------------------------------------------------

; allocate local variables
; [RBP - 08] - exit label offset (8 bytes) clear
; [RBP - 16] - result (double)   (8 bytes) clear
; [RBP - 22] - FPU control word  (2 bytes)
; [RBP - 24] - FPU control word  (2 bytes)
; [RBP - 28] - MXCSR             (4 bytes)
; [RBP - 32] - MXCSR             (4 bytes)

@@_LOCALS_64_SPACE        EQU 32 ; !!! must be a multiple of 16
@@_LOCALS_64_EXIT_LABEL   EQU RBP - 08
@@_LOCALS_64_RESULT       EQU RBP - 16
@@_LOCALS_64_FPU_CW_0     EQU RBP - 22
@@_LOCALS_64_FPU_CW       EQU RBP - 24
@@_LOCALS_64_FPU_MXCSR_0  EQU RBP - 28
@@_LOCALS_64_FPU_MXCSR    EQU RBP - 32

macro @@_LOCALS_ALLOC_64
; --------------------------
; SUB RSP, FF  | 4883EC FF
; SUB RSP, FF+ | 4881EC FF+
; --------------------------
{
        local  .exit

    if (@@_LOCALS_64_SPACE < -128) | (@@_LOCALS_64_SPACE > 127)
        @@bound 7, .exit
        push    rax
        mov     rax, @@_LOCALS_64_SPACE
        mov     [rdi + 00], dword 0x00EC8148
        mov     [rdi + 03], eax
        pop     rax
        add     rdi, 7
    else
        @@bound 4, .exit
        push    rax
        mov     rax, @@_LOCALS_64_SPACE
        mov     [rdi + 00], dword 0x00EC8348
        mov     [rdi + 03], al
        pop     rax
        add     rdi, 4
    end if
   .exit:
}

; release local variables
macro @@_LOCALS_RELEASE_64
; --------------------------
; ADD RSP, FF  | 4883C4 FF
; ADD RSP, FF+ | 4881C4 FF+
; --------------------------
{
        local  .exit

    if (@@_LOCALS_64_SPACE < -128) | (@@_LOCALS_64_SPACE > 127)
        @@bound 7, .exit
        push    rax
        mov     rax, @@_LOCALS_64_SPACE
        mov     [rdi + 00], dword 0x00C48148
        mov     [rdi + 03], eax
        pop     rax
        add     rdi, 7
    else
        @@bound 4, .exit
        push    rax
        mov     rax, @@_LOCALS_64_SPACE
        mov     [rdi + 00], dword 0x00C48348
        mov     [rdi + 03], al
        pop     rax
        add     rdi, 4
    end if
   .exit:
}

; clear local variables
macro @@_LOCALS_CLEAR_64
; --------------------------------------
; XOR RAX, RAX            | 48 31 C0
; MOV QWORD [RBP-08], RAX | 48 89 45 F8
; MOV QWORD [RBP-16], RAX | 48 89 45 F0
; --------------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [rdi + 00], dword 0x00C03148
        mov     [rdi + 03], dword 0xF8458948
        mov     [rdi + 07], dword 0xF0458948
        add     rdi, 11
   .exit:
}

; ------------------------------------------------------------------------------

; FPU frame enter
; mask all FPU exceptions
; round toward zero
; full precision

macro @@_SSE_FRAME_ENTER_32
; -------------------------------------------------------
; STMXCSR DWORD [EBP-28]         | 0F AE 5D E4          ; save MXCSR register
; MOV     DWORD [EBP-32], 0x7F80 | C7 45 E0 80 7F 00 00 ; mask all exceptions, round toward zero ; 11 111111 0 000000
; LDMXCSR DWORD [EBP-32]         | 0F AE 55 E0          ; load MXCSR register
; -------------------------------------------------------
{
        local  .exit

        @@bound 15, .exit
        mov     [edi + 00], dword 0xE45DAE0F
        mov     [edi + 04], dword 0x80E045C7
        mov     [edi + 08], dword 0x0F00007F
        mov     [edi + 11], dword 0xE055AE0F
        add     edi, 15
   .exit:
}

macro @@_FPU_FRAME_ENTER_32
; --------------------------------------------------
; FNSTCW WORD [EBP-22]         | D9 7D EA          ; save FPU control word
; MOV    WORD [EBP-24], 0x0F3F | 66 C7 45 E8 3F 0F ; mask all exceptions, round toward zero, full precision ; 11 11 00111111
; FLDCW  WORD [EBP-24]         | D9 6D E8          ; load FPU control word
; --------------------------------------------------
{
        local  .exit

        @@bound 12, .exit
        mov     [edi + 00], dword 0x66EA7DD9
        mov     [edi + 04], dword 0x3FE845C7
        mov     [edi + 08], dword 0xE86DD90F
        add     edi, 12
   .exit:
}

macro @@__FPU_FRAME_ENTER_32
; -----------------------------------------------
; FNSTCW WORD [EBP-22]         | D9 7D EA       ; save FPU control word
; FNSTCW WORD [EBP-24]         | D9 7D E8       ; copy FPU control word
; OR     WORD [EBP-24], 0x003F | 66 83 4D E8 3F ; mask all exceptions
; FLDCW  WORD [EBP-24]         | D9 6D E8       ; load FPU control word
; -----------------------------------------------
{
        local  .exit

        @@bound 14, .exit
        mov     [edi + 00], dword 0xD9EA7DD9
        mov     [edi + 04], dword 0x8366E87D
        mov     [edi + 08], dword 0xD93FE84D
        mov     [edi + 12], word 0xE86D
        add     edi, 14
   .exit:
}

macro @@_SSE_FRAME_ENTER_64
; -------------------------------------------------------
; STMXCSR DWORD [RBP-28]         | 0F AE 5D E4          ; save MXCSR register
; MOV     DWORD [RBP-32], 0x7F80 | C7 45 E0 80 7F 00 00 ; mask all exceptions, round toward zero ; 11 111111 0 000000
; LDMXCSR DWORD [RBP-32]         | 0F AE 55 E0          ; load MXCSR register
; -------------------------------------------------------
{
        local  .exit

        @@bound 15, .exit
        mov     [rdi + 00], dword 0xE45DAE0F
        mov     [rdi + 04], dword 0x80E045C7
        mov     [rdi + 08], dword 0x0F00007F
        mov     [rdi + 11], dword 0xE055AE0F
        add     rdi, 15
   .exit:
}

macro @@_FPU_FRAME_ENTER_64
; --------------------------------------------------
; FNSTCW WORD [RBP-22]         | D9 7D EA          ; save FPU control word
; MOV    WORD [RBP-24], 0x0F3F | 66 C7 45 E8 3F 0F ; mask all exceptions, round toward zero, full precision ; 11 11 00111111
; FLDCW  WORD [RBP-24]         | D9 6D E8          ; load FPU control word
; --------------------------------------------------
{
        local  .exit

        @@bound 12, .exit
        mov     [rdi + 00], dword 0x66EA7DD9
        mov     [rdi + 04], dword 0x3FE845C7
        mov     [rdi + 08], dword 0xE86DD90F
        add     rdi, 12
   .exit:
}

macro @@__FPU_FRAME_ENTER_64
; -----------------------------------------------
; FNSTCW WORD [RBP-22]         | D9 7D EA       ; save FPU control word
; FNSTCW WORD [RBP-24]         | D9 7D E8       ; copy FPU control word
; OR     WORD [RBP-24], 0x003F | 66 83 4D E8 3F ; mask all exceptions
; FLDCW  WORD [RBP-24]         | D9 6D E8       ; load FPU control word
; -----------------------------------------------
{
        local  .exit

        @@bound 14, .exit
        mov     [rdi + 00], dword 0xD9EA7DD9
        mov     [rdi + 04], dword 0x8366E87D
        mov     [rdi + 08], dword 0xD93FE84D
        mov     [rdi + 12], word 0xE86D
        add     rdi, 14
   .exit:
}

; ------------------------------------------------------------------------------

; FPU frame leave
; -----------------------------------------------
; FPU exception flags
; -----------------------------------------------
; 7 - ES - Exception Flag
; 6 - SF - Stack Fault
; 5 - PE - Precision
; 4 - UE - Underflow
; 3 - OE - Overflow
; 2 - ZE - Zero Divide
; 1 - DE - Denormalized
; 0 - IE - Invalid Operation
; -----------------------------------------------

macro @@_SSE_FRAME_LEAVE_32
; -----------------------------------------------
; STMXCSR DWORD [EBP-32]      | 0F AE 5D E0     ; get MXCSR register
; MOV     EAX, DWORD [EBP-32] | 8B 45 E0
; AND     EAX, 0x0000000D     | 83 E0 0D        ; extract OE, ZE & IE flags
; JE      @F (+4)             | 74 04
; XORPD   XMM0, XMM0          | 66 0F 57 C0     ; return zero on error
; @@:                         |
; LDMXCSR DWORD [EBP-28]      | 0F AE 55 E4     ; restore MXCSR register
; -----------------------------------------------
{
        local  .exit

        @@bound 20, .exit
        mov     [edi + 00], dword 0xE05DAE0F
        mov     [edi + 04], dword 0x83E0458B
        mov     [edi + 08], dword 0x04740DE0
        mov     [edi + 12], dword 0xC0570F66
        mov     [edi + 16], dword 0xE455AE0F
        add     edi, 20
   .exit:
}

macro @@_FPU_FRAME_LEAVE_32
; -----------------------------------------------
; FNSTSW AX              | DF E0                ; get status word
; AND    EAX, 0x0000000D | 83 E0 0D             ; extract OE, ZE & IE flags
; JE     @F (+6)         | 74 06
; FNCLEX                 | DB E2                ; clear all exceptions
; FSTP   ST0             | DD D8                ; remove invalid result
; FLDZ                   | D9 EE                ; return zero on error
; @@:                    |
; FLDCW  WORD [EBP-22]   | D9 6D EA             ; restore FPU control word
; -----------------------------------------------
{
        local  .exit

        @@bound 16, .exit
        mov     [edi + 00], dword 0xE083E0DF
        mov     [edi + 04], dword 0xDB06740D
        mov     [edi + 08], dword 0xD9D8DDE2
        mov     [edi + 12], dword 0xEA6DD9EE
        add     edi, 16
   .exit:
}

macro @@_SSE_FRAME_LEAVE_64
; -----------------------------------------------
; STMXCSR DWORD [RBP-32]      | 0F AE 5D E0     ; get MXCSR register
; MOV     EAX, DWORD [RBP-32] | 8B 45 E0
; AND     EAX, 0x0000000D     | 83 E0 0D        ; extract OE, ZE & IE flags
; JE      @F (+4)             | 74 04
; XORPD   XMM0, XMM0          | 66 0F 57 C0     ; return zero on error
; @@:                         |
; LDMXCSR DWORD [RBP-28]      | 0F AE 55 E4     ; restore MXCSR register
; -----------------------------------------------
{
        local  .exit

        @@bound 20, .exit
        mov     [rdi + 00], dword 0xE05DAE0F
        mov     [rdi + 04], dword 0x83E0458B
        mov     [rdi + 08], dword 0x04740DE0
        mov     [rdi + 12], dword 0xC0570F66
        mov     [rdi + 16], dword 0xE455AE0F
        add     rdi, 20
   .exit:
}

macro @@_FPU_FRAME_LEAVE_64
; -----------------------------------------------
; FNSTSW AX              | DF E0                ; get status word
; AND    EAX, 0x0000000D | 83 E0 0D             ; extract OE, ZE & IE flags
; JE     @F (+6)         | 74 06
; FNCLEX                 | DB E2                ; clear all exceptions
; FSTP   ST0             | DD D8                ; remove invalid result
; FLDZ                   | D9 EE                ; return zero on error
; @@:                    |
; FLDCW  WORD [RBP-22]   | D9 6D EA             ; restore FPU control word
; -----------------------------------------------
{
        local  .exit

        @@bound 16, .exit
        mov     [rdi + 00], dword 0xE083E0DF
        mov     [rdi + 04], dword 0xDB06740D
        mov     [rdi + 08], dword 0xD9D8DDE2
        mov     [rdi + 12], dword 0xEA6DD9EE
        add     rdi, 16
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_FLDZ_32
; ------------------------------------
; CMP  DWORD [EBP-08], 0 | 837D F8 00
; JNE  +4 (JNE A)        | 75 04
; FLDZ                   | D9EE
; JMP  +3 (JMP B)        | EB 03
; A:                     |
; FLD  QWORD [EBP-16]    | DD45 F0
; B:                     |
; ------------------------------------
{
        local  .exit

        @@bound 13, .exit
        mov     [edi + 00], dword 0x00F87D83
        mov     [edi + 04], dword 0xEED90475
        mov     [edi + 08], dword 0x45DD03EB
        mov     [edi + 12], byte 0xF0
        add     edi, 13
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_FLDZ_64
; --------------------------------------
; CMP  QWORD [RBP-08], 0 | 48837D F8 00
; JNE  +4 (JNE A)        | 75 04
; FLDZ                   | D9EE
; JMP  +3 (JMP B)        | EB 03
; A:                     |
; FLD  QWORD [RBP-16]    | DD45 F0
; B:                     |
; --------------------------------------
{
        local  .exit

        @@bound 14, .exit
        mov     [rdi + 00], dword 0xF87D8348
        mov     [rdi + 04], dword 0xD9047500
        mov     [rdi + 08], dword 0xDD03EBEE
        mov     [rdi + 12], word 0xF045
        add     rdi, 14
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_FLDQ_32
; ------------------------------------
; CMP  DWORD [EBP-08], 0 | 837D F8 00
; JE   +3 (JE B)         | 74 03
; FLD  QWORD [EBP-16]    | DD45 F0
; B:                     |
; ------------------------------------
{
        local  .exit

        @@bound 9, .exit
        mov     [edi + 00], dword 0x00F87D83
        mov     [edi + 04], dword 0x45DD0374
        mov     [edi + 08], byte 0xF0
        add     edi, 9
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_FLDQ_64
; --------------------------------------
; CMP  QWORD [RBP-08], 0 | 48837D F8 00
; JE   +3 (JE B)         | 74 03
; FLD  QWORD [RBP-16]    | DD45 F0
; B:                     |
; --------------------------------------
{
        local  .exit

        @@bound 10, .exit
        mov     [rdi + 00], dword 0xF87D8348
        mov     [rdi + 04], dword 0xDD037400
        mov     [rdi + 08], word 0xF045
        add     rdi, 10
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_MOVSD_32
; ----------------------------------------
; CMP   DWORD [EBP-08], 0    | 837D F8 00
; JE    +5 (JE B)            | 74 05
; MOVSD XMM0, QWORD [EBP-16] | F20F1045 F0
; B:                         |
; ----------------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [edi + 00], dword 0x00F87D83
        mov     [edi + 04], dword 0x0FF20574
        mov     [edi + 07], dword 0xF045100F
        add     edi, 11
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_MOVSD_64
; -----------------------------------------
; CMP   QWORD [RBP-08], 0    | 48837D F8 00
; JE    +5 (JE B)            | 74 05
; MOVSD XMM0, QWORD [RBP-16] | F20F1045 F0
; B:                         |
; -----------------------------------------
{
        local  .exit

        @@bound 12, .exit
        mov     [rdi + 00], dword 0xF87D8348
        mov     [rdi + 04], dword 0xF2057400
        mov     [rdi + 08], dword 0xF045100F
        add     rdi, 12
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_FSTP_FLDQ_32
; ------------------------------------
; CMP  DWORD [EBP-08], 0 | 837D F8 00
; JE   +5 (JE B)         | 74 05
; FSTP ST0               | DDD8
; FLD  QWORD [EBP-16]    | DD45 F0
; B:                     |
; ------------------------------------
{
        local  .exit

        @@bound 11, .exit
        mov     [edi + 00], dword 0x00F87D83
        mov     [edi + 04], dword 0xD8DD0574
        mov     [edi + 07], dword 0xF045DDD8
        add     edi, 11
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_EXIT_CODE_FSTP_FLDQ_64
; --------------------------------------
; CMP  QWORD [RBP-08], 0 | 48837D F8 00
; JE   +5 (JE B)         | 74 05
; FSTP ST0               | DDD8
; FLD  QWORD [RBP-16]    | DD45 F0
; B:                     |
; --------------------------------------
{
        local  .exit

        @@bound 12, .exit
        mov     [rdi + 00], dword 0xF87D8348
        mov     [rdi + 04], dword 0xDD057400
        mov     [rdi + 08], dword 0xF045DDD8
        add     rdi, 12
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_EBP_mFF_0_EAX FF
;  FF > 0
; -FF >= -128
; -----------------------------------
; XOR EAX, EAX            | 31C0
; MOV DWORD [EBP-FF], EAX | 8945 -FF
; -----------------------------------
{
        local  .exit

        @@bound 5, .exit
        push    eax
        mov     al, FF
        neg     al
        mov     [xdi + 0], dword 0x4589C031
        mov     [xdi + 4], al
        pop     eax
        add     xdi, 5
   .exit:
}


; ------------------------------------------------------------------------------

macro @@_MOV_EBP_mFF_0 FF
;  FF > 0
; -FF >= -128
; ------------------------------------------
; MOV DWORD [EBP-FF], 0 | C745 -FF 00000000
; ------------------------------------------
{
        local  .exit

        @@bound 7, .exit
        push    eax
        mov     al, FF
        neg     al
        mov     [xdi + 0], word 0x45C7
        mov     [xdi + 2], al
        mov     [xdi + 3], dword 0x00000000
        pop     eax
        add     xdi, 7
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_RBP_mFF_0_RAX FF
;  FF > 0
; -FF >= -128
; -------------------------------------
; XOR RAX, RAX            | 4831C0
; MOV QWORD [RBP-FF], RAX | 488945 -FF
; -------------------------------------
{
        local  .exit

        @@bound 7, .exit
        push    rax
        mov     al, FF
        neg     al
        mov     [xdi + 0], dword 0x48C03148
        mov     [xdi + 4], word 0x4589
        mov     [xdi + 6], al
        pop     rax
        add     xdi, 7
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_MOV_RBP_mFF_0 FF
;  FF > 0
; -FF >= -128
; --------------------------------------------
; MOV QWORD [RBP-FF], 0 | 48C745 -FF 00000000
; --------------------------------------------
{
        local  .exit

        @@bound 8, .exit
        push    rax
        mov     al, FF
        neg     al
        mov     [xdi + 0], dword 0x0045C748
        mov     [xdi + 3], al
        mov     [xdi + 4], dword 0x00000000
        pop     rax
        add     xdi, 8
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_NOP
; ---------
; NOP | 90
; ---------
{
        local  .exit

        @@bound 1, .exit
        mov     [xdi], byte 0x90
        inc     xdi
   .exit:
}

; ------------------------------------------------------------------------------

macro @@_RET
; ---------
; RET | C3
; ---------
{
        local  .exit

        @@bound 1, .exit
        mov     [xdi], byte 0xC3
        inc     xdi
   .exit:
}

; ------------------------------------------------------------------------------
