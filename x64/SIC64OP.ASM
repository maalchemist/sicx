
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; code optimization functions

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_OP:

; ------------------------------------------------------------------------------

DEFINE SIC_OP.RSP_PUSH_POP  TRUE ; FALSE ;
DEFINE SIC_OP.LOAD_CONST   FALSE ;  TRUE ;
DEFINE SIC_OP.FXCH         FALSE ;  TRUE ;

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.nop, code, csize

    locals
       .edi     dq ?
       .eee     dq ?
       .zzz     dq ?
       .esi     dq ?
       .ezx     dq ?
       .ecx     dq ?
       .xcx     dq ?
       .xdi     dq ?
       .xsi     dq ?
       .misize  dq ?
       .cisize  dq ?                            ; current instruction size
       .pisize  dq ?                            ; previous instruction size
    endl

    ; be sure actual code size >= a, goto b otherwise
    macro .bound a, b {
        cmp     [.zzz], a
        jl      b
    }

    macro .instr.shift.back v, p {
      if v eq
        push    [.pisize]
        pop     [.misize]
        neg     [.misize]
        inc     [.misize]                       ; [.pisize] bytes shift back
      else
        mov     [.misize], 1-(v)                ; v bytes shift back
       if p eq 1
        push    rdx
        mov     rdx, [.pisize]
        sub     [.misize], rdx
        pop     rdx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

        mov     [code], rcx
        mov     [csize], rdx
;       mov     [], r8
;       mov     [], r9

        push    rbx rsi rdi

        mov     rax, [csize]
        test    rax, rax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], rax                     ; save initial code size
        mov     rbx, rax                        ; rbx = initial code size
        mov     rdi, [code]                     ; rdi = code offset
        mov     [.eee], rdi                     ; save code offset
        mov     [.zzz], 0                       ; scanned bytes
        mov     [.ecx], rdi
        add     [.ecx], rax                     ; [.ecx] = code end pointer

        mov     [.cisize], 0
        mov     [.pisize], 0

   .cc.root:
        mov     rax, [.cisize]
        mov     [.pisize], rax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; rax = current instruction size
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        test    rax, rax
        jz     .cc.result
        mov     [.cisize], rax

   .cc.main:
        mov     [.misize], 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  macro SIC_OP.cc.L0.1B0.nop
  {
   .cc.nop.in:
        cmp     eax, 1
        jne    .cc.nop.out
        ; ---------------------------------------------------------
        ; 1 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  90       NOP              |
        ; ---------------------------------------------------------
        mov     [.esi], 1
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0x90
        jne    .cc.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 1
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.nop.out:
  }
   .cc.nop..in:
        SIC_OP.cc.L0.1B0.nop
   .cc.nop..out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
   .cc.momem:
        add     rdi, [.edi]                     ; rdi = destination memory
        cmp     rdi, rsi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     rdi, [.xdi]
        add     rdi, [.edi]
        mov     rax, [.esi]
        sub     rax, [.edi]
        sub     [.ezx], rax
        sub     [.ecx], rax
        sub     rbx, rax
        jle    .cc.result
        mov     rax, [.misize]
        jmp    .cc.next.rdi

   .cc.next:
        mov     rax, [.cisize]
   .cc.next.rdi:
        add     rdi, rax                        ; rdi = next instruction
        ;
        mov     rcx, rdi
        sub     rcx, [.eee]
        mov     [.zzz], rcx
        ;
        sub     rbx, rax
;       cmp     rbx, 0
        jg     .cc.root

   .cc.result:
        mov     rax, [.ezx]

   .cc.return:
        pop     rdi rsi rbx
        ret

        ; -> [.esi] - initial bytes
        ; <- rcx    - bytes to copy
        ; <- rsi    - source memory
   .cc.size:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.L0, sic, csize, rcode, sop

       .static.FSTP.ST0 EQU 1
       .static.FREE.ST0 EQU 1

    locals
       .byte    db ?
       .rbx     dq ?
       .edi     dq ?
       .esi     dq ?
       .ezx     dq ?
       .ecx     dq ?
       .xcx     dq ?
       .xdi     dq ?
       .xsi     dq ?
       .misize  dq ?
       .cisize  dq ?                            ; current instruction size
       .pisize  dq ?                            ; previous instruction size
    endl

    macro .instr.shift.back v, p {
      if v eq
        push    [.pisize]
        pop     [.misize]
        neg     [.misize]
        inc     [.misize]                       ; [.pisize] bytes shift back
      else
        mov     [.misize], 1-(v)                ; v bytes shift back
       if p eq 1
        push    rdx
        mov     rdx, [.pisize]
        sub     [.misize], rdx
        pop     rdx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

        mov     [sic], rcx
        mov     [csize], rdx
        mov     [rcode], r8
        mov     [sop], r9

        push    rbx rsi rdi

        mov     rax, [csize]
        test    rax, rax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], rax                     ; save initial code size
        mov     [.rbx], rax                     ; [.rbx] = initial code size
        mov     rsi, [sic]                      ; rsi = T_sic_data structure offset
        mov     rdi, [rsi + T_sic_data.code]    ; rdi = code segment entry offset
        mov     [.ecx], rdi
        add     [.ecx], rax                     ; [.ecx] = code end pointer

        xor     rax, rax
        mov     [.cisize], rax
        mov     [.pisize], rax

   .cc.root:
        mov     rax, [.cisize]
        mov     [.pisize], rax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; rax = current instruction size
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        test    rax, rax
        jz     .cc.result
        mov     [.cisize], rax
        mov     rbx, rax                        ; rbx = current instruction size

   .cc.main:
        mov     [.misize], 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.BASE?:

   .cc.L0.BASE:

  $ifdef _SSEX
  macro SIC_OP.cc.L0.6B0.xmm2.xmm2.nop
  {
   .cc.xmm2.xmm2.nop.in:
        cmp     ebx, 6
        jne    .cc.xmm2.xmm2.nop.out
        ; ---------------------------------------------------------
        ; 23 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 11 4C 24 08  MOVSD QWORD [xSP+8], XMM1
        ;  F2 0F 11 04 24     MOVSD QWORD [xSP], XMM0
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ;  90                 NOP
        ; ---------------------------------------------------------
        mov     [.esi], 23
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm2.xmm2.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x4C110FF2
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [rdi + 04], dword 0x0FF20824
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [rdi + 08], dword 0xF2240411
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [rdi + 12], dword 0x2404100F
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [rdi + 16], dword 0x4C100FF2
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [rdi + 19], dword 0x9008244C
        jne    .cc.xmm2.xmm2.nop.out
   .cc.xmm2.xmm2.nop.leave:
;       mov     [.esi], 23
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.xmm2.xmm2.nop.out:
  }
   .cc.xmm2.xmm2.nop..in:
        SIC_OP.cc.L0.6B0.xmm2.xmm2.nop
   .cc.xmm2.xmm2.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm.xmm2.nop
  {
   .cc.xmm.xmm2.nop.in:
        cmp     ebx, 5
        jne    .cc.xmm.xmm2.nop.out
        ; ---------------------------------------------------------
        ; 17 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 11 04 24     MOVSD QWORD [xSP], XMM0
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ;  90                 NOP
        ; ---------------------------------------------------------
        ; 17 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ; ---------------------------------------------------------
        mov     [.esi], 17
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm.xmm2.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04110FF2
        jne    .cc.xmm.xmm2.nop.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.xmm.xmm2.nop.out
        cmp     [rdi + 08], dword 0x0FF22404
        jne    .cc.xmm.xmm2.nop.out
        cmp     [rdi + 12], dword 0x08244C10
        jne    .cc.xmm.xmm2.nop.out
        cmp     [rdi + 16], byte 0x90
        jne    .cc.xmm.xmm2.nop.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x4C100FF2
        mov     [rdi + 04], word 0x0824
        ; ---------------------------------------------------------
;       mov     [.esi], 17
        mov     [.edi], 6
       .instr.shift.back 6, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm.xmm2.nop.out:
  }
   .cc.xmm.xmm2.nop..in:
        SIC_OP.cc.L0.5B0.xmm.xmm2.nop
   .cc.xmm.xmm2.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm.xmm.nop.fld
  {
   .cc.xmm.xmm.nop.fld.in:
        cmp     ebx, 5
        jne    .cc.xmm.xmm.nop.fld.out
        ; ---------------------------------------------------------
        ; 21 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 11 04 24     MOVSD QWORD [xSP], XMM0
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  90                 NOP
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ; 21 BYTES -> 8 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 11 04 24     MOVSD QWORD [xSP], XMM0
        ;  DD 04 24           FLD   QWORD [xSP]
        ; ---------------------------------------------------------
        mov     [.esi], 21
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm.xmm.nop.fld.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04110FF2
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [rdi + 08], dword 0xF2902404
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [rdi + 12], dword 0x2444110F
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [rdi + 16], dword 0x2444DDC0
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [rdi + 20], byte 0xC0
        jne    .cc.xmm.xmm.nop.fld.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x04110FF2
        mov     [rdi + 04], dword 0x2404DD24
        ; ---------------------------------------------------------
;       mov     [.esi], 21
        mov     [.edi], 8
       .instr.shift.back 8, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm.xmm.nop.fld.out:
  }
   .cc.xmm.xmm.nop.fld..in:
        SIC_OP.cc.L0.5B0.xmm.xmm.nop.fld
   .cc.xmm.xmm.nop.fld..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm.xmm.nop
  {
   .cc.xmm.xmm.nop.in:
        cmp     ebx, 5
        jne    .cc.xmm.xmm.nop.out
        ; ---------------------------------------------------------
        ; 11 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 11 04 24  MOVSD QWORD [xSP], XMM0
        ;  F2 0F 10 04 24  MOVSD XMM0, QWORD [xSP]
        ;  90              NOP
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm.xmm.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04110FF2
        jne    .cc.xmm.xmm.nop.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.xmm.xmm.nop.out
        cmp     [rdi + 07], dword 0x90240410
        jne    .cc.xmm.xmm.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 11
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.xmm.xmm.nop.out:
  }
   .cc.xmm.xmm.nop..in:
        SIC_OP.cc.L0.5B0.xmm.xmm.nop
   .cc.xmm.xmm.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm.nop.fld
  {
   .cc.xmm.nop.fld.in:
        cmp     ebx, 5
        jne    .cc.xmm.nop.fld.out
        ; ---------------------------------------------------------
        ; 16 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  90                 NOP
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ; 16 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;> DD 04 24           FLD   QWORD [xSP]
        ; ---------------------------------------------------------
        mov     [.esi], 16
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm.nop.fld.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04100FF2
        jne    .cc.xmm.nop.fld.out
        cmp     [rdi + 04], dword 0x0FF29024
        jne    .cc.xmm.nop.fld.out
        cmp     [rdi + 08], dword 0xC0244411
        jne    .cc.xmm.nop.fld.out
        cmp     [rdi + 12], dword 0xC02444DD
        jne    .cc.xmm.nop.fld.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], word 0x04DD
        mov     [rdi + 02], byte 0x24
        ; ---------------------------------------------------------
;       mov     [.esi], 16
        mov     [.edi], 3
       .instr.shift.back 3, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm.nop.fld.out:
  }
   .cc.xmm.nop.fld..in:
        SIC_OP.cc.L0.5B0.xmm.nop.fld
   .cc.xmm.nop.fld..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm.nop
  {
   .cc.xmm.nop.in:
        cmp     ebx, 5
        jne    .cc.xmm.nop.out
        ; ---------------------------------------------------------
        ; 6 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24  MOVSD XMM0, QWORD [xSP]
        ;  90              NOP
        ; ---------------------------------------------------------
        ; 6 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24  MOVSD XMM0, QWORD [xSP]
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04100FF2
        jne    .cc.xmm.nop.out
        cmp     [rdi + 04], word 0x9024
        jne    .cc.xmm.nop.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x04100FF2
        mov     [rdi + 04], byte 0x24
        ; ---------------------------------------------------------
;       mov     [.esi], 6
        mov     [.edi], 5
       .instr.shift.back 5, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm.nop.out:
  }
   .cc.xmm.nop..in:
        SIC_OP.cc.L0.5B0.xmm.nop
   .cc.xmm.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm2.nop.fld.01
  {
   .cc.xmm2.nop.fld.01.in:
        cmp     ebx, 5
        jne    .cc.xmm2.nop.fld.01.out
        ; ---------------------------------------------------------
        ; 32 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ;  90                 NOP
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ;  F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ; 32 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;> DD 04 24           FLD   QWORD [xSP]
        ;  DD 44 24 08        FLD   QWORD [xSP+8]
        ; ---------------------------------------------------------
        mov     [.esi], 32
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm2.nop.fld.01.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04100FF2
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 08], dword 0x9008244C
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 12], dword 0x44110FF2
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 16], dword 0x44DDC024
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 20], dword 0x0FF2C024
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 24], dword 0xC0244C11
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [rdi + 28], dword 0xC02444DD
        jne    .cc.xmm2.nop.fld.01.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x002404DD
        mov     [rdi + 03], dword 0x082444DD
        ; ---------------------------------------------------------
;       mov     [.esi], 32
        mov     [.edi], 7
       .instr.shift.back 7, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm2.nop.fld.01.out:
  }
   .cc.xmm2.nop.fld.01..in:
        SIC_OP.cc.L0.5B0.xmm2.nop.fld.01
   .cc.xmm2.nop.fld.01..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm2.nop.fld.10
  {
   .cc.xmm2.nop.fld.10.in:
        cmp     ebx, 5
        jne    .cc.xmm2.nop.fld.10.out
        ; ---------------------------------------------------------
        ; 32 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ;  90                 NOP
        ;  F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ; 32 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;> DD 44 24 08        FLD   QWORD [xSP+8]
        ;  DD 04 24           FLD   QWORD [xSP]
        ; ---------------------------------------------------------
        mov     [.esi], 32
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm2.nop.fld.10.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04100FF2
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 08], dword 0x9008244C
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 12], dword 0x4C110FF2
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 16], dword 0x44DDC024
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 20], dword 0x0FF2C024
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 24], dword 0xC0244411
        jne    .cc.xmm2.nop.fld.10.out
        cmp     [rdi + 28], dword 0xC02444DD
        jne    .cc.xmm2.nop.fld.10.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x082444DD
        mov     [rdi + 03], dword 0x2404DD08
        ; ---------------------------------------------------------
;       mov     [.esi], 32
        mov     [.edi], 7
       .instr.shift.back 7, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm2.nop.fld.10.out:
  }
   .cc.xmm2.nop.fld.10..in:
        SIC_OP.cc.L0.5B0.xmm2.nop.fld.10
   .cc.xmm2.nop.fld.10..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.xmm2.nop
  {
   .cc.xmm2.nop.in:
        cmp     ebx, 5
        jne    .cc.xmm2.nop.out
        ; ---------------------------------------------------------
        ; 12 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ;  90                 NOP
        ; ---------------------------------------------------------
        ; 12 BYTES -> 11 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [xSP+8]
        ; ---------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm2.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04100FF2
        jne    .cc.xmm2.nop.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.xmm2.nop.out
        cmp     [rdi + 08], dword 0x9008244C
        jne    .cc.xmm2.nop.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x04100FF2
        mov     [rdi + 04], dword 0x100FF224
        mov     [rdi + 07], dword 0x08244C10
        ; ---------------------------------------------------------
;       mov     [.esi], 12
        mov     [.edi], 11
       .instr.shift.back 11, 1                  ; instruction shift back
        jmp    .cc.momem
   .cc.xmm2.nop.out:
  }
   .cc.xmm2.nop..in:
        SIC_OP.cc.L0.5B0.xmm2.nop
   .cc.xmm2.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.4B0.rspB.xsd.nop
  {
   .cc.rspB.xsd.nop.in:
        cmp     ebx, 4
        jne    .cc.rspB.xsd.nop.out
        ; ---------------------------------------------------------
        ; 15 BYTES
        ; ---------------------------------------------------------
        ;> 48 83 C4 FF         ADD   RSP, FF
        ;  F2 0F 10 4C 24 FF   MOVSD XMM1, QWORD [RSP+FF]
        ; ?F2 0F 58 C1         ADDSD XMM0, XMM1
        ; ?F2 0F 5C C1         SUBSD XMM0, XMM1
        ; ?F2 0F 59 C1         MULSD XMM0, XMM1
        ; ?F2 0F 5E C1         DIVSD XMM0, XMM1
        ;  90                  NOP
        ; ---------------------------------------------------------
        ; 15 BYTES -> 10 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 44 24 FF   ADDSD XMM0, QWORD [RSP+FF]
        ; ?F2 0F 5C 44 24 FF   SUBSD XMM0, QWORD [RSP+FF]
        ; ?F2 0F 59 44 24 FF   MULSD XMM0, QWORD [RSP+FF]
        ; ?F2 0F 5E 44 24 FF   DIVSD XMM0, QWORD [RSP+FF]
        ;  48 83 C4 FF         ADD   RSP, FF
        ; ---------------------------------------------------------
        ; 15 BYTES -> 13 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 84 24 FF+  ADDSD XMM0, QWORD [RSP+FF+]
        ; ?F2 0F 5C 84 24 FF+  SUBSD XMM0, QWORD [RSP+FF+]
        ; ?F2 0F 59 84 24 FF+  MULSD XMM0, QWORD [RSP+FF+]
        ; ?F2 0F 5E 84 24 FF+  DIVSD XMM0, QWORD [RSP+FF+]
        ;  48 83 C4 FF         ADD   RSP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 15
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rspB.xsd.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], byte 0x48
        jne    .cc.rspB.xsd.nop.out
        cmp     [rdi + 01], word 0xC483
        jne    .cc.rspB.xsd.nop.out
        cmp     [rdi + 04], dword 0x4C100FF2
        jne    .cc.rspB.xsd.nop.out
        cmp     [rdi + 08], byte 0x24
        jne    .cc.rspB.xsd.nop.out
        cmp     [rdi + 10], word 0x0FF2
        jne    .cc.rspB.xsd.nop.out
        cmp     [rdi + 13], word 0x90C1
        jne    .cc.rspB.xsd.nop.out
        ; ---------------------------------------------------------
        movsx   edx, byte [rdi + 03]
        movsx   eax, byte [rdi + 09]
        add     edx, eax
        cmp     edx, +127
        jg     .cc.rspB.xsd.nop.D
        cmp     edx, -128
        jl     .cc.rspB.xsd.nop.D
   .cc.rspB.xsd.nop.B:
        ; ---------------------------------------------------------
        ; 15 BYTES -> 10 BYTES
        ; ---------------------------------------------------------
        mov     al, byte [rdi + 03]
        mov     ah, byte [rdi + 12]
        mov     [rdi + 00], word 0x0FF2
        mov     [rdi + 02], ah
        mov     [rdi + 03], word 0x2444
        mov     [rdi + 05], dl
        mov     [rdi + 06], byte 0x48
        mov     [rdi + 07], word 0xC483
        mov     [rdi + 09], al
        ; ---------------------------------------------------------
;       mov     [.esi], 15
        mov     [.edi], 10
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspB.xsd.nop.D:
        ; ---------------------------------------------------------
        ; 15 BYTES -> 13 BYTES
        ; ---------------------------------------------------------
        mov     al, byte [rdi + 03]
        mov     ah, byte [rdi + 12]
        mov     [rdi + 00], word 0x0FF2
        mov     [rdi + 02], ah
        mov     [rdi + 03], word 0x2484
        mov     [rdi + 05], edx
        mov     [rdi + 09], byte 0x48
        mov     [rdi + 10], word 0xC483
        mov     [rdi + 12], al
        ; ---------------------------------------------------------
;       mov     [.esi], 15
        mov     [.edi], 13
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspB.xsd.nop.out:
  }
   .cc.rspB.xsd.nop..in:
        SIC_OP.cc.L0.4B0.rspB.xsd.nop
   .cc.rspB.xsd.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.7B0.rspD.xsd.nop
  {
   .cc.rspD.xsd.nop.in:
        cmp     ebx, 7
        jne    .cc.rspD.xsd.nop.out
        ; ---------------------------------------------------------
        ; 18 BYTES
        ; ---------------------------------------------------------
        ;> 48 81 C4 FF+        ADD   RSP, FF+
        ;  F2 0F 10 4C 24 FF   MOVSD XMM1, QWORD [RSP+FF]
        ; ?F2 0F 58 C1         ADDSD XMM0, XMM1
        ; ?F2 0F 5C C1         SUBSD XMM0, XMM1
        ; ?F2 0F 59 C1         MULSD XMM0, XMM1
        ; ?F2 0F 5E C1         DIVSD XMM0, XMM1
        ;  90                  NOP
        ; ---------------------------------------------------------
        ; 18 BYTES -> 13 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 44 24 FF   ADDSD XMM0, QWORD [RSP+FF]
        ; ?F2 0F 5C 44 24 FF   SUBSD XMM0, QWORD [RSP+FF]
        ; ?F2 0F 59 44 24 FF   MULSD XMM0, QWORD [RSP+FF]
        ; ?F2 0F 5E 44 24 FF   DIVSD XMM0, QWORD [RSP+FF]
        ;  48 81 C4 FF+        ADD   RSP, FF+
        ; ---------------------------------------------------------
        ; 18 BYTES -> 16 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 84 24 FF+  ADDSD XMM0, QWORD [RSP+FF+]
        ; ?F2 0F 5C 84 24 FF+  SUBSD XMM0, QWORD [RSP+FF+]
        ; ?F2 0F 59 84 24 FF+  MULSD XMM0, QWORD [RSP+FF+]
        ; ?F2 0F 5E 84 24 FF+  DIVSD XMM0, QWORD [RSP+FF+]
        ;  48 81 C4 FF+        ADD   RSP, FF+
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rspD.xsd.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], byte 0x48
        jne    .cc.rspD.xsd.nop.out
        cmp     [rdi + 01], word 0xC481
        jne    .cc.rspD.xsd.nop.out
        cmp     [rdi + 07], dword 0x4C100FF2
        jne    .cc.rspD.xsd.nop.out
        cmp     [rdi + 11], byte 0x24
        jne    .cc.rspD.xsd.nop.out
        cmp     [rdi + 13], word 0x0FF2
        jne    .cc.rspD.xsd.nop.out
        cmp     [rdi + 16], word 0x90C1
        jne    .cc.rspD.xsd.nop.out
        ; ---------------------------------------------------------
        mov     edx, dword [rdi + 03]
        movsx   eax, byte [rdi + 12]
        add     edx, eax
        cmp     edx, +127
        jg     .cc.rspD.xsd.nop.D
        cmp     edx, -128
        jl     .cc.rspD.xsd.nop.D
   .cc.rspD.xsd.nop.B:
        ; ---------------------------------------------------------
        ; 18 BYTES -> 13 BYTES
        ; ---------------------------------------------------------
        mov     r8d, dword [rdi + 03]
        mov     ah, byte [rdi + 15]
        mov     [rdi + 00], word 0x0FF2
        mov     [rdi + 02], ah
        mov     [rdi + 03], word 0x2444
        mov     [rdi + 05], dl
        mov     [rdi + 06], byte 0x48
        mov     [rdi + 07], word 0xC481
        mov     [rdi + 09], r8d
        ; ---------------------------------------------------------
;       mov     [.esi], 18
        mov     [.edi], 13
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspD.xsd.nop.D:
        ; ---------------------------------------------------------
        ; 18 BYTES -> 16 BYTES
        ; ---------------------------------------------------------
        mov     r8d, dword [rdi + 03]
        mov     ah, byte [rdi + 15]
        mov     [rdi + 00], word 0x0FF2
        mov     [rdi + 02], ah
        mov     [rdi + 03], word 0x2484
        mov     [rdi + 05], edx
        mov     [rdi + 09], byte 0x48
        mov     [rdi + 10], dword 0xC481
        mov     [rdi + 12], r8d
        ; ---------------------------------------------------------
;       mov     [.esi], 18
        mov     [.edi], 16
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspD.xsd.nop.out:
  }
   .cc.rspD.xsd.nop..in:
        SIC_OP.cc.L0.7B0.rspD.xsd.nop
   .cc.rspD.xsd.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.6B0.xmm.xsd.nop
  {
   .cc.xmm.xsd.nop.in:
        cmp     ebx, 6
        jne    .cc.xmm.xsd.nop.out
        ; ---------------------------------------------------------
        ; 11 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 4C 24 FF  MOVSD XMM1, QWORD [xSP+FF]
        ; ?F2 0F 58 C1        ADDSD XMM0, XMM1
        ; ?F2 0F 5C C1        SUBSD XMM0, XMM1
        ; ?F2 0F 59 C1        MULSD XMM0, XMM1
        ; ?F2 0F 5E C1        DIVSD XMM0, XMM1
        ;  90                 NOP
        ; ---------------------------------------------------------
        ; 11 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;>?F2 0F 58 44 24 FF  ADDSD XMM0, QWORD [xSP+FF]
        ; ?F2 0F 5C 44 24 FF  SUBSD XMM0, QWORD [xSP+FF]
        ; ?F2 0F 59 44 24 FF  MULSD XMM0, QWORD [xSP+FF]
        ; ?F2 0F 5E 44 24 FF  DIVSD XMM0, QWORD [xSP+FF]
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xmm.xsd.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x4C100FF2
        jne    .cc.xmm.xsd.nop.out
        cmp     [rdi + 04], byte 0x24
        jne    .cc.xmm.xsd.nop.out
        cmp     [rdi + 06], word 0x0FF2
        jne    .cc.xmm.xsd.nop.out
        cmp     [rdi + 09], word 0x90C1
        jne    .cc.xmm.xsd.nop.out
        ; ---------------------------------------------------------
        mov     al, byte [rdi + 05]
        mov     ah, byte [rdi + 08]
        mov     [rdi + 00], word 0x0FF2
        mov     [rdi + 02], ah
        mov     [rdi + 03], word 0x2444
        mov     [rdi + 05], al
        ; ---------------------------------------------------------
;       mov     [.esi], 11
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.xmm.xsd.nop.out:
  }
   .cc.xmm.xsd.nop..in:
        SIC_OP.cc.L0.6B0.xmm.xsd.nop
   .cc.xmm.xsd.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.10B0.100
  {
        cmp     ebx, 10
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.100.out
        cmp     [rdi + 10], word 0x31FF
        jne    .cc.100.out
        cmp     [rdi + 12], word 0xB948
        je     .cc.100.02
   .cc.100..01:
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; ?F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ; ?DD 44 24 C0        FLD   QWORD [xSP-64]
        ; -------------------------------------------------------------------------
        cmp     [rdi + 12], dword 0x04100FF2
        jne    .cc.100.out
        cmp     [rdi + 16], word 0x9024
        jne    .cc.100.out
        cmp     [rdi + 18], dword 0x44110FF2
        je     .cc.100.01.01
        ; -------------------------------------------------------------------------
        ; 18 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; 18 BYTES -> 18 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  F2 0F 10 01        MOVSD XMM0, QWORD [RCX]
        ;  48 83 C4 F8        ADD   RSP, -08
        ; -------------------------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     [rdi + 10], dword 0x01100FF2
        mov     [rdi + 14], dword 0xF8C48348
;       mov     [.esi], 18
        mov     [.edi], 18
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.01.01:
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; ?F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ; ?DD 44 24 C0        FLD   QWORD [xSP-64]
        ; -------------------------------------------------------------------------
        cmp     [rdi + 22], dword 0x44DDC024
        jne    .cc.100.out
        cmp     [rdi + 26], word 0xC024
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; -------------------------------------------------------------------------
        ; 28 BYTES -> 16 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 AA+          MOV   RCX, AA+
        ;  DD 01              FLD   QWORD [RCX]
        ;  48 83 C4 F8        ADD   RSP, -08
        ; -------------------------------------------------------------------------
        mov     [.esi], 28
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     [rdi + 10], word 0x01DD
        mov     [rdi + 12], dword 0xF8C48348
;       mov     [.esi], 28
        mov     [.edi], 16
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.02:
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV  RCX, BB+
        ;  FF 31              PUSH QWORD [RCX]
        ;  48 B9 AA+          MOV  RCX, AA+
        ;  FF 31              PUSH QWORD [RCX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [rdi + 22], word 0x31FF
        jne    .cc.100.out
        cmp     [rdi + 24], word 0xB948
        je     .cc.100.03
   .cc.100..02:
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ;? F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ;? F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ;? F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ;? F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        cmp     [rdi + 24], dword 0x04100FF2
        jne    .cc.100.out
        cmp     [rdi + 28], dword 0x100FF224
        jne    .cc.100.out
        cmp     [rdi + 32], word 0x244C
        jne    .cc.100.out
        cmp     [rdi + 34], word 0x9008
        jne    .cc.100.out
        cmp     [rdi + 36], dword 0x44110FF2
        je     .cc.100.02.01
        cmp     [rdi + 36], dword 0x4C110FF2
        je     .cc.100.02.02
        ; -------------------------------------------------------------------------
        ; 36 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; 36 BYTES -> 32 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  48 B8 AA+          MOV   RAX, AA+
        ;  F2 0F 10 00        MOVSD XMM0, QWORD [RAX]
        ;  F2 0F 10 09        MOVSD XMM1, QWORD [RCX]
        ;  48 83 C4 F0        ADD   RSP, -16
        ; -------------------------------------------------------------------------
        mov     [.esi], 36
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     rax, [rdi + 14]
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x00100FF2
        mov     [rdi + 24], dword 0x09100FF2
        mov     [rdi + 28], dword 0xF0C48348
;       mov     [.esi], 36
        mov     [.edi], 32
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.02.01:
        ; --------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ;  F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        cmp     [rdi + 40], dword 0x44DDC024
        jne    .cc.100.out
        cmp     [rdi + 44], dword 0x0FF2C024
        jne    .cc.100.out
        cmp     [rdi + 44], dword 0xC0244C11
        jne    .cc.100.out
        cmp     [rdi + 48], dword 0xC02444DD
        jne    .cc.100.out
        ; ---------------------------------------------------------
        ; 56 BYTES -> 28 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  48 B8 AA+          MOV   RAX, AA+
        ;  DD 00              FLD   QWORD [RAX]
        ;  DD 01              FLD   QWORD [RCX]
        ;  48 83 C4 F0        ADD   RSP, -16
        ; -------------------------------------------------------------------------
        mov     [.esi], 56
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     rax, [rdi + 14]
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x01DD00DD
        mov     [rdi + 24], dword 0xF0C48348
;       mov     [.esi], 56
        mov     [.edi], 28
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.02.02:
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; ---------------------------------------------------------
        ;  F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ;  F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;  DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        cmp     [rdi + 40], dword 0x44DDC024
        jne    .cc.100.out
        cmp     [rdi + 44], dword 0x0FF2C024
        jne    .cc.100.out
        cmp     [rdi + 44], dword 0xC0244411
        jne    .cc.100.out
        cmp     [rdi + 48], dword 0xC02444DD
        jne    .cc.100.out
        ; ---------------------------------------------------------
        ; 56 BYTES -> 28 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  48 B8 AA+          MOV   RAX, AA+
        ;  DD 01              FLD   QWORD [RCX]
        ;  DD 00              FLD   QWORD [RAX]
        ;  48 83 C4 F0        ADD   RSP, -16
        ; -------------------------------------------------------------------------
        mov     [.esi], 56
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     rax, [rdi + 14]
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x00DD01DD
        mov     [rdi + 24], dword 0xF0C48348
;       mov     [.esi], 56
        mov     [.edi], 28
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.03:
        ; -------------------------------------------------------------------------
        ;> 48 B9 CC+          MOV  RCX, CC+
        ;  FF 31              PUSH QWORD [RCX]
        ;  48 B9 BB+          MOV  RCX, BB+
        ;  FF 31              PUSH QWORD [RCX]
        ;  48 B9 AA+          MOV  RCX, AA+
        ;  FF 31              PUSH QWORD [RCX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [rdi + 32], word 0x31FF
        jne    .cc.100.out
   .cc.100..03:
        ; -------------------------------------------------------------------------
        ; 54 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 CC+          MOV   RCX, CC+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  F2 0F 10 54 24 10  MOVSD XMM2, QWORD [ESP + 16]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; 54 BYTES -> 46 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 CC+          MOV   RCX, CC+
        ;  48 BA BB+          MOV   RDX, BB+
        ;  48 B8 AA+          MOV   RAX, AA+
        ;  F2 0F 10 00        MOVSD XMM0, QWORD [RAX]
        ;  F2 0F 10 0A        MOVSD XMM1, QWORD [RDX]
        ;  F2 0F 10 11        MOVSD XMM2, QWORD [RCX]
        ;  48 83 C4 E8        ADD   RSP, -24
        ; -------------------------------------------------------------------------
        cmp     [rdi + 36], dword 0x04100FF2
        jne    .cc.100.out
        cmp     [rdi + 40], dword 0x100FF224
        jne    .cc.100.out
        cmp     [rdi + 44], dword 0xF208244C
        jne    .cc.100.out
        cmp     [rdi + 48], dword 0x2454100F
        jne    .cc.100.out
        cmp     [rdi + 52], word 0x9010
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 54
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     rdx, [rdi + 14]
        mov     rax, [rdi + 26]
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB848
        mov     [rdi + 22], rax
        mov     [rdi + 30], dword 0x00100FF2
        mov     [rdi + 34], dword 0x0A100FF2
        mov     [rdi + 38], dword 0x11100FF2
        mov     [rdi + 42], dword 0xE8C48348
;       mov     [.esi], 54
        mov     [.edi], 46
       .instr.shift.back 4                       ; instruction shift back
        jmp    .cc.momem
   .cc.100.out:
  }
   .cc.100..in:
        SIC_OP.cc.L0.10B0.100
   .cc.100..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.10B0.101
  {
        cmp     ebx, 10
        jne    .cc.101.out
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  51                 PUSH  RCX
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ;? F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ;? F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ;? F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ;? F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ; -------------------------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.101.out
        cmp     [rdi + 10], dword 0xB94831FF
        jne    .cc.101.out
        cmp     [rdi + 22], dword 0x100FF251
        jne    .cc.101.out
        cmp     [rdi + 26], dword 0x0FF22404
        jne    .cc.101.out
        cmp     [rdi + 30], dword 0x08244C10
        jne    .cc.101.out
        cmp     [rdi + 34], byte 0x90
        jne    .cc.101.out
   .cc.101..01:
        ; -------------------------------------------------------------------------
        ; 35 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  51                 PUSH  RCX
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; 35 BYTES -> 33 BYTES
        ; -------------------------------------------------------------------------
        ;  48 B9 BB+          MOV   RCX, BB+
        ;  48 B8 AA+          MOV   RAX, AA+
        ;  66 48 0F 6E C0     MOVQ  XMM0, RAX
        ;  F2 0F 10 09        MOVSD XMM1, QWORD [RCX]
        ;  48 83 C4 F0        ADD   RSP, -16
        ; -------------------------------------------------------------------------
        mov     [.esi], 35
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.101.out
        ; ---------------------------------------------------------
        mov     rax, [rdi + 14]
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x100FF2C0
        mov     [rdi + 28], dword 0xC4834809
        mov     [rdi + 32], byte 0xF0
;       mov     [.esi], 35
        mov     [.edi], 33
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.101.out:
  }
   .cc.101..in:
        SIC_OP.cc.L0.10B0.101
   .cc.101..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.10B0.102
  {
        cmp     ebx, 10
        jne    .cc.102.out
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  51                 PUSH  RCX
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ;? F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ;? F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ; ---------------------------------------------------------
        ;? F2 0F 11 4C 24 C0  MOVSD QWORD [xSP-64], XMM1
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ;? F2 0F 11 44 24 C0  MOVSD QWORD [xSP-64], XMM0
        ;? DD 44 24 C0        FLD   QWORD [xSP-64]
        ; -------------------------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.102.out
        cmp     [rdi + 10], byte 0x51
        jne    .cc.102.out
        cmp     [rdi + 11], word 0xB948
        jne    .cc.102.out
        cmp     [rdi + 21], dword 0x0FF231FF
        jne    .cc.102.out
        cmp     [rdi + 25], dword 0xF2240410
        jne    .cc.102.out
        cmp     [rdi + 29], dword 0x244C100F
        jne    .cc.102.out
        cmp     [rdi + 33], word 0x9008
        jne    .cc.102.out
   .cc.102..01:
        ; -------------------------------------------------------------------------
        ; 35 BYTES
        ; -------------------------------------------------------------------------
        ;> 48 B9 BB+          MOV   RCX, BB+
        ;  51                 PUSH  RCX
        ;  48 B9 AA+          MOV   RCX, AA+
        ;  FF 31              PUSH  QWORD [RCX]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08  MOVSD XMM1, QWORD [ESP + 8]
        ;  90                 NOP
        ; -------------------------------------------------------------------------
        ; 35 BYTES -> 33 BYTES
        ; -------------------------------------------------------------------------
        ;  48 B9 BB+          MOV   RCX, BB+
        ;  48 B8 AA+          MOV   RAX, AA+
        ;  F2 0F 10 00        MOVSD XMM0, QWORD [RAX]
        ;  66 48 0F 6E C9     MOVQ  XMM1, RCX
        ;  48 83 C4 F0        ADD   RSP, -16
        ; -------------------------------------------------------------------------
        mov     [.esi], 35
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.102.out
        ; ---------------------------------------------------------
        mov     rax, [rdi + 13]
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x00100FF2
        mov     [rdi + 24], dword 0x6E0F4866
        mov     [rdi + 28], dword 0xC48348C9
        mov     [rdi + 32], byte 0xF0
;       mov     [.esi], 35
        mov     [.edi], 33
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.102.out:
  }
   .cc.102..in:
        SIC_OP.cc.L0.10B0.102
   .cc.102..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B0.fstp2.fld2.nop
  {
   .cc.fstp2.fld2.nop.in:
        cmp     ebx, 4
        jne    .cc.fstp2.fld2.nop.out
        ; ---------------------------------------------------------
        ; 15 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  DD5C2408 FSTP QWORD [xSP+8] |
        ;   DD1C24   FSTP QWORD [xSP]   |
        ;   DD0424   FLD  QWORD [xSP]   |
        ;   DD442408 FLD  QWORD [xSP+8] |
        ;   90       NOP                |
        ; ---------------------------------------------------------
        mov     [.esi], 15
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fstp2.fld2.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x08245CDD
        jne    .cc.fstp2.fld2.nop.out
        cmp     [rdi + 04], dword 0xDD241CDD
        jne    .cc.fstp2.fld2.nop.out
        cmp     [rdi + 08], dword 0x44DD2404
        jne    .cc.fstp2.fld2.nop.out
        cmp     [rdi + 11], dword 0x90082444
        jne    .cc.fstp2.fld2.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 15
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.fstp2.fld2.nop.out:
  }
   .cc.fstp2.fld2.nop..in:
        SIC_OP.cc.L0.4B0.fstp2.fld2.nop
   .cc.fstp2.fld2.nop..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B0.fstp.fld2.nop
  {
   .cc.fstp.fld2.nop.in:
        cmp     ebx, 3
        jne    .cc.fstp.fld2.nop.out
        ; ---------------------------------------------------------
        ; 11 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  DD1C24   FSTP QWORD [xSP]   | DD442408 FLD  QWORD [xSP+8]
        ;   DD0424   FLD  QWORD [xSP]   |
        ;   DD442408 FLD  QWORD [xSP+8] |
        ;   90       NOP                |
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fstp.fld2.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0xDD241CDD
        jne    .cc.fstp.fld2.nop.out
        cmp     [rdi + 04], dword 0x44DD2404
        jne    .cc.fstp.fld2.nop.out
        cmp     [rdi + 07], dword 0x90082444
        jne    .cc.fstp.fld2.nop.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x082444DD
        ; ---------------------------------------------------------
;       mov     [.esi], 11
        mov     [.edi], 4
       .instr.shift.back 4, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.fstp.fld2.nop.out:
  }
   .cc.fstp.fld2.nop..in:
        SIC_OP.cc.L0.3B0.fstp.fld2.nop
   .cc.fstp.fld2.nop..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B0.fstp.fld.nop
  {
   .cc.fstp.fld.nop.in:
        cmp     ebx, 3
        jne    .cc.fstp.fld.nop.out
        ; ---------------------------------------------------------
        ; 7 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  DD1C24   FSTP QWORD [xSP] |
        ;   DD0424   FLD  QWORD [xSP] |
        ;   90       NOP              |
        ; ---------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fstp.fld.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xDD241CDD
        jne    .cc.fstp.fld.nop.out
        cmp     [rdi + 3], dword 0x902404DD
        jne    .cc.fstp.fld.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 7
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.fstp.fld.nop.out:
  }
   .cc.fstp.fld.nop..in:
        SIC_OP.cc.L0.3B0.fstp.fld.nop
   .cc.fstp.fld.nop..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B0.fld.nop
  {
   .cc.fld.nop.in:
        cmp     ebx, 3
        jne    .cc.fld.nop.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  DD0424   FLD  QWORD [xSP] | DD0424   FLD  QWORD [xSP]
        ;   90       NOP              |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fld.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0x902404DD
        jne    .cc.fld.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 4
        mov     [.edi], 3
       .instr.shift.back 3, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.fld.nop.out:
  }
   .cc.fld.nop..in:
        SIC_OP.cc.L0.3B0.fld.nop
   .cc.fld.nop..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B0.fld2.nop
  {
   .cc.fld2.nop.in:
        cmp     ebx, 3
        jne    .cc.fld2.nop.out
        ; ---------------------------------------------------------
        ; 8 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;>  DD0424   FLD  QWORD [xSP]   | DD0424   FLD  QWORD [xSP]
        ;   DD442408 FLD  QWORD [xSP+8] | DD442408 FLD  QWORD [xSP+8]
        ;   90       NOP                |
        ; ---------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fld2.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xDD2404DD
        jne    .cc.fld2.nop.out
        cmp     [rdi + 4], dword 0x90082444
        jne    .cc.fld2.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 8
        mov     [.edi], 7
       .instr.shift.back 7, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.fld2.nop.out:
  }
   .cc.fld2.nop..in:
        SIC_OP.cc.L0.3B0.fld2.nop
   .cc.fld2.nop..out:
  $end

  macro SIC_OP.cc.L0.1B0.nop
  {
   .cc.nop.in:
        cmp     ebx, 1
        jne    .cc.nop.out
        ; ---------------------------------------------------------
        ; 1 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  90       NOP              |
        ; ---------------------------------------------------------
        mov     [.esi], 1
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.nop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0x90
        jne    .cc.nop.out
        ; ---------------------------------------------------------
;       mov     [.esi], 1
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.nop.out:
  }
   .cc.nop..in:
        SIC_OP.cc.L0.1B0.nop
   .cc.nop..out:

   .cc.L0.BASE.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.4B_7B?:
        cmp     ebx, 4
        je     .cc.L0.4B_7B
        cmp     ebx, 7
        jne    .cc.L0.4B_7B.out

   .cc.L0.4B_7B:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B_7B.a0
  {
   .cc.a0.in:
        cmp     ebx, 4
        je     .cc.a0.spB
;       cmp     ebx, 7
;       jne    .cc.L0.4B_7B.out ; .cc.a0.out
        ; --------------------------------------------------------------------------
        ;?4883C4 FF  ADD   RSP, FF         |
        ;?4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
   .cc.a0.spD:
        ; --------------------------------------------------------------------------
        ;?4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.a0.out
        cmp     [rdi + 1], word 0xC481
        jne    .cc.a0.out
        ; --------------------------------------------------------------------------
        mov     eax, dword [rdi + 3]
        mov     rdx, 7
        mov     [.esi], 7
        jmp    .cc.a0.spx
   .cc.a0.spB:
        ; --------------------------------------------------------------------------
        ;?4883C4 FF  ADD   RSP, FF         |
        ; --------------------------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.a0.out
        cmp     [rdi + 1], word 0xC483
        jne    .cc.a0.out
        ; --------------------------------------------------------------------------
        movsx   eax, byte [rdi + 3]
        mov     rdx, 4
        mov     [.esi], 4
;       jmp    .cc.a0.spx
   .cc.a0.spx:
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ; DD0424     FLD   QWORD [xSP]     |
        ; DD4424 08  FLD   QWORD [xSP + 8] |
        ;                                  |
        ;?DEC1       FADDP                 |
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;?4883C4 FF  ADD   RSP, FF         |
        ;?4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;?4883C4 FF  ADD   RSP, FF         |
        ;?4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
        cmp     [rdi + rdx + 00], word 0x1CDD
        jne    .cc.a0.out
        cmp     [rdi + rdx + 02], byte 0x24
        jne    .cc.a0.out
        ;
        cmp     [rdi + rdx + 02], dword 0xC4834824
        je     .cc.a0.spy.spB
        cmp     [rdi + rdx + 02], dword 0xC4814824
        je     .cc.a0.spy.spD
        ;
        cmp     [rdi + rdx + 03], dword 0xDD2404DD
        jne    .cc.a0.out
        cmp     [rdi + rdx + 07], dword 0xDE082444
        jne    .cc.a0.out
        cmp     [rdi + rdx + 12], byte 0x48
        jne    .cc.a0.out
        cmp     [rdi + rdx + 13], word 0xC483
        je     .cc.a0.spx.spB
        cmp     [rdi + rdx + 13], word 0xC481
        je     .cc.a0.spx.spD
        jmp    .cc.a0.out
   .cc.a0.spx.spD:
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ; DD0424     FLD   QWORD [xSP]     |
        ; DD4424 08  FLD   QWORD [xSP + 8] |
        ;                                  |
        ;?DEC1       FADDP                 |
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ; 4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
        mov     ecx, dword [rdi + rdx + 15]
        test    ecx, ecx
        js     .cc.a0.out
        ;
        add     ecx, eax
        test    ecx, ecx
        js     .cc.a0.out
        ;
        mov     [.xcx], rcx
        add     [.esi], 7
        jmp    .cc.a0.spx.spx
   .cc.a0.spx.spB:
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ; DD0424     FLD   QWORD [xSP]     |
        ; DD4424 08  FLD   QWORD [xSP + 8] |
        ;                                  |
        ;?DEC1       FADDP                 |
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ; 4883C4 FF  ADD   RSP, FF         |
        ; --------------------------------------------------------------------------
        movsx   ecx, byte [rdi + rdx + 15]
        test    ecx, ecx
        js     .cc.a0.out
        ;
        add     ecx, eax
        test    ecx, ecx
        js     .cc.a0.out
        ;
        mov     [.xcx], rcx
        add     [.esi], 4
;       jmp    .cc.a0.spx.spx
   .cc.a0.spx.spx:
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ; DD0424     FLD   QWORD [xSP]     |
        ; DD4424 08  FLD   QWORD [xSP + 8] |
        ;                                  |
        ;?DEC1       FADDP                 |
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        add     [.esi], 12
        add     eax, 8
        test    eax, eax
        js     .cc.a0.out
        ;
        cmp     eax, +127
        jg     .cc.a0.spx.fpD
        cmp     eax, -128
        jl     .cc.a0.spx.fpD
   .cc.a0.spx.fpB:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> (8|11) BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 |?4883C4 FF  ADD   RSP, FF
        ;?DEE9       FSUBP                 |?4881C4 FF+ ADD   RSP, FF+
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        mov     dl, [rdi + rdx + 11]
        case    dl,\
                0xC1, .cc.a0.spx.fpB.addp,\
                0xE9, .cc.a0.spx.fpB.subp,\
                0xE1, .cc.a0.spx.fpB.subrp,\
                0xC9, .cc.a0.spx.fpB.mulp,\
                0xF9, .cc.a0.spx.fpB.divp,\
                0xF1, .cc.a0.spx.fpB.divrp
        jmp    .cc.a0.out
        ; ---------------------------------------------------------
   .cc.a0.spx.fpB.addp:
        mov     dh, 0x44
        jmp    .cc.a0.spx.fpB.spx
   .cc.a0.spx.fpB.subp:
        mov     dh, 0x64
        jmp    .cc.a0.spx.fpB.spx
   .cc.a0.spx.fpB.subrp:
        mov     dh, 0x6C
        jmp    .cc.a0.spx.fpB.spx
   .cc.a0.spx.fpB.mulp:
        mov     dh, 0x4C
        jmp    .cc.a0.spx.fpB.spx
   .cc.a0.spx.fpB.divp:
        mov     dh, 0x74
        jmp    .cc.a0.spx.fpB.spx
   .cc.a0.spx.fpB.divrp:
        mov     dh, 0x7C
        jmp    .cc.a0.spx.fpB.spx
        ; ---------------------------------------------------------
   .cc.a0.spx.fpB.spx:
        mov     ecx, dword [.xcx]
        cmp     ecx, +127
        jg     .cc.a0.spx.fpB.spD
        cmp     ecx, -128
        jl     .cc.a0.spx.fpB.spD
        test    ecx, ecx
        jz     .cc.a0.spx.fpB.spZ
   .cc.a0.spx.fpB.spB:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> 8 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 | 4883C4 FF  ADD   RSP, FF
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x002400DC
        mov     [rdi + 1], dh
        mov     [rdi + 3], al
        mov     [rdi + 4], dword 0x00C48348
        mov     dl, byte [.xcx]
        mov     [rdi + 7], dl
;       mov     [.esi], ...
        mov     [.edi], 8
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpB.spD:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> 11 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 | 4881C4 FF+ ADD   RSP, FF+
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x002400DC
        mov     [rdi + 1], dh
        mov     [rdi + 3], al
        mov     [rdi + 4], dword 0x00C48148
        mov     edx, dword [.xcx]
        mov     [rdi + 7], edx
;       mov     [.esi], ...
        mov     [.edi], 11
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpB.spZ:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> 4 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 |
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x002400DC
        mov     [rdi + 1], dh
        mov     [rdi + 3], al
;       mov     [.esi], ...
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.a0.spx.fpD:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> (11|14) BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 |?4883C4 FF  ADD   RSP, FF
        ;?DEE9       FSUBP                 |?4881C4 FF+ ADD   RSP, FF+
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        mov     dl, [rdi + rdx + 11]
        case    dl,\
                0xC1, .cc.a0.spx.fpD.addp,\
                0xE9, .cc.a0.spx.fpD.subp,\
                0xE1, .cc.a0.spx.fpD.subrp,\
                0xC9, .cc.a0.spx.fpD.mulp,\
                0xF9, .cc.a0.spx.fpD.divp,\
                0xF1, .cc.a0.spx.fpD.divrp
        jmp    .cc.a0.out
        ; ---------------------------------------------------------
   .cc.a0.spx.fpD.addp:
        mov     dh, 0x84
        jmp    .cc.a0.spx.fpD.spx
   .cc.a0.spx.fpD.subp:
        mov     dh, 0xA4
        jmp    .cc.a0.spx.fpD.spx
   .cc.a0.spx.fpD.subrp:
        mov     dh, 0xAC
        jmp    .cc.a0.spx.fpD.spx
   .cc.a0.spx.fpD.mulp:
        mov     dh, 0x8C
        jmp    .cc.a0.spx.fpD.spx
   .cc.a0.spx.fpD.divp:
        mov     dh, 0xB4
        jmp    .cc.a0.spx.fpD.spx
   .cc.a0.spx.fpD.divrp:
        mov     dh, 0xBC
        jmp    .cc.a0.spx.fpD.spx
        ; ---------------------------------------------------------
   .cc.a0.spx.fpD.spx:
        mov     ecx, dword [.xcx]
        cmp     ecx, +127
        jg     .cc.a0.spx.fpD.spD
        cmp     ecx, -128
        jl     .cc.a0.spx.fpD.spD
        test    ecx, ecx
        jz     .cc.a0.spx.fpD.spZ
   .cc.a0.spx.fpD.spB:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> 11 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 | 4883C4 FF  ADD   RSP, FF
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x002400DC
        mov     [rdi + 01], dh
        mov     [rdi + 03], eax
        mov     [rdi + 07], dword 0x00C48348
        mov     dl, byte [.xcx]
        mov     [rdi + 10], dl
;       mov     [.esi], ...
        mov     [.edi], 11
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpD.spD:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> 14 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 | 4881C4 FF+ ADD   RSP, FF+
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x002400DC
        mov     [rdi + 01], dh
        mov     [rdi + 03], eax
        mov     [rdi + 07], dword 0x00C48148
        mov     edx, dword [.xcx]
        mov     [rdi + 10], edx
;       mov     [.esi], ...
        mov     [.edi], 14
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpD.spZ:
        ; --------------------------------------------------------------------------
        ; (4|7) + 12 + (4|7) BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>4881C4 FF+ ADD   RSP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 |
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x002400DC
        mov     [rdi + 01], dh
        mov     [rdi + 03], eax
;       mov     [.esi], ...
        mov     [.edi], 7
        jmp    .cc.momem
        ;
   .cc.a0.spy.spD:
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ; 4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
        mov     ecx, dword [rdi + rdx + 6]
        add     ecx, eax
        mov     [.xcx], rcx
        add     [.esi], 7
        jmp    .cc.a0.spy.spy
   .cc.a0.spy.spB:
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | RDX = 4
        ;>4881C4 FF+ ADD   RSP, FF+        | RDX = 7
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ; 4883C4 FF  ADD   RSP, FF         |
        ; --------------------------------------------------------------------------
        movsx   ecx, byte [rdi + rdx + 6]
        add     ecx, eax
        mov     [.xcx], rcx
        add     [.esi], 4
;       jmp    .cc.a0.spy.spy
   .cc.a0.spy.spy:
        add     [.esi], 3
        ;
        cmp     eax, +127
        jg     .cc.a0.spy.fpD
        cmp     eax, -128
        jl     .cc.a0.spy.fpD
   .cc.a0.spy.fpB:
        mov     edx, dword [.xcx]
        cmp     edx, +127
        jg     .cc.a0.spy.fpB.spD
        cmp     edx, -128
        jl     .cc.a0.spy.fpB.spD
        test    edx, edx
        jz     .cc.a0.spy.fpB.spZ
   .cc.a0.spy.fpB.spB:
        ; --------------------------------------------------------------------------
        ; (4) + 3 + (4|7) BYTES -> 8 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | DD5C24 FF  FSTP  QWORD [xSP + FF]
        ;                                  | 4883C4 FF  ADD   RSP, FF
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 8
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00245CDD
        mov     [rdi + 3], al
        mov     [rdi + 4], dword 0x00C48348
        mov     [rdi + 7], dl
;       mov     [.esi], ...
        mov     [.edi], 8
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpB.spD:
        ; --------------------------------------------------------------------------
        ; (4) + 3 + (4|7) BYTES -> 11 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | DD5C24 FF  FSTP  QWORD [xSP + FF]
        ;                                  | 4881C4 FF+ ADD   RSP, FF+
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 11
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00245CDD
        mov     [rdi + 3], al
        mov     [rdi + 4], dword 0x00C48148
        mov     [rdi + 7], edx
;       mov     [.esi], ...
        mov     [.edi], 11
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpB.spZ:
        ; --------------------------------------------------------------------------
        ; (4) + 3 + (4|7) BYTES -> 4 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 FF  ADD   RSP, FF         | DD5C24 FF  FSTP  QWORD [xSP + FF]
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 4
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00245CDD
        mov     [rdi + 3], al
;       mov     [.esi], ...
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.a0.spy.fpD:
        mov     edx, dword [.xcx]
        cmp     edx, +127
        jg     .cc.a0.spy.fpD.spD
        cmp     edx, -128
        jl     .cc.a0.spy.fpD.spD
        test    edx, edx
        jz     .cc.a0.spy.fpD.spZ
   .cc.a0.spy.fpD.spB:
        ; --------------------------------------------------------------------------
        ; (7) + 3 + (4|7) BYTES -> 11 BYTES
        ; --------------------------------------------------------------------------
        ;>4881C4 FF+ ADD   RSP, FF+        | DD9C24 FF+ FSTP  QWORD [xSP + FF+]
        ;                                  | 4883C4 FF  ADD   RSP, FF
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 11
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x00249CDD
        mov     [rdi + 03], eax
        mov     [rdi + 07], dword 0x00C48348
        mov     [rdi + 10], dl
;       mov     [.esi], ...
        mov     [.edi], 11
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpD.spD:
        ; --------------------------------------------------------------------------
        ; (7) + 3 + (4|7) BYTES -> 14 BYTES
        ; --------------------------------------------------------------------------
        ;>4881C4 FF+ ADD   RSP, FF+        | DD9C24 FF+ FSTP  QWORD [xSP + FF+]
        ;                                  | 4881C4 FF+ ADD   RSP, FF+
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 14
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x00249CDD
        mov     [rdi + 03], eax
        mov     [rdi + 07], dword 0x00C48148
        mov     [rdi + 10], edx
;       mov     [.esi], ...
        mov     [.edi], 14
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpD.spZ:
        ; --------------------------------------------------------------------------
        ; (7) + 3 + (4|7) BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;>4881C4 FF+ ADD   RSP, FF+        | DD9C24 FF+ FSTP  QWORD [xSP + FF+]
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+4883C4 FF  ADD   RSP, FF         |
        ;+4881C4 FF+ ADD   RSP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 7
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x00249CDD
        mov     [rdi + 03], eax
;       mov     [.esi], ...
        mov     [.edi], 7
        jmp    .cc.momem
   .cc.a0.out:
  }
   .cc.a0..in:
        SIC_OP.cc.L0.4B_7B.a0
   .cc.a0..out:
  $end

  macro SIC_OP.cc.L0.4B_7B.add_rsp.mov_c
  {
   .cc.add_rsp.mov_c.in:
        cmp     ebx, 4
        je     .cc.add_rsp.mov_c.bx
;       cmp     ebx, 7
;       jne    .cc.L0.4B_7B.out ; .cc.add_rsp.mov_c.out
   .cc.add_rsp.mov_c.dx:
        ; --------------------------------------------------------------------------
        ; 17 BYTES -> 17 BYTES
        ; --------------------------------------------------------------------------
        ;>4881C4 AA+   ADD  RSP, AA+        | 7 BYTES
        ;                                   |
        ;?48B8 QWORD   MOV  RAX, QWORD      | 10 BYTES
        ;?48B9 QWORD   MOV  RCX, QWORD      |
        ;?48BA QWORD   MOV  RDX, QWORD      |
        ;?49B8 QWORD   MOV  R8,  QWORD      |
        ;?49B9 QWORD   MOV  R9,  QWORD      |
        ;?49BA QWORD   MOV  R10, QWORD      |
        ;?49BB QWORD   MOV  R11, QWORD      |
        ;?49BC QWORD   MOV  R12, QWORD      |
        ;?49BD QWORD   MOV  R13, QWORD      |
        ;?49BE QWORD   MOV  R14, QWORD      |
        ;?49BF QWORD   MOV  R15, QWORD      |
        ; --------------------------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.add_rsp.mov_c.out
        cmp     [rdi + 1], word 0xC481
        jne    .cc.add_rsp.mov_c.out
        mov     ax, [rdi + 7]
        case    ax,\
                0xB848 , .cc.add_rsp.mov_c.dx.reg,\
                0xB948 , .cc.add_rsp.mov_c.dx.reg,\
                0xBA48 , .cc.add_rsp.mov_c.dx.reg,\
                0xB849 , .cc.add_rsp.mov_c.dx.reg,\
                0xB949 , .cc.add_rsp.mov_c.dx.reg,\
                0xBA49 , .cc.add_rsp.mov_c.dx.reg,\
                0xBB49 , .cc.add_rsp.mov_c.dx.reg,\
                0xBC49 , .cc.add_rsp.mov_c.dx.reg,\
                0xBD49 , .cc.add_rsp.mov_c.dx.reg,\
                0xBE49 , .cc.add_rsp.mov_c.dx.reg,\
                0xBF49 , .cc.add_rsp.mov_c.dx.reg
        jmp    .cc.add_rsp.mov_c.out
   .cc.add_rsp.mov_c.dx.reg:
        mov     rdx, [rdi + 9]
        mov     ecx, [rdi + 3]
        ; --------------------------------------------------------------------------
        ;>4*** QWORD   MOV  R**, QWORD      |
        ; 4881C4 AA+   ADD  RSP, AA+        |
        ; --------------------------------------------------------------------------
        mov     [rdi + 00], ax
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x00C48148
        mov     [rdi + 13], ecx
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.next
        ;
   .cc.add_rsp.mov_c.bx:
        ; --------------------------------------------------------------------------
        ; 14 BYTES -> 14 BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 AA    ADD  RSP, AA         | 4 BYTES
        ;                                   |
        ;?48B8 QWORD   MOV  RAX, QWORD      | 10 BYTES
        ;?48B9 QWORD   MOV  RCX, QWORD      |
        ;?48BA QWORD   MOV  RDX, QWORD      |
        ;?49B8 QWORD   MOV  R8,  QWORD      |
        ;?49B9 QWORD   MOV  R9,  QWORD      |
        ;?49BA QWORD   MOV  R10, QWORD      |
        ;?49BB QWORD   MOV  R11, QWORD      |
        ;?49BC QWORD   MOV  R12, QWORD      |
        ;?49BD QWORD   MOV  R13, QWORD      |
        ;?49BE QWORD   MOV  R14, QWORD      |
        ;?49BF QWORD   MOV  R15, QWORD      |
        ; --------------------------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.add_rsp.mov_c.out
        cmp     [rdi + 1], word 0xC483
        jne    .cc.add_rsp.mov_c.out
        mov     ax, [rdi + 4]
        case    ax,\
                0xB848 , .cc.add_rsp.mov_c.bx.reg,\
                0xB948 , .cc.add_rsp.mov_c.bx.reg,\
                0xBA48 , .cc.add_rsp.mov_c.bx.reg,\
                0xB849 , .cc.add_rsp.mov_c.bx.reg,\
                0xB949 , .cc.add_rsp.mov_c.bx.reg,\
                0xBA49 , .cc.add_rsp.mov_c.bx.reg,\
                0xBB49 , .cc.add_rsp.mov_c.bx.reg,\
                0xBC49 , .cc.add_rsp.mov_c.bx.reg,\
                0xBD49 , .cc.add_rsp.mov_c.bx.reg,\
                0xBE49 , .cc.add_rsp.mov_c.bx.reg,\
                0xBF49 , .cc.add_rsp.mov_c.bx.reg
        jmp    .cc.add_rsp.mov_c.out
   .cc.add_rsp.mov_c.bx.reg:
        mov     rdx, [rdi + 6]
        mov     cl, [rdi + 3]
        ; --------------------------------------------------------------------------
        ;>4*** QWORD   MOV  R**, QWORD      |
        ; 4883C4 AA    ADD  RSP, AA         |
        ; --------------------------------------------------------------------------
        mov     [rdi + 00], ax
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x00C48348
        mov     [rdi + 13], cl
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.next
   .cc.add_rsp.mov_c.out:
  }
   .cc.add_rsp.mov_c..in:
        SIC_OP.cc.L0.4B_7B.add_rsp.mov_c
   .cc.add_rsp.mov_c..out:

  macro SIC_OP.cc.L0.4B_7B.add_rsp
  {
   .cc.add_rsp.in:
        cmp     ebx, 4
        je     .cc.add_rsp.bx
;       cmp     ebx, 7
;       jne    .cc.L0.4B_7B.out ; .cc.add_rsp.out
   .cc.add_rsp.dx:
        ; --------------------------------------------------------------------------
        ;>4881C4 AA+   ADD  RSP, AA+        |
        ;?4883C4 BB    ADD  RSP, BB         |
        ;?4881C4 BB+   ADD  RSP, BB+        |
        ; --------------------------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.add_rsp.out
        cmp     [rdi + 1], word 0xC481
        jne    .cc.add_rsp.out
        cmp     [rdi + 7], byte 0x48
        jne    .cc.add_rsp.out
        cmp     [rdi + 8], word 0xC483
        je     .cc.add_rsp.db
        cmp     [rdi + 8], word 0xC481
        je     .cc.add_rsp.dd
        jmp    .cc.add_rsp.out
        ;
   .cc.add_rsp.bx:
        ; --------------------------------------------------------------------------
        ;>4883C4 AA    ADD  RSP, AA         |
        ;?4883C4 BB    ADD  RSP, BB         |
        ;?4881C4 BB+   ADD  RSP, BB+        |
        ; --------------------------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.add_rsp.out
        cmp     [rdi + 1], word 0xC483
        jne    .cc.add_rsp.out
        cmp     [rdi + 4], byte 0x48
        jne    .cc.add_rsp.out
        cmp     [rdi + 5], word 0xC483
        je     .cc.add_rsp.bb
        cmp     [rdi + 5], word 0xC481
        je     .cc.add_rsp.bd
        jmp    .cc.add_rsp.out
        ;
   .cc.add_rsp.dd:
        ; --------------------------------------------------------------------------
        ; 14 BYTES -> 4(7) BYTES
        ; --------------------------------------------------------------------------
        ;>4881C4 AA+   ADD  RSP, AA+        |
        ; 4881C4 BB+   ADD  RSP, BB+        |
        ; --------------------------------------------------------------------------
        mov     [.esi], 14
        mov     eax, dword [rdi + 03]
        mov     edx, dword [rdi + 10]
        add     eax, edx
        jmp    .cc.add_rsp.x
   .cc.add_rsp.db:
        ; --------------------------------------------------------------------------
        ; 11 BYTES -> 4(7) BYTES
        ; --------------------------------------------------------------------------
        ;>4881C4 AA+   ADD  RSP, AA+        |
        ; 4883C4 BB    ADD  RSP, BB         |
        ; --------------------------------------------------------------------------
        mov     [.esi], 11
        mov     eax, dword [rdi + 03]
        movsx   edx, byte [rdi + 10]
        add     eax, edx
        jmp    .cc.add_rsp.x
   .cc.add_rsp.bd:
        ; --------------------------------------------------------------------------
        ; 11 BYTES -> 4(7) BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 AA    ADD  RSP, AA         |
        ; 4881C4 BB+   ADD  RSP, BB+        |
        ; --------------------------------------------------------------------------
        mov     [.esi], 11
        movsx   eax, byte [rdi + 3]
        mov     edx, dword [rdi + 7]
        add     eax, edx
        jmp    .cc.add_rsp.x
   .cc.add_rsp.bb:
        ; --------------------------------------------------------------------------
        ; 8 BYTES -> 4(7) BYTES
        ; --------------------------------------------------------------------------
        ;>4883C4 AA    ADD  RSP, AA         |
        ; 4883C4 BB    ADD  RSP, BB         |
        ; --------------------------------------------------------------------------
        mov     [.esi], 8
        movsx   eax, byte [rdi + 3]
        movsx   edx, byte [rdi + 7]
        add     eax, edx
;       jmp    .cc.add_rsp.x
   .cc.add_rsp.x:
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.add_rsp.out
        ; ---------------------------------------------------------
        cmp     eax, +127
        jg     .cc.add_rsp.xd
        cmp     eax, -127
        jl     .cc.add_rsp.xd
        test    eax, eax
        jz     .cc.add_rsp.xz
   .cc.add_rsp.xb:
        ; --------------------------------------------------------------------------
        ; 14|11|8 BYTES -> 4 BYTES
        ; --------------------------------------------------------------------------
        ; 4883C4 AA    ADD  RSP, AA         |
        ; --------------------------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], al
;       mov     [.esi], ...
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.move.memory
   .cc.add_rsp.xd:
        ; --------------------------------------------------------------------------
        ; 14|11|8 BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ; 4881C4 AA+   ADD  RSP, AA+        |
        ; --------------------------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48148
        mov     [rdi + 3], eax
;       mov     [.esi], ...
        mov     [.edi], 7
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.move.memory
   .cc.add_rsp.xz:
        ; --------------------------------------------------------------------------
        ; 14|11|8 BYTES -> 0 BYTES
        ; --------------------------------------------------------------------------
;       mov     [.esi], ...
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.move.memory
   .cc.add_rsp.out:
  }
   .cc.add_rsp..in:
        SIC_OP.cc.L0.4B_7B.add_rsp
   .cc.add_rsp..out:

   .cc.L0.4B_7B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 1
        jne    .cc.L0.1B.out
   .cc.L0.1B:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.1B.push.fild.fstp_st0 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.push.fild.fstp_st0.in:
;       cmp     ebx, 1
;       jne    .cc.push.fild.fstp_st0.out
        ; ---------------------------------------------------------
        ;>  50       PUSH RAX         |
        ;   DF2C 24  FILD QWORD [RSP] |
        ; ---------------------------------------------------------
        ;?4883C4 FF  ADD  RSP, FF     |
        ;?4881C4 FF+ ADD  RSP, FF+    |
        ; ---------------------------------------------------------
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0x242CDF50
        jne    .cc.push.fild.fstp_st0.out
        cmp     [rdi + 3], dword 0xC4834824
        je     .cc.push.fild.spB.fstp_st0
        cmp     [rdi + 3], dword 0xC4814824
        je     .cc.push.fild.spD.fstp_st0
        cmp     [rdi + 4], word 0xD8DD
        je     .cc.push.fild.spN.fstp_st0
        jmp    .cc.push.fild.fstp_st0.out
        ;
   .cc.push.fild.spN.fstp_st0:
        ; ---------------------------------------------------------
        ; 6 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH RAX         | 50       PUSH RAX
        ;   DF2C 24  FILD QWORD [RSP] |
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.push.fild.fstp_st0.out
    else
        jl     .cc.push.fild.fstp_st0.out
    end if
        ; ---------------------------------------------------------
;       mov     [.esi], 6
        mov     [.edi], 1
        jmp    .cc.momem
        ;
   .cc.push.fild.spB.fstp_st0:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 7|4|0 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH RAX         |?4883C4 FF  ADD  RSP, FF-8
        ;   DF2C 24  FILD QWORD [RSP] |?4881C4 FF+ ADD  RSP, FF-8
        ; 4883C4 FF  ADD  RSP, FF     |?
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [rdi + 8], word 0xD8DD
        jne    .cc.push.fild.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.push.fild.fstp_st0.out
    else
        jl     .cc.push.fild.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        movsx   eax, byte [rdi + 7]
        sub     eax, 8
        jl     .cc.push.fild.spB.fstp_st0.spN
        test    eax, eax
        jz     .cc.push.fild.spB.fstp_st0.spZ
        cmp     eax, +127
        jg     .cc.push.fild.spB.fstp_st0.spD
;       cmp     eax, -128
;       jl     .cc.push.fild.spB.fstp_st0.spD
   .cc.push.fild.spB.fstp_st0.spB:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       | 4883C4 FF  ADD  RSP, FF-8
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], al
;       mov     [.esi], 10
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spB.fstp_st0.spD:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       | 4881C4 FF+ ADD  RSP, FF-8
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48148
        mov     [rdi + 3], eax
;       mov     [.esi], 10
        mov     [.edi], 7
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spB.fstp_st0.spZ:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |
        ; ---------------------------------------------------------
;       mov     [.esi], 10
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spB.fstp_st0.spN:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH RAX         | 50         PUSH RAX
        ;   ...                       | 4883C4 FF  ADD  RSP, FF
        ; ---------------------------------------------------------
        add     eax, 8
        mov     [rdi + 1], dword 0x00C48348
        mov     [rdi + 4], al
;       mov     [.esi], 10
        mov     [.edi], 5
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
        ;
   .cc.push.fild.spD.fstp_st0:
        ; ---------------------------------------------------------
        ; 13 BYTES -> 7|6|0 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH RAX         |?4883C4 FF  ADD  RSP, FF-8
        ;   DF2C 24  FILD QWORD [RSP] |?4881C4 FF+ ADD  RSP, FF-8
        ; 4881C4 FF+ ADD  RSP, FF+    |?
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [rdi + 11], word 0xD8DD
        jne    .cc.push.fild.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 13
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.push.fild.fstp_st0.out
    else
        jl     .cc.push.fild.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        mov     eax, [rdi + 7]
        sub     eax, 8
        jl     .cc.push.fild.spD.fstp_st0.spN
        test    eax, eax
        jz     .cc.push.fild.spD.fstp_st0.spZ
        cmp     eax, +127
        jg     .cc.push.fild.spD.fstp_st0.spD
;       cmp     eax, -128
;       jl     .cc.push.fild.spD.fstp_st0.spD
   .cc.push.fild.spD.fstp_st0.spB:
        ; ---------------------------------------------------------
        ; 13 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       | 4883C4 FF  ADD  RSP, FF-8
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], al
;       mov     [.esi], 13
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spD.fstp_st0.spD:
        ; ---------------------------------------------------------
        ; 13 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       | 4881C4 FF+ ADD  RSP, FF-8
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48148
        mov     [rdi + 3], eax
;       mov     [.esi], 13
        mov     [.edi], 7
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spD.fstp_st0.spZ:
        ; ---------------------------------------------------------
        ; 13 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |
        ; ---------------------------------------------------------
;       mov     [.esi], 13
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spD.fstp_st0.spN:
        ; ---------------------------------------------------------
        ; 13 BYTES -> 8 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH RAX         | 50         PUSH RAX
        ;   ...                       | 4881C4 FF+ ADD  RSP, FF
        ; ---------------------------------------------------------
        add     eax, 8
        mov     [rdi + 1], dword 0x00C48148
        mov     [rdi + 4], eax
;       mov     [.esi], 13
        mov     [.edi], 8
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.fstp_st0.out:
  }
;  .cc.push.fild.fstp_st0..in:
;       SIC_OP.cc.L0.1B.push.fild.fstp_st0 .static.FSTP.ST0
;  .cc.push.fild.fstp_st0..out:
  $end

  macro SIC_OP.cc.L0.1B.rax_rsp_rcx
  {
   .cc.rax_rsp_rcx.in:
;       cmp     ebx, 1
;       jne    .cc.rax_rsp_rcx.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;> 50        PUSH RAX
        ;  488B0C24  MOV  RCX, QWORD [RSP]
        ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ;> 50        PUSH RAX
        ;  4889C1    MOV  RCX, RAX
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rax_rsp_rcx.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0x50
        jne    .cc.rax_rsp_rcx.out
        cmp     [rdi + 1], dword 0x240C8B48
        jne    .cc.rax_rsp_rcx.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0xC1894850
;       mov     [.esi], 5
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.rax_rsp_rcx.out:
  }
   .cc.rax_rsp_rcx..in:
        SIC_OP.cc.L0.1B.rax_rsp_rcx
   .cc.rax_rsp_rcx..out:

  macro SIC_OP.cc.L0.1B.rcx_rsp_xmm0
  {
   .cc.rcx_rsp_xmm0.in:
;       cmp     ebx, 1
;       jne    .cc.rcx_rsp_xmm0.out
        ; ---------------------------------------------------------
        ; 6 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;> 51          PUSH  RCX
        ;  F20F100424  MOVSD XMM0, QWORD [RSP]
        ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ;> 51          PUSH  RCX
        ;  66480F6EC1  MOVQ  XMM0, RCX
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rcx_rsp_xmm0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0x100FF251
        jne    .cc.rcx_rsp_xmm0.out
        cmp     [rdi + 4], word 0x2404
        jne    .cc.rcx_rsp_xmm0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x0F486651
        mov     [rdi + 4], word 0xC16E
;       mov     [.esi], 6
        mov     [.edi], 6
        jmp    .cc.momem
   .cc.rcx_rsp_xmm0.out:
  }
   .cc.rcx_rsp_xmm0..in:
        SIC_OP.cc.L0.1B.rcx_rsp_xmm0
   .cc.rcx_rsp_xmm0..out:

  macro SIC_OP.cc.L0.1B.rax_rsp_rax
  {
   .cc.rax_rsp_rax.in:
;       cmp     ebx, 1
;       jne    .cc.rax_rsp_rax.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> 50          PUSH  RAX
        ;  488B0424    MOV   RAX, QWORD [RSP]
        ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ;> 50          PUSH  RAX
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rax_rsp_rax.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0x50
        jne    .cc.rax_rsp_rax.out
        cmp     [rdi + 1], dword 0x24048B48
        jne    .cc.rax_rsp_rax.out
        ; ---------------------------------------------------------
;       mov     [.esi], 5
        mov     [.edi], 1
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.rax_rsp_rax.out:
  }
   .cc.rax_rsp_rax..in:
        SIC_OP.cc.L0.1B.rax_rsp_rax
   .cc.rax_rsp_rax..out:

   .cc.L0.1B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 2
        jne    .cc.L0.2B.out
   .cc.L0.2B:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fld.fstp_st0 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fld.fstp_st0.in:
;       cmp     ebx, 2
;       jne    .cc.fld.fstp_st0.out
        ; ---------------------------------------------------------
        ;>? DD00     FLD  QWORD [RAX] |
        ; ? DD01     FLD  QWORD [RCX] |
        ; ? DD02     FLD  QWORD [RDX] |
        ; ---------------------------------------------------------
        ; ? DF28     FILD QWORD [RAX] |
        ; ? DF29     FILD QWORD [RCX] |
        ; ? DF2A     FILD QWORD [RDX] |
        ; ---------------------------------------------------------
        ; ? DB00     FILD DWORD [RAX] |
        ; ? DB01     FILD DWORD [RCX] |
        ; ? DB02     FILD DWORD [RDX] |
        ; ---------------------------------------------------------
        ; ? D9E8     FLD1             |
        ; ? D9E9     FLDL2T           |
        ; ? D9EA     FLDL2E           |
        ; ? D9EB     FLDPI            |
        ; ? D9EC     FLDLG2           |
        ; ? D9ED     FLDLN2           |
        ; ? D9EE     FLDZ             |
        ; ---------------------------------------------------------
        ;?4883C4 FF  ADD  RSP, FF     |
        ;?4881C4 FF+ ADD  RSP, FF+    |
        ; ---------------------------------------------------------
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     ax, [rdi + 0]
        case    ax,\
                0x00DD, .cc.fld.fstp_st0.match,\
                0x01DD, .cc.fld.fstp_st0.match,\
                0x02DD, .cc.fld.fstp_st0.match,\
                0x28DF, .cc.fld.fstp_st0.match,\
                0x29DF, .cc.fld.fstp_st0.match,\
                0x2ADF, .cc.fld.fstp_st0.match,\
                0x00DB, .cc.fld.fstp_st0.match,\
                0x01DB, .cc.fld.fstp_st0.match,\
                0x02DB, .cc.fld.fstp_st0.match,\
                0xE8D9, .cc.fld.fstp_st0.match,\
                0xE9D9, .cc.fld.fstp_st0.match,\
                0xEAD9, .cc.fld.fstp_st0.match,\
                0xEBD9, .cc.fld.fstp_st0.match,\
                0xECD9, .cc.fld.fstp_st0.match,\
                0xEDD9, .cc.fld.fstp_st0.match,\
                0xEED9, .cc.fld.fstp_st0.match
        jmp    .cc.fld.fstp_st0.out
   .cc.fld.fstp_st0.match:
        cmp     [rdi + 3], word 0xC483
        je     .cc.fld.spB.fstp_st0
        cmp     [rdi + 3], word 0xC481
        je     .cc.fld.spD.fstp_st0
        cmp     [rdi + 2], word 0xD8DD
        je     .cc.fld.spN.fstp_st0
        jmp    .cc.fld.fstp_st0.out
   .cc.fld.spN.fstp_st0:
        ; ---------------------------------------------------------
        ; 4 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  D***     FLD*             |
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fld.fstp_st0.out
    else
        jl     .cc.fld.fstp_st0.out
    end if
        ; ---------------------------------------------------------
;       mov     [.esi], 4
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.fld.spB.fstp_st0:
        ; ---------------------------------------------------------
        ; 8 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  D***     FLD*             | 4883C4 FF  ADD  RSP, FF
        ; 4883C4 FF  ADD  RSP, FF     |
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [rdi + 2], byte 0x48
        jne    .cc.fld.fstp_st0.out
        cmp     [rdi + 6], word 0xD8DD
        jne    .cc.fld.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fld.fstp_st0.out
    else
        jl     .cc.fld.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        mov     al, [rdi + 5]
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], al
;       mov     [.esi], 8
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.fld.spD.fstp_st0:
        ; ---------------------------------------------------------
        ; 11 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;>  D***     FLD*             | 4881C4 FF+ ADD  RSP, FF+
        ; 4881C4 FF+ ADD  RSP, FF+    |
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [rdi + 2], byte 0x48
        jne    .cc.fld.fstp_st0.out
        cmp     [rdi + 9], word 0xD8DD
        jne    .cc.fld.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fld.fstp_st0.out
    else
        jl     .cc.fld.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        mov     eax, [rdi + 5]
        mov     [rdi + 0], dword 0x00C48148
        mov     [rdi + 3], eax
;       mov     [.esi], 11
        mov     [.edi], 7
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.fld.fstp_st0.out:
  }
   .cc.fld.fstp_st0..in:
        SIC_OP.cc.L0.2B.fld.fstp_st0 .static.FSTP.ST0
   .cc.fld.fstp_st0..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fst_rax static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_rax.in:
;       cmp     ebx, 2
;       jne    .cc.fst_rax.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  DD10     FST  QWORD [RAX] |   DD18     FSTP QWORD [RAX]
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_rax.out
    else
        jl     .cc.fst_rax.out
    end if
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xD8DD10DD
        jne    .cc.fst_rax.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0x18DD
;       mov     [.esi], 4
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.fst_rax.out:
  }
   .cc.fst_rax..in:
        SIC_OP.cc.L0.2B.fst_rax .static.FSTP.ST0
   .cc.fst_rax..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fst_rcx static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_rcx.in:
;       cmp     ebx, 2
;       jne    .cc.fst_rcx.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  DD11     FST  QWORD [RCX] |   DD19     FSTP QWORD [RCX]
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_rcx.out
    else
        jl     .cc.fst_rcx.out
    end if
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xD8DD11DD
        jne    .cc.fst_rcx.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0x19DD
;       mov     [.esi], 4
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.fst_rcx.out:
  }
   .cc.fst_rcx..in:
        SIC_OP.cc.L0.2B.fst_rcx .static.FSTP.ST0
   .cc.fst_rcx..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fst_rdx static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_rdx.in:
;       cmp     ebx, 2
;       jne    .cc.fst_rdx.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  DD12     FST  QWORD [RDX] |   DD1A     FSTP QWORD [RDX]
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_rdx.out
    else
        jl     .cc.fst_rdx.out
    end if
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xD8DD12DD
        jne    .cc.fst_rdx.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0x1ADD
;       mov     [.esi], 4
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.fst_rdx.out:
  }
   .cc.fst_rdx..in:
        SIC_OP.cc.L0.2B.fst_rdx .static.FSTP.ST0
   .cc.fst_rdx..out:
  $end

   .cc.L0.2B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 3
        jne    .cc.L0.3B.out
   .cc.L0.3B:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.fxch.01
  {
   .cc.fxch.01.in:
;       cmp     ebx, 3
;       jne    .cc.fxch.01.out
        ; --------------------------------------------------------------------------
        ; 9 BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;> DD0424     FLD QWORD [xSP]      | DD4424 AA  FLD QWORD [xSP + AA]
        ;  DD4424 AA  FLD QWORD [xSP + AA] | DD0424     FLD QWORD [xSP]
        ;  D9C9       FXCH                 |
        ; --------------------------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fxch.01.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xDD2404DD
        jne    .cc.fxch.01.out
        cmp     [rdi + 4], word 0x2444
        jne    .cc.fxch.01.out
        cmp     [rdi + 7], word 0xC9D9
        jne    .cc.fxch.01.out
        ; ---------------------------------------------------------
        mov     eax, dword [rdi + 3]
        ; ---------------------------------------------------------
        mov     [rdi + 0], eax
        mov     [rdi + 4], dword 0x002404DD
;       mov     [.esi], 9
        mov     [.edi], 7
        jmp    .cc.momem
   .cc.fxch.01.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.01..in:
        SIC_OP.cc.L0.3B.fxch.01
   .cc.fxch.01..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.fxch.07
  {
   .cc.fxch.07.in:
;       cmp     ebx, 3
;       jne    .cc.fxch.07.out
        ; --------------------------------------------------------------------------
        ; 7 BYTES -> 5 BYTES
        ; --------------------------------------------------------------------------
        ;> DD0424  FLD QWORD [xSP] |? D9E8    FLD1
        ;? D9E8    FLD1            |? D9E9    FLDL2T
        ;? D9E9    FLDL2T          |? D9EA    FLDL2E
        ;? D9EA    FLDL2E          |? D9EB    FLDPI
        ;? D9EB    FLDPI           |? D9EC    FLDLG2
        ;? D9EC    FLDLG2          |? D9ED    FLDLN2
        ;? D9ED    FLDLN2          |? D9EE    FLDZ
        ;? D9EE    FLDZ            |  DD0424  FLD QWORD [xSP]
        ;  D9C9    FXCH            |
        ; --------------------------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fxch.07.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xD92404DD
        jne    .cc.fxch.07.out
        mov     dx, word [rdi + 3]
        case    dx,\
                0xE8D9, .cc.fxch.07.match,\
                0xE9D9, .cc.fxch.07.match,\
                0xEAD9, .cc.fxch.07.match,\
                0xEBD9, .cc.fxch.07.match,\
                0xECD9, .cc.fxch.07.match,\
                0xEDD9, .cc.fxch.07.match,\
                0xEED9, .cc.fxch.07.match
        jmp    .cc.fxch.07.out
   .cc.fxch.07.match:
        cmp     [rdi + 7], word 0xC9D9
        jne    .cc.fxch.07.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dx
        mov     [rdi + 2], dword 0x002404DD
;       mov     [.esi], 7
        mov     [.edi], 5
        jmp    .cc.momem
   .cc.fxch.07.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.07..in:
        SIC_OP.cc.L0.3B.fxch.07
   .cc.fxch.07..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.d
  {
   .cc.d.in:
;       cmp     ebx, 3
;       jne    .cc.d.out
        ; --------------------------------------------------------------------------
        ; 11 BYTES -> 5 BYTES
        ; --------------------------------------------------------------------------
        ;>DD1C24     FSTP QWORD [xSP]     | D***       F***
        ; DD0424     FLD  QWORD [xSP]     | DD1C24     FSTP QWORD [xSP]
        ;?D8**       F***                 |
        ;?D9**       F***                 |
        ;?DA**       F***                 |
        ;?DB**       F***                 |
        ;?DC**       F***                 |
        ;?DD**       F***                 |
        ;?DE**       F***                 |
        ;?DF**       F***                 |
        ; DD1C24     FSTP QWORD [xSP]     |
        ; --------------------------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.d.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0xDD241CDD
        jne    .cc.d.out
        cmp     [rdi + 04], word 0x2404
        jne    .cc.d.out
        ; ---------------------------------------------------------
        push    rdi
        add     rdi, 6
        call    SIC_IDA.ida                     ; rax = current instruction size
        pop     rdi
        ;
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        cmp     eax, 2
        jne    .cc.d.out
        ; ---------------------------------------------------------
        cmp     [rdi + 08], word 0x1CDD
        jne    .cc.d.out
        cmp     [rdi + 10], byte 0x24
        jne    .cc.d.out
        ; ---------------------------------------------------------
        mov     dx, [rdi + 06]
        cmp     dl, 0xD8
        jb     .cc.d.out
        cmp     dl, 0xDF
        ja     .cc.d.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dx
        mov     [rdi + 2], dword 0x00241CDD
;       mov     [.esi], 11
        mov     [.edi], 5
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.d.out:
  }
   .cc.d..in:
        SIC_OP.cc.L0.3B.d
   .cc.d..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.e
  {
   .cc.e.in:
;       cmp     ebx, 3
;       jne    .cc.e.out
        ; --------------------------------------------------------------------------
        ; 12 BYTES -> 6 BYTES
        ; --------------------------------------------------------------------------
        ;>DD1C24     FSTP QWORD [xSP]     | D***       F***
        ; DD0424     FLD  QWORD [xSP]     | 4883C4 FF  ADD  RSP, FF
        ;?D8**       F***                 |
        ;?D9**       F***                 |
        ;?DA**       F***                 |
        ;?DB**       F***                 |
        ;?DC**       F***                 |
        ;?DD**       F***                 |
        ;?DE**       F***                 |
        ;?DF**       F***                 |
        ; 4883C4 FF  ADD  RSP, FF         |
        ; --------------------------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.e.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0xDD241CDD
        jne    .cc.e.out
        cmp     [rdi + 04], word 0x2404
        jne    .cc.e.out
        ; ---------------------------------------------------------
        push    rdi
        add     rdi, 6
        call    SIC_IDA.ida                     ; rax = current instruction size
        pop     rdi
        ;
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        cmp     eax, 2
        jne    .cc.e.out
        ; ---------------------------------------------------------
        cmp     [rdi + 08], byte 0x48
        jne    .cc.e.out
        cmp     [rdi + 09], word 0xC483
        jne    .cc.e.out
        ; ---------------------------------------------------------
        mov     al, [rdi + 11]
        test    al, al
        js     .cc.e.out
        ; ---------------------------------------------------------
        mov     dx, [rdi + 06]
        cmp     dl, 0xD8
        jb     .cc.e.out
        cmp     dl, 0xDF
        ja     .cc.e.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dx
        mov     [rdi + 2], dword 0x00C48348
        mov     [rdi + 5], al
;       mov     [.esi], 12
        mov     [.edi], 6
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.e.out:
  }
   .cc.e..in:
        SIC_OP.cc.L0.3B.e
   .cc.e..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.3B.xor_rax_xmm0
  {
   .cc.xor_rax_xmm0.in:
;       cmp     ebx, 3
;       jne    .cc.xor_rax_xmm0.out
        ; ---------------------------------------------------------
        ; 8 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;> 48 31 C0        XOR    RAX, RAX
        ;  66 48 0F 6E C0  MOVQ   XMM0, RAX
        ; ---------------------------------------------------------
        ;> 48 31 C0        XOR    RAX, RAX
        ;  66 0F 57 C0     XORPD  XMM0, XMM0
        ; ---------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.xor_rax_xmm0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0x66C03148
        jne    .cc.xor_rax_xmm0.out
        cmp     [rdi + 4], dword 0xC06E0F48
        jne    .cc.xor_rax_xmm0.out
        ; ---------------------------------------------------------
        mov     [rdi + 3], dword 0xC0570F66
;       mov     [.esi], 8
        mov     [.edi], 7
        jmp    .cc.momem
   .cc.xor_rax_xmm0.out:
  }
   .cc.xor_rax_xmm0..in:
        SIC_OP.cc.L0.3B.xor_rax_xmm0
   .cc.xor_rax_xmm0..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.00.01
  {
   .cc.00.01.in:
;       cmp     ebx, 3
;       jne    .cc.00.01.out
        ; ---------------------------------------------------------
        ; 6 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  DD0424   FLD  QWORD [xSP] |
        ;   DD1C24   FSTP QWORD [xSP] |
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.00.01.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xDD2404DD
        jne    .cc.00.01.out
        cmp     [rdi + 4], word 0x241C
        jne    .cc.00.01.out
        ; ---------------------------------------------------------
;       mov     [.esi], 6
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.00.01.out:
  }
   .cc.00.01..in:
        SIC_OP.cc.L0.3B.00.01
   .cc.00.01..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.01
  {
   .cc.01.in:
;       cmp     ebx, 3
;       jne    .cc.01.out
        ; ---------------------------------------------------------
        ; 10 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  DD1C24   FSTP QWORD [xSP] | 4883C4 FF  ADD RSP, FF
        ;   DD0424   FLD  QWORD [xSP] |
        ; 4883C4 FF  ADD  RSP, FF     |
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.01.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xDD241CDD
        jne    .cc.01.out
        cmp     [rdi + 4], word 0x2404
        jne    .cc.01.out
        cmp     [rdi + 6], byte 0x48
        jne    .cc.01.out
        cmp     [rdi + 7], word 0xC483
        jne    .cc.01.out
        ; ---------------------------------------------------------
        mov     al, [rdi + 9]
        test    al, al
        js     .cc.01.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], al
;       mov     [.esi], 10
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.01.out:
  }
   .cc.01..in:
        SIC_OP.cc.L0.3B.01
   .cc.01..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.02
  {
   .cc.02.in:
;       cmp     ebx, 3
;       jne    .cc.02.out
        ; ---------------------------------------------------------
        ; 6 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  DD1C24   FSTP QWORD [xSP] |   DD1424   FST QWORD [xSP]
        ;   DD0424   FLD  QWORD [xSP] |
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.02.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0xDD241CDD
        jne    .cc.02.out
        cmp     [rdi + 4], word 0x2404
        jne    .cc.02.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x002414DD
;       mov     [.esi], 6
        mov     [.edi], 3
        jmp    .cc.momem
   .cc.02.out:
  }
   .cc.02..in:
        SIC_OP.cc.L0.3B.02
   .cc.02..out:
  $end

   .cc.L0.3B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 4
        jne    .cc.L0.4B.out
   .cc.L0.4B:

  $ifdef _SSEX
  macro SIC_OP.cc.L0.4B.rspB.xop
  {
   .cc.4B.rspB.xop.in:
;       cmp     ebx, 4
;       jne    .cc.4B.rspB.xop.out
        ; ---------------------------------------------------------
        ; 8 BYTES
        ; ---------------------------------------------------------
        ;> 48 83 C4 FF         ADD   RSP, FF
        ; ?F2 0F ** **         **
        ; ?66 0F ** **         **
        ; ---------------------------------------------------------
        ; 8 BYTES -> 8 BYTES
        ; ---------------------------------------------------------
        ;>?F2 0F ** **         **
        ; ?66 0F ** **         **
        ;  48 83 C4 FF         ADD   RSP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.4B.rspB.xop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], byte 0x48
        jne    .cc.4B.rspB.xop.out
        cmp     [rdi + 01], word 0xC483
        jne    .cc.4B.rspB.xop.out
        cmp     [rdi + 04], word 0x0FF2
        je     .cc.4B.rspB.xop.next
        cmp     [rdi + 04], word 0x0F66
        jne    .cc.4B.rspB.xop.out
   .cc.4B.rspB.xop.66.0F:
        ; ---------------------------------------------------------
        ;> 48 83 C4 FF         ADD   RSP, FF
        ; ?66 0F ** **         **
        ; -66 0F 2F **         COMISD
        ; -66 0F 2E **         UCOMISD
        ; ---------------------------------------------------------
        mov     al, byte [rdi + 06]
        case    al,\
                0x2F, .cc.4B.rspB.xop.out,\
                0x2E, .cc.4B.rspB.xop.out
   .cc.4B.rspB.xop.next:
        push    rdi
        add     rdi, [.cisize]
        call    SIC_IDA.ida                     ; rax = current instruction size
        pop     rdi
        ;
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        cmp     eax, 4
        jne    .cc.4B.rspB.xop.out
   .cc.4B.rspB.xop.main:
        ; ---------------------------------------------------------
        mov     al, byte [rdi + 03]
        mov     edx, dword [rdi + 04]
        mov     [rdi + 00], edx
        mov     [rdi + 04], dword 0x00C48348
        mov     [rdi + 07], al
        ; ---------------------------------------------------------
;       mov     [.esi], 8
        mov     [.edi], 8
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.4B.rspB.xop.out:
  }
   .cc.4B.rspB.xop..in:
        SIC_OP.cc.L0.4B.rspB.xop
   .cc.4B.rspB.xop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.4B.fstp.xmm
  {
   .cc.fstp.xmm.in:
;       cmp     ebx, 4
;       jne    .cc.fstp.xmm.out
        ; ---------------------------------------------------------
        ; 15 BYTES
        ; ---------------------------------------------------------
        ;> DD 5C 24 C0        FSTP  QWORD [xSP-64]
        ;  F2 0F 10 44 24 C0  MOVSD XMM0, QWORD [xSP-64]
        ;  F2 0F 11 04 24     MOVSD QWORD [xSP], XMM0
        ; ---------------------------------------------------------
        ; 15 BYTES -> 8 BYTES
        ; ---------------------------------------------------------
        ;> DD 1C 24           FSTP  QWORD [xSP]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ; ---------------------------------------------------------
        mov     [.esi], 15
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fstp.xmm.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0xC0245CDD
        jne    .cc.fstp.xmm.out
        cmp     [rdi + 04], dword 0x44100FF2
        jne    .cc.fstp.xmm.out
        cmp     [rdi + 08], dword 0x0FF2C024
        jne    .cc.fstp.xmm.out
        cmp     [rdi + 11], dword 0x2404110F
        jne    .cc.fstp.xmm.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0xF2241CDD
        mov     [rdi + 04], dword 0x2404100F
        ; ---------------------------------------------------------
;       mov     [.esi], 15
        mov     [.edi], 8
       .instr.shift.back 8, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.fstp.xmm.out:
  }
   .cc.fstp.xmm..in:
        SIC_OP.cc.L0.4B.fstp.xmm
   .cc.fstp.xmm..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.fxch.02
  {
   .cc.fxch.02.in:
;       cmp     ebx, 4
;       jne    .cc.fxch.02.out
        ; --------------------------------------------------------------------------
        ; 10 BYTES -> 8 BYTES
        ; --------------------------------------------------------------------------
        ;> DD4424 BB  FLD QWORD [xSP + BB] | DD4424 AA  FLD QWORD [xSP + AA]
        ;  DD4424 AA  FLD QWORD [xSP + AA] | DD4424 BB  FLD QWORD [xSP + BB]
        ;  D9C9       FXCH                 |
        ; --------------------------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fxch.02.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], word 0x44DD
        jne    .cc.fxch.02.out
        cmp     [rdi + 2], byte 0x24
        jne    .cc.fxch.02.out
        cmp     [rdi + 4], word 0x44DD
        jne    .cc.fxch.02.out
        cmp     [rdi + 6], byte 0x24
        jne    .cc.fxch.02.out
        cmp     [rdi + 8], word 0xC9D9
        jne    .cc.fxch.02.out
        ; ---------------------------------------------------------
        mov     edx, dword [rdi + 0]
        mov     eax, dword [rdi + 4]
        ; ---------------------------------------------------------
        mov     [rdi + 0], eax
        mov     [rdi + 4], edx
;       mov     [.esi], 10
        mov     [.edi], 8
        jmp    .cc.momem
   .cc.fxch.02.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.02..in:
        SIC_OP.cc.L0.4B.fxch.02
   .cc.fxch.02..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.fxch.08
  {
   .cc.fxch.08.in:
;       cmp     ebx, 4
;       jne    .cc.fxch.08.out
        ; --------------------------------------------------------------------------
        ; 8 BYTES -> 6 BYTES
        ; --------------------------------------------------------------------------
        ;> DD4424 AA  FLD QWORD [xSP + AA] |? D9E8       FLD1
        ;? D9E8       FLD1                 |? D9E9       FLDL2T
        ;? D9E9       FLDL2T               |? D9EA       FLDL2E
        ;? D9EA       FLDL2E               |? D9EB       FLDPI
        ;? D9EB       FLDPI                |? D9EC       FLDLG2
        ;? D9EC       FLDLG2               |? D9ED       FLDLN2
        ;? D9ED       FLDLN2               |? D9EE       FLDZ
        ;? D9EE       FLDZ                 |  DD4424 AA  FLD QWORD [xSP + AA]
        ;  D9C9       FXCH                 |
        ; --------------------------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fxch.08.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], word 0x44DD
        jne    .cc.fxch.08.out
        cmp     [rdi + 2], byte 0x24
        jne    .cc.fxch.08.out
        mov     dx, word [rdi + 4]
        case    dx,\
                0xE8D9, .cc.fxch.08.match,\
                0xE9D9, .cc.fxch.08.match,\
                0xEAD9, .cc.fxch.08.match,\
                0xEBD9, .cc.fxch.08.match,\
                0xECD9, .cc.fxch.08.match,\
                0xEDD9, .cc.fxch.08.match,\
                0xEED9, .cc.fxch.08.match
        jmp    .cc.fxch.08.out
   .cc.fxch.08.match:
        cmp     [rdi + 6], word 0xC9D9
        jne    .cc.fxch.08.out
        ; ---------------------------------------------------------
        mov     eax, dword [rdi + 0]
        ; ---------------------------------------------------------
        mov     [rdi + 0], dx
        mov     [rdi + 2], eax
;       mov     [.esi], 8
        mov     [.edi], 6
        jmp    .cc.momem
   .cc.fxch.08.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.08..in:
        SIC_OP.cc.L0.4B.fxch.08
   .cc.fxch.08..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.b
  {
   .cc.b.in:
;       cmp     ebx, 4
;       jne    .cc.b.out
        ; --------------------------------------------------------------------------
        ; 6 BYTES -> 4 BYTES
        ; --------------------------------------------------------------------------
        ;>DD4424 FF  FLD   QWORD [xSP + FF]|?DC4424 FF  FADD  QWORD [xSP + FF]
        ;?DEC1       FADDP                 |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;?DEE9       FSUBP                 |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ;?DEE1       FSUBRP                |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ;?DEC9       FMULP                 |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ;?DEF9       FDIVP                 |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;?DEF1       FDIVRP                |
        ; --------------------------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.b.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], word 0x44DD
        jne    .cc.b.out
        cmp     [rdi + 2], byte 0x24
        jne    .cc.b.out
        cmp     [rdi + 4], byte 0xDE
        jne    .cc.b.out
        ; ---------------------------------------------------------
        mov     dl, [rdi + 5]
        case    dl,\
                0xC1, .cc.b.addp,\
                0xE9, .cc.b.subp,\
                0xE1, .cc.b.subrp,\
                0xC9, .cc.b.mulp,\
                0xF9, .cc.b.divp,\
                0xF1, .cc.b.divrp
        jmp    .cc.b.out
        ; ---------------------------------------------------------
   .cc.b.addp:
        mov     ah, 0x44
        jmp    .cc.b.set
   .cc.b.subp:
        mov     ah, 0x64
        jmp    .cc.b.set
   .cc.b.subrp:
        mov     ah, 0x6C
        jmp    .cc.b.set
   .cc.b.mulp:
        mov     ah, 0x4C
        jmp    .cc.b.set
   .cc.b.divp:
        mov     ah, 0x74
        jmp    .cc.b.set
   .cc.b.divrp:
        mov     ah, 0x7C
        jmp    .cc.b.set
        ; ---------------------------------------------------------
   .cc.b.set:
        mov     [rdi + 0], byte 0xDC
        mov     [rdi + 1], ah
;       mov     [.esi], 6
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.b.out:
  }
   .cc.b..in:
        SIC_OP.cc.L0.4B.b
   .cc.b..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.00.02
  {
   .cc.00.02.in:
;       cmp     ebx, 4
;       jne    .cc.00.02.out
        ; ---------------------------------------------------------
        ; 11 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;> DD442408  FLD  QWORD [xSP+8] | 4883C408  ADD  RSP, 8
        ;  4883C408  ADD  RSP, 8        |
        ;  DD1C24    FSTP QWORD [xSP]   |
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.00.02.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x082444DD
        jne    .cc.00.02.out
        cmp     [rdi + 04], dword 0x08C48348
        jne    .cc.00.02.out
        cmp     [rdi + 08], word 0x1CDD
        jne    .cc.00.02.out
        cmp     [rdi + 10], byte 0x24
        jne    .cc.00.02.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x08C48348
;       mov     [.esi], 11
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.00.02.out:
  }
   .cc.00.02..in:
        SIC_OP.cc.L0.4B.00.02
   .cc.00.02..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.add_rsp.fstp_st0 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.add_rsp.fstp_st0.in:
;       cmp     ebx, 4
;       jne    .cc.add_rsp.fstp_st0.out
        ; ---------------------------------------------------------
        ; 6 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;> 4883C4 FF  ADD  RSP, FF     |  DDD8       FSTP ST0
        ;  DDD8       FSTP ST0         |  4883C4 FF  ADD  RSP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.add_rsp.fstp_st0.out
    else
        jl     .cc.add_rsp.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.add_rsp.fstp_st0.out
        cmp     [rdi + 1], word 0xC483
        jne    .cc.add_rsp.fstp_st0.out
        cmp     [rdi + 4], word 0xD8DD
        jne    .cc.add_rsp.fstp_st0.out
        ; ---------------------------------------------------------
        mov     dl, [rdi + 3]
        mov     [rdi + 0], word 0xD8DD
        mov     [rdi + 2], dword 0x00C48348
        mov     [rdi + 5], dl
;       mov     [.esi], 6
        mov     [.edi], 6
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.add_rsp.fstp_st0.out:
  }
   .cc.add_rsp.fstp_st0..in:
        SIC_OP.cc.L0.4B.add_rsp.fstp_st0 .static.FSTP.ST0
   .cc.add_rsp.fstp_st0..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.add_rsp.fpu
  {
   .cc.add_rsp.fpu.in:
;       cmp     ebx, 4
;       jne    .cc.add_rsp.fpu.out
        ; ---------------------------------------------------------
        ;> 4883C4 FF  ADD  RSP, FF     | 4 BYTES
        ;? D***       F***             | 2 BYTES
        ;? D*** FF+   F*** FF+         | 6 BYTES
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0x48
        jne    .cc.add_rsp.fpu.out
        cmp     [rdi + 1], word 0xC483
        jne    .cc.add_rsp.fpu.out
        ; ---------------------------------------------------------
        mov     dl, [rdi + 4]
        cmp     dl, 0xD8
        jb     .cc.add_rsp.fpu.out
        cmp     dl, 0xDF
        ja     .cc.add_rsp.fpu.out
        ; ---------------------------------------------------------
        push    rdi
        add     rdi, 4
        call    SIC_IDA.ida                     ; rax = current instruction size
        pop     rdi
        ;
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        cmp     eax, 2
        je     .cc.add_rsp.fpu.2B
        cmp     eax, 6
        je     .cc.add_rsp.fpu.6B
        jmp    .cc.add_rsp.fpu.out
   .cc.add_rsp.fpu.2B:
        ; ---------------------------------------------------------
        ; 6 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;> 4883C4 FF  ADD  RSP, FF      |  D***       F***
        ;? D8**       F***              |  4883C4 FF  ADD  RSP, FF
        ;? D9**       F***              |
        ;? DA**       F***              |
        ;? DB**       F***              |
        ;? DC**       F***              |
        ;? DD**       F***              |
        ;? DE**       F***              |
        ;? DF**       F***              |
        ;+ DD11       FST   QWORD [RCX] |
        ;+ DDC0       FFREE ST0         |
        ;- DDD8       FSTP  ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.add_rsp.fpu.out
        ; ---------------------------------------------------------
        mov     dl, [rdi + 3]
        mov     ax, [rdi + 4]
        cmp     ax, 0xD8DD
        je     .cc.add_rsp.fpu.out
;       cmp     ax, 0x11DD
;       je     .cc.add_rsp.fpu.out
;       cmp     ax, 0xC0DD
;       je     .cc.add_rsp.fpu.out
        mov     [rdi + 0], ax
        mov     [rdi + 2], dword 0x00C48348
        mov     [rdi + 5], dl
;       mov     [.esi], 6
        mov     [.edi], 6
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.add_rsp.fpu.6B:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 10 BYTES
        ; ---------------------------------------------------------
        ;> 4883C4 FF  ADD  RSP, FF     |  D*** FF+   F*** FF+
        ;? D8** FF+   F*** FF+         |  4883C4 FF  ADD  RSP, FF
        ;? D9** FF+   F*** FF+         |
        ;? DA** FF+   F*** FF+         |
        ;? DB** FF+   F*** FF+         |
        ;? DC** FF+   F*** FF+         |
        ;? DD** FF+   F*** FF+         |
        ;? DE** FF+   F*** FF+         |
        ;? DF** FF+   F*** FF+         |
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.add_rsp.fpu.out
        ; ---------------------------------------------------------
        mov     dl, [rdi + 3]
        mov     ax, [rdi + 4]
        mov     [rdi + 0], ax
        mov     eax, [rdi + 6]
        mov     [rdi + 2], eax
        mov     [rdi + 6], dword 0x00C48348
        mov     [rdi + 9], dl
;       mov     [.esi], 10
        mov     [.edi], 10
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.add_rsp.fpu.out:
  }
   .cc.add_rsp.fpu..in:
        SIC_OP.cc.L0.4B.add_rsp.fpu
   .cc.add_rsp.fpu..out:
  $end

  macro SIC_OP.cc.L0.4B.sub_rsp_8
  {
   .cc.sub_rsp_8.in:
;       cmp     ebx, 4
;       jne    .cc.sub_rsp_8.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;>  4883C4 F8  ADD RSP, -8   |   53       PUSH RBX
        ;>  4883EC 08  SUB RSP, +8   |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.sub_rsp_8.out
        ; ---------------------------------------------------------
        mov     eax, [rdi + 0]
        case    eax,\
                0xF8C48348, .cc.sub_rsp_8.match,\
                0x08EC8348, .cc.sub_rsp_8.match
        jmp    .cc.sub_rsp_8.out
   .cc.sub_rsp_8.match:
        mov     [rdi + 0], byte 0x53
;       mov     [.esi], 4
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.sub_rsp_8.out:
  }
  $ifdef SIC_OP.RSP_PUSH_POP
   .cc.sub_rsp_8..in:
;       SIC_OP.cc.L0.4B.sub_rsp_8
   .cc.sub_rsp_8..out:
  $end

  macro SIC_OP.cc.L0.4B.add_rsp_8
  {
   .cc.add_rsp_8.in:
;       cmp     ebx, 4
;       jne    .cc.add_rsp_8.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;>  4883C4 08  ADD RSP, +8   |   5*       POP R*X
        ;>  4883EC F8  SUB RSP, -8   |
        ;?  48B8 8B    MOV RAX, B8B  |
        ;?  48B9 8B    MOV RCX, B8B  |
        ;?  48BA 8B    MOV RDX, B8B  |
        ;?  4831C0     XOR RAX, RAX  |
        ;?  4831C9     XOR RCX, RCX  |
        ;?  4831D2     XOR RDX, RDX  |
        ;?  48C7C0 4B  MOV RAX, B4B  |
        ;?  48C7C1 4B  MOV RCX, B4B  |
        ;?  48C7C2 4B  MOV RDX, B4B  |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.add_rsp_8.out
        ; ---------------------------------------------------------
        cmp     [rdi + 4], byte 0x48
        jne    .cc.add_rsp_8.out
        mov     eax, [rdi + 0]
        case    eax,\
                0x08C48348, .cc.add_rsp_8.match,\
                0xF8EC8348, .cc.add_rsp_8.match
        jmp    .cc.add_rsp_8.out
   .cc.add_rsp_8.match:
        mov     ax, [rdi + 5]
        case    al,\
                0xB8, .cc.add_rsp_8.rax,\
                0xB9, .cc.add_rsp_8.rcx,\
                0xBA, .cc.add_rsp_8.rdx
        case    ax,\
                0xC031, .cc.add_rsp_8.rax,\
                0xC931, .cc.add_rsp_8.rcx,\
                0xD231, .cc.add_rsp_8.rdx
        case    ax,\
                0xC0C7, .cc.add_rsp_8.rax,\
                0xC1C7, .cc.add_rsp_8.rcx,\
                0xC2C7, .cc.add_rsp_8.rdx
        jmp    .cc.add_rsp_8.out
   .cc.add_rsp_8.rax:
        ; ---------------------------------------------------------
        ; 4 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> ... | 58  POP RAX
        ; ---------------------------------------------------------
        mov     [rdi + 0], byte 0x58
;       mov     [.esi], 4
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.add_rsp_8.rcx:
        ; ---------------------------------------------------------
        ; 4 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> ... | 59  POP RCX
        ; ---------------------------------------------------------
        mov     [rdi + 0], byte 0x59
;       mov     [.esi], 4
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.add_rsp_8.rdx:
        ; ---------------------------------------------------------
        ; 4 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> ... | 5A  POP RDX
        ; ---------------------------------------------------------
        mov     [rdi + 0], byte 0x5A
;       mov     [.esi], 4
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.add_rsp_8.out:
  }
  $ifdef SIC_OP.RSP_PUSH_POP
   .cc.add_rsp_8..in:
;       SIC_OP.cc.L0.4B.add_rsp_8
   .cc.add_rsp_8..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.4B.add_rsp_8.fstp_rsp
  {
   .cc.add_rsp_8.fstp_rsp.in:
;       cmp     ebx, 4
;       jne    .cc.add_rsp_8.fstp_rsp.out
        ; ---------------------------------------------------------
        ; 7 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;>  4883C4 08  ADD  RSP, +8     | DD5C2408  FSTP QWORD [RSP + 8]
        ;>  4883EC F8  SUB  RSP, -8     | 5*        POP R*X
        ;   DD1C24     FSTP QWORD [RSP] |
        ;?  48B8 8B    MOV  RAX, B8B    |
        ;?  48B9 8B    MOV  RCX, B8B    |
        ;?  48BA 8B    MOV  RDX, B8B    |
        ;?  4831C0     XOR  RAX, RAX    |
        ;?  4831C9     XOR  RCX, RCX    |
        ;?  4831D2     XOR  RDX, RDX    |
        ;?  48C7C0 4B  MOV  RAX, B4B    |
        ;?  48C7C1 4B  MOV  RCX, B4B    |
        ;?  48C7C2 4B  MOV  RDX, B4B    |
        ; ---------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.add_rsp_8.fstp_rsp.out
        ; ---------------------------------------------------------
        cmp     [rdi + 4], word 0x1CDD
        jne    .cc.add_rsp_8.fstp_rsp.out
        cmp     [rdi + 6], byte 0x24
        jne    .cc.add_rsp_8.fstp_rsp.out
        cmp     [rdi + 7], byte 0x48
        jne    .cc.add_rsp_8.fstp_rsp.out
        mov     eax, [rdi + 0]
        case    eax,\
                0x08C48348, .cc.add_rsp_8.fstp_rsp.match,\
                0xF8EC8348, .cc.add_rsp_8.fstp_rsp.match
        jmp    .cc.add_rsp_8.fstp_rsp.out
   .cc.add_rsp_8.fstp_rsp.match:
        mov     ax, [rdi + 8]
        case    al,\
                0xB8, .cc.add_rsp_8.fstp_rsp.rax,\
                0xB9, .cc.add_rsp_8.fstp_rsp.rcx,\
                0xBA, .cc.add_rsp_8.fstp_rsp.rdx
        case    ax,\
                0xC031, .cc.add_rsp_8.fstp_rsp.rax,\
                0xC931, .cc.add_rsp_8.fstp_rsp.rcx,\
                0xD231, .cc.add_rsp_8.fstp_rsp.rdx
        case    ax,\
                0xC0C7, .cc.add_rsp_8.fstp_rsp.rax,\
                0xC1C7, .cc.add_rsp_8.fstp_rsp.rcx,\
                0xC2C7, .cc.add_rsp_8.fstp_rsp.rdx
        jmp    .cc.add_rsp_8.fstp_rsp.out
   .cc.add_rsp_8.fstp_rsp.rax:
        ; ---------------------------------------------------------
        ; 7 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> ... | DD5C2408  FSTP QWORD [RSP + 8]
        ;      | 58        POP RAX
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x08245CDD
        mov     [rdi + 4], byte 0x58
;       mov     [.esi], 7
        mov     [.edi], 5
        jmp    .cc.momem
   .cc.add_rsp_8.fstp_rsp.rcx:
        ; ---------------------------------------------------------
        ; 7 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> ... | DD5C2408  FSTP QWORD [RSP + 8]
        ;      | 59        POP RCX
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x08245CDD
        mov     [rdi + 4], byte 0x59
;       mov     [.esi], 7
        mov     [.edi], 5
        jmp    .cc.momem
   .cc.add_rsp_8.fstp_rsp.rdx:
        ; ---------------------------------------------------------
        ; 7 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> ... | DD5C2408  FSTP QWORD [RSP + 8]
        ;      | 5A        POP RDX
        ; ---------------------------------------------------------
        mov     [rdi + 0], dword 0x08245CDD
        mov     [rdi + 4], byte 0x5A
;       mov     [.esi], 7
        mov     [.edi], 5
        jmp    .cc.momem
   .cc.add_rsp_8.fstp_rsp.out:
  }
   .cc.add_rsp_8.fstp_rsp..in:
        SIC_OP.cc.L0.4B.add_rsp_8.fstp_rsp
   .cc.add_rsp_8.fstp_rsp..out:
  $end

  macro SIC_OP.cc.L0.4B.rsp_rax
  {
   .cc.rsp_rax.in:
;       cmp     ebx, 4
;       jne    .cc.rsp_rax.out
        ; ---------------------------------------------------------
        ; 8 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;> 48890424  MOV [RSP], RAX | 48890424  MOV [RSP], RAX
        ;  488B0424  MOV RAX, [RSP] |
        ; ---------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rsp_rax.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], dword 0x24048948
        jne    .cc.rsp_rax.out
        cmp     [rdi + 4], dword 0x24048B48
        jne    .cc.rsp_rax.out
        ; ---------------------------------------------------------
;       mov     [.esi], 8
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.rsp_rax.out:
  }
   .cc.rsp_rax..in:
        SIC_OP.cc.L0.4B.rsp_rax
   .cc.rsp_rax..out:

   .cc.L0.4B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 5
        jne    .cc.L0.5B.out
   .cc.L0.5B:

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B.movsd.xmm
  {
   .cc.movsd.xmm.in:
;       cmp     ebx, 5
;       jne    .cc.movsd.xmm.out
        ; ---------------------------------------------------------
        ; 10 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ;  F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ; ---------------------------------------------------------
        ; 10 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F 10 04 24     MOVSD XMM0, QWORD [xSP]
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.movsd.xmm.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], dword 0x04100FF2
        jne    .cc.movsd.xmm.out
        cmp     [rdi + 04], dword 0x100FF224
        jne    .cc.movsd.xmm.out
        cmp     [rdi + 08], word 0x2404
        jne    .cc.movsd.xmm.out
        ; ---------------------------------------------------------
        mov     [rdi + 00], dword 0x04100FF2
        mov     [rdi + 04], byte 0x24
        ; ---------------------------------------------------------
;       mov     [.esi], 10
        mov     [.edi], 5
       .instr.shift.back 5                      ; instruction shift back
        jmp    .cc.momem
   .cc.movsd.xmm.out:
  }
   .cc.movsd.xmm..in:
        SIC_OP.cc.L0.5B.movsd.xmm
   .cc.movsd.xmm..out:
  $end

  macro SIC_OP.cc.L0.5B.mov_eax_0
  {
   .cc.mov_eax_0.in:
;       cmp     ebx, 5
;       jne    .cc.mov_eax_0.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  B8 00+   MOV  EAX, 00+    | 4831C0     XOR  RAX, RAX
        ;-4883D0 00  ADC  RAX, 0
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.mov_eax_0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], byte 0xB8
        jne    .cc.mov_eax_0.out
        cmp     [rdi + 1], dword 0x00000000
        jne    .cc.mov_eax_0.out
        cmp     [rdi + 5], dword 0x00D08348
        je     .cc.mov_eax_0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], byte 0x48
        mov     [rdi + 1], word 0xC031
;       mov     [.esi], 5
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_eax_0.out:
  }
   .cc.mov_eax_0..in:
        SIC_OP.cc.L0.5B.mov_eax_0
   .cc.mov_eax_0..out:

   .cc.L0.5B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 7
        jne    .cc.L0.7B.out
   .cc.L0.7B:

  $ifdef _SSEX
  macro SIC_OP.cc.L0.7B.rspB.xop
  {
   .cc.7B.rspB.xop.in:
;       cmp     ebx, 7
;       jne    .cc.7B.rspB.xop.out
        ; ---------------------------------------------------------
        ; 11 BYTES
        ; ---------------------------------------------------------
        ;> 48 81 C4 FF+        ADD   RSP, FF+
        ; ?F2 0F ** **         **
        ; ?66 0F ** **         **
        ; ---------------------------------------------------------
        ; 11 BYTES -> 11 BYTES
        ; ---------------------------------------------------------
        ;>?F2 0F ** **         **
        ; ?66 0F ** **         **
        ;  48 81 C4 FF+        ADD   RSP, FF+
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.7B.rspB.xop.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], byte 0x48
        jne    .cc.7B.rspB.xop.out
        cmp     [rdi + 01], word 0xC481
        jne    .cc.7B.rspB.xop.out
        cmp     [rdi + 07], word 0x0FF2
        je     .cc.7B.rspB.xop.next
        cmp     [rdi + 07], word 0x0F66
        jne    .cc.7B.rspB.xop.out
   .cc.7B.rspB.xop.66.0F:
        ; ---------------------------------------------------------
        ;> 48 81 C4 FF+        ADD   RSP, FF+
        ; ?66 0F ** **         **
        ; -66 0F 2F **         COMISD
        ; -66 0F 2E **         UCOMISD
        ; ---------------------------------------------------------
        mov     dl, byte [rdi + 09]
        case    dl,\
                0x2F, .cc.7B.rspB.xop.out,\
                0x2E, .cc.7B.rspB.xop.out
   .cc.7B.rspB.xop.next:
        push    rdi
        add     rdi, [.cisize]
        call    SIC_IDA.ida                     ; rax = current instruction size
        pop     rdi
        ;
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        cmp     eax, 4
        jne    .cc.7B.rspB.xop.out
   .cc.7B.rspB.xop.main:
        ; ---------------------------------------------------------
        mov     eax, dword [rdi + 03]
        mov     edx, dword [rdi + 07]
        mov     [rdi + 00], edx
        mov     [rdi + 04], dword 0x00C48148
        mov     [rdi + 07], eax
        ; ---------------------------------------------------------
;       mov     [.esi], 11
        mov     [.edi], 11
       .instr.shift.back 7                      ; instruction shift back
        jmp    .cc.momem
   .cc.7B.rspB.xop.out:
  }
   .cc.7B.rspB.xop..in:
        SIC_OP.cc.L0.7B.rspB.xop
   .cc.7B.rspB.xop..out:
  $end

   .cc.L0.7B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 10
        jne    .cc.L0.10B.out
   .cc.L0.10B:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.10B.con.I0
  {
   .cc.con.I0.in:
;       cmp     ebx, 10
;       jne    .cc.con.I0.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> 48B8 00000000  MOV  RAX, 0      | D9EE  FLDZ
        ;       00000000                   |
        ;  50             PUSH RAX         |
        ;  DF2C24         FILD QWORD [RSP] |
        ;  4883C408       ADD  RSP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.con.I0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], word 0xB848
        jne    .cc.con.I0.out
        cmp     [rdi + 02], dword 0x00000000
        jne    .cc.con.I0.out
        cmp     [rdi + 06], dword 0x00000000
        jne    .cc.con.I0.out
        cmp     [rdi + 10], dword 0x242CDF50
        jne    .cc.con.I0.out
        cmp     [rdi + 14], dword 0x08C48348
        jne    .cc.con.I0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0xEED9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.I0.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.I0..in:
        SIC_OP.cc.L0.10B.con.I0
   .cc.step.con.I0..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.10B.con.I1
  {
   .cc.con.I1.in:
;       cmp     ebx, 10
;       jne    .cc.con.I1.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> 48B8 01000000  MOV  RAX, 0      | D9E8  FLD1
        ;       00000000                   |
        ;  50             PUSH RAX         |
        ;  DF2C24         FILD QWORD [RSP] |
        ;  4883C408       ADD  RSP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.con.I1.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], word 0xB848
        jne    .cc.con.I1.out
        cmp     [rdi + 02], dword 0x00000001
        jne    .cc.con.I1.out
        cmp     [rdi + 06], dword 0x00000000
        jne    .cc.con.I1.out
        cmp     [rdi + 10], dword 0x242CDF50
        jne    .cc.con.I1.out
        cmp     [rdi + 14], dword 0x08C48348
        jne    .cc.con.I1.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0xE8D9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.I1.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.I1..in:
        SIC_OP.cc.L0.10B.con.I1
   .cc.step.con.I1..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.10B.con.0
  {
   .cc.con.0.in:
;       cmp     ebx, 10
;       jne    .cc.con.0.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> 48B9 00000000  MOV  RCX, 0      | D9EE  FLDZ
        ;       00000000                   |
        ;  51             PUSH RCX         |
        ;  DD0424         FLD  QWORD [RSP] |
        ;  4883C408       ADD  RSP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.con.0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.con.0.out
        cmp     [rdi + 02], dword 0x00000000
        jne    .cc.con.0.out
        cmp     [rdi + 06], dword 0x00000000
        jne    .cc.con.0.out
        cmp     [rdi + 10], dword 0x2404DD51
        jne    .cc.con.0.out
        cmp     [rdi + 14], dword 0x08C48348
        jne    .cc.con.0.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0xEED9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.0.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.0..in:
        SIC_OP.cc.L0.10B.con.0
   .cc.step.con.0..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.10B.con.1
  {
   .cc.con.1.in:
;       cmp     ebx, 10
;       jne    .cc.con.1.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> 48B9 00000000  MOV  RCX, 1      | D9E8  FLD1
        ;       0000F03F                   |
        ;  51             PUSH RCX         |
        ;  DD0424         FLD  QWORD [RSP] |
        ;  4883C408       ADD  RSP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.con.1.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.con.1.out
        cmp     [rdi + 02], dword 0x00000000
        jne    .cc.con.1.out
        cmp     [rdi + 06], dword 0x3FF00000
        jne    .cc.con.1.out
        cmp     [rdi + 10], dword 0x2404DD51
        jne    .cc.con.1.out
        cmp     [rdi + 14], dword 0x08C48348
        jne    .cc.con.1.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0xE8D9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.1.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.1..in:
        SIC_OP.cc.L0.10B.con.1
   .cc.step.con.1..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.10B.con.pi
  {
   .cc.con.pi.in:
;       cmp     ebx, 10
;       jne    .cc.con.pi.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> 48B9 182D4454  MOV  RCX, PI     | D9EB  FLDPI
        ;       FB210940                   |
        ;  51             PUSH RCX         |
        ;  DD0424         FLD  QWORD [RSP] |
        ;  4883C408       ADD  RSP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.con.pi.out
        ; ---------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.con.pi.out
        cmp     [rdi + 02], dword 0x54442D18
        jne    .cc.con.pi.out
        cmp     [rdi + 06], dword 0x400921FB
        jne    .cc.con.pi.out
        cmp     [rdi + 10], dword 0x2404DD51
        jne    .cc.con.pi.out
        cmp     [rdi + 14], dword 0x08C48348
        jne    .cc.con.pi.out
        ; ---------------------------------------------------------
        mov     [rdi + 0], word 0xEBD9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.pi.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.pi..in:
        SIC_OP.cc.L0.10B.con.pi
   .cc.step.con.pi..out:
    $end
  $end

  macro SIC_OP.cc.L0.10B.mov_rax_Q0
  {
   .cc.mov_rax_Q0.in:
;       cmp     ebx, 10
;       jne    .cc.mov_rax_Q0.out
        ; ---------------------------------------------------------
        ; 10 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>48B8 00+   MOV  RAX, 00+    | 4831C0     XOR  RAX, RAX
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.mov_rax_Q0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], word 0xB848
        jne    .cc.mov_rax_Q0.out
        xor     rax, rax
        cmp     [rdi + 2], rax
        jne    .cc.mov_rax_Q0.out
        ; ---------------------------------------------------------
        mov     [rdi + 1], word 0xC031
;       mov     [.esi], 10
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_rax_Q0.out:
  }
   .cc.mov_rax_Q0..in:
        SIC_OP.cc.L0.10B.mov_rax_Q0
   .cc.mov_rax_Q0..out:

  macro SIC_OP.cc.L0.10B.mov_rdx_Q0
  {
   .cc.mov_rdx_Q0.in:
;       cmp     ebx, 10
;       jne    .cc.mov_rdx_Q0.out
        ; ---------------------------------------------------------
        ; 10 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>48BA 00+   MOV  RDX, 00+    | 4831D2     XOR  RDX, RDX
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.mov_rdx_Q0.out
        ; ---------------------------------------------------------
        cmp     [rdi + 0], word 0xBA48
        jne    .cc.mov_rdx_Q0.out
        xor     rax, rax
        cmp     [rdi + 2], rax
        jne    .cc.mov_rdx_Q0.out
        ; ---------------------------------------------------------
        mov     [rdi + 1], word 0xD231
;       mov     [.esi], 10
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_rdx_Q0.out:
  }
   .cc.mov_rdx_Q0..in:
        SIC_OP.cc.L0.10B.mov_rdx_Q0
   .cc.mov_rdx_Q0..out:

  macro SIC_OP.cc.L0.10B.mov_rcx_Q0
  {
   .cc.mov_rcx_Q0.in:
;       cmp     ebx, 10
;       jne    .cc.mov_rcx_Q0.out
        ; ----------------------------------------------------------------------
        ; 10 BYTES -> 3 BYTES
        ; ----------------------------------------------------------------------
        ;>48B9 00+   MOV  RCX, 00+    | 4831C9     XOR  RCX, RCX
        ; ----------------------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.mov_rcx_Q0.out
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], word 0xB948
        jne    .cc.mov_rcx_Q0.out
        xor     rax, rax
        cmp     [rdi + 2], rax
        jne    .cc.mov_rcx_Q0.out
        ; ----------------------------------------------------------------------
        mov     [rdi + 1], word 0xC931
;       mov     [.esi], 10
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_rcx_Q0.out:
  }
   .cc.mov_rcx_Q0..in:
        SIC_OP.cc.L0.10B.mov_rcx_Q0
   .cc.mov_rcx_Q0..out:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.10B.10
  {
   .cc.10.in:
;       cmp     ebx, 10
;       jne    .cc.10.out
        ; -------------------------------------------------------------------------
        ;>48B9 AA+  MOV  RCX, AA+    |
        ; FF31      PUSH QWORD [RCX] |
        ; ...                        |
        ; -------------------------------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .cc.10.out
        cmp     [rdi + 10], word 0x31FF
        jne    .cc.10.out
        cmp     [rdi + 12], word 0xB948
        je     .cc.10.02
   .cc.10..01:
        ; -------------------------------------------------------------------------
        ; 16 BYTES -> 16 BYTES
        ; -------------------------------------------------------------------------
        ;>48B9 AA+  MOV  RCX, AA+    | 48B9 AA+  MOV RCX, AA+
        ; FF31      PUSH QWORD [RCX] | DD01      FLD QWORD [RCX]
        ; DD0424    FLD  QWORD [RSP] | 4883C4F8  ADD RSP, -08
        ; 90        NOP              |
        ; -------------------------------------------------------------------------
        cmp     [rdi + 12], dword 0x902404DD
        jne    .cc.10.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 16
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.10.out
        ; ---------------------------------------------------------
        mov     [rdi + 10], word 0x01DD
        mov     [rdi + 12], dword 0xF8C48348
;       mov     [.esi], 16
        mov     [.edi], 16
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.10.02:
        ; -------------------------------------------------------------------------
        ;>48B9 BB+  MOV  RCX, BB+    |
        ; FF31      PUSH QWORD [RCX] |
        ; 48B9 AA+  MOV  RCX, AA+    |
        ; FF31      PUSH QWORD [RCX] |
        ; ...                        |
        ; -------------------------------------------------------------------------
        cmp     [rdi + 22], word 0x31FF
        jne    .cc.10.out
        cmp     [rdi + 24], word 0xB948
        je     .cc.10.03
   .cc.10..02:
        ; -------------------------------------------------------------------------
        ; 31 BYTES -> 28 BYTES
        ; -------------------------------------------------------------------------
        ;>48B9 BB+  MOV  RCX, BB+        | 48B9 BB+  MOV RCX, BB+
        ; FF31      PUSH QWORD [RCX]     | 48B8 AA+  MOV RAX, AA+
        ; 48B9 AA+  MOV  RCX, AA+        | DD00      FLD QWORD [RAX]
        ; FF31      PUSH QWORD [RCX]     | DD01      FLD QWORD [RCX]
        ; DD0424    FLD  QWORD [RSP]     | 4883C4F0  ADD RSP, -16
        ; DD4424 08 FLD  QWORD [RSP + 8] |
        ; -------------------------------------------------------------------------
        cmp     [rdi + 24], dword 0xDD2404DD
        jne    .cc.10.out
        cmp     [rdi + 28], word 0x2444
        jne    .cc.10.out
        cmp     [rdi + 30], byte 0x08
        jne    .cc.10.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 31
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.10.out
        ; ---------------------------------------------------------
        mov     rax, [rdi + 14]
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x01DD00DD
        mov     [rdi + 24], dword 0xF0C48348
;       mov     [.esi], 31
        mov     [.edi], 28
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.10.03:
        ; -------------------------------------------------------------------------
        ;>48B9 CC+  MOV  RCX, CC+    |
        ; FF31      PUSH QWORD [RCX] |
        ; 48B9 BB+  MOV  RCX, BB+    |
        ; FF31      PUSH QWORD [RCX] |
        ; 48B9 AA+  MOV  RCX, AA+    |
        ; FF31      PUSH QWORD [RCX] |
        ; ...                        |
        ; -------------------------------------------------------------------------
        cmp     [rdi + 34], word 0x31FF
        jne    .cc.10.out
   .cc.10..03:
        ; -------------------------------------------------------------------------
        ; 47 BYTES -> 40 BYTES
        ; -------------------------------------------------------------------------
        ;>48B9 CC+  MOV  RCX, CC+         | 48B9 CC+  MOV RCX, CC+
        ; FF31      PUSH QWORD [RCX]      | 48BA BB+  MOV RDX, BB+
        ; 48B9 BB+  MOV  RCX, BB+         | 48B8 AA+  MOV RAX, AA+
        ; FF31      PUSH QWORD [RCX]      | DD00      FLD QWORD [RAX]
        ; 48B9 AA+  MOV  RCX, AA+         | DD02      FLD QWORD [RDX]
        ; FF31      PUSH QWORD [RCX]      | DD01      FLD QWORD [RCX]
        ; DD0424    FLD  QWORD [RSP]      | 4883C4E8  ADD RSP, -24
        ; DD4424 08 FLD  QWORD [RSP + 8]  |
        ; DD4424 10 FLD  QWORD [RSP + 16] |
        ; -------------------------------------------------------------------------
        cmp     [rdi + 36], dword 0xDD2404DD
        jne    .cc.10.out
        cmp     [rdi + 40], dword 0xDD082444
        jne    .cc.10.out
        cmp     [rdi + 44], word 0x2444
        jne    .cc.10.out
        cmp     [rdi + 46], byte 0x10
        jne    .cc.10.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 47
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.10.out
        ; ---------------------------------------------------------
        mov     rdx, [rdi + 14]
        mov     rax, [rdi + 26]
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB848
        mov     [rdi + 22], rax
        mov     [rdi + 30], word 0x00DD
        mov     [rdi + 32], dword 0x01DD02DD
        mov     [rdi + 36], dword 0xE8C48348
;       mov     [.esi], 47
        mov     [.edi], 40
       .instr.shift.back 4                       ; instruction shift back
        jmp    .cc.momem
   .cc.10.out:
  }
   .cc.10..in:
        SIC_OP.cc.L0.10B.10
   .cc.10..out:
  $end

   .cc.L0.10B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
   .cc.momem:
        add     rdi, [.edi]                     ; rdi = destination memory
        cmp     rdi, rsi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     rdi, [.xdi]
        add     rdi, [.edi]
        mov     rax, [.esi]
        sub     rax, [.edi]
        sub     [.ezx], rax
        sub     [.ecx], rax
        sub     [.rbx], rax
        jle    .cc.result
        mov     rax, [.misize]
        jmp    .cc.next.rdi

   .cc.next:
        mov     rax, [.cisize]
   .cc.next.rdi:
        add     rdi, rax                        ; rdi = next instruction
        sub     [.rbx], rax
;       cmp     [.rbx], 0
        jg     .cc.root

   .cc.result:
        mov     rax, [.ezx]

   .cc.return:
        pop     rdi rsi rbx
        ret

        ; -> [.esi] - initial bytes
        ; <- rcx    - bytes to copy
        ; <- rsi    - source memory
   .cc.size:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.L2, code, csize, rcode

       .static.FSTP.ST0 EQU 0
       .static.FREE.ST0 EQU 0

    locals
       .rbx     dq ?
       .edi     dq ?
       .eee     dq ?
       .zzz     dq ?
       .esi     dq ?
       .ezx     dq ?
       .ecx     dq ?
       .xcx     dq ?
       .xdi     dq ?
       .xsi     dq ?
       .misize  dq ?
       .cisize  dq ?                            ; current instruction size
       .pisize  dq ?                            ; previous instruction size
    endl

    ; be sure actual code size >= a, goto b otherwise
    macro .bound a, b {
        cmp     [.zzz], a
        jl      b
    }

    macro .instr.shift.back v, p {
      if v eq
        push    [.pisize]
        pop     [.misize]
        neg     [.misize]
        inc     [.misize]                       ; [.pisize] bytes shift back
      else
        mov     [.misize], 1-(v)                ; v bytes shift back
       if p eq 1
        push    rdx
        mov     rdx, [.pisize]
        sub     [.misize], rdx
        pop     rdx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

        mov     [code], rcx
        mov     [csize], rdx
        mov     [rcode], r8
;       mov     [], r9

        push    rbx rsi rdi

        mov     rax, [csize]
        test    rax, rax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], rax                     ; save initial code size
        mov     [.rbx], rax                     ; [.rbx] = initial code size
        mov     rdi, [code]                     ; rdi = code offset
        mov     [.eee], rdi                     ; save code offset
        mov     [.zzz], 0                       ; scanned bytes
        mov     [.ecx], rdi
        add     [.ecx], rax                     ; [.ecx] = code end pointer

        mov     [.cisize], 0
        mov     [.pisize], 0

   .cc.root:
        mov     rax, [.cisize]
        mov     [.pisize], rax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; rax = current instruction size
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        test    rax, rax
        jz     .cc.result
        mov     [.cisize], rax
        mov     rbx, rax                        ; rbx = current instruction size

   .cc.main:
        mov     [.misize], 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.4B_7B?:
        cmp     ebx, 4
        je     .cc.L0.4B_7B
        cmp     ebx, 7
        jne    .cc.L0.4B_7B.out

   .cc.L0.4B_7B:

   .cc.add_rsp..in:
        SIC_OP.cc.L0.4B_7B.add_rsp
   .cc.add_rsp..out:

   .cc.L0.4B_7B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 1
        jne    .cc.L0.1B.out
   .cc.L0.1B:

  $ifndef _SSEX
   .cc.push.fild.fstp_st0..in:
        SIC_OP.cc.L0.1B.push.fild.fstp_st0 .static.FSTP.ST0
   .cc.push.fild.fstp_st0..out:
  $end

   .cc.L0.1B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 2
        jne    .cc.L0.2B.out
   .cc.L0.2B:

  $ifndef _SSEX
   .cc.fld.fstp_st0..in:
        SIC_OP.cc.L0.2B.fld.fstp_st0 .static.FSTP.ST0
   .cc.fld.fstp_st0..out:
  $end

  $ifndef _SSEX
   .cc.fst_rax..in:
        SIC_OP.cc.L0.2B.fst_rax .static.FSTP.ST0
   .cc.fst_rax..out:
  $end

  $ifndef _SSEX
   .cc.fst_rcx..in:
        SIC_OP.cc.L0.2B.fst_rcx .static.FSTP.ST0
   .cc.fst_rcx..out:
  $end

  $ifndef _SSEX
   .cc.fst_rdx..in:
        SIC_OP.cc.L0.2B.fst_rdx .static.FSTP.ST0
   .cc.fst_rdx..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.2B.fild_rsp_int
  {
   .cc.fild_rsp_int.in:
;       cmp     ebx, 2
;       jne    .cc.fild_rsp_int.out
        ; ----------------------------------------------------------------------
        ; 9 BYTES -> 2 BYTES
        ; ----------------------------------------------------------------------
        ;>  FF30     PUSH QWORD [RAX] |   DF28     FILD QWORD [RAX]
        ;   DF2C24   FILD QWORD [RSP] |
        ; 4883C4 08  ADD  RSP, 08     |
        ; ----------------------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.fild_rsp_int.out
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], dword 0x2CDF30FF
        jne    .cc.fild_rsp_int.out
        cmp     [rdi + 2], dword 0x48242CDF
        jne    .cc.fild_rsp_int.out
        cmp     [rdi + 5], dword 0x08C48348
        jne    .cc.fild_rsp_int.out
        ; ----------------------------------------------------------------------
        mov     [rdi + 0], word 0x28DF
;       mov     [.esi], 9
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.fild_rsp_int.out:
  }
   .cc.fild_rsp_int..in:
        SIC_OP.cc.L2.2B.fild_rsp_int
   .cc.fild_rsp_int..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.2B.c22 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c22.in:
;       cmp     ebx, 2
;       jne    .cc.c22.out
        ; ----------------------------------------------------------------------
        ; 8 BYTES -> 6 BYTES
        ; ----------------------------------------------------------------------
        ;>  DD11     FST  QWORD [RCX] |   DD19     FSTP QWORD [RCX]
        ; 4883C4 AA  ADD  RSP, AA     | 4883C4 AA  ADD  RSP, AA
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; rcx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c22.out
    else
        jl     .cc.c22.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], dword 0x834811DD
        jne    .cc.c22.out
        cmp     [rdi + 3], word 0xC483
        jne    .cc.c22.out
        cmp     [rdi + 6], word 0xD8DD
        jne    .cc.c22.out
        ; ----------------------------------------------------------------------
        mov     [rdi + 0], word 0x19DD
;       mov     [.esi], 8
        mov     [.edi], 6
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.c22.out:
  }
   .cc.c22..in:
        SIC_OP.cc.L2.2B.c22 .static.FSTP.ST0
   .cc.c22..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L2.2B.ffree static.FREE.ST0
  {
    if ~ static.FREE.ST0 in <0,1>
        oops
    end if

   .cc.ffree.in:
;       cmp     ebx, 2
;       jne    .cc.ffree.out
        ; ----------------------------------------------------------------------
        ; 2 BYTES -> 0 BYTES
        ; ----------------------------------------------------------------------
        ;> DD C0  FFREE ST0
        ; ----------------------------------------------------------------------
        mov     [.esi], 2
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.ffree.out
    else
        jl     .cc.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], word 0xC0DD
        jne    .cc.ffree.out
        ; ----------------------------------------------------------------------
;       mov     [.esi], 2
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.ffree.out:
  }
   .cc.ffree..in:
        SIC_OP.cc.L2.2B.ffree .static.FREE.ST0
   .cc.ffree..out:
  $end

   .cc.L0.2B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 3
        jne    .cc.L0.3B.out
   .cc.L0.3B:

  $ifndef _SSEX
  macro SIC_OP.cc.L2.3B.c23 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c23.in:
;       cmp     ebx, 3
;       jne    .cc.c23.out
        ; ----------------------------------------------------------------------
        ; 9 BYTES -> 7 BYTES
        ; ----------------------------------------------------------------------
        ;>  DD55 FF  FST  QWORD [RBP-FF] |   DD5D FF  FSTP QWORD [RBP-FF]
        ; 4883C4 AA  ADD  RSP, AA        | 4883C4 AA  ADD  RSP, AA
        ;   DDD8     FSTP ST0            |
        ; ----------------------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; rcx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c23.out
    else
        jl     .cc.c23.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], word 0x55DD
        jne    .cc.c23.out
        cmp     [rdi + 3], byte 0x48
        jne    .cc.c23.out
        cmp     [rdi + 4], word 0xC483
        jne    .cc.c23.out
        cmp     [rdi + 7], word 0xD8DD
        jne    .cc.c23.out
        ; ----------------------------------------------------------------------
        mov     [rdi + 1], byte 0x5D
;       mov     [.esi], 9
        mov     [.edi], 7
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.c23.out:
  }
   .cc.c23..in:
        SIC_OP.cc.L2.3B.c23 .static.FSTP.ST0
   .cc.c23..out:
  $end

   .cc.L0.3B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 4
        jne    .cc.L0.4B.out
   .cc.L0.4B:

  $ifdef _SSEX
  macro SIC_OP.cc.L2.4B.xmm0.ffree static.FREE.ST0
  {
    if ~ static.FREE.ST0 in <0,1>
        oops
    end if

   .cc.4B.xmm0.ffree.in:
;       cmp     ebx, 4
;       jne    .cc.4B.xmm0.ffree.out
        ; ----------------------------------------------------------------------
        ; 6 BYTES -> 0 BYTES
        ; ----------------------------------------------------------------------
        ;>?F2 0F 10 00  MOVSD XMM0, QWORD [RAX]
        ; ?F2 0F 10 01  MOVSD XMM0, QWORD [RCX]
        ; ?F2 0F 10 02  MOVSD XMM0, QWORD [RDX]
        ;  DD C0        FFREE ST0
        ; ----------------------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.4B.xmm0.ffree.out
    else
        jl     .cc.4B.xmm0.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], dword 0x00100FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [rdi + 0], dword 0x01100FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [rdi + 0], dword 0x02100FF2
        je     .cc.4B.xmm0.ffree.main
        jmp    .cc.4B.xmm0.ffree.out
   .cc.4B.xmm0.ffree.main:
        cmp     [rdi + 4], word 0xC0DD
        jne    .cc.4B.xmm0.ffree.out
        ; ----------------------------------------------------------------------
;       mov     [.esi], 6
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.4B.xmm0.ffree.out:
  }
   .cc.4B.xmm0.ffree..in:
        SIC_OP.cc.L2.4B.xmm0.ffree .static.FREE.ST0
   .cc.4B.xmm0.ffree..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L2.4B.xmm0.rspB.ffree static.FREE.ST0
  {
    if ~ static.FREE.ST0 in <0,1>
        oops
    end if

   .cc.4B.xmm0.rspB.ffree.in:
;       cmp     ebx, 4
;       jne    .cc.4B.xmm0.rspB.ffree.out
        ; ----------------------------------------------------------------------
        ; 10 BYTES -> 4 BYTES
        ; ----------------------------------------------------------------------
        ;>?F2 0F 10 00  MOVSD XMM0, QWORD [RAX]
        ; ?F2 0F 10 01  MOVSD XMM0, QWORD [RCX]
        ; ?F2 0F 10 02  MOVSD XMM0, QWORD [RDX]
        ;  48 83 C4 FF  ADD   RSP, FF
        ;  DD C0        FFREE ST0
        ; ----------------------------------------------------------------------
        ;> 48 83 C4 FF  ADD   RSP, FF
        ; ----------------------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.4B.xmm0.rspB.ffree.out
    else
        jl     .cc.4B.xmm0.rspB.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], dword 0x00100FF2
        je     .cc.4B.xmm0.rspB.ffree.main
        cmp     [rdi + 0], dword 0x01100FF2
        je     .cc.4B.xmm0.rspB.ffree.main
        cmp     [rdi + 0], dword 0x02100FF2
        je     .cc.4B.xmm0.rspB.ffree.main
        jmp    .cc.4B.xmm0.rspB.ffree.out
   .cc.4B.xmm0.rspB.ffree.main:
        cmp     [rdi + 4], byte 0x48
        jne    .cc.4B.xmm0.rspB.ffree.out
        cmp     [rdi + 5], word 0xC483
        jne    .cc.4B.xmm0.rspB.ffree.out
        cmp     [rdi + 8], word 0xC0DD
        jne    .cc.4B.xmm0.rspB.ffree.out
        ; ----------------------------------------------------------------------
        mov     eax, [rdi + 4]
        mov     [rdi + 0], eax
;       mov     [.esi], 10
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.4B.xmm0.rspB.ffree.out:
  }
   .cc.4B.xmm0.rspB.ffree..in:
        SIC_OP.cc.L2.4B.xmm0.rspB.ffree .static.FREE.ST0
   .cc.4B.xmm0.rspB.ffree..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.4B.c21 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c21.in:
;       cmp     ebx, 4
;       jne    .cc.c21.out
        ; ----------------------------------------------------------------------
        ; 12 BYTES -> 10 BYTES
        ; ----------------------------------------------------------------------
        ;>4883C4 CC  ADD  RSP, CC     |   DD19     FSTP QWORD [RCX]
        ;   DD11     FST  QWORD [RCX] | 4883C4 CC  ADD  RSP, CC
        ; 4883C4 AA  ADD  RSP, AA     | 4883C4 AA  ADD  RSP, AA
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; rcx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c21.out
    else
        jl     .cc.c21.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 00], byte 0x48
        jne    .cc.c21.out
        cmp     [rdi + 01], word 0xC483
        jne    .cc.c21.out
        cmp     [rdi + 04], dword 0x834811DD
        jne    .cc.c21.out
        cmp     [rdi + 07], word 0xC483
        jne    .cc.c21.out
        cmp     [rdi + 10], word 0xD8DD
        jne    .cc.c21.out
        ; ----------------------------------------------------------------------
        mov     dl, byte [rdi + 3]              ;  dl = CC
        mov     dh, byte [rdi + 9]              ;  dh = AA
        mov     [rdi + 0], word 0x19DD
        mov     [rdi + 2], dword 0x00C48348
        mov     [rdi + 5], dl
        mov     [rdi + 6], dword 0x00C48348
        mov     [rdi + 9], dh
;       mov     [.esi], 12
        mov     [.edi], 10
       .instr.shift.back 8                      ; instruction shift back
        jmp    .cc.momem
   .cc.c21.out:
  }
   .cc.c21..in:
       SIC_OP.cc.L2.4B.c21 .static.FSTP.ST0
   .cc.c21..out:
  $end

  $ifndef _SSEX
   .cc.add_rsp.fstp_st0..in:
        SIC_OP.cc.L0.4B.add_rsp.fstp_st0 .static.FSTP.ST0
   .cc.add_rsp.fstp_st0..out:
  $end

  $ifndef _SSEX
   .cc.add_rsp.fpu..in:
        SIC_OP.cc.L0.4B.add_rsp.fpu
   .cc.add_rsp.fpu..out:
  $end

  $ifdef SIC_OP.RSP_PUSH_POP
   .cc.sub_rsp_8..in:
        SIC_OP.cc.L0.4B.sub_rsp_8
   .cc.sub_rsp_8..out:
  $end

  $ifdef SIC_OP.RSP_PUSH_POP
   .cc.add_rsp_8..in:
        SIC_OP.cc.L0.4B.add_rsp_8
   .cc.add_rsp_8..out:
  $end

   .cc.L0.4B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 5
        jne    .cc.L0.5B.out
   .cc.L0.5B:

  $ifdef _SSEX
  macro SIC_OP.cc.L2.5B.xmm0.ffree static.FREE.ST0
  {
    if ~ static.FREE.ST0 in <0,1>
        oops
    end if

   .cc.5B.xmm0.ffree.in:
;       cmp     ebx, 5
;       jne    .cc.5B.xmm0.ffree.out
        ; ----------------------------------------------------------------------
        ; 7 BYTES -> 0 BYTES
        ; ----------------------------------------------------------------------
        ;>?66 48 0F 6E C0  MOVQ     XMM0, RAX
        ; ?66 49 0F 6E C2  MOVQ     XMM0, R10
        ; ?F2 48 0F 2A C0  CVTSI2SD XMM0, RAX
        ; ?F2 48 0F 2A C1  CVTSI2SD XMM0, RCX
        ; ?F2 48 0F 2A C2  CVTSI2SD XMM0, RDX
        ; ?F2 48 0F 2A 01  CVTSI2SD XMM0, QWORD [RCX]
        ;  DD C0           FFREE    ST0
        ; ----------------------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.5B.xmm0.ffree.out
    else
        jl     .cc.5B.xmm0.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], dword 0x6E0F4866
        je     .cc.5B.xmm0.ffree.LA
        cmp     [rdi + 0], dword 0x6E0F4966
        je     .cc.5B.xmm0.ffree.LB
        cmp     [rdi + 0], dword 0x2A0F48F2
        je     .cc.5B.xmm0.ffree.LZ
        jmp    .cc.5B.xmm0.ffree.out
   .cc.5B.xmm0.ffree.LA:
        cmp     [rdi + 4], byte 0xC0
        je     .cc.5B.xmm0.ffree.main
        jmp    .cc.5B.xmm0.ffree.out
   .cc.5B.xmm0.ffree.LB:
        cmp     [rdi + 4], byte 0xC2
        je     .cc.5B.xmm0.ffree.main
        jmp    .cc.5B.xmm0.ffree.out
   .cc.5B.xmm0.ffree.LZ:
        cmp     [rdi + 4], byte 0xC0
        je     .cc.5B.xmm0.ffree.main
        cmp     [rdi + 4], byte 0xC1
        je     .cc.5B.xmm0.ffree.main
        cmp     [rdi + 4], byte 0xC2
        je     .cc.5B.xmm0.ffree.main
        cmp     [rdi + 4], byte 0x01
        je     .cc.5B.xmm0.ffree.main
        jmp    .cc.5B.xmm0.ffree.out
   .cc.5B.xmm0.ffree.main:
        cmp     [rdi + 5], word 0xC0DD
        jne    .cc.5B.xmm0.ffree.out
        ; ----------------------------------------------------------------------
;       mov     [.esi], 7
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.5B.xmm0.ffree.out:
  }
   .cc.5B.xmm0.ffree..in:
        SIC_OP.cc.L2.5B.xmm0.ffree .static.FREE.ST0
   .cc.5B.xmm0.ffree..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L2.5B.xmm0.rspB.ffree static.FREE.ST0
  {
    if ~ static.FREE.ST0 in <0,1>
        oops
    end if

   .cc.5B.xmm0.rspB.ffree.in:
;       cmp     ebx, 5
;       jne    .cc.5B.xmm0.rspB.ffree.out
        ; ----------------------------------------------------------------------
        ; 11 BYTES -> 4 BYTES
        ; ----------------------------------------------------------------------
        ;>?66 48 0F 6E C0  MOVQ     XMM0, RAX
        ; ?66 49 0F 6E C2  MOVQ     XMM0, R10
        ; ?F2 48 0F 2A C0  CVTSI2SD XMM0, RAX
        ; ?F2 48 0F 2A C1  CVTSI2SD XMM0, RCX
        ; ?F2 48 0F 2A C2  CVTSI2SD XMM0, RDX
        ; ?F2 48 0F 2A 01  CVTSI2SD XMM0, QWORD [RCX]
        ;  48 83 C4 FF     ADD      RSP, FF
        ;  DD C0           FFREE    ST0
        ; ----------------------------------------------------------------------
        ;> 48 83 C4 FF     ADD      RSP, FF
        ; ----------------------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.5B.xmm0.rspB.ffree.out
    else
        jl     .cc.5B.xmm0.rspB.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [rdi + 0], dword 0x6E0F4866
        je     .cc.5B.xmm0.rspB.ffree.LA
        cmp     [rdi + 0], dword 0x6E0F4966
        je     .cc.5B.xmm0.rspB.ffree.LB
        cmp     [rdi + 0], dword 0x2A0F48F2
        je     .cc.5B.xmm0.rspB.ffree.LZ
        jmp    .cc.5B.xmm0.rspB.ffree.out
   .cc.5B.xmm0.rspB.ffree.LA:
        cmp     [rdi + 4], byte 0xC0
        je     .cc.5B.xmm0.rspB.ffree.main
        jmp    .cc.5B.xmm0.rspB.ffree.out
   .cc.5B.xmm0.rspB.ffree.LB:
        cmp     [rdi + 4], byte 0xC2
        je     .cc.5B.xmm0.rspB.ffree.main
        jmp    .cc.5B.xmm0.rspB.ffree.out
   .cc.5B.xmm0.rspB.ffree.LZ:
        cmp     [rdi + 4], byte 0xC0
        je     .cc.5B.xmm0.rspB.ffree.main
        cmp     [rdi + 4], byte 0xC1
        je     .cc.5B.xmm0.rspB.ffree.main
        cmp     [rdi + 4], byte 0xC2
        je     .cc.5B.xmm0.rspB.ffree.main
        cmp     [rdi + 4], byte 0x01
        je     .cc.5B.xmm0.rspB.ffree.main
        jmp    .cc.5B.xmm0.rspB.ffree.out
   .cc.5B.xmm0.rspB.ffree.main:
        cmp     [rdi + 5], byte 0x48
        jne    .cc.5B.xmm0.rspB.ffree.out
        cmp     [rdi + 6], word 0xC483
        jne    .cc.5B.xmm0.rspB.ffree.out
        cmp     [rdi + 9], word 0xC0DD
        jne    .cc.5B.xmm0.rspB.ffree.out
        ; ----------------------------------------------------------------------
        mov     eax, [rdi + 5]
        mov     [rdi + 0], eax
;       mov     [.esi], 11
        mov     [.edi], 4
       .instr.shift.back 4                      ; instruction shift back
        jmp    .cc.momem
   .cc.5B.xmm0.rspB.ffree.out:
  }
   .cc.5B.xmm0.rspB.ffree..in:
        SIC_OP.cc.L2.5B.xmm0.rspB.ffree .static.FREE.ST0
   .cc.5B.xmm0.rspB.ffree..out:
  $end

   .cc.L0.5B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.7B:

   .cc.L0.7B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.10B:

   .cc.L0.10B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
   .cc.momem:
        add     rdi, [.edi]                     ; rdi = destination memory
        cmp     rdi, rsi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     rdi, [.xdi]
        add     rdi, [.edi]
        mov     rax, [.esi]
        sub     rax, [.edi]
        sub     [.ezx], rax
        sub     [.ecx], rax
        sub     [.rbx], rax
        jle    .cc.result
        mov     rax, [.misize]
        jmp    .cc.next.rdi

   .cc.next:
        mov     rax, [.cisize]
   .cc.next.rdi:
        add     rdi, rax                        ; rdi = next instruction
        ;
        mov     rcx, rdi
        sub     rcx, [.eee]
        mov     [.zzz], rcx
        ;
        sub     [.rbx], rax
;       cmp     [.rbx], 0
        jg     .cc.root

   .cc.result:
        mov     rax, [.ezx]

   .cc.return:
        pop     rdi rsi rbx
        ret

        ; -> [.esi] - initial bytes
        ; <- rcx    - bytes to copy
        ; <- rsi    - source memory
   .cc.size:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.L3, code, csize, rcode

       .static.FSTP.ST0 EQU 1
       .static.FREE.ST0 EQU 1

    locals
       .rbx     dq ?
       .edi     dq ?
       .eee     dq ?
       .zzz     dq ?
       .esi     dq ?
       .ezx     dq ?
       .ecx     dq ?
       .xcx     dq ?
       .xdi     dq ?
       .xsi     dq ?
       .misize  dq ?
       .cisize  dq ?                            ; current instruction size
       .pisize  dq ?                            ; previous instruction size
    endl

    ; be sure actual code size >= a, goto b otherwise
    macro .bound a, b {
        cmp     [.zzz], a
        jl      b
    }

    macro .instr.shift.back v, p {
      if v eq
        push    [.pisize]
        pop     [.misize]
        neg     [.misize]
        inc     [.misize]                       ; [.pisize] bytes shift back
      else
        mov     [.misize], 1-(v)                ; v bytes shift back
       if p eq 1
        push    rdx
        mov     rdx, [.pisize]
        sub     [.misize], rdx
        pop     rdx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

        mov     [code], rcx
        mov     [csize], rdx
        mov     [rcode], r8
;       mov     [], r9

        push    rbx rsi rdi

        mov     rax, [csize]
        test    rax, rax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], rax                     ; save initial code size
        mov     [.rbx], rax                     ; [.rbx] = initial code size
        mov     rdi, [code]                     ; rdi = code offset
        mov     [.eee], rdi                     ; save code offset
        mov     [.zzz], 0                       ; scanned bytes
        mov     [.ecx], rdi
        add     [.ecx], rax                     ; [.ecx] = code end pointer

        mov     [.cisize], 0
        mov     [.pisize], 0

   .cc.root:
        mov     rax, [.cisize]
        mov     [.pisize], rax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; rax = current instruction size
        and     rdx, IDA_INVALID                ; rdx = instruction flags
        jnz    .cc.result
        test    rax, rax
        jz     .cc.result
        mov     [.cisize], rax
        mov     rbx, rax                        ; rbx = current instruction size

   .cc.main:
        mov     [.misize], 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.4B_7B?:
        cmp     ebx, 4
        je     .cc.L0.4B_7B
        cmp     ebx, 7
        jne    .cc.L0.4B_7B.out

   .cc.L0.4B_7B:

   .cc.add_rsp..in:
        SIC_OP.cc.L0.4B_7B.add_rsp
   .cc.add_rsp..out:

   .cc.L0.4B_7B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 1
        jne    .cc.L0.1B.out
   .cc.L0.1B:

  $ifndef _SSEX
   .cc.push.fild.fstp_st0..in:
        SIC_OP.cc.L0.1B.push.fild.fstp_st0 .static.FSTP.ST0
   .cc.push.fild.fstp_st0..out:
  $end

   .cc.L0.1B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 2
        jne    .cc.L0.2B.out
   .cc.L0.2B:

  $ifndef _SSEX
   .cc.fld.fstp_st0..in:
        SIC_OP.cc.L0.2B.fld.fstp_st0 .static.FSTP.ST0
   .cc.fld.fstp_st0..out:
  $end

  $ifndef _SSEX
   .cc.fst_rax..in:
        SIC_OP.cc.L0.2B.fst_rax .static.FSTP.ST0
   .cc.fst_rax..out:
  $end

  $ifndef _SSEX
   .cc.fst_rcx..in:
        SIC_OP.cc.L0.2B.fst_rcx .static.FSTP.ST0
   .cc.fst_rcx..out:
  $end

  $ifndef _SSEX
   .cc.fst_rdx..in:
        SIC_OP.cc.L0.2B.fst_rdx .static.FSTP.ST0
   .cc.fst_rdx..out:
  $end

  $ifndef _SSEX
   .cc.fild_rsp_int..in:
        SIC_OP.cc.L2.2B.fild_rsp_int
   .cc.fild_rsp_int..out:
  $end

  $ifndef _SSEX
   .cc.c22..in:
        SIC_OP.cc.L2.2B.c22 .static.FSTP.ST0
   .cc.c22..out:
  $end

  $ifdef _SSEX
   .cc.free..in:
        SIC_OP.cc.L2.2B.ffree .static.FREE.ST0
   .cc.free..out:
  $end

   .cc.L0.2B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 3
        jne    .cc.L0.3B.out
   .cc.L0.3B:

  $ifndef _SSEX
   .cc.c23..in:
        SIC_OP.cc.L2.3B.c23 .static.FSTP.ST0
   .cc.c23..out:
  $end

   .cc.L0.3B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 4
        jne    .cc.L0.4B.out
   .cc.L0.4B:

  $ifdef _SSEX
   .cc.4B.xmm0.free..in:
        SIC_OP.cc.L2.4B.xmm0.ffree .static.FREE.ST0
   .cc.4B.xmm0.free..out:
  $end

  $ifdef _SSEX
   .cc.4B.xmm0.rspB.free..in:
        SIC_OP.cc.L2.4B.xmm0.rspB.ffree .static.FREE.ST0
   .cc.4B.xmm0.rspB.free..out:
  $end

  $ifndef _SSEX
   .cc.c21..in:
        SIC_OP.cc.L2.4B.c21 .static.FSTP.ST0
   .cc.c21..out:
  $end

  $ifndef _SSEX
   .cc.add_rsp.fstp_st0..in:
        SIC_OP.cc.L0.4B.add_rsp.fstp_st0 .static.FSTP.ST0
   .cc.add_rsp.fstp_st0..out:
  $end

  $ifndef _SSEX
   .cc.add_rsp.fpu..in:
        SIC_OP.cc.L0.4B.add_rsp.fpu
   .cc.add_rsp.fpu..out:
  $end

  $ifdef SIC_OP.RSP_PUSH_POP
   .cc.sub_rsp_8..in:
        SIC_OP.cc.L0.4B.sub_rsp_8
   .cc.sub_rsp_8..out:
  $end

  $ifdef SIC_OP.RSP_PUSH_POP
   .cc.add_rsp_8..in:
        SIC_OP.cc.L0.4B.add_rsp_8
   .cc.add_rsp_8..out:
  $end

   .cc.L0.4B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 5
        jne    .cc.L0.5B.out
   .cc.L0.5B:

  $ifdef _SSEX
   .cc.5B.xmm0.free..in:
        SIC_OP.cc.L2.5B.xmm0.ffree .static.FREE.ST0
   .cc.5B.xmm0.free..out:
  $end

  $ifdef _SSEX
   .cc.5B.xmm0.rspB.free..in:
        SIC_OP.cc.L2.5B.xmm0.rspB.ffree .static.FREE.ST0
   .cc.5B.xmm0.rspB.free..out:
  $end

   .cc.L0.5B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.7B:

   .cc.L0.7B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.10B:

   .cc.L0.10B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
   .cc.momem:
        add     rdi, [.edi]                     ; rdi = destination memory
        cmp     rdi, rsi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     rdi, [.xdi]
        add     rdi, [.edi]
        mov     rax, [.esi]
        sub     rax, [.edi]
        sub     [.ezx], rax
        sub     [.ecx], rax
        sub     [.rbx], rax
        jle    .cc.result
        mov     rax, [.misize]
        jmp    .cc.next.rdi

   .cc.next:
        mov     rax, [.cisize]
   .cc.next.rdi:
        add     rdi, rax                        ; rdi = next instruction
        ;
        mov     rcx, rdi
        sub     rcx, [.eee]
        mov     [.zzz], rcx
        ;
        sub     [.rbx], rax
;       cmp     [.rbx], 0
        jg     .cc.root

   .cc.result:
        mov     rax, [.ezx]

   .cc.return:
        pop     rdi rsi rbx
        ret

        ; -> [.esi] - initial bytes
        ; <- rcx    - bytes to copy
        ; <- rsi    - source memory
   .cc.size:
        lea     rcx, [rdi - 1]
        mov     [.xdi], rcx
        mov     rsi, rdi
        add     rsi, [.esi]                     ; rsi = source memory
        mov     rcx, [.ecx]
        sub     rcx, rsi                        ; rcx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------
