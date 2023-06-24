
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
        cinvoke _strnicmp, rdi, SC_SIC_OPT_FLAG_#value, SC_SIC_OPT_FLAG_#value#.size
        test    eax, eax
        jnz     @F
        mov     rsi, SIC_OPT_FLAG_#value
        add     rdi, SC_SIC_OPT_FLAG_#value#.size
        jmp    .option.x.change
        @@:
    }

   .sop.buffer.icount   EQU 256                 ; compiler options buffer items count
   .sop.buffer.size     EQU .sop.buffer.icount * 8

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

       .sic             T_sic64_data ?
       .ecode           dd ?                    ; error code
       .rdata           dq ?
       .code            dq ?
       .code.shift      dq ?                    ; code shift
       .code.xsize      dq ?
       .e               dq ?                    ; expression
       .s               dq ?
       .s.buffer        dq ?
       .size            dq ?
       .o               dq ?
       .z               dq ?
       .sop             dq ?                    ; compiler options
       .sop.active      dq ?                    ; compiler options
       .sop.buffer      dq ?                    ; compiler options buffer
       .sop.buffer.item dq ?                    ; compiler options buffer current item index
       .coops           dq ?                    ; actual compiler options
       .seg.count       dd ?
       .cspace          dq ?                    ; free bytes available for code
       .code.size       dq ?                    ; maximum code size
       .csize           dq ?                    ; code size
       .rsi             dq ?
       .rdi             dq ?
       .ppchar          dq ?
       .opparam         dq ?                    ; option parameter offset
       .int32param      dd ?
       .agn             dq ?                    ; align bytes
       .ano             db ?                    ; anonymous label flag
       .char            db ?
       .cbra            dq ?                    ; parenthesis counter ()
       .csbra           dq ?                    ; square bracket counter []
       .ccbra           dq ?                    ; curly bracket counter {}
       .mups            dq ?                    ; markup symbols counter
       .nops            dq ?
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

        mov     [sic], rcx
        mov     [s], rdx
        mov     [sop], r8
;       mov     [], r9

       .proc.enter

        mov     rbx, [sic]                      ; rbx = sic data structure offset
        test    rbx, rbx
        jz     .error.null.sic

        lea     rsi, [.sic]                     ; rsi = temp sic structure offset
        stdcall zerosic, rsi

        xor     rax, rax
        mov     [.s.buffer], rax                ; clear string buffer
        mov     [.ecode], eax                   ; clear error code
        mov     [.cbra], rax                    ; clear parenthesis counter
        mov     [.csbra], rax                   ; clear square bracket counter
        mov     [.ccbra], rax                   ; clear curly bracket counter
        mov     [.nops], rax
        mov     [.seg.count], eax
        mov     [.code.shift], rax              ; clear code shift
        mov     [.code.xsize], rax
        mov     [.csize], rax                   ; clear code size
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

        mov     rax, [@_CFG.code_size]          ; rax = free bytes available for code
        mov     [.cspace], rax                  ; assign available bytes
        mov     [.code.size], rax               ; assign maximum code size

        stdcall cfree, [rbx + T_sic_data.code]  ; free previously allocated memory
        stdcall hfree, [rbx + T_sic_data.data]
        lea     rcx, [rbx + T_sic_data.code]    ; clear data
        stdcall fillchar, rcx, sizeof.T_sic_data - T_sic_data.code, 0

   .sop.buffer.in:                              ; options buffer
        mov     rcx, .sop.buffer.size
        stdcall halloc, rcx                     ; allocate memory for options buffer
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [.sop.buffer], rax
        mov     [.sop.buffer.item], 0           ; clear options buffer
        stdcall fillchar, rax, .sop.buffer.size, 0
   .sop.buffer.out:

        mov     rdx, [sop]
        mov     [.sop.active], rdx
        mov     rax, [.sop.buffer]              ; rax = options buffer address
        mov     [rax], rdx
        mov     [.coops], rdx
        or      rdx, SIC_OPT_FLAG_EXTERNAL_CALL ; set external call flag
        mov     [.sop], rdx

        mov     rdi, [s]                        ; rdi = input string offset
        test    rdi, rdi
        jz     .error.string                    ; error. null string

   .s.buffer.in:
;       invoke  lstrlen, rdi
        cinvoke strlen, rdi
        test    eax, eax                        ; eax = input string length
        jz     .error.string                    ; error. empty string
;       xor     rcx, rcx
        lea     ecx, [eax + 1]
        stdcall halloc, rcx                     ; allocate memory for string buffer
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [.s.buffer], rax
        ; LPTSTR lstrcpy ( LPTSTR, LPTSTR )
;       invoke  lstrcpy, rax, rdi               ; copy input string to string buffer
        cinvoke strcpy, rax, rdi                ; copy input string to string buffer
        test    rax, rax
        jz     .error                           ; error. string copy error
   .s.buffer.out:

   .data.in:
        mov     rcx, [@_CFG.memory]
        stdcall halloc, rcx                     ; allocate memory for data segment
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [rbx + T_sic_data.data], rax
        ;
macro c
{
;       xor     rdx, rdx
;       test    [sop], SIC_OPT_FLAG_SYSTEM_MEMORY
;       jz     .data.sys.mem.out
;  .data.sys.mem.in:
;       test    rax, 0xF
;       jz      @F                              ; data is already aligned to 16 bytes
;       sub     dl, al                          ; data 16-byte alignment
;       and     rdx, 0xF
;   @@:
;       add     rdx, sys_mem_dsize              ; reserve bytes for system use
;       mov     [rbx + T_sic_data.dsize], edx
;  .data.sys.mem.out:
;       mov     rcx, [@_CFG.memory]
;       sub     rcx, rdx
;       js     .error.memory
;       mov     [rbx + T_sic_data.dspace], ecx
}
        mov     rcx, [@_CFG.memory]
        mov     [rbx + T_sic_data.dspace], ecx
   .data.out:

        stdcall calloc, [.code.size]            ; allocate memory for code segment
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [rbx + T_sic_data.code], rax    ; rax = code segment offset
        mov     rdi, rax                        ; rdi = destination
        mov     [.rdi], rdi                     ; save initial position

        mov     rax, [rbx + T_sic_data.fdata]   ; copy function data segment offset
        mov     [rsi + T_sic_data.fdata], rax
        mov     rax, [rbx + T_sic_data.cdata]   ; copy constant data segment offset
        mov     [rsi + T_sic_data.cdata], rax
        mov     rax, [rbx + T_sic_data.vdata]   ; copy variable data segment offset
        mov     [rsi + T_sic_data.vdata], rax
        mov     rax, [rbx + T_sic_data.rdata]   ; copy runtime data segment offset
        mov     [rax + table.header.icount], 0  ; clear runtime data table
        mov     [rsi + T_sic_data.rdata], rax
        mov     [.rdata], rax
        ;
        mov     rax, [rbx + T_sic_data.data]    ; copy data segment offset
        mov     [rsi + T_sic_data.data], rax
        mov     eax, [rbx + T_sic_data.dspace]  ; copy data space
        mov     [rsi + T_sic_data.dspace], eax
        mov     eax, [rbx + T_sic_data.dsize]   ; copy data size
        mov     [rsi + T_sic_data.dsize], eax

        stdcall sysset, [.rdata]                ; set system table items
        stdcall conoze, [.rdata]                ; zero labels offsets
        stdcall tupdate                         ; update tables related data

        mov     [.code.xsize], rdi
        mov     rdx, [.s.buffer]                ; rdx = input string offset
        dec     rdx

   .char.next:
        inc     rdx
        mov     [.mups], 0
   .char.test:
        mov     cl, byte [rdx]
        test    cl, cl
        jz     .char.test.leave                 ; zero termination
        cmp     cl, '/'
        jne    .char.test.char
        mov     ch, byte [rdx + 1]
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
        inc     rdx
        mov     cl, byte [rdx]
        test    cl, cl
        jz     .char.test.leave                 ; zero termination
        cmp     cl, '/'
        jne    .char.test.markup.char
        mov     ch, byte [rdx + 1]
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
        sub     rdx, [.mups]
   .char.test.leave:
        mov     [.mups], 0
        mov     [.e], rdx
        dec     rdx

   .scan:
        inc     rdx
        mov     cl, byte [rdx]
   .scan.test:
        cmp     cl, '$'
        je     .scan.test.options
        cmp     cl, '#'
        jne    .scan.test.char
   .scan.test.options:
        call   .test.options
        cmp     [.option], 0
        jz     .scan.test.char
        mov     rcx, rdx
        sub     rcx, [.e]                       ; rcx = length of string to compile
        jz     .scan.update.options
        mov     cl, byte [rdx - 1]
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
        dec     rdx
        mov     cl, '¶'
        mov     byte [rdx], cl
        jmp    .segment.test
   .scan.update.options:
        call   .update.options
        cmp     [.ecode], 0
        jnz    .error.main
        mov     cl, byte [rdx]
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
        inc     rdx
        mov     cl, byte [rdx]
        case    cl,\
                0x0D, .scan.test.CRLF,\
                0x0A, .scan.test.CRLF
        dec     rdx
        mov     cl, byte [rdx]
        jmp    .segment.test

   .scan.next:
        jmp    .scan

   .comment.L0:                                 ; /
        mov     rax, rdx                        ; rax = comment entry
        inc     rdx
        mov     cl, byte [rdx]
        case    cl,\
                '/', .comment.L2,\
                '*', .comment.L4
        jmp    .scan.test
   .comment.L2:                                 ; //
        inc     rdx
        mov     cl, byte [rdx]
        case    cl,\                            ; search for line or segment end
                0x0D, .comment.L22,\            ; carriage return (FE:CR)
                0x0A, .comment.L22,\            ; line feed (FE:LF)
                   0, .comment                  ; string termination
        jmp    .comment.L2
   .comment.L22:
        inc     rdx
        mov     cl, byte [rdx]
        case    cl,\                            ; search for line or segment end
                0x0D, .comment.L22,\            ; carriage return (FE:CR)
                0x0A, .comment.L22              ; line feed (FE:LF)
;       dec     rdx
;       mov     cl, byte [rdx]
        jmp    .comment
   .comment.L4:                                 ; /*
        inc     rdx
        cmp     byte [rdx], 0
        jz     .comment
        cmp     word [rdx], '*/'
        jnz    .comment.L4
        add     rdx, 2
   .comment:
        mov     byte [rax], 0xA0                ; replace comment with no-break spaces
        inc     rax
        cmp     rax, rdx
        jne    .comment
        mov     cl, '¶'                         ; paragraph (end of segment)
        dec     rdx
        mov     [rdx], cl
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
        inc     rdx
        mov     cl, byte [rdx]
        case    cl,\
                ch, .string.leave,\             ; string end
                 0, .segment
        jmp    .string.scan
   .string.leave:
        mov     cl, byte [rdx - 1]
        cmp     cl, '\'
        je     .string.scan                     ; bypass \" \' \” \’ \» \›
        jmp    .scan

   .label.L0:
        mov     rax, rdx
   .label.L0.scan:
        inc     rax
        mov     cl, byte [rax]                  ; bypass blanks
        xcase  .label.L0.scan, cl, 0x20, 0x09, 0xA0, 0x08
;       xcase  .label.L0.scan, cl, 0x20, 0x0D, 0x0A, 0x09, 0xA0, 0x08
        cmp     cl, '='
        je     .label.L0.bypass                 ; bypass :=
;       cmp     cl, ':'
;       je     .label.L0.bypass                 ; bypass ::
        jmp    .label.L0.LL
   .label.L0.bypass:
        mov     rdx, rax
        jmp    .scan
   .label.L0.LL:
        mov     [.ano], 0
        mov     rax, rdx
   .label.L2:
        dec     rax
        cmp     rax, [.e]
        jge    .label.L2.LL
   .label.L2.C0:
        mov     [.call], 1
        mov     byte [rdx], 0xA0
        jmp    .scan
   .label.L2.LL:
        mov     cl, byte [rax]                  ; bypass blanks
;       xcase  .label.L2, cl, 0x20, 0x09, 0xA0, 0x08
        xcase  .label.L2, cl, 0x20, 0x0D, 0x0A, 0x09, 0xA0, 0x08
        inc     rax
        mov     rcx, [.e]                       ; rcx = [.e]
        sub     rax, rcx                        ; rax = label length
        test    rax, rax
        jz     .scan
        cmp     rax, 2
        jne    .label.L2.name
   .label.L2.2B:
        cmp     word [rcx], '@@'                ; rcx = [.e]
        jne    .label.L2.name
   .label.L2.2B.anonymous:                      ; anonymous label
        mov     [.ano], 1
        jmp    .label.align
   .label.L2.name:
        cmp     rax, citem.nsize
        jge    .scan
        cmp     word [rcx], '??'                ; rcx = [.e]
        je     .label.L2.get
        mov     cl, byte [rcx]                  ; rcx = [.e]
        mov     ch, cl
       .chisa   cl, ch, .label.L2.get
        jmp    .scan                            ; bypass non alpha first symbol
   .label.L2.get:
        mov     [.z], rax                       ; [.z] = label length
        push    rdx                             ; save rdx
        stdcall rtaget, [.rdata], [.e], rax     ; ? runtime object (runtime data segment of sic structure)
        mov     rax, rdx                        ; rax = table item offset
        pop     rdx                             ; restore rdx
        test    rax, rax
        jnz    .label.L2.x

        push    rdx                             ; save rdx
        stdcall nrtaget, [sic], [.e], [.z]      ; ? defined non runtime object
        pop     rdx                             ; restore rdx
        test    rax, rax
        jnz    .scan

        mov     rcx, [.e]
        add     rcx, [.z]
   .label.L2.scan:                              ; scan backward label name until chars are "alphabetic" or numeric
        dec     rcx
        cmp     rcx, [.e]
        jl     .label.L2.scan.off
        mov     ah, byte [rcx]
        mov     al, ah
       .chisan  al, ah, .label.L2.scan
   .label.L2.scan.off:
        inc     rcx
        cmp     rcx, [.e]
        jne    .scan
   .label.L2.add:
        push    rdx
        lea     rcx, [.cname]
        stdcall copymem, rcx, [.e], [.z]
        lea     rcx, [.cname]
        add     rcx, [.z]
        mov     byte [rcx], 0
        lea     rdx, [.cname]
        xor     rax, rax
        mov     al, 'o'
        stdcall rtaset, [.rdata], rdx, 0, 0, rax
        pop     rdx
        test    rax, rax
        jz     .scan
        inc     [rbx + T_sic_data.rcount]       ; increase runtimes count

   .label.L2.x:
        cmp     byte [rax + citem64.datype], '?'
        jne    .label.L2.o
        mov     byte [rax + citem64.datype], 'o'; change data type of table item
        jmp    .label.L2.o.0
   .label.L2.o:
        cmp     byte [rax + citem64.datype], 'o'
        jne    .scan
   .label.L2.o.0:
        cmp     [rax + citem64.offset], 0
        jne    .scan

   .label.align:
        call   .optima
        push    rax
        lea     rcx, [rdx + 1]
   .label.align.scan:
        inc     rdx
        mov     al, byte [rdx]
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
        mov     byte [rdx], '¶'
   .label.align.main:
        cmp     byte [rdx], ':'
        jne    .label.align.get                 ; LABEL:: - default alignment at LABEL
        mov     byte [rdx], '¶'
        jmp    .label.align.default
   .label.align.get:
        mov     [.o], rcx
        lea     rdx, [.s]
        cinvoke strtol, rcx, rdx, 10
        mov     rdx, [.s]
        cmp     rdx, [.o]
        jne    .label.align.assign
   .label.align.no:
        xor     rax, rax
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
        mov     [.agn], rax
        pop     rax
        dec     rdx
        call   .align
        cmp     [.ano], 0
        jnz    .char.next
   .label.assign:
        mov     [rax + citem64.offset], rdi     ; assign label offset
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
        mov     [.s], rdx
        sub     rdx, [.e]                       ; rdx = length of string to compile
        jz     .compile.next
        cmp     [.no.compile], 0
        jnz    .compile.next
        cmp     [.accept.code], 0
        jz     .compile.next
        mov     [.size], rdx
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
        mov     rcx, [.s]
        mov     byte [rcx], '¶'
   .compile:
        cmp     [.call], 0
        jz     .compile.no.call
   .compile.call:
        or      [.sop], SIC_OPT_FLAG_EXECUTE
        jmp    .compile.perform
   .compile.no.call:
        and     [.sop], not SIC_OPT_FLAG_EXECUTE
   .compile.perform:
        mov     [rsi + T_sic_data.rcode], edx
        stdcall sic_compile, rsi, [.e], [.sop]
        mov     edx, [rsi + T_sic_data.dsize]   ; update data size
        mov     [rbx + T_sic_data.dsize], edx
        mov     edx, [rsi + T_sic_data.dspace]  ; update data space
        mov     [rbx + T_sic_data.dspace], edx
        mov     rdx, [sop]
        mov     [.sop.active], rdx              ; save active compiler options

   .compile.break?:
        test    [rsi + T_sic_data.coops], SIC_OPT_FLAG_BYPASS
        jnz    .compile.next
        test    rax, rax
        jnz    .compile.success
   .compile.error:
        call   .cursor                          ; update cursor position
        jmp    .compile.break?.out
   .compile.success:
;       xor     rdx, rdx
        mov     edx, [rsi + T_sic_data.ccurs]
   .compile.break:
        sub     rdx, [.size]
        jns    .compile.break?.out
;       dec     rdx
        add     [.s], rdx
        mov     rdx, [.s]
        mov     dl, byte [rdx]
        mov     [.char], dl
   .compile.break?.out:

;       xor     rdx, rdx
        mov     edx, [rsi + T_sic_data.coops]
        or      [.coops], rdx                   ; set actual compiler options

        mov     edx, [rsi + T_sic_data.tokens]
        test    edx, edx
        jz     .compile.next                    ; no tokens. empty segment

        add     [rbx + T_sic_data.tokens], edx

        mov     edx, [rsi + T_sic_data.rpn]
        add     [rbx + T_sic_data.rpn], edx
        mov     edx, [rsi + T_sic_data.fcount]
        add     [rbx + T_sic_data.fcount], edx
        mov     edx, [rsi + T_sic_data.ccount]
        add     [rbx + T_sic_data.ccount], edx
        mov     edx, [rsi + T_sic_data.vcount]
        add     [rbx + T_sic_data.vcount], edx
        mov     edx, [rsi + T_sic_data.rcount]
        add     [rbx + T_sic_data.rcount], edx

        mov     edx, [rsi + T_sic_data.ecode]   ; get error code
        mov     [.ecode], edx
        test    edx, edx
        jnz    .error

        cmp     [.call], 0
        jnz    .compile.execute

   .compile.rcode:
        mov     ecx, [rsi + T_sic_data.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .compile.?execute
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .compile.?execute
        jmp    .compile.curs
   .compile.?execute:
        cmp     [rsi + T_sic_data.fcount], 0
        jz     .compile.next

   .compile.execute:                            ; execute code
   .compile.execute.enter?:
        cmp     [.code.enter], 0
        jnz    .compile.execute.main
        call   .cb.enter
   .compile.execute.main:
        mov     [.call], 0
;       xor     rcx, rcx
        mov     ecx, [rsi + T_sic_data.size]
        test    rcx, rcx
        jz     .compile.next
        mov     rdx, [rsi + T_sic_data.code]
        test    rdx, rdx
        jz     .compile.next
        mov     rdx, [rsi + T_sic_data.entry]
        test    rdx, rdx
        jz     .compile.next
        mov     byte [rdx + rcx], 0xC3
        ;
        push    rdi rbx                         ; save registers when calling the built-in functions
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
        call    rdx
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
        pop     rbx rdi
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
        test    [rsi + T_sic_data.rcode], RCODE_FLAG_JUMP
        jz     .compile.rcode.jump.out
;       cmp     [rsi + T_sic_data.fcount], 1
;       jne    .error
   .compile.rcode.jump.out:

   .compile.rcode.retn:
        test    [rsi + T_sic_data.rcode], RCODE_FLAG_RETN
        jz     .compile.rcode.retn.out
        cmp     [rsi + T_sic_data.fcount], 1
        jne    .error
   .compile.rcode.retn.out:

   .compile.rcode.exit:
        test    [rsi + T_sic_data.rcode], RCODE_FLAG_EXIT
        jz     .compile.rcode.exit.out
;       cmp     [rsi + T_sic_data.fcount], 1
;       jne    .error
        mov     [.rcode.exit], 1
   .compile.rcode.exit.out:

   .compile.code:
        test    rax, rax
        jnz    .compile.code.main
   .compile.code.z:
        ; if RCODE_FLAG_ZERO_SIZE is set, the zero-size code is not an error
        test    [rsi + T_sic_data.rcode], RCODE_FLAG_ZERO_SIZE
        jz     .error

   .compile.code.main:
        @@bound rax, .error.memory

        inc     [.seg.count]                    ; valid segment
        mov     [.nops], 0

   .compile.code.copy:
   .compile.code.enter?:
        cmp     [.code.enter], 0
        jnz    .compile.code.copy.main
        call   .cb.enter
   .compile.code.copy.main:
;       xor     rax, rax
        mov     eax, [rsi + T_sic_data.size]
        test    rax, rax
        jz     .compile.code.copy.out
        mov     rdx, [rsi + T_sic_data.code]
        stdcall copymem, rdi, rdx, rax
;       xor     rax, rax
        mov     eax, [rsi + T_sic_data.size]
        add     rdi, rax
        add     [.csize], rax                   ; increase code size
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
        mov     rdx, [.sop.active]              ; restore active compiler options
        mov     [sop], rdx
        or      rdx, SIC_OPT_FLAG_EXTERNAL_CALL ; set external call flag
        mov     [.sop], rdx
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
        mov     rdx, [.s]
        lea     rax, [rdx + 1]
        mov     [.e], rax
        jmp    .char.next
   .compile.out:

   .cb.segments:
        mov     edx, [.seg.count]
        test    edx, edx
        jnz    .cb.segments.out
        mov     eax, [rsi + T_sic_data.size]
        test    eax, eax
        jz     .error                           ; error. no valid segments
   .cb.segments.out:

   .cb.runtimes:
        stdcall conoun, [.rdata]
        test    rax, rax
        jnz    .error.rt.token                  ; error. undefined runtime items found
   .cb.runtimes.out:

        sub     rdi, [.nops]

;       cmp     [.code.enter], 0
;       jz     .cb.CODE.empty
        sub     [.code.xsize], rdi              ; [.code.xsize] - negative or zero
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
        @@_EXIT_CODE_MOVSD_64
        ; ---------------------------------------
        jmp    .cb.leave
    $else
        ; ---------------------------------------
        ;?DDD8             FSTP ST0
        ; ---------------------------------------
        mov     dx, [rdi - 2]
        cmp     dx, word 0xD8DD
        je     .cb.CODE.exit.FSTP
   .cb.CODE.exit.FLDZ:
        ; ---------------------------------------
        @@_EXIT_CODE_FLDZ_64
        ; ---------------------------------------
        jmp    .cb.leave
   .cb.CODE.exit.FSTP:
        @@xshl  rdi, 2                          ; remove last <FSTP ST0> instruction
        add     [.code.shift], 2
   .cb.CODE.exit.FLDQ:
        ; ---------------------------------------
        @@_EXIT_CODE_FLDQ_64
        ; ---------------------------------------
        jmp    .cb.leave
    $end
   .cb.CODE.exit.out:

   .cb.CODE:
    $ifdef _SSEX
        ; ---------------------------------------
        ;?DDC0             FFREE ST0
        ; ---------------------------------------
        mov     dx, [rdi - 2]
        cmp     dx, word 0xC0DD
        jne    .cb.CODE.out
   .cb.CODE.FFREE:
        ; ---------------------------------------
        ;*DDC0             FFREE ST0
        ; ---------------------------------------
        @@xshl  rdi, 2                          ; remove last <FFREE ST0> instruction
        add     [.code.shift], 2
;       jmp    .cb.CODE.out
    $else
        ; ---------------------------------------
        ;?DDD8             FSTP ST0
        ; ---------------------------------------
        mov     dx, [rdi - 2]
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
        @@xshl  rdi, 2                          ; remove last <FSTP ST0> instruction
        add     [.code.shift], 2
;       jmp    .cb.CODE.out
    $end
   .cb.CODE.out:

   .cb.leave:

   .cb.leave.??exit:
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        test    rdx, rdx                        ; rdx = ??exit label table item offset
        jz     .cb.leave.??exit.out
   .cb.leave.??exit.in:
        mov     rcx, [rdx + citem64.offset]
        sub     rcx, [.code.shift]
        mov     [rdx + citem64.offset], rcx
   .cb.leave.??exit.out:

        mov     rcx, [.code.shift]
        sub     [.rdi], rcx

   .cb.leave.eflags.test:
        cmp     [.fp.frame.on], 0
        jz     .cb.leave.eflags.out
   .cb.leave.eflags.in:
        ; ---------------------------------------
      $ifdef _SSEX
        @@_SSE_FRAME_LEAVE_64                   ; SSE frame
      $else
        @@_FPU_FRAME_LEAVE_64                   ; FPU frame
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
        @@_XOR_RAX_RAX                          ; return null FPU exception flags in RAX
        ; ---------------------------------------
   .cb.leave.eflags.off.out:

   .cb.leave.frame.test:
        cmp     [.stack.frame.on], 0
        jz     .cb.leave.frame.out
   .cb.leave.frame.in:
        ; ---------------------------------------
        @@_LEAVE_64                             ; restore stack
        ; ---------------------------------------
   .cb.leave.frame.out:

   .cb.leave.return.in:
        ; ---------------------------------------
        @@_RET                                  ; return
        ; ---------------------------------------
   .cb.leave.return.out:

        call   .optima

        mov     rdx, rdi
        sub     rdx, [rbx + T_sic_data.code]    ; rdx = code size
        cmp     rdx, 0
        jle    .error

        mov     [rbx + T_sic_data.size], edx

   .realloc.code.test:
   .realloc.code:
        mov     rcx, [rbx + T_sic_data.code]
        mov     [.code], rcx
        stdcall crealloc, rcx, rdx
        mov     [rbx + T_sic_data.code], rax
        mov     [rbx + T_sic_data.entry], rax
        sub     rax, [.code]                    ; rax = code delta
        stdcall conoup, [.rdata], rax           ; update labels offsets
   .realloc.code.out:
;       mov     rax, [rbx + T_sic_data.code]
;       mov     [rbx + T_sic_data.entry], rax

   .realloc.data.test:
   .realloc.data:
;       xor     rdx, rdx
        mov     edx, [rbx + T_sic_data.dsize]
        test    rdx, rdx
        jnz    .realloc.data.realloc
   .realloc.data.free:
        stdcall hfree, [rbx + T_sic_data.data]  ; free data segment
        xor     rax, rax
        mov     [rbx + T_sic_data.data], rax    ; clear data segment fields
        mov     [rbx + T_sic_data.dsize], eax
        mov     [rbx + T_sic_data.dspace], eax
        jmp    .realloc.data.out
   .realloc.data.realloc:
        mov     rcx, [rbx + T_sic_data.data]
        stdcall hrealloc, rcx, rdx              ; offset remains the same
;       test    rax, rax
;       jz     .realloc.data.out
;       mov     [rbx + T_sic_data.data], rax
;       stdcall datoup, [.rdata], ???           ; update data offsets
   .realloc.data.out:

        stdcall FlushCodeCache, rbx

   .return:
        stdcall cfree, [rsi + T_sic_data.code]  ; free previously allocated memory
        stdcall hfree, [.s.buffer]              ; free string buffer
        stdcall hfree, [.sop.buffer]            ; free options buffer
        mov     rax, [.coops]
        and     rax, SIC_OPT_USER_FLAGS         ; return only user-available compiler options
        mov     [rbx + T_sic_data.coops], eax   ; return actual compiler options
;       xor     rax, rax
        mov     eax, [rbx + T_sic_data.size]    ; return code size
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
        push    rdx
        stdcall cfree, [rsi + T_sic_data.code]  ; free previously allocated memory
        stdcall cfree, [rbx + T_sic_data.code]
        stdcall hfree, [rbx + T_sic_data.data]
        mov     rax, [.coops]
        and     rax, SIC_OPT_USER_FLAGS         ; return only user-available compiler options
        mov     [rbx + T_sic_data.coops], eax   ; return actual compiler options
        mov     eax, [.ecode]
        mov     [rbx + T_sic_data.ecode], eax   ; return error code
        xor     rax, rax
        mov     [rbx + T_sic_data.code], rax    ; clear code segment fields
        mov     [rbx + T_sic_data.entry], rax
        mov     [rbx + T_sic_data.size], eax
        mov     [rbx + T_sic_data.cspace], eax
        mov     [rbx + T_sic_data.data], rax    ; clear data segment fields
        mov     [rbx + T_sic_data.dsize], eax
        mov     [rbx + T_sic_data.dspace], eax
        pop     rdx
   .error.cursor:
        cmp     [.ecode], SIC_ERROR_STRING
        je     .error.leave
        call   .cursor                          ; update cursor position
        stdcall hfree, [.s.buffer]              ; free string buffer
        stdcall hfree, [.sop.buffer]            ; free options buffer
   .error.leave:
        xor     rax, rax
       .proc.leave
        ret

   .error.null.sic:
        xor     rax, rax
       .proc.leave
        ret

   .cursor:                                     ; update cursor position
        push    rdx rcx
        mov     rcx, [.e]
        sub     rcx, [.s.buffer]
        mov     edx, [rsi + T_sic_data.ccurs]
        add     rdx, rcx
        mov     [rbx + T_sic_data.ccurs], edx
        mov     edx, [rsi + T_sic_data.pcurs]
        add     rdx, rcx
        mov     [rbx + T_sic_data.pcurs], edx
        pop     rcx rdx
        retn

   .optima:
        push    rax rdx rcx
        mov     rdx, rdi                        ; rdi = current memory pointer
        sub     rdx, [.rdi]                     ; rdx = code size
        jz     .optima.return
   .optima.test:
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_OPTIMIZATION
        jz     .optima.return                   ; no optimization due to compiler options
   .optima.main:
        cmp     [.code.exit], 0
        jz     .optima.main.L2
   .optima.main.L3:
        stdcall code.clean.L3, [.rdi], rdx, [rbx + T_sic_data.rcode]
        jmp    .optima.clean.out
   .optima.main.L2:
        stdcall code.clean.L2, [.rdi], rdx, [rbx + T_sic_data.rcode]
   .optima.clean.out:
        mov     rdi, [.rdi]
        add     rdi, rax
   .optima.return:
        mov     [.rdi], rdi
        pop     rcx rdx rax
        retn

   .align:
        push    rax rdx rcx
        test    [sop], SIC_OPT_FLAG_NO_CALIGN
        jnz    .align.return                    ; no code alignment
        ;
        mov     rcx, [.agn]
        cmp     rcx, 0
        jle    .align.return                    ; no code alignment
        cmp     rcx, 64
        jg     .align.return                    ; no code alignment
        ;
        cmp     [.cspace], rcx
        jl     .align.return                    ; no space for nopping
   .align.main:
        mov     rax, rdi
        cqo
        div     rcx                             ; rax = rdi div n
        test    rdx, rdx                        ; rdx = rdi mod n
        jz     .align.return
   .align.nopping:
        sub     rcx, rdx
        mov     rax, rcx
   .align.padding:
        dec     rax
        js     .align.shift
        mov     byte [rdi + rax], 0x90          ; nop padding
        jmp    .align.padding
   .align.shift:
        add     rdi, rcx
        add     [.nops], rcx
   .align.return:
        mov     [.rdi], rdi
        pop     rcx rdx rax
        retn

        ; -> rdx - string
   .test.options:
        mov     [.option], 0
        mov     cl, byte [rdx]
   .test.options.test:
        cmp     cl, '$'
        je     .test.options.L2
        cmp     cl, '#'
        jne    .test.options.return
   .test.options.L2:
        mov     ch, byte [rdx + 1]
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

        ; -> rdx - string
   .update.options:
        mov     [.rsi], rsi
        push    rbx rsi rdi
        mov     rbx, rdx
        mov     [.option], 0
        mov     [.opparam], 0
        mov     [.int32param], 0
        ;
        mov     cl, byte [rbx]
   .update.options.test:
        cmp     cl, '$'
        je     .update.options.test.L2
        cmp     cl, '#'
        jne    .update.options.return
   .update.options.test.L2:
        mov     ch, byte [rbx + 1]
        case    ch,\
                '+', .update.option.on      ,\
                '-', .update.option.off     ,\
                '>', .update.option.execute ,\
                '=', .update.option.default ,\
                '{', .update.option.save    ,\
                '}', .update.option.restore
        jmp    .update.options.return
   .update.option.save:
        mov     rcx, [.sop.buffer.item]
        cmp     rcx, .sop.buffer.icount
        jge    .update.options.error.range
        shl     rcx, 3                          ; rcx = [.sop.buffer.item] * 8
        add     rcx, [.sop.buffer]              ; rcx = options buffer address
        mov     rdi, [sop]
        mov     [rcx], rdi                      ; save options
        inc     [.sop.buffer.item]
        jmp    .update.option.assign
   .update.option.restore:
        dec     [.sop.buffer.item]
        js     .update.options.error.range
        mov     rcx, [.sop.buffer.item]
        shl     rcx, 3                          ; rcx = [.sop.buffer.item] * 8
        add     rcx, [.sop.buffer]              ; rcx = options buffer address
        mov     rdi, [rcx]                      ; restore options
        jmp    .update.option.assign
   .update.option.default:
        mov     rdi, SIC_OPT_DEFAULT_X64
;       jmp    .update.option.assign
   .update.option.assign:
        mov     [.e], rdx
        mov     [rsi + T_sic_data.ccurs], 2
        mov     [rsi + T_sic_data.pcurs], 0
        mov     rsi, rdi                        ; assign options
        lea     rdi, [rbx + 2]
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
        mov     [.e], rdx
        mov     [rsi + T_sic_data.ccurs], 2
        mov     [rsi + T_sic_data.pcurs], 0
        xor     rsi, rsi
        lea     rdi, [rbx + 1]
   .option.x.scan:
        inc     rdi
        mov     cl, byte [rdi]
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
        test    rsi, rsi
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
        test    rsi, rsi
        jz     .update.options.return
   .option.x.change.main:
        mov     cl, byte [rdi]
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
        mov     rdx, rdi
   .option.x.change.main.@:
        inc     rdx
        mov     cl, byte [rdx]
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
        mov     [.opparam], rdx                 ; save option parameter offset
        lea     rdx, [.ppchar]
        cinvoke strtol, [.opparam], rdx, 10     ; eax = int32 parameter
        mov     [.int32param], eax
        mov     rdi, [.ppchar]
        cmp     rdi, [.opparam]
        jne    .option.x.change.main.@8
   .option.x.change.main.@@:
        mov     [.opparam], 0
        mov     dx, word [rdi]
        case    dx,\
                '//', .option.x.change.main.2,\
                '/*', .option.x.change.main.2
        jmp    .update.options.error
   .option.x.change.main.@8:
        mov     cl, byte [rdi]
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
        mov     [sop], rsi
        or      rsi, SIC_OPT_FLAG_EXTERNAL_CALL ; set external call flag
        mov     [.sop], rsi
        jmp    .update.options.leave
   .option.x.execute:
        case    rsi,\
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
        stdcall vmalign, [.rsi], rdx
        jmp    .update.options.leave
   .option.x.off:
        mov     rdx, [.opparam]
        case    rsi,\
                SIC_OPT_FLAG_CPUX64 , .option.x.off.CPUX64,\
                SIC_OPT_FLAG_CPUX32 , .option.x.off.CPUX32,\
                SIC_OPT_FLAG_CPUX   , .option.x.off.CPUX
        test    rdx, rdx
        jnz    .update.options.error
        not     rsi
        and     [sop], rsi
        and     [.sop], rsi
        jmp    .update.options.leave
   .option.x.off.CPUX64:
        test    rdx, rdx
        jnz    .update.options.error
        mov     [.accept.code], 0
        jmp    .update.options.leave
   .option.x.off.CPUX32:
        test    rdx, rdx
        jnz    .update.options.error
        mov     [.accept.code], 1
        jmp    .update.options.leave
   .option.x.off.CPUX:
        test    rdx, rdx
        jnz    .update.options.error
        mov     [.accept.code], 0
        jmp    .update.options.leave
   .option.x.on:
        mov     rdx, [.opparam]
        case    rsi,\
                SIC_OPT_FLAG_CPUX64 , .option.x.on.CPUX64,\
                SIC_OPT_FLAG_CPUX32 , .option.x.on.CPUX32,\
                SIC_OPT_FLAG_CPUX   , .option.x.on.CPUX
        or      [sop], rsi
        or      [.sop], rsi
        case    rsi,\
                SIC_OPT_FLAG_DALIGN , .option.x.on.dalign
        test    rdx, rdx
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
        mov     rsi, [.rsi]
        mov     [rsi + T_sic_data.dalign], edx
        jmp    .update.options.leave
   .option.x.on.CPUX64:
        test    rdx, rdx
        jnz    .update.options.error
        mov     [.accept.code], 1
        jmp    .update.options.leave
   .option.x.on.CPUX32:
        test    rdx, rdx
        jnz    .update.options.error
        mov     [.accept.code], 0
        jmp    .update.options.leave
   .option.x.on.CPUX:
        test    rdx, rdx
        jnz    .update.options.error
        mov     [.accept.code], 1
;       jmp    .update.options.leave
        ;
   .update.options.leave:
        mov     rdx, rdi
        sub     rdx, rbx
        stdcall fillchar, rbx, rdx, 0xA0A0A0A0  ; replace compiler directive with no-break spaces
        lea     rbx, [rdi - 1]
        mov     byte [rbx], '¶'                 ; paragraph (end of segment)
        ;
        mov     [.no.compile], 1
   .update.options.return:
        mov     rdx, rbx
        pop     rdi rsi rbx
        retn
   .update.options.error:
        mov     [.ecode], SIC_ERROR_TOKEN
        mov     rdx, rbx
        pop     rdi rsi rbx
        retn
   .update.options.error.range:
        mov     [.ecode], SIC_ERROR_RANGE
        mov     rdx, rbx
        pop     rdi rsi rbx
        retn

   .cb.enter:
        push    rax
        cmp     [.code.enter], 0
        jnz    .cb.enter.leave
        mov     [.code.enter], 1
        ;
   .cb.enter.frame.test:
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.frame.out
   .cb.enter.frame.in:
        mov     [.stack.frame.on], 1
        ; ---------------------------------------
        @@_ENTER_64                             ; stack frame
        ; ---------------------------------------
   .cb.enter.frame.out:
        ;
    $ifdef _X64
   .cb.enter.align.test:
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_STACK_FRAME
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
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.locals.out
        test    rcx, SIC_OPT_FLAG_LOCALS
        jz     .cb.enter.locals.out
   .cb.enter.locals.in:
        mov     [.locals.on], 1
        ; ---------------------------------------
        @@_LOCALS_ALLOC_64                      ; allocate local variables
        @@_LOCALS_CLEAR_64                      ; clear local variables
        ; ---------------------------------------
   .cb.enter.locals.out:
        ;
   .cb.enter.eflags.test:
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.eflags.out
        test    rcx, SIC_OPT_FLAG_LOCALS
        jz     .cb.enter.eflags.out
        test    rcx, SIC_OPT_FLAG_FP_FRAME
        jz     .cb.enter.eflags.out
   .cb.enter.eflags.in:
        mov     [.fp.frame.on], 1
        ; ---------------------------------------
      $ifdef _SSEX
        @@_SSE_FRAME_ENTER_64                   ; SSE frame
      $else
        @@_FPU_FRAME_ENTER_64                   ; FPU frame
      $end
        ; ---------------------------------------
   .cb.enter.eflags.out:
        ;
        mov     [.code.xsize], rdi
   .cb.enter.leave:
        pop     rax
        retn
$endp

; ------------------------------------------------------------------------------
