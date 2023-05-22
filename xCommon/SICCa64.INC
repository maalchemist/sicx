
; FASM SOURCE FILE
; http://flatassembler.net

; <SI>mple <C>ompiler
; function call compiler macros

; Copyright © 2000-3000, Andrey A. Meshkov (AL-CHEMIST)
; All rights reserved
;
; http://maalchemist.ru
; http://maalchemist.narod.ru
; maa@maalchemist.ru
; maalchemist@yandex.ru
; maalchemist@gmail.com

; ------------------------------------------------------------------------------

DEFINE SIC_FORCE_ASSIGN FALSE ; TRUE ;

; ------------------------------------------------------------------------------

; function call (absolute indirect)
; -> fio : function item offset
; -> rcx : function actual argument count
macro @@_CALL_64 fio
{
        local  .vararg, .fixarg, .inline, .call, .done, .stack, .bypass.exit, .exit
        local  .error.exit, .error.memory, .error.argument, .error.evaluate, .error.no.impl

        push    rax rsi

        mov     [.FPU], 1                       ; use FPU

        xor     rax, rax
;       mov     [.SPD], eax
        mov     [.mode], rax
        mov     [.fpatype], ax
        mov     [.cotype], eax
        mov     [.int.bytes], al
        mov     [.proc.mode], al
        mov     [.neg], al
        mov     [.firesp], al
        mov     [.fi2resp], al
        mov     [.fbypass], al
        mov     [.external], al
        mov     [.stdcall], al
        mov     [.dynamic], al
        mov     [.coshift], rax

        mov     [.P.count], eax

        xor     r15, r15                        ; r15 = 0 - additional stack delta
        mov     [.SAF], r15d                    ; clear stack align flag

    if ~ fio in < edx, rdx >
        mov     rdx, qword fio                  ; rdx = function item offset
    end if

        mov     rsi, [rdx + fitem64.offset]     ; rsi = function entry offset
        mov     [.fuoff], rsi                   ; save function entry offset

        mov     [.ezx], rcx                     ; [.ezx] = function actual argument count

        movsx   rax, [rdx + fitem64.retype]
        mov     [.fretype], ax                  ; [.fretype] = function return type
        mov     [.frecount], rax                ; [.frecount] = function return count
        cmp     ax, 'i'                         ; ? integer function
        jne     @F
        mov     [.frecount], 1
        mov     [.firesp], 1
    @@:

        mov     ax, [rdx + fitem64.acount]
        mov     [.facount], ax                  ; [.facount] = function argument count

        movzx   rax, [rdx + fitem64.cosize]     ; ax = function code size or flags

   .f.dynamic?:
        test    ax, 0010000000000000b
        jz     .f.dynamic?.out
   .f.dynamic:                                  ; dynamic function
        mov     [.dynamic], 1
   .f.dynamic?.out:

    $ifdef _X32
   .f.stdcall?:
        test    ax, 0100000000000000b
        jz     .f.stdcall?.out
   .f.stdcall:                                  ; stdcall function
        mov     [.stdcall], 1
   .f.stdcall?.out:
    $end

   .f.external?:
        test    ax, 1000000000000000b
        jz     .f.external?.out
   .f.external:                                 ; external function ; cosize = function flags
        mov     [.external], 1
   .f.external?.out:

        cmp     [.facount], -1
        jg     .fixarg

        cmp     [.vargf], 0
        jz     .vararg
   .varg.x:
        cmp     [.external], 0
        jnz    .error.exit

        pcase   rsi,\
                @@addr         , .error.exit,\
                @@assign       , .error.exit,\
                @@reassign     , .error.exit
        pcase   rsi,\
                @@vcopy        , .error.exit,\
                @@vcopx        , .error.exit
        pcase   rsi,\
                @@swapr        , .error.exit,\
                @@swapl        , .error.exit
        pcase   rsi,\
                @@if.or        , .error.exit,\
                @@if.nor       , .error.exit,\
                @@if.and       , .error.exit,\
                @@if.nand      , .error.exit
        pcase   rsi,\
                @@ie.or        , .error.exit,\
                @@ie.nor       , .error.exit,\
                @@ie.and       , .error.exit,\
                @@ie.nand      , .error.exit
        pcase   rsi,\
                @@case.e       , .error.exit,\
                @@rcase.e      , .error.exit,\
                @@case.ne      , .error.exit,\
                @@rcase.ne     , .error.exit,\
                @@case.a       , .error.exit,\
                @@rcase.a      , .error.exit,\
                @@case.ae      , .error.exit,\
                @@rcase.ae     , .error.exit,\
                @@case.b       , .error.exit,\
                @@rcase.b      , .error.exit,\
                @@case.be      , .error.exit,\
                @@rcase.be     , .error.exit
        pcase   rsi,\
                @@goto.if.or   , .error.exit,\
                @@goto.if.nor  , .error.exit,\
                @@goto.if.and  , .error.exit,\
                @@goto.if.nand , .error.exit
        pcase   rsi,\
                @@calls        , .error.exit,\
                @@rcalls       , .error.exit
        pcase   rsi,\
                @@call.if.or   , .error.exit,\
                @@call.if.nor  , .error.exit,\
                @@call.if.and  , .error.exit,\
                @@call.if.nand , .error.exit,\
                @@call.ie.or   , .error.exit,\
                @@call.ie.nor  , .error.exit,\
                @@call.ie.and  , .error.exit,\
                @@call.ie.nand , .error.exit
        pcase   rsi,\
                @@co.vminmax   , .error.exit,\
                @@co.vmaxmin   , .error.exit,\
                @@vncycle      , .error.exit,\
                @@vnstep       , .error.exit,\
                @@vpoly        , .error.exit
        pcase   rsi,\
                @@matrip       , .error.exit,\
                @@matrip.rc    , .error.exit
        pcase   rsi,\
                @@vcount       , .inline.vcount.varg
        jmp    .vararg.out
   .vararg:                                             ; variable number of arguments
        @@bound 10, .error.memory                       ; store argument count in r13 register
        mov     [rdi + 0], word 0xBD49
        mov     [rdi + 2], rcx
        add     rdi, 10
        ; ----------------------------------------------
        ; MOV   R13, ACOUNT     | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;-MOV   RCX, ACOUNT     | 48B9 FFFFFFFFFFFFFFFF ; argument count (10B)
        ; ----------------------------------------------
   .vararg.out:
        jmp     .xarg

   .fixarg:                                             ; fixed number of arguments
        cmp     [.vargf], 0
        jnz    .error.exit

   .xarg:
        cmp     [.external], 0
        jnz    .call

   .inline:                                             ; copy function code
        and     rax, 0xFF                               ; clear native function flags
        stdcall code_object, [.cooff], 0                ; ecx = object type

        mov     [.vargf], 0                             ; clear varg function flag
        cmp     [.facount], 0
        jz     .inline.fixarg.0p
        cmp     [.facount], 1
        je     .inline.fixarg.1p
        cmp     [.facount], 2
        je     .inline.fixarg.2p
        cmp     [.facount], 3
        je     .inline.fixarg.3p
        cmp     [.facount], -1
        jg     .inline.fixarg.4p
   .inline.vararg:                                      ; variable number of arguments
        pcase   rsi,\
                @@varg.z        , .inline.varg,\
                @@varg.nz       , .inline.varg,\
                @@varg.az       , .inline.varg,\
                @@varg.aez      , .inline.varg,\
                @@varg.bz       , .inline.varg,\
                @@varg.bez      , .inline.varg,\
                @@varg.e        , .inline.varg,\
                @@varg.ne       , .inline.varg,\
                @@varg.a        , .inline.varg,\
                @@varg.ae       , .inline.varg,\
                @@varg.b        , .inline.varg,\
                @@varg.be       , .inline.varg

        pcase   rsi,\
                @@vcount        , .inline.vcount
        pcase   rsi,\
                @@assign        , .inline.assign,\
                @@reassign      , .inline.reassign
        pcase   rsi,\
                @@vcopy         , .inline.vcopy,\
                @@vcopx         , .inline.vcopx
        pcase   rsi,\
                @@swapr         , .inline.swapr,\
                @@swapl         , .inline.swapl
        pcase   rsi,\
                @@co.vminmax    , .inline.x2copyDV,\
                @@co.vmaxmin    , .inline.x2copyDV
        pcase   rsi,\
                @@goto.if.or    , .inline.jump.v,\
                @@goto.if.nor   , .inline.jump.v,\
                @@goto.if.and   , .inline.jump.v,\
                @@goto.if.nand  , .inline.jump.v
        pcase   rsi,\
                @@calls         , .inline.calls,\
                @@rcalls        , .inline.rcalls
        pcase   rsi,\
                @@call.if.or    , .inline.jump.v,\
                @@call.if.nor   , .inline.jump.v,\
                @@call.if.and   , .inline.jump.v,\
                @@call.if.nand  , .inline.jump.v,\
                @@call.ie.or    , .inline.jump.v.2p,\
                @@call.ie.nor   , .inline.jump.v.2p,\
                @@call.ie.and   , .inline.jump.v.2p,\
                @@call.ie.nand  , .inline.jump.v.2p
        pcase   rsi,\
                @@matrip        , .inline.matrip,\
                @@matrip.rc     , .inline.matrip
        pcase   rsi,\
                @@return          , .error.exit,\       ; @@return -> @@exit or @@.returnv
                @@return.if.true  , .error.exit,\       ; @@return.if.true -> @@exit.if.true or @@.returnv.if.true
                @@return.if.false , .error.exit         ; @@return.if.false -> @@exit.if.false or @@.returnv.if.false
        jmp    .inline.proc

   .inline.varg:
        mov     [.vargf], 1                     ; set varg function flag
        jmp    .inline.arg.filter

   .inline.fixarg.0p:                           ; fixed number of arguments ; no arguments
        cmp     [.frecount], 0
        jz     .inline.fixarg.0p.nr
   .inline.fixarg.0p.rr:                        ; fixed number of arguments ; no arguments ; returns result
        pcase   rsi,\
                @@fldz          , .inline.proc,\
                @@fld1          , .inline.proc,\
                @@fldpi         , .inline.proc,\
                @@fldl2t        , .inline.proc,\
                @@fldl2e        , .inline.proc,\
                @@fldlg2        , .inline.proc,\
                @@fldln2        , .inline.proc,\
                @@nan           , .inline.proc,\
                @@nanu          , .inline.proc,\
                @@pinf          , .inline.proc,\
                @@ninf          , .inline.proc,\
                @@peps          , .inline.proc,\
                @@neps          , .inline.proc,\
                @@maxd          , .inline.proc,\
                @@mind          , .inline.proc
        pcase   rsi,\
                @@is.x32        , .inline.is.x32,\
                @@is.n32        , .inline.is.n32,\
                @@is.x64        , .inline.is.x64,\
                @@is.n64        , .inline.is.n64,\
                @@dll.bits      , .inline.dll.bits
        pcase   rsi,\
                @@result.get    , .inline.proc
        jmp    .inline.proc.0p.rr
   .inline.fixarg.0p.nr:                        ; fixed number of arguments ; no arguments ; no result
        pcase   rsi,\
                @@proc.begin    , .inline.asm.instruction,\
                @@proc.end      , .inline.asm.instruction
        pcase   rsi,\
                @@int3          , .inline.asm.instruction,\
                @@int.3         , .inline.asm.instruction
        pcase   rsi,\
                @@finit         , .inline.fpu.instruction,\
                @@fninit        , .inline.fpu.instruction,\
                @@fclex         , .inline.fpu.instruction,\
                @@fnclex        , .inline.fpu.instruction,\
                @@fstp          , .inline.fpu.instruction
        pcase   rsi,\
                @@retn          , .inline.retn
        pcase   rsi,\
                @@exit          , .inline.exit
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.1p:                           ; fixed number of arguments ; 1 argument
        cmp     [.frecount], 0
        jz     .inline.fixarg.1p.nr
   .inline.fixarg.1p.rr:                        ; fixed number of arguments ; 1 argument ; returns result
        pcase   rsi,\
                @@sizeof        , .inline.sizeof
        pcase   rsi,\
                @@.addr.1P      , .inline.addr.1P,\
                @@saddr         , .inline.saddr
        pcase   rsi,\
                @@result.set    , .inline.result.set
        pcase   rsi,\
                @@pdouble       , .inline.pvalue,\
                @@pint          , .inline.pvalue,\
                @@pstr          , .inline.pvalue,\
                @@pint64        , .inline.pvalue
        pcase   rsi,\
                @@pcomplex      , .inline.pcomplex
        pcase   rsi,\
                @@vfloat        , .inline.vdouble,\
                @@vdouble       , .inline.vdouble,\
                @@vcomplex      , .inline.vcomplex,\
                @@vint          , .inline.vinteger,\
                @@vinteger      , .inline.vinteger,\
                @@vstr          , .inline.vstring,\
                @@vstring       , .inline.vstring
        pcase   rsi,\
                @@.double       , .inline.double
        pcase   rsi,\
                @@.int          , .inline.int64,\
                @@.int64        , .inline.int64
        pcase   rsi,\
                @@covalue       , .inline.covalue,\
                @@restore       , .inline.restore
        pcase   rsi,\
                @@inc.pre       , .inline.inc.pre,\
                @@inc.post      , .inline.inc.post,\
                @@dec.pre       , .inline.dec.pre,\
                @@dec.post      , .inline.dec.post
        pcase   rsi,\
                @@setz          , .inline.setz,\
                @@set1          , .inline.set1,\
                @@int           , .inline.int,\
                @@frac          , .inline.frac,\
                @@round         , .inline.round,\
                @@factln        , .inline.factln,\
                @@fact          , .inline.fact,\
                @@fact2         , .inline.fact2
        pcase   rsi,\
                @@trunc         , .inline.trunc
;       pcase   rsi,\
;               @@isign         , .inline.isign,\
;               @@risign        , .inline.risign,\
;               @@trunc         , .inline.trunc
        pcase   rsi,\
                @@sign          , .inline.sign,\
                @@rsign         , .inline.rsign,\
                @@chs           , .inline.chs,\
                @@abs           , .inline.abs,\
                @@nabs          , .inline.nabs,\
                @@inc           , .inline.inc,\
                @@dec           , .inline.dec,\
                @@nzero         , .inline.nzero,\
                @@rnzero        , .inline.rnzero,\
                @@pos           , .inline.pos,\
                @@neg           , .inline.neg,\
                @@inv           , .inline.inv
        pcase   rsi,\
                @@ot            , .inline.ot,\
                @@not           , .inline.not,\
                @@if.true       , .inline.if.true,\
                @@if.false      , .inline.if.false,\
                @@if.z          , .inline.if.z,\
                @@if.nz         , .inline.if.nz,\
                @@if.az         , .inline.if.az,\
                @@if.aez        , .inline.if.aez,\
                @@if.bz         , .inline.if.bz,\
                @@if.bez        , .inline.if.bez
        pcase   rsi,\
                @@bsf           , .inline.bsf,\
                @@bsr           , .inline.bsr,\
                @@hammw         , .inline.hammw,\
                @@bnot          , .inline.bnot,\
                @@bswap         , .inline.bswap,\
                @@b4swap        , .inline.b4swap,\
                @@b2swap        , .inline.b2swap,\
                @@bitswap       , .inline.bitswap,\
                @@bit32swap     , .inline.bit32swap,\
                @@bit16swap     , .inline.bit16swap,\
                @@bit8swap      , .inline.bit8swap
        pcase   rsi,\
                @@.mul.2pi      , .inline.mul.2pi,\
                @@.mul.pi       , .inline.mul.pi,\
                @@.mul.pi2      , .inline.mul.pi2,\
                @@.mul.pi4      , .inline.mul.pi4,\
                @@.div.2pi      , .inline.div.2pi,\
                @@.div.pi       , .inline.div.pi,\
                @@.div.pi2      , .inline.div.pi2,\
                @@.div.pi4      , .inline.div.pi4,\
                @@.quo.2pi      , .inline.quo.2pi,\
                @@.quo.pi       , .inline.quo.pi,\
                @@.quo.pi2      , .inline.quo.pi2,\
                @@.quo.pi4      , .inline.quo.pi4,\
                @@.mod.2pi      , .inline.mod.2pi,\
                @@.mod.pi       , .inline.mod.pi,\
                @@.mod.pi2      , .inline.mod.pi2,\
                @@.mod.pi4      , .inline.mod.pi4
        pcase   rsi,\
                @@bit           , .inline.bit,\
                @@nibble        , .inline.nibble,\
                @@byte          , .inline.byte,\
                @@word          , .inline.word,\
                @@dword         , .inline.dword,\
                @@qword         , .inline.qword,\
                @@nword         , .inline.nword,\
                @@tword         , .inline.tword,\
                @@xword         , .inline.xword,\
                @@oword         , .inline.oword,\
                @@yword         , .inline.yword,\
                @@zword         , .inline.zword
        pcase   rsi,\
                @@kibi          , .inline.kibi,\
                @@mebi          , .inline.mebi,\
                @@gibi          , .inline.gibi,\
                @@tebi          , .inline.tebi,\
                @@pebi          , .inline.pebi,\
                @@exbi          , .inline.exbi,\
                @@zebi          , .inline.zebi,\
                @@yobi          , .inline.yobi
        pcase   rsi,\
                @@kibo          , .inline.kibo,\
                @@mebo          , .inline.mebo,\
                @@gibo          , .inline.gibo,\
                @@tebo          , .inline.tebo,\
                @@pebo          , .inline.pebo,\
                @@exbo          , .inline.exbo,\
                @@zebo          , .inline.zebo,\
                @@yobo          , .inline.yobo
        pcase   rsi,\
                @@deca          , .inline.deca,\
                @@hecto         , .inline.hecto,\
                @@kilo          , .inline.kilo,\
                @@mega          , .inline.mega,\
                @@giga          , .inline.giga,\
                @@tera          , .inline.tera,\
                @@peta          , .inline.peta,\
                @@exa           , .inline.exa,\
                @@zetta         , .inline.zetta,\
                @@yotta         , .inline.yotta
        pcase   rsi,\
                @@deci          , .inline.deci,\
                @@centi         , .inline.centi,\
                @@milli         , .inline.milli,\
                @@micro         , .inline.micro,\
                @@nano          , .inline.nano,\
                @@pico          , .inline.pico,\
                @@femto         , .inline.femto,\
                @@atto          , .inline.atto,\
                @@zepto         , .inline.zepto,\
                @@yocto         , .inline.yocto
        pcase   rsi,\
                @@co.chs        , .inline.co.chs,\
                @@co.abs        , .inline.co.abs,\
                @@co.nabs       , .inline.co.nabs,\
                @@co.rcopy      , .inline.co.rcopy,\
                @@co.rxcopy     , .inline.co.rcopy
        pcase   rsi,\
                @@co.bnot       , .inline.co.bnot
        pcase   rsi,\
                @@.1D.1P.matrip , .inline.matrip
        jmp    .inline.proc.1p.rr
   .inline.fixarg.1p.nr:                        ; fixed number of arguments ; 1 argument ; no result
        pcase   rsi,\
                @@goto          , .inline.jump
        pcase   rsi,\
                @@goto.if.x32   , .inline.jump,\
                @@goto.if.n32   , .inline.jump,\
                @@goto.if.x64   , .inline.jump,\
                @@goto.if.n64   , .inline.jump
        pcase   rsi,\
                @@call          , .inline.jump
        pcase   rsi,\
                @@call.if.x32   , .inline.jump,\
                @@call.if.n32   , .inline.jump,\
                @@call.if.x64   , .inline.jump,\
                @@call.if.n64   , .inline.jump
        pcase   rsi,\
                @@fstsw         , .inline.fstxw,\
                @@fnstsw        , .inline.fstxw,\
                @@fstef         , .inline.fstxw,\
                @@fnstef        , .inline.fstxw,\
                @@fstcw         , .inline.fstxw,\
                @@fnstcw        , .inline.fstxw
        pcase   rsi,\
                @@fldcw         , .inline.fldxw,\
                @@fmaske        , .inline.fldxw,\
                @@fnmaske       , .inline.fldxw
        pcase   rsi,\
                @@exit.if.true  , .inline.exit.if,\
                @@exit.if.false , .inline.exit.if
        pcase   rsi,\
                @@.returnv      , .inline.return
        pcase   rsi,\
                @@reset         , .inline.restore
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.2p:                           ; fixed number of arguments ; 2 arguments
        cmp     [.frecount], 0
        jz     .inline.fixarg.2p.nr
   .inline.fixarg.2p.rr:                        ; fixed number of arguments ; 2 arguments ; returns result
        pcase   rsi,\
                @@add           , .inline.add,\
                @@add.pos       , .inline.add.pos,\
                @@add.neg       , .inline.add.neg,\
                @@sub           , .inline.sub,\
                @@sub.pos       , .inline.sub.pos,\
                @@sub.neg       , .inline.sub.neg,\
                @@subr          , .inline.subr,\
                @@subr.pos      , .inline.subr.pos,\
                @@subr.neg      , .inline.subr.neg,\
                @@mul           , .inline.mul,\
                @@mul.pos       , .inline.mul.pos,\
                @@mul.neg       , .inline.mul.neg,\
                @@div           , .inline.div,\
                @@div.pos       , .inline.div.pos,\
                @@div.neg       , .inline.div.neg,\
                @@divr          , .inline.divr,\
                @@divr.pos      , .inline.divr.pos,\
                @@divr.neg      , .inline.divr.neg,\
                @@quo           , .inline.quo,\
                @@quo.pos       , .inline.quo.pos,\
                @@quo.neg       , .inline.quo.neg,\
                @@quor          , .inline.quor,\
                @@quor.pos      , .inline.quor.pos,\
                @@quor.neg      , .inline.quor.neg,\
                @@mod           , .inline.mod,\
                @@mod.pos       , .inline.mod.pos,\
                @@mod.neg       , .inline.mod.neg,\
                @@modr          , .inline.modr,\
                @@modr.pos      , .inline.modr.pos,\
                @@modr.neg      , .inline.modr.neg
        pcase   rsi,\
                @@min           , .inline.min,\
                @@max           , .inline.max,\
                @@adev          , .inline.adev,\
                @@nadev         , .inline.nadev
        pcase   rsi,\
                @@ipow          , .inline.ipow,\
                @@pow           , .inline.pow,\
                @@.pow.??       , .inline.pow.??,\      ; a^b  : pow  | bxor
                @@powr          , .inline.powr,\
                @@.powr.??      , .inline.powr.??,\     ; a~^b : powr | bxnor
                @@root          , .inline.root,\
                @@rootr         , .inline.rootr
        pcase   rsi,\
                @@gcd           , .inline.gcd,\
                @@lcm           , .inline.lcm
        pcase   rsi,\
                @@bt            , .inline.bt,\
                @@hammd         , .inline.hammd,\
                @@bor           , .inline.bor,\
                @@bnor          , .inline.bnor,\
                @@born          , .inline.born,\
                @@bnorn         , .inline.bnorn,\
                @@borc          , .inline.borc,\
                @@bnorc         , .inline.bnorc,\
                @@bcor          , .inline.bcor,\
                @@bcorn         , .inline.bcorn,\
                @@bxor          , .inline.bxor,\
                @@bxnor         , .inline.bxnor,\
                @@band          , .inline.band,\
                @@bnand         , .inline.bnand,\
                @@bandn         , .inline.bandn,\
                @@bnandn        , .inline.bnandn,\
                @@breset        , .inline.breset,\
                @@bset          , .inline.bset,\
                @@shr           , .inline.shr,\
                @@shl           , .inline.shl,\
                @@sar           , .inline.sar,\
                @@sal           , .inline.sal,\
                @@ror           , .inline.ror,\
                @@rol           , .inline.rol
        pcase   rsi,\
                @@igcd          , .inline.igcd,\
                @@ilcm          , .inline.ilcm
        pcase   rsi,\
                @@btc           , .inline.btc,\
                @@btr           , .inline.btr,\
                @@bts           , .inline.bts
        pcase   rsi,\
                @@or            , .inline.or,\
                @@nor           , .inline.nor,\
                @@xor           , .inline.xor,\
                @@xnor          , .inline.xnor,\
                @@and           , .inline.and,\
                @@nand          , .inline.nand
        pcase   rsi,\
                @@if.e          , .inline.if.e,\
                @@if.ne         , .inline.if.ne,\
                @@if.a          , .inline.if.a,\
                @@if.ae         , .inline.if.ae,\
                @@if.b          , .inline.if.b,\
                @@if.be         , .inline.if.be
        pcase   rsi,\
                @@if.bea        , .inline.if.bea,\
                @@if.aeb        , .inline.if.aeb
        pcase   rsi,\
                @@case.x32      , .inline.case.x32,\
                @@case.n32      , .inline.case.n32,\
                @@case.x64      , .inline.case.x64,\
                @@case.n64      , .inline.case.n64
        pcase   rsi,\
                @@co.add        , .inline.co.add,\
                @@co.sub        , .inline.co.sub,\
                @@co.subr       , .inline.co.subr,\
                @@co.mul        , .inline.co.mul,\
                @@co.div        , .inline.co.div,\
                @@co.divr       , .inline.co.divr,\
                @@co.quo        , .inline.co.quo,\
                @@co.quor       , .inline.co.quor,\
                @@co.mod        , .inline.co.mod,\
                @@co.modr       , .inline.co.modr
        pcase   rsi,\
                @@co.bor        , .inline.co.bor,\
                @@co.bnor       , .inline.co.bnor,\
                @@co.born       , .inline.co.born,\
                @@co.bnorn      , .inline.co.bnorn,\
                @@co.borc       , .inline.co.borc,\
                @@co.bnorc      , .inline.co.bnorc,\
                @@co.bcor       , .inline.co.bcor,\
                @@co.bcorn      , .inline.co.bcorn,\
                @@co.bxor       , .inline.co.bxor,\
                @@co.bxnor      , .inline.co.bxnor,\
                @@co.band       , .inline.co.band,\
                @@co.bnand      , .inline.co.bnand,\
                @@co.bandn      , .inline.co.bandn,\
                @@co.bnandn     , .inline.co.bnandn,\
                @@co.breset     , .inline.co.breset,\
                @@co.bset       , .inline.co.bset,\
                @@co.shr        , .inline.co.shr,\
                @@co.shl        , .inline.co.shl,\
                @@co.sar        , .inline.co.sar,\
                @@co.sal        , .inline.co.sal,\
                @@co.ror        , .inline.co.ror,\
                @@co.rol        , .inline.co.rol
        pcase   rsi,\
                @@copy          , .inline.copy,\
                @@xcopy         , .inline.copy,\
                @@copx          , .inline.copx,\
                @@ycopx         , .inline.copx
        pcase   rsi,\
                @@copy.int      , .inline.copy.int,\
                @@xcopy.int     , .inline.copy.int,\
                @@copx.int      , .inline.copx.int,\
                @@ycopx.int     , .inline.copx.int
        pcase   rsi,\
                @@copy.frac     , .inline.copy.frac,\
                @@xcopy.frac    , .inline.copy.frac,\
                @@copx.frac     , .inline.copx.frac,\
                @@ycopx.frac    , .inline.copx.frac
        pcase   rsi,\
                @@copy.round    , .inline.copy.round,\
                @@xcopy.round   , .inline.copy.round,\
                @@copx.round    , .inline.copx.round,\
                @@ycopx.round   , .inline.copx.round
        pcase   rsi,\
                @@pcopy         , .inline.pcopy,\
                @@pxcopy        , .inline.pcopy,\
                @@pcopx         , .inline.pcopx,\
                @@pycopx        , .inline.pcopx
        pcase   rsi,\
                @@swap          , .inline.swap
        pcase   rsi,\
                @@swap.int      , .inline.swap.int,\
                @@swap.frac     , .inline.swap.frac,\
                @@swap.round    , .inline.swap.round
        pcase   rsi,\
                @@farr          , .inline.xarr,\
                @@barr          , .inline.xarr
        pcase   rsi,\
                @@pfarr         , .inline.pxarr,\
                @@pbarr         , .inline.pxarr
        pcase   rsi,\
                @@fara          , .inline.fara,\
                @@bara          , .inline.bara
        pcase   rsi,\
                @@pfara         , .inline.pxarr,\
                @@pbara         , .inline.pxarr
        pcase   rsi,\
                @@farv          , .inline.farv,\
                @@barv          , .inline.barv
        pcase   rsi,\
                @@.1D.2P.matrip , .inline.matrip,\
                @@.1D.matrip.rc , .inline.matrip
        pcase   rsi,\
                @@.addr.2P      , .inline.addr.2P
        pcase   rsi,\
                @@ccovalue      , .inline.ccovalue,\
                @@crestore      , .inline.crestore
        pcase   rsi,\
                @@czcopy        , .inline.ccopy.2p,\
                @@czrcopy       , .inline.ccopy.2p,\
                @@czicopy       , .inline.ccopy.2p
        jmp    .inline.proc.2p.rr
   .inline.fixarg.2p.nr:                        ; fixed number of arguments ; 2 arguments ; no result
        pcase   rsi,\
                @@absolute      , .inline.absolute
        pcase   rsi,\
                @@goto.if.true  , .inline.goto.if.true,\
                @@goto.if.false , .inline.goto.if.false,\
                @@goto.if.z     , .inline.goto.if.z,\
                @@goto.if.nz    , .inline.goto.if.nz,\
                @@goto.if.az    , .inline.goto.if.az,\
                @@goto.if.aez   , .inline.goto.if.aez,\
                @@goto.if.bz    , .inline.goto.if.bz,\
                @@goto.if.bez   , .inline.goto.if.bez
        pcase   rsi,\
                @@call.ie.x32   , .inline.jump.2p,\
                @@call.ie.n32   , .inline.jump.2p,\
                @@call.ie.x64   , .inline.jump.2p,\
                @@call.ie.n64   , .inline.jump.2p
        pcase   rsi,\
                @@call.if.true  , .inline.call.if.true,\
                @@call.if.false , .inline.call.if.false,\
                @@call.if.z     , .inline.call.if.z,\
                @@call.if.nz    , .inline.call.if.nz,\
                @@call.if.az    , .inline.call.if.az,\
                @@call.if.aez   , .inline.call.if.aez,\
                @@call.if.bz    , .inline.call.if.bz,\
                @@call.if.bez   , .inline.call.if.bez
        pcase   rsi,\
                @@creset        , .inline.crestore
        pcase   rsi,\
                @@czmove        , .inline.cmove.2p,\
                @@czrmove       , .inline.cmove.2p,\
                @@czimove       , .inline.cmove.2p
        pcase   rsi,\
                @@.returnv.if.true  , .inline.return.if,\
                @@.returnv.if.false , .inline.return.if
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.3p:                           ; fixed number of arguments ; 3 arguments
        cmp     [.frecount], 0
        jz     .inline.fixarg.3p.nr
   .inline.fixarg.3p.rr:                        ; fixed number of arguments ; 3 arguments ; returns result
        pcase   rsi,\
                @@farw          , .inline.xarr,\
                @@barw          , .inline.xarr
        pcase   rsi,\
                @@pfarw         , .inline.pxarr,\
                @@pbarw         , .inline.pxarr
        pcase   rsi,\
                @@co.fxtractse  , .inline.x2copyD,\
                @@co.fxtractes  , .inline.x2copyD
        pcase   rsi,\
                @@co.sincos     , .inline.x2copyD,\
                @@co.cossin     , .inline.x2copyD,\
                @@co.shch       , .inline.x2copyD,\
                @@co.chsh       , .inline.x2copyD
        pcase   rsi,\
                @@co.fsincos    , .inline.x2copyD,\
                @@co.fcossin    , .inline.x2copyD,\
                @@co.fsincospi  , .inline.x2copyD,\
                @@co.fcossinpi  , .inline.x2copyD,\
                @@co.fshch      , .inline.x2copyD,\
                @@co.fchsh      , .inline.x2copyD
        pcase   rsi,\
                @@.2D.3P.matrip , .inline.matrip
        pcase   rsi,\
                @@cxcopy        , .inline.ccopy.3p,\
                @@cxrcopy       , .inline.ccopy.3p,\
                @@cxicopy       , .inline.ccopy.3p
        pcase   rsi,\
                @@cpcopy        , .inline.cpcopy.3p
        pcase   rsi,\
                @@fmadd132      , .inline.fmadd132,\
                @@fmadd213      , .inline.fmadd213,\
                @@fmadd231      , .inline.fmadd231,\
                @@fnmadd132     , .inline.fnmadd132,\
                @@fnmadd213     , .inline.fnmadd213,\
                @@fnmadd231     , .inline.fnmadd231,\
                @@fmsub132      , .inline.fmsub132,\
                @@fmsub213      , .inline.fmsub213,\
                @@fmsub231      , .inline.fmsub231,\
                @@fnmsub132     , .inline.fnmsub132,\
                @@fnmsub213     , .inline.fnmsub213,\
                @@fnmsub231     , .inline.fnmsub231
;       pcase   rsi,\
;               @@cpown         , .inline.stack.4,\
;               @@crootn        , .inline.stack.4
        jmp    .inline.proc.3p.rr
   .inline.fixarg.3p.nr:                        ; fixed number of arguments ; 3 arguments ; no result
        pcase   rsi,\
                @@call.ie.true  , .inline.call.ie.true,\
                @@call.ie.false , .inline.call.ie.false,\
                @@call.ie.z     , .inline.call.ie.z,\
                @@call.ie.nz    , .inline.call.ie.nz,\
                @@call.ie.az    , .inline.call.ie.az,\
                @@call.ie.aez   , .inline.call.ie.aez,\
                @@call.ie.bz    , .inline.call.ie.bz,\
                @@call.ie.bez   , .inline.call.ie.bez
        pcase   rsi,\
                @@cxmove        , .inline.cmove.3p,\
                @@cxrmove       , .inline.cmove.3p,\
                @@cximove       , .inline.cmove.3p
        pcase   rsi,\
                @@cpmove        , .inline.cpmove.3p
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.fixarg.4p:                           ; fixed number of arguments ; 4 arguments and more
        cmp     [.frecount], 0
        jz     .inline.fixarg.4p.nr
   .inline.fixarg.4p.rr:                        ; fixed number of arguments ; 4 arguments and more ; returns result
        pcase   rsi,\
                @@x2copy        , .inline.x2copy,\
                @@x3copy        , .inline.x3copy,\
                @@x4copy        , .inline.x4copy
        pcase   rsi,\
                @@co.quo.mod    , .inline.x2copyD,\
                @@co.mod.quo    , .inline.x2copyD,\
                @@co.minmax     , .inline.x2copyD,\
                @@co.maxmin     , .inline.x2copyD
        pcase   rsi,\
                @@co.lineco     , .inline.x2copyD
        pcase   rsi,\
                @@co.deg2arc    , .inline.x3copyD,\
                @@co.rad2arc    , .inline.x3copyD,\
                @@co.grad2arc   , .inline.x3copyD,\
                @@co.cycle2arc  , .inline.x3copyD
        pcase   rsi,\
                @@.2D.4P.matrip , .inline.matrip,\
                @@.2D.matrip.rc , .inline.matrip
        pcase   rsi,\
                @@ccopy         , .inline.ccopy,\
                @@crrcopy       , .inline.ccopy,\
                @@ciicopy       , .inline.ccopy,\
                @@cswap         , .inline.cswap
;       pcase   rsi,\
;               @@crootsn       , .inline.stack.8
        cmp     [.facount], 4
        jg     .inline.proc
        jmp    .inline.proc.4p.rr
   .inline.fixarg.4p.nr:                        ; fixed number of arguments ; 4 arguments and more ; no result
        pcase   rsi,\
                @@cmove         , .inline.cmove,\
                @@crrmove       , .inline.cmove,\
                @@ciimove       , .inline.cmove,\
                @@cswop         , .inline.cswop
        jmp    .inline.proc.nr
;       jmp    .inline.proc

   .inline.vcount:
        ; ----------------------------------------------
        ; MOV   R13, ACOUNT     | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; ----------------------------------------------
        mov     rcx, [.ezx]
    $ifndef _SSEX
        cmp     rcx, 1
        je     .inline.vcount.1
    $end
        test    rcx, rcx
        jz     .inline.vcount.0
   .inline.vcount.q:
    $ifdef _SSEX
        @@range 5, .error.memory
        mov     [rdi + 00], dword 0x2A0F49F2
        mov     [rdi + 04], byte 0xC5
        @@xshr  rdi, 5
        ; ----------------------------------------------
        ; MOV      R13, ACOUNT | 49BD CCCCCCCCCCCCCCCC  ; 10 BYTES
        ;*CVTSI2SD XMM0, R13   | F2490F2AC5             ; 5 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@range 8, .error.memory
        mov     [rdi - 10], word 0xB948
        mov     [rdi + 00], dword 0x242CDF51
        mov     [rdi + 04], dword 0x08C48348
        @@xshr  rdi, 8
        ; ----------------------------------------------
        ; MOV   RCX, ACOUNT     | 48B9 CCCCCCCCCCCCCCCC ; 10 BYTES
        ;*PUSH  RCX             | 51                    ; 1 BYTES
        ; FILD  QWORD [RSP]     | DF2C 24               ; 3 BYTES
        ; ADD   RSP, 8          | 4883C408              ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $end
        jmp    .done
    $ifndef _SSEX
   .inline.vcount.1:
        @@xshl  rdi, 10
        mov     [rdi + 0], word 0xE8D9
        @@xshr  rdi, 2
        ; ----------------------------------------------
        ;*FLD1                  | D9E8                  ; 2 BYTES
        ;>
        ; ----------------------------------------------
        jmp    .done
    $end
   .inline.vcount.0:
    $ifdef _SSEX
        @@xshl  rdi, 10
        mov     [rdi + 0], dword 0xC0570F66
        @@xshr  rdi, 4
        ; ----------------------------------------------
        ;*XORPD XMM0, XMM0      | 660F57C0              ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@xshl  rdi, 10
        mov     [rdi + 0], word 0xEED9
        @@xshr  rdi, 2
        ; ----------------------------------------------
        ;*FLDZ                  | D9EE                  ; 2 BYTES
        ;>
        ; ----------------------------------------------
    $end
        jmp    .done
   .inline.vcount.varg:
        ; ----------------------------------------------
        ; ...                   |
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 5, .error.memory
        mov     [rdi + 00], dword 0x2A0F49F2
        mov     [rdi + 04], byte 0xC5
        @@xshr  rdi, 5
        ; ----------------------------------------------
        ;*CVTSI2SD XMM0, R13   | F2490F2AC5             ; 5 BYTES
        ;>
        ; ----------------------------------------------
    $else
        @@range 9, .error.memory
        mov     [rdi + 00], dword 0x2CDF5541
        mov     [rdi + 04], byte 0x24
        mov     [rdi + 05], dword 0x08C48348
        @@xshr  rdi, 9
        ; ----------------------------------------------
        ;*PUSH  R13             | 4155                  ; 2 BYTES
        ; FILD  QWORD [RSP]     | DF2C 24               ; 3 BYTES
        ; ADD   RSP, 8          | 4883C408              ; 4 BYTES
        ;>
        ; ----------------------------------------------
    $end
        jmp    .done

    $ifdef _SSEX
   .inline.sse.dcon.test:
        stmxcsr [.mxcsr]                                    ; store MXCSR register state
        test    [.mxcsr], 00001101B                         ; test OE, ZE and IE flags
        jnz    .inline.sse.dcon.error
   .inline.sse.dcon:
        mov     rcx, [.frecount]
        case    rcx,\
                1, .inline.sse.dcon.xmm0,\
                2, .inline.sse.dcon.xmm1,\
                3, .inline.sse.dcon.xmm2,\
                4, .inline.sse.dcon.xmm3,\
                5, .inline.sse.dcon.xmm4,\
                6, .inline.sse.dcon.xmm5,\
                7, .inline.sse.dcon.xmm6,\
                8, .inline.sse.dcon.xmm7
        jmp    .inline.sse.dcon.error
   .inline.sse.dcon.xmm7:
        movsd   qword [rsp - 08], xmm7
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm6:
        movsd   qword [rsp - 08], xmm6
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm5:
        movsd   qword [rsp - 08], xmm5
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm4:
        movsd   qword [rsp - 08], xmm4
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm3:
        movsd   qword [rsp - 08], xmm3
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm2:
        movsd   qword [rsp - 08], xmm2
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm1:
        movsd   qword [rsp - 08], xmm1
        jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm0:
        movsd   qword [rsp - 08], xmm0
;       jmp    .inline.sse.dcon.xmm
   .inline.sse.dcon.xmm:
        mov     rcx, [rsp - 08]                             ; rcx = double constant
        @@range 11, .error.memory
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x51
        @@xshr  rdi, 11
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        dec     [.frecount]
        cmp     [.frecount], 0
        jg     .inline.sse.dcon                             ; next constant
        mov     [.cotype], 'dcon'
        jmp    .exit
   .inline.sse.dcon.error:
        jmp    .error.evaluate
    $else
   .inline.st0.dcon.test:
        fnstsw  ax
        fnclex
        test    ax, 00001101B                               ; test OE, ZE and IE flags
        jnz    .inline.st0.dcon.error
   .inline.st0.dcon:                                        ; st0 = double constant
        fstp    qword [rsp - 08]
        mov     rcx, [rsp - 08]
   .inline.rcx.dcon:                                        ; rcx = double constant
        @@range 11, .error.memory
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], byte 0x51
        @@xshr  rdi, 11
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        dec     [.frecount]
        cmp     [.frecount], 0
        jg     .inline.st0.dcon                             ; next constant
        mov     [.cotype], 'dcon'
        jmp    .exit
   .inline.st0.dcon.error:
        fstp    st0
        dec     [.frecount]
        cmp     [.frecount], 0
        jg     .inline.st0.dcon.error                       ; next fpu stack item
        jmp    .error.evaluate
    $end

   .inline.rax.icon:                                        ; rax = integer constant
        @@range 11, .error.memory
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x50
        @@xshr  rdi, 11
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'icon'
        jmp    .exit

   .inline.rax.scon:                                        ; rax = string constant
        @@range 11, .error.memory
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x52
        @@xshr  rdi, 11
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ; PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'scon'
        jmp    .exit

   .inline.proc.0p.rr:
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon

   .inline.proc.1p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [RSP]       | DD0424               ; 3 BYTES
        ;?FILD     QWORD [RSP]       | DF2C24               ; 3 BYTES

        ;?MOVSD    XMM0, QWORD [RSP] | F2  0F100424         ; 5 BYTES
        ;?CVTSI2SD XMM0, QWORD [RSP] | F2480F2A0424         ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                        | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.1p.rr.p1:
        cmp     [rsi + 00], dword 0x04100FF2
        je     .inline.proc.1p.rr.p1.D?
        cmp     [rsi + 00], dword 0x2A0F48F2
        jne    .inline.proc
        ;
   .inline.proc.1p.rr.p1.I?:
        cmp     [rsi + 04], word 0x2404
        jne    .inline.proc
   .inline.proc.1p.rr.p1.I:
        mov     [.sid], 6
        jmp    .inline.proc.1p.rr.enter
        ;
   .inline.proc.1p.rr.p1.D?:
        cmp     [rsi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.1p.rr.p1.D:
        mov     [.sid], 5
        jmp    .inline.proc.1p.rr.enter
    $else
        cmp     [rsi + 02], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 00], word 0x04DD
        je     .inline.proc.1p.rr.p1.D
        cmp     [rsi + 00], word 0x2CDF
        jne    .inline.proc
   .inline.proc.1p.rr.p1.I:
   .inline.proc.1p.rr.p1.D:
        mov     [.sid], 3
;       jmp    .inline.proc.1p.rr.enter
    $end
   .inline.proc.1p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_CON , .inline.proc.1p.rr.dcon,\
                OBJ_INT_CON    , .inline.proc.1p.rr.icon,\
                OBJ_STRING_CON , .inline.proc.1p.rr.icon
        jmp    .inline.proc
   .inline.proc.1p.rr.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        add     rsp, 8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11
        add     [.RSP], 8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
   .inline.proc.1p.rr.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        add     rsp, 8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11
        add     [.RSP], 8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon

   .inline.proc.2p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [RSP]          | DD0424            ; 3 BYTES
        ;?FILD     QWORD [RSP]          | DF2C24

        ;?MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ;?CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [RSP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     QWORD [RSP+FF]       | DF6C24 FF

        ;?MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ;?CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.2p.rr.p1:
        cmp     [rsi + 00], dword 0x04100FF2
        je     .inline.proc.2p.rr.p1.D?
        cmp     [rsi + 00], dword 0x2A0F48F2
        jne    .inline.proc
        ;
   .inline.proc.2p.rr.p1.I?:
        cmp     [rsi + 04], word 0x2404
        jne    .inline.proc
   .inline.proc.2p.rr.p1.I:
   .inline.proc.2p.rr.p1.I.p2:
        cmp     [rsi + 06], dword 0x4C100FF2
        je     .inline.proc.2p.rr.p1.I.p2.D?
        cmp     [rsi + 06], dword 0x2A0F48F2
        jne    .inline.proc
        ;
   .inline.proc.2p.rr.p1.I.p2.I?:
        cmp     [rsi + 10], word 0x244C
        jne    .inline.proc
   .inline.proc.2p.rr.p1.I.p2.I:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 6+7
        jmp    .inline.proc.2p.rr.enter
        ;
   .inline.proc.2p.rr.p1.I.p2.D?:
        cmp     [rsi + 10], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.I.p2.D:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 6+6
        jmp    .inline.proc.2p.rr.enter
        ;
   .inline.proc.2p.rr.p1.D?:
        cmp     [rsi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.D:
   .inline.proc.2p.rr.p1.D.p2:
        cmp     [rsi + 05], dword 0x4C100FF2
        je     .inline.proc.2p.rr.p1.D.p2.D?
        cmp     [rsi + 05], dword 0x2A0F48F2
        jne    .inline.proc
        ;
   .inline.proc.2p.rr.p1.D.p2.I?:
        cmp     [rsi + 09], word 0x244C
        jne    .inline.proc
   .inline.proc.2p.rr.p1.D.p2.I:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ; CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+7
        jmp    .inline.proc.2p.rr.enter
        ;
   .inline.proc.2p.rr.p1.D.p2.D?:
        cmp     [rsi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.2p.rr.p1.D.p2.D:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ; MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6
        jmp    .inline.proc.2p.rr.enter
    $else
   .inline.proc.2p.rr.p1:
        cmp     [rsi + 02], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 00], word 0x04DD
        je     .inline.proc.2p.rr.p1.out
        cmp     [rsi + 00], word 0x2CDF
        jne    .inline.proc
   .inline.proc.2p.rr.p1.out:
   .inline.proc.2p.rr.p2:
        cmp     [rsi + 05], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 03], word 0x44DD
        je     .inline.proc.2p.rr.p2.out
        cmp     [rsi + 03], word 0x6CDF
        jne    .inline.proc
   .inline.proc.2p.rr.p2.out:
        mov     [.sid], 3+4
    $end
   .inline.proc.2p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_CON , .inline.proc.2p.rr.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.rr.icon,\
                OBJ_STRING_CON , .inline.proc.2p.rr.icon
        jmp    .inline.proc
   .inline.proc.2p.rr.dcon:
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.2p.rr.dcon.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.rr.dcon.icon,\
                OBJ_STRING_CON , .inline.proc.2p.rr.dcon.icon
        jmp    .inline.proc
   .inline.proc.2p.rr.icon:
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.2p.rr.icon.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.rr.icon.icon,\
                OBJ_STRING_CON , .inline.proc.2p.rr.icon.icon
        jmp    .inline.proc
   .inline.proc.2p.rr.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
        movsd   xmm1, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        add     rsp, 8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
   .inline.proc.2p.rr.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm1, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        add     rsp, 8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
   .inline.proc.2p.rr.icon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
        movsd   xmm1, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        add     rsp, 8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
   .inline.proc.2p.rr.icon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm1, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        add     rsp, 8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon

   .inline.proc.3p.rr:
     ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [RSP]          | DD0424            ; 3 BYTES
        ;?FILD     QWORD [RSP]          | DF2C24

        ;?MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ;?CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [RSP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     QWORD [RSP+FF]       | DF6C24 FF

        ;?MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ;?CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [RSP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     QWORD [RSP+FF]       | DF6C24 FF

        ;?MOVSD    XMM2, QWORD [RSP+FF] | F2  0F105424 FF   ; 6 BYTES
        ;?CVTSI2SD XMM2, QWORD [RSP+FF] | F2480F2A5424 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.3p.rr.p1:
        cmp     [rsi + 00], dword 0x04100FF2
        je     .inline.proc.3p.rr.p1.D?
        cmp     [rsi + 00], dword 0x2A0F48F2
        jne    .inline.proc
        ;
   .inline.proc.3p.rr.p1.I?:
        cmp     [rsi + 04], word 0x2404
        jne    .inline.proc
   .inline.proc.3p.rr.p1.I:
        cmp     [rsi + 06], dword 0x2A0F48F2
        jne    .inline.proc
        cmp     [rsi + 10], word 0x244C
        jne    .inline.proc
   .inline.proc.3p.rr.p1.I.p2.I:
        cmp     [rsi + 13], dword 0x2A0F48F2
        jne    .inline.proc
        cmp     [rsi + 17], word 0x2454
        jne    .inline.proc
   .inline.proc.3p.rr.p1.I.p2.I.p3.I:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; CVTSI2SD XMM2, QWORD [RSP+FF] | F2480F2A5424 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 6+7+7
        jmp    .inline.proc.3p.rr.enter
        ;
   .inline.proc.3p.rr.p1.D?:
        cmp     [rsi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.D:
        cmp     [rsi + 05], dword 0x4C100FF2
        jne    .inline.proc
        cmp     [rsi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.D.p2.D:
        cmp     [rsi + 11], dword 0x54100FF2
        jne    .inline.proc
        cmp     [rsi + 15], byte 0x24
        jne    .inline.proc
   .inline.proc.3p.rr.p1.D.p2.D.p3.D:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ; MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ; MOVSD    XMM2, QWORD [RSP+FF] | F2  0F105424 FF   ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6+6
        jmp    .inline.proc.3p.rr.enter
    $else
   .inline.proc.3p.rr.p1:
        cmp     [rsi + 02], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 00], word 0x04DD
        je     .inline.proc.3p.rr.p1.out
        cmp     [rsi + 00], word 0x2CDF
        jne    .inline.proc
   .inline.proc.3p.rr.p1.out:
   .inline.proc.3p.rr.p2:
        cmp     [rsi + 05], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 03], word 0x44DD
        je     .inline.proc.3p.rr.p2.out
        cmp     [rsi + 03], word 0x6CDF
        jne    .inline.proc
   .inline.proc.3p.rr.p2.out:
   .inline.proc.3p.rr.p3:
        cmp     [rsi + 09], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 07], word 0x44DD
        je     .inline.proc.3p.rr.p3.out
        cmp     [rsi + 07], word 0x6CDF
        jne    .inline.proc
   .inline.proc.3p.rr.p3.out:
        mov     [.sid], 3+4+4
    $end
   .inline.proc.3p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_CON , .inline.proc.3p.rr.dcon,\
                OBJ_INT_CON    , .inline.proc.3p.rr.icon
        jmp    .inline.proc
        ;
   .inline.proc.3p.rr.dcon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.3p.rr.dcon.dcon
        jmp    .inline.proc
   .inline.proc.3p.rr.dcon.dcon:
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.3p.rr.dcon.dcon.dcon
        jmp    .inline.proc
        ;
   .inline.proc.3p.rr.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.3p.rr.icon.icon
        jmp    .inline.proc
   .inline.proc.3p.rr.icon.icon:
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.3p.rr.icon.icon.icon
        jmp    .inline.proc
        ;
   .inline.proc.3p.rr.dcon.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
        movsd   xmm1, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 31]                             ; rcx = constant #3
        push    rcx
    $ifdef _SSEX
        movsd   xmm2, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        add     rsp, 8+8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11+11
        add     [.RSP], 8+8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
        ;
   .inline.proc.3p.rr.icon.icon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm1, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 31]                             ; rcx = constant #3
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm2, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        add     rsp, 8+8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11+11
        add     [.RSP], 8+8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon

   .inline.proc.4p.rr:
        ; --------------------------------------------------
        ; function entry
        ; --------------------------------------------------
        ;?FLD      QWORD [RSP]          | DD0424            ; 3 BYTES
        ;?FILD     QWORD [RSP]          | DF2C24

        ;?MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ;?CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [RSP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     QWORD [RSP+FF]       | DF6C24 FF

        ;?MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ;?CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [RSP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     QWORD [RSP+FF]       | DF6C24 FF

        ;?MOVSD    XMM2, QWORD [RSP+FF] | F2  0F105424 FF   ; 6 BYTES
        ;?CVTSI2SD XMM2, QWORD [RSP+FF] | F2480F2A5424 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?FLD      QWORD [RSP+FF]       | DD4424 FF         ; 4 BYTES
        ;?FILD     QWORD [RSP+FF]       | DF6C24 FF

        ;?MOVSD    XMM3, QWORD [RSP+FF] | F2  0F105C24 FF   ; 6 BYTES
        ;?CVTSI2SD XMM3, QWORD [RSP+FF] | F2480F2A5C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
    $ifdef _SSEX
   .inline.proc.4p.rr.p1:
        cmp     [rsi + 00], dword 0x04100FF2
        je     .inline.proc.4p.rr.p1.D?
        cmp     [rsi + 00], dword 0x2A0F48F2
        jne    .inline.proc
        ;
   .inline.proc.4p.rr.p1.I?:
        cmp     [rsi + 04], word 0x2404
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I:
        cmp     [rsi + 06], dword 0x2A0F48F2
        jne    .inline.proc
        cmp     [rsi + 10], word 0x244C
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I.p2.I:
        cmp     [rsi + 13], dword 0x2A0F48F2
        jne    .inline.proc
        cmp     [rsi + 17], word 0x2454
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I.p2.I.p3.I:
        cmp     [rsi + 20], dword 0x2A0F48F2
        jne    .inline.proc
        cmp     [rsi + 24], word 0x245C
        jne    .inline.proc
   .inline.proc.4p.rr.p1.I.p2.I.p3.I.p4.I:
        ; --------------------------------------------------
        ; CVTSI2SD XMM0, QWORD [RSP]    | F2480F2A0424      ; 6 BYTES
        ; CVTSI2SD XMM1, QWORD [RSP+FF] | F2480F2A4C24 FF   ; 7 BYTES
        ; CVTSI2SD XMM2, QWORD [RSP+FF] | F2480F2A5424 FF   ; 7 BYTES
        ; CVTSI2SD XMM3, QWORD [RSP+FF] | F2480F2A5C24 FF   ; 7 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 6+7+7+7
        jmp    .inline.proc.4p.rr.enter
        ;
   .inline.proc.4p.rr.p1.D?:
        cmp     [rsi + 04], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D:
        cmp     [rsi + 05], dword 0x4C100FF2
        jne    .inline.proc
        cmp     [rsi + 09], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D.p2.D:
        cmp     [rsi + 11], dword 0x54100FF2
        jne    .inline.proc
        cmp     [rsi + 15], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D.p2.D.p3.D:
        cmp     [rsi + 17], dword 0x5C100FF2
        jne    .inline.proc
        cmp     [rsi + 21], byte 0x24
        jne    .inline.proc
   .inline.proc.4p.rr.p1.D.p2.D.p3.D.p4.D:
        ; --------------------------------------------------
        ; MOVSD    XMM0, QWORD [RSP]    | F2  0F100424      ; 5 BYTES
        ; MOVSD    XMM1, QWORD [RSP+FF] | F2  0F104C24 FF   ; 6 BYTES
        ; MOVSD    XMM2, QWORD [RSP+FF] | F2  0F105424 FF   ; 6 BYTES
        ; MOVSD    XMM3, QWORD [RSP+FF] | F2  0F105C24 FF   ; 6 BYTES
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                           | ...
        ; --------------------------------------------------
        mov     [.sid], 5+6+6+6
        jmp    .inline.proc.4p.rr.enter
    $else
   .inline.proc.4p.rr.p1:
        cmp     [rsi + 02], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 00], word 0x04DD
        je     .inline.proc.4p.rr.p1.out
        cmp     [rsi + 00], word 0x2CDF
        jne    .inline.proc
   .inline.proc.4p.rr.p1.out:
   .inline.proc.4p.rr.p2:
        cmp     [rsi + 05], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 03], word 0x44DD
        je     .inline.proc.4p.rr.p2.out
        cmp     [rsi + 03], word 0x6CDF
        jne    .inline.proc
   .inline.proc.4p.rr.p2.out:
   .inline.proc.4p.rr.p3:
        cmp     [rsi + 09], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 07], word 0x44DD
        je     .inline.proc.4p.rr.p3.out
        cmp     [rsi + 07], word 0x6CDF
        jne    .inline.proc
   .inline.proc.4p.rr.p3.out:
   .inline.proc.4p.rr.p4:
        cmp     [rsi + 13], byte 0x24
        jne    .inline.proc
        cmp     [rsi + 11], word 0x44DD
        je     .inline.proc.4p.rr.p4.out
        cmp     [rsi + 11], word 0x6CDF
        jne    .inline.proc
   .inline.proc.4p.rr.p4.out:
        mov     [.sid], 3+4+4+4
    $end
   .inline.proc.4p.rr.enter:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon,\
                OBJ_INT_CON    , .inline.proc.4p.rr.icon
        jmp    .inline.proc
        ;
   .inline.proc.4p.rr.dcon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon.dcon
        jmp    .inline.proc
   .inline.proc.4p.rr.dcon.dcon:
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon.dcon.dcon
        jmp    .inline.proc
   .inline.proc.4p.rr.dcon.dcon.dcon:
        stdcall code_object, [.cooff], -33                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.4p.rr.dcon.dcon.dcon.dcon
        jmp    .inline.proc
        ;
   .inline.proc.4p.rr.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.4p.rr.icon.icon
        jmp    .inline.proc
   .inline.proc.4p.rr.icon.icon:
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.4p.rr.icon.icon.icon
        jmp    .inline.proc
   .inline.proc.4p.rr.icon.icon.icon:
        stdcall code_object, [.cooff], -33                  ; ecx = object type
        case    ecx,\
                OBJ_INT_CON , .inline.proc.4p.rr.icon.icon.icon.icon
        jmp    .inline.proc
        ;
   .inline.proc.4p.rr.dcon.dcon.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
        movsd   xmm1, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 31]                             ; rcx = constant #3
        push    rcx
    $ifdef _SSEX
        movsd   xmm2, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 42]                             ; rcx = constant #4
        push    rcx
    $ifdef _SSEX
        movsd   xmm3, qword [rsp]
    $else
        fld     qword [rsp]
    $end
        ;
        add     rsp, 8+8+8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11+11+11
        add     [.RSP], 8+8+8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
        ;
   .inline.proc.4p.rr.icon.icon.icon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 20]                             ; rcx = constant #2
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm1, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 31]                             ; rcx = constant #3
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm2, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        mov     rcx, [rdi - 42]                             ; rcx = constant #4
        push    rcx
    $ifdef _SSEX
       cvtsi2sd xmm3, qword [rsp]
    $else
        fild    qword [rsp]
    $end
        ;
        add     rsp, 8+8+8+8
        add     rsi, [.sid]
        ;
        push    rdi rbx ; save registers when calling the built-in function
        call    rsi
        pop     rbx rdi
        ;
        @@xshl  rdi, 11+11+11+11
        add     [.RSP], 8+8+8+8
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon

   .inline.sizeof:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, OFFSET       | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR  , .inline.sizeof.dvar,\
                OBJ_DOUBLE_CON  , .inline.sizeof.dcon,\
                OBJ_INT_VAR     , .inline.sizeof.ivar,\
                OBJ_INT_CON     , .inline.sizeof.icon,\
                OBJ_STRING_VAR  , .inline.sizeof.svar,\
                OBJ_STRING_CON  , .inline.sizeof.scon,\
                OBJ_POINTER     , .inline.sizeof.ptr
        jmp    .error.argument
   .inline.sizeof.dvar:
        mov     rcx, 12
        jmp    .inline.sizeof.8
   .inline.sizeof.dcon:
        mov     rcx, 11
        jmp    .inline.sizeof.8
   .inline.sizeof.ivar:
        mov     rcx, 12
        jmp    .inline.sizeof.8
   .inline.sizeof.icon:
        mov     rcx, 11
        jmp    .inline.sizeof.8
   .inline.sizeof.svar:
        mov     rcx, 12
        jmp    .inline.sizeof.8
   .inline.sizeof.scon:
        mov     rcx, 11
        jmp    .inline.sizeof.8
   .inline.sizeof.ptr:
        mov     rcx, 14
;       jmp    .inline.sizeof.8
   .inline.sizeof.8:
        @@xshl  rdi, rcx
        add     [.RSP], 8
        mov     rax, 8
        jmp    .inline.rax.icon

   .inline.absolute:
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_POINTER , .inline.absolute.ptr
        jmp    .error.argument
   .inline.absolute.ptr:
        stdcall code_object, [.cooff], -14                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.absolute.ptr.dvar,\
                OBJ_INT_VAR    , .inline.absolute.ptr.ivar,\
                OBJ_INT_CON    , .inline.absolute.ptr.icon,\
                OBJ_STRING_VAR , .inline.absolute.ptr.svar,\
                OBJ_STRING_CON , .inline.absolute.ptr.scon,\
                OBJ_POINTER    , .inline.absolute.ptr.ptr
        jmp    .error.argument
   .inline.absolute.ptr.ptr:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 26]
        mov     rcx, [rdi - 12]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.svar:
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 24]
        test    rdx, rdx
        jz     .error.argument
        mov     rdx, [rdx]
        mov     rcx, [rdi - 12]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.scon:
        ; --------------------------------------------------
        ; MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ; PUSH    RDX               | 52

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 23]
        mov     rcx, [rdi - 12]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 24]
        mov     rcx, [rdi - 12]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 23]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        mov     rdx, [rdi - 23]
        mov     rcx, [rdi - 12]
        jmp    .inline.absolute.ptr.main
   .inline.absolute.ptr.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 24]
        mov     rcx, [rdi - 12]
   .inline.absolute.ptr.main:
        lea     rcx, [rcx + xitem64.value]
        mov     [rcx], rdx
        jmp    .exit

   .inline.assign:
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090

        ;?MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_POINTER , .inline.assign.ptr
        jmp    .error.argument
   .inline.assign.ptr:
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.assign.ptr.dvar,\
                OBJ_INT_VAR    , .inline.assign.ptr.ivar,\
                OBJ_INT_CON    , .inline.assign.ptr.icon,\
                OBJ_STRING_VAR , .inline.assign.ptr.svar,\
                OBJ_STRING_CON , .inline.assign.ptr.scon,\
                OBJ_POINTER    , .inline.assign.ptr.ptr
        jmp    .error.argument
   .inline.assign.ptr.ptr:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 36]
        mov     rcx, [rdi - 22]
        @@xshl  rdi, 38
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.svar:
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 34]
        test    rdx, rdx
        jz     .error.argument
        mov     rdx, [rdx]
        mov     rcx, [rdi - 22]
        @@xshl  rdi, 36
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.scon:
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ; PUSH    RDX               | 52

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 33]
        mov     rcx, [rdi - 22]
        @@xshl  rdi, 35
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 34]
        mov     rcx, [rdi - 22]
        @@xshl  rdi, 36
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 33]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        mov     rdx, [rdi - 33]
        mov     rcx, [rdi - 22]
        @@xshl  rdi, 35
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rax, [rdi - 46]
        mov     rdx, [rdi - 34]
        mov     rcx, [rdi - 22]
        sub     rax, rdx
        cmp     rax, 8
        jne    .inline.assign.ptr.dvar.x
   .inline.assign.ptr.dvar.dvar.x:
        @@xshl  rdi, 48
        jmp    .inline.assign.ptr.main
   .inline.assign.ptr.dvar:
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.assign.ptr.dvar.dvar
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 34]
        mov     rcx, [rdi - 22]
   .inline.assign.ptr.dvar.x:
        @@xshl  rdi, 36
   .inline.assign.ptr.main:
        lea     rcx, [rcx + xitem64.value]
        mov     [rcx], rdx
        mov     [.FPU], 0
        jmp    .exit

   .inline.reassign:
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090

        ;?MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_POINTER , .inline.reassign.ptr
        jmp    .error.argument
   .inline.reassign.ptr:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090

        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 22]
        @@xshl  rdi, 24
   .inline.reassign.ptr.main:
        mov     rdx, [rcx + xitem64.idata]
        lea     rcx, [rcx + xitem64.value]
        mov     [rcx], rdx
        mov     [.FPU], 0
        jmp    .exit

   .inline.addr.1P:
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.addr.1P.dvar,\
                OBJ_INT_VAR    , .inline.addr.1P.ivar,\
                OBJ_STRING_VAR , .inline.addr.1P.svar
        jmp    .error.argument
   .inline.addr.1P.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@range 4-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0x90909051
        @@xshr  rdi, 4
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ;*PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 8
        jmp    .exit
   .inline.addr.1P.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 14-12, .error.memory
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 8
        jmp    .exit
   .inline.addr.1P.svar:
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        @@range 14-12, .error.memory
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 8
        jmp    .exit

   .inline.addr.2P:
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.addr.2P.dvar
        jmp    .error.argument
   .inline.addr.2P.dvar:
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.addr.2P.dvar.dvar
        jmp    .error.argument
   .inline.addr.2P.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31

        ; MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 22]
        mov     rcx, [rdi - 10]
        sub     rdx, rcx
        cmp     rdx, 8
        jne    .error.argument
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 16
        jmp    .exit

   .inline.saddr:
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_STRING_VAR , .inline.saddr.svar,\
                OBJ_STRING_CON , .inline.saddr.scon
        jmp    .error.argument
   .inline.saddr.svar:
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]
        test    rdx, rdx
        jz     .error.argument
        @@range 14-12, .error.memory
        mov     rdx, [rdx]
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 8
        jmp    .exit
   .inline.saddr.scon:
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA FFFFFFFFFFFFFFFF ; string constant (11B)
        ; PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        @@range 14-11, .error.memory
        @@xshl  rdi, 11
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 8
        jmp    .exit

   .inline.vdouble:
        ; --------------------------------------------------
        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vdouble.icon,\
                OBJ_POINTER , .inline.vdouble.ptr
        jmp    .error.argument
   .inline.vdouble.icon:
        @@range 12-11, .error.memory
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 9]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        @@xshl  rdi, 11
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0x31FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        add     [.RSP], 8
        jmp    .exit
   .inline.vdouble.ptr:
        ; --------------------------------------------------
        ;*MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 14
        mov     [rdi + 10], word 0x31FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        add     [.RSP], 8
        jmp    .exit

   .inline.vcomplex:
        ; --------------------------------------------------
        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vcomplex.icon,\
                OBJ_POINTER , .inline.vcomplex.ptr
        jmp    .error.argument
   .inline.vcomplex.icon:
        @@range 24-11, .error.memory
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 9]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        mov     rcx, [rdi - 09]
        lea     rdx, [rcx + 8]
        @@xshl  rdi, 11
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0xB94831FF
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x31FF
        @@xshr  rdi, 24
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
;       add     [.RSP], 0
        jmp    .exit
   .inline.vcomplex.ptr:
        @@range 24-14, .error.memory
        ; --------------------------------------------------
        ;*MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 12]
        lea     rdx, [rcx + 8]
        @@xshl  rdi, 14
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0xB94831FF
        mov     [rdi + 14], rcx
        mov     [rdi + 22], word 0x31FF
        @@xshr  rdi, 24
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
;       add     [.RSP], 0
        jmp    .exit

   .inline.vinteger:
        ; --------------------------------------------------
        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vinteger.icon,\
                OBJ_POINTER , .inline.vinteger.ptr
        jmp    .error.argument
   .inline.vinteger.icon:
        @@range 12-11, .error.memory
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 9]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        @@xshl  rdi, 11
        mov     [rdi + 10], word 0x30FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ; --------------------------------------------------
        mov     [.cotype], 'ivar'
        add     [.RSP], 8
        jmp    .exit
   .inline.vinteger.ptr:
        ; --------------------------------------------------
        ;*MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 10], word 0x30FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ; --------------------------------------------------
        mov     [.cotype], 'ivar'
        add     [.RSP], 8
        jmp    .exit

   .inline.vstring:
        ; --------------------------------------------------
        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_CON , .inline.vstring.icon,\
                OBJ_POINTER , .inline.vstring.ptr
        jmp    .error.argument
   .inline.vstring.icon:
        @@range 12-11, .error.memory
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 9]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        @@xshl  rdi, 11
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0x32FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ; --------------------------------------------------
        mov     [.cotype], 'svar'
        add     [.RSP], 8
        jmp    .exit
   .inline.vstring.ptr:
        ; --------------------------------------------------
        ;*MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0x32FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ; --------------------------------------------------
        mov     [.cotype], 'svar'
        add     [.RSP], 8
        jmp    .exit

   .inline.pvalue:
        ; --------------------------------------------------
        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR     , .inline.pvalue.ivar,\
                OBJ_INT_CON     , .inline.pvalue.icon,\
                OBJ_INT_RSP_RAX , .inline.pvalue.irsp.rax,\
                OBJ_POINTER     , .inline.pvalue.ptr
        jmp    .error.argument
   .inline.pvalue.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 3-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 0], byte 0x48
        mov     [rdi + 1], word 0x088B
        @@xshr  rdi, 3
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RCX, [RAX]        | 488B08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
;       dec     [.ezx]
        jmp    .inline.proc
   .inline.pvalue.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 9]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        mov     [rdi - 11], word 0xB948
        @@xshl  rdi, 1
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.pvalue.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;*
        ;>
        ; --------------------------------------------------
        pcase   rsi,\
                @@pdouble , .inline.pvalue.irsp.rax.pdouble
   .inline.pvalue.irsp.rax.x:
        jmp    .error.argument
   .inline.pvalue.irsp.rax.pdouble:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424
        ;*MOV     RCX, RAX          | 4889C1
        ;>
        ; --------------------------------------------------
        @@range 3, .error.memory
        mov     [rdi + 0], byte 0x48
        mov     [rdi + 1], word 0xC189
        @@xshr  rdi, 3
;       add     [.RSP], 0
;       mov     [.ezx], 0
        jmp    .inline.proc
   .inline.pvalue.ptr:
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;*PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
   .inline.pvalue.ptr.x:
        @@xshl  rdi, 4
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.proc

   .inline.pcomplex:
        ; --------------------------------------------------
        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.pcomplex.ivar,\
                OBJ_INT_CON , .inline.pcomplex.icon,\
                OBJ_POINTER , .inline.pcomplex.ptr
        jmp    .error.argument
   .inline.pcomplex.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 3-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 0], byte 0x48
        mov     [rdi + 1], word 0x088B
        @@xshr  rdi, 3
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RCX, [RAX]        | 488B08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.pcomplex.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 9]
        stdcall tagettio, [sic], rdx                        ; ?match any declared variable offset
        test    rdx, rdx
        jz     .error.pointer
        ;
        mov     [rdi - 11], word 0xB948
        @@xshl  rdi, 1
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.pcomplex.ptr:
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;*PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 4
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc

   .inline.double:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ; ...                       | ...
        ;?MOV     RCX, VALUE        | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.double.dst0,\
                OBJ_DOUBLE_SSE  , .inline.double.dsse,\
                OBJ_DOUBLE_VAR  , .inline.double.dvar,\
                OBJ_DOUBLE_CON  , .inline.double.dcon,\
                OBJ_INT_VAR     , .inline.double.ivar,\
                OBJ_INT_CON     , .inline.double.icon,\
                OBJ_INT_RSP_RAX , .inline.double.irsp.rax,\
                OBJ_POINTER     , .inline.double.ptr
        jmp    .error.argument
   .inline.double.dst0:
   .inline.double.dsse:
   .inline.double.dvar:
   .inline.double.dcon:
        jmp    .inline.proc
   .inline.double.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*
        ;>
        ; ----------------------------------------------
;       add     [.RSP], 0
        mov     rsi, @@_io.rax_as_double
        mov     rax, @@_io.rax_as_double.size
        jmp    .inline.proc
   .inline.double.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 5, .error.memory
        mov     [rdi + 00], dword 0x2A0F48F2
        mov     [rdi + 04], byte 0xC0
        @@xshr  rdi, 5
        ; ----------------------------------------------
        ; MOV      RAX, VALUE | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH     RAX        | 50
        ;*CVTSI2SD XMM0, RAX  | F2480F2AC0
        ;>
        ; ----------------------------------------------
    $else
        @@range 3, .error.memory
        mov     [rdi + 00], word 0x2CDF
        mov     [rdi + 02], byte 0x24
        @@xshr  rdi, 3
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH  RAX             | 50
        ;*FILD  QWORD [RSP]     | DF2C24
        ;>
        ; ----------------------------------------------
    $end
;       add     [.RSP], 0
        jmp    .done
   .inline.double.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 5, .error.memory
        mov     [rdi + 00], dword 0x2A0F48F2
        mov     [rdi + 04], byte 0xC0
        @@xshr  rdi, 5
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV      [RSP], RAX       | 48890424              ; integer RSP RAX (4B)
        ;*CVTSI2SD XMM0, RAX        | F2480F2AC0
        ;>
        ; --------------------------------------------------
    $else
        @@range 3, .error.memory
        mov     [rdi + 00], word 0x2CDF
        mov     [rdi + 02], byte 0x24
        @@xshr  rdi, 3
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;*FILD    QWORD [RSP]       | DF2C24
        ;>
        ; --------------------------------------------------
    $end
;       add     [.RSP], 0
        jmp    .done
   .inline.double.ptr:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RCX, VALUE        | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ;*PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@range 5-4, .error.memory
        @@xshl  rdi, 4
        mov     [rdi + 00], dword 0x2A0F48F2
        mov     [rdi + 04], byte 0xC1
        @@xshr  rdi, 5
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV      RCX, VALUE       | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ;*CVTSI2SD XMM0, RCX        | F2480F2AC1
        ;>
        ; --------------------------------------------------
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RCX, VALUE        | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ;*NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@range 4-2, .error.memory
        @@xshl  rdi, 3
        mov     [rdi + 00], dword 0x59242CDF
        @@xshr  rdi, 4
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RCX, VALUE        | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ;*FILD    QWORD [RSP]       | DF2C24
        ; POP     RCX               | 59
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .done

   .inline.int64:
        mov     [.firesp], 1
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ;?MOV     RDX, OFFSET       | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.int64.dst0,\
                OBJ_DOUBLE_SSE  , .inline.int64.dsse,\
                OBJ_DOUBLE_VAR  , .inline.int64.dvar,\
                OBJ_DOUBLE_CON  , .inline.int64.dcon,\
                OBJ_INT_VAR     , .inline.int64.ivar,\
                OBJ_INT_CON     , .inline.int64.icon,\
                OBJ_INT_RSP_RAX , .inline.int64.irsp.rax,\
                OBJ_STRING_VAR  , .inline.int64.svar,\
                OBJ_STRING_CON  , .inline.int64.scon,\
                OBJ_POINTER     , .inline.int64.ptr
        jmp    .error.argument
   .inline.int64.dst0:
   .inline.int64.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ;>
        ; --------------------------------------------------
;       add     [.RSP], 0
        mov     rsi, @@_dv.rsp_as_int64
        mov     rax, @@_dv.rsp_as_int64.size
        jmp    .inline.proc
   .inline.int64.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF
        ;>
        ; ----------------------------------------------
;       add     [.RSP], 0
        mov     rsi, @@_do.rcx_as_int64
        mov     rax, @@_do.rcx_as_int64.size
        jmp    .inline.proc
   .inline.int64.dcon:
        ; ----------------------------------------------
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 09]                         ; rcx = constant
        stdcall f2i, rcx                                ; rax = int64 constant
        mov     [rdi - 10], byte 0xB8
        mov     [rdi - 09], rax
        mov     [rdi - 01], byte 0x50
        ; ----------------------------------------------
        ; MOV   RAX, INT64      | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.cotype], 'icon'
        jmp    .exit
   .inline.int64.ivar:
   .inline.int64.icon:
   .inline.int64.irsp.rax:
   .inline.int64.svar:
   .inline.int64.scon:
   .inline.int64.ptr:
;       add     [.RSP], 0
;       jmp    .inline.proc
        jmp    .bypass.exit

   .inline.is.x32:
        mov     rax, 0
;       add     [.RSP], 0
        jmp    .inline.rax.icon
   .inline.is.n32:
        mov     rax, 1
;       add     [.RSP], 0
        jmp    .inline.rax.icon
   .inline.is.x64:
        mov     rax, 1
;       add     [.RSP], 0
        jmp    .inline.rax.icon
   .inline.is.n64:
        mov     rax, 0
;       add     [.RSP], 0
        jmp    .inline.rax.icon
   .inline.dll.bits:
        mov     rax, 64
;       add     [.RSP], 0
        jmp    .inline.rax.icon

; ------
   .inline.inc.pre:
        mov     [.proc], @@inc.pre.map.index
        jmp    .inline.proc.1p.pp
   .inline.inc.post:
        mov     [.proc], @@inc.post.map.index
        jmp    .inline.proc.1p.pp
   .inline.dec.pre:
        mov     [.proc], @@dec.pre.map.index
        jmp    .inline.proc.1p.pp
   .inline.dec.post:
        mov     [.proc], @@dec.post.map.index
        jmp    .inline.proc.1p.pp
; ------
   .inline.proc.1p.pp:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.proc.1p.pp.dvar,\
                OBJ_INT_VAR    , .inline.proc.1p.pp.ivar,\
                OBJ_STRING_VAR , .inline.proc.1p.pp.svar
        jmp    .error.argument
;       jmp    .inline.proc.1p.pp.no.var
   .inline.proc.1p.pp.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 2
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;*                          |
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        jmp    .inline.proc.1p.pp.proc
   .inline.proc.1p.pp.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.proc.1p.pp.svar:
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;*PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.proc.1p.pp.isvar:
        mov     [rdi - 12], word 0xB948
        @@xshl  rdi, 2
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;*                          |
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
;       jmp    .inline.proc.1p.pp.proc.mode.1
   .inline.proc.1p.pp.proc.mode.1:
        mov     [.mode], 1
   .inline.proc.1p.pp.proc:
        dec     [.ezx]
        stdcall map_proc_x2, @x2_procs_1p_pp, [.proc], [.mode]
        jmp    .inline.proc
   .inline.proc.1p.pp.no.var:
        pcase   rsi,\
                @@inc.pre  , .inline.inc,\
                @@inc.post , .inline.inc,\
                @@dec.pre  , .inline.dec,\
                @@dec.post , .inline.dec
        jmp    .error.exit

; ------
   .inline.setz:
        mov     [.proc], @@setz.map.index
        jmp    .inline.proc.1p
   .inline.set1:
        mov     [.proc], @@set1.map.index
        jmp    .inline.proc.1p
   .inline.int:
        mov     [.proc], @@int.map.index
        jmp    .inline.proc.1p
   .inline.frac:
        mov     [.proc], @@frac.map.index
        jmp    .inline.proc.1p
   .inline.round:
        mov     [.proc], @@round.map.index
        jmp    .inline.proc.1p
   .inline.factln:
        mov     [.proc], @@factln.map.index
        jmp    .inline.proc.1p
   .inline.fact:
        mov     [.proc], @@fact.map.index
        jmp    .inline.proc.1p
   .inline.fact2:
        mov     [.proc], @@fact2.map.index
        jmp    .inline.proc.1p
; ------
   .inline.bit:
        mov     [.proc], @@bit.map.index
        jmp    .inline.proc.1p
   .inline.nibble:
        mov     [.proc], @@nibble.map.index
        jmp    .inline.proc.1p
   .inline.byte:
        mov     [.proc], @@byte.map.index
        jmp    .inline.proc.1p
   .inline.word:
        mov     [.proc], @@word.map.index
        jmp    .inline.proc.1p
   .inline.dword:
        mov     [.proc], @@dword.map.index
        jmp    .inline.proc.1p
   .inline.qword:
        mov     [.proc], @@qword.map.index
        jmp    .inline.proc.1p
   .inline.nword:
        mov     [.proc], @@nword.map.index
        jmp    .inline.proc.1p
   .inline.tword:
        mov     [.proc], @@tword.map.index
        jmp    .inline.proc.1p
   .inline.xword:
        mov     [.proc], @@xword.map.index
        jmp    .inline.proc.1p
   .inline.oword:
        mov     [.proc], @@oword.map.index
        jmp    .inline.proc.1p
   .inline.yword:
        mov     [.proc], @@yword.map.index
        jmp    .inline.proc.1p
   .inline.zword:
        mov     [.proc], @@zword.map.index
        jmp    .inline.proc.1p
; ------
   .inline.kibi:
        mov     [.proc], @@kibi.map.index
        jmp    .inline.proc.1p
   .inline.mebi:
        mov     [.proc], @@mebi.map.index
        jmp    .inline.proc.1p
   .inline.gibi:
        mov     [.proc], @@gibi.map.index
        jmp    .inline.proc.1p
   .inline.tebi:
        mov     [.proc], @@tebi.map.index
        jmp    .inline.proc.1p
   .inline.pebi:
        mov     [.proc], @@pebi.map.index
        jmp    .inline.proc.1p
   .inline.exbi:
        mov     [.proc], @@exbi.map.index
        jmp    .inline.proc.1p
   .inline.zebi:
        mov     [.proc], @@zebi.map.index
        jmp    .inline.proc.1p
   .inline.yobi:
        mov     [.proc], @@yobi.map.index
        jmp    .inline.proc.1p
; ------
   .inline.kibo:
        mov     [.proc], @@kibo.map.index
        jmp    .inline.proc.1p
   .inline.mebo:
        mov     [.proc], @@mebo.map.index
        jmp    .inline.proc.1p
   .inline.gibo:
        mov     [.proc], @@gibo.map.index
        jmp    .inline.proc.1p
   .inline.tebo:
        mov     [.proc], @@tebo.map.index
        jmp    .inline.proc.1p
   .inline.pebo:
        mov     [.proc], @@pebo.map.index
        jmp    .inline.proc.1p
   .inline.exbo:
        mov     [.proc], @@exbo.map.index
        jmp    .inline.proc.1p
   .inline.zebo:
        mov     [.proc], @@zebo.map.index
        jmp    .inline.proc.1p
   .inline.yobo:
        mov     [.proc], @@yobo.map.index
        jmp    .inline.proc.1p
; ------
   .inline.deca:
        mov     [.proc], @@deca.map.index
        jmp    .inline.proc.1p
   .inline.hecto:
        mov     [.proc], @@hecto.map.index
        jmp    .inline.proc.1p
   .inline.kilo:
        mov     [.proc], @@kilo.map.index
        jmp    .inline.proc.1p
   .inline.mega:
        mov     [.proc], @@mega.map.index
        jmp    .inline.proc.1p
   .inline.giga:
        mov     [.proc], @@giga.map.index
        jmp    .inline.proc.1p
   .inline.tera:
        mov     [.proc], @@tera.map.index
        jmp    .inline.proc.1p
   .inline.peta:
        mov     [.proc], @@peta.map.index
        jmp    .inline.proc.1p
   .inline.exa:
        mov     [.proc], @@exa.map.index
        jmp    .inline.proc.1p
   .inline.zetta:
        mov     [.proc], @@zetta.map.index
        jmp    .inline.proc.1p
   .inline.yotta:
        mov     [.proc], @@yotta.map.index
        jmp    .inline.proc.1p
; ------
   .inline.deci:
        mov     [.proc], @@deci.map.index
        jmp    .inline.proc.1p
   .inline.centi:
        mov     [.proc], @@centi.map.index
        jmp    .inline.proc.1p
   .inline.milli:
        mov     [.proc], @@milli.map.index
        jmp    .inline.proc.1p
   .inline.micro:
        mov     [.proc], @@micro.map.index
        jmp    .inline.proc.1p
   .inline.nano:
        mov     [.proc], @@nano.map.index
        jmp    .inline.proc.1p
   .inline.pico:
        mov     [.proc], @@pico.map.index
        jmp    .inline.proc.1p
   .inline.femto:
        mov     [.proc], @@femto.map.index
        jmp    .inline.proc.1p
   .inline.atto:
        mov     [.proc], @@atto.map.index
        jmp    .inline.proc.1p
   .inline.zepto:
        mov     [.proc], @@zepto.map.index
        jmp    .inline.proc.1p
   .inline.yocto:
        mov     [.proc], @@yocto.map.index
        jmp    .inline.proc.1p
; ------
   .inline.proc.1p:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.1p.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.1p.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.1p.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.1p.dcon,\
                OBJ_INT_VAR     , .inline.proc.1p.ivar,\
                OBJ_INT_CON     , .inline.proc.1p.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.1p.irsp.rax
        jmp    .error.argument
        ;
   .inline.proc.1p.con:
        stdcall map_proc_x3_rcx, @x3_procs_1p, [.proc], 2   ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.1p.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.con.call:
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
        ;
   .inline.proc.1p.dst0:
   .inline.proc.1p.dsse:
   .inline.proc.1p.dvar:
        jmp    .inline.proc.1p.proc
   .inline.proc.1p.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
    $else
        fld     qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.proc.1p.con
   .inline.proc.1p.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]
    $else
        fild    qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.proc.1p.con
   .inline.proc.1p.irsp.rax:
   .inline.proc.1p.ivar:
   .inline.proc.1p.proc.mode.1:
        mov     [.mode], 1
        mov     [.fpatype], 'i'
   .inline.proc.1p.proc:
        stdcall map_proc_x3, @x3_procs_1p, [.proc], [.mode]
        jmp    .inline.proc

; ------
;  .inline.isign:
;       mov     [.proc], @@isign.map.index
;       jmp    .inline.proc.1p.ir
;  .inline.risign:
;       mov     [.proc], @@risign.map.index
;       jmp    .inline.proc.1p.ir
   .inline.trunc:
        mov     [.proc], @@trunc.map.index
        jmp    .inline.proc.1p.ir
; ------
   .inline.proc.1p.ir:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.1p.ir.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.1p.ir.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.1p.ir.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.1p.ir.dcon,\
                OBJ_INT_VAR     , .inline.proc.1p.ir.ivar,\
                OBJ_INT_CON     , .inline.proc.1p.ir.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.1p.ir.irsp.rax
        jmp    .error.argument
        ;
   .inline.proc.1p.ir.dst0:
   .inline.proc.1p.ir.dsse:
   .inline.proc.1p.ir.dvar:
        jmp    .inline.proc.1p.ir.proc
   .inline.proc.1p.ir.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
    $else
        fld     qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        stdcall map_proc_x3_rcx, @x3_procs_1p_ir, [.proc], 1; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.1p.ir.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.ir.con.call:
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
        jmp    .inline.rax.icon
   .inline.proc.1p.ir.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 13-12, .error.memory
        @@xshl  rdi, 12
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x008B
        @@xshr  rdi, 13
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RAX, QWORD [RAX]  | 488B00
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.fpatype], 'i'
        stdcall map_proc_x3, @x3_procs_1p_ir, [.proc], 2
        jmp    .inline.proc
   .inline.proc.1p.ir.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 1
        add     [.RSP], 8
        stdcall map_proc_x3_rcx, @x3_procs_1p_ir, [.proc], 2; rcx = proc_reg offset
        test    rcx, rcx
        jnz    .inline.proc.1p.ir.con.call
        jmp    .error.exit
   .inline.proc.1p.ir.irsp.rax:
   .inline.proc.1p.ir.proc.mode.2:
        mov     [.mode], 2
        mov     [.fpatype], 'i'
   .inline.proc.1p.ir.proc:
        stdcall map_proc_x3, @x3_procs_1p_ir, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.sign:
        mov     [.proc], @@sign.map.index
        jmp    .inline.proc.1p.xr
   .inline.rsign:
        mov     [.proc], @@rsign.map.index
        jmp    .inline.proc.1p.xr
   .inline.chs:
        mov     [.proc], @@chs.map.index
        jmp    .inline.proc.1p.xr
   .inline.abs:
        mov     [.proc], @@abs.map.index
        jmp    .inline.proc.1p.xr
   .inline.nabs:
        mov     [.proc], @@nabs.map.index
        jmp    .inline.proc.1p.xr
   .inline.inc:
        mov     [.proc], @@inc.map.index
        jmp    .inline.proc.1p.xr
   .inline.dec:
        mov     [.proc], @@dec.map.index
        jmp    .inline.proc.1p.xr
   .inline.nzero:
        mov     [.proc], @@nzero.map.index
        jmp    .inline.proc.1p.xr
   .inline.rnzero:
        mov     [.proc], @@rnzero.map.index
        jmp    .inline.proc.1p.xr
   .inline.pos:
        mov     [.proc], @@pos.map.index
        jmp    .inline.proc.1p.xr
   .inline.neg:
        mov     [.proc], @@neg.map.index
        jmp    .inline.proc.1p.xr
   .inline.inv:
        mov     [.proc], @@inv.map.index
        jmp    .inline.proc.1p.xr
; ------
   .inline.ot:
        mov     [.proc], @@ot.map.index
        jmp    .inline.proc.1p.xr
   .inline.not:
        mov     [.proc], @@not.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.true:
        mov     [.proc], @@if.true.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.false:
        mov     [.proc], @@if.false.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.z:
        mov     [.proc], @@if.z.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.nz:
        mov     [.proc], @@if.nz.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.az:
        mov     [.proc], @@if.az.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.aez:
        mov     [.proc], @@if.aez.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.bz:
        mov     [.proc], @@if.bz.map.index
        jmp    .inline.proc.1p.xr
   .inline.if.bez:
        mov     [.proc], @@if.bez.map.index
        jmp    .inline.proc.1p.xr
; ------
   .inline.proc.1p.xr:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.1p.xr.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.1p.xr.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.1p.xr.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.1p.xr.dcon,\
                OBJ_INT_VAR     , .inline.proc.1p.xr.ivar,\
                OBJ_INT_CON     , .inline.proc.1p.xr.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.1p.xr.irsp.rax
        jmp    .error.argument
        ;
   .inline.proc.1p.xr.con:
        stdcall map_proc_x3_rcx, @x3_procs_1p_xr, [.proc], 2; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.1p.xr.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.xr.con.call:
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
        ;
   .inline.proc.1p.xr.dst0:
   .inline.proc.1p.xr.dsse:
   .inline.proc.1p.xr.dvar:
        jmp    .inline.proc.1p.xr.proc
   .inline.proc.1p.xr.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
    $else
        fld     qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.proc.1p.xr.con
   .inline.proc.1p.xr.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]
    $else
        fild    qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.proc.1p.xr.con
   .inline.proc.1p.xr.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall map_proc_x3_rcx, @x3_procs_1p_xr, [.proc], 1; rcx = proc.enter offset
        test    rcx, rcx
        jz     .error.exit
        ;
        @@range 13-12, .error.memory
        @@xshl  rdi, 12
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x008B
        @@xshr  rdi, 13
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RAX, QWORD [RAX]  | 488B00
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.fpatype], 'i'
        stdcall map_proc_x3, @x3_procs_1p_xr, [.proc], 1
        jmp    .inline.proc
   .inline.proc.1p.xr.irsp.rax:
   .inline.proc.1p.xr.proc.mode.1:
        mov     [.mode], 1
        mov     [.fpatype], 'i'
   .inline.proc.1p.xr.proc:
        stdcall map_proc_x3, @x3_procs_1p_xr, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.fmadd132:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fmadd132.fma
      $end
        mov     [.proc], @@fmadd132.map.index
        jmp    .inline.proc.3p
   .inline.fmadd132.fma:
        mov     [.proc], @@fmadd132.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fmadd213:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fmadd213.fma
      $end
        mov     [.proc], @@fmadd213.map.index
        jmp    .inline.proc.3p
   .inline.fmadd213.fma:
        mov     [.proc], @@fmadd213.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fmadd231:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fmadd231.fma
      $end
        mov     [.proc], @@fmadd231.map.index
        jmp    .inline.proc.3p
   .inline.fmadd231.fma:
        mov     [.proc], @@fmadd231.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fnmadd132:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fnmadd132.fma
      $end
        mov     [.proc], @@fnmadd132.map.index
        jmp    .inline.proc.3p
   .inline.fnmadd132.fma:
        mov     [.proc], @@fnmadd132.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fnmadd213:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fnmadd213.fma
      $end
        mov     [.proc], @@fnmadd213.map.index
        jmp    .inline.proc.3p
   .inline.fnmadd213.fma:
        mov     [.proc], @@fnmadd213.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fnmadd231:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fnmadd231.fma
      $end
        mov     [.proc], @@fnmadd231.map.index
        jmp    .inline.proc.3p
   .inline.fnmadd231.fma:
        mov     [.proc], @@fnmadd231.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fmsub132:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fmsub132.fma
      $end
        mov     [.proc], @@fmsub132.map.index
        jmp    .inline.proc.3p
   .inline.fmsub132.fma:
        mov     [.proc], @@fmsub132.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fmsub213:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fmsub213.fma
      $end
        mov     [.proc], @@fmsub213.map.index
        jmp    .inline.proc.3p
   .inline.fmsub213.fma:
        mov     [.proc], @@fmsub213.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fmsub231:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fmsub231.fma
      $end
        mov     [.proc], @@fmsub231.map.index
        jmp    .inline.proc.3p
   .inline.fmsub231.fma:
        mov     [.proc], @@fmsub231.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fnmsub132:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fnmsub132.fma
      $end
        mov     [.proc], @@fnmsub132.map.index
        jmp    .inline.proc.3p
   .inline.fnmsub132.fma:
        mov     [.proc], @@fnmsub132.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fnmsub213:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fnmsub213.fma
      $end
        mov     [.proc], @@fnmsub213.map.index
        jmp    .inline.proc.3p
   .inline.fnmsub213.fma:
        mov     [.proc], @@fnmsub213.fma.map.index
        jmp    .inline.proc.3p
        ;
   .inline.fnmsub231:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_FMA
        jnz    .inline.fnmsub231.fma
      $end
        mov     [.proc], @@fnmsub231.map.index
        jmp    .inline.proc.3p
   .inline.fnmsub231.fma:
        mov     [.proc], @@fnmsub231.fma.map.index
        jmp    .inline.proc.3p
; ------
   .inline.proc.3p:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.3p.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.3p.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.3p.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.3p.dcon
        jmp    .error.argument
        ;
   .inline.proc.3p.dst0:
   .inline.proc.3p.dsse:
   .inline.proc.3p.dvar:
   .inline.proc.3p.dcon:
        stdcall map_proc_x2, @x2_procs_3p, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.bsf:
        mov     [.proc], @@bsf.map.index
        jmp    .inline.iproc.i1p
   .inline.bsr:
        mov     [.proc], @@bsr.map.index
        jmp    .inline.iproc.i1p
        ;
   .inline.hammw:
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_POPCNT
        jnz    .inline.hammw.cpu
        mov     [.proc], @@hammw.map.index
        jmp    .inline.iproc.i1p
   .inline.hammw.cpu:
        mov     [.proc], @@hammw.cpu.map.index
        jmp    .inline.iproc.i1p
        ;
   .inline.bnot:
        mov     [.proc], @@bnot.map.index
        jmp    .inline.iproc.i1p
   .inline.bswap:
        mov     [.proc], @@bswap.map.index
        jmp    .inline.iproc.i1p
   .inline.b4swap:
        mov     [.proc], @@b4swap.map.index
        jmp    .inline.iproc.i1p
   .inline.b2swap:
        mov     [.proc], @@b2swap.map.index
        jmp    .inline.iproc.i1p
   .inline.bitswap:
        mov     [.proc], @@bitswap.map.index
        jmp    .inline.iproc.i1p
   .inline.bit32swap:
        mov     [.proc], @@bit32swap.map.index
        jmp    .inline.iproc.i1p
   .inline.bit16swap:
        mov     [.proc], @@bit16swap.map.index
        jmp    .inline.iproc.i1p
   .inline.bit8swap:
        mov     [.proc], @@bit8swap.map.index
        jmp    .inline.iproc.i1p
; ------
   .inline.iproc.i1p:
;       mov     [.mode], 0
        mov     [.fpatype], 'i'
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i1p.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i1p.ivar,\
                OBJ_INT_CON     , .inline.iproc.i1p.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i1p.irsp.rax
        jmp    .error.argument
        ;
   .inline.iproc.i1p.con:
        stdcall map_proc_x2_rcx, @x2_iprocs_i1p, [.proc], 1 ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.iproc.i1p.con.call
        jmp    .error.exit
   .inline.iproc.i1p.con.call:
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
   .inline.iproc.i1p.con.icon:
        jmp    .inline.rax.icon
        ;
   .inline.iproc.i1p.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.iproc.i1p.con
   .inline.iproc.i1p.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     rax, qword [rdi - 09]
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.iproc.i1p.con
   .inline.iproc.i1p.irsp.rax:
   .inline.iproc.i1p.ivar:
   .inline.iproc.i1p.proc:
        stdcall map_proc_x2, @x2_iprocs_i1p, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.mul.2pi:
        mov     [.proc], @@.mul.2pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.mul.pi:
        mov     [.proc], @@.mul.pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.mul.pi2:
        mov     [.proc], @@.mul.pi2.map.index
        jmp    .inline.proc.1p.dm
   .inline.mul.pi4:
        mov     [.proc], @@.mul.pi4.map.index
        jmp    .inline.proc.1p.dm
   .inline.div.2pi:
        mov     [.proc], @@.div.2pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.div.pi:
        mov     [.proc], @@.div.pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.div.pi2:
        mov     [.proc], @@.div.pi2.map.index
        jmp    .inline.proc.1p.dm
   .inline.div.pi4:
        mov     [.proc], @@.div.pi4.map.index
        jmp    .inline.proc.1p.dm
   .inline.quo.2pi:
        mov     [.proc], @@.quo.2pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.quo.pi:
        mov     [.proc], @@.quo.pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.quo.pi2:
        mov     [.proc], @@.quo.pi2.map.index
        jmp    .inline.proc.1p.dm
   .inline.quo.pi4:
        mov     [.proc], @@.quo.pi4.map.index
        jmp    .inline.proc.1p.dm
   .inline.mod.2pi:
        mov     [.proc], @@.mod.2pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.mod.pi:
        mov     [.proc], @@.mod.pi.map.index
        jmp    .inline.proc.1p.dm
   .inline.mod.pi2:
        mov     [.proc], @@.mod.pi2.map.index
        jmp    .inline.proc.1p.dm
   .inline.mod.pi4:
        mov     [.proc], @@.mod.pi4.map.index
        jmp    .inline.proc.1p.dm
; ------
   .inline.proc.1p.dm:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.1p.dm.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.1p.dm.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.1p.dm.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.1p.dm.dcon,\
                OBJ_INT_VAR     , .inline.proc.1p.dm.ivar,\
                OBJ_INT_CON     , .inline.proc.1p.dm.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.1p.dm.irsp.rax
        jmp    .error.argument
        ;
   .inline.proc.1p.dm.con:
        stdcall map_proc_x3_rcx, @x3_procs_1p_dm, [.proc], 2; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.1p.dm.con.call
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.1p.dm.con.call:
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
        ;
   .inline.proc.1p.dm.dst0:
   .inline.proc.1p.dm.dsse:
   .inline.proc.1p.dm.dvar:
        jmp    .inline.proc.1p.dm.proc
   .inline.proc.1p.dm.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
    $else
        fld     qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.proc.1p.dm.con
   .inline.proc.1p.dm.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]
    $else
        fild    qword [rdi - 09]
    $end
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .inline.proc.1p.dm.con
   .inline.proc.1p.dm.irsp.rax:
   .inline.proc.1p.dm.ivar:
   .inline.proc.1p.dm.proc.mode.1:
        mov     [.mode], 1
        mov     [.fpatype], 'i'
   .inline.proc.1p.dm.proc:
        stdcall map_proc_x3, @x3_procs_1p_dm, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.add:
        mov     [.proc], @@add.map.index
        jmp    .inline.proc.2p
   .inline.add.pos:
        mov     [.proc], @@add.pos.map.index
        jmp    .inline.proc.2p
   .inline.add.neg:
        mov     [.proc], @@add.neg.map.index
        jmp    .inline.proc.2p
   .inline.sub:
        mov     [.proc], @@sub.map.index
        jmp    .inline.proc.2p
   .inline.sub.pos:
        mov     [.proc], @@sub.pos.map.index
        jmp    .inline.proc.2p
   .inline.sub.neg:
        mov     [.proc], @@sub.neg.map.index
        jmp    .inline.proc.2p
   .inline.subr:
        mov     [.proc], @@subr.map.index
        jmp    .inline.proc.2p
   .inline.subr.pos:
        mov     [.proc], @@subr.pos.map.index
        jmp    .inline.proc.2p
   .inline.subr.neg:
        mov     [.proc], @@subr.neg.map.index
        jmp    .inline.proc.2p
   .inline.mul:
        mov     [.proc], @@mul.map.index
        jmp    .inline.proc.2p
   .inline.mul.pos:
        mov     [.proc], @@mul.pos.map.index
        jmp    .inline.proc.2p
   .inline.mul.neg:
        mov     [.proc], @@mul.neg.map.index
        jmp    .inline.proc.2p
   .inline.div:
        mov     [.proc], @@div.map.index
        jmp    .inline.proc.2p
   .inline.div.pos:
        mov     [.proc], @@div.pos.map.index
        jmp    .inline.proc.2p
   .inline.div.neg:
        mov     [.proc], @@div.neg.map.index
        jmp    .inline.proc.2p
   .inline.divr:
        mov     [.proc], @@divr.map.index
        jmp    .inline.proc.2p
   .inline.divr.pos:
        mov     [.proc], @@divr.pos.map.index
        jmp    .inline.proc.2p
   .inline.divr.neg:
        mov     [.proc], @@divr.neg.map.index
        jmp    .inline.proc.2p
   .inline.quo:
        mov     [.proc], @@quo.map.index
        jmp    .inline.proc.2p
   .inline.quo.pos:
        mov     [.proc], @@quo.pos.map.index
        jmp    .inline.proc.2p
   .inline.quo.neg:
        mov     [.proc], @@quo.neg.map.index
        jmp    .inline.proc.2p
   .inline.quor:
        mov     [.proc], @@quor.map.index
        jmp    .inline.proc.2p
   .inline.quor.pos:
        mov     [.proc], @@quor.pos.map.index
        jmp    .inline.proc.2p
   .inline.quor.neg:
        mov     [.proc], @@quor.neg.map.index
        jmp    .inline.proc.2p
   .inline.mod:
        mov     [.proc], @@mod.map.index
        jmp    .inline.proc.2p
   .inline.mod.pos:
        mov     [.proc], @@mod.pos.map.index
        jmp    .inline.proc.2p
   .inline.mod.neg:
        mov     [.proc], @@mod.neg.map.index
        jmp    .inline.proc.2p
   .inline.modr:
        mov     [.proc], @@modr.map.index
        jmp    .inline.proc.2p
   .inline.modr.pos:
        mov     [.proc], @@modr.pos.map.index
        jmp    .inline.proc.2p
   .inline.modr.neg:
        mov     [.proc], @@modr.neg.map.index
        jmp    .inline.proc.2p
; ------
   .inline.min:
        mov     [.proc], @@min.map.index
        jmp    .inline.proc.2p
   .inline.max:
        mov     [.proc], @@max.map.index
        jmp    .inline.proc.2p
   .inline.adev:
        mov     [.proc], @@adev.map.index
        jmp    .inline.proc.2p
   .inline.nadev:
        mov     [.proc], @@nadev.map.index
        jmp    .inline.proc.2p
; ------
   .inline.gcd:
        mov     [.proc], @@gcd.map.index
        jmp    .inline.proc.2p
   .inline.lcm:
        mov     [.proc], @@lcm.map.index
        jmp    .inline.proc.2p
; ------
   .inline.or:
        mov     [.proc], @@or.map.index
        jmp    .inline.proc.2p
   .inline.nor:
        mov     [.proc], @@nor.map.index
        jmp    .inline.proc.2p
   .inline.xor:
        mov     [.proc], @@xor.map.index
        jmp    .inline.proc.2p
   .inline.xnor:
        mov     [.proc], @@xnor.map.index
        jmp    .inline.proc.2p
   .inline.and:
        mov     [.proc], @@and.map.index
        jmp    .inline.proc.2p
   .inline.nand:
        mov     [.proc], @@nand.map.index
        jmp    .inline.proc.2p
; ------
   .inline.if.e:
        mov     [.proc], @@if.e.map.index
        jmp    .inline.proc.2p
   .inline.if.ne:
        mov     [.proc], @@if.ne.map.index
        jmp    .inline.proc.2p
   .inline.if.a:
        mov     [.proc], @@if.a.map.index
        jmp    .inline.proc.2p
   .inline.if.ae:
        mov     [.proc], @@if.ae.map.index
        jmp    .inline.proc.2p
   .inline.if.b:
        mov     [.proc], @@if.b.map.index
        jmp    .inline.proc.2p
   .inline.if.be:
        mov     [.proc], @@if.be.map.index
        jmp    .inline.proc.2p
   .inline.if.bea:
        mov     [.proc], @@if.bea.map.index
        jmp    .inline.proc.2p
   .inline.if.aeb:
        mov     [.proc], @@if.aeb.map.index
        jmp    .inline.proc.2p
; ------
   .inline.case.x32:
        mov     [.proc], @@case.x32.map.index
        jmp    .inline.proc.2p
   .inline.case.n32:
        mov     [.proc], @@case.n32.map.index
        jmp    .inline.proc.2p
   .inline.case.x64:
        mov     [.proc], @@case.x64.map.index
        jmp    .inline.proc.2p
   .inline.case.n64:
        mov     [.proc], @@case.n64.map.index
        jmp    .inline.proc.2p
; ------
   .inline.proc.2p:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ;?MOV     RCX, VALUE        | 48B9 DDDDDDDDDDDDDDDD ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.2p.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.2p.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.2p.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.2p.dcon,\
                OBJ_INT_VAR     , .inline.proc.2p.ivar,\
                OBJ_INT_CON     , .inline.proc.2p.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2p.irsp.rax,\
                OBJ_POINTER     , .inline.proc.2p.ptr
        jmp    .error.argument
        ;
   .inline.proc.2p.con.con:
;       stdcall map_proc_x3_rcx, @x3_procs_2p, [.proc], 2   ; rcx = proc.enter offset
        stdcall map_proc_x4_rcx, @x4_procs_2p, [.proc], 2   ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.2p.con.con.call
    $ifndef _SSEX
        fstp    st0
        fstp    st0
    $end
        jmp    .error.exit
   .inline.proc.2p.con.con.call:
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
        ;
        cmp     [.fretype], 'i'
    $ifdef _SSEX
        jne    .inline.sse.dcon.test
    $else
        jne    .inline.st0.dcon.test
    $end
        jmp    .inline.rax.icon
        ;
   .inline.proc.2p.dst0:
   .inline.proc.2p.dsse:
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2p.dvar.dst0,\
                OBJ_DOUBLE_SSE , .inline.proc.2p.dvar.dsse,\
                OBJ_DOUBLE_VAR , .inline.proc.2p.dvar.dvar,\
                OBJ_DOUBLE_CON , .inline.proc.2p.dvar.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.dvar.icon
        jmp    .error.argument
   .inline.proc.2p.dvar.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 21]                      ; xmm0 = int64 as double
        movsd   qword [rdi - 21], xmm0
    $else
        fild    qword [rdi - 21]                            ; st0 = int64 as double
        fstp    qword [rdi - 21]
    $end
        mov     [rdi - 23], word 0xB948
        mov     [rdi - 13], byte 0x51
;       add     [.RSP], 0
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.proc.2p.dvar.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        pcase   rsi,\
                @@div     , .inline.proc.2p.dvar.dcon.div,\
                @@div.pos , .inline.proc.2p.dvar.dcon.div.pos,\
                @@div.neg , .inline.proc.2p.dvar.dcon.div.neg
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar.dcon.div.pos:
        mov     [.procn], @@mul.pos.map.index
        jmp    .inline.proc.2p.dvar.dcon.div.x
   .inline.proc.2p.dvar.dcon.div.neg:
        mov     [.procn], @@mul.neg.map.index
        jmp    .inline.proc.2p.dvar.dcon.div.x
   .inline.proc.2p.dvar.dcon.div:
        mov     [.procn], @@mul.map.index
;       jmp    .inline.proc.2p.dvar.dcon.div.x
   .inline.proc.2p.dvar.dcon.div.x:                         ; a / c = a * (1/c)
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        divsd   xmm0, qword [rdi - 21]
    $else
        fld1
        fld     qword [rdi - 21]
        fdivp
    $end
   .inline.proc.2p.dvar.dcon.div.x.test:
    $ifdef _SSEX
        stmxcsr [.mxcsr]
        test    [.mxcsr], 00001101B                         ; test OE, ZE and IE flags
    $else
        fnstsw  ax
        fnclex
        test    ax, 00001101B                               ; test OE, ZE and IE flags
    $end
        jnz    .inline.proc.2p.dvar.dcon.div.x.error
   .inline.proc.2p.dvar.dcon.div.x.success:
    $ifdef _SSEX
        movsd   qword [rdi - 21], xmm0
    $else
        fstp    qword [rdi - 21]
    $end
        mov     rcx, [.procn]
        mov     [.proc], rcx
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar.dcon.div.x.error:
    $ifndef _SSEX
;       fstp    qword [rsp - 08]
        fstp    st0
    $end
        jmp    .error.evaluate
;       jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, qword [rdi - 10]
        mov     rdx, qword [rdi - 22]
        cmp     rcx, rdx
        jne    .inline.proc.2p.proc
        pcase   rsi,\
                @@sub      , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@sub.pos  , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@sub.neg  , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@subr     , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@subr.pos , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@subr.neg , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@div      , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@div.pos  , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@div.neg  , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@divr     , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@divr.pos , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@divr.neg , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@quo      , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@quo.pos  , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@quo.neg  , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@quor     , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@quor.pos , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@quor.neg , .inline.proc.2p.dvar.dvar.dcon.1,\
                @@mod      , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@mod.pos  , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@mod.neg  , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@modr     , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@modr.pos , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@modr.neg , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@adev     , .inline.proc.2p.dvar.dvar.dcon.0,\
                @@nadev    , .inline.proc.2p.dvar.dvar.dcon.0
        pcase   rsi,\
                @@if.e     , .inline.proc.2p.dvar.dvar.icon.1,\
                @@if.ne    , .inline.proc.2p.dvar.dvar.icon.0,\
                @@if.a     , .inline.proc.2p.dvar.dvar.icon.0,\
                @@if.ae    , .inline.proc.2p.dvar.dvar.icon.1,\
                @@if.b     , .inline.proc.2p.dvar.dvar.icon.0,\
                @@if.be    , .inline.proc.2p.dvar.dvar.icon.1,\
                @@if.bea   , .inline.proc.2p.dvar.dvar.icon.0,\
                @@if.aeb   , .inline.proc.2p.dvar.dvar.icon.0
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dvar.dvar.dcon.0:
        add     [.RSP], 16
        @@xshl  rdi, 24
    $ifdef _SSEX
        xorpd   xmm0, xmm0
        jmp    .inline.sse.dcon
    $else
        fldz
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.dvar.dvar.dcon.1:
        add     [.RSP], 16
        @@xshl  rdi, 24
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        jmp    .inline.sse.dcon
    $else
        fld1
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.dvar.dvar.icon.0:
        add     [.RSP], 16
        @@xshl  rdi, 24
        xor     rax, rax
        jmp    .inline.rax.icon
   .inline.proc.2p.dvar.dvar.icon.1:
        add     [.RSP], 16
        @@xshl  rdi, 24
        mov     rax, 1
        jmp    .inline.rax.icon
   .inline.proc.2p.dvar.dst0:
   .inline.proc.2p.dvar.dsse:
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.2p.dcon.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.2p.dcon.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.2p.dcon.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.2p.dcon.dcon,\
                OBJ_INT_VAR     , .inline.proc.2p.dcon.ivar,\
                OBJ_INT_CON     , .inline.proc.2p.dcon.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2p.dcon.irsp.rax
        jmp    .error.argument
   .inline.proc.2p.dcon.dst0:
   .inline.proc.2p.dcon.dsse:
   .inline.proc.2p.dcon.dvar:
        pcase   rsi,\
                @@divr     , .inline.proc.2p.dcon.dx.divr,\
                @@divr.pos , .inline.proc.2p.dcon.dx.divr.pos,\
                @@divr.neg , .inline.proc.2p.dcon.dx.divr.neg
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon.dx.divr.pos:
        mov     [.procn], @@mul.pos.map.index
        jmp    .inline.proc.2p.dcon.dx.divr.x
   .inline.proc.2p.dcon.dx.divr.neg:
        mov     [.procn], @@mul.neg.map.index
        jmp    .inline.proc.2p.dcon.dx.divr.x
   .inline.proc.2p.dcon.dx.divr:
        mov     [.procn], @@mul.map.index
;       jmp    .inline.proc.2p.dcon.dx.divr.x
   .inline.proc.2p.dcon.dx.divr.x:                          ; c ~/ a = a / c = a * (1/c)
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        divsd   xmm0, qword [rdi - 09]
    $else
        fld1
        fld     qword [rdi - 09]
        fdivp
    $end
   .inline.proc.2p.dcon.dx.divr.x.test:
    $ifdef _SSEX
        stmxcsr [.mxcsr]
        test    [.mxcsr], 00001101B                         ; test OE, ZE and IE flags
    $else
        fnstsw  ax
        fnclex
        test    ax, 00001101B                               ; test OE, ZE and IE flags
    $end
        jnz    .inline.proc.2p.dcon.dx.divr.x.error
   .inline.proc.2p.dcon.dx.divr.x.success:
    $ifdef _SSEX
        movsd   qword [rdi - 09], xmm0
    $else
        fstp    qword [rdi - 09]
    $end
        mov     rcx, [.procn]
        mov     [.proc], rcx
        jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon.dx.divr.x.error:
    $ifndef _SSEX
;       fstp    qword [rsp - 08]
        fstp    st0
    $end
        jmp    .error.evaluate
;       jmp    .inline.proc.2p.proc
   .inline.proc.2p.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
        movsd   xmm1, qword [rdi - 20]
    $else
        fld     qword [rdi - 09]
        fld     qword [rdi - 20]
    $end
        @@xshl  rdi, 22
        add     [.RSP], 16
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
       cvtsi2sd xmm1, qword [rdi - 20]
    $else
        fld     qword [rdi - 09]
        fild    qword [rdi - 20]
    $end
        @@xshl  rdi, 22
        add     [.RSP], 16
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.dcon.ivar:
   .inline.proc.2p.dcon.irsp.rax:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   RCX, QWORD      | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 9]                          ; rcx = constant
        stdcall f2i, rcx                                ; rax = int64 constant
        @@xshl  rdi, 11
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x50
        @@xshr  rdi, 11
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   RAX, INT64      | 48B8 FFFFFFFFFFFFFFFF
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        jmp    .inline.proc.2p.mode.1
        ;
   .inline.proc.2p.irsp.rax:
        jmp    .inline.proc.2p.mode.1
   .inline.proc.2p.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.proc.2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.proc.2p.ivar.ivar,\
                OBJ_INT_CON     , .inline.proc.2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.proc.2p.icon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.2p.icon.dst0,\
                OBJ_DOUBLE_SSE  , .inline.proc.2p.icon.dsse,\
                OBJ_DOUBLE_VAR  , .inline.proc.2p.icon.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.2p.icon.dcon,\
                OBJ_INT_VAR     , .inline.proc.2p.icon.ivar,\
                OBJ_INT_CON     , .inline.proc.2p.icon.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2p.icon.irsp.rax
        jmp    .error.argument
   .inline.proc.2p.icon.dst0:
   .inline.proc.2p.icon.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]                      ; xmm0 = int64 as double
        movsd   qword [rdi - 09], xmm0
    $else
        fild    qword [rdi - 09]                            ; st0 = int64 as double
        fstp    qword [rdi - 09]
    $end
        mov     [rdi - 11], word 0xB948
        mov     [rdi - 01], byte 0x51
;       add     [.RSP], 0
        ; --------------------------------------------------
        ; ...                       | ...
        ; FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ; MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        jmp    .inline.proc.2p.dcon.dst0
   .inline.proc.2p.icon.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]                      ; xmm0 = int64 as double
        movsd   qword [rdi - 09], xmm0
    $else
        fild    qword [rdi - 09]                            ; st0 = int64 as double
        fstp    qword [rdi - 09]
    $end
        mov     [rdi - 11], word 0xB948
        mov     [rdi - 01], byte 0x51
;       add     [.RSP], 0
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        jmp    .inline.proc.2p.dcon.dvar
   .inline.proc.2p.icon.dcon:
        ; ----------------------------------------------
        ; MOV   RCX, QWORD      | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]
        movsd   xmm1, qword [rdi - 20]
    $else
        fild    qword [rdi - 09]
        fld     qword [rdi - 20]
    $end
        @@xshl  rdi, 22
        add     [.RSP], 16
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.icon.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
       cvtsi2sd xmm0, qword [rdi - 09]
       cvtsi2sd xmm1, qword [rdi - 20]
    $else
        fild    qword [rdi - 09]
        fild    qword [rdi - 20]
    $end
        @@xshl  rdi, 22
        add     [.RSP], 16
        jmp    .inline.proc.2p.con.con
   .inline.proc.2p.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 21]                         ; rcx = constant
        stdcall f2i, rcx                                ; rax = int64 constant
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x50
        @@xshr  rdi, 23
        ; ----------------------------------------------
        ;*MOV   RAX, INT64      | 48B8 FFFFFFFFFFFFFFFF
        ; PUSH  RAX             | 50
        ; MOV   RAX, OFFSET     | 48B8 FFFFFFFFFFFFFFFF
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        jmp    .inline.proc.2p.mode.1
   .inline.proc.2p.ivar.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, qword [rdi - 10]
        mov     rdx, qword [rdi - 22]
        cmp     rcx, rdx
        je     .inline.proc.2p.ivar.ivar.x
        ;
        stdcall map_proc_x4_rcx, @x4_procs_2p, [.proc], 3   ; rcx = proc.enter offset
        test    rcx, rcx
        jz     .inline.proc.2p.mode.1
        ;
        @@range 26-24, .error.memory
        mov     rdx, [rdi - 22]
        mov     rax, [rdi - 10]
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rdx
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x088B
        mov     [rdi + 13], word 0xB848
        mov     [rdi + 15], rax
        mov     [rdi + 23], byte 0x48
        mov     [rdi + 24], word 0x008B
        @@xshr  rdi, 26
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RCX, QWORD [RAX]  | 488B08
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RAX, QWORD [RAX]  | 488B00
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.fpatype], 'i'
        stdcall map_proc_x4, @x4_procs_2p, [.proc], 3
        jmp    .inline.proc
   .inline.proc.2p.ivar.ivar.x:
        pcase   rsi,\
                @@sub      , .inline.proc.2p.ivar.ivar.icon.0,\
                @@sub.pos  , .inline.proc.2p.ivar.ivar.icon.0,\
                @@sub.neg  , .inline.proc.2p.ivar.ivar.icon.0,\
                @@subr     , .inline.proc.2p.ivar.ivar.icon.0,\
                @@subr.pos , .inline.proc.2p.ivar.ivar.icon.0,\
                @@subr.neg , .inline.proc.2p.ivar.ivar.icon.0,\
                @@div      , .inline.proc.2p.ivar.ivar.icon.1,\
                @@div.pos  , .inline.proc.2p.ivar.ivar.icon.1,\
                @@div.neg  , .inline.proc.2p.ivar.ivar.icon.1,\
                @@divr     , .inline.proc.2p.ivar.ivar.icon.1,\
                @@divr.pos , .inline.proc.2p.ivar.ivar.icon.1,\
                @@divr.neg , .inline.proc.2p.ivar.ivar.icon.1,\
                @@quo      , .inline.proc.2p.ivar.ivar.icon.1,\
                @@quo.pos  , .inline.proc.2p.ivar.ivar.icon.1,\
                @@quo.neg  , .inline.proc.2p.ivar.ivar.icon.1,\
                @@quor     , .inline.proc.2p.ivar.ivar.icon.1,\
                @@quor.pos , .inline.proc.2p.ivar.ivar.icon.1,\
                @@quor.neg , .inline.proc.2p.ivar.ivar.icon.1,\
                @@mod      , .inline.proc.2p.ivar.ivar.icon.0,\
                @@mod.pos  , .inline.proc.2p.ivar.ivar.icon.0,\
                @@mod.neg  , .inline.proc.2p.ivar.ivar.icon.0,\
                @@modr     , .inline.proc.2p.ivar.ivar.icon.0,\
                @@modr.pos , .inline.proc.2p.ivar.ivar.icon.0,\
                @@modr.neg , .inline.proc.2p.ivar.ivar.icon.0,\
                @@adev     , .inline.proc.2p.ivar.ivar.icon.0,\
                @@nadev    , .inline.proc.2p.ivar.ivar.icon.0
        pcase   rsi,\
                @@if.e     , .inline.proc.2p.ivar.ivar.icon.1,\
                @@if.ne    , .inline.proc.2p.ivar.ivar.icon.0,\
                @@if.a     , .inline.proc.2p.ivar.ivar.icon.0,\
                @@if.ae    , .inline.proc.2p.ivar.ivar.icon.1,\
                @@if.b     , .inline.proc.2p.ivar.ivar.icon.0,\
                @@if.be    , .inline.proc.2p.ivar.ivar.icon.1,\
                @@if.bea   , .inline.proc.2p.ivar.ivar.icon.0,\
                @@if.aeb   , .inline.proc.2p.ivar.ivar.icon.0
        jmp    .inline.proc.2p.mode.1
   .inline.proc.2p.ivar.ivar.dcon.0:
        add     [.RSP], 16
        @@xshl  rdi, 24
    $ifdef _SSEX
        xorpd   xmm0, xmm0
        jmp    .inline.sse.dcon
    $else
        fldz
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.ivar.ivar.dcon.1:
        add     [.RSP], 16
        @@xshl  rdi, 24
    $ifdef _SSEX
        xmovsd  xmm0, ??.1.0
        jmp    .inline.sse.dcon
    $else
        fld1
        jmp    .inline.st0.dcon
    $end
   .inline.proc.2p.ivar.ivar.icon.0:
        add     [.RSP], 16
        @@xshl  rdi, 24
        xor     rax, rax
        jmp    .inline.rax.icon
   .inline.proc.2p.ivar.ivar.icon.1:
        add     [.RSP], 16
        @@xshl  rdi, 24
        mov     rax, 1
        jmp    .inline.rax.icon
   .inline.proc.2p.ivar.icon:
   .inline.proc.2p.ivar.irsp.rax:
   .inline.proc.2p.icon.ivar:
   .inline.proc.2p.icon.irsp.rax:
   .inline.proc.2p.mode.1:
        mov     [.mode], 1
        mov     [.fpatype], 'i'
   .inline.proc.2p.proc:
;       stdcall map_proc_x3, @x3_procs_2p, [.proc], [.mode]
        stdcall map_proc_x4, @x4_procs_2p, [.proc], [.mode]
        jmp    .inline.proc
        ;
   .inline.proc.2p.ptr:
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, VALUE        | 48B9 DDDDDDDDDDDDDDDD ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -14                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.proc.2p.ptr.dcon,\
                OBJ_INT_CON    , .inline.proc.2p.ptr.icon
        jmp    .error.argument
   .inline.proc.2p.ptr.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, VALUE        | 48B9 DDDDDDDDDDDDDDDD ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 23]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rcx, [rdi - 12]                             ; rcx = offset value
        jmp    .inline.proc.2p.ptr.proc
   .inline.proc.2p.ptr.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, VALUE        | 48B9 DDDDDDDDDDDDDDDD ; pointer constant (14B)
        ; PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        mov     rax, [rdi - 23]                             ; rax = integer constant
        mov     rcx, [rdi - 12]                             ; rcx = offset value
;       jmp    .inline.proc.2p.ptr.proc
   .inline.proc.2p.ptr.proc:
        case    [.proc],\
                @@add.map.index, .inline.proc.2p.ptr.add,\
                @@sub.map.index, .inline.proc.2p.ptr.sub
        jmp    .error.argument
   .inline.proc.2p.ptr.sub:
        sub     rcx, rax
        jmp    .inline.proc.2p.ptr.main
   .inline.proc.2p.ptr.add:
        add     rcx, rax
   .inline.proc.2p.ptr.main:
        @@xshl  rdi, 25
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 16
        jmp    .exit

; ------
   .inline.bt:
        mov     [.proc], @@bt.map.index
        jmp    .inline.iproc.i2p
        ;
   .inline.hammd:
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_POPCNT
        jnz    .inline.hammd.cpu
        mov     [.proc], @@hammd.map.index
        jmp    .inline.iproc.i2p
   .inline.hammd.cpu:
        mov     [.proc], @@hammd.cpu.map.index
        jmp    .inline.iproc.i2p
        ;
   .inline.bor:
        mov     [.proc], @@bor.map.index
        jmp    .inline.iproc.i2p
   .inline.bnor:
        mov     [.proc], @@bnor.map.index
        jmp    .inline.iproc.i2p
   .inline.born:
        mov     [.proc], @@born.map.index
        jmp    .inline.iproc.i2p
   .inline.bnorn:
        mov     [.proc], @@bnorn.map.index
        jmp    .inline.iproc.i2p
   .inline.borc:
        mov     [.proc], @@borc.map.index
        jmp    .inline.iproc.i2p
   .inline.bnorc:
        mov     [.proc], @@bnorc.map.index
        jmp    .inline.iproc.i2p
   .inline.bcor:
        mov     [.proc], @@bcor.map.index
        jmp    .inline.iproc.i2p
   .inline.bcorn:
        mov     [.proc], @@bcorn.map.index
        jmp    .inline.iproc.i2p
   .inline.bxor:
        mov     [.proc], @@bxor.map.index
        jmp    .inline.iproc.i2p
   .inline.bxnor:
        mov     [.proc], @@bxnor.map.index
        jmp    .inline.iproc.i2p
   .inline.band:
        mov     [.proc], @@band.map.index
        jmp    .inline.iproc.i2p
   .inline.bnand:
        mov     [.proc], @@bnand.map.index
        jmp    .inline.iproc.i2p
        ;
   .inline.bandn:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_BMI1
        jnz    .inline.bandn.bmi
      $end
        mov     [.proc], @@bandn.map.index
        jmp    .inline.iproc.i2p
   .inline.bandn.bmi:
        mov     [.proc], @@bandn.bmi.map.index
        jmp    .inline.iproc.i2p
        ;
   .inline.bnandn:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_BMI1
        jnz    .inline.bnandn.bmi
      $end
        mov     [.proc], @@bnandn.map.index
        jmp    .inline.iproc.i2p
   .inline.bnandn.bmi:
        mov     [.proc], @@bnandn.bmi.map.index
        jmp    .inline.iproc.i2p
        ;
   .inline.breset:
        mov     [.proc], @@breset.map.index
        jmp    .inline.iproc.i2p
   .inline.bset:
        mov     [.proc], @@bset.map.index
        jmp    .inline.iproc.i2p
        ;
   .inline.shr:
        mov     [.proc], @@shr.map.index
        jmp    .inline.iproc.i2p
   .inline.shl:
        mov     [.proc], @@shl.map.index
        jmp    .inline.iproc.i2p
   .inline.sar:
        mov     [.proc], @@sar.map.index
        jmp    .inline.iproc.i2p
   .inline.sal:
        mov     [.proc], @@sal.map.index
        jmp    .inline.iproc.i2p
   .inline.ror:
        mov     [.proc], @@ror.map.index
        jmp    .inline.iproc.i2p
   .inline.rol:
        mov     [.proc], @@rol.map.index
        jmp    .inline.iproc.i2p
; ------
   .inline.igcd:
        mov     [.proc], @@igcd.map.index
        jmp    .inline.iproc.i2p
   .inline.ilcm:
        mov     [.proc], @@ilcm.map.index
        jmp    .inline.iproc.i2p
; ------
   .inline.iproc.i2p:
;       mov     [.mode], 0
        mov     [.fpatype], 'i'
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.irsp.rax
        jmp    .error.argument
        ;
   .inline.iproc.i2p.con.con:
        stdcall map_proc_x2_rdx, @x2_iprocs_i2p, [.proc], 1 ; rdx = proc.enter offset
        test    rdx, rdx
        jnz    .inline.iproc.i2p.con.con.call
        jmp    .error.exit
   .inline.iproc.i2p.con.con.call:
        @@xshl  rdi, [.xshl], rax
        push    rdi rbx ; save registers when calling the built-in function
        mov     rax, [.icon1]
        mov     rcx, [.icon2]
        call    rdx
        pop     rbx rdi
   .inline.iproc.i2p.con.con.icon:
        jmp    .inline.rax.icon
        ;
   .inline.iproc.i2p.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.ivar.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.ivar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        @@xshl  rdi, 23
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x50
        @@xshr  rdi, 23
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.ivar.ivar:
   .inline.iproc.i2p.ivar.icon:
   .inline.iproc.i2p.ivar.irsp.rax:
        jmp    .inline.iproc.i2p.proc
        ;
   .inline.iproc.i2p.irsp.rax:
        jmp    .inline.iproc.i2p.proc
        ;
   .inline.iproc.i2p.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.dcon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.dcon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.dcon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.dcon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.dcon.ivar:
   .inline.iproc.i2p.dcon.irsp.rax:
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon1], rax
        mov     rcx, [rdi - 20]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon1], rax
        mov     rax, [rdi - 20]                             ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.icon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.icon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.icon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.icon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.icon.ivar:
   .inline.iproc.i2p.icon.irsp.rax:
        jmp    .inline.iproc.i2p.proc
   .inline.iproc.i2p.icon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rax, [rdi - 09]                             ; rax = int64 constant
        mov     [.icon1], rax
        mov     rcx, [rdi - 20]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.icon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rax, [rdi - 09]                             ; rax = int64 constant
        mov     [.icon1], rax
        mov     rax, [rdi - 20]                             ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.con.con
   .inline.iproc.i2p.proc:
        stdcall map_proc_x2, @x2_iprocs_i2p, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.btc:
        mov     [.proc], @@btc.map.index
        jmp    .inline.iproc.i2p.iv
   .inline.btr:
        mov     [.proc], @@btr.map.index
        jmp    .inline.iproc.i2p.iv
   .inline.bts:
        mov     [.proc], @@bts.map.index
        jmp    .inline.iproc.i2p.iv
   .inline.iproc.i2p.iv:
;       mov     [.mode], 0
        mov     [.fpatype], 'i'
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.irsp.rax
        jmp    .error.argument
        ;
   .inline.iproc.i2p.iv.con.con:
        stdcall map_proc_x4_rdx, @x4_iprocs_i2p, [.proc], 1 ; rdx = proc.enter offset
        test    rdx, rdx
        jnz    .inline.iproc.i2p.iv.con.con.call
        jmp    .error.exit
   .inline.iproc.i2p.iv.con.con.call:
        @@xshl  rdi, [.xshl], rax
        push    rdi rbx ; save registers when calling the built-in function
        mov     rax, [.icon1]
        mov     rcx, [.icon2]
        call    rdx
        pop     rbx rdi
   .inline.iproc.i2p.iv.con.con.icon:
        jmp    .inline.rax.icon
        ;
   .inline.iproc.i2p.iv.irsp.rax:
        jmp    .inline.iproc.i2p.iv.proc
        ;
   .inline.iproc.i2p.iv.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.dcon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.dcon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.dcon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.dcon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.iv.dcon.ivar:
   .inline.iproc.i2p.iv.dcon.irsp.rax:
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon1], rax
        mov     rcx, [rdi - 20]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.dcon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon1], rax
        mov     rax, [rdi - 20]                             ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.icon.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.icon.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.icon.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.icon.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.iv.icon.ivar:
   .inline.iproc.i2p.iv.icon.irsp.rax:
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.icon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rax, [rdi - 09]                             ; rax = int64 constant
        mov     [.icon1], rax
        mov     rcx, [rdi - 20]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.icon.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 22
        mov     rax, [rdi - 09]                             ; rax = int64 constant
        mov     [.icon1], rax
        mov     rax, [rdi - 20]                             ; rax = int64 constant
        mov     [.icon2], rax
        add     [.RSP], 16
        jmp    .inline.iproc.i2p.iv.con.con
   .inline.iproc.i2p.iv.proc:
        stdcall map_proc_x4, @x4_iprocs_i2p, [.proc], [.mode]
        jmp    .inline.proc
        ;
   .inline.iproc.i2p.iv.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.iproc.i2p.iv.ivar.dcon,\
                OBJ_INT_VAR     , .inline.iproc.i2p.iv.ivar.ivar,\
                OBJ_INT_CON     , .inline.iproc.i2p.iv.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.iproc.i2p.iv.ivar.irsp.rax
        jmp    .error.argument
   .inline.iproc.i2p.iv.ivar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rdx, [rdi - 10]                             ; rdx = offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RAX, INT32        | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.mode], 3
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.ivar.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = offset
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RAX, INT32        | 48B8 FFFFFFFFFFFFFFFF
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.mode], 3
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF
        ; ADD     RSP, 8            | 4883C408
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.mode], 3
        jmp    .inline.iproc.i2p.iv.proc
   .inline.iproc.i2p.iv.ivar.ivar:
        @@xshl  rdi, 12
        mov     [rdi + 1], byte 0xB9
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        mov     [.mode], 2
        jmp    .inline.iproc.i2p.iv.proc

; ------
   .inline.ipow:
        cmp     [.arg.count], 2
        jl     .error.argument
        mov     rcx, [.arg.cursor]
        cmp     byte [rcx - 1], 'f'                         ; argument #1 data type
        jne    .error.argument
        cmp     byte [rcx - 3], 'i'                         ; argument #2 data type
        jne    .error.argument
        jmp    .inline.proc

; ------
   .inline.pow:
        mov     [.proc], @@pow.map.index
        jmp    .inline.proc.2ps
   .inline.pow.??:
        mov     [.proc.mode], 1
        mov     [.proc], @@pow.map.index
        jmp    .inline.proc.2ps
   .inline.root:
        mov     [.proc], @@root.map.index
        jmp    .inline.proc.2ps
; ------
   .inline.proc.2ps:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ;-integer constant (11B)
        ;?PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_SSE  , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_VAR  , .inline.proc.2ps.dvar,\
                OBJ_DOUBLE_CON  , .inline.proc.2ps.dcon,\
                OBJ_INT_VAR     , .inline.proc.2ps.ivar,\
                OBJ_INT_CON     , .inline.proc.2ps.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2ps.irsp.rax
        jmp    .error.argument
        ;
   .inline.proc.2ps.ivar:
   .inline.proc.2ps.icon:
   .inline.proc.2ps.irsp.rax:
        cmp     [.proc.mode], 1
        jne    .error.argument
        mov     [.fretype], 'i'                             ; integer bxor(x,y)
        jmp    .inline.bxor
        ;
   .inline.proc.2ps.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_SSE , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_VAR , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_CON , .inline.proc.2ps.dvar.dcon
        jmp    .error.argument
        ;
   .inline.proc.2ps.dvar.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = double constant
        case    rcx,\
                [??.0.0.H], .inline.proc.2ps.dvar.dcon.0,\
                [??.1.0.H], .inline.proc.2ps.dvar.dcon.1,\
                [??.2.0.H], .inline.proc.2ps.dvar.dcon.2,\
                [??.3.0.H], .inline.proc.2ps.dvar.dcon.3,\
                [??.4.0.H], .inline.proc.2ps.dvar.dcon.4
   .inline.proc.2ps.dvar.dcon.x:
        jmp    .inline.proc.2ps.proc
        ;
   .inline.proc.2ps.dvar.dcon.0:
;       mov     [.moden], 3
        stdcall map_proc_x8, @x8_procs_2ps, [.proc], 3
        test    rsi, rsi
        jz     .inline.proc.2ps.proc
        @@xshl  rdi, 23
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.proc
        ;
   .inline.proc.2ps.dvar.dcon.1:
        mov     [.moden], 4
        jmp    .inline.proc.2ps.dvar.dcon.n
   .inline.proc.2ps.dvar.dcon.2:
        mov     [.moden], 5
        jmp    .inline.proc.2ps.dvar.dcon.n
   .inline.proc.2ps.dvar.dcon.3:
        mov     [.moden], 6
        jmp    .inline.proc.2ps.dvar.dcon.n
   .inline.proc.2ps.dvar.dcon.4:
        mov     [.moden], 7
        jmp    .inline.proc.2ps.dvar.dcon.n
   .inline.proc.2ps.dvar.dcon.n:
        stdcall map_proc_x8, @x8_procs_2ps, [.proc], [.moden]
        test    rsi, rsi
        jz     .inline.proc.2ps.proc
        mov     rdx, [rdi - 10]                             ; rdx = double variable offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0x31FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
        ;
   .inline.proc.2ps.dcon:
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_SSE , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_VAR , .inline.proc.2ps.proc,\
                OBJ_DOUBLE_CON , .inline.proc.2ps.dcon.dcon
        jmp    .error.argument
        ;
   .inline.proc.2ps.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 20]
        call    @@frac.enter
        movsd   qword [.dcon2], xmm0
    $else
        fld     qword [rdi - 20]
        call    @@frac.enter
        fstp    qword [.dcon2]
    $end
        mov     rcx, qword [.dcon2]
        test    rcx, rcx
        jnz    .inline.proc.2ps.dcon.dcon.main
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 20]
      cvttsd2si rcx, xmm0
    $else
        fld     qword [rdi - 20]
        call    @@int.enter
        fistp   qword [.icon1]
        mov     rcx, qword [.icon1]
    $end
   .inline.proc.2ps.dcon.dcon.i:
        test    rcx, 1
        jnz    .inline.proc.2ps.dcon.dcon.main
   .inline.proc.2ps.dcon.dcon.i.even:
;       mov     [.moden], 1
        stdcall map_proc_x8_rcx, @x8_procs_2ps, [.proc], 1  ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2ps.dcon.dcon.main:
;       mov     [.moden], 2
        stdcall map_proc_x8_rcx, @x8_procs_2ps, [.proc], 2  ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2ps.proc:
        stdcall map_proc_x8, @x8_procs_2ps, [.proc], [.mode]
        jmp    .inline.proc
; ------
; ------
   .inline.powr:
        mov     [.proc], @@powr.map.index
        jmp    .inline.proc.2pr
   .inline.powr.??:
        mov     [.proc.mode], 1
        mov     [.proc], @@powr.map.index
        jmp    .inline.proc.2pr
   .inline.rootr:
        mov     [.proc], @@rootr.map.index
        jmp    .inline.proc.2pr
; ------
   .inline.proc.2pr:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.proc.2pr.proc,\
                OBJ_DOUBLE_SSE  , .inline.proc.2pr.proc,\
                OBJ_DOUBLE_VAR  , .inline.proc.2pr.proc,\
                OBJ_DOUBLE_CON  , .inline.proc.2pr.dcon,\
                OBJ_INT_VAR     , .inline.proc.2pr.ivar,\
                OBJ_INT_CON     , .inline.proc.2pr.icon,\
                OBJ_INT_RSP_RAX , .inline.proc.2pr.irsp.rax
        jmp    .error.argument
        ;
   .inline.proc.2pr.ivar:
   .inline.proc.2pr.icon:
   .inline.proc.2pr.irsp.rax:
        cmp     [.proc.mode], 1
        jne    .error.argument
        mov     [.fretype], 'i'                             ; integer bxnor(x,y)
        jmp    .inline.bxnor
        ;
   .inline.proc.2pr.dcon:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.proc.2pr.dcon.x,\
                OBJ_DOUBLE_SSE , .inline.proc.2pr.dcon.x,\
                OBJ_DOUBLE_VAR , .inline.proc.2pr.dcon.x,\
                OBJ_DOUBLE_CON , .inline.proc.2pr.dcon.dcon
        jmp    .error.argument
        ;
   .inline.proc.2pr.dcon.x:
        mov     rcx, [rdi - 09]                             ; rcx = double constant
        case    rcx,\
                [??.0.0.H], .inline.proc.2pr.dcon.0,\
                [??.1.0.H], .inline.proc.2pr.dcon.1,\
                [??.2.0.H], .inline.proc.2pr.dcon.2,\
                [??.3.0.H], .inline.proc.2pr.dcon.3,\
                [??.4.0.H], .inline.proc.2pr.dcon.4
        jmp    .inline.proc.2pr.proc
        ;
   .inline.proc.2pr.dcon.0:
        mov     [.moden], 3
        jmp    .inline.proc.2pr.dcon.n
   .inline.proc.2pr.dcon.1:
        mov     [.moden], 4
        jmp    .inline.proc.2pr.dcon.n
   .inline.proc.2pr.dcon.2:
        mov     [.moden], 5
        jmp    .inline.proc.2pr.dcon.n
   .inline.proc.2pr.dcon.3:
        mov     [.moden], 6
        jmp    .inline.proc.2pr.dcon.n
   .inline.proc.2pr.dcon.4:
        mov     [.moden], 7
        jmp    .inline.proc.2pr.dcon.n
   .inline.proc.2pr.dcon.n:
        stdcall map_proc_x8, @x8_procs_2pr, [.proc], [.moden]
        test    rsi, rsi
        jz     .inline.proc.2pr.proc
        @@xshl  rdi, 11
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
        ;
   .inline.proc.2pr.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
        call    @@frac.enter
        movsd   qword [.dcon2], xmm0
    $else
        fld     qword [rdi - 09]
        call    @@frac.enter
        fstp    qword [.dcon2]
    $end
        mov     rcx, qword [.dcon2]
        test    rcx, rcx
        jnz    .inline.proc.2pr.dcon.dcon.main
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
      cvttsd2si rcx, xmm0
    $else
        fld     qword [rdi - 09]
        call    @@int.enter
        fistp   qword [.icon1]
        mov     rcx, qword [.icon1]
    $end
   .inline.proc.2pr.dcon.i.dcon:
        test    rcx, 1
        jnz    .inline.proc.2pr.dcon.dcon.main
   .inline.proc.2pr.dcon.i.even.dcon:
;       mov     [.moden], 1
        stdcall map_proc_x8_rcx, @x8_procs_2pr, [.proc], 1  ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2pr.dcon.dcon.main:
;       mov     [.moden], 2
        stdcall map_proc_x8_rcx, @x8_procs_2pr, [.proc], 2  ; rcx = proc.enter offset
        test    rcx, rcx
        jnz    .inline.proc.2px.dcon.dcon
   .inline.proc.2pr.proc:
        stdcall map_proc_x8, @x8_procs_2pr, [.proc], [.mode]
        jmp    .inline.proc
; ------
; ------
   .inline.proc.2px.dcon.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        movsd   xmm0, qword [rdi - 09]
        movsd   xmm1, qword [rdi - 20]
    $else
        fld     qword [rdi - 09]
        fld     qword [rdi - 20]
    $end
        @@xshl  rdi, 22
        push    rdi rbx ; save registers when calling the built-in function
        call    rcx
        pop     rbx rdi
        add     [.RSP], 16
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end

; ------
   .inline.co.chs:
        mov     [.proc], @@co.chs.map.index
        jmp    .inline.co.proc.1p
   .inline.co.abs:
        mov     [.proc], @@co.abs.map.index
        jmp    .inline.co.proc.1p
   .inline.co.nabs:
        mov     [.proc], @@co.nabs.map.index
        jmp    .inline.co.proc.1p
   .inline.co.rcopy:
        mov     [.proc], @@co.rcopy.map.index
        jmp    .inline.co.proc.1p
; ------
   .inline.co.proc.1p:
;       mov     [.mode], 0
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.co.proc.1p.dvar,\
                OBJ_INT_VAR    , .inline.co.proc.1p.ivar
        jmp    .error.argument
   .inline.co.proc.1p.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.proc
   .inline.co.proc.1p.ivar:
        mov     [.mode], 1
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     [rdi - 12], word 0xB948
        @@xshl  rdi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
   .inline.co.proc.1p.ivar.proc:
        stdcall map_proc_x2, @x2_co_procs_1p, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.co.bnot:
; ------
   .inline.co.iproc.1p:
        ; ----------------------------------------------
        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.co.iproc.1p.ivar
        jmp    .error.argument
   .inline.co.iproc.1p.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     [rdi - 12], word 0xB948
        @@xshl  rdi, 2
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        jmp    .inline.proc

; ------
   .inline.co.add:
        mov     [.proc], @@co.add.map.index
        jmp    .inline.co.proc.2p
   .inline.co.sub:
        mov     [.proc], @@co.sub.map.index
        jmp    .inline.co.proc.2p
   .inline.co.subr:
        mov     [.proc], @@co.subr.map.index
        jmp    .inline.co.proc.2p
   .inline.co.mul:
        mov     [.proc], @@co.mul.map.index
        jmp    .inline.co.proc.2p
   .inline.co.div:
        mov     [.proc], @@co.div.map.index
        jmp    .inline.co.proc.2p
   .inline.co.divr:
        mov     [.proc], @@co.divr.map.index
        jmp    .inline.co.proc.2p
   .inline.co.quo:
        mov     [.proc], @@co.quo.map.index
        jmp    .inline.co.proc.2p
   .inline.co.quor:
        mov     [.proc], @@co.quor.map.index
        jmp    .inline.co.proc.2p
   .inline.co.mod:
        mov     [.proc], @@co.mod.map.index
        jmp    .inline.co.proc.2p
   .inline.co.modr:
        mov     [.proc], @@co.modr.map.index
        jmp    .inline.co.proc.2p
; ------
   .inline.co.proc.2p:
;       mov     [.mode], 0
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.co.proc.2p.dvar,\
                OBJ_INT_VAR    , .inline.co.proc.2p.ivar,\
                OBJ_STRING_VAR , .inline.co.proc.2p.svar
        jmp    .error.argument
   .inline.co.proc.2p.dvar:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.co.proc.2p.dvar.x:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.co.proc.2p.dvar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.co.proc.2p.dvar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.co.proc.2p.dvar.dvar,\
                OBJ_DOUBLE_CON  , .inline.co.proc.2p.dvar.dcon,\
                OBJ_INT_VAR     , .inline.co.proc.2p.dvar.ivar,\
                OBJ_INT_CON     , .inline.co.proc.2p.dvar.icon,\
                OBJ_INT_RSP_RAX , .inline.co.proc.2p.dvar.irsp.rax
        jmp    .error.argument
   .inline.co.proc.2p.dvar.dst0:
   .inline.co.proc.2p.dvar.dsse:
   .inline.co.proc.2p.dvar.dvar:
   .inline.co.proc.2p.dvar.dcon:
        ; ----------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 2                                  ; remove last PUSH... instruction
        ; ----------------------------------------------
        ; ...
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.co.proc.2p.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 24-14, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0xC4834800
        mov     [rdi + 18], dword 0x110FF2F8
        mov     [rdi + 22], word 0x2404
        @@xshr  rdi, 24
        ; ----------------------------------------------
        ; MOV      RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV      RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; CVTSI2SD XMM0, QWORD [RAX] | F2480F2A00
        ; ADD      RSP, -8           | 4883C4F8
        ; MOVSD    QWORD [RSP], XMM0 | F20F110424
        ;>
        ; ----------------------------------------------
    $else
        @@range 19-14, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x834828DF
        mov     [rdi + 14], dword 0x1CDDF8C4
        mov     [rdi + 18], byte 0x24
        @@xshr  rdi, 19
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; FILD  QWORD [RAX]     | DF28
        ; ADD   RSP, -8         | 4883C4F8
        ; FSTP  QWORD [RSP]     | DD1C24
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.co.proc.2p.dvar.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 20-12, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0x110FF2C0
        mov     [rdi + 18], word 0x2404
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ; MOV      RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH     RAX               | 50
        ;*MOV      RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; CVTSI2SD XMM0, RAX         | F2480F2AC0
        ; MOVSD    QWORD [RSP], XMM0 | F20F110424
        ;>
        ; ----------------------------------------------
    $else
        @@range 16-12, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0xDD242CDF
        mov     [rdi + 14], word 0x241C
        @@xshr  rdi, 16
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH  RAX             | 50
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; FILD  QWORD [RSP]     | DF2C24
        ; FSTP  QWORD [RSP]     | DD1C24
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.co.proc.2p.dvar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 20-16, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0x110FF2C0
        mov     [rdi + 18], word 0x2404
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ; ...                        | ...
        ;*MOV      RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; CVTSI2SD XMM0, RAX         | F2480F2AC0
        ; MOVSD    QWORD [RSP], XMM0 | F20F110424
        ;>
        ; ----------------------------------------------
    $else
        @@range 6-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0xDD242CDF
        mov     [rdi + 04], word 0x241C
        @@xshr  rdi, 6
        ; ----------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;*FILD    QWORD [RSP]       | DF2C24
        ; FSTP    QWORD [RSP]       | DD1C24
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
        ;
   .inline.co.proc.2p.ivar:
        mov     [.mode], 1
   .inline.co.proc.2p.ivar.x:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
   .inline.co.proc.2p.ivar.xx:
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.co.proc.2p.ivar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.co.proc.2p.ivar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.co.proc.2p.ivar.dvar,\
                OBJ_DOUBLE_CON  , .inline.co.proc.2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.co.proc.2p.ivar.ivar,\
                OBJ_INT_CON     , .inline.co.proc.2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.co.proc.2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.co.proc.2p.ivar.dst0:
        ; ----------------------------------------------
        ; ...                   | ...
        ;*FSTP  QWORD [RSP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 22-15, .error.memory
        mov     rcx, @@__int64                          ; rcx = "int" proc offset
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0xB948D2FF
        mov     [rdi + 14], rdx
        @@xshr  rdi, 22
        ; ----------------------------------------------
        ;*MOV   RDX, @@__int64  | 48BA PPPPPPPPPPPPPPPP
        ; CALL  RDX             | FFD2
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
;       @@range 15-17, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], dword 0x2C0F48F2
        mov     [rdi + 04], dword 0x00B948C0
        mov     [rdi + 07], rdx
        @@xshr  rdi, 15
        ; --------------------------------------------------
        ;*CVTTSD2SI  RAX, XMM0   | F2480F2CC0
        ; MOV        RCX, OFFSET | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 19-14, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x01100FF2
        mov     [rdi + 04], dword 0x2C0F48F2
        mov     [rdi + 08], dword 0x00B948C0
        mov     [rdi + 11], rdx
        @@xshr  rdi, 19
        ; ----------------------------------------------
        ; MOV        RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ;*MOVSD      XMM0, QWORD [RCX] | F20F1001
        ; CVTTSD2SI  RAX, XMM0         | F2480F2CC0
        ; MOV        RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        @@range 24-14, .error.memory
        mov     rcx, @@__int64                          ; rcx = "int" proc offset
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0xBA4801DD
        mov     [rdi + 04], rcx
        mov     [rdi + 12], dword 0xB948D2FF
        mov     [rdi + 16], rdx
        @@xshr  rdi, 24
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS
        ;*FLD   QWORD [RCX]     | DD01
        ; MOV   RDX, @@__int64  | 48BA PPPPPPPPPPPPPPPP
        ; CALL  RDX             | FFD2
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 21]                         ; rcx = constant
        stdcall f2i, rcx                                ; rax = int64 constant
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        cmp     rax, +1
        je     .inline.co.proc.2p.ivar.dcon.p1
        cmp     rax, -1
        je     .inline.co.proc.2p.ivar.dcon.m1
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, INT64      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dcon.p1:
        mov     [.mode], 2
   .inline.co.proc.2p.ivar.dcon.p1.x:
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.dcon.m1:
        mov     [.mode], 3
   .inline.co.proc.2p.ivar.dcon.m1.x:
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x00008B48
        mov     [rdi + 03], word 0xB948
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RAX, [RAX]      | 488B00
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;*PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 21]                         ; rax = integer constant
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        cmp     rax, +1
        je     .inline.co.proc.2p.ivar.icon.p1
        cmp     rax, -1
        je     .inline.co.proc.2p.ivar.icon.m1
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C4 08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.icon.p1:
        mov     [.mode], 2
   .inline.co.proc.2p.ivar.icon.p1.x:
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.icon.m1:
        mov     [.mode], 3
   .inline.co.proc.2p.ivar.icon.m1.x:
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.co.proc.2p.ivar.proc
   .inline.co.proc.2p.ivar.proc:
        stdcall map_proc_x4, @x4_co_procs_2p, [.proc], [.mode]
        jmp    .inline.proc
        ;
   .inline.co.proc.2p.svar:
        mov     [.mode], 1
   .inline.co.proc.2p.svar.x:
        ; ----------------------------------------------
        ; ...                   | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        case    [.proc],\
                @@co.add.map.index  , .inline.co.proc.2p.svar.add,\
                @@co.sub.map.index  , .inline.co.proc.2p.svar.sub,\
                @@co.subr.map.index , .inline.co.proc.2p.svar.subr
        jmp    .error.exit
   .inline.co.proc.2p.svar.subr:
        mov     [.proc], @@co.str.subr.map.index
        jmp    .inline.co.proc.2p.svar.xx
   .inline.co.proc.2p.svar.sub:
        mov     [.proc], @@co.str.sub.map.index
        jmp    .inline.co.proc.2p.svar.xx
   .inline.co.proc.2p.svar.add:
        mov     [.proc], @@co.str.add.map.index
;       jmp    .inline.co.proc.2p.svar.xx
   .inline.co.proc.2p.svar.xx:
        stdcall code_object, [.cooff], -12              ; ecx = object type
        mov     [.FPU], 0
        jmp    .inline.co.proc.2p.ivar.xx

; ------
   .inline.co.bor:
        mov     [.proc], @@co.bor.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bnor:
        mov     [.proc], @@co.bnor.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.born:
        mov     [.proc], @@co.born.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bnorn:
        mov     [.proc], @@co.bnorn.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.borc:
        mov     [.proc], @@co.borc.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bnorc:
        mov     [.proc], @@co.bnorc.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bcor:
        mov     [.proc], @@co.bcor.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bcorn:
        mov     [.proc], @@co.bcorn.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bxor:
        mov     [.proc], @@co.bxor.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bxnor:
        mov     [.proc], @@co.bxnor.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.band:
        mov     [.proc], @@co.band.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bnand:
        mov     [.proc], @@co.bnand.map.index
        jmp    .inline.co.iproc.i2p
        ;
   .inline.co.bandn:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_BMI1
        jnz    .inline.co.bandn.bmi
      $end
        mov     [.proc], @@co.bandn.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bandn.bmi:
        mov     [.proc], @@co.bandn.bmi.map.index
        jmp    .inline.co.iproc.i2p
        ;
   .inline.co.bnandn:
      $ifdef _VEX
        test    [@_CFG.cpu_flags], SIC_CPU_FLAG_BMI1
        jnz    .inline.co.bnandn.bmi
      $end
        mov     [.proc], @@co.bnandn.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bnandn.bmi:
        mov     [.proc], @@co.bnandn.bmi.map.index
        jmp    .inline.co.iproc.i2p
        ;
   .inline.co.breset:
        mov     [.proc], @@co.breset.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.bset:
        mov     [.proc], @@co.bset.map.index
        jmp    .inline.co.iproc.i2p
        ;
   .inline.co.shr:
        mov     [.proc], @@co.shr.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.shl:
        mov     [.proc], @@co.shl.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.sar:
        mov     [.proc], @@co.sar.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.sal:
        mov     [.proc], @@co.sal.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.ror:
        mov     [.proc], @@co.ror.map.index
        jmp    .inline.co.iproc.i2p
   .inline.co.rol:
        mov     [.proc], @@co.rol.map.index
        jmp    .inline.co.iproc.i2p
; ------
   .inline.co.iproc.i2p:
;       mov     [.mode], 0
        mov     [.fpatype], 'i'
        ; --------------------------------------------------
        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.co.iproc.i2p.ivar
        jmp    .error.argument
   .inline.co.iproc.i2p.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.co.iproc.i2p.ivar.dcon,\
                OBJ_INT_VAR     , .inline.co.iproc.i2p.ivar.x,\
                OBJ_INT_CON     , .inline.co.iproc.i2p.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.co.iproc.i2p.ivar.irsp.rax
        jmp    .error.argument
   .inline.co.iproc.i2p.ivar.irsp.rax:
;       add     [.RSP], 0
   .inline.co.iproc.i2p.ivar.x:
        mov     [rdi - 12], word 0xB948
        @@xshl  rdi, 2
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.co.iproc.i2p.ivar.proc
   .inline.co.iproc.i2p.ivar.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [rdi - 21], rax
        mov     [rdi - 23], word 0xB848
        mov     [rdi - 13], byte 0x50
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
;       add     [.RSP], 0
   .inline.co.iproc.i2p.ivar.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     [.xshl], 23
        mov     rax, [rdi - 21]                             ; rax = int64 constant
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
   .inline.co.iproc.i2p.ivar.icon.x:
        test    rax, rax
        jz     .inline.co.iproc.i2p.ivar.con.0
        cmp     rax, 1
        je     .inline.co.iproc.i2p.ivar.con.1
        cmp     rax, -1
        je     .inline.co.iproc.i2p.ivar.con.m1
        jmp    .inline.co.iproc.i2p.ivar.x
   .inline.co.iproc.i2p.ivar.con.0:
        mov     [.mode], 1
        jmp    .inline.co.iproc.i2p.ivar.con.proc
   .inline.co.iproc.i2p.ivar.con.1:
        mov     [.mode], 2
        jmp    .inline.co.iproc.i2p.ivar.con.proc
   .inline.co.iproc.i2p.ivar.con.m1:
        mov     [.mode], 3
        jmp    .inline.co.iproc.i2p.ivar.con.proc
   .inline.co.iproc.i2p.ivar.con.proc:
        @@xshl  rdi, [.xshl], rax
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
;       jmp    .inline.co.iproc.i2p.ivar.proc
   .inline.co.iproc.i2p.ivar.proc:
        stdcall map_proc_x4, @x4_co_iprocs_i2p, [.proc], [.mode]
        jmp    .inline.proc

   .inline.covalue:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.covalue.dvar,\
                OBJ_INT_VAR    , .inline.covalue.ivar,\
                OBJ_STRING_VAR , .inline.covalue.svar
        jmp    .error.argument
   .inline.covalue.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]
        test    rcx, rcx
        jz     .error.argument
    $ifdef _SSEX
        movsd   xmm0, qword [rcx]
    $else
        fld     qword [rcx]
    $end
        @@xshl  rdi, 12
        add     [.RSP], 8
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end
   .inline.covalue.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]
        test    rcx, rcx
        jz     .error.argument
        ;
        mov     rax, [rcx]
        @@xshl  rdi, 12
        add     [.RSP], 8
        jmp    .inline.rax.icon
   .inline.covalue.svar:
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]
        test    rcx, rcx
        jz     .error.argument
        ;
        mov     rax, [rcx]
        @@xshl  rdi, 12
        add     [.RSP], 8
        jmp    .inline.rax.scon

   .inline.restore:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.restore.dvar,\
                OBJ_INT_VAR    , .inline.restore.ivar,\
                OBJ_STRING_VAR , .inline.restore.svar
        jmp    .error.argument
   .inline.restore.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 23-12, .error.memory
        mov     rcx, [rdi - 10]
        test    rcx, rcx
        jz     .error.argument
    $ifdef _SSEX
        movsd   xmm0, qword [rcx]
        movsd   qword [rsp - 8], xmm0
    $else
        fld     qword [rcx]
        fst     qword [rsp - 8]
    $end
        mov     rax, qword [rsp - 8]
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], word 0x0189
        @@xshr  rdi, 23
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RAX, FF+          | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     QWORD [RCX], RAX  | 488901
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
    $ifdef _SSEX
        pcase   rsi, @@restore, .inline.sse.dcon.test
    $else
        pcase   rsi, @@restore, .inline.st0.dcon.test
        fstp    st0
    $end
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done
   .inline.restore.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 23-12, .error.memory
        mov     rcx, [rdi - 10]
        test    rcx, rcx
        jz     .error.argument
        ;
        mov     rax, [rcx]
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], word 0x0889
        @@xshr  rdi, 23
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RCX, FF+          | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     QWORD [RAX], RCX  | 488908
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        pcase   rsi, @@restore, .inline.rax.icon
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done
   .inline.restore.svar:
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        @@range 23-12, .error.memory
        mov     rcx, [rdi - 10]
        test    rcx, rcx
        jz     .error.argument
        ;
        mov     rax, [rcx]
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], word 0x0A89
        @@xshr  rdi, 23
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, FF+          | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     QWORD [RDX], RCX  | 48890A
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        pcase   rsi, @@restore, .inline.rax.scon
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ;?MOV     RDX, OFFSET       | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.copy.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.dvar,\
                OBJ_INT_VAR    , .inline.copy.ivar,\
                OBJ_STRING_VAR , .inline.copy.svar
        jmp    .error.argument
; ------
   .inline.copy.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.dvar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.dvar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.dvar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.dvar.dcon,\
                OBJ_INT_VAR     , .inline.copy.dvar.ivar,\
                OBJ_INT_CON     , .inline.copy.dvar.icon,\
                OBJ_INT_RSP_RAX , .inline.copy.dvar.irsp.rax
        jmp    .error.argument
   .inline.copy.dvar.dst0:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0x11DD
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; FST     QWORD [RCX]       | DD11
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copy.dvar.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x01110FF2
;       mov     [rdi + 10], dword 0x01D60F66
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;+MOVSD   QWORD [RCX], XMM0 | F20F1101
        ;-MOVQ    QWORD [RCX], XMM0 | 660FD601
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copy.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 31-24, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x018B
        mov     [rdi + 13], word 0xB948
        mov     [rdi + 15], rdx
        mov     [rdi + 23], dword 0x66018948
        mov     [rdi + 27], dword 0xC06E0F48
;       mov     [rdi + 23], dword 0xF2018948
;       mov     [rdi + 26], dword 0x01100FF2
        @@xshr  rdi, 31
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ; MOV     RAX, QWORD [RCX]  | 488B01
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     QWORD [RCX], RAX  | 488901
        ;+MOVQ    XMM0, RAX         | 66480F6EC0
        ;-MOVSD   XMM0, QWORD [RCX] | F20F1001
        ;>
        ; --------------------------------------------------
    $else
        @@range 28-24, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x018B
        mov     [rdi + 13], word 0xB948
        mov     [rdi + 15], rdx
        mov     [rdi + 23], byte 0x48
        mov     [rdi + 24], dword 0x01DD0189
        @@xshr  rdi, 28
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ; MOV     RAX, QWORD [RCX]  | 488B01
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     QWORD [RCX], RAX  | 488901
        ; FLD     QWORD [RCX]       | DD01
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 28-23, .error.memory
        mov     rax, [rdi - 21]                             ; rax = source value
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ    XMM0, RAX         | 66480F6EC0
        ; MOV     QWORD [RCX], RAX  | 488901
        ;>
        ; --------------------------------------------------
    $else
        @@range 25-23, .error.memory
        mov     rax, [rdi - 21]                             ; rax = source value
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOV     QWORD [RCX], RAX  | 488901
        ; FLD     QWORD [RCX]       | DD01
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.dvar.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 19-14, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0x110FF200
        mov     [rdi + 18], byte 0x01
        @@xshr  rdi, 19
        ; --------------------------------------------------
        ; MOV       RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV       RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; CVTSI2SD  XMM0, QWORD [RAX] | F2480F2A00
        ; MOVSD     QWORD [RCX], XMM0 | F20F1101
        ;>
        ; --------------------------------------------------
    $else
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x11DD28DF
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; FILD    QWORD [RAX]       | DF28
        ; FST     QWORD [RCX]       | DD11
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.dvar.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 9-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0x2A0F48F2
        mov     [rdi + 04], dword 0x110FF2C0
        mov     [rdi + 08], byte 0x01
        @@xshr  rdi, 9
        ; ----------------------------------------------
        ; MOV       RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH      RAX               | 50
        ; MOV       RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;*CVTSI2SD  XMM0, RAX         | F2480F2AC0
        ; MOVSD     QWORD [RCX], XMM0 | F20F1101
        ;>
        ; ----------------------------------------------
    $else
        @@range 5-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0xDD242CDF
        mov     [rdi + 04], byte 0x11
        @@xshr  rdi, 5
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH  RAX             | 50
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;*FILD  QWORD [RSP]     | DF2C24
        ; FST   QWORD [RCX]     | DD11
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .done
   .inline.copy.dvar.irsp.rax:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 23-16, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0x110FF2C0
        mov     [rdi + 18], dword 0xC4834801
        mov     [rdi + 22], byte 0x08
        @@xshr  rdi, 23
        ; --------------------------------------------------
        ; ...                         | ...
        ;*MOV       RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; CVTSI2SD  XMM0, RAX         | F2480F2AC0
        ; MOVSD     QWORD [RCX], XMM0 | F20F1101
        ; ADD       RSP, 8            | 4883C4 08
        ;>
        ; --------------------------------------------------
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 9-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0xDD242CDF
        mov     [rdi + 04], dword 0xC4834811
        mov     [rdi + 08], byte 0x08
        @@xshr  rdi, 9
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     [RSP], RAX        | 48890424
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;*FILD    QWORD [RSP]       | DF2C24
        ; FST     QWORD [RCX]       | DD11
        ; ADD     RSP, 8            | 4883C4 08
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
; ------
   .inline.copy.ivar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.ivar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.ivar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.ivar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.ivar.dcon,\
                OBJ_INT_VAR     , .inline.copy.ivar.ivar,\
                OBJ_INT_CON     , .inline.copy.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.copy.ivar.irsp.rax,\
                OBJ_STRING_VAR  , .inline.copy.ivar.svar,\
                OBJ_POINTER     , .inline.copy.ivar.ptr
        jmp    .error.argument
   .inline.copy.ivar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; ----------------------------------------------
        ; ...                   | ...
        ;*FSTP  QWORD [RSP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        mov     rsi, @@_copy_io.rcx_dv.st0
        mov     rax, @@_copy_io.rcx_dv.st0.size
        jmp    .inline.proc
    $end
   .inline.copy.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        mov     rsi, @@_copy_io.rcx_dv.xmm0
        mov     rax, @@_copy_io.rcx_dv.xmm0.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_do.rax
        mov     rax, @@_copy_io.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copy.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 21]                         ; rcx = constant
        stdcall f2i, rcx                                ; rax = int64 constant
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, INT64      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x48008B48
        mov     [rdi + 04], byte 0xB9
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RAX, [RAX]      | 488B00
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;*PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.irsp.rax:
         ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.ivar.rsp.proc
   .inline.copy.ivar.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x48028B48
        mov     [rdi + 04], byte 0xB9
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS
        ;*MOV   RAX, [RDX]      | 488B02
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.ptr:
        ; ----------------------------------------------
        ;*MOV   RCX, VALUE      | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 26
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.ivar.proc
   .inline.copy.ivar.proc:
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc
   .inline.copy.ivar.rsp.proc:
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax_rsp
        mov     rax, @@_copy_io.rcx_iv.rax_rsp.size
        jmp    .inline.proc
; ------
   .inline.copy.svar:
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR     , .inline.copy.svar.ivar,\
                OBJ_INT_CON     , .inline.copy.svar.icon,\
                OBJ_INT_RSP_RAX , .inline.copy.svar.irsp.rax,\
                OBJ_STRING_VAR  , .inline.copy.svar.svar,\
                OBJ_STRING_CON  , .inline.copy.svar.scon,\
                OBJ_POINTER     , .inline.copy.svar.ptr
        jmp    .error.argument
   .inline.copy.svar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 22]                         ; rax = source offset
        mov     rax, [rax]                              ; rax = source value
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x48008B48
        mov     [rdi + 04], byte 0xBA
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RAX, [RAX]      | 488B00
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.svar.rax.proc
   .inline.copy.svar.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        mov     rax, [rdi - 21]                             ; rax = source value
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.svar.rax.proc
   .inline.copy.svar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        @@range 17-16, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x48018948
        mov     [rdi + 13], dword 0x08C48348
        @@xshr  rdi, 17
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     [RCX], RAX        | 488901
        ; ADD     RSP, 8            | 4883C408
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done
   .inline.copy.svar.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 22]                         ; rax = source offset
        mov     rax, [rax]                              ; rax = source value
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x48028B48
        mov     [rdi + 04], byte 0xBA
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS
        ;*MOV   RAX, [RDX]      | 488B02
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.svar.rax.proc
   .inline.copy.svar.scon:
        ; ----------------------------------------------
        ;*MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ; PUSH  RDX             | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 21]                         ; rax = source value
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copy.svar.rax.proc
   .inline.copy.svar.ptr:
        ; ----------------------------------------------
        ;*MOV   RCX, VALUE      | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 24]                         ; rax = source value
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 26
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
;       jmp    .inline.copy.svar.rax.proc
   .inline.copy.svar.rax.proc:
      $ifdef SIC_FORCE_ASSIGN
        test    rdx, rdx
        jz     .error.argument
        mov     [rdx], rax ; assign string value at compile time
      $end
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@_copy_so.rdx_sv.rax
        mov     rax, @@_copy_so.rdx_sv.rax.size
        jmp    .inline.proc

   .inline.copy.int:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.copy.int.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.int.dvar,\
                OBJ_INT_VAR    , .inline.copy.ivar          ; copy.int() EQU copy()
        jmp    .error.argument
; ------
   .inline.copy.int.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.int.dvar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.int.dvar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.int.dvar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.int.dvar.dcon,\
                OBJ_INT_VAR     , .inline.copy.dvar.ivar,\      ; copy.int() EQU copy()
                OBJ_INT_CON     , .inline.copy.dvar.icon,\      ; copy.int() EQU copy()
                OBJ_INT_RSP_RAX , .inline.copy.dvar.irsp.rax    ; copy.int() EQU copy()
        jmp    .error.argument
   .inline.copy.int.dvar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ;*FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.int_do.rcx_dv.cpu
        mov     rax, @@_copy.int_do.rcx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.int.dvar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.int_do.rcx_dv.cpu
        mov     rax, @@_copy.int_do.rcx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.int.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        mov     rcx, [rdi - 22]                             ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rcx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET         | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.int_do.rcx_do.rax
        mov     rax, @@_copy.int_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copy.int.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2f.int, rcx                                ; rax = int(source)
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done

   .inline.copy.frac:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.copy.frac.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.frac.dvar,\
                OBJ_INT_VAR    , .inline.copy.frac.ivar
        jmp    .error.argument
; ------
   .inline.copy.frac.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.frac.dvar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.frac.dvar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.frac.dvar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.frac.dvar.dcon,\
                OBJ_INT_VAR     , .inline.copy.frac.dvar.ivar,\
                OBJ_INT_CON     , .inline.copy.frac.dvar.icon,\
                OBJ_INT_RSP_RAX , .inline.copy.frac.dvar.irsp.rax
        jmp    .error.argument
   .inline.copy.frac.dvar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ;*FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.frac_do.rcx_dv.cpu
        mov     rax, @@_copy.frac_do.rcx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.frac.dvar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.frac_do.rcx_dv.cpu
        mov     rax, @@_copy.frac_do.rcx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.frac.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        mov     rcx, [rdi - 22]                             ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rcx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.frac_do.rcx_do.rax
        mov     rax, @@_copy.frac_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copy.frac.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2f.frac, rcx                               ; rax = frac(source)
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copy.frac.dvar.ivar:
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        jmp    .inline.copy.frac.dvar.assign.zero
   .inline.copy.frac.dvar.icon:
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV     RCX, OFFSET   | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copy.frac.dvar.assign.zero
   .inline.copy.frac.dvar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C408
        ;>
        ; --------------------------------------------------
;       jmp    .inline.copy.frac.dvar.assign.zero
   .inline.copy.frac.dvar.assign.zero:
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zero_do.rcx
        mov     rax, @@_assign.zero_do.rcx.size
        jmp    .inline.proc
; ------
   .inline.copy.frac.ivar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.frac.ivar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.frac.ivar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.frac.ivar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.frac.ivar.dcon,\
                OBJ_INT_VAR     , .inline.copy.frac.ivar.ivar,\
                OBJ_INT_CON     , .inline.copy.frac.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.copy.frac.ivar.irsp.rax
        jmp    .error.argument
   .inline.copy.frac.ivar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; ----------------------------------------------
        ; ...                   | ...
        ; FSTP  QWORD [RSP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@range 14-12, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; ----------------------------------------------
        ; FSTP  QWORD [RSP]     | DD1C24
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; ADD   RSP, 8          | 4883C408
        ;>
        ; ----------------------------------------------
        jmp    .inline.copy.frac.ivar.assign.zero
    $end
   .inline.copy.frac.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C408
        ;>
        ; --------------------------------------------------
        jmp    .inline.copy.frac.ivar.assign.zero
    $else
        jmp    .error.argument
    $end
   .inline.copy.frac.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV     RCX, OFFSET   | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV     RCX, OFFSET   | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV     RCX, OFFSET   | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.icon:
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        @@xshl  rdi, 16
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C408
        ;>
        ; --------------------------------------------------
;       jmp    .inline.copy.frac.ivar.assign.zero
   .inline.copy.frac.ivar.assign.zero:
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zero_io.rcx
        mov     rax, @@_assign.zero_io.rcx.size
        jmp    .inline.proc

   .inline.copy.round:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.copy.round.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copy.round.dvar,\
                OBJ_INT_VAR    , .inline.copy.round.ivar
        jmp    .error.argument
; ------
   .inline.copy.round.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.round.dvar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.round.dvar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.round.dvar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.round.dvar.dcon,\
                OBJ_INT_VAR     , .inline.copy.dvar.ivar,\      ; copy.round() EQU copy()
                OBJ_INT_CON     , .inline.copy.dvar.icon,\      ; copy.round() EQU copy()
                OBJ_INT_RSP_RAX , .inline.copy.dvar.irsp.rax    ; copy.round() EQU copy()
        jmp    .error.argument
   .inline.copy.round.dvar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ;*FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_do.rcx_dv.cpu
        mov     rax, @@_copy.round_do.rcx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.round.dvar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_do.rcx_dv.cpu
        mov     rax, @@_copy.round_do.rcx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.round.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = destination offset
        mov     rcx, [rdi - 22]                             ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rcx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_do.rcx_do.rax
        mov     rax, @@_copy.round_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copy.round.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2f.round, rcx                              ; rax = round(source)
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
; ------
   .inline.copy.round.ivar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.copy.round.ivar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.copy.round.ivar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.copy.round.ivar.dvar,\
                OBJ_DOUBLE_CON  , .inline.copy.round.ivar.dcon,\
                OBJ_INT_VAR     , .inline.copy.ivar.ivar,\      ; copy.round() EQU copy()
                OBJ_INT_CON     , .inline.copy.ivar.icon,\      ; copy.round() EQU copy()
                OBJ_INT_RSP_RAX , .inline.copy.ivar.irsp.rax    ; copy.round() EQU copy()
        jmp    .error.argument
   .inline.copy.round.ivar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; ----------------------------------------------
        ; ...                   | ...
        ;*FSTP  QWORD [RSP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 10]                         ; rcx = destination offset
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_io.rcx_dv.cpu
        mov     rax, @@_copy.round_io.rcx_dv.cpu.size
        jmp    .inline.proc
    $end
   .inline.copy.round.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]                             ; rcx = destination offset
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV   RCX, OFFSET         | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_io.rcx_dv.cpu
        mov     rax, @@_copy.round_io.rcx_dv.cpu.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.copy.round.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        mov     rcx, [rdi - 22]                         ; rcx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rcx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_io.rcx_do.rax
        mov     rax, @@_copy.round_io.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copy.round.ivar.dcon:
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 21]                         ; rcx = constant
        stdcall f2ir, rcx                               ; rax = int64 constant: round(source)
        mov     rcx, [rdi - 10]                         ; rcx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, INT64      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc

   .inline.pcopy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)

        ;?MOV     RDX, OFFSET       | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopy.ivar
        jmp    .error.argument
        ;
   .inline.pcopy.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        mov     rdx, [rdi - 10]                             ; rdx = integer variable offset
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.pcopy.ivar.dst0,\
                OBJ_DOUBLE_SSE  , .inline.pcopy.ivar.dsse,\
                OBJ_DOUBLE_VAR  , .inline.pcopy.ivar.dvar,\
                OBJ_DOUBLE_CON  , .inline.pcopy.ivar.dcon,\
                OBJ_INT_VAR     , .inline.pcopy.ivar.ivar,\
                OBJ_INT_CON     , .inline.pcopy.ivar.icon,\
                OBJ_INT_RSP_RAX , .inline.pcopy.ivar.irsp.rax,\
                OBJ_STRING_VAR  , .inline.pcopy.ivar.svar,\
                OBJ_STRING_CON  , .inline.pcopy.ivar.scon
        jmp    .error.argument
   .inline.pcopy.ivar.dst0:
    $ifdef _SSEX
        jmp    .error.argument
    $else
        ; --------------------------------------------------
        ; ...                       | ...
        ;*FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 15
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; ------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        mov     rsi, @@_copy_doo.rdx_dv.st0
        mov     rax, @@_copy_doo.rdx_dv.st0.size
        jmp    .inline.proc
    $end
   .inline.pcopy.ivar.dsse:
    $ifdef _SSEX
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 17
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; ------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        mov     rsi, @@_copy_doo.rdx_dv.xmm0
        mov     rax, @@_copy_doo.rdx_dv.xmm0.size
        jmp    .inline.proc
    $else
        jmp    .error.argument
    $end
   .inline.pcopy.ivar.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;*PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_doo.rdx_do.rcx
        mov     rax, @@_copy_doo.rdx_do.rcx.size
        jmp    .inline.proc
   .inline.pcopy.ivar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_doo.rdx_dv.rax
        mov     rax, @@_copy_doo.rdx_dv.rax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_ioo.rdx_io.rax
        mov     rax, @@_copy_ioo.rdx_io.rax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_ioo.rdx_iv.rax
        mov     rax, @@_copy_ioo.rdx_iv.rax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C4 08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_ioo.rdx_iv.rax
        mov     rax, @@_copy_ioo.rdx_iv.rax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.svar:
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@_copy_soo.rdx_so.rax
        mov     rax, @@_copy_soo.rdx_so.rax.size
        jmp    .inline.proc
   .inline.pcopy.ivar.scon:
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ; PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; string constant (11B)
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@_copy_soo.rdx_sv.rax
        mov     rax, @@_copy_soo.rdx_sv.rax.size
        jmp    .inline.proc

   .inline.copx:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH  RCX             | 51

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH  RAX             | 50

        ;?MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32

        ;?MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH  RDX             | 52

        ;?MOV   RCX, VALUE      | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH  RCX             | 51
        ;?NOP3                  | 909090
        ;>
        ; ----------------------------------------------
   .inline.copx.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.dvar,\
                OBJ_DOUBLE_CON , .inline.copx.dcon,\
                OBJ_INT_VAR    , .inline.copx.ivar,\
                OBJ_INT_CON    , .inline.copx.icon,\
                OBJ_STRING_VAR , .inline.copx.svar,\
                OBJ_STRING_CON , .inline.copx.scon,\
                OBJ_POINTER    , .inline.copx.ptr
        jmp    .error.argument
; ------
   .inline.copx.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.dvar.ivar
        jmp    .error.argument
   .inline.copx.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 31-24, .error.memory
        mov     rax, [rdi - 10]                         ; rax = source offset
        mov     rdx, [rdi - 22]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x018B
        mov     [rdi + 13], word 0xB948
        mov     [rdi + 15], rdx
        mov     [rdi + 23], dword 0x66018948
        mov     [rdi + 27], dword 0xC06E0F48
;       mov     [rdi + 23], dword 0xF2018948
;       mov     [rdi + 26], dword 0x01100FF2
        @@xshr  rdi, 31
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ; MOV   RAX, QWORD [RCX]  | 488B01
        ; MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   QWORD [RCX], RAX  | 488901
        ;+MOVQ  XMM0, RAX         | 66480F6EC0
        ;-MOVSD XMM0, QWORD [RCX] | F20F1001
        ;>
        ; ----------------------------------------------
    $else
        @@range 28-24, .error.memory
        mov     rax, [rdi - 10]                         ; rax = source offset
        mov     rdx, [rdi - 22]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 02], rax
        mov     [rdi + 10], byte 0x48
        mov     [rdi + 11], word 0x018B
        mov     [rdi + 13], word 0xB948
        mov     [rdi + 15], rdx
        mov     [rdi + 23], byte 0x48
        mov     [rdi + 24], dword 0x01DD0189
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS
        ; MOV   RAX, QWORD [RCX]| 488B01
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copx.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_do.rax
        mov     rax, @@_copy_io.rcx_do.rax.size
        jmp    .inline.proc
; ------
   .inline.copx.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.dcon.ivar
        jmp    .error.argument
   .inline.copx.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 09]                         ; rax = source value
;       mov     rdx, [rdi - 21]                         ; rdx = destination offset
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
;       mov     [rdi + 00], word 0xB948
;       mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
;       mov     [rdi + 00], word 0xB948
;       mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copx.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 09]                         ; rcx = constant
        stdcall f2i, rcx                                ; rax = int64 constant
        mov     rdx, [rdi - 21]                         ; rdx = destination offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, INT64      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc
; ------
   .inline.copx.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.ivar.dvar,\
                OBJ_INT_VAR    , .inline.copx.ivar.ivar,\
                OBJ_STRING_VAR , .inline.copx.ivar.svar
        jmp    .error.argument
   .inline.copx.ivar.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_do.rcx_io.rax
        mov     rax, @@_copy_do.rcx_io.rax.size
        jmp    .inline.proc
   .inline.copx.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_io.rax
        mov     rax, @@_copy_io.rcx_io.rax.size
        jmp    .inline.proc
   .inline.copx.ivar.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 22]                         ; rdx = destination offset
        mov     rax, [rdi - 10]                         ; rax = source offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], dword 0x00008B48
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RAX, [RAX]      | 488B00
        ;>
        ; ----------------------------------------------
        mov     rax, [rax]                              ; rax = source value
        add     [.RSP], 16
        jmp    .inline.copx.rax.svar.proc
; ------
   .inline.copx.icon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.icon.dvar,\
                OBJ_INT_VAR    , .inline.copx.icon.ivar,\
                OBJ_STRING_VAR , .inline.copx.icon.svar
        jmp    .error.argument
   .inline.copx.icon.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 09]                         ; rdx = source value
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rdx
        mov     [rdi + 10], byte 0x50
        @@xshr  rdi, 11
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        mov     rsi, @@_copy_do.rcx_iv.rsp
        mov     rax, @@_copy_do.rcx_iv.rsp.size
        jmp    .inline.proc
   .inline.copx.icon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 09]                         ; rdx = source value
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc
   .inline.copx.icon.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 21]                         ; rdx = destination offset
        mov     rax, [rdi - 09]                         ; rax = source value
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.copx.rax.svar.proc
; ------
   .inline.copx.svar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR    , .inline.copx.svar.ivar,\
                OBJ_STRING_VAR , .inline.copx.svar.svar
        jmp    .error.argument
   .inline.copx.svar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        mov     [rdi + 20], dword 0x00008B48
        @@xshr  rdi, 23
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RAX, [RAX]      | 488B00
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc
   .inline.copx.svar.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 22]                         ; rdx = destination offset
        mov     rax, [rdi - 10]                         ; rax = source offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], dword 0x00008B48
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RAX, [RAX]      | 488B00
        ;>
        ; ----------------------------------------------
        mov     rax, [rax]                              ; rax = source value
        add     [.RSP], 16
        jmp    .inline.copx.rax.svar.proc
; ------
   .inline.copx.scon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ; PUSH  RDX             | 52
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_STRING_VAR , .inline.copx.scon.svar
        jmp    .error.argument
   .inline.copx.scon.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ; PUSH  RDX             | 52
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 21]                         ; rax = destination offset
        mov     rax, [rdi - 09]                         ; rax = source value
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.copx.rax.svar.proc
; ------
   .inline.copx.ptr:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, VALUE      | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -14              ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR    , .inline.copx.ptr.ivar,\
                OBJ_STRING_VAR , .inline.copx.ptr.svar
        jmp    .error.argument
   .inline.copx.ptr.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, VALUE      | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 12]                         ; rdx = source value
        @@xshl  rdi, 26
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc
   .inline.copx.ptr.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;*PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, VALUE      | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 24]                         ; rax = destination offset
        mov     rax, [rdi - 12]                         ; rax = source value
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ;*MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
;       jmp    .inline.copx.rax.svar.proc
   .inline.copx.rax.svar.proc:
      $ifdef SIC_FORCE_ASSIGN
        test    rdx, rdx
        jz     .error.argument
        mov     [rdx], rax ; assign string value at compile time
      $end
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@_copy_so.rdx_sv.rax
        mov     rax, @@_copy_so.rdx_sv.rax.size
        jmp    .inline.proc

   .inline.copx.int:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH  RCX             | 51

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
   .inline.copx.int.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.int.dvar,\
                OBJ_DOUBLE_CON , .inline.copx.int.dcon,\
                OBJ_INT_VAR    , .inline.copx.ivar,\    ; copx.int() EQU copx()
                OBJ_INT_CON    , .inline.copx.icon      ; copx.int() EQU copx()
        jmp    .error.argument
; ------
   .inline.copx.int.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.int.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.dvar.ivar ; copx.int() EQU copx()
        jmp    .error.argument
   .inline.copx.int.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.int_do.rcx_do.rax
        mov     rax, @@_copy.int_do.rcx_do.rax.size
        jmp    .inline.proc
; ------
   .inline.copx.int.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.int.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.dcon.ivar ; copx.int() EQU copx()
        jmp    .error.argument
   .inline.copx.int.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 09]                         ; rcx = constant
        stdcall f2f.int, rcx                            ; rax = int(source)
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done

   .inline.copx.frac:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH  RCX             | 51

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
   .inline.copx.frac.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.dvar,\
                OBJ_DOUBLE_CON , .inline.copx.frac.dcon,\
                OBJ_INT_VAR    , .inline.copx.frac.ivar,\
                OBJ_INT_CON    , .inline.copx.frac.icon
        jmp    .error.argument
; ------
   .inline.copx.frac.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.dvar.ivar
        jmp    .error.argument
   .inline.copx.frac.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.frac_do.rcx_do.rax
        mov     rax, @@_copy.frac_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copx.frac.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB9
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copx.frac.ivar.assign.zero
; ------
   .inline.copx.frac.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.dcon.ivar
        jmp    .error.argument
   .inline.copx.frac.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 09]                         ; rcx = constant
        stdcall f2f.frac, rcx                           ; rax = frac(source)
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copx.frac.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 01], byte 0xB9
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copx.frac.ivar.assign.zero
; ------
   .inline.copx.frac.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.ivar.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.ivar.ivar
        jmp    .error.argument
   .inline.copx.frac.ivar.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 14
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copx.frac.dvar.assign.zero
   .inline.copx.frac.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB9
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        jmp    .inline.copx.frac.ivar.assign.zero
; ------
   .inline.copx.frac.icon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.frac.icon.dvar,\
                OBJ_INT_VAR    , .inline.copx.frac.icon.ivar
        jmp    .error.argument
   .inline.copx.frac.icon.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 13
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
;       jmp    .inline.copx.frac.dvar.assign.zero
   .inline.copx.frac.dvar.assign.zero:
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zero_do.rcx
        mov     rax, @@_assign.zero_do.rcx.size
        jmp    .inline.proc
   .inline.copx.frac.icon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 01], byte 0xB9
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
;       jmp    .inline.copx.frac.ivar.assign.zero
   .inline.copx.frac.ivar.assign.zero:
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zero_io.rcx
        mov     rax, @@_assign.zero_io.rcx.size
        jmp    .inline.proc

   .inline.copx.round:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH  RCX             | 51

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
   .inline.copx.round.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.round.dvar,\
                OBJ_DOUBLE_CON , .inline.copx.round.dcon,\
                OBJ_INT_VAR    , .inline.copx.ivar,\    ; copx.round() EQU copx()
                OBJ_INT_CON    , .inline.copx.icon      ; copx.round() EQU copx()
        jmp    .error.argument
; ------
   .inline.copx.round.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.round.dvar.dvar,\
                OBJ_INT_VAR    , .inline.copx.round.dvar.ivar
        jmp    .error.argument
   .inline.copx.round.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_do.rcx_do.rax
        mov     rax, @@_copy.round_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.copx.round.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = source offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB9
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD)
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy.round_io.rcx_do.rax
        mov     rax, @@_copy.round_io.rcx_do.rax.size
        jmp    .inline.proc
; ------
   .inline.copx.round.dcon:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.copx.round.dcon.dvar,\
                OBJ_INT_VAR    , .inline.copx.round.dcon.ivar
        jmp    .error.argument
   .inline.copx.round.dcon.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 09]                         ; rcx = constant
        stdcall f2f.round, rcx                          ; rax = round(source)
    $ifdef _SSEX
        @@range 28-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], dword 0x6E0F4866
        mov     [rdi + 24], dword 0x018948C0
        @@xshr  rdi, 28
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD        | 48B8 SSSSSSSSSSSSSSSS
        ; MOVQ  XMM0, RAX         | 66480F6EC0
        ; MOV   QWORD [RCX], RAX  | 488901
        ;>
        ; ----------------------------------------------
    $else
        @@range 25-23, .error.memory
        @@xshl  rdi, 23
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], dword 0x01DD0189
        @@xshr  rdi, 25
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   QWORD [RCX], RAX| 488901
        ; FLD   QWORD [RCX]     | DD01
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .done
   .inline.copx.round.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 09]                         ; rcx = constant
        stdcall f2ir, rcx                               ; rax = int64 constant: round(source)
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ; MOV   RAX, INT64      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_io.rcx_iv.rax
        mov     rax, @@_copy_io.rcx_iv.rax.size
        jmp    .inline.proc

   .inline.pcopx:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH  RCX             | 51

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH  RAX             | 50

        ;?MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32

        ;?MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH  RDX             | 52
        ;>
        ; ----------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.pcopx.dvar,\
                OBJ_DOUBLE_CON , .inline.pcopx.dcon,\
                OBJ_INT_VAR    , .inline.pcopx.ivar,\
                OBJ_INT_CON    , .inline.pcopx.icon,\
                OBJ_STRING_VAR , .inline.pcopx.svar,\
                OBJ_STRING_CON , .inline.pcopx.scon
        jmp    .error.argument
        ;
   .inline.pcopx.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        mov     rax, [rdi - 10]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.dvar.ivar
        jmp    .error.argument
   .inline.pcopx.dvar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_doo.rdx_do.rax
        mov     rax, @@_copy_doo.rdx_do.rax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.dcon:
        ; ----------------------------------------------
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        mov     rax, [rdi - 09]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.dcon.ivar
        jmp    .error.argument
   .inline.pcopx.dcon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, QWORD      | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH  RCX             | 51
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ; MOV   RAX, QWORD      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_doo.rdx_dv.rax
        mov     rax, @@_copy_doo.rdx_dv.rax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        mov     rax, [rdi - 10]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.ivar.ivar
        jmp    .error.argument
   .inline.pcopx.ivar.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_ioo.rdx_io.rax
        mov     rax, @@_copy_ioo.rdx_io.rax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.icon:
        ; ----------------------------------------------
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        mov     rax, [rdi - 09]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.icon.ivar
        jmp    .error.argument
   .inline.pcopx.icon.ivar:
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH  RAX             | 50
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD
        ; MOV   RAX, VALUE      | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_copy_ioo.rdx_iv.rax
        mov     rax, @@_copy_ioo.rdx_iv.rax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.svar:
        ; ----------------------------------------------
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        mov     rax, [rdi - 10]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.svar.ivar
        jmp    .error.argument
   .inline.pcopx.svar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@_copy_soo.rdx_so.rax
        mov     rax, @@_copy_soo.rdx_so.rax.size
        jmp    .inline.proc
        ;
   .inline.pcopx.scon:
        ; ----------------------------------------------
        ; MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ; PUSH  RDX             | 52
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -11              ; ecx = object type
        mov     rax, [rdi - 09]
        case    ecx,\
                OBJ_INT_VAR , .inline.pcopx.scon.ivar
        jmp    .error.argument
   .inline.pcopx.scon.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, VALUE      | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ; PUSH  RDX             | 52
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 10], word 0xB848
        mov     [rdi + 12], rax
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@_copy_soo.rdx_sv.rax
        mov     rax, @@_copy_soo.rdx_sv.rax.size
        jmp    .inline.proc

   .inline.x2copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.x2copy.dvar,\
                OBJ_INT_VAR    , .inline.x2copy.ivar,\
                OBJ_STRING_VAR , .inline.x2copy.svar
        jmp    .error.argument
   .inline.x2copy.dvar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        mov     rsi, @@.x2copy.d
        mov     rax, @@.x2copy.d.size
        jmp    .inline.proc
   .inline.x2copy.ivar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        mov     rsi, @@.x2copy.i
        mov     rax, @@.x2copy.i.size
        jmp    .inline.proc
   .inline.x2copy.svar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@.x2copy.s
        mov     rax, @@.x2copy.s.size
        jmp    .inline.proc

   .inline.x2copyD:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        sub     [.ezx], 2
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        jmp    .inline.proc

   .inline.x2copyDV:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ;
        mov     rax, [rdi - 20]                             ; rax = x_1 offset
        mov     rdx, [rdi - 32]                             ; rdx = x_2 offset
        @@xshl  rdi, 34
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        sub     [.ezx], 2
        mov     rcx, [.ezx]
        mov     [rdi + 20], word 0xBD49
        mov     [rdi + 22], rcx
        @@xshr  rdi, 30
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        jmp    .inline.proc

   .inline.x3copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.x3copy.x:
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.x3copy.dvar,\
                OBJ_INT_VAR    , .inline.x3copy.ivar,\
                OBJ_STRING_VAR , .inline.x3copy.svar
        jmp    .error.argument
   .inline.x3copy.dvar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rdx = x_3 offset
        @@xshl  rdi, 36
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        @@xshr  rdi, 30
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 48
        mov     [.ezx], 0
        mov     rsi, @@.x3copy.d
        mov     rax, @@.x3copy.d.size
        jmp    .inline.proc
   .inline.x3copy.ivar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rcx = x_3 offset
        @@xshl  rdi, 36
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        @@xshr  rdi, 30
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 48
        mov     [.ezx], 0
        mov     rsi, @@.x3copy.i
        mov     rax, @@.x3copy.i.size
        jmp    .inline.proc
   .inline.x3copy.svar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rcx = x_3 offset
        @@xshl  rdi, 36
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        @@xshr  rdi, 30
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 48
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@.x3copy.s
        mov     rax, @@.x3copy.s.size
        jmp    .inline.proc

   .inline.x3copyD:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rdx = x_3 offset
        @@xshl  rdi, 36
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        @@xshr  rdi, 30
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 24
        sub     [.ezx], 3
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        jmp    .inline.proc

   .inline.x4copy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.x4copy.dvar,\
                OBJ_INT_VAR    , .inline.x4copy.ivar,\
                OBJ_STRING_VAR , .inline.x4copy.svar
        jmp    .error.argument
   .inline.x4copy.dvar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rcx = x_3 offset
        mov     r10, [rdi - 46]                             ; r10 = x_4 offset
        @@xshl  rdi, 48
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        mov     [rdi + 30], word 0xBA49
        mov     [rdi + 32], r10
        @@xshr  rdi, 40
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     R10, OFFSET       | 49BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 64
        mov     [.ezx], 0
        mov     rsi, @@.x4copy.d
        mov     rax, @@.x4copy.d.size
        jmp    .inline.proc
   .inline.x4copy.ivar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rcx = x_3 offset
        mov     r10, [rdi - 46]                             ; r10 = x_4 offset
        @@xshl  rdi, 48
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        mov     [rdi + 30], word 0xBA49
        mov     [rdi + 32], r10
        @@xshr  rdi, 40
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     R10, OFFSET       | 49BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 64
        mov     [.ezx], 0
        mov     rsi, @@.x4copy.i
        mov     rax, @@.x4copy.i.size
        jmp    .inline.proc
   .inline.x4copy.svar:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32

        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rcx = x_3 offset
        mov     r10, [rdi - 46]                             ; r10 = x_4 offset
        @@xshl  rdi, 48
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        mov     [rdi + 30], word 0xBA49
        mov     [rdi + 32], r10
        @@xshr  rdi, 40
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     R10, OFFSET       | 49BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 64
        mov     [.ezx], 0
        mov     [.FPU], 0
        mov     rsi, @@.x4copy.s
        mov     rax, @@.x4copy.s.size
        jmp    .inline.proc

   .inline.x4copyD:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        ;
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ;
        mov     rax, [rdi - 10]                             ; rax = x_1 offset
        mov     rdx, [rdi - 22]                             ; rdx = x_2 offset
        mov     rcx, [rdi - 34]                             ; rcx = x_3 offset
        mov     r10, [rdi - 46]                             ; r10 = x_4 offset
        @@xshl  rdi, 48
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB948
        mov     [rdi + 22], rcx
        mov     [rdi + 30], word 0xBA49
        mov     [rdi + 32], r10
        @@xshr  rdi, 40
        ; --------------------------------------------------
        ; ...                       | ...
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     R10, OFFSET       | 49BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        sub     [.ezx], 4
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        jmp    .inline.proc

   .inline.swap:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30

        ;?MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar,\
                OBJ_STRING_VAR , .inline.swap.svar
        jmp    .error.argument
   .inline.swap.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.dvar.ivar
        jmp    .error.argument
   .inline.swap.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.ivar.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar.ivar,\
                OBJ_STRING_VAR , .inline.swap.ivar.svar
        jmp    .error.argument
   .inline.swap.svar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_INT_VAR    , .inline.swap.svar.ivar,\
                OBJ_STRING_VAR , .inline.swap.svar.svar
        jmp    .error.argument
; ------
   .inline.swap.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_do.rcx_do.rax
        mov     rax, @@_swap_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.swap.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_do.rcx_io.rax
        mov     rax, @@_swap_do.rcx_io.rax.size
        jmp    .inline.proc
; ------
   .inline.swap.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_io.rcx_do.rax
        mov     rax, @@_swap_io.rcx_do.rax.size
        jmp    .inline.proc
   .inline.swap.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_io.rcx_io.rax
        mov     rax, @@_swap_io.rcx_io.rax.size
        jmp    .inline.proc
   .inline.swap.ivar.svar:
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 22]                         ; rax = source offset
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
      $ifdef SIC_FORCE_ASSIGN
        test    rax, rax
        jz     .error.argument
        test    rdx, rdx
        jz     .error.argument
        mov     rsi, [rax]
        mov     rcx, [rdx]
        mov     [rax], rcx ; assign values at compile time
        mov     [rdx], rsi
      $end
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_io.rcx_io.rax
        mov     rax, @@_swap_io.rcx_io.rax.size
        jmp    .inline.proc
; ------
   .inline.swap.svar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 22]                         ; rax = source offset
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
      $ifdef SIC_FORCE_ASSIGN
        test    rax, rax
        jz     .error.argument
        test    rdx, rdx
        jz     .error.argument
        mov     rsi, [rax]
        mov     rcx, [rdx]
        mov     [rax], rcx ; assign values at compile time
        mov     [rdx], rsi
      $end
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_io.rcx_io.rax
        mov     rax, @@_swap_io.rcx_io.rax.size
        jmp    .inline.proc
   .inline.swap.svar.svar:
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA DDDDDDDDDDDDDDDD ; string variable (12B)
        ; PUSH  QWORD [RDX]     | FF32
        ;>
        ; ----------------------------------------------
        mov     rax, [rdi - 22]                         ; rax = source offset
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
      $ifdef SIC_FORCE_ASSIGN
        test    rax, rax
        jz     .error.argument
        test    rdx, rdx
        jz     .error.argument
        mov     rsi, [rax]
        mov     rcx, [rdx]
        mov     [rax], rcx ; assign values at compile time
        mov     [rdx], rsi
      $end
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap_io.rcx_io.rax
        mov     rax, @@_swap_io.rcx_io.rax.size
        jmp    .inline.proc

   .inline.swap.int:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
   .inline.swap.int.x:
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.int.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar      ; swap.int() EQU swap()
        jmp    .error.argument
   .inline.swap.int.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.int.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.dvar.ivar ; swap.int() EQU swap()
        jmp    .error.argument
; ------
   .inline.swap.int.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap.int_do.rcx_do.rax
        mov     rax, @@_swap.int_do.rcx_do.rax.size
        jmp    .inline.proc

   .inline.swap.frac:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
   .inline.swap.frac.x:
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.frac.dvar,\
                OBJ_INT_VAR    , .inline.swap.frac.ivar
        jmp    .error.argument
   .inline.swap.frac.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.frac.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.frac.dvar.ivar
        jmp    .error.argument
   .inline.swap.frac.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.frac.ivar.dvar,\
                OBJ_INT_VAR    , .inline.swap.frac.ivar.ivar
        jmp    .error.argument
; ------
   .inline.swap.frac.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap.frac_do.rcx_do.rax
        mov     rax, @@_swap.frac_do.rcx_do.rax.size
        jmp    .inline.proc
   .inline.swap.frac.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zeroes_do.rcx_io.rax
        mov     rax, @@_assign.zeroes_do.rcx_io.rax.size
        jmp    .inline.proc
; ------
   .inline.swap.frac.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zeroes_io.rcx_do.rax
        mov     rax, @@_assign.zeroes_io.rcx_do.rax.size
        jmp    .inline.proc
   .inline.swap.frac.ivar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_assign.zeroes_io.rcx_io.rax
        mov     rax, @@_assign.zeroes_io.rcx_io.rax.size
        jmp    .inline.proc

   .inline.swap.round:
        ; ----------------------------------------------
        ; code before function call
        ; ----------------------------------------------
        ;?MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH  QWORD [RCX]     | FF31

        ;?MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
   .inline.swap.round.x:
        case    ecx,\                                   ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.swap.round.dvar,\
                OBJ_INT_VAR    , .inline.swap.round.ivar
        jmp    .error.argument
   .inline.swap.round.dvar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.round.dvar.dvar,\
                OBJ_INT_VAR    , .inline.swap.round.dvar.ivar
        jmp    .error.argument
   .inline.swap.round.ivar:
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        stdcall code_object, [.cooff], -12              ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swap.round.ivar.dvar,\
                OBJ_INT_VAR    , .inline.swap.ivar.ivar ; swap.round() EQU swap()
        jmp    .error.argument
; ------
   .inline.swap.round.dvar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xBA
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap.round_do.rcx_do.rdx
        mov     rax, @@_swap.round_do.rcx_do.rdx.size
        jmp    .inline.proc
   .inline.swap.round.dvar.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap.round_do.rcx_io.rax
        mov     rax, @@_swap.round_do.rcx_io.rax.size
        jmp    .inline.proc
; ------
   .inline.swap.round.ivar.dvar:
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RAX, OFFSET     | 48B8 DDDDDDDDDDDDDDDD ; integer variable (12B)
        ; PUSH  QWORD [RAX]     | FF30
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = destination offset
        @@xshl  rdi, 24
        mov     [rdi + 01], byte 0xB8
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ;*MOV   RAX, OFFSET     | 48B8 SSSSSSSSSSSSSSSS
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     rsi, @@_swap.round_io.rcx_do.rax
        mov     rax, @@_swap.round_io.rcx_do.rax.size
        jmp    .inline.proc

   .inline.vcopy:
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;
        ;?MOV     R13, ACOUNT       | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        mov     rcx, [.ezx]
        mov     [.zzx], rcx
        dec     [.zzx]
        @@xshl  rdi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.vcopy.dvar,\
                OBJ_INT_VAR    , .inline.vcopy.ivar,\
                OBJ_STRING_VAR , .inline.vcopy.svar
        jmp    .error.argument
   .inline.vcopy.dvar:
    $ifdef _SSEX
        ; (13*acount+5)-(12*acount+10) = acount-5
;       ; (13*acount+4)-(12*acount+10) = acount-6
        mov     rcx, [.ezx]
        sub     rcx, 5
;       sub     rcx, 6
        js     .inline.vcopy.dvar.x
    $else
        ; (13*acount+2)-(12*acount+10) = acount-8
        mov     rcx, [.ezx]
        sub     rcx, 8
        js     .inline.vcopy.dvar.x
    $end
        @@range rcx, .error.memory
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.vcopy.dvar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopy.dvar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, qword [rdx]
        mov     [.rcx], rcx
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopy.dvar.push:
        add     rdx, 12
        push    qword [rdx]
        dec     rcx
        jnz    .inline.vcopy.dvar.push
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 15 BYTES
        ; FLD   QWORD [RCX]       | DD01
        ; MOV   RAX, [RCX]        | 488B 01
        ;
        ; MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX        | 4889 01
        ;
        ; MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX        | 4889 01
        ;
        ; ...                     |
        ;
        ; MOV   RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX        | 4889 01
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 18 BYTES
        ;+MOV   RAX, [RCX]        | 488B 01
        ;+MOVQ  XMM0, RAX         | 66480F6EC0
        ;
        ; ...                     |
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 17 BYTES
        ;-MOVSD XMM0, QWORD [RCX] | F20F1001
        ;-MOV   RAX, [RCX]        | 488B 01
        ;
        ; ...                     |
        ; ----------------------------------------------
        mov     rcx, [.rcx]
    $ifdef _SSEX
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x66018B48
        mov     [rdi + 14], dword 0xC06E0F48
        @@xshr  rdi, 18
;       mov     [rdi + 10], dword 0x01100FF2
;       mov     [rdi + 13], dword 0x018B4801
;       @@xshr  rdi, 17
    $else
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x8B4801DD
        mov     [rdi + 14], byte 0x01
        @@xshr  rdi, 15
    $end
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopy.dvar.pop:
        mov     [rdi + 00], word 0xB948
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8948
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        dec     rcx
        jnz    .inline.vcopy.dvar.pop
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopy.ivar:
    $ifdef _SSEX
        ; (13*acount+5)-(12*acount+10) = acount-5
        mov     rcx, [.ezx]
        sub     rcx, 5
        js     .inline.vcopy.ivar.x
    $else
        ; (13*acount+2)-(12*acount+10) = acount-8
        mov     rcx, [.ezx]
        sub     rcx, 8
        js     .inline.vcopy.ivar.x
    $end
        @@range rcx, .error.memory
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.vcopy.ivar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopy.ivar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, qword [rdx]
        mov     [.rcx], rcx
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopy.ivar.push:
        add     rdx, 12
        push    qword [rdx]
        dec     rcx
        jnz    .inline.vcopy.ivar.push
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; 15 BYTES
        ; FILD  QWORD [RCX]     | DF29
        ; MOV   RAX, [RCX]      | 488B 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; ...                   |
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ;*MOV      RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 18 BYTES
        ; CVTSI2SD XMM0, QWORD [RCX] | F2480F2A01
        ; MOV      RAX, [RCX]        | 488B 01
        ;
        ; ...                        |
        ; ----------------------------------------------
        mov     rcx, [.rcx]
    $ifdef _SSEX
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0x018B4801
        @@xshr  rdi, 18
    $else
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x8B4829DF
        mov     [rdi + 14], byte 0x01
        @@xshr  rdi, 15
    $end
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopy.ivar.pop:
        mov     [rdi + 00], word 0xB948
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8948
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        dec     rcx
        jnz    .inline.vcopy.ivar.pop
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopy.svar:
        ; (13*acount)-(12*acount+10) = acount-10
        mov     rcx, [.ezx]
        sub     rcx, 10
        js     .inline.vcopy.svar.x
        @@range rcx, .error.memory
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.vcopy.svar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopy.svar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, qword [rdx]
        mov     [.rcx], rcx
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopy.svar.push:
        add     rdx, 12
        push    qword [rdx]
        dec     rcx
        jnz    .inline.vcopy.svar.push
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; 13 BYTES
        ; MOV   RAX, [RCX]      | 488B 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; ...                   |
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;>
        ; ----------------------------------------------
        mov     rcx, [.rcx]
        mov     rax, [rcx] ; get string value
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x8B48
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopy.svar.pop:
        mov     [rdi + 00], word 0xB948
        pop     rdx
      $ifdef SIC_FORCE_ASSIGN
        test    rdx, rdx
        jz     .error.argument
        mov     [rdx], rax ; assign string value at compile time
      $end
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0x8948
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        dec     rcx
        jnz    .inline.vcopy.svar.pop
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.vcopx:
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;
        ;?MOV     R13, ACOUNT       | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        mov     rcx, [.ezx]
        mov     [.zzx], rcx
        dec     [.zzx]
        @@xshl  rdi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.vcopx.dvar,\
                OBJ_INT_VAR    , .inline.vcopx.ivar,\
                OBJ_STRING_VAR , .inline.vcopx.svar
        jmp    .error.argument
   .inline.vcopx.dvar:
        mov     rcx, qword [rdi - 10]
        mov     [.rcx], rcx
    $ifdef _SSEX
        ; (13*acount+5)-(12*acount+10) = acount-5
;       ; (13*acount+4)-(12*acount+10) = acount-6
        mov     rcx, [.ezx]
        sub     rcx, 5
;       sub     rcx, 6
        js     .inline.vcopx.dvar.x
    $else
        ; (13*acount+2)-(12*acount+10) = acount-8
        mov     rcx, [.ezx]
        sub     rcx, 8
        js     .inline.vcopx.dvar.x
    $end
        @@range rcx, .error.memory
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.vcopx.dvar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopx.dvar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopx.dvar.push:
        push    qword [rdx]
        add     rdx, 12
        dec     rcx
        jnz    .inline.vcopx.dvar.push
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; 15 BYTES
        ; FLD   QWORD [RCX]     | DD01
        ; MOV   RAX, [RCX]      | 488B 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; ...                   |
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;>
        ; ----------------------------------------------
        ;
        ; ------------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 18 BYTES
        ;+MOV   RAX, [RCX]        | 488B 01
        ;+MOVQ  XMM0, RAX         | 66480F6EC0
        ;
        ; ...                     |
        ;>
        ; ------------------------------------------------
        ;
        ; ------------------------------------------------
        ;*MOV   RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 17 BYTES
        ;-MOVSD XMM0, QWORD [RCX] | F20F1001
        ;-MOV   RAX, [RCX]        | 488B 01
        ;
        ; ...                     |
        ;>
        ; ------------------------------------------------
        mov     rcx, [.rcx]
    $ifdef _SSEX
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x66018B48
        mov     [rdi + 14], dword 0xC06E0F48
        @@xshr  rdi, 18
;       mov     [rdi + 10], dword 0x01100FF2
;       mov     [rdi + 13], dword 0x018B4801
;       @@xshr  rdi, 17
    $else
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x8B4801DD
        mov     [rdi + 14], byte 0x01
        @@xshr  rdi, 15
    $end
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopx.dvar.pop:
        mov     [rdi + 00], word 0xB948
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8948
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        dec     rcx
        jnz    .inline.vcopx.dvar.pop
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopx.ivar:
        mov     rcx, qword [rdi - 10]
        mov     [.rcx], rcx
    $ifdef _SSEX
        ; (13*acount+5)-(12*acount+10) = acount-5
        mov     rcx, [.ezx]
        sub     rcx, 5
        js     .inline.vcopx.ivar.x
    $else
        ; (13*acount+2)-(12*acount+10) = acount-8
        mov     rcx, [.ezx]
        sub     rcx, 8
        js     .inline.vcopx.ivar.x
    $end
        @@range rcx, .error.memory
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.vcopx.ivar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopx.ivar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopx.ivar.push:
        push    qword [rdx]
        add     rdx, 12
        dec     rcx
        jnz    .inline.vcopx.ivar.push
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; 15 BYTES
        ; FILD  QWORD [RCX]     | DF29
        ; MOV   RAX, [RCX]      | 488B 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; ...
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;>
        ; ----------------------------------------------
        ;
        ; ---------------------------------------------------
        ;*MOV      RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; 18 BYTES
        ; CVTSI2SD XMM0, QWORD [RCX] | F2480F2A01
        ; MOV      RAX, [RCX]        | 488B 01
        ;
        ; ...
        ;>
        ; ---------------------------------------------------
        mov     rcx, [.rcx]
    $ifdef _SSEX
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x2A0F48F2
        mov     [rdi + 14], dword 0x018B4801
        @@xshr  rdi, 18
    $else
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], dword 0x8B4829DF
        mov     [rdi + 14], byte 0x01
        @@xshr  rdi, 15
    $end
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopx.ivar.pop:
        mov     [rdi + 00], word 0xB948
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8948
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        dec     rcx
        jnz    .inline.vcopx.ivar.pop
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.vcopx.svar:
        mov     rcx, qword [rdi - 10]
        mov     [.rcx], rcx
        ; (13*acount)-(12*acount+10) = acount-10
        mov     rcx, [.ezx]
        sub     rcx, 10
        js     .inline.vcopx.svar.x
        @@range rcx, .error.memory
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.vcopx.svar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.vcopx.svar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopx.svar.push:
        push    qword [rdx]
        add     rdx, 12
        dec     rcx
        jnz    .inline.vcopx.svar.push
        ;
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 SSSSSSSSSSSSSSSS ; 13 BYTES
        ; MOV   RAX, [RCX]      | 488B 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;
        ; ...                   |
        ;
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; 13 BYTES
        ; MOV   [RCX], RAX      | 4889 01
        ;>
        ; ----------------------------------------------
        mov     rcx, [.rcx]
        mov     rax, [rcx] ; get string value
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x8B48
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.vcopx.svar.pop:
        mov     [rdi + 00], word 0xB948
        pop     rdx
      $ifdef SIC_FORCE_ASSIGN
        test    rdx, rdx
        jz     .error.argument
        mov     [rdx], rax ; assign string value at compile time
      $end
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0x8948
        mov     [rdi + 12], byte 0x01
        @@xshr  rdi, 13
        dec     rcx
        jnz    .inline.vcopx.svar.pop
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.swapr:
        mov     [.XSP], 0
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;
        ;?MOV     R13, ACOUNT       | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        @@xshl  rdi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swapr.dvar,\
                OBJ_INT_VAR    , .inline.swapr.ivar,\
                OBJ_STRING_VAR , .inline.swapr.svar
        jmp    .error.argument
   .inline.swapr.dvar:
    $ifdef _SSEX
        ; (19*acount+2)-(12*acount+10) = 7*acount-8
;       ; (19*acount+1)-(12*acount+10) = 7*acount-9
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 8
;       sub     rax, 9
        js     .inline.swapr.dvar.x
    $else
        ; (19*acount-1)-(12*acount+10) = 7*acount-11
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 11
        js     .inline.swapr.dvar.x
    $end
        @@range rax, .error.memory
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.swapr.dvar.x:
        mov     rcx, [.ezx]
        mov     [.zzx], rcx
   .inline.swapr.dvar.push:
        push    qword [rdi - 10]                            ; PUSH X(1), X(2), ... , X(N-1), X(N)
        add     [.XSP], 8
        @@xshl  rdi, 12
        dec     [.zzx]
        jz     .inline.swapr.dvar.push.out
        ;
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .inline.swapr.error
        jmp    .inline.swapr.dvar.push
   .inline.swapr.dvar.push.out:
        ; ----------------------------------------------
        ; X(N) -> R10
        ;*MOV   RAX, X(N)       | 48B8 FFFFFFFFFFFFFFFF ; 13 BYTES
        ; MOV   R10, [RAX]      | 4C8B 10
        ;
        ; X(N-1) -> X(N)
        ; MOV   RDX, RAX:X(N)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N-1)     | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(N-2) -> X(N-1)
        ; MOV   RDX, RAX:X(N-1) | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N-2)     | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; MOV   RDX, RAX:X(3)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(2)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(1) -> X(2)
        ; MOV   RDX, RAX:X(2)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(1)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(N) -> X(1)
        ; MOV   [RAX], R10      | 4C89 10               ; 5 BYTES
        ; FLD   QWORD [RAX]     | DD00
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(N) -> X(1)
        ;+MOV   [RAX], R10        | 4C89 10             ; 8 BYTES
        ;+MOVQ  XMM0, R10         | 66490F6EC2
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(N) -> X(1)
        ;-MOV   [RAX], R10        | 4C89 10             ; 7 BYTES
        ;-MOVSD XMM0, QWORD [RAX] | F20F1000
        ;>
        ; ----------------------------------------------
        mov     [rdi + 00], word 0xB848
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8B4C
        mov     [rdi + 12], byte 0x10
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.swapr.dvar.pop:
        mov     [rdi + 00], word 0x8948
        mov     [rdi + 02], byte 0xC2
        mov     [rdi + 03], word 0xB848
        pop     qword [rdi + 05]
        mov     [rdi + 13], word 0x8B48
        mov     [rdi + 15], byte 0x08
        mov     [rdi + 16], word 0x8948
        mov     [rdi + 18], byte 0x0A
        @@xshr  rdi, 19
        dec     rcx
        jnz    .inline.swapr.dvar.pop
        ;
    $ifdef _SSEX
        mov     [rdi + 00], dword 0x6610894C
        mov     [rdi + 04], dword 0xC26E0F49
        @@xshr  rdi, 8
;       mov     [rdi + 00], dword 0x0010894C
;       mov     [rdi + 03], dword 0x00100FF2
;       @@xshr  rdi, 7
    $else
        mov     [rdi + 00], word 0x894C
        mov     [rdi + 02], byte 0x10
        mov     [rdi + 03], word 0x00DD
        @@xshr  rdi, 5
    $end
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapr.ivar:
    $ifdef _SSEX
        ; (19*acount+2)-(12*acount+10) = 7*acount-8
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 8
        js     .inline.swapr.ivar.x
    $else
        ; (19*acount-1)-(12*acount+10) = 7*acount-11
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 11
        js     .inline.swapr.ivar.x
    $end
        @@range rax, .error.memory
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.swapr.ivar.x:
        mov     rcx, [.ezx]
        mov     [.zzx], rcx
   .inline.swapr.ivar.push:
        push    qword [rdi - 10]                            ; PUSH X(1), X(2), ... , X(N-1), X(N)
        add     [.XSP], 8
        @@xshl  rdi, 12
        dec     [.zzx]
        jz     .inline.swapr.ivar.push.out
        ;
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .inline.swapr.error
        jmp    .inline.swapr.ivar.push
   .inline.swapr.ivar.push.out:
        ; ----------------------------------------------
        ; X(N) -> R10
        ;*MOV   RAX, X(N)       | 48B8 FFFFFFFFFFFFFFFF ; 13 BYTES
        ; MOV   R10, [RAX]      | 4C8B 10
        ;
        ; X(N-1) -> X(N)
        ; MOV   RDX, RAX:X(N)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N-1)     | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(N-2) -> X(N-1)
        ; MOV   RDX, RAX:X(N-1) | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N-2)     | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; MOV   RDX, RAX:X(3)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(2)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(1) -> X(2)
        ; MOV   RDX, RAX:X(2)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(1)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(N) -> X(1)
        ; MOV   [RAX], R10      | 4C89 10               ; 5 BYTES
        ; FILD  QWORD [RAX]     | DF28
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(N) -> X(1)
        ; MOV      [RAX], R10        | 4C89 10          ; 8 BYTES
        ; CVTSI2SD XMM0, QWORD [RAX] | F2480F2A00
        ;>
        ; ----------------------------------------------
        mov     [rdi + 00], word 0xB848
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8B4C
        mov     [rdi + 12], byte 0x10
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.swapr.ivar.pop:
        mov     [rdi + 00], word 0x8948
        mov     [rdi + 02], byte 0xC2
        mov     [rdi + 03], word 0xB848
        pop     qword [rdi + 05]
        mov     [rdi + 13], word 0x8B48
        mov     [rdi + 15], byte 0x08
        mov     [rdi + 16], word 0x8948
        mov     [rdi + 18], byte 0x0A
        @@xshr  rdi, 19
        dec     rcx
        jnz    .inline.swapr.ivar.pop
        ;
    $ifdef _SSEX
        mov     [rdi + 00], dword 0xF210894C
        mov     [rdi + 04], dword 0x002A0F48
        @@xshr  rdi, 8
    $else
        mov     [rdi + 00], word 0x894C
        mov     [rdi + 02], byte 0x10
        mov     [rdi + 03], word 0x28DF
        @@xshr  rdi, 5
    $end
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapr.svar:
        ; (19*acount-3)-(12*acount+10) = 7*acount-13
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 13
        js     .inline.swapr.svar.x
        @@range rax, .error.memory
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.swapr.svar.x:
        mov     rcx, [.ezx]
        mov     [.zzx], rcx
   .inline.swapr.svar.push:
        push    qword [rdi - 10]                            ; PUSH X(1), X(2), ... , X(N-1), X(N)
        add     [.XSP], 8
        @@xshl  rdi, 12
        dec     [.zzx]
        jz     .inline.swapr.svar.push.out
        ;
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .inline.swapr.error
        jmp    .inline.swapr.svar.push
   .inline.swapr.svar.push.out:
        ; ----------------------------------------------
        ; X(N) -> R10
        ;*MOV   RAX, X(N)       | 48B8 FFFFFFFFFFFFFFFF ; 13 BYTES
        ; MOV   R10, [RAX]      | 4C8B 10
        ;
        ; X(N-1) -> X(N)
        ; MOV   RDX, RAX:X(N)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N-1)     | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(N-2) -> X(N-1)
        ; MOV   RDX, RAX:X(N-1) | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N-2)     | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; ...
        ;
        ; X(2) -> X(3)
        ; MOV   RDX, RAX:X(3)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(2)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(1) -> X(2)
        ; MOV   RDX, RAX:X(2)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(1)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(N) -> X(1)
        ; MOV   [RAX], R10      | 4C89 10               ; 3 BYTES
        ;>
        ; ----------------------------------------------
        mov     [rdi + 00], word 0xB848
        pop     rdx
        mov     [rdi + 02], rdx
        push    qword [rdx]
        pop     qword [.rdx]
        mov     [rdi + 10], word 0x8B4C
        mov     [rdi + 12], byte 0x10
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.swapr.svar.pop:
        mov     [rdi + 00], word 0x8948
        mov     [rdi + 02], byte 0xC2
        mov     [rdi + 03], word 0xB848
        pop     rax
        mov     [rdi + 05], rax
      $ifdef SIC_FORCE_ASSIGN
        test    rax, rax
        jz     .error.argument
        test    rdx, rdx
        jz     .error.argument
        push    qword [rax]
        pop     qword [rdx] ; assign string value at compile time
      $end
        mov     rdx, rax
        mov     [rdi + 13], word 0x8B48
        mov     [rdi + 15], byte 0x08
        mov     [rdi + 16], word 0x8948
        mov     [rdi + 18], byte 0x0A
        @@xshr  rdi, 19
        dec     rcx
        jnz    .inline.swapr.svar.pop
        ;
        mov     [rdi + 00], word 0x894C
        mov     [rdi + 02], byte 0x10
      $ifdef SIC_FORCE_ASSIGN
        mov     rdx, [.rdx]
        test    rax, rax
        jz     .error.argument
        mov     [rax], rdx ; assign string value at compile time
      $end
        @@xshr  rdi, 3
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapr.error:
        add     rsp, [.XSP]
        jmp    .error.argument

   .inline.swapl:
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ;?PUSH    QWORD [RDX]       | FF32
        ;
        ;?MOV     R13, ACOUNT       | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        ;
        mov     rcx, [.ezx]
        mov     [.zzx], rcx
        dec     [.zzx]
        @@xshl  rdi, 10
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.swapl.dvar,\
                OBJ_INT_VAR    , .inline.swapl.ivar,\
                OBJ_STRING_VAR , .inline.swapl.svar
        jmp    .error.argument
   .inline.swapl.dvar:
        mov     rcx, [rdi - 10]
        mov     [.rcx], rcx                                 ; [.rcx] = X(1)
    $ifdef _SSEX
        ; (19*acount+2)-(12*acount+10) = 7*acount-8
;       ; (19*acount+1)-(12*acount+10) = 7*acount-9
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 8
        js     .inline.swapl.dvar.x
    $else
        ; (19*acount-1)-(12*acount+10) = 7*acount-11
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 11
        js     .inline.swapl.dvar.x
    $end
        @@range rax, .error.memory
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
   .inline.swapl.dvar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_DOUBLE_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.swapl.dvar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, [.ezx]
        dec     rcx
        ;
        push    [.rcx]                                      ; PUSH X(1)
   .inline.swapl.dvar.push:
        push    qword [rdx]                                 ; PUSH X(N), X(N-1), ... , X(3), X(2)
        add     rdx, 12
        dec     rcx
        jnz    .inline.swapl.dvar.push
        ;
        ; ----------------------------------------------
        ; X(2) -> R10
        ;*MOV   RAX, X(2)       | 48B8 FFFFFFFFFFFFFFFF ; 13 BYTES
        ; MOV   R10, [RAX]      | 4C8B 10
        ;
        ; X(3) -> X(2)
        ; MOV   RDX, RAX:X(2)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(3)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(4) -> X(3)
        ; MOV   RDX, RAX:X(3)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(4)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; MOV   RDX, RAX:X(N-1) | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(1) -> X(N)
        ; MOV   RDX, RAX:X(N)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(1)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(2) -> X(1)
        ; MOV   QWORD [RAX], R10| 4C89 10               ; 5 BYTES
        ; FLD   QWORD [RAX]     | DD00
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(2) -> X(1)
        ;+MOV   QWORD [RAX], R10  | 4C89 10             ; 8 BYTES
        ;+MOVQ  XMM0, R10         | 66490F6EC2
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(2) -> X(1)
        ;-MOV   QWORD [RAX], R10  | 4C89 10             ; 7 BYTES
        ;-MOVSD XMM0, QWORD [RAX] | F20F1000
        ;>
        ; ----------------------------------------------
        mov     [rdi + 00], word 0xB848
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8B4C
        mov     [rdi + 12], byte 0x10
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.swapl.dvar.pop:
        mov     [rdi + 00], word 0x8948
        mov     [rdi + 02], byte 0xC2
        mov     [rdi + 03], word 0xB848
        pop     qword [rdi + 05]
        mov     [rdi + 13], word 0x8B48
        mov     [rdi + 15], byte 0x08
        mov     [rdi + 16], word 0x8948
        mov     [rdi + 18], byte 0x0A
        @@xshr  rdi, 19
        dec     rcx
        jnz    .inline.swapl.dvar.pop
        ;
    $ifdef _SSEX
        mov     [rdi + 00], dword 0x6610894C
        mov     [rdi + 04], dword 0xC26E0F49
        @@xshr  rdi, 8
;       mov     [rdi + 00], dword 0x0010894C
;       mov     [rdi + 03], dword 0x00100FF2
;       @@xshr  rdi, 7
    $else
        mov     [rdi + 00], word 0x894C
        mov     [rdi + 02], byte 0x10
        mov     [rdi + 03], word 0x00DD
        @@xshr  rdi, 5
    $end
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapl.ivar:
        mov     rcx, [rdi - 10]
        mov     [.rcx], rcx                                 ; [.rcx] = X(1)
    $ifdef _SSEX
        ; (19*acount+2)-(12*acount+10) = 7*acount-8
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 8
        js     .inline.swapl.ivar.x
    $else
        ; (19*acount-1)-(12*acount+10) = 7*acount-11
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 11
        js     .inline.swapl.ivar.x
    $end
        @@range rax, .error.memory
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD ;>integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
   .inline.swapl.ivar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_INT_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.swapl.ivar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, [.ezx]
        dec     rcx
        ;
        push    [.rcx]                                      ; PUSH X(1)
   .inline.swapl.ivar.push:
        push    qword [rdx]                                 ; PUSH X(N), X(N-1), ... , X(3), X(2)
        add     rdx, 12
        dec     rcx
        jnz    .inline.swapl.ivar.push
        ;
        ; ----------------------------------------------
        ; X(2) -> R10
        ;*MOV   RAX, X(2)       | 48B8 FFFFFFFFFFFFFFFF ; 13 BYTES
        ; MOV   R10, QWORD [RAX]| 4C8B 10
        ;
        ; X(3) -> X(2)
        ; MOV   RDX, RAX:X(2)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(3)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(4) -> X(3)
        ; MOV   RDX, RAX:X(3)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(4)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; MOV   RDX, RAX:X(N-1) | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(1) -> X(N)
        ; MOV   RDX, RAX:X(N)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(1)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(2) -> X(1)
        ; MOV   QWORD [RAX], R10| 4C89 10               ; 5 BYTES
        ; FILD  QWORD [RAX]     | DF28
        ;>
        ; ----------------------------------------------
        ;
        ; ----------------------------------------------
        ; ...
        ;
        ; X(2) -> X(1)
        ; MOV      QWORD [RAX], R10  | 4C89 10          ; 8 BYTES
        ; CVTSI2SD XMM0, QWORD [RAX] | F2480F2A00
        ;>
        ; ----------------------------------------------
        mov     [rdi + 00], word 0xB848
        pop     qword [rdi + 02]
        mov     [rdi + 10], word 0x8B4C
        mov     [rdi + 12], byte 0x10
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.swapl.ivar.pop:
        mov     [rdi + 00], word 0x8948
        mov     [rdi + 02], byte 0xC2
        mov     [rdi + 03], word 0xB848
        pop     qword [rdi + 05]
        mov     [rdi + 13], word 0x8B48
        mov     [rdi + 15], byte 0x08
        mov     [rdi + 16], word 0x8948
        mov     [rdi + 18], byte 0x0A
        @@xshr  rdi, 19
        dec     rcx
        jnz    .inline.swapl.ivar.pop
        ;
    $ifdef _SSEX
        mov     [rdi + 00], dword 0xF210894C
        mov     [rdi + 04], dword 0x002A0F48
        @@xshr  rdi, 8
    $else
        mov     [rdi + 00], word 0x894C
        mov     [rdi + 02], byte 0x10
        mov     [rdi + 03], word 0x28DF
        @@xshr  rdi, 5
    $end
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.ezx], 0
        jmp    .done
        ;
   .inline.swapl.svar:
        mov     rcx, [rdi - 10]
        mov     [.rcx], rcx                                 ; [.rcx] = X(1)
        ; (19*acount-3)-(12*acount+10) = 7*acount-13
        mov     rcx, [.ezx]
        mov     rax, 7
        mul     rcx
        sub     rax, 13
        js     .inline.swapl.svar.x
        @@range rax, .error.memory
        ; --------------------------------------------------
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD ;>string variable (12B)
        ; PUSH    QWORD [RDX]       | FF32
        ;>
        ; --------------------------------------------------
   .inline.swapl.svar.x:
        @@xshl  rdi, 12
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        cmp     ecx, OBJ_STRING_VAR
        jne    .error.argument
        dec     [.zzx]
        jnz    .inline.swapl.svar.x
        ;
        @@xshl  rdi, 12
        lea     rdx, [rdi + 2]
        mov     rcx, [.ezx]
        dec     rcx
        ;
        push    [.rcx]                                      ; PUSH X(1)
   .inline.swapl.svar.push:
        push    qword [rdx]                                 ; PUSH X(N), X(N-1), ... , X(3), X(2)
        add     rdx, 12
        dec     rcx
        jnz    .inline.swapl.svar.push
        ;
        ; ----------------------------------------------
        ; X(2) -> R10
        ;*MOV   RAX, X(2)       | 48B8 FFFFFFFFFFFFFFFF ; 13 BYTES
        ; MOV   R10, QWORD [RAX]| 4C8B 10
        ;
        ; X(3) -> X(2)
        ; MOV   RDX, RAX:X(2)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(3)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(4) -> X(3)
        ; MOV   RDX, RAX:X(3)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(4)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; ...
        ;
        ; X(N) -> X(N-1)
        ; MOV   RDX, RAX:X(N-1) | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(N)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(1) -> X(N)
        ; MOV   RDX, RAX:X(N)   | 4889 C2               ; 19 BYTES
        ; MOV   RAX, X(1)       | 48B8 FFFFFFFFFFFFFFFF
        ; MOV   RCX, [RAX]      | 488B 08
        ; MOV   [RDX], RCX      | 4889 0A
        ;
        ; X(2) -> X(1)
        ; MOV   QWORD [RAX], R10| 4C89 10               ; 3 BYTES
        ;>
        ; ----------------------------------------------
        mov     [rdi + 00], word 0xB848
        pop     rdx
        mov     [rdi + 02], rdx
        push    qword [rdx]
        pop     qword [.rdx]
        mov     [rdi + 10], word 0x8B4C
        mov     [rdi + 12], byte 0x10
        @@xshr  rdi, 13
        mov     rcx, [.ezx]
        dec     rcx
   .inline.swapl.svar.pop:
        mov     [rdi + 00], word 0x8948
        mov     [rdi + 02], byte 0xC2
        mov     [rdi + 03], word 0xB848
        pop     rax
        mov     [rdi + 05], rax
      $ifdef SIC_FORCE_ASSIGN
        test    rax, rax
        jz     .error.argument
        test    rdx, rdx
        jz     .error.argument
        push    qword [rax]
        pop     qword [rdx] ; assign string value at compile time
      $end
        mov     rdx, rax
        mov     [rdi + 13], word 0x8B48
        mov     [rdi + 15], byte 0x08
        mov     [rdi + 16], word 0x8948
        mov     [rdi + 18], byte 0x0A
        @@xshr  rdi, 19
        dec     rcx
        jnz    .inline.swapl.svar.pop
        ;
        mov     [rdi + 00], word 0x894C
        mov     [rdi + 02], byte 0x10
      $ifdef SIC_FORCE_ASSIGN
        mov     rdx, [.rdx]
        test    rax, rax
        jz     .error.argument
        mov     [rax], rdx ; assign string value at compile time
      $end
        @@xshr  rdi, 3
        ;
        mov     rcx, [.ezx]
        shl     rcx, 3
        add     [.RSP], rcx
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.cmove:
        mov     [.FPU], 0
   .inline.ccopy:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccopy.dvar
        jmp    .error.argument
   .inline.ccopy.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccopy.dvar.dvar
        jmp    .error.argument
   .inline.ccopy.dvar.dvar:
        ; --------------------------------------------------
        ;?...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.ccopy.main,\
                OBJ_DOUBLE_SSE , .inline.ccopy.main,\
                OBJ_DOUBLE_VAR , .inline.ccopy.main,\
                OBJ_DOUBLE_CON , .inline.ccopy.main
        jmp    .error.argument
   .inline.ccopy.main:
        ; --------------------------------------------------
        ;?...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]
        mov     rdx, [rdi - 22]
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        sub     [.ezx], 2
        jmp    .inline.proc

   .inline.ccovalue:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccovalue.dvar
        jmp    .error.argument
   .inline.ccovalue.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccovalue.dvar.dvar
        jmp    .error.argument
   .inline.ccovalue.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        mov     rcx, [rdi - 10]
        movsd   xmm0, qword [rcx]
        mov     rcx, [rdi - 22]
        movsd   xmm1, qword [rcx]
    $else
        mov     rcx, [rdi - 10]
        fld     qword [rcx]
        mov     rcx, [rdi - 22]
        fld     qword [rcx]
    $end
        @@xshl  rdi, 24
        add     [.RSP], 16
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end

   .inline.crestore:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.crestore.dvar
        jmp    .error.argument
   .inline.crestore.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.crestore.dvar.dvar
        jmp    .error.argument
   .inline.crestore.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 46-24, .error.memory
    $ifdef _SSEX
        mov     rcx, [rdi - 10]
        movsd   xmm0, qword [rcx]
        movsd   qword [rsp - 08], xmm0
        mov     rdx, [rdi - 22]
        movsd   xmm1, qword [rdx]
        movsd   qword [rsp - 16], xmm1
    $else
        mov     rcx, [rdi - 10]
        fld     qword [rcx]
        fst     qword [rsp - 08]
        mov     rdx, [rdi - 22]
        fld     qword [rdx]
        fst     qword [rsp - 16]
    $end
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xB848
        mov     rax, [rsp - 08]
        mov     [rdi + 12], rax
        mov     [rdi + 20], byte 0x48
        mov     [rdi + 21], word 0x0189
        ;
        mov     [rdi + 23], word 0xB948
        mov     [rdi + 25], rdx
        mov     [rdi + 33], word 0xB848
        mov     rax, [rsp - 16]
        mov     [rdi + 35], rax
        mov     [rdi + 43], byte 0x48
        mov     [rdi + 44], word 0x0189
        @@xshr  rdi, 46
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RAX, FF+          | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     QWORD [RCX], RAX  | 488901

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RAX, FF+          | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     QWORD [RCX], RAX  | 488901
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
    $ifdef _SSEX
        pcase   rsi, @@crestore, .inline.sse.dcon.test
    $else
        pcase   rsi, @@crestore, .inline.st0.dcon.test
        fstp    st0
        fstp    st0
    $end
        mov     [.FPU], 0
        mov     [.ezx], 0
        jmp    .done

   .inline.cmove.2p:
        mov     [.FPU], 0
   .inline.ccopy.2p:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccopy.2p.dvar
        jmp    .error.argument
   .inline.ccopy.2p.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccopy.2p.dvar.dvar
        jmp    .error.argument
   .inline.ccopy.2p.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]
        mov     rdx, [rdi - 22]
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        jmp    .inline.proc

   .inline.cmove.3p:
        mov     [.FPU], 0
   .inline.ccopy.3p:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.ccopy.3p.dvar
        jmp    .error.argument
   .inline.ccopy.3p.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.ccopy.3p.dvar.dvar
        jmp    .error.argument
   .inline.ccopy.3p.dvar.dvar:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0 , .inline.ccopy.3p.main,\
                OBJ_DOUBLE_SSE , .inline.ccopy.3p.main,\
                OBJ_DOUBLE_VAR , .inline.ccopy.3p.main,\
                OBJ_DOUBLE_CON , .inline.ccopy.3p.main
        jmp    .error.argument
   .inline.ccopy.3p.main:
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 10]
        mov     rdx, [rdi - 22]
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        sub     [.ezx], 2
        jmp    .inline.proc

   .inline.cpmove.3p:
        mov     [.FPU], 0
   .inline.cpcopy.3p:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ; ...                       | ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;?PUSH    RCX               | 51
        ;?NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.cpcopy.3p.ivar,\
                OBJ_POINTER , .inline.cpcopy.3p.ptr
        jmp    .error.argument
   .inline.cpcopy.3p.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 3-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 0], byte 0x48
        mov     [rdi + 1], word 0x088B
        @@xshr  rdi, 3
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*MOV     RCX, [RAX]        | 488B08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc
   .inline.cpcopy.3p.ptr:
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS ; pointer constant (14B)
        ;*PUSH    RCX               | 51
        ; NOP3                      | 909090
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 4
        ; --------------------------------------------------
        ; MOV     RCX, VALUE        | 48B9 SSSSSSSSSSSSSSSS
        ;*
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        dec     [.ezx]
        jmp    .inline.proc

   .inline.cswop:
        mov     [.FPU], 0
   .inline.cswap:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\                                       ; ecx = object type
                OBJ_DOUBLE_VAR , .inline.cswap.dvar
        jmp    .error.argument
   .inline.cswap.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.cswap.dvar.dvar
        jmp    .error.argument
   .inline.cswap.dvar.dvar:
        stdcall code_object, [.cooff], -24                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.cswap.dvar.dvar.dvar
        jmp    .error.argument
   .inline.cswap.dvar.dvar.dvar:
        stdcall code_object, [.cooff], -36                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.cswap.dvar.dvar.dvar.dvar
        jmp    .error.argument
   .inline.cswap.dvar.dvar.dvar.dvar:
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31

        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        push    rax rbx
        mov     rcx, [rdi - 10]
        mov     rdx, [rdi - 22]
        mov     rax, [rdi - 34]
        mov     rbx, [rdi - 46]
        @@xshl  rdi, 48
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0xBA48
        mov     [rdi + 12], rdx
        mov     [rdi + 20], word 0xB848
        mov     [rdi + 22], rax
        mov     [rdi + 30], word 0xBB48
        mov     [rdi + 32], rbx
        @@xshr  rdi, 40
        pop     rbx rax
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; MOV     RDX, OFFSET       | 48BA DDDDDDDDDDDDDDDD
        ; MOV     RAX, OFFSET       | 48B8 DDDDDDDDDDDDDDDD
        ; MOV     RBX, OFFSET       | 48BB DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 32
        mov     [.ezx], 0
        jmp    .inline.proc

   .inline.bara:
        mov     [.neg], 1
   .inline.fara:
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
        ;
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.xara.index.dcon,\
                OBJ_INT_CON     , .inline.xara.index.icon
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.xarr.index.dst0,\
                OBJ_DOUBLE_SSE  , .inline.xarr.index.dsse,\
                OBJ_DOUBLE_VAR  , .inline.xarr.index.dvar,\
                OBJ_INT_VAR     , .inline.xarr.index.ivar,\
                OBJ_INT_RSP_RAX , .inline.xarr.index.irsp.rax
        jmp    .error.argument
   .inline.xara.index.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rax, [rdi - 21]                             ; rax = int64 constant
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        jmp    .inline.xara.index.con
   .inline.xara.index.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
   .inline.xara.index.con:
        @@xshl  rdi, 23
        cmp     [.neg], 0
        jz      @F
        neg     rax
    @@:
        lea     rdx, [rdx + rax*8]
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x90909051
        @@xshr  rdi, 14
        ; ----------------------------------------------
        ;*MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF ; pointer constant (14B)
        ; PUSH  RCX             | 51
        ; NOP3                  | 909090
        ;>
        ; ----------------------------------------------
        mov     [.cotype], 'pcon'
        add     [.RSP], 16
        jmp    .exit

   .inline.xarr:
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_DOUBLE_VAR                         ; ecx = object type
        jne    .error.argument
   .inline.xarr.index:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 IIIIIIIIIIIIIIII ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 IIIIIIIIIIIIIIII ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.xarr.index.dst0,\
                OBJ_DOUBLE_SSE  , .inline.xarr.index.dsse,\
                OBJ_DOUBLE_VAR  , .inline.xarr.index.dvar,\
                OBJ_DOUBLE_CON  , .inline.xarr.index.dcon,\
                OBJ_INT_VAR     , .inline.xarr.index.ivar,\
                OBJ_INT_CON     , .inline.xarr.index.icon,\
                OBJ_INT_RSP_RAX , .inline.xarr.index.irsp.rax
        jmp    .error.argument
   .inline.xarr.index.dst0:
        ; ----------------------------------------------
        ; ...                   | ...
        ;*FSTP  QWORD [RSP]     | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        @@range 26-15, .error.memory
        mov     rax, @@__int64                          ; rax = "int" proc offset
        mov     rdx, [rdi - 10]                         ; rdx = variable offset
        @@xshl  rdi, 15
        mov     [rdi + 00], dword 0x08C48348
        mov     [rdi + 04], word 0xBA48
        mov     [rdi + 06], rax
        mov     [rdi + 14], dword 0xB948D2FF
        mov     [rdi + 18], rdx
        @@xshr  rdi, 26
        ; ----------------------------------------------
        ;*ADD   RSP, 8          | 4883C408
        ; MOV   RDX, @@__int64  | 48BA PPPPPPPPPPPPPPPP
        ; CALL  RDX             | FFD2
        ; MOV   RCX, OFFSET     | 48B9 AAAAAAAAAAAAAAAA
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        @@range 19-17, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 17
        mov     [rdi + 00], dword 0x08C48348
        mov     [rdi + 04], dword 0x2C0F48F2
        mov     [rdi + 08], dword 0x00B948C0
        mov     [rdi + 11], rdx
        @@xshr  rdi, 19
        ; --------------------------------------------------
        ;*ADD        RSP, 8      | 4883C408
        ; CVTTSD2SI  RAX, XMM0   | F2480F2CC0
        ; MOV        RCX, OFFSET | 48B9 AAAAAAAAAAAAAAAA
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.dvar:
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 IIIIIIIIIIIIIIII ; double variable (12B)
        ;*PUSH  QWORD [RCX]     | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
    $ifdef _SSEX
        @@range 19-14, .error.memory
        mov     rdx, [rdi - 10]                         ; rdx = variable offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x01100FF2
        mov     [rdi + 04], dword 0x2C0F48F2
        mov     [rdi + 08], dword 0x00B948C0
        mov     [rdi + 11], rdx
        @@xshr  rdi, 19
        ; ----------------------------------------------
        ; MOV        RCX, OFFSET       | 48B9 IIIIIIIIIIIIIIII
        ;*MOVSD      XMM0, QWORD [RCX] | F20F1001
        ; CVTTSD2SI  RAX, XMM0         | F2480F2CC0
        ; MOV        RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
    $else
        @@range 24-14, .error.memory
        mov     rax, @@__int64                          ; rax = "int" proc offset
        mov     rdx, [rdi - 10]                         ; rdx = variable offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0xBA4801DD
        mov     [rdi + 04], rax
        mov     [rdi + 12], dword 0xB948D2FF
        mov     [rdi + 16], rdx
        @@xshr  rdi, 24
        ; ----------------------------------------------
        ; MOV   RCX, OFFSET     | 48B9 IIIIIIIIIIIIIIII
        ;*FLD   QWORD [RCX]     | DD01
        ; MOV   RDX, @@__int64  | 48BA PPPPPPPPPPPPPPPP
        ; CALL  RDX             | FFD2
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
    $end
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RAX, INT64        | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.ivar:
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 IIIIIIIIIIIIIIII ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH  QWORD [RCX]     | FF31
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 10]                         ; rdx = variable offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x48008B48
        mov     [rdi + 04], byte 0xB9
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 IIIIIIIIIIIIIIII
        ;*MOV   RAX, [RAX]      | 488B00
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.index.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ; double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C4 08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.xarr.proc
   .inline.xarr.proc:
        mov     [.ezx], 0
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        pcase   rsi,\
                @@farw , .inline.xarw.proc,\
                @@barw , .inline.xarw.proc,\
                @@fara , .inline.xara.proc,\
                @@bara , .inline.xara.proc
        jmp    .inline.proc
   .inline.xarw.proc:
;       add     [.RSP], 0
        mov     [.ezx], 1
        jmp    .inline.proc
   .inline.xara.proc:
;       add     [.RSP], 0
        jmp    .inline.proc

   .inline.pxarr:
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_INT_VAR                            ; ecx = object type
        jne    .error.argument
   .inline.pxarr.index:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 IIIIIIIIIIIIIIII ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 IIIIIIIIIIIIIIII ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.pxarr.index.dst0,\
                OBJ_DOUBLE_SSE  , .inline.pxarr.index.dsse,\
                OBJ_DOUBLE_VAR  , .inline.pxarr.index.dvar,\
                OBJ_DOUBLE_CON  , .inline.pxarr.index.dcon,\
                OBJ_INT_VAR     , .inline.pxarr.index.ivar,\
                OBJ_INT_CON     , .inline.pxarr.index.icon,\
                OBJ_INT_RSP_RAX , .inline.pxarr.index.irsp.rax
        jmp    .error.argument
   .inline.pxarr.index.dst0:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 26-15, .error.memory
        mov     rax, @@__int64                              ; rax = "int" proc offset
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 15
        mov     [rdi + 00], dword 0x08C48348
        mov     [rdi + 04], word 0xBA48
        mov     [rdi + 06], rax
        mov     [rdi + 14], dword 0xB948D2FF
        mov     [rdi + 18], rdx
        @@xshr  rdi, 26
        ; --------------------------------------------------
        ;*ADD     RSP, 8            | 4883C408
        ; MOV     RDX, @@__int64    | 48BA PPPPPPPPPPPPPPPP
        ; CALL    RDX               | FFD2
        ; MOV     RCX, OFFSET       | 48B9 AAAAAAAAAAAAAAAA
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.dsse:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@range 19-17, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 17
        mov     [rdi + 00], dword 0x08C48348
        mov     [rdi + 04], dword 0x2C0F48F2
        mov     [rdi + 08], dword 0x00B948C0
        mov     [rdi + 11], rdx
        @@xshr  rdi, 19
        ; --------------------------------------------------
        ;*ADD        RSP, 8      | 4883C408
        ; CVTTSD2SI  RAX, XMM0   | F2480F2CC0
        ; MOV        RCX, OFFSET | 48B9 AAAAAAAAAAAAAAAA
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 IIIIIIIIIIIIIIII ; double variable (12B)
        ;*PUSH    QWORD [RCX]       | FF31
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 19-14, .error.memory
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x01100FF2
        mov     [rdi + 04], dword 0x2C0F48F2
        mov     [rdi + 08], dword 0x00B948C0
        mov     [rdi + 11], rdx
        @@xshr  rdi, 19
        ; --------------------------------------------------
        ; MOV        RCX, OFFSET       | 48B9 IIIIIIIIIIIIIIII
        ;*MOVSD      XMM0, QWORD [RCX] | F20F1001
        ; CVTTSD2SI  RAX, XMM0         | F2480F2CC0
        ; MOV        RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
    $else
        @@range 24-14, .error.memory
        mov     rax, @@__int64                              ; rax = "int" proc offset
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0xBA4801DD
        mov     [rdi + 04], rax
        mov     [rdi + 12], dword 0xB948D2FF
        mov     [rdi + 16], rdx
        @@xshr  rdi, 24
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 IIIIIIIIIIIIIIII
        ;*FLD     QWORD [RCX]       | DD01
        ; MOV     RDX, @@__int64    | 48BA PPPPPPPPPPPPPPPP
        ; CALL    RDX               | FFD2
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
    $end
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 23
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rdx
        @@xshr  rdi, 20
        ; --------------------------------------------------
        ;*MOV     RAX, INT64        | 48B8 FFFFFFFFFFFFFFFF
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 IIIIIIIIIIIIIIII ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 14
        mov     [rdi + 00], dword 0x48008B48
        mov     [rdi + 04], byte 0xB9
        mov     [rdi + 05], rdx
        @@xshr  rdi, 13
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 IIIIIIIIIIIIIIII
        ;*MOV   RAX, [RAX]      | 488B00
        ; MOV   RCX, OFFSET     | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; ----------------------------------------------
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 13
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.index.irsp.rax:
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 10]                             ; rdx = variable offset
        @@xshl  rdi, 16
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD
        ; ADD     RSP, 8            | 4883C4 08
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        jmp    .inline.pxarr.proc
   .inline.pxarr.proc:
        mov     [.ezx], 0
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        pcase   rsi,\
                @@pfarw , .inline.pxarw.proc,\
                @@pbarw , .inline.pxarw.proc,\
                @@pfara , .inline.pxara.proc,\
                @@pbara , .inline.pxara.proc
        jmp    .inline.proc
   .inline.pxarw.proc:
;       add     [.RSP], 0
        mov     [.ezx], 1
        jmp    .inline.proc
   .inline.pxara.proc:
;       add     [.RSP], 0
        jmp    .inline.proc

   .inline.barv:
        mov     [.neg], 1
   .inline.farv:
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.xarv.dvar
        jmp    .error.argument
   .inline.xarv.dvar:
        stdcall code_object, [.cooff], -12                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.xarv.dvar.dcon,\
                OBJ_INT_CON    , .inline.xarv.dvar.icon
        jmp    .error.argument
   .inline.xarv.dvar.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 21]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rcx, [rdi - 10]
        ;
        @@xshl  rdi, 23
        add     [.RSP], 16
        jmp    .inline.xarv.proc
   .inline.xarv.dvar.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     rax, [rdi - 21]
        mov     rcx, [rdi - 10]
        ;
        @@xshl  rdi, 23
        add     [.RSP], 16
   .inline.xarv.proc:
        cmp     [.neg], 0
        jz     .inline.xarv.proc.x
        neg     rax
   .inline.xarv.proc.x:
        lea     rcx, [rcx + rax*8]
        mov     [rdi + 00], word 0xB948
        mov     [rdi + 02], rcx
        mov     [rdi + 10], word 0x31FF
        @@xshr  rdi, 12
        ; --------------------------------------------------
        ;*MOV     RCX, OFFSET       | 48B9 DDDDDDDDDDDDDDDD ;>double variable (12B)
        ; PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
        mov     [.cotype], 'dvar'
        jmp    .exit

   .inline.matrip:
        mov     [.fpatype], 'i'
        ; --------------------------------------------------
        ;?MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ;?PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        ;?MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     [.proc_o], rsi
        mov     [.proc_z], rax
        push    [.ezx]
        pop     [.rcx]
        mov     [.rdi], rdi
        pcase   rsi,\
                @@matrip    , .inline.matrip.va,\
                @@matrip.rc , .inline.matrip.va
        jmp    .inline.matrip.arg
   .inline.matrip.va:
        ; --------------------------------------------------
        ; ...                       | ...
        ; --------------------------------------------------
        ; MOV     R13, ACOUNT       | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; ----------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        sub     [.rdi], 10
        sub     [.coshift], 10
   .inline.matrip.arg:
        stdcall code_object, [.cooff], [.coshift]           ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_VAR , .inline.matrip.dvar,\
                OBJ_DOUBLE_CON , .inline.matrip.dcon,\
                OBJ_INT_VAR    , .inline.matrip.ivar,\
                OBJ_INT_CON    , .inline.matrip.icon
        jmp    .error.argument
   .inline.matrip.dvar:
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; double variable (12B)
        ;*PUSH    QWORD [RCX]       | FF31
        ;>
        ; --------------------------------------------------
    $ifdef _SSEX
        @@range 10-2, .error.memory
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0x01100FF2
        mov     [rdi + 04], dword 0x2C0F48F2
        mov     [rdi + 08], word 0x50C0
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ; MOV       RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ;*MOVSD     XMM0, QWORD [RCX] | F20F1001
        ; CVTTSD2SI RAX, XMM0         | F2480F2CC0
        ; PUSH      RAX               | 50
        ;>
        ; --------------------------------------------------
    $else
        @@range 15-2, .error.memory
        mov     rcx, @@__int64                              ; rcx = "int" proc offset
        @@xshl  rdi, 2
        mov     [rdi + 00], dword 0xBA4801DD
        mov     [rdi + 04], rcx
        mov     [rdi + 12], word 0xD2FF
        mov     [rdi + 14], byte 0x50
        @@xshr  rdi, 15
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS
        ;*FLD     QWORD [RCX]       | DD01
        ; MOV     RDX, @@__int64    | 48BA PPPPPPPPPPPPPPPP
        ; CALL    RDX               | FFD2
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
    $end
        sub     [.rdi], 12
        sub     [.coshift], 12
        jmp    .inline.matrip.next
   .inline.matrip.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 FFFFFFFFFFFFFFFF ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rax, [.rdi]
        mov     rcx, [rax - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     rdx, [.rdi]
        mov     [rdx - 09], rax
        ; --------------------------------------------------
        ; MOV     RCX, INT64        | 48B9 FFFFFFFFFFFFFFFF
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        sub     [.rdi], 11
        sub     [.coshift], 11
        jmp    .inline.matrip.next
   .inline.matrip.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 FFFFFFFFFFFFFFFF ; integer variable (12B)
        ; PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        sub     [.rdi], 12
        sub     [.coshift], 12
        jmp    .inline.matrip.next
   .inline.matrip.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 FFFFFFFFFFFFFFFF ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        sub     [.rdi], 11
        sub     [.coshift], 11
;       jmp    .inline.matrip.next
   .inline.matrip.next:
        dec     [.rcx]
        jnz    .inline.matrip.arg
        mov     rsi, [.proc_o]
        mov     rax, [.proc_z]
        jmp    .inline.proc

   .inline.calls:
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;
        ; ...                   |
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;
        ; MOV   R13, ACOUNT     | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; ----------------------------------------------
        ; acount * 10 + 10
        mov     rcx, [.ezx]
        mov     rax, 10
        mul     rcx
        add     rax, 10
        @@xshl  rdi, rax
        ;
        mov     rdx, rdi
        add     rdx, 2
   .inline.calls.push:
        push    qword [rdx]
        add     rdx, 10
        dec     rcx
        jnz    .inline.calls.push
        ;
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;
        ; ...                   |
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;>
        ; ----------------------------------------------
        ; acount * 12
        mov     rcx, [.ezx]
        mov     rax, 12
        mul     rcx
        @@range rax, .error.memory
        ;
        mov     rdx, rdi
   .inline.calls.pop:
        mov     [rdx + 00], word 0xBA48
        pop     qword [rdx + 02]
        mov     [rdx + 10], word 0x12FF
        add     rdx, 12
        dec     rcx
        jnz    .inline.calls.pop
        ;
        @@xshr  rdi, rax
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.rcalls:
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;
        ; ...                   |
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;
        ; MOV   R13, ACOUNT     | 49BD CCCCCCCCCCCCCCCC ; argument count (10B)
        ;>
        ; ----------------------------------------------
        mov     rcx, [.ezx]
        lea     rdx, [rdi - 18]
   .inline.rcalls.push:
        push    qword [rdx]
        sub     rdx, 10
        dec     rcx
        jnz    .inline.rcalls.push
        ; acount * 10 + 10
        mov     rcx, [.ezx]
        mov     rax, 10
        mul     rcx
        add     rax, 10
        @@xshl  rdi, rax
        ;
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;
        ; ...                   |
        ;
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; 12 BYTES
        ; CALL  QWORD [RDX]     | FF12
        ;>
        ; ----------------------------------------------
        ; acount * 12
        mov     rcx, [.ezx]
        mov     rax, 12
        mul     rcx
        @@range rax, .error.memory
        ;
        mov     rdx, rdi
   .inline.rcalls.pop:
        mov     [rdx + 00], word 0xBA48
        pop     qword [rdx + 02]
        mov     [rdx + 10], word 0x12FF
        add     rdx, 12
        dec     rcx
        jnz    .inline.rcalls.pop
        ;
        @@xshr  rdi, rax
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.jump:
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        jmp    .inline.proc

   .inline.jump.2p:
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        mov     [rdi - 20], word 0xB948
        jmp    .inline.proc

   .inline.jump.v:
        mov     rdx, [.ezx]
        dec     rdx
        shl     rdx, 3
        add     [.RSP], rdx
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;?MOV     R13, VALUE        | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; MOV     R11, OFFSET       | 49BB FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV     R13, VALUE        | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     [rdi - 20], word 0xBB49
        jmp    .inline.proc

   .inline.jump.v.2p:
        mov     rdx, [.ezx]
        sub     rdx, 2
        shl     rdx, 3
        add     [.RSP], rdx
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;?MOV     R13, VALUE        | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_ARG_COUNT
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; MOV     R10, OFFSET       | 49BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV     R11, OFFSET       | 49BB FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV     R13, VALUE        | 49BD FFFFFFFFFFFFFFFF ; argument count (10B)
        ;>
        ; --------------------------------------------------
        mov     [rdi - 30], word 0xBA49
        mov     [rdi - 20], word 0xBB49
        jmp    .inline.proc

; ------
   .inline.goto.if.true:
        mov     [.proc], @@goto.if.true.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.false:
        mov     [.proc], @@goto.if.false.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.z:
        mov     [.proc], @@goto.if.z.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.nz:
        mov     [.proc], @@goto.if.nz.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.az:
        mov     [.proc], @@goto.if.az.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.aez:
        mov     [.proc], @@goto.if.aez.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.bz:
        mov     [.proc], @@goto.if.bz.map.index
        jmp    .inline.jump.if_xz
   .inline.goto.if.bez:
        mov     [.proc], @@goto.if.bez.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.true:
        mov     [.proc], @@call.if.true.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.false:
        mov     [.proc], @@call.if.false.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.z:
        mov     [.proc], @@call.if.z.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.nz:
        mov     [.proc], @@call.if.nz.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.az:
        mov     [.proc], @@call.if.az.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.aez:
        mov     [.proc], @@call.if.aez.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.bz:
        mov     [.proc], @@call.if.bz.map.index
        jmp    .inline.jump.if_xz
   .inline.call.if.bez:
        mov     [.proc], @@call.if.bez.map.index
        jmp    .inline.jump.if_xz
; ------
   .inline.jump.if_xz:
;       mov     [.mode], 0
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 BBBBBBBBBBBBBBBB ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 BBBBBBBBBBBBBBBB ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 BBBBBBBBBBBBBBBB ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 BBBBBBBBBBBBBBBB ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.jump.if_xz.dst0,\
                OBJ_DOUBLE_SSE  , .inline.jump.if_xz.dsse,\
                OBJ_DOUBLE_VAR  , .inline.jump.if_xz.dvar,\
                OBJ_DOUBLE_CON  , .inline.jump.if_xz.dcon,\
                OBJ_INT_VAR     , .inline.jump.if_xz.ivar,\
                OBJ_INT_CON     , .inline.jump.if_xz.icon,\
                OBJ_INT_RSP_RAX , .inline.jump.if_xz.irsp.rax
        jmp    .error.argument
        ;
   .inline.jump.if_xz.dst0:
   .inline.jump.if_xz.dsse:
   .inline.jump.if_xz.dvar:
        add     [.RSP], 8
        jmp    .inline.proc
   .inline.jump.if_xz.dcon:
        add     [.RSP], 8
        mov     [.mode], 2
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 BBBBBBBBBBBBBBBB ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 21
        mov     rdx, [rdi + 13]                         ; rdx = label offset
        mov     rcx, [rdi + 02]                         ; rcx = double constant
        mov     [rsp - 8], rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp - 8]                   ; xmm0 = x
        xorpd   xmm5, xmm5                              ; xmm5 = 0
    $else
        fld     qword [rsp - 8]
    $end
        ;
        xor     rcx, rcx
    $ifdef _SSEX
        comisd  xmm0, xmm5                              ; compare x to 0
        ja     .inline.jump.if_xz.dcon..az
        jb     .inline.jump.if_xz.dcon..bz
    $else
        ftst                                            ; compare x to 0
        fstsw   ax
        sahf
        ja     .inline.jump.if_xz.dcon..az
        jb     .inline.jump.if_xz.dcon..bz
    $end
   .inline.jump.if_xz.dcon..z:                          ; rcx = 0
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .inline.jump.if_xz.icon.x
   .inline.jump.if_xz.dcon..az:                         ; rcx = +1
        inc     rcx
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .inline.jump.if_xz.icon.x
   .inline.jump.if_xz.dcon..bz:                         ; rcx = -1
        dec     rcx
    $ifndef _SSEX
        fstp    st0
    $end
        jmp    .inline.jump.if_xz.icon.x
        ;
   .inline.jump.if_xz.icon:
        add     [.RSP], 8
        mov     [.mode], 2
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 BBBBBBBBBBBBBBBB ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 21
        mov     rdx, [rdi + 13]                         ; rdx = label offset
        mov     rcx, [rdi + 02]                         ; rcx = integer constant
   .inline.jump.if_xz.icon.x:
        pcase   rsi,\
                @@goto.if.true  , .inline.jump.if_xz.icon.nz,\
                @@goto.if.false , .inline.jump.if_xz.icon.z,\
                @@goto.if.z     , .inline.jump.if_xz.icon.z,\
                @@goto.if.nz    , .inline.jump.if_xz.icon.nz,\
                @@goto.if.az    , .inline.jump.if_xz.icon.az,\
                @@goto.if.aez   , .inline.jump.if_xz.icon.aez,\
                @@goto.if.bz    , .inline.jump.if_xz.icon.bz,\
                @@goto.if.bez   , .inline.jump.if_xz.icon.bez,\
                @@call.if.true  , .inline.jump.if_xz.icon.nz,\
                @@call.if.false , .inline.jump.if_xz.icon.z,\
                @@call.if.z     , .inline.jump.if_xz.icon.z,\
                @@call.if.nz    , .inline.jump.if_xz.icon.nz,\
                @@call.if.az    , .inline.jump.if_xz.icon.az,\
                @@call.if.aez   , .inline.jump.if_xz.icon.aez,\
                @@call.if.bz    , .inline.jump.if_xz.icon.bz,\
                @@call.if.bez   , .inline.jump.if_xz.icon.bez
        jmp    .error.exit
   .inline.jump.if_xz.icon.z:
        cmp     rcx, 0                                  ; compare x to 0
        je     .inline.jump.if_xz.icon.exec             ; exec if x = 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.nz:
        cmp     rcx, 0                                  ; compare x to 0
        jne    .inline.jump.if_xz.icon.exec             ; exec if x != 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.az:
        cmp     rcx, 0                                  ; compare x to 0
        jg     .inline.jump.if_xz.icon.exec             ; exec if x > 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.aez:
        cmp     rcx, 0                                  ; compare x to 0
        jge    .inline.jump.if_xz.icon.exec             ; exec if x >= 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.bz:
        cmp     rcx, 0                                  ; compare x to 0
        jl     .inline.jump.if_xz.icon.exec             ; exec if x < 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.bez:
        cmp     rcx, 0                                  ; compare x to 0
        jle    .inline.jump.if_xz.icon.exec             ; exec if x <= 0
        jmp    .inline.jump.if_xz.icon.no.exec
   .inline.jump.if_xz.icon.no.exec:
        or      [.rcode], RCODE_FLAG_ZERO_SIZE
        jmp    .exit
   .inline.jump.if_xz.icon.exec:
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.if_xz.proc
        ;
   .inline.jump.if_xz.ivar:
        add     [.RSP], 8
        mov     [.mode], 1
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 BBBBBBBBBBBBBBBB ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; ----------------------------------------------
        mov     rdx, [rdi - 08]                         ; rdx = label offset
        @@xshl  rdi, 12
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 BBBBBBBBBBBBBBBB
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.if_xz.proc
   .inline.jump.if_xz.irsp.rax:
        add     [.RSP], 8
        mov     [.mode], 2
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        mov     rdx, [rdi - 08]                             ; rdx = label offset
        @@xshl  rdi, 14
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        mov     [rdi + 10], dword 0x08C48348
        @@xshr  rdi, 14
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF
        ; ADD     RSP, 8            | 4883C408
        ;>
        ; --------------------------------------------------
        jmp    .inline.jump.if_xz.proc
   .inline.jump.if_xz.proc:
        stdcall map_proc_x3, @x3_jump_procs_if_xz, [.proc], [.mode]
        jmp    .inline.proc

; ------
   .inline.call.ie.true:
        mov     [.proc], @@call.ie.true.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.false:
        mov     [.proc], @@call.ie.false.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.z:
        mov     [.proc], @@call.ie.z.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.nz:
        mov     [.proc], @@call.ie.nz.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.az:
        mov     [.proc], @@call.ie.az.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.aez:
        mov     [.proc], @@call.ie.aez.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.bz:
        mov     [.proc], @@call.ie.bz.map.index
        jmp    .inline.jump.ie_xz
   .inline.call.ie.bez:
        mov     [.proc], @@call.ie.bez.map.index
        jmp    .inline.jump.ie_xz
; ------
   .inline.jump.ie_xz:
;       mov     [.mode], 0
        mov     [.ezx], 0
        mov     [.FPU], 0
        ; --------------------------------------------------
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;?MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        stdcall code_object, [.cooff], -10                  ; ecx = object type
        cmp     ecx, OBJ_LOFFSET
        jne    .error.argument
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 BBBBBBBBBBBBBBBB ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 BBBBBBBBBBBBBBBB ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 BBBBBBBBBBBBBBBB ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 BBBBBBBBBBBBBBBB ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        stdcall code_object, [.cooff], -20                  ; ecx = object type
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.jump.ie_xz.dst0,\
                OBJ_DOUBLE_SSE  , .inline.jump.ie_xz.dsse,\
                OBJ_DOUBLE_VAR  , .inline.jump.ie_xz.dvar,\
                OBJ_DOUBLE_CON  , .inline.jump.ie_xz.dcon,\
                OBJ_INT_VAR     , .inline.jump.ie_xz.ivar,\
                OBJ_INT_CON     , .inline.jump.ie_xz.icon,\
                OBJ_INT_RSP_RAX , .inline.jump.ie_xz.irsp.rax
        jmp    .error.argument
        ;
   .inline.jump.ie_xz.dst0:
   .inline.jump.ie_xz.dsse:
   .inline.jump.ie_xz.dvar:
        add     [.RSP], 8
        jmp    .inline.proc
   .inline.jump.ie_xz.dcon:
        add     [.RSP], 8
        mov     [.mode], 2
        ; ----------------------------------------------
        ;*MOV   RCX, QWORD      | 48B9 BBBBBBBBBBBBBBBB ; double constant (11B)
        ; PUSH  RCX             | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 31
        mov     rax, [rdi + 13]                         ; rax = label offset
        mov     rdx, [rdi + 23]                         ; rdx = label offset
        mov     rcx, [rdi + 02]                         ; rcx = double constant
        mov     [rsp - 8], rcx
    $ifdef _SSEX
        movsd   xmm0, qword [rsp - 8]                   ; xmm0 = x
        xorpd   xmm5, xmm5                              ; xmm5 = 0
    $else
        fld     qword [rsp - 8]
    $end
        mov     [rsp - 8], rax                          ; save rax
        ;
        xor     rcx, rcx
    $ifdef _SSEX
        comisd  xmm0, xmm5                              ; compare x to 0
        ja     .inline.jump.ie_xz.dcon..az
        jb     .inline.jump.ie_xz.dcon..bz
    $else
        ftst                                            ; compare x to 0
        fstsw   ax
        sahf
        ja     .inline.jump.ie_xz.dcon..az
        jb     .inline.jump.ie_xz.dcon..bz
    $end
   .inline.jump.ie_xz.dcon..z:                          ; rcx = 0
    $ifndef _SSEX
        fstp    st0
    $end
        mov     rax, [rsp - 8]                          ; restore rax
        jmp    .inline.jump.ie_xz.icon.x
   .inline.jump.ie_xz.dcon..az:                         ; rcx = +1
        inc     rcx
    $ifndef _SSEX
        fstp    st0
    $end
        mov     rax, [rsp - 8]                          ; restore rax
        jmp    .inline.jump.ie_xz.icon.x
   .inline.jump.ie_xz.dcon..bz:                         ; rcx = -1
        dec     rcx
    $ifndef _SSEX
        fstp    st0
    $end
        mov     rax, [rsp - 8]                          ; restore rax
        jmp    .inline.jump.ie_xz.icon.x
        ;
   .inline.jump.ie_xz.icon:
        add     [.RSP], 8
        mov     [.mode], 2
        ; ----------------------------------------------
        ;*MOV   RAX, VALUE      | 48B8 BBBBBBBBBBBBBBBB ; integer constant (11B)
        ; PUSH  RAX             | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; ----------------------------------------------
        @@xshl  rdi, 31
        mov     rax, [rdi + 13]                         ; rax = label offset
        mov     rdx, [rdi + 23]                         ; rdx = label offset
        mov     rcx, [rdi + 02]                         ; rcx = integer constant
   .inline.jump.ie_xz.icon.x:
        pcase   rsi,\
                @@call.ie.true  , .inline.jump.ie_xz.icon.nz,\
                @@call.ie.false , .inline.jump.ie_xz.icon.z,\
                @@call.ie.z     , .inline.jump.ie_xz.icon.z,\
                @@call.ie.nz    , .inline.jump.ie_xz.icon.nz,\
                @@call.ie.az    , .inline.jump.ie_xz.icon.az,\
                @@call.ie.aez   , .inline.jump.ie_xz.icon.aez,\
                @@call.ie.bz    , .inline.jump.ie_xz.icon.bz,\
                @@call.ie.bez   , .inline.jump.ie_xz.icon.bez
        jmp    .error.exit
   .inline.jump.ie_xz.icon.z:
        cmp     rcx, 0                                  ; compare x to 0
        je     .inline.jump.ie_xz.icon.if.exec          ; exec if x = 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.nz:
        cmp     rcx, 0                                  ; compare x to 0
        jne    .inline.jump.ie_xz.icon.if.exec          ; exec if x != 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.az:
        cmp     rcx, 0                                  ; compare x to 0
        jg     .inline.jump.ie_xz.icon.if.exec          ; exec if x > 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.aez:
        cmp     rcx, 0                                  ; compare x to 0
        jge    .inline.jump.ie_xz.icon.if.exec          ; exec if x >= 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.bz:
        cmp     rcx, 0                                  ; compare x to 0
        jl     .inline.jump.ie_xz.icon.if.exec          ; exec if x < 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.bez:
        cmp     rcx, 0                                  ; compare x to 0
        jle    .inline.jump.ie_xz.icon.if.exec          ; exec if x <= 0
        jmp    .inline.jump.ie_xz.icon.else.exec
   .inline.jump.ie_xz.icon.else.exec:
        mov     rdx, rax
   .inline.jump.ie_xz.icon.if.exec:
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; ----------------------------------------------
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.ie_xz.proc
        ;
   .inline.jump.ie_xz.ivar:
        add     [.RSP], 8
        mov     [.mode], 1
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 BBBBBBBBBBBBBBBB ; integer variable (12B)
        ;*PUSH  QWORD [RAX]     | FF30
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; ----------------------------------------------
        mov     rcx, [rdi - 18]                         ; rcx = label offset
        mov     rdx, [rdi - 08]                         ; rdx = label offset
        @@xshl  rdi, 22
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rcx
        @@xshr  rdi, 20
        ; ----------------------------------------------
        ; MOV   RAX, OFFSET     | 48B8 BBBBBBBBBBBBBBBB
        ;*MOV   RDX, OFFSET     | 48BA FFFFFFFFFFFFFFFF
        ; MOV   RCX, OFFSET     | 48B9 FFFFFFFFFFFFFFFF
        ;>
        ; ----------------------------------------------
        jmp    .inline.jump.ie_xz.proc
   .inline.jump.ie_xz.irsp.rax:
        add     [.RSP], 8
        mov     [.mode], 2
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ; MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF ; label offset (10B)
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 18]                             ; rcx = label offset
        mov     rdx, [rdi - 08]                             ; rdx = label offset
        @@xshl  rdi, 24
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        mov     [rdi + 10], word 0xB948
        mov     [rdi + 12], rcx
        mov     [rdi + 20], dword 0x08C48348
        @@xshr  rdi, 24
        ; --------------------------------------------------
        ; ...                       | ...
        ;*MOV     RDX, OFFSET       | 48BA FFFFFFFFFFFFFFFF
        ; MOV     RCX, OFFSET       | 48B9 FFFFFFFFFFFFFFFF
        ; ADD     RSP, 8            | 4883C408
        ;>
        ; --------------------------------------------------
   .inline.jump.ie_xz.proc:
        stdcall map_proc_x3, @x3_jump_procs_ie_xz, [.proc], [.mode]
        jmp    .inline.proc

   .inline.fstxw:
        ; --------------------------------------------------
        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_INT_VAR , .inline.fstxw.ivar
        jmp    .error.argument
   .inline.fstxw.ivar:
        pcase   rsi,\
                @@fstsw  , .inline.fstsw.ivar,\
                @@fnstsw , .inline.fnstsw.ivar,\
                @@fstef  , .inline.fstef.ivar,\
                @@fnstef , .inline.fnstef.ivar,\
                @@fstcw  , .inline.fstcw.ivar,\
                @@fnstcw , .inline.fnstcw.ivar
        jmp    .error.exit
   .inline.fstsw.ivar:
        mov     rsi, @@_fstsw_io.rax
        mov     rax, @@_fstsw_io.rax.size
        jmp    .inline.fstxw.proc
   .inline.fnstsw.ivar:
        mov     rsi, @@_fnstsw_io.rax
        mov     rax, @@_fnstsw_io.rax.size
        jmp    .inline.fstxw.proc
   .inline.fstef.ivar:
        mov     rsi, @@_fstef_io.rax
        mov     rax, @@_fstef_io.rax.size
        jmp    .inline.fstxw.proc
   .inline.fnstef.ivar:
        mov     rsi, @@_fnstef_io.rax
        mov     rax, @@_fnstef_io.rax.size
        jmp    .inline.fstxw.proc
   .inline.fstcw.ivar:
        mov     rsi, @@_fstcw_io.rax
        mov     rax, @@_fstcw_io.rax.size
        jmp    .inline.fstxw.proc
   .inline.fnstcw.ivar:
        mov     rsi, @@_fnstcw_io.rax
        mov     rax, @@_fnstcw_io.rax.size
        jmp    .inline.fstxw.proc
   .inline.fstxw.proc:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 2
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*                          |
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.fldxw:
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 BBBBBBBBBBBBBBBB ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_CON , .inline.fldxw.dcon,\
                OBJ_INT_VAR    , .inline.fldxw.ivar,\
                OBJ_INT_CON    , .inline.fldxw.icon
        jmp    .error.argument
   .inline.fldxw.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 BBBBBBBBBBBBBBBB ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        @@xshl  rdi, 11
        mov     [rdi + 00], word 0xB848
        mov     [rdi + 02], rax
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RAX, INT64        | 48B8 SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        pcase   rsi,\
                @@fldcw   , .inline.fldcw.dcon,\
                @@fmaske  , .inline.fmaske.dcon,\
                @@fnmaske , .inline.fnmaske.dcon
        jmp    .error.exit
   .inline.fldcw.dcon:
        mov     rsi, @@_fldcw_iv.rax
        mov     rax, @@_fldcw_iv.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fmaske.dcon:
        mov     rsi, @@_fmaske_iv.rax
        mov     rax, @@_fmaske_iv.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fnmaske.dcon:
        mov     rsi, @@_fnmaske_iv.rax
        mov     rax, @@_fnmaske_iv.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fldxw.ivar:
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;*PUSH    QWORD [RAX]       | FF30
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 2
        ; --------------------------------------------------
        ; MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS
        ;*                          |
        ;>
        ; --------------------------------------------------
        pcase   rsi,\
                @@fldcw   , .inline.fldcw.ivar,\
                @@fmaske  , .inline.fmaske.ivar,\
                @@fnmaske , .inline.fnmaske.ivar
        jmp    .error.exit
   .inline.fldcw.ivar:
        mov     rsi, @@_fldcw_io.rax
        mov     rax, @@_fldcw_io.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fmaske.ivar:
        mov     rsi, @@_fmaske_io.rax
        mov     rax, @@_fmaske_io.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fnmaske.ivar:
        mov     rsi, @@_fnmaske_io.rax
        mov     rax, @@_fnmaske_io.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fldxw.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;*PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        @@xshl  rdi, 1
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS
        ;*                          |
        ;>
        ; --------------------------------------------------
        pcase   rsi,\
                @@fldcw   , .inline.fldcw.icon,\
                @@fmaske  , .inline.fmaske.icon,\
                @@fnmaske , .inline.fnmaske.icon
        jmp    .error.exit
   .inline.fldcw.icon:
        mov     rsi, @@_fldcw_iv.rax
        mov     rax, @@_fldcw_iv.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fmaske.icon:
        mov     rsi, @@_fmaske_iv.rax
        mov     rax, @@_fmaske_iv.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fnmaske.icon:
        mov     rsi, @@_fnmaske_iv.rax
        mov     rax, @@_fnmaske_iv.rax.size
        jmp    .inline.fldxw.x.proc
   .inline.fldxw.x.proc:
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.result.set:
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.result.set.dst0,\
                OBJ_DOUBLE_SSE  , .inline.result.set.dsse,\
                OBJ_DOUBLE_VAR  , .inline.result.set.dvar,\
                OBJ_DOUBLE_CON  , .inline.result.set.dcon,\
                OBJ_INT_VAR     , .inline.result.set.ivar,\
                OBJ_INT_CON     , .inline.result.set.icon,\
                OBJ_INT_RSP_RAX , .inline.result.set.irsp.rax
        jmp    .error.argument
   .inline.result.set.dst0:
   .inline.result.set.dsse:
   .inline.result.set.dvar:
   .inline.result.set.dcon:
        mov     rsi, @@.result.set.double
        mov     rax, @@.result.set.double.size
        jmp    .inline.proc
   .inline.result.set.ivar:
   .inline.result.set.icon:
   .inline.result.set.irsp.rax:
        mov     rsi, @@.result.set.int
        mov     rax, @@.result.set.int.size
        jmp    .inline.proc

   .inline.exit:
        push    rax rcx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     rcx rax
        test    rdx, rdx                                    ; rdx = table item offset value
        jz     .error.exit
        lea     rdx, [rdx + citem64.offset]
        test    rdx, rdx                                    ; rdx = offset
        jz     .error.exit
   .inline.exit.proc:
        @@range 10, .error.memory
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.exit.if:
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_CON  , .inline.exit.if.dcon,\
                OBJ_INT_VAR     , .inline.exit.if.ivar,\
                OBJ_INT_CON     , .inline.exit.if.icon,\
                OBJ_INT_RSP_RAX , .inline.exit.if.irsp.rax
        jmp    .error.argument
   .inline.exit.if.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    rax
        mov     rcx, [rdi - 09]                             ; rcx = constant
        stdcall f2i, rcx                                    ; rax = int64 constant
        mov     [rdi - 11], word 0xB848
        mov     [rdi - 09], rax
        mov     [rdi - 01], byte 0x50
        pop     rax
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
   .inline.exit.if.icon:
   .inline.exit.if.ivar:
   .inline.exit.if.irsp.rax:
;       jmp    .inline.exit.if.main:
   .inline.exit.if.main:
        push    rax rcx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     rcx rax
        test    rdx, rdx                                    ; rdx = table item offset value
        jz     .error.exit
        lea     rdx, [rdx + citem64.offset]
        test    rdx, rdx                                    ; rdx = offset
        jz     .error.exit
   .inline.exit.if.proc:
        @@range 10, .error.memory
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.return:
        push    rcx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     rcx
        test    rdx, rdx                                    ; rdx = table item offset value
        jz     .error.exit
        lea     rdx, [rdx + citem64.offset]
        test    rdx, rdx                                    ; rdx = offset
        jz     .error.exit
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.return.dst0,\
                OBJ_DOUBLE_SSE  , .inline.return.dsse,\
                OBJ_DOUBLE_VAR  , .inline.return.dvar,\
                OBJ_DOUBLE_CON  , .inline.return.dcon,\
                OBJ_INT_VAR     , .inline.return.ivar,\
                OBJ_INT_CON     , .inline.return.icon,\
                OBJ_INT_RSP_RAX , .inline.return.irsp.rax
        jmp    .error.argument
   .inline.return.dst0:
   .inline.return.dsse:
   .inline.return.dvar:
   .inline.return.dcon:
        mov     rsi, @@.return.double
        mov     rax, @@.return.double.size
        jmp    .inline.return.proc
   .inline.return.ivar:
   .inline.return.icon:
   .inline.return.irsp.rax:
        mov     rsi, @@.return.int
        mov     rax, @@.return.int.size
;       jmp    .inline.return.proc
   .inline.return.proc:
        @@range 10, .error.memory
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 8
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.return.if:
        push    rcx
        stdcall rtaget, [.rdata], ??exit.name, ??exit.name.size
        pop     rcx
        test    rdx, rdx                                    ; rdx = table item offset value
        jz     .error.exit
        lea     rdx, [rdx + citem64.offset]
        test    rdx, rdx                                    ; rdx = offset
        jz     .error.exit
        ; --------------------------------------------------
        ; ...                       | ...
        ;?FSTP    QWORD [RSP]       | DD1C24                ; double ST0 (3B)

        ; ...                       | ...
        ;?MOVSD   QWORD [RSP], XMM0 | F20F110424            ; double SSE (5B)

        ;?MOV     RCX, OFFSET       | 48B9 SSSSSSSSSSSSSSSS ; double variable (12B)
        ;?PUSH    QWORD [RCX]       | FF31

        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, OFFSET       | 48B8 SSSSSSSSSSSSSSSS ; integer variable (12B)
        ;?PUSH    QWORD [RAX]       | FF30

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ; ...                       | ...
        ;?MOV     [RSP], RAX        | 48890424              ; integer RSP RAX (4B)
        ;>
        ; --------------------------------------------------
        case    ecx,\
                OBJ_DOUBLE_ST0  , .inline.return.if.dst0,\
                OBJ_DOUBLE_SSE  , .inline.return.if.dsse,\
                OBJ_DOUBLE_VAR  , .inline.return.if.dvar,\
                OBJ_DOUBLE_CON  , .inline.return.if.dcon,\
                OBJ_INT_VAR     , .inline.return.if.ivar,\
                OBJ_INT_CON     , .inline.return.if.icon,\
                OBJ_INT_RSP_RAX , .inline.return.if.irsp.rax
        jmp    .error.argument
   .inline.return.if.dst0:
   .inline.return.if.dsse:
   .inline.return.if.dvar:
   .inline.return.if.dcon:
        pcase   rsi,\
                @@.returnv.if.true  , .inline.return.double.if.true,\
                @@.returnv.if.false , .inline.return.double.if.false
        jmp    .error.exit
   .inline.return.double.if.true:
        mov     rsi, @@.return.double.if.true
        mov     rax, @@.return.double.if.true.size
        jmp    .inline.return.if.proc
   .inline.return.double.if.false:
        mov     rsi, @@.return.double.if.false
        mov     rax, @@.return.double.if.false.size
        jmp    .inline.return.if.proc
   .inline.return.if.ivar:
   .inline.return.if.icon:
   .inline.return.if.irsp.rax:
        pcase   rsi,\
                @@.returnv.if.true  , .inline.return.int.if.true,\
                @@.returnv.if.false , .inline.return.int.if.false
        jmp    .error.exit
   .inline.return.int.if.true:
        mov     rsi, @@.return.int.if.true
        mov     rax, @@.return.int.if.true.size
        jmp    .inline.return.if.proc
   .inline.return.int.if.false:
        mov     rsi, @@.return.int.if.false
        mov     rax, @@.return.int.if.false.size
;       jmp    .inline.return.if.proc
   .inline.return.if.proc:
        @@range 10, .error.memory
        mov     [rdi + 00], word 0xBA48
        mov     [rdi + 02], rdx
        @@xshr  rdi, 10
        ; --------------------------------------------------
        ;*MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS
        ;>
        ; --------------------------------------------------
        add     [.RSP], 16
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.retn:
        @@range 1, .error.memory
        mov     [rdi + 00], byte 0xC3
        @@xshr  rdi, 1
        ; --------------------------------------------------
        ;*RETN                      | C3
        ;>
        ; --------------------------------------------------
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .done

   .inline.arg.filter:
        mov     [.ezx], 0
;       mov     [.FPU], 0
        jmp    .inline.proc.exit

   .inline.directive:
        mov     [.ezx], 0
        mov     [.FPU], 0
        or      [.rcode], RCODE_FLAG_ZERO_SIZE
        jmp    .inline.proc

   .inline.asm.instruction:
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.fpu.instruction:
        mov     [.ezx], 0
        mov     [.FPU], 0
        jmp    .inline.proc

   .inline.proc.ezx.dec:
        dec     [.ezx]
        jmp    .inline.proc

   .inline.proc.ezx.0:
        mov     [.ezx], 0
        jmp    .inline.proc

   .inline.proc.nr:
        mov     [.FPU], 0
;       jmp    .inline.proc

   .inline.proc:
        lea     rcx, [rax - 1]                              ; exclude RETN (0xC3) instruction
        @@bound rcx, .error.memory
        cld
        rep     movsb
        jmp    .done

   .inline.proc.exit:
        lea     rcx, [rax - 1]                              ; exclude RETN (0xC3) instruction
        @@bound rcx, .error.memory
        cld
        rep     movsb
        jmp    .exit

   .call.xcon.result:
        mov     [.frecount], 1
        mov     cx, [.RET]                                  ; cl = return type (00001111)
        case    cl,\
                1, .call.xcon.result.I1,\
                2, .call.xcon.result.I2,\
                4, .call.xcon.result.I4,\
                8, .call.xcon.result.I8
        case    cl,\
                1001B, .call.xcon.result.D2,\
                1010B, .call.xcon.result.D3,\
                1100B, .call.xcon.result.D4
   .call.xcon.result.ST0:
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        movsd   qword [rsp - 8], xmm0
        fld     qword [rsp - 8]
        jmp    .inline.st0.dcon.test
    $end
   .call.xcon.result.I1:
        movsx   rax, al
        jmp    .inline.rax.icon
   .call.xcon.result.I2:
        movsx   rax, ax
        jmp    .inline.rax.icon
   .call.xcon.result.I4:
        movsxd  rax, eax
        jmp    .inline.rax.icon
   .call.xcon.result.I8:
        jmp    .inline.rax.icon
   .call.xcon.result.D2:
        mov     [.frecount], 2
        sub     [.RSP], 8
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end
   .call.xcon.result.D3:
        mov     [.frecount], 3
        sub     [.RSP], 16
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end
   .call.xcon.result.D4:
        mov     [.frecount], 4
        sub     [.RSP], 24
    $ifdef _SSEX
        jmp    .inline.sse.dcon.test
    $else
        jmp    .inline.st0.dcon.test
    $end

   .call:                                                   ; external procedure call
        inc     [.EPC]                                      ; increase external procedure count
        mov     cx, [rdx + fitem64.cosize]                  ; cx = function flags
        mov     rax, [.ezx]                                 ; ax = function actual argument count
        ;
        mov     [.RET], cx
        shr     [.RET], 8
        and     [.RET], 0x000F                              ; byte [.RET] = return type (00001111)
   .call.E.stack:
        cmp     ax, 0
        je     .call.E.stack.0
        cmp     ax, 1
        je     .call.E.stack.1
        cmp     ax, 2
        je     .call.E.stack.2
        cmp     ax, 3
        je     .call.E.stack.3
        jmp    .call.E.stack.4p
        ;
   .call.E.stack.0:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.E.stack.0.main
        cmp     [.dynamic], 0
        jnz    .call.E.stack.0.main
   .call.E.stack.0.call:
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        call    rsi
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        jmp    .call.xcon.result
   .call.E.stack.0.main:
        mov     r10, 32
        sub     [.RSP], r10
        test    [.RSP], 0x0F                                ; 16-byte stack align
        jz     .call.E.stack.0.out
        inc     [.SAF]                                      ; set stack align flag
        add     r10, 8
        sub     [.RSP], 8
   .call.E.stack.0.out:
        ; ----------------------------------------------
        ;+ADD   RSP, -32         | 4883C4 E0
        ; SUB   RSP, +32         | 4883EC 20
        ; ----------------------------------------------
        @@bound 4, .error.memory
        @copy.d rdi, 0x00C48348, 3
        mov     r11, r10
        neg     r11
        @copy.b rdi, r11b
;       @copy.d rdi, 0x00EC8348, 3
;       @copy.b rdi, r10b
        jmp    .call.E.stack.out
        ;
   .call.E.stack.1:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.E.stack.1.main
        cmp     [.dynamic], 0
        jnz    .call.E.stack.1.main
   .call.E.stack.1.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.E.stack.1.xcon?.out                    ; bypass void
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.1.dcon,\
                OBJ_INT_CON    , .call.E.stack.1.icon,\
                OBJ_STRING_CON , .call.E.stack.1.icon
        jmp    .call.E.stack.1.xcon?.out
   .call.E.stack.1.icon:
        ; --------------------------------------------------
        ;*MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     [rsp], rcx
        ;
        call    rsi                                         ; rcx = argument #1 : integer
        ;
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .call.xcon.result
   .call.E.stack.1.dcon:
        ; --------------------------------------------------
        ;*MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     [rsp], rcx
        movsd   xmm0, qword [rsp]                           ; xmm0 = rcx
        ;
        call    rsi                                         ; xmm0 = argument #1 : double
        ;
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11
        add     [.RSP], 8
        jmp    .call.xcon.result
   .call.E.stack.1.xcon?.out:
        ;
   .call.E.stack.1.main:
        mov     r10, 24
        sub     [.RSP], r10
        test    [.RSP], 0x0F                                ; 16-byte stack align
        jz     .call.E.stack.1.out
        inc     [.SAF]                                      ; set stack align flag
        add     r10, 8
        sub     [.RSP], 8
   .call.E.stack.1.out:
        ; ----------------------------------------------
        ; ADD   RSP, -24         | 4883EC 18
        ; SUB   RSP, +24         | 4883C4 E8
        ;
        ; MOV   RAX, [RSP+24]    | 488B4424 18
        ; MOV   [RSP+00], RAX    | 48890424
        ; ----------------------------------------------
        jmp    .call.E.stack.x
        ;
   .call.E.stack.2:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.E.stack.2.main
        cmp     [.dynamic], 0
        jnz    .call.E.stack.2.main
   .call.E.stack.2.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.E.stack.2.xcon?.out                    ; bypass void
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.2.dcon,\
                OBJ_INT_CON    , .call.E.stack.2.icon,\
                OBJ_STRING_CON , .call.E.stack.2.icon
        jmp    .call.E.stack.2.xcon?.out
   .call.E.stack.2.dcon:
        push    rcx rdx
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.2.dcon.dcon,\
                OBJ_INT_CON    , .call.E.stack.2.dcon.icon,\
                OBJ_STRING_CON , .call.E.stack.2.dcon.icon
        jmp    .call.E.stack.2.xcon?.out
   .call.E.stack.2.icon:
        push    rcx rdx
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.2.icon.dcon,\
                OBJ_INT_CON    , .call.E.stack.2.icon.icon,\
                OBJ_STRING_CON , .call.E.stack.2.icon.icon
        jmp    .call.E.stack.2.xcon?.out
        ;
   .call.E.stack.2.dcon.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        movsd   xmm0, qword [rsp]                           ; xmm0 = rcx
        movsd   xmm1, qword [rsp + 8]                       ; xmm1 = rdx
        ;
        call    rsi                                         ; xmm0 = argument #1 : double
        ;                                                   ; xmm1 = argument #2 : double
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        jmp    .call.xcon.result
        ;
   .call.E.stack.2.dcon.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        movsd   xmm0, qword [rsp]                           ; xmm0 = rcx
        ;
        call    rsi                                         ; xmm0 = argument #1 : double
        ;                                                   ; rdx  = argument #2 : integer
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        jmp    .call.xcon.result
        ;
   .call.E.stack.2.icon.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        movsd   xmm1, qword [rsp + 8]                       ; xmm1 = rdx
        ;
        call    rsi                                         ; rcx  = argument #1 : integer
        ;                                                   ; xmm1 = argument #2 : double
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        jmp    .call.xcon.result
        ;
   .call.E.stack.2.icon.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        ;
        call    rsi                                         ; rcx = argument #1 : integer
        ;                                                   ; rdx = argument #2 : integer
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11
        add     [.RSP], 8+8
        jmp    .call.xcon.result
   .call.E.stack.2.xcon?.out:
        ;
   .call.E.stack.2.main:
        mov     r10, 16
        sub     [.RSP], r10
        test    [.RSP], 0x0F                                ; 16-byte stack align
        jz     .call.E.stack.2.out
        inc     [.SAF]                                      ; set stack align flag
        add     r10, 8
        sub     [.RSP], 8
   .call.E.stack.2.out:
        ; ----------------------------------------------
        ; ADD   RSP, -16         | 4883C4 F0
        ; SUB   RSP, +16         | 4883EC 10
        ;
        ; MOV   RAX, [RSP+16+00] | 488B4424 10
        ; MOV   [RSP+00], RAX    | 48890424
        ;
        ; MOV   RAX, [RSP+16+08] | 488B4424 18
        ; MOV   [RSP+00+08], RAX | 48894424 08
        ; ----------------------------------------------
        jmp    .call.E.stack.x
        ;
   .call.E.stack.3:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.E.stack.3.main
        cmp     [.dynamic], 0
        jnz    .call.E.stack.3.main
   .call.E.stack.3.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.E.stack.3.xcon?.out                    ; bypass void
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.3.dcon,\
                OBJ_INT_CON    , .call.E.stack.3.icon
        jmp    .call.E.stack.3.xcon?.out
        ;
   .call.E.stack.3.dcon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.3.dcon.dcon
        jmp    .call.E.stack.3.xcon?.out
   .call.E.stack.3.dcon.dcon:
        push    rcx rdx
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.3.dcon.dcon.dcon
        jmp    .call.E.stack.3.xcon?.out
        ;
   .call.E.stack.3.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_INT_CON , .call.E.stack.3.icon.icon
        jmp    .call.E.stack.3.xcon?.out
   .call.E.stack.3.icon.icon:
        push    rcx rdx
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_INT_CON , .call.E.stack.3.icon.icon.icon
        jmp    .call.E.stack.3.xcon?.out
        ;
   .call.E.stack.3.dcon.dcon.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     r8, [rdi - 31]                              ; r8  = constant #3
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        mov     [rsp + 16], r8
        movsd   xmm0, qword [rsp]                           ; xmm0 = rcx
        movsd   xmm1, qword [rsp + 8]                       ; xmm1 = rdx
        movsd   xmm2, qword [rsp + 16]                      ; xmm2 = r8
        ;
        call    rsi                                         ; xmm0 = argument #1 : double
        ;                                                   ; xmm1 = argument #2 : double
        ;                                                   ; xmm2 = argument #3 : double
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11+11
        add     [.RSP], 8+8+8
        jmp    .call.xcon.result
        ;
   .call.E.stack.3.icon.icon.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     r8, [rdi - 31]                              ; r8  = constant #3
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        mov     [rsp + 16], r8
        ;
        call    rsi                                         ; rcx = argument #1 : integer
        ;                                                   ; rdx = argument #2 : integer
        ;                                                   ; r8  = argument #3 : integer
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11+11
        add     [.RSP], 8+8+8
        jmp    .call.xcon.result
   .call.E.stack.3.xcon?.out:
        ;
   .call.E.stack.3.main:
        mov     r10, 8
        sub     [.RSP], r10
        test    [.RSP], 0x0F                                ; 16-byte stack align
        jz     .call.E.stack.3.out
        inc     [.SAF]                                      ; set stack align flag
        add     r10, 8
        sub     [.RSP], 8
   .call.E.stack.3.out:
        ; ----------------------------------------------
        ; ADD   RSP, -08         | 4883C4 F8
        ; SUB   RSP, +08         | 4883EC 08
        ;
        ; MOV   RAX, [RSP+08+00] | 488B4424 08
        ; MOV   [RSP+00], RAX    | 48890424
        ;
        ; MOV   RAX, [RSP+08+08] | 488B4424 10
        ; MOV   [RSP+00+08], RAX | 48894424 08
        ; MOV   RAX, [RSP+08+16] | 488B4424 18
        ; MOV   [RSP+00+16], RAX | 48894424 10
        ; ----------------------------------------------
        jmp    .call.E.stack.x
        ;
   .call.E.stack.4p:
        cmp     ax, 4
        jne    .call.E.stack.4p.main
   .call.E.stack.4:
        test    [sop], SIC_OPT_FLAG_NO_ECALC
        jnz    .call.E.stack.4p.main
        cmp     [.dynamic], 0
        jnz    .call.E.stack.4p.main
   .call.E.stack.4.xcon?:
        cmp     byte [.RET], 0x0F
        je     .call.E.stack.4.xcon?.out                    ; bypass void
        ; --------------------------------------------------
        ; code before function call
        ; --------------------------------------------------
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ;?MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ;?PUSH    RCX               | 51

        ;?MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ;?PUSH    RAX               | 50

        ;?MOV     RDX, VALUE        | 48BA SSSSSSSSSSSSSSSS ; string constant (11B)
        ;?PUSH    RDX               | 52
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], 0                    ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.4.dcon,\
                OBJ_INT_CON    , .call.E.stack.4.icon
        jmp    .call.E.stack.4.xcon?.out
        ;
   .call.E.stack.4.dcon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.4.dcon.dcon
        jmp    .call.E.stack.4.xcon?.out
   .call.E.stack.4.dcon.dcon:
        push    rcx rdx
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.4.dcon.dcon.dcon
        jmp    .call.E.stack.4.xcon?.out
   .call.E.stack.4.dcon.dcon.dcon:
        push    rcx rdx
        stdcall code_object, [.cooff], -33                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_DOUBLE_CON , .call.E.stack.4.dcon.dcon.dcon.dcon
        jmp    .call.E.stack.4.xcon?.out
        ;
   .call.E.stack.4.icon:
        ; --------------------------------------------------
        ; ...
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    rcx rdx
        stdcall code_object, [.cooff], -11                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_INT_CON , .call.E.stack.4.icon.icon
        jmp    .call.E.stack.4.xcon?.out
   .call.E.stack.4.icon.icon:
        push    rcx rdx
        stdcall code_object, [.cooff], -22                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_INT_CON , .call.E.stack.4.icon.icon.icon
        jmp    .call.E.stack.4.xcon?.out
   .call.E.stack.4.icon.icon.icon:
        push    rcx rdx
        stdcall code_object, [.cooff], -33                  ; ecx = object type
        mov     [.OBJ], ecx
        pop     rdx rcx
        case    [.OBJ],\
                OBJ_INT_CON , .call.E.stack.4.icon.icon.icon.icon
        jmp    .call.E.stack.4.xcon?.out
        ;
   .call.E.stack.4.dcon.dcon.dcon.dcon:
        ; --------------------------------------------------
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RCX, QWORD        | 48B9 SSSSSSSSSSSSSSSS ; double constant (11B)
        ; PUSH    RCX               | 51
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     r8, [rdi - 31]                              ; r8  = constant #3
        mov     r9, [rdi - 42]                              ; r9  = constant #4
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        mov     [rsp + 16], r8
        mov     [rsp + 24], r9
        movsd   xmm0, qword [rsp]                           ; xmm0 = rcx
        movsd   xmm1, qword [rsp + 8]                       ; xmm1 = rdx
        movsd   xmm2, qword [rsp + 16]                      ; xmm2 = r8
        movsd   xmm3, qword [rsp + 24]                      ; xmm3 = r9
        ;
        call    rsi                                         ; xmm0 = argument #1 : double
        ;                                                   ; xmm1 = argument #2 : double
        ;                                                   ; xmm2 = argument #3 : double
        ;                                                   ; xmm3 = argument #4 : double
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11+11+11
        add     [.RSP], 8+8+8+8
        jmp    .call.xcon.result
        ;
   .call.E.stack.4.icon.icon.icon.icon:
        ; --------------------------------------------------
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ; MOV     RAX, VALUE        | 48B8 SSSSSSSSSSSSSSSS ; integer constant (11B)
        ; PUSH    RAX               | 50
        ;>
        ; --------------------------------------------------
        push    0                                           ; x64 stack align
        test    spl, 0x0F
        jz      @F
        push    8
    @@:
        sub     rsp, 0x20                                   ; allocate 32 bytes of "shadow space"
        mov     rcx, [rdi - 09]                             ; rcx = constant #1
        mov     rdx, [rdi - 20]                             ; rdx = constant #2
        mov     r8, [rdi - 31]                              ; r8  = constant #3
        mov     r9, [rdi - 42]                              ; r9  = constant #4
        mov     [rsp], rcx
        mov     [rsp + 8], rdx
        mov     [rsp + 16], r8
        mov     [rsp + 24], r9
        ;
        call    rsi                                         ; rdx = argument #1 : integer
        ;                                                   ; rcx = argument #2 : integer
        ;                                                   ; r8  = argument #3 : integer
        ;                                                   ; r9  = argument #4 : integer
        add     rsp, 0x20
        pop     rcx                                         ; x64 stack align
        test    ecx, ecx
        jz      @F
        pop     rcx
    @@:
        @@xshl  rdi, 11+11+11+11
        add     [.RSP], 8+8+8+8
        jmp    .call.xcon.result
   .call.E.stack.4.xcon?.out:
        ;
   .call.E.stack.4p.main:
        xor     r10, r10
;       sub     [.RSP], r10
        test    [.RSP], 0x0F                                ; 16-byte stack align
        jz     .call.E.stack.4.out
        inc     [.SAF]                                      ; set stack align flag
        add     r10, 8
        sub     [.RSP], 8
   .call.E.stack.4.out:
;       jmp    .call.E.stack.x

   .call.E.stack.x:
        ; -> r10 = current RSP delta
   .call.E.stack.x.enter:
        test    r10, r10
        jz     .call.E.stack.x.P1
        ;
        @@bound 4, .error.memory
        ; ----------------------------------------------
        ; ADD   RSP, -??         | 4883C4 ??
        ; SUB   RSP, +??         | 4883EC ??
        ; ----------------------------------------------
        @copy.d rdi, 0x00C48348, 3
        mov     r11, r10
        neg     r11
        @copy.b rdi, r11b
;       @copy.d rdi, 0x00EC8348, 3
;       @copy.b rdi, r10b

   .call.E.stack.x.P1:
        inc     [.P.count]
    ; ----------------
   .call.p1:
        test    cl, 00000001b
        jz     .call.p1.float
   .call.p1.int:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p1.int.RSP.B
   .call.p1.int.RSP.D:
        ; ----------------------------------------------
        ; MOV   RCX, QWORD [RSP+FF] | 488B8C24 FFFFFFFF
        ; ----------------------------------------------
        @@bound 8, .error.memory
        mov     [rdi + 0], dword 0x248C8B48
        mov     [rdi + 4], r10d
        add     rdi, 8
        jmp    .call.p1.out
   .call.p1.int.RSP.B:
        test    r10d, r10d
        jz     .call.p1.int.RSP.Z
        ; ----------------------------------------------
        ; MOV   RCX, QWORD [RSP+FF] | 488B4C24 FF
        ; ----------------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x244C8B48
        mov     [rdi + 4], r10b
        add     rdi, 5
        jmp    .call.p1.out
   .call.p1.int.RSP.Z:
        ; ----------------------------------------------
        ; MOV   RCX, QWORD [RSP] | 488B0C24
        ; ----------------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 0], dword 0x240C8B48
        add     rdi, 4
        jmp    .call.p1.out
   .call.p1.float:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p1.float.RSP.B
   .call.p1.float.RSP.D:
        ; ----------------------------------------------
        ; MOVSD XMM0, QWORD [RSP+FF] | F20F1084 24 FFFFFFFF
        ; ----------------------------------------------
        @@bound 9, .error.memory
        mov     [rdi + 0], dword 0x84100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10d
        add     rdi, 9
        jmp    .call.p1.out
   .call.p1.float.RSP.B:
        test    r10d, r10d
        jz     .call.p1.float.RSP.Z
        ; ----------------------------------------------
        ; MOVSD XMM0, QWORD [RSP+FF] | F20F1044 24 FF
        ; ----------------------------------------------
        @@bound 6, .error.memory
        mov     [rdi + 0], dword 0x44100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], byte r10b
        add     rdi, 6
        jmp    .call.p1.out
   .call.p1.float.RSP.Z:
        ; ----------------------------------------------
        ; MOVSD XMM0, QWORD [RSP] | F20F1004 24
        ; ----------------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x04100FF2
        mov     [rdi + 4], byte 0x24
        add     rdi, 5
;       jmp    .call.p1.out
   .call.p1.out:
    ; ----------------

        movzx   r11, ax
        dec     r11                             ; r11 = argument count - 1
        jz     .call.E.stack.out

        mov     r12, 8                          ; r12 = 8
        xor     r14, r14                        ; r14 = 0
   .call.E.stack.x.loop:
        add     r10, r12
        add     r14, r12

        inc     [.P.count]
        cmp     [.P.count], 2
        je     .call.E.stack.x.P2
        cmp     [.P.count], 3
        je     .call.E.stack.x.P3
        cmp     [.P.count], 4
        je     .call.E.stack.x.P4
        jmp    .call.E.stack.x.rax

   .call.E.stack.x.P2:
    ; ----------------
   .call.p2:
        test    cl, 00000010b
        jz     .call.p2.float
   .call.p2.int:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p2.int.RSP.B
   .call.p2.int.RSP.D:
        ; ----------------------------------------------
        ; MOV   RDX, QWORD [RSP+FF] | 488B9424 FFFFFFFF
        ; ----------------------------------------------
        @@bound 8, .error.memory
        mov     [rdi + 0], dword 0x24948B48
        mov     [rdi + 4], r10d
        add     rdi, 8
        jmp    .call.p2.out
   .call.p2.int.RSP.B:
        ; ----------------------------------------------
        ; MOV   RDX, QWORD [RSP+FF] | 488B5424 FF
        ; ----------------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x24548B48
        mov     [rdi + 4], r10b
        add     rdi, 5
        jmp    .call.p2.out
   .call.p2.float:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p2.float.RSP.B
   .call.p2.float.RSP.D:
        ; ----------------------------------------------
        ; MOVSD XMM1, QWORD [RSP+FF] | F20F108C 24 FFFFFFFF
        ; ----------------------------------------------
        @@bound 9, .error.memory
        mov     [rdi + 0], dword 0x8C100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10d
        add     rdi, 9
        jmp    .call.p2.out
   .call.p2.float.RSP.B:
        ; ----------------------------------------------
        ; MOVSD XMM1, QWORD [RSP+FF] | F20F104C 24 FF
        ; ----------------------------------------------
        @@bound 6, .error.memory
        mov     [rdi + 0], dword 0x4C100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10b
        add     rdi, 6
;       jmp    .call.p2.out
   .call.p2.out:
    ; ----------------
        jmp    .call.E.stack.x.next

   .call.E.stack.x.P3:
    ; ----------------
   .call.p3:
        test    cl, 00000100b
        jz     .call.p3.float
   .call.p3.int:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p3.int.RSP.B
   .call.p3.int.RSP.D:
        ; ----------------------------------------------
        ; MOV   R8, QWORD [RSP+FF] | 4C8B8424 FFFFFFFF
        ; ----------------------------------------------
        @@bound 8, .error.memory
        mov     [rdi + 0], dword 0x24848B4C
        mov     [rdi + 4], r10d
        add     rdi, 8
        jmp    .call.p3.out
   .call.p3.int.RSP.B:
        ; ----------------------------------------------
        ; MOV   R8, QWORD [RSP+FF] | 4C8B4424 FF
        ; ----------------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x24448B4C
        mov     [rdi + 4], r10b
        add     rdi, 5
        jmp    .call.p3.out
   .call.p3.float:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p3.float.RSP.B
   .call.p3.float.RSP.D:
        ; ----------------------------------------------
        ; MOVSD XMM2, QWORD [RSP+FF] | F20F1094 24 FFFFFFFF
        ; ----------------------------------------------
        @@bound 9, .error.memory
        mov     [rdi + 0], dword 0x94100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10d
        add     rdi, 9
        jmp    .call.p3.out
   .call.p3.float.RSP.B:
        ; ----------------------------------------------
        ; MOVSD XMM2, QWORD [RSP+FF] | F20F1054 24 FF
        ; ----------------------------------------------
        @@bound 6, .error.memory
        mov     [rdi + 0], dword 0x54100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10b
        add     rdi, 6
;       jmp    .call.p3.out
   .call.p3.out:
    ; ----------------
        jmp    .call.E.stack.x.next

   .call.E.stack.x.P4:
    ; ----------------
   .call.p4:
        test    cl, 00001000b
        jz     .call.p4.float
   .call.p4.int:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p4.int.RSP.B
   .call.p4.int.RSP.D:
        ; ----------------------------------------------
        ; MOV   R9, QWORD [RSP+FF] | 4C8B8C24 FFFFFFFF
        ; ----------------------------------------------
        @@bound 8, .error.memory
        mov     [rdi + 0], dword 0x248C8B4C
        mov     [rdi + 4], r10d
        add     rdi, 8
        jmp    .call.p4.out
   .call.p4.int.RSP.B:
        ; ----------------------------------------------
        ; MOV   R9, QWORD [RSP+FF] | 4C8B4C24 FF
        ; ----------------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x244C8B4C
        mov     [rdi + 4], r10b
        add     rdi, 5
        jmp    .call.p4.out
   .call.p4.float:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.p4.float.RSP.B
   .call.p4.float.RSP.D:
        ; ----------------------------------------------
        ; MOVSD XMM3, QWORD [RSP+FF] | F20F109C 24 FFFFFFFF
        ; ----------------------------------------------
        @@bound 9, .error.memory
        mov     [rdi + 0], dword 0x9C100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10d
        add     rdi, 9
        jmp    .call.p4.out
   .call.p4.float.RSP.B:
        ; ----------------------------------------------
        ; MOVSD XMM3, QWORD [RSP+FF] | F20F105C 24 FF
        ; ----------------------------------------------
        @@bound 6, .error.memory
        mov     [rdi + 0], dword 0x5C100FF2
        mov     [rdi + 4], byte 0x24
        mov     [rdi + 5], r10b
        add     rdi, 6
;       jmp    .call.p4.out
   .call.p4.out:
    ; ----------------
        jmp    .call.E.stack.x.next

   .call.E.stack.x.rax:
        test    r10d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.E.stack.x.rax.byte
   .call.E.stack.x.rax.dword:
        ; ----------------------------------------------
        ; MOV RAX, [RSP+????????] | 488B8424 ????????
        ; ----------------------------------------------
        @@bound 8, .error.memory
        @copy.d rdi, 0x24848B48
        @copy.d rdi, r10d
        jmp    .call.E.stack.x.rax.out
   .call.E.stack.x.rax.byte:
        ; ----------------------------------------------
        ; MOV RAX, [RSP+??]       | 488B4424 ??
        ; ----------------------------------------------
        @@bound 5, .error.memory
        @copy.d rdi, 0x24448B48
        @copy.b rdi, r10b
   .call.E.stack.x.rax.out:

   .call.E.stack.x.rsp:
        test    r14d, 0xFFFFFF80                ; .... 1000 0000
        jz     .call.E.stack.x.rsp.byte
   .call.E.stack.x.rsp.dword:
        ; ----------------------------------------------
        ; MOV [RSP+????????], RAX | 48898424 ????????
        ; ----------------------------------------------
        @@bound 8, .error.memory
        @copy.d rdi, 0x24848948
        @copy.d rdi, r14d
        jmp    .call.E.stack.x.rsp.out
   .call.E.stack.x.rsp.byte:
        ; ----------------------------------------------
        ; MOV [RSP+??], RAX       | 48894424 ??
        ; ----------------------------------------------
        @@bound 5, .error.memory
        @copy.d rdi, 0x24448948
        @copy.b rdi, r14b
   .call.E.stack.x.rsp.out:

   .call.E.stack.x.next:
        dec     r11
        jnz    .call.E.stack.x.loop

   .call.E.stack.out:

   .call.enter:
        ; ------------------------------------------------------
        ; MOV   RAX, <OFFSET>        | 48B8 8877665544332211
        ; CALL  RAX                  | FFD0
        ; ------------------------------------------------------
        @@bound 12, .error.memory
        mov     rcx, [rdx + fitem64.offset]     ; rcx = function entry offset
        mov     [rdi + 00], word 0xB848         ; near, absolute indirect function call
        mov     [rdi + 02], qword rcx
        mov     [rdi + 10], word 0xD0FF
        add     rdi, 12
    ; ----------------
   .call.L.stack:
        cmp     ax, 0
        je     .call.L.stack.0
        cmp     ax, 1
        je     .call.L.stack.1
        cmp     ax, 2
        je     .call.L.stack.2
        cmp     ax, 3
        je     .call.L.stack.3
        jmp    .call.L.stack.4p
   .call.L.stack.0:
        ; ----------------------------------------------
        ; ADD RSP, +32  | 4883C4 20
        ; ----------------------------------------------
        add     r15, 32
        cmp     [.SAF], 0
        jz      @F
        add     r15, 8
    @@:
        jmp    .call.L.stack.out
   .call.L.stack.1:
        ; ----------------------------------------------
        ; ADD RSP, +24  | 4883C4 18
        ; ----------------------------------------------
        add     r15, 24
        cmp     [.SAF], 0
        jz      @F
        add     r15, 8
    @@:
        jmp    .call.L.stack.out
   .call.L.stack.2:
        ; ----------------------------------------------
        ; ADD RSP, +16  | 4883C4 10
        ; ----------------------------------------------
        add     r15, 16
        cmp     [.SAF], 0
        jz      @F
        add     r15, 8
    @@:
        jmp    .call.L.stack.out
   .call.L.stack.3:
        ; ----------------------------------------------
        ; ADD RSP, +08  | 4883C4 08
        ; ----------------------------------------------
        add     r15, 8
        cmp     [.SAF], 0
        jz      @F
        add     r15, 8
    @@:
        jmp    .call.L.stack.out
   .call.L.stack.4p:
        cmp     [.SAF], 0
        jz     .call.L.stack.out
        add     r15, 8
;       jmp    .call.L.stack.out
   .call.L.stack.out:

   .call.result:
        mov     cx, [.RET]                      ; cl = return type (00001111)
        cmp     cl, 0x0F
        je     .call.result.none                ; void
        cmp     cl, 8
        je     .call.result.I8
        cmp     cl, 4
        je     .call.result.I4
        cmp     cl, 2
        je     .call.result.I2
        cmp     cl, 1
        je     .call.result.I1
        cmp     cl, 1001B ; 0x09
        je     .call.result.D2
        cmp     cl, 1010B ; 0x0A
        je     .call.result.D3
        cmp     cl, 1100B ; 0x0C
        je     .call.result.D4
        jmp    .call.result.double
   .call.result.none:
    $ifdef _SSEX
        ; ----------------------------------------------
        ; XORPD XMM0, XMM0        | 66 0F 57 C0
        ; ----------------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 00], dword 0xC0570F66
        add     rdi, 4
        jmp    .call.result.out
    $else
        ; ----------------------------------------------
        ; FLDZ                    | D9EE
        ; ----------------------------------------------
        @@bound 2, .error.memory
        mov     [rdi + 00], word 0xEED9
        add     rdi, 2
        jmp    .call.result.out
    $end
   .call.result.I1:
        mov     [.int.bytes], 1
        ; ----------------------------------------------
        ; MOVSX RAX, AL           | 480FBEC0
        ; ----------------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 00], dword 0xC0BE0F48
        add     rdi, 4
        jmp    .call.result.out
   .call.result.I2:
        mov     [.int.bytes], 2
        ; ----------------------------------------------
        ; MOVSX RAX, AX           | 480FBFC0
        ; ----------------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 00], dword 0xC0BF0F48
        add     rdi, 4
        jmp    .call.result.out
   .call.result.I4:
        mov     [.int.bytes], 4
        ; ----------------------------------------------
        ; MOVSXD RAX, EAX         | 4863C0
        ; ----------------------------------------------
        @@bound 3, .error.memory
        mov     [rdi + 00], word 0x6348
        mov     [rdi + 02], byte 0xC0
        add     rdi, 3
        jmp    .call.result.out
   .call.result.I8:
        mov     [.int.bytes], 8
        jmp    .call.result.out
   .call.result.D4:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM3, QWORD [RSP-8] | F2 0F 10 5C 24 F8
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM2, QWORD [RSP-8] | F2 0F 10 54 24 F8
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM1, QWORD [RSP-8] | F2 0F 10 4C 24 F8
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [RSP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 40, .error.memory
        mov     [rdi + 00], dword 0xF8245CDD
        mov     [rdi + 04], dword 0x5C100FF2
        mov     [rdi + 08], word 0xF824
        mov     [rdi + 10], dword 0xF8245CDD
        mov     [rdi + 14], dword 0x54100FF2
        mov     [rdi + 18], word 0xF824
        mov     [rdi + 20], dword 0xF8245CDD
        mov     [rdi + 24], dword 0x4C100FF2
        mov     [rdi + 28], word 0xF824
        mov     [rdi + 30], dword 0xF8245CDD
        mov     [rdi + 34], dword 0x44100FF2
        mov     [rdi + 38], word 0xF824
        add     rdi, 40
        jmp    .call.result.out
    $end
        jmp    .call.result.out
   .call.result.D3:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM2, QWORD [RSP-8] | F2 0F 10 54 24 F8
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM1, QWORD [RSP-8] | F2 0F 10 4C 24 F8
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [RSP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 30, .error.memory
        mov     [rdi + 00], dword 0xF8245CDD
        mov     [rdi + 04], dword 0x54100FF2
        mov     [rdi + 08], word 0xF824
        mov     [rdi + 10], dword 0xF8245CDD
        mov     [rdi + 14], dword 0x4C100FF2
        mov     [rdi + 18], word 0xF824
        mov     [rdi + 20], dword 0xF8245CDD
        mov     [rdi + 24], dword 0x44100FF2
        mov     [rdi + 28], word 0xF824
        add     rdi, 30
        jmp    .call.result.out
    $end
        jmp    .call.result.out
   .call.result.D2:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM1, QWORD [RSP-8] | F2 0F 10 4C 24 F8
        ; FSTP        QWORD [RSP-8] | DD 5C 24 F8
        ; MOVSD XMM0, QWORD [RSP-8] | F2 0F 10 44 24 F8
        ; ----------------------------------------------
        @@bound 20, .error.memory
        mov     [rdi + 00], dword 0xF8245CDD
        mov     [rdi + 04], dword 0x4C100FF2
        mov     [rdi + 08], word 0xF824
        mov     [rdi + 10], dword 0xF8245CDD
        mov     [rdi + 14], dword 0x44100FF2
        mov     [rdi + 18], word 0xF824
        add     rdi, 20
        jmp    .call.result.out
    $end
        jmp    .call.result.out
   .call.result.double:
    $ifndef _SSEX
        ; ----------------------------------------------
        ; MOVSD QWORD [RSP-8], XMM0 | F2 0F 11 44 24 F8
        ; FLD   QWORD [RSP-8]       | DD 44 24 F8
        ; ----------------------------------------------
        @@bound 10, .error.memory
        mov     [rdi + 00], dword 0x44110FF2
        mov     [rdi + 04], dword 0x44DDF824
        mov     [rdi + 08], word 0xF824
        add     rdi, 10
;       jmp    .call.result.out
    $end
   .call.result.out:

   .done:
        mov     rcx, [.ezx]                     ; rcx = function argument count
        lea     rdx, [8 * rcx - 8]              ; rdx = (acount - 1) * 8
        dec     rbx
        jnz    .stack
        add     rdx, 8

   .stack:
        inc     rbx                             ; restore rpn items counter
        add     rdx, r15
        cmp     [.frecount], 1
        jle     @F
        mov     rcx, [.frecount]
        lea     rcx, [rcx * 8 - 8]
        sub     rdx, rcx
    @@:
        test    rdx, rdx
        jz     .stack.out
        cmp     rdx, +127
        jg     .stack.dword
        cmp     rdx, -128
        jl     .stack.dword
        ;
   .stack.byte:                                 ; -128 <= RDX <= 127
        add     [.RSP], rdx
        ; --------------------------------------
        ; ADD RSP, FF | 4883C4 FF
        ; --------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 0], dword 0x00C48348
        mov     [rdi + 3], dl
        add     rdi, 4
        jmp    .stack.out
        ;
   .stack.dword:                                ; (RDX < -128) or (RDX > 127)
        add     [.RSP], rdx
        ; --------------------------------------
        ; ADD RSP, FFFFFFFF | 4881C4 FFFFFFFF
        ; --------------------------------------
        @@bound 7, .error.memory
        mov     [rdi + 0], dword 0x00C48148
        mov     [rdi + 3], edx
        add     rdi, 7
;       jmp    .stack.out
        ;
   .stack.out:

   .call..result:
   .call..result.?I:
        cmp     [.fretype], 'i'
        jne    .call..result.I.out
   .call..result.I:
        cmp     rbx, 1                          ; rbx = rpn items counter
        je     .call..result.I.ST0
   .call..result.I.RSP:                         ; function result is parameter of function
        mov     [.firesp], 1                    ; return integer result in RSP
        ; --------------------------------------
        ; MOV   [RSP], RAX  | 48890424
        ; --------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 0], dword 0x24048948
        add     rdi, 4
        jmp    .call..result.out
   .call..result.I.ST0:                         ; return integer result in ST0
    $ifdef _SSEX
        ; --------------------------------------
        ; CVTSI2SD XMM0, RAX | F2480F2AC0
        ; --------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x2A0F48F2
        mov     [rdi + 4], byte 0xC0
        add     rdi, 5
    $else
        ; --------------------------------------
        ; PUSH  RAX         | 50
        ; FILD  QWORD [RSP] | DF2C24
        ; POP   RAX         | 58
        ; --------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x242CDF50
        mov     [rdi + 4], byte 0x58
        add     rdi, 5
    $end
        jmp    .call..result.out
   .call..result.I.out:
        ;
   .call..result.?IX:
        mov     cl, [.int.bytes]
        test    cl, cl
        jz     .call..result.IX.out
   .call..result.IX:
        case    cl,\
                8, .call..result.I8,\
                4, .call..result.I4,\
                2, .call..result.I2,\
                1, .call..result.I1
        jmp    .call..result.out
   .call..result.I8:
   .call..result.I4:
   .call..result.I2:
   .call..result.I1:
        cmp     rbx, 1                          ; rbx = rpn items counter
        je     .call..result.IQ.ST0
   .call..result.IQ.RSP:                        ; function result is parameter of function
        mov     [.firesp], 1                    ; return integer result in RSP
        ; --------------------------------------
        ; MOV   [RSP], RAX  | 48890424
        ; --------------------------------------
        @@bound 4, .error.memory
        mov     [rdi + 0], dword 0x24048948
        add     rdi, 4
        jmp    .call..result.out
   .call..result.IQ.ST0:                        ; return integer result in ST0
    $ifdef _SSEX
        ; --------------------------------------
        ; CVTSI2SD XMM0, RAX | F2480F2AC0
        ; --------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x2A0F48F2
        mov     [rdi + 4], byte 0xC0
        add     rdi, 5
    $else
        ; --------------------------------------
        ; PUSH  RAX         | 50
        ; FILD  QWORD [RSP] | DF2C24
        ; POP   RAX         | 58
        ; --------------------------------------
        @@bound 5, .error.memory
        mov     [rdi + 0], dword 0x242CDF50
        mov     [rdi + 4], byte 0x58
        add     rdi, 5
    $end
;       jmp    .call..result.out
   .call..result.IX.out:
   .call..result.out:

        jmp    .exit

   .error.exit:
        pop     rsi rax
        jmp    .cb.error

   .error.memory:
        pop     rsi rax
        jmp    .cb.error.memory

   .error.argument:
        pop     rsi rax
        jmp    .cb.error.argument

   .error.evaluate:
        pop     rsi rax
        jmp    .cb.error.evaluate

   .error.no.impl:
        pop     rsi rax
        jmp    .cb.error.no.impl

   .error.pointer:
        pop     rsi rax
        jmp    .cb.error.pointer

   .bypass.exit:
        mov     [.fbypass], 1

   .exit:
        pop     rsi rax
}

; ------------------------------------------------------------------------------
