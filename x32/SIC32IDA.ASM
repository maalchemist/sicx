
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; Instruction Disassembler
; code

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; Based on ldasm.h and ldasm.c by vol4ok
; https://github.com/vol4ok/libsplice
; @modifier:
; https://github.com/Rprop/LDasm  | r_prop@outlook.com
; https://github.com/rrrfff/LDasm | rrrfff@foxmail.com

SIC_IDA:

; ------------------------------------------------------------------------------

; Instruction format:
; | prefix | REX/VEX/EVEX | opcode | modR/M | SIB | disp8/16/32 | imm8/16/32/64 |
;
; -> edi = code pointer
; -> eax = 0
;
macro SIC_IDA.code {

    ; opcode flag [table + ecx]
    macro .opf.ecx flags \{
      $ifdef _X64
        mov     rbx, flags
        mov     bl, byte [rbx + rcx]
      $else
        mov     bl, byte [flags + ecx]
      $end
    \}

    ; opcode flag [table + edx]
    macro .opf.edx flags \{
      $ifdef _X64
        mov     rbx, flags
        mov     bl, byte [rbx + rdx]
      $else
        mov     bl, byte [flags + edx]
      $end
    \}

    ; opcode flag [table + imm]
    macro .opf.imm flags, imm \{
      $ifdef _X64
        mov     rbx, flags
        mov     bl, byte [rbx + imm]
      $else
        mov     bl, byte [flags + imm]
      $end
    \}

        mov     [.flag], al
        mov     [.pr_66], al
        mov     [.pr_67], al
        mov     [.rex_w], al
        mov     [.m_mod], al
        mov     [.m_ro], al
        mov     [.m_rm], al

        mov     esi, edi                        ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode

        ; phase 1: parse prefixies
   .prefix.loop:
       .opf.ecx IDA_flags                       ; bl = opcode flag
        and     bl, OP_PREFIX
   .prefix?:
        test    bl, bl
        jz     .prefix.leave
        ;
   .prefix.66?:
        cmp     cl, 0x66
        jne    .prefix.66.leave
   .prefix.66:
        ; (*p == 0x66)
        mov     [.pr_66], 1
   .prefix.66.leave:
        ;
   .prefix.67?:
        cmp     cl, 0x67
        jne    .prefix.67.leave
   .prefix.67:
        ; (*p == 0x67)
        mov     [.pr_67], 1
   .prefix.67.leave:
        ;
        inc     [.data.prefix_size]
        or      [.data.flags], IDA_PREFIX
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax                             ; eax = opcode size
   .prefix.error?:
        cmp     eax, 15
        jne    .prefix.loop
   .prefix.error:
        ; (s == 15)
        or      [.data.flags], IDA_INVALID
        jmp    .return
   .prefix.leave:

        ; ——————————————————————————————————————————————————————————————————
        ; Intel® 64 and IA-32 Architectures Software Developer’s Manual V2A
        ; ——————————————————————————————————————————————————————————————————
        ; 2.3 INTEL® ADVANCED VECTOR EXTENSIONS (INTEL® AVX)
        ; 2.3.5.2 VEX Byte 1, bit [7] - ‘R’
        ;   VEX Byte 1, bit [7] contains a bit analogous to a bit inverted REX.R.
        ;   In protected and compatibility modes the bit must be set to ‘1’ otherwise the instruction is LES or LDS.
        ;   This bit is present in both 2- and 3-byte VEX prefixes.
        ; 2.3.5.3 3-byte VEX byte 1, bit[6] - ‘X’
        ;   Bit[6] of the 3-byte VEX byte 1 encodes a bit analogous to a bit inverted REX.X.
        ;   It is an extension of the SIB Index field in 64-bit modes.
        ;   In 32-bit modes, this bit must be set to ‘1’ otherwise the instruction is LES or LDS.
        ;   This bit is available only in the 3-byte VEX prefix.
        ; ——————————————————————————————————————————————————————————————————

        ; parse 2-byte VEX prefix
        ; ——————————————————————————————————————————————————
        ;           |  7    6    5    4    3    2    1    0
        ; ——————————————————————————————————————————————————
        ;  0 (0xC5) |  1    1    0    0    0    1    0    1
        ;  1        | ~R  ~v3  ~v2  ~v1  ~v0    L   p1   p0
        ; ——————————————————————————————————————————————————
   .vex.2??:
        cmp     cl, 0xC5
        jne    .vex.2.leave
   .vex.2?:
        cmp     [.x64], 0
        jnz    .vex.2
   .vex.2?.x32:
        mov     bl, byte [esi + 1]              ; bl = next opcode
        and     bl, 10000000B                   ; 0x80
        cmp     bl, 10000000B                   ; x32: VEX.R=1B?
        jne    .vex.2.leave                     ; x32: 0xC5 = LDS
   .vex.2:                                      ; x32: VEX.R=1B
        or      [.data.flags], IDA_VEX2
        mov     [.data.prex_size], 2
        mov     [.data.prex_0], cl
        mov     cl, byte [esi + 1]
        mov     [.data.prex_1], cl
        add     esi, 2                          ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        add     eax, 2                          ; eax = opcode size
   .vex.2.pr?:                                  ; implied mandatory prefixes
        mov     bl, [.data.prex_1]
        and     bl, 00000011B                   ; bl = implied mandatory prefix
        cmp     bl, 1                           ; 01B:0x66 | 10B:0xF3 | 11B:0xF2
        jne    .vex.2.pr.out
   .vex.2.pr66:
        mov     [.pr_66], 1
   .vex.2.pr.out:
   .vex.2.flag:
   .vex.2.flag.0F.op:                           ; [0F] <op>
       .opf.ecx IDA_flags_ex                    ; bl = opcode flag
        mov     bh, bl
        mov     [.flag], bl
   .vex.2.flag.leave:
   .vex.2.invalid?:
        and     bl, OP_INVALID                  ; bl = opcode flag
        jz     .opcode.enter
;       jz     .vex.2.leave
   .vex.2.invalid:
        ; (f & OP_INVALID)
        or      [.data.flags], IDA_INVALID
        jmp    .return
   .vex.2.leave:

        ; parse 3-byte VEX prefix
        ; ——————————————————————————————————————————————————
        ;           |  7    6    5    4    3    2    1    0
        ; ——————————————————————————————————————————————————
        ;  0 (0xC4) |  1    1    0    0    0    1    0    0
        ;  1        | ~R   ~X   ~B   m4   m3   m2   m1   m0
        ;  2        |  W  ~v3  ~v2  ~v1  ~v0    L   p1   p0
        ; ——————————————————————————————————————————————————
   .vex.3??:
        cmp     cl, 0xC4
        jne    .vex.3.leave
   .vex.3?:
        cmp     [.x64], 0
        jnz    .vex.3
   .vex.3?.x32:
        mov     bl, byte [esi + 1]              ; bl = next opcode
        and     bl, 11000000B                   ; 0xC0
        cmp     bl, 11000000B                   ; x32: VEX.RX=11B?
        jne    .vex.3.leave                     ; x32: 0xC4 = LES
   .vex.3:                                      ; x32: VEX.RX=11B
        or      [.data.flags], IDA_VEX3
        mov     [.data.prex_size], 3
        mov     [.data.prex_0], cl
        mov     cl, byte [esi + 1]
        mov     [.data.prex_1], cl
        mov     cl, byte [esi + 2]
        mov     [.data.prex_2], cl
        add     esi, 3                          ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        add     eax, 3                          ; eax = opcode size
   .vex.3.pr?:                                  ; implied mandatory prefixes
        mov     bl, [.data.prex_2]
        and     bl, 00000011B                   ; bl = implied mandatory prefix
        cmp     bl, 1                           ; 01B:0x66 | 10B:0xF3 | 11B:0xF2
        jne    .vex.3.pr.out
   .vex.3.pr66:
        mov     [.pr_66], 1
   .vex.3.pr.out:
   .vex.3.flag:
   .vex.3.flag.rex.w:
        mov     bl, [.data.prex_2]
        shr     bl, 7
        and     bl, 1
        mov     [.rex_w], bl
   .vex.3.flag.mmmmm:
        mov     bl, [.data.prex_1]
        and     bl, 00011111B                   ; bl = vex_mmmmm
        cmp     bl, 3
        je     .vex.3.flag.0F3A.op
        cmp     bl, 2
        je     .vex.3.flag.0F38.op
        cmp     bl, 1
        je     .vex.3.flag.0F.op
   .vex.3.flag.op:                              ; <op>
        or      [.data.flags], IDA_INVALID
        jmp    .return
;      .opf.rcx IDA_flags                       ; bl = opcode flag
;       jmp    .vex.3.flag.leave
   .vex.3.flag.0F.op:                           ; [0F] <op>
       .opf.ecx IDA_flags_ex                    ; bl = opcode flag
        jmp    .vex.3.flag.leave
   .vex.3.flag.0F38.op:                         ; [0F38] <op>
       .opf.imm IDA_flags_ex, 0x38              ; bl = opcode flag
        jmp    .vex.3.flag.leave
   .vex.3.flag.0F3A.op:                         ; [0F3A] <op>
       .opf.imm IDA_flags_ex, 0x3A              ; bl = opcode flag
;       jmp    .vex.3.flag.leave
   .vex.3.flag.leave:
        mov     bh, bl
        mov     [.flag], bl
   .vex.3.invalid?:
        and     bl, OP_INVALID                  ; bl = opcode flag
        jz     .opcode.enter
;       jz     .vex.3.leave
   .vex.3.invalid:
        ; (f & OP_INVALID)
        or      [.data.flags], IDA_INVALID
        jmp    .return
   .vex.3.leave:

        ; ——————————————————————————————————————————————————————————————————
        ; Intel® 64 and IA-32 Architectures Software Developer’s Manual V2A
        ; ——————————————————————————————————————————————————————————————————
        ; 2.7 INTEL® AVX-512 ENCODING
        ; 2.7.11.2 Opcode Independent #UD
        ;   Table 2-38. Opcode Independent, State Dependent EVEX Bit Fields
        ;   Non-64-bit #UD: BOUND if EVEX.RX != 11b
        ; ——————————————————————————————————————————————————————————————————

        ; parse 4-byte EVEX prefix
        ; ——————————————————————————————————————————————————
        ;           |  7    6    5    4    3    2    1    0
        ; ——————————————————————————————————————————————————
        ;  0 (0x62) |  0    1    1    0    0    0    1    0
        ;  1        |  R    X    B    R'   0    0   m1   m0
        ;  2        |  W   v3   v2   v1   v0    1   p1   p0
        ;  3        |  z    L'   L    b    V'  a2   a1   a0
        ; ——————————————————————————————————————————————————
   .evex??:
        cmp     cl, 0x62
        jne    .evex.leave
   .evex?:
        cmp     [.x64], 0
        jnz    .evex
   .evex?.x32:
        mov     bl, byte [esi + 1]              ; bl = next opcode
        and     bl, 11000000B                   ; 0xC0
        cmp     bl, 11000000B                   ; x32: EVEX.RX=11B?
        jne    .evex.leave                      ; x32: 0x62 = BOUND
   .evex:                                       ; x32: EVEX.RX=11B
        or      [.data.flags], IDA_EVEX
        mov     [.data.prex_size], 4
        mov     [.data.prex_0], cl
        mov     cl, byte [esi + 1]
        mov     [.data.prex_1], cl
        mov     cl, byte [esi + 2]
        mov     [.data.prex_2], cl
        mov     cl, byte [esi + 3]
        mov     [.data.prex_3], cl
        add     esi, 4                          ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        add     eax, 4                          ; eax = opcode size
   .evex.pr?:                                   ; implied mandatory prefixes
        mov     bl, [.data.prex_2]
        and     bl, 00000011B                   ; bl = implied mandatory prefix
        cmp     bl, 1                           ; 01B:0x66 | 10B:0xF3 | 11B:0xF2
        jne    .evex.pr.out
   .evex.pr66:
        mov     [.pr_66], 1
   .evex.pr.out:
   .evex.flag:
   .evex.flag.rex.w:
        mov     bl, [.data.prex_2]
        shr     bl, 7
        and     bl, 1
        mov     [.rex_w], bl
   .evex.flag.mm:
        mov     bl, [.data.prex_1]
        and     bl, 00000011B                   ; bl = evex_mm
        cmp     bl, 3
        je     .evex.flag.0F3A.op
        cmp     bl, 2
        je     .evex.flag.0F38.op
        cmp     bl, 1
        je     .evex.flag.0F.op
   .evex.flag.op:                               ; <op>
        or      [.data.flags], IDA_INVALID
        jmp    .return
;      .opf.rcx IDA_flags                       ; bl = opcode flag
;       jmp    .evex.flag.leave
   .evex.flag.0F.op:                            ; [0F] <op>
       .opf.ecx IDA_flags_ex                    ; bl = opcode flag
        jmp    .evex.flag.leave
   .evex.flag.0F38.op:                          ; [0F38] <op>
       .opf.imm IDA_flags_ex, 0x38              ; bl = opcode flag
        jmp    .evex.flag.leave
   .evex.flag.0F3A.op:                          ; [0F3A] <op>
       .opf.imm IDA_flags_ex, 0x3A              ; bl = opcode flag
;       jmp    .evex.flag.leave
   .evex.flag.leave:
        mov     bh, bl
        mov     [.flag], bl
   .evex.invalid?:
        and     bl, OP_INVALID                  ; bl = opcode flag
        jz     .opcode.enter
;       jz     .evex.leave
   .evex.invalid:
        ; (f & OP_INVALID)
        or      [.data.flags], IDA_INVALID
        jmp    .return
   .evex.leave:

        ; parse REX prefix
        ; —————————————————
        ;  7 6 5 4 3 2 1 0
        ; —————————————————
        ;  0 1 0 0 W R X B
        ; —————————————————
   .rex?:
;       cmp     [.data.prex_size], 0
;       jnz    .rex.leave
   .rex:
        cmp     [.x64], 0
        jz     .rex.leave
   .rex.x64:
        mov     bl, cl
        shr     bl, 4
        cmp     bl, 4
        jne    .rex.leave
        ; *p >> 4 == 4                          ; opcode = 0100****
        or      [.data.flags], IDA_REX
        mov     [.data.rex], cl
   .rex.w:
        shr     cl, 3
        and     cl, 1                           ; cl = REX.W bit
        mov     [.rex_w], cl
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax
   .rex.dup?:
        ; can be only one REX prefix
        mov     bl, cl
        shr     bl, 4
        cmp     bl, 4
        jne    .rex.leave
   .rex.dup:
        ; *p >> 4 == 4                          ; opcode = 0100****
        or      [.data.flags], IDA_INVALID
;       inc     eax                             ; ??? ; eax = opcode size
        jmp    .return
   .rex.leave:

        ; phase 2: parse opcode
   .opcode.enter:
        mov     ebx, esi
        sub     ebx, edi                        ; ebx = esi - edi
        mov     [.data.opcode_offset], bl
        mov     [.data.opcode_size], 1
        mov     dl, cl                          ; dl = previous opcode
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax                             ; eax = opcode size

   .opcode?:
        cmp     [.data.prex_size], 0
        jnz    .opcode.leave
        ; is 2 byte opcode?
   .opcode:
        cmp     dl, 0x0F
        je     .opcode.2b
        ;
   .opcode.1b:
        ; (op != 0x0F)
       .opf.edx IDA_flags                       ; bl = opcode flag
        mov     [.flag], bl
        ; pr_66 = pr_67 for opcodes A0-A3
        cmp     dl, 0xA0
        jb     .opcode.leave
        cmp     dl, 0xA3
        ja     .opcode.leave
        ; (op >= 0xA0) && (op <= 0xA3)
        mov     bl, [.pr_67]
        mov     [.pr_66], bl                    ; pr_66 = pr_67
        jmp    .opcode.leave
        ;
   .opcode.2b:
        ; (op == 0x0F)
        mov     dl, cl                          ; dl = previous opcode
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax                             ; eax = opcode size
        inc     [.data.opcode_size]
       .opf.edx IDA_flags_ex                    ; bl = opcode flag
        mov     bh, bl
        mov     [.flag], bl
        ;
   .opcode.2b.invalid?:
        and     bl, OP_INVALID
        jz     .opcode.2b.invalid.leave
   .opcode.2b.invalid:
        ; (f & OP_INVALID)
        or      [.data.flags], IDA_INVALID
        jmp    .return
   .opcode.2b.invalid.leave:
        ;
   .opcode.2b.sse?:
        ; for SSE instructions
        and     bh, OP_EXTENDED
        jz     .opcode.2b.sse.leave
   .opcode.2b.sse:
        ; (f & OP_EXTENDED)
        mov     dl, cl                          ; dl = previous opcode
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax                             ; eax = opcode size
        inc     [.data.opcode_size]
   .opcode.2b.sse.leave:
        ;
   .opcode.leave:

        ; phase 3: parse ModR/M, SIB and DISP
        ;
        ; ModR/M byte
        ; —————————————————————————————
        ; | MOD   | REG/opcode | R/M  |
        ; | **    | ***        | ***  |
        ; —————————————————————————————
        ;
        ; SIB byte
        ; —————————————————————————————
        ; | SCALE | INDEX      | BASE |
        ; | **    | ***        | ***  |
        ; —————————————————————————————
        ;
   .modrm?:
        mov     bl, [.flag]
        and     bl, OP_MODRM
        jz     .modrm.leave
   .modrm:
        ; (f & OP_MODRM)
        mov     [.m_mod], cl
        shr     [.m_mod], 6                     ; **------
        mov     [.m_ro], cl
        and     [.m_ro], 0x38                   ; 0x38 = 00111000
        shr     [.m_ro], 3
        mov     [.m_rm], cl
        and     [.m_rm], 7                      ; 7 = 00000111

        mov     [.data.modrm], cl
        or      [.data.flags], IDA_MODRM
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax                             ; eax = opcode size

        ; in F6, F7 opcodes immediate data present if R/O == 0
   .modrm.F6.F7?:
        cmp     [.m_ro], 0
        je     .modrm.F6?
        cmp     [.m_ro], 1                      ; ???
        je     .modrm.F6?
        jmp    .modrm.F6.F7.leave
        ;
   .modrm.F6?:
        ; (ro == 0) || (ro == 1)
        cmp     dl, 0xF6
        jne    .modrm.F6.leave
   .modrm.F6:
        ; (op == 0xF6) && ((ro == 0) || (ro == 1))
        or      [.flag], OP_DATA_I8
   .modrm.F6.leave:
        ;
   .modrm.F7?:
        cmp     dl, 0xF7
        jne    .modrm.F7.leave
   .modrm.F7:
        ; (op == 0xF7) && ((ro == 0) || (ro == 1))
        or      [.flag], OP_DATA_I16_I32_I64
   .modrm.F7.leave:
        ;
   .modrm.F6.F7.leave:

        ; is SIB byte exist?
   .modrm.sib?:
        cmp     [.m_mod], 3
        je     .modrm.sib.leave
        cmp     [.m_rm], 4
        jne    .modrm.sib.leave
        cmp     [.x64], 0
        jnz    .modrm.sib
        cmp     [.pr_67], 0
        jnz    .modrm.sib.leave
   .modrm.sib:
        ; (mod != 3) && (rm == 4) && (is64 || !pr_67)
        mov     [.data.sib], cl
        or      [.data.flags], IDA_SIB
        inc     esi                             ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        inc     eax                             ; eax = opcode size
        ; if base == 5 and mod == 0
        mov     bl, [.data.sib]
        and     bl, 7                           ; bl = SIB.base
        cmp     bl, 5
        jne    .modrm.sib.leave
        cmp     [.m_mod], 0
        jnz    .modrm.sib.leave
        ; (base == 5) && (mod == 0)
        mov     [.data.disp_size], 4
   .modrm.sib.leave:

   .modrm.disp:
        cmp     [.m_mod], 0
        je     .modrm.disp.mod.0
        cmp     [.m_mod], 1
        je     .modrm.disp.mod.1
        cmp     [.m_mod], 2
        je     .modrm.disp.mod.2
        jmp    .modrm.disp.leave
        ;
   .modrm.disp.mod.0:
        ; (mod == 0)
        cmp     [.x64], 0
        jnz    .modrm.disp.mod.0.x64.nz
        cmp     [.pr_67], 0
        jnz    .modrm.disp.mod.0.pr_67.nz
   .modrm.disp.mod.0.else:
        cmp     [.m_rm], 5
        jne    .modrm.disp.leave
        ; (rm == 5)
        mov     [.data.disp_size], 4
        jmp    .modrm.disp.leave
   .modrm.disp.mod.0.pr_67.nz:
        ; (pr_67 != 0)
        cmp     [.m_rm], 6
        jne    .modrm.disp.leave
        ; (rm == 6)
        mov     [.data.disp_size], 2
        jmp    .modrm.disp.leave
   .modrm.disp.mod.0.x64.nz:
        ; (is64 != 0)
        cmp     [.m_rm], 5
        jne    .modrm.disp.leave
        ; (rm == 5)
        mov     [.data.disp_size], 4
        or      [.data.flags], IDA_RELATIVE
        jmp    .modrm.disp.leave
        ;
   .modrm.disp.mod.1:
        ; (mod == 1)
        mov     [.data.disp_size], 1
        jmp    .modrm.disp.leave
   .modrm.disp.mod.2:
        ; (mod == 2)
        cmp     [.x64], 0
        jnz    .modrm.disp.mod.2.x64.nz
        cmp     [.pr_67], 0
        jnz    .modrm.disp.mod.2.pr_67.nz
        ;
   .modrm.disp.mod.2.else:
        mov     [.data.disp_size], 4
        jmp    .modrm.disp.leave
   .modrm.disp.mod.2.pr_67.nz:
        ; (pr_67 != 0)
        mov     [.data.disp_size], 2
        jmp    .modrm.disp.leave
   .modrm.disp.mod.2.x64.nz:
        ; (is64 != 0)
        mov     [.data.disp_size], 4
;       jmp    .modrm.disp.leave
        ;
   .modrm.disp.leave:

   .modrm.disp.size:
        cmp     [.data.disp_size], 0
        jz     .modrm.disp.size.leave
   .modrm.disp.size.nz:
        ; (ld->disp_size != 0)
        mov     ebx, esi
        sub     ebx, edi                        ; ebx = esi - edi
        mov     [.data.disp_offset], bl
        mov     bl, [.data.disp_size]
        add     esi, ebx                        ; esi = current code pointer
        mov     cl, byte [esi]                  ; cl = current opcode
        add     eax, ebx                        ; eax = opcode size
        or      [.data.flags], IDA_DISP
   .modrm.disp.size.leave:

   .modrm.leave:

        ; phase 4: parse immediate data
   .modrm.imm.a?:
        mov     bl, [.flag]
        and     bl, OP_DATA_I16_I32_I64
        jz     .modrm.imm.b?
        cmp     [.rex_w], 0
        jnz    .modrm.imm.a
        cmp     [.x64], 0
        jz     .modrm.imm.b?
        cmp     dl, 0xA0
        jb     .modrm.imm.b?
        cmp     dl, 0xA3
        ja     .modrm.imm.b?
   .modrm.imm.a:
        ; (f & OP_DATA_I16_I32_I64) && (rexw || (is64 && (op >= 0xA0) && (op <= 0xA3))
        mov    [.data.imm_size], 8
        jmp    .modrm.imm.leave
        ;
   .modrm.imm.b?:
        mov     bl, [.flag]
        mov     bh, bl
        and     bl, OP_DATA_I16_I32
        jnz    .modrm.imm.b
        and     bh, OP_DATA_I16_I32_I64
        jnz    .modrm.imm.b
        jmp    .modrm.imm.leave
   .modrm.imm.b:
        ; (f & OP_DATA_I16_I32) || (f & OP_DATA_I16_I32_I64)
        mov     bl, [.pr_66]
        shl     bl, 1
        mov     [.data.imm_size], 4
        sub     [.data.imm_size], bl
;       jmp    .modrm.imm.leave
        ;
   .modrm.imm.leave:

        ; if exist, add OP_DATA_I16 and OP_DATA_I8 size
        mov     bl, [.flag]
        and     bl, 3
        add     [.data.imm_size], bl

   .modrm.imm.size:
        mov     bl, [.data.imm_size]
        test    bl, bl
        jz     .modrm.imm.size.leave
   .modrm.imm.size.nz:
        ; (ld->imm_size != 0)
        and     ebx, 0xFF
        add     eax, ebx
        mov     ebx, esi
        sub     ebx, edi                        ; ebx = esi - edi
        mov     [.data.imm_offset], bl
        or      [.data.flags], IDA_IMM
        ;
   .modrm.imm.relative?:
        mov     bl, [.flag]
        and     bl, OP_RELATIVE
        jz     .modrm.imm.relative.leave
   .modrm.imm.relative:
        ; (f & OP_RELATIVE)
        or      [.data.flags], IDA_RELATIVE
   .modrm.imm.relative.leave:
        ;
   .modrm.imm.size.leave:

   .error?:
        cmp     eax, 15
        jbe    .return
   .error:
        ; (s > 15)
        ; instruction is too long
        or      [.data.flags], IDA_INVALID
}

; ------------------------------------------------------------------------------

; -> edi - code pointer
; <- eax - instruction size
; <- edx - instruction flags
proc SIC_IDA.ida

    locals
       .data    T_ida_data
       .x64     db ?

       .flag    db ?
       .pr_66   db ?
       .pr_67   db ?
       .rex_w   db ?
       .m_mod   db ?
       .m_ro    db ?
       .m_rm    db ?
    endl

;       mov     [], rcx
;       mov     [], rdx
;       mov     [], r8
;       mov     [], r9

   .enter:
        push    ebx esi ecx

        mov     [.x64], 0                       ; 32-bit system

        xor     eax, eax                        ; eax = opcode size
        xor     ebx, ebx
        xor     ecx, ecx
        xor     edx, edx

;       mov     [.data.instr_size], al
        mov     [.data.flags], eax
        mov     [.data.prefix_size], al
        mov     [.data.rex], al
        mov     [.data.prex_size], al
        mov     [.data.prex_0], al
        mov     [.data.prex_1], al
        mov     [.data.prex_2], al
        mov     [.data.prex_3], al
        mov     [.data.modrm], al
        mov     [.data.sib], al
        mov     [.data.opcode_offset], al
        mov     [.data.opcode_size], al
        mov     [.data.disp_offset], al
        mov     [.data.disp_size], al
        mov     [.data.imm_offset], al
        mov     [.data.imm_size], al

;       test    edi, edi
;       jz     .leave

        SIC_IDA.code

   .return:
;       xor     edx, edx
;       mov     dl, [.data.flags]
        movzx   edx, byte [.data.flags]
   .leave:
        pop     ecx esi ebx
        ret
endp ; .ida

; ------------------------------------------------------------------------------

; INT sic_inda ( LPVOID code, LPVOID data, BYTE x64 )
;
; instruction disassembler
;
; -> code - pointer to the code
; -> data - pointer to T_ida_data structure
; -> x64  - x64=0 for 32-bit, x64!=0 for 64-bit code
;
; <- eax - instruction size
; <- edx - instruction flags
;
$proc sic_inda, code, data, .x64

    locals
       .data    T_ida_data

       .flag    db ?
       .pr_66   db ?
       .pr_67   db ?
       .rex_w   db ?
       .m_mod   db ?
       .m_ro    db ?
       .m_rm    db ?
    endl

;       mov     [code], rcx
;       mov     [data], rdx
;       mov     [.x64], r8
;       mov     [], r9

   .enter:
        push    ebx esi edi

        xor     eax, eax                        ; eax = opcode size

        mov     [.data.instr_size], al
        mov     [.data.flags], eax
        mov     [.data.prefix_size], al
        mov     [.data.rex], al
        mov     [.data.prex_size], al
        mov     [.data.prex_0], al
        mov     [.data.prex_1], al
        mov     [.data.prex_2], al
        mov     [.data.prex_3], al
        mov     [.data.modrm], al
        mov     [.data.sib], al
        mov     [.data.opcode_offset], al
        mov     [.data.opcode_size], al
        mov     [.data.disp_offset], al
        mov     [.data.disp_size], al
        mov     [.data.imm_offset], al
        mov     [.data.imm_size], al

;       mov     rdi, rcx
        mov     edi, [code]
        test    edi, edi
        jz     .return

        xor     ebx, ebx
        xor     ecx, ecx
        xor     edx, edx

        SIC_IDA.code

   .return:
   .data.enter:
        mov     edx, [data]
        test    edx, edx
        jz     .data.leave

        mov     [edx + T_ida_data.instr_size], al
        mov     ecx, [.data.flags]
        mov     [edx + T_ida_data.flags], ecx
        mov     cl, [.data.prefix_size]
        mov     [edx + T_ida_data.prefix_size], cl
        mov     cl, [.data.rex]
        mov     [edx + T_ida_data.rex], cl
        mov     cl, [.data.prex_size]
        mov     [edx + T_ida_data.prex_size], cl
        mov     cl, [.data.prex_0]
        mov     [edx + T_ida_data.prex_0], cl
        mov     cl, [.data.prex_1]
        mov     [edx + T_ida_data.prex_1], cl
        mov     cl, [.data.prex_2]
        mov     [edx + T_ida_data.prex_2], cl
        mov     cl, [.data.prex_3]
        mov     [edx + T_ida_data.prex_3], cl
        mov     cl, [.data.modrm]
        mov     [edx + T_ida_data.modrm], cl
        mov     cl, [.data.sib]
        mov     [edx + T_ida_data.sib], cl
        mov     cl, [.data.opcode_offset]
        mov     [edx + T_ida_data.opcode_offset], cl
        mov     cl, [.data.opcode_size]
        mov     [edx + T_ida_data.opcode_size], cl
        mov     cl, [.data.disp_offset]
        mov     [edx + T_ida_data.disp_offset], cl
        mov     cl, [.data.disp_size]
        mov     [edx + T_ida_data.disp_size], cl
        mov     cl, [.data.imm_offset]
        mov     [edx + T_ida_data.imm_offset], cl
        mov     cl, [.data.imm_size]
        mov     [edx + T_ida_data.imm_size], cl
   .data.leave:
;       xor     edx, edx
;       mov     dl, [.data.flags]
        movzx   edx, byte [.data.flags]
   .leave:
        pop     edi esi ebx
        ret
$endp ; sic_ida

; ------------------------------------------------------------------------------
