
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

DEFINE SIC_OP.ESP_PUSH_POP  TRUE ; FALSE ;
DEFINE SIC_OP.LOAD_CONST   FALSE ;  TRUE ;
DEFINE SIC_OP.FXCH         FALSE ;  TRUE ;

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.nop, code, csize

    locals
       .edi     dd ?
       .eee     dd ?
       .zzz     dd ?
       .esi     dd ?
       .ezx     dd ?
       .ecx     dd ?
       .xcx     dd ?
       .xdi     dd ?
       .xsi     dd ?
       .misize  dd ?
       .cisize  dd ?                            ; current instruction size
       .pisize  dd ?                            ; previous instruction size
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
        push    edx
        mov     edx, [.pisize]
        sub     [.misize], edx
        pop     edx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

;       mov     [code], rcx
;       mov     [csize], rdx
;       mov     [], r8
;       mov     [], r9

        push    ebx esi edi

        mov     eax, [csize]
        test    eax, eax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], eax                     ; save initial code size
        mov     ebx, eax                        ; ebx = initial code size
        mov     edi, [code]                     ; edi = code offset
        mov     [.eee], edi                     ; save code offset
        mov     [.zzz], 0                       ; scanned bytes
        mov     [.ecx], edi
        add     [.ecx], eax                     ; [.ecx] = code end pointer

        mov     [.cisize], 0
        mov     [.pisize], 0

   .cc.root:
        mov     eax, [.cisize]
        mov     [.pisize], eax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; eax = current instruction size
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        test    eax, eax
        jz     .cc.result
        mov     [.cisize], eax

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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0x90
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
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
   .cc.momem:
        add     edi, [.edi]                     ; edi = destination memory
        cmp     edi, esi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     edi, [.xdi]
        add     edi, [.edi]
        mov     ecx, [.esi]
        sub     ecx, [.edi]
        sub     [.ezx], ecx
        sub     [.ecx], ecx
        sub     ebx, ecx
        jle    .cc.result
        mov     eax, [.misize]
        jmp    .cc.next.edi

   .cc.next:
        mov     eax, [.cisize]
   .cc.next.edi:
        add     edi, eax                        ; edi = next instruction
        ;
        mov     ecx, edi
        sub     ecx, [.eee]
        mov     [.zzz], ecx
        ;
        sub     ebx, eax
;       cmp     ebx, 0
        jg     .cc.root

   .cc.result:
        mov     eax, [.ezx]

   .cc.return:
        pop     edi esi ebx
        ret

        ; -> [.esi] - initial bytes
        ; <- ecx    - bytes to copy
        ; <- esi    - source memory
   .cc.size:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.L0, sic, csize, rcode, sop

       .static.FSTP.ST0 EQU 1
       .static.FREE.ST0 EQU 1

    locals
       .byte    db ?
       .ebx     dd ?
       .edi     dd ?
       .esi     dd ?
       .ezx     dd ?
       .ecx     dd ?
       .xcx     dd ?
       .xdi     dd ?
       .xsi     dd ?
       .misize  dd ?
       .cisize  dd ?                            ; current instruction size
       .pisize  dd ?                            ; previous instruction size
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
        push    edx
        mov     edx, [.pisize]
        sub     [.misize], edx
        pop     edx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

;       mov     [sic], rcx
;       mov     [csize], rdx
;       mov     [rcode], r8
;       mov     [sop], r9

        push    ebx esi edi

        mov     eax, [csize]
        test    eax, eax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], eax                     ; save initial code size
        mov     [.ebx], eax                     ; [.ebx] = initial code size
        mov     esi, [sic]                      ; esi = T_sic_data structure offset
        mov     edi, [esi + T_sic_data.code]    ; edi = code segment entry offset
        mov     [.ecx], edi
        add     [.ecx], eax                     ; [.ecx] = code end pointer

        xor     eax, eax
        mov     [.cisize], eax
        mov     [.pisize], eax

   .cc.root:
        mov     eax, [.cisize]
        mov     [.pisize], eax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; eax = current instruction size
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        test    eax, eax
        jz     .cc.result
        mov     [.cisize], eax
        mov     ebx, eax                        ; ebx = current instruction size

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
        cmp     [edi + 00], dword 0x4C110FF2
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [edi + 04], dword 0x0FF20824
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [edi + 08], dword 0xF2240411
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [edi + 12], dword 0x2404100F
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [edi + 16], dword 0x4C100FF2
        jne    .cc.xmm2.xmm2.nop.out
        cmp     [edi + 19], dword 0x9008244C
        jne    .cc.xmm2.xmm2.nop.out
        ; ---------------------------------------------------------
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
        cmp     [edi + 00], dword 0x04110FF2
        jne    .cc.xmm.xmm2.nop.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.xmm.xmm2.nop.out
        cmp     [edi + 08], dword 0x0FF22404
        jne    .cc.xmm.xmm2.nop.out
        cmp     [edi + 12], dword 0x08244C10
        jne    .cc.xmm.xmm2.nop.out
        cmp     [edi + 16], byte 0x90
        jne    .cc.xmm.xmm2.nop.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x4C100FF2
        mov     [edi + 04], word 0x0824
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
        cmp     [edi + 00], dword 0x04110FF2
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [edi + 08], dword 0xF2902404
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [edi + 12], dword 0x2444110F
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [edi + 16], dword 0x2444DDC0
        jne    .cc.xmm.xmm.nop.fld.out
        cmp     [edi + 20], byte 0xC0
        jne    .cc.xmm.xmm.nop.fld.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x04110FF2
        mov     [edi + 04], dword 0x2404DD24
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
        cmp     [edi + 00], dword 0x04110FF2
        jne    .cc.xmm.xmm.nop.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.xmm.xmm.nop.out
        cmp     [edi + 07], dword 0x90240410
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
        cmp     [edi + 00], dword 0x04100FF2
        jne    .cc.xmm.nop.fld.out
        cmp     [edi + 04], dword 0x0FF29024
        jne    .cc.xmm.nop.fld.out
        cmp     [edi + 08], dword 0xC0244411
        jne    .cc.xmm.nop.fld.out
        cmp     [edi + 12], dword 0xC02444DD
        jne    .cc.xmm.nop.fld.out
        ; ---------------------------------------------------------
        mov     [edi + 00], word 0x04DD
        mov     [edi + 02], byte 0x24
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
        cmp     [edi + 00], dword 0x04100FF2
        jne    .cc.xmm.nop.out
        cmp     [edi + 04], word 0x9024
        jne    .cc.xmm.nop.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x04100FF2
        mov     [edi + 04], byte 0x24
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
        cmp     [edi + 00], dword 0x04100FF2
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 08], dword 0x9008244C
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 12], dword 0x44110FF2
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 16], dword 0x44DDC024
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 20], dword 0x0FF2C024
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 24], dword 0xC0244C11
        jne    .cc.xmm2.nop.fld.01.out
        cmp     [edi + 28], dword 0xC02444DD
        jne    .cc.xmm2.nop.fld.01.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x002404DD
        mov     [edi + 03], dword 0x082444DD
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
  macro SIC_OP.cc.L0.5B0.xmm2.nop.fld2r
  {
   .cc.xmm2.nop.fld2r.in:
        cmp     ebx, 5
        jne    .cc.xmm2.nop.fld2r.out
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
        jl     .cc.xmm2.nop.fld2r.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0x04100FF2
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 08], dword 0x9008244C
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 12], dword 0x4C110FF2
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 16], dword 0x44DDC024
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 20], dword 0x0FF2C024
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 24], dword 0xC0244411
        jne    .cc.xmm2.nop.fld2r.out
        cmp     [edi + 28], dword 0xC02444DD
        jne    .cc.xmm2.nop.fld2r.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x082444DD
        mov     [edi + 03], dword 0x2404DD08
        ; ---------------------------------------------------------
;       mov     [.esi], 32
        mov     [.edi], 7
       .instr.shift.back 7, 1                   ; instruction shift back
        jmp    .cc.momem
   .cc.xmm2.nop.fld2r.out:
  }
   .cc.xmm2.nop.fld2r..in:
        SIC_OP.cc.L0.5B0.xmm2.nop.fld2r
   .cc.xmm2.nop.fld2r..out:
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
        cmp     [edi + 00], dword 0x04100FF2
        jne    .cc.xmm2.nop.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.xmm2.nop.out
        cmp     [edi + 08], dword 0x9008244C
        jne    .cc.xmm2.nop.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x04100FF2
        mov     [edi + 04], dword 0x100FF224
        mov     [edi + 07], dword 0x08244C10
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
  macro SIC_OP.cc.L0.3B0.rspB.xsd.nop
  {
   .cc.rspB.xsd.nop.in:
        cmp     ebx, 3
        jne    .cc.rspB.xsd.nop.out
        ; ---------------------------------------------------------
        ; 14 BYTES
        ; ---------------------------------------------------------
        ;> 83 C4 FF            ADD   ESP, FF
        ;  F2 0F 10 4C 24 FF   MOVSD XMM1, QWORD [ESP+FF]
        ; ?F2 0F 58 C1         ADDSD XMM0, XMM1
        ; ?F2 0F 5C C1         SUBSD XMM0, XMM1
        ; ?F2 0F 59 C1         MULSD XMM0, XMM1
        ; ?F2 0F 5E C1         DIVSD XMM0, XMM1
        ;  90                  NOP
        ; ---------------------------------------------------------
        ; 14 BYTES -> 9 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 44 24 FF   ADDSD XMM0, QWORD [ESP+FF]
        ; ?F2 0F 5C 44 24 FF   SUBSD XMM0, QWORD [ESP+FF]
        ; ?F2 0F 59 44 24 FF   MULSD XMM0, QWORD [ESP+FF]
        ; ?F2 0F 5E 44 24 FF   DIVSD XMM0, QWORD [ESP+FF]
        ;  83 C4 FF            ADD   RSP, FF
        ; ---------------------------------------------------------
        ; 14 BYTES -> 12 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 84 24 FF+  ADDSD XMM0, QWORD [ESP+FF+]
        ; ?F2 0F 5C 84 24 FF+  SUBSD XMM0, QWORD [ESP+FF+]
        ; ?F2 0F 59 84 24 FF+  MULSD XMM0, QWORD [ESP+FF+]
        ; ?F2 0F 5E 84 24 FF+  DIVSD XMM0, QWORD [ESP+FF+]
        ;  83 C4 FF            ADD   RSP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 14
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rspB.xsd.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0xC483
        jne    .cc.rspB.xsd.nop.out
        cmp     [edi + 03], dword 0x4C100FF2
        jne    .cc.rspB.xsd.nop.out
        cmp     [edi + 07], byte 0x24
        jne    .cc.rspB.xsd.nop.out
        cmp     [edi + 09], word 0x0FF2
        jne    .cc.rspB.xsd.nop.out
        cmp     [edi + 12], word 0x90C1
        jne    .cc.rspB.xsd.nop.out
        ; ---------------------------------------------------------
        movsx   edx, byte [edi + 02]
        movsx   eax, byte [edi + 08]
        add     edx, eax
        cmp     edx, +127
        jg     .cc.rspB.xsd.nop.D
        cmp     edx, -128
        jl     .cc.rspB.xsd.nop.D
   .cc.rspB.xsd.nop.B:
        ; ---------------------------------------------------------
        ; 14 BYTES -> 9 BYTES
        ; ---------------------------------------------------------
        mov     al, byte [edi + 02]
        mov     ah, byte [edi + 11]
        mov     [edi + 00], word 0x0FF2
        mov     [edi + 02], ah
        mov     [edi + 03], word 0x2444
        mov     [edi + 05], dl
        mov     [edi + 06], word 0xC483
        mov     [edi + 08], al
        ; ---------------------------------------------------------
;       mov     [.esi], 14
        mov     [.edi], 9
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspB.xsd.nop.D:
        ; ---------------------------------------------------------
        ; 14 BYTES -> 12 BYTES
        ; ---------------------------------------------------------
        mov     al, byte [edi + 02]
        mov     ah, byte [edi + 11]
        mov     [edi + 00], word 0x0FF2
        mov     [edi + 02], ah
        mov     [edi + 03], word 0x2484
        mov     [edi + 05], edx
        mov     [edi + 09], word 0xC483
        mov     [edi + 11], al
        ; ---------------------------------------------------------
;       mov     [.esi], 14
        mov     [.edi], 12
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspB.xsd.nop.out:
  }
   .cc.rspB.xsd.nop..in:
        SIC_OP.cc.L0.3B0.rspB.xsd.nop
   .cc.rspB.xsd.nop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.6B0.rspD.xsd.nop
  {
   .cc.rspD.xsd.nop.in:
        cmp     ebx, 6
        jne    .cc.rspD.xsd.nop.out
        ; ---------------------------------------------------------
        ; 17 BYTES
        ; ---------------------------------------------------------
        ;> 81 C4 FF+           ADD   ESP, FF+
        ;  F2 0F 10 4C 24 FF   MOVSD XMM1, QWORD [ESP+FF]
        ; ?F2 0F 58 C1         ADDSD XMM0, XMM1
        ; ?F2 0F 5C C1         SUBSD XMM0, XMM1
        ; ?F2 0F 59 C1         MULSD XMM0, XMM1
        ; ?F2 0F 5E C1         DIVSD XMM0, XMM1
        ;  90                  NOP
        ; ---------------------------------------------------------
        ; 17 BYTES -> 12 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 44 24 FF   ADDSD XMM0, QWORD [ESP+FF]
        ; ?F2 0F 5C 44 24 FF   SUBSD XMM0, QWORD [ESP+FF]
        ; ?F2 0F 59 44 24 FF   MULSD XMM0, QWORD [ESP+FF]
        ; ?F2 0F 5E 44 24 FF   DIVSD XMM0, QWORD [ESP+FF]
        ;  81 C4 FF+           ADD   ESP, FF+
        ; ---------------------------------------------------------
        ; 17 BYTES -> 15 BYTES
        ; ---------------------------------------------------------
        ; ?F2 0F 58 84 24 FF+  ADDSD XMM0, QWORD [ESP+FF+]
        ; ?F2 0F 5C 84 24 FF+  SUBSD XMM0, QWORD [ESP+FF+]
        ; ?F2 0F 59 84 24 FF+  MULSD XMM0, QWORD [ESP+FF+]
        ; ?F2 0F 5E 84 24 FF+  DIVSD XMM0, QWORD [ESP+FF+]
        ;  81 C4 FF+           ADD   ESP, FF+
        ; ---------------------------------------------------------
        mov     [.esi], 17
        call   .cc.size                         ; rcx = bytes to copy
        jl     .cc.rspD.xsd.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0xC481
        jne    .cc.rspD.xsd.nop.out
        cmp     [edi + 06], dword 0x4C100FF2
        jne    .cc.rspD.xsd.nop.out
        cmp     [edi + 10], byte 0x24
        jne    .cc.rspD.xsd.nop.out
        cmp     [edi + 12], word 0x0FF2
        jne    .cc.rspD.xsd.nop.out
        cmp     [edi + 15], word 0x90C1
        jne    .cc.rspD.xsd.nop.out
        ; ---------------------------------------------------------
        mov     edx, dword [edi + 02]
        movsx   eax, byte [edi + 11]
        add     edx, eax
        cmp     edx, +127
        jg     .cc.rspD.xsd.nop.D
        cmp     edx, -128
        jl     .cc.rspD.xsd.nop.D
   .cc.rspD.xsd.nop.B:
        ; ---------------------------------------------------------
        ; 17 BYTES -> 12 BYTES
        ; ---------------------------------------------------------
        push    ebx
        mov     ebx, dword [edi + 02]
        mov     ah, byte [edi + 14]
        mov     [edi + 00], word 0x0FF2
        mov     [edi + 02], ah
        mov     [edi + 03], word 0x2444
        mov     [edi + 05], dl
        mov     [edi + 06], word 0xC481
        mov     [edi + 08], ebx
        pop     ebx
        ; ---------------------------------------------------------
;       mov     [.esi], 17
        mov     [.edi], 12
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspD.xsd.nop.D:
        ; ---------------------------------------------------------
        ; 17 BYTES -> 15 BYTES
        ; ---------------------------------------------------------
        push    ebx
        mov     ebx, dword [edi + 02]
        mov     ah, byte [edi + 14]
        mov     [edi + 00], word 0x0FF2
        mov     [edi + 02], ah
        mov     [edi + 03], word 0x2484
        mov     [edi + 05], edx
        mov     [edi + 09], word 0xC481
        mov     [edi + 11], ebx
        pop     ebx
        ; ---------------------------------------------------------
;       mov     [.esi], 17
        mov     [.edi], 15
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.rspD.xsd.nop.out:
  }
   .cc.rspD.xsd.nop..in:
        SIC_OP.cc.L0.6B0.rspD.xsd.nop
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
        cmp     [edi + 00], dword 0x4C100FF2
        jne    .cc.xmm.xsd.nop.out
        cmp     [edi + 04], byte 0x24
        jne    .cc.xmm.xsd.nop.out
        cmp     [edi + 06], word 0x0FF2
        jne    .cc.xmm.xsd.nop.out
        cmp     [edi + 09], word 0x90C1
        jne    .cc.xmm.xsd.nop.out
        ; ---------------------------------------------------------
        mov     al, byte [edi + 05]
        mov     ah, byte [edi + 08]
        mov     [edi + 00], word 0x0FF2
        mov     [edi + 02], ah
        mov     [edi + 03], word 0x2444
        mov     [edi + 05], al
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
  macro SIC_OP.cc.L0.5B0.100
  {
        cmp     ebx, 5
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        ;> B9 AAAAAAAA           MOV  ECX, AAAAAAAA
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .cc.100.out
        cmp     [edi + 05], dword 0xFF0471FF
        jne    .cc.100.out
        cmp     [edi + 09], byte 0x31
        jne    .cc.100.out
        cmp     [edi + 10], byte 0xB9
        je     .cc.100.02
   .cc.100..01:
        ; -------------------------------------------------------------------------
        ; 16 BYTES
        ; -------------------------------------------------------------------------
        ;> B9 AAAAAAAA           MOV   ECX, AAAAAAAA
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  F2 0F 10 04 24        MOVSD XMM0, QWORD [ESP]
        ;  90                    NOP
        ; -------------------------------------------------------------------------
        ; 16 BYTES -> 11 BYTES
        ; -------------------------------------------------------------------------
        ;> F2 0F 10 05 AAAAAAAA  MOVSD XMM0, QWORD [AAAAAAAA]
        ;  83 C4 F8              ADD   ESP, -08
        ; -------------------------------------------------------------------------
        cmp     [edi + 10], dword 0x04100FF2
        jne    .cc.100.out
        cmp     [edi + 14], word 0x9024
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 16
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     eax, [edi + 01]
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], eax
        mov     [edi + 08], word 0xC483
        mov     [edi + 10], byte 0xF8
;       mov     [.esi], 16
        mov     [.edi], 11
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.02:
        ; -------------------------------------------------------------------------
        ;> B9 BBBBBBBB           MOV  ECX, BBBBBBBB
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  B9 AAAAAAAA           MOV  ECX, AAAAAAAA
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [edi + 15], dword 0xFF0471FF
        jne    .cc.100.out
        cmp     [edi + 19], byte 0x31
        jne    .cc.100.out
        cmp     [edi + 20], byte 0xB9
        je     .cc.100.03
   .cc.100..02:
        ; -------------------------------------------------------------------------
        ; 32 BYTES
        ; -------------------------------------------------------------------------
        ;> B9 BBBBBBBB           MOV   ECX, BBBBBBBB
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  B9 AAAAAAAA           MOV   ECX, AAAAAAAA
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  F2 0F 10 04 24        MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08     MOVSD XMM1, QWORD [ESP + 8]
        ;  90                    NOP
        ; -------------------------------------------------------------------------
        ; 32 BYTES -> 19 BYTES
        ; -------------------------------------------------------------------------
        ;> F2 0F 10 05 AAAAAAAA  MOVSD XMM0, QWORD [AAAAAAAA]
        ;  F2 0F 10 0D BBBBBBBB  MOVSD XMM1, [BBBBBBBB]
        ;  83 C4 F0              ADD   ESP, -16
        ; -------------------------------------------------------------------------
        cmp     [edi + 20], dword 0x04100FF2
        jne    .cc.100.out
        cmp     [edi + 24], dword 0x100FF224
        jne    .cc.100.out
        cmp     [edi + 28], word 0x244C
        jne    .cc.100.out
        cmp     [edi + 30], word 0x9008
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 32
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        mov     edx, [edi + 01]
        mov     eax, [edi + 11]
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x0D100FF2
        mov     [edi + 12], edx
        mov     [edi + 16], word 0xC483
        mov     [edi + 18], byte 0xF0
;       mov     [.esi], 32
        mov     [.edi], 19
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.100.03:
        ; -------------------------------------------------------------------------
        ;> B9 CCCCCCCC           MOV  ECX, CCCCCCCC
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  B9 BBBBBBBB           MOV  ECX, BBBBBBBB
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  B9 AAAAAAAA           MOV  ECX, AAAAAAAA
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [edi + 25], dword 0xFF0471FF
        jne    .cc.100.out
        cmp     [edi + 29], byte 0x31
        jne    .cc.100.out
   .cc.100..03:
        ; -------------------------------------------------------------------------
        ; 48 BYTES
        ; -------------------------------------------------------------------------
        ;> B9 CCCCCCCC           MOV   ECX, CCCCCCCC
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  B9 BBBBBBBB           MOV   ECX, BBBBBBBB
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  B9 AAAAAAAA           MOV   ECX, AAAAAAAA
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  F2 0F 10 04 24        MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08     MOVSD XMM1, QWORD [ESP + 8]
        ;  F2 0F 10 54 24 10     MOVSD XMM2, QWORD [ESP + 16]
        ;  90                    NOP
        ; -------------------------------------------------------------------------
        ; 48 BYTES -> 27 BYTES
        ; -------------------------------------------------------------------------
        ;> F2 0F 10 05 AAAAAAAA  MOVSD XMM0, QWORD [AAAAAAAA]
        ;  F2 0F 10 0D BBBBBBBB  MOVSD XMM1, QWORD [BBBBBBBB]
        ;  F2 0F 10 15 CCCCCCCC  MOVSD XMM2, QWORD [CCCCCCCC]
        ;  83 C4 E8              ADD   ESP, -24
        ; -------------------------------------------------------------------------
        cmp     [edi + 30], dword 0x04100FF2
        jne    .cc.100.out
        cmp     [edi + 34], dword 0x100FF224
        jne    .cc.100.out
        cmp     [edi + 38], dword 0xF208244C
        jne    .cc.100.out
        cmp     [edi + 42], dword 0x2454100F
        jne    .cc.100.out
        cmp     [edi + 46], word 0x9010
        jne    .cc.100.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 48
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.100.out
        ; ---------------------------------------------------------
        push    ecx
        mov     ecx, [edi + 01]
        mov     edx, [edi + 11]
        mov     eax, [edi + 21]
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x0D100FF2
        mov     [edi + 12], edx
        mov     [edi + 16], dword 0x15100FF2
        mov     [edi + 20], ecx
        mov     [edi + 24], word 0xC483
        mov     [edi + 26], byte 0xE8
        pop     ecx
;       mov     [.esi], 48
        mov     [.edi], 27
       .instr.shift.back 3                       ; instruction shift back
        jmp    .cc.momem
   .cc.100.out:
  }
   .cc.100..in:
        SIC_OP.cc.L0.5B0.100
   .cc.100..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B0.101
  {
        cmp     ebx, 5
        jne    .cc.101.out
        ; -------------------------------------------------------------------------
        ;> B9 AAAAAAAA           MOV  ECX, AAAAAAAA
        ;  FF 71 04              PUSH DWORD [ECX + 4]
        ;  FF 31                 PUSH DWORD [ECX]
        ;  ...
        ; -------------------------------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .cc.101.out
        cmp     [edi + 05], dword 0xFF0471FF
        jne    .cc.101.out
        cmp     [edi + 09], byte 0x31
        jne    .cc.101.out
   .cc.101..01:
        ; -------------------------------------------------------------------------
        ; 22 BYTES
        ; -------------------------------------------------------------------------
        ;> B9 AAAAAAAA           MOV   ECX, AAAAAAAA
        ;  FF 71 04              PUSH  DWORD [ECX + 4]
        ;  FF 31                 PUSH  DWORD [ECX]
        ;  F2 0F 10 04 24        MOVSD XMM0, QWORD [ESP]
        ;  F2 0F 10 4C 24 08     MOVSD XMM1, QWORD [ESP + 8]
        ;  90                    NOP
        ; -------------------------------------------------------------------------
        ; 22 BYTES -> 16 BYTES
        ; -------------------------------------------------------------------------
        ;> F2 0F 10 05 AAAAAAAA  MOVSD XMM0, QWORD [AAAAAAAA]
        ;  F2 0F 10 0C 24        MOVSD XMM1, QWORD [ESP]
        ;  83 C4 F8              ADD   ESP, -08
        ; -------------------------------------------------------------------------
        cmp     [edi + 10], dword 0x04100FF2
        jne    .cc.101.out
        cmp     [edi + 14], dword 0x100FF224
        jne    .cc.101.out
        cmp     [edi + 18], dword 0x9008244C
        jne    .cc.101.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 22
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.101.out
        ; ---------------------------------------------------------
        mov     eax, [edi + 01]
        mov     [edi + 00], dword 0x05100FF2
        mov     [edi + 04], eax
        mov     [edi + 08], dword 0x0C100FF2
        mov     [edi + 12], dword 0xF8C48324
;       mov     [.esi], 22
        mov     [.edi], 16
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.101.out:
  }
   .cc.101..in:
        SIC_OP.cc.L0.5B0.101
   .cc.101..out:
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fstp2.fld2.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0x08245CDD
        jne    .cc.fstp2.fld2.nop.out
        cmp     [edi + 04], dword 0xDD241CDD
        jne    .cc.fstp2.fld2.nop.out
        cmp     [edi + 08], dword 0x44DD2404
        jne    .cc.fstp2.fld2.nop.out
        cmp     [edi + 11], dword 0x90082444
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fstp.fld2.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0xDD241CDD
        jne    .cc.fstp.fld2.nop.out
        cmp     [edi + 04], dword 0x44DD2404
        jne    .cc.fstp.fld2.nop.out
        cmp     [edi + 07], dword 0x90082444
        jne    .cc.fstp.fld2.nop.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x082444DD
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fstp.fld.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xDD241CDD
        jne    .cc.fstp.fld.nop.out
        cmp     [edi + 3], dword 0x902404DD
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fld.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0x902404DD
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
        cmp     [edi + 0], dword 0xDD2404DD
        jne    .cc.fld2.nop.out
        cmp     [edi + 4], dword 0x90082444
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.nop.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0x90
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

   .cc.L0.3B_6B?:
        cmp     ebx, 3
        je     .cc.L0.3B_6B
        cmp     ebx, 6
        jne    .cc.L0.3B_6B.out

   .cc.L0.3B_6B:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B_6B.a0
  {
   .cc.a0.in:
        cmp     ebx, 3
        je     .cc.a0.spB
;       cmp     ebx, 6
;       jne    .cc.L0.3B_6B.out ; .cc.a0.out
        ; --------------------------------------------------------------------------
        ;?  83C4 FF  ADD   ESP, FF         |
        ;?  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
   .cc.a0.spD:
        ; --------------------------------------------------------------------------
        ;?  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        cmp     [edi + 0], word 0xC481
        jne    .cc.a0.out
        ; --------------------------------------------------------------------------
        mov     eax, dword [edi + 2]
        mov     edx, 6
        mov     [.esi], 6
        jmp    .cc.a0.spx
   .cc.a0.spB:
        ; --------------------------------------------------------------------------
        ;?  83C4 FF  ADD   ESP, FF         |
        ; --------------------------------------------------------------------------
        cmp     [edi + 0], word 0xC483
        jne    .cc.a0.out
        ; --------------------------------------------------------------------------
        movsx   eax, byte [edi + 2]
        mov     edx, 3
        mov     [.esi], 3
;       jmp    .cc.a0.spx
   .cc.a0.spx:
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
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
        ;?  83C4 FF  ADD   ESP, FF         |
        ;?  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;?  83C4 FF  ADD   ESP, FF         |
        ;?  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        cmp     [edi + edx + 00], word 0x1CDD
        jne    .cc.a0.out
        cmp     [edi + edx + 02], byte 0x24
        jne    .cc.a0.out
        ;
        cmp     [edi + edx + 03], word 0xC483
        je     .cc.a0.spy.spB
        cmp     [edi + edx + 03], word 0xC481
        je     .cc.a0.spy.spD
        ;
        cmp     [edi + edx + 03], dword 0xDD2404DD
        jne    .cc.a0.out
        cmp     [edi + edx + 07], dword 0xDE082444
        jne    .cc.a0.out
        cmp     [edi + edx + 12], word 0xC483
        je     .cc.a0.spx.spB
        cmp     [edi + edx + 12], word 0xC481
        je     .cc.a0.spx.spD
        jmp    .cc.a0.out
   .cc.a0.spx.spD:
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
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
        ;   81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        mov     ecx, dword [edi + edx + 14]
        test    ecx, ecx
        js     .cc.a0.out
        ;
        add     ecx, eax
        test    ecx, ecx
        js     .cc.a0.out
        ;
        mov     [.xcx], ecx
        add     [.esi], 6
        jmp    .cc.a0.spx.spx
   .cc.a0.spx.spB:
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
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
        ;   83C4 FF  ADD   ESP, FF         |
        ; --------------------------------------------------------------------------
        movsx   ecx, byte [edi + edx + 14]
        test    ecx, ecx
        js     .cc.a0.out
        ;
        add     ecx, eax
        test    ecx, ecx
        js     .cc.a0.out
        ;
        mov     [.xcx], ecx
        add     [.esi], 3
;       jmp    .cc.a0.spx.spx
   .cc.a0.spx.spx:
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
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
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
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
        ; (3|6) + 12 + (3|6) BYTES -> (7|10) BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 |?  83C4 FF  ADD   ESP, FF
        ;?DEE9       FSUBP                 |?  81C4 FF+ ADD   ESP, FF+
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        mov     dl, [edi + edx + 11]
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
        ; (3|6) + 12 + (3|6) BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 |   83C4 FF  ADD   ESP, FF
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002400DC
        mov     [edi + 1], dh
        mov     [edi + 3], al
        mov     [edi + 4], word 0xC483
        mov     dl, byte [.xcx]
        mov     [edi + 6], dl
;       mov     [.esi], ...
        mov     [.edi], 7
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpB.spD:
        ; --------------------------------------------------------------------------
        ; (3|6) + 12 + (3|6) BYTES -> 10 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
        ;                                  |?DC6C24 FF  FSUBR QWORD [xSP + FF]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC4C24 FF  FMUL  QWORD [xSP + FF]
        ; DD0424     FLD   QWORD [xSP]     |?DC7424 FF  FDIV  QWORD [xSP + FF]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DC7C24 FF  FDIVR QWORD [xSP + FF]
        ;                                  |
        ;?DEC1       FADDP                 |   81C4 FF+ ADD   ESP, FF+
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002400DC
        mov     [edi + 1], dh
        mov     [edi + 3], al
        mov     [edi + 4], word 0xC481
        mov     edx, dword [.xcx]
        mov     [edi + 6], edx
;       mov     [.esi], ...
        mov     [.edi], 10
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpB.spZ:
        ; --------------------------------------------------------------------------
        ; (3|6) + 12 + (3|6) BYTES -> 4 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC4424 FF  FADD  QWORD [xSP + FF]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DC6424 FF  FSUB  QWORD [xSP + FF]
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
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002400DC
        mov     [edi + 1], dh
        mov     [edi + 3], al
;       mov     [.esi], ...
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.a0.spx.fpD:
        ; --------------------------------------------------------------------------
        ; (3|6) + 12 + (3|6) BYTES -> (10|13) BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 |?  83C4 FF  ADD   ESP, FF
        ;?DEE9       FSUBP                 |?  81C4 FF+ ADD   ESP, FF+
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        mov     dl, [edi + edx + 11]
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
        ; (3|6) + 12 + (3|6) BYTES -> 10 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 |   83C4 FF  ADD   ESP, FF
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002400DC
        mov     [edi + 1], dh
        mov     [edi + 3], eax
        mov     [edi + 7], word 0xC483
        mov     dl, byte [.xcx]
        mov     [edi + 9], dl
;       mov     [.esi], ...
        mov     [.edi], 10
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpD.spD:
        ; --------------------------------------------------------------------------
        ; (3|6) + 12 + (3|6) BYTES -> 13 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
        ;                                  |?DCAC24 FF+ FSUBR QWORD [xSP + FF+]
        ; DD1C24     FSTP  QWORD [xSP]     |?DC8C24 FF+ FMUL  QWORD [xSP + FF+]
        ; DD0424     FLD   QWORD [xSP]     |?DCB424 FF+ FDIV  QWORD [xSP + FF+]
        ; DD4424 08  FLD   QWORD [xSP + 8] |?DCBC24 FF+ FDIVR QWORD [xSP + FF+]
        ;                                  |
        ;?DEC1       FADDP                 |   81C4 FF+ ADD   ESP, FF+
        ;?DEE9       FSUBP                 |
        ;?DEE1       FSUBRP                |
        ;?DEC9       FMULP                 |
        ;?DEF9       FDIVP                 |
        ;?DEF1       FDIVRP                |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002400DC
        mov     [edi + 1], dh
        mov     [edi + 3], eax
        mov     [edi + 7], word 0xC481
        mov     edx, dword [.xcx]
        mov     [edi + 9], edx
;       mov     [.esi], ...
        mov     [.edi], 13
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spx.fpD.spZ:
        ; --------------------------------------------------------------------------
        ; (3|6) + 12 + (3|6) BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         |?DC8424 FF+ FADD  QWORD [xSP + FF+]
        ;>  81C4 FF+ ADD   ESP, FF+        |?DCA424 FF+ FSUB  QWORD [xSP + FF+]
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
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; ---------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002400DC
        mov     [edi + 1], dh
        mov     [edi + 3], eax
;       mov     [.esi], ...
        mov     [.edi], 7
        jmp    .cc.momem
        ;
   .cc.a0.spy.spD:
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;   81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        mov     ecx, dword [edi + edx + 5]
        add     ecx, eax
        mov     [.xcx], ecx
        add     [.esi], 6
        jmp    .cc.a0.spy.spy
   .cc.a0.spy.spB:
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | EDX = 3
        ;>  81C4 FF+ ADD   ESP, FF+        | EDX = 6
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;   83C4 FF  ADD   ESP, FF         |
        ; --------------------------------------------------------------------------
        movsx   ecx, byte [edi + edx + 5]
        add     ecx, eax
        mov     [.xcx], ecx
        add     [.esi], 3
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
        ; (3) + 3 + (3|6) BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | DD5C24 FF  FSTP  QWORD [xSP + FF]
        ;                                  |   83C4 FF  ADD   ESP, FF
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 7
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x00245CDD
        mov     [edi + 3], al
        mov     [edi + 4], word 0xC483
        mov     [edi + 6], dl
;       mov     [.esi], ...
        mov     [.edi], 7
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpB.spD:
        ; --------------------------------------------------------------------------
        ; (3) + 3 + (3|6) BYTES -> 10 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | DD5C24 FF  FSTP  QWORD [xSP + FF]
        ;                                  |   81C4 FF+ ADD   ESP, FF+
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        cmp     [.esi], 10
        jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x00245CDD
        mov     [edi + 3], al
        mov     [edi + 4], word 0xC481
        mov     [edi + 6], edx
;       mov     [.esi], ...
        mov     [.edi], 10
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpB.spZ:
        ; --------------------------------------------------------------------------
        ; (3) + 3 + (3|6) BYTES -> 4 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 FF  ADD   ESP, FF         | DD5C24 FF  FSTP  QWORD [xSP + FF]
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 4
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x00245CDD
        mov     [edi + 3], al
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
        ; (6) + 3 + (3|6) BYTES -> 10 BYTES
        ; --------------------------------------------------------------------------
        ;>  81C4 FF+ ADD   ESP, FF+        | DD9C24 FF+ FSTP  QWORD [xSP + FF+]
        ;                                  |   83C4 FF  ADD   ESP, FF
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 10
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x00249CDD
        mov     [edi + 3], eax
        mov     [edi + 7], word 0xC483
        mov     [edi + 9], dl
;       mov     [.esi], ...
        mov     [.edi], 10
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpD.spD:
        ; --------------------------------------------------------------------------
        ; (6) + 3 + (3|6) BYTES -> 13 BYTES
        ; --------------------------------------------------------------------------
        ;>  81C4 FF+ ADD   ESP, FF+        | DD9C24 FF+ FSTP  QWORD [xSP + FF+]
        ;                                  |   81C4 FF+ ADD   ESP, FF+
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
        cmp     [.esi], 13
        jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x00249CDD
        mov     [edi + 3], eax
        mov     [edi + 7], word 0xC481
        mov     [edi + 9], edx
;       mov     [.esi], ...
        mov     [.edi], 13
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.a0.spy.fpD.spZ:
        ; --------------------------------------------------------------------------
        ; (6) + 3 + (3|6) BYTES -> 7 BYTES
        ; --------------------------------------------------------------------------
        ;>  81C4 FF+ ADD   ESP, FF+        | DD9C24 FF+ FSTP  QWORD [xSP + FF+]
        ;                                  |
        ; DD1C24     FSTP  QWORD [xSP]     |
        ;                                  |
        ;+  83C4 FF  ADD   ESP, FF         |
        ;+  81C4 FF+ ADD   ESP, FF+        |
        ; --------------------------------------------------------------------------
;       cmp     [.esi], 7
;       jb     .cc.a0.out
        ; --------------------------------------------------------------------------
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.a0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x00249CDD
        mov     [edi + 3], eax
;       mov     [.esi], ...
        mov     [.edi], 7
        jmp    .cc.momem
   .cc.a0.out:
  }
   .cc.a0..in:
        SIC_OP.cc.L0.3B_6B.a0
   .cc.a0..out:
  $end

  macro SIC_OP.cc.L0.3B_6B.add_esp.mov_c
  {
   .cc.add_esp.mov_c.in:
        cmp     ebx, 3
        je     .cc.add_esp.mov_c.bx
;       cmp     ebx, 6
;       jne    .cc.L0.3B_6B.out ; .cc.add_esp.mov_c.out
   .cc.add_esp.mov_c.dx:
        ; --------------------------------------------------------------------------
        ; 11 BYTES -> 11 BYTES
        ; --------------------------------------------------------------------------
        ;>  81C4 AA+   ADD  ESP, AA+        | 6 BYTES
        ;                                   |
        ;?  B8 DWORD   MOV  EAX, DWORD      | 5 BYTES
        ;?  B9 DWORD   MOV  ECX, DWORD      |
        ;?  BA DWORD   MOV  EDX, DWORD      |
        ; --------------------------------------------------------------------------
        cmp     [edi + 0], word 0xC481
        jne    .cc.add_esp.mov_c.out
        mov     al, [edi + 6]
        case    al,\
                0xB8 , .cc.add_esp.mov_c.dx.reg,\
                0xB9 , .cc.add_esp.mov_c.dx.reg,\
                0xBA , .cc.add_esp.mov_c.dx.reg
        jmp    .cc.add_esp.mov_c.out
   .cc.add_esp.mov_c.dx.reg:
        mov     edx, [edi + 7]
        mov     ecx, [edi + 2]
        ; --------------------------------------------------------------------------
        ;>  B* DWORD   MOV  E**, DWORD      |
        ;   81C4 AA+   ADD  ESP, AA+        |
        ; --------------------------------------------------------------------------
        mov     [edi + 0], al
        mov     [edi + 1], edx
        mov     [edi + 5], word 0xC481
        mov     [edi + 7], ecx
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.next
        ;
   .cc.add_esp.mov_c.bx:
        ; --------------------------------------------------------------------------
        ; 8 BYTES -> 8 BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 AA    ADD  ESP, AA         | 3 BYTES
        ;                                   |
        ;?  B8 DWORD   MOV  EAX, DWORD      | 5 BYTES
        ;?  B9 DWORD   MOV  ECX, DWORD      |
        ;?  BA DWORD   MOV  EDX, DWORD      |
        ; --------------------------------------------------------------------------
        cmp     [edi + 0], word 0xC483
        jne    .cc.add_esp.mov_c.out
        mov     al, [edi + 3]
        case    al,\
                0xB8 , .cc.add_esp.mov_c.bx.reg,\
                0xB9 , .cc.add_esp.mov_c.bx.reg,\
                0xBA , .cc.add_esp.mov_c.bx.reg
        jmp    .cc.add_esp.mov_c.out
   .cc.add_esp.mov_c.bx.reg:
        mov     edx, [edi + 4]
        mov     cl, [edi + 2]
        ; --------------------------------------------------------------------------
        ;>  B* DWORD   MOV  E**, DWORD      |
        ;   83C4 AA    ADD  ESP, AA         |
        ; --------------------------------------------------------------------------
        mov     [edi + 0], al
        mov     [edi + 1], edx
        mov     [edi + 5], word 0xC483
        mov     [edi + 7], cl
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.next
   .cc.add_esp.mov_c.out:
  }
   .cc.add_esp.mov_c..in:
        SIC_OP.cc.L0.3B_6B.add_esp.mov_c
   .cc.add_esp.mov_c..out:

  macro SIC_OP.cc.L0.3B_6B.add_esp
  {
   .cc.add_esp.in:
        cmp     ebx, 3
        je     .cc.add_esp.bx
;       cmp     ebx, 6
;       jne    .cc.L0.3B_6B.out ; .cc.add_esp.out
   .cc.add_esp.dx:
        ; --------------------------------------------------------------------------
        ;>  81C4 AA+   ADD  ESP, AA+        |
        ;?  83C4 BB    ADD  ESP, BB         |
        ;?  81C4 BB+   ADD  ESP, BB+        |
        ; --------------------------------------------------------------------------
        cmp     [edi + 0], word 0xC481
        jne    .cc.add_esp.out
        cmp     [edi + 6], word 0xC483
        je     .cc.add_esp.db
        cmp     [edi + 6], word 0xC481
        je     .cc.add_esp.dd
        jmp    .cc.add_esp.out
        ;
   .cc.add_esp.bx:
        ; --------------------------------------------------------------------------
        ;>  83C4 AA    ADD  ESP, AA         |
        ;?  83C4 BB    ADD  ESP, BB         |
        ;?  81C4 BB+   ADD  ESP, BB+        |
        ; --------------------------------------------------------------------------
        cmp     [edi + 0], word 0xC483
        jne    .cc.add_esp.out
        cmp     [edi + 3], word 0xC483
        je     .cc.add_esp.bb
        cmp     [edi + 3], word 0xC481
        je     .cc.add_esp.bd
        jmp    .cc.add_esp.out
        ;
   .cc.add_esp.dd:
        ; --------------------------------------------------------------------------
        ; 12 BYTES -> 3(6) BYTES
        ; --------------------------------------------------------------------------
        ;>  81C4 AA+   ADD  ESP, AA+        |
        ;   81C4 BB+   ADD  ESP, BB+        |
        ; --------------------------------------------------------------------------
        mov     [.esi], 12
        mov     eax, dword [edi + 2]
        mov     edx, dword [edi + 8]
        add     eax, edx
        jmp    .cc.add_esp.x
   .cc.add_esp.db:
        ; --------------------------------------------------------------------------
        ; 9 BYTES -> 3(6) BYTES
        ; --------------------------------------------------------------------------
        ;>  81C4 AA+   ADD  ESP, AA+        |
        ;   83C4 BB    ADD  ESP, BB         |
        ; --------------------------------------------------------------------------
        mov     [.esi], 9
        mov     eax, dword [edi + 2]
        movsx   edx, byte [edi + 8]
        add     eax, edx
        jmp    .cc.add_esp.x
   .cc.add_esp.bd:
        ; --------------------------------------------------------------------------
        ; 9 BYTES -> 3(6) BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 AA    ADD  ESP, AA         |
        ;   81C4 BB+   ADD  ESP, BB+        |
        ; --------------------------------------------------------------------------
        mov     [.esi], 9
        movsx   eax, byte [edi + 2]
        mov     edx, dword [edi + 5]
        add     eax, edx
        jmp    .cc.add_esp.x
   .cc.add_esp.bb:
        ; --------------------------------------------------------------------------
        ; 6 BYTES -> 3(6) BYTES
        ; --------------------------------------------------------------------------
        ;>  83C4 AA    ADD  ESP, AA         |
        ;   83C4 BB    ADD  ESP, BB         |
        ; --------------------------------------------------------------------------
        mov     [.esi], 6
        movsx   eax, byte [edi + 2]
        movsx   edx, byte [edi + 5]
        add     eax, edx
;       jmp    .cc.add_esp.x
   .cc.add_esp.x:
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.add_esp.out
        ; ---------------------------------------------------------
        cmp     eax, +127
        jg     .cc.add_esp.xd
        cmp     eax, -127
        jl     .cc.add_esp.xd
        test    eax, eax
        jz     .cc.add_esp.xz
   .cc.add_esp.xb:
        ; --------------------------------------------------------------------------
        ; 12|9|6 BYTES -> 3 BYTES
        ; --------------------------------------------------------------------------
        ;   83C4 AA    ADD  ESP, AA         |
        ; --------------------------------------------------------------------------
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], al
;       mov     [.esi], ...
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.move.memory
   .cc.add_esp.xd:
        ; --------------------------------------------------------------------------
        ; 12|9|6 BYTES -> 6 BYTES
        ; --------------------------------------------------------------------------
        ;   81C4 AA+   ADD  ESP, AA+        |
        ; --------------------------------------------------------------------------
        mov     [edi + 0], word 0xC481
        mov     [edi + 2], eax
;       mov     [.esi], ...
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.move.memory
   .cc.add_esp.xz:
        ; --------------------------------------------------------------------------
        ; 12|9|6 BYTES -> 0 BYTES
        ; --------------------------------------------------------------------------
;       mov     [.esi], ...
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.move.memory
   .cc.add_esp.out:
  }
   .cc.add_esp..in:
        SIC_OP.cc.L0.3B_6B.add_esp
   .cc.add_esp..out:

   .cc.L0.3B_6B.out:

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
        cmp     ebx, 1
        jne    .cc.push.fild.fstp_st0.out
        ; ---------------------------------------------------------
        ;>  50       PUSH EAX         |
        ;   DB04 24  FILD DWORD [ESP] |
        ; ---------------------------------------------------------
        ;?  83C4 FF  ADD  ESP, FF     |
        ;?  81C4 FF+ ADD  ESP, FF+    |
        ; ---------------------------------------------------------
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0x2404DB50
        jne    .cc.push.fild.fstp_st0.out
        cmp     [edi + 4], word 0xC483
        je     .cc.push.fild.spB.fstp_st0
        cmp     [edi + 4], word 0xC481
        je     .cc.push.fild.spD.fstp_st0
        cmp     [edi + 4], word 0xD8DD
        je     .cc.push.fild.spN.fstp_st0
        jmp    .cc.push.fild.fstp_st0.out
        ;
   .cc.push.fild.spN.fstp_st0:
        ; ---------------------------------------------------------
        ; 6 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH EAX         | 50       PUSH EAX
        ;   DB04 24  FILD DWORD [ESP] |
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
        ; 9 BYTES -> 6|4|3|0 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH EAX         |?  83C4 FF  ADD  ESP, FF-4
        ;   DB04 24  FILD DWORD [ESP] |?  81C4 FF+ ADD  ESP, FF-4
        ;   83C4 FF  ADD  ESP, FF     |?
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [edi + 7], word 0xD8DD
        jne    .cc.push.fild.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.push.fild.fstp_st0.out
    else
        jl     .cc.push.fild.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        movsx   eax, byte [edi + 6]
        sub     eax, 4
        jl     .cc.push.fild.spB.fstp_st0.spN
        test    eax, eax
        jz     .cc.push.fild.spB.fstp_st0.spZ
        cmp     eax, +127
        jg     .cc.push.fild.spB.fstp_st0.spD
;       cmp     eax, -128
;       jl     .cc.push.fild.spB.fstp_st0.spD
   .cc.push.fild.spB.fstp_st0.spB:
        ; ---------------------------------------------------------
        ; 9 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |   83C4 FF  ADD  ESP, FF-4
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], al
;       mov     [.esi], 9
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spB.fstp_st0.spD:
        ; ---------------------------------------------------------
        ; 9 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |   81C4 FF+ ADD  ESP, FF-4
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC481
        mov     [edi + 2], eax
;       mov     [.esi], 9
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spB.fstp_st0.spZ:
        ; ---------------------------------------------------------
        ; 9 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |
        ; ---------------------------------------------------------
;       mov     [.esi], 9
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spB.fstp_st0.spN:
        ; ---------------------------------------------------------
        ; 9 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH EAX         |   50       PUSH EAX
        ;   ...                       |   83C4 FF  ADD  ESP, FF
        ; ---------------------------------------------------------
        add     eax, 4
        mov     [edi + 1], word 0xC483
        mov     [edi + 3], eax
;       mov     [.esi], 9
        mov     [.edi], 4
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
        ;
   .cc.push.fild.spD.fstp_st0:
        ; ---------------------------------------------------------
        ; 12 BYTES -> 7|6|3|0 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH EAX         |?  83C4 FF  ADD  ESP, FF-4
        ;   DB04 24  FILD DWORD [ESP] |?  81C4 FF+ ADD  ESP, FF-4
        ;   81C4 FF+ ADD  ESP, FF+    |?
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [edi + 10], word 0xD8DD
        jne    .cc.push.fild.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.push.fild.fstp_st0.out
    else
        jl     .cc.push.fild.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        mov     eax, [edi + 6]
        sub     eax, 4
        jl     .cc.push.fild.spD.fstp_st0.spN
        test    eax, eax
        jz     .cc.push.fild.spD.fstp_st0.spZ
        cmp     eax, +127
        jg     .cc.push.fild.spD.fstp_st0.spD
;       cmp     eax, -128
;       jl     .cc.push.fild.spD.fstp_st0.spD
   .cc.push.fild.spD.fstp_st0.spB:
        ; ---------------------------------------------------------
        ; 12 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |   83C4 FF  ADD  ESP, FF-4
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], al
;       mov     [.esi], 12
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spD.fstp_st0.spD:
        ; ---------------------------------------------------------
        ; 12 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |   81C4 FF+ ADD  ESP, FF-4
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC481
        mov     [edi + 2], eax
;       mov     [.esi], 12
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spD.fstp_st0.spZ:
        ; ---------------------------------------------------------
        ; 12 BYTES -> 0 BYTES
        ; ---------------------------------------------------------
        ;>  ...                       |
        ; ---------------------------------------------------------
;       mov     [.esi], 12
        mov     [.edi], 0
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.spD.fstp_st0.spN:
        ; ---------------------------------------------------------
        ; 12 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;>  50       PUSH EAX         |   50       PUSH EAX
        ;   ...                       |   81C4 FF+ ADD  ESP, FF-4
        ; ---------------------------------------------------------
        add     eax, 4
        mov     [edi + 1], word 0xC481
        mov     [edi + 3], eax
;       mov     [.esi], 12
        mov     [.edi], 7
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.push.fild.fstp_st0.out:
  }
;  .cc.push.fild.fstp_st0..in:
;       SIC_OP.cc.L0.1B.push.fild.fstp_st0 .static.FSTP.ST0
;  .cc.push.fild.fstp_st0..out:
  $end

  macro SIC_OP.cc.L0.1B.eax_esp_eax
  {
   .cc.eax_esp_eax.in:
;       cmp     ebx, 1
;       jne    .cc.eax_esp_eax.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> 50          PUSH  EAX
        ;  8B0424      MOV   EAX, DWORD [ESP]
        ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ;> 50          PUSH  EAX
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.eax_esp_eax.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0x24048B50
        jne    .cc.eax_esp_eax.out
        ; ---------------------------------------------------------
;       mov     [.esi], 4
        mov     [.edi], 1
       .instr.shift.back                        ; instruction shift back
        jmp    .cc.momem
   .cc.eax_esp_eax.out:
  }
   .cc.eax_esp_eax..in:
        SIC_OP.cc.L0.1B.eax_esp_eax
   .cc.eax_esp_eax..out:

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
        ;>? DD00     FLD  QWORD [EAX] |
        ; ? DD01     FLD  QWORD [ECX] |
        ; ? DD02     FLD  QWORD [EDX] |
        ; ---------------------------------------------------------
        ; ? DB00     FILD DWORD [EAX] |
        ; ? DB01     FILD DWORD [ECX] |
        ; ? DB02     FILD DWORD [EDX] |
        ; ---------------------------------------------------------
        ; ? DF28     FILD QWORD [EAX] |
        ; ? DF29     FILD QWORD [ECX] |
        ; ? DF2A     FILD QWORD [EDX] |
        ; ---------------------------------------------------------
        ; ? D9E8     FLD1             |
        ; ? D9E9     FLDL2T           |
        ; ? D9EA     FLDL2E           |
        ; ? D9EB     FLDPI            |
        ; ? D9EC     FLDLG2           |
        ; ? D9ED     FLDLN2           |
        ; ? D9EE     FLDZ             |
        ; ---------------------------------------------------------
        ;?  83C4 FF  ADD  ESP, FF     |
        ;?  81C4 FF+ ADD  ESP, FF+    |
        ; ---------------------------------------------------------
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     ax, [edi + 0]
        case    ax,\
                0x00DD, .cc.fld.fstp_st0.match,\
                0x01DD, .cc.fld.fstp_st0.match,\
                0x02DD, .cc.fld.fstp_st0.match,\
                0x00DB, .cc.fld.fstp_st0.match,\
                0x01DB, .cc.fld.fstp_st0.match,\
                0x02DB, .cc.fld.fstp_st0.match,\
                0x28DF, .cc.fld.fstp_st0.match,\
                0x29DF, .cc.fld.fstp_st0.match,\
                0x2ADF, .cc.fld.fstp_st0.match,\
                0xE8D9, .cc.fld.fstp_st0.match,\
                0xE9D9, .cc.fld.fstp_st0.match,\
                0xEAD9, .cc.fld.fstp_st0.match,\
                0xEBD9, .cc.fld.fstp_st0.match,\
                0xECD9, .cc.fld.fstp_st0.match,\
                0xEDD9, .cc.fld.fstp_st0.match,\
                0xEED9, .cc.fld.fstp_st0.match
        jmp    .cc.fld.fstp_st0.out
   .cc.fld.fstp_st0.match:
        cmp     [edi + 2], word 0xC483
        je     .cc.fld.spB.fstp_st0
        cmp     [edi + 2], word 0xC481
        je     .cc.fld.spD.fstp_st0
        cmp     [edi + 2], word 0xD8DD
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
        call   .cc.size                         ; ecx = bytes to copy
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
        ; 7 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  D***     FLD*             |   83C4 FF  ADD  ESP, FF
        ;   83C4 FF  ADD  ESP, FF     |
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [edi + 5], word 0xD8DD
        jne    .cc.fld.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fld.fstp_st0.out
    else
        jl     .cc.fld.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        mov     al, [edi + 4]
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], al
;       mov     [.esi], 7
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.fld.spD.fstp_st0:
        ; ---------------------------------------------------------
        ; 10 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;>  D***     FLD*             |   81C4 FF+ ADD  ESP, FF+
        ;   81C4 FF+ ADD  ESP, FF+    |
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        cmp     [edi + 8], word 0xD8DD
        jne    .cc.fld.fstp_st0.out
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fld.fstp_st0.out
    else
        jl     .cc.fld.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        mov     eax, [edi + 4]
        mov     [edi + 0], word 0xC481
        mov     [edi + 2], eax
;       mov     [.esi], 10
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.fld.fstp_st0.out:
  }
   .cc.fld.fstp_st0..in:
        SIC_OP.cc.L0.2B.fld.fstp_st0 .static.FSTP.ST0
   .cc.fld.fstp_st0..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fst_eax static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_eax.in:
;       cmp     ebx, 2
;       jne    .cc.fst_eax.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  DD10     FST  QWORD [EAX] |   DD18     FSTP QWORD [EAX]
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_eax.out
    else
        jl     .cc.fst_eax.out
    end if
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xD8DD10DD
        jne    .cc.fst_eax.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0x18DD
;       mov     [.esi], 4
        mov     [.edi], 2
;      .instr.shift.back 2                      ; instruction shift back
        jmp    .cc.momem
   .cc.fst_eax.out:
  }
   .cc.fst_eax..in:
        SIC_OP.cc.L0.2B.fst_eax .static.FSTP.ST0
   .cc.fst_eax..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fst_ecx static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_ecx.in:
;       cmp     ebx, 2
;       jne    .cc.fst_ecx.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  DD11     FST  QWORD [ECX] |   DD19     FSTP QWORD [ECX]
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_ecx.out
    else
        jl     .cc.fst_ecx.out
    end if
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xD8DD11DD
        jne    .cc.fst_ecx.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0x19DD
;       mov     [.esi], 4
        mov     [.edi], 2
;      .instr.shift.back 2                      ; instruction shift back
        jmp    .cc.momem
   .cc.fst_ecx.out:
  }
   .cc.fst_ecx..in:
        SIC_OP.cc.L0.2B.fst_ecx .static.FSTP.ST0
   .cc.fst_ecx..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.2B.fst_edx static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_edx.in:
;       cmp     ebx, 2
;       jne    .cc.fst_edx.out
        ; ---------------------------------------------------------
        ; 4 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  DD12     FST  QWORD [EDX] |   DD1A     FSTP QWORD [EDX]
        ;   DDD8     FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 4
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_edx.out
    else
        jl     .cc.fst_edx.out
    end if
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xD8DD12DD
        jne    .cc.fst_edx.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0x1ADD
;       mov     [.esi], 4
        mov     [.edi], 2
;      .instr.shift.back 2                      ; instruction shift back
        jmp    .cc.momem
   .cc.fst_edx.out:
  }
   .cc.fst_edx..in:
        SIC_OP.cc.L0.2B.fst_edx .static.FSTP.ST0
   .cc.fst_edx..out:
  $end

   .cc.L0.2B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 3
        jne    .cc.L0.3B.out
   .cc.L0.3B:

  $ifdef _SSEX
  macro SIC_OP.cc.L0.3B.espB.xop
  {
   .cc.3B.espB.xop.in:
;       cmp     ebx, 3
;       jne    .cc.3B.espB.xop.out
        ; ---------------------------------------------------------
        ; 7 BYTES
        ; ---------------------------------------------------------
        ;> 83 C4 FF            ADD   ESP, FF
        ; ?F2 0F ** **         **
        ; ?66 0F ** **         **
        ; ---------------------------------------------------------
        ; 7 BYTES -> 7 BYTES
        ; ---------------------------------------------------------
        ;>?F2 0F ** **         **
        ; ?66 0F ** **         **
        ;  83 C4 FF            ADD   ESP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.3B.espB.xop.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0xC483
        jne    .cc.3B.espB.xop.out
        cmp     [edi + 03], word 0x0FF2
        je     .cc.3B.espB.xop.next
        cmp     [edi + 03], word 0x0F66
        jne    .cc.3B.espB.xop.out
   .cc.3B.espB.xop.66.0F:
        ; ---------------------------------------------------------
        ;> 83 C4 FF            ADD   ESP, FF
        ; ?66 0F ** **         **
        ; -66 0F 2F **         COMISD
        ; -66 0F 2E **         UCOMISD
        ; ---------------------------------------------------------
        mov     al, byte [edi + 05]
        case    al,\
                0x2F, .cc.3B.espB.xop.out,\
                0x2E, .cc.3B.espB.xop.out
   .cc.3B.espB.xop.next:
        push    edi
        add     edi, [.cisize]
        call    SIC_IDA.ida                     ; eax = current instruction size
        pop     edi
        ;
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        cmp     eax, 4
        jne    .cc.3B.espB.xop.out
   .cc.3B.espB.xop.main:
        ; ---------------------------------------------------------
        mov     al, byte [edi + 02]
        mov     edx, dword [edi + 03]
        mov     [edi + 00], edx
        mov     [edi + 04], word 0xC483
        mov     [edi + 06], al
        ; ---------------------------------------------------------
;       mov     [.esi], 7
        mov     [.edi], 7
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.3B.espB.xop.out:
  }
   .cc.3B.espB.xop..in:
        SIC_OP.cc.L0.3B.espB.xop
   .cc.3B.espB.xop..out:
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.3B.espB.xmm
  {
   .cc.espB.xmm.in:
;       cmp     ebx, 3
;       jne    .cc.espB.xmm.out
        ; ---------------------------------------------------------
        ; 11 BYTES
        ; ---------------------------------------------------------
        ;> 83 C4 FF         ADD   ESP, FF
        ; ?F2 0F 10 05 DD+  XMM0, MOVSD QWORD [DDDDDDDD]
        ; ?F2 0F 10 0D DD+  XMM1, MOVSD QWORD [DDDDDDDD]
        ; ?F2 0F 11 05 DD+  MOVSD QWORD [DDDDDDDD], XMM0
        ; ?F2 0F 11 0D DD+  MOVSD QWORD [DDDDDDDD], XMM1
        ; ---------------------------------------------------------
        ; 11 BYTES -> 11 BYTES
        ; ---------------------------------------------------------
        ;> F2 0F ** ** DD+  ***
        ;  83 C4 FF         ADD   ESP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.espB.xmm.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0xC483
        jne    .cc.espB.xmm.out
        mov     eax, [edi + 3]
        case    eax,\
                0x05100FF2, .cc.espB.xmm.main,\
                0x0D100FF2, .cc.espB.xmm.main,\
                0x05110FF2, .cc.espB.xmm.main,\
                0x0D110FF2, .cc.espB.xmm.main
        jmp    .cc.espB.xmm.out
   .cc.espB.xmm.main:
        ; ---------------------------------------------------------
        push    ecx
        mov     cl, byte [edi + 02]
        mov     edx, [edi + 07]
        mov     [edi + 00], eax
        mov     [edi + 04], edx
        mov     [edi + 08], word 0xC483
        mov     [edi + 10], byte cl
        pop     ecx
        ; ---------------------------------------------------------
;       mov     [.esi], 11
        mov     [.edi], 11
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.espB.xmm.out:
  }
   .cc.espB.xmm..in:
        SIC_OP.cc.L0.3B.espB.xmm
   .cc.espB.xmm..out:
  $end

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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.01.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xDD2404DD
        jne    .cc.fxch.01.out
        cmp     [edi + 4], word 0x2444
        jne    .cc.fxch.01.out
        cmp     [edi + 7], word 0xC9D9
        jne    .cc.fxch.01.out
        ; ---------------------------------------------------------
        mov     eax, dword [edi + 3]
        ; ---------------------------------------------------------
        mov     [edi + 0], eax
        mov     [edi + 4], dword 0x002404DD
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
  macro SIC_OP.cc.L0.3B.fxch.04
  {
   .cc.fxch.04.in:
;       cmp     ebx, 3
;       jne    .cc.fxch.04.out
        ; --------------------------------------------------------------------------
        ; 11 BYTES -> 9 BYTES
        ; --------------------------------------------------------------------------
        ;> DD0424      FLD QWORD [xSP] | DD05   AA+  FLD QWORD [AA+]
        ;  DD05   AA+  FLD QWORD [AA+] | DD0424      FLD QWORD [xSP]
        ;  D9C9        FXCH            |
        ; --------------------------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.04.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xDD2404DD
        jne    .cc.fxch.04.out
        cmp     [edi + 4], byte 0x05
        jne    .cc.fxch.04.out
        cmp     [edi + 9], word 0xC9D9
        jne    .cc.fxch.04.out
        ; ---------------------------------------------------------
        mov     eax, dword [edi + 5]
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0x05DD
        mov     [edi + 2], eax
        mov     [edi + 6], dword 0x002404DD
;       mov     [.esi], 11
        mov     [.edi], 9
        jmp    .cc.momem
   .cc.fxch.04.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.04..in:
        SIC_OP.cc.L0.3B.fxch.04
   .cc.fxch.04..out:
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.07.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xD92404DD
        jne    .cc.fxch.07.out
        mov     dx, word [edi + 3]
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
        cmp     [edi + 7], word 0xC9D9
        jne    .cc.fxch.07.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dx
        mov     [edi + 2], dword 0x002404DD
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.d.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0xDD241CDD
        jne    .cc.d.out
        cmp     [edi + 04], word 0x2404
        jne    .cc.d.out
        ; ---------------------------------------------------------
        push    edi
        add     edi, 6
        call    SIC_IDA.ida                     ; eax = current instruction size
        pop     edi
        ;
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        cmp     eax, 2
        jne    .cc.d.out
        ; ---------------------------------------------------------
        cmp     [edi + 08], word 0x1CDD
        jne    .cc.d.out
        cmp     [edi + 10], byte 0x24
        jne    .cc.d.out
        ; ---------------------------------------------------------
        mov     dx, [edi + 06]
        cmp     dl, 0xD8
        jb     .cc.d.out
        cmp     dl, 0xDF
        ja     .cc.d.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dx
        mov     [edi + 2], dword 0x00241CDD
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
        ; 11 BYTES -> 5 BYTES
        ; --------------------------------------------------------------------------
        ;>DD1C24     FSTP QWORD [xSP]     | D***       F***
        ; DD0424     FLD  QWORD [xSP]     | 83C4 FF    ADD  ESP, FF
        ;?D8**       F***                 |
        ;?D9**       F***                 |
        ;?DA**       F***                 |
        ;?DB**       F***                 |
        ;?DC**       F***                 |
        ;?DD**       F***                 |
        ;?DE**       F***                 |
        ;?DF**       F***                 |
        ; 83C4 FF    ADD  ESP, FF         |
        ; --------------------------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.e.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0xDD241CDD
        jne    .cc.e.out
        cmp     [edi + 04], word 0x2404
        jne    .cc.e.out
        ; ---------------------------------------------------------
        push    edi
        add     edi, 6
        call    SIC_IDA.ida                     ; eax = current instruction size
        pop     edi
        ;
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        cmp     eax, 2
        jne    .cc.e.out
        ; ---------------------------------------------------------
        cmp     [edi + 08], word 0xC483
        jne    .cc.e.out
        ; ---------------------------------------------------------
        mov     al, [edi + 10]
        test    al, al
        js     .cc.e.out
        ; ---------------------------------------------------------
        mov     dx, [edi + 06]
        cmp     dl, 0xD8
        jb     .cc.e.out
        cmp     dl, 0xDF
        ja     .cc.e.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dx
        mov     [edi + 2], word 0xC483
        mov     [edi + 4], al
;       mov     [.esi], 11
        mov     [.edi], 5
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.e.out:
  }
   .cc.e..in:
        SIC_OP.cc.L0.3B.e
   .cc.e..out:
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.00.01.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xDD2404DD
        jne    .cc.00.01.out
        cmp     [edi + 4], word 0x241C
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
        ; 9 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;>  DD1C24   FSTP QWORD [xSP] |   83C4 FF  ADD ESP, FF
        ;   DD0424   FLD  QWORD [xSP] |
        ;   83C4 FF  ADD  ESP, FF     |
        ; ---------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.01.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xDD241CDD
        jne    .cc.01.out
        cmp     [edi + 4], word 0x2404
        jne    .cc.01.out
        cmp     [edi + 6], word 0xC483
        jne    .cc.01.out
        ; ---------------------------------------------------------
        mov     al, [edi + 8]
        test    al, al
        js     .cc.01.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], al
;       mov     [.esi], 9
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.02.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0xDD241CDD
        jne    .cc.02.out
        cmp     [edi + 4], word 0x2404
        jne    .cc.02.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x002414DD
;       mov     [.esi], 6
        mov     [.edi], 3
        jmp    .cc.momem
   .cc.02.out:
  }
   .cc.02..in:
        SIC_OP.cc.L0.3B.02
   .cc.02..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.add_esp.fstp_st0 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.add_esp.fstp_st0.in:
;       cmp     ebx, 3
;       jne    .cc.add_esp.fstp_st0.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> 83C4 FF   ADD  ESP, FF     |  DDD8      FSTP ST0
        ;  DDD8      FSTP ST0         |  83C4 FF   ADD  ESP, FF
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.add_esp.fstp_st0.out
    else
        jl     .cc.add_esp.fstp_st0.out
    end if
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0xC483
        jne    .cc.add_esp.fstp_st0.out
        cmp     [edi + 3], word 0xD8DD
        jne    .cc.add_esp.fstp_st0.out
        ; ---------------------------------------------------------
        mov     dl, [edi + 2]
        mov     [edi + 0], dword 0xC483D8DD
        mov     [edi + 4], dl
;       mov     [.esi], 5
        mov     [.edi], 5
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.add_esp.fstp_st0.out:
  }
   .cc.add_esp.fstp_st0..in:
        SIC_OP.cc.L0.3B.add_esp.fstp_st0 .static.FSTP.ST0
   .cc.add_esp.fstp_st0..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.3B.add_esp.fpu
  {
   .cc.add_esp.fpu.in:
;       cmp     ebx, 3
;       jne    .cc.add_esp.fpu.out
        ; ---------------------------------------------------------
        ;> 83C4 FF   ADD  ESP, FF     | 3 BYTES
        ;? D***      F***             | 2 BYTES
        ;? D*** FF+  F*** FF+         | 6 BYTES
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0xC483
        jne    .cc.add_esp.fpu.out
        ; ---------------------------------------------------------
        mov     dl, [edi + 3]
        cmp     dl, 0xD8
        jb     .cc.add_esp.fpu.out
        cmp     dl, 0xDF
        ja     .cc.add_esp.fpu.out
        ; ---------------------------------------------------------
        push    edi
        add     edi, 3
        call    SIC_IDA.ida                     ; eax = current instruction size
        pop     edi
        ;
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        cmp     eax, 2
        je     .cc.add_esp.fpu.2B
        cmp     eax, 6
        je     .cc.add_esp.fpu.6B
        jmp    .cc.add_esp.fpu.out
   .cc.add_esp.fpu.2B:
        ; ---------------------------------------------------------
        ; 5 BYTES -> 5 BYTES
        ; ---------------------------------------------------------
        ;> 83C4 FF   ADD  ESP, FF      |  D***      F***
        ;? D8**      F***              |  83C4 FF   ADD  ESP, FF
        ;? D9**      F***              |
        ;? DA**      F***              |
        ;? DB**      F***              |
        ;? DC**      F***              |
        ;? DD**      F***              |
        ;? DE**      F***              |
        ;? DF**      F***              |
        ;+ DD11      FST   QWORD [ECX] |
        ;+ DDC0      FFREE ST0         |
        ;- DDD8      FSTP  ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.add_esp.fpu.out
        ; ---------------------------------------------------------
        mov     dl, [edi + 2]
        mov     ax, [edi + 3]
        cmp     ax, 0xD8DD
        je     .cc.add_esp.fpu.out
;       cmp     ax, 0x11DD
;       je     .cc.add_esp.fpu.out
;       cmp     ax, 0xC0DD
;       je     .cc.add_esp.fpu.out
        mov     [edi + 0], ax
        mov     [edi + 2], word 0xC483
        mov     [edi + 4], dl
;       mov     [.esi], 5
        mov     [.edi], 5
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.add_esp.fpu.6B:
        ; ---------------------------------------------------------
        ; 9 BYTES -> 9 BYTES
        ; ---------------------------------------------------------
        ;> 83C4 FF   ADD  ESP, FF     |  D*** FF+  F*** FF+
        ;? D8** FF+  F*** FF+         |  83C4 FF   ADD  ESP, FF
        ;? D9** FF+  F*** FF+         |
        ;? DA** FF+  F*** FF+         |
        ;? DB** FF+  F*** FF+         |
        ;? DC** FF+  F*** FF+         |
        ;? DD** FF+  F*** FF+         |
        ;? DE** FF+  F*** FF+         |
        ;? DF** FF+  F*** FF+         |
        ; ---------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.add_esp.fpu.out
        ; ---------------------------------------------------------
        mov     dl, [edi + 2]
        mov     ax, [edi + 3]
        mov     [edi + 0], ax
        mov     eax, [edi + 5]
        mov     [edi + 2], eax
        mov     [edi + 6], word 0xC483
        mov     [edi + 8], dl
;       mov     [.esi], 9
        mov     [.edi], 9
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.add_esp.fpu.out:
  }
   .cc.add_esp.fpu..in:
        SIC_OP.cc.L0.3B.add_esp.fpu
   .cc.add_esp.fpu..out:
  $end

  macro SIC_OP.cc.L0.3B.sub_esp_4
  {
   .cc.sub_esp_4.in:
;       cmp     ebx, 3
;       jne    .cc.sub_esp_4.out
        ; ---------------------------------------------------------
        ; 3 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;>    83C4 FC  ADD ESP, -4   |   53       PUSH EBX
        ;>    83EC 04  SUB ESP, +4   |
        ; ---------------------------------------------------------
        mov     [.esi], 3
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.sub_esp_4.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0x83
        jne    .cc.sub_esp_4.out
        mov     ax, [edi + 1]
        case    ax,\
                0xFCC4, .cc.sub_esp_4.match,\
                0x04EC, .cc.sub_esp_4.match
        jmp    .cc.sub_esp_4.out
   .cc.sub_esp_4.match:
        mov     [edi + 0], byte 0x53
;       mov     [.esi], 3
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.sub_esp_4.out:
  }
  $ifdef SIC_OP.ESP_PUSH_POP
   .cc.sub_esp_4..in:
;       SIC_OP.cc.L0.3B.sub_esp_4
   .cc.sub_esp_4..out:
  $end

  macro SIC_OP.cc.L0.3B.add_esp_4
  {
   .cc.add_esp_4.in:
;       cmp     ebx, 3
;       jne    .cc.add_esp_4.out
        ; ---------------------------------------------------------
        ; 3 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;>    83C4 04  ADD ESP, +4   |   5*       POP E*X
        ;>    83EC FC  SUB ESP, -4   |
        ;?    B8 4B    MOV EAX, 4B   |
        ;?    B9 4B    MOV ECX, 4B   |
        ;?    BA 4B    MOV EDX, 4B   |
        ;?    31C0     XOR EAX, EAX  |
        ;?    31C9     XOR ECX, ECX  |
        ;?    31D2     XOR EDX, EDX  |
        ; ---------------------------------------------------------
        mov     [.esi], 3
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.add_esp_4.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0x83
        jne    .cc.add_esp_4.out
        mov     ax, [edi + 1]
        case    ax,\
                0x04C4, .cc.add_esp_4.match,\
                0xFCEC, .cc.add_esp_4.match
        jmp    .cc.add_esp_4.out
   .cc.add_esp_4.match:
        mov     ax, [edi + 3]
        case    al,\
                0xB8, .cc.add_esp_4.eax,\
                0xB9, .cc.add_esp_4.ecx,\
                0xBA, .cc.add_esp_4.edx
        case    ax,\
                0xC031, .cc.add_esp_4.eax,\
                0xC931, .cc.add_esp_4.ecx,\
                0xD231, .cc.add_esp_4.edx
        jmp    .cc.add_esp_4.out
   .cc.add_esp_4.eax:
        ; ---------------------------------------------------------
        ; 3 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> ... | 58  POP EAX
        ; ---------------------------------------------------------
        mov     [edi + 0], byte 0x58
;       mov     [.esi], 3
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.add_esp_4.ecx:
        ; ---------------------------------------------------------
        ; 3 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> ... | 59  POP ECX
        ; ---------------------------------------------------------
        mov     [edi + 0], byte 0x59
;       mov     [.esi], 3
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.add_esp_4.edx:
        ; ---------------------------------------------------------
        ; 3 BYTES -> 1 BYTES
        ; ---------------------------------------------------------
        ;> ... | 5A  POP EDX
        ; ---------------------------------------------------------
        mov     [edi + 0], byte 0x5A
;       mov     [.esi], 3
        mov     [.edi], 1
        jmp    .cc.momem
   .cc.add_esp_4.out:
  }
  $ifdef SIC_OP.ESP_PUSH_POP
   .cc.add_esp_4..in:
;       SIC_OP.cc.L0.3B.add_esp_4
   .cc.add_esp_4..out:
  $end

  macro SIC_OP.cc.L0.3B.esp_eax
  {
   .cc.esp_eax.in:
;       cmp     ebx, 3
;       jne    .cc.esp_eax.out
        ; ---------------------------------------------------------
        ; 6 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;> 890424  MOV [ESP], EAX | 890424  MOV [ESP], EAX
        ;> 8B0424  MOV EAX, [ESP] |
        ; ---------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.esp_eax.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0x8B240489
        jne    .cc.esp_eax.out
        cmp     [edi + 4], word 0x2404
        jne    .cc.esp_eax.out
        ; ---------------------------------------------------------
;       mov     [.esi], 6
        mov     [.edi], 3
        jmp    .cc.momem
   .cc.esp_eax.out:
  }
   .cc.esp_eax..in:
        SIC_OP.cc.L0.3B.esp_eax
   .cc.esp_eax..out:

   .cc.L0.3B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 4
        jne    .cc.L0.4B.out
   .cc.L0.4B:

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
        cmp     [edi + 00], dword 0xC0245CDD
        jne    .cc.fstp.xmm.out
        cmp     [edi + 04], dword 0x44100FF2
        jne    .cc.fstp.xmm.out
        cmp     [edi + 08], dword 0x0FF2C024
        jne    .cc.fstp.xmm.out
        cmp     [edi + 11], dword 0x2404110F
        jne    .cc.fstp.xmm.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0xF2241CDD
        mov     [edi + 04], dword 0x2404100F
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.02.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x44DD
        jne    .cc.fxch.02.out
        cmp     [edi + 2], byte 0x24
        jne    .cc.fxch.02.out
        cmp     [edi + 4], word 0x44DD
        jne    .cc.fxch.02.out
        cmp     [edi + 6], byte 0x24
        jne    .cc.fxch.02.out
        cmp     [edi + 8], word 0xC9D9
        jne    .cc.fxch.02.out
        ; ---------------------------------------------------------
        mov     edx, dword [edi + 0]
        mov     eax, dword [edi + 4]
        ; ---------------------------------------------------------
        mov     [edi + 0], eax
        mov     [edi + 4], edx
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
  macro SIC_OP.cc.L0.4B.fxch.05
  {
   .cc.fxch.05.in:
;       cmp     ebx, 4
;       jne    .cc.fxch.05.out
        ; --------------------------------------------------------------------------
        ; 12 BYTES -> 10 BYTES
        ; --------------------------------------------------------------------------
        ;> DD4424 BB   FLD QWORD [xSP + BB] | DD05   AA+  FLD QWORD [AA+]
        ;  DD05   AA+  FLD QWORD [AA+]      | DD4424 BB   FLD QWORD [xSP + BB]
        ;  D9C9        FXCH                 |
        ; --------------------------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.05.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0x44DD
        jne    .cc.fxch.05.out
        cmp     [edi + 02], byte 0x24
        jne    .cc.fxch.05.out
        cmp     [edi + 04], word 0x05DD
        jne    .cc.fxch.05.out
        cmp     [edi + 10], word 0xC9D9
        jne    .cc.fxch.05.out
        ; ---------------------------------------------------------
        mov     edx, dword [edi + 00]
        mov     eax, dword [edi + 06]
        ; ---------------------------------------------------------
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], edx
;       mov     [.esi], 12
        mov     [.edi], 10
        jmp    .cc.momem
   .cc.fxch.05.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.05..in:
        SIC_OP.cc.L0.4B.fxch.05
   .cc.fxch.05..out:
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.08.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x44DD
        jne    .cc.fxch.08.out
        cmp     [edi + 2], byte 0x24
        jne    .cc.fxch.08.out
        mov     dx, word [edi + 4]
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
        cmp     [edi + 6], word 0xC9D9
        jne    .cc.fxch.08.out
        ; ---------------------------------------------------------
        mov     eax, dword [edi + 0]
        ; ---------------------------------------------------------
        mov     [edi + 0], dx
        mov     [edi + 2], eax
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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.b.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x44DD
        jne    .cc.b.out
        cmp     [edi + 2], byte 0x24
        jne    .cc.b.out
        cmp     [edi + 4], byte 0xDE
        jne    .cc.b.out
        ; ---------------------------------------------------------
        mov     dl, [edi + 5]
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
        mov     [edi + 0], byte 0xDC
        mov     [edi + 1], ah
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
        ; 10 BYTES -> 3 BYTES
        ; ---------------------------------------------------------
        ;> DD442408  FLD  QWORD [xSP+8] | 83C408    ADD  ESP, 8
        ;  83C408    ADD  ESP, 8        |
        ;  DD1C24    FSTP QWORD [xSP]   |
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.00.02.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0x082444DD
        jne    .cc.00.02.out
        cmp     [edi + 4], dword 0xDD08C483
        jne    .cc.00.02.out
        cmp     [edi + 8], word 0x241C
        jne    .cc.00.02.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], byte 0x08
;       mov     [.esi], 10
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.00.02.out:
  }
   .cc.00.02..in:
        SIC_OP.cc.L0.4B.00.02
   .cc.00.02..out:
  $end

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
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.movsd.xmm.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0x04100FF2
        jne    .cc.movsd.xmm.out
        cmp     [edi + 04], dword 0x100FF224
        jne    .cc.movsd.xmm.out
        cmp     [edi + 08], word 0x2404
        jne    .cc.movsd.xmm.out
        ; ---------------------------------------------------------
        mov     [edi + 00], dword 0x04100FF2
        mov     [edi + 04], byte 0x24
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

  $ifndef _SSEX
  macro SIC_OP.cc.L0.5B.con.I0
  {
   .cc.con.I0.in:
;       cmp     ebx, 5
;       jne    .cc.con.I0.out
        ; ---------------------------------------------------------
        ; 12 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> B8 00000000  MOV  EAX, 0      | D9EE  FLDZ
        ;  50           PUSH EAX         |
        ;  DB0424       FILD DWORD [ESP] |
        ;  83C404       ADD  ESP, 4      |
        ; ---------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.con.I0.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], byte 0xB8
        jne    .cc.con.I0.out
        cmp     [edi + 01], dword 0x00000000
        jne    .cc.con.I0.out
        cmp     [edi + 05], dword 0x2404DB50
        jne    .cc.con.I0.out
        cmp     [edi + 08], dword 0x04C48324
        jne    .cc.con.I0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xEED9
;       mov     [.esi], 12
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.I0.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.I0..in:
        SIC_OP.cc.L0.5B.con.I0
   .cc.step.con.I0..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.5B.con.I1
  {
   .cc.con.I1.in:
;       cmp     ebx, 5
;       jne    .cc.con.I1.out
        ; ---------------------------------------------------------
        ; 12 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> B8 01000000  MOV  EAX, 1      | D9E8  FLD1
        ;  50           PUSH EAX         |
        ;  DB0424       FILD DWORD [ESP] |
        ;  83C404       ADD  ESP, 4      |
        ; ---------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.con.I1.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], byte 0xB8
        jne    .cc.con.I1.out
        cmp     [edi + 01], dword 0x00000001
        jne    .cc.con.I1.out
        cmp     [edi + 05], dword 0x2404DB50
        jne    .cc.con.I1.out
        cmp     [edi + 08], dword 0x04C48324
        jne    .cc.con.I1.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xE8D9
;       mov     [.esi], 12
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.I1.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.I1..in:
        SIC_OP.cc.L0.5B.con.I1
   .cc.step.con.I1..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.5B.con.0
  {
   .cc.con.0.in:
;       cmp     ebx, 5
;       jne    .cc.con.0.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> BA 00000000  MOV  EDX, 0.HI   | D9EE  FLDZ
        ;  B9 00000000  MOV  ECX, 0.LO   |
        ;  52           PUSH EDX         |
        ;  51           PUSH ECX         |
        ;  DD0424       FLD  QWORD [ESP] |
        ;  83C408       ADD  ESP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.con.0.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .cc.con.0.out
        cmp     [edi + 01], dword 0x00000000
        jne    .cc.con.0.out
        cmp     [edi + 05], byte 0xB9
        jne    .cc.con.0.out
        cmp     [edi + 06], dword 0x00000000
        jne    .cc.con.0.out
        cmp     [edi + 10], dword 0x04DD5152
        jne    .cc.con.0.out
        cmp     [edi + 14], dword 0x08C48324
        jne    .cc.con.0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xEED9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.0.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.0..in:
        SIC_OP.cc.L0.5B.con.0
   .cc.step.con.0..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.5B.con.1
  {
   .cc.con.1.in:
;       cmp     ebx, 5
;       jne    .cc.con.1.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> BA 0000F03F  MOV  EDX, 1.HI   | D9E8  FLD1
        ;  B9 00000000  MOV  ECX, 1.LO   |
        ;  52           PUSH EDX         |
        ;  51           PUSH ECX         |
        ;  DD0424       FLD  QWORD [ESP] |
        ;  83C408       ADD  ESP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.con.1.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .cc.con.1.out
        cmp     [edi + 01], dword 0x3FF00000
        jne    .cc.con.1.out
        cmp     [edi + 05], byte 0xB9
        jne    .cc.con.1.out
        cmp     [edi + 06], dword 0x00000000
        jne    .cc.con.1.out
        cmp     [edi + 10], dword 0x04DD5152
        jne    .cc.con.1.out
        cmp     [edi + 14], dword 0x08C48324
        jne    .cc.con.1.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xE8D9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.1.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.1..in:
        SIC_OP.cc.L0.5B.con.1
   .cc.step.con.1..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.5B.con.pi
  {
   .cc.con.pi.in:
;       cmp     ebx, 5
;       jne    .cc.con.pi.out
        ; ---------------------------------------------------------
        ; 18 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;> BA FB210940  MOV  EDX, PI.HI  | D9EB  FLDPI
        ;  B9 182D4454  MOV  ECX, PI.LO  |
        ;  52           PUSH EDX         |
        ;  51           PUSH ECX         |
        ;  DD0424       FLD  QWORD [ESP] |
        ;  83C408       ADD  ESP, 8      |
        ; ---------------------------------------------------------
        mov     [.esi], 18
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.con.pi.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .cc.con.pi.out
        cmp     [edi + 01], dword 0x400921FB
        jne    .cc.con.pi.out
        cmp     [edi + 05], byte 0xB9
        jne    .cc.con.pi.out
        cmp     [edi + 06], dword 0x54442D18
        jne    .cc.con.pi.out
        cmp     [edi + 10], dword 0x04DD5152
        jne    .cc.con.pi.out
        cmp     [edi + 14], dword 0x08C48324
        jne    .cc.con.pi.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xEBD9
;       mov     [.esi], 18
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.con.pi.out:
  }
    $ifdef SIC_OP.LOAD_CONST
   .cc.step.con.pi..in:
        SIC_OP.cc.L0.5B.con.pi
   .cc.step.con.pi..out:
    $end
  $end

  $ifdef _SSEX
  macro SIC_OP.cc.L0.5B.mov_edx_eax_0_xmm0
  {
   .cc.mov_edx_eax_0_xmm0.in:
;       cmp     ebx, 5
;       jne    .cc.mov_edx_eax_0_xmm0.out
        ; ---------------------------------------------------------
        ; 17 BYTES -> 8 BYTES
        ; ---------------------------------------------------------
        ;>  BA 00+          MOV   EDX, 00+
        ;   B9 00+          MOV   ECX, 00+
        ;   52              PUSH  EDX
        ;   51              PUSH  ECX
        ;   F2 0F 10 04 24  MOVSD XMM0, QWORD [ESP]
        ; ---------------------------------------------------------
        ;>  31 C9           XOR   ECX, ECX
        ;   51              PUSH  ECX
        ;   51              PUSH  ECX
        ;   66 0F 57 C0     XORPD XMM0, XMM0
        ; ---------------------------------------------------------
        mov     [.esi], 17
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.mov_edx_eax_0_xmm0.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], dword 0x000000BA
        jne    .cc.mov_edx_eax_0_xmm0.out
        cmp     [edi + 04], dword 0x0000B900
        jne    .cc.mov_edx_eax_0_xmm0.out
        cmp     [edi + 08], dword 0x51520000
        jne    .cc.mov_edx_eax_0_xmm0.out
        cmp     [edi + 12], dword 0x04100FF2
        jne    .cc.mov_edx_eax_0_xmm0.out
        cmp     [edi + 16], byte 0x24
        jne    .cc.mov_edx_eax_0_xmm0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x5151C931
        mov     [edi + 4], dword 0xC0570F66
;       mov     [.esi], 17
        mov     [.edi], 8
        jmp    .cc.momem
   .cc.mov_edx_eax_0_xmm0.out:
  }
   .cc.mov_edx_eax_0_xmm0..in:
        SIC_OP.cc.L0.5B.mov_edx_eax_0_xmm0
   .cc.mov_edx_eax_0_xmm0..out:
  $end

  macro SIC_OP.cc.L0.5B.mov_edx_eax_0
  {
   .cc.mov_edx_eax_0.in:
;       cmp     ebx, 5
;       jne    .cc.mov_edx_eax_0.out
        ; ---------------------------------------------------------
        ; 12 BYTES -> 4 BYTES
        ; ---------------------------------------------------------
        ;>  BA 00+   MOV  EDX, 00+    |   31C9     XOR  ECX, ECX
        ;   B9 00+   MOV  ECX, 00+    |   51       PUSH ECX
        ;   52       PUSH EDX         |   51       PUSH ECX
        ;   51       PUSH ECX         |
        ; ---------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.mov_edx_eax_0.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], dword 0x000000BA
        jne    .cc.mov_edx_eax_0.out
        cmp     [edi + 4], dword 0x0000B900
        jne    .cc.mov_edx_eax_0.out
        cmp     [edi + 8], dword 0x51520000
        jne    .cc.mov_edx_eax_0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], dword 0x5151C931
;       mov     [.esi], 12
        mov     [.edi], 4
        jmp    .cc.momem
   .cc.mov_edx_eax_0.out:
  }
   .cc.mov_edx_eax_0..in:
        SIC_OP.cc.L0.5B.mov_edx_eax_0
   .cc.mov_edx_eax_0..out:

  macro SIC_OP.cc.L0.5B.mov_eax_0
  {
   .cc.mov_eax_0.in:
;       cmp     ebx, 5
;       jne    .cc.mov_eax_0.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  B8 00+   MOV  EAX, 00+    |   31C0     XOR  EAX, EAX
        ;-  83D0 00  ADC  EAX, 0
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.mov_eax_0.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0xB8
        jne    .cc.mov_eax_0.out
        cmp     [edi + 1], dword 0x00000000
        jne    .cc.mov_eax_0.out
        cmp     [edi + 4], dword 0x00D08300
        je     .cc.mov_eax_0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC031
;       mov     [.esi], 5
        mov     [.edi], 2
       .instr.shift.back 2                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_eax_0.out:
  }
   .cc.mov_eax_0..in:
        SIC_OP.cc.L0.5B.mov_eax_0
   .cc.mov_eax_0..out:

  macro SIC_OP.cc.L0.5B.mov_edx_0
  {
   .cc.mov_edx_0.in:
;       cmp     ebx, 5
;       jne    .cc.mov_edx_0.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  BA 00+   MOV  EDX, 00+    |   31D2     XOR  EDX, EDX
        ;-  83D2 00  ADC  EDX, 0
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.mov_edx_0.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0xBA
        jne    .cc.mov_edx_0.out
        cmp     [edi + 1], dword 0x00000000
        jne    .cc.mov_edx_0.out
        cmp     [edi + 4], dword 0x00D28300
        je     .cc.mov_edx_0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xD231
;       mov     [.esi], 5
        mov     [.edi], 2
       .instr.shift.back 2                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_edx_0.out:
  }
   .cc.mov_edx_0..in:
        SIC_OP.cc.L0.5B.mov_edx_0
   .cc.mov_edx_0..out:

  macro SIC_OP.cc.L0.5B.mov_ecx_0
  {
   .cc.mov_ecx_0.in:
;       cmp     ebx, 5
;       jne    .cc.mov_ecx_0.out
        ; ---------------------------------------------------------
        ; 5 BYTES -> 2 BYTES
        ; ---------------------------------------------------------
        ;>  B9 00+   MOV  ECX, 00+    |   31C9     XOR  ECX, ECX
        ;-  83D1 00  ADC  ECX, 0
        ; ---------------------------------------------------------
        mov     [.esi], 5
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.mov_ecx_0.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], byte 0xB9
        jne    .cc.mov_ecx_0.out
        cmp     [edi + 1], dword 0x00000000
        jne    .cc.mov_ecx_0.out
        cmp     [edi + 4], dword 0x00D18300
        je     .cc.mov_ecx_0.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0xC931
;       mov     [.esi], 5
        mov     [.edi], 2
       .instr.shift.back 2                      ; instruction shift back
        jmp    .cc.momem
   .cc.mov_ecx_0.out:
  }
   .cc.mov_ecx_0..in:
        SIC_OP.cc.L0.5B.mov_ecx_0
   .cc.mov_ecx_0..out:

  $ifndef _SSEX
  macro SIC_OP.cc.L0.5B.10
  {
   .cc.10.in:
;       cmp     ebx, 5
;       jne    .cc.10.out
        ; -------------------------------------------------------------------------
        ;>B9 AAAAAAAA  MOV  ECX, AAAAAAAA    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; ...                                |
        ; -------------------------------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .cc.10.out
        cmp     [edi + 05], dword 0xFF0471FF
        jne    .cc.10.out
        cmp     [edi + 09], byte 0x31
        jne    .cc.10.out
        cmp     [edi + 10], byte 0xB9
        je     .cc.10.02
   .cc.10..01:
        ; -------------------------------------------------------------------------
        ; 13 BYTES -> 9 BYTES
        ; -------------------------------------------------------------------------
        ;>B9 AAAAAAAA  MOV  ECX, AAAAAAAA    | DD05 AAAAAAAA  FLD QWORD [AAAAAAAA]
        ; FF71 04      PUSH DWORD [ECX + 4]  | 83C4 F8        ADD ESP, -08
        ; FF31         PUSH DWORD [ECX]      |
        ; DD0424       FLD  QWORD [ESP]      |
        ; -------------------------------------------------------------------------
        cmp     [edi + 10], word 0x04DD
        jne    .cc.10.out
        cmp     [edi + 12], byte 0x24
        jne    .cc.10.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 13
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.10.out
        ; ---------------------------------------------------------
        mov     eax, [edi + 01]
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0xC483
        mov     [edi + 08], byte 0xF8
;       mov     [.esi], 13
        mov     [.edi], 9
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.10.02:
        ; -------------------------------------------------------------------------
        ;>B9 BBBBBBBB  MOV  ECX, BBBBBBBB    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; B9 AAAAAAAA  MOV  ECX, AAAAAAAA    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; ...                                |
        ; -------------------------------------------------------------------------
        cmp     [edi + 15], dword 0xFF0471FF
        jne    .cc.10.out
        cmp     [edi + 19], byte 0x31
        jne    .cc.10.out
        cmp     [edi + 20], byte 0xB9
        je     .cc.10.03
   .cc.10..02:
        ; -------------------------------------------------------------------------
        ; 27 BYTES -> 15 BYTES
        ; -------------------------------------------------------------------------
        ;>B9 BBBBBBBB  MOV  ECX, BBBBBBBB    | DD05 AAAAAAAA  FLD QWORD [AAAAAAAA]
        ; FF71 04      PUSH DWORD [ECX + 4]  | DD05 BBBBBBBB  FLD QWORD [BBBBBBBB]
        ; FF31         PUSH DWORD [ECX]      | 83C4 F0        ADD ESP, -16
        ; B9 AAAAAAAA  MOV  ECX, AAAAAAAA    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; DD0424       FLD  QWORD [ESP]      |
        ; DD4424 08    FLD  QWORD [ESP + 8]  |
        ; -------------------------------------------------------------------------
        cmp     [edi + 20], dword 0xDD2404DD
        jne    .cc.10.out
        cmp     [edi + 24], word 0x2444
        jne    .cc.10.out
        cmp     [edi + 26], byte 0x08
        jne    .cc.10.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 27
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.10.out
        ; ---------------------------------------------------------
        mov     edx, [edi + 01]
        mov     eax, [edi + 11]
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0x05DD
        mov     [edi + 08], edx
        mov     [edi + 12], word 0xC483
        mov     [edi + 14], byte 0xF0
;       mov     [.esi], 27
        mov     [.edi], 15
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.10.03:
        ; -------------------------------------------------------------------------
        ;>B9 CCCCCCCC  MOV  ECX, CCCCCCCC    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; B9 BBBBBBBB  MOV  ECX, BBBBBBBB    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; B9 AAAAAAAA  MOV  ECX, AAAAAAAA    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; ...                                |
        ; -------------------------------------------------------------------------
        cmp     [edi + 25], dword 0xFF0471FF
        jne    .cc.10.out
        cmp     [edi + 29], byte 0x31
        jne    .cc.10.out
   .cc.10..03:
        ; -------------------------------------------------------------------------
        ; 41 BYTES -> 21 BYTES
        ; -------------------------------------------------------------------------
        ;>B9 CCCCCCCC  MOV  ECX, CCCCCCCC    | DD05 AAAAAAAA  FLD QWORD [AAAAAAAA]
        ; FF71 04      PUSH DWORD [ECX + 4]  | DD05 BBBBBBBB  FLD QWORD [BBBBBBBB]
        ; FF31         PUSH DWORD [ECX]      | DD05 CCCCCCCC  FLD QWORD [CCCCCCCC]
        ; B9 BBBBBBBB  MOV  ECX, BBBBBBBB    | 83C4 E8        ADD ESP, -24
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; B9 AAAAAAAA  MOV  ECX, AAAAAAAA    |
        ; FF71 04      PUSH DWORD [ECX + 4]  |
        ; FF31         PUSH DWORD [ECX]      |
        ; DD0424       FLD  QWORD [ESP]      |
        ; DD4424 08    FLD  QWORD [ESP + 8]  |
        ; DD4424 10    FLD  QWORD [ESP + 16] |
        ; -------------------------------------------------------------------------
        cmp     [edi + 30], dword 0xDD2404DD
        jne    .cc.10.out
        cmp     [edi + 34], dword 0xDD082444
        jne    .cc.10.out
        cmp     [edi + 38], word 0x2444
        jne    .cc.10.out
        cmp     [edi + 40], byte 0x10
        jne    .cc.10.out
        ; -------------------------------------------------------------------------
        mov     [.esi], 41
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.10.out
        ; ---------------------------------------------------------
        push    ecx
        mov     ecx, [edi + 01]
        mov     edx, [edi + 11]
        mov     eax, [edi + 21]
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0x05DD
        mov     [edi + 08], edx
        mov     [edi + 12], word 0x05DD
        mov     [edi + 14], ecx
        mov     [edi + 18], word 0xC483
        mov     [edi + 20], byte 0xE8
        pop     ecx
;       mov     [.esi], 41
        mov     [.edi], 21
       .instr.shift.back 3                       ; instruction shift back
        jmp    .cc.momem
   .cc.10.out:
  }
   .cc.10..in:
        SIC_OP.cc.L0.5B.10
   .cc.10..out:
  $end

   .cc.L0.5B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 6
        jne    .cc.L0.6B.out
   .cc.L0.6B:

  $ifdef _SSEX
  macro SIC_OP.cc.L0.6B.espB.xop
  {
   .cc.6B.espB.xop.in:
;       cmp     ebx, 6
;       jne    .cc.6B.espB.xop.out
        ; ---------------------------------------------------------
        ; 10 BYTES
        ; ---------------------------------------------------------
        ;> 81 C4 FF+           ADD   ESP, FF+
        ; ?F2 0F ** **         **
        ; ?66 0F ** **         **
        ; ---------------------------------------------------------
        ; 10 BYTES -> 10 BYTES
        ; ---------------------------------------------------------
        ;>?F2 0F ** **         **
        ; ?66 0F ** **         **
        ;  81 C4 FF+           ADD   ESP, FF+
        ; ---------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.6B.espB.xop.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0xC481
        jne    .cc.6B.espB.xop.out
        cmp     [edi + 06], word 0x0FF2
        je     .cc.6B.espB.xop.next
        cmp     [edi + 06], word 0x0F66
        jne    .cc.6B.espB.xop.out
   .cc.6B.espB.xop.66.0F:
        ; ---------------------------------------------------------
        ;> 81 C4 FF+           ADD   ESP, FF+
        ; ?66 0F ** **         **
        ; -66 0F 2F **         COMISD
        ; -66 0F 2E **         UCOMISD
        ; ---------------------------------------------------------
        mov     al, byte [edi + 08]
        case    al,\
                0x2F, .cc.6B.espB.xop.out,\
                0x2E, .cc.6B.espB.xop.out
   .cc.6B.espB.xop.next:
        push    edi
        add     edi, [.cisize]
        call    SIC_IDA.ida                     ; eax = current instruction size
        pop     edi
        ;
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        cmp     eax, 4
        jne    .cc.6B.espB.xop.out
   .cc.6B.espB.xop.main:
        ; ---------------------------------------------------------
        mov     eax, dword [edi + 02]
        mov     edx, dword [edi + 06]
        mov     [edi + 00], edx
        mov     [edi + 04], word 0xC481
        mov     [edi + 06], eax
        ; ---------------------------------------------------------
;       mov     [.esi], 10
        mov     [.edi], 10
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.6B.espB.xop.out:
  }
   .cc.6B.espB.xop..in:
        SIC_OP.cc.L0.6B.espB.xop
   .cc.6B.espB.xop..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.6B.fst_mem static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.fst_mem.in:
;       cmp     ebx, 6
;       jne    .cc.fst_mem.out
        ; ---------------------------------------------------------
        ; 8 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;> DD15 AA+  FST  QWORD [AA+] |  DD1D AA+  FSTP QWORD [AA+]
        ;  DDD8      FSTP ST0         |
        ; ---------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; ecx = bytes to copy
        ; ---------------------------------------------------------
    if static.FSTP.ST0 eq 1
        jle    .cc.fst_mem.out
    else
        jl     .cc.fst_mem.out
    end if
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x15DD
        jne    .cc.fst_mem.out
        cmp     [edi + 6], word 0xD8DD
        jne    .cc.fst_mem.out
        ; ---------------------------------------------------------
        mov     [edi + 1], byte 0x1D
;       mov     [.esi], 8
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.fst_mem.out:
  }
   .cc.fst_mem..in:
        SIC_OP.cc.L0.6B.fst_mem .static.FSTP.ST0
   .cc.fst_mem..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.6B.fxch.03
  {
   .cc.fxch.03.in:
;       cmp     ebx, 6
;       jne    .cc.fxch.03.out
        ; --------------------------------------------------------------------------
        ; 12 BYTES -> 10 BYTES
        ; --------------------------------------------------------------------------
        ;> DD05   BB+  FLD QWORD [BB+]      | DD4424 AA   FLD QWORD [xSP + AA]
        ;  DD4424 AA   FLD QWORD [xSP + AA] | DD05   BB+  FLD QWORD [BB+]
        ;  D9C9        FXCH                 |
        ; --------------------------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.03.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0x05DD
        jne    .cc.fxch.03.out
        cmp     [edi + 06], word 0x44DD
        jne    .cc.fxch.03.out
        cmp     [edi + 08], byte 0x24
        jne    .cc.fxch.03.out
        cmp     [edi + 10], word 0xC9D9
        jne    .cc.fxch.03.out
        ; ---------------------------------------------------------
        mov     edx, dword [edi + 00]
        mov     eax, dword [edi + 06]
        ; ---------------------------------------------------------
        mov     [edi + 00], eax
        mov     [edi + 04], word 0x05DD
        mov     [edi + 06], edx
;       mov     [.esi], 12
        mov     [.edi], 10
        jmp    .cc.momem
   .cc.fxch.03.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.03..in:
        SIC_OP.cc.L0.6B.fxch.03
   .cc.fxch.03..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.6B.fxch.06
  {
   .cc.fxch.06.in:
;       cmp     ebx, 6
;       jne    .cc.fxch.06.out
        ; --------------------------------------------------------------------------
        ; 14 BYTES -> 12 BYTES
        ; --------------------------------------------------------------------------
        ;> DD05 BB+  FLD QWORD [BB+] | DD05 AA+  FLD QWORD [AA+]
        ;  DD05 AA+  FLD QWORD [AA+] | DD05 BB+  FLD QWORD [BB+]
        ;  D9C9      FXCH            |
        ; --------------------------------------------------------------------------
        mov     [.esi], 14
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.06.out
        ; ---------------------------------------------------------
        cmp     [edi + 00], word 0x05DD
        jne    .cc.fxch.06.out
        cmp     [edi + 06], word 0x05DD
        jne    .cc.fxch.06.out
        cmp     [edi + 12], word 0xC9D9
        jne    .cc.fxch.06.out
        ; ---------------------------------------------------------
        mov     edx, dword [edi + 02]
        mov     eax, dword [edi + 08]
        ; ---------------------------------------------------------
        mov     [edi + 00], word 0x05DD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0x05DD
        mov     [edi + 08], edx
;       mov     [.esi], 14
        mov     [.edi], 12
        jmp    .cc.momem
   .cc.fxch.06.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.06..in:
        SIC_OP.cc.L0.6B.fxch.06
   .cc.fxch.06..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.6B.fxch.09
  {
   .cc.fxch.09.in:
;       cmp     ebx, 6
;       jne    .cc.fxch.09.out
        ; --------------------------------------------------------------------------
        ; 10 BYTES -> 8 BYTES
        ; --------------------------------------------------------------------------
        ;> DD05 AA+  FLD QWORD [AA+] |? D9E8      FLD1
        ;? D9E8      FLD1            |? D9E9      FLDL2T
        ;? D9E9      FLDL2T          |? D9EA      FLDL2E
        ;? D9EA      FLDL2E          |? D9EB      FLDPI
        ;? D9EB      FLDPI           |? D9EC      FLDLG2
        ;? D9EC      FLDLG2          |? D9ED      FLDLN2
        ;? D9ED      FLDLN2          |? D9EE      FLDZ
        ;? D9EE      FLDZ            |  DD05 AA+  FLD QWORD [AA+]
        ;  D9C9      FXCH            |
        ; --------------------------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fxch.09.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x05DD
        jne    .cc.fxch.09.out
        mov     dx, word [edi + 6]
        case    dx,\
                0xE8D9, .cc.fxch.09.match,\
                0xE9D9, .cc.fxch.09.match,\
                0xEAD9, .cc.fxch.09.match,\
                0xEBD9, .cc.fxch.09.match,\
                0xECD9, .cc.fxch.09.match,\
                0xEDD9, .cc.fxch.09.match,\
                0xEED9, .cc.fxch.09.match
        jmp    .cc.fxch.09.out
   .cc.fxch.09.match:
        cmp     [edi + 8], word 0xC9D9
        jne    .cc.fxch.09.out
        ; ---------------------------------------------------------
        mov     eax, dword [edi + 2]
        ; ---------------------------------------------------------
        mov     [edi + 0], dx
        mov     [edi + 2], word 0x05DD
        mov     [edi + 4], eax
;       mov     [.esi], 10
        mov     [.edi], 8
        jmp    .cc.momem
   .cc.fxch.09.out:
  }
    $ifdef SIC_OP.FXCH
   .cc.fxch.09..in:
        SIC_OP.cc.L0.6B.fxch.09
   .cc.fxch.09..out:
    $end
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.6B.c
  {
   .cc.c.in:
;       cmp     ebx, 6
;       jne    .cc.c.out
        ; --------------------------------------------------------------------------
        ; 8 BYTES -> 6 BYTES
        ; --------------------------------------------------------------------------
        ;>DD05 BB+   FLD QWORD [BB+]       |?DC05 BB+   FADD  QWORD [BB+]
        ;?DEC1       FADDP                 |?DC25 BB+   FSUB  QWORD [BB+]
        ;?DEE9       FSUBP                 |?DC2D BB+   FSUBR QWORD [BB+]
        ;?DEE1       FSUBRP                |?DC0D BB+   FMUL  QWORD [BB+]
        ;?DEC9       FMULP                 |?DC35 BB+   FDIV  QWORD [BB+]
        ;?DEF9       FDIVP                 |?DC3D BB+   FDIVR QWORD [BB+]
        ;?DEF1       FDIVRP                |
        ; --------------------------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.c.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x05DD
        jne    .cc.c.out
        cmp     [edi + 6], byte 0xDE
        jne    .cc.c.out
        ; ---------------------------------------------------------
        mov     dl, [edi + 7]
        case    dl,\
                0xC1, .cc.c.addp,\
                0xE9, .cc.c.subp,\
                0xE1, .cc.c.subrp,\
                0xC9, .cc.c.mulp,\
                0xF9, .cc.c.divp,\
                0xF1, .cc.c.divrp
        jmp    .cc.c.out
        ; ---------------------------------------------------------
   .cc.c.addp:
        mov     ah, 0x05
        jmp    .cc.c.set
   .cc.c.subp:
        mov     ah, 0x25
        jmp    .cc.c.set
   .cc.c.subrp:
        mov     ah, 0x2D
        jmp    .cc.c.set
   .cc.c.mulp:
        mov     ah, 0x0D
        jmp    .cc.c.set
   .cc.c.divp:
        mov     ah, 0x35
        jmp    .cc.c.set
   .cc.c.divrp:
        mov     ah, 0x3D
        jmp    .cc.c.set
        ; ---------------------------------------------------------
   .cc.c.set:
        mov     [edi + 0], byte 0xDC
        mov     [edi + 1], ah
;       mov     [.esi], 8
        mov     [.edi], 6
        jmp    .cc.momem
   .cc.c.out:
  }
   .cc.c..in:
        SIC_OP.cc.L0.6B.c
   .cc.c..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L0.6B.03
  {
   .cc.03.in:
;       cmp     ebx, 6
;       jne    .cc.03.out
        ; ---------------------------------------------------------
        ; 12 BYTES -> 6 BYTES
        ; ---------------------------------------------------------
        ;> DD 1D AA AA AA AA  FSTP QWORD [AA+]
        ;  DD 05 AA AA AA AA  FLD  QWORD [AA+]
        ; ---------------------------------------------------------
        ;> DD 15 AA AA AA AA  FST  QWORD [AA+]
        ; ---------------------------------------------------------
        mov     [.esi], 12
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.03.out
        ; ---------------------------------------------------------
        cmp     [edi + 0], word 0x1DDD
        jne    .cc.03.out
        cmp     [edi + 6], word 0x05DD
        jne    .cc.03.out
        mov     eax, [edi + 2]
        mov     edx, [edi + 8]
        cmp     eax, edx
        jne    .cc.03.out
        ; ---------------------------------------------------------
        mov     [edi + 0], word 0x15DD
        mov     [edi + 2], eax
;       mov     [.esi], 12
        mov     [.edi], 6
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.03.out:
  }
   .cc.03..in:
;       SIC_OP.cc.L0.6B.03
   .cc.03..out:
  $end

   .cc.L0.6B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
   .cc.momem:
        add     edi, [.edi]                     ; edi = destination memory
        cmp     edi, esi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     edi, [.xdi]
        add     edi, [.edi]
        mov     ecx, [.esi]
        sub     ecx, [.edi]
        sub     [.ezx], ecx
        sub     [.ecx], ecx
        sub     [.ebx], ecx
        jle    .cc.result
        mov     eax, [.misize]
        jmp    .cc.next.edi

   .cc.next:
        mov     eax, [.cisize]
   .cc.next.edi:
        add     edi, eax                        ; edi = next instruction
        sub     [.ebx], eax
;       cmp     [.ebx], 0
        jg     .cc.root

   .cc.result:
        mov     eax, [.ezx]

   .cc.return:
        pop     edi esi ebx
        ret

        ; -> [.esi] - initial bytes
        ; <- ecx    - bytes to copy
        ; <- esi    - source memory
   .cc.size:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.L2, code, csize, rcode

       .static.FSTP.ST0 EQU 0
       .static.FREE.ST0 EQU 0

    locals
       .ebx     dd ?
       .edi     dd ?
       .eee     dd ?
       .zzz     dd ?
       .esi     dd ?
       .ezx     dd ?
       .ecx     dd ?
       .xcx     dd ?
       .xdi     dd ?
       .xsi     dd ?
       .misize  dd ?
       .cisize  dd ?                            ; current instruction size
       .pisize  dd ?                            ; previous instruction size
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
        push    edx
        mov     edx, [.pisize]
        sub     [.misize], edx
        pop     edx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

;       mov     [code], rcx
;       mov     [csize], rdx
;       mov     [rcode], r8
;       mov     [], r9

        push    ebx esi edi

        mov     eax, [csize]
        test    eax, eax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], eax                     ; save initial code size
        mov     [.ebx], eax                     ; [.ebx] = initial code size
        mov     edi, [code]                     ; edi = code offset
        mov     [.eee], edi                     ; save code offset
        mov     [.zzz], 0                       ; scanned bytes
        mov     [.ecx], edi
        add     [.ecx], eax                     ; [.ecx] = code end pointer

        mov     [.cisize], 0
        mov     [.pisize], 0

   .cc.root:
        mov     eax, [.cisize]
        mov     [.pisize], eax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; eax = current instruction size
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        test    eax, eax
        jz     .cc.result
        mov     [.cisize], eax
        mov     ebx, eax                        ; ebx = current instruction size

   .cc.main:
        mov     [.misize], 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.3B_6B?:
        cmp     ebx, 3
        je     .cc.L0.3B_6B
        cmp     ebx, 6
        jne    .cc.L0.3B_6B.out

   .cc.L0.3B_6B:

   .cc.add_esp..in:
        SIC_OP.cc.L0.3B_6B.add_esp
   .cc.add_esp..out:

   .cc.L0.3B_6B.out:

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
   .cc.fst_eax..in:
        SIC_OP.cc.L0.2B.fst_eax .static.FSTP.ST0
   .cc.fst_eax..out:
  $end

  $ifndef _SSEX
   .cc.fst_ecx..in:
        SIC_OP.cc.L0.2B.fst_ecx .static.FSTP.ST0
   .cc.fst_ecx..out:
  $end

  $ifndef _SSEX
   .cc.fst_edx..in:
        SIC_OP.cc.L0.2B.fst_edx .static.FSTP.ST0
   .cc.fst_edx..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.2B.fild_esp_int
  {
   .cc.fild_esp_int.in:
;       cmp     ebx, 2
;       jne    .cc.fild_esp_int.out
        ; ----------------------------------------------------------------------
        ; 8 BYTES -> 2 BYTES
        ; ----------------------------------------------------------------------
        ;>  FF30     PUSH DWORD [EAX] |   DB00     FILD DWORD [EAX]
        ;   DB0424   FILD DWORD [ESP] |
        ;   83C4 04  ADD  ESP, 04     |
        ; ----------------------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; ecx = bytes to copy
        jl     .cc.fild_esp_int.out
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], dword 0x04DB30FF
        jne    .cc.fild_esp_int.out
        cmp     [edi + 4], dword 0x04C48324
        jne    .cc.fild_esp_int.out
        ; ----------------------------------------------------------------------
        mov     [edi + 0], word 0x00DB
;       mov     [.esi], 8
        mov     [.edi], 2
        jmp    .cc.momem
   .cc.fild_esp_int.out:
  }
   .cc.fild_esp_int..in:
        SIC_OP.cc.L2.2B.fild_esp_int
   .cc.fild_esp_int..out:
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
        ; 7 BYTES -> 5 BYTES
        ; ----------------------------------------------------------------------
        ;>  DD11     FST  QWORD [ECX] |   DD19     FSTP QWORD [ECX]
        ;   83C4 AA  ADD  ESP, AA     |   83C4 AA  ADD  ESP, AA
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 7
        call   .cc.size                         ; ecx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c22.out
    else
        jl     .cc.c22.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], dword 0xC48311DD
        jne    .cc.c22.out
        cmp     [edi + 5], word 0xD8DD
        jne    .cc.c22.out
        ; ----------------------------------------------------------------------
        mov     [edi + 0], word 0x19DD
;       mov     [.esi], 7
        mov     [.edi], 5
       .instr.shift.back 3                      ; instruction shift back
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
        cmp     [edi + 0], word 0xC0DD
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

  $ifdef _SSEX
   .cc.espB.xmm..in:
        SIC_OP.cc.L0.3B.espB.xmm
   .cc.espB.xmm..out:
  $end

  $ifndef _SSEX
   .cc.add_esp.fstp_st0..in:
        SIC_OP.cc.L0.3B.add_esp.fstp_st0 .static.FSTP.ST0
   .cc.add_esp.fstp_st0..out:
  $end

  $ifndef _SSEX
   .cc.add_esp.fpu..in:
        SIC_OP.cc.L0.3B.add_esp.fpu
   .cc.add_esp.fpu..out:
  $end

  $ifdef SIC_OP.ESP_PUSH_POP
   .cc.sub_esp_4..in:
        SIC_OP.cc.L0.3B.sub_esp_4
   .cc.sub_esp_4..out:
  $end

  $ifdef SIC_OP.ESP_PUSH_POP
   .cc.add_esp_4..in:
        SIC_OP.cc.L0.3B.add_esp_4
   .cc.add_esp_4..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.3B.c21 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c21.in:
;       cmp     ebx, 3
;       jne    .cc.c21.out
        ; ----------------------------------------------------------------------
        ; 10 BYTES -> 8 BYTES
        ; ----------------------------------------------------------------------
        ;>  83C4 CC  ADD  ESP, CC     |   DD19     FSTP QWORD [ECX]
        ;   DD11     FST  QWORD [ECX] |   83C4 CC  ADD  ESP, CC
        ;   83C4 AA  ADD  ESP, AA     |   83C4 AA  ADD  ESP, AA
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 10
        call   .cc.size                         ; ecx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c21.out
    else
        jl     .cc.c21.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], word 0xC483
        jne    .cc.c21.out
        cmp     [edi + 3], dword 0xC48311DD
        jne    .cc.c21.out
        cmp     [edi + 8], word 0xD8DD
        jne    .cc.c21.out
        ; ----------------------------------------------------------------------
        mov     dl, byte [edi + 2]              ;  dl = CC
        mov     dh, byte [edi + 7]              ;  dh = AA
        mov     [edi + 0], word 0x19DD
        mov     [edi + 2], word 0xC483
        mov     [edi + 4], dl
        mov     [edi + 5], word 0xC483
        mov     [edi + 7], dh
;       mov     [.esi], 10
        mov     [.edi], 8
       .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.c21.out:
  }
   .cc.c21..in:
        SIC_OP.cc.L2.3B.c21 .static.FSTP.ST0
   .cc.c21..out:
  $end

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
        ; 8 BYTES -> 6 BYTES
        ; ----------------------------------------------------------------------
        ;>  DD55 FF  FST  QWORD [EBP-FF] |   DD5D FF  FSTP QWORD [EBP-FF]
        ;   83C4 AA  ADD  ESP, AA        |   83C4 AA  ADD  ESP, AA
        ;   DDD8     FSTP ST0            |
        ; ----------------------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; ecx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c23.out
    else
        jl     .cc.c23.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], word 0x55DD
        jne    .cc.c23.out
        cmp     [edi + 3], word 0xC483
        jne    .cc.c23.out
        cmp     [edi + 6], word 0xD8DD
        jne    .cc.c23.out
        ; ----------------------------------------------------------------------
        mov     [edi + 1], byte 0x5D
;       mov     [.esi], 8
        mov     [.edi], 6
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.c23.out:
  }
   .cc.c23..in:
        SIC_OP.cc.L2.3B.c23 .static.FSTP.ST0
   .cc.c23..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.3B.c31 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c31.in:
;       cmp     ebx, 3
;       jne    .cc.c31.out
        ; ----------------------------------------------------------------------
        ; 14 BYTES -> 12 BYTES
        ; ----------------------------------------------------------------------
        ;>  83C4 CC  ADD  ESP, CC     |   DD1D BB+ FSTP QWORD [BB+]
        ;   DD15 BB+ FST  QWORD [BB+] |   83C4 CC  ADD  ESP, CC
        ;   83C4 AA  ADD  ESP, AA     |   83C4 AA  ADD  ESP, AA
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 14
        call   .cc.size                         ; ecx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c31.out
    else
        jl     .cc.c31.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 00], word 0xC483
        jne    .cc.c31.out
        cmp     [edi + 03], word 0x15DD
        jne    .cc.c31.out
        cmp     [edi + 09], word 0xC483
        jne    .cc.c31.out
        cmp     [edi + 12], word 0xD8DD
        jne    .cc.c31.out
        ; ----------------------------------------------------------------------
        mov     eax, dword [edi + 05]           ; eax = BB+
        mov     dl, byte [edi + 02]             ;  dl = CC
        mov     dh, byte [edi + 11]             ;  dh = AA
        mov     [edi + 00], word 0x1DDD
        mov     [edi + 02], eax
        mov     [edi + 06], word 0xC483
        mov     [edi + 08], dl
        mov     [edi + 09], word 0xC483
        mov     [edi + 11], dh
;       mov     [.esi], 14
        mov     [.edi], 12
       .instr.shift.back 12                     ; instruction shift back
        jmp    .cc.momem
   .cc.c31.out:
  }
   .cc.c31..in:
        SIC_OP.cc.L2.3B.c31 .static.FSTP.ST0
   .cc.c31..out:
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
        ;>?F2 0F 10 00  MOVSD    XMM0, QWORD [EAX]
        ; ?F2 0F 10 01  MOVSD    XMM0, QWORD [ECX]
        ; ?F2 0F 10 02  MOVSD    XMM0, QWORD [EDX]
        ; ?F2 0F 2A C0  CVTSI2SD XMM0, EAX
        ; ?F2 0F 2A C1  CVTSI2SD XMM0, ECX
        ; ?F2 0F 2A C2  CVTSI2SD XMM0, EDX
        ; ?F2 0F 2A 01  CVTSI2SD XMM0, QWORD [ECX]
        ;  DD C0        FFREE    ST0
        ; ----------------------------------------------------------------------
        mov     [.esi], 6
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.4B.xmm0.ffree.out
    else
        jl     .cc.4B.xmm0.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], dword 0x00100FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [edi + 0], dword 0x01100FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [edi + 0], dword 0x02100FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [edi + 0], dword 0xC02A0FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [edi + 0], dword 0xC12A0FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [edi + 0], dword 0xC22A0FF2
        je     .cc.4B.xmm0.ffree.main
        cmp     [edi + 0], dword 0x012A0FF2
        je     .cc.4B.xmm0.ffree.main
        jmp    .cc.4B.xmm0.ffree.out
   .cc.4B.xmm0.ffree.main:
        cmp     [edi + 4], word 0xC0DD
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
  macro SIC_OP.cc.L2.4B.xmm0.espB.ffree static.FREE.ST0
  {
    if ~ static.FREE.ST0 in <0,1>
        oops
    end if

   .cc.4B.xmm0.espB.ffree.in:
;       cmp     ebx, 4
;       jne    .cc.4B.xmm0.espB.ffree.out
        ; ----------------------------------------------------------------------
        ; 9 BYTES -> 3 BYTES
        ; ----------------------------------------------------------------------
        ;>?F2 0F 10 00  MOVSD    XMM0, QWORD [EAX]
        ; ?F2 0F 10 01  MOVSD    XMM0, QWORD [ECX]
        ; ?F2 0F 10 02  MOVSD    XMM0, QWORD [EDX]
        ; ?F2 0F 2A C0  CVTSI2SD XMM0, EAX
        ; ?F2 0F 2A C1  CVTSI2SD XMM0, ECX
        ; ?F2 0F 2A C2  CVTSI2SD XMM0, EDX
        ; ?F2 0F 2A 01  CVTSI2SD XMM0, QWORD [ECX]
        ;  83 C4 FF     ADD      ESP, FF
        ;  DD C0        FFREE    ST0
        ; ----------------------------------------------------------------------
        ;> 83 C4 FF     ADD      ESP, FF
        ; ----------------------------------------------------------------------
        mov     [.esi], 9
        call   .cc.size                         ; rcx = bytes to copy
    if static.FREE.ST0 eq 1
        jle    .cc.4B.xmm0.espB.ffree.out
    else
        jl     .cc.4B.xmm0.espB.ffree.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], dword 0x00100FF2
        je     .cc.4B.xmm0.espB.ffree.main
        cmp     [edi + 0], dword 0x01100FF2
        je     .cc.4B.xmm0.espB.ffree.main
        cmp     [edi + 0], dword 0x02100FF2
        je     .cc.4B.xmm0.espB.ffree.main
        cmp     [edi + 0], dword 0xC02A0FF2
        je     .cc.4B.xmm0.espB.ffree.main
        cmp     [edi + 0], dword 0xC12A0FF2
        je     .cc.4B.xmm0.espB.ffree.main
        cmp     [edi + 0], dword 0xC22A0FF2
        je     .cc.4B.xmm0.espB.ffree.main
        cmp     [edi + 0], dword 0x012A0FF2
        je     .cc.4B.xmm0.espB.ffree.main
        jmp    .cc.4B.xmm0.espB.ffree.out
   .cc.4B.xmm0.espB.ffree.main:
        cmp     [edi + 4], word 0xC483
        jne    .cc.4B.xmm0.espB.ffree.out
        cmp     [edi + 7], word 0xC0DD
        jne    .cc.4B.xmm0.espB.ffree.out
        ; ----------------------------------------------------------------------
        mov     al, [edi + 6]
        mov     [edi + 0], word 0xC483
        mov     [edi + 2], al
;       mov     [.esi], 9
        mov     [.edi], 3
       .instr.shift.back 3                      ; instruction shift back
        jmp    .cc.momem
   .cc.4B.xmm0.espB.ffree.out:
  }
   .cc.4B.xmm0.espB.ffree..in:
        SIC_OP.cc.L2.4B.xmm0.espB.ffree .static.FREE.ST0
   .cc.4B.xmm0.espB.ffree..out:
  $end

   .cc.L0.4B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.5B:

   .cc.L0.5B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 6
        jne    .cc.L0.6B.out
   .cc.L0.6B:

  $ifndef _SSEX
   .cc.fst_mem..in:
        SIC_OP.cc.L0.6B.fst_mem .static.FSTP.ST0
   .cc.fst_mem..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.6B.c32 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c32.in:
;       cmp     ebx, 6
;       jne    .cc.c32.out
        ; ----------------------------------------------------------------------
        ; 11 BYTES -> 9 BYTES
        ; ----------------------------------------------------------------------
        ;>  DD15 BB+ FST  QWORD [BB+] |   DD1D BB+ FSTP QWORD [BB+]
        ;   83C4 AA  ADD  ESP, AA     |   83C4 AA  ADD  ESP, AA
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 11
        call   .cc.size                         ; ecx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c32.out
    else
        jl     .cc.c32.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], word 0x15DD
        jne    .cc.c32.out
        cmp     [edi + 6], word 0xC483
        jne    .cc.c32.out
        cmp     [edi + 9], word 0xD8DD
        jne    .cc.c32.out
        ; ----------------------------------------------------------------------
        mov     [edi + 0], word 0x1DDD
;       mov     [.esi], 11
        mov     [.edi], 9
       .instr.shift.back 9                      ; instruction shift back
        jmp    .cc.momem
   .cc.c32.out:
  }
   .cc.c32..in:
        SIC_OP.cc.L2.6B.c32 .static.FSTP.ST0
   .cc.c32..out:
  $end

  $ifndef _SSEX
  macro SIC_OP.cc.L2.6B.c33 static.FSTP.ST0
  {
    if ~ static.FSTP.ST0 in <0,1>
        oops
    end if

   .cc.c33.in:
;       cmp     ebx, 6
;       jne    .cc.c33.out
        ; ----------------------------------------------------------------------
        ; 8 BYTES -> 6 BYTES
        ; ----------------------------------------------------------------------
        ;>  DD15 BB+ FST  QWORD [BB+] |   DD1D BB+ FSTP QWORD [BB+]
        ;   DDD8     FSTP ST0         |
        ; ----------------------------------------------------------------------
        mov     [.esi], 8
        call   .cc.size                         ; ecx = bytes to copy
    if static.FSTP.ST0 eq 1
        jle    .cc.c33.out
    else
        jl     .cc.c33.out
    end if
        ; ----------------------------------------------------------------------
        cmp     [edi + 0], word 0x15DD
        jne    .cc.c33.out
        cmp     [edi + 6], word 0xD8DD
        jne    .cc.c33.out
        ; ----------------------------------------------------------------------
        mov     [edi + 0], word 0x1DDD
;       mov     [.esi], 8
        mov     [.edi], 6
;      .instr.shift.back 6                      ; instruction shift back
        jmp    .cc.momem
   .cc.c33.out:
  }
   .cc.c33..in:
;       SIC_OP.cc.L2.6B.c33 .static.FSTP.ST0
   .cc.c33..out:
  $end

  $ifndef _SSEX
   .cc.03..in:
;       SIC_OP.cc.L0.6B.03
   .cc.03..out:
  $end

   .cc.L0.6B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
   .cc.momem:
        add     edi, [.edi]                     ; edi = destination memory
        cmp     edi, esi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     edi, [.xdi]
        add     edi, [.edi]
        mov     ecx, [.esi]
        sub     ecx, [.edi]
        sub     [.ezx], ecx
        sub     [.ecx], ecx
        sub     [.ebx], ecx
        jle    .cc.result
        mov     eax, [.misize]
        jmp    .cc.next.edi

   .cc.next:
        mov     eax, [.cisize]
   .cc.next.edi:
        add     edi, eax                        ; edi = next instruction
        ;
        mov     ecx, edi
        sub     ecx, [.eee]
        mov     [.zzz], ecx
        ;
        sub     [.ebx], eax
;       cmp     [.ebx], 0
        jg     .cc.root

   .cc.result:
        mov     eax, [.ezx]

   .cc.return:
        pop     edi esi ebx
        ret

        ; -> [.esi] - initial bytes
        ; <- ecx    - bytes to copy
        ; <- esi    - source memory
   .cc.size:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------

; code optimization
$proc code.clean.L3, code, csize, rcode

       .static.FSTP.ST0 EQU 1
       .static.FREE.ST0 EQU 1

    locals
       .ebx     dd ?
       .edi     dd ?
       .eee     dd ?
       .zzz     dd ?
       .esi     dd ?
       .ezx     dd ?
       .ecx     dd ?
       .xcx     dd ?
       .xdi     dd ?
       .xsi     dd ?
       .misize  dd ?
       .cisize  dd ?                            ; current instruction size
       .pisize  dd ?                            ; previous instruction size
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
        push    edx
        mov     edx, [.pisize]
        sub     [.misize], edx
        pop     edx
       end if
      end if
        mov     [.cisize], 0
        mov     [.pisize], 0
    }

;       mov     [code], rcx
;       mov     [csize], rdx
;       mov     [rcode], r8
;       mov     [], r9

        push    ebx esi edi

        mov     eax, [csize]
        test    eax, eax
        jz     .cc.return                       ; invalid code size

        mov     [.ezx], eax                     ; save initial code size
        mov     [.ebx], eax                     ; [.ebx] = initial code size
        mov     edi, [code]                     ; edi = code offset
        mov     [.eee], edi                     ; save code offset
        mov     [.zzz], 0                       ; scanned bytes
        mov     [.ecx], edi
        add     [.ecx], eax                     ; [.ecx] = code end pointer

        mov     [.cisize], 0
        mov     [.pisize], 0

   .cc.root:
        mov     eax, [.cisize]
        mov     [.pisize], eax                  ; [.pisize] = [.cisize]
        ;
        call    SIC_IDA.ida                     ; eax = current instruction size
        and     edx, IDA_INVALID                ; edx = instruction flags
        jnz    .cc.result
        test    eax, eax
        jz     .cc.result
        mov     [.cisize], eax
        mov     ebx, eax                        ; ebx = current instruction size

   .cc.main:
        mov     [.misize], 1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.3B_6B?:
        cmp     ebx, 3
        je     .cc.L0.3B_6B
        cmp     ebx, 6
        jne    .cc.L0.3B_6B.out

   .cc.L0.3B_6B:

   .cc.add_esp..in:
        SIC_OP.cc.L0.3B_6B.add_esp
   .cc.add_esp..out:

   .cc.L0.3B_6B.out:

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
   .cc.fst_eax..in:
        SIC_OP.cc.L0.2B.fst_eax .static.FSTP.ST0
   .cc.fst_eax..out:
  $end

  $ifndef _SSEX
   .cc.fst_ecx..in:
        SIC_OP.cc.L0.2B.fst_ecx .static.FSTP.ST0
   .cc.fst_ecx..out:
  $end

  $ifndef _SSEX
   .cc.fst_edx..in:
        SIC_OP.cc.L0.2B.fst_edx .static.FSTP.ST0
   .cc.fst_edx..out:
  $end

  $ifndef _SSEX
   .cc.fild_esp_int..in:
        SIC_OP.cc.L2.2B.fild_esp_int
   .cc.fild_esp_int..out:
  $end

  $ifndef _SSEX
   .cc.c22..in:
        SIC_OP.cc.L2.2B.c22 .static.FSTP.ST0
   .cc.c22..out:
  $end

  $ifdef _SSEX
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
   .cc.c21..in:
        SIC_OP.cc.L2.3B.c21 .static.FSTP.ST0
   .cc.c21..out:
  $end

  $ifndef _SSEX
   .cc.c23..in:
        SIC_OP.cc.L2.3B.c23 .static.FSTP.ST0
   .cc.c23..out:
  $end

  $ifndef _SSEX
   .cc.c31..in:
        SIC_OP.cc.L2.3B.c31 .static.FSTP.ST0
   .cc.c31..out:
  $end

  $ifndef _SSEX
   .cc.add_esp.fstp_st0..in:
        SIC_OP.cc.L0.3B.add_esp.fstp_st0 .static.FSTP.ST0
   .cc.add_esp.fstp_st0..out:
  $end

  $ifndef _SSEX
   .cc.add_esp.fpu..in:
        SIC_OP.cc.L0.3B.add_esp.fpu
   .cc.add_esp.fpu..out:
  $end

  $ifdef SIC_OP.ESP_PUSH_POP
   .cc.sub_esp_4..in:
        SIC_OP.cc.L0.3B.sub_esp_4
   .cc.sub_esp_4..out:
  $end

  $ifdef SIC_OP.ESP_PUSH_POP
   .cc.add_esp_4..in:
        SIC_OP.cc.L0.3B.add_esp_4
   .cc.add_esp_4..out:
  $end

   .cc.L0.3B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 4
        jne    .cc.L0.4B.out
   .cc.L0.4B:

  $ifdef _SSEX
   .cc.4B.xmm0.ffree..in:
        SIC_OP.cc.L2.4B.xmm0.ffree .static.FREE.ST0
   .cc.4B.xmm0.ffree..out:
  $end

  $ifdef _SSEX
   .cc.4B.xmm0.espB.ffree..in:
        SIC_OP.cc.L2.4B.xmm0.espB.ffree .static.FREE.ST0
   .cc.4B.xmm0.espB.ffree..out:
  $end

   .cc.L0.4B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   .cc.L0.5B:

   .cc.L0.5B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        cmp     ebx, 6
        jne    .cc.L0.6B.out
   .cc.L0.6B:

  $ifndef _SSEX
   .cc.fst_mem..in:
        SIC_OP.cc.L0.6B.fst_mem .static.FSTP.ST0
   .cc.fst_mem..out:
  $end

  $ifndef _SSEX
   .cc.c32..in:
        SIC_OP.cc.L2.6B.c32 .static.FSTP.ST0
   .cc.c32..out:
  $end

  $ifndef _SSEX
   .cc.c33..in:
;       SIC_OP.cc.L2.6B.c33 .static.FSTP.ST0
   .cc.c33..out:
  $end

   .cc.L0.6B.out:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        jmp    .cc.next

        ; -> [.esi] - initial bytes
        ; -> [.edi] - final bytes
   .cc.move.memory:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
   .cc.momem:
        add     edi, [.edi]                     ; edi = destination memory
        cmp     edi, esi
        jae    .cc.move.out
        call    momem
   .cc.move.out:
        mov     edi, [.xdi]
        add     edi, [.edi]
        mov     ecx, [.esi]
        sub     ecx, [.edi]
        sub     [.ezx], ecx
        sub     [.ecx], ecx
        sub     [.ebx], ecx
        jle    .cc.result
        mov     eax, [.misize]
        jmp    .cc.next.edi

   .cc.next:
        mov     eax, [.cisize]
   .cc.next.edi:
        add     edi, eax                        ; edi = next instruction
        ;
        mov     ecx, edi
        sub     ecx, [.eee]
        mov     [.zzz], ecx
        ;
        sub     [.ebx], eax
;       cmp     [.ebx], 0
        jg     .cc.root

   .cc.result:
        mov     eax, [.ezx]

   .cc.return:
        pop     edi esi ebx
        ret

        ; -> [.esi] - initial bytes
        ; <- ecx    - bytes to copy
        ; <- esi    - source memory
   .cc.size:
        lea     ecx, [edi - 1]
        mov     [.xdi], ecx
        mov     esi, edi
        add     esi, [.esi]                     ; esi = source memory
        mov     ecx, [.ecx]
        sub     ecx, esi                        ; ecx = bytes to copy
        retn
$endp

; ------------------------------------------------------------------------------
