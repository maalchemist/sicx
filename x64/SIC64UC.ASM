
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; code utils

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_UC:

; ------------------------------------------------------------------------------

DEFINE SIC_UC.OBJ_PTR_VAR     FALSE ; TRUE ;
DEFINE SIC_UC.OBJ_REF         FALSE ; TRUE ;
DEFINE SIC_UC.OBJ_IND         FALSE ; TRUE ;
DEFINE SIC_UC.OBJ_INT_RAX_ST0 FALSE ; TRUE ;

; ------------------------------------------------------------------------------

; get object type
; !!! don`t change rax register
;
; -> rdi   - memory to scan
; -> cooff - code segment entry offset
; -> shift - memory shift
; <- rcx   - object type
proc code_object, cooff, shift

        ; 3 4 5 8 10 11 12 14
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ;-double reference (15B)
        ; MOV     RCX, QWORD [RCX]  | 488B09
        ; PUSH    QWORD [RCX]       | FF31

        ; ...                       | ...
        ; MOV     RCX, QWORD [RCX]  | 488B09                ;-double indirect (5B)
        ; PUSH    QWORD [RCX]       | FF31

        ; ...                       | ...
        ; LEA     RCX, [RCX+RAX*8]  | 488D0CC1              ;-double offset (5B)
        ; PUSH    RCX               | 51

        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50

        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ;-integer reference (15B)
        ; MOV     RAX, QWORD [RCX]  | 488B01
        ; PUSH    QWORD [RAX]       | FF30

        ; ...                       | ...
        ; MOV     RAX, QWORD [RCX]  | 488B01                ;-integer indirect (5B)
        ; PUSH    QWORD [RAX]       | FF30

        ; ...                       | ...
        ; LEA     RAX, [RCX+RAX*8]  | 488D04C1              ;-integer offset (5B)
        ; PUSH    RAX               | 50

        ; ...                       | ...
        ; MOV     RAX, [RSP]        | 488B0424              ;-integer RAX RSP (4B)

        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ; ...                       | ...
        ; PUSH    RAX               | 50                    ;-integer RAX ST0 (8B)
        ; FILD    QWORD [RSP]       | DF2C24
        ; POP     RAX               | 58
        ; FSTP    QWORD [RSP]       | DD1C24

        ; MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ; PUSH    RDX               | 52

        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ;-string reference (15B)
        ; MOV     RDX, QWORD [RCX]  | 488B11
        ; PUSH    QWORD [RDX]       | FF32

        ; ...                       | ...
        ; MOV     RDX, QWORD [RCX]  | 488B11                ;-string indirect (5B)
        ; PUSH    QWORD [RDX]       | FF32

        ; ...                       | ...
        ; LEA     RDX, [RCX+RAX*8]  | 488D14C1              ;-string offset (5B)
        ; PUSH    RDX               | 52

        ; MOV     RCX, VALUE        | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ;-pointer variable (14B)
        ; PUSH    QWORD [RCX]       | FF31
        ; NOP2                      | 9090

        ; ...                       | ...
        ; LEA     RCX, [RCX+RAX]    | 488D0C01              ;-pointer offset (5B)
        ; PUSH    RCX               | 51

        ; MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)

        ; MOV     R13, VALUE        | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------

;       mov     [cooff], rcx
;       mov     [shift], rdx
;       mov     [], r8
;       mov     [], r9

        push    rbx rsi rdi rax

;       mov     rdx, [shift]
        lea     rbx, [rdi + rdx]

        mov     rsi, rbx
        sub     rsi, rcx
;       sub     rsi, [cooff]

        xor     rcx, rcx

        cmp     rsi, 3
        jl     .return

    $ifdef SIC_UC.OBJ_REF
   .15B:
        cmp     rsi, 15
        jl     .15B.out
        lea     rdi, [rbx - 15]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .15B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .15B.out
   .15B.10B:
        cmp     rax, 10
        jne    .15B.10B.out
        ;
   .double.ref?:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double reference (15B)
        ; MOV     RCX, QWORD [RCX]  | 488B09
        ; PUSH    QWORD [RCX]       | FF31
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .double.ref?.out
        cmp     [rdi + 10], dword 0xFF098B48
        jne    .double.ref?.out
        cmp     [rdi + 14], byte 0x31
        jne    .double.ref?.out
   .double.ref:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
        mov     ecx, OBJ_DOUBLE_REF
        jmp    .return
   .double.ref?.out:
        ;
   .int.ref?:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; integer reference (15B)
        ; MOV     RAX, QWORD [RCX]  | 488B01
        ; PUSH    QWORD [RAX]       | FF30
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .int.ref?.out
        cmp     [rdi + 10], dword 0xFF018B48
        jne    .int.ref?.out
        cmp     [rdi + 14], byte 0x30
        jne    .int.ref?.out
   .int.ref:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
        mov     ecx, OBJ_INT_REF
        jmp    .return
   .int.ref?.out:
        ;
   .string.ref?:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; string reference (15B)
        ; MOV     RDX, QWORD [RCX]  | 488B11
        ; PUSH    QWORD [RDX]       | FF32
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .string.ref?.out
        cmp     [rdi + 10], dword 0xFF118B48
        jne    .string.ref?.out
        cmp     [rdi + 14], byte 0x32
        jne    .string.ref?.out
   .string.ref:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
        mov     ecx, OBJ_STRING_REF
        jmp    .return
   .string.ref?.out:
        ;
   .15B.10B.out:
   .15B.out:
    $end

   .14B:
        cmp     rsi, 14
        jl     .14B.out
        lea     rdi, [rbx - 14]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .14B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .14B.out
   .14B.10B:
        cmp     rax, 10
        jne    .14B.10B.out
        ;
   .pointer?:
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .pointer?.out
        cmp     [rdi + 10], dword 0x90909051
        jne    .pointer?.out
   .pointer:
        mov     rcx, OBJ_POINTER
        jmp    .return
   .pointer?.out:
        ;
    $ifdef SIC_UC.OBJ_PTR_VAR
   .ptr.var?:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer variable (14B)
        ; PUSH    QWORD [RCX]       | FF31
        ; NOP2                      | 9090
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .ptr.var?.out
        cmp     [rdi + 10], dword 0x909031FF
        jne    .ptr.var?.out
   .ptr.var:
        mov     rcx, OBJ_PNT_VAR
        jmp    .return
   .ptr.var?.out:
    $end
        ;
   .14B.10B.out:
   .14B.out:

   .12B:
        cmp     rsi, 12
        jl     .12B.out
        lea     rdi, [rbx - 12]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .12B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .12B.out
   .12B.10B:
        cmp     rax, 10
        jne    .12B.10B.out
        ;
   .double.var?:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .double.var?.out
        cmp     [rdi + 10], word 0x31FF
        jne    .double.var?.out
   .double.var:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
        mov     rcx, OBJ_DOUBLE_VAR
        jmp    .return
   .double.var?.out:
        ;
   .int.var?:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB848
        jne    .int.var?.out
        cmp     [rdi + 10], word 0x30FF
        jne    .int.var?.out
   .int.var:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
        mov     rcx, OBJ_INT_VAR
        jmp    .return
   .int.var?.out:
        ;
   .string.var?:
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xBA48
        jne    .string.var?.out
        cmp     [rdi + 10], word 0x32FF
        jne    .string.var?.out
   .string.var:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
        mov     rcx, OBJ_STRING_VAR
        jmp    .return
   .string.var?.out:
        ;
   .12B.10B.out:
   .12B.out:

   .11B:
        cmp     rsi, 11
        jl     .11B.out
        lea     rdi, [rbx - 11]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .11B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .11B.out
   .11B.10B:
        cmp     rax, 10
        jne    .11B.10B.out
        ;
   .double.con?:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB948
        jne    .double.con?.out
        cmp     [rdi + 10], byte 0x51
        jne    .double.con?.out
   .double.con:
        mov     rcx, OBJ_DOUBLE_CON
        jmp    .return
   .double.con?.out:
        ;
   .int.con?:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xB848
        jne    .int.con?.out
        cmp     [rdi + 10], byte 0x50
        jne    .int.con?.out
   .int.con:
        mov     rcx, OBJ_INT_CON
        jmp    .return
   .int.con?.out:
        ;
   .string.con?:
        ; --------------------------------------------------
        ; MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ; PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xBA48
        jne    .string.con?.out
        cmp     [rdi + 10], byte 0x52
        jne    .string.con?.out
   .string.con:
        mov     rcx, OBJ_STRING_CON
        jmp    .return
   .string.con?.out:
        ;
   .11B.10B.out:
   .11B.out:

   .10B:
        cmp     rsi, 10
        jl     .10B.out
        lea     rdi, [rbx - 10]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .10B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .10B.out
   .10B.10B:
        cmp     rax, 10
        jne    .10B.10B.out
        ;
   .label.off?:
        ; --------------------------------------------------
        ; MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xBA48
        jne    .label.off?.out
   .label.off.test:
        mov     rdx, [rdi + 02]
        test    rdx, rdx
        jz     .return
   .label.off:
        mov     rcx, OBJ_LOFFSET
        jmp    .return
   .label.off?.out:
        ;
   .arg.count?:
        ; --------------------------------------------------
        ; MOV     R13, VALUE        | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0xBD49
        jne    .arg.count?.out
   .arg.count:
        mov     rcx, OBJ_ARG_COUNT
        jmp    .return
   .arg.count?.out:
        ;
   .10B.10B.out:
   .10B.out:

    $ifdef SIC_UC.OBJ_INT_RAX_ST0
   .8B:
        cmp     rsi, 8
        jl     .8B.out
        lea     rdi, [rbx - 8]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .8B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .8B.out
   .8B.1B:
        cmp     rax, 1
        jne    .8B.1B.out
        ;
   .int.rax.st0?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; PUSH    RAX               | 50                    ; integer RAX ST0 (8B)
        ; FILD    QWORD [RSP]       | DF2C24
        ; POP     RAX               | 58
        ; FSTP    QWORD [RSP]       | DD1C24
        ; --------------------------------------------------
        cmp     [rdi + 00], dword 0x242CDF50
        jne    .int.rax.st0?.out
        cmp     [rdi + 04], dword 0x241CDD58
        jne    .int.rax.st0?.out
   .int.rax.st0:
        mov     rcx, OBJ_INT_RAX_ST0
        jmp    .return
   .int.rax.st0?.out:
        ;
   .8B.1B.out:
   .8B.out:
    $end

   .5B:
        cmp     rsi, 5
        jl     .5B.out
        lea     rdi, [rbx - 5]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .5B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .5B.out
   .5B.5B:
        cmp     rax, 5
        jne    .5B.5B.out
        ;
    $ifdef _SSEX
   .double.sse?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], byte 0xF2
        jne    .double.sse?.out
        cmp     [rdi + 01], dword 0x2404110F
        jne    .double.sse?.out
   .double.sse:
        mov     rcx, OBJ_DOUBLE_SSE
        jmp    .return
   .double.sse?.out:
    $end
        ;
   .5B.5B.out:
        ;
   .5B.4B:
;       cmp     rax, 4
;       jne    .5B.4B.out
        ;
   .5B.4B.out:
        ;
    $ifdef SIC_UC.OBJ_IND
   .5B.3B:
        cmp     rax, 3
        jne    .5B.3B.out
        ;
   .double.ind?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RCX, QWORD [RCX]  | 488B09                ; double indirect (5B)
        ; PUSH    QWORD [RCX]       | FF31
        ; --------------------------------------------------
        cmp     [rdi + 00], dword 0xFF098B48
        jne    .double.ind?.out
        cmp     [rdi + 04], byte 0x31
        jne    .double.ind?.out
   .double.ind:
        mov     rcx, OBJ_DOUBLE_IND
        jmp    .return
   .double.ind?.out:
        ;
   .int.ind?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, QWORD [RCX]  | 488B01                ; integer indirect (5B)
        ; PUSH    QWORD [RAX]       | FF30
        ; --------------------------------------------------
        cmp     [rdi + 00], dword 0xFF018B48
        jne    .int.ind?.out
        cmp     [rdi + 04], byte 0x30
        jne    .int.ind?.out
   .int.ind:
        mov     rcx, OBJ_INT_IND
        jmp    .return
   .int.ind?.out:
        ;
   .string.ind?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RDX, QWORD [RCX]  | 488B11                ; string indirect (5B)
        ; PUSH    QWORD [RDX]       | FF32
        ; --------------------------------------------------
        cmp     [rdi + 00], dword 0xFF118B48
        jne    .string.ind?.out
        cmp     [rdi + 04], byte 0x32
        jne    .string.ind?.out
   .string.ind:
        mov     rcx, OBJ_STRING_IND
        jmp    .return
   .string.ind?.out:
        ;
   .5B.3B.out:
    $end
   .5B.out:

   .4B:
        cmp     rsi, 4
        jl     .4B.out
        lea     rdi, [rbx - 4]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .4B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .4B.out
   .4B.4B:
        cmp     rax, 4
        jne    .4B.4B.out
        ;
   .int.rsp.rax?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], dword 0x24048948
        jne    .int.rsp.rax?.out
   .int.rsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        mov     rcx, OBJ_INT_RSP_RAX
        jmp    .return
   .int.rsp.rax?.out:
        ;
   .4B.4B.out:
   .4B.out:

   .3B:
;       cmp     rsi, 3
;       jl     .3B.out
        lea     rdi, [rbx - 3]
        call    SIC_IDA.ida                                 ; rax = current instruction size
        test    rax, rax
        jz     .3B.out
        and     rdx, IDA_INVALID                            ; rdx = instruction flags
        jnz    .3B.out
   .3B.3B:
        cmp     rax, 3
        jne    .3B.3B.out
        ;
   .double.st0?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ;>
        ; --------------------------------------------------
        cmp     [rdi + 00], word 0x1CDD
        jne    .double.st0?.out
        cmp     [rdi + 02], byte 0x24
        jne    .double.st0?.out
   .double.st0:
        mov     rcx, OBJ_DOUBLE_ST0
        jmp    .return
   .double.st0?.out:
        ;
   .3B.3B.out:
   .3B.out:

   .return:
        pop     rax rdi rsi rbx
        ret
endp

; ------------------------------------------------------------------------------
