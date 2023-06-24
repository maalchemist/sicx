
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; build functions

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_B:

; ------------------------------------------------------------------------------

; DWORD sic_build ( LPVOID sic, LPCSTR s, DWORD sop )
;
; allocate memory for sic code segment and compile string ( s )
; <s> can be multiline expression with ';' as delimiter
;
; -> sic : T_sic_data structure offset
; -> s   : string to compile
; -> sop : sic compiler options
;
; <- eax        : generated code size or zero on error
; <- sic.coops  : actual compiler options
; <- sic.tokens : scanned tokens count
; <- sic.ccurs  : current string cursor
; <- sic.pcurs  : previous string cursor
;
$proc sic_build, sic, s, sop

    macro .proc.enter
    {
      $ifdef _X64 ; push & 16-byte stack align for x64
        pushsa  rbx, rsi, rdi, r12, r13, r14, r15
      $else
        push    ebx esi edi
      $end

      $ifdef _SSEX                              ; built-in functions can modify xmm6, xmm7 registers
      $ifdef _X64
        movdqa  dqword [.xmm6], xmm6
        movdqa  dqword [.xmm7], xmm7
      $else
        movdqu  dqword [.xmm6], xmm6
        movdqu  dqword [.xmm7], xmm7
      $end
      $end

      $ifdef _SSEX
        stmxcsr [.mxcsr_o]                      ; save mxcsr register
        and     [.mxcsr_o], 0xFFFFFFC0          ; 11000000 ; clear exceptions
        stmxcsr [.mxcsr_n]                      ; copy mxcsr register
;       and     [.mxcsr_n], dword 0xFFFF807F    ; 10000000 01111111 ; reset RC/m bits
        and     [.mxcsr_n], dword 0xFFFF8040    ; 10000000 01000000 ; reset RC/m bits, clear exceptions
        or      [.mxcsr_n], dword 0x00007F80    ; 01111111 10000000 ; round toward zero, mask all exceptions
        ldmxcsr [.mxcsr_n]                      ; load mxcsr register
      $end
        fnclex
        fnstcw  [.fpu_cw_o]                     ; save FPU control word
        mov     [.fpu_cw_n], word 0x0F3F        ; 00001111 00111111 ; round toward zero, full precision, mask all exceptions
        fldcw   [.fpu_cw_n]                     ; load FPU control word
    }

    macro .proc.leave
    {
      $ifdef _SSEX
        ldmxcsr [.mxcsr_o]                      ; restore mxcsr register
      $end
        fnclex
        fldcw   [.fpu_cw_o]                     ; restore FPU control word

      $ifdef _SSEX
      $ifdef _X64
        movdqa  xmm6, dqword [.xmm6]
        movdqa  xmm7, dqword [.xmm7]
      $else
        movdqu  xmm6, dqword [.xmm6]
        movdqu  xmm7, dqword [.xmm7]
      $end
      $end

      $ifdef _X64
        pop     r15 r14 r13 r12 rdi rsi rbx
      $else
        pop     edi esi ebx
      $end
    }

    ; test character is "alphabetic" ('.', '_', '@', 'A'..'Z', 'a'..'z')
    ; -> al = ah : character to test
    ; modifies al
    macro .chisa al, ah, label
    {
        cmp     al, '.'
        je      label                           ; '.'
        cmp     al, '_'
        je      label                           ; '_'
        ;
        sub     al, '@' + 27
        add     al, 27
        jc      label                           ; '@', 'A'..'Z'
        mov     al, ah
        sub     al, 'a' + 26
        add     al, 26
        jc      label                           ; 'a'..'z'
    }

    ; test character is "alphabetic" ('.', '_', '@', 'A'..'Z', 'a'..'z') or numeric ('0'..'9')
    ; -> al = ah : character to test
    ; modifies al
    macro .chisan al, ah, label
    {
        cmp     al, '.'
        je      label                           ; '.'
        cmp     al, '_'
        je      label                           ; '_'
        ;
        sub     al, '@' + 27
        add     al, 27
        jc      label                           ; '@', 'A'..'Z'
        mov     al, ah
        sub     al, 'a' + 26
        add     al, 26
        jc      label                           ; 'a'..'z'
        mov     al, ah
        sub     al, '0' + 10
        add     al, 10
        jc      label                           ; '0'..'9'
    }

    macro .option.test [value]
    {
      forward
        cinvoke _strnicmp, edi, SC_SIC_OPT_FLAG_#value, SC_SIC_OPT_FLAG_#value#.size
        test    eax, eax
        jnz     @F
        mov     esi, SIC_OPT_FLAG_#value
        add     edi, SC_SIC_OPT_FLAG_#value#.size
        jmp    .option.x.change
        @@:
    }

   .sop.buffer.icount   EQU 256                 ; compiler options buffer items count
   .sop.buffer.size     EQU .sop.buffer.icount * 4

    locals
      $ifdef _SSEX
       .xmm6            dq 2 dup ?              ; !!! .xmm temp variables must be 16-byte aligned
       .xmm7            dq 2 dup ?              ; !!! declaration must be at the begin of locals
      $end

       .mxcsr_o         dd ?
       .mxcsr_n         dd ?
       .mxcsr           dd ?
       .fpu_cw_o        dw ?
       .fpu_cw_n        dw ?
       .fpu_sw          dw ?

       .sic             T_sic32_data ?
       .ecode           dd ?                    ; error code
       .rdata           dd ?
       .code            dd ?
       .code.shift      dd ?                    ; code shift
       .code.xsize      dd ?
       .e               dd ?                    ; expression
       .s               dd ?
       .s.buffer        dd ?
       .size            dd ?
       .o               dd ?
       .z               dd ?
       .sop             dd ?                    ; compiler options
       .sop.active      dd ?                    ; compiler options
       .sop.buffer      dd ?                    ; compiler options buffer
       .sop.buffer.item dd ?                    ; compiler options buffer current item index
       .coops           dd ?                    ; actual compiler options
       .seg.count       dd ?
       .cspace          dd ?                    ; free bytes available for code
       .code.size       dd ?                    ; maximum code size
       .csize           dd ?                    ; code size
       .esi             dd ?
       .edi             dd ?
       .ppchar          dd ?
       .opparam         dd ?                    ; option parameter offset
       .int32param      dd ?
       .agn             dd ?                    ; align bytes
       .ano             db ?                    ; anonymous label flag
       .char            db ?
       .cbra            dd ?                    ; parenthesis counter ()
       .csbra           dd ?                    ; square bracket counter []
       .ccbra           dd ?                    ; curly bracket counter {}
       .mups            dd ?                    ; markup symbols counter
       .nops            dd ?
       .call            db ?                    ; call flag
       .code.enter      db ?                    ; code enter flag
       .code.exit       db ?                    ; code exit flag
       .rcode.exit      db ?                    ; rcode.exit flag
       .cname           rb citem.nsize
       .option          db ?
       .no.compile      db ?
       .accept.code     db ?

       .stack.frame.on  db ?                    ; stack.frame
       .stack.align.on  db ?                    ; stack.align
       .locals.on       db ?                    ; locals
       .fp.frame.on     db ?                    ; fp.frame
    endl

;       mov     [sic], rcx
;       mov     [s], rdx
;       mov     [sop], r8
;       mov     [], r9

       .proc.enter

        mov     ebx, [sic]                      ; ebx = sic data structure offset
        test    ebx, ebx
        jz     .error.null.sic

        lea     esi, [.sic]                     ; esi = temp sic structure offset
        stdcall zerosic, esi

        xor     eax, eax
        mov     [.s.buffer], eax                ; clear string buffer
        mov     [.ecode], eax                   ; clear error code
        mov     [.cbra], eax                    ; clear parenthesis counter
        mov     [.csbra], eax                   ; clear square bracket counter
        mov     [.ccbra], eax                   ; clear curly bracket counter
        mov     [.nops], eax
        mov     [.seg.count], eax
        mov     [.code.shift], eax              ; clear code shift
        mov     [.code.xsize], eax
        mov     [.csize], eax                   ; clear code size
        mov     [.call], al
        mov     [.no.compile], al
        mov     [.code.enter], al
        mov     [.code.exit], al
        mov     [.rcode.exit], al
        mov     [.stack.frame.on], al
        mov     [.stack.align.on], al
        mov     [.locals.on], al
        mov     [.fp.frame.on], al

        mov     [.accept.code], 1

        mov     eax, [@_CFG.code_size]          ; eax = free bytes available for code
        mov     [.cspace], eax                  ; assign available bytes
        mov     [.code.size], eax               ; assign maximum code size

        stdcall cfree, [ebx + T_sic_data.code]  ; free previously allocated memory
        stdcall hfree, [ebx + T_sic_data.data]
        lea     ecx, [ebx + T_sic_data.code]    ; clear data
        stdcall fillchar, ecx, sizeof.T_sic_data - T_sic_data.code, 0

   .sop.buffer.in:                              ; options buffer
        mov     ecx, .sop.buffer.size
        stdcall halloc, ecx                     ; allocate memory for options buffer
        test    eax, eax
        jz     .error                           ; error. memory allocation error
        mov     [.sop.buffer], eax
        mov     [.sop.buffer.item], 0           ; clear options buffer
        stdcall fillchar, eax, .sop.buffer.size, 0
   .sop.buffer.out:

        mov     edx, [sop]
        mov     [.sop.active], edx
        mov     eax, [.sop.buffer]              ; eax = options buffer address
        mov     [eax], edx
        mov     [.coops], edx
        or      edx, SIC_OPT_FLAG_EXTERNAL_CALL ; set external call flag
        mov     [.sop], edx

        mov     edi, [s]                        ; edi = input string offset
        test    edi, edi
        jz     .error.string                    ; error. null string

   .s.buffer.in:
;       invoke  lstrlen, edi
        cinvoke strlen, edi
        test    eax, eax                        ; eax = input string length
        jz     .error.string                    ; error. empty string
;       xor     rcx, rcx
        lea     ecx, [eax + 1]
        stdcall halloc, ecx                     ; allocate memory for string buffer
        test    eax, eax
        jz     .error                           ; error. memory allocation error
        mov     [.s.buffer], eax
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, eax, edi               ; copy input string to string buffer
        cinvoke strcpy, eax, edi                ; copy input string to string buffer
        test    eax, eax
        jz     .error                           ; error. string copy error
   .s.buffer.out:

   .data.in:
        mov     ecx, [@_CFG.memory]
        stdcall halloc, ecx                     ; allocate memory for data segment
        test    eax, eax
        jz     .error                           ; error. memory allocation error
        mov     [ebx + T_sic_data.data], eax
        ;
macro c
{
;       xor     edx, edx
;       test    [sop], SIC_OPT_FLAG_SYSTEM_MEMORY
;       jz     .data.sys.mem.out
;  .data.sys.mem.in:
;       test    eax, 0xF
;       jz      @F                              ; data is already aligned to 16 bytes
;       sub     dl, al                          ; data 16-byte alignment
;       and     edx, 0xF
;   @@:
;       add     edx, sys_mem_dsize              ; reserve bytes for system use
;       mov     [ebx + T_sic_data.dsize], edx
;  .data.sys.mem.out:
;       mov     ecx, [@_CFG.memory]
;       sub     ecx, edx
;       js     .error.memory
;       mov     [ebx + T_sic_data.dspace], ecx
}
        mov     ecx, [@_CFG.memory]
        mov     [ebx + T_sic_data.dspace], ecx
   .data.out:

        stdcall calloc, [.code.size]            ; allocate memory for code segment
        test    eax, eax
        jz     .error                           ; error. memory allocation error
        mov     [ebx + T_sic_data.code], eax    ; eax = code segment offset
        mov     edi, eax                        ; edi = destination
        mov     [.edi], edi                     ; save initial position

        mov     eax, [ebx + T_sic_data.fdata]   ; copy function data segment offset
        mov     [esi + T_sic_data.fdata], eax
        mov     eax, [ebx + T_sic_data.cdata]   ; copy constant data segment offset
        mov     [esi + T_sic_data.cdata], eax
        mov     eax, [ebx + T_sic_data.vdata]   ; copy variable data segment offset
        mov     [esi + T_sic_data.vdata], eax
        mov     eax, [ebx + T_sic_data.rdata]   ; copy runtime data segment offset
        mov     [eax + table.header.icount], 0  ; clear runtime data table
        mov     [esi + T_sic_data.rdata], eax
        mov     [.rdata], eax
        ;
        mov     eax, [ebx + T_sic_data.data]    ; copy data segment offset
        mov     [esi + T_sic_data.data], eax
        mov     eax, [ebx + T_sic_data.dspace]  ; copy data space
        mov     [esi + T_sic_data.dspace], eax
        mov     eax, [ebx + T_sic_data.dsize]   ; copy data size
        mov     [esi + T_sic_data.dsize], eax

        stdcall sysset, [.rdata]                ; set system table items
        stdcall conoze, [.rdata]                ; zero labels offsets
        stdcall tupdate                         ; update tables related data

        mov     [.code.xsize], edi
        mov     edx, [.s.buffer]                ; edx = input string offset
        dec     edx

   .char.next:
        inc     edx
        mov     [.mups], 0
   .char.test:
        mov     cl, byte [edx]
        test    cl, cl
        jz     .char.test.leave                 ; zero termination
        cmp     cl, '/'
        jne    .char.test.char
        mov     ch, byte [edx + 1]
        case    ch,\
                '/', .char.test.leave,\         ; //
                '*', .char.test.leave           ; /*
        jmp    .char.test.markup
   .char.test.char:
        case    cl,\                            ; ? markup symbols
                '!', .char.test.markup,\        ; exclamation mark
                '|', .char.test.markup,\        ; vertical line
                '¦', .char.test.markup,\        ; broken bar
                '#', .char.test.markup,\        ; number sign
                '*', .char.test.markup,\        ; asterisk
                '+', .char.test.markup,\        ; plus sign
                '/', .char.test.markup,\        ; solidus
                '\', .char.test.markup,\        ; reverse solidus
                '•', .char.test.markup          ; bullet
   .char.test.space:
        case    cl,\                            ; skip leading blanks
                0x20, .char.next,\              ; space
                0x0D, .char.next,\              ; carriage return (FE:CR)
                0x0A, .char.next,\              ; line feed (FE:LF)
                0x09, .char.next,\              ; tabulation (FE:TAB)
                0xA0, .char.next,\              ; no-break space
                0x08, .char.next                ; backspace (FE:BS)
        jmp    .char.test.leave
   .char.test.markup:
        inc     [.mups]
        inc     edx
        mov     cl, byte [edx]
        test    cl, cl
        jz     .char.test.leave                 ; zero termination
        cmp     cl, '/'
        jne    .char.test.markup.char
        mov     ch, byte [edx + 1]
        case    ch,\
                '/', .char.test.leave,\         ; //
                '*', .char.test.leave           ; /*
        jmp    .char.test.markup
   .char.test.markup.char:
        case    cl,\                            ; ? markup symbols
                '!', .char.test.markup,\        ; exclamation mark
                '|', .char.test.markup,\        ; vertical line
                '¦', .char.test.markup,\        ; broken bar
                '#', .char.test.markup,\        ; number sign
                '*', .char.test.markup,\        ; asterisk
                '+', .char.test.markup,\        ; plus sign
                '/', .char.test.markup,\        ; solidus
                '\', .char.test.markup,\        ; reverse solidus
                '•', .char.test.markup          ; bullet
   .char.test.markup.space:
        case    cl,\                            ; skip blanks
                0x20, .char.next,\              ; space
                0x0D, .char.next,\              ; carriage return (FE:CR)
                0x0A, .char.next,\              ; line feed (FE:LF)
                0x09, .char.next,\              ; tabulation (FE:TAB)
                0xA0, .char.next,\              ; no-break space
                0x08, .char.next                ; backspace (FE:BS)
        sub     edx, [.mups]
   .char.test.leave:
        mov     [.mups], 0
        mov     [.e], edx
        dec     edx

   .scan:
        inc     edx
        mov     cl, byte [edx]
   .scan.test:
        cmp     cl, '$'
        je     .scan.test.options
        cmp     cl, '#'
        jne    .scan.test.char
   .scan.test.options:
        call   .test.options
        cmp     [.option], 0
        jz     .scan.test.char
        mov     ecx, edx
        sub     ecx, [.e]                       ; ecx = length of string to compile
        jz     .scan.update.options
        mov     cl, byte [edx - 1]
        case    cl,\
                0x0D, .scan.options.segment,\   ; carriage return (FE:CR)
                0x0A, .scan.options.segment     ; line feed (FE:LF)
;       case    cl,\
;               0x20, .scan.options.segment,\   ; space
;               0x0D, .scan.options.segment,\   ; carriage return (FE:CR)
;               0x0A, .scan.options.segment,\   ; line feed (FE:LF)
;               0x09, .scan.options.segment,\   ; tabulation (FE:TAB)
;               0xA0, .scan.options.segment,\   ; no-break space
;               0x08, .scan.options.segment     ; backspace (FE:BS)
        jmp    .error.token
   .scan.options.segment:
        dec     edx
        mov     cl, '¶'
        mov     byte [edx], cl
        jmp    .segment.test
   .scan.update.options:
        call   .update.options
        cmp     [.ecode], 0
        jnz    .error.main
        mov     cl, byte [edx]
   .scan.test.char:
        case    cl,\
                '/', .comment.L0,\              ; comment
                '"', .string.L0,\               ; string
                "'", .string.L2,\               ; string
                '“', .string.L3,\               ; string
                '„', .string.L3,\               ; string
                '‘', .string.L4,\               ; string
                '‚', .string.L4,\               ; string
                "«", .string.L5,\               ; string
                "‹", .string.L6,\               ; string
                ':', .label.L0,\                ; label termination
                '(', .bra,\                     ; left parenthesis
                ')', .ket,\                     ; right parenthesis
                '[', .lsbra,\                   ; left square bracket
                ']', .rsbra,\                   ; right square bracket
                '{', .lcbra,\                   ; left curly bracket
                '}', .rcbra,\                   ; right curly bracket
                ';', .segment.test,\            ; segment or argument separator
                '¶', .segment,\                 ; paragraph
                '§', .segment,\                 ; section sign
                 0 , .segment

   .scan.test.CRLF?:
        test    [sop], SIC_OPT_FLAG_COMPACT
        jz     .scan
        case    cl,\
                0x0D, .scan.test.CRLF,\         ; carriage return (FE:CR)
                0x0A, .scan.test.CRLF           ; line feed (FE:LF)
        jmp    .scan.next
   .scan.test.CRLF:
        inc     edx
        mov     cl, byte [edx]
        case    cl,\
                0x0D, .scan.test.CRLF,\
                0x0A, .scan.test.CRLF
        dec     edx
        mov     cl, byte [edx]
        jmp    .segment.test

   .scan.next:
        jmp    .scan

   .comment.L0:                                 ; /
        mov     eax, edx                        ; eax = comment entry
        inc     edx
        mov     cl, byte [edx]
        case    cl,\
                '/', .comment.L2,\
                '*', .comment.L4
        jmp    .scan.test
   .comment.L2:                                 ; //
        inc     edx
        mov     cl, byte [edx]
        case    cl,\                            ; search for line or segment end
                0x0D, .comment.L22,\            ; carriage return (FE:CR)
                0x0A, .comment.L22,\            ; line feed (FE:LF)
                   0, .comment                  ; string termination
        jmp    .comment.L2
   .comment.L22:
        inc     edx
        mov     cl, byte [edx]
        case    cl,\                            ; search for line or segment end
                0x0D, .comment.L22,\            ; carriage return (FE:CR)
                0x0A, .comment.L22              ; line feed (FE:LF)
;       dec     edx
;       mov     cl, byte [edx]
        jmp    .comment
   .comment.L4:                                 ; /*
        inc     edx
        cmp     byte [edx], 0
        jz     .comment
        cmp     word [edx], '*/'
        jnz    .comment.L4
        add     edx, 2
   .comment:
        mov     byte [eax], 0xA0                ; replace comment with no-break spaces
        inc     eax
        cmp     eax, edx
        jne    .comment
        mov     cl, '¶'                         ; paragraph (end of segment)
        dec     edx
        mov     [edx], cl
        jmp    .scan.test

   .string.L6:
        mov     ch, "›"
        jmp    .string.scan
   .string.L5:
        mov     ch, "»"
        jmp    .string.scan
   .string.L4:
        mov     ch, "’"
        jmp    .string.scan
   .string.L3:
        mov     ch, "”"
        jmp    .string.scan
   .string.L2:
        mov     ch, "'"
        jmp    .string.scan
   .string.L0:
        mov     ch, '"'
   .string.scan:
        inc     edx
        mov     cl, byte [edx]
        case    cl,\
                ch, .string.leave,\             ; string end
                 0, .segment
        jmp    .string.scan
   .string.leave:
        mov     cl, byte [edx - 1]
        cmp     cl, '\'
        je     .string.scan                     ; bypass \" \' \” \’ \» \›
        jmp    .scan

   .label.L0:
        mov     eax, edx
   .label.L0.scan:
        inc     eax
        mov     cl, byte [eax]                  ; bypass blanks
        xcase  .label.L0.scan, cl, 0x20, 0x09, 0xA0, 0x08
;       xcase  .label.L0.scan, cl, 0x20, 0x0D, 0x0A, 0x09, 0xA0, 0x08
        cmp     cl, '='
        je     .label.L0.bypass                 ; bypass :=
;       cmp     cl, ':'
;       je     .label.L0.bypass                 ; bypass ::
        jmp    .label.L0.LL
   .label.L0.bypass:
        mov     edx, eax
        jmp    .scan
   .label.L0.LL:
        mov     [.ano], 0
        mov     eax, edx
   .label.L2:
        dec     eax
        cmp     eax, [.e]
        jge    .label.L2.LL
   .label.L2.C0:
        mov     [.call], 1
        mov     byte [edx], 0xA0
        jmp    .scan
   .label.L2.LL:
        mov     cl, byte [eax]                  ; bypass blanks
;       xcase  .label.L2, cl, 0x20, 0x09, 0xA0, 0x08
        xcase  .label.L2, cl, 0x20, 0x0D, 0x0A, 0x09, 0xA0, 0x08
        inc     eax
        mov     ecx, [.e]                       ; ecx = [.e]
        sub     eax, ecx                        ; eax = label length
        test    eax, eax
        jz     .scan
        cmp     eax, 2
        jne    .label.L2.name
   .label.L2.2B:
        cmp     word [ecx], '@@'                ; ecx = [.e]
        jne    .label.L2.name
   .label.L2.2B.anonymous:                      ; anonymous label
        mov     [.ano], 1
        jmp    .label.align
   .label.L2.name:
        cmp     eax, citem.nsize
        jge    .scan
        cmp     word [ecx], '??'                ; ecx = [.e]
        je     .label.L2.get
        mov     cl, byte [ecx]                  ; ecx = [.e]
        mov     ch, cl
       .chisa   cl, ch, .label.L2.get
        jmp    .scan                            ; bypass non alpha first symbol
   .label.L2.get:
        mov     [.z], eax                       ; [.z] = label length
        push    edx                             ; save edx
        stdcall rtaget, [.rdata], [.e], eax     ; ? runtime object (runtime data segment of sic structure)
        mov     eax, edx                        ; eax = table item offset
        pop     edx                             ; restore edx
        test    eax, eax
        jnz    .label.L2.x

        push    edx                             ; save edx
        stdcall nrtaget, [sic], [.e], [.z]      ; ? defined non runtime object
        pop     edx                             ; restore edx
        test    eax, eax
        jnz    .scan

        mov     ecx, [.e]
        add     ecx, [.z]
   .label.L2.scan:                              ; scan backward label name until chars are "alphabetic" or numeric
        dec     ecx
        cmp     ecx, [.e]
        jl     .label.L2.scan.off
        mov     ah, byte [ecx]
        mov     al, ah
       .chisan  al, ah, .label.L2.scan
   .label.L2.scan.off:
        inc     ecx
        cmp     ecx, [.e]
        jne    .scan
   .label.L2.add:
        push    edx
        lea     ecx, [.cname]
        stdcall copymem, ecx, [.e], [.z]
        lea     ecx, [.cname]
        add     ecx, [.z]
        mov     byte [ecx], 0
        lea     edx, [.cname]
        xor     eax, eax
        mov     al, 'o'
        stdcall rtaset, [.rdata], edx, 0, 0, eax
        pop     edx
        test    eax, eax
        jz     .scan
        inc     [ebx + T_sic_data.rcount]       ; increase runtimes count

   .label.L2.x:
        cmp     byte [eax + citem32.datype], '?'
        jne    .label.L2.o
        mov     byte [eax + citem32.datype], 'o'; change data type of table item
        jmp    .label.L2.o.0
   .label.L2.o:
        cmp     byte [eax + citem32.datype], 'o'
        jne    .scan
   .label.L2.o.0:
        cmp     [eax + citem32.offset], 0
        jne    .scan

   .label.align:
        call   .optima
        push    eax
        lea     ecx, [edx + 1]
   .label.align.scan:
        inc     edx
        mov     al, byte [edx]
        case    al,\
                0x20, .label.align.space,\
                0x0D, .label.align.space,\
                0x0A, .label.align.space,\
                0x09, .label.align.space,\
                0xA0, .label.align.space,\
                0x08, .label.align.space
        cmp     al, '0'
        jb     .label.align.main
        cmp     al, '9'
        ja     .label.align.main
        jmp    .label.align.scan
   .label.align.space:
        mov     byte [edx], '¶'
   .label.align.main:
        cmp     byte [edx], ':'
        jne    .label.align.get                 ; LABEL:: - default alignment at LABEL
        mov     byte [edx], '¶'
        jmp    .label.align.default
   .label.align.get:
        mov     [.o], ecx
        lea     edx, [.s]
        cinvoke strtol, ecx, edx, 10
        mov     edx, [.s]
        cmp     edx, [.o]
        jne    .label.align.assign
   .label.align.no:
        xor     eax, eax
        jmp    .label.align.assign              ; LABEL: - no alignment
   .label.align.default:                        ; default alignment
    $ifdef _X64
        mov     rax, 16
    $else
      $ifdef _SSEX
        mov     eax, 16
      $else
        mov     eax, 8
      $end
    $end
   .label.align.assign:
        mov     [.agn], eax
        pop     eax
        dec     edx
        call   .align
        cmp     [.ano], 0
        jnz    .char.next
   .label.assign:
        mov     [eax + citem32.offset], edi     ; assign label offset
        jmp    .char.next

   .bra:
        inc     [.cbra]
        jmp    .scan
   .ket:
        dec     [.cbra]
        js     .error.bracket
        jmp    .scan

   .lsbra:
        inc     [.csbra]
        jmp    .scan
   .rsbra:
        dec     [.csbra]
        js     .error.bracket
        jmp    .scan

   .lcbra:
        inc     [.ccbra]
        jmp    .scan
   .rcbra:
        dec     [.ccbra]
        js     .error.bracket
        jmp    .scan

   .segment.test:
        cmp     [.cbra], 0
        jnz    .scan
        cmp     [.csbra], 0
        jnz    .scan
        cmp     [.ccbra], 0
        jnz    .scan
   .segment:
        mov     [.char], cl
        mov     [.s], edx
        sub     edx, [.e]                       ; edx = length of string to compile
        jz     .compile.next
        cmp     [.no.compile], 0
        jnz    .compile.next
        cmp     [.accept.code], 0
        jz     .compile.next
        mov     [.size], edx
   .compile.test:
        cmp     [.cbra], 0
        jnz    .error.bracket
        cmp     [.csbra], 0
        jnz    .error.bracket
        cmp     [.ccbra], 0
        jnz    .error.bracket
   .compile.segment.CRLF?:
        test    [sop], SIC_OPT_FLAG_COMPACT
        jz     .compile
        case    cl,\
                0x0D, .compile.segment.CRLF,\   ; carriage return (FE:CR)
                0x0A, .compile.segment.CRLF     ; line feed (FE:LF)
        jmp    .compile
   .compile.segment.CRLF:
        mov     ecx, [.s]
        mov     byte [ecx], '¶'
   .compile:
        cmp     [.call], 0
        jz     .compile.no.call
   .compile.call:
        or      [.sop], SIC_OPT_FLAG_EXECUTE
        jmp    .compile.perform
   .compile.no.call:
        and     [.sop], not SIC_OPT_FLAG_EXECUTE
   .compile.perform:
        mov     [esi + T_sic_data.rcode], edx
        stdcall sic_compile, esi, [.e], [.sop]
        mov     edx, [esi + T_sic_data.dsize]   ; update data size
        mov     [ebx + T_sic_data.dsize], edx
        mov     edx, [esi + T_sic_data.dspace]  ; update data space
        mov     [ebx + T_sic_data.dspace], edx
        mov     edx, [sop]
        mov     [.sop.active], edx              ; save active compiler options

   .compile.break?:
        test    [esi + T_sic_data.coops], SIC_OPT_FLAG_BYPASS
        jnz    .compile.next
        test    eax, eax
        jnz    .compile.success
   .compile.error:
        call   .cursor                          ; update cursor position
        jmp    .compile.break?.out
   .compile.success:
;       xor     rdx, rdx
        mov     edx, [esi + T_sic_data.ccurs]
   .compile.break:
        sub     edx, [.size]
        jns    .compile.break?.out
;       dec     edx
        add     [.s], edx
        mov     edx, [.s]
        mov     dl, byte [edx]
        mov     [.char], dl
   .compile.break?.out:

;       xor     rdx, rdx
        mov     edx, [esi + T_sic_data.coops]
        or      [.coops], edx                   ; set actual compiler options

        mov     edx, [esi + T_sic_data.tokens]
        test    edx, edx
        jz     .compile.next                    ; no tokens. empty segment

        add     [ebx + T_sic_data.tokens], edx

        mov     edx, [esi + T_sic_data.rpn]
        add     [ebx + T_sic_data.rpn], edx
        mov     edx, [esi + T_sic_data.fcount]
        add     [ebx + T_sic_data.fcount], edx
        mov     edx, [esi + T_sic_data.ccount]
        add     [ebx + T_sic_data.ccount], edx
        mov     edx, [esi + T_sic_data.vcount]
        add     [ebx + T_sic_data.vcount], edx
        mov     edx, [esi + T_sic_data.rcount]
        add     [ebx + T_sic_data.rcount], edx

        mov     edx, [esi + T_sic_data.ecode]   ; get error code
        mov     [.ecode], edx
        test    edx, edx
        jnz    .error

        cmp     [.call], 0
        jnz    .compile.execute

   .compile.rcode:
        mov     ecx, [esi + T_sic_data.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .compile.?execute
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .compile.?execute
        jmp    .compile.curs
   .compile.?execute:
        cmp     [esi + T_sic_data.fcount], 0
        jz     .compile.next

   .compile.execute:                            ; execute code
   .compile.execute.enter?:
        cmp     [.code.enter], 0
        jnz    .compile.execute.main
        call   .cb.enter
   .compile.execute.main:
        mov     [.call], 0
;       xor     rcx, rcx
        mov     ecx, [esi + T_sic_data.size]
        test    ecx, ecx
        jz     .compile.next
        mov     edx, [esi + T_sic_data.code]
        test    edx, edx
        jz     .compile.next
        mov     edx, [esi + T_sic_data.entry]
        test    edx, edx
        jz     .compile.next
        mov     byte [edx + ecx], 0xC3
        ;
        push    edi ebx                         ; save registers when calling the built-in functions
    $ifdef _X64                                 ; x64 stack align
   .compile.execute.align:
        push    0
        test    spl, 0x0F
        jz     .compile.execute.align.leave
        push    8
   .compile.execute.align.leave:
        sub     rsp, 0x20                       ; ??? allocate 32 bytes of "shadow space"
    $end
    $ifdef _SSEX
        xnclex
    $else
        fnclex
    $end
        call    edx
    $ifdef _X64                                 ; x64 stack align
        add     rsp, 0x20
        pop     rcx
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
    $end
    $ifdef _SSEX
;       xorpd   xmm0, xmm0
    $else
        ffree   st0
    $end
        pop     ebx edi
   .compile.execute.test:
    $ifdef _SSEX
        stmxcsr [.mxcsr]
        test    [.mxcsr], 00001101B             ; test OE, ZE and IE flags
        jnz    .compile.execute.error           ; error
    $else
        fnstsw  [.fpu_sw]
        test    [.fpu_sw], 00001101B            ; test OE, ZE and IE flags
        jnz    .compile.execute.error           ; error
    $end
        inc     [.seg.count]                    ; valid segment
        jmp    .compile.next                    ; success
   .compile.execute.error:
        call   .cursor                          ; update cursor position
        jmp    .error.execute

   .compile.curs:
        call   .cursor                          ; update cursor position

   .compile.rcode.jump:
        test    [esi + T_sic_data.rcode], RCODE_FLAG_JUMP
        jz     .compile.rcode.jump.out
;       cmp     [esi + T_sic_data.fcount], 1
;       jne    .error
   .compile.rcode.jump.out:

   .compile.rcode.retn:
        test    [esi + T_sic_data.rcode], RCODE_FLAG_RETN
        jz     .compile.rcode.retn.out
        cmp     [esi + T_sic_data.fcount], 1
        jne    .error
   .compile.rcode.retn.out:

   .compile.rcode.exit:
        test    [esi + T_sic_data.rcode], RCODE_FLAG_EXIT
        jz     .compile.rcode.exit.out
;       cmp     [esi + T_sic_data.fcount], 1
;       jne    .error
        mov     [.rcode.exit], 1
   .compile.rcode.exit.out:

   .compile.code:
        test    eax, eax
        jnz    .compile.code.main
   .compile.code.z:
        ; if RCODE_FLAG_ZERO_SIZE is set, the zero-size code is not an error
        test    [esi + T_sic_data.rcode], RCODE_FLAG_ZERO_SIZE
        jz     .error

   .compile.code.main:
        @@bound eax, .error.memory

        inc     [.seg.count]                    ; valid segment
        mov     [.nops], 0

   .compile.code.copy:
   .compile.code.enter?:
        cmp     [.code.enter], 0
        jnz    .compile.code.copy.main
        call   .cb.enter
   .compile.code.copy.main:
;       xor     rax, rax
        mov     eax, [esi + T_sic_data.size]
        test    eax, eax
        jz     .compile.code.copy.out
        mov     edx, [esi + T_sic_data.code]
        stdcall copymem, edi, edx, eax
;       xor     rax, rax
        mov     eax, [esi + T_sic_data.size]
        add     edi, eax
        add     [.csize], eax                   ; increase code size
   .compile.code.copy.out:
        ;
   .compile.next:
        mov     [.call], 0
        mov     [.no.compile], 0
        cmp     [.char], 0
        jnz    .compile.next.char
   .compile.next.exit?:
        cmp     [.csize], 0
        jz     .compile.out
        cmp     [.code.exit], 0
        jz     .compile.next.exit
        jmp    .compile.out
   .compile.next.exit:
        mov     [.code.exit], 1
        mov     edx, [.sop.active]              ; restore active compiler options
        mov     [sop], edx
        or      edx, SIC_OPT_FLAG_EXTERNAL_CALL ; set external call flag
        mov     [.sop], edx
    $ifdef _X64
        mov     rdx, ??exit.code
        mov     [.e], rdx
        dec     rdx
    $else
        mov     edx, ??exit.code - 1
        mov     [.e], ??exit.code
    $end
        jmp    .char.next
   .compile.next.char:
        mov     edx, [.s]
        lea     eax, [edx + 1]
        mov     [.e], eax
        jmp    .char.next
   .compile.out:

   .cb.segments:
        mov     edx, [.seg.count]
        test    edx, edx
        jnz    .cb.segments.out
        mov     eax, [esi + T_sic_data.size]
        test    eax, eax
        jz     .error                           ; error. no valid segments
   .cb.segments.out:

   .cb.runtimes:
        stdcall conoun, [.rdata]
        test    eax, eax
        jnz    .error.rt.token                  ; error. undefined runtime items found
   .cb.runtimes.out:

        sub     edi, [.nops]

;       cmp     [.code.enter], 0
;       jz     .cb.CODE.empty
        sub     [.code.xsize], edi              ; [.code.xsize] - negative or zero
        cmp     [.code.xsize], 0
        jnz    .cb.CODE.assigned
   .cb.CODE.empty:
    $ifdef _SSEX
        @@_XORPD_XMM0_XMM0
    $else
        @@_FLDZ
    $end
        jmp    .cb.leave

   .cb.CODE.assigned:
        cmp     [.rcode.exit], 0
        jz     .cb.CODE
   .cb.CODE.exit:
    $ifdef _SSEX
   .cb.CODE.exit.MOVSD:
        ; ---------------------------------------
        @@_EXIT_CODE_MOVSD_32
        ; ---------------------------------------
        jmp    .cb.leave
    $else
        ; ---------------------------------------
        ;?DDD8             FSTP ST0
        ; ---------------------------------------
        mov     dx, [edi - 2]
        cmp     dx, word 0xD8DD
        je     .cb.CODE.exit.FSTP
   .cb.CODE.exit.FLDZ:
        ; ---------------------------------------
        @@_EXIT_CODE_FLDZ_32
        ; ---------------------------------------
        jmp    .cb.leave
   .cb.CODE.exit.FSTP:
        @@xshl  edi, 2                          ; remove last <FSTP ST0> instruction
        add     [.code.shift], 2
   .cb.CODE.exit.FLDQ:
        ; ---------------------------------------
        @@_EXIT_CODE_FLDQ_32
        ; ---------------------------------------
        jmp    .cb.leave
    $end
   .cb.CODE.exit.out:

   .cb.CODE:
    $ifdef _SSEX
        ; ---------------------------------------
        ;?DDC0             FFREE ST0
        ; ---------------------------------------
        mov     dx, [edi - 2]
        cmp     dx, word 0xC0DD
        jne    .cb.CODE.out
   .cb.CODE.FFREE:
        ; ---------------------------------------
        ;*DDC0             FFREE ST0
        ; ---------------------------------------
        @@xshl  edi, 2                          ; remove last <FFREE ST0> instruction
        add     [.code.shift], 2
;       jmp    .cb.CODE.out
    $else
        ; ---------------------------------------
        ;?DDD8             FSTP ST0
        ; ---------------------------------------
        mov     dx, [edi - 2]
        cmp     dx, word 0xD8DD
        je     .cb.CODE.FSTP
   .cb.CODE.FLDZ:
        ; ---------------------------------------
        @@_FLDZ
        ; ---------------------------------------
        jmp    .cb.CODE.out
   .cb.CODE.FSTP:
        ; ---------------------------------------
        ;*DDD8             FSTP ST0
        ; ---------------------------------------
        @@xshl  edi, 2                          ; remove last <FSTP ST0> instruction
        add     [.code.shift], 2
;       jmp    .cb.CODE.out
    $end
   .cb.CODE.out:

   .cb.leave:

   .cb.leave.??exit:
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        test    edx, edx                        ; edx = ??exit label table item offset
        jz     .cb.leave.??exit.out
   .cb.leave.??exit.in:
        mov     ecx, [edx + citem32.offset]
        sub     ecx, [.code.shift]
        mov     [edx + citem32.offset], ecx
   .cb.leave.??exit.out:

        mov     ecx, [.code.shift]
        sub     [.edi], ecx

   .cb.leave.eflags.test:
        cmp     [.fp.frame.on], 0
        jz     .cb.leave.eflags.out
   .cb.leave.eflags.in:
        ; ---------------------------------------
      $ifdef _SSEX
        @@_SSE_FRAME_LEAVE_32                   ; SSE frame
      $else
        @@_FPU_FRAME_LEAVE_32                   ; FPU frame
      $end
        ; ---------------------------------------
   .cb.leave.eflags.out:

    $ifdef _X64
   .cb.leave.align.test:
        cmp     [.stack.align.on], 0
        jz     .cb.leave.align.out
   .cb.leave.align.in:
        ; ---------------------------------------
        @@_ADD_RSP_8
        ; ---------------------------------------
   .cb.leave.align.out:
    $end

   .cb.leave.eflags.off.test:
        cmp     [.fp.frame.on], 0
        jnz    .cb.leave.eflags.off.out
   .cb.leave.eflags.off.in:
        ; ---------------------------------------
        @@_XOR_EAX_EAX                          ; return null FPU exception flags in EAX
        ; ---------------------------------------
   .cb.leave.eflags.off.out:

   .cb.leave.frame.test:
        cmp     [.stack.frame.on], 0
        jz     .cb.leave.frame.out
   .cb.leave.frame.in:
        ; ---------------------------------------
        @@_LEAVE_32                             ; restore stack
        ; ---------------------------------------
   .cb.leave.frame.out:

   .cb.leave.return.in:
        ; ---------------------------------------
        @@_RET                                  ; return
        ; ---------------------------------------
   .cb.leave.return.out:

        call   .optima

        mov     edx, edi
        sub     edx, [ebx + T_sic_data.code]    ; edx = code size
        cmp     edx, 0
        jle    .error

        mov     [ebx + T_sic_data.size], edx

   .realloc.code.test:
   .realloc.code:
        mov     ecx, [ebx + T_sic_data.code]
        mov     [.code], ecx
        stdcall crealloc, ecx, edx
        mov     [ebx + T_sic_data.code], eax
        mov     [ebx + T_sic_data.entry], eax
        sub     eax, [.code]                    ; eax = code delta
        stdcall conoup, [.rdata], eax           ; update labels offsets
   .realloc.code.out:
;       mov     eax, [ebx + T_sic_data.code]
;       mov     [ebx + T_sic_data.entry], eax

   .realloc.data.test:
   .realloc.data:
;       xor     rdx, rdx
        mov     edx, [ebx + T_sic_data.dsize]
        test    edx, edx
        jnz    .realloc.data.realloc
   .realloc.data.free:
        stdcall hfree, [ebx + T_sic_data.data]  ; free data segment
        xor     eax, eax
        mov     [ebx + T_sic_data.data], eax    ; clear data segment fields
        mov     [ebx + T_sic_data.dsize], eax
        mov     [ebx + T_sic_data.dspace], eax
        jmp    .realloc.data.out
   .realloc.data.realloc:
        mov     ecx, [ebx + T_sic_data.data]
        stdcall hrealloc, ecx, edx              ; offset remains the same
;       test    eax, eax
;       jz     .realloc.data.out
;       mov     [ebx + T_sic_data.data], eax
;       stdcall datoup, [.rdata], ???           ; update data offsets
   .realloc.data.out:

        stdcall FlushCodeCache, ebx

   .return:
        stdcall cfree, [esi + T_sic_data.code]  ; free previously allocated memory
        stdcall hfree, [.s.buffer]              ; free string buffer
        stdcall hfree, [.sop.buffer]            ; free options buffer
        mov     eax, [.coops]
        and     eax, SIC_OPT_USER_FLAGS         ; return only user-available compiler options
        mov     [ebx + T_sic_data.coops], eax   ; return actual compiler options
;       xor     eax, eax
        mov     eax, [ebx + T_sic_data.size]    ; return code size
       .proc.leave
        ret

   .error.string:
        mov     [.ecode], SIC_ERROR_STRING
        jmp    .error.main
   .error.memory:
        mov     [.ecode], SIC_ERROR_MEMORY
        jmp    .error.main
   .error.bracket:
        mov     [.ecode], SIC_ERROR_BRACKET
        jmp    .error.main
   .error.execute:
        mov     [.ecode], SIC_ERROR_EXECUTE
        jmp    .error.main
   .error.token:
        mov     [.ecode], SIC_ERROR_TOKEN
        jmp    .error.main
   .error.rt.token:
        mov     [.ecode], SIC_ERROR_RT_TOKEN
        jmp    .error.main
   .error:
        cmp     [.ecode], 0
        jnz    .error.main
        mov     [.ecode], SIC_ERROR_GENERAL
   .error.main:
        push    edx
        stdcall cfree, [esi + T_sic_data.code]  ; free previously allocated memory
        stdcall cfree, [ebx + T_sic_data.code]
        stdcall hfree, [ebx + T_sic_data.data]
        mov     eax, [.coops]
        and     eax, SIC_OPT_USER_FLAGS         ; return only user-available compiler options
        mov     [ebx + T_sic_data.coops], eax   ; return actual compiler options
        mov     eax, [.ecode]
        mov     [ebx + T_sic_data.ecode], eax   ; return error code
        xor     eax, eax
        mov     [ebx + T_sic_data.code], eax    ; clear code segment fields
        mov     [ebx + T_sic_data.entry], eax
        mov     [ebx + T_sic_data.size], eax
        mov     [ebx + T_sic_data.cspace], eax
        mov     [ebx + T_sic_data.data], eax    ; clear data segment fields
        mov     [ebx + T_sic_data.dsize], eax
        mov     [ebx + T_sic_data.dspace], eax
        pop     edx
   .error.cursor:
        cmp     [.ecode], SIC_ERROR_STRING
        je     .error.leave
        call   .cursor                          ; update cursor position
        stdcall hfree, [.s.buffer]              ; free string buffer
        stdcall hfree, [.sop.buffer]            ; free options buffer
   .error.leave:
        xor     eax, eax
       .proc.leave
        ret

   .error.null.sic:
        xor     eax, eax
       .proc.leave
        ret

   .cursor:                                     ; update cursor position
        push    edx ecx
        mov     ecx, [.e]
        sub     ecx, [.s.buffer]
        mov     edx, [esi + T_sic_data.ccurs]
        add     edx, ecx
        mov     [ebx + T_sic_data.ccurs], edx
        mov     edx, [esi + T_sic_data.pcurs]
        add     edx, ecx
        mov     [ebx + T_sic_data.pcurs], edx
        pop     ecx edx
        retn

   .optima:
        push    eax edx ecx
        mov     edx, edi                        ; edi = current memory pointer
        sub     edx, [.edi]                     ; edx = code size
        jz     .optima.return
   .optima.test:
        mov     ecx, [sop]
        test    ecx, SIC_OPT_FLAG_OPTIMIZATION
        jz     .optima.return                   ; no optimization due to compiler options
   .optima.main:
        cmp     [.code.exit], 0
        jz     .optima.main.L2
   .optima.main.L3:
        stdcall code.clean.L3, [.edi], edx, [ebx + T_sic_data.rcode]
        jmp    .optima.clean.out
   .optima.main.L2:
        stdcall code.clean.L2, [.edi], edx, [ebx + T_sic_data.rcode]
   .optima.clean.out:
        mov     edi, [.edi]
        add     edi, eax
   .optima.return:
        mov     [.edi], edi
        pop     ecx edx eax
        retn

   .align:
        push    eax edx ecx
        test    [sop], SIC_OPT_FLAG_NO_CALIGN
        jnz    .align.return                    ; no code alignment
        ;
        mov     ecx, [.agn]
        cmp     ecx, 0
        jle    .align.return                    ; no code alignment
        cmp     ecx, 64
        jg     .align.return                    ; no code alignment
        ;
        cmp     [.cspace], ecx
        jl     .align.return                    ; no space for nopping
   .align.main:
        mov     eax, edi
        cdq
        div     ecx                             ; eax = edi div n
        test    edx, edx                        ; edx = edi mod n
        jz     .align.return
   .align.nopping:
        sub     ecx, edx
        mov     eax, ecx
   .align.padding:
        dec     eax
        js     .align.shift
        mov     byte [edi + eax], 0x90          ; nop padding
        jmp    .align.padding
   .align.shift:
        add     edi, ecx
        add     [.nops], ecx
   .align.return:
        mov     [.edi], edi
        pop     ecx edx eax
        retn

        ; -> edx - string
   .test.options:
        mov     [.option], 0
        mov     cl, byte [edx]
   .test.options.test:
        cmp     cl, '$'
        je     .test.options.L2
        cmp     cl, '#'
        jne    .test.options.return
   .test.options.L2:
        mov     ch, byte [edx + 1]
        case    ch,\
                '+', .test.options.accept ,\
                '-', .test.options.accept ,\
                '>', .test.options.accept ,\
                '=', .test.options.accept ,\
                '{', .test.options.accept ,\
                '}', .test.options.accept
        jmp    .test.options.return
   .test.options.accept:
        mov     [.option], ch
   .test.options.return:
        retn

        ; -> edx - string
   .update.options:
        mov     [.esi], esi
        push    ebx esi edi
        mov     ebx, edx
        mov     [.option], 0
        mov     [.opparam], 0
        mov     [.int32param], 0
        ;
        mov     cl, byte [ebx]
   .update.options.test:
        cmp     cl, '$'
        je     .update.options.test.L2
        cmp     cl, '#'
        jne    .update.options.return
   .update.options.test.L2:
        mov     ch, byte [ebx + 1]
        case    ch,\
                '+', .update.option.on      ,\
                '-', .update.option.off     ,\
                '>', .update.option.execute ,\
                '=', .update.option.default ,\
                '{', .update.option.save    ,\
                '}', .update.option.restore
        jmp    .update.options.return
   .update.option.save:
        mov     ecx, [.sop.buffer.item]
        cmp     ecx, .sop.buffer.icount
        jge    .update.options.error.range
        shl     ecx, 2                          ; ecx = [.sop.buffer.item] * 4
        add     ecx, [.sop.buffer]              ; ecx = options buffer address
        mov     edi, [sop]
        mov     [ecx], edi                      ; save options
        inc     [.sop.buffer.item]
        jmp    .update.option.assign
   .update.option.restore:
        dec     [.sop.buffer.item]
        js     .update.options.error.range
        mov     ecx, [.sop.buffer.item]
        shl     ecx, 2                          ; ecx = [.sop.buffer.item] * 4
        add     ecx, [.sop.buffer]              ; ecx = options buffer address
        mov     edi, [ecx]                      ; restore options
        jmp    .update.option.assign
   .update.option.default:
        mov     edi, SIC_OPT_DEFAULT_X32
;       jmp    .update.option.assign
   .update.option.assign:
        mov     [.e], edx
        mov     [esi + T_sic_data.ccurs], 2
        mov     [esi + T_sic_data.pcurs], 0
        mov     esi, edi                        ; assign options
        lea     edi, [ebx + 2]
        jmp    .update.options.leave
        ;
   .update.option.execute:
        mov     [.option], ch
        jmp    .option.x
   .update.option.off:
        mov     [.option], ch
        jmp    .option.x
   .update.option.on:
        mov     [.option], ch
        ;
   .option.x:
        mov     [.e], edx
        mov     [esi + T_sic_data.ccurs], 2
        mov     [esi + T_sic_data.pcurs], 0
        xor     esi, esi
        lea     edi, [ebx + 1]
   .option.x.scan:
        inc     edi
        mov     cl, byte [edi]
        case    cl,\                            ; skip blanks
                0x20, .option.x.scan,\          ; space
                0x0D, .option.x.scan,\          ; carriage return (FE:CR)
                0x0A, .option.x.scan,\          ; line feed (FE:LF)
                0x09, .option.x.scan,\          ; tabulation (FE:TAB)
                0xA0, .option.x.scan,\          ; no-break space
                0x08, .option.x.scan            ; backspace (FE:BS)
;                '¶', .update.options.error,\   ; paragraph
;                '§', .update.options.error,\   ; section sign
;                 0 , .update.options.error
        test    esi, esi
        jnz    .option.x.change.main
   .option.test OPTIMIZATION ,\
                STACK_FRAME  ,\
                STACK.FRAME  ,\
                LOCALS       ,\
                FP_FRAME     ,\
                FP.FRAME     ,\
                DEBUG        ,\
                CPUX64       ,\
                CPUX32       ,\
                CPUX         ,\
                DALIGN       ,\
                NO_CALIGN    ,\
                NO.CALIGN    ,\
                NO_ECALC     ,\
                NO.ECALC     ,\
                COMPLEX      ,\
                COMPACT
        jmp    .update.options.error
   .option.x.change:
        inc     [.seg.count]                    ; valid segment
        test    esi, esi
        jz     .update.options.return
   .option.x.change.main:
        mov     cl, byte [edi]
        case    cl,\                            ; test blanks
                0x20, .option.x.change.main.0,\ ; space
                0x0D, .option.x.change.main.2,\ ; carriage return (FE:CR)
                0x0A, .option.x.change.main.2,\ ; line feed (FE:LF)
                0x09, .option.x.change.main.0,\ ; tabulation (FE:TAB)
                0xA0, .option.x.change.main.0,\ ; no-break space
                0x08, .option.x.change.main.0,\ ; backspace (FE:BS)
                 '¶', .option.x.change.main.2,\ ; paragraph
                 '§', .option.x.change.main.2,\ ; section sign
                  0 , .option.x.change.main.2
        jmp    .update.options.error
   .option.x.change.main.0:
        mov     edx, edi
   .option.x.change.main.@:
        inc     edx
        mov     cl, byte [edx]
        case    cl,\                            ; test blanks
                0x20, .option.x.change.main.@,\ ; space
                0x0D, .option.x.change.main.2,\ ; carriage return (FE:CR)
                0x0A, .option.x.change.main.2,\ ; line feed (FE:LF)
                0x09, .option.x.change.main.@,\ ; tabulation (FE:TAB)
                0xA0, .option.x.change.main.@,\ ; no-break space
                0x08, .option.x.change.main.@,\ ; backspace (FE:BS)
                 '¶', .option.x.change.main.2,\ ; paragraph
                 '§', .option.x.change.main.2,\ ; section sign
                  0 , .option.x.change.main.2
        mov     [.opparam], edx                 ; save option parameter offset
        lea     edx, [.ppchar]
        cinvoke strtol, [.opparam], edx, 10     ; eax = int32 parameter
        mov     [.int32param], eax
        mov     edi, [.ppchar]
        cmp     edi, [.opparam]
        jne    .option.x.change.main.@8
   .option.x.change.main.@@:
        mov     [.opparam], 0
        mov     dx, word [edi]
        case    dx,\
                '//', .option.x.change.main.2,\
                '/*', .option.x.change.main.2
        jmp    .update.options.error
   .option.x.change.main.@8:
        mov     cl, byte [edi]
        case    cl,\                            ; test blanks
                0x20, .option.x.change.main.2,\ ; space
                0x0D, .option.x.change.main.2,\ ; carriage return (FE:CR)
                0x0A, .option.x.change.main.2,\ ; line feed (FE:LF)
                0x09, .option.x.change.main.2,\ ; tabulation (FE:TAB)
                0xA0, .option.x.change.main.2,\ ; no-break space
                0x08, .option.x.change.main.2,\ ; backspace (FE:BS)
                 '¶', .option.x.change.main.2,\ ; paragraph
                 '§', .option.x.change.main.2,\ ; section sign
                  0 , .option.x.change.main.2
        jmp    .update.options.error
   .option.x.change.main.2:
        cmp     [.option], '+'
        je     .option.x.on
        cmp     [.option], '-'
        je     .option.x.off
        cmp     [.option], '>'
        je     .option.x.execute
   .option.x.assign:
        mov     [sop], esi
        or      esi, SIC_OPT_FLAG_EXTERNAL_CALL ; set external call flag
        mov     [.sop], esi
        jmp    .update.options.leave
   .option.x.execute:
        case    esi,\
                SIC_OPT_FLAG_DALIGN , .option.x.execute.dalign
        jmp    .update.options.error
   .option.x.execute.dalign:
        mov     edx, [.int32param]
        cmp     [.opparam], 0
        jnz    .option.x.execute.dalign.perform
   .option.x.execute.dalign.default:
    $ifdef _X64
        mov     edx, 16
    $else
      $ifdef _SSEX
        mov     edx, 16
      $else
        mov     edx, 8
      $end
    $end
   .option.x.execute.dalign.perform:
        stdcall vmalign, [.esi], edx
        jmp    .update.options.leave
   .option.x.off:
        mov     edx, [.opparam]
        case    esi,\
                SIC_OPT_FLAG_CPUX64 , .option.x.off.CPUX64,\
                SIC_OPT_FLAG_CPUX32 , .option.x.off.CPUX32,\
                SIC_OPT_FLAG_CPUX   , .option.x.off.CPUX
        test    edx, edx
        jnz    .update.options.error
        not     esi
        and     [sop], esi
        and     [.sop], esi
        jmp    .update.options.leave
   .option.x.off.CPUX64:
        test    edx, edx
        jnz    .update.options.error
        mov     [.accept.code], 1
        jmp    .update.options.leave
   .option.x.off.CPUX32:
        test    edx, edx
        jnz    .update.options.error
        mov     [.accept.code], 0
        jmp    .update.options.leave
   .option.x.off.CPUX:
        test    edx, edx
        jnz    .update.options.error
        mov     [.accept.code], 0
        jmp    .update.options.leave
   .option.x.on:
        mov     edx, [.opparam]
        case    esi,\
                SIC_OPT_FLAG_CPUX64 , .option.x.on.CPUX64,\
                SIC_OPT_FLAG_CPUX32 , .option.x.on.CPUX32,\
                SIC_OPT_FLAG_CPUX   , .option.x.on.CPUX
        or      [sop], esi
        or      [.sop], esi
        case    esi,\
                SIC_OPT_FLAG_DALIGN , .option.x.on.dalign
        test    edx, edx
        jnz    .update.options.error
        jmp    .update.options.leave
   .option.x.on.dalign:
        mov     edx, [.int32param]
        cmp     [.opparam], 0
        jnz    .option.x.on.dalign.assign
   .option.x.on.dalign.default:
    $ifdef _X64
        mov     edx, 16
    $else
      $ifdef _SSEX
        mov     edx, 16
      $else
        mov     edx, 8
      $end
    $end
   .option.x.on.dalign.assign:
        mov     esi, [.esi]
        mov     [esi + T_sic_data.dalign], edx
        jmp    .update.options.leave
   .option.x.on.CPUX64:
        test    edx, edx
        jnz    .update.options.error
        mov     [.accept.code], 0
        jmp    .update.options.leave
   .option.x.on.CPUX32:
        test    edx, edx
        jnz    .update.options.error
        mov     [.accept.code], 1
        jmp    .update.options.leave
   .option.x.on.CPUX:
        test    edx, edx
        jnz    .update.options.error
        mov     [.accept.code], 1
;       jmp    .update.options.leave
        ;
   .update.options.leave:
        mov     edx, edi
        sub     edx, ebx
        stdcall fillchar, ebx, edx, 0xA0A0A0A0  ; replace compiler directive with no-break spaces
        lea     ebx, [edi - 1]
        mov     byte [ebx], '¶'                 ; paragraph (end of segment)
        ;
        mov     [.no.compile], 1
   .update.options.return:
        mov     edx, ebx
        pop     edi esi ebx
        retn
   .update.options.error:
        mov     [.ecode], SIC_ERROR_TOKEN
        mov     edx, ebx
        pop     edi esi ebx
        retn
   .update.options.error.range:
        mov     [.ecode], SIC_ERROR_RANGE
        mov     edx, ebx
        pop     edi esi ebx
        retn

   .cb.enter:
        push    eax
        cmp     [.code.enter], 0
        jnz    .cb.enter.leave
        mov     [.code.enter], 1
        ;
   .cb.enter.frame.test:
        mov     ecx, [sop]
        test    ecx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.frame.out
   .cb.enter.frame.in:
        mov     [.stack.frame.on], 1
        ; ---------------------------------------
        @@_ENTER_32                             ; stack frame
        ; ---------------------------------------
   .cb.enter.frame.out:
        ;
    $ifdef _X64
   .cb.enter.align.test:
        mov     ecx, [sop]
        test    ecx, SIC_OPT_FLAG_STACK_FRAME
        jnz    .cb.enter.align.out
   .cb.enter.align.in:
        mov     [.stack.align.on], 1
        ; ---------------------------------------
        @@_PUSH_RAX                             ; 16-byte stack align
;       @@_ADD_RSP_m8                           ; 16-byte stack align
        ; ---------------------------------------
   .cb.enter.align.out:
    $end
        ;
   .cb.enter.locals.test:
        mov     ecx, [sop]
        test    ecx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.locals.out
        test    ecx, SIC_OPT_FLAG_LOCALS
        jz     .cb.enter.locals.out
   .cb.enter.locals.in:
        mov     [.locals.on], 1
        ; ---------------------------------------
        @@_LOCALS_ALLOC_32                      ; allocate local variables
        @@_LOCALS_CLEAR_32                      ; clear local variables
        ; ---------------------------------------
   .cb.enter.locals.out:
        ;
   .cb.enter.eflags.test:
        mov     ecx, [sop]
        test    ecx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.eflags.out
        test    ecx, SIC_OPT_FLAG_LOCALS
        jz     .cb.enter.eflags.out
        test    ecx, SIC_OPT_FLAG_FP_FRAME
        jz     .cb.enter.eflags.out
   .cb.enter.eflags.in:
        mov     [.fp.frame.on], 1
        ; ---------------------------------------
      $ifdef _SSEX
        @@_SSE_FRAME_ENTER_32                   ; SSE frame
      $else
        @@_FPU_FRAME_ENTER_32                   ; FPU frame
      $end
        ; ---------------------------------------
   .cb.enter.eflags.out:
        ;
        mov     [.code.xsize], edi
   .cb.enter.leave:
        pop     eax
        retn
$endp

; ------------------------------------------------------------------------------
