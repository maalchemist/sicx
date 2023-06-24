
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; compile functions

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

SIC_C:

; ------------------------------------------------------------------------------

; ALGORITHM
;
; [1] convert input string to rpn array
; [2] convert rpn array to executable code
;
;     operation priority
;       00  (
;       01  )
;       02  ,
;       03
;       04  assign operator = := *:= =: =:* :=:
;       04  assign operator [=] {=} <=>
;       04  assign operator [:=] {:=} <:=>
;       04  assign operator [=:] {=:} <=:>
;       04  assign operator [:=:] {:=:} <:=:>
;       04  += -= ~-=
;       04  *= /= ~/=
;       04  \= ~\= %= ~%=
;       04  ~=
;       04  ^= ~^=
;       04  |= ~|= |~= ~|~=
;       04  |-= ~|-= -|= -|~=
;       04  &= ~&= &~= ~&~=
;       04  |0|= |1|=
;       04  >>= <<= >>>= <<<= >><= <<>=
;       05  == <> != > >= !< < <= !>
;       05  ==~ <>~ !=~ >~ >=~ !<~ <~ <=~ !>~
;       06  || ^^ !&
;       07  && !| !^
;       08  + -
;       09  * /
;       10  \
;       11  %
;       12  ++ +-
;       12  -+ -- ~- ~-+ ~--
;       12  *+ *-
;       12  /+ /- ~/ ~/+ ~/-
;       12  \+ \- ~\ ~\+ ~\-
;       12  %+ %- ~% ~%+ ~%-
;       12  \% %\
;       13  [+] {+} <+>
;       13  [-] {-} <-> [~-] {~-} <~->
;       13  [*] {*} <*>
;       13  [/] {/} </> [~/] {~/} <~/>
;       13  [\] {\} <\> [~\] {~\} <~\>
;       13  [%] {%} <%> [~%] {~%} <~%>
;       13  |A| |+| |G| |*| |H| |/| |C| |\| |Q| |h| |c|
;       14  *% /% ~/% +% ~+% -% ~-%
;       15  ?< ?> ?<> ?><
;       15  <==> >==<
;       15  <==>~ >==<~
;       16
;       17  ^ ** ~^ ~** */ ~*/
;       17  bitwise ^ ~^
;       18  bitwise | ~| |~ ~|~
;       19  bitwise |- ~|- -| -|~
;       20  bitwise & ~& &~ ~&~
;       21  bitwise |0| |1|
;       22  >> << >>> <<< >>< <<>
;       23  >?< >?~< >?-< >?+<
;       24  -> ~> *-> *~> ->> ~>>
;       25  &-> &~> *&-> *&~>
;       27  postfix = :=
;       27  postfix ! !! ° °°
;       27  postfix ++ --
;       27  postfix ^ ^^
;       27  postfix ==. <>. !=. >. >=. !<. <. <=. !>.
;       27  postfix ==.~ <>.~ !=.~ >.~ >=.~ !<.~ <.~ <=.~ !>.~
;       28  prefix + - ++ --
;       28  prefix / ~ ?
;       28  prefix <<? >>?
;       28  prefix !. ~!.
;       28  prefix ! ° °°
;       32
;       33  :: (=) ==
;       33  function
;       33  argument filter
;       34  postfix function
;       34  data modifier
;       34  postfix `
;       42  prefix * **
;       42  prefix & &&

; ------------------------------------------------------------------------------

; DWORD sic_compile ( LPVOID sic, LPCSTR s, DWORD sop )
;
; allocate memory for sic code segment and compile string ( s )
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
$proc sic_compile, sic, s, sop

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

        mov     rdx, [sop]                      ; compiler options
        test    rdx, SIC_OPT_FLAG_EXECUTE
        jnz     @F
        test    rdx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz     @F

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
      @@:
    }

    macro .proc.leave
    {
        mov     rdx, [sop]                      ; compiler options
        test    rdx, SIC_OPT_FLAG_EXECUTE
        jnz     @F
        test    rdx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz     @F

      $ifdef _SSEX
        ldmxcsr [.mxcsr_o]                      ; restore mxcsr register
      $end
        fnclex
        fldcw   [.fpu_cw_o]                     ; restore FPU control word
      @@:

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

    ; get function index
    ; -> fuo : function table offset
    ; -> fun : function name
    ; -> nas : name size
    ; <- eax : function index
    ; <- rdx : function item offset
    macro .fuget fuo, fun, nas
    {
       $if nas eq ; assume fun is function offset label
        stdcall taget, fuo, fun#.fname, fun#.nsize
       $else
        stdcall taget, fuo, fun, nas
       $end
    }

    ; get constant index in constant table ( coo )
    ; -> coo : constant table offset
    ; -> con : constant name
    ; -> nas : name size
    ; <- eax : constant index
    ; <- edx : constant offset
    macro .coget coo, con, nas
    {
        stdcall taget, coo, con, nas
    }

    ; get variable index in variable table ( vao )
    ; -> vao : variable table offset
    ; -> van : variable name
    ; -> nas : name size
    ; <- eax : variable index
    ; <- edx : variable offset
    macro .vaget vao, van, nas
    {
        stdcall taget, vao, van, nas
    }

    ; get runtime object index in runtime table ( ruo )
    ; -> ruo : runtime table offset
    ; -> run : object name
    ; -> nas : name size
    ; <- eax : object index
    ; <- edx : object offset
    macro .ruget ruo, run, nas
    {
        stdcall rtaget, ruo, run, nas
    }

    ; add item to stack
    ; -> idata : item data
    ; -> pdata : operation priority or data type
    ; -> param : parameter
    ; -> cnext : scan next char
    ; -> stash : shrink stack
    ; <- eax   : operation priority or data type
    ; <- edx   : parameter
    macro .push idata, pdata, paramLO, paramHI, cnext, stash
    {
       $if paramHI eq 'x64'

       $if paramLO in <rdx, rcx, rax>
        mov     qword [.param], paramLO
       $else
       $if paramLO eq 0
        xor     rdx, rdx
       $else
        mov     rdx, qword paramLO
       $end
        mov     qword [.param], rdx
       $end

       $else

       $if paramLO in <edx, rdx>
        mov     dword [.param], edx
       $ef paramLO in <ecx, rcx>
        mov     dword [.param], ecx
       $ef paramLO in <eax, rax>
        mov     dword [.param], eax
       $else
       $if paramLO eq 0
        xor     edx, edx
       $else
        mov     edx, dword paramLO
       $end
        mov     dword [.param], edx
       $end

       $if paramHI in <edx, rdx>
        mov     dword [.param + 4], edx
       $ef paramHI in <ecx, rcx>
        mov     dword [.param + 4], ecx
       $ef paramHI in <eax, rax>
        mov     dword [.param + 4], eax
       $else
       $if paramHI eq 0
        xor     edx, edx
       $else
        mov     edx, dword paramHI
       $end
        mov     dword [.param + 4], edx
       $end

       $end

       $if pdata in <eax, rax>
       $ef pdata eq 0
        xor     rax, rax
       $else
        mov     rax, pdata
       $end

        mov     [.idata], idata

       $if stash eq 's'
        oops
;       call   .stack.set
       $ef stash eq 's1'
        oops
;       call   .stack.set
       $ef stash eq 's2'
        oops
;       call   .stack.set.L2
       $ef stash eq 's3'
        oops
;       call   .stack.set.L3
       $ef stash eq 's4'
        oops
;       call   .stack.set.L4
       $ef stash eq 's5'
        oops
;       call   .stack.set.L5
       $else
        call   .stack.add
       $end
        test    rcx, rcx

       $if cnext eq
        je     .error
       $ef cnext eq 0
        je     .error
       $ef cnext eq 1
        jnz    .char.next
        jmp    .error
       $else
        jnz     cnext
        jmp    .error
       $end
    }

    ; add null item to stack
    ; -> cnext : scan next char
    ; -> stash : shrink stack
    ; <- eax   : operation priority or data type
    ; <- edx   : parameter
    macro .pushn cnext, stash
    {
       $ifdef _X64
        xor     rax, rax
        xor     rdx, rdx
        mov     qword [.param], rdx
        mov     [.idata], edx
       $else
        xor     eax, eax
        xor     edx, edx
        mov     dword [.param], edx
        mov     dword [.param + 4], edx
        mov     [.idata], edx
       $end

       $if stash eq 's'
        oops
;       call   .stack.set
       $ef stash eq 's1'
        oops
;       call   .stack.set
       $ef stash eq 's2'
        oops
;       call   .stack.set.L2
       $ef stash eq 's3'
        oops
;       call   .stack.set.L3
       $ef stash eq 's4'
        oops
;       call   .stack.set.L4
       $ef stash eq 's5'
        oops
;       call   .stack.set.L5
       $else
        call   .stack.add
       $end
        test    rcx, rcx

       $if cnext eq
        je     .error
       $ef cnext eq 0
        je     .error
       $ef cnext eq 1
        jnz    .char.next
        jmp    .error
       $else
        jnz     cnext
        jmp    .error
       $end
    }

    ; add string constant to stack
    ; -> offset : string offset
    ; -> length : string length
    ; -> cnext  : scan next char
    ; <- eax    : operation priority or data type
    ; <- edx    : parameter
    macro .push.cs offset, length, cnext
    {
        mov     [.datas], length

       $if offset in <rdx, rcx, rax>
        mov     qword [.param], offset
       $else
       $if offset eq 0
        xor     rdx, rdx
       $else
        mov     rdx, qword offset
       $end
        mov     qword [.param], rdx
       $end

;       mov     dword [.param + 4], 0 ; edx

        mov     [.idata], 'c¶'
        mov     rax, 's'

        call   .stack.add
        test    rcx, rcx

       $if cnext eq
        je     .error
       $ef cnext eq 0
        je     .error
       $ef cnext eq 1
        jnz    .char.next
        jmp    .error
       $else
        jnz     cnext
        jmp    .error
       $end
    }

    ; add function to stack
    ; -> fname : function offset label
    ; -> idata : item data
    ; -> pdata : function priority
    ; -> cnext : scan next char
    ; -> stash : shrink stack
    ; <- edx   : function priority
    ; <- eax   : function parameter
    macro .pushf fname, idata, pdata, cnext, stash
    {
;      $if ~ defined fname
;       display 'function ',`fname,' not defined',13,10
;       oops
;      $end
      $ifdef _X64
        mov     rdx, fname#.fname               ; function name
        mov     [.fun], rdx
        mov     rdx, fname#.nsize               ; name size
        mov     [.nas], rdx
      $else
        mov     [.fun], fname#.fname            ; function name
        mov     [.nas], fname#.nsize            ; name size
      $endif
        call   .pushf.get
    $ifdef _X64
       .push    idata, pdata, rdx, 'x64', cnext, stash
    $else
       .push    idata, pdata, edx, 0, cnext, stash
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

    ; test character is data modifier first symbol:
    ; "alphabetic" ('.', '_', '@', 'A'..'Z', 'a'..'z'), numeric ('0'..'9') or
    ; special symbol ('+', '-', '*', '/', '\', '%')
    ; -> al = ah : character to test
    ; modifies al
    macro .chisdm al, ah, label
    {
        cmp     al, '+'
        je      label                           ; '+'
        cmp     al, '-'
        je      label                           ; '-'
        cmp     al, '*'
        je      label                           ; '*'
        cmp     al, '/'
        je      label                           ; '/'
        cmp     al, '\'
        je      label                           ; '\'
        cmp     al, '%'
        je      label                           ; '%'
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

    ; test character is numeric ('0'..'9')
    ; -> al : character to test
    macro .chisn al, label
    {
;       sub     al, '0' + 10
;       add     al, 10
;       jc      label
        cmp     al, '0'
        jb      @F
        cmp     al, ':'
        jb      label
    @@:
    }

    ; test character is numeric ('0'..'9')
    ; -> al : character to test
    macro .chisne al
    {
        cmp     al, '0'
        jb     .error
        cmp     al, '9'
        ja     .error
    }

    ; test character is (...) function symbol
    ; -> al : character to test
    macro .chissyp al, label
    {
        case    al,\
                '(', label,\
                ')', label,\
                '=', label
;               ':', label,\
;               '+', label,\
;               '-', label,\
;               '*', label,\
;               '/', label,\
;               '\', label,\
;               '%', label,\
;               '^', label,\
;               '~', label
    }

    ; test character is function symbol
    ; -> al : character to test
    macro .chissym al, label
    {
        case    al,\
                '+', label,\
                '-', label,\
                '*', label,\
                '/', label,\
                '\', label,\
                '%', label,\
                '=', label,\
                '(', label,\
                ')', label,\
                '[', label,\
                ']', label,\
                '{', label,\
                '}', label,\
                '<', label,\
                '>', label,\
                '!', label,\
                '&', label,\
                ':', label,\
                '.', label,\
                '?', label,\
                '^', label,\
                '|', label,\
                '~', label,\
                '°', label
    }

    macro .call.rpn.add
    {
        push    rax rdx rcx
        call   .rpn.add
        pop     rcx rdx rax
    }

    macro .arg.set reg, [arg]
    {
      common
        local @acount, @offset

        @acount = 0
        @offset = 0

        mov     reg, [.arg.cursor]

      forward
        mov     word [reg + @offset], arg

        @acount = @acount + 1
        @offset = @offset + 2

      common
       if @acount = 1
        inc     [.arg.count]
       else
        add     [.arg.count], @acount
       end if
        add     [.arg.cursor], @offset
    }

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

       .sic.codata      T_sic_codata ?          ; compiler data

       .ecode           dd ?                    ; error code
       .rcode           dd ?                    ; return code
       .fdata           dq ?                    ; function data segment offset
       .cdata           dq ?                    ; constant data segment offset
       .vdata           dq ?                    ; variable data segment offset
       .rdata           dq ?                    ; runtime data segment offset
       .titem           dq ?                    ; table item offset
       .stack.ic        dd ?                    ; stack array items count
       .stack.cu        dq ?                    ; stack cursor
       .stacko          dq ?                    ; stack offset
       .stacki          dq ?                    ; stack[first-1] item offset
       .rpn.ic          dd ?                    ; rpn array items count
       .rpn             dq ?                    ; rpn array offset
       .rpni            dq ?                    ; rpn[first-1] item offset

       .arg.data        dq ?                    ; argument data offset
       .arg.count       dq ?                    ; argument data items count
       .arg.cursor      dq ?                    ; argument data cursor

       .csc             dq ?                    ; current string cursor
       .psc             dq ?                    ; previous string cursor
       .cooff           dq ?                    ; code segment entry offset
       .coshi           dq ?                    ; code offset shift
       .fuoff           dq ?                    ; function entry offset
       .frecount        dq ?                    ; function return count
       .facount         dw ?                    ; function argument count
       .vargf           db ?                    ; varg function flag
       .external        db ?                    ; external function flag
       .stdcall         db ?                    ; stdcall function flag
       .dynamic         db ?                    ; dynamic function flag
       .void            db ?                    ; void function flag
       .infix           db ?                    ; infix function flag
       .prefix          db ?                    ; prefix function flag
;      .postfix         db ?                    ; postfix function flag
       .cotype          dd ?                    ; constant type
       .opcode          dd ?
       .rax             dq ?
       .rbx             dq ?
       .rcx             dq ?
       .rdx             dq ?
       .rdi             dq ?
       .rsi             dq ?
       .sito            dq ?                    ; stack item offset
       .vito            dq ?                    ; var function stack item offset
       .cspace          dq ?                    ; free bytes available for code
       .code.space      dq ?                    ; code space
       .code.xsize      dq ?
       .calign          dd ?                    ; code align value
       .dalign          dd ?                    ; data align value
       .XSP             dq ?                    ; stack pointer
       .RSP             dq ?                    ; stack pointer
       .RSP.AL          dq ?
       .SAF             dd ?                    ; stack align flag
;      .SPD             dd ?                    ; stack delta for x32
       .EPC             dd ?                    ; external procedure count
       .OBJ             dd ?                    ; object type
       .RET             dw ?                    ; return type
       .LSO             dw ?                    ; last stack object type
       .FPU             dd ?
       .ezx             dq ?
       .zzx             dq ?
       .sid             dq ?
       .shl             dq ?
       .shr             dq ?
       .vii             dd ?
       .fun             dq ?
       .nas             dq ?
       .pchar           dq ?
       .datype          dq ?
       .tokens          dd ?                    ; scanned tokens counter
       .fcount          dd ?                    ; functions counter
       .ccount          dd ?                    ; constants counter
       .vcount          dd ?                    ; variables counter
       .rcount          dd ?                    ; runtimes counter
       .cbra            dq ?                    ; parenthesis counter ()
       .csbra           dq ?                    ; square bracket counter []
       .ccbra           dq ?                    ; curly bracket counter {}
       .abs.bra         dq ?                    ; abs() function bracket counter (|...|)
       .nabs.bra        dq ?                    ; nabs() function bracket counter (!...!)
       .cblanks         dd ?                    ; blanks counter
       .blanks          dd ?                    ; blanks flag
       .acount          dd ?
       .acount.var      db ?
       .acount.any      db ?
       .ecount          dd ?
       .icounter        dd ?
       .pcount          dq ?
       .fpcount         dq ?
       .coshift         dq ?
       .xshl            dq ?
       .dcon1           dq ?
       .dcon2           dq ?
       .icon1           dq ?
       .icon2           dq ?
       .data.mod        db ?                    ; data modifier flag
       .proc.mode       db ?                    ; proc mode
       .isint           dq ?
       .int32           dd ?
       .int64           dq ?
       .param           dq ?
       .float           dq ?
       .floas           dq ?
       .floai           dq ?
       .ctype           db ?                    ; constant type
       .cbase           dq ?                    ; constant base
       .proc            dq ?
       .procn           dq ?
       .mode            dq ?
       .moden           dq ?
       .param1          dq ?
       .param2          dq ?
       .proc_o          dq ?                    ; function offset
       .proc_z          dq ?                    ; function size
       .rpn.proc        dq ?                    ; rpn function offset
       .rpn.add.res     dd ?                    ; add rpn item result
       .func            dq ?                    ; previous pushf function offset
       .funco           dq ?                    ; function offset
       .funci           dw ?                    ; function item data
       .funcp           dw ?                    ; function priority
       .token           dq ?                    ; previous token data
                                                ; byte [.token]   - token type
                                                ; byte [.token+1] - additional data
       .itype           dw ?                    ; item type
       .idata           dd ?                    ; item data
       .datas           dd ?                    ; data size
       .escape          dd ?
       .cbuff           dd ?
       .dnslen          dd ?                    ; last double number string length
       .rsic            dq ?                    ; rsi ceil
       .neg             db ?
       .break           db ?                    ; break flag
       .int.bytes       db ?                    ; integer result bytes
       .fpatype         dw ?                    ; function parameters type
       .fretype         dw ?                    ; function return type
       .firesp          db ?                    ; function integer result on stack
       .fi2resp         db ?                    ; function 2-integer result on stack
       .fbypass         db ?                    ; bypass function

       .P.count         dd ?

       .var.declare     db ?                    ; variable declaration flag
       .var.assign      db ?                    ; variable assign flag
       .var.double      db ?                    ; double variable declaration flag
       .var.complex     db ?                    ; complex variable declaration flag
       .var.integer     db ?                    ; integer variable declaration flag
       .var.string      db ?                    ; string variable declaration flag

       .stack.frame.on  db ?                    ; stack.frame
       .stack.align.on  db ?                    ; stack.align
       .locals.on       db ?                    ; locals
       .fp.frame.on     db ?                    ; fp.frame
    endl

        mov     [sic], rcx
        mov     [s], rdx
        mov     [sop], r8
;       mov     [], r9

   .enter:
       .proc.enter

;   $ifndef _COFF
;       procall display.string, [s]
;   $end

        xor     rbx, rbx                        ; rbx = 0

        mov     [.ecode], ebx                   ; clear error code

        mov     [.arg.data], rbx                ; clear argument data offset
        mov     [.arg.count], rbx               ; clear argument data items count
        mov     [.arg.cursor], rbx              ; clear argument data cursor

        mov     rdi, [sic]                      ; rdi = T_sic_data structure offset
        test    rdi, rdi
        jz     .error                           ; error. null T_sic_data structure offset

        mov     [.code.space], rbx              ; clear code space
        mov     [.stacko], rbx                  ; clear stack array
        mov     [.tokens], ebx                  ; clear scanned tokens count
        mov     [.stack.ic], ebx                ; clear stack item count
        mov     [.rpn], rbx                     ; clear rpn array
        mov     [.rpn.ic], ebx                  ; clear rpn array item count
        mov     [.fcount], ebx                  ; clear functions count
        mov     [.ccount], ebx                  ; clear constants count
        mov     [.vcount], ebx                  ; clear variables count
        mov     [.rcount], ebx                  ; clear runtimes count
        mov     [.rcode], ebx                   ; clear return code

        mov     [rdi + T_sic_data.tokens], ebx  ; clear scanned tokens count
        mov     [rdi + T_sic_data.rpn], ebx     ; clear rpn array item count
        mov     [rdi + T_sic_data.fcount], ebx  ; clear functions count
        mov     [rdi + T_sic_data.ccount], ebx  ; clear constants count
        mov     [rdi + T_sic_data.vcount], ebx  ; clear variables count
        mov     [rdi + T_sic_data.rcount], ebx  ; clear runtimes count
        mov     [rdi + T_sic_data.gdata], rbx   ; clear global data
        mov     [rdi + T_sic_data.gcode], ebx   ; clear global code
        mov     [rdi + T_sic_data.ecode], ebx   ; clear error code
        mov     [rdi + T_sic_data.rcode], ebx   ; clear return code

        stdcall cfree, [rdi + T_sic_data.code]  ; free previously allocated memory
        mov     [rdi + T_sic_data.code], rbx    ; clear code segment offset
        mov     [rdi + T_sic_data.entry], rbx   ; clear entry point
        mov     [rdi + T_sic_data.size], ebx    ; clear code size
        mov     [rdi + T_sic_data.cspace], ebx  ; clear code space

        mov     edx, [rdi + T_sic_data.calign]
        mov     [.calign], edx                  ; save code align value

        mov     edx, [rdi + T_sic_data.dalign]
        mov     [.dalign], edx                  ; save data align value

        mov     rdx, [sop]                      ; compiler options
        test    rdx, SIC_OPT_FLAG_EXECUTE
        jnz    .coops
        test    rdx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .coops
;       and     rdx, not SIC_OPT_FLAG_LOCALS
   .coops:
        mov     [sop], rdx                      ; actual compiler options
        mov     [rdi + T_sic_data.coops], edx   ; return actual compiler options

        mov     rsi, [s]                        ; rsi = input string offset
        mov     [.csc], rsi
        mov     [.psc], rsi
        test    rsi, rsi
        jz     .error.string                    ; error. null string

        cmp     [@_FDATA], 0
        jz     .error                           ; error. null global function table
        cmp     [@_CDATA], 0
        jz     .error                           ; error. null global constant table
        cmp     [@_VDATA], 0
        jz     .error                           ; error. null global variable table

   .rsic.in:
        mov     [.rsic], rbx                    ; clear [.rsic]
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jz     .rsic.out
        xor     rdx, rdx
        mov     edx, [rdi + T_sic_data.rcode]
        mov     [.rsic], rdx
   .rsic.out:

   .arg.data.in:
        mov     rcx, [@_CFG.memory]
        stdcall halloc, rcx                     ; allocate memory for argument data
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [.arg.data], rax
;  .arg.data.cursor.align?:
;       test    rax, 0x0F
;       jz     .arg.data.cursor
;  .arg.data.cursor.align:
;       mov     rdx, rax
;       and     rdx, 0x0F
;       xor     rcx, rcx
;       sub     rcx, rdx
;       and     rcx, 0x0F
;       add     rax, rcx
   .arg.data.cursor:
        mov     [.arg.cursor], rax
   .arg.data.out:

   .data.in:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .data.out
        mov     rcx, [rdi + T_sic_data.data]    ; rcx = data segment offset
        stdcall hfree, rcx                      ; free previously allocated memory
        mov     [rdi + T_sic_data.data], rbx    ; clear data segment offset
        mov     [rdi + T_sic_data.dsize], ebx   ; clear data size
        mov     [rdi + T_sic_data.dspace], ebx  ; clear data space
        ;
        mov     rcx, [@_CFG.memory]
        stdcall halloc, rcx                     ; allocate memory for data segment
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [rdi + T_sic_data.data], rax
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
;       mov     [rdi + T_sic_data.dsize], edx
;  .data.sys.mem.out:
;       mov     rcx, [@_CFG.memory]
;       sub     rcx, rdx
;       js     .error.memory
;       mov     [rdi + T_sic_data.dspace], ecx
}
        mov     rcx, [@_CFG.memory]
        mov     [rdi + T_sic_data.dspace], ecx
   .data.out:

        mov     rdx, [rdi + T_sic_data.fdata]   ; rdx = function data segment offset
        test    rdx, rdx
        jz     .error                           ; error. null function data segment offset
        mov     [.fdata], rdx                   ; [.fdata] = function data segment offset

        mov     rdx, [rdi + T_sic_data.cdata]   ; rdx = constant data segment offset
        test    rdx, rdx
        jz     .error                           ; error. null constant data segment offset
        mov     [.cdata], rdx                   ; [.cdata] = constant data segment offset

        mov     rdx, [rdi + T_sic_data.vdata]   ; rdx = variable data segment offset
        test    rdx, rdx
        jz     .error                           ; error. null variable data segment offset
        mov     [.vdata], rdx                   ; [.vdata] = variable data segment offset

   .rdata.in:
        mov     rdx, [rdi + T_sic_data.rdata]   ; rdx = runtime data segment offset
        test    rdx, rdx
        jz     .error                           ; error. null runtime data segment offset
        mov     [.rdata], rdx                   ; [.rdata] = runtime data segment offset
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .rdata.out
        mov     [rdx + table.header.icount], ebx; clear runtime data table
   .rdata.out:

        stdcall calloc, [@_CFG.code_size]       ; allocate memory for code segment
        test    rax, rax
        jz     .error                           ; error. memory allocation error
        mov     [rdi + T_sic_data.code], rax    ; rax = code segment offset

   .update.test:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .update.out
   .update.in:
        stdcall tupdate                         ; update tables related data
   .update.out:

        mov     [.stacko], rax                  ; [.stacko] = stack offset
        mov     rdx, rax
        add     rdx, [@_CFG.code_size]
        sub     rdx, sizeof.sitem64             ; rdx = rpn[first-1] item offset
        mov     [.rpni], rdx                    ; [.rpni] = rpn[first-1] item offset
    $ifdef _X64
        mov     [rdx + 00], rbx                 ; clear rpn[first-1] item
        mov     [rdx + 08], rbx
    $else
        mov     [edx + 00], ebx                 ; clear rpn[first-1] item
        mov     [edx + 04], ebx
        mov     [edx + 08], ebx
        mov     [edx + 12], ebx
    $end
        sub     rdx, sizeof.sitem64             ; rdx = rpn first item offset
        mov     [.rpn], rdx                     ; [.rpn] = rpn first item offset

        mov     [.sito], rax                    ; [.sito] = stack first item offset
        sub     rax, sizeof.sitem64             ; rax = stack[first-1] item offset
        mov     [.stacki], rax                  ; [.stacki] = stack[first-1] item offset

        mov     [.vito], rbx                    ; clear var function stack item offset
        mov     [.func], rbx                    ; clear pushf function offset
        mov     [.titem], rbx                   ; clear table item offset
        mov     [.cbra], rbx                    ; clear parenthesis counter
        mov     [.csbra], rbx                   ; clear square bracket counter
        mov     [.ccbra], rbx                   ; clear curly bracket counter
        mov     [.abs.bra], rbx                 ; clear abs() function bracket counter
        mov     [.nabs.bra], rbx                ; clear nabs() function bracket counter
        mov     [.cblanks], ebx                 ; clear blanks counter
        mov     [.blanks], ebx                  ; clear blanks flag
        mov     [.break], bl                    ; clear break flag

        mov     [.var.declare], bl              ; clear variable declaration flag
        mov     [.var.assign], bl               ; clear variable assign flag
        mov     [.var.double], bl               ; clear double variable declaration flag
        mov     [.var.complex], bl              ; clear complex variable declaration flag
        mov     [.var.integer], bl              ; clear integer variable declaration flag
        mov     [.var.string], bl               ; clear string variable declaration flag

    $ifdef _X64
        mov     [.token], rbx                   ; clear token data
    $else
        mov     dword [.token + 0], ebx         ; clear token data
        mov     dword [.token + 4], ebx         ; clear token data
    $end
        mov     [.floas], rbx
        mov     [.floai], rbx
        mov     [.ctype], bl
        mov     [.cbase], rbx
        mov     [.dnslen], ebx

   .rsic.update.in:
        cmp     [.rsic], 0
        je     .rsic.update.out
        add     [.rsic], rsi
   .rsic.update.out:

        dec     rsi

;      $align
   .char.next:
        cmp     [.break], 0
        jnz    .char.leave
        inc     rsi
        mov     [.psc], rsi

   .char.test:
        mov     ah, byte [rsi]
        case    ah,\                            ; skip blanks
                0x20, .char.blank,\             ; space
                0x0D, .char.blank,\             ; carriage return (FE:CR)
                0x0A, .char.blank,\             ; line feed (FE:LF)
                0x09, .char.blank,\             ; tabulation (FE:TAB)
                0xA0, .char.blank,\             ; no-break space
                0x08, .char.blank,\             ; backspace (FE:BS)
                 '¶', .char.leave,\             ; paragraph (end of segment)
                 '§', .char.leave               ; section sign (end of segment)
        jmp    .char.char

   .char.blank:
        inc     [.cblanks]                      ; inc blanks counter
        jmp    .char.next

   .char.char:
        cmp     [.rsic], 0
        je     .char.scan.test
        cmp     rsi, [.rsic]
        jae    .char.leave
   .char.scan.test:
        test    ah, ah
        jnz    .scan                            ; continue while not terminating zero found
   .char.leave:
        cmp     byte [.token + 1], ' '
        jbe    .error.token                     ; error. invalid token order

        mov     rax, rsp                        ; set rax != 0

        cmp     [.cbra], 0
        jne    .error.bracket                   ; ((...) (...))
        cmp     [.csbra], 0
        jne    .error.bracket                   ; [[...] [...]]
        cmp     [.ccbra], 0
        jne    .error.bracket                   ; {{...} {...}}
        cmp     [.abs.bra], 0
        jne    .error.bracket                   ; (|(|...|) (|...|)|)
        cmp     [.nabs.bra], 0
        jne    .error.bracket                   ; (!(!...!) (!...!)!)
        jmp    .return

   .error.CPU:
        mov     [.ecode], SIC_ERROR_CPU
        jmp    .error.main
   .error.string:
        mov     [.ecode], SIC_ERROR_STRING
        jmp    .error.main
   .error.bracket:
        mov     [.ecode], SIC_ERROR_BRACKET
        jmp    .error.main
   .error.token:
        mov     [.ecode], SIC_ERROR_TOKEN
        jmp    .error.main
   .error.memory:
        mov     [.ecode], SIC_ERROR_MEMORY
        jmp    .error.main
   .error.no.impl:
        mov     [.ecode], SIC_ERROR_NO_IMPL
        jmp    .error.main
   .error:
        cmp     [.ecode], 0
        jnz    .error.main
        mov     [.ecode], SIC_ERROR_GENERAL
   .error.main:
        xor     rax, rax

   .return:
        mov     [.RSP], 0
        mov     [.EPC], 0
        mov     [.csc], rsi
        mov     [.rsi], rsi

        test    rax, rax
        jz     .return.main
        call   .stack.verify
        test    rax, rax                        ; rax = code size
        jz     .return.main

        mov     rdi, [sic]                      ; rdi = T_sic_data structure offset

;   $ifdef _SSE3
;       test    [@_CFG.cpu_flags], SIC_CPU_FLAG_SSE3
;       jz     .error.CPU
;   $end

;   $ifdef _SSE4.1
;       test    [@_CFG.cpu_flags], SIC_CPU_FLAG_SSE4.1
;       jz     .error.CPU
;   $end

        test    [sop], SIC_OPT_FLAG_EXECUTE
        jnz    .return.main
        test    [sop], SIC_OPT_FLAG_OPTIMIZATION
        jz     .return.main
;       jnz    .return.optimization.L0
;  .return.optimization.nop:                    ; optimize code
;       stdcall code.clean.nop, [rdi + T_sic_data.code], rax
;       jmp    .return.main
   .return.optimization.L0:
        stdcall code.clean.L0, rdi, rax, [.rcode], [sop]

   .return.main:
        mov     rdi, [sic]                      ; rdi = T_sic_data structure offset
;       test    rdi, rdi
;       jz     .return.ret

        mov     rcx, [.code.space]
        mov     [rdi + T_sic_data.cspace], ecx  ; assign code space

;       mov     ecx, [.stack.ic]
        mov     ecx, [.tokens]
        mov     [rdi + T_sic_data.tokens], ecx  ; assign scanned tokens count

   .return.rpn.count:
        mov     ecx, [.rpn.ic]                  ; ecx = rpn array item count
        mov     [rdi + T_sic_data.rpn], ecx
   .return.rpn.items:
        mov     ecx, [.fcount]
        mov     [rdi + T_sic_data.fcount], ecx  ; assign functions count
        mov     ecx, [.ccount]
        mov     [rdi + T_sic_data.ccount], ecx  ; assign constants count
        mov     ecx, [.vcount]
        mov     [rdi + T_sic_data.vcount], ecx  ; assign variables count
        mov     ecx, [.rcount]
        mov     [rdi + T_sic_data.rcount], ecx  ; assign runtimes count

   .return.code:
        mov     rsi, rax                        ; rsi = code size (save)
        mov     [rdi + T_sic_data.size], eax
        mov     rax, [rdi + T_sic_data.code]
   .return.code.realloc.test:
        mov     rcx, [sop]                      ; rcx = compiler options
        test    rcx, SIC_OPT_FLAG_EXTERNAL_CALL ; no memory reallocation on external call
        jnz    .return.code.entry
   .return.code.realloc:
        stdcall crealloc, rax, rsi
        mov     [rdi + T_sic_data.code], rax
   .return.code.entry:
        mov     [rdi + T_sic_data.entry], rax   ; assign entry point

   .return.code.flush:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .return.code.flush.out
        stdcall FlushCodeCache, rdi
   .return.code.flush.out:

   .return.cursor:
        mov     rax, [.csc]
        sub     rax, [s]
        mov     [rdi + T_sic_data.ccurs], eax   ; assign current string cursor
        mov     rax, [.psc]
        sub     rax, [s]
        mov     [rdi + T_sic_data.pcurs], eax   ; assign previous string cursor
   .return.cursor.out:

        mov     eax, [.ecode]                   ; assign error code
        mov     [rdi + T_sic_data.ecode], eax

        mov     eax, [.rcode]
        mov     [rdi + T_sic_data.rcode], eax   ; assign return code

   .return.data:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .return.data.out
        ;
        mov     rcx, [rdi + T_sic_data.data]    ; rcx = data segment offset
        mov     edx, [rdi + T_sic_data.dsize]   ; rdx = data segment size
        test    rdx, rdx
        jz     .return.data.free
        cmp     [.ecode], 0
        jnz    .return.data.free                ; error
   .return.data.realloc.test:
   .return.data.realloc:
        stdcall hrealloc, rcx, rdx              ; offset remains the same
        test    rax, rax
        jz     .return.data.out
;       mov     [rdi + T_sic_data.data], rax
;       stdcall datoup, [.rdata], ???           ; update data offsets
        jmp    .return.data.out
   .return.data.free:
        stdcall hfree, rcx                      ; free previously allocated memory
        xor     rcx, rcx
        mov     [rdi + T_sic_data.data], rcx    ; clear data segment fields
        mov     [rdi + T_sic_data.dspace], ecx
        mov     [rdi + T_sic_data.dsize], ecx
   .return.data.out:

   .return.arg.data:
        mov     rcx, [.arg.data]
        stdcall hfree, rcx                      ; free argument data
   .return.arg.data.out:

        mov     rax, rsi                        ; result = code size (restore)
   .return.ret:
       .proc.leave
        ret

;      $align
   .scan:
        inc     [.tokens]                       ; inc scanned tokens count
        mov     al, ah
        mov     rdi, rsi

        xor     rbx, rbx
   .blanks.test:
        mov     [.blanks], ebx
        cmp     [.cblanks], 0
        jz     .blanks.out
   .blanks.in:
        inc     [.blanks]
        mov     [.cblanks], ebx
   .blanks.out:

   .symbol.test:
        xor     rdx, rdx                        ; rdx = symbols count
        xor     rcx, rcx                        ; rcx = chars
        mov     bx, word [.token]               ; bx = token additional data
        mov     cl, al                          ; cl = current char
   .symbol.loop:
       .chissym cl, .symbol.next                ; test character is function symbol
        test    rdx, rdx
        jnz    .symbol.in
        jmp    .symbol.out
   .symbol.next:
;       cmp     rdx, 4                          ; max symbols count = 4
        cmp     rdx, 5                          ; max symbols count = 5
        je     .symbol.in
        inc     rdx
        mov     ch, cl                          ; ch = previous char
        mov     cl, byte [rsi + rdx]            ; cl = current char
        jmp    .symbol.loop
   .symbol.in:
        cmp     bx, 'fµ'
        je     .symbol.prefix
        cmp     bh, 'µ'
        jae    .symbol.main                     ; postfix symbols
   .symbol.prefix:
        xor     ch, ch                          ; ch=0 for prefix symbols
   .symbol.main:
        case    rdx,\
                1, .symbol.x1,\
                2, .symbol.x2,\
                3, .symbol.x3,\
                4, .symbol.x4
; --------------------------------------------- ; 5 and more symbols
   .symbol.x5p:
        add     rsi, 4
   .symbol.x5.common:
        test    ch, ch
        jnz    .symbol.x5.postfix
   .symbol.x5.prefix:
        jmp    .symbol.x5.out
   .symbol.x5.postfix:
        mov     edx, dword [rsi - 4]
        mov     ch, byte [rsi]
        case    edx,\
                '[:=:', .symbol.x5.?swap.int,\
                '{:=:', .symbol.x5.?swap.frac,\
                '<:=:', .symbol.x5.?swap.round,\
                '<==>', .symbol.x5.?aif.bea,\
                '>==<', .symbol.x5.?aif.aeb
        jmp    .symbol.x5.out
   .symbol.x5.?swap.int:                        ; [:=:?
        cmp     ch, ']'
        jne    .symbol.x5.out
   .symbol.x5.swap.int:
       .pushf   @@swap.int, 'f ', 4, 1          ; [:=:]
        ;
   .symbol.x5.?swap.frac:                       ; {:=:?
        cmp     ch, '}'
        jne    .symbol.x5.out
   .symbol.x5.swap.frac:
       .pushf   @@swap.frac, 'f ', 4, 1         ; {:=:}
        ;
   .symbol.x5.?swap.round:                      ; <:=:?
        cmp     ch, '>'
        jne    .symbol.x5.out
   .symbol.x5.swap.round:
       .pushf   @@swap.round, 'f ', 4, 1        ; <:=:>
        ;
   .symbol.x5.?aif.bea:                         ; <==>?
        cmp     ch, '~'
        jne    .symbol.x5.out
   .symbol.x5.aif.bea:
       .pushf   @@aif.bea, 'f ', 15, 1          ; <==>~
        ;
   .symbol.x5.?aif.aeb:                         ; >==<?
        cmp     ch, '~'
        jne    .symbol.x5.out
   .symbol.x5.aif.aeb:
       .pushf   @@aif.aeb, 'f ', 15, 1          ; >==<~
        ;
   .symbol.x5.out:
        sub     rsi, 4
; --------------------------------------------- ; 4 symbols
   .symbol.x4:
        mov     edx, dword [rsi]
        add     rsi, 3
   .symbol.x4.common:
        test    ch, ch
        jnz    .symbol.x4.postfix
   .symbol.x4.prefix:
        jmp    .symbol.x4.out
   .symbol.x4.postfix:
        case    edx,\
                '*&->', .symbol.x4.pfara,\
                '*&~>', .symbol.x4.pbara,\
                '>?~<', .symbol.x4.btc,\
                '>?-<', .symbol.x4.btr,\
                '>?+<', .symbol.x4.bts,\
                '[~-]', .symbol.x4.subr.int,\
                '[~/]', .symbol.x4.divr.int,\
                '[~\]', .symbol.x4.quor.int,\
                '[~%]', .symbol.x4.modr.int,\
                '{~-}', .symbol.x4.subr.frac,\
                '{~/}', .symbol.x4.divr.frac,\
                '{~\}', .symbol.x4.quor.frac,\
                '{~%}', .symbol.x4.modr.frac,\
                '<~->', .symbol.x4.subr.round,\
                '<~/>', .symbol.x4.divr.round,\
                '<~\>', .symbol.x4.quor.round,\
                '<~%>', .symbol.x4.modr.round,\
                '<==>', .symbol.x4.if.bea,\
                '>==<', .symbol.x4.if.aeb,\
                '==.~', .symbol.x4.aif.z,\
                '!=.~', .symbol.x4.aif.nz,\
                '<>.~', .symbol.x4.aif.nz,\
                '>=.~', .symbol.x4.aif.aez,\
                '!<.~', .symbol.x4.aif.aez,\
                '<=.~', .symbol.x4.aif.bez,\
                '!>.~', .symbol.x4.aif.bez,\
                '~|~=', .symbol.x4.co.bnorn,\
                '~|-=', .symbol.x4.co.bnorc,\
                '-|~=', .symbol.x4.co.bcorn,\
                '~&~=', .symbol.x4.co.bnandn,\
                '>>>=', .symbol.x4.co.sar,\
                '<<<=', .symbol.x4.co.sal,\
                '>><=', .symbol.x4.co.ror,\
                '<<>=', .symbol.x4.co.rol,\
                '[:=]', .symbol.x4.copy.int,\
                '{:=}', .symbol.x4.copy.frac,\
                '<:=>', .symbol.x4.copy.round,\
                '[=:]', .symbol.x4.copx.int,\
                '{=:}', .symbol.x4.copx.frac,\
                '<=:>', .symbol.x4.copx.round
        jmp    .symbol.x4.out
   .symbol.x4.pfara:
       .pushf   @@pfara, 'f ', 25, 1            ; *&->
   .symbol.x4.pbara:
       .pushf   @@pbara, 'f ', 25, 1            ; *&~>
        ;
   .symbol.x4.btc:
       .pushf   @@btc, 'f ', 23, 1              ; >?~<
   .symbol.x4.btr:
       .pushf   @@btr, 'f ', 23, 1              ; >?-<
   .symbol.x4.bts:
       .pushf   @@bts, 'f ', 23, 1              ; >?+<
        ;
   .symbol.x4.subr.int:
       .pushf   @@subr.int, 'f ', 13, 1         ; [~-]
   .symbol.x4.divr.int:
       .pushf   @@divr.int, 'f ', 13, 1         ; [~/]
   .symbol.x4.quor.int:
       .pushf   @@quor.int, 'f ', 13, 1         ; [~\]
   .symbol.x4.modr.int:
       .pushf   @@modr.int, 'f ', 13, 1         ; [~%]
        ;
   .symbol.x4.subr.frac:
       .pushf   @@subr.frac, 'f ', 13, 1        ; {~-}
   .symbol.x4.divr.frac:
       .pushf   @@divr.frac, 'f ', 13, 1        ; {~/}
   .symbol.x4.quor.frac:
       .pushf   @@quor.frac, 'f ', 13, 1        ; {~\}
   .symbol.x4.modr.frac:
       .pushf   @@modr.frac, 'f ', 13, 1        ; {~%}
        ;
   .symbol.x4.subr.round:
       .pushf   @@subr.round, 'f ', 13, 1       ; <~->
   .symbol.x4.divr.round:
       .pushf   @@divr.round, 'f ', 13, 1       ; <~/>
   .symbol.x4.quor.round:
       .pushf   @@quor.round, 'f ', 13, 1       ; <~\>
   .symbol.x4.modr.round:
       .pushf   @@modr.round, 'f ', 13, 1       ; <~%>
        ;
   .symbol.x4.if.bea:
       .pushf   @@if.bea, 'f ', 15, 1           ; <==>
   .symbol.x4.if.aeb:
       .pushf   @@if.aeb, 'f ', 15, 1           ; >==<
        ;
   .symbol.x4.aif.z:
       .pushf   @@aif.z, 'f¶', 27, 1            ; postfix ==.~
   .symbol.x4.aif.nz:
       .pushf   @@aif.nz, 'f¶', 27, 1           ; postfix !=.~ <>.~
   .symbol.x4.aif.aez:
       .pushf   @@aif.aez, 'f¶', 27, 1          ; postfix >=.~ !<.~
   .symbol.x4.aif.bez:
       .pushf   @@aif.bez, 'f¶', 27, 1          ; postfix <=.~ !>.~
        ;
   .symbol.x4.co.bnorn:
       .pushf   @@co.bnorn, 'f ', 4, 1          ; ~|~=
   .symbol.x4.co.bnorc:
       .pushf   @@co.bnorc, 'f ', 4, 1          ; ~|-=
   .symbol.x4.co.bcorn:
       .pushf   @@co.bcorn, 'f ', 4, 1          ; -|~=
   .symbol.x4.co.bnandn:
       .pushf   @@co.bnandn, 'f ', 4, 1         ; ~&~=
   .symbol.x4.co.sar:
       .pushf   @@co.sar, 'f ', 4, 1            ; >>>=
   .symbol.x4.co.sal:
       .pushf   @@co.sal, 'f ', 4, 1            ; <<<=
   .symbol.x4.co.ror:
       .pushf   @@co.ror, 'f ', 4, 1            ; >><=
   .symbol.x4.co.rol:
       .pushf   @@co.rol, 'f ', 4, 1            ; <<>=
        ;
   .symbol.x4.copy.int:
       .pushf   @@copy.int, 'f ', 4, 1          ; [:=]
   .symbol.x4.copy.frac:
       .pushf   @@copy.frac, 'f ', 4, 1         ; {:=}
   .symbol.x4.copy.round:
       .pushf   @@copy.round, 'f ', 4, 1        ; <:=>
   .symbol.x4.copx.int:
       .pushf   @@copx.int, 'f ', 4, 1          ; [=:]
   .symbol.x4.copx.frac:
       .pushf   @@copx.frac, 'f ', 4, 1         ; {=:}
   .symbol.x4.copx.round:
       .pushf   @@copx.round, 'f ', 4, 1        ; <=:>
        ;
   .symbol.x4.out:
        sub     rsi, 3
; --------------------------------------------- ; 3 symbols
   .symbol.x3:
        mov     edx, dword [rsi]
        and     edx, 0x00FFFFFF
        add     rsi, 2
   .symbol.x3.common:
        test    ch, ch
        jnz    .symbol.x3.postfix
   .symbol.x3.prefix:
        case    edx,\
                '<<?', .symbol.x3.bsf,\
                '>>?', .symbol.x3.bsr,\
                '~!.', .symbol.x3.rnzero
        jmp    .symbol.x3.out
   .symbol.x3.bsf:
       .pushf   @@bsf, 'Fµ', 28, 1              ; <<?x
   .symbol.x3.bsr:
       .pushf   @@bsr, 'Fµ', 28, 1              ; >>?x
   .symbol.x3.rnzero:
       .pushf   @@rnzero, 'Fµ', 28, 1           ; ~!.x
   .symbol.x3.postfix:
        case    edx,\
                '~|~', .symbol.x3.bnorn,\
                '~|-', .symbol.x3.bnorc,\
                '-|~', .symbol.x3.bcorn,\
                '~&~', .symbol.x3.bnandn,\
                '>>>', .symbol.x3.sar,\
                '<<<', .symbol.x3.sal,\
                '>><', .symbol.x3.ror,\
                '<<>', .symbol.x3.rol,\
                '>?<', .symbol.x3.bt,\
                '==.', .symbol.x3.if.z,\
                '!=.', .symbol.x3.if.nz,\
                '<>.', .symbol.x3.if.nz,\
                '>=.', .symbol.x3.if.aez,\
                '!<.', .symbol.x3.if.aez,\
                '<=.', .symbol.x3.if.bez,\
                '!>.', .symbol.x3.if.bez,\
                '>.~', .symbol.x3.aif.az,\
                '<.~', .symbol.x3.aif.bz,\
                '==~', .symbol.x3.aif.e,\
                '!=~', .symbol.x3.aif.ne,\
                '<>~', .symbol.x3.aif.ne,\
                '>=~', .symbol.x3.aif.ae,\
                '!<~', .symbol.x3.aif.ae,\
                '<=~', .symbol.x3.aif.be,\
                '!>~', .symbol.x3.aif.be,\
                '*->', .symbol.x3.pfarr,\
                '*~>', .symbol.x3.pbarr,\
                '&->', .symbol.x3.fara,\
                '&~>', .symbol.x3.bara,\
                '->>', .symbol.x3.farv,\
                '~>>', .symbol.x3.barv,\
                '|+|', .symbol.x3.mean,\
                '|*|', .symbol.x3.gmean,\
                '|/|', .symbol.x3.hmean,\
                '|\|', .symbol.x3.chmean,\
                '?<>', .symbol.x3.minmax,\
                '?><', .symbol.x3.maxmin,\
                '[+]', .symbol.x3.add.int,\
                '[-]', .symbol.x3.sub.int,\
                '[*]', .symbol.x3.mul.int,\
                '[/]', .symbol.x3.div.int,\
                '[\]', .symbol.x3.quo.int,\
                '[%]', .symbol.x3.mod.int,\
                '{+}', .symbol.x3.add.frac,\
                '{-}', .symbol.x3.sub.frac,\
                '{*}', .symbol.x3.mul.frac,\
                '{/}', .symbol.x3.div.frac,\
                '{\}', .symbol.x3.quo.frac,\
                '{%}', .symbol.x3.mod.frac,\
                '<+>', .symbol.x3.add.round,\
                '<->', .symbol.x3.sub.round,\
                '<*>', .symbol.x3.mul.round,\
                '</>', .symbol.x3.div.round,\
                '<\>', .symbol.x3.quo.round,\
                '<%>', .symbol.x3.mod.round,\
                '~-+', .symbol.x3.subr.pos,\
                '~--', .symbol.x3.subr.neg,\
                '~/+', .symbol.x3.divr.pos,\
                '~/-', .symbol.x3.divr.neg,\
                '~\+', .symbol.x3.quor.pos,\
                '~\-', .symbol.x3.quor.neg,\
                '~%+', .symbol.x3.modr.pos,\
                '~%-', .symbol.x3.modr.neg,\
                '~**', .symbol.x3.powr,\
                '~*/', .symbol.x3.rootr,\
                '~/%', .symbol.x3.percent.divr,\
                '~+%', .symbol.x3.percent.incr,\
                '~-%', .symbol.x3.percent.decr,\
                '~-=', .symbol.x3.co.subr,\
                '~/=', .symbol.x3.co.divr,\
                '~\=', .symbol.x3.co.quor,\
                '~%=', .symbol.x3.co.modr,\
                '~|=', .symbol.x3.co.bnor,\
                '|~=', .symbol.x3.co.born,\
                '|-=', .symbol.x3.co.borc,\
                '-|=', .symbol.x3.co.bcor,\
                '~^=', .symbol.x3.co.bxnor,\
                '~&=', .symbol.x3.co.bnand,\
                '&~=', .symbol.x3.co.bandn,\
                '>>=', .symbol.x3.co.shr,\
                '<<=', .symbol.x3.co.shl,\
                '*:=', .symbol.x3.pcopy,\
                '=:*', .symbol.x3.pcopx,\
                ':=:', .symbol.x3.swap,\
                ':++', .symbol.x3.data.mod,\
                ':--', .symbol.x3.data.mod,\
                '[=]', .symbol.x3.copy.int,\
                '{=}', .symbol.x3.copy.frac,\
                '<=>', .symbol.x3.copy.round
        jmp    .symbol.x3.out
   .symbol.x3.data.mod:
        mov     [.data.mod], 2
        jmp    .alpha.scan
        ;
   .symbol.x3.bnorn:
       .pushf   @@bnorn, 'f ', 18, 1            ; ~|~
   .symbol.x3.bnorc:
       .pushf   @@bnorc, 'f ', 19, 1            ; ~|-
   .symbol.x3.bcorn:
       .pushf   @@bcorn, 'f ', 19, 1            ; -|~
   .symbol.x3.bnandn:
       .pushf   @@bnandn, 'f ', 20, 1           ; ~&~
   .symbol.x3.sar:
       .pushf   @@sar, 'f ', 22, 1              ; >>>
   .symbol.x3.sal:
       .pushf   @@sal, 'f ', 22, 1              ; <<<
   .symbol.x3.ror:
       .pushf   @@ror, 'f ', 22, 1              ; >><
   .symbol.x3.rol:
       .pushf   @@rol, 'f ', 22, 1              ; <<>
   .symbol.x3.bt:
       .pushf   @@bt, 'f ', 23, 1               ; >?<
        ;
   .symbol.x3.if.z:
       .pushf   @@if.z, 'f¶', 27, 1             ; postfix ==.
   .symbol.x3.if.nz:
       .pushf   @@if.nz, 'f¶', 27, 1            ; postfix !=. <>.
   .symbol.x3.if.aez:
       .pushf   @@if.aez, 'f¶', 27, 1           ; postfix >=. !<.
   .symbol.x3.if.bez:
       .pushf   @@if.bez, 'f¶', 27, 1           ; postfix <=. !>.
        ;
   .symbol.x3.aif.az:
       .pushf   @@aif.az, 'f¶', 27, 1           ; postfix >.~
   .symbol.x3.aif.bz:
       .pushf   @@aif.bz, 'f¶', 27, 1           ; postfix <.~
        ;
   .symbol.x3.aif.e:
       .pushf   @@aif.e, 'f ', 5, 1             ; ==~
   .symbol.x3.aif.ne:
       .pushf   @@aif.ne, 'f ', 5, 1            ; !=~ <>~
   .symbol.x3.aif.ae:
       .pushf   @@aif.ae, 'f ', 5, 1            ; >=~ !<~
   .symbol.x3.aif.be:
       .pushf   @@aif.be, 'f ', 5, 1            ; <=~ !>~
        ;
   .symbol.x3.pfarr:
       .pushf   @@pfarr, 'f ', 24, 1            ; *->
   .symbol.x3.pbarr:
       .pushf   @@pbarr, 'f ', 24, 1            ; *~>
   .symbol.x3.fara:
       .pushf   @@fara, 'f ', 25, 1             ; &->
   .symbol.x3.bara:
       .pushf   @@bara, 'f ', 25, 1             ; &~>
   .symbol.x3.farv:
       .pushf   @@farv, 'f ', 24, 1             ; ->>
   .symbol.x3.barv:
       .pushf   @@barv, 'f ', 24, 1             ; ~>>
   .symbol.x3.mean:
       .pushf   @@mean, 'f ', 13, 1             ; |+|
   .symbol.x3.gmean:
       .pushf   @@gmean, 'f ', 13, 1            ; |*|
   .symbol.x3.hmean:
       .pushf   @@hmean, 'f ', 13, 1            ; |/|
   .symbol.x3.chmean:
       .pushf   @@chmean, 'f ', 13, 1           ; |\|
   .symbol.x3.minmax:
       .pushf   @@minmax, 'f ', 15, 1           ; ?<>
   .symbol.x3.maxmin:
       .pushf   @@maxmin, 'f ', 15, 1           ; ?><
        ;
   .symbol.x3.add.int:
       .pushf   @@add.int, 'f ', 13, 1          ; [+]
   .symbol.x3.sub.int:
       .pushf   @@sub.int, 'f ', 13, 1          ; [-]
   .symbol.x3.mul.int:
       .pushf   @@mul.int, 'f ', 13, 1          ; [*]
   .symbol.x3.div.int:
       .pushf   @@div.int, 'f ', 13, 1          ; [/]
   .symbol.x3.quo.int:
       .pushf   @@quo.int, 'f ', 13, 1          ; [\]
   .symbol.x3.mod.int:
       .pushf   @@mod.int, 'f ', 13, 1          ; [%]
        ;
   .symbol.x3.add.frac:
       .pushf   @@add.frac, 'f ', 13, 1         ; {+}
   .symbol.x3.sub.frac:
       .pushf   @@sub.frac, 'f ', 13, 1         ; {-}
   .symbol.x3.mul.frac:
       .pushf   @@mul.frac, 'f ', 13, 1         ; {*}
   .symbol.x3.div.frac:
       .pushf   @@div.frac, 'f ', 13, 1         ; {/}
   .symbol.x3.quo.frac:
       .pushf   @@quo.frac, 'f ', 13, 1         ; {\}
   .symbol.x3.mod.frac:
       .pushf   @@mod.frac, 'f ', 13, 1         ; {%}
        ;
   .symbol.x3.add.round:
       .pushf   @@add.round, 'f ', 13, 1        ; <+>
   .symbol.x3.sub.round:
       .pushf   @@sub.round, 'f ', 13, 1        ; <->
   .symbol.x3.mul.round:
       .pushf   @@mul.round, 'f ', 13, 1        ; <*>
   .symbol.x3.div.round:
       .pushf   @@div.round, 'f ', 13, 1        ; </>
   .symbol.x3.quo.round:
       .pushf   @@quo.round, 'f ', 13, 1        ; <\>
   .symbol.x3.mod.round:
       .pushf   @@mod.round, 'f ', 13, 1        ; <%>
        ;
   .symbol.x3.subr.pos:
       .pushf   @@subr.pos, 'f ', 12, 1         ; ~-+
   .symbol.x3.subr.neg:
       .pushf   @@subr.neg, 'f ', 12, 1         ; ~--
   .symbol.x3.divr.pos:
       .pushf   @@divr.pos, 'f ', 12, 1         ; ~/+
   .symbol.x3.divr.neg:
       .pushf   @@divr.neg, 'f ', 12, 1         ; ~/-
   .symbol.x3.quor.pos:
       .pushf   @@quor.pos, 'f ', 12, 1         ; ~\+
   .symbol.x3.quor.neg:
       .pushf   @@quor.neg, 'f ', 12, 1         ; ~\-
   .symbol.x3.modr.pos:
       .pushf   @@modr.pos, 'f ', 12, 1         ; ~%+
   .symbol.x3.modr.neg:
       .pushf   @@modr.neg, 'f ', 12, 1         ; ~%-
        ;
   .symbol.x3.powr:
       .pushf   @@powr, 'f ', 17, 1             ; ~**
   .symbol.x3.rootr:
       .pushf   @@rootr, 'f ', 17, 1            ; ~*/
        ;
   .symbol.x3.percent.divr:
       .pushf   @@percent.divr, 'f ', 14, 1     ; ~/%
   .symbol.x3.percent.incr:
       .pushf   @@percent.incr, 'f ', 14, 1     ; ~+%
   .symbol.x3.percent.decr:
       .pushf   @@percent.decr, 'f ', 14, 1     ; ~-%
        ;
   .symbol.x3.co.subr:
       .pushf   @@co.subr, 'f ', 4, 1           ; ~-=
   .symbol.x3.co.divr:
       .pushf   @@co.divr, 'f ', 4, 1           ; ~/=
   .symbol.x3.co.quor:
       .pushf   @@co.quor, 'f ', 4, 1           ; ~\=
   .symbol.x3.co.modr:
       .pushf   @@co.modr, 'f ', 4, 1           ; ~%=
   .symbol.x3.co.bnor:
       .pushf   @@co.bnor, 'f ', 4, 1           ; ~|=
   .symbol.x3.co.born:
       .pushf   @@co.born, 'f ', 4, 1           ; |~=
   .symbol.x3.co.borc:
       .pushf   @@co.borc, 'f ', 4, 1           ; |-=
   .symbol.x3.co.bcor:
       .pushf   @@co.bcor, 'f ', 4, 1           ; -|=
   .symbol.x3.co.bxnor:
       .pushf   @@co.bxnor, 'f ', 4, 1          ; ~^=
   .symbol.x3.co.bnand:
       .pushf   @@co.bnand, 'f ', 4, 1          ; ~&=
   .symbol.x3.co.bandn:
       .pushf   @@co.bandn, 'f ', 4, 1          ; &~=
   .symbol.x3.co.shr:
       .pushf   @@co.shr, 'f ', 4, 1            ; >>=
   .symbol.x3.co.shl:
       .pushf   @@co.shl, 'f ', 4, 1            ; <<=
        ;
   .symbol.x3.pcopy:
       .pushf   @@pcopy, 'f ', 4, 1             ; *:=
   .symbol.x3.pcopx:
       .pushf   @@pcopx, 'f ', 4, 1             ; =:*
   .symbol.x3.swap:
       .pushf   @@swap, 'f ', 4, 1              ; :=:
        ;
   .symbol.x3.copy.int:
       .pushf   @@copy.int, 'f ', 4, 1          ; [=]
   .symbol.x3.copy.frac:
       .pushf   @@copy.frac, 'f ', 4, 1         ; {=}
   .symbol.x3.copy.round:
       .pushf   @@copy.round, 'f ', 4, 1        ; <=>
        ;
   .symbol.x3.out:
        sub     rsi, 2
; --------------------------------------------- ; 2 symbols
   .symbol.x2:
        mov     dx, word [rsi]
        inc     rsi
   .symbol.x2.common:
        test    ch, ch
        jnz    .symbol.x2.postfix
   .symbol.x2.prefix:
        case    dx,\
                '++', .symbol.x2.inc.pre,\
                '--', .symbol.x2.dec.pre,\
                '!.', .symbol.x2.nzero,\
                '°°', .symbol.x2.r2g,\
                ':=', .symbol.x2.result.set,\
                '==', .symbol.x2.result.get,\
                '&&', .symbol.x2.saddr,\
                '**', .symbol.x2.pcomplex.x,\
                '(|', .symbol.x2.abs.bra,\
                '(!', .symbol.x2.nabs.bra
        jmp    .symbol.x2.out
   .symbol.x2.saddr:
       .pushf   @@saddr, 'Fµ', 42, 1            ; &&x
   .symbol.x2.pcomplex.x:
       .pushf   @@pcomplex, 'Fµ', 42, 1         ; **x
        ;
   .symbol.x2.inc.pre:
       .pushf   @@inc.pre, 'Fµ', 28, 1          ; ++x
   .symbol.x2.dec.pre:
       .pushf   @@dec.pre, 'Fµ', 28, 1          ; --x
   .symbol.x2.nzero:
       .pushf   @@nzero, 'Fµ', 28, 1            ; !.x
   .symbol.x2.r2g:
       .pushf   @@r2g, 'Fµ', 28, 1              ; °°x
        ;
   .symbol.x2.result.set:
       .pushf   @@result.set, 'f=', 4, 1        ; :=x
   .symbol.x2.result.get:
       .pushf   @@result.get, 'f¶', 33, 1       ; ==
        ;
   .symbol.x2.abs.bra:
        inc     [.abs.bra]
       .pushn   0                               ; null item
       .pushf   ??nop, 0x013F, 0, 1             ; '?'=0x3F 0x01
   .symbol.x2.nabs.bra:
        inc     [.nabs.bra]
       .pushn   0                               ; null item
       .pushf   ??nop, 0x023F, 0, 1             ; '?'=0x3F 0x02
        ;
   .symbol.x2.postfix:
        case    dx,\
                '~|', .symbol.x2.bnor,\
                '|~', .symbol.x2.born,\
                '|-', .symbol.x2.borc,\
                '-|', .symbol.x2.bcor,\
                '~&', .symbol.x2.bnand,\
                '&~', .symbol.x2.bandn,\
                '>>', .symbol.x2.shr,\
                '<<', .symbol.x2.shl,\
                '||', .symbol.x2.or,\
                '!|', .symbol.x2.nor,\
                '^^', .symbol.x2.pcomplex,\     ; .symbol.x2.xor
                '!^', .symbol.x2.xnor,\
                '&&', .symbol.x2.and,\
                '!&', .symbol.x2.nand,\
                '>.', .symbol.x2.if.az,\
                '<.', .symbol.x2.if.bz,\
                '==', .symbol.x2.if.e,\
                '!=', .symbol.x2.if.ne,\
                '<>', .symbol.x2.if.ne,\
                '>=', .symbol.x2.if.ae,\
                '!<', .symbol.x2.if.ae,\
                '<=', .symbol.x2.if.be,\
                '!>', .symbol.x2.if.be,\
                '>~', .symbol.x2.aif.a,\
                '<~', .symbol.x2.aif.b,\
                '->', .symbol.x2.farr,\
                '~>', .symbol.x2.barr,\
                '?<', .symbol.x2.min,\
                '?>', .symbol.x2.max,\
                '++', .symbol.x2.inc.post,\
                '-+', .symbol.x2.sub.pos,\
                '*+', .symbol.x2.mul.pos,\
                '/+', .symbol.x2.div.pos,\
                '\+', .symbol.x2.quo.pos,\
                '%+', .symbol.x2.mod.pos,\
                '+-', .symbol.x2.add.neg,\
                '--', .symbol.x2.dec.post,\
                '*-', .symbol.x2.mul.neg,\
                '/-', .symbol.x2.div.neg,\
                '\-', .symbol.x2.quo.neg,\
                '%-', .symbol.x2.mod.neg,\
                '\%', .symbol.x2.quo.mod,\
                '%\', .symbol.x2.mod.quo,\
                '**', .symbol.x2.pow,\
                '*/', .symbol.x2.root,\
                '~-', .symbol.x2.subr,\
                '~/', .symbol.x2.divr,\
                '~\', .symbol.x2.quor,\
                '~%', .symbol.x2.modr,\
                '~^', .symbol.x2.powr.??,\
                '*%', .symbol.x2.percent.mul,\
                '/%', .symbol.x2.percent.div,\
                '+%', .symbol.x2.percent.inc,\
                '-%', .symbol.x2.percent.dec,\
                '!!', .symbol.x2.fact2,\
                '°°', .symbol.x2.g2r,\
                '+=', .symbol.x2.co.add,\
                '-=', .symbol.x2.co.sub,\
                '*=', .symbol.x2.co.mul,\
                '/=', .symbol.x2.co.div,\
                '\=', .symbol.x2.co.quo,\
                '%=', .symbol.x2.co.mod,\
                '~=', .symbol.x2.co.bnot,\
                '|=', .symbol.x2.co.bor,\
                '^=', .symbol.x2.co.bxor,\
                '&=', .symbol.x2.co.band,\
                ':=', .symbol.x2.co.rxcopy,\
                '=:', .symbol.x2.copx,\
                '::', .symbol.x2.absolute,\
                ':+', .symbol.x2.data.mod,\
                ':-', .symbol.x2.data.mod,\
                ':/', .symbol.x2.data.mod,\
                ':\', .symbol.x2.data.mod,\
                ':%', .symbol.x2.data.mod,\
                '|)', .symbol.x2.abs.ket,\
                '!)', .symbol.x2.nabs.ket
        jmp    .symbol.x2.out
   .symbol.x2.data.mod:
        mov     [.data.mod], 2
        jmp    .alpha.scan
        ;
   .symbol.x2.pcomplex:
       .pushf   @@pcomplex, 'fµ', 27, 1         ; x^^
        ;
   .symbol.x2.bnor:
       .pushf   @@bnor, 'f ', 18, 1             ; ~|
   .symbol.x2.born:
       .pushf   @@born, 'f ', 18, 1             ; |~
   .symbol.x2.borc:
       .pushf   @@borc, 'f ', 19, 1             ; |-
   .symbol.x2.bcor:
       .pushf   @@bcor, 'f ', 19, 1             ; -|
   .symbol.x2.bnand:
       .pushf   @@bnand, 'f ', 20, 1            ; ~&
   .symbol.x2.bandn:
       .pushf   @@bandn, 'f ', 20, 1            ; &~
   .symbol.x2.shr:
       .pushf   @@shr, 'f ', 22, 1              ; >>
   .symbol.x2.shl:
       .pushf   @@shl, 'f ', 22, 1              ; <<
   .symbol.x2.or:
       .pushf   @@or, 'f ', 6, 1                ; ||
   .symbol.x2.nor:
       .pushf   @@nor, 'f ', 7, 1               ; !|
;  .symbol.x2.xor:
;      .pushf   @@xor, 'f ', 6, 1               ; ^^
   .symbol.x2.xnor:
       .pushf   @@xnor, 'f ', 7, 1              ; !^
   .symbol.x2.and:
       .pushf   @@and, 'f ', 7, 1               ; &&
   .symbol.x2.nand:
       .pushf   @@nand, 'f ', 6, 1              ; !&
        ;
   .symbol.x2.if.az:
       .pushf   @@if.az, 'f¶', 27, 1            ; postfix >.
   .symbol.x2.if.bz:
       .pushf   @@if.bz, 'f¶', 27, 1            ; postfix <.
        ;
   .symbol.x2.if.e:
       .pushf   @@if.e, 'f ', 5, 1              ; ==
   .symbol.x2.if.ne:
       .pushf   @@if.ne, 'f ', 5, 1             ; != <>
   .symbol.x2.if.ae:
       .pushf   @@if.ae, 'f ', 5, 1             ; >= !<
   .symbol.x2.if.be:
       .pushf   @@if.be, 'f ', 5, 1             ; <= !>
        ;
   .symbol.x2.aif.a:
       .pushf   @@aif.a, 'f ', 5, 1             ; >~
   .symbol.x2.aif.b:
       .pushf   @@aif.b, 'f ', 5, 1             ; <~
        ;
   .symbol.x2.farr:
       .pushf   @@farr, 'f ', 24, 1             ; ->
   .symbol.x2.barr:
       .pushf   @@barr, 'f ', 24, 1             ; ~>
   .symbol.x2.min:
       .pushf   @@min, 'f ', 15, 1              ; ?<
   .symbol.x2.max:
       .pushf   @@max, 'f ', 15, 1              ; ?>
        ;
   .symbol.x2.add.pos:
   .symbol.x2.inc.post:
       .pushf   @@inc.post, 'fµ', 27, 1         ; postfix ++
   .symbol.x2.sub.pos:
       .pushf   @@sub.pos, 'f ', 12, 1          ; -+
   .symbol.x2.mul.pos:
       .pushf   @@mul.pos, 'f ', 12, 1          ; *+
   .symbol.x2.div.pos:
       .pushf   @@div.pos, 'f ', 12, 1          ; /+
   .symbol.x2.quo.pos:
       .pushf   @@quo.pos, 'f ', 12, 1          ; \+
   .symbol.x2.mod.pos:
       .pushf   @@mod.pos, 'f ', 12, 1          ; %+
        ;
   .symbol.x2.add.neg:
       .pushf   @@add.neg, 'f ', 12, 1          ; +-
   .symbol.x2.sub.neg:
   .symbol.x2.dec.post:
       .pushf   @@dec.post, 'fµ', 27, 1         ; postfix --
   .symbol.x2.mul.neg:
       .pushf   @@mul.neg, 'f ', 12, 1          ; *-
   .symbol.x2.div.neg:
       .pushf   @@div.neg, 'f ', 12, 1          ; /-
   .symbol.x2.quo.neg:
       .pushf   @@quo.neg, 'f ', 12, 1          ; \-
   .symbol.x2.mod.neg:
       .pushf   @@mod.neg, 'f ', 12, 1          ; %-
        ;
   .symbol.x2.quo.mod:
       .pushf   @@quo.mod, 'f ', 12, 1          ; \%
   .symbol.x2.mod.quo:
       .pushf   @@mod.quo, 'f ', 12, 1          ; %\
        ;
   .symbol.x2.pow:
       .pushf   @@pow, 'f ', 17, 1              ; **
   .symbol.x2.root:
       .pushf   @@root, 'f ', 17, 1             ; */
   .symbol.x2.powr.??:
;      .pushf   @@powr, 'f ', 17, 1             ; ~^
       .pushf   ??powr.??, 'f ', 17, 1          ; ~^
   .symbol.x2.subr:
       .pushf   @@subr, 'f ', 12, 1             ; ~-
   .symbol.x2.divr:
       .pushf   @@divr, 'f ', 12, 1             ; ~/
   .symbol.x2.quor:
       .pushf   @@quor, 'f ', 12, 1             ; ~\
   .symbol.x2.modr:
       .pushf   @@modr, 'f ', 12, 1             ; ~%
        ;
   .symbol.x2.percent.mul:
       .pushf   @@percent.mul, 'f ', 14, 1      ; *%
   .symbol.x2.percent.div:
       .pushf   @@percent.div, 'f ', 14, 1      ; /%
   .symbol.x2.percent.inc:
       .pushf   @@percent.inc, 'f ', 14, 1      ; +%
   .symbol.x2.percent.dec:
       .pushf   @@percent.dec, 'f ', 14, 1      ; -%
   .symbol.x2.fact2:
       .pushf   @@fact2, 'f¶', 27, 1            ; postfix !! x!!
   .symbol.x2.g2r:
       .pushf   @@g2r, 'f¶', 27, 1              ; postfix °° x°°
        ;
   .symbol.x2.co.add:
       .pushf   @@co.add, 'f ', 4, 1            ; +=
   .symbol.x2.co.sub:
       .pushf   @@co.chs, 'fµ', 4, 1            ; -=
   .symbol.x2.co.mul:
       .pushf   @@co.mul, 'f ', 4, 1            ; *=
   .symbol.x2.co.div:
       .pushf   @@co.div, 'f ', 4, 1            ; /=
   .symbol.x2.co.quo:
       .pushf   @@co.quo, 'f ', 4, 1            ; \=
   .symbol.x2.co.mod:
       .pushf   @@co.mod, 'f ', 4, 1            ; %=
   .symbol.x2.co.bnot:
       .pushf   @@co.bnot, 'f ', 4, 1           ; ~=
   .symbol.x2.co.bor:
       .pushf   @@co.bor, 'f ', 4, 1            ; |=
   .symbol.x2.co.bxor:
       .pushf   @@co.bxor, 'f ', 4, 1           ; ^=
   .symbol.x2.co.band:
       .pushf   @@co.band, 'f ', 4, 1           ; &=
        ;
   .symbol.x2.co.rxcopy:
       .pushf   @@co.rxcopy, 'fµ', 27, 1        ; x:=
   .symbol.x2.copx:
       .pushf   @@copx, 'f ', 4, 1              ; =:
   .symbol.x2.absolute:
        cmp     [.var.declare], 0
        jz     .symbol.x2.absolute.error
       .pushf   @@absolute, 'A ', 33, 1         ; ::
   .symbol.x2.absolute.error:
        inc     rsi
        jmp    .error.token
        ;
   .symbol.x2.abs.ket:
        dec     [.abs.bra]
        js     .error.bracket
   .symbol.x2.abs.ket.p.scan:
        mov     al, 0x01
        call   .stack.par.scan
        test    rax, rax
        jz     .symbol.x2.out
   .symbol.x2.abs.ket.p.abs?:
        cmp     [rax + sitem64.ItemType - sizeof.sitem64], 0
        jne    .symbol.x2.out
   .symbol.x2.abs.ket.p.abs:
        push    rax
        mov     [rax + sitem64.ItemType], '(('  ; 0x01 -> (
       .push    ')¶', 1, 0, 0, 0                ; )
        pop     rax
        sub     rax, sizeof.sitem64
        mov     rdx, [??.abs]                   ; (|???|) -> abs(???)
        mov     [rax + sitem64.ItemType], 'Fµ'
        mov     [rax + sitem64.ArgCount], 1
        mov     [rax + sitem64.ReType], 1
        mov     [rax + sitem64.Priority], 33
        mov     [rax + sitem64.Param], rdx
        jmp    .char.next
        ;
   .symbol.x2.nabs.ket:
        dec     [.nabs.bra]
        js     .error.bracket
   .symbol.x2.nabs.ket.p.scan:
        mov     al, 0x02
        call   .stack.par.scan
        test    rax, rax
        jz     .symbol.x2.out
   .symbol.x2.nabs.ket.p.abs?:
        cmp     [rax + sitem64.ItemType - sizeof.sitem64], 0
        jne    .symbol.x2.out
   .symbol.x2.nabs.ket.p.abs:
        push    rax
        mov     [rax + sitem64.ItemType], '(('  ; 0x02 -> (
       .push    ')¶', 1, 0, 0, 0                ; )
        pop     rax
        sub     rax, sizeof.sitem64
        mov     rdx, [??.nabs]                  ; (!???!) -> nabs(???)
        mov     [rax + sitem64.ItemType], 'Fµ'
        mov     [rax + sitem64.ArgCount], 1
        mov     [rax + sitem64.ReType], 1
        mov     [rax + sitem64.Priority], 33
        mov     [rax + sitem64.Param], rdx
        jmp    .char.next
        ;
   .symbol.x2.out:
        dec     rsi
; --------------------------------------------- ; 1 symbol
   .symbol.x1:
        mov     dl, byte [rsi]
   .symbol.x1.common:
        test    ch, ch
        jnz    .symbol.x1.postfix
   .symbol.x1.prefix:
        case    dl,\
                '+', .symbol.x1.uplus,\
                '-', .symbol.x1.chs,\
                '*', .symbol.x1.pdouble.x,\
                '/', .symbol.x1.inv,\
                '&', .symbol.x1.addr,\
                '~', .symbol.x1.bnot,\
                '?', .symbol.x1.ot,\
                '!', .symbol.x1.not,\
                '°', .symbol.x1.r2d,\
                '=', .symbol.x1.result.set
        jmp    .symbol.x1.out
   .symbol.x1.uplus:
       .pushf   @@uplus, 'Fµ', 28, 1            ; +x
   .symbol.x1.chs:
       .pushf   @@chs, 'Fµ', 28, 1              ; -x
   .symbol.x1.pdouble.x:
       .pushf   @@pdouble, 'Fµ', 42, 1          ; *x
   .symbol.x1.inv:
       .pushf   @@inv, 'Fµ', 28, 1              ; /x
        ;
   .symbol.x1.addr:
       .pushf   @@addr, 'Fµ', 42, 1             ; &x
   .symbol.x1.bnot:
       .pushf   @@bnot, 'Fµ', 28, 1             ; ~x
   .symbol.x1.ot:
       .pushf   @@ot, 'Fµ', 28, 1               ; ?x
   .symbol.x1.not:
       .pushf   @@not, 'Fµ', 28, 1              ; !x
   .symbol.x1.r2d:
       .pushf   @@r2d, 'Fµ', 28, 1              ; °x
        ;
   .symbol.x1.result.set:
       .pushf   @@result.set, 'Fµ', 4, 1        ; =x
   .symbol.x1.postfix:
        case    dl,\
                '+', .symbol.x1.add,\
                '-', .symbol.x1.sub,\
                '*', .symbol.x1.mul,\
                '/', .symbol.x1.div,\
                '\', .symbol.x1.quo,\
                '%', .symbol.x1.mod,\
                '|', .symbol.x1.VL,\
                '&', .symbol.x1.band,\
                '!', .symbol.x1.fact,\
                '^', .symbol.x1.pdouble,\
                '°', .symbol.x1.d2r,\
                '=', .symbol.x1.co.rcopy
        jmp    .symbol.x1.out
   .symbol.x1.add:
       .pushf   @@add, 'f ', 8, 1               ; +
   .symbol.x1.sub:
       .pushf   @@sub, 'f ', 8, 1               ; -
   .symbol.x1.mul:
       .pushf   @@mul, 'f ', 9, 1               ; *
   .symbol.x1.div:
       .pushf   @@div, 'f ', 9, 1               ; /
   .symbol.x1.quo:
       .pushf   @@quo, 'f ', 10, 1              ; \
   .symbol.x1.mod:
       .pushf   @@mod, 'f ', 11, 1              ; %
        ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ; |...
   .symbol.x1.VL:
        mov     dl, byte [rsi + 1]
        cmp     dl, 'A'
        je     .symbol.x1.VL.AU
        cmp     dl, 'G'
        je     .symbol.x1.VL.GU
        cmp     dl, 'Q'
        je     .symbol.x1.VL.QU
        cmp     dl, 'H'
        je     .symbol.x1.VL.HU
        cmp     dl, 'h'
        je     .symbol.x1.VL.HL
        cmp     dl, 'C'
        je     .symbol.x1.VL.CU
        cmp     dl, 'c'
        je     .symbol.x1.VL.CL
        cmp     dl, '0'
        je     .symbol.x1.VL.0
        cmp     dl, '1'
        je     .symbol.x1.VL.1
   .symbol.x1.bor:
       .pushf   @@bor, 'f ', 18, 1              ; |
        ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ; |?|
   .symbol.x1.VL.AU:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.AU.VL:                         ; |A|
        add     rsi, 2
       .pushf   @@mean, 'f ', 13, 1
        ;
   .symbol.x1.VL.GU:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.GU.VL:                         ; |G|
        add     rsi, 2
       .pushf   @@gmean, 'f ', 13, 1
        ;
   .symbol.x1.VL.QU:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.QU.VL:                         ; |Q|
        add     rsi, 2
       .pushf   @@qmean, 'f ', 13, 1
        ;
   .symbol.x1.VL.HU:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.HU.VL:                         ; |H|
        add     rsi, 2
       .pushf   @@hmean, 'f ', 13, 1
        ;
   .symbol.x1.VL.HL:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.HL.VL:                         ; |h|
        add     rsi, 2
       .pushf   @@hemean, 'f ', 13, 1
        ;
   .symbol.x1.VL.CU:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.CU.VL:                         ; |C|
        add     rsi, 2
       .pushf   @@chmean, 'f ', 13, 1
        ;
   .symbol.x1.VL.CL:
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.CL.VL:                         ; |c|
        add     rsi, 2
       .pushf   @@cemean, 'f ', 13, 1
        ;
   .symbol.x1.VL.0:                             ; |0...
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.0.VL?:                         ; |0|...
        mov     dl, byte [rsi + 3]
        cmp     dl, '='
        je     .symbol.x1.VL.0.VL.EQ
   .symbol.x1.VL.0.VL:                          ; |0|
        add     rsi, 2
       .pushf   @@breset, 'f ', 21, 1
   .symbol.x1.VL.0.VL.EQ:                       ; |0|=
        add     rsi, 3
       .pushf   @@co.breset, 'f ', 4, 1
        ;
   .symbol.x1.VL.1:                             ; |1...
        mov     dl, byte [rsi + 2]
        cmp     dl, '|'
        jne    .symbol.x1.bor
   .symbol.x1.VL.1.VL?:                         ; |1|...
        mov     dl, byte [rsi + 3]
        cmp     dl, '='
        je     .symbol.x1.VL.1.VL.EQ
   .symbol.x1.VL.1.VL:                          ; |1|
        add     rsi, 2
       .pushf   @@bset, 'f ', 21, 1
   .symbol.x1.VL.1.VL.EQ:                       ; |1|=
        add     rsi, 3
       .pushf   @@co.bset, 'f ', 4, 1
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
        ;
   .symbol.x1.band:
       .pushf   @@band, 'f ', 20, 1             ; &
   .symbol.x1.fact:
       .pushf   @@fact, 'f¶', 27, 1             ; postfix ! x!
   .symbol.x1.pdouble:
       .pushf   @@pdouble, 'fµ', 27, 1          ; x^
   .symbol.x1.d2r:
       .pushf   @@d2r, 'f¶', 27, 1              ; postfix ° x°
        ;
   .symbol.x1.co.rcopy:
       .pushf   @@co.rcopy, 'fµ', 27, 1         ; x=
        ;
   .symbol.x1.out:
; ----------------------------------------------
   .symbol.out:
        xor     rbx, rbx

        mov     bh, byte [.token + 5]           ; bh = token L3 additional data
        shl     rbx, 8
        mov     bh, byte [.token + 3]           ; bh = token L2 additional data
        mov     bl, byte [.token + 1]           ; bl = token L1 additional data
        mov     rdx, [.func]                    ; rdx = [.func]

        case    al,\
                '(', .bra,\                     ; left parenthesis
                ')', .ket,\                     ; right parenthesis
                ';', .sem,\                     ; semicolon
                ',', .com,\                     ; comma
                ':', .colon,\                   ; colon
                '#', .number,\                  ; number sign
                '$', .dollar,\                  ; dollar sign
                '`', .gaccent,\                 ; grave accent
                '<', .jbb,\                     ; less-than sign
                '>', .jaa,\                     ; greater-than sign
                '[', .lsbra,\                   ; left square bracket
                ']', .rsbra,\                   ; right square bracket
                '{', .lcbra,\                   ; left curly bracket
                '}', .rcbra                     ; right curly bracket

        case    al,\
                "'", .apo,\                     ; apostrophe
                '"', .quo,\                     ; quotation mark
                '“', .dquo,\                    ; left double quotation mark
                '„', .dquo,\                    ; double low-9 quotation mark
                '‘', .squo,\                    ; left single quotation mark
                '‚', .squo,\                    ; single low-9 quotation mark
                '«', .daquo,\                   ; left-pointing double angle quotation mark
                '‹', .saquo                     ; single left-pointing angle quotation mark

   .alpha.digit:
;       cmp     bl, 'µ'                         ; token is function, variable or constant
;       jae    .error.token                     ; error. invalid token order

        cmp     bx, ':$'
        je     .digit.xfloat.B16                ; $:FFFFFFFFFFFFFFFF

        cmp     bl, ':'
        je     .data.mod.TEST

       .chisa   al, ah, .alpha                  ; test character is "alphabetic"
        mov     al, ah
       .chisne  al                              ; test character is numeric

   .digit:
        cmp     [.cbase], 0
        jg     .digit.uint
        cmp     bx, '##'
        je     .digit.uint.B2
        cmp     bx, '$$'
        je     .digit.uint.B8
        cmp     bl, '#'
        je     .digit.uint.B10
        cmp     bl, '$'
        je     .digit.uint.B16
        jmp    .digit.TEST
   .digit.sint:
        call   .stack.shrink
        lea     rax, [.pchar]
        cinvoke _strtoi64, rsi, rax, [.cbase]   ; get x-based signed integer
        cmp     rsi, [.pchar]
        je     .error
        jmp    .digit.xint.push
   .digit.xfloat.B16:
        mov     [.ctype], 1
        mov     [.cbase], 16
        call   .stack.shrink
        jmp    .digit.uint
   .digit.uint.B2:
        mov     [.cbase], 2
        call   .stack.shrink
        jmp    .digit.uint
   .digit.uint.B8:
        mov     [.cbase], 8
        call   .stack.shrink
        jmp    .digit.uint
   .digit.uint.B16:
        mov     [.cbase], 16
        jmp    .digit.uint
   .digit.uint.B10:
        mov     [.cbase], 10
;       jmp    .digit.uint
   .digit.uint:
        call   .stack.shrink
        lea     rax, [.pchar]
        cinvoke _strtoui64, rsi, rax, [.cbase]  ; get x-based unsigned integer
        cmp     rsi, [.pchar]
        je     .error
        cmp     [.ctype], 0
        jnz    .digit.xfloat
   .digit.xint.push:
    $ifdef _X64
   .digit.xint.push.x64:
       .push    'c¶', 'i', rax, 'x64', 0
        jmp    .digit.out
    $else
   .digit.xint.push.x32:
       .push    'c¶', 'i', eax, 0, 0
        jmp    .digit.out
    $end
   .digit.xfloat:
    $ifdef _X64
        mov     qword [.float], rax
        jmp    .digit.float.push.x64
    $else
        mov     dword [.float], eax
        mov     dword [.float + 4], edx
        jmp    .digit.float.push.x32
    $end
   .digit.TEST:
        cmp     bl, '¶'                         ; token is variable or constant
        je     .error.token                     ; error. invalid token order
   .digit.float:
        mov     [.floas], rsi
        lea     rax, [.pchar]
        ; strtod expects a string of the following form:
        ; [whitespace] [sign] [digits] [.digits] [ {d | D | e | E}[sign]digits]
        cinvoke strtod, rsi, rax
    $ifdef _X64
        movsd   qword [.float], xmm0
    $else
        fstp    qword [.float]
    $end
        mov     rax, [.pchar]
        sub     rax, rsi                        ; rax = double number string length
        mov     [.dnslen], eax                  ; save last double number string length
        test    rax, rax
        jz     .error.token                     ; error. invalid floating point string
        mov     ax, word [.float + 6]
        and     ax, 0x7FF0
        cmp     ax, 0x7FF0
        je     .error.token                     ; error. invalid floating point value
    $ifdef _X64
   .digit.float.push.x64:
       .push    'c¶', 'f', [.float], 'x64', 0
    $else
   .digit.float.push.x32:
       .push    'c¶', 'f', [.float], [.float + 4], 0
    $end
   .digit.out:
        mov     [.ctype], 0
        mov     [.cbase], 0
        lea     rax, [.pchar]
        mov     rsi, [rax]
        jmp    .char.test

   .data.mod.TEST:
       .chisdm  al, ah, .alpha                  ; test character is data modifier first symbol
        jmp    .error

    macro c
    {
   .bra:
        cmp     bl, '·'                         ; bl = token additional data
        je     .bra.accept                      ; token is function with no parameters
        cmp     bl, '¶'                         ; bl = token additional data
        je     .error.token                     ; error. invalid token order
   .bra.accept:
        inc     [.cbra]
   .bra.base:
       .push    '((', 0, 0, 0, 1                ; (
    }

   .bra:
        xor     rdx, rdx                        ; rdx = symbols count
        xor     rcx, rcx                        ; rcx = chars
        mov     cl, al                          ; cl = current char
   .bra.symbol.loop:
       .chissyp cl, .bra.symbol.next            ; test character is function symbol
        test    rdx, rdx
        jnz    .bra.symbol.in
        jmp    .bra.symbol.out
   .bra.symbol.next:
;       cmp     rdx, 5                          ; max symbols count = 5
        cmp     rdx, 3                          ; max symbols count = 3
        je     .bra.symbol.in
        inc     rdx
        mov     ch, cl                          ; ch = previous char
        mov     cl, byte [rsi + rdx]            ; cl = current char
        jmp    .bra.symbol.loop
   .bra.symbol.in:
        cmp     ch, ')'
        jne    .bra.symbol.out
        case    rdx,\
                3, .bra.symbol.x3
        jmp    .bra.symbol.out
   .bra.symbol.x3:
        mov     dl, byte [rsi + 1]
        add     rsi, 2
        case    dl,\
                '=', .bra.symbol.x3.result.get
        jmp    .bra.symbol.x3.out
   .bra.symbol.x3.result.get:
       .pushf   @@result.get, 'f¶', 33, 1       ; (=)
   .bra.symbol.x3.out:
        sub     rsi, 2
;       jmp    .bra.symbol.out
   .bra.symbol.out:
        cmp     bl, '·'                         ; bl = token additional data
        je     .bra.accept                      ; token is function with no parameters
        cmp     bl, '¶'                         ; bl = token additional data
        je     .error.token                     ; error. invalid token order
   .bra.accept:
        inc     [.cbra]
   .bra.base:
       .push    '((', 0, 0, 0, 1                ; (

   .ket:
        dec     [.cbra]
        js     .error.bracket
   .ket.base:
       .push    ')¶', 1, 0, 0, 1                ; )

   .sem:                                        ; ;
        cmp     [.cbra], 0
        jnz    .com
        cmp     [.csbra], 0
        jnz    .com
        cmp     [.ccbra], 0
        jnz    .com
        cmp     [.abs.bra], 0
        jnz    .com
        cmp     [.nabs.bra], 0
        jnz    .com
        jmp    .char.leave                      ; string termination outside the parentheses

   .com:                                        ; ,
        cmp     bl, '¶'                         ; bl = token additional data
        jb     .error.token                     ; error. invalid token order
   .com.base:
       .push    ', ', 2, 0, 0, 1                ; ,

   .colon:                                      ; :
   .colon.nop:
       .pushf   ??nop, '?:', 0, 1
    macro c
    {
   .colon:                                      ; :
       .pushf   ??nop, '?:', 0, 1               ; :a
        cmp     bl, '¶'                         ; token is variable or constant
        je     .colon.postfix                   ; a:
   .colon.prefix:
       .pushf   ??nop, '!:', 0, 1               ; :a
   .colon.postfix:
       .pushf   ??nop, '?:', 0, 1               ; a:
    }

   .number:                                     ; number sign
        cmp     bl, '¶'                         ; token is variable or constant
        je     .number.postfix                  ; a#
   .number.prefix:
       .pushf   ??nop, '!#', 0, 1               ; #a
   .number.postfix:
       .pushf   ??nop, '?#', 0, 1               ; a#

   .dollar:                                     ; dollar sign
   .dollar.nop:
       .pushf   ??nop, '?$', 0, 1               ; $
    macro c
    {
   .dollar:                                     ; dollar sign
        cmp     bl, '¶'                         ; token is variable or constant
        je     .dollar.postfix                  ; a$
   .dollar.prefix:
       .pushf   ??nop, '!$', 0, 1               ; $a
   .dollar.postfix:
       .pushf   ??nop, '?$', 0, 1               ; a$
    }

   .gaccent:                                    ; grave accent
        cmp     bl, '¶'                         ; token is variable or constant
        je     .gaccent.postfix                 ; a`
   .gaccent.prefix:
       .pushf   ??nop, '!`', 0, 1               ; `a
   .gaccent.postfix:
       .pushf   @@covalue, 'f¶', 34, 1          ; a`

    macro c
    {
   .ver:                                        ; vertical line
   .ver.nop:
       .pushf   ??nop, '?|', 0, 1               ; |
    }

    macro c
    {
   .bbar:                                       ; broken bar
   .bbar.nop:
       .pushf   ??nop, '?¦', 0, 1               ; ¦
    }

    macro c
    {
   .bbar:                                       ; ¦
        cmp     bl, 'µ'
        jb     .bbar.prefix                     ; prefix ¦
   .bbar.p.scan:
        mov     al, '¦'
        call   .stack.par.scan
        test    rax, rax
        jz     .bbar.p.out
   .bbar.p.abs?:
        cmp     [rax + sitem64.ItemType - sizeof.sitem64], 0
        jne    .bbar.p.out
   .bbar.p.abs:
        push    rax
        mov     [rax + sitem64.ItemType], '(('  ; ¦ -> (
       .push    ')¶', 1, 0, 0, 0                ; )
        pop     rax
        sub     rax, sizeof.sitem64
        mov     rdx, [??.abs]                   ; ¦???¦ -> abs(???)
        mov     [rax + sitem64.ItemType], 'Fµ'
        mov     [rax + sitem64.ArgCount], 1
        mov     [rax + sitem64.ReType], 1
        mov     [rax + sitem64.Priority], 33
        mov     [rax + sitem64.Param], rdx
        jmp    .char.next
   .bbar.p.out:
        ;
   .bbar.base:
   .bbar.nop:
       .pushf   ??nop, '?¦', 0, 1               ; ¦
   .bbar.prefix:
       .pushn   0                               ; null item
       .pushf   ??nop, '?¦', 0, 1               ; ¦
    }

   .jbb:                                        ; <
   .jbb.base:
       .pushn   0                               ; null item
       .pushf   @@if.b, 'f<', 5, 1              ; <
;  .jbb.nop:
;      .pushf   ??nop, '?<', 0, 1               ; <

   .jaa:                                        ; >
   .jaa.p.in:
        cmp     bl, '¶'
        jb     .jaa.p.out                       ; token is not variable or constant
   .jaa.p.scan:
        mov     al, '<'
        call   .stack.par.scan
        test    rax, rax
        jz     .jaa.p.out
   .jaa.p.round?:
        cmp     [rax + sitem64.ItemType - sizeof.sitem64], 0
        jne    .jaa.p.out
   .jaa.p.round:
        push    rax
        mov     [rax + sitem64.ItemType], '(('  ; < -> (
       .push    ')¶', 1, 0, 0, 0                ; )
        pop     rax
        sub     rax, sizeof.sitem64
        mov     rdx, [??.vround]                ; <???> -> vround(???)
        mov     [rax + sitem64.ItemType], 'Fµ'
        mov     [rax + sitem64.ArgCount], -1
        mov     [rax + sitem64.ReType], 1
        mov     [rax + sitem64.Priority], 33
        mov     [rax + sitem64.Param], rdx
        jmp    .char.next
   .jaa.p.out:
        ;
   .jaa.base:
       .pushf   @@if.a, 'f>', 5, 1              ; >
;  .jaa.nop:
;      .pushf   ??nop, '?>', 0, 1               ; >

   .lsbra:                                      ; [
        inc     [.csbra]
        cmp     bl, '¶'                         ; token is variable or constant
        je     .lsbra.postfix                   ; a[
   .lsbra.nop:
       .pushn   0                               ; null item
       .pushf   ??nop, '?[', 0, 1               ; [
   .lsbra.postfix:
       .pushf   @@farr, 'F ', 29, 0             ; a[ -> a farr matrip[
       .pushf   @@matrip, 'F ', 33, 0
       .pushf   ??nop, 'f[', 0, 1

   .rsbra:                                      ; ]
        dec     [.csbra]
        js     .error.bracket
   .rsbra.p.in:
        cmp     bl, '¶'
        jb     .rsbra.p.out                     ; token is not variable or constant
   .rsbra.p.scan:
        mov     al, '['
        call   .stack.par.scan
        test    rax, rax
        jz     .rsbra.p.out
        ;
        mov     dx, [rax + sitem64.ItemType]
        push    rax
        push    rdx
        mov     [rax + sitem64.ItemType], '(('  ; [ -> (
       .push    ')¶', 1, 0, 0, 0                ; )
        pop     rdx
        pop     rax
        cmp     dx, 'f['
        je     .char.next                       ; a farr matrip[...] -> a farr matrip(...)
   .rsbra.p.int?:
        cmp     [rax + sitem64.ItemType - sizeof.sitem64], 0
        jne    .rsbra.p.out
   .rsbra.p.int:
        sub     rax, sizeof.sitem64
        mov     rdx, [??.vint]                  ; [???] -> vint(???)
        mov     [rax + sitem64.ItemType], 'Fµ'
        mov     [rax + sitem64.ArgCount], -1
        mov     [rax + sitem64.ReType], 1
        mov     [rax + sitem64.Priority], 33
        mov     [rax + sitem64.Param], rdx
        jmp    .char.next
   .rsbra.p.out:
        ;
   .rsbra.nop:
       .pushf   ??nop, '?]', 0, 1               ; ]

   .lcbra:                                      ; {
        inc     [.ccbra]
        cmp     bl, '¶'                         ; token is variable or constant
        je     .lcbra.postfix                   ; a{
   .lcbra.nop:
       .pushn   0                               ; null item
       .pushf   ??nop, '?{', 0, 1               ; {
   .lcbra.postfix:
       .pushf   @@pfarr, 'F ', 29, 0            ; a{ -> a pfarr matrip{
       .pushf   @@matrip, 'F ', 33, 0
       .pushf   ??nop, 'f{', 0, 1

   .rcbra:                                      ; }
        dec     [.ccbra]
        js     .error.bracket
   .rcbra.p.in:
        cmp     bl, '¶'
        jb     .rcbra.p.out                     ; token is not variable or constant
   .rcbra.p.scan:
        mov     al, '{'
        call   .stack.par.scan
        test    rax, rax
        jz     .rcbra.p.out
        ;
        mov     dx, [rax + sitem64.ItemType]
        push    rax
        push    rdx
        mov     [rax + sitem64.ItemType], '(('  ; { -> (
       .push    ')¶', 1, 0, 0, 0                ; )
        pop     rdx
        pop     rax
        cmp     dx, 'f{'
        je     .char.next                       ; a pfarr matrip{...} -> a pfarr matrip(...)
   .rcbra.p.frac?:
        cmp     [rax + sitem64.ItemType - sizeof.sitem64], 0
        jne    .rcbra.p.out
   .rcbra.p.frac:
        sub     rax, sizeof.sitem64
        mov     rdx, [??.vfrac]                 ; {???} -> vfrac(???)
        mov     [rax + sitem64.ItemType], 'Fµ'
        mov     [rax + sitem64.ArgCount], -1
        mov     [rax + sitem64.ReType], 1
        mov     [rax + sitem64.Priority], 33
        mov     [rax + sitem64.Param], rdx
        jmp    .char.next
   .rcbra.p.out:
        ;
   .rcbra.nop:
       .pushf   ??nop, '?}', 0, 1               ; }

   .saquo:
        mov     cl, "›"
        jmp    .str
   .daquo:
        mov     cl, "»"
        jmp    .str
   .squo:
        mov     cl, "’"
        jmp    .str
   .dquo:
        mov     cl, "”"
        jmp    .str
   .apo:
        mov     cl, "'"
        jmp    .str
   .quo:
        mov     cl, '"'
;       jmp    .str
   .str:
        lea     rax, [rsi + 1]                  ; rax = string offset
   .str.scan:
        inc     rsi
        mov     ch, byte [rsi]
        case    ch,\
                cl, .str.leave,\
                 0, .error
        jmp    .str.scan
   .str.leave:
        mov     ch, byte [rsi - 1]
        cmp     ch, '\'
        je     .str.scan                        ; bypass \" \' \” \’ \» \›
   .str.end:
    $ifdef _X64
        mov     r8, rsi                         ; rsi = end of string offset
        sub     r8, rax                         ; r8 = string length
        mov     rdx, rax
        mov     rcx, [sic]
        stdcall costr, rcx, rdx, r8             ; copy string to data segment
    $else
        mov     ecx, esi                        ; esi = end of string offset
        sub     ecx, eax                        ; ecx = string length
        stdcall costr, [sic], eax, ecx          ; copy string to data segment
    $end
        test    rax, rax
        jz     .error.memory
        ;
        push    rsi
        lea     rsi, [rax + rcx]
        call   .str.unescape                    ; replace escape symbols
        pop     rsi
        mov     byte [rdx], 0
        sub     rdx, rax                        ; rdx = string length
        sub     rcx, rdx                        ; rcx = string length delta
        test    rcx, rcx
        jz     .str.push
        push    rsi
        mov     rsi, [sic]
        sub     [rsi + T_sic_data.dsize], ecx
        add     [rsi + T_sic_data.dspace], ecx
        pop     rsi
   .str.push:
       .push.cs rax, edx, 1                     ; push string constant

;      $align
   .alpha:
        cmp     [.cbase], 0
        jg     .digit.uint
   .alpha.hex?:
        cmp     bl, '$'
        jne    .alpha.hex?.out
        mov     [.cbase], 16
        jmp    .digit.uint
   .alpha.hex?.out:
        cmp     byte [.token], 'c'
        jne    .alpha.TEST
        cmp     [.dnslen], 1
        jne    .alpha.TEST                      ; ex.: 00x*** is invalid, must be 0x***
        cmp     [.blanks], 0
        jne    .alpha.TEST                      ; ex.: 0 x*** is invalid, must be 0x***
    $ifdef _SSEX
        movsd   xmm0, qword [.float]
      cvttsd2si rax, xmm0                       ; rax = trunc([.float])
        mov     qword [.cbase], rax             ; [.cbase] = trunc([.float])
    $else
        fld     qword [.float]
        fistp   qword [.cbase]                  ; [.cbase] = trunc([.float])
    $end
        cmp     [.cbase], 0
        jl     .alpha.TEST
   .alpha.base:
        case    byte [rdi],\
                'x', .alpha.xbase,\
                'X', .alpha.xbase,\
                'b', .alpha.bbase,\
                'B', .alpha.bbase,\
                'o', .alpha.obase,\
                'O', .alpha.obase,\
                'i', .alpha.tbase,\
                'I', .alpha.tbase,\
                'n', .alpha.tbase,\
                'N', .alpha.tbase,\
                't', .alpha.tbase,\
                'T', .alpha.tbase,\
                'h', .alpha.hbase,\
                'H', .alpha.hbase
        jmp    .alpha.TEST
   .alpha.xbase:
        cmp     [.cbase], 0
        jg     .char.next
        mov     [.cbase], 16
        jmp    .char.next
   .alpha.bbase:
        cmp     [.cbase], 0
        jne    .alpha.TEST
        mov     [.cbase], 2
        jmp    .char.next
   .alpha.obase:
        cmp     [.cbase], 0
        jne    .alpha.TEST
        mov     [.cbase], 8
        jmp    .char.next
   .alpha.tbase:
        cmp     [.cbase], 0
        jne    .alpha.TEST
        mov     [.cbase], 10
        jmp    .char.next
   .alpha.hbase:
        cmp     [.cbase], 0
        jg     .char.next
        mov     [.ctype], 1
        mov     [.cbase], 16
        jmp    .char.next

   .alpha.TEST:
;       cmp     bl, '¶'                         ; token is variable or constant
;       je     .error.token                     ; error. invalid token order

        mov     [.ctype], 0
        mov     [.cbase], 0
        mov     [.data.mod], bl                 ; bl = token additional data
        cmp     bl, ':'
        je     .alpha.co.data.mod?
        cmp     bl, '#'
        je     .alpha.nu.data.mod?
        cmp     bl, '`'
        je     .alpha.gaccent
   .alpha.!data.mod:
        mov     [.data.mod], 0
        jmp    .alpha.scan
   .alpha.gaccent:                              ; bl = '`' - grave accent
        mov     [.data.mod], 0
        jmp    .alpha.scan
   .alpha.nu.data.mod?:                         ; bl = '#' - number sign
        mov     al, byte [.token]               ; al = item type
        cmp     al, '!'
        jne    .alpha.data.mod
   .alpha.nu.!data.mod:                         ; al = '!' - prefix #
        mov     [.data.mod], 0
        jmp    .alpha.scan
   .alpha.co.data.mod?:                         ; bl = ':' - colon
        mov     al, byte [.token]               ; al = item type
        cmp     al, 'f'
        jne    .alpha.data.mod
   .alpha.co.!data.mod:
        mov     [.data.mod], 0
        jmp    .alpha.scan
   .alpha.data.mod:
        dec     rdi
;       jmp    .alpha.scan
   .alpha.scan:                                 ; scan forward while character
        inc     rsi                             ; is "alphabetic" or numeric
        mov     ah, byte [rsi]
        mov     al, ah
        cmp     [.data.mod], 0
        jz      @F
       .chisan  al, ah, .alpha.scan
;      .chisdm  al, ah, .alpha.scan
        jmp    .alpha.scan.out
    @@:
       .chisan  al, ah, .alpha.scan
   .alpha.scan.out:

        mov     rbx, rsi
        sub     rbx, rdi                        ; rbx = symbol length

        cmp     [.data.mod], '#'
        je     .alpha.TEST.postfix

   .alpha.TEST.x:
        cmp     byte [.token + 1], '#'
        je     .alpha.TEST.global.prefer
        cmp     byte [.token + 1], '`'
        jne    .alpha.TEST.runtime
        cmp     byte [.token + 3], '`'
        jne    .alpha.TEST.runtime.explicit

   .alpha.TEST.local.prefer:                    ; ``x
        call   .stack.shrink
        call   .stack.shrink
        jmp    .alpha.TEST.local                ; test local first

   .alpha.TEST.runtime.explicit:                ; `x
        call   .stack.shrink
       .ruget   [.rdata], rdi, rbx              ; ? runtime object (runtime data segment of sic structure)
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.runtime
   .alpha.TEST.runtime.undef:
        jmp    .alpha.undef

   .alpha.TEST.global.prefer:                   ; #x
        call   .stack.shrink
        jmp    .alpha.TEST.global               ; test global first

   .alpha.TEST.runtime:
       .ruget   [.rdata], rdi, rbx              ; ? runtime object (runtime data segment of sic structure)
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.runtime

   .alpha.TEST.local:
       .coget   [.cdata], rdi, rbx              ; ? local named constant (constant data segment of sic structure)
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.constant
       .vaget   [.vdata], rdi, rbx              ; ? local variable (variable data segment of sic structure)
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.variable
       .fuget   [.fdata], rdi, rbx              ; ? local function (function data segment of sic structure)
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.function
        cmp     byte [.token + 1], '#'
        je     .alpha.undef

   .alpha.TEST.global:
       .coget   [@_CDATA], rdi, rbx             ; ? global named constant
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.constant
       .vaget   [@_VDATA], rdi, rbx             ; ? global variable
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.variable
       .fuget   [@_FDATA], rdi, rbx             ; ? global function
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.function
        cmp     byte [.token + 1], '#'
        je     .alpha.TEST.local                ; test local after global

   .alpha.TEST.postfix?:                        ; ? (...):func (...)#func
        cmp     [.data.mod], 0
        jz     .alpha.undef
   .alpha.TEST.postfix:                         ; (...):func (...)#func
        push    rdi
        inc     rdi
        dec     rbx
        cmp     [.data.mod], '#'
        je     .alpha.TEST.postfix.global
   .alpha.TEST.postfix.local:
       .fuget   [.fdata], rdi, rbx              ; ? local function
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.postfix
        cmp     [.data.mod], '#'
        je     .alpha.TEST.postfix.undef
   .alpha.TEST.postfix.global:
       .fuget   [@_FDATA], rdi, rbx             ; ? global function
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .alpha.postfix
        cmp     [.data.mod], '#'
        je     .alpha.TEST.postfix.local
   .alpha.TEST.postfix.undef:
        pop     rdi
        jmp    .alpha.undef
   .alpha.postfix:
        pop     rdi
        cmp     [rdx + fitem64.acount], 1
        jl     .alpha.undef

   .alpha.function:
   .alpha.function.break?:
        mov     bx, [rdx + fitem64.acount]
        test    bx, bx
        jnz    .alpha.function.break?.out
        mov     bx, [rdx + fitem64.retype]
        test    bx, bx
        jnz    .alpha.function.break?.out
   .alpha.function.break:
        mov     [.break], 1
   .alpha.function.break?.out:

        mov     [.titem], rdx                   ; assign table item offset
        mov     bl, byte [.token + 1]           ; bl = token additional data
        cmp     [.data.mod], 2
        je     .alpha.function.data.mod.main
;       cmp     bl, '¶'                         ; token is variable or constant
;       je     .error.token                     ; error. invalid token order
        cmp     bl, '¶'                         ; token is variable or constant
        jb     .alpha.function.push

        case    rdx ,\
                [??.bor]    , .alpha.function.bor    ,\
                [??.bnor]   , .alpha.function.bnor   ,\
                [??.born]   , .alpha.function.born   ,\
                [??.bnorn]  , .alpha.function.bnorn  ,\
                [??.borc]   , .alpha.function.borc   ,\
                [??.bnorc]  , .alpha.function.bnorc  ,\
                [??.bcor]   , .alpha.function.bcor   ,\
                [??.bcorn]  , .alpha.function.bcorn  ,\
                [??.bxor]   , .alpha.function.bxor   ,\
                [??.bxnor]  , .alpha.function.bxnor  ,\
                [??.band]   , .alpha.function.band   ,\
                [??.bnand]  , .alpha.function.bnand  ,\
                [??.bandn]  , .alpha.function.bandn  ,\
                [??.bnandn] , .alpha.function.bnandn ,\
                [??.breset] , .alpha.function.breset ,\
                [??.bset]   , .alpha.function.bset
        case    rdx ,\
                [??.shr]    , .alpha.function.shr    ,\
                [??.shl]    , .alpha.function.shl    ,\
                [??.sar]    , .alpha.function.sar    ,\
                [??.sal]    , .alpha.function.sal    ,\
                [??.ror]    , .alpha.function.ror    ,\
                [??.rol]    , .alpha.function.rol
        case    rdx ,\
                [??.bt]     , .alpha.function.bt     ,\
                [??.btc]    , .alpha.function.btc    ,\
                [??.btr]    , .alpha.function.btr    ,\
                [??.bts]    , .alpha.function.bts
        case    rdx ,\
                [??.or]     , .alpha.function.or     ,\
                [??.nor]    , .alpha.function.nor    ,\
                [??.xor]    , .alpha.function.xor    ,\
                [??.xnor]   , .alpha.function.xnor   ,\
                [??.and]    , .alpha.function.and    ,\
                [??.nand]   , .alpha.function.nand
        case    rdx ,\
                [??.add]    , .alpha.function.add    ,\
                [??.sub]    , .alpha.function.sub    ,\
                [??.subr]   , .alpha.function.subr   ,\
                [??.mul]    , .alpha.function.mul    ,\
                [??.div]    , .alpha.function.div    ,\
                [??.divr]   , .alpha.function.divr   ,\
                [??.quo]    , .alpha.function.quo    ,\
                [??.quor]   , .alpha.function.quor   ,\
                [??.mod]    , .alpha.function.mod    ,\
                [??.modr]   , .alpha.function.modr
        case    rdx ,\
                [??.absolute] , .alpha.function.absolute
        jmp    .error.token                     ; error. invalid token order
   .alpha.function.bor:
       .pushf   @@bor, 'F ', 18, 0              ; bor
        jmp    .char.test
   .alpha.function.bnor:
       .pushf   @@bnor, 'F ', 18, 0             ; bnor
        jmp    .char.test
   .alpha.function.born:
       .pushf   @@born, 'F ', 18, 0             ; born
        jmp    .char.test
   .alpha.function.bnorn:
       .pushf   @@bnorn, 'F ', 18, 0            ; bnorn
        jmp    .char.test
   .alpha.function.borc:
       .pushf   @@borc, 'F ', 19, 0             ; borc
        jmp    .char.test
   .alpha.function.bnorc:
       .pushf   @@bnorc, 'F ', 19, 0            ; bnorc
        jmp    .char.test
   .alpha.function.bcor:
       .pushf   @@bcor, 'F ', 19, 0             ; bcor
        jmp    .char.test
   .alpha.function.bcorn:
       .pushf   @@bcorn, 'F ', 19, 0            ; bcorn
        jmp    .char.test
   .alpha.function.bxor:
       .pushf   @@bxor, 'F ', 17, 0             ; bxor
        jmp    .char.test
   .alpha.function.bxnor:
       .pushf   @@bxnor, 'F ', 17, 0            ; bxnor
        jmp    .char.test
   .alpha.function.band:
       .pushf   @@band, 'F ', 20, 0             ; band
        jmp    .char.test
   .alpha.function.bnand:
       .pushf   @@bnand, 'F ', 20, 0            ; bnand
        jmp    .char.test
   .alpha.function.bandn:
       .pushf   @@bandn, 'F ', 20, 0            ; bandn
        jmp    .char.test
   .alpha.function.bnandn:
       .pushf   @@bnandn, 'F ', 20, 0           ; bnandn
        jmp    .char.test
   .alpha.function.breset:
       .pushf   @@breset, 'F ', 21, 0           ; breset
        jmp    .char.test
   .alpha.function.bset:
       .pushf   @@bset, 'F ', 21, 0             ; bset
        jmp    .char.test
        ;
   .alpha.function.shr:
       .pushf   @@shr, 'F ', 22, 0              ; shr
        jmp    .char.test
   .alpha.function.shl:
       .pushf   @@shl, 'F ', 22, 0              ; shl
        jmp    .char.test
   .alpha.function.sar:
       .pushf   @@sar, 'F ', 22, 0              ; sar
        jmp    .char.test
   .alpha.function.sal:
       .pushf   @@sal, 'F ', 22, 0              ; sal
        jmp    .char.test
   .alpha.function.ror:
       .pushf   @@ror, 'F ', 22, 0              ; ror
        jmp    .char.test
   .alpha.function.rol:
       .pushf   @@rol, 'F ', 22, 0              ; rol
        jmp    .char.test
        ;
   .alpha.function.bt:
       .pushf   @@bt, 'F ', 23, 0               ; bt
        jmp    .char.test
   .alpha.function.btc:
       .pushf   @@btc, 'F ', 23, 0              ; btc
        jmp    .char.test
   .alpha.function.btr:
       .pushf   @@btr, 'F ', 23, 0              ; btr
        jmp    .char.test
   .alpha.function.bts:
       .pushf   @@bts, 'F ', 23, 0              ; bts
        jmp    .char.test
        ;
   .alpha.function.or:
       .pushf   @@or, 'F ', 6, 0                ; or
        jmp    .char.test
   .alpha.function.nor:
       .pushf   @@nor, 'F ', 7, 0               ; nor
        jmp    .char.test
   .alpha.function.xor:
       .pushf   @@xor, 'F ', 6, 0               ; xor
        jmp    .char.test
   .alpha.function.xnor:
       .pushf   @@xnor, 'F ', 7, 0              ; xnor
        jmp    .char.test
   .alpha.function.and:
       .pushf   @@and, 'F ', 7, 0               ; and
        jmp    .char.test
   .alpha.function.nand:
       .pushf   @@nand, 'F ', 6, 0              ; nand
        jmp    .char.test
        ;
   .alpha.function.add:
       .pushf   @@add, 'F ', 8, 0               ; add
        jmp    .char.test
   .alpha.function.sub:
       .pushf   @@sub, 'F ', 8, 0               ; sub
        jmp    .char.test
   .alpha.function.subr:
       .pushf   @@subr, 'F ', 12, 0             ; subr
        jmp    .char.test
   .alpha.function.mul:
       .pushf   @@mul, 'F ', 9, 0               ; mul
        jmp    .char.test
   .alpha.function.div:
       .pushf   @@div, 'F ', 9, 0               ; div
        jmp    .char.test
   .alpha.function.divr:
       .pushf   @@divr, 'F ', 12, 0             ; divr
        jmp    .char.test
   .alpha.function.quo:
       .pushf   @@quo, 'F ', 10, 0              ; quo
        jmp    .char.test
   .alpha.function.quor:
       .pushf   @@quor, 'F ', 12, 0             ; quor
        jmp    .char.test
   .alpha.function.mod:
       .pushf   @@mod, 'F ', 11, 0              ; mod
        jmp    .char.test
   .alpha.function.modr:
       .pushf   @@modr, 'F ', 12, 0             ; modr
        jmp    .char.test
   .alpha.function.absolute:
        cmp     [.var.declare], 0
        jz     .error.token
       .pushf   @@absolute, 'A ', 33, 0         ; absolute
        jmp    .char.test

   .alpha.function.push:
        cmp     [.data.mod], 0
        jnz    .alpha.function.data.mod
        case    rdx ,\
                [??.absolute] , .alpha.absolute   ,\
                [??.tcarg]    , .alpha.tcarg
        case    rdx ,\
                [??.varg.z]   , .alpha.arg.filter ,\
                [??.varg.nz]  , .alpha.arg.filter ,\
                [??.varg.az]  , .alpha.arg.filter ,\
                [??.varg.aez] , .alpha.arg.filter ,\
                [??.varg.bz]  , .alpha.arg.filter ,\
                [??.varg.bez] , .alpha.arg.filter ,\
                [??.varg.e]   , .alpha.arg.filter ,\
                [??.varg.ne]  , .alpha.arg.filter ,\
                [??.varg.a]   , .alpha.arg.filter ,\
                [??.varg.ae]  , .alpha.arg.filter ,\
                [??.varg.b]   , .alpha.arg.filter ,\
                [??.varg.be]  , .alpha.arg.filter
; ------
    $ifdef _X64
        cmp     word [rdx + fitem64.acount], 0  ; ?function argument count = 0
        jz     .alpha.function.push.x64.acount.z
   .alpha.function.push.x64:
       .push    'Fµ', 33, rdx, 'x64', 0
        jmp    .char.test
   .alpha.function.push.x64.acount.z:           ; function argument count = 0
       .push    'F·', 33, rdx, 'x64', 0
        jmp    .char.test
    $else
        cmp     word [edx + fitem32.acount], 0  ; ?function argument count = 0
        jz     .alpha.function.push.x32.acount.z
   .alpha.function.push.x32:
       .push    'Fµ', 33, edx, 0, 0
        jmp    .char.test
   .alpha.function.push.x32.acount.z:           ; function argument count = 0
       .push    'F·', 33, edx, 0, 0
        jmp    .char.test
    $end
; ------
   .alpha.function.data.mod:                    ; function is data modifier (:int, ...)
        call   .stack.shrink
        case    rdx ,\
                [??.absolute] , .alpha.absolute ,\
                [??.tcarg]    , .error.token
;               [??.tcarg]    , .alpha.tcarg
   .alpha.function.data.mod.main:
        mov     bl, byte [.token + 1]
        cmp     bl, '·'
        je     .alpha.function.data.mod.main.x
    $ifdef _X64
       .push    'F¶', 34, rdx, 'x64', 0
        jmp    .char.test
    $else
       .push    'F¶', 34, edx, 0, 0
        jmp    .char.test
    $end
   .alpha.function.data.mod.main.x:
    $ifdef _X64
       .push    'F¶', 33, rdx, 'x64', 0
        jmp    .char.test
    $else
       .push    'F¶', 33, edx, 0, 0
        jmp    .char.test
    $end
; ------
   .alpha.absolute:                             ; absolute
        cmp     [.var.declare], 0
        jz     .error.token
   .alpha.arg.filter:                           ; function is argument filter
    $ifdef _X64
   .alpha.arg.filter.push.x64:
       .push    'Aµ', 33, rdx, 'x64', 0
        jmp    .char.test
    $else
   .alpha.arg.filter.push.x32:
       .push    'Aµ', 33, edx, 0, 0
        jmp    .char.test
    $end
; ------
   .alpha.tcarg:
    $ifdef _X64
       .pushf   @@addr, 'Fµ', 42, 0             ; &x
        jmp    .char.test
    $else
        jmp    .char.test
    $end
; ------

   .alpha.constant:
        mov     [.titem], rdx                   ; assign table item offset
        mov     bl, byte [.token + 1]           ; bl = token additional data
        cmp     bl, '¶'                         ; token is variable or constant
        je     .error.token                     ; error. invalid token order

        movzx   rcx, [rdx + citem64.cotype]     ; rcx = constant type
        test    rcx, rcx
        jnz     @F
        mov     cx, 'r¶'                        ; rcx = default constant type
    @@:
        movzx   rax, [rdx + citem64.datype]     ; rax = constant data type
        lea     rdx, [rdx + citem64.value]
        case    al,\
                'f', .alpha.constant.f,\
                'i', .alpha.constant.i,\
                's', .alpha.constant.s
;               'p', .alpha.constant.p
;               'o', .alpha.constant.o
    $ifdef _X64
   .alpha.constant.x.x64:
       .push    ecx, eax, rdx, 'x64', 0
        jmp    .char.test
    $else
   .alpha.constant.x.x32:
       .push    ecx, eax, edx, 0, 0
        jmp    .char.test
    $end
    ;
   .alpha.constant.f:
    $ifdef _X64
   .alpha.constant.f.x64:
       .push    'c¶', 'f', [rdx], 'x64', 0
        jmp    .char.test
    $else
   .alpha.constant.f.x32:
        mov     ecx, [edx + 4]
       .push    'c¶', 'f', [edx], ecx, 0
        jmp    .char.test
    $end
    ;
   .alpha.constant.i:
    $ifdef _X64
   .alpha.constant.i.x64:
       .push    'c¶', 'i', [rdx], 'x64', 0
        jmp    .char.test
    $else
   .alpha.constant.i.x32:
       .push    'c¶', 'i', [edx], 0, 0
        jmp    .char.test
    $end
    ;
   .alpha.constant.s:
    $ifdef _X64
   .alpha.constant.s.x64:
       .push    'c¶', 's', [rdx], 'x64', 0
        jmp    .char.test
    $else
   .alpha.constant.s.x32:
       .push    'c¶', 's', [edx], 0, 0
        jmp    .char.test
    $end
    ;
    macro c
    {
   .alpha.constant.p:
    $ifdef _X64
   .alpha.constant.p.x64:
       .push    'c¶', 'p', [rdx], 'x64', 0
        jmp    .char.test
    $else
   .alpha.constant.p.x32:
       .push    'c¶', 'p', [edx], 0, 0
        jmp    .char.test
    $end
    }
    ;
    macro c
    {
   .alpha.constant.o:
    $ifdef _X64
   .alpha.constant.o.x64:
       .push    'c¶', 'o', [rdx], 'x64', 0
        jmp    .char.test
    $else
   .alpha.constant.o.x32:
       .push    'c¶', 'o', [edx], 0, 0
        jmp    .char.test
    $end
    }

   .alpha.variable:
        mov     [.titem], rdx                   ; assign table item offset
        mov     bl, byte [.token + 1]           ; bl = token additional data
        cmp     bl, '¶'                         ; token is variable or constant
        je     .error.token                     ; error. invalid token order

        movzx   rax, [rdx + vitem64.datype]     ; rax = variable data type
        case    al,\
                'o', .alpha.variable.o
        lea     rdx, [rdx + vitem64.offset]
;       mov     rdx, [rdx + vitem64.offset]
    $ifdef _X64
   .alpha.variable.x64:
       .push    'v¶', eax, rdx, 'x64', 0
        jmp    .char.test
    $else
   .alpha.variable.x32:
       .push    'v¶', eax, edx, 0, 0
        jmp    .char.test
    $end
    ;
   .alpha.variable.o:
        mov     rdx, [rdx + vitem64.offset]
    $ifdef _X64
   .alpha.variable.o.x64:
       .push    'v¶', eax, rdx, 'x64', 0
        jmp    .char.test
    $else
   .alpha.variable.o.x32:
       .push    'v¶', eax, edx, 0, 0
        jmp    .char.test
    $end

   .alpha.runtime:
        mov     [.titem], rdx                   ; assign table item offset
        mov     bl, byte [.token + 1]           ; bl = token additional data
        cmp     bl, '¶'                         ; token is variable or constant
        je     .error.token                     ; error. invalid token order

        movzx   rcx, [rdx + citem64.cotype]     ; rcx = constant type
        test    rcx, rcx
        jnz     @F
        mov     cx, 'r¶'                        ; rcx = default constant type
    @@:
        movzx   rax, [rdx + citem64.datype]     ; rax = constant data type
        lea     rdx, [rdx + citem64.value]
    $ifdef _X64
   .alpha.runtime.x64:
       .push    ecx, eax, rdx, 'x64', 0
        jmp    .char.test
    $else
   .alpha.runtime.x32:
       .push    ecx, eax, edx, 0, 0
        jmp    .char.test
    $end

   .alpha.undef:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jz     .error.token
   .alpha.undef.main:
        mov     bl, byte [.token + 1]           ; bl = token additional data
        cmp     bl, '¶'                         ; token is variable or constant
        je     .error.token                     ; error. invalid token order
        ;
        mov     bl, byte [rsi]
        mov     byte [rsi], 0
        xor     rax, rax
        mov     al, '?'
        ;
        cmp     [.var.declare], 0
        jz     .alpha.undef.arun
        cmp     [.var.declare], 2
        je     .alpha.undef.set
   .alpha.undef.test.var:
        mov     rdx, [.vito]                    ; rdx = var function stack item offset
        test    rdx, rdx
        jz     .alpha.undef.arun
        ;
        cmp     [.var.double], 1
        je     .alpha.undef.test.double
        cmp     [.var.complex], 1
        je     .alpha.undef.test.complex
        cmp     [.var.integer], 1
        je     .alpha.undef.test.integer
        cmp     [.var.string], 1
        je     .alpha.undef.test.string
        jmp    .alpha.undef.arun
   .alpha.undef.test.string:
        mov     [.var.string], 2
        mov     rcx, [??.var.string]
        jmp    .alpha.undef.test.leave
   .alpha.undef.test.integer:
        mov     [.var.integer], 2
        mov     rcx, [??.var.integer]
        jmp    .alpha.undef.test.leave
   .alpha.undef.test.complex:
        mov     [.var.complex], 2
        mov     rcx, [??.var.complex]
        jmp    .alpha.undef.test.leave
   .alpha.undef.test.double:
        mov     [.var.double], 2
        mov     rcx, [??.var.double]
;       jmp    .alpha.undef.test.leave
   .alpha.undef.test.leave:
        mov     [.var.declare], 2
        or      [.rcode], RCODE_FLAG_DECLARE    ; variable declaration flag
        ;
        mov     [rdx + sitem64.ItemType], 'Fµ'
        mov     [rdx + sitem64.ArgCount], -1
        mov     [rdx + sitem64.ReType], 0
        mov     [rdx + sitem64.Priority], 0
        mov     [rdx + sitem64.Param], rcx
        ;
   .alpha.undef.set:
        cmp     [.var.double], 2
        je     .alpha.undef.set.double
        cmp     [.var.complex], 2
        je     .alpha.undef.set.complex
        cmp     [.var.integer], 2
        je     .alpha.undef.set.integer
        cmp     [.var.string], 2
        je     .alpha.undef.set.string
        jmp    .alpha.undef.arun
   .alpha.undef.set.string:
        mov     ax, 's1'
        jmp    .alpha.undef.arun
   .alpha.undef.set.integer:
        mov     ax, 'i1'
        jmp    .alpha.undef.arun
   .alpha.undef.set.complex:
        mov     ax, 'f2'
        jmp    .alpha.undef.arun
   .alpha.undef.set.double:
        mov     ax, 'f1'
;       jmp    .alpha.undef.arun
        ;
   .alpha.undef.arun:
    $ifdef _X64
        xor     r9, r9                          ; no data alignment
   .alpha.undef.arun.dalign?:
        test    [sop], SIC_OPT_FLAG_DALIGN
        jz     .alpha.undef.arun.perform
        mov     r9d, [.dalign]                  ; data alignment
   .alpha.undef.arun.perform:
        stdcall arun, [sic], rdi, rax, r9       ; add runtime undefined constant
    $else
        xor     ecx, ecx                        ; no data alignment
   .alpha.undef.arun.dalign?:
        test    [sop], SIC_OPT_FLAG_DALIGN
        jz     .alpha.undef.arun.perform
        mov     ecx, [.dalign]                  ; data alignment
   .alpha.undef.arun.perform:
        stdcall arun, [sic], edi, eax, ecx      ; add runtime undefined constant
    $end
        mov     [.titem], rax                   ; assign table item offset
        mov     byte [rsi], bl                  ; rax = table item offset
        test    rax, rax
        jz     .error
        ;
        inc     [.rcount]                       ; increase runtimes count
        xor     rcx, rcx
        mov     cx, 'r¶'
        mov     [rax + citem64.cotype], cx      ; assign table item constant type
        lea     rdx, [rax + citem64.value]      ; rdx = constant value offset
        movzx   rax, [rax + citem64.datype]     ; rax = constant data type
    $ifdef _X64
   .alpha.undef.x64:
       .push    ecx, eax, rdx, 'x64', 0
        jmp    .char.test
    $else
   .alpha.undef.x32:
       .push    ecx, eax, edx, 0, 0
        jmp    .char.test
    $end

; replace escape symbols
; !!! don't change <rax, rsi> registers
;
; \r -> 13
; \n -> 10
; \t -> 09
; ...
; -> rax = string offset
; -> rsi = end of string buffer offset
; <- rdx = end of unescaped string offset
$sproc .str.unescape

        push    rax rbx rcx

    $ifdef _X64
   .str.unescape.stack.align:
        mov     [.RSP.AL], 0
        test    rsp, 0x0F
        jz      @F
        push    rax
        inc     [.RSP.AL]
    @@:
    $end

        mov     rdx, rsi
        lea     rcx, [rax - 1]
   .str.unescape.scan:
        inc     rcx
        cmp     rcx, rdx
        je     .str.unescap.return
   .str.unescape.test:
        mov     al, byte [rcx]
        cmp     al, '\'
        jne    .str.unescape.scan
        inc     rcx
        cmp     rcx, rdx
        je     .str.unescap.return
        movzx   rax, byte [rcx]
        case    al,\
                'x', .str.unescape.h1,\         ; \x?? EQU 0x??
                'X', .str.unescape.h1,\         ; \X?? EQU 0x??
                'u', .str.unescape.u1,\         ; \u???? EQU 0x??
                'U', .str.unescape.u1,\         ; \U???? EQU 0x??
                'c', .str.unescape.c1           ; \c# EQU CTRL+#

   .str.unescape.e1:
        call   .str.E2B
        jz     .str.unescape.o1?
   .str.unescape.e:
        mov     byte [rcx - 1], al
        jmp    .str.unescape.1.shift            ; \? -> ?

   .str.unescape.o1?:                           ; ? first symbol is oct digit
        dec     rcx
        call   .str.O2B
        jz     .str.unescape.m1.shift           ; \* -> *
        mov     byte [.escape], al
   .str.unescape.o2?:                           ; ? second symbol is oct digit
        call   .str.O2B
        jnz    .str.unescape.o2
   .str.unescape.o1:                            ; \* -> ?
        mov     al, byte [.escape]
        test    al, al
        jnz    .str.unescape.m2.shift
   .str.unescape.o1.0:                          ; \0 -> 0
        mov     byte [rcx - 2], al
        dec     rcx
        mov     rax, -1                         ; rax = shift value
        jmp    .str.unescape.shift
   .str.unescape.o2:                            ; \** -> **
        shl     [.escape], 3
        or      byte [.escape], al
   .str.unescape.o3?:                           ; ? third symbol is oct digit
        call   .str.O2B
        jz     .str.unescape.o3.noct
        shl     [.escape], 3
        or      ax, word [.escape]
        cmp     ax, 0xFF
        ja     .str.unescape.o3.noct.o2
   .str.unescape.ooo:
        mov     byte [rcx - 3], al
   .str.unescape.ooo.shift:                     ; \??? -> ?
        mov     rax, -3                         ; rax = shift value
        jmp    .str.unescape.shift
   .str.unescape.o3.noct.o2:
        shr     [.escape], 3
   .str.unescape.o3.noct:
        mov     al, byte [.escape]
        mov     byte [rcx - 3], al
   .str.unescape.oo.shift:                      ; \??* -> ?*
        dec     rcx
        mov     rax, -2                         ; rax = shift value
        jmp    .str.unescape.shift

   .str.unescape.h1:                            ; ? first symbol is hex digit
        call   .str.H2B
        jz     .str.unescape.m2.shift           ; \x* -> x*
        mov     byte [.escape], al
   .str.unescape.h2:                            ; ? second symbol is hex digit
        call   .str.H2B
        jz     .str.unescape.m3.shift           ; \x?* -> x?*
        shl     [.escape], 4
        or      al, byte [.escape]
   .str.unescape.hh:
        mov     byte [rcx - 3], al
   .str.unescape.hh.shift:                      ; \x?? -> ?
        mov     rax, -3                         ; rax = shift value
        jmp    .str.unescape.shift

   .str.unescape.u1:                            ; ? first symbol is hex digit
        call   .str.H2B
        jz     .str.unescape.m2.shift           ; \u* -> u*
        mov     byte [.escape], al
   .str.unescape.u2:                            ; ? second symbol is hex digit
        call   .str.H2B
        jz     .str.unescape.m3.shift           ; \u?* -> u?*
        shl     [.escape], 4
        or      byte [.escape], al
   .str.unescape.u3:                            ; ? third symbol is hex digit
        call   .str.H2B
        jz     .str.unescape.m4.shift           ; \u??* -> u??*
        shl     [.escape], 4
        or      byte [.escape], al
   .str.unescape.u4:                            ; ? fourth symbol is hex digit
        call   .str.H2B
        jz     .str.unescape.m5.shift           ; \u???* -> u???*
        shl     [.escape], 4
        or      byte [.escape], al
   .str.unescape.u2a:                           ; unicode to ansi
        push    rcx
        push    rdx
        lea     rcx, [.cbuff]
        movzx   rdx, word [.escape]
        cinvoke wctomb, rcx, rdx
        pop     rdx
        pop     rcx
   .str.unescape.u2a.result:                    ; ? \u???? is valid ansi char
        cmp     eax, 1
        jne    .str.unescape.m5.shift           ; \u???? -> u????
   .str.unescape.uuuu:
        mov     al, byte [.cbuff]
        mov     byte [rcx - 5], al
   .str.unescape.uuuu.shift:                    ; \u???? -> ?
        mov     rax, -5                         ; rax = shift value
        jmp    .str.unescape.shift

   .str.unescape.c1:                            ; \c# : # in ('?', '@', 'A', ..., 'Z', '[', '\', ']', '_')
        inc     rcx                             ; \cC = CTRL+C = 0x03
        cmp     rcx, rdx                        ; \cZ = CTRL+Z = 0x1A
        je     .str.unescape.m2.shift           ; \c* -> c*
        mov     al, byte [rcx]
        cmp     al, '?'
        je     .str.unescape.c.DEL
        sub     al, '@'
        cmp     al, '_'-'@'
        ja     .str.unescape.m2.shift           ; \c* -> c*
   .str.unescape.c:
        mov     byte [rcx - 2], al
   .str.unescape.c.shift:
        mov     rax, -2                         ; rax = shift value
        jmp    .str.unescape.shift
   .str.unescape.c.DEL:
        mov     byte [rcx - 2], 0x7F
        mov     rax, -2                         ; rax = shift value
        jmp    .str.unescape.shift

   .str.unescape.m5.shift:
        dec     rcx
   .str.unescape.m4.shift:
        dec     rcx
   .str.unescape.m3.shift:
        dec     rcx
   .str.unescape.m2.shift:
        dec     rcx
   .str.unescape.m1.shift:
        dec     rcx
   .str.unescape.1.shift:
        mov     rax, -1                         ; rax = shift value
;       jmp    .str.unescape.shift

   .str.unescape.shift:                         ; shift chars left ; rax = shift value (negative)
        push    rcx                             ; a,a,a,\,\,b,b,b,c,c,[Z] -> a,a,a,\,b,b,b,c,c,[Z],[Z] ; rax = -1
   .str.unescape.shift.loop.enter:              ; a,a,a,\,x,3,0,b,c,d,[Z] -> a,a,a,0,b,c,d,[Z],c,d,[Z] ; rax = -3
        inc     rcx                             ; [Z] - terminating zero
        cmp     rcx, rdx
        ja     .str.unescape.shift.loop.leave
        mov     bl, byte [rcx]
        mov     byte [rcx + rax], bl            ; rax = shift value
        jmp    .str.unescape.shift.loop.enter
   .str.unescape.shift.loop.leave:
        pop     rcx
        add     rcx, rax
        add     rdx, rax
;       mov     byte [rdx], 0
   .str.unescape.shift.leave:
        jmp    .str.unescape.scan

   .str.unescap.return:
    $ifdef _X64
   .str.unescape.stack.restore:
        cmp     [.RSP.AL], 0
        jz      @F
        pop     rax
    @@:
    $end
        pop     rcx rbx rax
        retn
$endp

; escape char to 8-bit bin
; -> rax = escape char ('\', 'a', 'b', 'e', 'f', 'n', 'r', 't', 'v')
$sproc .str.E2B

        sub     al, '\'
        cmp     al, 'v'-'\'
        ja     .str.E2B.error
    $ifdef _X64
        push    rdx
        mov     rdx, @_E2B
        mov     al, [rdx + rax]
        pop     rdx
    $else
        mov     al, [@_E2B + eax]
    $end

   .str.E2B.return:
        cmp     al, -1
        retn

   .str.E2B.error:
        mov     al, -1
        cmp     al, -1
        retn
$endp

; oct digit char to 3-bit bin
; -> [rcx+1] = oct digit char ('0'..'7')
$sproc .str.O2B

        inc     rcx
        cmp     rcx, rdx
        je     .str.O2B.error

        movzx   rax, byte [rcx]
        sub     al, '0'
        cmp     al, '7'-'0'
        ja     .str.O2B.error
    $ifdef _X64
        push    rdx
        mov     rdx, @_O2B
        mov     al, [rdx + rax]
        pop     rdx
    $else
        mov     al, [@_O2B + eax]
    $end

   .str.O2B.return:
        cmp     al, -1
        retn

   .str.O2B.error:
        mov     al, -1
        cmp     al, -1
        retn
$endp

; hex digit char to 4-bit bin
; -> [rcx+1] = hex digit char ('0'..'9', 'A'..'F', 'a'..'f')
$sproc .str.H2B

        inc     rcx
        cmp     rcx, rdx
        je     .str.H2B.error

        movzx   rax, byte [rcx]
        sub     al, '0'
        cmp     al, 'f'-'0'
        ja     .str.H2B.error
    $ifdef _X64
        push    rdx
        mov     rdx, @_H2B
        mov     al, [rdx + rax]
        pop     rdx
    $else
        mov     al, [@_H2B + eax]
    $end

   .str.H2B.return:
        cmp     al, -1
        retn

   .str.H2B.error:
        mov     al, -1
        cmp     al, -1
        retn
$endp

; get function table item offset
; -> [.fun] : function name
; -> [.nas] : name size
; <- rdx    : function item offset
$sproc .pushf.get

        stdcall taget, [.fdata], [.fun], [.nas] ; ? local function
        test    rdx, rdx                        ; rdx = table item offset value
        jnz    .pushf.get.return
        stdcall taget,[@_FDATA], [.fun], [.nas] ; ? global function
                                                ; rdx = table item offset value
   .pushf.get.return:
        retn
$endp

; shift token data left
; !!! don't change rdx
$sproc .token.shl

    $ifdef _X64
        shl     [.token], 16
    $else
        mov     cx, word [.token + 4]           ; WORD #4      = WORD #3
        mov     word [.token + 6], cx           ; [.token + 6] = [.token + 4]
        mov     cx, word [.token + 2]           ; WORD #3      = WORD #2
        mov     word [.token + 4], cx           ; [.token + 4] = [.token + 2]
        mov     cx, word [.token + 0]           ; WORD #2      = WORD #1
        mov     word [.token + 2], cx           ; [.token + 2] = [.token + 0]
    $end
        retn
$endp

; shift token data right
; !!! don't change rdx
$sproc .token.shr

    $ifdef _X64
        shr     [.token], 16
    $else
        mov     cx, word [.token + 2]           ; WORD #1      = WORD #2
        mov     word [.token + 0], cx           ; [.token + 0] = [.token + 2]
        mov     cx, word [.token + 4]           ; WORD #2      = WORD #3
        mov     word [.token + 2], cx           ; [.token + 2] = [.token + 4]
        mov     cx, word [.token + 6]           ; WORD #3      = WORD #4
        mov     word [.token + 4], cx           ; [.token + 4] = [.token + 6]
        xor     ecx, ecx                        ; WORD #4      = 0
        mov     word [.token + 6], cx           ; [.token + 6] = 0
    $end
        retn
$endp

; shrink stack ("delete" last stack item)
; !!! don't change rdx
$sproc .stack.shrink

        cmp     [.stack.ic], 0
        jle    .stack.shrink.return

        sub     [.sito], sizeof.sitem64         ; "delete" last stack item
        dec     [.stack.ic]                     ; decrease stack item count
        dec     [.tokens]                       ; dec scanned tokens count

        call   .token.shr
   .stack.shrink.return:
        retn
$endp

; add item to stack
; -> [.sito]  : current stack item offset
; -> [.idata] : item data
; -> [.datas] : data size
; -> [.param] : parameter
; -> [.titem] : table item offset
; -> ax       : operation priority or data type
; <- rcx      : 0 on error
; <- [.token] : [.idata]
$sproc .stack.add

        mov     edx, [.stack.ic]                ; edx = stack item count
        cmp     edx, [@_CFG.stack_count]
        jae    .sa.error.memory

        call   .token.shl

        mov     cx, word [.idata]
        mov     word [.token], cx

        movzx   rbx, cx                         ; rbx = item type

        test    edx, edx
        jnz    .sa.enter

   .sa.0:
        cmp     cl, 'F'
        je     .sa.f.alpha
        jmp    .sa.main
   .sa.f.alpha:
        mov     rcx, [.param]
        test    rcx, rcx
        jz     .sa.main
   .sa.f.alpha.offset:
        mov     rcx, [rcx + fitem64.offset]
        test    rcx, rcx
        jz     .sa.error.token                  ; error. null function offset
        pcase   rcx,\
                @@var             , .sa.var.double,\
                @@float           , .sa.var.double,\
                @@double          , .sa.var.double,\
                @@cvar            , .sa.var.complex,\
                @@complex         , .sa.var.complex,\
                @@int             , .sa.var.int,\
                @@integer         , .sa.var.integer,\
                @@str             , .sa.var.string,\
                @@string          , .sa.var.string
        pcase   rcx,\
                @@assign          , .sa.var.assign,\
                @@reassign        , .sa.var.assign
        pcase   rcx,\
                @@if.true         , .sa.fun.if.bool,\
                @@if.false        , .sa.fun.if.bool
        pcase   rcx,\
                @@ie.true         , .sa.fun.ie.bool,\
                @@ie.false        , .sa.fun.ie.bool
        pcase   rcx,\
                @@return          , .sa.fun.exit,\
                @@return.if.true  , .sa.fun.exit.bool,\
                @@return.if.false , .sa.fun.exit.bool,\
                @@exit            , .sa.fun.exit,\
                @@exit.if.true    , .sa.fun.exit.bool,\
                @@exit.if.false   , .sa.fun.exit.bool
        pcase   rcx,\
                @@goto            , .sa.fun.jump,\
                @@xgoto           , .sa.fun.jump,\
                @@rxgoto          , .sa.fun.jump,\
                @@goto.if.x32     , .sa.fun.jump,\
                @@goto.if.n32     , .sa.fun.jump,\
                @@goto.if.x64     , .sa.fun.jump,\
                @@goto.if.n64     , .sa.fun.jump,\
                @@goto.if.true    , .sa.fun.jump.bool,\
                @@goto.if.false   , .sa.fun.jump.bool,\
                @@goto.if.z       , .sa.fun.jump,\
                @@goto.if.nz      , .sa.fun.jump,\
                @@goto.if.az      , .sa.fun.jump,\
                @@goto.if.aez     , .sa.fun.jump,\
                @@goto.if.bz      , .sa.fun.jump,\
                @@goto.if.bez     , .sa.fun.jump,\
                @@goto.if.or      , .sa.fun.jump,\
                @@goto.if.nor     , .sa.fun.jump,\
                @@goto.if.and     , .sa.fun.jump,\
                @@goto.if.nand    , .sa.fun.jump
        pcase   rcx,\
                @@call            , .sa.fun.jump,\
                @@calls           , .sa.fun.jump,\
                @@rcalls          , .sa.fun.jump,\
                @@xcall           , .sa.fun.jump,\
                @@rxcall          , .sa.fun.jump,\
                @@call.if.x32     , .sa.fun.jump,\
                @@call.if.n32     , .sa.fun.jump,\
                @@call.if.x64     , .sa.fun.jump,\
                @@call.if.n64     , .sa.fun.jump,\
                @@call.ie.x32     , .sa.fun.jump,\
                @@call.ie.n32     , .sa.fun.jump,\
                @@call.ie.x64     , .sa.fun.jump,\
                @@call.ie.n64     , .sa.fun.jump,\
                @@call.if.true    , .sa.fun.jump.bool,\
                @@call.if.false   , .sa.fun.jump.bool,\
                @@call.if.z       , .sa.fun.jump,\
                @@call.if.nz      , .sa.fun.jump,\
                @@call.if.az      , .sa.fun.jump,\
                @@call.if.aez     , .sa.fun.jump,\
                @@call.if.bz      , .sa.fun.jump,\
                @@call.if.bez     , .sa.fun.jump,\
                @@call.ie.true    , .sa.fun.jump.bool,\
                @@call.ie.false   , .sa.fun.jump.bool,\
                @@call.ie.z       , .sa.fun.jump,\
                @@call.ie.nz      , .sa.fun.jump,\
                @@call.ie.az      , .sa.fun.jump,\
                @@call.ie.aez     , .sa.fun.jump,\
                @@call.ie.bz      , .sa.fun.jump,\
                @@call.ie.bez     , .sa.fun.jump,\
                @@call.if.or      , .sa.fun.jump,\
                @@call.if.nor     , .sa.fun.jump,\
                @@call.if.and     , .sa.fun.jump,\
                @@call.if.nand    , .sa.fun.jump,\
                @@call.ie.or      , .sa.fun.jump,\
                @@call.ie.nor     , .sa.fun.jump,\
                @@call.ie.and     , .sa.fun.jump,\
                @@call.ie.nand    , .sa.fun.jump
        jmp    .sa.main
   .sa.var.string:
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        mov     [.var.string], 1
        mov     ax, 3                           ; variable declaration has the lowest possible priority
        jmp    .sa.var.main
   .sa.var.int:
        cmp     [.var.declare], 0
        jnz    .sa.main
        mov     [.var.integer], 1
        mov     ax, 3                           ; variable declaration has the lowest possible priority
        jmp    .sa.var.main
   .sa.var.integer:
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        mov     [.var.integer], 1
        mov     ax, 3                           ; variable declaration has the lowest possible priority
        jmp    .sa.var.main
   .sa.var.complex:
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        mov     [.var.complex], 1
        mov     ax, 3                           ; variable declaration has the lowest possible priority
        jmp    .sa.var.main
   .sa.var.double:
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        mov     [.var.double], 1
        mov     ax, 3                           ; variable declaration has the lowest possible priority
;       jmp    .sa.var.main
   .sa.var.main:
        cmp     [.var.assign], 0
        jnz    .sa.error.token
        mov     [.var.declare], 1
        mov     rcx, [.sito]
        mov     [.vito], rcx                    ; assign var function stack item offset
        jmp    .sa.main.enter
   .sa.var.assign:
        cmp     [.var.assign], 0
        jnz    .sa.error.token
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        mov     [.var.assign], 1
        or      [.rcode], RCODE_FLAG_ASSIGN     ; variable assign flag
        jmp    .sa.main
        ;
   .sa.fun.if.bool:
        or      [.rcode], RCODE_FLAG_BOOL
        jmp    .sa.main
        ;
   .sa.fun.ie.bool:
        or      [.rcode], RCODE_FLAG_BOOL
        jmp    .sa.main
        ;
   .sa.fun.exit.bool:
        or      [.rcode], RCODE_FLAG_BOOL
   .sa.fun.exit:
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        test    [.rcode], RCODE_FLAG_JUMP
        jnz    .sa.error.token
        test    [.rcode], RCODE_FLAG_EXIT
        jnz    .sa.error.token
        or      [.rcode], RCODE_FLAG_EXIT       ; jump to exit
        xor     ax, ax                          ; priority = 0
        jmp    .sa.main
        ;
   .sa.fun.jump.bool:
        or      [.rcode], RCODE_FLAG_BOOL
   .sa.fun.jump:
        cmp     [.var.declare], 0
        jnz    .sa.error.token
        test    [.rcode], RCODE_FLAG_JUMP
        jnz    .sa.error.token
        test    [.rcode], RCODE_FLAG_EXIT
        jnz    .sa.error.token
        or      [.rcode], RCODE_FLAG_JUMP       ; label jump or procedure call
        xor     ax, ax                          ; priority = 0
        jmp    .sa.main

   .sa.enter:
        test    edx, edx
        jz     .sa.main

   .sa.f.in:                                    ; change functions
        mov     rdx, [.sito]                    ; rdx = current stack item offset
        sub     rdx, sizeof.sitem64             ; rdx = previous stack item offset
        mov     cx, [rdx + sitem64.ItemType]
        cmp     cx, 'fµ'
        je     .sa.f.ix
   .sa.f.fn:
        mov     cx, [rdx + sitem64.DataType]
        cmp     cx, 'f2'
        jne    .sa.f.out
   .sa.f.f2:
        cmp     bl, 'f'
        jne    .sa.f.out
        mov     rcx, [.param]
        test    rcx, rcx
        jz     .sa.f.out
        mov     rcx, [rcx + fitem64.offset]
        pcase   rcx,\
                @@co.rcopy  , .sa.f.f2.copy,\   ; z=
                @@co.rxcopy , .sa.f.f2.copy,\   ; z:=
                @@swap      , .sa.f.f2.swap     ; z:=:
        jne    .sa.f.out
   .sa.f.f2.copy:
        mov     rcx, [??.ccopy]
        mov     [.param], rcx
        mov     bx, 'f '                        ; item type
        mov     ax, 4                           ; operation priority or data type
        mov     word [.token], bx
        jmp    .sa.main
   .sa.f.f2.swap:
        mov     rcx, [??.cswap]
        mov     [.param], rcx
        mov     bx, 'f '                        ; item type
        mov     ax, 4                           ; operation priority or data type
        mov     word [.token], bx
        jmp    .sa.main
        ;
   .sa.f.ix:                                    ; change postfix functions to infix functions
        mov     [.funco], 0
        mov     [.funci], cx
        mov     [.funcp], ax
        mov     [.infix], 0
        case    bh,\                            ; !!! test all possible prefix symbols
                '+', .sa.f.infix.add,\
                '-', .sa.f.infix.sub,\
                '*', .sa.f.infix.mul,\
                '/', .sa.f.infix.div,\
                '&', .sa.f.infix.amp,\
                '!', .sa.f.infix.exc,\
                '?', .sa.f.infix.quest,\
                '~', .sa.f.infix.tilde,\
                '°', .sa.f.infix.degree,\
                '#', .sa.f.infix,\
                '$', .sa.f.infix
        cmp     bl, ')'
        je     .sa.f.x
        cmp     bl, ','
        je     .sa.f.x
        cmp     bl, '('
        je     .sa.f.infix
        cmp     bh, 'µ'
        jb     .sa.f.x
        jmp    .sa.f.infix
   .sa.f.infix.add:
;      .pushf   @@uplus, 'f+', 28, 1
        push    [??.uplus]
        pop     [.funco]
        mov     [.funci], 'f+'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix.sub:
;      .pushf   @@chs, 'f-', 28, 1
        push    [??.chs]
        pop     [.funco]
        mov     [.funci], 'f-'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix.mul:
;      .pushf   ??pdouble, 'f*', 42, 1
        push    [??.pdouble]
        pop     [.funco]
        mov     [.funci], 'f*'
        mov     [.funcp], 42
        jmp    .sa.f.infix
   .sa.f.infix.div:
;      .pushf   @@inv, 'f/', 28, 1
        push    [??.inv]
        pop     [.funco]
        mov     [.funci], 'f/'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix.amp:
;      .pushf   ??addr, 'f&', 42, 1
        push    [??.addr]
        pop     [.funco]
        mov     [.funci], 'f&'
        mov     [.funcp], 42
        jmp    .sa.f.infix
   .sa.f.infix.exc:
;      .pushf   @@not, 'f!', 28, 1
        push    [??.not]
        pop     [.funco]
        mov     [.funci], 'f!'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix.quest:
;      .pushf   @@ot, 'f?', 28, 1
        push    [??.ot]
        pop     [.funco]
        mov     [.funci], 'f?'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix.tilde:
;      .pushf   @@bnot, 'f~', 28, 1
        push    [??.bnot]
        pop     [.funco]
        mov     [.funci], 'f~'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix.degree:
;      .pushf   @@r2d, 'f°', 28, 1
        push    [??.r2d]
        pop     [.funco]
        mov     [.funci], 'f°'
        mov     [.funcp], 28
        jmp    .sa.f.infix
   .sa.f.infix:
        mov     [.infix], 1
   .sa.f.x:
        mov     rcx, [rdx + sitem64.Param]
        case    rcx,\
                [??.inc.post]  , .sa.f.inc,\        ; ? a++b : inc.post -> add.pos
                [??.dec.post]  , .sa.f.dec,\        ; ? a--b : dec.post -> sub.neg
                [??.pdouble]   , .sa.f.pdouble,\    ; ? a^b  : pdouble -> pow | bxor
                [??.pcomplex]  , .sa.f.pcomplex,\   ; ? a^^b : pcomplex -> xor
                [??.co.chs]    , .sa.f.co.chs,\     ; ? a-=b : co.chs -> co.sub
                [??.co.rcopy]  , .sa.f.co.rcopy,\   ; ? a=b  : co.rcopy -> copy
                [??.co.rxcopy] , .sa.f.co.rxcopy    ; ? a:=b : co.rxcopy -> xcopy
        jmp    .sa.f.out
        ;
   .sa.f.inc:                                   ; a++...
        cmp     [.infix], 0
        jz     .sa.f.postfix
   .sa.f.inc.infix:                             ; a++b
        mov     rcx, [??.add.pos]               ; inc.post -> add.pos
        mov     [rdx + sitem64.Priority], 12
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.dec:                                   ; a--...
        cmp     [.infix], 0
        jz     .sa.f.postfix
   .sa.f.dec.infix:                             ; a--b
        mov     rcx, [??.sub.neg]               ; dec.post -> sub.neg
        mov     [rdx + sitem64.Priority], 12
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.pdouble:                               ; a^...
        cmp     [.infix], 0
        jz     .sa.f.postfix
        test    [sop], SIC_OPT_FLAG_COMPLEX
        jnz    .sa.f.pdouble.infix.complex
   .sa.f.pdouble.infix:                         ; a^b
;       mov     rcx, [??.pow]                   ; pdouble -> pow
        mov     rcx, [??.pow.??]                ; pdouble -> pow | bxor
        mov     [rdx + sitem64.Priority], 17
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
   .sa.f.pdouble.infix.complex:                 ; a^b
        mov     rcx, [??.cpow]                  ; pdouble -> cpow
        mov     [rdx + sitem64.Priority], 17
        mov     [rdx + sitem64.Param], rcx
        mov     [rdx + sitem64.ArgCount], 4
        mov     [rdx + sitem64.ReType], 2
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.pcomplex:                              ; a^^...
        cmp     [.infix], 0
        jz     .sa.f.postfix
   .sa.f.pcomplex.infix:                        ; a^^b
        mov     rcx, [??.xor]                   ; pcomplex -> xor
        mov     [rdx + sitem64.Priority], 6
        mov     [rdx + sitem64.Param], rcx
        mov     [rdx + sitem64.ReType], 1
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.co.chs:                                ; a-=...
        cmp     [.infix], 0
        jz     .sa.f.postfix
   .sa.f.co.chs.infix:                          ; a-=b
        mov     rcx, [??.co.sub]                ; co.chs -> co.sub
        mov     [rdx + sitem64.Priority], 4
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.co.rcopy:                              ; a=...
        cmp     [.infix], 0
        jz     .sa.f.postfix
   .sa.f.co.rcopy.infix.copy:                   ; a=b
        test    [.rcode], RCODE_FLAG_BOOL
        jnz    .sa.f.co.rcopy.infix.if.e
        ;
        mov     rcx, [??.copy]                  ; co.rcopy -> copy
        mov     [rdx + sitem64.Priority], 4
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
   .sa.f.co.rcopy.infix.if.e:                   ; a=b
        mov     rcx, [??.if.e]                  ; co.rcopy -> if.e
        mov     [rdx + sitem64.Priority], 5
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.co.rxcopy:                             ; a:=...
        cmp     [.infix], 0
        jz     .sa.f.postfix
   .sa.f.co.rxcopy.infix:                       ; a:=b
        mov     rcx, [??.xcopy]                 ; co.rxcopy -> xcopy
        mov     [rdx + sitem64.Priority], 4
        mov     [rdx + sitem64.Param], rcx
        mov     cx, 'f '
        jmp    .sa.f.item.type
        ;
   .sa.f.postfix:                               ; postfix function
        mov     cx, 'f¶'
   .sa.f.item.type:
        mov     word [.token + 2], cx
        mov     [rdx + sitem64.ItemType], cx
        ;
        mov     rcx, [.funco]
        test    rcx, rcx
        jz     .sa.f.out
        mov     [.param], rcx
        mov     ax, [.funcp]
        mov     bx, [.funci]
        mov     word [.token], bx
;       jmp    .sa.f.out
   .sa.f.out:

   .sa.main:
        mov     rcx, [.sito]
        ;
        test    [sop], SIC_OPT_FLAG_COMPLEX
        jz     .sa.main.enter
;       cmp     bl, 'F'
;       je     .sa.main.f
        cmp     bl, 'f'
        jne    .sa.main.enter
   .sa.main.f:
        mov     rdx, [.param]
        case    rdx,\
                [??.add]     , .sa.main.f.add,\   ; +
                [??.sub]     , .sa.main.f.sub,\   ; -
                [??.subr]    , .sa.main.f.subr,\  ; ~-
                [??.mul]     , .sa.main.f.mul,\   ; *
                [??.div]     , .sa.main.f.div,\   ; /
                [??.divr]    , .sa.main.f.divr,\  ; ~/
                [??.pow]     , .sa.main.f.pow,\   ; ^ **
                [??.pow.??]  , .sa.main.f.pow,\   ; ^
                [??.powr]    , .sa.main.f.powr,\  ; ~^ ~**
                [??.powr.??] , .sa.main.f.powr,\  ; ~^
                [??.root]    , .sa.main.f.root,\  ; */
                [??.rootr]   , .sa.main.f.rootr   ; ~*/
        jmp    .sa.main.enter
   .sa.main.f.rootr:
        mov     rdx, [??.crootr]
        jmp    .sa.main.f.assign
   .sa.main.f.root:
        mov     rdx, [??.croot]
        jmp    .sa.main.f.assign
   .sa.main.f.powr:
        mov     rdx, [??.cpowr]
        jmp    .sa.main.f.assign
   .sa.main.f.pow:
        mov     rdx, [??.cpow]
        jmp    .sa.main.f.assign
   .sa.main.f.divr:
        mov     rdx, [??.cdivr]
        jmp    .sa.main.f.assign
   .sa.main.f.div:
        mov     rdx, [??.cdiv]
        jmp    .sa.main.f.assign
   .sa.main.f.mul:
        mov     rdx, [??.cmul]
        jmp    .sa.main.f.assign
   .sa.main.f.subr:
        mov     rdx, [??.csubr]
        jmp    .sa.main.f.assign
   .sa.main.f.sub:
        mov     rdx, [??.csub]
        jmp    .sa.main.f.assign
   .sa.main.f.add:
        mov     rdx, [??.cadd]
   .sa.main.f.assign:
        mov     [.param], rdx
        ;
   .sa.main.enter:
        mov     [rcx + sitem64.ItemType], bx    ; item type
        mov     [rcx + sitem64.Priority], ax    ; operation priority or data type

        cmp     bl, 'c'
        jne    .sa.no.constant
        cmp     al, 's'
        jne    .sa.no.string
   .sa.string.constant:
        mov     edx, [.datas]
        jmp    .sa.data.size
   .sa.no.constant:
   .sa.no.string:
        xor     edx, edx
   .sa.data.size:
        mov     [rcx + sitem64.DataSize], edx   ; data size

    $ifdef _X64
   .sa.param.x64:                               ; parameter
        mov     rdx, [.param]
        mov     [rcx + sitem64.Param], rdx
    $else
   .sa.param.x32:
        mov     edx, dword [.param + 0]
        mov     dword [ecx + sitem32.Param + 0], edx
        mov     edx, dword [.param + 4]
        mov     dword [ecx + sitem32.Param + 4], edx
    $end

        cmp     bl, 'f'                         ; set function offset
        je     .sa.f
        cmp     bl, 'F'                         ; set function offset
        je     .sa.f
        cmp     bl, 'A'                         ; set function offset
        je     .sa.f
        xor     rdx, rdx
        jmp    .sa.f.set
   .sa.f:
        mov     rdx, [rcx + sitem64.Param]
        test    rdx, rdx
        jz     .sa.error
        mov     ax, [rdx + fitem64.retype]
        mov     [rcx + sitem64.ReType], ax
        mov     rdx, [rdx + fitem64.offset]
   .sa.f.set:
        mov     [.func], rdx

   .sa.inc:
        add     [.sito], sizeof.sitem64
        inc     [.stack.ic]                     ; increase stack item count
   .sa.return:
        mov     rcx, rsp                        ; rcx <> 0
        retn

   .sa.error:
        xor     rcx, rcx
        retn

   .sa.error.memory:
        mov     [.ecode], SIC_ERROR_MEMORY
        xor     rcx, rcx
        retn

   .sa.error.token:
        mov     [.ecode], SIC_ERROR_TOKEN
        xor     rcx, rcx
        retn

   .sa.error.argument:
        mov     [.ecode], SIC_ERROR_ARGUMENT
        xor     rcx, rcx
        retn
$endp

; set stack item
; -> [.sito]  : current stack item offset
; -> [.idata] : item data
; -> [.datas] : data size
; -> [.param] : parameter
; -> ax       : operation priority or data type
; <- ecx      : 0 on error
; <- [.token] : [.idata]
macro c
{
$sproc .stack.set

        call   .stack.shrink
        call   .stack.add
        retn
$endp
; double stack shrink
$sproc .stack.set.L2

        call   .stack.shrink
        call   .stack.shrink
        call   .stack.add
        retn
$endp
; triple stack shrink
$sproc .stack.set.L3

        call   .stack.shrink
        call   .stack.shrink
        call   .stack.shrink
        call   .stack.add
        retn
$endp
; quadro stack shrink
$sproc .stack.set.L4

        call   .stack.shrink
        call   .stack.shrink
        call   .stack.shrink
        call   .stack.shrink
        call   .stack.add
        retn
$endp
; penta stack shrink
$sproc .stack.set.L5

        call   .stack.shrink
        call   .stack.shrink
        call   .stack.shrink
        call   .stack.shrink
        call   .stack.shrink
        call   .stack.add
        retn
$endp
}

; backward stack scan for left parenthesis
; -> al  : parenthesis symbol to find
;          < [ { |
; <- rax : stack item offset or 0 on error
$sproc .stack.par.scan

        push    rsi

        mov     rsi, [.stacko]                  ; rsi = stack offset
        xor     rcx, rcx
        mov     ecx, [.stack.ic]                ; rcx = stack item count
        test    rcx, rcx
        jz     .sps.error

        lea     rdx, [rcx + 1]                  ; rdx = ([stack item count] + 1)
        shl     rdx, 4                          ; rdx = ([stack item count] + 1) * 16
        mov     rsi, [.stacki]                  ; rsi = stack[first-1] item offset

;       some AV-engines go crazy about lea rsi, [rsi...]
;       lea     rsi, [rsi + rdx]                ; rsi = stack[last+1] item offset
        add     rsi, rdx                        ; rsi = stack[last+1] item offset

;      $align
   .sps.scan:
        sub     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dx, [rsi + sitem64.ItemType]
   .sps.scan.test:
        cmp     dh, al
        je     .sps.success
   .sps.next:
        dec     rcx
        jnz    .sps.scan

   .sps.error:
        xor     rax, rax                        ; error. rax = 0
        pop     rsi
        retn

   .sps.success:
        mov     rax, rsi                        ; success. rax = stack item offset
        pop     rsi
        retn
$endp

; verify stack tokens
; assign functions argument count
; get argument count for functions with a variable number of arguments
; -> tokens : c v r f F A ( ) , ! ? 0
; <- tokens : c v r f F A ( ) ,
; <- eax    : 0 on error
$sproc .stack.verify

        xor     rdx, rdx
        mov     rsi, [.stacko]                  ; rsi = stack offset
        xor     rcx, rcx
        mov     ecx, [.stack.ic]                ; rcx = stack item count
        cmp     rcx, rdx
        jng    .sv.error
        mov     rsi, [.stacki]                  ; rsi = stack[first-1] item offset

;      $align
   .sv.scan:
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     rdi, [rsi + sitem64.Param]

        mov     dl, byte [rsi + sitem64.ItemType]
        cmp     dl, 'v'
        je     .sv.var
        cmp     dl, 'r'
        je     .sv.var
        cmp     dl, 'f'
        je     .sv.fun
        cmp     dl, 'F'
        je     .sv.fun
        cmp     dl, 'A'
        je     .sv.fun
        cmp     dl, '!'
        je     .sv.error                        ; error. undefined token
        cmp     dl, '?'
        jne    .sv.next
        jmp    .sv.error                        ; error. undefined token

   .sv.var:                                     ; rdi = variable value offset
        cmp     rdi, 0
        jnz    .sv.next
        jmp    .sv.error                        ; error. null variable offset

   .sv.fun:                                     ; rdi = function item offset
        mov     rbx, [rdi + fitem64.offset]
        test    rbx, rbx
        jz     .sv.error                        ; error. null function offset
   .sv.fun.prefix?:
        mov     [.prefix], 0
        pcase   rbx,\
                @@addr , .sv.fun.prefix
        jmp    .sv.fun.prefix.out
   .sv.fun.prefix:
        mov     [.prefix], 1
   .sv.fun.prefix.out:

        mov     bx, [rdi + fitem64.acount]      ; bx = function argument count
        cmp     bx, 0
        jge    .sv.fun.assign                   ; fixed argument count

   .sv.fun.va:                                  ; variable argument count
   .sv.fun.va.any?.in:
        mov     [.acount.any], 0
        cmp     bx, 0x8000
        jne    .sv.fun.va.any?.out
        mov     [.acount.any], 1
   .sv.fun.va.any?.out:
        movsx   eax, bx
        neg     eax
        mov     [.acount], eax

   .sv.fun.args:
        xor     rax, rax                        ; rax <- parenthesis counter
        xor     rbx, rbx                        ; rbx <- function argument counter
        xor     rdx, rdx                        ; dh <- argument flag, dl <- current token type

        mov     [.rsi], rsi                     ; save registers
        mov     [.rcx], rcx
        dec     rcx
        jz     .sv.fun.out

        mov     rdi, rsi                        ; get left parenthesis counter floor
        mov     [.pcount], 0                    ; [.pcount] = parenthesis counter floor
                                                ; func a,b,c    -> [.pcount]=0
                                                ; func(a,b,c)   -> [.pcount]=1
                                                ; func(a,(b,c)) -> [.pcount]=1
                                                ; func((a,b,c)) -> [.pcount]=2
   .sv.par.in:
        add     rdi, sizeof.sitem64             ; rdi = current stack item offset
        mov     dl, byte [rdi + sitem64.ItemType]
        cmp     dl, '!'
        je     .sv.error
        cmp     dl, '?'
        je     .sv.error
        cmp     dl, 'A'
        je     .sv.par.next
        cmp     dl, '('
        jne    .sv.par.out
        inc     [.pcount]
   .sv.par.next:
        dec     rcx
        jnz    .sv.par.in
   .sv.par.out:
        mov     rcx, [.rcx]
        dec     rcx

        xor     rdx, rdx                        ; get actual argument count
        mov     [.fpcount], rdx                 ; clear function parenthesis counter
        cmp     [.pcount], 0
        jnz    .sv.fun.in
        inc     [.fpcount]
   .sv.fun.in:
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dl, byte [rsi + sitem64.ItemType]
        cmp     dl, '!'
        je     .sv.error
        cmp     dl, '?'
        je     .sv.error
        cmp     dl, '('
        je     .sv.fun.bra
        cmp     dl, ')'
        je     .sv.fun.ket
        cmp     dl, 'f'
        je     .sv.fun.fun
        cmp     dl, 'F'
        je     .sv.fun.fun
        cmp     dl, 'A'
        je     .sv.fun.next
        cmp     dl, ','
        je     .sv.fun.next
        cmp     dl, 0
        je     .sv.fun.next                     ; ignore empty item
   .sv.fun.arg:
        mov     dx, [rsi + sitem64.DataType]
        cmp     dx, 'f2'
        je     .sv.fun.arg.f2
        inc     rbx
        cmp     [.pcount], 0
        jnz    .sv.fun.next
        cmp     [.prefix], 0
        jnz    .sv.fun.out
        jmp    .sv.fun.next
   .sv.fun.arg.f2:
        add     rbx, 2
        cmp     [.pcount], 0
        jnz    .sv.fun.next
        cmp     [.prefix], 0
        jnz    .sv.fun.out
        jmp    .sv.fun.next
   .sv.fun.fun:
        mov     rax, [rsi + sitem64.Param]
        mov     ax, [rax + fitem64.acount]      ; ax = function argument count
        cmp     ax, 0
        jl     .sv.fun.fun.va                   ; variable argument count
        and     rax, 0xFFFF
        sub     rbx, rax
        movsx   rax, [rsi + sitem64.ReType]
        test    rax, rax
        jz     .sv.error                        ; void function is invalid argument
        cmp     rax, 'i'                        ; ? integer function
        je     .sv.fun.fun.rt.1
        cmp     rax, -1                         ; ? :int | :int64
        jne    .sv.fun.fun.next
   .sv.fun.fun.rt.1:
        mov     rax, 1                          ; set return type = 1
   .sv.fun.fun.next:
        add     rbx, rax
        cmp     [.pcount], 0
        jnz    .sv.fun.next
        cmp     [.prefix], 0
        jnz    .sv.fun.out
        jmp    .sv.fun.next
        ;
   .sv.fun.fun.va:                              ; variable argument count
        mov     rax, [rsi + sitem64.Param]
        cmp     rax, [??.addr]
        je     .sv.fun.fun.va.addr
   .sv.fun.fun.va.x:
        dec     rcx
        jz     .sv.error
        xor     rax, rax                        ; rax = parenthesis counter
        mov     [.zzx], rsi
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dl, byte [rsi + sitem64.ItemType]
        case    dl,\
                '(', .sv.fun.fun.va.x.bra
        jmp    .sv.error
   .sv.fun.fun.va.x.scan:
        dec     rcx
        jz     .sv.error
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dl, byte [rsi + sitem64.ItemType]
        case    dl,\
                '(', .sv.fun.fun.va.x.bra,\
                ')', .sv.fun.fun.va.x.ket
        jmp    .sv.fun.fun.va.x.scan
   .sv.fun.fun.va.x.bra:
        inc     rax
        jmp    .sv.fun.fun.va.x.scan
   .sv.fun.fun.va.x.ket:
        dec     rax
        jnz    .sv.fun.fun.va.x.scan
   .sv.fun.fun.va.x.arg:
        mov     rax, [.zzx]
        movsx   rax, [rax + sitem64.ReType]
        test    rax, rax
        jz     .sv.error                        ; void function is invalid argument
        cmp     rax, 'i'                        ; ? integer function
        jne     @F
        mov     rax, 1                          ; integer function
    @@:
        add     rbx, rax
        jmp    .sv.fun.next
        ;
   .sv.fun.fun.va.addr:
        dec     rcx
        jz     .sv.error
        xor     rax, rax                        ; rax = parenthesis counter
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dl, byte [rsi + sitem64.ItemType]
        case    dl,\
                'v', .sv.fun.fun.va.addr.arg,\
                'r', .sv.fun.fun.va.addr.arg,\
                '(', .sv.fun.fun.va.addr.bra
        jmp    .sv.error
   .sv.fun.fun.va.addr.scan:
        dec     rcx
        jz     .sv.error
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dl, byte [rsi + sitem64.ItemType]
        case    dl,\
                '(', .sv.fun.fun.va.addr.bra,\
                ')', .sv.fun.fun.va.addr.ket
        jmp    .sv.fun.fun.va.addr.scan
   .sv.fun.fun.va.addr.bra:
        inc     rax
        jmp    .sv.fun.fun.va.addr.scan
   .sv.fun.fun.va.addr.ket:
        dec     rax
        jnz    .sv.fun.fun.va.addr.scan
   .sv.fun.fun.va.addr.arg:
        inc     rbx
        jmp    .sv.fun.next
        ;
   .sv.fun.bra:
        inc     [.fpcount]
        jmp    .sv.fun.next
   .sv.fun.ket:
        dec     [.fpcount]
        jz     .sv.fun.out
   .sv.fun.next:
        dec     rcx
        jnz    .sv.fun.in
   .sv.fun.out:
        mov     rsi, [.rsi]                     ; restore registers
        mov     rcx, [.rcx]
   .sv.fun.test:
        cmp     rbx, 0
        jl     .sv.error
        cmp     [.acount.any], 0
        jnz    .sv.fun.assign
        cmp     bx, word [.acount]
        jl     .sv.error                        ; error. invalid argument count
   .sv.fun.assign:                              ; bx = function argument count
        mov     [rsi + sitem64.ArgCount], bx    ; save argument count

   .sv.next:
        dec     rcx
        jnz    .sv.scan

   .sv.return:
        mov     rax, 1                          ; success. eax != 0
        call   .rpn.build
        retn

   .sv.error:
        mov     [.ecode], SIC_ERROR_STACK
        xor     rax, rax                        ; error. eax = 0
        retn
$endp

; build rpn array (reverse stack scan)
; -> tokens : c v r f F A ( ) ,
; <- tokens : c v r f F A 0
; <- eax    : rpn item count
$sproc .rpn.build

;       stdcall tupdate                         ; update tables related data

        mov     rsi, [.stacko]                  ; rsi = stack offset
        xor     rcx, rcx
        mov     ecx, [.stack.ic]                ; rcx = stack item count
        cmp     rcx, 0
        jng    .rb.error
        mov     rdi, [.rpni]                    ; rdi = rpn[first-1] item offset

        lea     rdx, [2 * rcx]                  ; rdx = [item count] * 2
        lea     rax, [8 * rdx]                  ; rax = [item count] * 16

        add     rsi, rax                        ; rsi = stack[last+1] item offset
        xor     rax, rax
        xor     rbx, rbx                        ; rbx = 0

        mov     [.ecount], eax

;      $align
   .rb.scan:
        sub     rsi, sizeof.sitem64             ; rsi = current stack item offset
        mov     dl, byte [rsi + sitem64.ItemType]
;       cmp     dl, 0
;       je     .rb.prev
;       cmp     dl, ')'
;       je     .rb.prev
        cmp     dl, '('
        je     .rb.bra
        cmp     dl, 'c'
        je     .rb.var
        cmp     dl, 'v'
        je     .rb.var
        cmp     dl, 'r'
        je     .rb.var
        cmp     dl, 'f'
        je     .rb.fun
        cmp     dl, 'F'
        je     .rb.fun
        cmp     dl, 'A'
        je     .rb.fun
        cmp     dl, ','
        je     .rb.com

        jmp    .rb.prev

   .rb.bra:
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
        push    rax rsi
        dec     rax
   .rb.bra.in:
        add     rsi, sizeof.sitem64
        mov     dl, byte [rsi + sitem64.ItemType]
        test    dl, dl
        jz     .rb.bra.next                     ; skip empty item
        cmp     dl, ')'
        jne    .rb.bra.item
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
        jmp    .rb.bra.out
   .rb.bra.item:
       .call.rpn.add
        test    rbx, rbx
        jnz    .rb.bra.out
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
   .rb.bra.next:
        dec     rax
        jns    .rb.bra.in
   .rb.bra.out:
        pop     rsi rax
        test    ebx, ebx
        jnz    .rb.error
        jmp    .rb.prev

   .rb.com:
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
;       jmp    .rb.fun
   .rb.fun:
        test    rax, rax
        jz     .rb.prev
        push    rax rsi
        mov     dh, [rsi + sitem64.OPriority]   ; dh = fixed operation priority
;       mov     dh, byte [rsi + sitem64.Priority]
        dec     rax
   .rb.fun.in:
        add     rsi, sizeof.sitem64
        cmp     byte [rsi + sitem64.ItemType], 0
        jz     .rb.fun.next                     ; skip empty item
        mov     dl, [rsi + sitem64.OPriority]   ; dl = current operation priority
;       mov     dl, byte [rsi + sitem64.Priority]
        cmp     dl, dh
        jle    .rb.fun.out                      ; add to output string operation
   .rb.fun.item:                                ; with greater priority
       .call.rpn.add
        test    rbx, rbx
        jnz    .rb.fun.out
        cmp     [.rpn.add.res], 1
        je     .rb.fun.out.add.res.1
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
   .rb.fun.next:
        dec     rax
        jns    .rb.fun.in
   .rb.fun.out:
        pop     rsi rax
        test    rbx, rbx
        jnz    .rb.error
        jmp    .rb.prev
   .rb.fun.out.add.res.1:
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
        pop     rsi rax
        jmp    .rb.prev

   .rb.var:
       .call.rpn.add
        test    rbx, rbx
        jnz    .rb.error
        mov     [rsi + sitem64.ItemType], bx    ; let the item be empty
;       jmp    .rb.prev

   .rb.prev:
        inc     rax
        cmp     rax, rcx
        jb     .rb.scan

   .rb.cleanup:
        mov     rsi, [.stacki]                  ; rsi = stack[first-1] item offset
   .rb.a:
        add     rsi, sizeof.sitem64             ; rsi = current stack item offset
        cmp     byte [rsi + sitem64.ItemType], 0
        jz     .rb.b                            ; skip empty item
       .call.rpn.add
        test    rbx, rbx
        jnz    .rb.error
   .rb.b:
        dec     rcx
        jnz    .rb.a

   .rb.return:
        mov     rdi, [.rpn]                     ; rdi = rpn array offset
        mov     eax, [.rpn.ic]                  ; eax = rpn item count
        call   .code.build                      ; build code
        retn

   .rb.error:
        cmp     [.ecode], 0
        jnz    .rb.error.main
        mov     [.ecode], SIC_ERROR_RPN_BUILD
   .rb.error.main:
        xor     rax, rax
        retn
$endp

; add item to rpn
; -> rdi : previous rpn item offset
; -> rsi : stack item to copy offset
; <- [.rpn.add.res]
$sproc .rpn.add

        mov     [.rpn.add.res], 0

        mov     ebx, [.rpn.ic]                  ; ebx = rpn item count
        cmp     ebx, [@_CFG.rpn_count]
        jae    .rpn.error.memory

        mov     [.icounter], ebx                ; [.icounter] = items count

        movzx   rbx, [rsi + sitem64.ItemType]
        case    bl,\
                'f', .rpn.add.f,\
                'F', .rpn.add.f,\
                'A', .rpn.add.f
        jmp    .rpn.add.item

   .rpn.add.f:
        mov     rbx, [rsi + sitem64.Param]
        cmp     [rbx + fitem64.cosize], 0
        jl     .rpn.external                    ; code size < 0 : external function

        movsx   rax, [rbx + fitem64.retype]
        cmp     ax, 'i'                         ; ? integer function
        jne     @F
        mov     rax, 1
    @@:
        mov     [.frecount], rax                ; [.frecount] = function return count
        movsx   rax, [rbx + fitem64.acount]
        mov     [.acount], eax

        cmp     [.frecount], 1
        jg     .rpn.multiple.result             ; multiple-result function

        mov     rbx, [rbx + fitem64.offset]     ; rbx = function entry offset

   .rpn.test:
        pcase   rbx,\
                @@retn , .rpn.test.retn

   .rpn.test.bypass:
        pcase   rbx,\
                @@uplus , .rpn.bypass.item

   .rpn.test.dup:
        cmp     [.rpn.ic], 2
        jl     .rpn.test.dup.out
        cmp     [.frecount], 1
        jne    .rpn.test.dup.out
   .rpn.test.dup.rt.1:                          ; function retype = 1
        pcase   rbx,\
                @@ot       , .rpn.test.dup.x,\
                @@setz     , .rpn.test.dup.x,\
                @@set1     , .rpn.test.dup.x,\
                @@sign     , .rpn.test.dup.x,\
                @@rsign    , .rpn.test.dup.x,\
                @@nzero    , .rpn.test.dup.x,\
                @@rnzero   , .rpn.test.dup.x,\
                @@abs      , .rpn.test.dup.x,\
                @@nabs     , .rpn.test.dup.x,\
                @@pos      , .rpn.test.dup.x,\
                @@neg      , .rpn.test.dup.x,\
                @@int      , .rpn.test.dup.x,\
                @@frac     , .rpn.test.dup.x,\
                @@round    , .rpn.test.dup.x,\
                @@rint     , .rpn.test.dup.x,\
                @@rheven   , .rpn.test.dup.x,\
                @@rhodd    , .rpn.test.dup.x,\
                @@rzero    , .rpn.test.dup.x,\
                @@rinf     , .rpn.test.dup.x,\
                @@rpinf    , .rpn.test.dup.x,\
                @@rninf    , .rpn.test.dup.x
;               @@isign    , .rpn.test.dup.x
;               @@risign   , .rpn.test.dup.x
        jmp    .rpn.test.dup.out
   .rpn.test.dup.x:                             ; f(x)
        movzx   rdx, [rdi + sitem64.ItemType]   ; rdx = previous rpn item type
        case    dl,\
                'f', .rpn.test.dup.x.f,\
                'F', .rpn.test.dup.x.f
        jmp    .rpn.test.dup.out
   .rpn.test.dup.x.f:
        mov     rdx, [rdi + sitem64.Param]
        mov     rdx, [rdx + fitem64.offset]     ; rdx = prev function entry offset
        cmp     rbx, rdx
        jne    .rpn.test.dup.out
   .rpn.test.dup.x.e:
        pcase   rbx,\
                @@rsign  , .rpn.test.dup.rsign,\
                @@rnzero , .rpn.test.dup.rnzero
;               @@risign , .rpn.test.dup.risign
        jmp    .rpn.bypass.item                 ; f(f(x)) EQU f(x)
        ;
   .rpn.test.dup.rsign:                         ; rsign(rsign(x)) EQU sign(x)
        push    [??.sign]                       ; change prev rpn item function
        pop     [rdi + sitem64.Param]
        jmp    .rpn.bypass.item
;  .rpn.test.dup.risign:                        ; risign(risign(x)) EQU isign(x)
;       push    [??.isign]                      ; change prev rpn item function
;       pop     [rdi + sitem64.Param]
;       jmp    .rpn.bypass.item
   .rpn.test.dup.rnzero:                        ; rnzero(rnzero(x)) EQU nzero(x)
        push    [??.nzero]                      ; change prev rpn item function
        pop     [rdi + sitem64.Param]
        jmp    .rpn.bypass.item
   .rpn.test.dup.out:

   .rpn.test.dupn:
        cmp     [.rpn.ic], 2
        jl     .rpn.test.dupn.out
        pcase   rbx,\
                @@chs , .rpn.test.dupn.x,\
                @@inv , .rpn.test.dupn.x
        jmp    .rpn.test.dupn.out
   .rpn.test.dupn.x:                            ; f(x)
        movzx   rdx, [rdi + sitem64.ItemType]   ; rdx = previous rpn item type
        case    dl,\
                'f', .rpn.test.dupn.f,\
                'F', .rpn.test.dupn.f
        jmp    .rpn.test.dupn.out
   .rpn.test.dupn.f:
        mov     rdx, [rdi + sitem64.Param]
        mov     rdx, [rdx + fitem64.offset]     ; rdx = prev function entry offset
        cmp     rbx, rdx
        jne    .rpn.test.dupn.out
   .rpn.test.dupn.e:                            ; f(f(x)) EQU x
        mov     [rdi + sitem64.ItemType], 0     ; clear prev rpn item
        jmp    .rpn.bypass.item
    macro c
    {
        push    [??.uplus]                      ; change prev rpn item function
        pop     [rdi + sitem64.Param]
        jmp    .rpn.bypass.item
    }
    macro c
    {
        mov     rbx, @@uplus
        push    [??.uplus]
        pop     [rsi + sitem64.Param]
      ; mov     [rsi + sitem64.ArgCount], 1
        mov     [rdi + sitem64.ItemType], 0     ; clear prev rpn item
        jmp    .rpn.test.dupn.out
    }
   .rpn.test.dupn.out:

   .rpn.test.dupn.int:                          ; integer argument & integer result
        cmp     [.rpn.ic], 2
        jl     .rpn.test.dupn.int.out
        pcase   rbx,\
                @@bnot    , .rpn.test.dupn.int.x,\
                @@bswap   , .rpn.test.dupn.int.x,\
                @@bitswap , .rpn.test.dupn.int.x
        jmp    .rpn.test.dupn.int.out
   .rpn.test.dupn.int.x:                        ; f(x)
        movzx   rdx, [rdi + sitem64.ItemType]   ; rdx = previous rpn item type
        case    dl,\
                'f', .rpn.test.dupn.int.f,\
                'F', .rpn.test.dupn.int.f
        jmp    .rpn.test.dupn.int.out
   .rpn.test.dupn.int.f:
        mov     rdx, [rdi + sitem64.Param]
        mov     rdx, [rdx + fitem64.offset]     ; rdx = prev function entry offset
        cmp     rbx, rdx
        jne    .rpn.test.dupn.int.out
   .rpn.test.dupn.int.e:                        ; f(f(x)) EQU x
        mov     [rdi + sitem64.ItemType], 0     ; clear prev rpn item
        jmp    .rpn.bypass.item
    macro c
    {
        push    [??.nop]                        ; change prev rpn item function
        pop     [rdi + sitem64.Param]
        jmp    .rpn.bypass.item
    }
   .rpn.test.dupn.int.out:

   .rpn.test.vx.hypot:                          ; hypot()
        pcase   rbx,\
                @@hypot , .rpn.test.vhypot
        jmp    .rpn.test.vx.hypot.out
   .rpn.test.vhypot:
        cmp     [rsi + sitem64.ArgCount], 3
        je     .rpn.test.vhypot.3P
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.add.item
;       je     .rpn.test.vhypot.2P
        jmp    .rpn.error
   .rpn.test.vhypot.3P:
        mov     rbx, @@hypot3                   ; hypot3(x,y,z)
        push    [??.hypot3]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.add.item
;  .rpn.test.vhypot.2P:
;       jmp    .rpn.add.item
   .rpn.test.vx.hypot.out:

   .rpn.test.vx.return:                         ; change functions
        pcase   rbx,\
                @@return          , .rpn.test.vreturn,\
                @@return.if.true  , .rpn.test.vreturn.if.true,\
                @@return.if.false , .rpn.test.vreturn.if.false
        jmp    .rpn.test.vx.return.out
   .rpn.test.vreturn:
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.vreturn.1P
        cmp     [rsi + sitem64.ArgCount], 0
        je     .rpn.test.vreturn.0P
        jmp    .rpn.error
   .rpn.test.vreturn.1P:
        mov     rbx, @@.returnv                 ; return(x)
        push    [??.returnv]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.return
   .rpn.test.vreturn.0P:
        mov     rbx, @@exit                     ; exit()
        push    [??.exit]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.return
        ;
   .rpn.test.vreturn.if.true:
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.vreturn.if.true.2P
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.vreturn.if.true.1P
        jmp    .rpn.error
   .rpn.test.vreturn.if.true.2P:
        mov     rbx, @@.returnv.if.true         ; return.if.true(x,c)
        push    [??.returnv.if.true]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.return
   .rpn.test.vreturn.if.true.1P:
        mov     rbx, @@exit.if.true             ; exit.if.true(c)
        push    [??.exit.if.true]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.return
        ;
   .rpn.test.vreturn.if.false:
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.vreturn.if.false.2P
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.vreturn.if.false.1P
        jmp    .rpn.error
   .rpn.test.vreturn.if.false.2P:
        mov     rbx, @@.returnv.if.false        ; return.if.false(x,c)
        push    [??.returnv.if.false]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.return
   .rpn.test.vreturn.if.false.1P:
        mov     rbx, @@exit.if.false            ; exit.if.false(c)
        push    [??.exit.if.false]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.return
        ;
   .rpn.test.vx.return.out:

   .rpn.test.vx:                                ; change functions
        movzx   rdx, [rdi + sitem64.ItemType]   ; rdx = previous rpn item type
        cmp     dl, 'A'
        je     .rpn.test.vx.out
   .rpn.test.vx.main:
        pcase   rbx,\
                @@addr      , .rpn.test.addr
        pcase   rbx,\
                @@vcopy     , .rpn.test.vx.vcopy,\
                @@vcopx     , .rpn.test.vx.vcopx,\
                @@swapr     , .rpn.test.vx.swapx,\
                @@swapl     , .rpn.test.vx.swapx,\
                @@vnorm     , .rpn.test.vx.vnorm,\
                @@vsumsqr   , .rpn.test.vx.vsumsqr,\
                @@vsum      , .rpn.test.vx.vsum,\
                @@vmul      , .rpn.test.vx.vmul,\
                @@vmin      , .rpn.test.vx.vmin,\
                @@vmax      , .rpn.test.vx.vmax,\
                @@vmean     , .rpn.test.vx.vmean,\
                @@vvart     , .rpn.test.vx.z,\
                @@vvarp     , .rpn.test.vx.z,\
                @@vstdp     , .rpn.test.vx.z
        pcase   rbx,\
                @@case.e    , .rpn.test.vx.y,\
                @@rcase.e   , .rpn.test.vx.y,\
                @@case.ne   , .rpn.test.vx.y,\
                @@rcase.ne  , .rpn.test.vx.y,\
                @@case.a    , .rpn.test.vx.y,\
                @@rcase.a   , .rpn.test.vx.y,\
                @@case.ae   , .rpn.test.vx.y,\
                @@rcase.ae  , .rpn.test.vx.y,\
                @@case.b    , .rpn.test.vx.y,\
                @@rcase.b   , .rpn.test.vx.y,\
                @@case.be   , .rpn.test.vx.y,\
                @@rcase.be  , .rpn.test.vx.y,\
                @@vpoly     , .rpn.test.vx.y
        pcase   rbx,\
                @@.vint     , .rpn.test.vint,\
                @@.vfrac    , .rpn.test.vfrac,\
                @@.vround   , .rpn.test.vround
        pcase   rbx,\
                @@matrip    , .rpn.test.matrip,\
                @@matrip.rc , .rpn.test.matrip.rc
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vcopy:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.out
        mov     rbx, @@copy
        push    [??.copy]
        pop     [rsi + sitem64.Param]           ; vcopy(x,y) -> copy(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vcopx:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.out
        mov     rbx, @@copx
        push    [??.copx]
        pop     [rsi + sitem64.Param]           ; vcopx(x,y) -> copx(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.swapx:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.out
        mov     rbx, @@swap
        push    [??.swap]
        pop     [rsi + sitem64.Param]           ; swapr(x,y) -> swap(x,y)
        jmp    .rpn.test.vx.out                 ; swapl(x,y) -> swap(x,y)
   .rpn.test.vx.vnorm:
        cmp     [rsi + sitem64.ArgCount], 1
        jne    .rpn.test.vx.out
        mov     rbx, @@abs
        push    [??.abs]
        pop     [rsi + sitem64.Param]           ; v(x) -> abs(x)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vsumsqr:
        cmp     [rsi + sitem64.ArgCount], 1
        jne    .rpn.test.vx.out
        mov     rbx, @@pow2
        push    [??.pow2]
        pop     [rsi + sitem64.Param]           ; v(x) -> x^2
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vsum:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.x                   ; ? vsum(x) -> x
        mov     rbx, @@add
        push    [??.add]
        pop     [rsi + sitem64.Param]           ; vsum(x,y) -> add(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vmul:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.x                   ; ? vmul(x) -> x
        mov     rbx, @@mul
        push    [??.mul]
        pop     [rsi + sitem64.Param]           ; vmul(x,y) -> mul(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vmin:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.x                   ; ? vmin(x) -> x
        mov     rbx, @@min
        push    [??.min]
        pop     [rsi + sitem64.Param]           ; vmin(x,y) -> min(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vmax:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.x                   ; ? vmax(x) -> x
        mov     rbx, @@max
        push    [??.max]
        pop     [rsi + sitem64.Param]           ; vmax(x,y) -> max(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.vmean:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.x                   ; ? vmean(x) -> x
        mov     rbx, @@mean
        push    [??.mean]
        pop     [rsi + sitem64.Param]           ; vmean(x,y) -> mean(x,y)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.x:
        cmp     [rsi + sitem64.ArgCount], 1
        jne    .rpn.test.vx.out
        jmp    .rpn.bypass.item                 ; v(x) -> x
    macro c
    {
        mov     rbx, @@uplus
        push    [??.uplus]
        pop     [rsi + sitem64.Param]           ; v(x) -> x
        jmp    .rpn.test.vx.out
    }
        ;
   .rpn.test.vx.y:
        cmp     [rsi + sitem64.ArgCount], 2
        jne    .rpn.test.vx.out
   .rpn.test.vx.y.change:
        mov     rbx, @@uplus
        push    [??.uplus]
        pop     [rsi + sitem64.Param]           ; v(x,y) -> y
        mov     [rsi + sitem64.ArgCount], 1
        mov     [rdi + sitem64.ItemType], 0     ; clear prev rpn item
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.vx.z:
        cmp     [rsi + sitem64.ArgCount], 1
        jne    .rpn.test.vx.out
        cmp     byte [rdi + sitem64.ItemType], 'c'
        je     .rpn.test.vx.z.cv
        cmp     byte [rdi + sitem64.ItemType], 'v'
        je     .rpn.test.vx.z.cv
        cmp     byte [rdi + sitem64.ItemType], 'r'
        je     .rpn.test.vx.z.cv
        mov     rbx, @@setz
        push    [??.setz]
        pop     [rsi + sitem64.Param]           ; v(x) -> setz(x)
        jmp    .rpn.test.vx.out
   .rpn.test.vx.z.cv:
        mov     rbx, @@fldz
        push    [??.fldz]
        pop     [rsi + sitem64.Param]           ; v(x) -> 0
        mov     [rsi + sitem64.ArgCount], 0
        mov     [rdi + sitem64.ItemType], 0     ; clear prev rpn item
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.vint:
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.vint.1P
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.vint.2P
        jmp    .rpn.error
   .rpn.test.vint.1P:
        mov     rbx, @@int
        push    [??.int]
        pop     [rsi + sitem64.Param]           ; vint(x) -> int(x)
        jmp    .rpn.test.vx.out
   .rpn.test.vint.2P:
        mov     rbx, @@intto
        push    [??.intto]
        pop     [rsi + sitem64.Param]           ; vint(x,n) -> intto(x,n)
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.vfrac:
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.vfrac.1P
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.vfrac.2P
        jmp    .rpn.error
   .rpn.test.vfrac.1P:
        mov     rbx, @@frac
        push    [??.frac]
        pop     [rsi + sitem64.Param]           ; vfrac(x) -> frac(x)
        jmp    .rpn.test.vx.out
   .rpn.test.vfrac.2P:
        mov     rbx, @@fracto
        push    [??.fracto]
        pop     [rsi + sitem64.Param]           ; vfrac(x,n) -> fracto(x,n)
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.vround:
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.vround.1P
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.vround.2P
        jmp    .rpn.error
   .rpn.test.vround.1P:
        mov     rbx, @@round
        push    [??.round]
        pop     [rsi + sitem64.Param]           ; vround(x) -> round(x)
        jmp    .rpn.test.vx.out
   .rpn.test.vround.2P:
        mov     rbx, @@roundto
        push    [??.roundto]
        pop     [rsi + sitem64.Param]           ; vround(x,n) -> roundto(x,n)
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.matrip:
        cmp     [rsi + sitem64.ArgCount], 1
        je     .rpn.test.matrip.1D.1P
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.matrip.1D.2P
        cmp     [rsi + sitem64.ArgCount], 3
        je     .rpn.test.matrip.2D.3P
        cmp     [rsi + sitem64.ArgCount], 4
        je     .rpn.test.matrip.2D.4P
        jmp    .rpn.test.vx.out
   .rpn.test.matrip.1D.1P:
        jmp    .rpn.bypass.item                 ; matrip(i) -> i
    macro c
    {
        mov     rbx, @@.1D.1P.matrip
        push    [??.1D.1P.matrip]
        pop     [rsi + sitem64.Param]           ; matrip(i) -> 1D.1P.matrip(i)
        jmp    .rpn.test.vx.out
    }
   .rpn.test.matrip.1D.2P:
        mov     rbx, @@.1D.2P.matrip
        push    [??.1D.2P.matrip]
        pop     [rsi + sitem64.Param]           ; matrip(n,i) -> 1D.2P.matrip(n,i)
        jmp    .rpn.test.vx.out
   .rpn.test.matrip.2D.3P:
        mov     rbx, @@.2D.3P.matrip
        push    [??.2D.3P.matrip]
        pop     [rsi + sitem64.Param]           ; matrip(n,i,j) -> 2D.3P.matrip(n,i,j)
        jmp    .rpn.test.vx.out
   .rpn.test.matrip.2D.4P:
        mov     rbx, @@.2D.4P.matrip
        push    [??.2D.4P.matrip]
        pop     [rsi + sitem64.Param]           ; matrip(n,m,i,j) -> 2D.4P.matrip(n,m,i,j)
        jmp    .rpn.test.vx.out
   .rpn.test.matrip.rc:
;       cmp     [rsi + sitem64.ArgCount], 1
;       je     .rpn.test.matrip.1D.1P           ; matrip.rc(i) -> 1D.1P.matrip(i)
        cmp     [rsi + sitem64.ArgCount], 2
        je     .rpn.test.matrip.rc.1D
;       cmp     [rsi + sitem64.ArgCount], 3
;       je     .rpn.test.matrip.2D.3P           ; matrip.rc(n,i,j) -> 2D.3P.matrip(n,i,j)
        cmp     [rsi + sitem64.ArgCount], 4
        je     .rpn.test.matrip.rc.2D
        jmp    .rpn.test.vx.out
   .rpn.test.matrip.rc.1D:
        mov     rbx, @@.1D.matrip.rc
        push    [??.1D.matrip.rc]
        pop     [rsi + sitem64.Param]           ; matrip.rc(n,i) -> 1D.matrip.rc(n,i)
        jmp    .rpn.test.vx.out
   .rpn.test.matrip.rc.2D:
        mov     rbx, @@.2D.matrip.rc
        push    [??.2D.matrip.rc]
        pop     [rsi + sitem64.Param]           ; matrip.rc(n,m,i,j) -> 2D.matrip.rc(n,m,i,j)
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.addr:
        mov     bx, [rsi + sitem64.ArgCount]
        case    bx,\
                1, .rpn.test.addr.1P,\
                2, .rpn.test.addr.2P
        jmp    .rpn.error
   .rpn.test.addr.1P:
        mov     rbx, @@.addr.1P
        push    [??.addr.1P]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.vx.out
   .rpn.test.addr.2P:
        mov     rbx, @@.addr.2P
        push    [??.addr.2P]
        pop     [rsi + sitem64.Param]
        jmp    .rpn.test.vx.out
        ;
   .rpn.test.vx.out:

        mov     [.rpn.proc], rbx

        cmp     [.frecount], 0
        jnz    .rpn.x.test.rt.nz
   .rpn.x.test.rt.z:                            ; function retype = 0
        pcase   rbx,\
                @@exit          , .rpn.test.return,\
                @@exit.if.true  , .rpn.test.return,\
                @@exit.if.false , .rpn.test.return
        pcase   rbx,\
                @@goto          , .rpn.test.jump,\
                @@xgoto         , .rpn.test.jump.vx,\
                @@rxgoto        , .rpn.test.jump.vx,\
                @@goto.if.x32   , .rpn.test.jump,\
                @@goto.if.n32   , .rpn.test.jump,\
                @@goto.if.x64   , .rpn.test.jump,\
                @@goto.if.n64   , .rpn.test.jump,\
                @@goto.if.true  , .rpn.test.jump,\
                @@goto.if.false , .rpn.test.jump,\
                @@goto.if.z     , .rpn.test.jump,\
                @@goto.if.nz    , .rpn.test.jump,\
                @@goto.if.az    , .rpn.test.jump,\
                @@goto.if.aez   , .rpn.test.jump,\
                @@goto.if.bz    , .rpn.test.jump,\
                @@goto.if.bez   , .rpn.test.jump,\
                @@goto.if.or    , .rpn.test.jump,\
                @@goto.if.nor   , .rpn.test.jump,\
                @@goto.if.and   , .rpn.test.jump,\
                @@goto.if.nand  , .rpn.test.jump
        pcase   rbx,\
                @@call          , .rpn.test.jump,\
                @@calls         , .rpn.test.jump.v,\
                @@rcalls        , .rpn.test.jump.v,\
                @@xcall         , .rpn.test.jump.vx,\
                @@rxcall        , .rpn.test.jump.vx,\
                @@call.if.x32   , .rpn.test.jump,\
                @@call.if.n32   , .rpn.test.jump,\
                @@call.if.x64   , .rpn.test.jump,\
                @@call.if.n64   , .rpn.test.jump,\
                @@call.ie.x32   , .rpn.test.jump.2p,\
                @@call.ie.n32   , .rpn.test.jump.2p,\
                @@call.ie.x64   , .rpn.test.jump.2p,\
                @@call.ie.n64   , .rpn.test.jump.2p,\
                @@call.if.true  , .rpn.test.jump,\
                @@call.if.false , .rpn.test.jump,\
                @@call.if.z     , .rpn.test.jump,\
                @@call.if.nz    , .rpn.test.jump,\
                @@call.if.az    , .rpn.test.jump,\
                @@call.if.aez   , .rpn.test.jump,\
                @@call.if.bz    , .rpn.test.jump,\
                @@call.if.bez   , .rpn.test.jump,\
                @@call.ie.true  , .rpn.test.jump.2p,\
                @@call.ie.false , .rpn.test.jump.2p,\
                @@call.ie.z     , .rpn.test.jump.2p,\
                @@call.ie.nz    , .rpn.test.jump.2p,\
                @@call.ie.az    , .rpn.test.jump.2p,\
                @@call.ie.aez   , .rpn.test.jump.2p,\
                @@call.ie.bz    , .rpn.test.jump.2p,\
                @@call.ie.bez   , .rpn.test.jump.2p,\
                @@call.if.or    , .rpn.test.jump,\
                @@call.if.nor   , .rpn.test.jump,\
                @@call.if.and   , .rpn.test.jump,\
                @@call.if.nand  , .rpn.test.jump,\
                @@call.ie.or    , .rpn.test.jump.2p,\
                @@call.ie.nor   , .rpn.test.jump.2p,\
                @@call.ie.and   , .rpn.test.jump.2p,\
                @@call.ie.nand  , .rpn.test.jump.2p
        pcase   rbx,\
                @@absolute      , .rpn.test.absolute,\
                @@assign        , .rpn.test.assign,\
                @@reassign      , .rpn.test.assign
        jmp    .rpn.x.test.out

   .rpn.x.test.rt.nz:                           ; function retype != 0
        pcase   rbx,\
                @@sizeof        , .rpn.test.sizeof
        pcase   rbx,\
                @@copy          , .rpn.test.copy,\
                @@xcopy         , .rpn.test.copy
        pcase   rbx,\
                @@result.set    , .rpn.test.xresult,\
                @@result.get    , .rpn.test.xresult,\
                @@co.rcopy      , .rpn.test.xresult,\
                @@co.rxcopy     , .rpn.test.xresult
   .rpn.x.test.out:
        jmp    .rpn.add.item

   .rpn.external:
        inc     [.ecount]
        jmp    .rpn.add.item

   .rpn.multiple.result:
        jmp    .rpn.add.item

   .rpn.test.sizeof:
        cmp     [.rpn.ic], 1
        jl     .rpn.error                       ; no arguments -> error
        mov     dl, byte [rdi + sitem64.ItemType]
        cmp     dl, 'f'
        je     .rpn.test.sizeof.f
        cmp     dl, 'F'
        je     .rpn.test.sizeof.f
        jmp    .rpn.add.item
   .rpn.test.sizeof.f:
        mov     rax, 8
        mov     rdx, [rdi + sitem64.Param]
        mov     rdx, [rdx + fitem64.offset]
        pcase   rdx,\
                @@var     , .rpn.test.sizeof.assign.8,\
                @@double  , .rpn.test.sizeof.assign.8,\
                @@float   , .rpn.test.sizeof.assign.8,\
                @@cvar    , .rpn.test.sizeof.assign.16,\
                @@complex , .rpn.test.sizeof.assign.16,\
                @@int     , .rpn.test.sizeof.assign,\
                @@integer , .rpn.test.sizeof.assign,\
                @@str     , .rpn.test.sizeof.assign,\
                @@string  , .rpn.test.sizeof.assign,\
                @@ptr     , .rpn.test.sizeof.assign,\
                @@pointer , .rpn.test.sizeof.assign
        jmp    .rpn.add.item
   .rpn.test.sizeof.assign.16:
        mov     rax, 16
        jmp    .rpn.test.sizeof.assign
   .rpn.test.sizeof.assign.8:
;       mov     rax, 8
;       jmp    .rpn.test.sizeof.assign
   .rpn.test.sizeof.assign:
        mov     byte [rdi + sitem64.ItemType], 'c'
        mov     byte [rdi + sitem64.DataType], 'i'
        mov     [rdi + sitem64.Data64], rax
        jmp    .rpn.bypass.item

   .rpn.test.copy:
        mov     dx, [rdi + sitem64.ItemType]
        cmp     dl, 'f'
        je     .rpn.copy.f
        cmp     dl, 'F'
        je     .rpn.copy.f
        jmp    .rpn.add.item
   .rpn.copy.f:
        mov     rbx, [rdi + sitem64.Param]
        case    rbx,\
                [??.farr]  , .rpn.copy.f.farr,\
                [??.barr]  , .rpn.copy.f.barr,\
                [??.pfarr] , .rpn.copy.f.pfarr,\
                [??.pbarr] , .rpn.copy.f.pbarr
        jmp    .rpn.add.item
   .rpn.copy.f.farr:
        ; u->n=x --> farw(u,n,x)
        ; rpn: v:[x] v:[n] v:[u] f:[->] f:[=] --> v:[x] v:[n] v:[u] f:[farw] 0:[...]
        mov     rbx, [??.farw]
        mov     [rdi + sitem64.Param], rbx
        mov     [rdi + sitem64.ArgCount], 3
        jmp    .rpn.bypass.item
   .rpn.copy.f.barr:
        ; u~>n=x --> barw(u,n,x)
        ; rpn: v:[x] v:[n] v:[u] f:[~>] f:[=] --> v:[x] v:[n] v:[u] f:[barw] 0:[...]
        mov     rbx, [??.barw]
        mov     [rdi + sitem64.Param], rbx
        mov     [rdi + sitem64.ArgCount], 3
        jmp    .rpn.bypass.item
   .rpn.copy.f.pfarr:
        ; u*->n=x --> pfarw(u,n,x)
        ; rpn: v:[x] v:[n] v:[u] f:[*->] f:[=] --> v:[x] v:[n] v:[u] f:[pfarw] 0:[...]
        mov     rbx, [??.pfarw]
        mov     [rdi + sitem64.Param], rbx
        mov     [rdi + sitem64.ArgCount], 3
        jmp    .rpn.bypass.item
   .rpn.copy.f.pbarr:
        ; u*~>n=x --> pbarw(u,n,x)
        ; rpn: v:[x] v:[n] v:[u] f:[*~>] f:[=] --> v:[x] v:[n] v:[u] f:[pbarw] 0:[...]
        mov     rbx, [??.pbarw]
        mov     [rdi + sitem64.Param], rbx
        mov     [rdi + sitem64.ArgCount], 3
        jmp    .rpn.bypass.item

   .rpn.test.absolute:                          ; rdi = first parameter rpn item offset
        cmp     [.rpn.ic], 1
        jl     .rpn.error
        mov     dl, byte [rdi + sitem64.ItemType]
        cmp     dl, 'r'
        jne    .rpn.error
   .rpn.test.absolute.r:
        stdcall tageta, [.rdata], [rdi + sitem64.Param]
        test    rdx, rdx
        jz     .rpn.error
        mov     [rdi + sitem64.Param], rdx
        mov     dx, [rdi + sitem64.DataType]
        mov     [rdi + sitem64.DataType], 'a'
        cmp     dx, 'f2'
        jne    .rpn.add.item
   .rpn.test.absolute.f2:
        mov     rdx, [.vito]                    ; rdx = var function stack item offset
        test    rdx, rdx
        jz     .rpn.error
        dec     [rdx + sitem64.ArgCount]
        jmp    .rpn.add.item

   .rpn.test.assign:                            ; rdi = first parameter rpn item offset
        cmp     [.rpn.ic], 1
        jl     .rpn.error
        mov     dl, byte [rdi + sitem64.ItemType]
        cmp     dl, 'r'
        je     .rpn.test.assign.r
        cmp     dl, 'v'
        jne    .rpn.error
   .rpn.test.assign.v?:
        stdcall tageta, [.vdata], [rdi + sitem64.Param]
        test    rdx, rdx
        jnz    .rpn.test.assign.v
        stdcall tageta, [@_VDATA], [rdi + sitem64.Param]
        test    rdx, rdx
        jz     .rpn.error
   .rpn.test.assign.v:
        mov     [rdi + sitem64.Param], rdx
        mov     [rdi + sitem64.DataType], 'a'
        jmp    .rpn.add.item
   .rpn.test.assign.r:
        stdcall tageta, [.rdata], [rdi + sitem64.Param]
        test    rdx, rdx
        jz     .rpn.error
        mov     [rdi + sitem64.Param], rdx
        mov     dx, [rdi + sitem64.DataType]
        mov     [rdi + sitem64.DataType], 'a'
        cmp     dx, 'f2'
        jne    .rpn.add.item
   .rpn.test.assign.f2:
        dec     [rsi + sitem64.ArgCount]
        jmp    .rpn.add.item

   .rpn.test.retn:
        or      [.rcode], RCODE_FLAG_RETN       ; return from procedure
        jmp    .rpn.add.item

   .rpn.test.return:
        test    [sop], SIC_OPT_FLAG_STACK_FRAME
        jz     .rpn.error
        test    [sop], SIC_OPT_FLAG_LOCALS
        jz     .rpn.error
        jmp    .rpn.add.item

   .rpn.test.xresult:
        test    [sop], SIC_OPT_FLAG_STACK_FRAME
        jz     .rpn.error
        test    [sop], SIC_OPT_FLAG_LOCALS
        jz     .rpn.error
        jmp    .rpn.add.item

   .rpn.test.jump:
        cmp     byte [rdi + sitem64.ItemType], 'v'
        je     .rpn.jump.v
        cmp     byte [rdi + sitem64.ItemType], 'r'
        je     .rpn.jump.v
        retn
   .rpn.jump.v:
        cmp     byte [rdi + sitem64.DataType], '?'
        jne    .rpn.jump.v.o
        mov     byte [rdi + sitem64.DataType], 'o'  ; change data type of stack item
        jmp    .rpn.add.item
   .rpn.jump.v.o:
        cmp     byte [rdi + sitem64.DataType], 'o'
        je     .rpn.add.item
        retn

   .rpn.test.jump.2p:
        cmp     [.rpn.ic], 2
        jl     .rpn.error
   .rpn.test.jump.2p.p1:                        ; rdi = first parameter rpn item offset
        cmp     byte [rdi + sitem64.ItemType], 'v'
        je     .rpn.jump.2p.p1.v
        cmp     byte [rdi + sitem64.ItemType], 'r'
        je     .rpn.jump.2p.p1.v
        retn
   .rpn.jump.2p.p1.v:
        cmp     byte [rdi + sitem64.DataType], '?'
        jne    .rpn.jump.2p.p1.v.o
        mov     byte [rdi + sitem64.DataType], 'o'  ; change data type of stack item
        jmp    .rpn.test.jump.2p.p2
   .rpn.jump.2p.p1.v.o:
        cmp     byte [rdi + sitem64.DataType], 'o'
        je     .rpn.test.jump.2p.p2
        retn
   .rpn.test.jump.2p.p2:
        lea     rdx, [rdi + sizeof.sitem64]     ; rdx = second parameter rpn item offset
        cmp     byte [rdx + sitem64.ItemType], 'v'
        je     .rpn.jump.2p.p2.v
        cmp     byte [rdx + sitem64.ItemType], 'r'
        je     .rpn.jump.2p.p2.v
        retn
   .rpn.jump.2p.p2.v:
        cmp     byte [rdx + sitem64.DataType], '?'
        jne    .rpn.jump.2p.p2.v.o
        mov     byte [rdx + sitem64.DataType], 'o'  ; change data type of stack item
        jmp    .rpn.add.item
   .rpn.jump.2p.p2.v.o:
        cmp     byte [rdx + sitem64.DataType], 'o'
        je     .rpn.add.item
        retn

   .rpn.test.jump.vx:                           ; test variable number of label parameters
;       xor     rcx, rcx
;       mov     cx, [rsi + sitem64.ArgCount]
        movzx   rcx, word [rsi + sitem64.ArgCount]
        dec     rcx
        lea     rdx, [rdi - sizeof.sitem64]     ; rdx = parameter rpn item offset
        jmp    .rpn.test.jump.v.x

   .rpn.test.jump.v:                            ; test variable number of label parameters
;       xor     rcx, rcx
;       mov     cx, [rsi + sitem64.ArgCount]
        movzx   rcx, word [rsi + sitem64.ArgCount]
        lea     rdx, [rdi - sizeof.sitem64]     ; rdx = parameter rpn item offset
   .rpn.test.jump.v.x:
        add     rdx, sizeof.sitem64             ; rdi = current parameter rpn item offset
        cmp     byte [rdx + sitem64.ItemType], 'v'
        je     .rpn.jump.v.v
        cmp     byte [rdx + sitem64.ItemType], 'r'
        je     .rpn.jump.v.v
        jmp    .rpn.test.jump.v.retn
   .rpn.jump.v.v:
        cmp     byte [rdx + sitem64.DataType], '?'
        jne    .rpn.jump.v.v?
        mov     byte [rdx + sitem64.DataType], 'o'  ; change data type of stack item
        dec     rcx
        jnz    .rpn.test.jump.v.x
        jmp    .rpn.test.jump.v.add
   .rpn.jump.v.v?:
        cmp     byte [rdx + sitem64.DataType], 'o'
        je     .rpn.jump.v.v.o
        cmp     byte [rdx + sitem64.DataType], 'p'
        jne    .rpn.test.jump.v.retn
   .rpn.jump.v.v.p:
        mov     rax, [rdx + sitem64.Offset]
        test    rax, rax
        jz     .rpn.test.jump.v.retn
        mov     rax, [rax]
        test    rax, rax
        jnz    .rpn.test.jump.v.retn                ; accept only null pointers
        mov     [rdx + sitem64.Offset], rax
        mov     byte [rdx + sitem64.DataType], 'o'  ; change data type of stack item
   .rpn.jump.v.v.o:
        dec     rcx
        jnz    .rpn.test.jump.v.x
        jmp    .rpn.test.jump.v.add
   .rpn.test.jump.v.retn:
        retn
   .rpn.test.jump.v.add:
        jmp    .rpn.add.item

   .rpn.test.pjump:
        cmp     byte [rdi + sitem64.ItemType], 'v'
        je     .rpn.pjump.v
        cmp     byte [rdi + sitem64.ItemType], 'r'
        je     .rpn.pjump.v
        retn
   .rpn.pjump.v:
        cmp     byte [rdi + sitem64.DataType], 'p'
        je     .rpn.add.item
        retn

   .rpn.add.item:
        sub     rdi, sizeof.sitem64             ; rdi = current rpn item offset
        mov     bx, [rsi + sitem64.ItemType]
        mov     [rdi + sitem64.ItemType], bx
        mov     bx, [rsi + sitem64.ArgCount]
        mov     [rdi + sitem64.ArgCount], bx
        mov     bx, [rsi + sitem64.ReType]
        mov     [rdi + sitem64.ReType], bx
        mov     bx, [rsi + sitem64.Priority]
        mov     [rdi + sitem64.Priority], bx

    $ifdef _X64
        mov     rbx, [rsi + sitem64.Param]
        mov     [rdi + sitem64.Param], rbx
    $else
        mov     ebx, [esi + sitem32.Param + 4]
        mov     [edi + sitem32.Param + 4], ebx
        mov     ebx, [esi + sitem32.Param + 0]
        mov     [edi + sitem32.Param + 0], ebx
    $end

        inc     [.rpn.ic]                       ; increase rpn item count
        xor     rbx, rbx                        ; keep rbx = 0
        retn

   .rpn.bypass.item:
        xor     rbx, rbx                        ; keep rbx = 0
        retn

   .rpn.error:
        mov     rbx, rsp
        retn

   .rpn.error.memory:
        mov     [.ecode], SIC_ERROR_MEMORY
        mov     rbx, rsp
        retn

   .rpn.error.argument:
        mov     [.ecode], SIC_ERROR_ARGUMENT
        mov     rbx, rsp
        retn

   .rpn.error.no.impl:
        mov     [.ecode], SIC_ERROR_NO_IMPL
        mov     rbx, rsp
        retn
$endp

; -> tokens : c v r f F A 0
; <- eax    : code size
$sproc .code.build

        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz     @F
        stdcall conoun, [.rdata]
        test    rax, rax
        jnz    .cb.error                        ; error. undefined runtime items found
    @@:

        mov     rsi, [sic]                      ; rsi = T_sic_data structure offset

        mov     rdi, [rsi + T_sic_data.code]    ; rdi = code segment entry offset
        mov     [.cooff], rdi                   ; save code segment entry offset

;       mov     rsi, [.rpn]                     ; rsi = rpn array offset
        xor     rcx, rcx
        mov     ecx, [.rpn.ic]                  ; rcx = rpn item count
        test    rcx, rcx
        jz     .cb.error                        ; error. no rpn items
        mov     rsi, [.rpni]                    ; rsi = rpn[first-1] item offset

        ; verify code
        mov     rbx, rcx
        xor     rdx, rdx                        ; rdx = stack cursor
        mov     [.fuoff], rdx                   ; clear previous function offset
        mov     [.vargf], dl                    ; clear varg function flag
        mov     [.frecount], rdx                ; clear function return count

;      $align
   .cv.in:
        sub     rsi, sizeof.sitem64             ; rsi = current rpn item offset
        mov     al, byte [rsi + sitem64.ItemType]
;       cmp     al, 'c'
;       je     .cv.con
;       cmp     al, 'v'
;       je     .cv.var
;       cmp     al, 'r'
;       je     .cv.var
        cmp     al, 'f'
        je     .cv.fun
        cmp     al, 'F'
        je     .cv.fun
        cmp     al, 'A'
        je     .cv.out
        cmp     al, 0
        je     .cv.out
;  .cv.con:
;  .cv.var:
        mov     ax, [rsi + sitem64.DataType]    ; ax = data type
        cmp     ax, 'f2'
        je     .cv.f2
        inc     rdx                             ; token is constant or variable
        jmp    .cv.out
   .cv.f2:
        add     rdx, 2                          ; 2 variables
        jmp    .cv.out
   .cv.fun:
        movzx   rax, [rsi + sitem64.ArgCount]   ; rax = function argument count
        cmp     rdx, rax
        jl     .cb.error
        ;
        movsx   rax, [rsi + sitem64.ReType]     ; rax = function return type
        cmp     ax, 'i'                         ; ? integer function
        jne     @F
        mov     rax, 1
    @@:
        test    rax, rax
        jnz     @F
;       cmp     [.var.declare], 0
;       jnz     @F
        cmp     rbx, 1                          ; void function must be at first index
        jne    .cb.error
    @@:
        cmp     rax, 1
        jle     @F
        dec     rax
        add     rdx, rax
    @@:
        movzx   rax, [rsi + sitem64.ArgCount]   ; rax = function argument count
        dec     rax                             ; rax = function argument count - 1
        sub     rdx, rax
        cmp     rdx, 1
        jl     .cb.error                        ; error. invalid stack cursor
   .cv.out:
        dec     rbx
        jnz    .cv.in
        cmp     rdx, 1
        jl     .cb.error                        ; error. invalid stack cursor
;       jne    .cb.error                        ; error. invalid stack cursor
        mov     [.stack.cu], rdx

        ; build code
        xor     rbx, rbx
        mov     ebx, [.rpn.ic]                  ; rbx = rpn item count
        inc     rbx
        shl     rbx, 4                          ; rbx = ([rpn item count]+1) * 16
        mov     rax, [@_CFG.code_size]
        sub     rax, rbx                        ; rax = free bytes available for code
        mov     [.code.space], rax
        mov     [.cspace], rax                  ; [.cspace] = free bytes available for code

        mov     rsi, [.rpni]                    ; rsi = rpn[first-1] item offset
        mov     rbx, rcx                        ; rbx = rpn items counter
        xor     rax, rax                        ; rax = function call counter

        mov     [.FPU], 1                       ; use FPU
        mov     [.LSO], 0
        mov     [.RSP], 0

        mov     [.stack.frame.on], 0
        mov     [.stack.align.on], 0
        mov     [.locals.on], 0
        mov     [.fp.frame.on], 0

   .cb.enter.frame.test:
        mov     ecx, [.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .cb.enter.frame.in
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .cb.enter.frame.in
        ;
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_EXECUTE
        jnz    .cb.enter.frame
        test    rcx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .cb.enter.frame.out
   .cb.enter.frame:
        test    rcx, SIC_OPT_FLAG_STACK_FRAME
        jz     .cb.enter.frame.out
   .cb.enter.frame.in:
        mov     [.stack.frame.on], 1
        ; ---------------------------------------
        @@_ENTER_64                             ; stack frame
        ; ---------------------------------------
   .cb.enter.frame.out:

    $ifdef _X64
   .cb.enter.align.test:
        mov     ecx, [.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .cb.enter.align.out
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .cb.enter.align.out
        ;
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_EXECUTE
        jnz    .cb.enter.align
        test    rcx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .cb.enter.align.out
   .cb.enter.align:
        test    rcx, SIC_OPT_FLAG_STACK_FRAME
        jnz    .cb.enter.align.out
   .cb.enter.align.in:
        mov     [.stack.align.on], 1
        ; ---------------------------------------
        @@_PUSH_RAX                             ; 16-byte stack align
;       @@_ADD_RSP_m8                           ; 16-byte stack align
        ; ---------------------------------------
;       sub     [.RSP], 8                       ; !!! don't change [.RSP]
   .cb.enter.align.out:
    $end

   .cb.enter.locals.test:
        mov     ecx, [.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .cb.enter.locals.out
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .cb.enter.locals.out
        ;
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_EXECUTE
        jnz    .cb.enter.locals
        test    rcx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .cb.enter.locals.out
   .cb.enter.locals:
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

   .cb.enter.eflags.test:
        mov     rcx, [sop]
        test    rcx, SIC_OPT_FLAG_EXECUTE
        jnz    .cb.enter.eflags
        test    rcx, SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .cb.enter.eflags.out
   .cb.enter.eflags:
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

        mov     [.code.xsize], rdi

;      $align
   .cb.in:
        sub     rsi, sizeof.sitem64             ; rsi = current rpn item offset
        mov     cx, [rsi + sitem64.ItemType]
;       cmp     cl, 'c'
;       je     .cb.con
        cmp     cl, 'v'
        je     .cb.var
        cmp     cl, 'r'
        je     .cb.var
        cmp     cl, 'f'
        je     .cb.fun
        cmp     cl, 'F'
        je     .cb.fun
        cmp     cl, 'A'
        je     .cb.fun
        cmp     cl, 0
        je     .cb.out
   .cb.con:
        inc     [.ccount]                       ; increase constants count
        mov     cx, [rsi + sitem64.DataType]    ; cx = item data type
        case    cl,\
                'f', .cb.con.dou,\              ; double float
                'i', .cb.con.int,\              ; integer
                's', .cb.con.str                ; string
;               'p', .cb.con.ptr                ; pointer
;               'o', .cb.con.off                ; offset
        jmp    .cb.error
   .cb.con.dou:
        mov     byte [.LSO], 'f'
   .cb.con.dou.push:                            ; push double constant onto stack
        ; ---------------------------------------
        @@_PUSH_CF_64 (rsi + sitem64.Param)
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'cf'
        jmp    .cb.out
   .cb.con.int:
        mov     byte [.LSO], 'i'
        mov     rcx, [rsi + sitem64.Param]
   .cb.con.int.push:                            ; push integer constant onto stack
        ; ---------------------------------------
        @@_PUSH_CI_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'ci'
        jmp    .cb.out
   .cb.con.str:
        mov     byte [.LSO], 's'
        mov     rcx, [rsi + sitem64.Param]
   .cb.con.str.push:                            ; push string constant onto stack
        ; ---------------------------------------
        @@_PUSH_CS_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'cs'
        jmp    .cb.out
; ------
   .cb.var:
        inc     [.vcount]                       ; increase variables count
        mov     dx, [rsi + sitem64.DataType]    ; dx = item data type
        case    dx,\
                'f1', .cb.var.f1,\              ; 1 double float
                'i1', .cb.var.i1,\              ; 1 integer
                's1', .cb.var.s1,\              ; 1 string
                'f2', .cb.var.f2                ; 2 double floats
        case    dl,\
                'f', .cb.var.dou,\              ; double float
                'i', .cb.var.int,\              ; integer
                's', .cb.var.str,\              ; string
                'p', .cb.var.ptr,\              ; pointer
                'o', .cb.var.off,\              ; offset
                'a', .cb.var.add                ; address
        jmp    .cb.error
        ;
   .cb.var.dou:
        mov     byte [.LSO], 'f'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.dou.push:                            ; push double variable onto stack
        ; ---------------------------------------
        @@_PUSH_VF_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vf'
        jmp    .cb.out
        ;
   .cb.var.int:
        mov     byte [.LSO], 'i'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.int.push:                            ; push integer variable onto stack
        ; ---------------------------------------
        @@_PUSH_VI_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vi'
        jmp    .cb.out
        ;
   .cb.var.str:
        mov     byte [.LSO], 's'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.str.push:                            ; push string variable onto stack
        ; ---------------------------------------
        @@_PUSH_VS_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vs'
        jmp    .cb.out
        ;
   .cb.var.ptr:
        mov     byte [.LSO], 'p'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.ptr.push:                            ; push pointer constant onto stack
        ; ---------------------------------------
        @@_PUSH_CP_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vp'
        jmp    .cb.out
        ;
   .cb.var.off:
        mov     byte [.LSO], 'o'
        mov     rcx, [rsi + sitem64.Param]
   .cb.var.off.push:                            ; push offset onto stack
        ; ---------------------------------------
        @@_PUSH_O_64 rcx
        ; ---------------------------------------
;       sub     [.RSP], 0
       .arg.set rcx, 'vo'
        jmp    .cb.out
        ;
   .cb.var.add:
        mov     byte [.LSO], 'a'
        mov     rcx, [rsi + sitem64.Param]
   .cb.var.add.push:                            ; push pointer onto stack
        ; ---------------------------------------
        @@_PUSH_A_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'va'
        jmp    .cb.out
        ;
   .cb.var.f1:
        mov     [.LSO], 'f1'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.f1.push:                             ; push 1 double variable onto stack
        ; ---------------------------------------
        @@_PUSH_VF_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vf'
        jmp    .cb.out
        ;
   .cb.var.i1:
        mov     [.LSO], 'i1'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.i1.push:                             ; push 1 integer onto stack
        ; ---------------------------------------
        @@_PUSH_VI_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vi'
        jmp    .cb.out
        ;
   .cb.var.s1:
        mov     [.LSO], 's1'
        mov     rcx, [rsi + sitem64.Param]
   .cb.var.s1.push:                             ; push string variable onto stack
        ; ---------------------------------------
        @@_PUSH_VS_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 8
       .arg.set rcx, 'vs'
        jmp    .cb.out
        ;
   .cb.var.f2:
        mov     [.LSO], 'f2'
        mov     rcx, [rsi + sitem64.Param]
        test    rcx, rcx
        jz     .cb.error.argument
        mov     rcx, [rcx]
   .cb.var.f2.push:                             ; push 2 double variables onto stack
        ; ---------------------------------------
        @@_PUSH_VF2_64 rcx
        ; ---------------------------------------
        sub     [.RSP], 16
       .arg.set rcx, 'vf', 'vf'
        jmp    .cb.out
; ------
   .cb.fun:                                     ; function call
        inc     [.fcount]                       ; increase functions count
        inc     rax                             ; increase function call counter
        mov     byte [.LSO], 0
        movzx   rcx, [rsi + sitem64.ArgCount]   ; rcx = function actual argument count
        mov     rdx, [rsi + sitem64.Param]      ; rdx = function item offset
   .cb.fun.call:
        ; ---------------------------------------
        @@_CALL_64 rdx
        ; ---------------------------------------
        cmp     [.fbypass], 0
        jz     .cb.fun.result
   .cb.fun.bypass:
        dec     rax                             ; decrease function call counter
        jmp    .cb.out
   .cb.fun.result:
        movzx   rcx, [rsi + sitem64.ArgCount]   ; rcx = function actual argument count
        sub     [.arg.count], rcx
        shl     rcx, 1                          ; rcx*2
        sub     [.arg.cursor], rcx
        ;
        mov     ecx, [.cotype]
   .cb.fun.?x:
        test    ecx, ecx
        jz     .cb.fun.?x.out
   .cb.fun.?dx:
        case    ecx,\
                'dcon', .cb.fun.dx,\
                'dvar', .cb.fun.dx
        jmp    .cb.fun.?dx.out
   .cb.fun.dx:
        dec     rax                             ; decrease function call counter
        mov     byte [.LSO], 'f'
        sub     [.RSP], 8
       .arg.set rcx, '?f'
        jmp    .cb.out
   .cb.fun.?dx.out:
        ;
   .cb.fun.?ix:
        case    ecx,\
                'icon', .cb.fun.ix,\
                'ivar', .cb.fun.ix
        jmp    .cb.fun.?ix.out
   .cb.fun.ix:
        dec     rax                             ; decrease function call counter
        mov     byte [.LSO], 'i'
        sub     [.RSP], 8
       .arg.set rcx, '?i'
        jmp    .cb.out
   .cb.fun.?ix.out:
        ;
   .cb.fun.?sx:
        case    ecx,\
                'scon', .cb.fun.sx,\
                'svar', .cb.fun.sx
        jmp    .cb.fun.?sx.out
   .cb.fun.sx:
        dec     rax                             ; decrease function call counter
        mov     byte [.LSO], 's'
        sub     [.RSP], 8
       .arg.set rcx, '?s'
        jmp    .cb.out
   .cb.fun.?sx.out:
        ;
   .cb.fun.?px:
        cmp     ecx, 'pcon'
        jne    .cb.fun.?px.out
;       case    ecx,\
;               'pcon', .cb.fun.px,\
;               'pvar', .cb.fun.px
;       jmp    .cb.fun.?px.out
   .cb.fun.px:
        dec     rax                             ; decrease function call counter
        mov     byte [.LSO], 'p'
        sub     [.RSP], 8
       .arg.set rcx, '?p'
        jmp    .cb.out
   .cb.fun.?px.out:
   .cb.fun.?x.out:
        ;
        cmp     [.firesp], 1                    ; ? function integer result in RSP
        je     .cb.fun.rt.iresp
    $ifdef _X32
        cmp     [.fi2resp], 1                   ; ? function 2-integer result in ESP
        je     .cb.fun.rt.i2resp
    $end
        cmp     rbx, 1
        je     .cb.out
        cmp     [.FPU], 0
        jz     .cb.out
        jmp    .cb.fun.rt.x
        ;
   .cb.fun.rt.iresp:
       .arg.set rcx, '?i'
        jmp    .cb.out
        ;
    $ifdef _X32
   .cb.fun.rt.i2resp:
       .arg.set rcx, '?i', '?i'
        jmp    .cb.out
    $end
        ;
   .cb.fun.rt.x:
        mov     dx, [rsi + sitem64.ReType]      ; dx = function return type
        cmp     dx, 0
        jle    .cb.out
        case    dx,\
                1, .cb.fun.rt.1,\
                2, .cb.fun.rt.2,\
                3, .cb.fun.rt.3,\
                4, .cb.fun.rt.4
        jmp    .cb.error
   .cb.fun.rt.4:
    $ifdef _SSEX
        @@_MOVSD_QW_RSP_RT4
    $else
        @@_FSTP_QW_RSP_RT4                      ; pop function call result from FPU stack
    $end
       .arg.set rcx, '?f', '?f', '?f', '?f'
        jmp    .cb.out
        ; ---------------------------------------
   .cb.fun.rt.3:
    $ifdef _SSEX
        @@_MOVSD_QW_RSP_RT3
    $else
        @@_FSTP_QW_RSP_RT3                      ; pop function call result from FPU stack
    $end
       .arg.set rcx, '?f', '?f', '?f'
        jmp    .cb.out
        ; ---------------------------------------
   .cb.fun.rt.2:
    $ifdef _SSEX
        @@_MOVSD_QW_RSP_RT2
    $else
        @@_FSTP_QW_RSP_RT2                      ; pop function call result from FPU stack
    $end
       .arg.set rcx, '?f', '?f'
        jmp    .cb.out
        ; ---------------------------------------
   .cb.fun.rt.1:
    $ifdef _SSEX
        @@_MOVSD_QW_RSP_RT1
    $else
        @@_FSTP_QW_RSP_RT1                      ; pop function call result from FPU stack
    $end
       .arg.set rcx, '?f'
;       jmp    .cb.out
        ; ---------------------------------------
   .cb.out:
        dec     rbx
        jnz    .cb.in

        sub     [.code.xsize], rdi              ; [.code.xsize] - negative or zero

        mov     ecx, [.rcode]
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .cb.out.rcode.assign
        jmp    .cb.out.main

   .cb.out.rcode.assign:
        cmp     [.code.xsize], 0
        jnz    .cb.error
;       jmp    .cb.out.main

   .cb.out.main:
        cmp     [.code.xsize], 0
        jz     .cb.leave.main

        test    rax, rax                        ; rax = function call counter
        jnz    .cb.leave

   .cb.out.X:
        mov     [.frecount], 1                  ; no functions. expression consists
        mov     rdx, [.stack.cu]                ; of single constant or variable
        mov     ax, [.LSO]
        cmp     ax, 'f2'
        je     .cb.out.F2
        cmp     al, 'f'
        je     .cb.out.F
        cmp     al, 'i'
        je     .cb.out.I
        cmp     al, 's'
        je     .cb.out.P
        cmp     al, 'p'
        je     .cb.out.P
        cmp     al, 'o'
        je     .cb.out.P
        cmp     al, 'a'
        je     .cb.out.P
        jmp    .cb.leave.main
   .cb.out.P:
        cmp     rdx, 1
        jne    .cb.error
        ; ---------------------------------------
    $ifdef _SSEX
        @@_XORPD_XMM0_XMM0                      ;
    $else
        @@_FLDZ                                 ;
    $end
        @@_ADD_RSP_8                            ;
        ; ---------------------------------------
        add     [.RSP], 8
        jmp    .cb.leave.main
   .cb.out.I:
        cmp     rdx, 1
        jne    .cb.error
        ; ---------------------------------------
    $ifdef _SSEX
        @@_CVTSI2SD_XMM0_QW_RSP                 ;
    $else
        @@_FILD_QW_RSP                          ;
    $end
        @@_ADD_RSP_8                            ;
        ; ---------------------------------------
        add     [.RSP], 8
        jmp    .cb.leave.main
   .cb.out.F:
        cmp     rdx, 1
        jne    .cb.error
        ; ---------------------------------------
    $ifdef _SSEX
        @@_MOVSD_XMM0_QW_RSP                    ;
    $else
        @@_FLD_QW_RSP                           ;
    $end
        @@_ADD_RSP_8                            ;
        ; ---------------------------------------
        add     [.RSP], 8
        jmp    .cb.leave.main
   .cb.out.F2:
        cmp     rdx, 2
        jne    .cb.error
        ; ---------------------------------------
    $ifdef _SSEX
        @@_MOVSD_XMM0_QW_RSP                    ;
    $else
        @@_FLD_QW_RSP                           ;
    $end
        @@_ADD_RSP_16                           ;
        ; ---------------------------------------
        add     [.RSP], 16
        jmp    .cb.leave.main

   .cb.leave:

        cmp     [.frecount], 0
        jle    .cb.leave.main
        mov     rdx, [.stack.cu]
        cmp     rdx, [.frecount]
        jne    .cb.error
        ;
        cmp     rdx, 1
        jle    .cb.leave.main
        lea     rdx, [rdx * 8 - 8]
        @@_ADD_RSP_RDX

   .cb.leave.main:

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
        add     [.RSP], 8
   .cb.leave.align.out:
    $end

        ; DEBUG
        ; ---------------------------------------
;       @@_MOV_EBX [.RSP]
        ; ---------------------------------------

   .cb.leave.eflags.off.test:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .cb.leave.eflags.off.out
        ;
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

    $ifdef _SSEX
   .cb.leave.ffree.test:
        mov     rcx, [sop]
   .cb.leave.ffree.test.optimization.in:
        test    rcx, SIC_OPT_FLAG_DEBUG
        jnz    .cb.leave.ffree.test.optimization.out
        test    rcx, SIC_OPT_FLAG_OPTIMIZATION
        jz     .cb.leave.ffree.out
   .cb.leave.ffree.test.optimization.out:
        test    rcx, SIC_OPT_FLAG_EXTERNAL_CALL
        jz     .cb.leave.ffree.out
        ;
        mov     ecx, [.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .cb.leave.ffree.out
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .cb.leave.ffree.out
        ;
        cmp     [.code.xsize], 0
        jz     .cb.leave.ffree.out
        cmp     [.FPU], 0
        jz     .cb.leave.ffree.out
   .cb.leave.ffree.in:
        ; ---------------------------------------
        @@_FFREE_ST0                            ; free FPU stack (compiler directive)
        ; ---------------------------------------
   .cb.leave.ffree.out:
    $else
   .cb.leave.fstp.test:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jz     .cb.leave.fstp.out
        ;
        mov     ecx, [.rcode]
        test    ecx, RCODE_FLAG_DECLARE
        jnz    .cb.leave.fstp.out
        test    ecx, RCODE_FLAG_ASSIGN
        jnz    .cb.leave.fstp.out
        ;
        cmp     [.code.xsize], 0
        jz     .cb.leave.fstp.out
        cmp     [.FPU], 0
        jz     .cb.leave.fstp.out
   .cb.leave.fstp.in:
        dec     [.frecount]
        ; ---------------------------------------
        @@_FSTP_ST0                             ; clear FPU stack
        ; ---------------------------------------
        cmp     [.frecount], 0
        jg     .cb.leave.fstp.in
   .cb.leave.fstp.out:
    $end

   .cb.leave.return.test:
        test    [sop], SIC_OPT_FLAG_EXTERNAL_CALL
        jnz    .cb.leave.return.out
   .cb.leave.return.in:
        ; ---------------------------------------
        @@_RET                                  ; return
        ; ---------------------------------------
   .cb.leave.return.out:

   .cb.test:
        cmp     [.cspace], 0
        jl     .cb.error                        ; error. code size greater than buffer

   .cb.success:
        mov     rax, rdi                        ; rax = current code offset
        mov     rdx, [sic]                      ; rdx = T_sic_data structure offset
        sub     rax, [rdx + T_sic_data.code]    ; eax = code size (result)
        retn

   .cb.error:
        mov     [.ecode], SIC_ERROR_CODE_BUILD
        xor     rax, rax
        retn

   .cb.error.memory:
        mov     [.ecode], SIC_ERROR_MEMORY
        xor     rax, rax
        retn

   .cb.error.argument:
        mov     [.ecode], SIC_ERROR_ARGUMENT
        xor     rax, rax
        retn

   .cb.error.evaluate:
        mov     [.ecode], SIC_ERROR_EVALUATE
        xor     rax, rax
        retn

   .cb.error.no.impl:
        mov     [.ecode], SIC_ERROR_NO_IMPL
        xor     rax, rax
        retn

   .cb.error.pointer:
        mov     [.ecode], SIC_ERROR_POINTER
        xor     rax, rax
        retn
$endp

$endp

; ------------------------------------------------------------------------------
