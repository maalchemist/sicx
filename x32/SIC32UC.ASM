
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
; !!! don`t change eax register
;
; -> edi   - memory to scan
; -> cooff - code segment entry offset
; -> shift - memory shift
; <- ecx   - object type
proc code_object, cooff, shift

        ; 3 4 5 6 7 8 9 10 12
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)

        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51

        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ;-double reference (12B)
        ; MOV     ECX, DWORD [ECX]  | 8B09
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; ...                       | ...
        ; MOV     ECX, DWORD [ECX]  | 8B09                  ;-double indirect (7B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31

        ; ...                       | ...
        ; LEA     ECX, [ECX+EAX*8]  | 8D0CC1                ;-double offset (4B)
        ; PUSH    ECX               | 51

        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50

        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30

        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ;-integer reference (9B)
        ; MOV     EAX, DWORD [ECX]  | 8B01
        ; PUSH    DWORD [EAX]       | FF30

        ; ...                       | ...
        ; MOV     EAX, DWORD [ECX]  | 8B01                  ;-integer indirect (4B)
        ; PUSH    DWORD [EAX]       | FF30

        ; ...                       | ...
        ; LEA     EAX, [ECX+EAX*4]  | 8D0481                ;-integer offset (4B)
        ; PUSH    EAX               | 50

        ; ...                       | ...
        ; MOV     EAX, [ESP]        | 8B0424                ;-integer RAX RSP (3B)

        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)

        ; ...                       | ...
        ; MOV     EAX, [ESP]        | 8B0424                ;-integer EAX:EDX ESP (7B)
        ; MOV     EDX, [ESP+4]      | 8B542404

        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424                ;-integer ESP EAX:EDX (7B)
        ; MOV     [ESP+4], EDX      | 89542404

        ; ...                       | ...
        ; PUSH    EAX               | 50                    ;-integer RAX ST0 (8B)
        ; FILD    DWORD [ESP]       | DB0424
        ; POP     EAX               | 58
        ; FSTP    QWORD [ESP]       | DD1C24

        ; ...                       | ...
        ; PUSH    EDX               | 52                    ;-integer EAX:EDX ST0 (10B)
        ; PUSH    EAX               | 50
        ; FILD    QWORD [ESP]       | DF2C24
        ; POP     EAX               | 58
        ; POP     EDX               | 5A
        ; FSTP    QWORD [ESP]       | DD1C24

        ; MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ; PUSH    EDX               | 52

        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32

        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ;-string reference (9B)
        ; MOV     EDX, DWORD [ECX]  | 8B11
        ; PUSH    DWORD [EDX]       | FF32

        ; ...                       | ...
        ; MOV     EDX, DWORD [ECX]  | 8B11                  ;-string indirect (4B)
        ; PUSH    DWORD [EDX]       | FF32

        ; ...                       | ...
        ; LEA     EDX, [ECX+EAX*4]  | 8D1481                ;-string offset (4B)
        ; PUSH    EDX               | 52

        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090

        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ;-pointer variable (9B)
        ; PUSH    DWORD [ECX]       | FF31
        ; NOP2                      | 9090

        ; ...                       | ...
        ; LEA     ECX, [ECX+EAX]    | 8D0C01                ;-pointer offset (4B)
        ; PUSH    ECX               | 51

        ; MOV     EDX, VALUE        | BA FFFFFFFF           ; label offset (5B)

        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------

;       mov     [cooff], rcx
;       mov     [shift], rdx
;       mov     [], r8
;       mov     [], r9

        push    ebx esi edi eax

        mov     edx, [shift]
        lea     ebx, [edi + edx]

        mov     esi, ebx
;       sub     rax, rcx
        sub     esi, [cooff]

        xor     ecx, ecx

        cmp     esi, 3
        jl     .return

   .12B:
        cmp     esi, 12
        jl     .12B.out
        lea     edi, [ebx - 12]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .12B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .12B.out

   .12B.5B:
        cmp     eax, 5
        jne    .12B.5B.out
        ;
   .double.con?:
        ; --------------------------------------------------
        ; MOV     EDX, QWORD.HI     | BA FFFF..HI           ; double constant (12B)
        ; MOV     ECX, QWORD.LO     | B9 FFFF..LO
        ; PUSH    EDX               | 52
        ; PUSH    ECX               | 51
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .double.con?.out
        cmp     [edi + 05], byte 0xB9
        jne    .double.con?.out
        cmp     [edi + 10], word 0x5152
        jne    .double.con?.out
   .double.con:
        mov     ecx, OBJ_DOUBLE_CON
        jmp    .return
   .double.con?.out:
        ;
    $ifdef SIC_UC.OBJ_REF
   .double.ref?:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double reference (12B)
        ; MOV     ECX, DWORD [ECX]  | 8B09
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .double.ref?.out
        cmp     [edi + 05], dword 0x71FF098B
        jne    .double.ref?.out
        cmp     [edi + 09], byte 0x04
        jne    .double.ref?.out
        cmp     [edi + 10], word 0x31FF
        jne    .double.ref?.out
   .double.ref:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
        mov     ecx, OBJ_DOUBLE_REF
        jmp    .return
   .double.ref?.out:
    $end
        ;
   .12B.5B.out:
   .12B.out:

   .10B:
        cmp     esi, 10
        jl     .10B.out
        lea     edi, [ebx - 10]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .10B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .10B.out
   .10B.5B:
        cmp     eax, 5
        jne    .10B.5B.out
        ;
   .double.var?:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; double variable (10B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .double.var?.out
        cmp     [edi + 05], dword 0xFF0471FF
        jne    .double.var?.out
        cmp     [edi + 09], byte 0x31
        jne    .double.var?.out
   .double.var:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
        mov     ecx, OBJ_DOUBLE_VAR
        jmp    .return
   .double.var?.out:
        ;
   .10B.5B.out:
   .10B.out:

   .9B:
        cmp     esi, 9
        jl     .9B.out
        lea     edi, [ebx - 9]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .9B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .9B.out
   .9B.5B:
        cmp     eax, 5
        jne    .9B.5B.out
        ;
   .pointer?:
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; pointer constant (9B)
        ; PUSH    ECX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .pointer?.out
        cmp     [edi + 05], dword 0x90909051
        jne    .pointer?.out
   .pointer:
        mov     ecx, OBJ_POINTER
        jmp    .return
   .pointer?.out:
        ;
    $ifdef SIC_UC.OBJ_PTR_VAR
   .ptr.var?:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; pointer variable (9B)
        ; PUSH    DWORD [ECX]       | FF31
        ; NOP2                      | 9090
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .ptr.var?.out
        cmp     [edi + 05], dword 0x909031FF
        jne    .ptr.var?.out
   .ptr.var:
        mov     ecx, OBJ_PTR_VAR
        jmp    .return
   .ptr.var?.out:
    $end
        ;
    $ifdef SIC_UC.OBJ_REF
   .int.ref?:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B9 FFFFFFFF           ; integer reference (9B)
        ; MOV     EAX, DWORD [EAX]  | 8B01
        ; PUSH    DWORD [EAX]       | FF30
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .int.ref?.out
        cmp     [edi + 05], dword 0x30FF018B
        jne    .int.ref?.out
   .int.ref:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
        mov     ecx, OBJ_INT_REF
        jmp    .return
   .int.ref?.out:
    $end
        ;
    $ifdef SIC_UC.OBJ_REF
   .string.ref?:
        ; --------------------------------------------------
        ; MOV     ECX, OFFSET       | B9 FFFFFFFF           ; string reference (9B)
        ; MOV     EDX, DWORD [ECX]  | 8B11
        ; PUSH    DWORD [EDX]       | FF32
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .string.ref?.out
        cmp     [edi + 05], dword 0x32FF118B
        jne    .string.ref?.out
   .string.ref:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
        mov     ecx, OBJ_STRING_REF
        jmp    .return
   .string.ref?.out:
    $end
        ;
   .9B.5B.out:
   .9B.out:

    $ifdef SIC_UC.OBJ_INT_RAX_ST0
   .8B:
        cmp     esi, 8
        jl     .8B.out
        lea     edi, [ebx - 8]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .8B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .8B.out
   .8B.1B:
        cmp     eax, 1
        jne    .8B.1B.out
        ;
   .int.rax.st0?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; PUSH    EAX               | 50                    ; integer RAX ST0 (8B)
        ; FILD    DWORD [ESP]       | DB0424
        ; POP     EAX               | 58
        ; FSTP    QWORD [ESP]       | DD1C24
        ; --------------------------------------------------
        cmp     [edi + 00], dword 0x2404DB50
        jne    .int.rax.st0?.out
        cmp     [edi + 00], dword 0x241CDD58
        jne    .int.rax.st0?.out
   .int.rax.st0:
        mov     ecx, OBJ_INT_RAX_ST0
        jmp    .return
   .int.rax.st0?.out:
        ;
   .8B.1B.out:
   .8B.out:
    $end

   .7B:
        cmp     esi, 7
        jl     .7B.out
        lea     edi, [ebx - 7]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .7B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .7B.out
   .7B.5B:
        cmp     eax, 5
        jne    .7B.5B.out
        ;
   .int.var?:
        ; --------------------------------------------------
        ; MOV     EAX, OFFSET       | B8 FFFFFFFF           ; integer variable (7B)
        ; PUSH    DWORD [EAX]       | FF30
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB8
        jne    .int.var?.out
        cmp     [edi + 05], word 0x30FF
        jne    .int.var?.out
   .int.var:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
        mov     ecx, OBJ_INT_VAR
        jmp    .return
   .int.var?.out:
        ;
   .string.var?:
        ; --------------------------------------------------
        ; MOV     EDX, OFFSET       | BA FFFFFFFF           ; string variable (7B)
        ; PUSH    DWORD [EDX]       | FF32
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .string.var?.out
        cmp     [edi + 05], word 0x32FF
        jne    .string.var?.out
   .string.var:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
        mov     ecx, OBJ_STRING_VAR
        jmp    .return
   .string.var?.out:
        ;
   .7B.5B.out:
        ;
    $ifdef SIC_UC.OBJ_IND
   .7B.2B:
        cmp     eax, 2
        jne    .7B.2B.out
        ;
   .double.ind?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     ECX, DWORD [ECX]  | 8B09                  ; double indirect (7B)
        ; PUSH    DWORD [ECX+4]     | FF71 04
        ; PUSH    DWORD [ECX]       | FF31
        ; --------------------------------------------------
        cmp     [edi + 00], dword 0x71FF098B
        jne    .double.ind?.out
        cmp     [edi + 03], dword 0x31FF0471
        jne    .double.ind?.out
   .double.ind:
        mov     ecx, OBJ_DOUBLE_IND
        jmp    .return
   .double.ind?.out:
        ;
   .7B.2B.out:
    $end
   .7B.out:

   .6B:
        cmp     esi, 6
        jl     .6B.out
        lea     edi, [ebx - 6]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .6B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .6B.out
   .6B.5B:
        cmp     eax, 5
        jne    .6B.5B.out
        ;
   .int.con?:
        ; --------------------------------------------------
        ; MOV     EAX, VALUE        | B8 FFFFFFFF           ; integer constant (6B)
        ; PUSH    EAX               | 50
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB8
        jne    .int.con?.out
        cmp     [edi + 05], byte 0x50
        jne    .int.con?.out
   .int.con:
        mov     ecx, OBJ_INT_CON
        jmp    .return
   .int.con?.out:
        ;
   .string.con?:
        ; --------------------------------------------------
        ; MOV     EDX, VALUE        | BA FFFFFFFF           ; string constant (6B)
        ; PUSH    EDX               | 52
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .string.con?.out
        cmp     [edi + 05], byte 0x52
        jne    .string.con?.out
   .string.con:
        mov     ecx, OBJ_STRING_CON
        jmp    .return
   .string.con?.out:
        ;
   .6B.5B.out:
   .6B.out:

   .5B:
        cmp     esi, 5
        jl     .5B.out
        lea     edi, [ebx - 5]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .5B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .5B.out
   .5B.5B:
        cmp     eax, 5
        jne    .5B.5B.out
        ;
    $ifdef _SSEX
   .double.sse?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOVSD   QWORD [ESP], XMM0 | F20F110424            ; double SSE (5B)
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xF2
        jne    .double.sse?.out
        cmp     [edi + 01], dword 0x2404110F
        jne    .double.sse?.out
   .double.sse:
        mov     ecx, OBJ_DOUBLE_SSE
        jmp    .return
   .double.sse?.out:
    $end
        ;
   .label.off?:
        ; --------------------------------------------------
        ; MOV     EDX, VALUE        | BA FFFFFFFF           ; label offset (5B)
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xBA
        jne    .label.off?.out
   .label.off.test:
        mov     edx, [edi + 01]
        test    edx, edx
        jz     .return
   .label.off:
        mov     ecx, OBJ_LOFFSET
        jmp    .return
   .label.off?.out:
        ;
   .arg.count?:
        ; --------------------------------------------------
        ; MOV     ECX, VALUE        | B9 FFFFFFFF           ; argument count (5B)
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], byte 0xB9
        jne    .arg.count?.out
   .arg.count:
        mov     ecx, OBJ_ARG_COUNT
        jmp    .return
   .arg.count?.out:
        ;
   .5B.5B.out:
   .5B.out:

   .4B:
        cmp     esi, 4
        jl     .4B.out
        lea     edi, [ebx - 4]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .4B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .4B.out
   .4B.3B:
;       cmp     eax, 3
;       jne    .4B.3B.out
        ;
   .4B.3B.out:
        ;
    $ifdef SIC_UC.OBJ_IND
   .4B.2B:
        cmp     eax, 2
        jne    .4B.2B.out
        ;
   .int.ind?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EAX, DWORD [ECX]  | 8B01                  ; integer indirect (4B)
        ; PUSH    DWORD [EAX]       | FF30
        ; --------------------------------------------------
        cmp     [edi + 00], dword 0x30FF018B
        jne    .int.ind?.out
   .int.ind:
        mov     rcx, OBJ_INT_IND
        jmp    .return
   .int.ind?.out:
        ;
   .string.ind?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     EDX, DWORD [ECX]  | 8B11                  ; string indirect (4B)
        ; PUSH    DWORD [EDX]       | FF32
        ; --------------------------------------------------
        cmp     [edi + 00], dword 0x32FF118B
        jne    .string.ind?.out
   .string.ind:
        mov     rcx, OBJ_STRING_IND
        jmp    .return
   .string.ind?.out:
        ;
   .4B.2B.out:
    $end
   .4B.out:

   .3B:
        cmp     esi, 3
        jl     .3B.out
        lea     edi, [ebx - 3]
        call    SIC_IDA.ida                                 ; eax = current instruction size
        test    eax, eax
        jz     .3B.out
        and     edx, IDA_INVALID                            ; edx = instruction flags
        jnz    .3B.out
   .3B.3B:
        cmp     eax, 3
        jne    .3B.3B.out
        ;
   .double.st0?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [ESP]       | DD1C24                ; double ST0 (3B)
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], word 0x1CDD
        jne    .double.st0?.out
        cmp     [edi + 02], byte 0x24
        jne    .double.st0?.out
   .double.st0:
        mov     ecx, OBJ_DOUBLE_ST0
        jmp    .return
   .double.st0?.out:
        ;
   .int.rsp.rax?:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [ESP], EAX        | 890424                ; integer RSP RAX (3B)
        ;>
        ; --------------------------------------------------
        cmp     [edi + 00], word 0x0489
        jne    .int.rsp.rax?.out
        cmp     [edi + 02], byte 0x24
        jne    .int.rsp.rax?.out
   .int.rsp.rax:
        mov     ecx, OBJ_INT_RSP_RAX
        jmp    .return
   .int.rsp.rax?.out:
        ;
   .3B.3B.out:
   .3B.out:

   .return:
        pop     eax edi esi ebx
        ret
endp

; ------------------------------------------------------------------------------
